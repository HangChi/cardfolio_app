import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../../../core/errors/app_failure.dart';
import '../domain/sync_models.dart';
import 'account_sync_remote.dart';

final class RestAccountSyncRemote implements AccountSyncRemote {
  factory RestAccountSyncRemote({
    required Uri baseUri,
    required http.Client client,
    Duration requestTimeout = const Duration(seconds: 30),
    Duration attachmentTimeout = const Duration(minutes: 2),
  }) {
    if (requestTimeout <= Duration.zero ||
        attachmentTimeout <= Duration.zero) {
      throw ArgumentError('同步超时必须大于零');
    }
    return RestAccountSyncRemote._(
      _validatedBaseUri(baseUri),
      client,
      requestTimeout,
      attachmentTimeout,
    );
  }

  RestAccountSyncRemote._(
    this._baseUri,
    this._client,
    this._requestTimeout,
    this._attachmentTimeout,
  );

  static const int protocolVersion = 1;
  static final RegExp _checksumPattern = RegExp(r'^[0-9a-f]{64}$');

  final Uri _baseUri;
  final http.Client _client;
  final Duration _requestTimeout;
  final Duration _attachmentTimeout;

  @override
  Future<void> register({
    required String email,
    required String password,
    required String deviceId,
  }) async {
    final normalizedEmail = _normalizedEmail(email);
    if (password.length < 8 || deviceId.isEmpty) {
      throw const AuthenticationFailure('请输入有效邮箱和至少 8 位密码。');
    }
    await _jsonRequest(
      'POST',
      '/v1/auth/register',
      body: <String, Object?>{
        'protocolVersion': protocolVersion,
        'email': normalizedEmail,
        'password': password,
        'deviceId': deviceId,
      },
    );
  }

  @override
  Future<AccountSession> verifyRegistration({
    required String email,
    required String code,
    required String deviceId,
  }) => _verifyEmailCode(
    '/v1/auth/register/verify',
    email: email,
    code: code,
    deviceId: deviceId,
  );

  @override
  Future<void> resendRegistration({
    required String email,
    required String deviceId,
  }) => _sendEmailAction(
    '/v1/auth/register/resend',
    email: email,
    deviceId: deviceId,
  );

  @override
  Future<AccountSession> login({
    required String email,
    required String password,
    required String deviceId,
  }) => _authenticate(
    'login',
    email: email,
    password: password,
    deviceId: deviceId,
  );

  @override
  Future<void> sendPasswordReset({
    required String email,
    required String deviceId,
  }) => _sendEmailAction(
    '/v1/auth/password/reset/send',
    email: email,
    deviceId: deviceId,
  );

  @override
  Future<AccountSession> verifyPasswordReset({
    required String email,
    required String code,
    required String newPassword,
    required String deviceId,
  }) async {
    if (newPassword.length < 8) {
      throw const AuthenticationFailure('新密码至少需要 8 位。');
    }
    final normalizedEmail = _normalizedEmail(email);
    final normalizedCode = code.trim();
    if (!RegExp(r'^\d{6,10}$').hasMatch(normalizedCode) || deviceId.isEmpty) {
      throw const AuthenticationFailure('请输入有效邮箱验证码。');
    }
    final response = await _jsonRequest(
      'POST',
      '/v1/auth/password/reset/verify',
      body: <String, Object?>{
        'protocolVersion': protocolVersion,
        'email': normalizedEmail,
        'code': normalizedCode,
        'newPassword': newPassword,
        'deviceId': deviceId,
      },
    );
    return AccountSession.fromJson(response);
  }

  @override
  Future<void> sendEmailOtp({
    required String email,
    required bool createUser,
    required String deviceId,
  }) async {
    final normalizedEmail = _normalizedEmail(email);
    if (deviceId.isEmpty) throw const AuthenticationFailure();
    await _jsonRequest(
      'POST',
      '/v1/auth/email/send',
      body: <String, Object?>{
        'protocolVersion': protocolVersion,
        'email': normalizedEmail,
        'createUser': createUser,
        'deviceId': deviceId,
      },
    );
  }

