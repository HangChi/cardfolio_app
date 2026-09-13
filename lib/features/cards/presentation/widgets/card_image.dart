import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_theme.dart';
import '../../data/card_providers.dart';

/// 同时支持选图预览和受管图片的统一展示组件。
class CardImage extends ConsumerWidget {
  const CardImage.local({
    required String path,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.semanticLabel = '卡片图片',
    super.key,
  }) : localPath = path,
       managedRelativePath = null;

  const CardImage.managed({
    required String relativePath,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.semanticLabel = '卡片图片',
    super.key,
  }) : managedRelativePath = relativePath,
       localPath = null;

  const CardImage.placeholder({
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.semanticLabel = '暂无卡片图片',
    super.key,
  }) : managedRelativePath = null,
       localPath = null;

  final String? localPath;
  final String? managedRelativePath;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String semanticLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    File? file;
    try {
      if (localPath case final path?) {
        file = File(path);
      } else if (managedRelativePath case final relativePath?) {
        file = ref.read(managedImageStoreProvider).resolve(relativePath);
      }
    } on Object {
      file = null;
    }

    final radius =
        borderRadius ?? BorderRadius.circular(context.tokens.radiusMd);
    final placeholder = _ImagePlaceholder(
      semanticLabel: semanticLabel,
      borderRadius: radius,
    );

    if (file == null) return placeholder;
    final resolvedFile = file;

    return Semantics(
      image: true,
      label: semanticLabel,
      child: ClipRRect(
        borderRadius: radius,
        child: LayoutBuilder(
          builder: (context, constraints) => Image.file(
            resolvedFile,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
            cacheWidth: _decodeWidth(context, constraints),
            errorBuilder: (context, error, stackTrace) => placeholder,
          ),
        ),
      ),
    );
  }

  /// 按显示约束降采样解码，避免列表缩略图整图解码原图。
  ///
  /// cover 裁剪会让实际显示尺寸略大于约束盒，留出余量避免可见失真；
  /// 约束不有限（如无界横向滚动）时返回 null，退回原始解码。
  int? _decodeWidth(BuildContext context, BoxConstraints constraints) {
    final double bound;
    if (constraints.maxWidth.isFinite) {
      bound = constraints.maxWidth;
    } else if (constraints.maxHeight.isFinite) {
      bound = constraints.maxHeight;
    } else {
      return null;
    }
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    return (bound * devicePixelRatio * 1.3).round();
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.semanticLabel,
    required this.borderRadius,
  });

  final String semanticLabel;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      image: true,
      label: '$semanticLabel，图片不可用',
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.palette.surfaceMuted,
          borderRadius: borderRadius,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Center(
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.style_outlined,
              color: scheme.primary,
              size: context.tokens.iconMd,
            ),
          ),
        ),
      ),
    );
  }
}
