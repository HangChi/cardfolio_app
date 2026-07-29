import 'package:cardfolio_app/features/backup/domain/backup_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BackupManifest', () {
    test('accepts the current logical backup format', () {
      final manifest = BackupManifest.fromJson(<String, Object?>{
        'format': BackupManifest.formatName,
        'formatVersion': 1,
        'sourceSchemaVersion': 6,
        'createdAt': '2026-07-29T08:00:00.000Z',
        'dataFile': 'data.json',
        'entries': <Object?>[
          <String, Object?>{
            'path': 'data.json',
            'byteSize': 2,
            'sha256':
                'e3b0c44298fc1c149afbf4c8996fb924'
                '27ae41e4649b934ca495991b7852b855',
          },
        ],
        'entityCounts': <String, Object?>{'cardDefinitions': 0},
      });

      expect(manifest.formatVersion, 1);
      expect(manifest.createdAt, DateTime.utc(2026, 7, 29, 8));
      expect(manifest.entries.single.path, 'data.json');
    });

    test('rejects a future format before data is read', () {
      expect(
        () => BackupManifest.fromJson(<String, Object?>{
          'format': BackupManifest.formatName,
          'formatVersion': 2,
          'sourceSchemaVersion': 6,
          'createdAt': '2026-07-29T08:00:00.000Z',
          'dataFile': 'data.json',
          'entries': <Object?>[],
          'entityCounts': <String, Object?>{},
        }),
        throwsA(isA<BackupCompatibilityFailure>()),
      );
    });

    test('rejects an obsolete format before data is read', () {
      expect(
        () => BackupManifest.fromJson(<String, Object?>{
          'format': BackupManifest.formatName,
          'formatVersion': 0,
          'sourceSchemaVersion': 1,
          'createdAt': '2026-07-29T08:00:00.000Z',
          'dataFile': 'data.json',
          'entries': <Object?>[],
          'entityCounts': <String, Object?>{},
        }),
        throwsA(isA<BackupCompatibilityFailure>()),
      );
    });
  });

  group('backup entry paths', () {
    for (final unsafePath in <String>[
      '../data.json',
      '/data.json',
      r'images\card.jpg',
      'images/./card.jpg',
      'images//card.jpg',
      'images/C:/card.jpg',
      'images/\u0000card.jpg',
      'unknown/file.bin',
    ]) {
      test('rejects unsafe or unknown path "$unsafePath"', () {
        expect(
          () => BackupEntry(
            path: unsafePath,
            byteSize: 1,
            sha256:
                'ca978112ca1bbdcafac231b39a23dc4d'
                'a786eff8147c4e72b9807785afee48bb',
          ),
          throwsA(isA<BackupValidationFailure>()),
        );
      });
    }
  });

  test('cancellation is observable before commit', () {
    final token = BackupCancellationToken()..cancel();

    expect(token.throwIfCancelled, throwsA(isA<BackupCancelledFailure>()));
  });

  test('progress requires a normalized fraction', () {
    expect(
      () =>
          BackupProgress(stage: BackupStage.validatingArchive, fraction: 1.01),
      throwsA(isA<ArgumentError>()),
    );
  });
}
