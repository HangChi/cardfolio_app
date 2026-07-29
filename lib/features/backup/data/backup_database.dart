import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import '../../cards/data/local/card_database.dart';
import '../domain/backup_models.dart';

final class BackupSnapshot {
  BackupSnapshot._(this._entities);

  factory BackupSnapshot.fromJson(Object? value) {
    final json = _asObject(value, '备份数据无效。');
    if (json['logicalSchemaVersion'] != logicalSchemaVersion) {
      throw const BackupCompatibilityFailure('备份数据版本不受支持。');
    }
    final rawEntities = _asObject(json['entities'], '备份实体列表无效。');
    if (rawEntities.keys.toSet().difference(entityNames.toSet()).isNotEmpty ||
        entityNames.any((name) => !rawEntities.containsKey(name))) {
      throw const BackupValidationFailure('备份实体列表不完整。');
    }

    final entities = <String, List<Map<String, Object?>>>{};
    var total = 0;
    for (final name in entityNames) {
      final rawRows = rawEntities[name];
      if (rawRows is! List<Object?>) {
        throw const BackupValidationFailure('备份实体数据无效。');
      }
      total += rawRows.length;
      if (total > BackupLimits.maxEntries) {
        throw const BackupValidationFailure('备份实体数量超出安全限制。');
      }
      entities[name] = rawRows
          .map((row) => _asObject(row, '备份实体字段无效。'))
          .toList(growable: false);
    }
    return BackupSnapshot._(entities);
  }

  static const int logicalSchemaVersion = 1;
  static const List<String> entityNames = <String>[
    'cardDefinitions',
    'cardItems',
    'cardImages',
    'cardSets',
    'cardSetMembers',
    'tags',
    'cardTags',
    'seriesRecords',
    'seriesCards',
    'seriesSets',
    'customFieldDefinitions',
    'customFieldValues',
    'purchases',
    'purchaseItems',
    'exchangeRates',
    'recycleBinSettings',
    'fileCleanupQueue',
  ];

  final Map<String, List<Map<String, Object?>>> _entities;

  List<Map<String, Object?>> rows(String name) => _entities[name]!;

  Map<String, int> get entityCounts => <String, int>{
    for (final name in entityNames) name: rows(name).length,
  };

  int get totalEntityCount =>
      entityCounts.values.fold<int>(0, (sum, count) => sum + count);

  Map<String, Object?> toJson() => <String, Object?>{
    'logicalSchemaVersion': logicalSchemaVersion,
    'entities': <String, Object?>{
      for (final name in entityNames)
        name: rows(
          name,
        ).map((row) => Map<String, Object?>.from(row)).toList(growable: false),
    },
  };
}

final class LogicalImportPreview {
  const LogicalImportPreview({
    required this.addedCount,
    required this.skippedCount,
    required this.conflicts,
  });

  final int addedCount;
  final int skippedCount;
  final List<BackupConflict> conflicts;
}

final class LogicalImportResult {
  const LogicalImportResult({
    required this.addedCount,
    required this.skippedCount,
  });

  final int addedCount;
  final int skippedCount;
}

