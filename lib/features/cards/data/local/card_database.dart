import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

import '../../domain/card_models.dart';
import '../../../organization/domain/organization_models.dart';
import '../../../purchases/domain/purchase_models.dart';
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

  TextColumn get cardType => text().nullable()();

  BoolColumn get needsCompletion =>
      boolean().withDefault(const Constant(false))();

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

  DateTimeColumn get acquiredAt => dateTime().nullable()();

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

@TableIndex(name: 'idx_card_sets_created_at', columns: {#createdAt})
@TableIndex(name: 'idx_card_sets_deleted_at', columns: {#deletedAt})
class CardSets extends Table {
  TextColumn get id => text()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  IntColumn get expectedCount => integer().nullable()();

  BoolColumn get countKnown => boolean()();

  TextColumn get issueInfo => text().nullable()();

  TextColumn get notes => text().nullable()();

  TextColumn get coverImageId =>
      text().nullable().references(CardImages, #id)();

  IntColumn get version => integer()
      .withDefault(const Constant(1))
      // ignore: recursive_getters, Drift 的 check() 按设计引用列自身。
      .check(version.isBiggerThanValue(0))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  List<String> get customConstraints => <String>[
    'CHECK ((count_known = 0 AND expected_count IS NULL) OR '
        '(count_known = 1 AND expected_count > 0))',
  ];

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@TableIndex(name: 'idx_card_set_members_set_id', columns: {#setId})
@TableIndex(
  name: 'idx_card_set_members_set_sort',
  columns: {#setId, #sortOrder},
)
@TableIndex(
  name: 'idx_card_set_members_definition_id',
  columns: {#definitionId},
)
class CardSetMembers extends Table {
  TextColumn get id => text()();

  TextColumn get setId => text().references(CardSets, #id)();

  TextColumn get definitionId => text().references(CardDefinitions, #id)();

  TextColumn get memberNo => text().nullable()();

  BoolColumn get required => boolean().withDefault(const Constant(true))();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

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

@TableIndex(name: 'idx_tags_deleted_at', columns: {#deletedAt})
@TableIndex(name: 'idx_tags_updated_at', columns: {#updatedAt})
class Tags extends Table {
  TextColumn get id => text()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  TextColumn get normalizedName => text().withLength(min: 1, max: 100)();

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

@TableIndex(name: 'idx_card_tags_tag_id', columns: {#tagId})
@TableIndex(name: 'idx_card_tags_definition_id', columns: {#definitionId})
class CardTags extends Table {
  TextColumn get tagId => text().references(Tags, #id)();

  TextColumn get definitionId => text().references(CardDefinitions, #id)();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{tagId, definitionId};
}

@TableIndex(name: 'idx_series_deleted_at', columns: {#deletedAt})
@TableIndex(name: 'idx_series_updated_at', columns: {#updatedAt})
class SeriesRecords extends Table {
  @override
  String get tableName => 'series_records';

  TextColumn get id => text()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  TextColumn get description => text().nullable()();

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

@TableIndex(name: 'idx_series_cards_definition_id', columns: {#definitionId})
class SeriesCards extends Table {
  TextColumn get seriesId => text().references(SeriesRecords, #id)();

  TextColumn get definitionId => text().references(CardDefinitions, #id)();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{
    seriesId,
    definitionId,
  };
}

@TableIndex(name: 'idx_series_sets_set_id', columns: {#setId})
class SeriesSets extends Table {
  TextColumn get seriesId => text().references(SeriesRecords, #id)();

  TextColumn get setId => text().references(CardSets, #id)();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{seriesId, setId};
}

@TableIndex(name: 'idx_custom_fields_deleted_at', columns: {#deletedAt})
class OrganizationFieldDefinitions extends Table {
  @override
  String get tableName => 'custom_field_definitions';

  TextColumn get id => text()();

  TextColumn get name => text().withLength(min: 1, max: 100)();

  TextColumn get normalizedName => text().withLength(min: 1, max: 100)();

  TextColumn get fieldType => textEnum<CustomFieldType>()();

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

@TableIndex(
  name: 'idx_custom_field_values_definition_id',
  columns: {#definitionId},
)
class OrganizationFieldValues extends Table {
  @override
  String get tableName => 'custom_field_values';

  TextColumn get fieldId =>
      text().references(OrganizationFieldDefinitions, #id)();

  TextColumn get definitionId => text().references(CardDefinitions, #id)();

  TextColumn get textValue => text().nullable()();

  RealColumn get numberValue => real().nullable()();

  DateTimeColumn get dateValue => dateTime().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<String> get customConstraints => <String>[
    'CHECK ((text_value IS NOT NULL) + (number_value IS NOT NULL) + '
        '(date_value IS NOT NULL) = 1)',
  ];

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{fieldId, definitionId};
}

@TableIndex(name: 'idx_purchases_purchased_at', columns: {#purchasedAt})
@TableIndex(name: 'idx_purchases_currency', columns: {#currency})
@TableIndex(name: 'idx_purchases_adjustment_of_id', columns: {#adjustmentOfId})
class Purchases extends Table {
  TextColumn get id => text()();

  DateTimeColumn get purchasedAt => dateTime()();

  IntColumn get amountMinor => integer()();

  TextColumn get currency => text().withLength(min: 3, max: 3)();

  IntColumn get shippingMinor => integer().withDefault(const Constant(0))();

  IntColumn get feesMinor => integer().withDefault(const Constant(0))();

  TextColumn get channel => text().nullable()();

  TextColumn get seller => text().nullable()();

  TextColumn get notes => text().nullable()();

  TextColumn get adjustmentOfId =>
      text().nullable().references(Purchases, #id)();

  IntColumn get version => integer()
      .withDefault(const Constant(1))
      // ignore: recursive_getters, Drift check() references the column itself.
      .check(version.isBiggerThanValue(0))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<String> get customConstraints => <String>[
    'CHECK ('
        '(adjustment_of_id IS NULL AND amount_minor >= 0 '
        'AND shipping_minor >= 0 AND fees_minor >= 0) '
        'OR '
        '(adjustment_of_id IS NOT NULL AND amount_minor < 0 '
        'AND shipping_minor = 0 AND fees_minor = 0)'
        ')',
  ];

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@TableIndex(
  name: 'idx_purchase_items_target',
  columns: {#targetType, #targetId},
)
class PurchaseItems extends Table {
  TextColumn get purchaseId => text().references(Purchases, #id)();

  TextColumn get targetType => textEnum<PurchaseTargetType>()();

  TextColumn get targetId => text()();

  TextColumn get targetName => text()();

  IntColumn get allocatedMinor => integer().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  List<String> get customConstraints => <String>[
    'CHECK (allocated_minor IS NULL OR allocated_minor >= 0)',
  ];

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{
    purchaseId,
    targetType,
    targetId,
  };
}

@TableIndex(
  name: 'idx_exchange_rates_lookup',
  columns: {#baseCurrency, #quoteCurrency, #rateDate},
)
class ExchangeRates extends Table {
  TextColumn get baseCurrency => text().withLength(min: 3, max: 3)();

  TextColumn get quoteCurrency => text().withLength(min: 3, max: 3)();

  DateTimeColumn get rateDate => dateTime()();

  IntColumn get numerator =>
      integer()
      // ignore: recursive_getters, Drift check() references the column itself.
      .check(numerator.isBiggerThanValue(0))();

  IntColumn get denominator =>
      integer()
      // ignore: recursive_getters, Drift check() references the column itself.
      .check(denominator.isBiggerThanValue(0))();

  TextColumn get source => text()();

  DateTimeColumn get capturedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{
    baseCurrency,
    quoteCurrency,
    rateDate,
    source,
  };
}

class RecycleBinSettingsRows extends Table {
  @override
  String get tableName => 'recycle_bin_settings';

  IntColumn get id => integer()();

  IntColumn get retentionDays => integer().withDefault(const Constant(30))();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<String> get customConstraints => <String>[
    'CHECK (id = 1)',
    'CHECK (retention_days IN (7, 30, 90))',
  ];

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

@TableIndex(name: 'idx_file_cleanup_created_at', columns: {#createdAt})
class FileCleanupQueueEntries extends Table {
  @override
  String get tableName => 'file_cleanup_queue';

  TextColumn get relativePath => text()();

  DateTimeColumn get createdAt => dateTime()();

  IntColumn get attemptCount => integer().withDefault(const Constant(0))();

  DateTimeColumn get lastAttemptAt => dateTime().nullable()();

  @override
  List<String> get customConstraints => <String>['CHECK (attempt_count >= 0)'];

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{relativePath};
}

class SyncSettingsRows extends Table {
  @override
  String get tableName => 'sync_settings';

  IntColumn get id => integer()();

  TextColumn get deviceId => text()();

  BoolColumn get enabled => boolean().withDefault(const Constant(false))();

  TextColumn get cursor => text().nullable()();

  TextColumn get accountUserId => text().nullable()();

  TextColumn get accountEmail => text().nullable()();

  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  TextColumn get lastErrorCode => text().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<String> get customConstraints => <String>['CHECK (id = 1)'];

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

class SyncEntityStateRows extends Table {
  @override
  String get tableName => 'sync_entity_states';

  TextColumn get entityType => text()();

  TextColumn get entityId => text()();

  IntColumn get serverVersion => integer()();

  TextColumn get payloadJson => text().nullable()();

  BoolColumn get deleted => boolean().withDefault(const Constant(false))();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<String> get customConstraints => <String>[
    'CHECK (server_version >= 0)',
    'CHECK ((deleted = 0 AND payload_json IS NOT NULL) OR '
        '(deleted = 1 AND payload_json IS NULL))',
  ];

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{entityType, entityId};
}

@TableIndex(
  name: 'idx_sync_outbox_entity',
  columns: {#entityType, #entityId},
  unique: true,
)
@TableIndex(name: 'idx_sync_outbox_due', columns: {#nextAttemptAt, #createdAt})
class SyncOutboxEntries extends Table {
  @override
  String get tableName => 'sync_outbox';

  TextColumn get operationId => text()();

  TextColumn get entityType => text()();

  TextColumn get entityId => text()();

  TextColumn get operation => text()();

  IntColumn get baseServerVersion => integer()();

  TextColumn get payloadJson => text().nullable()();

  TextColumn get changedFieldsJson => text()();

  DateTimeColumn get createdAt => dateTime()();

  IntColumn get attemptCount => integer().withDefault(const Constant(0))();

  DateTimeColumn get nextAttemptAt => dateTime().nullable()();

  TextColumn get lastErrorCode => text().nullable()();

  @override
  List<String> get customConstraints => <String>[
    'CHECK (operation IN (\'upsert\', \'delete\'))',
    'CHECK (base_server_version >= 0)',
    'CHECK (attempt_count >= 0)',
    'CHECK ((operation = \'upsert\' AND payload_json IS NOT NULL) OR '
        '(operation = \'delete\' AND payload_json IS NULL))',
  ];

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{operationId};
}

@TableIndex(
  name: 'idx_sync_conflicts_open',
  columns: {#resolvedAt, #detectedAt},
)
class SyncConflictRows extends Table {
  @override
  String get tableName => 'sync_conflicts';

  TextColumn get id => text()();

  TextColumn get entityType => text()();

  TextColumn get entityId => text()();

  TextColumn get localOperation => text()();

  TextColumn get localPayloadJson => text().nullable()();

  TextColumn get remoteOperation => text()();

  TextColumn get remotePayloadJson => text().nullable()();

  IntColumn get remoteServerVersion => integer()();

  TextColumn get conflictingFieldsJson => text()();

  DateTimeColumn get detectedAt => dateTime()();

  DateTimeColumn get resolvedAt => dateTime().nullable()();

  @override
  List<String> get customConstraints => <String>[
    'CHECK (local_operation IN (\'upsert\', \'delete\'))',
    'CHECK (remote_operation IN (\'upsert\', \'delete\'))',
    'CHECK (remote_server_version > 0)',
  ];

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

@DriftDatabase(
  tables: <Type>[
    CardDefinitions,
    CardItems,
    CardImages,
    CardSets,
    CardSetMembers,
    Tags,
    CardTags,
    SeriesRecords,
    SeriesCards,
    SeriesSets,
    OrganizationFieldDefinitions,
    OrganizationFieldValues,
    Purchases,
    PurchaseItems,
    ExchangeRates,
    RecycleBinSettingsRows,
    FileCleanupQueueEntries,
    SyncSettingsRows,
    SyncEntityStateRows,
    SyncOutboxEntries,
    SyncConflictRows,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createImageIndexes();
      await _createCardSetIndexes();
      await _createOrganizationIndexes();
      await _createPurchaseIndexes();
      await _createRecycleBinIndexes();
      await _createSyncIndexes();
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
      from2To3: (m, schema) async {
        await m.createTable(schema.cardSets);
        await m.createTable(schema.cardSetMembers);
        await _createCardSetIndexes();
      },
      from3To4: (m, schema) async {
        await m.addColumn(
          schema.cardDefinitions,
          schema.cardDefinitions.cardType,
        );
        await m.addColumn(
          schema.cardDefinitions,
          schema.cardDefinitions.needsCompletion,
        );
        await m.addColumn(schema.cardItems, schema.cardItems.acquiredAt);
        await m.createTable(schema.tags);
        await m.createTable(schema.cardTags);
        await m.createTable(schema.seriesRecords);
        await m.createTable(schema.seriesCards);
        await m.createTable(schema.seriesSets);
        await m.createTable(schema.customFieldDefinitions);
        await m.createTable(schema.customFieldValues);
        await _createOrganizationIndexes();
      },
      from4To5: (m, schema) async {
        await m.createTable(schema.purchases);
        await m.createTable(schema.purchaseItems);
        await m.createTable(schema.exchangeRates);
        await _createPurchaseIndexes();
      },
      from5To6: (m, schema) async {
        await m.createTable(schema.recycleBinSettings);
        await m.createTable(schema.fileCleanupQueue);
        await _createRecycleBinIndexes();
      },
      from6To7: (m, schema) async {
        await m.createTable(schema.syncSettings);
        await m.createTable(schema.syncEntityStates);
        await m.createTable(schema.syncOutbox);
        await m.createTable(schema.syncConflicts);
        await _createSyncIndexes();
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

  Future<void> _createCardSetIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_card_sets_created_at '
      'ON card_sets(created_at);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_card_sets_deleted_at '
      'ON card_sets(deleted_at);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_card_set_members_set_id '
      'ON card_set_members(set_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_card_set_members_set_sort '
      'ON card_set_members(set_id, sort_order);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_card_set_members_definition_id '
      'ON card_set_members(definition_id);',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS '
      'idx_card_set_members_active_definition '
      'ON card_set_members(set_id, definition_id) '
      'WHERE deleted_at IS NULL;',
    );
  }

  Future<void> _createOrganizationIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tags_deleted_at '
      'ON tags(deleted_at);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_tags_updated_at '
      'ON tags(updated_at);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_card_tags_tag_id '
      'ON card_tags(tag_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_card_tags_definition_id '
      'ON card_tags(definition_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_series_deleted_at '
      'ON series_records(deleted_at);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_series_updated_at '
      'ON series_records(updated_at);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_series_cards_definition_id '
      'ON series_cards(definition_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_series_sets_set_id '
      'ON series_sets(set_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_custom_fields_deleted_at '
      'ON custom_field_definitions(deleted_at);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_custom_field_values_definition_id '
      'ON custom_field_values(definition_id);',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_tags_active_normalized_name '
      'ON tags(normalized_name) WHERE deleted_at IS NULL;',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS '
      'idx_custom_fields_active_normalized_name '
      'ON custom_field_definitions(normalized_name) '
      'WHERE deleted_at IS NULL;',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_card_definitions_card_type '
      'ON card_definitions(card_type);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_card_definitions_needs_completion '
      'ON card_definitions(needs_completion);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_card_definitions_issued_at '
      'ON card_definitions(issued_at);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_card_items_acquired_at '
      'ON card_items(acquired_at);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_series_name '
      'ON series_records(name);',
    );
  }

  Future<void> _createPurchaseIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_purchases_purchased_at '
      'ON purchases(purchased_at);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_purchases_currency '
      'ON purchases(currency);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_purchases_adjustment_of_id '
      'ON purchases(adjustment_of_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_purchase_items_target '
      'ON purchase_items(target_type, target_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_exchange_rates_lookup '
      'ON exchange_rates(base_currency, quote_currency, rate_date);',
    );
  }

  Future<void> _createRecycleBinIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_file_cleanup_created_at '
      'ON file_cleanup_queue(created_at);',
    );
  }

  Future<void> _createSyncIndexes() async {
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_sync_outbox_entity '
      'ON sync_outbox(entity_type, entity_id);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_outbox_due '
      'ON sync_outbox(next_attempt_at, created_at);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_conflicts_open '
      'ON sync_conflicts(resolved_at, detected_at);',
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

  /// 更新卡片定义与藏品数量，不影响图片、标签和集卡册归属。
  Future<void> updateCardBase({
    required UpdateCardRequest request,
    required DateTime updatedAt,
  }) {
    return transaction(() async {
      final item =
          await (select(cardItems)..where(
                (row) =>
                    row.id.equals(request.cardItemId) & row.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      if (item == null) throw StateError('卡片不存在。');

      final definition = await (select(
        cardDefinitions,
      )..where((row) => row.id.equals(item.definitionId))).getSingleOrNull();
      if (definition == null) throw StateError('卡片资料不存在。');

      final definitionChanged =
          await (update(
            cardDefinitions,
          )..where((row) => row.id.equals(definition.id))).write(
            CardDefinitionsCompanion(
              name: Value(request.name),
              city: Value<String?>(request.city),
              issuer: Value<String?>(request.issuer),
              issuedAt: Value<String?>(request.issuedAt?.toIsoString()),
              code: Value<String?>(request.code),
              notes: Value<String?>(request.notes),
              updatedAt: Value(updatedAt),
              version: Value(definition.version + 1),
            ),
          );
      final itemChanged =
          await (update(
            cardItems,
          )..where((row) => row.id.equals(request.cardItemId))).write(
            CardItemsCompanion(
              quantity: Value(request.quantity),
              updatedAt: Value(updatedAt),
              version: Value(item.version + 1),
            ),
          );
      if (definitionChanged != 1 || itemChanged != 1) {
        throw StateError('卡片不存在。');
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
        throw StateError('每次请选择 1 到 20 张图片。');
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
      final target = active.cast<CardImage?>().firstWhere(
        (image) => image!.id == imageId,
        orElse: () => null,
      );
      if (target == null) throw StateError('图片不存在。');

      final coveringSets = await (select(
        cardSets,
      )..where((set) => set.coverImageId.equals(imageId))).get();
      for (final set in coveringSets) {
        await (update(
          cardSets,
        )..where((entry) => entry.id.equals(set.id))).write(
          CardSetsCompanion(
            coverImageId: const Value<String?>(null),
            updatedAt: Value(deletedAt),
            version: Value(set.version + 1),
          ),
        );
      }

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

  /// 仅供测试构造回收站状态。Feature 007 才提供生产删除与恢复入口。
  @visibleForTesting
  Future<void> softDeleteItemForTest(String cardItemId, DateTime deletedAt) {
    return setItemDeletedAtForTest(cardItemId, deletedAt);
  }

  @visibleForTesting
  Future<void> setItemDeletedAtForTest(String cardItemId, DateTime? deletedAt) {
    return (update(cardItems)..where((item) => item.id.equals(cardItemId)))
        .write(CardItemsCompanion(deletedAt: Value(deletedAt)));
  }
}
