import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:cardfolio_app/features/purchases/data/local/purchase_database.dart';
import 'package:cardfolio_app/features/purchases/domain/purchase_models.dart';
import 'package:cardfolio_app/features/recycle_bin/data/local/recycle_bin_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  final createdAt = DateTime.utc(2026, 7, 1);
  final deletedAt = DateTime.utc(2026, 7, 20);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<void> insertCard({
    String definitionId = 'definition-1',
    String itemId = 'item-1',
  }) {
    return db.insertCardGraph(
      CardRowGraph(
        definition: CardDefinitionsCompanion.insert(
          id: definitionId,
          name: '樱花纪念卡',
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
        item: CardItemsCompanion.insert(
          id: itemId,
          definitionId: definitionId,
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
        images: <CardImagesCompanion>[
          CardImagesCompanion.insert(
            id: 'image-$itemId',
            cardItemId: itemId,
            kind: CardImageKind.front,
            relativePath: 'originals/$itemId/front.jpg',
            derivedRelativePath: Value('derived/$itemId/front.webp'),
            checksum: 'sha256-$itemId',
            isCover: const Value(true),
            createdAt: createdAt,
          ),
        ],
      ),
    );
  }

  test('soft delete and restore use the inverse ordinary query path', () async {
    await insertCard();

    await db.softDeleteCard('item-1', deletedAt);

    expect(await db.watchCardSummaries().first, isEmpty);
    final deleted = await db.watchRecycleBinEntries().first;
    expect(deleted.single.cardItemId, 'item-1');
    expect(deleted.single.name, '樱花纪念卡');
    expect(deleted.single.imageCount, 1);
    expect(deleted.single.coverRelativePath, 'originals/item-1/front.jpg');

    await db.restoreCard('item-1', DateTime.utc(2026, 7, 22));

    expect(await db.watchRecycleBinEntries().first, isEmpty);
    expect((await db.watchCardSummaries().first).single.cardItemId, 'item-1');
    expect((await db.watchCardDetail('item-1').first)!.images, hasLength(1));
  });

  test('repeated delete and restore do not increment version again', () async {
    await insertCard();

    await db.softDeleteCard('item-1', deletedAt);
    await db.softDeleteCard('item-1', deletedAt.add(const Duration(days: 1)));
    var item = await db.select(db.cardItems).getSingle();
    expect(item.version, 2);
    expect(item.deletedAt?.toUtc(), deletedAt);

    await db.restoreCard('item-1', DateTime.utc(2026, 7, 22));
    await db.restoreCard('item-1', DateTime.utc(2026, 7, 23));
    item = await db.select(db.cardItems).getSingle();
    expect(item.version, 3);
    expect(item.deletedAt, isNull);
  });

  test('permanent deletion previews impact and preserves definition', () async {
    await insertCard();
    await db.createPurchase(
      request: CreatePurchaseRequest(
        id: 'purchase-1',
        purchasedAt: createdAt,
        amountMinor: 1200,
        currency: 'CNY',
        targets: const <PurchaseTargetInput>[
          PurchaseTargetInput(
            targetType: PurchaseTargetType.card,
            targetId: 'item-1',
          ),
        ],
      ),
      now: createdAt,
    );
    await db.softDeleteCard('item-1', deletedAt);

    final impact = await db.previewPermanentDeletion('item-1');
    expect(impact.imageCount, 1);
    expect(impact.fileCount, 2);
    expect(impact.purchaseAssociationCount, 1);

    await db.permanentlyDeleteCard('item-1', deletedAt);

    expect(await db.countItems(), 0);
    expect(await db.countImages(), 0);
    expect(await db.countDefinitions(), 1);
    expect(await db.select(db.purchases).get(), hasLength(1));
    expect(await db.select(db.purchaseItems).get(), isEmpty);
    expect(
      (await db.pendingFileCleanup())
          .map((entry) => entry.relativePath)
          .toSet(),
      <String>{'originals/item-1/front.jpg', 'derived/item-1/front.webp'},
    );
  });

  test(
    'retention setting defaults to 30 and accepts supported values',
    () async {
      expect((await db.watchRecycleBinSettings().first).retentionDays, 30);

      await db.updateRecycleBinRetention(7, createdAt);
      expect((await db.watchRecycleBinSettings().first).retentionDays, 7);

      await expectLater(
        db.updateRecycleBinRetention(14, createdAt),
        throwsA(isA<ArgumentError>()),
      );
    },
  );

  test('expired ids include the exact cutoff but not newer cards', () async {
    await insertCard(itemId: 'item-old', definitionId: 'definition-old');
    await insertCard(itemId: 'item-new', definitionId: 'definition-new');
    final now = DateTime.utc(2026, 7, 31);
    await db.softDeleteCard('item-old', now.subtract(const Duration(days: 30)));
    await db.softDeleteCard(
      'item-new',
      now.subtract(const Duration(days: 29, hours: 23)),
    );

    expect(await db.expiredRecycleBinIds(nowUtc: now, retentionDays: 30), [
      'item-old',
    ]);
  });
}
