# Feature 002 契约

## 1. 领域契约

```text
GalleryPicker
  pickMany(limit) -> Future<List<SelectedGalleryImage>>
  recoverLost() -> Future<List<SelectedGalleryImage>>

CardRepository
  addImages(request) -> Future<void>
  updateImageKind(cardItemId, imageId, kind) -> Future<void>
  reorderImages(cardItemId, orderedImageIds) -> Future<void>
  setCover(cardItemId, imageId) -> Future<void>
  getImageDeletionImpact(cardItemId, imageId) -> Future<ImageDeletionImpact>
  deleteImage(cardItemId, imageId, keepOriginal) -> Future<void>
```

既有 `watchCards`、`watchCard`、`createCard` 和 `referencedImagePaths` 保持。契约不暴露 Drift、`XFile`、Widget 或绝对路径。

## 2. 写入请求

`PendingCardImage` 包含预生成图片 UUID、源路径和用途。`CreateCardRequest.images` 至少一项且最多 20 项；`AddCardImagesRequest.images` 至少一项，仓储在事务中校验追加后的总数不超过 20。

## 3. 查询模型

`CardImageRef` 暴露 `id`、原图相对路径、可选派生图相对路径、用途、顺序和封面标记。`CardDetail.images` 严格按顺序返回，`cover` 按标记查找。

## 4. 失败契约

- 参数、容量、最后一张删除和目标不属于藏品：`ValidationFailure`；
- 相册失败：`GalleryAccessFailure`；
- 文件读取、格式、空间或清理失败：`ImageImportFailure`；
- 数据库事务失败：`PersistenceFailure`；
- 数据库不可用：`DatabaseUnavailableFailure`。

## 5. 原子性

批量文件先导入确定路径，随后单事务写入图片元数据和 `CardItem.updatedAt/version`。失败补偿只删除本次操作写入的路径。封面、排序、用途和图片删除各自在单个数据库事务完成。
