import 'package:drift/drift.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/time/clock.dart';
import '../domain/card_models.dart';
import '../domain/card_repository.dart';
import 'files/managed_image_store.dart';
import 'local/card_database.dart';

/// 协调受管文件与数据库事务的卡片仓储。
///
/// 写入顺序遵循 `docs/architecture/image-storage.md` §3：先复制图片到最终受管路径，
/// 再在单个事务写库；事务失败时补偿删除本次复制的文件。进程级中断遗留的孤儿文件由
/// 启动清理处理。
class CardRepositoryImpl implements CardRepository {
  const CardRepositoryImpl({
    required AppDatabase database,
    required ManagedImageStore imageStore,
    required this.clock,
  }) : _db = database,
       _images = imageStore;

  final AppDatabase _db;
  final ManagedImageStore _images;
  final Clock clock;

  @override
  Stream<List<CardSummary>> watchCards() => _db.watchCardSummaries();

  @override
  Stream<CardDetail?> watchCard(String cardItemId) =>
      _db.watchCardDetail(cardItemId);

  @override
  Future<Set<String>> referencedImagePaths() async {
    try {
      return await _db.referencedImagePaths();
    } on AppFailure {
      rethrow;
    } catch (error) {
      throw DatabaseUnavailableFailure('收藏库暂时无法读取，请重试。', error);
    }
  }

  @override
  Future<String> createCard(CreateCardRequest request) async {
    // 校验失败必须发生在任何文件或数据库操作之前。
    final normalized = request.normalized();
    final cardItemId = normalized.ids.cardItemId;

    if (await _cardExists(cardItemId)) {
      // 幂等：相同草稿重复提交返回既有藏品，不复制第二份图片。
      return cardItemId;
    }

    final image = await _images.importImage(
      sourcePath: normalized.sourceImagePath,
      cardItemId: cardItemId,
      imageId: normalized.ids.imageId,
    );

    final now = clock.nowUtc();
    try {
      await _db.insertCardGraph(_buildGraph(normalized, image, now));
    } catch (error) {
      // 事务已回滚，补偿删除本次复制的文件，避免留下孤儿。
      await _images.delete(image.relativePath);
      throw PersistenceFailure('保存失败，请重试。', error);
    }

    return cardItemId;
  }

  Future<bool> _cardExists(String cardItemId) async {
    try {
      return await _db.cardItemExists(cardItemId);
    } catch (error) {
      throw DatabaseUnavailableFailure('收藏库暂时无法打开，请重试。', error);
    }
  }

  CardRowGraph _buildGraph(
    CreateCardRequest request,
    ManagedImage image,
    DateTime now,
  ) {
    return CardRowGraph(
      definition: CardDefinitionsCompanion.insert(
        id: request.ids.definitionId,
        name: request.name,
        city: Value<String?>(request.city),
        issuer: Value<String?>(request.issuer),
        issuedAt: Value<String?>(request.issuedAt?.toIsoString()),
        code: Value<String?>(request.code),
        notes: Value<String?>(request.notes),
        createdAt: now,
        updatedAt: now,
      ),
      item: CardItemsCompanion.insert(
        id: request.ids.cardItemId,
        definitionId: request.ids.definitionId,
        quantity: Value<int>(request.quantity),
        createdAt: now,
        updatedAt: now,
      ),
      images: <CardImagesCompanion>[
        CardImagesCompanion.insert(
          id: request.ids.imageId,
          cardItemId: request.ids.cardItemId,
          kind: CardImageKind.front,
          relativePath: image.relativePath,
          checksum: image.checksum,
          createdAt: now,
        ),
      ],
    );
  }
}
