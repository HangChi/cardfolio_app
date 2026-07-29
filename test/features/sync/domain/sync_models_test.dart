import 'package:cardfolio_app/features/sync/domain/sync_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncMutation', () {
    test('rejects an operation id that is not a UUID', () {
      expect(
        () => SyncMutation(
          operationId: 'operation-1',
          entityType: 'cardDefinitions',
          entityId: 'definition-1',
          operation: SyncOperation.upsert,
          baseServerVersion: 0,
          payload: const <String, Object?>{'id': 'definition-1'},
          changedFields: const <String>{'id'},
          createdAt: DateTime.utc(2026, 7, 29),
        ),
        throwsArgumentError,
      );
    });

    test('rejects a delete operation that carries a payload', () {
      expect(
        () => SyncMutation(
          operationId: '4f8d7a3e-28c2-4aa2-94b8-a08f2248d64c',
          entityType: 'cardDefinitions',
          entityId: 'definition-1',
          operation: SyncOperation.delete,
          baseServerVersion: 3,
          payload: const <String, Object?>{'id': 'definition-1'},
          changedFields: const <String>{},
          createdAt: DateTime.utc(2026, 7, 29),
        ),
        throwsArgumentError,
      );
    });
  });

  group('mergeSyncPayload', () {
    const base = <String, Object?>{
      'id': 'definition-1',
      'name': '旧名称',
      'notes': '旧备注',
    };

    test('merges changes to different fields', () {
      final result = mergeSyncPayload(
        basePayload: base,
        localPayload: const <String, Object?>{
          'id': 'definition-1',
          'name': '本地名称',
          'notes': '旧备注',
        },
        remotePayload: const <String, Object?>{
          'id': 'definition-1',
          'name': '旧名称',
          'notes': '远端备注',
        },
        localOperation: SyncOperation.upsert,
        remoteOperation: SyncOperation.upsert,
      );

      expect(result.kind, SyncMergeKind.merged);
      expect(result.conflictingFields, isEmpty);
      expect(result.payload, <String, Object?>{
        'id': 'definition-1',
        'name': '本地名称',
        'notes': '远端备注',
      });
    });

    test('allows both devices to converge on the same field value', () {
      final result = mergeSyncPayload(
        basePayload: base,
        localPayload: const <String, Object?>{
          'id': 'definition-1',
          'name': '共同名称',
          'notes': '旧备注',
        },
        remotePayload: const <String, Object?>{
          'id': 'definition-1',
          'name': '共同名称',
          'notes': '旧备注',
        },
        localOperation: SyncOperation.upsert,
        remoteOperation: SyncOperation.upsert,
      );

      expect(result.kind, SyncMergeKind.merged);
      expect(result.payload?['name'], '共同名称');
    });

    test('reports different values written to the same field', () {
      final result = mergeSyncPayload(
        basePayload: base,
        localPayload: const <String, Object?>{
          'id': 'definition-1',
          'name': '本地名称',
          'notes': '旧备注',
        },
        remotePayload: const <String, Object?>{
          'id': 'definition-1',
          'name': '远端名称',
          'notes': '旧备注',
        },
        localOperation: SyncOperation.upsert,
        remoteOperation: SyncOperation.upsert,
      );

      expect(result.kind, SyncMergeKind.conflict);
      expect(result.conflictingFields, <String>{'name'});
      expect(result.payload, isNull);
    });

    test('reports delete and edit as a conflict regardless of timestamps', () {
      final result = mergeSyncPayload(
        basePayload: base,
        localPayload: null,
        remotePayload: const <String, Object?>{
          'id': 'definition-1',
          'name': '远端名称',
          'notes': '旧备注',
          'updatedAt': '2026-07-28T00:00:00.000Z',
        },
        localOperation: SyncOperation.delete,
        remoteOperation: SyncOperation.upsert,
      );

      expect(result.kind, SyncMergeKind.conflict);
      expect(result.conflictingFields, <String>{r'$operation'});
    });
  });
}