extension BackupDatabase on AppDatabase {
  Future<BackupSnapshot> exportLogicalBackup() {
    return transaction(() async {
      final entities = <String, Object?>{
        'cardDefinitions': await _readRows(
          await select(cardDefinitions).get(),
          (row) => row.toJson(serializer: _utcSerializer),
          (row) => row.id,
        ),
        'cardItems': await _readRows(
          await select(cardItems).get(),
          (row) => row.toJson(serializer: _utcSerializer),
          (row) => row.id,
        ),
        'cardImages': await _readRows(
          await select(cardImages).get(),
          (row) => row.toJson(serializer: _utcSerializer),
          (row) => row.id,
        ),
        'cardSets': await _readRows(
          await select(cardSets).get(),
          (row) => row.toJson(serializer: _utcSerializer),
          (row) => row.id,
        ),
        'cardSetMembers': await _readRows(
          await select(cardSetMembers).get(),
          (row) => row.toJson(serializer: _utcSerializer),
          (row) => row.id,
        ),
        'tags': await _readRows(
          await select(tags).get(),
          (row) => row.toJson(serializer: _utcSerializer),
          (row) => row.id,
        ),
        'cardTags': await _readRows(
          await select(cardTags).get(),
          (row) => row.toJson(serializer: _utcSerializer),
          (row) => '${row.tagId}\u0000${row.definitionId}',
        ),
        'seriesRecords': await _readRows(
          await select(seriesRecords).get(),
          (row) => row.toJson(serializer: _utcSerializer),
          (row) => row.id,
        ),
        'seriesCards': await _readRows(
          await select(seriesCards).get(),
          (row) => row.toJson(serializer: _utcSerializer),
          (row) => '${row.seriesId}\u0000${row.definitionId}',
        ),
        'seriesSets': await _readRows(
          await select(seriesSets).get(),
          (row) => row.toJson(serializer: _utcSerializer),
          (row) => '${row.seriesId}\u0000${row.setId}',
        ),
        'customFieldDefinitions': await _readRows(
          await select(organizationFieldDefinitions).get(),
          (row) => row.toJson(serializer: _utcSerializer),
          (row) => row.id,
        ),
        'customFieldValues': await _readRows(
          await select(organizationFieldValues).get(),
          (row) => row.toJson(serializer: _utcSerializer),
          (row) => '${row.fieldId}\u0000${row.definitionId}',
        ),
        'purchases': await _readRows(
          await select(purchases).get(),
          (row) => row.toJson(serializer: _utcSerializer),
          (row) => row.id,
        ),
        'purchaseItems': await _readRows(
          await select(purchaseItems).get(),
          (row) => row.toJson(serializer: _utcSerializer),
          (row) =>
              '${row.purchaseId}\u0000${row.targetType.name}'
              '\u0000${row.targetId}',
        ),
        'exchangeRates': await _readRows(
          await select(exchangeRates).get(),
          (row) => row.toJson(serializer: _utcSerializer),
          (row) =>
              '${row.baseCurrency}\u0000${row.quoteCurrency}'
              '\u0000${row.rateDate.toUtc().toIso8601String()}'
              '\u0000${row.source}',
        ),
        'recycleBinSettings': await _readRows(
          await select(recycleBinSettingsRows).get(),
          (row) => row.toJson(serializer: _utcSerializer),
          (row) => row.id.toString(),
        ),
        'fileCleanupQueue': await _readRows(
          await select(fileCleanupQueueEntries).get(),
          (row) => row.toJson(serializer: _utcSerializer),
          (row) => row.relativePath,
        ),
      };
      return BackupSnapshot.fromJson(<String, Object?>{
        'logicalSchemaVersion': BackupSnapshot.logicalSchemaVersion,
        'entities': entities,
      });
    });
  }

  Future<LogicalImportPreview> previewLogicalImport(
    BackupSnapshot snapshot, {
    required BackupMode mode,
  }) async {
    await _validateSnapshotInIsolation(snapshot);
    final current = await exportLogicalBackup();
    if (mode == BackupMode.emptyLibrary && current.totalEntityCount != 0) {
      throw const BackupValidationFailure('当前收藏库不是空库，请选择仅新增合并。');
    }
    return _compareSnapshots(current, snapshot, mode);
  }

  Future<LogicalImportResult> importLogicalBackup(
    BackupSnapshot snapshot, {
    required BackupMode mode,
    Future<void> Function()? beforeCommit,
  }) async {
    final preview = await previewLogicalImport(snapshot, mode: mode);
    if (preview.conflicts.isNotEmpty) {
      throw const BackupValidationFailure('备份与当前收藏库存在冲突，未导入任何数据。');
    }

    try {
      await transaction(() async {
        final current = await exportLogicalBackup();
        final missing = _missingRows(current, snapshot);
        await _insertSnapshotRows(this, missing);
        if (beforeCommit != null) await beforeCommit();
      });
    } on BackupValidationFailure {
      rethrow;
    } catch (error) {
      throw BackupStorageFailure('导入失败，现有数据未改变。', error);
    }
    return LogicalImportResult(
      addedCount: preview.addedCount,
      skippedCount: preview.skippedCount,
    );
  }

