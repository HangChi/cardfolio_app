import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'local_app_state.dart';

final class JsonLocalAppStateStore implements LocalAppStateStore {
  JsonLocalAppStateStore(this.file);

  final File file;
  Future<void> _pendingWrite = Future<void>.value();

  @override
  Future<LocalAppState> read() async {
    try {
      if (!await file.exists()) return const LocalAppState();
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map<Object?, Object?>) return const LocalAppState();
      return LocalAppState.fromJson(
        decoded.map((key, value) => MapEntry('$key', value)),
      );
    } on Object {
      return const LocalAppState();
    }
  }

  @override
  Future<LocalAppState> update(
    LocalAppState Function(LocalAppState current) change,
  ) async {
    final completer = Completer<LocalAppState>();
    _pendingWrite = _pendingWrite
        .then((_) async {
          final next = change(await read());
          await file.parent.create(recursive: true);
          final temporary = File('${file.path}.tmp');
          await temporary.writeAsString(jsonEncode(next.toJson()), flush: true);
          if (await file.exists()) await file.delete();
          await temporary.rename(file.path);
          completer.complete(next);
        })
        .catchError((Object error, StackTrace stackTrace) {
          if (!completer.isCompleted) {
            completer.completeError(error, stackTrace);
          }
        });
    return completer.future;
  }
}
