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
import '../../domain/image_processing.dart';
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
  late final PageController _imagePageController;
  String? _selectedImageId;

  CardDetail get card => widget.card;

  @override
  void initState() {
    super.initState();
    final initialIndex = _preferredImageIndex(card);
    _selectedImageId = card.images.isEmpty
        ? null
        : card.images[initialIndex].id;
    _imagePageController = PageController(initialPage: initialIndex);
  }

  @override
  void didUpdateWidget(covariant _DetailContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selectedStillExists = card.images.any(
      (image) => image.id == _selectedImageId,
    );
    if (!selectedStillExists) {
      final target = _preferredImageIndex(card);
      _selectedImageId = card.images.isEmpty ? null : card.images[target].id;
    }
    final targetIndex = _selectedImageIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_imagePageController.hasClients) return;
      final currentPage = _imagePageController.page?.round();
      if (currentPage != targetIndex) {
        _imagePageController.jumpToPage(targetIndex);
      }
    });
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  int get _selectedImageIndex {
    if (card.images.isEmpty) return 0;
    final index = card.images.indexWhere(
      (image) => image.id == _selectedImageId,
    );
    return index < 0 ? _preferredImageIndex(card) : index;
  }

  CardImageRef? get _selectedImage =>
      card.images.isEmpty ? null : card.images[_selectedImageIndex];

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
    final source = await showModalBottomSheet<_DetailImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('拍摄'),
              subtitle: const Text('拍摄后直接添加，可在图片管理中编辑'),
              onTap: () => Navigator.of(context).pop(_DetailImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('从相册选择'),
              onTap: () =>
                  Navigator.of(context).pop(_DetailImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    late final List<PendingCardImage> pendingImages;
    try {
      final generator = ref.read(idGeneratorProvider);
      if (source == _DetailImageSource.gallery) {
        final selections = await ref
            .read(galleryPickerProvider)
            .pickMany(limit: remaining);
        pendingImages = <PendingCardImage>[
          for (final selection in selections)
            PendingCardImage(id: generator.newId(), sourcePath: selection.path),
        ];
      } else {
        final captured = await ref.read(cameraCaptureProvider).capture();
        if (captured == null || !mounted) return;
        final imageId = generator.newId();
        pendingImages = <PendingCardImage>[
          PendingCardImage(id: imageId, sourcePath: captured.path),
        ];
      }
    } on AppFailure catch (failure) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.userMessage)));
      }
      return;
    }
    if (pendingImages.isEmpty || !mounted) return;
    await _run(
      () => ref
          .read(cardRepositoryProvider)
          .addImages(
            AddCardImagesRequest(
              cardItemId: card.cardItemId,
              images: pendingImages,
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
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('编辑图片'),
              subtitle: const Text('裁剪、旋转、亮度、对比度与清晰度'),
              onTap: () {
                Navigator.pop(sheetContext);
                _editImage(image);
              },
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

  Future<void> _editImage(CardImageRef image) async {
    final store = ref.read(managedImageStoreProvider);
    final source = store.resolve(image.displayRelativePath);
    final processed = await context.push<ProcessedImage>(
      imageEditorPath,
      extra: ImageEditorRouteArgs(sourcePath: source.path, outputId: image.id),
    );
    if (processed == null || !mounted) return;
    await _run(
      () => ref
          .read(cardRepositoryProvider)
          .updateImageEdit(
            cardItemId: card.cardItemId,
            imageId: image.id,
            derivedSourcePath: processed.path,
          ),
    );
    final derived = store.resolve('derived/${card.cardItemId}/${image.id}.jpg');
    PaintingBinding.instance.imageCache.evict(FileImage(derived));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final selectedImage = _selectedImage;
    final selectedImageIndex = _selectedImageIndex;
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            child: card.images.isEmpty
                ? CardImage.placeholder(semanticLabel: '${card.name}暂无图片')
                : PageView.builder(
                    controller: _imagePageController,
                    itemCount: card.images.length,
                    onPageChanged: (index) => setState(
                      () => _selectedImageId = card.images[index].id,
                    ),
                    itemBuilder: (context, index) {
                      final image = card.images[index];
                      return CardImage.managed(
                        relativePath: image.displayRelativePath,
                        semanticLabel:
                            '${card.name}，${image.kind.label}'
                            '${image.isCover ? '，封面' : ''}'
                            '，第 ${index + 1} 张，共 ${card.images.length} 张',
                      );
                    },
                  ),
          ),
        ),
        SizedBox(height: tokens.spaceSm),
        _ImageGalleryToolbar(
          image: selectedImage,
          index: selectedImageIndex,
          count: card.images.length,
          busy: _busy,
          canAdd: card.images.length < CreateCardRequest.maxImages,
          onAdd: _addImages,
          onManage: selectedImage == null
              ? null
              : () => _openImageManager(selectedImage, selectedImageIndex),
        ),
        SizedBox(height: tokens.spaceLg),
        Text(card.name, style: Theme.of(context).textTheme.headlineSmall),
        if (metadata.isNotEmpty) ...<Widget>[
          SizedBox(height: tokens.spaceSm),
          Text(
            metadata,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: context.palette.textSecondary,
            ),
          ),
        ],
        SizedBox(height: tokens.spaceLg),
        Container(
          padding: EdgeInsets.all(tokens.spaceMd),
          decoration: BoxDecoration(
            color: context.palette.surface,
            borderRadius: BorderRadius.circular(tokens.radiusLg),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
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
        SizedBox(height: tokens.spaceSm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.push(copyCardPath(card.cardItemId)),
            icon: const Icon(Icons.content_copy_outlined),
            label: const Text('复制资料建卡'),
          ),
        ),
      ],
    );
  }
}

