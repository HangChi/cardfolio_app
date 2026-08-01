import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../core/errors/app_failure.dart';
import '../../purchases/domain/purchase_models.dart';
import '../../cards/presentation/widgets/card_image.dart';
import '../data/dashboard_providers.dart';
import '../domain/dashboard_models.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(homeDashboardProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      floatingActionButton: FloatingActionButton.small(
        key: const Key('home-create-card'),
        tooltip: '录入卡片',
        shape: const CircleBorder(),
        onPressed: () => context.push(createCardPath),
        child: const Icon(Icons.add),
      ),
      body: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _DashboardError(
          message: error is AppFailure ? error.userMessage : '首页与统计暂时无法读取，请重试。',
          onRetry: () => ref.invalidate(homeDashboardProvider),
        ),
        data: (data) =>
            data.isEmpty ? const _EmptyHome() : _HomeContent(data: data),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.data});

  final HomeDashboard data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text('我的收藏', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 640 ? 4 : 2;
            return GridView.count(
              crossAxisCount: columns,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.8,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: <Widget>[
                _MetricCard(
                  label: '卡片',
                  value: '${data.entityCount}',
                  icon: Icons.credit_card_outlined,
                  onTap: () => context.go(libraryTabPath('cards')),
                ),
                _MetricCard(
                  label: '套卡',
                  value: '${data.setCount}',
                  icon: Icons.view_carousel_outlined,
                  onTap: () => context.go(libraryTabPath('sets')),
                ),
                _MetricCard(
                  label: '集卡册',
                  value: '${data.seriesCount}',
                  icon: Icons.collections_bookmark_outlined,
                  onTap: () => context.go(libraryTabPath('series')),
                ),
                _MetricCard(
                  label: '本月新增',
                  value: '${data.monthAddedCount}',
                  icon: Icons.calendar_month_outlined,
                  onTap: () => context.go(libraryTabPath('cards')),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        _SectionTitle(title: '累计花费', icon: Icons.payments_outlined),
        if (data.costTotals.isEmpty)
          const _EmptySection(message: '还没有记录入手成本。')
        else
          Card(
            child: Column(
              children: <Widget>[
                for (final total in data.costTotals)
                  ListTile(
                    title: Text(
                      total.currency == 'CNY'
                          ? '¥${CurrencyAmount(minorUnits: total.minorUnits, currency: total.currency).formatted}'
                          : '${total.currency} '
                                '${CurrencyAmount(minorUnits: total.minorUnits, currency: total.currency).formatted}',
                    ),
                    subtitle: Text('${total.purchaseCount} 笔成本记录'),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 24),
        _SectionTitle(title: '最近录入', icon: Icons.history),
        if (data.recentCards.isEmpty)
          const _EmptySection(message: '还没有最近录入。')
        else
          for (final card in data.recentCards)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: SizedBox(
                width: 64,
                height: 44,
                child: card.coverRelativePath == null
                    ? CardImage.placeholder(semanticLabel: '${card.name}封面')
                    : CardImage.managed(
                        relativePath: card.coverRelativePath!,
                        semanticLabel: '${card.name}封面',
                      ),
              ),
              title: Text(card.name),
              subtitle: Text('数量 ${card.quantity}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(cardDetailPath(card.cardItemId)),
            ),
        const SizedBox(height: 16),
        _SectionTitle(title: '即将集齐', icon: Icons.flag_outlined),
        if (data.nearlyCompleteSets.isEmpty)
          const _EmptySection(message: '暂时没有只差 1 款的套卡。')
        else
          for (final set in data.nearlyCompleteSets)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                child: Icon(Icons.collections_bookmark_outlined),
              ),
              title: Text(set.name),
              subtitle: Text(
                '${set.ownedRequiredCount}/${set.requiredMemberCount} 款',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(cardSetDetailPath(set.id)),
            ),
        const SizedBox(height: 16),
        _SectionTitle(title: '待补资料', icon: Icons.edit_note_outlined),
        if (data.needsCompletionCards.isEmpty)
          const _EmptySection(message: '卡片资料都已补全。')
        else
          for (final card in data.needsCompletionCards)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(child: Icon(Icons.info_outline)),
              title: Text(card.name),
              subtitle: const Text('标记为待补资料'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(cardDetailPath(card.cardItemId)),
            ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(label, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: <Widget>[
          Icon(icon),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.credit_card_off_outlined, size: 56),
            const SizedBox(height: 16),
            Text('还没有收藏', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('添加第一张卡片后，这里会展示收藏概览与待办。'),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => context.push(createCardPath),
              icon: const Icon(Icons.add),
              label: const Text('添加第一张卡片'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});

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