  /// 同步协议复用备份的规范行格式，按实体类型原子覆盖一行。
  ///
  /// 实体名来自 [BackupSnapshot.entityNames] 的固定白名单，绝不把远端值拼进 SQL。
  Future<void> upsertLogicalEntity(
    String entity,
    Map<String, Object?> row,
  ) async {
    switch (entity) {
      case 'cardDefinitions':
        await into(cardDefinitions).insertOnConflictUpdate(
          CardDefinition.fromJson(row, serializer: _utcSerializer),
        );
      case 'cardItems':
        await into(cardItems).insertOnConflictUpdate(
          CardItem.fromJson(row, serializer: _utcSerializer),
        );
      case 'cardImages':
        await into(cardImages).insertOnConflictUpdate(
          CardImage.fromJson(row, serializer: _utcSerializer),
        );
      case 'cardSets':
        await into(cardSets).insertOnConflictUpdate(
          CardSet.fromJson(row, serializer: _utcSerializer),
        );
      case 'cardSetMembers':
        await into(cardSetMembers).insertOnConflictUpdate(
          CardSetMember.fromJson(row, serializer: _utcSerializer),
        );
      case 'tags':
        await into(
          tags,
        ).insertOnConflictUpdate(Tag.fromJson(row, serializer: _utcSerializer));
      case 'cardTags':
        await into(cardTags).insertOnConflictUpdate(
          CardTag.fromJson(row, serializer: _utcSerializer),
        );
      case 'seriesRecords':
        await into(seriesRecords).insertOnConflictUpdate(
          SeriesRecord.fromJson(row, serializer: _utcSerializer),
        );
      case 'seriesCards':
        await into(seriesCards).insertOnConflictUpdate(
          SeriesCard.fromJson(row, serializer: _utcSerializer),
        );
      case 'seriesSets':
        await into(seriesSets).insertOnConflictUpdate(
          SeriesSet.fromJson(row, serializer: _utcSerializer),
        );
      case 'customFieldDefinitions':
        await into(organizationFieldDefinitions).insertOnConflictUpdate(
          OrganizationFieldDefinition.fromJson(row, serializer: _utcSerializer),
        );
      case 'customFieldValues':
        await into(organizationFieldValues).insertOnConflictUpdate(
          OrganizationFieldValue.fromJson(row, serializer: _utcSerializer),
        );
      case 'purchases':
        await into(purchases).insertOnConflictUpdate(
          Purchase.fromJson(row, serializer: _utcSerializer),
        );
      case 'purchaseItems':
        await into(purchaseItems).insertOnConflictUpdate(
          PurchaseItem.fromJson(row, serializer: _utcSerializer),
        );
      case 'exchangeRates':
        await into(exchangeRates).insertOnConflictUpdate(
          ExchangeRate.fromJson(row, serializer: _utcSerializer),
        );
      case 'recycleBinSettings':
        await into(recycleBinSettingsRows).insertOnConflictUpdate(
          RecycleBinSettingsRow.fromJson(row, serializer: _utcSerializer),
        );
      default:
        throw BackupValidationFailure('同步包含未知实体：$entity。');
    }
  }

  /// 应用关系实体的物理删除；带 `deletedAt` 的实体仍通过 upsert 传播软删除。
  Future<void> deleteLogicalEntity(String entity, String key) async {
    final parts = key.split('\u0000');
    switch (entity) {
      case 'cardDefinitions':
        await (delete(
          cardDefinitions,
        )..where((row) => row.id.equals(key))).go();
      case 'cardItems':
        await (delete(cardItems)..where((row) => row.id.equals(key))).go();
      case 'cardImages':
        await (delete(cardImages)..where((row) => row.id.equals(key))).go();
      case 'cardSets':
        await (delete(cardSets)..where((row) => row.id.equals(key))).go();
      case 'cardSetMembers':
        await (delete(cardSetMembers)..where((row) => row.id.equals(key))).go();
      case 'tags':
        await (delete(tags)..where((row) => row.id.equals(key))).go();
      case 'cardTags':
        _requireKeyParts(parts, 2);
        await (delete(cardTags)..where(
              (row) =>
                  row.tagId.equals(parts[0]) &
                  row.definitionId.equals(parts[1]),
            ))
            .go();
      case 'seriesRecords':
        await (delete(seriesRecords)..where((row) => row.id.equals(key))).go();
      case 'seriesCards':
        _requireKeyParts(parts, 2);
        await (delete(seriesCards)..where(
              (row) =>
                  row.seriesId.equals(parts[0]) &
                  row.definitionId.equals(parts[1]),
            ))
            .go();
      case 'seriesSets':
        _requireKeyParts(parts, 2);
        await (delete(seriesSets)..where(
              (row) =>
                  row.seriesId.equals(parts[0]) & row.setId.equals(parts[1]),
            ))
            .go();
      case 'customFieldDefinitions':
        await (delete(
          organizationFieldDefinitions,
        )..where((row) => row.id.equals(key))).go();
      case 'customFieldValues':
        _requireKeyParts(parts, 2);
        await (delete(organizationFieldValues)..where(
              (row) =>
                  row.fieldId.equals(parts[0]) &
                  row.definitionId.equals(parts[1]),
            ))
            .go();
      case 'purchases':
        await (delete(purchases)..where((row) => row.id.equals(key))).go();
      case 'purchaseItems':
        _requireKeyParts(parts, 3);
        await (delete(purchaseItems)..where(
              (row) =>
                  row.purchaseId.equals(parts[0]) &
                  row.targetType.equals(parts[1]) &
                  row.targetId.equals(parts[2]),
            ))
            .go();
      case 'exchangeRates':
        _requireKeyParts(parts, 4);
        await (delete(exchangeRates)..where(
              (row) =>
                  row.baseCurrency.equals(parts[0]) &
                  row.quoteCurrency.equals(parts[1]) &
                  row.rateDate.equals(DateTime.parse(parts[2]).toUtc()) &
                  row.source.equals(parts[3]),
            ))
            .go();
      case 'recycleBinSettings':
        await (delete(
          recycleBinSettingsRows,
        )..where((row) => row.id.equals(int.parse(key)))).go();
      default:
        throw BackupValidationFailure('同步包含未知实体：$entity。');
    }
  }
}

