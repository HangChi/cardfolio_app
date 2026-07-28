# Feature 003 契约

## 1. 仓储契约

```text
CardSetRepository
  watchSets() -> Stream<List<CardSetSummary>>
  watchSet(setId) -> Stream<CardSetDetail?>
  watchCandidates(setId) -> Stream<List<CardSetCandidate>>
  createSet(request) -> Future<String>
  updateSet(request) -> Future<void>
  addMember(request) -> Future<void>
  updateMember(request) -> Future<void>
  reorderMembers(setId, orderedMemberIds) -> Future<void>
  removeMember(setId, memberId) -> Future<void>
  setCover(setId, imageId?) -> Future<void>
```

契约只暴露领域对象，不暴露 Drift 行、Widget、绝对路径或图片字节。

## 2. 写入请求

- `CreateCardSetRequest`：预生成套卡 ID、名称、总数模式、发行信息和备注。
- `UpdateCardSetRequest`：保留套卡 ID，执行与创建相同的规范化。
- `AddCardSetMemberRequest.existing`：引用已有款式 ID。
- `AddCardSetMemberRequest.missing`：携带预生成款式 ID和名称，在同一事务创建无藏品款式与成员。
- `UpdateCardSetMemberRequest`：修改编号和必需性。

所有字符串去首尾空白，空可选值转为 null；名称最多 100 字符，发行信息和备注最多 1000 字符，成员编号最多 100 字符。

## 3. 查询模型

`CardSetSummary` 提供封面相对路径、已拥有/缺失/重复成员数、已知总数进度和可空完成状态。`CardSetDetail` 增加有序成员；`CardSetMemberDetail` 提供款式、编号、必需性、拥有数量、首个活跃藏品 ID 和封面图片 ID。

## 4. 失败契约

- 表单、总数、重复成员、排序集合、封面归属：`CardSetValidationFailure`；
- 目标套卡或成员已不存在：`CardSetValidationFailure`；
- 数据库读失败：`DatabaseUnavailableFailure`；
- 数据库事务失败：`PersistenceFailure`。

错误文案不得包含 SQL、绝对路径、堆栈或原始异常。

## 5. 原子性

套卡创建/编辑、成员新增/修改/排序/移除和封面变化均在单个数据库事务提交。新增缺失成员时，款式定义和成员关系必须同时成功或同时回滚。
