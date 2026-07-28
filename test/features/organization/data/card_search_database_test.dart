import 'package:cardfolio_app/features/card_sets/data/local/card_set_database.dart';
import 'package:cardfolio_app/features/card_sets/domain/card_set_models.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:cardfolio_app/features/organization/data/local/card_search_database.dart';
import 'package:cardfolio_app/features/organization/data/local/organization_database.dart';
import 'package:cardfolio_app/features/organization/domain/organization_models.dart';
import 'package:cardfolio_app/features/purchases/data/local/purchase_database.dart';
import 'package:cardfolio_app/features/purchases/domain/purchase_models.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  final now = DateTime.utc(2026, 7, 28, 12);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<void> insertCard({
    required String suffix,
    required String name,
    String? city,
    String? issuer,
    String? issuedAt,
    String? code,
    String? notes,
    String? cardType,
    bool needsCompletion = false,
    DateTime? acquiredAt,
    int quantity = 1,
    DateTime? createdAt,
  }) {
    final timestamp = createdAt ?? now;
    return db.insertCardGraph(
      CardRowGraph(
        definition: CardDefinitionsCompanion.insert(
          id: 'definition-$suffix',
          name: name,
          city: Value(city),
          issuer: Value(issuer),
          issuedAt: Value(issuedAt),
          code: Value(code),
          notes: Value(notes),
          cardType: Value(cardType),
          needsCompletion: Value(needsCompletion),
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
        item: CardItemsCompanion.insert(
          id: 'item-$suffix',
          definitionId: 'definition-$suffix',
          acquiredAt: Value(acquiredAt),
          quantity: Value(quantity),
          createdAt: timestamp,
          updatedAt: timestamp,
        ),
        images: <CardImagesCompanion>[
          CardImagesCompanion.insert(
            id: 'image-$suffix',
            cardItemId: 'item-$suffix',
            kind: CardImageKind.front,
            relativePath: 'originals/item-$suffix/image-$suffix.jpg',
            checksum: 'sha256-$suffix',
            isCover: const Value(true),
            createdAt: timestamp,
          ),
        ],
      ),
    );
  }

  Future<void> seedDiscoveryFixture() async {
    await insertCard(
      suffix: 'a',
      name: '樱花纪念卡',
      city: '东京',
      issuer: 'Metro',
      issuedAt: '2026-03',
      code: 'SK-01',
      notes: '春季限定',
      cardType: '纪念卡',
      needsCompletion: true,
      acquiredAt: DateTime.utc(2026, 5, 1),
      quantity: 2,
      createdAt: now.add(const Duration(minutes: 1)),
    );
    await insertCard(
      suffix: 'b',
      name: '机场线单程票',
      city: '上海',
      issuer: '申通地铁',
      issuedAt: '2025',
      code: 'AIR-02',
      notes: '浦东机场购入',
      cardType: '单程票',
      acquiredAt: DateTime.utc(2026, 4, 1),
    );
    await insertCard(
      suffix: 'c',
      name: '无日期交通卡',
      city: '东京',
      notes: '票面有中文说明',
      cardType: '储值卡',
      needsCompletion: true,
      createdAt: now.add(const Duration(minutes: 2)),
    );

    for (final (id, name) in <(String, String)>[
      ('spring', '春季'),
      ('limited', '限定'),
    ]) {
      await db.createOrganizationTag(
        request: CreateTagRequest(id: id, name: name).normalized(),
        now: now,
      );
    }
    await db.replaceCardTags(
      definitionId: 'definition-a',
      tagIds: const <String>['spring', 'limited'],
      now: now,
    );
    await db.replaceCardTags(
      definitionId: 'definition-b',
      tagIds: const <String>['limited'],
      now: now,
    );
    await db.createCardSet(
      request: const CreateCardSetRequest(
        id: 'set-1',
        name: '东京纪念套卡',
        countKnown: false,
      ).normalized(),
      now: now,
    );
    await db.addCardSetMember(
      request: const AddCardSetMemberRequest.existing(
        id: 'member-a',
        setId: 'set-1',
        definitionId: 'definition-a',
      ).normalized(),
      now: now,
    );
  }

  test('searches name, code, city, issuer, notes, and active tags', () async {
    await seedDiscoveryFixture();

    for (final (term, expected) in <(String, String)>[
      ('樱花', 'item-a'),
      ('air-02', 'item-b'),
      ('上海', 'item-b'),
      ('METRO', 'item-a'),
      ('中文说明', 'item-c'),
      ('春季', 'item-a'),
    ]) {
      final result = await db
          .watchOrganizedCards(CardLibraryQuery(searchText: term).normalized())
          .first;
      expect(result.map((card) => card.cardItemId), contains(expected));
    }
  });

  test('combines dimensions with AND and supports tag any or all', () async {
    await seedDiscoveryFixture();

    final anyResult = await db
        .watchOrganizedCards(
          const CardLibraryQuery(
            city: '东京',
            tagIds: <String>['spring', 'limited'],
            tagMatchMode: TagMatchMode.any,
            needsCompletion: true,
          ).normalized(),
        )
        .first;
    expect(anyResult.map((card) => card.cardItemId), <String>['item-a']);

    final allResult = await db
        .watchOrganizedCards(
          const CardLibraryQuery(
            tagIds: <String>['spring', 'limited'],
            tagMatchMode: TagMatchMode.all,
          ).normalized(),
        )
        .first;
    expect(allResult.map((card) => card.cardItemId), <String>['item-a']);

    final impossible = await db
        .watchOrganizedCards(
          const CardLibraryQuery(
            city: '上海',
            tagIds: <String>['spring'],
          ).normalized(),
        )
        .first;
    expect(impossible, isEmpty);
  });

  test(
    'filters set membership, duplicates, type, year, and pending data',
    () async {
      await seedDiscoveryFixture();

      final result = await db
          .watchOrganizedCards(
            const CardLibraryQuery(
              cardType: '纪念卡',
              year: 2026,
              setMembership: SetMembershipFilter.inSet,
              duplicate: true,
              needsCompletion: true,
            ).normalized(),
          )
          .first;
      expect(result.map((card) => card.cardItemId), <String>['item-a']);

      final notInSet = await db
          .watchOrganizedCards(
            const CardLibraryQuery(
              setMembership: SetMembershipFilter.notInSet,
            ).normalized(),
          )
          .first;
      expect(notInSet.map((card) => card.cardItemId).toSet(), <String>{
        'item-b',
        'item-c',
      });
    },
  );

  test(
    'filters issuer and every dashboard set status with shared rules',
    () async {
      Future<void> createStatusSet({
        required String suffix,
        required bool countKnown,
        required int memberCount,
        required int ownedCount,
      }) async {
        for (var index = 0; index < ownedCount; index++) {
          await insertCard(
            suffix: '$suffix-owned-$index',
            name: '$suffix 已拥有 $index',
            issuer: suffix == 'complete' ? 'Metro' : '其他机构',
          );
        }
        await db.createCardSet(
          request: CreateCardSetRequest(
            id: 'set-$suffix',
            name: '套卡 $suffix',
            countKnown: countKnown,
            expectedCount: countKnown ? memberCount : null,
          ).normalized(),
          now: now,
        );
        for (var index = 0; index < memberCount; index++) {
          final definitionId = 'definition-$suffix-member-$index';
          if (index < ownedCount) {
            await db.addCardSetMember(
              request: AddCardSetMemberRequest.existing(
                id: 'member-$suffix-$index',
                setId: 'set-$suffix',
                definitionId: 'definition-$suffix-owned-$index',
              ).normalized(),
              now: now,
            );
          } else {
            await db.addCardSetMember(
              request: AddCardSetMemberRequest.missing(
                id: 'member-$suffix-$index',
                setId: 'set-$suffix',
                definitionId: definitionId,
                definitionName: '$suffix 缺少 $index',
              ).normalized(),
              now: now,
            );
          }
        }
      }

      await createStatusSet(
        suffix: 'complete',
        countKnown: true,
        memberCount: 1,
        ownedCount: 1,
      );
      await createStatusSet(
        suffix: 'near',
        countKnown: true,
        memberCount: 2,
        ownedCount: 1,
      );
      await createStatusSet(
        suffix: 'incomplete',
        countKnown: true,
        memberCount: 3,
        ownedCount: 1,
      );
      await createStatusSet(
        suffix: 'unknown',
        countKnown: false,
        memberCount: 1,
        ownedCount: 1,
      );

      final issuer = await db
          .watchOrganizedCards(
            const CardLibraryQuery(issuer: 'metro').normalized(),
          )
          .first;
      expect(issuer.map((card) => card.cardItemId), <String>[
        'item-complete-owned-0',
      ]);

      for (final (status, expected) in <(CardSetStatusFilter, String)>[
        (CardSetStatusFilter.complete, 'item-complete-owned-0'),
        (CardSetStatusFilter.nearlyComplete, 'item-near-owned-0'),
        (CardSetStatusFilter.incomplete, 'item-incomplete-owned-0'),
        (CardSetStatusFilter.unknown, 'item-unknown-owned-0'),
      ]) {
        final cards = await db
            .watchOrganizedCards(
              CardLibraryQuery(setStatus: status).normalized(),
            )
            .first;
        expect(cards.map((card) => card.cardItemId), <String>[expected]);
      }
    },
  );

  test(
    'sorts null dates last and uses item id as a stable tiebreaker',
    () async {
      await seedDiscoveryFixture();
      await insertCard(
        suffix: 'd',
        name: '同年卡 D',
        issuedAt: '2026-03',
        acquiredAt: DateTime.utc(2026, 5, 1),
      );

      final issued = await db
          .watchOrganizedCards(
            const CardLibraryQuery(
              sortField: CardSortField.issuedAt,
              sortDirection: SortDirection.descending,
            ).normalized(),
          )
          .first;
      expect(issued.last.cardItemId, 'item-c');
      expect(
        issued
            .where((card) => card.issuedAt?.toIsoString() == '2026-03')
            .map((card) => card.cardItemId),
        <String>['item-a', 'item-d'],
      );

      final acquired = await db
          .watchOrganizedCards(
            const CardLibraryQuery(
              sortField: CardSortField.acquiredAt,
              sortDirection: SortDirection.ascending,
            ).normalized(),
          )
          .first;
      expect(acquired.last.cardItemId, 'item-c');
    },
  );

  test(
    'sorts attributable acquisition cost within original currency groups',
    () async {
      for (final (suffix, name) in <(String, String)>[
        ('cost-a', '高成本人民币卡'),
        ('cost-b', '低成本人民币卡'),
        ('cost-c', '日元卡'),
        ('cost-d', '无购买卡'),
      ]) {
        await insertCard(suffix: suffix, name: name);
      }
      for (final request in <CreatePurchaseRequest>[
        CreatePurchaseRequest(
          id: 'purchase-a',
          purchasedAt: now,
          amountMinor: 50000,
          currency: 'CNY',
          targets: const <PurchaseTargetInput>[
            PurchaseTargetInput(
              targetType: PurchaseTargetType.card,
              targetId: 'item-cost-a',
            ),
          ],
        ),
        CreatePurchaseRequest(
          id: 'purchase-b',
          purchasedAt: now,
          amountMinor: 30000,
          currency: 'CNY',
          targets: const <PurchaseTargetInput>[
            PurchaseTargetInput(
              targetType: PurchaseTargetType.card,
              targetId: 'item-cost-b',
            ),
          ],
        ),
        CreatePurchaseRequest(
          id: 'purchase-c',
          purchasedAt: now,
          amountMinor: 1000,
          currency: 'JPY',
          targets: const <PurchaseTargetInput>[
            PurchaseTargetInput(
              targetType: PurchaseTargetType.card,
              targetId: 'item-cost-c',
            ),
          ],
        ),
      ]) {
        await db.createPurchase(request: request.normalized(), now: now);
      }

      final cards = await db
          .watchOrganizedCards(
            const CardLibraryQuery(
              sortField: CardSortField.acquisitionCost,
              sortDirection: SortDirection.descending,
            ).normalized(),
          )
          .first;

      expect(cards.map((card) => card.cardItemId), <String>[
        'item-cost-a',
        'item-cost-b',
        'item-cost-c',
        'item-cost-d',
      ]);
      expect(cards.first.acquisitionCostCurrency, 'CNY');
      expect(cards.first.acquisitionCostMinor, 50000);
      expect(cards[2].acquisitionCostCurrency, 'JPY');
      expect(cards.last.acquisitionCostCurrency, isNull);
    },
  );

  test('excludes soft-deleted card items and tags from discovery', () async {
    await seedDiscoveryFixture();
    await db.setItemDeletedAtForTest('item-a', now);
    await db.deleteOrganizationTag(tagId: 'limited', now: now);

    final cards = await db
        .watchOrganizedCards(
          const CardLibraryQuery(searchText: '限定').normalized(),
        )
        .first;
    expect(cards, isEmpty);
  });

  test(
    'queries 10000 definitions with text, tag, and stable sort under 300ms',
    () async {
      await db.createOrganizationTag(
        request: const CreateTagRequest(
          id: 'benchmark-tag',
          name: '基准',
        ).normalized(),
        now: now,
      );
      await db.batch((batch) {
        for (var index = 0; index < 10000; index++) {
          final suffix = index.toString().padLeft(5, '0');
          batch.insert(
            db.cardDefinitions,
            CardDefinitionsCompanion.insert(
              id: 'definition-$suffix',
              name: index == 9876 ? '性能目标卡' : '测试卡$suffix',
              city: const Value('上海'),
              cardType: const Value('纪念卡'),
              createdAt: now,
              updatedAt: now,
            ),
          );
          batch.insert(
            db.cardItems,
            CardItemsCompanion.insert(
              id: 'item-$suffix',
              definitionId: 'definition-$suffix',
              createdAt: now,
              updatedAt: now,
            ),
          );
        }
        batch.insert(
          db.cardTags,
          CardTagsCompanion.insert(
            tagId: 'benchmark-tag',
            definitionId: 'definition-09876',
            createdAt: now,
          ),
        );
      });

      final watch = Stopwatch()..start();
      final result = await db
          .watchOrganizedCards(
            const CardLibraryQuery(
              searchText: '性能目标',
              cardType: '纪念卡',
              city: '上海',
              tagIds: <String>['benchmark-tag'],
              sortField: CardSortField.name,
            ).normalized(),
          )
          .first;
      watch.stop();

      expect(result.map((card) => card.cardItemId), <String>['item-09876']);
      expect(
        watch.elapsedMilliseconds,
        lessThan(300),
        reason: '查询耗时 ${watch.elapsedMilliseconds}ms',
      );
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
