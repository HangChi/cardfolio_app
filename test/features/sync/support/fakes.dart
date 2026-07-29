import 'dart:typed_data';

import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/features/sync/data/account_sync_remote.dart';
import 'package:cardfolio_app/features/sync/data/secure_session_store.dart';
import 'package:cardfolio_app/features/sync/domain/account_sync_repository.dart';
import 'package:cardfolio_app/features/sync/domain/sync_models.dart';

final class MemorySecureSessionStore implements SecureSessionStore {
  AccountSession? session;

  @override
  Future<void> clear() async {
    session = null;
  }

  @override
  Future<AccountSession?> read() async => session;

  @override
  Future<void> write(AccountSession value) async {
    session = value;
  }
}

final class FakeAccountSyncRemote implements AccountSyncRemote {
  final pushCalls = <List<SyncMutation>>[];
  final acceptedOperationVersions = <String, int>{};
  final attachments = <String, Uint8List>{};
  final pullPages = <SyncPullPage>[];
  var failFirstPushAfterAccept = false;
  var failLogout = false;
  var refreshCalls = 0;
  var logoutCalls = 0;
  var deleteCalls = 0;
  var _nextVersion = 1;

  AccountSession session({
    DateTime? expiresAt,
    String accessToken = 'access-secret',
  }) => AccountSession(
    userId: 'user-1',
    email: 'collector@example.test',
    accessToken: accessToken,
    refreshToken: 'refresh-secret',
    expiresAt: expiresAt ?? DateTime.utc(2026, 7, 30),
  );

  @override
  Future<AccountSession> register({
    required String email,
    required String password,
    required String deviceId,
  }) async => session();

  @override
  Future<AccountSession> login({
    required String email,
    required String password,
    required String deviceId,
  }) async => session();

  @override
  Future<AccountSession> refresh({
    required String refreshToken,
    required String deviceId,
  }) async {
    refreshCalls++;
    return session(accessToken: 'refreshed-access');
  }

  @override
  Future<void> logout({required String accessToken}) async {
    logoutCalls++;
    if (failLogout) {
      throw const SyncTransportFailure(code: 'offline', retryable: true);
    }
  }

  @override
  Future<void> deleteAccount({required String accessToken}) async {
    deleteCalls++;
  }

  @override
  Future<CloudDataDownload> downloadCloudData({
    required String accessToken,
  }) async => CloudDataDownload(
    fileName: 'cloud.zip',
    bytes: Uint8List.fromList(<int>[1]),
    sha256: List<String>.filled(64, '0').join(),
  );

  @override
  Future<SyncPushResult> push({
    required String accessToken,
    required String deviceId,
    required List<SyncMutation> mutations,
  }) async {
    pushCalls.add(List<SyncMutation>.from(mutations));
    final acknowledgements = <SyncAck>[];
    for (final mutation in mutations) {
      final version = acceptedOperationVersions.putIfAbsent(
        mutation.operationId,
        () => _nextVersion++,
      );
      acknowledgements.add(
        SyncAck(
          operationId: mutation.operationId,
          entityType: mutation.entityType,
          entityId: mutation.entityId,
          serverVersion: version,
        ),
      );
    }
    if (failFirstPushAfterAccept && pushCalls.length == 1) {
      throw const SyncTransportFailure(code: 'response_lost', retryable: true);
    }
    return SyncPushResult(
      acknowledgements: acknowledgements,
      changes: const <RemoteSyncChange>[],
      cursor: 'push-${acceptedOperationVersions.length}',
    );
  }

  @override
  Future<SyncPullPage> pull({
    required String accessToken,
    required String? cursor,
    required int limit,
  }) async {
    if (pullPages.isNotEmpty) return pullPages.removeAt(0);
    return SyncPullPage(
      changes: const <RemoteSyncChange>[],
      cursor: cursor,
      hasMore: false,
    );
  }

  @override
  Future<void> uploadAttachment({
    required String accessToken,
    required String checksum,
    required Uint8List bytes,
  }) async {
    attachments.putIfAbsent(checksum, () => Uint8List.fromList(bytes));
  }

  @override
  Future<Uint8List> downloadAttachment({
    required String accessToken,
    required String checksum,
  }) async => Uint8List.fromList(attachments[checksum]!);
}

final class FakeAccountSyncRepository implements AccountSyncRepository {
  SyncOverview overview = const SyncOverview.localOnly();
  List<SyncConflict> conflicts = const <SyncConflict>[];
  String? loginEmail;
  String? loginPassword;
  String? registerEmail;
  var syncCalls = 0;
  var signOutCalls = 0;
  bool? syncEnabled;
  bool? deleteLocalCopy;
  String? resolvedConflictId;
  SyncConflictResolution? resolution;

  @override
  Stream<SyncOverview> watchOverview() => Stream<SyncOverview>.value(overview);

  @override
  Stream<List<SyncConflict>> watchConflicts() =>
      Stream<List<SyncConflict>>.value(conflicts);

  @override
  Future<void> login({required String email, required String password}) async {
    loginEmail = email;
    loginPassword = password;
  }

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {
    registerEmail = email;
  }

  @override
  Future<void> setSyncEnabled(bool enabled) async {
    syncEnabled = enabled;
  }

  @override
  Future<void> syncNow() async {
    syncCalls++;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }

  @override
  Future<void> deleteAccount({required bool deleteLocalCopy}) async {
    this.deleteLocalCopy = deleteLocalCopy;
  }

  @override
  Future<CloudDataDownload> downloadCloudData() async =>
      throw UnimplementedError();

  @override
  Future<void> resolveConflict({
    required String conflictId,
    required SyncConflictResolution resolution,
    Map<String, Object?>? mergedPayload,
  }) async {
    resolvedConflictId = conflictId;
    this.resolution = resolution;
  }
}
