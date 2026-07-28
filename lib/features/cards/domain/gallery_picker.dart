import 'card_models.dart';

/// 相册选择契约。
abstract interface class GalleryPicker {
  /// 最多选择 [limit] 张图片。用户取消时返回空列表，不视为错误。
  Future<List<SelectedGalleryImage>> pickMany({required int limit});

  /// 恢复 Android 低内存回收导致丢失的选择结果。
  ///
  /// 没有可恢复结果时返回 null；同一结果只允许被消费一次。
  Future<List<SelectedGalleryImage>> recoverLost();
}
