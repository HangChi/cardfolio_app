import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/camera_capture.dart';

final class ImagePickerCameraCapture implements CameraCapture {
  ImagePickerCameraCapture([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<CapturedImage?> capture() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
        requestFullMetadata: false,
      );
      return file == null ? null : _toDomain(file);
    } on PlatformException catch (error) {
      throw CameraAccessFailure(_messageFor(error), error);
    } catch (error) {
      throw CameraAccessFailure('无法打开相机，你仍可从相册导入图片。', error);
    }
  }

  @override
  Future<List<CapturedImage>> recoverLost() async {
    try {
      final response = await _picker.retrieveLostData();
      if (response.isEmpty) return const <CapturedImage>[];
      if (response.exception != null) {
        throw CameraAccessFailure('上次拍摄的图片已失效，请重新拍摄。', response.exception);
      }
      final files = response.files ?? <XFile>[?response.file];
      return files.map(_toDomain).toList(growable: false);
    } on CameraAccessFailure {
      rethrow;
    } on UnimplementedError {
      return const <CapturedImage>[];
    } on PlatformException catch (error) {
      throw CameraAccessFailure('上次拍摄的图片已失效，请重新拍摄。', error);
    } catch (error) {
      throw CameraAccessFailure('上次拍摄的图片已失效，请重新拍摄。', error);
    }
  }

  CapturedImage _toDomain(XFile file) =>
      CapturedImage(path: file.path, displayName: file.name);

  String _messageFor(PlatformException error) {
    return switch (error.code) {
      'camera_access_denied' => '需要相机权限才能拍摄，你仍可从相册导入图片。',
      'camera_access_restricted' => '当前设备限制了相机访问，你仍可从相册导入图片。',
      'camera_unavailable' => '当前设备没有可用相机，你仍可从相册导入图片。',
      _ => '无法打开相机，你仍可从相册导入图片。',
    };
  }
}
