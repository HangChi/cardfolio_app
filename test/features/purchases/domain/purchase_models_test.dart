import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/features/purchases/domain/purchase_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyAmount', () {
    test('parses and formats common minor-unit exponents without floats', () {
      expect(CurrencyAmount.parse('500.25', 'cny').minorUnits, 50025);
      expect(CurrencyAmount.parse('1,000', 'JPY').minorUnits, 1000);
      expect(CurrencyAmount.parse('12.345', 'KWD').minorUnits, 12345);
      expect(
        const CurrencyAmount(minorUnits: -12000, currency: 'CNY').formatted,
        '-120.00',
      );
    });

    test('rejects excess precision and non-ISO currency codes', () {
      expect(
        () => CurrencyAmount.parse('1.001', 'CNY'),
        throwsA(isA<PurchaseValidationFailure>()),
      );
      expect(
        () => CurrencyAmount.parse('10.00', 'RMB'),
        throwsA(isA<PurchaseValidationFailure>()),
      );
    });
  });

  group('CreatePurchaseRequest.normalized', () {
    test('normalizes UTC fields and derives the default ledger total', () {
      final request = CreatePurchaseRequest(
        id: ' purchase-1 ',
        purchasedAt: DateTime(2026, 7, 28, 18, 30),
        amountMinor: 50000,
        currency: ' cny ',
        shippingMinor: 2000,
        feesMinor: 500,
        channel: ' 线下 ',
        seller: ' 交通馆 ',
        notes: ' 保存票据 ',
        targets: const <PurchaseTargetInput>[
          PurchaseTargetInput(
            targetType: PurchaseTargetType.card,
            targetId: ' card-1 ',
            allocatedMinor: 31500,
          ),
          PurchaseTargetInput(
            targetType: PurchaseTargetType.cardSet,
            targetId: ' set-1 ',
            allocatedMinor: 21000,
          ),
        ],
      ).normalized();

      expect(request.id, 'purchase-1');
      expect(request.purchasedAt.isUtc, isTrue);
      expect(request.currency, 'CNY');
      expect(request.channel, '线下');
      expect(request.seller, '交通馆');
      expect(request.notes, '保存票据');
      expect(request.defaultLedgerMinor, 52500);
      expect(request.targets.first.targetId, 'card-1');
      expect(request.targets.last.targetId, 'set-1');
      expect(request.hasAllocations, isTrue);
    });

    test('rejects duplicate targets after id normalization', () {
      expect(
        () => CreatePurchaseRequest(
          id: 'purchase-1',
          purchasedAt: DateTime.utc(2026, 7, 28),
          amountMinor: 50000,
          currency: 'CNY',
          targets: const <PurchaseTargetInput>[
            PurchaseTargetInput(
              targetType: PurchaseTargetType.card,
              targetId: 'card-1',
            ),
            PurchaseTargetInput(
              targetType: PurchaseTargetType.card,
              targetId: ' card-1 ',
            ),
          ],
        ).normalized(),
        throwsA(
          isA<PurchaseValidationFailure>().having(
            (failure) => failure.field,
            'field',
            PurchaseField.target,
          ),
        ),
      );
    });

    test('requires all allocations to sum to goods plus shipping and fees', () {
      final base = CreatePurchaseRequest(
        id: 'purchase-1',
        purchasedAt: DateTime.utc(2026, 7, 28),
        amountMinor: 50000,
        currency: 'CNY',
        shippingMinor: 2000,
        feesMinor: 500,
        targets: const <PurchaseTargetInput>[
          PurchaseTargetInput(
            targetType: PurchaseTargetType.card,
            targetId: 'card-1',
            allocatedMinor: 30000,
          ),
          PurchaseTargetInput(
            targetType: PurchaseTargetType.card,
            targetId: 'card-2',
          ),
        ],
      );

      expect(
        base.normalized,
        throwsA(
          isA<PurchaseValidationFailure>().having(
            (failure) => failure.field,
            'field',
            PurchaseField.allocation,
          ),
        ),
      );
      expect(
        () => CreatePurchaseRequest(
          id: 'purchase-2',
          purchasedAt: DateTime.utc(2026, 7, 28),
          amountMinor: 50000,
          currency: 'CNY',
          shippingMinor: 2000,
          feesMinor: 500,
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
        ).normalized(),
        throwsA(isA<PurchaseValidationFailure>()),
      );
    });

    test(
      'rejects negative ordinary amounts and a purchase without targets',
      () {
        expect(
          () => CreatePurchaseRequest(
            id: 'purchase-1',
            purchasedAt: DateTime.utc(2026, 7, 28),
            amountMinor: -1,
            currency: 'CNY',
            targets: const <PurchaseTargetInput>[
              PurchaseTargetInput(
                targetType: PurchaseTargetType.card,
                targetId: 'card-1',
              ),
            ],
          ).normalized(),
          throwsA(isA<PurchaseValidationFailure>()),
        );
        expect(
          () => CreatePurchaseRequest(
            id: 'purchase-1',
            purchasedAt: DateTime.utc(2026, 7, 28),
            amountMinor: 50000,
            currency: 'CNY',
          ).normalized(),
          throwsA(isA<PurchaseValidationFailure>()),
        );
      },
    );
  });

  group('SaveCardEntryCostRequest.normalized', () {
    test(
      'normalizes the target id and preserves the acquisition calendar day',
      () {
        final result = SaveCardEntryCostRequest(
          cardItemId: ' item-1 ',
          amountMinor: 5000,
          shippingMinor: 200,
          purchasedAt: DateTime(2026, 7, 28, 23, 45),
        ).normalized();

        expect(result.cardItemId, 'item-1');
        expect(result.purchasedAt, DateTime.utc(2026, 7, 28));
        expect(result.amountMinor, 5000);
        expect(result.shippingMinor, 200);
      },
    );

    test('rejects a negative card-entry amount', () {
      expect(
        () => const SaveCardEntryCostRequest(
          cardItemId: 'item-1',
          amountMinor: -1,
          shippingMinor: 0,
        ).normalized(),
        throwsA(
          isA<PurchaseValidationFailure>().having(
            (failure) => failure.field,
            'field',
            PurchaseField.amount,
          ),
        ),
      );
    });
  });

  group('adjustments and totals', () {
    test('normalizes a positive refund request without mutating its sign', () {
      final result = CreateAdjustmentRequest(
        id: ' adjustment-1 ',
        adjustmentOfId: ' purchase-1 ',
        adjustedAt: DateTime(2026, 7, 29),
        refundMinor: 12000,
        notes: ' 部分退款 ',
      ).normalized();

      expect(result.id, 'adjustment-1');
      expect(result.adjustmentOfId, 'purchase-1');
      expect(result.adjustedAt.isUtc, isTrue);
      expect(result.refundMinor, 12000);
      expect(result.notes, '部分退款');
    });

    test('rejects zero or negative refund input', () {
      expect(
        () => CreateAdjustmentRequest(
          id: 'adjustment-1',
          adjustmentOfId: 'purchase-1',
          adjustedAt: DateTime.utc(2026, 7, 29),
          refundMinor: 0,
        ).normalized(),
        throwsA(isA<PurchaseValidationFailure>()),
      );
    });

    test('ledger options include fees independently of allocations', () {
      final record = PurchaseRecord(
        id: 'purchase-1',
        purchasedAt: DateTime.utc(2026, 7, 28),
        amountMinor: 50000,
        currency: 'CNY',
        shippingMinor: 2000,
        feesMinor: 500,
        createdAt: DateTime.utc(2026, 7, 28),
        targets: const <PurchaseTargetSnapshot>[
          PurchaseTargetSnapshot(
            targetType: PurchaseTargetType.cardSet,
            targetId: 'set-1',
            targetName: '世博套卡',
            allocatedMinor: 52500,
          ),
        ],
      );

      expect(record.ledgerMinor(), 52500);
      expect(
        record.ledgerMinor(const CostDisplayOptions(includeShipping: false)),
        50500,
      );
      expect(
        record.ledgerMinor(
          const CostDisplayOptions(includeShipping: false, includeFees: false),
        ),
        50000,
      );
    });
  });

  test('exchange rates require a precise positive rational and source', () {
    final rate = ExchangeRateInput(
      baseCurrency: ' jpy ',
      quoteCurrency: ' cny ',
      rateDate: DateTime(2026, 7, 28, 18),
      numerator: 47,
      denominator: 1000,
      source: ' 手工录入 ',
      capturedAt: DateTime(2026, 7, 28, 19),
    ).normalized();

    expect(rate.baseCurrency, 'JPY');
    expect(rate.quoteCurrency, 'CNY');
    expect(rate.rateDate, DateTime.utc(2026, 7, 28));
    expect(rate.numerator, 47);
    expect(rate.denominator, 1000);
    expect(rate.source, '手工录入');
    expect(
      () => ExchangeRateInput(
        baseCurrency: 'JPY',
        quoteCurrency: 'CNY',
        rateDate: DateTime.utc(2026, 7, 28),
        numerator: 0,
        denominator: 1000,
        source: 'manual',
        capturedAt: DateTime.utc(2026, 7, 28),
      ).normalized(),
      throwsA(isA<PurchaseValidationFailure>()),
    );
  });
}
