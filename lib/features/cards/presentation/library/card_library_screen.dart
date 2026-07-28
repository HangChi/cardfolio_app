import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../app/app_theme.dart';
import '../../../card_sets/presentation/library/card_set_collection_view.dart';
import '../../data/card_providers.dart';
import '../../domain/card_models.dart';
import '../create/create_card_controller.dart';
import '../widgets/card_image.dart';

/// 收藏列表，覆盖加载、空、成功和失败状态。
class CardLibraryScreen extends ConsumerWidget {
  const CardLibraryScreen({super.key});

  Future<void> _startImport(BuildContext context, WidgetRef ref) async {
    final picked = await ref
        .read(createCardControllerProvider.notifier)
        .pickImage();
    if (!context.mounted) return;

    if (picked) {
      context.push(createCardPath);
      return;
    }

    final failure = ref.read(createCardControllerProvider).failure;
    if (failure != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.userMessage)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 新建页覆盖在收藏分支之上时继续持有本次草稿。
    ref.watch(createCardControllerProvider);
    final cards = ref.watch(cardListProvider);
    final tokens = context.tokens;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(
              tokens.spaceLg,
              tokens.spaceLg,
              tokens.spaceLg,
              tokens.spaceMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('我的收藏', style: Theme.of(context).textTheme.headlineMedium),
                SizedBox(height: tokens.spaceXs),
                cards.maybeWhen(
                  data: (items) => Text(
                    items.isEmpty ? '还没有卡片，从第一张开始记录' : '${items.length} 款式',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: tokens.spaceLg),
                    child: const TabBar(
                      tabs: <Widget>[
                        Tab(text: '卡片'),
                        Tab(text: '套卡'),
                      ],
                    ),
                  ),
                  SizedBox(height: tokens.spaceMd),
                  Expanded(
                    child: TabBarView(
                      children: <Widget>[
                        cards.when(
                          loading: () => const Center(
                            child: CircularProgressIndicator(
                              semanticsLabel: '正在加载收藏',
                            ),
                          ),
                          error: (error, stackTrace) => _LibraryError(
                            onRetry: () => ref.invalidate(cardListProvider),
                          ),
                          data: (items) => items.isEmpty
                              ? _EmptyLibrary(
                                  onImport: () => _startImport(context, ref),
                                )
                              : _CardList(items: items),
                        ),
                        const CardSetCollectionView(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.onImport});

  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 144,
              height: 104,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(tokens.radiusLg),
              ),
              child: const CardImage.placeholder(semanticLabel: '空收藏示意图'),
            ),
            SizedBox(height: tokens.spaceLg),
            Text(
              '让每一张交通卡，都有迹可循',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: tokens.spaceSm),
            Text(
              '选择一张卡片图片，补充名称后即可保存在本地。',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            SizedBox(height: tokens.spaceLg),
            FilledButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.file_upload_outlined),
              label: const Text('从相册导入'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryError extends StatelessWidget {
  const _LibraryError({required this.onRetry});

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
            const Text('收藏暂时无法加载'),
            SizedBox(height: context.tokens.spaceMd),
            FilledButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}

class _CardList extends StatelessWidget {
  const _CardList({required this.items});

  final List<CardSummary> items;

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
      itemCount: items.length,
      separatorBuilder: (context, index) => SizedBox(height: tokens.spaceMd),
      itemBuilder: (context, index) => _CardTile(card: items[index]),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.card});

  final CardSummary card;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final coverPath = card.coverRelativePath;
    final metadata = <String>[
      ?card.city,
      ?card.issuedAt?.toIsoString(),
      '${card.quantity} 张',
    ].join(' · ');

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusLg),
      ),
      child: InkWell(
        onTap: () => context.push(cardDetailPath(card.cardItemId)),
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        child: Padding(
          padding: EdgeInsets.all(tokens.spaceMd),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 104,
                height: 72,
                child: coverPath != null
                    ? CardImage.managed(
                        relativePath: coverPath,
                        semanticLabel: '${card.name}封面',
                      )
                    : CardImage.placeholder(semanticLabel: '${card.name}封面'),
              ),
              SizedBox(width: tokens.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      card.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: tokens.spaceSm),
                    Text(
                      metadata,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
