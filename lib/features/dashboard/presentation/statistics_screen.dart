import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_theme.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/app_layout.dart';
import '../../../core/widgets/app_surface.dart';
import '../../organization/data/organization_providers.dart';
import '../../purchases/domain/purchase_models.dart';
import '../data/dashboard_providers.dart';
import '../domain/dashboard_models.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  StatisticDimension _dimension = StatisticDimension.issuedYear;

  @override
  Widget build(BuildContext context) {
    final statistics = ref.watch(statisticsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('统计')),
      body: statistics.when(
        loading: () => const Center(
          child: CircularProgressIndicator(semanticsLabel: '正在生成收藏统计'),
        ),
        error: (error, stackTrace) => AppErrorState(
          icon: Icons.query_stats_outlined,
          title: '统计暂时无法读取',
          description: error is AppFailure
              ? error.userMessage
              : '收藏数据仍安全保存在本机，请稍后重试。',
          actionLabel: '重试',
          onAction: () => ref.invalidate(statisticsProvider),
        ),
        data: _buildContent,
      ),
    );
  }

  Widget _buildContent(StatisticsSnapshot data) {
    final tokens = context.tokens;
    final buckets = data.bucketsFor(_dimension);
    final maxCount = buckets.fold<int>(
      0,
      (current, bucket) => math.max(current, bucket.count),
    );
    final totalCost = _formatCny(data.totalCostMinor);

    return AppContentView(
      child: ListView(
        children: <Widget>[
          const AppPageHeader(
            eyebrow: 'COLLECTION INSIGHTS',
            title: '收藏统计',
            subtitle: '从数量分布到入手成本，回顾收藏如何慢慢生长。',
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: AppMetricCard(
                  label: '收藏总卡片数',
                  value: '${data.totalCardCount}',
                  icon: Icons.style_outlined,
                  supportingText: '按实体数量汇总',
                ),
              ),
              SizedBox(width: tokens.spaceSm),
              Expanded(
                child: AppMetricCard(
                  label: '总花费',
                  value: totalCost,
                  icon: Icons.payments_outlined,
                  supportingText: '全部时间净消费',
                  onTap: () =>
                      context.push(spendingCalendarMonthPath(DateTime.now())),
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.spaceLg),
          AppSectionHeader(
            title: '花费趋势',
            icon: Icons.timeline_rounded,
            subtitle: '按入手日期统计，未填写时使用成本记录日期。',
            action: TextButton(
              onPressed: () =>
                  context.push(spendingCalendarMonthPath(DateTime.now())),
              child: const Text('消费日历'),
            ),
          ),
          if (data.costTrend.isEmpty)
            AppSurfaceCard(
              color: context.palette.surfaceMuted,
              child: const Row(
                children: <Widget>[
                  Icon(Icons.receipt_long_outlined),
                  SizedBox(width: 12),
                  Expanded(child: Text('暂无花费记录。')),
                ],
              ),
            )
          else
            AppSurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  for (
                    var index = 0;
                    index < data.costTrend.length;
                    index++
                  ) ...[
                    _CostTrendTile(
                      point: data.costTrend[index],
                      onTap: () => context.push(
                        spendingCalendarMonthPath(data.costTrend[index].month),
                      ),
                    ),
                    if (index != data.costTrend.length - 1)
                      const Divider(indent: 72, endIndent: 16),
                  ],
                ],
              ),
            ),
          SizedBox(height: tokens.spaceLg),
          const AppSectionHeader(
            title: '数量分布',
            icon: Icons.bar_chart_rounded,
            subtitle: '切换维度后，点击条目可直接查看对应收藏。',
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                for (final dimension in StatisticDimension.values) ...[
                  ChoiceChip(
                    label: Text(dimension.label),
                    selected: dimension == _dimension,
                    avatar: dimension == _dimension
                        ? const Icon(Icons.check_rounded, size: 16)
                        : null,
                    onSelected: (_) => setState(() => _dimension = dimension),
                  ),
                  SizedBox(width: tokens.spaceSm),
                ],
              ],
            ),
          ),
          SizedBox(height: tokens.spaceMd),
          if (buckets.isEmpty)
            const AppEmptyState(
              icon: Icons.query_stats_outlined,
              title: '暂无统计数据',
              description: '先录入卡片或补充资料后，再回来查看这一维度。',
            )
          else
            AppSurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  for (var index = 0; index < buckets.length; index++) ...[
                    _BucketTile(
                      bucket: buckets[index],
                      maxCount: maxCount,
                      onTap: () => _drillDown(buckets[index]),
                    ),
                    if (index != buckets.length - 1)
                      const Divider(indent: 16, endIndent: 16),
                  ],
                ],
              ),
            ),
          SizedBox(height: tokens.space2xl),
        ],
      ),
    );
  }

  void _drillDown(StatisticBucket bucket) {
    ref.read(cardLibraryQueryProvider.notifier).replace(bucket.query);
    context.go(libraryPath);
  }
}

class _BucketTile extends StatelessWidget {
  const _BucketTile({
    required this.bucket,
    required this.maxCount,
    required this.onTap,
  });

  final StatisticBucket bucket;
  final int maxCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final progress = maxCount == 0 ? 0.0 : bucket.count / maxCount;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(tokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    bucket.label,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Text(
                  '${bucket.count}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
                SizedBox(width: tokens.spaceXs),
                const Icon(Icons.chevron_right_rounded, size: 20),
              ],
            ),
            SizedBox(height: tokens.spaceSm),
            Semantics(
              label: '${bucket.label}，${bucket.count} 张',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(tokens.radiusPill),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: context.palette.surfaceMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CostTrendTile extends StatelessWidget {
  const _CostTrendTile({required this.point, required this.onTap});

  final CostTrendPoint point;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted = CurrencyAmount(
      minorUnits: point.minorUnits,
      currency: point.currency,
    ).formatted;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: const Icon(Icons.calendar_month_outlined),
      ),
      title: Text(point.monthLabel),
      subtitle: Text('${point.purchaseCount} 笔记录'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '¥$formatted',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}

String _formatCny(int minorUnits) {
  final formatted = CurrencyAmount(
    minorUnits: minorUnits.abs(),
    currency: 'CNY',
  ).formatted;
  return minorUnits < 0 ? '-¥$formatted' : '¥$formatted';
}
