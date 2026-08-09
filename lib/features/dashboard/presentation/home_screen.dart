import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_theme.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/app_layout.dart';
import '../../../core/widgets/app_surface.dart';
import '../../cards/data/card_providers.dart';
import '../../cards/presentation/widgets/card_image.dart';
import '../../organization/data/organization_providers.dart';
import '../../organization/domain/organization_models.dart';
import '../../purchases/domain/purchase_models.dart';
import '../data/dashboard_providers.dart';
import '../domain/dashboard_models.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(homeDashboardProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('首页')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('home-create-card'),
        tooltip: '录入卡片',
        onPressed: () => context.push(createCardPath),
        icon: const Icon(Icons.add_rounded),
        label: const Text('录入卡片'),
      ),
      body: dashboard.when(
        loading: () => const Center(
          child: CircularProgressIndicator(semanticsLabel: '正在加载收藏概览'),
        ),
        error: (error, stackTrace) => AppErrorState(
          icon: Icons.cloud_off_outlined,
          title: '收藏概览暂时无法加载',
          description: error is AppFailure
              ? error.userMessage
              : '本地数据没有发生变化，请稍后重试。',
          actionLabel: '重试',
          onAction: () => ref.invalidate(homeDashboardProvider),
        ),
        data: (data) => data.isEmpty
            ? AppEmptyState(
                icon: Icons.style_outlined,
                title: '让第一张收藏留下轨迹',
                description: '添加卡片后，这里会显示收藏概览、最近录入和待办提醒。',
                actionLabel: '添加第一张卡片',
                onAction: () => context.push(createCardPath),
              )
            : _HomeContent(data: data),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.data});

  final HomeDashboard data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final totalCostMinor = data.costTotals.fold<int>(
      0,
      (total, cost) => total + cost.minorUnits,
    );
    final totalPurchaseCount = data.costTotals.fold<int>(
      0,
      (total, cost) => total + cost.purchaseCount,
    );
    return AppContentView(
      child: ListView(
        children: <Widget>[
          AppPageHeader(
            eyebrow: 'LOCAL COLLECTION',
            title: '你好，收藏家',
            subtitle: '所有卡片与图片都安全保存在本机。',
            action: AppStatusBadge(
              label: '本地收藏库',
              icon: Icons.offline_bolt_outlined,
              color: context.palette.success,
            ),
          ),
          _CollectionHero(data: data),
          SizedBox(height: tokens.spaceLg),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 760 ? 4 : 2;
              final spacing = tokens.spaceSm;
              final width =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: <Widget>[
                  SizedBox(
                    width: width,
                    child: AppMetricCard(
                      label: '卡片',
                      value: '${data.entityCount}',
                      icon: Icons.credit_card_outlined,
                      onTap: () => context.go(libraryTabPath('cards')),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: AppMetricCard(
                      label: '套卡',
                      value: '${data.setCount}',
                      icon: Icons.view_carousel_outlined,
                      onTap: () => context.go(libraryTabPath('sets')),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: AppMetricCard(
                      label: '集卡册',
                      value: '${data.seriesCount}',
                      icon: Icons.collections_bookmark_outlined,
                      onTap: () => context.go(libraryTabPath('series')),
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: AppMetricCard(
                      label: '本月新增',
                      value: '${data.monthAddedCount}',
                      icon: Icons.calendar_month_outlined,
                      onTap: () {
                        final now = ref.read(clockProvider).nowUtc().toLocal();
                        final fromUtc = DateTime.utc(now.year, now.month);
                        final beforeUtc = DateTime.utc(now.year, now.month + 1);
                        ref
                            .read(cardLibraryQueryProvider.notifier)
                            .replace(
                              CardLibraryQuery(
                                acquiredFromUtc: fromUtc,
                                acquiredBeforeUtc: beforeUtc,
                                sortField: CardSortField.acquiredAt,
                                sortDirection: SortDirection.descending,
                              ),
                            );
                        context.go(libraryTabPath('cards'));
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: tokens.spaceLg),
          AppSectionHeader(
            title: '累计消费',
            icon: Icons.payments_outlined,
            subtitle: '全部活跃收藏的人民币净消费。',
            action: TextButton(
              onPressed: () => _openCurrentSpendingMonth(context, ref),
              child: const Text('消费日历'),
            ),
          ),
          if (data.costTotals.isEmpty)
            const _EmptySection(message: '还没有记录入手成本。')
          else
            AppSurfaceCard(
              padding: EdgeInsets.zero,
              onTap: () => _openCurrentSpendingMonth(context, ref),
              semanticLabel: '累计消费，${_formatCny(totalCostMinor)}',
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: Text(
                  _formatCny(totalCostMinor),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                subtitle: Text('$totalPurchaseCount 笔成本记录 · 已扣除退款'),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
            ),
          SizedBox(height: tokens.spaceLg),
          const AppSectionHeader(
            title: '最近录入',
            icon: Icons.history_rounded,
            subtitle: '继续补充刚加入收藏库的卡片。',
          ),
          if (data.recentCards.isEmpty)
            const _EmptySection(message: '还没有最近录入。')
          else
            AppSurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  for (
                    var index = 0;
                    index < data.recentCards.length;
                    index++
                  ) ...[
                    _RecentCardTile(card: data.recentCards[index]),
                    if (index != data.recentCards.length - 1)
                      const Divider(indent: 96, endIndent: 16),
                  ],
                ],
              ),
            ),
          SizedBox(height: tokens.spaceLg),
          const AppSectionHeader(
            title: '即将集齐',
            icon: Icons.flag_outlined,
            subtitle: '距离完整收藏只差最后一步。',
          ),
          if (data.nearlyCompleteSets.isEmpty)
            const _EmptySection(message: '暂时没有只差 1 款的套卡。')
          else
            AppSurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  for (final set in data.nearlyCompleteSets)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        child: const Icon(Icons.collections_bookmark_outlined),
                      ),
                      title: Text(set.name),
                      subtitle: Text(
                        '${set.ownedRequiredCount}/${set.requiredMemberCount} 款',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push(cardSetDetailPath(set.id)),
                    ),
                ],
              ),
            ),
          SizedBox(height: tokens.spaceLg),
          const AppSectionHeader(
            title: '待补资料',
            icon: Icons.edit_note_outlined,
            subtitle: '补全信息，让收藏更容易查找和回顾。',
          ),
          if (data.needsCompletionCards.isEmpty)
            const _EmptySection(message: '卡片资料都已补全。')
          else
            AppSurfaceCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  for (final card in data.needsCompletionCards)
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: context.palette.warning.withValues(
                          alpha: 0.14,
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: context.palette.warning,
                        ),
                      ),
                      title: Text(card.name),
                      subtitle: const Text('标记为待补资料'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () =>
                          context.push(cardDetailPath(card.cardItemId)),
                    ),
                ],
              ),
            ),
          SizedBox(height: tokens.space2xl),
        ],
      ),
    );
  }

  void _openCurrentSpendingMonth(BuildContext context, WidgetRef ref) {
    final now = ref.read(clockProvider).nowUtc().toLocal();
    context.push(spendingCalendarMonthPath(DateTime(now.year, now.month)));
  }
}

class _CollectionHero extends StatelessWidget {
  const _CollectionHero({required this.data});

  final HomeDashboard data;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(tokens.spaceLg),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: context.palette.shadow,
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '收藏总览',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: scheme.onPrimary.withValues(alpha: 0.82),
                  ),
                ),
                SizedBox(height: tokens.spaceSm),
                Text(
                  '${data.entityCount}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: scheme.onPrimary,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
                SizedBox(height: tokens.spaceXs),
                Text(
                  '张实体卡 · ${data.setCount} 套收藏',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimary.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: scheme.onPrimary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.style_rounded,
              color: scheme.onPrimary,
              size: tokens.iconLg,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentCardTile extends StatelessWidget {
  const _RecentCardTile({required this.card});

  final DashboardCard card;

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push(cardDetailPath(card.cardItemId)),
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

class _EmptySection extends StatelessWidget {
  const _EmptySection({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      color: context.palette.surfaceMuted,
      child: Row(
        children: <Widget>[
          Icon(Icons.inbox_outlined, color: context.palette.textSecondary),
          SizedBox(width: context.tokens.spaceSm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
