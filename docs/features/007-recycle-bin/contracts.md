# Feature 007 契约

## 仓储

```text
RecycleBinRepository
  watchEntries() -> Stream<List<RecycleBinEntry>>
  watchSettings() -> Stream<RecycleBinSettings>
  deleteCard(cardItemId) -> Future<void>
  restoreCard(cardItemId) -> Future<void>
  previewPermanentDeletion(cardItemId) -> Future<PermanentDeletionImpact>
  permanentlyDelete(cardItemId) -> Future<void>
  updateRetentionDays(days) -> Future<void>
  purgeExpired() -> Future<int>
  retryPendingFileCleanup() -> Future<void>
```

仓储只暴露领域对象和稳定 ID，不暴露 Drift 行、文件绝对路径或 Widget。所有时间由 `Clock` 注入并归一为 UTC。

## 幂等与并发

- 已在回收站的卡片再次软删除视为成功。
- 已恢复的卡片再次恢复视为成功。
- 永久删除不存在的卡片视为成功，便于启动重试。
- 影响预览只接受回收站卡片；活跃或不存在卡片返回安全业务失败。
- 文件清理队列以相对路径唯一，重复入队不产生重复行。

## 失败

数据库失败映射为 `DatabaseUnavailableFailure('回收站操作失败，请重试。')`。非法状态映射为 `ValidationFailure`。文件清理失败不把已成功的永久删除报告为失败，队列将在启动或下一次清理时继续处理。
