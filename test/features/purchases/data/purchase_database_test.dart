import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/purchases/data/local/purchase_database.dart';
import 'package:cardfolio_app/features/purchases/domain/purchase_models.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  final now = DateTime.utc(2026, 7, 28, 8);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  Future<void> insertCard({required String id, required String name}) async {
    final definitionId = 'definition-$id';
    await db
        .into(db.cardDefinitions)
        .insert(
          CardDefinitionsCompanion.insert(
            id: definitionId,
            name: name,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.cardItems)
        .insert(
          CardItemsCompanion.insert(
            id: id,
            definitionId: definitionId,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> insertSet({required String id, required String name}) {
    return db
        .into(db.cardSets)
        .insert(
          CardSetsCompanion.insert(
            id: id,
            name: name,
            countKnown: false,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  CreatePurchaseRequest purchase({
    String id = 'purchase-1',
    int amountMinor = 50000,
    int shippingMinor = 0,
    int feesMinor = 0,
    String currency = 'CNY',
    List<PurchaseTargetInput>? targets,
  }) {
    return CreatePurchaseRequest(
      id: id,
      purchasedAt: now,
      amountMinor: amountMinor,
      currency: currency,
      shippingMinor: shippingMinor,
      feesMinor: feesMinor,
      targets:
          targets ??
          const <PurchaseTargetInput>[
            PurchaseTargetInput(
              targetType: PurchaseTargetType.card,
              targetId: 'card-1',
            ),
          ],
    ).normalized();
  }

  test('lists active card and set targets with their names', () async {
    await insertCard(id: 'card-1', name: '樱花纪念卡');
    await insertSet(id: 'set-1', name: '世博套卡');

    final options = await db.watchPurchaseTargetOptions().first;

    expect(options, hasLength(2));
    expect(options[0].targetType, PurchaseTargetType.card);
    expect(options[0].targetId, 'card-1');
    expect(options[0].targetName, '樱花纪念卡');
    expect(options[1].targetType, PurchaseTargetType.cardSet);
    expect(options[1].targetName, '世博套卡');
  });

  test(
    'card-entry cost uses and retains the acquisition calendar day',
    () async {
      await insertCard(id: 'card-1', name: '樱花纪念卡');
      final acquiredAt = DateTime(2026, 6, 15, 20, 30);

      await db.saveCardEntryCost(
        request: SaveCardEntryCostRequest(
          cardItemId: 'card-1',
          amountMinor: 5000,
          shippingMinor: 200,
          purchasedAt: acquiredAt,
        ),
        now: now,
      );

      var stored = await db.select(db.purchases).getSingle();
      expect(stored.id, cardEntryCostPurchaseId('card-1'));
      expect(stored.purchasedAt.toUtc(), DateTime.utc(2026, 6, 15));
      expect(stored.amountMinor, 5000);
      expect(stored.shippingMinor, 200);
      final originalVersion = stored.version;

      await db.saveCardEntryCost(
        request: const SaveCardEntryCostRequest(
          cardItemId: 'card-1',
          amountMinor: 6000,
          shippingMinor: 300,
        ),
        now: now.add(const Duration(days: 1)),
      );

      stored = await db.select(db.purchases).getSingle();
      expect(stored.purchasedAt.toUtc(), DateTime.utc(2026, 6, 15));
      expect(stored.amountMinor, 6000);
      expect(stored.shippingMinor, 300);
      expect(stored.version, originalVersion + 1);
    },
  );

  test(
    'zero card-entry cost removes both the ledger row and its target',
    () async {
      await insertCard(id: 'card-1', name: '樱花纪念卡');
      await db.saveCardEntryCost(
        request: const SaveCardEntryCostRequest(
          cardItemId: 'card-1',
          amountMinor: 5000,
          shippingMinor: 0,
        ),
        now: now,
      );

      await db.saveCardEntryCost(
        request: const SaveCardEntryCostRequest(
          cardItemId: 'card-1',
          amountMinor: 0,
          shippingMinor: 0,
        ),
        now: now.add(const Duration(minutes: 1)),
      );

      expect(await db.select(db.purchases).get(), isEmpty);
      expect(await db.select(db.purchaseItems).get(), isEmpty);
    },
  );

  test(
    'saves purchase targets atomically and allocations do not add cost',
    () async {
      await insertCard(id: 'card-1', name: '樱花纪念卡');
      await insertSet(id: 'set-1', name: '世博套卡');
      final request = purchase(
        targets: const <PurchaseTargetInput>[
          PurchaseTargetInput(
            targetType: PurchaseTargetType.card,
            targetId: 'card-1',
            allocatedMinor: 30000,
          ),
          PurchaseTargetInput(
            targetType: PurchaseTargetType.cardSet,
            targetId: 'set-1',
            allocatedMinor: 20000,
          ),
        ],
      );

      await db.createPurchase(request: request, now: now);

      final record = (await db.watchPurchaseRecords().first).single;
      final summary = await db
          .watchPurchaseCostSummary(const CostDisplayOptions())
          .first;
      expect(record.targets, hasLength(2));
      expect(record.targets[0].targetName, '樱花纪念卡');
      expect(record.targets[1].targetName, '世博套卡');
      expect(record.targets.map((target) => target.allocatedMinor), <int?>[
        30000,
        20000,
      ]);
      expect(summary.totals.single.currency, 'CNY');
      expect(summary.totals.single.minorUnits, 50000);
      expect(summary.totals.single.purchaseCount, 1);
    },
  );

  test('shipping and fee options change only the queried total', () async {
    await insertCard(id: 'card-1', name: '樱花纪念卡');
    await db.createPurchase(
      request: purchase(shippingMinor: 2000, feesMinor: 500),
      now: now,
    );

    final withAll = await db
        .watchPurchaseCostSummary(const CostDisplayOptions())
        .first;
    final withoutShipping = await db
        .watchPurchaseCostSummary(
          const CostDisplayOptions(includeShipping: false),
        )
        .first;
    final goodsOnly = await db
        .watchPurchaseCostSummary(
          const CostDisplayOptions(includeShipping: false, includeFees: false),
        )
        .first;
    final stored = await db.select(db.purchases).getSingle();

    expect(withAll.totals.single.minorUnits, 52500);
    expect(withoutShipping.totals.single.minorUnits, 50500);
    expect(goodsOnly.totals.single.minorUnits, 50000);
    expect(stored.shippingMinor, 2000);
    expect(stored.feesMinor, 500);
  });

  test(
    'refund is a negative row while the original purchase stays unchanged',
    () async {
      await insertCard(id: 'card-1', name: '樱花纪念卡');
      await db.createPurchase(request: purchase(), now: now);

      await db.createPurchaseAdjustment(
        request: CreateAdjustmentRequest(
          id: 'adjustment-1',
          adjustmentOfId: 'purchase-1',
          adjustedAt: now.add(const Duration(days: 1)),
          refundMinor: 12000,
          notes: '部分退款',
        ).normalized(),
        now: now.add(const Duration(days: 1)),
      );

      final records = await db.watchPurchaseRecords().first;
      final original = records.singleWhere((record) => !record.isAdjustment);
      final adjustment = records.singleWhere((record) => record.isAdjustment);
      final summary = await db
          .watchPurchaseCostSummary(const CostDisplayOptions())
          .first;
      expect(original.amountMinor, 50000);
      expect(original.adjustmentOfId, isNull);
      expect(adjustment.amountMinor, -12000);
      expect(adjustment.currency, 'CNY');
      expect(adjustment.targets.single.targetName, '樱花纪念卡');
      expect(summary.totals.single.minorUnits, 38000);
      expect(summary.totals.single.purchaseCount, 2);
    },
  );

  test(
    'same purchase id is idempotent and does not overwrite the fact',
    () async {
      await insertCard(id: 'card-1', name: '樱花纪念卡');
      await db.createPurchase(request: purchase(), now: now);

      await db.createPurchase(
        request: purchase(amountMinor: 90000),
        now: now.add(const Duration(hours: 1)),
      );

      final rows = await db.select(db.purchases).get();
      expect(rows, hasLength(1));
      expect(rows.single.amountMinor, 50000);
    },
  );

  test('unknown target rolls back without a partial purchase', () async {
    await expectLater(
      db.createPurchase(request: purchase(), now: now),
      throwsA(isA<StateError>()),
    );

    expect(await db.select(db.purchases).get(), isEmpty);
    expect(await db.select(db.purchaseItems).get(), isEmpty);
  });

  test(
    'target snapshot survives deletion while active total excludes it',
    () async {
      await insertCard(id: 'card-1', name: '即将删除的卡');
      await db.createPurchase(request: purchase(), now: now);

      await db.setItemDeletedAtForTest(
        'card-1',
        now.add(const Duration(days: 1)),
      );

      final record = (await db.watchPurchaseRecords().first).single;
      final options = await db.watchPurchaseTargetOptions().first;
      final summary = await db
          .watchPurchaseCostSummary(const CostDisplayOptions())
          .first;
      expect(record.targets.single.targetName, '即将删除的卡');
      expect(options, isEmpty);
      expect(summary.totals, isEmpty);
    },
  );

  test('stores a precise exchange rate and its audit fields', () async {
    final rate = ExchangeRateInput(
      baseCurrency: 'JPY',
      quoteCurrency: 'CNY',
      rateDate: now,
      numerator: 47,
      denominator: 1000,
      source: 'manual',
      capturedAt: now.add(const Duration(minutes: 2)),
    ).normalized();

    await db.savePurchaseExchangeRate(rate);

    final row = await db.select(db.exchangeRates).getSingle();
    expect(row.baseCurrency, 'JPY');
    expect(row.quoteCurrency, 'CNY');
    expect(row.numerator, 47);
    expect(row.denominator, 1000);
    expect(row.source, 'manual');
    expect(row.capturedAt.toUtc(), now.add(const Duration(minutes: 2)));
  });
}
