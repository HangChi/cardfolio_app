import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:cardfolio_app/core/time/clock.dart';
import 'package:cardfolio_app/features/backup/data/backup_database.dart';
import 'package:cardfolio_app/features/backup/data/backup_repository_impl.dart';
import 'package:cardfolio_app/features/backup/domain/backup_models.dart';
import 'package:cardfolio_app/features/card_sets/data/local/card_set_database.dart';
import 'package:cardfolio_app/features/card_sets/domain/card_set_models.dart';
import 'package:cardfolio_app/features/cards/data/files/managed_image_store.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory root;
  late AppDatabase sourceDb;
  late AppDatabase targetDb;
  late ManagedImageStore sourceImages;
  late ManagedImageStore targetImages;
  late BackupRepositoryImpl sourceRepository;
  late BackupRepositoryImpl targetRepository;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('cardfolio-backup-test-');
    sourceDb = AppDatabase(NativeDatabase.memory());
    targetDb = AppDatabase(NativeDatabase.memory());
    sourceImages = ManagedImageStore(Directory('${root.path}/source-images'));
    targetImages = ManagedImageStore(Directory('${root.path}/target-images'));
    sourceRepository = BackupRepositoryImpl(
      database: sourceDb,
      imageStore: sourceImages,
      workingDirectory: Directory('${root.path}/source-work'),
      clock: FixedClock(DateTime.utc(2026, 7, 29, 8)),
    );
    targetRepository = BackupRepositoryImpl(
      database: targetDb,
      imageStore: targetImages,
      workingDirectory: Directory('${root.path}/target-work'),
      clock: FixedClock(DateTime.utc(2026, 7, 29, 9)),
    );
    await _seedCard(sourceDb, sourceImages);
  });

  tearDown(() async {
    await sourceDb.close();
    await targetDb.close();
    if (root.existsSync()) await root.delete(recursive: true);
  });

  test('exports, inspects and restores data plus image bytes', () async {
    final backup = File('${root.path}/library.cardfolio.zip');
    final progress = <BackupStage>[];

    final exported = await sourceRepository.exportBackup(
      backup,
      onProgress: (value) => progress.add(value.stage),
    );
    final preview = await targetRepository.inspectBackup(
      backup,
      mode: BackupMode.emptyLibrary,
    );
    final imported = await targetRepository.importBackup(
      backup,
      mode: BackupMode.emptyLibrary,
    );

    expect(exported.entityCount, 3);
    expect(exported.imageCount, 1);
    expect(preview.entityCounts['cardImages'], 1);
    expect(preview.addedCount, 3);
    expect(preview.conflicts, isEmpty);
    expect(imported.addedCount, 3);
    expect(
      progress,
      containsAllInOrder(<BackupStage>[
        BackupStage.readingDatabase,
        BackupStage.checkingImages,
        BackupStage.writingArchive,
        BackupStage.completed,
      ]),
    );
    expect(
      await targetImages
          .resolve('originals/$_itemId/$_imageId.jpg')
          .readAsBytes(),
      <int>[1, 2, 3, 4],
    );
    expect(
      (await targetDb.exportLogicalBackup()).toJson(),
      (await sourceDb.exportLogicalBackup()).toJson(),
    );
  });

  test('archives and restores a standalone card-set cover file', () async {
    const coverPath = 'originals/set-$_setId/cover.jpg';
    const coverBytes = <int>[9, 8, 7, 6];
    final createdAt = DateTime.utc(2026, 7, 1, 8);
    await sourceDb.createCardSet(
      request: const CreateCardSetRequest(
        id: _setId,
        name: '四季套卡',
        countKnown: false,
      ).normalized(),
      now: createdAt,
    );
    await sourceDb.setCardSetStandaloneCover(
      setId: _setId,
      relativePath: coverPath,
      now: createdAt,
    );
    final sourceCover = sourceImages.resolve(coverPath);
    await sourceCover.parent.create(recursive: true);
    await sourceCover.writeAsBytes(coverBytes, flush: true);
    final backup = File('${root.path}/set-cover.cardfolio.zip');

    final exported = await sourceRepository.exportBackup(backup);
    final preview = await targetRepository.inspectBackup(
      backup,
      mode: BackupMode.emptyLibrary,
    );
    final imported = await targetRepository.importBackup(
      backup,
      mode: BackupMode.emptyLibrary,
    );

    expect(exported.imageCount, 2);
    expect(preview.imageCount, 2);
    expect(imported.imageCount, 2);
    expect(
      (await targetDb.watchCardSetDetail(_setId).first)?.coverRelativePath,
      coverPath,
    );
    expect(await targetImages.resolve(coverPath).readAsBytes(), coverBytes);
  });

  test('tampered archive is rejected without modifying the target', () async {
    final backup = File('${root.path}/tampered.cardfolio.zip');
    await sourceRepository.exportBackup(backup);
    final bytes = await backup.readAsBytes();
    bytes[bytes.length ~/ 2] ^= 0xFF;
    await backup.writeAsBytes(bytes, flush: true);

    await expectLater(
      targetRepository.inspectBackup(backup, mode: BackupMode.emptyLibrary),
      throwsA(isA<BackupValidationFailure>()),
    );
    expect((await targetDb.exportLogicalBackup()).totalEntityCount, 0);
    expect(targetImages.root.existsSync(), isFalse);
  });

  test('cancelled export leaves no destination file', () async {
    final backup = File('${root.path}/cancelled.cardfolio.zip');
    final token = BackupCancellationToken()..cancel();

    await expectLater(
      sourceRepository.exportBackup(backup, cancellationToken: token),
      throwsA(isA<BackupCancelledFailure>()),
    );

    expect(backup.existsSync(), isFalse);
    expect(
      Directory('${root.path}/source-work').listSync(recursive: true),
      isEmpty,
    );
  });

  test(
    'oversized import is rejected before copying into working storage',
    () async {
      final backup = File('${root.path}/oversized.cardfolio.zip');
      final handle = await backup.open(mode: FileMode.write);
      await handle.truncate(BackupLimits.maxUncompressedBytes + 1);
      await handle.close();

      await expectLater(
        targetRepository.inspectBackup(backup, mode: BackupMode.emptyLibrary),
        throwsA(isA<BackupValidationFailure>()),
      );

      expect(
        Directory('${root.path}/target-work').listSync(recursive: true),
        isEmpty,
      );
    },
  );

  test('image commit failure rolls back imported database rows', () async {
    final backup = File('${root.path}/commit-failure.cardfolio.zip');
    await sourceRepository.exportBackup(backup);
    await targetImages.root.create(recursive: true);
    await File('${targetImages.root.path}/originals').writeAsString('blocked');

    await expectLater(
      targetRepository.importBackup(backup, mode: BackupMode.emptyLibrary),
      throwsA(isA<BackupStorageFailure>()),
    );

    expect((await targetDb.exportLogicalBackup()).totalEntityCount, 0);
    expect(
      File('${targetImages.root.path}/originals').readAsStringSync(),
      'blocked',
    );
  });

  test('path traversal entry is rejected before extraction', () async {
    final backup = File('${root.path}/traversal.cardfolio.zip');
    final archive = Archive()
      ..addFile(ArchiveFile.string('../escape.txt', 'malicious'));
    await backup.writeAsBytes(ZipEncoder().encode(archive), flush: true);

    await expectLater(
      targetRepository.inspectBackup(backup, mode: BackupMode.emptyLibrary),
      throwsA(isA<BackupValidationFailure>()),
    );

    expect(File('${root.parent.path}/escape.txt').existsSync(), isFalse);
    expect((await targetDb.exportLogicalBackup()).totalEntityCount, 0);
  });

  test('future manifest version is rejected without reading data', () async {
    final backup = File('${root.path}/future.cardfolio.zip');
    final dataBytes = utf8.encode(
      jsonEncode(<String, Object?>{
        'logicalSchemaVersion': 1,
        'entities': <String, Object?>{
          for (final name in BackupSnapshot.entityNames) name: <Object?>[],
        },
      }),
    );
    final manifest = <String, Object?>{
      'format': BackupManifest.formatName,
      'formatVersion': 2,
      'sourceSchemaVersion': 6,
      'createdAt': '2026-07-29T08:00:00.000Z',
      'dataFile': 'data.json',
      'entries': <Object?>[
        <String, Object?>{
          'path': 'data.json',
          'byteSize': dataBytes.length,
          'sha256': sha256.convert(dataBytes).toString(),
        },
      ],
      'entityCounts': <String, Object?>{
        for (final name in BackupSnapshot.entityNames) name: 0,
      },
    };
    final archive = Archive()
      ..addFile(ArchiveFile.string('manifest.json', jsonEncode(manifest)))
      ..addFile(ArchiveFile.bytes('data.json', dataBytes));
    await backup.writeAsBytes(ZipEncoder().encode(archive), flush: true);

    await expectLater(
      targetRepository.inspectBackup(backup, mode: BackupMode.emptyLibrary),
      throwsA(isA<BackupCompatibilityFailure>()),
    );
    expect((await targetDb.exportLogicalBackup()).totalEntityCount, 0);
  });
}

