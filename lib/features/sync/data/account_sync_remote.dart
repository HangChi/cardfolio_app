import 'dart:typed_data';

import '../../../core/errors/app_failure.dart';
import '../domain/sync_models.dart';

abstract interface class AccountSyncRemote {
  Future<void> register({
    required String email,
    required String password,
    required String deviceId,
  });

  Future<AccountSession> verifyRegistration({
    required String email,
    required String code,
    required String deviceId,
  });

  Future<void> resendRegistration({
    required String email,
    required String deviceId,
  });

  Future<AccountSession> login({
    required String email,
    required String password,
    required String deviceId,
  });

  Future<void> sendPasswordReset({
    required String email,
    required String deviceId,
  });

  Future<AccountSession> verifyPasswordReset({
    required String email,
    required String code,
    required String newPassword,
    required String deviceId,
  });

  Future<void> sendEmailOtp({
    required String email,
    required bool createUser,
    required String deviceId,
  });

  Future<AccountSession> verifyEmailOtp({
    required String email,
    required String code,
    required String deviceId,
  });

  Future<void> sendPhoneOtp({
    required String phone,
    required bool createUser,
    required String deviceId,
  });

  Future<AccountSession> verifyPhoneOtp({
    required String phone,
    required String code,
    required String deviceId,
  });

  Future<AccountSession> refresh({
    required String refreshToken,
    required String deviceId,
  });

  Future<void> logout({required String accessToken});

  Future<void> deleteAccount({required String accessToken});

  Future<CloudDataDownload> downloadCloudData({required String accessToken});

  Future<SyncPushResult> push({
    required String accessToken,
    required String deviceId,
    required List<SyncMutation> mutations,
  });

  Future<SyncPullPage> pull({
    required String accessToken,
    required String? cursor,
    required int limit,
  });

  Future<void> uploadAttachment({
    required String accessToken,
    required String checksum,
    required Uint8List bytes,
  });

  Future<Uint8List> downloadAttachment({
    required String accessToken,
    required String checksum,
  });
}

final class UnavailableAccountSyncRemote implements AccountSyncRemote {
  const UnavailableAccountSyncRemote();

  Never _unavailable() => throw const SyncConfigurationFailure();

  @override
  Future<void> register({
    required String email,
    required String password,
    required String deviceId,
  }) async => _unavailable();

  @override
  Future<AccountSession> verifyRegistration({
    required String email,
    required String code,
    required String deviceId,
  }) async => _unavailable();

  @override
  Future<void> resendRegistration({
    required String email,
    required String deviceId,
  }) async => _unavailable();

  @override
  Future<AccountSession> login({
    required String email,
    required String password,
    required String deviceId,
  }) async => _unavailable();

  @override
  Future<void> sendPasswordReset({
    required String email,
    required String deviceId,
  }) async => _unavailable();

  @override
  Future<AccountSession> verifyPasswordReset({
    required String email,
    required String code,
    required String newPassword,
    required String deviceId,
  }) async => _unavailable();

  @override
  Future<void> sendEmailOtp({
    required String email,
    required bool createUser,
    required String deviceId,
  }) async => _unavailable();

  @override
  Future<AccountSession> verifyEmailOtp({
    required String email,
    required String code,
    required String deviceId,
  }) async => _unavailable();

  @override
  Future<void> sendPhoneOtp({
    required String phone,
    required bool createUser,
    required String deviceId,
  }) async => _unavailable();

  @override
  Future<AccountSession> verifyPhoneOtp({
    required String phone,
    required String code,
    required String deviceId,
  }) async => _unavailable();

  @override
  Future<AccountSession> refresh({
    required String refreshToken,
    required String deviceId,
  }) async => _unavailable();

  @override
  Future<void> logout({required String accessToken}) async => _unavailable();

  @override
  Future<void> deleteAccount({required String accessToken}) async =>
      _unavailable();

  @override
  Future<CloudDataDownload> downloadCloudData({
    required String accessToken,
  }) async => _unavailable();

  @override
  Future<SyncPushResult> push({
    required String accessToken,
    required String deviceId,
    required List<SyncMutation> mutations,
  }) async => _unavailable();

  @override
  Future<SyncPullPage> pull({
    required String accessToken,
    required String? cursor,
    required int limit,
  }) async => _unavailable();

  @override
  Future<void> uploadAttachment({
    required String accessToken,
    required String checksum,
    required Uint8List bytes,
  }) async => _unavailable();

  @override
  Future<Uint8List> downloadAttachment({
    required String accessToken,
    required String checksum,
  }) async => _unavailable();
}
