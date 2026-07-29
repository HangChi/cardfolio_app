import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../../../../core/id/id_generator.dart';
import '../../../../core/time/clock.dart';
import '../../../backup/data/backup_database.dart';
import '../../../cards/data/local/card_database.dart';
import '../../domain/sync_models.dart';

final class LocalSyncSettings {
  const LocalSyncSettings({
    required this.deviceId,
    required this.enabled,
    required this.cursor,
    required this.account,
    required this.lastSyncedAt,
    required this.lastErrorCode,
  });

  final String deviceId;
  final bool enabled;
  final String? cursor;
  final AccountSummary? account;
  final DateTime? lastSyncedAt;
  final String? lastErrorCode;
}

final class LocalSyncEntityState {
  const LocalSyncEntityState({
    required this.serverVersion,
    required this.operation,
    required this.payload,
  });

  final int serverVersion;
  final SyncOperation operation;
  final Map<String, Object?>? payload;
}

final class SyncLocalStore {
  factory SyncLocalStore({
    required AppDatabase database,
    required IdGenerator idGenerator,
    required Clock clock,
  }) => SyncLocalStore._(database, idGenerator, clock);

  const SyncLocalStore._(this._db, this._ids, this._clock);

  final AppDatabase _db;
  final IdGenerator _ids;
  final Clock _clock;

