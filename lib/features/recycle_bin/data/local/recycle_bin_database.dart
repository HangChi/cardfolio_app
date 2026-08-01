import 'package:drift/drift.dart';

import '../../../cards/data/local/card_database.dart';
import '../../../purchases/domain/purchase_models.dart';
import '../../domain/recycle_bin_models.dart';

extension RecycleBinDatabase on AppDatabase {
  Stream<List<RecycleBinEntry>> watchRecycleBinEntries() {
    return customSelect(
      '''
      SELECT ci.id AS card_item_id,
             cd.name AS name,
             ci.deleted_at AS deleted_at,
             (
               SELECT COUNT(*)
                 FROM card_images count_image
                WHERE count_image.card_item_id = ci.id
             ) AS image_count,
             (
               SELECT cover.relative_path
                 FROM card_images cover
                WHERE cover.card_item_id = ci.id
                ORDER BY cover.deleted_at IS NULL DESC,
                         cover.is_cover DESC,
                         cover.sort_order ASC,
                         cover.id ASC
                LIMIT 1
             ) AS cover_path
        FROM card_items ci
        JOIN card_definitions cd ON cd.id = ci.definition_id
       WHERE ci.deleted_at IS NOT NULL
       ORDER BY ci.deleted_at DESC, ci.id DESC
      ''',
      readsFrom: <ResultSetImplementation<Table, Object?>>{
        cardItems,
        cardDefinitions,
        cardImages,
      },
    ).watch().map(
      (rows) => rows
          .map(
            (row) => RecycleBinEntry(
              cardItemId: row.read<String>('card_item_id'),
              name: row.read<String>('name'),
              deletedAt: _timestamp(row.read<int>('deleted_at')),
              imageCount: row.read<int>('image_count'),
              coverRelativePath: row.readNullable<String>('cover_path'),
            ),
          )
          .toList(growable: false),
    );
  }

  Future<void> softDeleteCard(String cardItemId, DateTime deletedAt) async {
    await transaction(() async {
      final item = await (select(
        cardItems,
      )..where((row) => row.id.equals(cardItemId))).getSingleOrNull();
      if (item == null || item.deletedAt != null) return;
      await (update(
        cardItems,
      )..where((row) => row.id.equals(cardItemId))).write(
        CardItemsCompanion(
          deletedAt: Value(deletedAt.toUtc()),
          updatedAt: Value(deletedAt.toUtc()),
          version: Value(item.version + 1),
        ),
      );
    });
  }

  Future<void> restoreCard(String cardItemId, DateTime restoredAt) async {
    await transaction(() async {
      final item = await (select(
        cardItems,
      )..where((row) => row.id.equals(cardItemId))).getSingleOrNull();
      if (item == null || item.deletedAt == null) return;
      await (update(
        cardItems,
      )..where((row) => row.id.equals(cardItemId))).write(
        CardItemsCompanion(
          deletedAt: const Value<DateTime?>(null),
          updatedAt: Value(restoredAt.toUtc()),
          version: Value(item.version + 1),
        ),
      );
    });
  }

  Future<PermanentDeletionImpact> previewPermanentDeletion(
    String cardItemId,
  ) async {
    final item =
        await (select(cardItems)
              ..where((row) => row.id.equals(cardItemId))
              ..where((row) => row.deletedAt.isNotNull()))
            .getSingleOrNull();
    if (item == null) throw StateError('卡片不在回收站中。');

    final images = await (select(
      cardImages,
    )..where((row) => row.cardItemId.equals(cardItemId))).get();
    final paths = <String>{
      for (final image in images) image.relativePath,
      for (final image in images)
        if (image.derivedRelativePath != null) image.derivedRelativePath!,
    };
    final purchaseCount = countAll();
    final purchaseQuery = selectOnly(purchaseItems)
      ..addColumns(<Expression<Object>>[purchaseCount])
      ..where(
        purchaseItems.targetType.equalsValue(PurchaseTargetType.card) &
            purchaseItems.targetId.equals(cardItemId),
      );
    final associations =
        (await purchaseQuery.getSingle()).read(purchaseCount) ?? 0;
    return PermanentDeletionImpact(
      imageCount: images.length,
      fileCount: paths.length,
      purchaseAssociationCount: associations,
    );
  }

