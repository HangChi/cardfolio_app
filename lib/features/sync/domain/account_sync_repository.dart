import 'sync_models.dart';

abstract interface class AccountSyncRepository {
  Stream<SyncOverview> watchOverview();

  Stream<List<SyncConflict>> watchConflicts();

  Future<void> register({required String email, required String password});

  Future<void> verifyRegistration({
    required String email,
    required String code,
  });

  Future<void> resendRegistration({required String email});

  Future<void> login({required String email, required String password});

  Future<void> sendPasswordReset({required String email});

  Future<void> verifyPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<void> sendEmailOtp({required String email, required bool createUser});

  Future<void> verifyEmailOtp({required String email, required String code});

  Future<void> sendPhoneOtp({required String phone, required bool createUser});

  Future<void> verifyPhoneOtp({required String phone, required String code});

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
