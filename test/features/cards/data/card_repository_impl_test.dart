import 'dart:io';
import 'dart:typed_data';

import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/core/time/clock.dart';
import 'package:cardfolio_app/features/cards/data/card_repository_impl.dart';
import 'package:cardfolio_app/features/cards/data/files/managed_image_store.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

final Uint8List jpegBytes = Uint8List.fromList(<int>[
  0xFF, 0xD8, 0xFF, 0xE0, //
  ...List<int>.filled(64, 0x11),
  0xFF, 0xD9,
]);

void main() {
  late AppDatabase db;
  late Directory root;
  late Directory sourceDir;
  late ManagedImageStore store;
  late FixedClock clock;
  late CardRepositoryImpl repository;
  late String sourcePath;

  final now = DateTime.utc(2026, 7, 26, 9, 30);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    root = await Directory.systemTemp.createTemp('cardfolio-repo-root-');
    sourceDir = await Directory.systemTemp.createTemp('cardfolio-repo-src-');
    store = ManagedImageStore(root);
    clock = FixedClock(now);
    repository = CardRepositoryImpl(
      database: db,
      imageStore: store,
      clock: clock,
    );

    final source = File(p.join(sourceDir.path, 'IMG_0001.jpg'));
    await source.writeAsBytes(jpegBytes, flush: true);
    sourcePath = source.path;
  });

  tearDown(() async {
    await db.close();
    for (final dir in <Directory>[root, sourceDir]) {
      if (dir.existsSync()) await dir.delete(recursive: true);
    }
  });

  CreateCardRequest validRequest({
    String definitionId = 'definition-1',
    String itemId = 'item-1',
    String imageId = 'image-1',
    String name = '樱花纪念卡',
  }) {
    return CreateCardRequest(
      ids: CardDraftIds(
        definitionId: definitionId,
        cardItemId: itemId,
        imageId: imageId,
      ),
      sourceImagePath: sourcePath,
      name: name,
      city: '东京',
      issuer: 'Tokyo Metro',
      issuedAt: PartialDate.tryParse('2025-03'),
      code: '01 / 08',
    );
  }

  group('createCard', () {
    test('persists the card graph and the managed image', () async {
      final id = await repository.createCard(validRequest());

      expect(id, 'item-1');
      expect(await db.countDefinitions(), 1);
      expect(await db.countItems(), 1);
      expect(await db.countImages(), 1);

      final detail = await repository.watchCard('item-1').first;
      expect(detail!.name, '樱花纪念卡');
      expect(detail.city, '东京');
      expect(detail.issuedAt, PartialDate.tryParse('2025-03'));
      expect(detail.createdAt, now);

      final imagePath = detail.images.single.relativePath;
      expect(imagePath, 'originals/item-1/image-1.jpg');
      expect(store.resolve(imagePath).existsSync(), isTrue);
    });

    test('normalizes input before persisting', () async {
      await repository.createCard(
        CreateCardRequest(
          ids: const CardDraftIds(
            definitionId: 'definition-1',
            cardItemId: 'item-1',
            imageId: 'image-1',
          ),
          sourceImagePath: sourcePath,
          name: '  樱花纪念卡  ',
          city: '   ',
        ),
      );

      final detail = await repository.watchCard('item-1').first;
      expect(detail!.name, '樱花纪念卡');
      expect(detail.city, isNull);
    });

    test('rejects a blank name without touching disk or database', () async {
      await expectLater(
        repository.createCard(validRequest(name: '   ')),
        throwsA(isA<ValidationFailure>()),
      );

      expect(await db.countItems(), 0);
      final originals = Directory(p.join(root.path, 'originals'));
      expect(originals.existsSync(), isFalse);
    });

    test('does not write to the database when image import fails', () async {
      final broken = File(p.join(sourceDir.path, 'broken.jpg'));
      await broken.writeAsString('not an image', flush: true);

      await expectLater(
        repository.createCard(
          CreateCardRequest(
            ids: const CardDraftIds(
              definitionId: 'definition-1',
              cardItemId: 'item-1',
              imageId: 'image-1',
            ),
            sourceImagePath: broken.path,
            name: '樱花纪念卡',
          ),
        ),
        throwsA(isA<ImageImportFailure>()),
      );

      expect(await db.countDefinitions(), 0);
      expect(await db.countItems(), 0);
    });

    test('deletes the copied image when the transaction fails', () async {
      // 预先占用同一个 definition 主键，令事务在插入定义时失败。
      await db
          .into(db.cardDefinitions)
          .insert(
            CardDefinitionsCompanion.insert(
              id: 'definition-1',
              name: '已存在',
              createdAt: now,
              updatedAt: now,
            ),
          );

      await expectLater(
        repository.createCard(validRequest()),
        throwsA(isA<PersistenceFailure>()),
      );

      expect(await db.countItems(), 0);
      expect(await db.countImages(), 0);
      expect(
        store.resolve('originals/item-1/image-1.jpg').existsSync(),
        isFalse,
      );
    });

    test('returns the existing item for a repeated draft id', () async {
      final first = await repository.createCard(validRequest());
      final second = await repository.createCard(validRequest());

      expect(second, first);
      expect(await db.countItems(), 1);
      expect(await db.countImages(), 1);
      expect(await db.countDefinitions(), 1);
    });

    test('does not re-import the image on a repeated draft id', () async {
      await repository.createCard(validRequest());

      // 源文件在第一次保存后消失；幂等返回不得再次读取它。
      await File(sourcePath).delete();

      expect(await repository.createCard(validRequest()), 'item-1');
    });
  });

  group('queries', () {
    test('watchCards exposes summaries newest first', () async {
      await repository.createCard(validRequest());
      clock.advance(const Duration(minutes: 5));
      await repository.createCard(
        validRequest(
          definitionId: 'definition-2',
          itemId: 'item-2',
          imageId: 'image-2',
          name: '大阪世博会限定 ICOCA',
        ),
      );

      final summaries = await repository.watchCards().first;

      expect(summaries.map((summary) => summary.name), <String>[
        '大阪世博会限定 ICOCA',
        '樱花纪念卡',
      ]);
      expect(summaries.first.coverRelativePath, 'originals/item-2/image-2.jpg');
    });

    test('watchCard emits null for an unknown id', () async {
      expect(await repository.watchCard('missing').first, isNull);
    });

    test('referencedImagePaths lists every stored image', () async {
      await repository.createCard(validRequest());

      expect(await repository.referencedImagePaths(), <String>{
        'originals/item-1/image-1.jpg',
      });
    });
  });

  test('maps an unopenable database to a stable failure', () async {
    // 把一个目录当作数据库文件打开，必定失败。
    final unopenable = AppDatabase(NativeDatabase(File(root.path)));
    addTearDown(() async {
      try {
        await unopenable.close();
      } catch (_) {
        // 打不开的数据库关闭时同样会抛，测试无需关心。
      }
    });

    final failing = CardRepositoryImpl(
      database: unopenable,
      imageStore: store,
      clock: clock,
    );

    await expectLater(
      failing.createCard(validRequest()),
      throwsA(isA<DatabaseUnavailableFailure>()),
    );

    // 数据库都打不开，不得留下任何受管文件。
    expect(Directory(p.join(root.path, 'originals')).existsSync(), isFalse);
  });
}
