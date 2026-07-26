import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../app/app_theme.dart';
import '../../data/card_providers.dart';
import '../../domain/card_models.dart';
import '../widgets/card_image.dart';

/// 单卡详情，只展示 Feature 001 已持久化的字段。
class CardDetailScreen extends ConsumerWidget {
  const CardDetailScreen({required this.cardItemId, super.key});

  final String cardItemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(cardDetailProvider(cardItemId));

    return Scaffold(
      appBar: AppBar(title: const Text('卡片详情')),
      body: detail.when(
        loading: () => const Center(
          child: CircularProgressIndicator(semanticsLabel: '正在加载卡片详情'),
        ),
        error: (error, stackTrace) => _DetailError(
          onRetry: () => ref.invalidate(cardDetailProvider(cardItemId)),
        ),
        data: (card) =>
            card == null ? const _MissingCard() : _DetailContent(card: card),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.card});

  final CardDetail card;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final cover = card.cover;
    final metadata = <String>[
      ?card.city,
      ?card.issuer,
      ?card.issuedAt?.toIsoString(),
    ].join(' · ');

    return ListView(
      padding: EdgeInsets.fromLTRB(
        tokens.spaceLg,
        tokens.spaceMd,
        tokens.spaceLg,
        tokens.spaceXl,
      ),
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.58,
          child: cover != null
              ? CardImage.managed(
                  relativePath: cover.relativePath,
                  semanticLabel: '${card.name}正面',
                  borderRadius: BorderRadius.circular(tokens.radiusLg),
                )
              : CardImage.placeholder(
                  semanticLabel: '${card.name}正面',
                  borderRadius: BorderRadius.circular(tokens.radiusLg),
                ),
        ),
        SizedBox(height: tokens.spaceLg),
        Text(card.name, style: Theme.of(context).textTheme.headlineSmall),
        if (metadata.isNotEmpty) ...<Widget>[
          SizedBox(height: tokens.spaceSm),
          Text(
            metadata,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
        SizedBox(height: tokens.spaceLg),
        Container(
          padding: EdgeInsets.all(tokens.spaceMd),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(tokens.radiusLg),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: _Stat(label: '持有数量', value: '${card.quantity} 张'),
              ),
              const Expanded(
                child: _Stat(label: '存储位置', value: '本地'),
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.spaceMd),
        if (card.code case final code?) _DetailRow(label: '编号', value: code),
        if (card.notes case final notes?) _DetailRow(label: '备注', value: notes),
        SizedBox(height: tokens.spaceLg),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: null,
                child: const Text('编辑资料 · 后续开放'),
              ),
            ),
            SizedBox(width: tokens.spaceMd),
            Expanded(
              child: FilledButton(
                onPressed: null,
                child: const Text('记录购买 · 后续开放'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: context.tokens.spaceSm),
        Text(value, style: Theme.of(context).textTheme.titleLarge),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: context.tokens.spaceMd),
      padding: EdgeInsets.all(context.tokens.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(context.tokens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          SizedBox(height: context.tokens.spaceSm),
          Text(value),
        ],
      ),
    );
  }
}

class _MissingCard extends StatelessWidget {
  const _MissingCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.search_off_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: context.tokens.spaceMd),
            const Text('这张卡片不存在'),
            SizedBox(height: context.tokens.spaceMd),
            FilledButton(
              onPressed: () => context.go(libraryPath),
              child: const Text('返回收藏'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('卡片详情暂时无法加载'),
            SizedBox(height: context.tokens.spaceMd),
            FilledButton(onPressed: onRetry, child: const Text('重试')),
          ],
        ),
      ),
    );
  }
}
