import 'package:cardfolio_app/app/app_theme.dart';
import 'package:cardfolio_app/core/id/id_generator.dart';
import 'package:cardfolio_app/features/cards/data/card_providers.dart';
import 'package:cardfolio_app/features/purchases/data/purchase_providers.dart';
import 'package:cardfolio_app/features/purchases/domain/purchase_models.dart';
import 'package:cardfolio_app/features/purchases/presentation/purchase_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_purchase_repository.dart';

final class _FixedIdGenerator implements IdGenerator {
  @override
  String newId() => 'adjustment-new';
}

void main() {
  late FakePurchaseRepository repository;

  Widget subject() {
    return ProviderScope(
      overrides: [
        purchaseRepositoryProvider.overrideWithValue(repository),
        idGeneratorProvider.overrideWithValue(_FixedIdGenerator()),
      ],
      child: MaterialApp(
        theme: buildCardfolioTheme(),
        home: const PurchaseListScreen(),
      ),
    );
  }

  testWidgets('shows an explicit empty state and create action', (
    tester,
  ) async {
    repository = FakePurchaseRepository();

    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    expect(find.text('还没有购买记录'), findsOneWidget);
    expect(find.text('记录购买'), findsOneWidget);
  });

  testWidgets('groups totals by currency and toggles fee display scope', (
    tester,
  ) async {
    final createdAt = DateTime.utc(2026, 7, 28);
    repository = FakePurchaseRepository(
      records: <PurchaseRecord>[
        PurchaseRecord(
          id: 'purchase-cny',
          purchasedAt: createdAt,
          amountMinor: 50000,
          currency: 'CNY',
          shippingMinor: 2000,
          feesMinor: 500,
          createdAt: createdAt,
          targets: const <PurchaseTargetSnapshot>[
            PurchaseTargetSnapshot(
              targetType: PurchaseTargetType.card,
              targetId: 'card-1',
              targetName: '樱花纪念卡',
            ),
          ],
        ),
        PurchaseRecord(
          id: 'purchase-jpy',
          purchasedAt: createdAt,
          amountMinor: 1000,
          currency: 'JPY',
          shippingMinor: 0,
          feesMinor: 0,
          createdAt: createdAt,
          targets: const <PurchaseTargetSnapshot>[
            PurchaseTargetSnapshot(
              targetType: PurchaseTargetType.cardSet,
              targetId: 'set-1',
              targetName: '世博套卡',
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    expect(find.text('CNY 525.00'), findsWidgets);
    expect(find.text('JPY 1000'), findsWidgets);
    expect(find.text('樱花纪念卡'), findsOneWidget);
    expect(find.text('世博套卡'), findsOneWidget);

    await tester.tap(find.byKey(const Key('include-shipping')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('include-fees')));
    await tester.pumpAndSettle();

    expect(find.text('CNY 500.00'), findsOneWidget);
  });

  testWidgets('creates a refund adjustment without editing the original', (
    tester,
  ) async {
    final createdAt = DateTime.utc(2026, 7, 28);
    repository = FakePurchaseRepository(
      records: <PurchaseRecord>[
        PurchaseRecord(
          id: 'purchase-1',
          purchasedAt: createdAt,
          amountMinor: 50000,
          currency: 'CNY',
          shippingMinor: 0,
          feesMinor: 0,
          createdAt: createdAt,
          targets: const <PurchaseTargetSnapshot>[
            PurchaseTargetSnapshot(
              targetType: PurchaseTargetType.card,
              targetId: 'card-1',
              targetName: '樱花纪念卡',
            ),
          ],
        ),
      ],
    );

    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('refund-purchase-1')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('refund-amount')), '120.00');
    await tester.tap(find.widgetWithText(FilledButton, '保存退款'));
    await tester.pumpAndSettle();

    expect(repository.adjustments, hasLength(1));
    expect(repository.adjustments.single.adjustmentOfId, 'purchase-1');
    expect(repository.adjustments.single.refundMinor, 12000);
  });
}
