import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/time/clock.dart';
import '../../cards/data/files/managed_image_store.dart';
import '../domain/account_sync_repository.dart';
import '../domain/sync_models.dart';
import 'account_sync_remote.dart';
import 'local/sync_local_store.dart';
import 'secure_session_store.dart';

final class AccountSyncRepositoryImpl implements AccountSyncRepository {
  factory AccountSyncRepositoryImpl({
    required AccountSyncRemote remote,
    required SecureSessionStore sessions,
    required SyncLocalStore local,
    required ManagedImageStore images,
    required Clock clock,
  }) => AccountSyncRepositoryImpl._(remote, sessions, local, images, clock);

  AccountSyncRepositoryImpl._(
    this._remote,
    this._sessions,
    this._local,
    this._images,
    this._clock,
  );

  final AccountSyncRemote _remote;
  final SecureSessionStore _sessions;
  final SyncLocalStore _local;
  final ManagedImageStore _images;
  final Clock _clock;

  Future<void>? _activeSync;

  @override
  Stream<SyncOverview> watchOverview() => _local.watchOverview();

  @override
  Stream<List<SyncConflict>> watchConflicts() => _local.watchConflicts();

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {
    final settings = await _local.settings();
    await _remote.register(
      email: email,
      password: password,
      deviceId: settings.deviceId,
    );
  }

  @override
  Future<void> verifyRegistration({
    required String email,
    required String code,
  }) async {
    final settings = await _local.settings();
    final session = await _remote.verifyRegistration(
      email: email,
      code: code,
      deviceId: settings.deviceId,
    );
    await _acceptSession(session);
  }

  @override
  Future<void> resendRegistration({required String email}) async {
    final settings = await _local.settings();
    await _remote.resendRegistration(email: email, deviceId: settings.deviceId);
  }

  @override
  Future<void> login({required String email, required String password}) async {
    final settings = await _local.settings();
    final session = await _remote.login(
      email: email,
      password: password,
      deviceId: settings.deviceId,
    );
    await _acceptSession(session);
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {
    final settings = await _local.settings();
    await _remote.sendPasswordReset(email: email, deviceId: settings.deviceId);
  }

  @override
  Future<void> verifyPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final settings = await _local.settings();
    final session = await _remote.verifyPasswordReset(
      email: email,
      code: code,
      newPassword: newPassword,
      deviceId: settings.deviceId,
    );
    await _acceptSession(session);
  }

  @override
  Future<void> sendEmailOtp({
    required String email,
    required bool createUser,
  }) async {
    final settings = await _local.settings();
    await _remote.sendEmailOtp(
      email: email,
      createUser: createUser,
      deviceId: settings.deviceId,
    );
  }

  @override
  Future<void> verifyEmailOtp({
    required String email,
    required String code,
  }) async {
    final settings = await _local.settings();
    final session = await _remote.verifyEmailOtp(
      email: email,
      code: code,
      deviceId: settings.deviceId,
    );
    await _acceptSession(session);
  }

  @override
  Future<void> sendPhoneOtp({
    required String phone,
    required bool createUser,
  }) async {
    final settings = await _local.settings();
    await _remote.sendPhoneOtp(
      phone: phone,
      createUser: createUser,
      deviceId: settings.deviceId,
    );
  }

  @override
  Future<void> verifyPhoneOtp({
    required String phone,
    required String code,
  }) async {
    final settings = await _local.settings();
    final session = await _remote.verifyPhoneOtp(
      phone: phone,
      code: code,
      deviceId: settings.deviceId,
    );
    await _acceptSession(session);
  }

  @override
  Future<void> setSyncEnabled(bool enabled) async {
    await _local.setEnabled(enabled);
    if (enabled) await syncNow();
  }

  @override
  Future<void> syncNow() {
    final active = _activeSync;
    if (active != null) return active;
    final operation = _runSync();
    _activeSync = operation;
    return operation.whenComplete(() {
      if (identical(_activeSync, operation)) _activeSync = null;
    });
  }

