import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/core/time/clock.dart';
import 'package:cardfolio_app/features/cards/data/local/card_database.dart';
import 'package:cardfolio_app/features/purchases/data/purchase_repository_impl.dart';
import 'package:cardfolio_app/features/purchases/domain/purchase_models.dart';
import 'package:cardfolio_app/features/purchases/domain/purchase_repository.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late PurchaseRepository repository;
  final now = DateTime.utc(2026, 7, 28, 10);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = PurchaseRepositoryImpl(database: db, clock: FixedClock(now));
  });

  tearDown(() => db.close());

  Future<void> insertCard() async {
    await db
        .into(db.cardDefinitions)
        .insert(
          CardDefinitionsCompanion.insert(
            id: 'definition-1',
            name: '樱花纪念卡',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.cardItems)
        .insert(
          CardItemsCompanion.insert(
            id: 'card-1',
            definitionId: 'definition-1',
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  CreatePurchaseRequest request({String id = ' purchase-1 '}) {
    return CreatePurchaseRequest(
      id: id,
      purchasedAt: DateTime(2026, 7, 27, 18),
      amountMinor: 50000,
      currency: ' cny ',
      targets: const <PurchaseTargetInput>[
        PurchaseTargetInput(
          targetType: PurchaseTargetType.card,
          targetId: ' card-1 ',
        ),
      ],
    );
  }

  test(
    'normalizes and creates a purchase idempotently with the clock',
    () async {
      await insertCard();

      final first = await repository.createPurchase(request());
      final second = await repository.createPurchase(request());

      expect(first, 'purchase-1');
      expect(second, 'purchase-1');
      final records = await repository.watchPurchases().first;
      expect(records, hasLength(1));
      expect(records.single.currency, 'CNY');
      expect(records.single.createdAt, now);
      expect(records.single.targets.single.targetId, 'card-1');
    },
  );

  test(
    'maps an unknown target to a target-scoped validation failure',
    () async {
      await expectLater(
        repository.createPurchase(request()),
        throwsA(
          isA<PurchaseValidationFailure>().having(
            (failure) => failure.field,
            'field',
            PurchaseField.target,
          ),
        ),
      );
      expect(await db.select(db.purchases).get(), isEmpty);
    },
  );

  test(
    'creates a refund with the original currency and safe error mapping',
    () async {
      await insertCard();
      await repository.createPurchase(request());

      final id = await repository.createAdjustment(
        CreateAdjustmentRequest(
          id: ' adjustment-1 ',
          adjustmentOfId: ' purchase-1 ',
          adjustedAt: DateTime(2026, 7, 29),
          refundMinor: 12000,
        ),
      );

      expect(id, 'adjustment-1');
      final records = await repository.watchPurchases().first;
      final adjustment = records.singleWhere((record) => record.isAdjustment);
      expect(adjustment.currency, 'CNY');
      expect(adjustment.amountMinor, -12000);

      await expectLater(
        repository.createAdjustment(
          CreateAdjustmentRequest(
            id: 'adjustment-2',
            adjustmentOfId: 'missing',
            adjustedAt: now,
            refundMinor: 100,
          ),
        ),
        throwsA(
          isA<PurchaseValidationFailure>().having(
            (failure) => failure.field,
            'field',
            PurchaseField.adjustment,
          ),
        ),
      );
    },
  );

  test('exposes fee options and persists normalized exchange rates', () async {
    await insertCard();
    await repository.createPurchase(
      CreatePurchaseRequest(
        id: 'purchase-1',
        purchasedAt: now,
        amountMinor: 50000,
        currency: 'CNY',
        shippingMinor: 2000,
        feesMinor: 500,
        targets: const <PurchaseTargetInput>[
          PurchaseTargetInput(
            targetType: PurchaseTargetType.card,
            targetId: 'card-1',
          ),
        ],
      ),
    );

    final summary = await repository
        .watchCostSummary(
          const CostDisplayOptions(includeShipping: false, includeFees: false),
        )
        .first;
    expect(summary.totals.single.minorUnits, 50000);

    await repository.saveExchangeRate(
      ExchangeRateInput(
        baseCurrency: ' jpy ',
        quoteCurrency: ' cny ',
        rateDate: now,
        numerator: 47,
        denominator: 1000,
        source: ' manual ',
        capturedAt: now,
      ),
    );
    final rate = await db.select(db.exchangeRates).getSingle();
    expect(rate.baseCurrency, 'JPY');
    expect(rate.quoteCurrency, 'CNY');
    expect(rate.source, 'manual');
  });
}
