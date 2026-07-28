import 'package:cardfolio_app/app/app_router.dart';
import 'package:cardfolio_app/app/app_theme.dart';
import 'package:cardfolio_app/core/id/id_generator.dart';
import 'package:cardfolio_app/features/card_sets/data/card_set_providers.dart';
import 'package:cardfolio_app/features/card_sets/presentation/form/card_set_form_screen.dart';
import 'package:cardfolio_app/features/cards/data/card_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/fake_card_set_repository.dart';

final class _FixedIdGenerator implements IdGenerator {
  @override
  String newId() => 'set-new';
}

void main() {
  late FakeCardSetRepository repository;
  late GoRouter router;

  setUp(() {
    repository = FakeCardSetRepository();
    router = GoRouter(
      initialLocation: createCardSetPath,
      routes: <RouteBase>[
        GoRoute(
          path: createCardSetPath,
          builder: (context, state) => const CardSetFormScreen(),
        ),
        GoRoute(
          path: '/sets/:id',
          builder: (context, state) =>
              Scaffold(body: Text('已保存 ${state.pathParameters['id']}')),
        ),
      ],
    );
  });

  tearDown(() => router.dispose());

  Widget subject() {
    return ProviderScope(
      overrides: [
        cardSetRepositoryProvider.overrideWithValue(repository),
        idGeneratorProvider.overrideWithValue(_FixedIdGenerator()),
      ],
      child: MaterialApp.router(
        theme: buildCardfolioTheme(),
        routerConfig: router,
      ),
    );
  }

  testWidgets('creates a known-count set and opens its detail route', (
    tester,
  ) async {
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('set-name')), '四季套卡');
    await tester.enterText(find.byKey(const Key('set-expected-count')), '4');
    await tester.ensureVisible(find.text('创建套卡'));
    await tester.tap(find.text('创建套卡'));
    await tester.pumpAndSettle();

    expect(repository.created, hasLength(1));
    expect(repository.created.single.name, '四季套卡');
    expect(repository.created.single.expectedCount, 4);
    expect(find.text('已保存 set-new'), findsOneWidget);
  });

  testWidgets('unknown count clears the expected total', (tester) async {
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('set-name')), '交换会限定');
    await tester.tap(find.byKey(const Key('set-count-known')));
    await tester.ensureVisible(find.text('创建套卡'));
    await tester.tap(find.text('创建套卡'));
    await tester.pumpAndSettle();

    expect(repository.created.single.countKnown, isFalse);
    expect(repository.created.single.expectedCount, isNull);
  });

  testWidgets('blank name stays on the form with a stable error', (
    tester,
  ) async {
    await tester.pumpWidget(subject());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('创建套卡'));
    await tester.tap(find.text('创建套卡'));
    await tester.pump();

    expect(repository.created, isEmpty);
    expect(find.text('套卡名称不能为空。'), findsOneWidget);
  });
}