  Future<LocalSyncSettings> settings() async {
    var row = await (_db.select(
      _db.syncSettingsRows,
    )..where((item) => item.id.equals(1))).getSingleOrNull();
    if (row == null) {
      final now = _clock.nowUtc();
      await _db
          .into(_db.syncSettingsRows)
          .insert(
            SyncSettingsRowsCompanion.insert(
              id: const Value(1),
              deviceId: _ids.newId(),
              updatedAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      row = await (_db.select(
        _db.syncSettingsRows,
      )..where((item) => item.id.equals(1))).getSingle();
    }
    return _mapSettings(row);
  }

  Future<void> setAccount(AccountSummary? account) async {
    await settings();
    await (_db.update(
      _db.syncSettingsRows,
    )..where((row) => row.id.equals(1))).write(
      SyncSettingsRowsCompanion(
        accountUserId: Value(account?.userId),
        accountEmail: Value(account?.email),
        enabled: account == null ? const Value(false) : const Value.absent(),
        updatedAt: Value(_clock.nowUtc()),
      ),
    );
  }

  Future<void> setEnabled(bool enabled) async {
    final current = await settings();
    if (enabled && current.account == null) {
      throw StateError('未登录时不能开启同步');
    }
    await (_db.update(
      _db.syncSettingsRows,
    )..where((row) => row.id.equals(1))).write(
      SyncSettingsRowsCompanion(
        enabled: Value(enabled),
        lastErrorCode: const Value(null),
        updatedAt: Value(_clock.nowUtc()),
      ),
    );
  }

  Stream<SyncOverview> watchOverview() async* {
    await settings();
    final query = _db.customSelect(
      '''
      SELECT s.*,
        (SELECT COUNT(*) FROM sync_outbox) AS pending_count,
        (SELECT COUNT(*) FROM sync_conflicts WHERE resolved_at IS NULL)
          AS conflict_count
      FROM sync_settings s
      WHERE s.id = 1
      ''',
      readsFrom: <ResultSetImplementation>{
        _db.syncSettingsRows,
        _db.syncOutboxEntries,
        _db.syncConflictRows,
      },
    );
    yield* query.watch().map((rows) {
      final row = rows.single;
      final accountUserId = row.read<String?>('account_user_id');
      final accountEmail = row.read<String?>('account_email');
      final pending = row.read<int>('pending_count');
      final conflicts = row.read<int>('conflict_count');
      final enabled = row.read<bool>('enabled');
      final lastError = row.read<String?>('last_error_code');
      final lastSyncedSeconds = row.read<int?>('last_synced_at');
      final phase = accountUserId == null
          ? SyncPhase.localOnly
          : !enabled
          ? SyncPhase.disabled
          : conflicts > 0
          ? SyncPhase.conflicts
          : lastError != null
          ? SyncPhase.failed
          : pending > 0
          ? SyncPhase.pending
          : SyncPhase.synced;
      return SyncOverview(
        account: accountUserId == null || accountEmail == null
            ? null
            : AccountSummary(userId: accountUserId, email: accountEmail),
        enabled: enabled,
        phase: phase,
        pendingCount: pending,
        conflictCount: conflicts,
        lastSyncedAt: lastSyncedSeconds == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                lastSyncedSeconds * Duration.millisecondsPerSecond,
                isUtc: true,
              ),
        lastErrorCode: lastError,
      );
    });
  }

  Stream<List<SyncConflict>> watchConflicts() {
    final query = _db.select(_db.syncConflictRows)
      ..where((row) => row.resolvedAt.isNull())
      ..orderBy(<OrderingTerm Function(SyncConflictRows)>[
        (row) => OrderingTerm.desc(row.detectedAt),
        (row) => OrderingTerm.desc(row.id),
      ]);
    return query.watch().map(
      (rows) => rows.map(_mapConflict).toList(growable: false),
    );
  }

  Future<void> captureLocalChanges() async {
    await settings();
    final snapshot = await _db.exportLogicalBackup();
    final states = await _db.select(_db.syncEntityStateRows).get();
    final pending = await _db.select(_db.syncOutboxEntries).get();
    final stateByEntity = <String, SyncEntityStateRow>{
      for (final row in states) _entityKey(row.entityType, row.entityId): row,
    };
    final pendingKeys = pending
        .map((row) => _entityKey(row.entityType, row.entityId))
        .toSet();
    final currentKeys = <String>{};
    final now = _clock.nowUtc();

    await _db.transaction(() async {
      for (final entity in syncEntityTypes) {
        for (final row in snapshot.rows(entity)) {
          final entityId = logicalEntityRowKey(entity, row);
          final key = _entityKey(entity, entityId);
          currentKeys.add(key);
          if (pendingKeys.contains(key)) continue;
          final state = stateByEntity[key];
          final payloadJson = canonicalSyncJson(row);
          if (state?.payloadJson == payloadJson && !state!.deleted) continue;
          final baseline = _decodeMap(state?.payloadJson);
          await _db
              .into(_db.syncOutboxEntries)
              .insert(
                SyncOutboxEntriesCompanion.insert(
                  operationId: _ids.newId(),
                  entityType: entity,
                  entityId: entityId,
                  operation: SyncOperation.upsert.name,
                  baseServerVersion: state?.serverVersion ?? 0,
                  payloadJson: Value(payloadJson),
                  changedFieldsJson: jsonEncode(
                    (changedSyncFields(baseline, row).toList()..sort()),
                  ),
                  createdAt: now,
                ),
              );
        }
      }

      for (final state in states) {
        final key = _entityKey(state.entityType, state.entityId);
        if (currentKeys.contains(key) ||
            pendingKeys.contains(key) ||
            state.deleted) {
          continue;
        }
        await _db
            .into(_db.syncOutboxEntries)
            .insert(
              SyncOutboxEntriesCompanion.insert(
                operationId: _ids.newId(),
                entityType: state.entityType,
                entityId: state.entityId,
                operation: SyncOperation.delete.name,
                baseServerVersion: state.serverVersion,
                payloadJson: const Value(null),
                changedFieldsJson: '[]',
                createdAt: now,
              ),
            );
      }
    });
  }

  Future<List<SyncMutation>> pendingMutations({int limit = 100}) async {
    if (limit < 1 || limit > 100) {
      throw ArgumentError.value(limit, 'limit', '必须在 1..100');
    }
    final now = _clock.nowUtc();
    final query = _db.select(_db.syncOutboxEntries)
      ..where(
        (row) =>
            row.nextAttemptAt.isNull() |
            row.nextAttemptAt.isSmallerOrEqualValue(now),
      )
      ..orderBy(<OrderingTerm Function(SyncOutboxEntries)>[
        (row) => OrderingTerm.asc(row.createdAt),
        (row) => OrderingTerm.asc(row.operationId),
      ])
      ..limit(limit);
    return (await query.get()).map(_mapMutation).toList(growable: false);
  }

  Future<LocalSyncEntityState?> entityState(
    String entityType,
    String entityId,
  ) async {
    final row =
        await (_db.select(_db.syncEntityStateRows)..where(
              (item) =>
                  item.entityType.equals(entityType) &
                  item.entityId.equals(entityId),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    return LocalSyncEntityState(
      serverVersion: row.serverVersion,
      operation: row.deleted ? SyncOperation.delete : SyncOperation.upsert,
      payload: _decodeMap(row.payloadJson),
    );
  }

  Future<void> acknowledge(List<SyncAck> acknowledgements) {
    return _db.transaction(() async {
      for (final ack in acknowledgements) {
        final outbox =
            await (_db.select(_db.syncOutboxEntries)
                  ..where((row) => row.operationId.equals(ack.operationId)))
                .getSingleOrNull();
        if (outbox == null) continue;
        if (outbox.entityType != ack.entityType ||
            outbox.entityId != ack.entityId) {
          throw StateError('服务端确认与本地操作不匹配');
        }
        await _writeState(
          entityType: outbox.entityType,
          entityId: outbox.entityId,
          serverVersion: ack.serverVersion,
          operation: SyncOperation.values.byName(outbox.operation),
          payloadJson: outbox.payloadJson,
        );
        await (_db.delete(
          _db.syncOutboxEntries,
        )..where((row) => row.operationId.equals(ack.operationId))).go();
      }
    });
  }

  Future<void> applyRemoteChanges(
    List<RemoteSyncChange> changes, {
    required String? cursor,
  }) {
    final ordered = changes.toList()
      ..sort((left, right) {
        final leftOrder = _entityOrder[left.entityType]!;
        final rightOrder = _entityOrder[right.entityType]!;
        final byOperation = left.operation == right.operation
            ? 0
            : left.operation == SyncOperation.upsert
            ? -1
            : 1;
        if (byOperation != 0) return byOperation;
        return left.operation == SyncOperation.upsert
            ? leftOrder.compareTo(rightOrder)
            : rightOrder.compareTo(leftOrder);
      });

    return _db.transaction(() async {
      for (final change in ordered) {
        final pending =
            await (_db.select(_db.syncOutboxEntries)..where(
                  (row) =>
                      row.entityType.equals(change.entityType) &
                      row.entityId.equals(change.entityId),
                ))
                .getSingleOrNull();
        final baseline =
            await (_db.select(_db.syncEntityStateRows)..where(
                  (row) =>
                      row.entityType.equals(change.entityType) &
                      row.entityId.equals(change.entityId),
                ))
                .getSingleOrNull();

        if (pending == null) {
          await _applyChange(
            change.operation,
            change.entityType,
            change.entityId,
            change.payload,
          );
          await _writeState(
            entityType: change.entityType,
            entityId: change.entityId,
            serverVersion: change.serverVersion,
            operation: change.operation,
            payloadJson: change.payload == null
                ? null
                : canonicalSyncJson(change.payload!),
          );
          continue;
        }

        final localOperation = SyncOperation.values.byName(pending.operation);
        final localPayload = _decodeMap(pending.payloadJson);
        final result = mergeSyncPayload(
          basePayload: _decodeMap(baseline?.payloadJson),
          localPayload: localPayload,
          remotePayload: change.payload,
          localOperation: localOperation,
          remoteOperation: change.operation,
        );
        if (result.kind == SyncMergeKind.conflict) {
          final existing =
              await (_db.select(_db.syncConflictRows)..where(
                    (row) =>
                        row.entityType.equals(change.entityType) &
                        row.entityId.equals(change.entityId) &
                        row.resolvedAt.isNull(),
                  ))
                  .getSingleOrNull();
          if (existing == null) {
            await _db
                .into(_db.syncConflictRows)
                .insert(
                  SyncConflictRowsCompanion.insert(
                    id: _ids.newId(),
                    entityType: change.entityType,
                    entityId: change.entityId,
                    localOperation: localOperation.name,
                    localPayloadJson: Value(pending.payloadJson),
                    remoteOperation: change.operation.name,
                    remotePayloadJson: Value(
                      change.payload == null
                          ? null
                          : canonicalSyncJson(change.payload!),
                    ),
                    remoteServerVersion: change.serverVersion,
                    conflictingFieldsJson: jsonEncode(
                      result.conflictingFields.toList()..sort(),
                    ),
                    detectedAt: _clock.nowUtc(),
                  ),
                );
          }
          continue;
        }

        await _applyChange(
          result.operation,
          change.entityType,
          change.entityId,
          result.payload,
        );
        final mergedJson = result.payload == null
            ? null
            : canonicalSyncJson(result.payload!);
        final changedFields = changedSyncFields(change.payload, result.payload);
        await (_db.update(
          _db.syncOutboxEntries,
        )..where((row) => row.operationId.equals(pending.operationId))).write(
          SyncOutboxEntriesCompanion(
            operation: Value(result.operation.name),
            baseServerVersion: Value(change.serverVersion),
            payloadJson: Value(mergedJson),
            changedFieldsJson: Value(
              jsonEncode(changedFields.toList()..sort()),
            ),
            attemptCount: const Value(0),
            nextAttemptAt: const Value(null),
            lastErrorCode: const Value(null),
          ),
        );
        await _writeState(
          entityType: change.entityType,
          entityId: change.entityId,
          serverVersion: change.serverVersion,
          operation: change.operation,
          payloadJson: change.payload == null
              ? null
              : canonicalSyncJson(change.payload!),
        );
      }

      await settings();
      await (_db.update(
        _db.syncSettingsRows,
      )..where((row) => row.id.equals(1))).write(
        SyncSettingsRowsCompanion(
          cursor: Value(cursor),
          updatedAt: Value(_clock.nowUtc()),
        ),
      );
    });
  }

  Future<void> markMutationsFailed(
    Iterable<String> operationIds, {
    required String errorCode,
  }) {
    return _db.transaction(() async {
      for (final operationId in operationIds) {
        final row =
            await (_db.select(_db.syncOutboxEntries)
                  ..where((item) => item.operationId.equals(operationId)))
                .getSingleOrNull();
        if (row == null) continue;
        final attempt = row.attemptCount + 1;
        final seconds = math.min(3600, 1 << math.min(attempt, 11));
        await (_db.update(
          _db.syncOutboxEntries,
        )..where((item) => item.operationId.equals(operationId))).write(
          SyncOutboxEntriesCompanion(
            attemptCount: Value(attempt),
            nextAttemptAt: Value(
              _clock.nowUtc().add(Duration(seconds: seconds)),
            ),
            lastErrorCode: Value(errorCode),
          ),
        );
      }
      await settings();
      await (_db.update(
        _db.syncSettingsRows,
      )..where((row) => row.id.equals(1))).write(
        SyncSettingsRowsCompanion(
          lastErrorCode: Value(errorCode),
          updatedAt: Value(_clock.nowUtc()),
        ),
      );
    });
  }

  Future<void> markSyncSucceeded({required String? cursor}) async {
    await settings();
    await (_db.update(
      _db.syncSettingsRows,
    )..where((row) => row.id.equals(1))).write(
      SyncSettingsRowsCompanion(
        cursor: Value(cursor),
        lastSyncedAt: Value(_clock.nowUtc()),
        lastErrorCode: const Value(null),
        updatedAt: Value(_clock.nowUtc()),
      ),
    );
  }

  Future<void> resolveConflict({
    required String conflictId,
    required SyncConflictResolution resolution,
    Map<String, Object?>? mergedPayload,
  }) {
    return _db.transaction(() async {
      final conflict =
          await (_db.select(_db.syncConflictRows)..where(
                (row) => row.id.equals(conflictId) & row.resolvedAt.isNull(),
              ))
              .getSingleOrNull();
      if (conflict == null) throw StateError('冲突不存在或已经解决');
      final pending =
          await (_db.select(_db.syncOutboxEntries)..where(
                (row) =>
                    row.entityType.equals(conflict.entityType) &
                    row.entityId.equals(conflict.entityId),
              ))
              .getSingleOrNull();
      final remoteOperation = SyncOperation.values.byName(
        conflict.remoteOperation,
      );
      final remotePayload = _decodeMap(conflict.remotePayloadJson);

      switch (resolution) {
        case SyncConflictResolution.keepLocal:
          if (pending == null) throw StateError('本地冲突版本不存在');
          await (_db.update(
            _db.syncOutboxEntries,
          )..where((row) => row.operationId.equals(pending.operationId))).write(
            SyncOutboxEntriesCompanion(
              baseServerVersion: Value(conflict.remoteServerVersion),
              attemptCount: const Value(0),
              nextAttemptAt: const Value(null),
              lastErrorCode: const Value(null),
            ),
          );
        case SyncConflictResolution.useRemote:
          await _applyChange(
            remoteOperation,
            conflict.entityType,
            conflict.entityId,
            remotePayload,
          );
          if (pending != null) {
            await (_db.delete(_db.syncOutboxEntries)
                  ..where((row) => row.operationId.equals(pending.operationId)))
                .go();
          }
        case SyncConflictResolution.merge:
          if (mergedPayload == null) {
            throw ArgumentError('合并解决必须提供 mergedPayload');
          }
          await _applyChange(
            SyncOperation.upsert,
            conflict.entityType,
            conflict.entityId,
            mergedPayload,
          );
          final payloadJson = canonicalSyncJson(mergedPayload);
          final changedFields = changedSyncFields(remotePayload, mergedPayload);
          if (pending == null) {
            await _db
                .into(_db.syncOutboxEntries)
                .insert(
                  SyncOutboxEntriesCompanion.insert(
                    operationId: _ids.newId(),
                    entityType: conflict.entityType,
                    entityId: conflict.entityId,
                    operation: SyncOperation.upsert.name,
                    baseServerVersion: conflict.remoteServerVersion,
                    payloadJson: Value(payloadJson),
                    changedFieldsJson: jsonEncode(
                      changedFields.toList()..sort(),
                    ),
                    createdAt: _clock.nowUtc(),
                  ),
                );
          } else {
            await (_db.update(_db.syncOutboxEntries)
                  ..where((row) => row.operationId.equals(pending.operationId)))
                .write(
                  SyncOutboxEntriesCompanion(
                    operation: const Value('upsert'),
                    baseServerVersion: Value(conflict.remoteServerVersion),
                    payloadJson: Value(payloadJson),
                    changedFieldsJson: Value(
                      jsonEncode(changedFields.toList()..sort()),
                    ),
                    attemptCount: const Value(0),
                    nextAttemptAt: const Value(null),
                    lastErrorCode: const Value(null),
                  ),
                );
          }
      }

      await _writeState(
        entityType: conflict.entityType,
        entityId: conflict.entityId,
        serverVersion: conflict.remoteServerVersion,
        operation: remoteOperation,
        payloadJson: conflict.remotePayloadJson,
      );
      await (_db.update(_db.syncConflictRows)
            ..where((row) => row.id.equals(conflictId)))
          .write(SyncConflictRowsCompanion(resolvedAt: Value(_clock.nowUtc())));
    });
  }

  Future<void> clearSyncIdentity() {
    return _db.transaction(() async {
      await _db.delete(_db.syncOutboxEntries).go();
      await _db.delete(_db.syncEntityStateRows).go();
      await _db.delete(_db.syncConflictRows).go();
      await settings();
      await (_db.update(
        _db.syncSettingsRows,
      )..where((row) => row.id.equals(1))).write(
        SyncSettingsRowsCompanion(
          enabled: const Value(false),
          cursor: const Value(null),
          accountUserId: const Value(null),
          accountEmail: const Value(null),
          lastSyncedAt: const Value(null),
          lastErrorCode: const Value(null),
          updatedAt: Value(_clock.nowUtc()),
        ),
      );
    });
  }

  /// 账号删除选择“删除本地副本”时清空全部用户业务数据。
  ///
  /// 删除顺序遵循外键依赖；sync 元数据由 [clearSyncIdentity] 独立清理。
  Future<void> clearBusinessData() {
    return _db.transaction(() async {
      await _db.delete(_db.purchaseItems).go();
      await _db.delete(_db.purchases).go();
      await _db.delete(_db.organizationFieldValues).go();
      await _db.delete(_db.organizationFieldDefinitions).go();
      await _db.delete(_db.cardTags).go();
      await _db.delete(_db.seriesCards).go();
      await _db.delete(_db.seriesSets).go();
      await _db.delete(_db.cardSetMembers).go();
      await _db.delete(_db.cardSets).go();
      await _db.delete(_db.cardImages).go();
      await _db.delete(_db.cardItems).go();
      await _db.delete(_db.cardDefinitions).go();
      await _db.delete(_db.tags).go();
      await _db.delete(_db.seriesRecords).go();
      await _db.delete(_db.exchangeRates).go();
      await _db.delete(_db.recycleBinSettingsRows).go();
      await _db.delete(_db.fileCleanupQueueEntries).go();
    });
  }

  Future<void> _writeState({
    required String entityType,
    required String entityId,
    required int serverVersion,
    required SyncOperation operation,
    required String? payloadJson,
  }) {
    return _db
        .into(_db.syncEntityStateRows)
        .insertOnConflictUpdate(
          SyncEntityStateRowsCompanion.insert(
            entityType: entityType,
            entityId: entityId,
            serverVersion: serverVersion,
            payloadJson: Value(payloadJson),
            deleted: Value(operation == SyncOperation.delete),
            updatedAt: _clock.nowUtc(),
          ),
        );
  }

  Future<void> _applyChange(
    SyncOperation operation,
    String entityType,
    String entityId,
    Map<String, Object?>? payload,
  ) {
    return switch (operation) {
      SyncOperation.upsert => _db.upsertLogicalEntity(entityType, payload!),
      SyncOperation.delete => _db.deleteLogicalEntity(entityType, entityId),
    };
  }

  LocalSyncSettings _mapSettings(SyncSettingsRow row) => LocalSyncSettings(
    deviceId: row.deviceId,
    enabled: row.enabled,
    cursor: row.cursor,
    account: row.accountUserId == null || row.accountEmail == null
        ? null
        : AccountSummary(userId: row.accountUserId!, email: row.accountEmail!),
    lastSyncedAt: row.lastSyncedAt?.toUtc(),
    lastErrorCode: row.lastErrorCode,
  );

  SyncMutation _mapMutation(SyncOutboxEntry row) => SyncMutation(
    operationId: row.operationId,
    entityType: row.entityType,
    entityId: row.entityId,
    operation: SyncOperation.values.byName(row.operation),
    baseServerVersion: row.baseServerVersion,
    payload: _decodeMap(row.payloadJson),
    changedFields: _decodeStringSet(row.changedFieldsJson),
    createdAt: row.createdAt.toUtc(),
  );

  SyncConflict _mapConflict(SyncConflictRow row) => SyncConflict(
    id: row.id,
    entityType: row.entityType,
    entityId: row.entityId,
    localOperation: SyncOperation.values.byName(row.localOperation),
    localPayload: _decodeMap(row.localPayloadJson),
    remoteOperation: SyncOperation.values.byName(row.remoteOperation),
    remotePayload: _decodeMap(row.remotePayloadJson),
    remoteServerVersion: row.remoteServerVersion,
    conflictingFields: _decodeStringSet(row.conflictingFieldsJson),
    detectedAt: row.detectedAt,
  );
}

Map<String, Object?>? _decodeMap(String? value) {
  if (value == null) return null;
  final decoded = jsonDecode(value);
  if (decoded is! Map<String, Object?>) {
    throw const FormatException('同步载荷不是对象');
  }
  return decoded;
}

Set<String> _decodeStringSet(String value) {
  final decoded = jsonDecode(value);
  if (decoded is! List || decoded.any((item) => item is! String)) {
    throw const FormatException('同步字段列表无效');
  }
  return decoded.cast<String>().toSet();
}

String _entityKey(String entityType, String entityId) =>
    '$entityType\u0001$entityId';

const Map<String, int> _entityOrder = <String, int>{
  'cardDefinitions': 0,
  'cardItems': 1,
  'cardImages': 2,
  'cardSets': 3,
  'cardSetMembers': 4,
  'tags': 5,
  'cardTags': 6,
  'seriesRecords': 7,
  'seriesCards': 8,
  'seriesSets': 9,
  'customFieldDefinitions': 10,
  'customFieldValues': 11,
  'purchases': 12,
  'purchaseItems': 13,
  'exchangeRates': 14,
  'recycleBinSettings': 15,
};
