import 'sync_models.dart';

abstract interface class AccountSyncRepository {
  Stream<SyncOverview> watchOverview();

  Stream<List<SyncConflict>> watchConflicts();

  Future<void> register({required String email, required String password});

  Future<void> login({required String email, required String password});

  Future<void> setSyncEnabled(bool enabled);

  Future<void> syncNow();

  Future<void> signOut();

  Future<void> deleteAccount({required bool deleteLocalCopy});

  Future<CloudDataDownload> downloadCloudData();

  Future<void> resolveConflict({
    required String conflictId,
    required SyncConflictResolution resolution,
    Map<String, Object?>? mergedPayload,
  });
}
