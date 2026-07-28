import 'dart:async';

import 'package:cardfolio_app/app/app_theme.dart';
import 'package:cardfolio_app/core/id/id_generator.dart';
import 'package:cardfolio_app/features/cards/data/card_providers.dart';
import 'package:cardfolio_app/features/purchases/data/purchase_providers.dart';
import 'package:cardfolio_app/features/purchases/domain/purchase_models.dart';
import 'package:cardfolio_app/features/purchases/presentation/purchase_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_purchase_repository.dart';

final class _FixedIdGenerator implements IdGenerator {
  @override
  String newId() => 'purchase-new';
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
        home: const PurchaseFormScreen(),
      ),
    );
  }

  setUp(() {
    repository = FakePurchaseRepository(
      targets: const <PurchaseTargetOption>[
        PurchaseTargetOption(
          targetType: PurchaseTargetType.card,
          targetId: 'card-1',
          targetName: '樱花纪念卡',
        ),
        PurchaseTargetOption(
          targetType: PurchaseTargetType.cardSet,
          targetId: 'set-1',
          targetName: '世博套卡',
        ),
      ],
    );
  });

  testWidgets('saves exact amounts and selected targets', (tester) async {
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('purchase-amount')), '500.00');
    await tester.enterText(find.byKey(const Key('purchase-shipping')), '20.00');
    await tester.enterText(find.byKey(const Key('purchase-fees')), '5.00');
    await tester.enterText(find.byKey(const Key('purchase-channel')), '线下');
    await tester.scrollUntilVisible(
      find.byKey(const Key('target-card-card-1')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('target-card-card-1')).first);
    await tester.scrollUntilVisible(
      find.byKey(const Key('save-purchase')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('save-purchase')));
    await tester.pumpAndSettle();

    expect(repository.created, hasLength(1));
    final request = repository.created.single;
    expect(request.id, 'purchase-new');
    expect(request.amountMinor, 50000);
    expect(request.shippingMinor, 2000);
    expect(request.feesMinor, 500);
    expect(request.channel, '线下');
    expect(request.targets.single.targetId, 'card-1');
  });

  testWidgets('requires complete allocations equal to the default total', (
    tester,
  ) async {
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('purchase-amount')), '500.00');
    await tester.scrollUntilVisible(
      find.byKey(const Key('target-card-card-1')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('target-card-card-1')).first);
    await tester.pump();
    await tester.tap(find.byKey(const Key('target-cardSet-set-1')).first);
    await tester.pump();
    await tester.tap(find.byKey(const Key('enable-allocations')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('allocation-card-card-1')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.byKey(const Key('allocation-card-card-1')),
      '300.00',
    );
    await tester.enterText(
      find.byKey(const Key('allocation-cardSet-set-1')),
      '100.00',
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('save-purchase')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('save-purchase')));
    await tester.pump();

    expect(repository.created, isEmpty);
    expect(find.textContaining('分摊合计必须等于'), findsOneWidget);
  });

  testWidgets('disables duplicate submission while save is pending', (
    tester,
  ) async {
    repository.createCompleter = Completer<String>();
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('purchase-amount')), '500.00');
    await tester.scrollUntilVisible(
      find.byKey(const Key('target-card-card-1')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const Key('target-card-card-1')).first);
    await tester.scrollUntilVisible(
      find.byKey(const Key('save-purchase')),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.tap(find.byKey(const Key('save-purchase')));
    await tester.pump();

    final button = tester.widget<FilledButton>(
      find.byKey(const Key('save-purchase')),
    );
    expect(button.onPressed, isNull);
    expect(repository.created, hasLength(1));

    repository.createCompleter!.complete('purchase-new');
    await tester.pumpAndSettle();
  });
}
