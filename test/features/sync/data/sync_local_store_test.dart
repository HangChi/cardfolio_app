import 'package:cardfolio_app/core/id/id_generator.dart';
import 'package:cardfolio_app/core/time/clock.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/sync/data/local/sync_local_store.dart';
import 'package:cardfolio_app/features/sync/domain/sync_models.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late SyncLocalStore store;
  late FixedClock clock;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    clock = FixedClock(DateTime.utc(2026, 7, 29, 8));
    store = SyncLocalStore(
      database: database,
      idGenerator: _SequenceIdGenerator(),
      clock: clock,
    );
  });

  tearDown(() => database.close());

  test('overview starts in local-only mode with empty queues', () async {
    final overview = await store.watchOverview().first;

    expect(overview.phase, SyncPhase.localOnly);
    expect(overview.pendingCount, 0);
    expect(overview.conflictCount, 0);
  });

  test('captures 20 offline rows once and preserves operation ids', () async {
    for (var index = 0; index < 20; index++) {
      await _insertDefinition(
        database,
        id: _uuid(index + 1),
        name: '离线卡 ${index + 1}',
      );
    }

    await store.captureLocalChanges();
    final first = await store.pendingMutations();
    await store.captureLocalChanges();
    final second = await store.pendingMutations();

    expect(first, hasLength(20));
    expect(first.map((item) => item.operationId).toSet(), hasLength(20));
    expect(
      second.map((item) => item.operationId),
      first.map((item) => item.operationId),
    );
    expect(first.every((item) => item.baseServerVersion == 0), isTrue);
  });

  test(
    'acknowledgement removes outbox row and stores remote baseline',
    () async {
      final id = _uuid(1);
      await _insertDefinition(database, id: id, name: '待确认');
      await store.captureLocalChanges();
      final mutation = (await store.pendingMutations()).single;

      await store.acknowledge(<SyncAck>[
        SyncAck(
          operationId: mutation.operationId,
          entityType: mutation.entityType,
          entityId: mutation.entityId,
          serverVersion: 7,
        ),
      ]);

      expect(await store.pendingMutations(), isEmpty);
      final baseline = await store.entityState('cardDefinitions', id);
      expect(baseline?.serverVersion, 7);
      expect(baseline?.payload?['name'], '待确认');
    },
  );

  test('applies a remote row and advances the cursor atomically', () async {
    final id = _uuid(2);
    await store.applyRemoteChanges(<RemoteSyncChange>[
      RemoteSyncChange(
        changeId: 'change-1',
        entityType: 'cardDefinitions',
        entityId: id,
        operation: SyncOperation.upsert,
        serverVersion: 1,
        payload: <String, Object?>{
          'id': id,
          'name': '远端卡片',
          'city': null,
          'issuer': null,
          'issuedAt': null,
          'code': null,
          'notes': null,
          'cardType': null,
          'needsCompletion': false,
          'version': 1,
          'createdAt': '2026-07-29T08:00:00.000Z',
          'updatedAt': '2026-07-29T08:00:00.000Z',
          'deletedAt': null,
        },
        changedFields: const <String>{'name'},
        occurredAt: DateTime.utc(2026, 7, 29, 8),
      ),
    ], cursor: 'cursor-1');

    expect(
      (await database.select(database.cardDefinitions).getSingle()).name,
      '远端卡片',
    );
    expect((await store.settings()).cursor, 'cursor-1');
  });

  test('rebases changes to different fields without a conflict', () async {
    final id = _uuid(3);
    await _insertDefinition(database, id: id, name: '旧名称', notes: '旧备注');
    await store.captureLocalChanges();
    final initial = (await store.pendingMutations()).single;
    await store.acknowledge(<SyncAck>[
      SyncAck(
        operationId: initial.operationId,
        entityType: initial.entityType,
        entityId: initial.entityId,
        serverVersion: 1,
      ),
    ]);
    await (database.update(database.cardDefinitions)
          ..where((row) => row.id.equals(id)))
        .write(const CardDefinitionsCompanion(name: Value('本地名称')));
    await store.captureLocalChanges();

    await store.applyRemoteChanges(<RemoteSyncChange>[
      _definitionChange(
        id: id,
        serverVersion: 2,
        name: '旧名称',
        notes: '远端备注',
        changedFields: const <String>{'notes'},
      ),
    ], cursor: 'cursor-2');

    final row = await database.select(database.cardDefinitions).getSingle();
    expect(row.name, '本地名称');
    expect(row.notes, '远端备注');
    expect(await store.watchConflicts().first, isEmpty);
    final rebased = (await store.pendingMutations()).single;
    expect(rebased.baseServerVersion, 2);
    expect(rebased.payload?['name'], '本地名称');
    expect(rebased.payload?['notes'], '远端备注');
  });

  test('keeps local data and creates a copy for same-field conflict', () async {
    final id = _uuid(4);
    await _insertDefinition(database, id: id, name: '旧名称');
    await store.captureLocalChanges();
    final initial = (await store.pendingMutations()).single;
    await store.acknowledge(<SyncAck>[
      SyncAck(
        operationId: initial.operationId,
        entityType: initial.entityType,
        entityId: initial.entityId,
        serverVersion: 1,
      ),
    ]);
    await (database.update(database.cardDefinitions)
          ..where((row) => row.id.equals(id)))
        .write(const CardDefinitionsCompanion(name: Value('本地名称')));
    await store.captureLocalChanges();

    await store.applyRemoteChanges(<RemoteSyncChange>[
      _definitionChange(
        id: id,
        serverVersion: 2,
        name: '远端名称',
        notes: null,
        changedFields: const <String>{'name'},
      ),
    ], cursor: 'cursor-3');

    expect(
      (await database.select(database.cardDefinitions).getSingle()).name,
      '本地名称',
    );
    final conflict = (await store.watchConflicts().first).single;
    expect(conflict.localPayload?['name'], '本地名称');
    expect(conflict.remotePayload?['name'], '远端名称');
    expect(conflict.conflictingFields, <String>{'name'});
  });

  test('dead-letter removes the operation and suppresses recapture', () async {
    final id = _uuid(10);
    await _insertDefinition(database, id: id, name: '死信卡');
    await store.captureLocalChanges();
    final mutation = (await store.pendingMutations()).single;

    await store.markMutationDead(mutation.operationId, 'invalid_mutation');

    expect(await store.pendingMutations(), isEmpty);
    final overview = await store.watchOverview().first;
    expect(overview.lastErrorCode, 'dead_letter:invalid_mutation');
    // 实体状态已推进到死信载荷，重新捕获不能复活同一更改。
    await store.captureLocalChanges();
    expect(await store.pendingMutations(), isEmpty);
  });

  test('push ordering ranks parent upserts before children', () async {
    Future<void> insert(String operationId, String entityType) => database
        .into(database.syncOutboxEntries)
        .insert(
          SyncOutboxEntriesCompanion.insert(
            operationId: operationId,
            entityType: entityType,
            entityId: 'entity-$entityType',
            operation: 'upsert',
            baseServerVersion: 0,
            payloadJson: Value('{"id":"entity-$entityType"}'),
            changedFieldsJson: '[]',
            createdAt: DateTime.utc(2026, 7, 29, 8),
          ),
        );
    // operationId 字典序故意与实体层级相反，验证排序不依赖随机 id。
    await insert('a0000000-0000-4000-8000-000000000001', 'cardImages');
    await insert('b0000000-0000-4000-8000-000000000002', 'cardItems');
    await insert('c0000000-0000-4000-8000-000000000003', 'cardDefinitions');

    final mutations = await store.pendingMutations();

    expect(mutations.map((item) => item.entityType).toList(), <String>[
      'cardDefinitions',
      'cardItems',
      'cardImages',
    ]);
  });

  test('push ordering ranks child deletes before parents', () async {
    Future<void> insert(String operationId, String entityType) => database
        .into(database.syncOutboxEntries)
        .insert(
          SyncOutboxEntriesCompanion.insert(
            operationId: operationId,
            entityType: entityType,
            entityId: 'entity-$entityType',
            operation: 'delete',
            baseServerVersion: 0,
            payloadJson: const Value(null),
            changedFieldsJson: '[]',
            createdAt: DateTime.utc(2026, 7, 29, 8),
          ),
        );
    await insert('a0000000-0000-4000-8000-000000000004', 'cardDefinitions');
    await insert('f0000000-0000-4000-8000-000000000005', 'cardItems');

    final mutations = await store.pendingMutations();

    expect(mutations.map((item) => item.entityType).toList(), <String>[
      'cardItems',
      'cardDefinitions',
    ]);
  });
}

