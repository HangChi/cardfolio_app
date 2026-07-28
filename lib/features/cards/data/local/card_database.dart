import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

import '../../domain/card_models.dart';
import 'card_database.steps.dart';

part 'card_database.g.dart';

/// 卡片定义：同一款卡的公共资料，可被多个藏品实例引用。
///
/// 通用列（`version`、`createdAt`、`updatedAt`、`deletedAt`）遵循
/// `docs/architecture/database-schema.md` §1；`version` 由 ADR-006 要求，
/// 供后续同步做乐观并发判断。
@TableIndex(name: 'idx_card_definitions_deleted_at', columns: {#deletedAt})
class CardDefinitions extends Table {
  TextColumn get id => text()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  TextColumn get city => text().nullable()();

  TextColumn get issuer => text().nullable()();

  /// 部分日期的规范化文本：`YYYY`、`YYYY-MM` 或 `YYYY-MM-DD`。
  TextColumn get issuedAt => text().nullable()();

  TextColumn get code => text().nullable()();

  TextColumn get notes => text().nullable()();

  IntColumn get version => integer()
      .withDefault(const Constant(1))
      // ignore: recursive_getters, Drift 的 check() 按设计引用列自身。
      .check(version.isBiggerThanValue(0))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// 藏品实例：用户实际拥有的那一份。`id` 同时是创建操作的幂等键。
@TableIndex(name: 'idx_card_items_definition_id', columns: {#definitionId})
@TableIndex(name: 'idx_card_items_deleted_at', columns: {#deletedAt})
@TableIndex(name: 'idx_card_items_created_at', columns: {#createdAt})
class CardItems extends Table {
  TextColumn get id => text()();

  TextColumn get definitionId => text().references(CardDefinitions, #id)();

  IntColumn get quantity => integer()
      .withDefault(const Constant(1))
      // ignore: recursive_getters, Drift 的 check() 按设计引用列自身。
      .check(quantity.isBiggerThanValue(0))();

  IntColumn get version => integer()
      .withDefault(const Constant(1))
      // ignore: recursive_getters, Drift 的 check() 按设计引用列自身。
      .check(version.isBiggerThanValue(0))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  /// 软删除标记。Feature 001 恒为 null。
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// 受管图片。只保存相对路径，绝不保存绝对路径。
@TableIndex(name: 'idx_card_images_card_item_id', columns: {#cardItemId})
@TableIndex(name: 'idx_card_images_sort_order', columns: {#sortOrder})
class CardImages extends Table {
  TextColumn get id => text()();

  TextColumn get cardItemId => text().references(CardItems, #id)();

  TextColumn get kind => textEnum<CardImageKind>()();

  /// 相对于受管图片根目录的路径，全库唯一。
  TextColumn get relativePath => text().unique()();

  /// 可选派生图。原图不可被裁切或增强结果覆盖。
  TextColumn get derivedRelativePath => text().nullable()();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  BoolColumn get isCover => boolean().withDefault(const Constant(false))();

  /// 源文件 SHA-256，用于完整性校验与去重判断。
  TextColumn get checksum => text()();

  DateTimeColumn get createdAt => dateTime()();

  /// 保留原图地从图集移除时写入；默认查询排除。
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// 一次建卡写入涉及的全部行。三张表在同一事务内插入。
class CardRowGraph {
  const CardRowGraph({
    required this.definition,
    required this.item,
    required this.images,
  });

  final CardDefinitionsCompanion definition;
  final CardItemsCompanion item;
  final List<CardImagesCompanion> images;
}

/// 删除图片事务返回的文件信息。
class RemovedImageRecord {
  const RemovedImageRecord({
    required this.relativePath,
    required this.derivedRelativePath,
    required this.wasCover,
  });

  final String relativePath;
  final String? derivedRelativePath;
  final bool wasCover;
}

@DriftDatabase(tables: <Type>[CardDefinitions, CardItems, CardImages])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createImageIndexes();
    },
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await m.addColumn(
          schema.cardImages,
          schema.cardImages.derivedRelativePath,
        );
        await m.addColumn(schema.cardImages, schema.cardImages.isCover);
        await m.addColumn(schema.cardImages, schema.cardImages.deletedAt);
        await customStatement('UPDATE card_images SET is_cover = 1;');
        await _createImageIndexes();
      },
    ),
    beforeOpen: (details) async {
      // 外键约束默认关闭，必须在每个连接上显式启用。
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );

  Future<void> _createImageIndexes() async {
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_card_images_active_cover '
      'ON card_images(card_item_id) '
      'WHERE is_cover = 1 AND deleted_at IS NULL;',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_card_images_derived_path '
      'ON card_images(derived_relative_path) '
      'WHERE derived_relative_path IS NOT NULL;',
    );
  }

  /// 在单个事务中插入定义、藏品与图片。任一步失败则整体回滚。
  Future<void> insertCardGraph(CardRowGraph graph) {
    return transaction(() async {
      await into(cardDefinitions).insert(graph.definition);
      await into(cardItems).insert(graph.item);
      for (final image in graph.images) {
        await into(cardImages).insert(image);
      }
    });
  }

  /// 观察未删除卡片摘要，按创建时间倒序，ID 作为稳定兜底排序。
  Stream<List<CardSummary>> watchCardSummaries() {
    final cover = alias(cardImages, 'cover');
    final query = select(cardItems).join(<Join<HasResultSet, dynamic>>[
      innerJoin(
        cardDefinitions,
        cardDefinitions.id.equalsExp(cardItems.definitionId),
      ),
      leftOuterJoin(
        cover,
        cover.cardItemId.equalsExp(cardItems.id) &
            cover.isCover.equals(true) &
            cover.deletedAt.isNull(),
      ),
    ])..where(cardItems.deletedAt.isNull());

    query.orderBy(<OrderingTerm>[
      OrderingTerm.desc(cardItems.createdAt),
      OrderingTerm.desc(cardItems.id),
    ]);

    return query.watch().map(
      (rows) => rows
          .map((row) {
            final item = row.readTable(cardItems);
            final definition = row.readTable(cardDefinitions);
            return CardSummary(
              cardItemId: item.id,
              name: definition.name,
              quantity: item.quantity,
              createdAt: item.createdAt.toUtc(),
              coverRelativePath: row.readTableOrNull(cover)?.relativePath,
              city: definition.city,
              issuedAt: PartialDate.tryParse(definition.issuedAt),
            );
          })
          .toList(growable: false),
    );
  }

  /// 观察单张卡片详情。记录不存在或已软删除时发出 null。
  ///
  /// 使用一次联表查询而非嵌套流：图片左连接会为每张图片产生一行，在映射阶段
  /// 归并即可，同时保证三张表任一变化都会重新推送。
  Stream<CardDetail?> watchCardDetail(String cardItemId) {
    final query = select(cardItems).join(<Join<HasResultSet, dynamic>>[
      innerJoin(
        cardDefinitions,
        cardDefinitions.id.equalsExp(cardItems.definitionId),
      ),
      leftOuterJoin(
        cardImages,
        cardImages.cardItemId.equalsExp(cardItems.id) &
            cardImages.deletedAt.isNull(),
      ),
    ])..where(cardItems.id.equals(cardItemId) & cardItems.deletedAt.isNull());

    query.orderBy(<OrderingTerm>[
      OrderingTerm.asc(cardImages.sortOrder),
      OrderingTerm.asc(cardImages.id),
    ]);

    return query.watch().map((rows) {
      if (rows.isEmpty) return null;

      final item = rows.first.readTable(cardItems);
      final definition = rows.first.readTable(cardDefinitions);
      final images = rows
          .map((row) => row.readTableOrNull(cardImages))
          .nonNulls
          .map(
            (image) => CardImageRef(
              id: image.id,
              relativePath: image.relativePath,
              derivedRelativePath: image.derivedRelativePath,
              kind: image.kind,
              sortOrder: image.sortOrder,
              isCover: image.isCover,
            ),
          )
          .toList(growable: false);

      return CardDetail(
        cardItemId: item.id,
        definitionId: definition.id,
        name: definition.name,
        quantity: item.quantity,
        createdAt: item.createdAt.toUtc(),
        updatedAt: item.updatedAt.toUtc(),
        images: images,
        city: definition.city,
        issuer: definition.issuer,
        issuedAt: PartialDate.tryParse(definition.issuedAt),
        code: definition.code,
        notes: definition.notes,
      );
    });
  }

  Future<bool> cardItemExists(String cardItemId) async {
    final query = selectOnly(cardItems)
      ..addColumns(<Expression<Object>>[cardItems.id])
      ..where(cardItems.id.equals(cardItemId))
      ..limit(1);

    return await query.getSingleOrNull() != null;
  }

  /// 向藏品追加一批图片。调用方先完成文件导入，本事务只提交元数据。
  Future<void> addImages({
    required String cardItemId,
    required List<CardImagesCompanion> images,
    required DateTime updatedAt,
  }) {
    return transaction(() async {
      final active = await _activeImages(cardItemId);
      if (images.isEmpty ||
          active.length + images.length > CreateCardRequest.maxImages) {
        throw StateError('每张卡片必须保存 1 到 20 张图片。');
      }
      for (final image in images) {
        await into(cardImages).insert(image);
      }
      await _touchItem(cardItemId, updatedAt);
    });
  }

  Future<void> updateImageKind({
    required String cardItemId,
    required String imageId,
    required CardImageKind kind,
    required DateTime updatedAt,
  }) {
    return transaction(() async {
      final changed =
          await (update(cardImages)..where(
                (image) =>
                    image.id.equals(imageId) &
                    image.cardItemId.equals(cardItemId) &
                    image.deletedAt.isNull(),
              ))
              .write(CardImagesCompanion(kind: Value(kind)));
      if (changed != 1) throw StateError('图片不存在。');
      await _touchItem(cardItemId, updatedAt);
    });
  }

  Future<void> setCover({
    required String cardItemId,
    required String imageId,
    required DateTime updatedAt,
  }) {
    return transaction(() async {
      final target = await _activeImage(cardItemId, imageId);
      if (target == null) throw StateError('图片不存在。');
      await (update(cardImages)..where(
            (image) =>
                image.cardItemId.equals(cardItemId) & image.deletedAt.isNull(),
          ))
          .write(const CardImagesCompanion(isCover: Value(false)));
      await (update(cardImages)..where((image) => image.id.equals(imageId)))
          .write(const CardImagesCompanion(isCover: Value(true)));
      await _touchItem(cardItemId, updatedAt);
    });
  }

  Future<void> reorderImages({
    required String cardItemId,
    required List<String> orderedImageIds,
    required DateTime updatedAt,
  }) {
    return transaction(() async {
      final active = await _activeImages(cardItemId);
      final activeIds = active.map((image) => image.id).toSet();
      if (orderedImageIds.length != active.length ||
          orderedImageIds.toSet().length != orderedImageIds.length ||
          !orderedImageIds.every(activeIds.contains)) {
        throw StateError('图片顺序已变化，请刷新后重试。');
      }
      for (var index = 0; index < orderedImageIds.length; index++) {
        await (update(cardImages)
              ..where((image) => image.id.equals(orderedImageIds[index])))
            .write(CardImagesCompanion(sortOrder: Value(index)));
      }
      await _touchItem(cardItemId, updatedAt);
    });
  }

  Future<RemovedImageRecord> removeImage({
    required String cardItemId,
    required String imageId,
    required bool keepOriginal,
    required DateTime deletedAt,
  }) {
    return transaction(() async {
      final active = await _activeImages(cardItemId);
      if (active.length <= 1) {
        throw StateError('每张卡片至少保留一张图片。');
      }
      final target = active.cast<CardImage?>().firstWhere(
        (image) => image!.id == imageId,
        orElse: () => null,
      );
      if (target == null) throw StateError('图片不存在。');

      if (keepOriginal) {
        await (update(
          cardImages,
        )..where((image) => image.id.equals(imageId))).write(
          CardImagesCompanion(
            isCover: const Value(false),
            deletedAt: Value(deletedAt),
          ),
        );
      } else {
        await (delete(
          cardImages,
        )..where((image) => image.id.equals(imageId))).go();
      }

      final remaining = active
          .where((image) => image.id != imageId)
          .toList(growable: false);
      for (var index = 0; index < remaining.length; index++) {
        final promote = target.isCover && index == 0;
        await (update(
          cardImages,
        )..where((image) => image.id.equals(remaining[index].id))).write(
          CardImagesCompanion(
            sortOrder: Value(index),
            isCover: promote ? const Value(true) : const Value.absent(),
          ),
        );
      }
      await _touchItem(cardItemId, deletedAt);
      return RemovedImageRecord(
        relativePath: target.relativePath,
        derivedRelativePath: target.derivedRelativePath,
        wasCover: target.isCover,
      );
    });
  }

  Future<CardImage?> activeImage(String cardItemId, String imageId) =>
      _activeImage(cardItemId, imageId);

  Future<List<CardImage>> _activeImages(String cardItemId) {
    final query = select(cardImages)
      ..where(
        (image) =>
            image.cardItemId.equals(cardItemId) & image.deletedAt.isNull(),
      )
      ..orderBy(<OrderingTerm Function(CardImages)>[
        (image) => OrderingTerm.asc(image.sortOrder),
        (image) => OrderingTerm.asc(image.id),
      ]);
    return query.get();
  }

  Future<CardImage?> _activeImage(String cardItemId, String imageId) {
    final query = select(cardImages)
      ..where(
        (image) =>
            image.id.equals(imageId) &
            image.cardItemId.equals(cardItemId) &
            image.deletedAt.isNull(),
      );
    return query.getSingleOrNull();
  }

  Future<void> _touchItem(String cardItemId, DateTime updatedAt) async {
    final item = await (select(
      cardItems,
    )..where((item) => item.id.equals(cardItemId))).getSingleOrNull();
    if (item == null) throw StateError('卡片不存在。');
    final changed =
        await (update(
          cardItems,
        )..where((item) => item.id.equals(cardItemId))).write(
          CardItemsCompanion(
            updatedAt: Value(updatedAt),
            version: Value(item.version + 1),
          ),
        );
    if (changed != 1) throw StateError('卡片不存在。');
  }

  /// 数据库当前引用的全部图片相对路径。
  ///
  /// 包含软删除卡片的图片：回收站里的卡片恢复后仍需要它们，清理孤儿文件时
  /// 不得当作无引用删除。
  Future<Set<String>> referencedImagePaths() async {
    final query = selectOnly(cardImages)
      ..addColumns(<Expression<Object>>[
        cardImages.relativePath,
        cardImages.derivedRelativePath,
      ]);

    final rows = await query.get();
    return rows.expand((row) sync* {
      yield row.read(cardImages.relativePath)!;
      final derived = row.read(cardImages.derivedRelativePath);
      if (derived != null) yield derived;
    }).toSet();
  }

  Future<int> countDefinitions() => _countRows(cardDefinitions);

  Future<int> countItems() => _countRows(cardItems);

  Future<int> countImages() => _countRows(cardImages);

  Future<int> _countRows(TableInfo<Table, dynamic> table) async {
    final count = countAll();
    final query = selectOnly(table)..addColumns(<Expression<Object>>[count]);
    return (await query.getSingle()).read(count)!;
  }

  /// 仅供测试构造回收站状态。Feature 001 的生产代码不提供删除。
  @visibleForTesting
  Future<void> softDeleteItemForTest(String cardItemId, DateTime deletedAt) {
    return (update(cardItems)..where((item) => item.id.equals(cardItemId)))
        .write(CardItemsCompanion(deletedAt: Value(deletedAt)));
  }
}