  @override
  Future<AccountSession> verifyEmailOtp({
    required String email,
    required String code,
    required String deviceId,
  }) async {
    final normalizedEmail = _normalizedEmail(email);
    final normalizedCode = code.trim();
    if (!RegExp(r'^\d{6,10}$').hasMatch(normalizedCode) || deviceId.isEmpty) {
      throw const AuthenticationFailure('请输入有效邮箱验证码。');
    }
    final response = await _jsonRequest(
      'POST',
      '/v1/auth/email/verify',
      body: <String, Object?>{
        'protocolVersion': protocolVersion,
        'email': normalizedEmail,
        'code': normalizedCode,
        'deviceId': deviceId,
      },
    );
    return AccountSession.fromJson(response);
  }

  @override
  Future<void> sendPhoneOtp({
    required String phone,
    required bool createUser,
    required String deviceId,
  }) async {
    final normalizedPhone = _normalizedPhone(phone);
    if (deviceId.isEmpty) throw const AuthenticationFailure();
    await _jsonRequest(
      'POST',
      '/v1/auth/phone/send',
      body: <String, Object?>{
        'protocolVersion': protocolVersion,
        'phone': normalizedPhone,
        'createUser': createUser,
        'deviceId': deviceId,
      },
    );
  }

  @override
  Future<AccountSession> verifyPhoneOtp({
    required String phone,
    required String code,
    required String deviceId,
  }) async {
    final normalizedPhone = _normalizedPhone(phone);
    final normalizedCode = code.trim();
    if (!RegExp(r'^\d{6,10}$').hasMatch(normalizedCode) || deviceId.isEmpty) {
      throw const AuthenticationFailure('请输入有效短信验证码。');
    }
    final response = await _jsonRequest(
      'POST',
      '/v1/auth/phone/verify',
      body: <String, Object?>{
        'protocolVersion': protocolVersion,
        'phone': normalizedPhone,
        'code': normalizedCode,
        'deviceId': deviceId,
      },
    );
    return AccountSession.fromJson(response);
  }

  @override
  Future<AccountSession> refresh({
    required String refreshToken,
    required String deviceId,
  }) async {
    final response = await _jsonRequest(
      'POST',
      '/v1/auth/refresh',
      body: <String, Object?>{
        'protocolVersion': protocolVersion,
        'refreshToken': refreshToken,
        'deviceId': deviceId,
      },
    );
    return AccountSession.fromJson(response);
  }

  @override
  Future<void> logout({required String accessToken}) async {
    await _request('POST', '/v1/auth/logout', accessToken: accessToken);
  }

  @override
  Future<void> deleteAccount({required String accessToken}) async {
    await _request(
      'DELETE',
      '/v1/account',
      accessToken: accessToken,
      extraHeaders: const <String, String>{
        'x-account-deletion-confirmation': 'DELETE',
      },
    );
  }

  @override
  Future<CloudDataDownload> downloadCloudData({
    required String accessToken,
  }) async {
    final response = await _request(
      'GET',
      '/v1/account/export',
      accessToken: accessToken,
    );
    final checksum = response.headers['x-content-sha256'] ?? '';
    final actual = sha256.convert(response.bodyBytes).toString();
    if (!_checksumPattern.hasMatch(checksum) || actual != checksum) {
      throw const SyncProtocolFailure('云端数据下载校验失败，请重试。');
    }
    return CloudDataDownload(
      fileName: response.headers['x-file-name'] ?? 'cardfolio-cloud-export.zip',
      bytes: response.bodyBytes,
      sha256: checksum,
    );
  }

  @override
  Future<SyncPushResult> push({
    required String accessToken,
    required String deviceId,
    required List<SyncMutation> mutations,
  }) async {
    if (mutations.isEmpty || mutations.length > 100) {
      throw ArgumentError.value(mutations.length, 'mutations', '必须在 1..100');
    }
    final operationIds = mutations.map((item) => item.operationId).toList()
      ..sort();
    final idempotencyKey = operationIds.length == 1
        ? operationIds.single
        : sha256.convert(utf8.encode(operationIds.join('\n'))).toString();
    final response = await _jsonRequest(
      'POST',
      '/v1/sync/push',
      accessToken: accessToken,
      extraHeaders: <String, String>{'idempotency-key': idempotencyKey},
      body: <String, Object?>{
        'protocolVersion': protocolVersion,
        'deviceId': deviceId,
        'mutations': mutations.map((item) => item.toJson()).toList(),
      },
    );
    return SyncPushResult(
      acknowledgements: _objectList(
        response,
        'acks',
      ).map(SyncAck.fromJson).toList(growable: false),
      changes: _objectList(
        response,
        'changes',
      ).map(RemoteSyncChange.fromJson).toList(growable: false),
      cursor: _optionalString(response['cursor']),
    );
  }

