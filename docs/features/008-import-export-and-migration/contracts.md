# Feature 008 契约

## 仓储

```text
BackupRepository
  exportBackup(destinationFile, cancellationToken?, onProgress?)
    -> Future<BackupExportReport>
  inspectBackup(sourceFile, mode, cancellationToken?, onProgress?)
    -> Future<BackupImportPreview>
  importBackup(sourceFile, mode, cancellationToken?, onProgress?)
    -> Future<BackupImportReport>
```

`BackupMode.emptyLibrary` 只接受空业务库；`BackupMode.mergeAddOnly` 只新增、跳过相同、
阻断冲突。`inspectBackup` 是只读契约。`importBackup` 必须重新验证，不能信任过期预览。

## 平台文件选择

```text
BackupFilePicker
  chooseExportPath(suggestedName) -> Future<String?>
  publishExport(path) -> Future<bool>
  chooseImportPath() -> Future<String?>
```

返回 `null` 或 `false` 表示用户取消。桌面端由保存选择器确定最终路径；移动端先写入
App 临时目录，再通过系统分享面板发布，成功发布的临时文件在下一次导出前清理。
平台选择器不解析备份内容。

## 进度与取消

阶段为 `preparing`、`readingDatabase`、`checkingImages`、`writingArchive`、
`validatingArchive`、`validatingData`、`stagingImages`、`committing`、`completed`。
进度在 `0..1`。取消在进入 `committing` 前抛出 `BackupCancelledFailure`；提交期间忽略取消。

## 错误

- `BackupValidationFailure`：包损坏、超限、路径、关系、冲突或目标状态不合法；
- `BackupCompatibilityFailure`：格式版本不受支持；
- `BackupStorageFailure`：读取、临时空间、目标写入或图片提交失败；
- `BackupCancelledFailure`：用户主动取消。

所有用户文案脱敏；`cause` 不渲染、不记录内容和绝对路径。

## 幂等与事务

重复导出只产生新的创建时间，不修改库。相同备份重复合并时全部跳过。每次导入都重新
验证；数据库写入为单事务，图片 staging 失败不开始事务，提交失败执行数据库回滚与
本批次文件补偿。