  Future<void> _runSync() async {
    final settings = await _local.settings();
    if (settings.account == null) throw const AuthenticationFailure();
    if (!settings.enabled) return;
    var session = await _requireSession(settings);
    if (!_isFresh(session)) {
      session = await _refreshSession(session, settings.deviceId);
    }

    try {
      await _syncWithSession(session, settings);
    } on AuthenticationFailure {
      session = await _refreshSession(session, settings.deviceId);
      await _syncWithSession(session, await _local.settings());
    } on SyncTransportFailure catch (failure) {
      final pending = await _local.pendingMutations();
      await _local.markMutationsFailed(
        pending.map((item) => item.operationId),
        errorCode: failure.code,
      );
      rethrow;
    }
  }

  Future<void> _syncWithSession(
    AccountSession session,
    LocalSyncSettings initialSettings,
  ) async {
    await _local.captureLocalChanges();
    var cursor = initialSettings.cursor;
    final pending = await _local.pendingMutations();
    if (pending.isNotEmpty) {
      final prepared = <SyncMutation>[];
      for (final mutation in pending) {
        prepared.add(await _prepareMutation(session.accessToken, mutation));
      }
      final pushed = await _remote.push(
        accessToken: session.accessToken,
        deviceId: initialSettings.deviceId,
        mutations: prepared,
      );
      await _local.acknowledge(pushed.acknowledgements);
      final changes = await _prepareRemoteChanges(
        session.accessToken,
        pushed.changes,
      );
      cursor = pushed.cursor ?? cursor;
      await _local.applyRemoteChanges(changes, cursor: cursor);
    }

    var pages = 0;
    while (true) {
      if (pages++ >= 100) {
        throw const SyncProtocolFailure('云端增量分页超过安全限制。');
      }
      final page = await _remote.pull(
        accessToken: session.accessToken,
        cursor: cursor,
        limit: 100,
      );
      final changes = await _prepareRemoteChanges(
        session.accessToken,
        page.changes,
      );
      cursor = page.cursor ?? cursor;
      await _local.applyRemoteChanges(changes, cursor: cursor);
      if (!page.hasMore) break;
    }
    await _local.markSyncSucceeded(cursor: cursor);
  }

  Future<SyncMutation> _prepareMutation(
    String accessToken,
    SyncMutation mutation,
  ) async {
    if (mutation.entityType != 'cardImages' ||
        mutation.operation != SyncOperation.upsert) {
      return mutation;
    }
    final payload = Map<String, Object?>.from(mutation.payload!);
    final attachments = <Map<String, Object?>>[];
    final relativePath = payload['relativePath'];
    final checksum = payload['checksum'];
    if (relativePath is! String || checksum is! String) {
      throw const SyncProtocolFailure('图片同步载荷缺少路径或校验和。');
    }
    await _uploadManagedFile(
      accessToken: accessToken,
      relativePath: relativePath,
      expectedChecksum: checksum,
      attachments: attachments,
    );
    final derivedPath = payload['derivedRelativePath'];
    if (derivedPath != null) {
      if (derivedPath is! String) {
        throw const SyncProtocolFailure('派生图片同步路径无效。');
      }
      await _uploadManagedFile(
        accessToken: accessToken,
        relativePath: derivedPath,
        expectedChecksum: null,
        attachments: attachments,
      );
    }
    payload['_attachments'] = attachments;
    return SyncMutation(
      operationId: mutation.operationId,
      entityType: mutation.entityType,
      entityId: mutation.entityId,
      operation: mutation.operation,
      baseServerVersion: mutation.baseServerVersion,
      payload: payload,
      changedFields: mutation.changedFields,
      createdAt: mutation.createdAt,
    );
  }

  Future<void> _uploadManagedFile({
    required String accessToken,
    required String relativePath,
    required String? expectedChecksum,
    required List<Map<String, Object?>> attachments,
  }) async {
    final file = _images.resolve(relativePath);
    final Uint8List bytes;
    try {
      bytes = await file.readAsBytes();
    } on Object catch (error) {
      throw SyncProtocolFailure('本地同步图片无法读取。', error);
    }
    final checksum = sha256.convert(bytes).toString();
    if (expectedChecksum != null && checksum != expectedChecksum) {
      throw const SyncProtocolFailure('本地同步图片校验失败。');
    }
    await _remote.uploadAttachment(
      accessToken: accessToken,
      checksum: checksum,
      bytes: bytes,
    );
    attachments.add(<String, Object?>{
      'relativePath': relativePath,
      'checksum': checksum,
    });
  }

