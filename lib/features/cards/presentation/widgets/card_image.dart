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

    if (file == null || !file.existsSync()) return placeholder;

    return Semantics(
      image: true,
      label: semanticLabel,
      child: ClipRRect(
        borderRadius: radius,
        child: Image.file(
          file,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => placeholder,
        ),
      ),
    );
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
