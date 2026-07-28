import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../core/errors/app_failure.dart';
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _StatisticsError(
          message: error is AppFailure ? error.userMessage : '首页与统计暂时无法读取，请重试。',
          onRetry: () => ref.invalidate(statisticsProvider),
        ),
        data: _buildContent,
      ),
    );
  }

  Widget _buildContent(StatisticsSnapshot data) {
    final buckets = data.bucketsFor(_dimension);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text('数量分布', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final dimension in StatisticDimension.values)
              ChoiceChip(
                label: Text(dimension.label),
                selected: dimension == _dimension,
                onSelected: (_) => setState(() => _dimension = dimension),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (buckets.isEmpty)
          const _EmptyStatistics()
        else
          Card(
            child: Column(
              children: <Widget>[
                for (var index = 0; index < buckets.length; index++) ...[
                  _BucketTile(
                    bucket: buckets[index],
                    onTap: () => _drillDown(buckets[index]),
                  ),
                  if (index != buckets.length - 1) const Divider(height: 1),
                ],
              ],
            ),
          ),
        const SizedBox(height: 24),
        Text('花费趋势', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (data.costTrend.isEmpty)
          const Text('暂无花费记录。')
        else
          Card(
            child: Column(
              children: <Widget>[
                for (final point in data.costTrend)
                  ListTile(
                    leading: const Icon(Icons.calendar_month_outlined),
                    title: Text(
                      '${point.monthLabel} · ${point.currency} '
                      '${CurrencyAmount(minorUnits: point.minorUnits, currency: point.currency).formatted}',
                    ),
                    subtitle: Text('${point.purchaseCount} 笔记录'),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  void _drillDown(StatisticBucket bucket) {
    ref.read(cardLibraryQueryProvider.notifier).replace(bucket.query);
    context.go(libraryPath);
  }
}

class _BucketTile extends StatelessWidget {
  const _BucketTile({required this.bucket, required this.onTap});

  final StatisticBucket bucket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(bucket.label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('${bucket.count}'),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _EmptyStatistics extends StatelessWidget {
  const _EmptyStatistics();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            const Icon(Icons.query_stats_outlined, size: 40),
            const SizedBox(height: 8),
            Text('暂无统计数据', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            const Text('先录入卡片或补充资料后再查看。'),
          ],
        ),
      ),
    );
  }
}

class _StatisticsError extends StatelessWidget {
  const _StatisticsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}
