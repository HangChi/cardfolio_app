import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../app/app_theme.dart';
import '../../../cards/presentation/widgets/card_image.dart';
import '../../data/organization_providers.dart';
import '../../domain/organization_models.dart';

class SeriesCollectionView extends ConsumerWidget {
  const SeriesCollectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final series = ref.watch(organizationSeriesProvider);
    return series.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _SeriesError(
        onRetry: () => ref.invalidate(organizationSeriesProvider),
      ),
      data: (items) => items.isEmpty
          ? const _EmptySeries()
          : ListView.separated(
              padding: EdgeInsets.fromLTRB(
                context.tokens.spaceLg,
                context.tokens.spaceMd,
                context.tokens.spaceLg,
                context.tokens.spaceXl,
              ),
              itemCount: items.length + 1,
              separatorBuilder: (context, index) =>
                  SizedBox(height: context.tokens.spaceSm),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return OutlinedButton.icon(
                    onPressed: () => context.push(createSeriesPath),
                    icon: const Icon(Icons.add),
                    label: const Text('新建集卡册'),
                  );
                }
                return _SeriesTile(series: items[index - 1]);
              },
            ),
    );
  }
}

class _SeriesTile extends StatelessWidget {
  const _SeriesTile({required this.series});

  final SeriesSummary series;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => context.push(seriesDetailPath(series.id)),
        leading: SizedBox(
          width: 64,
          height: 44,
          child: series.coverRelativePath == null
              ? CardImage.placeholder(semanticLabel: '${series.name}集卡册封面')
              : CardImage.managed(
                  relativePath: series.coverRelativePath!,
                  semanticLabel: '${series.name}集卡册封面',
                ),
        ),
        title: Text(series.name),
        subtitle: Text('${series.cardCount} 款卡片 · ${series.setCount} 套卡'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _EmptySeries extends StatelessWidget {
  const _EmptySeries();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.collections_bookmark_outlined,
              size: 52,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: context.tokens.spaceMd),
            Text('还没有集卡册', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: context.tokens.spaceXs),
            const Text('集卡册可以同时收纳卡片和套卡，但不计算完成度。'),
            SizedBox(height: context.tokens.spaceLg),
            FilledButton.icon(
              onPressed: () => context.push(createSeriesPath),
              icon: const Icon(Icons.add),
              label: const Text('新建集卡册'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeriesError extends StatelessWidget {
  const _SeriesError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('集卡册暂时无法加载'),
          TextButton(onPressed: onRetry, child: const Text('重试')),
        ],
      ),
    );
  }
}