  Future<List<RemoteSyncChange>> _prepareRemoteChanges(
    String accessToken,
    List<RemoteSyncChange> changes,
  ) async {
    final result = <RemoteSyncChange>[];
    for (final change in changes) {
      final payload = change.payload == null
          ? null
          : Map<String, Object?>.from(change.payload!);
      if (change.entityType == 'cardImages' && payload != null) {
        final rawAttachments = payload.remove('_attachments');
        if (rawAttachments != null) {
          if (rawAttachments is! List) {
            throw const SyncProtocolFailure('云端图片附件列表无效。');
          }
          for (final raw in rawAttachments) {
            if (raw is! Map<String, Object?>) {
              throw const SyncProtocolFailure('云端图片附件无效。');
            }
            final relativePath = raw['relativePath'];
            final checksum = raw['checksum'];
            if (relativePath is! String || checksum is! String) {
              throw const SyncProtocolFailure('云端图片附件字段无效。');
            }
            final bytes = await _remote.downloadAttachment(
              accessToken: accessToken,
              checksum: checksum,
            );
            await _images.writeSyncedImage(
              relativePath: relativePath,
              bytes: bytes,
              expectedChecksum: checksum,
            );
          }
        }
      }
      result.add(
        RemoteSyncChange(
          changeId: change.changeId,
          entityType: change.entityType,
          entityId: change.entityId,
          operation: change.operation,
          serverVersion: change.serverVersion,
          payload: payload,
          changedFields: change.changedFields.where((field) {
            return field != '_attachments';
          }).toSet(),
          occurredAt: change.occurredAt,
        ),
      );
    }
    return result;
  }

  @override
  Future<void> signOut() async {
    final session = await _sessions.read();
    if (session != null) {
      try {
        await _remote.logout(accessToken: session.accessToken);
      } on AppFailure {
        // 本地退出不能被远端故障阻断；服务端短期令牌会自行过期。
      }
    }
    await _sessions.clear();
    await _local.clearSyncIdentity();
  }

  @override
  Future<void> deleteAccount({required bool deleteLocalCopy}) async {
    final settings = await _local.settings();
    final session = await _requireSession(settings);
    await _remote.deleteAccount(accessToken: session.accessToken);
    await _sessions.clear();
    try {
      if (deleteLocalCopy) {
        await _local.clearBusinessData();
        await _images.removeOrphans(const <String>{});
      }
    } finally {
      await _local.clearSyncIdentity();
    }
  }

  @override
  Future<CloudDataDownload> downloadCloudData() async {
    final settings = await _local.settings();
    var session = await _requireSession(settings);
    if (!_isFresh(session)) {
      session = await _refreshSession(session, settings.deviceId);
    }
    return _remote.downloadCloudData(accessToken: session.accessToken);
  }

  @override
  Future<void> resolveConflict({
    required String conflictId,
    required SyncConflictResolution resolution,
    Map<String, Object?>? mergedPayload,
  }) async {
    await _local.resolveConflict(
      conflictId: conflictId,
      resolution: resolution,
      mergedPayload: mergedPayload,
    );
    final settings = await _local.settings();
    if (settings.enabled) await syncNow();
  }

  Future<void> _acceptSession(AccountSession session) async {
    await _sessions.write(session);
    await _local.setAccount(
      AccountSummary(userId: session.userId, email: session.email),
    );
  }

  Future<AccountSession> _requireSession(LocalSyncSettings settings) async {
    final session = await _sessions.read();
    if (session == null ||
        settings.account == null ||
        session.userId != settings.account!.userId) {
      await _sessions.clear();
      throw const AuthenticationFailure();
    }
    return session;
  }

  bool _isFresh(AccountSession session) => session.expiresAt.isAfter(
    _clock.nowUtc().add(const Duration(minutes: 1)),
  );

  Future<AccountSession> _refreshSession(
    AccountSession current,
    String deviceId,
  ) async {
    final refreshed = await _remote.refresh(
      refreshToken: current.refreshToken,
      deviceId: deviceId,
    );
    if (refreshed.userId != current.userId) {
      await _sessions.clear();
      throw const AuthenticationFailure();
    }
    await _sessions.write(refreshed);
    return refreshed;
  }
}
