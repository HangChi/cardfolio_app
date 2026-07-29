import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
// drift 也导出 isNull/isNotNull 用于 SQL 表达式，这里隐藏以免与 matcher 冲突。
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  final createdAt = DateTime.utc(2026, 7, 26, 1, 2, 3);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  CardRowGraph exampleGraph({
    String definitionId = 'definition-1',
    String itemId = 'item-1',
    String imageId = 'image-1',
    String name = '樱花纪念卡',
    String relativePath = 'cards/image-1.jpg',
    int quantity = 1,
  }) {
    return CardRowGraph(
      definition: CardDefinitionsCompanion.insert(
        id: definitionId,
        name: name,
        city: const Value('东京'),
        issuer: const Value('Tokyo Metro'),
        issuedAt: const Value('2025-03'),
        code: const Value('01 / 08'),
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      item: CardItemsCompanion.insert(
        id: itemId,
        definitionId: definitionId,
        quantity: Value(quantity),
        createdAt: createdAt,
        updatedAt: createdAt,
      ),
      images: <CardImagesCompanion>[
        CardImagesCompanion.insert(
          id: imageId,
          cardItemId: itemId,
          kind: CardImageKind.front,
          relativePath: relativePath,
          checksum: 'sha256-abc',
          isCover: const Value(true),
          createdAt: createdAt,
        ),
      ],
    );
  }

  group('insertCardGraph', () {
    test('inserts and watches a complete card graph', () async {
      await db.insertCardGraph(exampleGraph());

      final summaries = await db.watchCardSummaries().first;

      expect(summaries.single.name, '樱花纪念卡');
      expect(summaries.single.quantity, 1);
      expect(summaries.single.cardItemId, 'item-1');
      expect(summaries.single.coverRelativePath, 'cards/image-1.jpg');
      expect(summaries.single.city, '东京');
      expect(summaries.single.issuedAt, PartialDate.tryParse('2025-03'));
      expect(summaries.single.createdAt, createdAt);
    });

    test('rolls back every row when image insertion fails', () async {
      final broken = CardRowGraph(
        definition: exampleGraph().definition,
        item: exampleGraph().item,
        images: <CardImagesCompanion>[
          CardImagesCompanion.insert(
            id: 'image-1',
            cardItemId: 'item-does-not-exist',
            kind: CardImageKind.front,
            relativePath: 'cards/image-1.jpg',
            checksum: 'sha256-abc',
            createdAt: createdAt,
          ),
        ],
      );

      await expectLater(db.insertCardGraph(broken), throwsA(anything));

      expect(await db.countDefinitions(), 0);
      expect(await db.countItems(), 0);
      expect(await db.countImages(), 0);
    });

    test('rejects a duplicate relative path', () async {
      await db.insertCardGraph(exampleGraph());

      await expectLater(
        db.insertCardGraph(
          exampleGraph(
            definitionId: 'definition-2',
            itemId: 'item-2',
            imageId: 'image-2',
          ),
        ),
        throwsA(anything),
      );

      expect(await db.countItems(), 1);
    });

    test('rejects a non-positive quantity at the database level', () async {
      await expectLater(
        db.insertCardGraph(exampleGraph(quantity: 0)),
        throwsA(anything),
      );

      expect(await db.countDefinitions(), 0);
    });
  });

  group('queries', () {
    test('watchCardDetail returns the full graph', () async {
      await db.insertCardGraph(exampleGraph());

      final detail = await db.watchCardDetail('item-1').first;

      expect(detail, isNotNull);
      expect(detail!.name, '樱花纪念卡');
      expect(detail.issuer, 'Tokyo Metro');
      expect(detail.code, '01 / 08');
      expect(detail.images.single.relativePath, 'cards/image-1.jpg');
      expect(detail.images.single.kind, CardImageKind.front);
      expect(detail.cover?.relativePath, 'cards/image-1.jpg');
    });

    test('watchCardDetail emits null for a missing card', () async {
      expect(await db.watchCardDetail('missing').first, isNull);
    });

    test('summaries are ordered newest first', () async {
      await db.insertCardGraph(exampleGraph());
      await db.insertCardGraph(
        CardRowGraph(
          definition: CardDefinitionsCompanion.insert(
            id: 'definition-2',
            name: '大阪世博会限定 ICOCA',
            createdAt: createdAt.add(const Duration(minutes: 1)),
            updatedAt: createdAt.add(const Duration(minutes: 1)),
          ),
          item: CardItemsCompanion.insert(
            id: 'item-2',
            definitionId: 'definition-2',
            createdAt: createdAt.add(const Duration(minutes: 1)),
            updatedAt: createdAt.add(const Duration(minutes: 1)),
          ),
          images: const <CardImagesCompanion>[],
        ),
      );

      final summaries = await db.watchCardSummaries().first;

      expect(summaries.map((summary) => summary.cardItemId), <String>[
        'item-2',
        'item-1',
      ]);
      expect(summaries.first.coverRelativePath, isNull);
    });

    test('soft-deleted items are excluded from both queries', () async {
      await db.insertCardGraph(exampleGraph());

      await db.softDeleteItemForTest('item-1', createdAt);

      expect(await db.watchCardSummaries().first, isEmpty);
      expect(await db.watchCardDetail('item-1').first, isNull);
    });

    test('cardItemExists reflects stored rows', () async {
      expect(await db.cardItemExists('item-1'), isFalse);

      await db.insertCardGraph(exampleGraph());

      expect(await db.cardItemExists('item-1'), isTrue);
    });

    test('referencedImagePaths includes soft-deleted items', () async {
      await db.insertCardGraph(exampleGraph());
      await db.softDeleteItemForTest('item-1', createdAt);

      // 软删除的卡片仍在回收站中引用其图片，清理孤儿文件时不得删除。
      expect(await db.referencedImagePaths(), <String>{'cards/image-1.jpg'});
    });

    test(
      'watchCardSummaries pushes a new value when a card is added',
      () async {
        final emissions = <int>[];
        final subscription = db.watchCardSummaries().listen(
          (summaries) => emissions.add(summaries.length),
        );

        await pumpEventQueue();
        await db.insertCardGraph(exampleGraph());
        await pumpEventQueue();
        await subscription.cancel();

        expect(emissions, <int>[0, 1]);
      },
    );
  });

  group('multi-image mutations', () {
    CardImagesCompanion image({
      required String id,
      required int sortOrder,
      CardImageKind kind = CardImageKind.other,
      bool isCover = false,
    }) {
      return CardImagesCompanion.insert(
        id: id,
        cardItemId: 'item-1',
        kind: kind,
        relativePath: 'cards/$id.jpg',
        sortOrder: Value(sortOrder),
        isCover: Value(isCover),
        checksum: 'sha256-$id',
        createdAt: createdAt,
      );
    }

    test('adds ordered images without changing the existing cover', () async {
      await db.insertCardGraph(exampleGraph());

      await db.addImages(
        cardItemId: 'item-1',
        images: <CardImagesCompanion>[
          image(id: 'image-2', sortOrder: 1, kind: CardImageKind.back),
          image(id: 'image-3', sortOrder: 2, kind: CardImageKind.packaging),
        ],
        updatedAt: createdAt.add(const Duration(minutes: 1)),
      );

      final detail = (await db.watchCardDetail('item-1').first)!;
      expect(detail.images.map((entry) => entry.id), <String>[
        'image-1',
        'image-2',
        'image-3',
      ]);
      expect(detail.cover?.id, 'image-1');
      expect(detail.images[1].kind, CardImageKind.back);
      expect(detail.images[2].kind, CardImageKind.packaging);
    });

    test('sets exactly one cover without changing image order', () async {
      await db.insertCardGraph(exampleGraph());
      await db.addImages(
        cardItemId: 'item-1',
        images: <CardImagesCompanion>[image(id: 'image-2', sortOrder: 1)],
        updatedAt: createdAt,
      );

      await db.setCover(
        cardItemId: 'item-1',
        imageId: 'image-2',
        updatedAt: createdAt.add(const Duration(minutes: 1)),
      );

      final detail = (await db.watchCardDetail('item-1').first)!;
      expect(detail.cover?.id, 'image-2');
      expect(detail.images.map((entry) => entry.id), <String>[
        'image-1',
        'image-2',
      ]);
      expect(detail.images.where((entry) => entry.isCover), hasLength(1));
    });

    test('the partial index rejects a second active cover', () async {
      await db.insertCardGraph(exampleGraph());

      await expectLater(
        db
            .into(db.cardImages)
            .insert(image(id: 'image-2', sortOrder: 1, isCover: true)),
        throwsA(anything),
      );
    });

    test('reorders only when every active image id appears once', () async {
      await db.insertCardGraph(exampleGraph());
      await db.addImages(
        cardItemId: 'item-1',
        images: <CardImagesCompanion>[
          image(id: 'image-2', sortOrder: 1),
          image(id: 'image-3', sortOrder: 2),
        ],
        updatedAt: createdAt,
      );

      await db.reorderImages(
        cardItemId: 'item-1',
        orderedImageIds: const <String>['image-3', 'image-1', 'image-2'],
        updatedAt: createdAt.add(const Duration(minutes: 1)),
      );
      expect(
        (await db.watchCardDetail('item-1').first)!.images.map(
          (entry) => entry.id,
        ),
        <String>['image-3', 'image-1', 'image-2'],
      );

      await expectLater(
        db.reorderImages(
          cardItemId: 'item-1',
          orderedImageIds: const <String>['image-1', 'image-1', 'image-2'],
          updatedAt: createdAt,
        ),
        throwsA(isA<StateError>()),
      );
      expect(
        (await db.watchCardDetail('item-1').first)!.images.map(
          (entry) => entry.id,
        ),
        <String>['image-3', 'image-1', 'image-2'],
      );
    });

    test('updates all six image kinds', () async {
      await db.insertCardGraph(exampleGraph());

      for (final kind in CardImageKind.values) {
        await db.updateImageKind(
          cardItemId: 'item-1',
          imageId: 'image-1',
          kind: kind,
          updatedAt: createdAt,
        );
        expect(
          (await db.watchCardDetail('item-1').first)!.images.single.kind,
          kind,
        );
      }
    });

    test('soft removal keeps the path referenced', () async {
      await db.insertCardGraph(exampleGraph());
      await db.addImages(
        cardItemId: 'item-1',
        images: <CardImagesCompanion>[image(id: 'image-2', sortOrder: 1)],
        updatedAt: createdAt,
      );

      final removed = await db.removeImage(
        cardItemId: 'item-1',
        imageId: 'image-2',
        keepOriginal: true,
        deletedAt: createdAt.add(const Duration(minutes: 1)),
      );

      expect(removed.relativePath, 'cards/image-2.jpg');
      expect((await db.watchCardDetail('item-1').first)!.images, hasLength(1));
      expect(await db.referencedImagePaths(), <String>{
        'cards/image-1.jpg',
        'cards/image-2.jpg',
      });
    });

    test('hard removal drops the path and promotes a new cover', () async {
      await db.insertCardGraph(exampleGraph());
      await db.addImages(
        cardItemId: 'item-1',
        images: <CardImagesCompanion>[
          image(id: 'image-2', sortOrder: 1),
          image(id: 'image-3', sortOrder: 2),
        ],
        updatedAt: createdAt,
      );

      await db.removeImage(
        cardItemId: 'item-1',
        imageId: 'image-1',
        keepOriginal: false,
        deletedAt: createdAt.add(const Duration(minutes: 1)),
      );

      final detail = (await db.watchCardDetail('item-1').first)!;
      expect(detail.images.map((entry) => entry.id), <String>[
        'image-2',
        'image-3',
      ]);
      expect(detail.images.map((entry) => entry.sortOrder), <int>[0, 1]);
      expect(detail.cover?.id, 'image-2');
      expect(
        await db.referencedImagePaths(),
        isNot(contains('cards/image-1.jpg')),
      );
    });

    test('allows removal of the last active image', () async {
      await db.insertCardGraph(exampleGraph());

      await db.removeImage(
        cardItemId: 'item-1',
        imageId: 'image-1',
        keepOriginal: true,
        deletedAt: createdAt,
      );

      expect((await db.watchCardDetail('item-1').first)!.images, isEmpty);
      expect(await db.referencedImagePaths(), contains('cards/image-1.jpg'));
    });
  });

  test('foreign keys are enforced', () async {
    final result = await db.customSelect('PRAGMA foreign_keys;').getSingle();

    expect(result.data.values.first, 1);
  });
}
