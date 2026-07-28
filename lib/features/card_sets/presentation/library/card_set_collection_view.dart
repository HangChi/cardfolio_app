import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../app/app_theme.dart';
import '../../../cards/presentation/widgets/card_image.dart';
import '../../data/card_set_providers.dart';
import '../../domain/card_set_models.dart';

class CardSetCollectionView extends ConsumerWidget {
  const CardSetCollectionView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sets = ref.watch(cardSetListProvider);
    return sets.when(
      loading: () => const Center(
        child: CircularProgressIndicator(semanticsLabel: '正在加载套卡'),
      ),
      error: (error, stackTrace) =>
          _SetListError(onRetry: () => ref.invalidate(cardSetListProvider)),
      data: (items) =>
          items.isEmpty ? const _EmptySets() : _SetList(items: items),
    );
  }
}

class _EmptySets extends StatelessWidget {
  const _EmptySets();

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.view_carousel_outlined,
              size: 52,
              color: AppColors.primary,
            ),
            SizedBox(height: tokens.spaceMd),
            Text('还没有套卡', style: Theme.of(context).textTheme.titleLarge),
            SizedBox(height: tokens.spaceSm),
            const Text(
              '把同一主题的卡片整理成成员清单，缺哪张会一目了然。',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: tokens.spaceLg),
            FilledButton.icon(
              onPressed: () => context.push(createCardSetPath),
              icon: const Icon(Icons.add),
              label: const Text('新建套卡'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetList extends StatelessWidget {
  const _SetList({required this.items});

  final List<CardSetSummary> items;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        tokens.spaceLg,
        0,
        tokens.spaceLg,
        tokens.spaceLg,
      ),
      itemCount: items.length + 1,
      separatorBuilder: (context, index) => SizedBox(height: tokens.spaceMd),
      itemBuilder: (context, index) {
        if (index == 0) {
          return OutlinedButton.icon(
            onPressed: () => context.push(createCardSetPath),
            icon: const Icon(Icons.add),
            label: const Text('新建套卡'),
          );
        }
        return _SetTile(set: items[index - 1]);
      },
    );
  }
}

class _SetTile extends StatelessWidget {
  const _SetTile({required this.set});

  final CardSetSummary set;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final progress = set.progress;
    final status = set.countKnown
        ? '${progress.ownedRequiredCount} / ${progress.requiredMemberCount}'
              ' · 缺 ${progress.missingRequiredCount}'
              ' · 重复 ${progress.duplicateMemberCount}'
        : '已拥有 ${progress.ownedMemberCount} 款 · 总数未知';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        onTap: () => context.push(cardSetDetailPath(set.id)),
        child: Padding(
          padding: EdgeInsets.all(tokens.spaceMd),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 88,
                height: 64,
                child: set.coverRelativePath == null
                    ? CardImage.placeholder(semanticLabel: '${set.name}套卡封面')
                    : CardImage.managed(
                        relativePath: set.coverRelativePath!,
                        semanticLabel: '${set.name}套卡封面',
                      ),
              ),
              SizedBox(width: tokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      set.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: tokens.spaceSm),
                    Text(status, style: Theme.of(context).textTheme.bodySmall),
                    if (progress.fraction case final fraction?) ...<Widget>[
                      SizedBox(height: tokens.spaceSm),
                      LinearProgressIndicator(
                        value: fraction,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(tokens.radiusPill),
                        semanticsLabel: '${set.name}完成度',
                        semanticsValue: '${(fraction * 100).round()}%',
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetListError extends StatelessWidget {
  const _SetListError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.error_outline, color: AppColors.error, size: 40),
            SizedBox(height: context.tokens.spaceMd),
            const Text('套卡暂时无法加载'),
            SizedBox(height: context.tokens.spaceMd),
            FilledButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}
