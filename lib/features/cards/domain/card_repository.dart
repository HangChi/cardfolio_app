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

  /// 当前被数据库引用的全部图片相对路径，供启动时清理孤儿文件。
  Future<Set<String>> referencedImagePaths();
}