  Future<void> permanentlyDeleteCard(String cardItemId, DateTime queuedAt) {
    return transaction(() async {
      final item = await (select(
        cardItems,
      )..where((row) => row.id.equals(cardItemId))).getSingleOrNull();
      if (item == null) return;
      if (item.deletedAt == null) throw StateError('卡片不在回收站中。');

      final images = await (select(
        cardImages,
      )..where((row) => row.cardItemId.equals(cardItemId))).get();
      final paths = <String>{
        for (final image in images) image.relativePath,
        for (final image in images)
          if (image.derivedRelativePath != null) image.derivedRelativePath!,
      };
      await _clearSeriesCoverReferences(this, paths, queuedAt.toUtc());
      for (final path in paths) {
        await into(fileCleanupQueueEntries).insert(
          FileCleanupQueueEntriesCompanion.insert(
            relativePath: path,
            createdAt: queuedAt.toUtc(),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }

      final imageIds = images.map((image) => image.id).toList(growable: false);
      if (imageIds.isNotEmpty) {
        final coveringSets = await (select(
          cardSets,
        )..where((set) => set.coverImageId.isIn(imageIds))).get();
        for (final set in coveringSets) {
          await (update(cardSets)..where((row) => row.id.equals(set.id))).write(
            CardSetsCompanion(
              coverImageId: const Value<String?>(null),
              updatedAt: Value(queuedAt.toUtc()),
              version: Value(set.version + 1),
            ),
          );
        }
      }
      await (delete(purchaseItems)..where(
            (row) =>
                row.targetType.equalsValue(PurchaseTargetType.card) &
                row.targetId.equals(cardItemId),
          ))
          .go();
      await (delete(
        cardImages,
      )..where((row) => row.cardItemId.equals(cardItemId))).go();
      await (delete(cardItems)..where((row) => row.id.equals(cardItemId))).go();
    });
  }

  Stream<RecycleBinSettings> watchRecycleBinSettings() {
    return select(recycleBinSettingsRows).watch().map((rows) {
      return RecycleBinSettings(
        retentionDays: rows.isEmpty
            ? RecycleBinSettings.defaultRetentionDays
            : rows.single.retentionDays,
      );
    });
  }

  Future<int> currentRecycleBinRetentionDays() async {
    final row = await select(recycleBinSettingsRows).getSingleOrNull();
    return row?.retentionDays ?? RecycleBinSettings.defaultRetentionDays;
  }

  Future<void> updateRecycleBinRetention(int days, DateTime updatedAt) async {
    if (!RecycleBinSettings.isSupported(days)) {
      throw ArgumentError.value(days, 'days');
    }
    await into(recycleBinSettingsRows).insertOnConflictUpdate(
      RecycleBinSettingsRowsCompanion.insert(
        id: const Value(1),
        retentionDays: Value(days),
        updatedAt: updatedAt.toUtc(),
      ),
    );
  }

  Future<List<String>> expiredRecycleBinIds({
    required DateTime nowUtc,
    required int retentionDays,
  }) async {
    if (!RecycleBinSettings.isSupported(retentionDays)) {
      throw ArgumentError.value(retentionDays, 'retentionDays');
    }
    final cutoff = nowUtc.toUtc().subtract(Duration(days: retentionDays));
    final query = selectOnly(cardItems)
      ..addColumns(<Expression<Object>>[cardItems.id])
      ..where(
        cardItems.deletedAt.isNotNull() &
            cardItems.deletedAt.isSmallerOrEqualValue(cutoff),
      )
      ..orderBy(<OrderingTerm>[
        OrderingTerm.asc(cardItems.deletedAt),
        OrderingTerm.asc(cardItems.id),
      ]);
    return (await query.get())
        .map((row) => row.read(cardItems.id)!)
        .toList(growable: false);
  }

  Future<List<FileCleanupQueueEntry>> pendingFileCleanup() {
    return (select(fileCleanupQueueEntries)
          ..orderBy(<OrderingTerm Function(FileCleanupQueueEntries)>[
            (row) => OrderingTerm.asc(row.createdAt),
            (row) => OrderingTerm.asc(row.relativePath),
          ]))
        .get();
  }

  Future<void> completeFileCleanup(String relativePath) {
    return (delete(
      fileCleanupQueueEntries,
    )..where((row) => row.relativePath.equals(relativePath))).go();
  }

  Future<void> markFileCleanupAttempt(
    String relativePath,
    DateTime attemptedAt,
  ) async {
    final row =
        await (select(fileCleanupQueueEntries)
              ..where((entry) => entry.relativePath.equals(relativePath)))
            .getSingleOrNull();
    if (row == null) return;
    await (update(
      fileCleanupQueueEntries,
    )..where((entry) => entry.relativePath.equals(relativePath))).write(
      FileCleanupQueueEntriesCompanion(
        attemptCount: Value(row.attemptCount + 1),
        lastAttemptAt: Value(attemptedAt.toUtc()),
      ),
    );
  }
}

DateTime _timestamp(int seconds) =>
    DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);

Future<void> _clearSeriesCoverReferences(
  AppDatabase db,
  Set<String> paths,
  DateTime updatedAt,
) async {
  if (paths.isEmpty) return;
  final coveringSeries = await (db.select(
    db.seriesRecords,
  )..where((series) => series.coverRelativePath.isIn(paths))).get();
  for (final series in coveringSeries) {
    await (db.update(
      db.seriesRecords,
    )..where((entry) => entry.id.equals(series.id))).write(
      SeriesRecordsCompanion(
        coverRelativePath: const Value<String?>(null),
        updatedAt: Value(updatedAt),
        version: Value(series.version + 1),
      ),
    );
  }
}
