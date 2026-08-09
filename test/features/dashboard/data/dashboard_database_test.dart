import 'dart:async';

import 'package:cardfolio_app/features/card_sets/data/local/card_set_database.dart';
import 'package:cardfolio_app/features/card_sets/domain/card_set_models.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/cards/domain/card_models.dart';
import 'package:cardfolio_app/features/dashboard/data/local/dashboard_database.dart';
import 'package:cardfolio_app/features/dashboard/domain/dashboard_models.dart';
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
    required DateTime createdAt,
    DateTime? acquiredAt,
    int quantity = 1,
    String? city,
    String? issuer,
    String? issuedAt,
    String? cardType,
    bool needsCompletion = false,
  }) {
    return db.insertCardGraph(
      CardRowGraph(
        definition: CardDefinitionsCompanion.insert(
          id: 'definition-$suffix',
          name: name,
          city: Value(city),
          issuer: Value(issuer),
          issuedAt: Value(issuedAt),
          cardType: Value(cardType),
          needsCompletion: Value(needsCompletion),
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
        item: CardItemsCompanion.insert(
          id: 'item-$suffix',
          definitionId: 'definition-$suffix',
          quantity: Value(quantity),
          acquiredAt: Value(acquiredAt ?? createdAt),
          createdAt: createdAt,
          updatedAt: createdAt,
        ),
        images: <CardImagesCompanion>[
          CardImagesCompanion.insert(
            id: 'image-$suffix',
            cardItemId: 'item-$suffix',
            kind: CardImageKind.front,
            relativePath: 'originals/item-$suffix/image-$suffix.jpg',
            checksum: 'checksum-$suffix',
            isCover: const Value(true),
            createdAt: createdAt,
          ),
        ],
      ),
    );
  }

  Future<void> addSet({
    required String suffix,
    required bool countKnown,
    required List<String> ownedDefinitions,
    int missingCount = 0,
  }) async {
    final total = ownedDefinitions.length + missingCount;
    await db.createCardSet(
      request: CreateCardSetRequest(
        id: 'set-$suffix',
        name: '套卡 $suffix',
        countKnown: countKnown,
        expectedCount: countKnown ? total : null,
      ).normalized(),
      now: now,
    );
    var index = 0;
    for (final definitionId in ownedDefinitions) {
      await db.addCardSetMember(
        request: AddCardSetMemberRequest.existing(
          id: 'member-$suffix-${index++}',
          setId: 'set-$suffix',
          definitionId: definitionId,
        ).normalized(),
        now: now,
      );
    }
    for (var missing = 0; missing < missingCount; missing++) {
      await db.addCardSetMember(
        request: AddCardSetMemberRequest.missing(
          id: 'member-$suffix-${index++}',
          setId: 'set-$suffix',
          definitionId: 'definition-$suffix-missing-$missing',
          definitionName: '$suffix 缺失 $missing',
        ).normalized(),
        now: now,
      );
    }
  }

  Future<void> seedFixture() async {
    await insertCard(
      suffix: 'a',
      name: '七月纪念卡',
      createdAt: DateTime.utc(2026, 7, 10),
      quantity: 2,
      city: '东京',
      issuer: 'Metro',
      issuedAt: '2026-03',
      cardType: '纪念卡',
    );
    await insertCard(
      suffix: 'b',
      name: '六月单程票',
      createdAt: DateTime.utc(2026, 6, 20),
      city: '上海',
      issuer: '申通地铁',
      issuedAt: '2025',
      cardType: '单程票',
      needsCompletion: true,
    );
    await insertCard(
      suffix: 'deleted',
      name: '已删除卡',
      createdAt: DateTime.utc(2026, 7, 1),
      quantity: 5,
      city: '东京',
      issuedAt: '2026',
    );
    await db.setItemDeletedAtForTest('item-deleted', now);
    await insertCard(
      suffix: 'future',
      name: '下月计划卡',
      createdAt: DateTime.utc(2026, 8, 1),
      quantity: 4,
    );

    await db.createOrganizationTag(
      request: const CreateTagRequest(
        id: 'tag-limited',
        name: '限定',
      ).normalized(),
      now: now,
    );
    await db.replaceCardTags(
      definitionId: 'definition-a',
      tagIds: const <String>['tag-limited'],
      now: now,
    );

    await addSet(
      suffix: 'complete',
      countKnown: true,
      ownedDefinitions: const <String>['definition-a'],
    );
    await addSet(
      suffix: 'near',
      countKnown: true,
      ownedDefinitions: const <String>['definition-b'],
      missingCount: 1,
    );
    await addSet(
      suffix: 'unknown',
      countKnown: false,
      ownedDefinitions: const <String>['definition-a'],
    );

    await db.createPurchase(
      request: CreatePurchaseRequest(
        id: 'purchase-cny',
        purchasedAt: DateTime.utc(2026, 6, 15),
        amountMinor: 1000,
        shippingMinor: 100,
        feesMinor: 50,
        currency: 'CNY',
        targets: const <PurchaseTargetInput>[
          PurchaseTargetInput(
            targetType: PurchaseTargetType.card,
            targetId: 'item-a',
          ),
        ],
      ).normalized(),
      now: now,
    );
    await db.createPurchaseAdjustment(
      request: CreateAdjustmentRequest(
        id: 'refund-cny',
        adjustmentOfId: 'purchase-cny',
        adjustedAt: DateTime.utc(2026, 7, 2),
        refundMinor: 200,
      ).normalized(),
      now: now,
    );
    await db.createPurchase(
      request: CreatePurchaseRequest(
        id: 'purchase-jpy',
        purchasedAt: DateTime.utc(2026, 6, 18),
        amountMinor: 300,
        currency: 'JPY',
        targets: const <PurchaseTargetInput>[
          PurchaseTargetInput(
            targetType: PurchaseTargetType.card,
            targetId: 'item-b',
          ),
        ],
      ).normalized(),
      now: now,
    );
  }

  test(
    'builds the home summary from active facts and original currencies',
    () async {
      await seedFixture();

      final home = await db
          .watchHomeDashboard(nowUtc: now, options: const CostDisplayOptions())
          .first;

      expect(home.entityCount, 7);
      expect(home.definitionCount, 3);
      expect(home.setCount, 3);
      expect(home.completedSetCount, 1);
      expect(home.monthAddedCount, 2);
      expect(
        home.costTotals
            .map((total) => (total.currency, total.minorUnits))
            .toList(),
        <(String, int)>[('CNY', 950), ('JPY', 300)],
      );
      expect(home.recentCards.map((card) => card.cardItemId), <String>[
        'item-future',
        'item-a',
        'item-b',
      ]);
      expect(home.nearlyCompleteSets.map((set) => set.id), <String>[
        'set-near',
      ]);
      expect(home.needsCompletionCards.map((card) => card.cardItemId), <String>[
        'item-b',
      ]);
    },
  );

  test(
    'groups card, tag, set, and cost distributions without conversion',
    () async {
      await seedFixture();

      final stats = await db
          .watchStatisticsSnapshot(const CostDisplayOptions())
          .first;

      expect(
        stats
            .bucketsFor(StatisticDimension.issuedYear)
            .map((bucket) => (bucket.label, bucket.count)),
        <(String, int)>[('2026', 2), ('2025', 1)],
      );
      expect(
        stats
            .bucketsFor(StatisticDimension.city)
            .map((bucket) => (bucket.label, bucket.count)),
        <(String, int)>[('东京', 2), ('上海', 1)],
      );
      expect(
        stats
            .bucketsFor(StatisticDimension.issuer)
            .map((bucket) => (bucket.label, bucket.count)),
        <(String, int)>[('Metro', 2), ('申通地铁', 1)],
      );
      expect(
        stats
            .bucketsFor(StatisticDimension.tag)
            .map((bucket) => (bucket.key, bucket.count)),
        <(String, int)>[('tag-limited', 2)],
      );
      expect(
        stats
            .bucketsFor(StatisticDimension.setStatus)
            .map((bucket) => (bucket.label, bucket.count)),
        <(String, int)>[('已集齐', 1), ('差 1 款', 1), ('总数未知', 1)],
      );
      expect(
        stats.costTrend
            .map(
              (point) => (point.monthLabel, point.currency, point.minorUnits),
            )
            .toList(),
        <(String, String, int)>[
          ('2026-06', 'CNY', 1150),
          ('2026-06', 'JPY', 300),
          ('2026-07', 'CNY', -200),
        ],
      );
    },
  );

  test('recomputes the home stream after source quantity changes', () async {
    await insertCard(suffix: 'reactive', name: '响应式卡片', createdAt: now);
    final iterator = StreamIterator(
      db.watchHomeDashboard(nowUtc: now, options: const CostDisplayOptions()),
    );
    addTearDown(iterator.cancel);

    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current.entityCount, 1);

    await (db.update(db.cardItems)
          ..where((item) => item.id.equals('item-reactive')))
        .write(const CardItemsCompanion(quantity: Value(4)));

    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current.entityCount, 4);
  });

  test('groups purchase trends by the device local calendar month', () async {
    await insertCard(suffix: 'timezone', name: '月界线卡', createdAt: now);
    final purchasedAt = DateTime.utc(2026, 6, 30, 16);
    await db.createPurchase(
      request: CreatePurchaseRequest(
        id: 'purchase-timezone',
        purchasedAt: purchasedAt,
        amountMinor: 100,
        currency: 'CNY',
        targets: const <PurchaseTargetInput>[
          PurchaseTargetInput(
            targetType: PurchaseTargetType.card,
            targetId: 'item-timezone',
          ),
        ],
      ).normalized(),
      now: now,
    );

    final point =
        (await db.watchStatisticsSnapshot(const CostDisplayOptions()).first)
            .costTrend
            .single;
    final local = purchasedAt.toLocal();
    final expectedMonth =
        '${local.year.toString().padLeft(4, '0')}-'
        '${local.month.toString().padLeft(2, '0')}';

    expect(point.monthLabel, expectedMonth);
  });

  test('card-entry spending follows the acquisition calendar day', () async {
    await insertCard(suffix: 'acquired', name: '购入日卡', createdAt: now);
    final acquiredAt = DateTime.utc(2026, 6, 30);
    await (db.update(db.cardItems)
          ..where((item) => item.id.equals('item-acquired')))
        .write(CardItemsCompanion(acquiredAt: Value(acquiredAt)));
    await db.saveCardEntryCost(
      request: const SaveCardEntryCostRequest(
        cardItemId: 'item-acquired',
        amountMinor: 8800,
        shippingMinor: 200,
      ),
      now: now,
    );

    final statistics = await db
        .watchStatisticsSnapshot(const CostDisplayOptions())
        .first;
    final calendar = await db
        .watchSpendingCalendarMonth(
          month: acquiredAt,
          options: const CostDisplayOptions(),
        )
        .first;

    expect(statistics.costTrend.single.monthLabel, '2026-06');
    expect(statistics.costTrend.single.minorUnits, 9000);
    expect(calendar.days, hasLength(1));
    expect(calendar.days.single.date, DateTime(2026, 6, 30));
    expect(calendar.days.single.entries.single.cardItemId, 'item-acquired');
  });

  test(
    'aggregates 10000 owned styles under the local P95 budget',
    () async {
      await db.batch((batch) {
        for (var index = 0; index < 10000; index++) {
          final suffix = index.toString().padLeft(5, '0');
          batch.insert(
            db.cardDefinitions,
            CardDefinitionsCompanion.insert(
              id: 'definition-benchmark-$suffix',
              name: '基准卡 $suffix',
              city: const Value('上海'),
              issuer: const Value('基准机构'),
              issuedAt: const Value('2026'),
              cardType: const Value('纪念卡'),
              createdAt: now,
              updatedAt: now,
            ),
          );
          batch.insert(
            db.cardItems,
            CardItemsCompanion.insert(
              id: 'item-benchmark-$suffix',
              definitionId: 'definition-benchmark-$suffix',
              createdAt: now,
              updatedAt: now,
            ),
          );
        }
      });

      final stopwatch = Stopwatch()..start();
      final home = await db
          .watchHomeDashboard(nowUtc: now, options: const CostDisplayOptions())
          .first;
      final stats = await db
          .watchStatisticsSnapshot(const CostDisplayOptions())
          .first;
      stopwatch.stop();

      expect(home.entityCount, 10000);
      expect(stats.bucketsFor(StatisticDimension.city).single.count, 10000);
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1200),
        reason: '首页与统计聚合耗时 ${stopwatch.elapsedMilliseconds}ms',
      );
    },
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
