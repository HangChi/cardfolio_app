import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/card_models.dart';
import '../../domain/gallery_picker.dart';

/// `image_picker` 适配器。
///
/// 把插件的 `XFile`、`PlatformException` 转换为领域类型，使上层不依赖插件。
class ImagePickerGallery implements GalleryPicker {
  ImagePickerGallery([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<List<SelectedGalleryImage>> pickMany({required int limit}) async {
    try {
      final files = await _picker.pickMultiImage(limit: limit);
      // 用户取消返回空列表，不是错误。
      return files.map(_toDomain).toList(growable: false);
    } on PlatformException catch (error) {
      throw GalleryAccessFailure(_messageFor(error), error);
    } catch (error) {
      throw GalleryAccessFailure('无法打开相册，请重试。', error);
    }
  }

  @override
  Future<List<SelectedGalleryImage>> recoverLost() async {
    // Android 在低内存时可能回收宿主 Activity，选择结果需要在重启后取回。
    try {
      final response = await _picker.retrieveLostData();
      if (response.isEmpty) return const <SelectedGalleryImage>[];
      if (response.exception != null) {
        throw GalleryAccessFailure('上次选择的图片已失效，请重新选择。', response.exception);
      }
      final files = response.files ?? <XFile>[?response.file];
      return files.map(_toDomain).toList(growable: false);
    } on GalleryAccessFailure {
      rethrow;
    } on UnimplementedError {
      return const <SelectedGalleryImage>[];
    } on PlatformException catch (error) {
      throw GalleryAccessFailure('上次选择的图片已失效，请重新选择。', error);
    } catch (error) {
      throw GalleryAccessFailure('上次选择的图片已失效，请重新选择。', error);
    }
  }

  SelectedGalleryImage _toDomain(XFile file) =>
      SelectedGalleryImage(path: file.path, displayName: file.name);

  String _messageFor(PlatformException error) {
    return switch (error.code) {
      'photo_access_denied' ||
      'camera_access_denied' => '需要相册权限才能选择图片，请在系统设置中开启。',
      _ => '无法打开相册，请重试。',
    };
  }
}
