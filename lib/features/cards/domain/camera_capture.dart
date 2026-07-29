import 'package:meta/meta.dart';

@immutable
final class CapturedImage {
  const CapturedImage({required this.path, this.displayName});

  final String path;
  final String? displayName;
}

/// 系统相机入口契约。领域层不暴露 `XFile` 或平台异常。
abstract interface class CameraCapture {
  /// 用户取消返回 null，不视为失败。
  Future<CapturedImage?> capture();

  /// 恢复 Android 宿主 Activity 被回收时保存的拍摄结果。
  Future<List<CapturedImage>> recoverLost();
}