String logicalEntityRowKey(String entity, Map<String, Object?> row) =>
    _rowKey(entity, row);

void _requireKeyParts(List<String> parts, int expected) {
  if (parts.length != expected) {
    throw const BackupValidationFailure('同步实体主键无效。');
  }
}

Future<void> _validateSnapshotInIsolation(BackupSnapshot snapshot) async {
  _validateUuidIdentifiers(snapshot);
  final isolated = _BackupValidationDatabase(NativeDatabase.memory());
  try {
    await isolated.transaction(() => _insertSnapshotRows(isolated, snapshot));
  } catch (error) {
    throw BackupValidationFailure('备份中的实体字段或关系无效。', error);
  } finally {
    await isolated.close();
  }
}

final RegExp _uuidPattern = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-'
  r'[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
);

const Map<String, List<String>> _requiredUuidFields = <String, List<String>>{
  'cardDefinitions': <String>['id'],
  'cardItems': <String>['id', 'definitionId'],
  'cardImages': <String>['id', 'cardItemId'],
  'cardSets': <String>['id'],
  'cardSetMembers': <String>['id', 'setId', 'definitionId'],
  'tags': <String>['id'],
  'cardTags': <String>['tagId', 'definitionId'],
  'seriesRecords': <String>['id'],
  'seriesCards': <String>['seriesId', 'definitionId'],
  'seriesSets': <String>['seriesId', 'setId'],
  'customFieldDefinitions': <String>['id'],
  'customFieldValues': <String>['fieldId', 'definitionId'],
  'purchases': <String>['id'],
  'purchaseItems': <String>['purchaseId', 'targetId'],
};

const Map<String, List<String>> _nullableUuidFields = <String, List<String>>{
  'cardSets': <String>['coverImageId'],
  'purchases': <String>['adjustmentOfId'],
};

void _validateUuidIdentifiers(BackupSnapshot snapshot) {
  for (final MapEntry(key: entity, value: fields)
      in _requiredUuidFields.entries) {
    for (final row in snapshot.rows(entity)) {
      for (final field in fields) {
        final value = row[field];
        if (value is! String || !_uuidPattern.hasMatch(value)) {
          throw const BackupValidationFailure('备份包含无效的实体标识。');
        }
      }
      for (final field in _nullableUuidFields[entity] ?? const <String>[]) {
        final value = row[field];
        if (value != null &&
            (value is! String || !_uuidPattern.hasMatch(value))) {
          throw const BackupValidationFailure('备份包含无效的实体标识。');
        }
      }
    }
  }
}

/// 使用独立运行时类型，避免 Drift 把隔离校验库误判为同一 executor 的重复实例。
final class _BackupValidationDatabase extends AppDatabase {
  _BackupValidationDatabase(super.executor);
}