Future<void> _insertDefinition(
  AppDatabase database, {
  required String id,
  required String name,
  String? notes,
}) {
  final now = DateTime.utc(2026, 7, 29, 8);
  return database
      .into(database.cardDefinitions)
      .insert(
        CardDefinitionsCompanion.insert(
          id: id,
          name: name,
          notes: Value(notes),
          createdAt: now,
          updatedAt: now,
        ),
      );
}

RemoteSyncChange _definitionChange({
  required String id,
  required int serverVersion,
  required String name,
  required String? notes,
  required Set<String> changedFields,
}) {
  return RemoteSyncChange(
    changeId: 'change-$serverVersion',
    entityType: 'cardDefinitions',
    entityId: id,
    operation: SyncOperation.upsert,
    serverVersion: serverVersion,
    payload: <String, Object?>{
      'id': id,
      'name': name,
      'city': null,
      'issuer': null,
      'issuedAt': null,
      'code': null,
      'notes': notes,
      'cardType': null,
      'needsCompletion': false,
      'version': 1,
      'createdAt': '2026-07-29T08:00:00.000Z',
      'updatedAt': '2026-07-29T08:00:00.000Z',
      'deletedAt': null,
    },
    changedFields: changedFields,
    occurredAt: DateTime.utc(2026, 7, 29, 8),
  );
}

String _uuid(int value) =>
    '00000000-0000-4000-8000-${value.toString().padLeft(12, '0')}';

final class _SequenceIdGenerator implements IdGenerator {
  var _next = 1000;

  @override
  String newId() => _uuid(_next++);
}
