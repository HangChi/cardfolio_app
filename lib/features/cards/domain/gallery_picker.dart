import 'card_models.dart';

/// 相册选择契约。
abstract interface class GalleryPicker {
  /// 选择一张图片。用户取消时返回 null，不视为错误。
  Future<SelectedGalleryImage?> pickOne();

  /// 恢复 Android 低内存回收导致丢失的选择结果。
  ///
  /// 没有可恢复结果时返回 null；同一结果只允许被消费一次。
  Future<SelectedGalleryImage?> recoverLost();
}