  @override
  Future<SyncPullPage> pull({
    required String accessToken,
    required String? cursor,
    required int limit,
  }) async {
    if (limit < 1 || limit > 100) {
      throw ArgumentError.value(limit, 'limit', '必须在 1..100');
    }
    final response = await _jsonRequest(
      'GET',
      '/v1/sync/pull',
      accessToken: accessToken,
      query: <String, String>{'cursor': ?cursor, 'limit': limit.toString()},
    );
    final hasMore = response['hasMore'];
    if (hasMore is! bool) {
      throw const SyncProtocolFailure();
    }
    return SyncPullPage(
      changes: _objectList(
        response,
        'changes',
      ).map(RemoteSyncChange.fromJson).toList(growable: false),
      cursor: _optionalString(response['cursor']),
      hasMore: hasMore,
    );
  }

  @override
  Future<void> uploadAttachment({
    required String accessToken,
    required String checksum,
    required Uint8List bytes,
  }) async {
    _validateAttachment(checksum, bytes);
    await _request(
      'PUT',
      '/v1/sync/attachments/$checksum',
      accessToken: accessToken,
      bodyBytes: bytes,
      extraHeaders: <String, String>{
        'content-type': 'application/octet-stream',
        'idempotency-key': checksum,
        'x-content-sha256': checksum,
      },
    );
  }

  @override
  Future<Uint8List> downloadAttachment({
    required String accessToken,
    required String checksum,
  }) async {
    if (!_checksumPattern.hasMatch(checksum)) {
      throw ArgumentError.value(checksum, 'checksum', '必须是 SHA-256');
    }
    final response = await _request(
      'GET',
      '/v1/sync/attachments/$checksum',
      accessToken: accessToken,
    );
    final bytes = Uint8List.fromList(response.bodyBytes);
    _validateAttachment(checksum, bytes);
    return bytes;
  }

  Future<AccountSession> _authenticate(
    String action, {
    required String email,
    required String password,
    required String deviceId,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.length < 8 || deviceId.isEmpty) {
      throw const AuthenticationFailure('请输入有效邮箱和至少 8 位密码。');
    }
    final response = await _jsonRequest(
      'POST',
      '/v1/auth/$action',
      body: <String, Object?>{
        'protocolVersion': protocolVersion,
        'email': normalizedEmail,
        'password': password,
        'deviceId': deviceId,
      },
    );
    return AccountSession.fromJson(response);
  }

  Future<void> _sendEmailAction(
    String path, {
    required String email,
    required String deviceId,
  }) async {
    final normalizedEmail = _normalizedEmail(email);
    if (deviceId.isEmpty) throw const AuthenticationFailure();
    await _jsonRequest(
      'POST',
      path,
      body: <String, Object?>{
        'protocolVersion': protocolVersion,
        'email': normalizedEmail,
        'deviceId': deviceId,
      },
    );
  }

  Future<AccountSession> _verifyEmailCode(
    String path, {
    required String email,
    required String code,
    required String deviceId,
  }) async {
    final normalizedEmail = _normalizedEmail(email);
    final normalizedCode = code.trim();
    if (!RegExp(r'^\d{6,10}$').hasMatch(normalizedCode) || deviceId.isEmpty) {
      throw const AuthenticationFailure('请输入有效邮箱验证码。');
    }
    final response = await _jsonRequest(
      'POST',
      path,
      body: <String, Object?>{
        'protocolVersion': protocolVersion,
        'email': normalizedEmail,
        'code': normalizedCode,
        'deviceId': deviceId,
      },
    );
    return AccountSession.fromJson(response);
  }

