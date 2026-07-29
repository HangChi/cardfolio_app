import 'dart:io';

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
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late Directory root;
  late Directory sourceDir;
  late ManagedImageStore store;
  late FixedClock clock;
  late CardRepositoryImpl repository;
  late String sourcePath;
  late String backSourcePath;
  late String packageSourcePath;

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

    Future<String> writeSource(String name, int marker) async {
      final source = File(p.join(sourceDir.path, name));
      final bytes = Uint8List.fromList(<int>[
        ...jpegBytes.take(4),
        ...List<int>.filled(64, marker),
        ...jpegBytes.skip(jpegBytes.length - 2),
      ]);
      await source.writeAsBytes(bytes, flush: true);
      return source.path;
    }

    sourcePath = await writeSource('IMG_0001.jpg', 0x11);
    backSourcePath = await writeSource('IMG_0002.jpg', 0x22);
    packageSourcePath = await writeSource('IMG_0003.jpg', 0x33);
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
    List<PendingCardImage> additionalImages = const <PendingCardImage>[],
  }) {
    return CreateCardRequest(
      ids: CardDraftIds(
        definitionId: definitionId,
        cardItemId: itemId,
        imageId: imageId,
      ),
      sourceImagePath: sourcePath,
      additionalImages: additionalImages,
      name: name,
      city: '东京',
      issuer: 'Tokyo Metro',
      issuedAt: PartialDate.tryParse('2025-03'),
      code: '01 / 08',
    );
  }

  group('createCard', () {
    test('persists multiple ordered images with the first as cover', () async {
      await repository.createCard(
        validRequest(
          additionalImages: <PendingCardImage>[
            PendingCardImage(
              id: 'image-2',
              sourcePath: backSourcePath,
              kind: CardImageKind.back,
            ),
            PendingCardImage(
              id: 'image-3',
              sourcePath: packageSourcePath,
              kind: CardImageKind.packaging,
            ),
          ],
        ),
      );

      final detail = (await repository.watchCard('item-1').first)!;
      expect(detail.images.map((image) => image.id), <String>[
        'image-1',
        'image-2',
        'image-3',
      ]);
      expect(detail.images.map((image) => image.sortOrder), <int>[0, 1, 2]);
      expect(detail.images.map((image) => image.kind), <CardImageKind>[
        CardImageKind.front,
        CardImageKind.back,
        CardImageKind.packaging,
      ]);
      expect(detail.cover?.id, 'image-1');
    });

    test(
      'persists an immutable original and its derived display image',
      () async {
        final derivedSource = File(p.join(sourceDir.path, 'processed.jpg'));
        final derivedBytes = Uint8List.fromList(<int>[
          ...jpegBytes.take(4),
          ...List<int>.filled(64, 0x77),
          ...jpegBytes.skip(jpegBytes.length - 2),
        ]);
        await derivedSource.writeAsBytes(derivedBytes, flush: true);
        final originalBytes = await File(sourcePath).readAsBytes();

        await repository.createCard(
          CreateCardRequest(
            ids: const CardDraftIds(
              definitionId: 'definition-1',
              cardItemId: 'item-1',
              imageId: 'image-1',
            ),
            sourceImagePath: sourcePath,
            derivedSourceImagePath: derivedSource.path,
            name: '樱花纪念卡',
          ),
        );

        final image =
            (await repository.watchCard('item-1').first)!.images.single;
        expect(image.relativePath, 'originals/item-1/image-1.jpg');
        expect(image.derivedRelativePath, 'derived/item-1/image-1.jpg');
        expect(image.displayRelativePath, image.derivedRelativePath);
        expect(
          await store.resolve(image.relativePath).readAsBytes(),
          originalBytes,
        );
        expect(
          await store.resolve(image.derivedRelativePath!).readAsBytes(),
          derivedBytes,
        );
        expect(await repository.referencedImagePaths(), <String>{
          image.relativePath,
          image.derivedRelativePath!,
        });
      },
    );

    test('compensates the original when derived import fails', () async {
      final brokenDerived = File(p.join(sourceDir.path, 'processed.png'));
      await brokenDerived.writeAsBytes(<int>[0x89, 0x50, 0x4e, 0x47]);

      await expectLater(
        repository.createCard(
          CreateCardRequest(
            ids: const CardDraftIds(
              definitionId: 'definition-1',
              cardItemId: 'item-1',
              imageId: 'image-1',
            ),
            sourceImagePath: sourcePath,
            derivedSourceImagePath: brokenDerived.path,
            name: '樱花纪念卡',
          ),
        ),
        throwsA(isA<ImageImportFailure>()),
      );

      expect(await db.countItems(), 0);
      final managedFiles = root.existsSync()
          ? root.listSync(recursive: true).whereType<File>()
          : const <File>[];
      expect(managedFiles, isEmpty);
    });

    test('compensates every copied file when a later image fails', () async {
      final broken = File(p.join(sourceDir.path, 'broken.jpg'));
      await broken.writeAsString('not an image', flush: true);

      await expectLater(
        repository.createCard(
          validRequest(
            additionalImages: <PendingCardImage>[
              PendingCardImage(id: 'image-2', sourcePath: backSourcePath),
              PendingCardImage(id: 'image-3', sourcePath: broken.path),
            ],
          ),
        ),
        throwsA(isA<ImageImportFailure>()),
      );

      expect(await db.countItems(), 0);
      final originals = Directory(p.join(root.path, 'originals'));
      expect(
        originals.existsSync()
            ? originals.listSync(recursive: true).whereType<File>()
            : const <File>[],
        isEmpty,
      );
    });

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

  group('image management', () {
    setUp(() async {
      await repository.createCard(validRequest());
    });

    test('adds images and preserves the current cover', () async {
      await repository.addImages(
        AddCardImagesRequest(
          cardItemId: 'item-1',
          images: <PendingCardImage>[
            PendingCardImage(
              id: 'image-2',
              sourcePath: backSourcePath,
              kind: CardImageKind.back,
            ),
          ],
        ),
      );

      final detail = (await repository.watchCard('item-1').first)!;
      expect(detail.images, hasLength(2));
      expect(detail.images.last.kind, CardImageKind.back);
      expect(detail.cover?.id, 'image-1');
    });

    test(
      'rejects additions beyond the twenty-image limit before import',
      () async {
        final images = List<PendingCardImage>.generate(
          CreateCardRequest.maxImages,
          (index) =>
              PendingCardImage(id: 'extra-$index', sourcePath: backSourcePath),
        );

        await expectLater(
          repository.addImages(
            AddCardImagesRequest(cardItemId: 'item-1', images: images),
          ),
          throwsA(isA<ValidationFailure>()),
        );

        expect(
          Directory(
            p.join(root.path, 'originals', 'item-1'),
          ).listSync().whereType<File>(),
          hasLength(1),
        );
      },
    );

    test('updates kind, order and cover independently', () async {
      await repository.addImages(
        AddCardImagesRequest(
          cardItemId: 'item-1',
          images: <PendingCardImage>[
            PendingCardImage(id: 'image-2', sourcePath: backSourcePath),
            PendingCardImage(id: 'image-3', sourcePath: packageSourcePath),
          ],
        ),
      );

      await repository.updateImageKind(
        cardItemId: 'item-1',
        imageId: 'image-2',
        kind: CardImageKind.number,
      );
      await repository.reorderImages(
        cardItemId: 'item-1',
        orderedImageIds: const <String>['image-3', 'image-1', 'image-2'],
      );
      await repository.setCover(cardItemId: 'item-1', imageId: 'image-2');

      final detail = (await repository.watchCard('item-1').first)!;
      expect(detail.images.map((image) => image.id), <String>[
        'image-3',
        'image-1',
        'image-2',
      ]);
      expect(detail.images.last.kind, CardImageKind.number);
      expect(detail.cover?.id, 'image-2');
    });

    test('reports deletion impact from the real managed file', () async {
      await repository.addImages(
        AddCardImagesRequest(
          cardItemId: 'item-1',
          images: <PendingCardImage>[
            PendingCardImage(id: 'image-2', sourcePath: backSourcePath),
          ],
        ),
      );

      final impact = await repository.getImageDeletionImpact(
        cardItemId: 'item-1',
        imageId: 'image-1',
      );

      expect(impact.imageId, 'image-1');
      expect(impact.byteSize, jpegBytes.length);
      expect(impact.isCover, isTrue);
      expect(impact.remainingImageCount, 1);
    });

    test('maps a missing managed file to a stable image failure', () async {
      await File(store.resolve('originals/item-1/image-1.jpg').path).delete();

      await expectLater(
        repository.getImageDeletionImpact(
          cardItemId: 'item-1',
          imageId: 'image-1',
        ),
        throwsA(isA<ImageImportFailure>()),
      );
    });

    test(
      'keeps or deletes the original according to the selected policy',
      () async {
        await repository.addImages(
          AddCardImagesRequest(
            cardItemId: 'item-1',
            images: <PendingCardImage>[
              PendingCardImage(id: 'image-2', sourcePath: backSourcePath),
              PendingCardImage(id: 'image-3', sourcePath: packageSourcePath),
            ],
          ),
        );
        final image2 = store.resolve('originals/item-1/image-2.jpg');
        final image3 = store.resolve('originals/item-1/image-3.jpg');

        await repository.deleteImage(
          cardItemId: 'item-1',
          imageId: 'image-2',
          keepOriginal: true,
        );
        await repository.deleteImage(
          cardItemId: 'item-1',
          imageId: 'image-3',
          keepOriginal: false,
        );

        expect(image2.existsSync(), isTrue);
        expect(image3.existsSync(), isFalse);
        expect(
          await repository.referencedImagePaths(),
          contains('originals/item-1/image-2.jpg'),
        );
      },
    );

    test('refuses to delete the last image', () async {
      await expectLater(
        repository.deleteImage(
          cardItemId: 'item-1',
          imageId: 'image-1',
          keepOriginal: true,
        ),
        throwsA(isA<ValidationFailure>()),
      );
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