const String _definitionId = '00000000-0000-4000-8000-000000000001';
const String _itemId = '00000000-0000-4000-8000-000000000002';
const String _imageId = '00000000-0000-4000-8000-000000000003';
const String _setId = '00000000-0000-4000-8000-000000000004';

Future<void> _seedCard(AppDatabase db, ManagedImageStore imageStore) async {
  final createdAt = DateTime.utc(2026, 7, 1, 8);
  final relativePath = 'originals/$_itemId/$_imageId.jpg';
  final bytes = <int>[1, 2, 3, 4];
  final image = imageStore.resolve(relativePath);
  await image.parent.create(recursive: true);
  await image.writeAsBytes(bytes, flush: true);

  await db.insertCardGraph(
    CardRowGraph(
      definition: CardDefinitionsCompanion.insert(
        id: _definitionId,
        name: '樱花纪念卡',
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      item: CardItemsCompanion.insert(
        id: _itemId,
        definitionId: _definitionId,
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      images: <CardImagesCompanion>[
        CardImagesCompanion.insert(
          id: _imageId,
          cardItemId: _itemId,
          kind: CardImageKind.front,
          relativePath: relativePath,
          isCover: const Value(true),
          checksum: sha256.convert(bytes).toString(),
          createdAt: createdAt,
        ),
      ],
    ),
  );
}
