import 'package:cardfolio_app/features/card_sets/data/card_set_providers.dart';
import 'package:cardfolio_app/features/card_sets/domain/card_set_models.dart';
import 'package:cardfolio_app/features/card_sets/presentation/library/card_set_collection_view.dart';
import 'package:cardfolio_app/app/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_card_set_repository.dart';

void main() {
  Widget subject(FakeCardSetRepository repository) {
    return ProviderScope(
      overrides: [cardSetRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: buildCardfolioTheme(),
        home: const Scaffold(body: CardSetCollectionView()),
      ),
    );
  }

  testWidgets('empty state directs the user to create a set', (tester) async {
    await tester.pumpWidget(subject(FakeCardSetRepository()));
    await tester.pumpAndSettle();

    expect(find.text('还没有套卡'), findsOneWidget);
    expect(find.text('新建套卡'), findsOneWidget);
  });

  testWidgets('renders known and unknown progress without color-only status', (
    tester,
  ) async {
    final now = DateTime.utc(2026, 7, 28);
    final repository = FakeCardSetRepository(
      sets: <CardSetSummary>[
        CardSetSummary(
          id: 'known',
          name: '四季套卡',
          countKnown: true,
          expectedCount: 4,
          createdAt: now,
          updatedAt: now,
          progress: const CardSetProgress(
            ownedMemberCount: 3,
            ownedRequiredCount: 3,
            requiredMemberCount: 4,
            missingRequiredCount: 1,
            duplicateMemberCount: 1,
            fraction: 0.75,
            isComplete: false,
          ),
        ),
        CardSetSummary(
          id: 'unknown',
          name: '交换会限定',
          countKnown: false,
          createdAt: now,
          updatedAt: now,
          progress: const CardSetProgress(
            ownedMemberCount: 2,
            ownedRequiredCount: 2,
            requiredMemberCount: 2,
            missingRequiredCount: 0,
            duplicateMemberCount: 0,
            fraction: null,
            isComplete: null,
          ),
        ),
      ],
    );

    await tester.pumpWidget(subject(repository));
    await tester.pumpAndSettle();

    expect(find.text('四季套卡'), findsOneWidget);
    expect(find.textContaining('3 / 4'), findsOneWidget);
    expect(find.textContaining('缺 1'), findsOneWidget);
    expect(find.textContaining('重复 1'), findsOneWidget);
    expect(find.text('交换会限定'), findsOneWidget);
    expect(find.textContaining('总数未知'), findsOneWidget);
  });
}