LogicalImportPreview _compareSnapshots(
  BackupSnapshot current,
  BackupSnapshot incoming,
  BackupMode mode,
) {
  if (mode == BackupMode.emptyLibrary) {
    return LogicalImportPreview(
      addedCount: incoming.totalEntityCount,
      skippedCount: 0,
      conflicts: const <BackupConflict>[],
    );
  }

  var added = 0;
  var skipped = 0;
  final conflicts = <BackupConflict>[];
  for (final name in BackupSnapshot.entityNames) {
    final local = <String, Map<String, Object?>>{
      for (final row in current.rows(name)) _rowKey(name, row): row,
    };
    for (final row in incoming.rows(name)) {
      final key = _rowKey(name, row);
      final existing = local[key];
      if (existing == null) {
        added++;
      } else if (_canonicalJson(existing) == _canonicalJson(row)) {
        skipped++;
      } else {
        conflicts.add(BackupConflict(entity: name, key: key));
      }
    }
  }
  return LogicalImportPreview(
    addedCount: added,
    skippedCount: skipped,
    conflicts: List<BackupConflict>.unmodifiable(conflicts),
  );
}

BackupSnapshot _missingRows(BackupSnapshot current, BackupSnapshot incoming) {
  final entities = <String, Object?>{};
  for (final name in BackupSnapshot.entityNames) {
    final localKeys = current
        .rows(name)
        .map((row) => _rowKey(name, row))
        .toSet();
    entities[name] = incoming
        .rows(name)
        .where((row) => !localKeys.contains(_rowKey(name, row)))
        .toList(growable: false);
  }
  return BackupSnapshot.fromJson(<String, Object?>{
    'logicalSchemaVersion': BackupSnapshot.logicalSchemaVersion,
    'entities': entities,
  });
}

Future<void> _insertSnapshotRows(
  AppDatabase db,
  BackupSnapshot snapshot,
) async {
  for (final row in snapshot.rows('cardDefinitions')) {
    await db
        .into(db.cardDefinitions)
        .insert(CardDefinition.fromJson(row, serializer: _utcSerializer));
  }
  for (final row in snapshot.rows('cardItems')) {
    await db
        .into(db.cardItems)
        .insert(CardItem.fromJson(row, serializer: _utcSerializer));
  }
  for (final row in snapshot.rows('cardImages')) {
    await db
        .into(db.cardImages)
        .insert(CardImage.fromJson(row, serializer: _utcSerializer));
  }
  for (final row in snapshot.rows('cardSets')) {
    await db
        .into(db.cardSets)
        .insert(CardSet.fromJson(row, serializer: _utcSerializer));
  }
  for (final row in snapshot.rows('cardSetMembers')) {
    await db
        .into(db.cardSetMembers)
        .insert(CardSetMember.fromJson(row, serializer: _utcSerializer));
  }
  for (final row in snapshot.rows('tags')) {
    await db
        .into(db.tags)
        .insert(Tag.fromJson(row, serializer: _utcSerializer));
  }
  for (final row in snapshot.rows('cardTags')) {
    await db
        .into(db.cardTags)
        .insert(CardTag.fromJson(row, serializer: _utcSerializer));
  }
  for (final row in snapshot.rows('seriesRecords')) {
    await db
        .into(db.seriesRecords)
        .insert(SeriesRecord.fromJson(row, serializer: _utcSerializer));
  }
  for (final row in snapshot.rows('seriesCards')) {
    await db
        .into(db.seriesCards)
        .insert(SeriesCard.fromJson(row, serializer: _utcSerializer));
  }
  for (final row in snapshot.rows('seriesSets')) {
    await db
        .into(db.seriesSets)
        .insert(SeriesSet.fromJson(row, serializer: _utcSerializer));
  }
  for (final row in snapshot.rows('customFieldDefinitions')) {
    await db
        .into(db.organizationFieldDefinitions)
        .insert(
          OrganizationFieldDefinition.fromJson(row, serializer: _utcSerializer),
        );
  }
  for (final row in snapshot.rows('customFieldValues')) {
    await db
        .into(db.organizationFieldValues)
        .insert(
          OrganizationFieldValue.fromJson(row, serializer: _utcSerializer),
        );
  }
  final purchaseRows = snapshot.rows('purchases').toList()
    ..sort((a, b) {
      final aAdjustment = a['adjustmentOfId'] == null ? 0 : 1;
      final bAdjustment = b['adjustmentOfId'] == null ? 0 : 1;
      final byKind = aAdjustment.compareTo(bAdjustment);
      return byKind != 0
          ? byKind
          : (a['id']! as String).compareTo(b['id']! as String);
    });
  for (final row in purchaseRows) {
    await db
        .into(db.purchases)
        .insert(Purchase.fromJson(row, serializer: _utcSerializer));
  }
  for (final row in snapshot.rows('purchaseItems')) {
    await db
        .into(db.purchaseItems)
        .insert(PurchaseItem.fromJson(row, serializer: _utcSerializer));
  }
  for (final row in snapshot.rows('exchangeRates')) {
    await db
        .into(db.exchangeRates)
        .insert(ExchangeRate.fromJson(row, serializer: _utcSerializer));
  }
  for (final row in snapshot.rows('recycleBinSettings')) {
    await db
        .into(db.recycleBinSettingsRows)
        .insert(
          RecycleBinSettingsRow.fromJson(row, serializer: _utcSerializer),
        );
  }
  for (final row in snapshot.rows('fileCleanupQueue')) {
    await db
        .into(db.fileCleanupQueueEntries)
        .insert(
          FileCleanupQueueEntry.fromJson(row, serializer: _utcSerializer),
        );
  }
}

