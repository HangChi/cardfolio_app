import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

/// 图片来源选择弹层的统一选项。
enum ImageSourceChoice { camera, gallery }

/// 拍摄 / 从相册选择二选一弹层，全应用共用，保证各处文案与顺序一致。
Future<ImageSourceChoice?> showImageSourceSheet(
  BuildContext context, {
  String? cameraSubtitle,
  String? gallerySubtitle,
}) {
  return showModalBottomSheet<ImageSourceChoice>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: sheetContext.tokens.spaceMd),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('拍摄'),
              subtitle: cameraSubtitle == null ? null : Text(cameraSubtitle),
              onTap: () =>
                  Navigator.pop(sheetContext, ImageSourceChoice.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('从相册选择'),
              subtitle: gallerySubtitle == null ? null : Text(gallerySubtitle),
              onTap: () =>
                  Navigator.pop(sheetContext, ImageSourceChoice.gallery),
            ),
          ],
        ),
      ),
    ),
  );
}
