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
            color: AppColors.primary.withValues(alpha: 0.08),
            child: const ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('集卡册用于收纳卡片和套卡，不计算完成度。'),
            ),
          ),
          SizedBox(height: context.tokens.spaceLg),
          _MemberSection(
            title: '卡片 · ${series.cards.length}',
            items: series.cards,
            isCard: true,
          ),
          SizedBox(height: context.tokens.spaceLg),
          _MemberSection(
            title: '套卡 · ${series.sets.length}',
            items: series.sets,
            isCard: false,
          ),
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
          for (final item in items)
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
      ],
    );
  }
}
