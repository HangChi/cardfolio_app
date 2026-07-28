import 'package:cardfolio_app/features/dashboard/domain/dashboard_models.dart';
import 'package:cardfolio_app/features/organization/domain/organization_models.dart';
import 'package:cardfolio_app/features/purchases/domain/purchase_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('statistics dimensions expose stable Chinese labels', () {
    expect(
      StatisticDimension.values.map((dimension) => dimension.label),
      <String>['发行年份', '城市', '机构', '类型', '标签', '套卡状态'],
    );
  });

  test('card distribution buckets create literal shared queries', () {
    final year = StatisticBucket.card(
      dimension: StatisticDimension.issuedYear,
      key: '2026',
      label: '2026',
      count: 3,
    );
    final issuer = StatisticBucket.card(
      dimension: StatisticDimension.issuer,
      key: 'Metro',
      label: 'Metro',
      count: 2,
    );
    final tag = StatisticBucket.card(
      dimension: StatisticDimension.tag,
      key: 'tag-1',
      label: '限定',
      count: 4,
    );

    expect(year.query.year, 2026);
    expect(issuer.query.issuer, 'Metro');
    expect(tag.query.tagIds, <String>['tag-1']);
  });

  test('set status buckets use the matching shared status filter', () {
    for (final (status, filter, label)
        in <(DashboardSetStatus, CardSetStatusFilter, String)>[
          (DashboardSetStatus.complete, CardSetStatusFilter.complete, '已集齐'),
          (
            DashboardSetStatus.nearlyComplete,
            CardSetStatusFilter.nearlyComplete,
            '差 1 款',
          ),
          (
            DashboardSetStatus.incomplete,
            CardSetStatusFilter.incomplete,
            '未集齐',
          ),
          (DashboardSetStatus.unknown, CardSetStatusFilter.unknown, '总数未知'),
        ]) {
      final bucket = StatisticBucket.setStatus(status: status, count: 1);
      expect(bucket.label, label);
      expect(bucket.query.setStatus, filter);
    }
  });

  test('cost trend month label is zero padded', () {
    final point = CostTrendPoint(
      month: DateTime.utc(2026, 7),
      currency: 'CNY',
      minorUnits: 1234,
      purchaseCount: 2,
    );

    expect(point.monthLabel, '2026-07');
  });

  test(
    'purchase history keeps the home content visible without active cards',
    () {
      const dashboard = HomeDashboard(
        entityCount: 0,
        definitionCount: 0,
        setCount: 0,
        completedSetCount: 0,
        monthAddedCount: 0,
        costTotals: <CostTotal>[
          CostTotal(currency: 'CNY', minorUnits: 100, purchaseCount: 1),
        ],
        recentCards: <DashboardCard>[],
        nearlyCompleteSets: <DashboardSet>[],
        needsCompletionCards: <DashboardCard>[],
      );

      expect(dashboard.isEmpty, isFalse);
    },
  );
}
