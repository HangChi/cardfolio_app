import 'card_models.dart';

/// 卡片读写契约。
///
/// 实现不得向上暴露 Drift 行、Flutter Widget、`XFile` 或数据库绝对路径
/// （见 `docs/features/001-local-card-creation/contracts.md` §1）。
abstract interface class CardRepository {
  /// 按创建时间倒序观察未删除的卡片摘要。
  Stream<List<CardSummary>> watchCards();

  /// 观察单张卡片详情；记录不存在或已删除时发出 null。
  Stream<CardDetail?> watchCard(String cardItemId);

  /// 创建一张卡片并返回藏品 ID。
  ///
  /// 以 `request.ids.cardItemId` 为幂等键：重复提交返回既有 ID，不产生第二组数据。
  Future<String> createCard(CreateCardRequest request);

  /// 更新卡片基础资料；图片、标签和集卡册归属由各自的接口维护。
  Future<void> updateCard(UpdateCardRequest request);

  /// 向既有藏品追加一批图片。
  Future<void> addImages(AddCardImagesRequest request);

  Future<void> updateImageKind({
    required String cardItemId,
    required String imageId,
    required CardImageKind kind,
  });

  /// 保存既有图片的新编辑结果；原图保持不变。
  Future<void> updateImageEdit({
    required String cardItemId,
    required String imageId,
    required String derivedSourcePath,
  });

  /// 调整全部活跃图片的顺序。ID 必须完整且不重复。
  Future<void> reorderImages({
    required String cardItemId,
    required List<String> orderedImageIds,
  });

  /// 设置封面；不改变图片顺序。
  Future<void> setCover({required String cardItemId, required String imageId});

  Future<ImageDeletionImpact> getImageDeletionImpact({
    required String cardItemId,
    required String imageId,
  });

  /// 从图集移除图片；[keepOriginal] 为真时保留受管原图。
  Future<void> deleteImage({
    required String cardItemId,
    required String imageId,
    required bool keepOriginal,
  });

  /// 当前被数据库引用的全部图片相对路径，供启动时清理孤儿文件。
  Future<Set<String>> referencedImagePaths();
}
