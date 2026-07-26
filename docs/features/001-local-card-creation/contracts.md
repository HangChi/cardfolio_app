# Feature 001 契约

## 1. 领域契约

```text
CardRepository
  watchCards() -> Stream<List<CardSummary>>
  watchCard(cardItemId) -> Stream<CardDetail?>
  createCard(request) -> Future<cardItemId>
  referencedImagePaths() -> Future<Set<relativePath>>

GalleryPicker
  pickOne() -> Future<SelectedGalleryImage?>
  recoverLost() -> Future<SelectedGalleryImage?>
```

领域契约不得暴露 Drift 行、Flutter Widget、`XFile` 或数据库绝对路径。

## 2. 创建请求

`CreateCardRequest` 包含预先生成的 definition/item/image UUID、源图片引用、名称、城市、发行方、发行时间、编号、备注。规范化后可选空字符串转为 `null`；名称为空抛出稳定的校验失败。

## 3. 查询模型

- `CardSummary`：藏品 ID、名称、封面相对路径、数量和必要摘要。
- `CardDetail`：定义资料、藏品资料和有序图片列表。

查询模型为只读快照，页面不得反向修改。

## 4. 失败契约

上层只接收稳定失败类型：

- `ValidationFailure`
- `GalleryAccessFailure`
- `ImageImportFailure`
- `PersistenceFailure`
- `DatabaseUnavailableFailure`

类型包含安全的用户文案和可选内部原因；内部原因只用于测试和脱敏诊断。

## 5. 幂等

`CardItem.id` 作为创建操作幂等键。相同草稿 ID 再次提交时返回既有藏品 ID，不复制第二份图片，不插入第二组数据。

## 6. 路由契约

- `/library`
- `/capture`
- `/cards/new`
- `/cards/:id`

详情路由只接收 `CardItem.id`。创建页的临时选择结果由进程内状态提供，不写入 URL。
