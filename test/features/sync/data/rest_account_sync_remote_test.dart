import 'dart:convert';
import 'dart:typed_data';

import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/features/sync/data/rest_account_sync_remote.dart';
import 'package:cardfolio_app/features/sync/domain/sync_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('rejects a non-HTTPS service endpoint', () {
    expect(
      () => RestAccountSyncRemote(
        baseUri: Uri.parse('http://sync.example.test'),
        client: MockClient((_) async => http.Response('', 500)),
      ),
      throwsA(isA<SyncConfigurationFailure>()),
    );
  });

  test('login sends the device and parses a versioned session', () async {
    late http.Request request;
    final remote = RestAccountSyncRemote(
      baseUri: Uri.parse('https://sync.example.test'),
      client: MockClient((value) async {
        request = value;
        return http.Response(
          jsonEncode(<String, Object?>{
            'protocolVersion': 1,
            'userId': 'user-1',
            'email': 'collector@example.test',
            'accessToken': 'access-secret',
            'refreshToken': 'refresh-secret',
            'expiresAt': '2026-07-29T10:00:00.000Z',
          }),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      }),
    );

    final session = await remote.login(
      email: 'collector@example.test',
      password: 'password-123',
      deviceId: 'device-1',
    );

    expect(request.method, 'POST');
    expect(request.url.path, '/v1/auth/login');
    expect(jsonDecode(request.body), <String, Object?>{
      'protocolVersion': 1,
      'email': 'collector@example.test',
      'password': 'password-123',
      'deviceId': 'device-1',
    });
    expect(session.userId, 'user-1');
    expect(session.accessToken, 'access-secret');
  });

  test(
    'registration and password recovery use dedicated OTP endpoints',
    () async {
      final requests = <http.Request>[];
      final remote = RestAccountSyncRemote(
        baseUri: Uri.parse('https://sync.example.test'),
        client: MockClient((request) async {
          requests.add(request);
          final isVerification = request.url.path.endsWith('/verify');
          return http.Response(
            jsonEncode(
              isVerification
                  ? <String, Object?>{
                      'protocolVersion': 1,
                      'userId': 'user-1',
                      'email': 'collector@example.test',
                      'accessToken': 'access-secret',
                      'refreshToken': 'refresh-secret',
                      'expiresAt': '2026-07-29T10:00:00.000Z',
                    }
                  : <String, Object?>{
                      'protocolVersion': 1,
                      'resendAfterSeconds': 60,
                    },
            ),
            200,
          );
        }),
      );

      await remote.register(
        email: 'new@example.test',
        password: 'password-123',
        deviceId: 'device-1',
      );
      await remote.verifyRegistration(
        email: 'new@example.test',
        code: '123456',
        deviceId: 'device-1',
      );
      await remote.sendPasswordReset(
        email: 'collector@example.test',
        deviceId: 'device-1',
      );
      await remote.verifyPasswordReset(
        email: 'collector@example.test',
        code: '654321',
        newPassword: 'new-password-123',
        deviceId: 'device-1',
      );

      expect(requests.map((request) => request.url.path), <String>[
        '/v1/auth/register',
        '/v1/auth/register/verify',
        '/v1/auth/password/reset/send',
        '/v1/auth/password/reset/verify',
      ]);
      expect(jsonDecode(requests.last.body), <String, Object?>{
        'protocolVersion': 1,
        'email': 'collector@example.test',
        'code': '654321',
        'newPassword': 'new-password-123',
        'deviceId': 'device-1',
      });
    },
  );

  test('phone OTP send and verify use the versioned auth contract', () async {
    final requests = <http.Request>[];
    final remote = RestAccountSyncRemote(
      baseUri: Uri.parse('https://sync.example.test'),
      client: MockClient((request) async {
        requests.add(request);
        if (request.url.path.endsWith('/send')) {
          return http.Response(
            jsonEncode(<String, Object?>{
              'protocolVersion': 1,
              'resendAfterSeconds': 60,
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode(<String, Object?>{
            'protocolVersion': 1,
            'userId': 'user-phone',
            'email': '+8613812345678',
            'accessToken': 'phone-access',
            'refreshToken': 'phone-refresh',
            'expiresAt': '2026-07-29T10:00:00.000Z',
          }),
          200,
        );
      }),
    );

    await remote.sendPhoneOtp(
      phone: '+86 138-1234-5678',
      createUser: true,
      deviceId: 'device-1',
    );
    final session = await remote.verifyPhoneOtp(
      phone: '+8613812345678',
      code: '123456',
      deviceId: 'device-1',
    );

    expect(requests[0].url.path, '/v1/auth/phone/send');
    expect(jsonDecode(requests[0].body), <String, Object?>{
      'protocolVersion': 1,
      'phone': '+8613812345678',
      'createUser': true,
      'deviceId': 'device-1',
    });
    expect(requests[1].url.path, '/v1/auth/phone/verify');
    expect(jsonDecode(requests[1].body), <String, Object?>{
      'protocolVersion': 1,
      'phone': '+8613812345678',
      'code': '123456',
      'deviceId': 'device-1',
    });
    expect(session.email, '+8613812345678');
  });

  test('email OTP send and verify use the versioned auth contract', () async {
    final requests = <http.Request>[];
    final remote = RestAccountSyncRemote(
      baseUri: Uri.parse('https://sync.example.test'),
      client: MockClient((request) async {
        requests.add(request);
        if (request.url.path.endsWith('/send')) {
          return http.Response(
            jsonEncode(<String, Object?>{
              'protocolVersion': 1,
              'resendAfterSeconds': 60,
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode(<String, Object?>{
            'protocolVersion': 1,
            'userId': 'user-email',
            'email': 'collector@example.test',
            'accessToken': 'email-access',
            'refreshToken': 'email-refresh',
            'expiresAt': '2026-07-29T10:00:00.000Z',
          }),
          200,
        );
      }),
    );

    await remote.sendEmailOtp(
      email: ' Collector@Example.Test ',
      createUser: true,
      deviceId: 'device-1',
    );
    final session = await remote.verifyEmailOtp(
      email: 'collector@example.test',
      code: '123456',
      deviceId: 'device-1',
    );

    expect(requests[0].url.path, '/v1/auth/email/send');
    expect(jsonDecode(requests[0].body), <String, Object?>{
      'protocolVersion': 1,
      'email': 'collector@example.test',
      'createUser': true,
      'deviceId': 'device-1',
    });
    expect(requests[1].url.path, '/v1/auth/email/verify');
    expect(jsonDecode(requests[1].body), <String, Object?>{
      'protocolVersion': 1,
      'email': 'collector@example.test',
      'code': '123456',
      'deviceId': 'device-1',
    });
    expect(session.email, 'collector@example.test');
  });

  test('push carries bearer auth and stable idempotency keys', () async {
    late http.Request request;
    final remote = RestAccountSyncRemote(
      baseUri: Uri.parse('https://sync.example.test'),
      client: MockClient((value) async {
        request = value;
        return http.Response(
          jsonEncode(<String, Object?>{
            'protocolVersion': 1,
            'acks': <Object?>[
              <String, Object?>{
                'operationId': '4f8d7a3e-28c2-4aa2-94b8-a08f2248d64c',
                'entityType': 'cardDefinitions',
                'entityId': 'definition-1',
                'serverVersion': 3,
              },
            ],
            'changes': <Object?>[],
            'cursor': 'cursor-3',
          }),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      }),
    );
    final mutation = SyncMutation(
      operationId: '4f8d7a3e-28c2-4aa2-94b8-a08f2248d64c',
      entityType: 'cardDefinitions',
      entityId: 'definition-1',
      operation: SyncOperation.upsert,
      baseServerVersion: 2,
      payload: const <String, Object?>{'id': 'definition-1', 'name': '本地名称'},
      changedFields: const <String>{'name'},
      createdAt: DateTime.utc(2026, 7, 29, 8),
    );

    final result = await remote.push(
      accessToken: 'access-secret',
      deviceId: 'device-1',
      mutations: <SyncMutation>[mutation],
    );

    expect(request.headers['authorization'], 'Bearer access-secret');
    expect(
      request.headers['idempotency-key'],
      '4f8d7a3e-28c2-4aa2-94b8-a08f2248d64c',
    );
    final body = jsonDecode(request.body) as Map<String, Object?>;
    expect(body['deviceId'], 'device-1');
    expect((body['mutations']! as List).single, mutation.toJson());
    expect(result.acknowledgements.single.serverVersion, 3);
    expect(result.cursor, 'cursor-3');
  });

  test('pull treats the cursor as opaque and parses changes', () async {
    late http.Request request;
    final remote = RestAccountSyncRemote(
      baseUri: Uri.parse('https://sync.example.test/base'),
      client: MockClient((value) async {
        request = value;
        return http.Response(
          jsonEncode(<String, Object?>{
            'protocolVersion': 1,
            'changes': <Object?>[],
            'cursor': 'opaque/next+1',
            'hasMore': false,
          }),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        );
      }),
    );

    final page = await remote.pull(
      accessToken: 'access-secret',
      cursor: 'opaque/current+1',
      limit: 100,
    );

    expect(request.url.path, '/base/v1/sync/pull');
    expect(request.url.queryParameters['cursor'], 'opaque/current+1');
    expect(request.url.queryParameters['limit'], '100');
    expect(page.cursor, 'opaque/next+1');
  });

  test(
    'maps retryable server failures without exposing response text',
    () async {
      final remote = RestAccountSyncRemote(
        baseUri: Uri.parse('https://sync.example.test'),
        client: MockClient(
          (_) async => http.Response(
            jsonEncode(<String, Object?>{
              'code': 'service_busy',
              'message': 'internal SQL and user payload',
              'retryable': true,
            }),
            503,
          ),
        ),
      );

      await expectLater(
        remote.pull(accessToken: 'secret', cursor: null, limit: 100),
        throwsA(
          isA<SyncTransportFailure>()
              .having((failure) => failure.code, 'code', 'service_busy')
              .having((failure) => failure.retryable, 'retryable', isTrue)
              .having(
                (failure) => failure.userMessage,
                'safe message',
                isNot(contains('SQL')),
              ),
        ),
      );
    },
  );

  test('attachment upload sends checksum and exact bytes', () async {
    late http.Request request;
    final remote = RestAccountSyncRemote(
      baseUri: Uri.parse('https://sync.example.test'),
      client: MockClient((value) async {
        request = value;
        return http.Response('', 204);
      }),
    );
    final bytes = Uint8List.fromList(<int>[1, 2, 3, 4]);

    await remote.uploadAttachment(
      accessToken: 'access-secret',
      checksum:
          '9f64a747e1b97f131fabb6b447296c9b6f0201e79fb3c5356e6c77e89b6a806a',
      bytes: bytes,
    );

    expect(request.method, 'PUT');
    expect(request.bodyBytes, bytes);
    expect(
      request.headers['idempotency-key'],
      '9f64a747e1b97f131fabb6b447296c9b6f0201e79fb3c5356e6c77e89b6a806a',
    );
  });
}
