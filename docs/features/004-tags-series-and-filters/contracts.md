# Feature 004 契约

## 1. 仓储契约

```text
OrganizationRepository
  watchCards(query) -> Stream<List<OrganizedCardSummary>>
  watchFacets() -> Stream<CardFilterFacets>
  watchCardOrganization(cardItemId) -> Stream<CardOrganizationDetail?>
  saveCardOrganization(request) -> Future<void>

  watchTags() -> Stream<List<TagSummary>>
  createTag(request) -> Future<String>
  renameTag(request) -> Future<void>
  previewTagChange(tagId) -> Future<ChangeImpact>
  mergeTags(sourceTagId, targetTagId) -> Future<void>
  deleteTag(tagId) -> Future<void>

  watchSeries() -> Stream<List<SeriesSummary>>
  watchSeriesDetail(seriesId) -> Stream<SeriesDetail?>
  saveSeries(request) -> Future<String>
  deleteSeries(seriesId) -> Future<void>

  watchFieldDefinitions() -> Stream<List<CustomFieldDefinition>>
  createField(request) -> Future<String>
  renameField(request) -> Future<void>
  previewFieldDeletion(fieldId) -> Future<ChangeImpact>
  deleteField(fieldId) -> Future<void>
```

契约只暴露领域对象，不暴露 Drift 行、Widget、SQL、绝对路径或平台类型。

## 2. 查询契约

`CardLibraryQuery` 包含 `searchText`、可空类型/城市/年份、标签 ID 集合及 `TagMatchMode`、`SetMembershipFilter`、可空重复/待补全布尔值、`CardSortField` 与方向。`normalized()` 去空白、去重标签并移除空条件。

`OrganizedCardSummary` 包含卡片/款式 ID、封面相对路径、名称、数量、城市、发行/入手日期、类型、待补全和标签摘要。查询失败映射为 `DatabaseUnavailableFailure`。

## 3. 写入契约

- 名称请求：预生成 ID、名称；名称 1..100 字符。
- `SaveCardOrganizationRequest`：卡片 ID、类型、待补全、入手日期、完整标签/系列 ID 集合及字段值集合；保存采用全量替换语义。
- `SaveSeriesRequest`：系列 ID、名称、可空描述、完整卡片款式/套卡 ID 集合；创建与编辑共用。
- `CustomFieldValueInput`：字段 ID 与恰好一个文本/数字/日期值；空文本代表清除。

## 4. 失败契约

- 空名称、重名、无效 ID、类型不匹配、非法合并：`OrganizationValidationFailure`；
- 目标记录不存在或集合中有未知关系：`OrganizationValidationFailure`；
- 数据库读失败：`DatabaseUnavailableFailure`；
- 数据库事务失败：`PersistenceFailure`。

错误文案不得包含 SQL、绝对路径、堆栈或原始异常。

## 5. 原子性与幂等

标签合并、卡片整理保存、系列成员保存和字段删除均为单数据库事务。关系写入使用唯一键与集合差异实现幂等；重复提交不得产生重复关系。
