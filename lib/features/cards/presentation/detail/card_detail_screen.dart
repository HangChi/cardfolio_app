import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_router.dart';
import '../../../../app/app_theme.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../card_sets/data/card_set_providers.dart';
import '../../../card_sets/domain/card_set_models.dart';
import '../../../organization/data/organization_providers.dart';
import '../../../organization/domain/organization_models.dart';
import '../../../purchases/data/purchase_providers.dart';
import '../../../purchases/domain/purchase_models.dart';
import '../../../recycle_bin/data/recycle_bin_providers.dart';
import '../../data/card_providers.dart';
import '../../domain/card_models.dart';
import '../widgets/card_image.dart';
import '../widgets/card_image_kind_label.dart';

/// 单卡详情，只展示 Feature 001 已持久化的字段。
class CardDetailScreen extends ConsumerWidget {
  const CardDetailScreen({required this.cardItemId, super.key});

  final String cardItemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(cardDetailProvider(cardItemId));

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(libraryPath);
            }
          },
        ),
        title: const Text('卡片详情'),
        actions: <Widget>[
          IconButton(
            key: const Key('delete-card'),
            tooltip: '移入回收站',
            onPressed: () => _confirmCardDeletion(context, ref),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
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

  Future<void> _confirmCardDeletion(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('移入回收站？'),
        content: const Text('卡片会从收藏和统计中隐藏，并可以在回收站恢复。'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('移入回收站'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(recycleBinRepositoryProvider).deleteCard(cardItemId);
      if (!context.mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(libraryPath);
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

class _DetailContent extends ConsumerStatefulWidget {
  const _DetailContent({required this.card});

  final CardDetail card;

  @override
  ConsumerState<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends ConsumerState<_DetailContent> {
  bool _busy = false;

  CardDetail get card => widget.card;

  Future<void> _run(Future<void> Function() operation) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await operation();
    } on AppFailure catch (failure) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.userMessage)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addImages() async {
    final remaining = CreateCardRequest.maxImages - card.images.length;
    if (remaining <= 0) return;
    late final List<SelectedGalleryImage> selections;
    try {
      selections = await ref
          .read(galleryPickerProvider)
          .pickMany(limit: remaining);
    } on AppFailure catch (failure) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.userMessage)));
      }
      return;
    }
    if (selections.isEmpty || !mounted) return;
    final generator = ref.read(idGeneratorProvider);
    await _run(
      () => ref
          .read(cardRepositoryProvider)
          .addImages(
            AddCardImagesRequest(
              cardItemId: card.cardItemId,
              images: <PendingCardImage>[
                for (final selection in selections)
                  PendingCardImage(
                    id: generator.newId(),
                    sourcePath: selection.path,
                  ),
              ],
            ),
          ),
    );
  }

  Future<void> _moveImage(int index, int delta) async {
    final target = index + delta;
    if (target < 0 || target >= card.images.length) return;
    final ids = card.images.map((image) => image.id).toList(growable: true);
    final id = ids.removeAt(index);
    ids.insert(target, id);
    await _run(
      () => ref
          .read(cardRepositoryProvider)
          .reorderImages(cardItemId: card.cardItemId, orderedImageIds: ids),
    );
  }

  Future<void> _confirmDelete(CardImageRef image) async {
    final ImageDeletionImpact impact;
    try {
      setState(() => _busy = true);
      impact = await ref
          .read(cardRepositoryProvider)
          .getImageDeletionImpact(
            cardItemId: card.cardItemId,
            imageId: image.id,
          );
    } on AppFailure catch (failure) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.userMessage)));
      }
      return;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (!mounted) return;

    final keepOriginal = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('移除图片？'),
        content: Text(
          '文件大小：${_formatBytes(impact.byteSize)}。'
          '${impact.isCover ? '这是当前封面，移除后将自动选择新封面。' : ''}',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('移除并保留原图'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('同时删除原图'),
          ),
        ],
      ),
    );
    if (keepOriginal == null || !mounted) return;
    await _run(
      () => ref
          .read(cardRepositoryProvider)
          .deleteImage(
            cardItemId: card.cardItemId,
            imageId: image.id,
            keepOriginal: keepOriginal,
          ),
    );
  }

  Future<void> _openImageManager(CardImageRef image, int index) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            ListTile(
              title: Text('第 ${index + 1} 张 · ${image.kind.label}'),
              subtitle: image.isCover ? const Text('当前封面') : null,
            ),
            if (!image.isCover)
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: const Text('设为封面'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _run(
                    () => ref
                        .read(cardRepositoryProvider)
                        .setCover(
                          cardItemId: card.cardItemId,
                          imageId: image.id,
                        ),
                  );
                },
              ),
            ExpansionTile(
              leading: const Icon(Icons.label_outline),
              title: const Text('图片用途'),
              children: <Widget>[
                for (final kind in CardImageKind.values)
                  ListTile(
                    title: Text(kind.label),
                    trailing: kind == image.kind
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _run(
                        () => ref
                            .read(cardRepositoryProvider)
                            .updateImageKind(
                              cardItemId: card.cardItemId,
                              imageId: image.id,
                              kind: kind,
                            ),
                      );
                    },
                  ),
              ],
            ),
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text('前移'),
              enabled: index > 0,
              onTap: index == 0
                  ? null
                  : () {
                      Navigator.pop(sheetContext);
                      _moveImage(index, -1);
                    },
            ),
            ListTile(
              leading: const Icon(Icons.arrow_forward),
              title: const Text('后移'),
              enabled: index < card.images.length - 1,
              onTap: index >= card.images.length - 1
                  ? null
                  : () {
                      Navigator.pop(sheetContext);
                      _moveImage(index, 1);
                    },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('移除图片'),
              enabled: card.images.length > 1,
              onTap: card.images.length <= 1
                  ? null
                  : () {
                      Navigator.pop(sheetContext);
                      _confirmDelete(image);
                    },
            ),
          ],
        ),
      ),
    );
  }

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
        SizedBox(height: tokens.spaceMd),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '${card.images.length} 张图片',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            TextButton.icon(
              onPressed:
                  _busy || card.images.length >= CreateCardRequest.maxImages
                  ? null
                  : _addImages,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: const Text('添加图片'),
            ),
          ],
        ),
        SizedBox(
          height: 144,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: card.images.length,
            separatorBuilder: (context, index) =>
                SizedBox(width: tokens.spaceMd),
            itemBuilder: (context, index) {
              final image = card.images[index];
              return SizedBox(
                width: 148,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      CardImage.managed(
                        relativePath: image.displayRelativePath,
                        semanticLabel:
                            '第 ${index + 1} 张，${image.kind.label}'
                            '${image.isCover ? '，封面' : ''}',
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          color: Colors.black.withValues(alpha: 0.64),
                          padding: EdgeInsets.symmetric(
                            horizontal: tokens.spaceSm,
                            vertical: 4,
                          ),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  image.kind.label,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              if (image.isCover)
                                const Text(
                                  '封面',
                                  style: TextStyle(color: Colors.white),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton.filledTonal(
                          key: Key('manage-image-${image.id}'),
                          onPressed: _busy
                              ? null
                              : () => _openImageManager(image, index),
                          tooltip: '管理第 ${index + 1} 张图片',
                          icon: const Icon(Icons.more_horiz),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
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
        _OrganizationSummary(cardItemId: card.cardItemId),
        _CardCostSummary(cardItemId: card.cardItemId),
        SizedBox(height: tokens.spaceLg),
        SizedBox(
          width: double.infinity,
          child: FilledButton.tonal(
            onPressed: () => context.push(editCardPath(card.cardItemId)),
            child: const Text('编辑资料'),
          ),
        ),
      ],
    );
  }
}

class _OrganizationSummary extends ConsumerWidget {
  const _OrganizationSummary({required this.cardItemId});

  final String cardItemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organization = ref.watch(cardOrganizationProvider(cardItemId));
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.tokens.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '整理信息',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextButton.icon(
                  key: const Key('edit-card-organization'),
                  onPressed: () =>
                      context.push(cardOrganizationPath(cardItemId)),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('编辑'),
                ),
              ],
            ),
            organization.when(
              loading: () =>
                  const LinearProgressIndicator(semanticsLabel: '加载整理信息'),
              error: (error, stackTrace) => const Text('整理信息暂时无法加载'),
              data: (detail) {
                if (detail == null) return const Text('卡片资料不存在');
                final memberships = ref.watch(
                  cardSetMembershipsProvider(detail.definitionId),
                );
                final cardSets =
                    ref.watch(cardSetListProvider).value ??
                    const <CardSetSummary>[];
                final selectedSetIds =
                    memberships.value
                        ?.map((membership) => membership.setId)
                        .toSet() ??
                    const <String>{};
                final selectedSetNames = cardSets
                    .where((set) => selectedSetIds.contains(set.id))
                    .map((set) => set.name)
                    .toList(growable: false);
                final labels = <String>[
                  ?detail.cardType,
                  if (detail.needsCompletion) '待完善',
                  if (detail.acquiredAt != null)
                    '入手 ${_dateLabel(detail.acquiredAt!)}',
                ];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (labels.isNotEmpty) Text(labels.join(' · ')),
                    if (detail.tags.isNotEmpty) ...<Widget>[
                      SizedBox(height: context.tokens.spaceSm),
                      Wrap(
                        spacing: context.tokens.spaceXs,
                        runSpacing: context.tokens.spaceXs,
                        children: <Widget>[
                          for (final tag in detail.tags)
                            Chip(label: Text(tag.name)),
                        ],
                      ),
                    ],
                    if (selectedSetNames.isNotEmpty)
                      Text('套卡：${selectedSetNames.join('、')}'),
                    if (detail.series.isNotEmpty)
                      Text(
                        '集卡册：${detail.series.map((item) => item.name).join('、')}',
                      ),
                    for (final field in detail.fieldValues)
                      Text(
                        '${field.fieldName}：${_fieldValueLabel(field.value)}',
                      ),
                    if (labels.isEmpty &&
                        detail.tags.isEmpty &&
                        selectedSetNames.isEmpty &&
                        detail.series.isEmpty &&
                        detail.fieldValues.isEmpty)
                      const Text('尚未添加标签、套卡、卡册或自定义资料'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CardCostSummary extends ConsumerWidget {
  const _CardCostSummary({required this.cardItemId});

  final String cardItemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cost = ref.watch(cardEntryCostProvider(cardItemId));
    return cost.maybeWhen(
      data: (value) {
        if (value.isEmpty) return const SizedBox.shrink();
        final amount = CurrencyAmount(
          minorUnits: value.amountMinor,
          currency: 'CNY',
        ).formatted;
        final shipping = CurrencyAmount(
          minorUnits: value.shippingMinor,
          currency: 'CNY',
        ).formatted;
        final total = CurrencyAmount(
          minorUnits: value.amountMinor + value.shippingMinor,
          currency: 'CNY',
        ).formatted;
        return Card(
          child: Padding(
            padding: EdgeInsets.all(context.tokens.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '入手成本',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: context.tokens.spaceSm),
                Text('卡片 ¥$amount · 运费 ¥$shipping'),
                SizedBox(height: context.tokens.spaceXs),
                Text(
                  '合计 ¥$total',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ],
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

String _fieldValueLabel(CustomFieldValueInput input) =>
    switch (input.fieldType) {
      CustomFieldType.text => input.textValue!,
      CustomFieldType.number => input.numberValue!.toString(),
      CustomFieldType.date => _dateLabel(input.dateValue!),
    };

String _dateLabel(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

String _formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kilobytes = bytes / 1024;
  if (kilobytes < 1024) {
    return '${kilobytes.toStringAsFixed(kilobytes % 1 == 0 ? 0 : 1)} KB';
  }
  final megabytes = kilobytes / 1024;
  return '${megabytes.toStringAsFixed(megabytes % 1 == 0 ? 0 : 1)} MB';
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
