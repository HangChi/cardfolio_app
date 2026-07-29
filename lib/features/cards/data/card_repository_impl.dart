import 'dart:io';

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

    final imported = await _importImages(cardItemId, normalized.images);

    final now = clock.nowUtc();
    try {
      await _db.insertCardGraph(_buildGraph(normalized, imported, now));
    } catch (error) {
      // 事务已回滚，补偿删除本次复制的文件，避免留下孤儿。
      await _deleteImported(imported);
      throw PersistenceFailure('保存失败，请重试。', error);
    }

    return cardItemId;
  }

  @override
  Future<void> addImages(AddCardImagesRequest request) async {
    final normalized = request.normalized();
    final current = await _detail(normalized.cardItemId);
    if (current == null) {
      throw const ValidationFailure(CardField.image, '卡片不存在，请返回收藏后重试。');
    }
    if (current.images.length + normalized.images.length >
        CreateCardRequest.maxImages) {
      throw const ValidationFailure(CardField.image, '每张卡片最多保存 20 张图片。');
    }

    final imported = await _importImages(
      normalized.cardItemId,
      normalized.images,
    );
    final now = clock.nowUtc();
    try {
      await _db.addImages(
        cardItemId: normalized.cardItemId,
        images: <CardImagesCompanion>[
          for (var index = 0; index < imported.length; index++)
            _imageCompanion(
              input: normalized.images[index],
              image: imported[index],
              cardItemId: normalized.cardItemId,
              sortOrder: current.images.length + index,
              isCover: false,
              createdAt: now,
            ),
        ],
        updatedAt: now,
      );
    } catch (error) {
      await _deleteImported(imported);
      if (error is StateError) {
        throw ValidationFailure(CardField.image, error.message);
      }
      throw PersistenceFailure('添加图片失败，请重试。', error);
    }
  }

  @override
  Future<void> updateImageKind({
    required String cardItemId,
    required String imageId,
    required CardImageKind kind,
  }) {
    return _mutate(
      () => _db.updateImageKind(
        cardItemId: cardItemId,
        imageId: imageId,
        kind: kind,
        updatedAt: clock.nowUtc(),
      ),
    );
  }

  @override
  Future<void> reorderImages({
    required String cardItemId,
    required List<String> orderedImageIds,
  }) {
    return _mutate(
      () => _db.reorderImages(
        cardItemId: cardItemId,
        orderedImageIds: orderedImageIds,
        updatedAt: clock.nowUtc(),
      ),
    );
  }

  @override
  Future<void> setCover({required String cardItemId, required String imageId}) {
    return _mutate(
      () => _db.setCover(
        cardItemId: cardItemId,
        imageId: imageId,
        updatedAt: clock.nowUtc(),
      ),
    );
  }

  @override
  Future<ImageDeletionImpact> getImageDeletionImpact({
    required String cardItemId,
    required String imageId,
  }) async {
    final detail = await _detail(cardItemId);
    final image = detail?.images.cast<CardImageRef?>().firstWhere(
      (entry) => entry!.id == imageId,
      orElse: () => null,
    );
    if (detail == null || image == null) {
      throw const ValidationFailure(CardField.image, '图片不存在，请刷新后重试。');
    }
    final int byteSize;
    try {
      byteSize = await _images.resolve(image.relativePath).length();
    } on FileSystemException catch (error) {
      throw ImageImportFailure('原图文件缺失，无法计算空间影响。', error);
    }
    return ImageDeletionImpact(
      imageId: imageId,
      byteSize: byteSize,
      isCover: image.isCover,
      remainingImageCount: detail.images.length - 1,
    );
  }

  @override
  Future<void> deleteImage({
    required String cardItemId,
    required String imageId,
    required bool keepOriginal,
  }) async {
    final RemovedImageRecord removed;
    try {
      removed = await _db.removeImage(
        cardItemId: cardItemId,
        imageId: imageId,
        keepOriginal: keepOriginal,
        deletedAt: clock.nowUtc(),
      );
    } on StateError catch (error) {
      throw ValidationFailure(CardField.image, error.message);
    } catch (error) {
      throw PersistenceFailure('移除图片失败，请重试。', error);
    }

    if (!keepOriginal) {
      await _images.delete(removed.relativePath);
      if (removed.derivedRelativePath case final derived?) {
        await _images.delete(derived);
      }
    }
  }

  Future<CardDetail?> _detail(String cardItemId) async {
    try {
      return await _db.watchCardDetail(cardItemId).first;
    } catch (error) {
      throw DatabaseUnavailableFailure('收藏库暂时无法读取，请重试。', error);
    }
  }

  Future<void> _mutate(Future<void> Function() action) async {
    try {
      await action();
    } on StateError catch (error) {
      throw ValidationFailure(CardField.image, error.message);
    } catch (error) {
      throw PersistenceFailure('更新图片失败，请重试。', error);
    }
  }

  Future<List<_ImportedCardImage>> _importImages(
    String cardItemId,
    List<PendingCardImage> inputs,
  ) async {
    final imported = <_ImportedCardImage>[];
    try {
      for (final input in inputs) {
        ManagedImage? original;
        ManagedImage? derived;
        try {
          original = await _images.importImage(
            sourcePath: input.sourcePath,
            cardItemId: cardItemId,
            imageId: input.id,
          );
          if (input.derivedSourcePath case final derivedSource?) {
            derived = await _images.importDerivedImage(
              sourcePath: derivedSource,
              cardItemId: cardItemId,
              imageId: input.id,
            );
          }
          imported.add(
            _ImportedCardImage(original: original, derived: derived),
          );
        } catch (_) {
          if (derived != null) await _images.delete(derived.relativePath);
          if (original != null) await _images.delete(original.relativePath);
          rethrow;
        }
      }
      return imported;
    } catch (_) {
      await _deleteImported(imported);
      rethrow;
    }
  }

  Future<void> _deleteImported(List<_ImportedCardImage> imported) async {
    for (final image in imported.reversed) {
      if (image.derived case final derived?) {
        await _images.delete(derived.relativePath);
      }
      await _images.delete(image.original.relativePath);
    }
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
    List<_ImportedCardImage> images,
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
        for (var index = 0; index < images.length; index++)
          _imageCompanion(
            input: request.images[index],
            image: images[index],
            cardItemId: request.ids.cardItemId,
            sortOrder: index,
            isCover: index == 0,
            createdAt: now,
          ),
      ],
    );
  }

  CardImagesCompanion _imageCompanion({
    required PendingCardImage input,
    required _ImportedCardImage image,
    required String cardItemId,
    required int sortOrder,
    required bool isCover,
    required DateTime createdAt,
  }) {
    return CardImagesCompanion.insert(
      id: input.id,
      cardItemId: cardItemId,
      kind: input.kind,
      relativePath: image.original.relativePath,
      derivedRelativePath: Value<String?>(image.derived?.relativePath),
      sortOrder: Value(sortOrder),
      isCover: Value(isCover),
      checksum: image.original.checksum,
      createdAt: createdAt,
    );
  }
}

final class _ImportedCardImage {
  const _ImportedCardImage({required this.original, this.derived});

  final ManagedImage original;
  final ManagedImage? derived;
}
