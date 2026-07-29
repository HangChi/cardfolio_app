import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/sync_models.dart';

abstract interface class SecureSessionStore {
  Future<AccountSession?> read();

  Future<void> write(AccountSession session);

  Future<void> clear();
}

abstract interface class SecretKeyValueStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

final class FlutterSecureKeyValueStore implements SecretKeyValueStore {
  const FlutterSecureKeyValueStore([
    this._storage = const FlutterSecureStorage(),
  ]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

final class SecureSessionStoreImpl implements SecureSessionStore {
  const SecureSessionStoreImpl(this._secrets);

  static const String sessionKey = 'cardfolio.account.session.v1';

  final SecretKeyValueStore _secrets;

  @override
  Future<AccountSession?> read() async {
    final encoded = await _secrets.read(sessionKey);
    if (encoded == null) return null;
    try {
      final value = jsonDecode(encoded);
      if (value is! Map<String, Object?>) {
        throw const FormatException('session is not an object');
      }
      return AccountSession.fromJson(value);
    } on Object {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(AccountSession session) =>
      _secrets.write(sessionKey, jsonEncode(session.toJson()));

  @override
  Future<void> clear() => _secrets.delete(sessionKey);
}
