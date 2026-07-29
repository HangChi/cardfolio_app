import 'package:cardfolio_app/features/sync/data/secure_session_store.dart';
import 'package:cardfolio_app/features/sync/domain/sync_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'stores the complete session in one secure value and clears it',
    () async {
      final secrets = _MemorySecretStore();
      final store = SecureSessionStoreImpl(secrets);
      final session = AccountSession(
        userId: 'user-1',
        email: 'collector@example.test',
        accessToken: 'access-secret',
        refreshToken: 'refresh-secret',
        expiresAt: DateTime.utc(2026, 7, 29, 10),
      );

      await store.write(session);
      final restored = await store.read();

      expect(secrets.values.keys, <String>{SecureSessionStoreImpl.sessionKey});
      expect(restored?.accessToken, 'access-secret');
      expect(restored?.refreshToken, 'refresh-secret');

      await store.clear();
      expect(await store.read(), isNull);
      expect(secrets.values, isEmpty);
    },
  );

  test(
    'clears a malformed secure value instead of returning a partial session',
    () async {
      final secrets = _MemorySecretStore()
        ..values[SecureSessionStoreImpl.sessionKey] = '{"accessToken":"only"}';
      final store = SecureSessionStoreImpl(secrets);

      expect(await store.read(), isNull);
      expect(secrets.values, isEmpty);
    },
  );
}

final class _MemorySecretStore implements SecretKeyValueStore {
  final values = <String, String>{};

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }
}
