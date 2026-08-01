import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../app/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../cards/presentation/widgets/card_image.dart';
import '../../data/organization_providers.dart';
import '../../domain/organization_models.dart';

class SeriesDetailScreen extends ConsumerWidget {
  const SeriesDetailScreen({required this.seriesId, super.key});

  final String seriesId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(seriesDetailProvider(seriesId));
    return detail.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('集卡册')),
        body: Center(
          child: TextButton(
            onPressed: () => ref.invalidate(seriesDetailProvider(seriesId)),
            child: const Text('加载失败，点击重试'),
          ),
        ),
      ),
      data: (series) => series == null
          ? Scaffold(
              appBar: AppBar(title: const Text('集卡册')),
              body: const Center(child: Text('这个集卡册不存在或已被删除')),
            )
          : _SeriesDetailBody(series: series),
    );
  }
}

class _SeriesDetailBody extends ConsumerWidget {
  const _SeriesDetailBody({required this.series});

  final SeriesDetail series;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nestedDefinitionIds = <String>{
      for (final group in series.setGroups)
        for (final card in group.cards) card.id,
    };
    final ungroupedCards = series.cards
        .where((card) => !nestedDefinitionIds.contains(card.id))
        .toList(growable: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(series.name),
        actions: <Widget>[
          IconButton(
            tooltip: '编辑集卡册',
            onPressed: () => context.push(editSeriesPath(series.id)),
            icon: const Icon(Icons.edit_outlined),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') _delete(context, ref);
            },
            itemBuilder: (context) => const <PopupMenuEntry<String>>[
              PopupMenuItem(value: 'delete', child: Text('删除集卡册')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          context.tokens.spaceLg,
          context.tokens.spaceMd,
          context.tokens.spaceLg,
          context.tokens.spaceXl,
        ),
        children: <Widget>[
          SizedBox(
            height: 200,
            child: series.coverRelativePath == null
                ? CardImage.placeholder(semanticLabel: '${series.name}集卡册封面')
                : CardImage.managed(
                    relativePath: series.coverRelativePath!,
                    semanticLabel: '${series.name}集卡册封面',
                  ),
          ),
          SizedBox(height: context.tokens.spaceMd),
          if (series.description != null) ...<Widget>[
            Text(
              series.description!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: context.tokens.spaceMd),
          ],
          Card(
            color: Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.72),
            child: const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('集卡册用于收纳卡片和套卡，不计算完成度。'),
            ),
          ),
          SizedBox(height: context.tokens.spaceLg),
          Text('目录', style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: context.tokens.spaceSm),
          if (series.setGroups.isEmpty && ungroupedCards.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('这个集卡册还没有收录内容。'),
              ),
            )
          else ...<Widget>[
            for (
              var index = 0;
              index < series.setGroups.length;
              index++
            ) ...<Widget>[
              _SetDirectory(group: series.setGroups[index]),
              if (index < series.setGroups.length - 1)
                SizedBox(height: context.tokens.spaceSm),
            ],
            if (ungroupedCards.isNotEmpty) ...<Widget>[
              SizedBox(height: context.tokens.spaceSm),
              _MemberSection(
                title: '其他卡片 · ${ungroupedCards.length}',
                items: ungroupedCards,
                isCard: true,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('删除“${series.name}”？'),
        content: const Text('只会删除集卡册归类，不会删除卡片或套卡。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除集卡册'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(organizationRepositoryProvider).deleteSeries(series.id);
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } on AppFailure catch (failure) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.userMessage)));
      }
    }
  }
}

class _SetDirectory extends StatelessWidget {
  const _SetDirectory({required this.group});

  final SeriesSetGroup group;

  @override
  Widget build(BuildContext context) {
    final set = group.set;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: SizedBox(
          width: 64,
          height: 44,
          child: set.coverRelativePath == null
              ? CardImage.placeholder(semanticLabel: '${set.name}套卡封面')
              : CardImage.managed(
                  relativePath: set.coverRelativePath!,
                  semanticLabel: '${set.name}套卡封面',
                ),
        ),
        title: Text(set.name),
        subtitle: Text('${group.cards.length} 张已拥有卡片'),
        childrenPadding: EdgeInsets.fromLTRB(
          context.tokens.spaceMd,
          0,
          context.tokens.spaceMd,
          context.tokens.spaceMd,
        ),
        children: <Widget>[
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => context.push(cardSetDetailPath(set.id)),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('查看套卡'),
            ),
          ),
          if (group.cards.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('这个套卡暂无已拥有成员'),
              ),
            )
          else
            for (final card in group.cards) _NestedCardTile(card: card),
        ],
      ),
    );
  }
}

class _NestedCardTile extends StatelessWidget {
  const _NestedCardTile({required this.card});

  final SeriesMemberSummary card;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: card.cardItemId == null
          ? null
          : () => context.push(cardDetailPath(card.cardItemId!)),
      leading: SizedBox(
        width: 56,
        height: 40,
        child: card.coverRelativePath == null
            ? CardImage.placeholder(semanticLabel: '${card.name}卡片封面')
            : CardImage.managed(
                relativePath: card.coverRelativePath!,
                semanticLabel: '${card.name}卡片封面',
              ),
      ),
      title: Text(card.name),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

class _MemberSection extends StatelessWidget {
  const _MemberSection({
    required this.title,
    required this.items,
    required this.isCard,
  });

  final String title;
  final List<SeriesMemberSummary> items;
  final bool isCard;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: context.tokens.spaceSm),
        if (items.isEmpty)
          const Text('暂无成员')
        else
          for (var index = 0; index < items.length; index++) ...<Widget>[
            Card(
              child: ListTile(
                onTap: isCard
                    ? item.cardItemId == null
                          ? null
                          : () => context.push(cardDetailPath(item.cardItemId!))
                    : () => context.push(cardSetDetailPath(item.id)),
                leading: SizedBox(
                  width: 72,
                  height: 52,
                  child: item.coverRelativePath == null
                      ? CardImage.placeholder(semanticLabel: '${item.name}预览图')
                      : CardImage.managed(
                          relativePath: item.coverRelativePath!,
                          semanticLabel: '${item.name}预览图',
                        ),
                ),
                title: Text(item.name),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
            if (index < items.length - 1)
              SizedBox(height: context.tokens.spaceSm),
          ],
      ],
    );
  }
}