int _preferredImageIndex(CardDetail card) {
  if (card.images.isEmpty) return 0;
  final coverIndex = card.images.indexWhere((image) => image.isCover);
  return coverIndex < 0 ? 0 : coverIndex;
}

class _ImageGalleryToolbar extends StatelessWidget {
  const _ImageGalleryToolbar({
    required this.image,
    required this.index,
    required this.count,
    required this.busy,
    required this.canAdd,
    required this.onAdd,
    required this.onManage,
  });

  final CardImageRef? image;
  final int index;
  final int count;
  final bool busy;
  final bool canAdd;
  final VoidCallback onAdd;
  final VoidCallback? onManage;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final selected = image;
    final label = selected == null
        ? '暂无图片'
        : '${selected.kind.label}${selected.isCover ? ' · 封面' : ''}';
    return Container(
      constraints: BoxConstraints(minHeight: tokens.minTapTarget),
      padding: EdgeInsets.only(left: tokens.spaceMd, right: tokens.spaceXs),
      decoration: BoxDecoration(
        color: context.palette.surfaceMuted,
        borderRadius: BorderRadius.circular(tokens.radiusMd),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            selected?.isCover == true
                ? Icons.star_rounded
                : Icons.image_outlined,
            size: tokens.iconSm,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(width: tokens.spaceSm),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          if (count > 0)
            Text(
              '${index + 1} / $count',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: context.palette.textSecondary,
              ),
            ),
          IconButton(
            tooltip: '添加图片',
            onPressed: busy || !canAdd ? null : onAdd,
            icon: const Icon(Icons.add_photo_alternate_outlined),
          ),
          if (selected != null)
            TextButton(
              key: Key('manage-image-${selected.id}'),
              onPressed: busy ? null : onManage,
              child: const Text('管理'),
            ),
        ],
      ),
    );
  }
}

enum _DetailImageSource { camera, gallery }

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
                Text('入手成本', style: Theme.of(context).textTheme.titleMedium),
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
          ).textTheme.bodySmall?.copyWith(color: context.palette.textSecondary),
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
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(context.tokens.radiusLg),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.palette.textSecondary,
            ),
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
            Icon(
              Icons.search_off_outlined,
              size: 48,
              color: context.palette.textSecondary,
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
