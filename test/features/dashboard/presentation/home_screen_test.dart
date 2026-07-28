import 'dart:async';

import 'package:cardfolio_app/core/errors/app_failure.dart';
import 'package:cardfolio_app/features/dashboard/data/dashboard_providers.dart';
import 'package:cardfolio_app/features/dashboard/domain/dashboard_models.dart';
import 'package:cardfolio_app/features/dashboard/presentation/home_screen.dart';
import 'package:cardfolio_app/features/purchases/domain/purchase_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_dashboard_repository.dart';

void main() {
  Widget app(FakeDashboardRepository repository) {
    return ProviderScope(
      retry: (retryCount, error) => null,
      overrides: [dashboardRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  testWidgets('renders summary, separated currencies, and action lists', (
    tester,
  ) async {
    final repository = FakeDashboardRepository(
      home: HomeDashboard(
        entityCount: 3,
        definitionCount: 2,
        setCount: 1,
        completedSetCount: 1,
        monthAddedCount: 2,
        costTotals: const <CostTotal>[
          CostTotal(currency: 'CNY', minorUnits: 1250, purchaseCount: 1),
          CostTotal(currency: 'JPY', minorUnits: 300, purchaseCount: 1),
        ],
        recentCards: <DashboardCard>[
          DashboardCard(
            cardItemId: 'item-1',
            definitionId: 'definition-1',
            name: '樱花纪念卡',
            quantity: 2,
            createdAt: DateTime.utc(2026, 7, 28),
            needsCompletion: false,
          ),
        ],
        nearlyCompleteSets: <DashboardSet>[
          DashboardSet(
            id: 'set-1',
            name: '四季套卡',
            status: DashboardSetStatus.nearlyComplete,
            ownedRequiredCount: 3,
            requiredMemberCount: 4,
            updatedAt: DateTime.utc(2026, 7, 28),
          ),
        ],
        needsCompletionCards: <DashboardCard>[
          DashboardCard(
            cardItemId: 'item-2',
            definitionId: 'definition-2',
            name: '资料待考证卡',
            quantity: 1,
            createdAt: DateTime.utc(2026, 7, 27),
            needsCompletion: true,
          ),
        ],
      ),
    );

    await tester.pumpWidget(app(repository));
    await tester.pumpAndSettle();

    expect(find.text('收藏概览'), findsOneWidget);
    expect(find.text('实体卡'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('CNY 12.50'), findsOneWidget);
    expect(find.text('JPY 300'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -360));
    await tester.pumpAndSettle();
    expect(find.text('樱花纪念卡'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -260));
    await tester.pumpAndSettle();
    expect(find.text('四季套卡'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -260));
    await tester.pumpAndSettle();
    expect(find.text('资料待考证卡'), findsOneWidget);
  });

  testWidgets('empty home gives an action to add the first card', (
    tester,
  ) async {
    await tester.pumpWidget(app(FakeDashboardRepository()));
    await tester.pumpAndSettle();

    expect(find.text('还没有收藏'), findsOneWidget);
    expect(find.text('添加第一张卡片'), findsOneWidget);
  });

  testWidgets('shows progress while the first dashboard value is pending', (
    tester,
  ) async {
    final controller = StreamController<HomeDashboard>();
    addTearDown(controller.close);
    final repository = FakeDashboardRepository(
      homeStream: () => controller.stream,
    );

    await tester.pumpWidget(app(repository));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('read error exposes safe copy and retries the provider', (
    tester,
  ) async {
    var attempt = 0;
    final repository = FakeDashboardRepository(
      homeStream: () {
        attempt++;
        if (attempt == 1) {
          return Stream<HomeDashboard>.error(
            const DatabaseUnavailableFailure('统计读取失败，请重试。'),
          );
        }
        return Stream<HomeDashboard>.value(const HomeDashboard.empty());
      },
    );

    await tester.pumpWidget(app(repository));
    await tester.pumpAndSettle();

    expect(find.text('统计读取失败，请重试。'), findsOneWidget);
    await tester.tap(find.text('重试'));
    await tester.pumpAndSettle();

    expect(repository.homeWatchCount, 2);
    expect(find.text('还没有收藏'), findsOneWidget);
  });
}