String _rowKey(String entity, Map<String, Object?> row) {
  String field(String name) {
    final value = row[name];
    if (value == null) {
      throw BackupValidationFailure('备份实体 $entity 缺少主键字段。');
    }
    return value.toString();
  }

  return switch (entity) {
    'cardDefinitions' ||
    'cardItems' ||
    'cardImages' ||
    'cardSets' ||
    'cardSetMembers' ||
    'tags' ||
    'seriesRecords' ||
    'customFieldDefinitions' ||
    'purchases' => field('id'),
    'cardTags' => '${field('tagId')}\u0000${field('definitionId')}',
    'seriesCards' => '${field('seriesId')}\u0000${field('definitionId')}',
    'seriesSets' => '${field('seriesId')}\u0000${field('setId')}',
    'customFieldValues' => '${field('fieldId')}\u0000${field('definitionId')}',
    'purchaseItems' =>
      '${field('purchaseId')}\u0000${field('targetType')}'
          '\u0000${field('targetId')}',
    'exchangeRates' =>
      '${field('baseCurrency')}\u0000${field('quoteCurrency')}'
          '\u0000${field('rateDate')}\u0000${field('source')}',
    'recycleBinSettings' => field('id'),
    'fileCleanupQueue' => field('relativePath'),
    _ => throw const BackupValidationFailure('备份包含未知实体。'),
  };
}

Future<List<Map<String, Object?>>> _readRows<T>(
  List<T> rows,
  Map<String, Object?> Function(T row) toJson,
  String Function(T row) key,
) async {
  final sorted = rows.toList()..sort((a, b) => key(a).compareTo(key(b)));
  return sorted.map(toJson).toList(growable: false);
}

String _canonicalJson(Object? value) => jsonEncode(_canonicalize(value));

Object? _canonicalize(Object? value) {
  if (value is Map<Object?, Object?>) {
    final keys = value.keys.cast<String>().toList()..sort();
    return <String, Object?>{
      for (final key in keys) key: _canonicalize(value[key]),
    };
  }
  if (value is List<Object?>) return value.map(_canonicalize).toList();
  return value;
}

Map<String, Object?> _asObject(Object? value, String message) {
  if (value is! Map<Object?, Object?>) throw BackupValidationFailure(message);
  final result = <String, Object?>{};
  for (final MapEntry(:key, :value) in value.entries) {
    if (key is! String) throw BackupValidationFailure(message);
    result[key] = value;
  }
  return result;
}

const ValueSerializer _utcSerializer = _UtcValueSerializer();

final class _UtcValueSerializer extends ValueSerializer {
  const _UtcValueSerializer();

  @override
  T fromJson<T>(Object? value) {
    if (value == null) return null as T;
    final typeList = <T>[];
    if (typeList is List<DateTime?>) {
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true) as T;
      }
      return DateTime.parse(value.toString()).toUtc() as T;
    }
    if (typeList is List<double?> && value is int) return value.toDouble() as T;
    return value as T;
  }

  @override
  Object? toJson<T>(T value) {
    if (value is DateTime) return value.toUtc().toIso8601String();
    return value;
  }
}
