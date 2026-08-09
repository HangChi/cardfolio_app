import 'package:cardfolio_app/app/app_router.dart';
import 'package:cardfolio_app/app/cardfolio_app.dart';
import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/features/dashboard/data/dashboard_providers.dart';
import 'package:cardfolio_app/features/dashboard/domain/dashboard_models.dart';
import 'package:cardfolio_app/features/organization/data/organization_providers.dart';
import 'package:cardfolio_app/features/organization/domain/organization_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_dashboard_repository.dart';

void main() {
  testWidgets('switches dimensions, renders trends, and drills down', (
    tester,
  ) async {
    final statistics = StatisticsSnapshot(
      distributions: <StatisticDimension, List<StatisticBucket>>{
        StatisticDimension.issuedYear: <StatisticBucket>[
          StatisticBucket.card(
            dimension: StatisticDimension.issuedYear,
            key: '2026',
            label: '2026',
            count: 3,
          ),
        ],
        StatisticDimension.issuer: <StatisticBucket>[
          StatisticBucket.card(
            dimension: StatisticDimension.issuer,
            key: 'Metro',
            label: 'Metro',
            count: 2,
          ),
        ],
      },
      costTrend: <CostTrendPoint>[
        CostTrendPoint(
          month: DateTime.utc(2026, 7),
          currency: 'CNY',
          minorUnits: 1250,
          purchaseCount: 1,
        ),
      ],
    );
    final repository = FakeDashboardRepository(statistics: statistics);
    final container = ProviderContainer(
      overrides: [
        dashboardRepositoryProvider.overrideWithValue(repository),
        organizedCardListProvider.overrideWith(
          (ref) => Stream<List<OrganizedCardSummary>>.value(
            const <OrganizedCardSummary>[],
          ),
        ),
        cardFilterFacetsProvider.overrideWith(
          (ref) => Stream<CardFilterFacets>.value(
            const CardFilterFacets(
              cardTypes: <String>[],
              cities: <String>[],
              years: <int>[],
              tags: <TagSummary>[],
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: CardfolioApp(
          router: createAppRouter(initialLocation: statsPath),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -240));
    await tester.pumpAndSettle();
    expect(find.text('2026-07'), findsOneWidget);
    expect(find.text('¥12.50'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('2026'), findsOneWidget);

    await tester.tap(find.text('机构'));
    await tester.pumpAndSettle();
    expect(find.text('Metro'), findsOneWidget);

    await tester.tap(find.text('Metro'));
    await tester.pumpAndSettle();

    expect(container.read(cardLibraryQueryProvider).issuer, 'Metro');
    expect(find.text('收藏'), findsWidgets);
  });

  testWidgets('empty dimension explains how to create statistics', (
    tester,
  ) async {
    final repository = FakeDashboardRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [dashboardRepositoryProvider.overrideWithValue(repository)],
        child: CardfolioApp(
          router: createAppRouter(initialLocation: statsPath),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('暂无统计数据'), findsOneWidget);
    expect(find.text('先录入卡片或补充资料后，再回来查看这一维度。'), findsOneWidget);
  });

  testWidgets('statistics read error shows safe copy and retry action', (
    tester,
  ) async {
    final repository = FakeDashboardRepository(
      statisticsStream: () => Stream<StatisticsSnapshot>.error(
        const DatabaseUnavailableFailure('统计页暂时不可用。'),
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        retry: (retryCount, error) => null,
        overrides: [dashboardRepositoryProvider.overrideWithValue(repository)],
        child: CardfolioApp(
          router: createAppRouter(initialLocation: statsPath),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('统计页暂时不可用。'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
  });
}