  static String _normalizedPhone(String value) {
    final phone = value.trim().replaceAll(RegExp(r'[\s()-]'), '');
    if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(phone)) {
      throw const AuthenticationFailure('手机号必须使用国际格式，例如 +8613812345678。');
    }
    return phone;
  }

  static String _normalizedEmail(String value) {
    final email = value.trim().toLowerCase();
    if (!email.contains('@') || email.startsWith('@') || email.endsWith('@')) {
      throw const AuthenticationFailure('请输入有效邮箱地址。');
    }
    return email;
  }

  Future<Map<String, Object?>> _jsonRequest(
    String method,
    String path, {
    String? accessToken,
    Map<String, String>? query,
    Map<String, String>? extraHeaders,
    Map<String, Object?>? body,
  }) async {
    final response = await _request(
      method,
      path,
      accessToken: accessToken,
      query: query,
      extraHeaders: extraHeaders,
      bodyBytes: body == null
          ? null
          : Uint8List.fromList(utf8.encode(jsonEncode(body))),
    );
    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on Object catch (error) {
      throw SyncProtocolFailure('云端返回了无法识别的数据。', error);
    }
    if (decoded is! Map<String, Object?> ||
        decoded['protocolVersion'] != protocolVersion) {
      throw const SyncProtocolFailure();
    }
    return decoded;
  }

  Future<http.Response> _request(
    String method,
    String path, {
    String? accessToken,
    Map<String, String>? query,
    Map<String, String>? extraHeaders,
    Uint8List? bodyBytes,
  }) async {
    final request = http.Request(method, _uri(path, query))
      ..headers.addAll(<String, String>{
        'accept': 'application/json',
        if (bodyBytes != null)
          'content-type': 'application/json; charset=utf-8',
        if (accessToken != null) 'authorization': 'Bearer $accessToken',
        ...?extraHeaders,
      });
    if (bodyBytes != null) request.bodyBytes = bodyBytes;

    final http.Response response;
    final timeout = path.startsWith('/v1/sync/attachments/')
        ? _attachmentTimeout
        : _requestTimeout;
    try {
      response = await (() async {
        final streamed = await _client.send(request);
        return http.Response.fromStream(streamed);
      })().timeout(timeout);
    } on TimeoutException catch (error) {
      throw SyncTransportFailure(
        code: 'network_timeout',
        retryable: true,
        cause: error,
      );
    } on Object catch (error) {
      throw SyncTransportFailure(
        code: 'network_unavailable',
        retryable: true,
        cause: error,
      );
    }
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }
    _throwResponseFailure(response);
  }

  Never _throwResponseFailure(http.Response response) {
    var code = 'http_${response.statusCode}';
    var retryable =
        response.statusCode == 408 ||
        response.statusCode == 429 ||
        response.statusCode >= 500;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, Object?>) {
        final remoteCode = decoded['code'];
        final remoteRetryable = decoded['retryable'];
        if (remoteCode is String && remoteCode.isNotEmpty) code = remoteCode;
        if (remoteRetryable is bool) retryable = remoteRetryable;
      }
    } on Object {
      // 错误正文永不展示；无法解析时使用状态码分类。
    }
    if (response.statusCode == 401) throw const AuthenticationFailure();
    if (response.statusCode == 403) {
      throw const SyncTransportFailure(
        code: 'forbidden',
        retryable: false,
        userMessage: '没有权限访问这份云端数据。',
      );
    }
    if (response.statusCode == 409 && code == 'idempotency_mismatch') {
      throw const SyncProtocolFailure('同步操作校验不一致，本地更改已保留。');
    }
    throw SyncTransportFailure(code: code, retryable: retryable);
  }

  Uri _uri(String path, Map<String, String>? query) {
    final basePath = _baseUri.path.endsWith('/')
        ? _baseUri.path.substring(0, _baseUri.path.length - 1)
        : _baseUri.path;
    return _baseUri.replace(path: '$basePath$path', queryParameters: query);
  }

  static Uri _validatedBaseUri(Uri value) {
    if (value.scheme != 'https' || !value.hasAuthority) {
      throw const SyncConfigurationFailure();
    }
    return value.replace(query: null, fragment: null);
  }

  static List<Map<String, Object?>> _objectList(
    Map<String, Object?> json,
    String key,
  ) {
    final value = json[key];
    if (value is! List) throw const SyncProtocolFailure();
    return value
        .map((item) {
          if (item is! Map<String, Object?>) {
            throw const SyncProtocolFailure();
          }
          return item;
        })
        .toList(growable: false);
  }

  static String? _optionalString(Object? value) {
    if (value == null) return null;
    if (value is! String) throw const SyncProtocolFailure();
    return value;
  }

  static void _validateAttachment(String checksum, Uint8List bytes) {
    if (!_checksumPattern.hasMatch(checksum)) {
      throw ArgumentError.value(checksum, 'checksum', '必须是 SHA-256');
    }
    if (bytes.isEmpty || bytes.length > 64 * 1024 * 1024) {
      throw const SyncProtocolFailure('同步图片为空或超过 64 MiB。');
    }
    if (sha256.convert(bytes).toString() != checksum) {
      throw const SyncProtocolFailure('同步图片校验失败。');
    }
  }
}
