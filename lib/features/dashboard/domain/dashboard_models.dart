import 'package:meta/meta.dart';

import '../../organization/domain/organization_models.dart';
import '../../purchases/domain/purchase_models.dart';

enum StatisticDimension { issuedYear, city, issuer, cardType, tag, setStatus }

extension StatisticDimensionLabel on StatisticDimension {
  String get label => switch (this) {
    StatisticDimension.issuedYear => '发行年份',
    StatisticDimension.city => '城市',
    StatisticDimension.issuer => '机构',
    StatisticDimension.cardType => '类型',
    StatisticDimension.tag => '标签',
    StatisticDimension.setStatus => '套卡状态',
  };
}

enum DashboardSetStatus { complete, nearlyComplete, incomplete, unknown }

extension DashboardSetStatusLabel on DashboardSetStatus {
  String get label => switch (this) {
    DashboardSetStatus.complete => '已集齐',
    DashboardSetStatus.nearlyComplete => '差 1 款',
    DashboardSetStatus.incomplete => '未集齐',
    DashboardSetStatus.unknown => '总数未知',
  };

  CardSetStatusFilter get queryFilter => switch (this) {
    DashboardSetStatus.complete => CardSetStatusFilter.complete,
    DashboardSetStatus.nearlyComplete => CardSetStatusFilter.nearlyComplete,
    DashboardSetStatus.incomplete => CardSetStatusFilter.incomplete,
    DashboardSetStatus.unknown => CardSetStatusFilter.unknown,
  };
}

@immutable
final class DashboardCard {
  const DashboardCard({
    required this.cardItemId,
    required this.definitionId,
    required this.name,
    required this.quantity,
    required this.createdAt,
    required this.needsCompletion,
    this.coverRelativePath,
  });

  final String cardItemId;
  final String definitionId;
  final String name;
  final int quantity;
  final DateTime createdAt;
  final bool needsCompletion;
  final String? coverRelativePath;
}

@immutable
final class DashboardSet {
  const DashboardSet({
    required this.id,
    required this.name,
    required this.status,
    required this.ownedRequiredCount,
    required this.requiredMemberCount,
    required this.updatedAt,
    this.coverRelativePath,
  });

  final String id;
  final String name;
  final DashboardSetStatus status;
  final int ownedRequiredCount;
  final int requiredMemberCount;
  final DateTime updatedAt;
  final String? coverRelativePath;

  int get missingRequiredCount => requiredMemberCount - ownedRequiredCount;
}

@immutable
final class HomeDashboard {
  const HomeDashboard({
    required this.entityCount,
    required this.definitionCount,
    required this.setCount,
    required this.completedSetCount,
    required this.monthAddedCount,
    required this.costTotals,
    required this.recentCards,
    required this.nearlyCompleteSets,
    required this.needsCompletionCards,
  });

  const HomeDashboard.empty()
    : entityCount = 0,
      definitionCount = 0,
      setCount = 0,
      completedSetCount = 0,
      monthAddedCount = 0,
      costTotals = const <CostTotal>[],
      recentCards = const <DashboardCard>[],
      nearlyCompleteSets = const <DashboardSet>[],
      needsCompletionCards = const <DashboardCard>[];

  final int entityCount;
  final int definitionCount;
  final int setCount;
  final int completedSetCount;
  final int monthAddedCount;
  final List<CostTotal> costTotals;
  final List<DashboardCard> recentCards;
  final List<DashboardSet> nearlyCompleteSets;
  final List<DashboardCard> needsCompletionCards;

  bool get isEmpty => entityCount == 0 && setCount == 0 && costTotals.isEmpty;
}

@immutable
final class StatisticBucket {
  const StatisticBucket._({
    required this.dimension,
    required this.key,
    required this.label,
    required this.count,
    required this.query,
  });

  factory StatisticBucket.card({
    required StatisticDimension dimension,
    required String key,
    required String label,
    required int count,
  }) {
    assert(dimension != StatisticDimension.setStatus);
    final query = switch (dimension) {
      StatisticDimension.issuedYear => CardLibraryQuery(year: int.parse(key)),
      StatisticDimension.city => CardLibraryQuery(city: key),
      StatisticDimension.issuer => CardLibraryQuery(issuer: key),
      StatisticDimension.cardType => CardLibraryQuery(cardType: key),
      StatisticDimension.tag => CardLibraryQuery(tagIds: <String>[key]),
      StatisticDimension.setStatus => throw ArgumentError.value(
        dimension,
        'dimension',
      ),
    };
    return StatisticBucket._(
      dimension: dimension,
      key: key,
      label: label,
      count: count,
      query: query,
    );
  }

  factory StatisticBucket.setStatus({
    required DashboardSetStatus status,
    required int count,
  }) {
    return StatisticBucket._(
      dimension: StatisticDimension.setStatus,
      key: status.name,
      label: status.label,
      count: count,
      query: CardLibraryQuery(setStatus: status.queryFilter),
    );
  }

  final StatisticDimension dimension;
  final String key;
  final String label;
  final int count;
  final CardLibraryQuery query;
}

@immutable
final class CostTrendPoint {
  const CostTrendPoint({
    required this.month,
    required this.currency,
    required this.minorUnits,
    required this.purchaseCount,
  });

  final DateTime month;
  final String currency;
  final int minorUnits;
  final int purchaseCount;

  String get monthLabel =>
      '${month.year.toString().padLeft(4, '0')}-'
      '${month.month.toString().padLeft(2, '0')}';
}

@immutable
final class StatisticsSnapshot {
  const StatisticsSnapshot({
    required this.distributions,
    required this.costTrend,
  });

  const StatisticsSnapshot.empty()
    : distributions = const <StatisticDimension, List<StatisticBucket>>{},
      costTrend = const <CostTrendPoint>[];

  final Map<StatisticDimension, List<StatisticBucket>> distributions;
  final List<CostTrendPoint> costTrend;

  List<StatisticBucket> bucketsFor(StatisticDimension dimension) =>
      distributions[dimension] ?? const <StatisticBucket>[];
}
