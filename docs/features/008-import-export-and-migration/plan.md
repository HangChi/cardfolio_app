# Feature 008 实施计划

> 本计划在当前会话内联执行；禁止创建分支、禁止子智能体、禁止启动模拟器；全部完成后
> 只提交一次。

## 技术栈与全局约束

Flutter、Riverpod、go_router、Drift/SQLite、`archive`、`file_picker`、
`share_plus`。所有生产行为先写失败测试并确认正确失败。格式版本和安全限制以
`spec.md` 为准。

## 任务 1：格式领域与安全校验

**文件：** 新增 `lib/features/backup/domain/backup_models.dart`、
`lib/features/backup/data/backup_archive.dart` 及对应测试。

1. 写版本、路径、条目限制、清单与取消失败测试并运行到预期失败。
2. 实现值对象、失败类型、SHA 校验和 ZIP 目录安全检查。
3. 运行目标测试到通过并消除重复。

## 任务 2：逻辑快照与全实体验证

**文件：** 新增 `backup_snapshot.dart`、`backup_database.dart` 及对应测试。

1. 写 17 表全实体序列化、稳定排序、关系断裂和金额保真失败测试。
2. 实现显式逻辑 DTO、数据库读写顺序、空库检查和 add-only 合并预览。
3. 运行目标测试到通过。

## 任务 3：导出、检查与原子导入

**文件：** 新增 repository 接口/实现、providers、文件 staging 组件及对应测试。

1. 写全实体 ZIP 往返、缺图/篡改、取消、重复导入和提交故障失败测试。
2. 实现临时目录、归档、重新验证、图片 staging、数据库事务与补偿。
3. 运行 Feature 数据/仓储测试到通过。

## 任务 4：文件选择与 UI

**文件：** 新增平台选择器与 `backup_screen.dart`；修改 router、bootstrap、设置页。

1. 写选择器取消、隐私说明、进度、预览/冲突/报告和路由失败测试。
2. 实现最小交互、Riverpod 注入和脱敏反馈。
3. 运行 Widget/App 测试到通过。

## 任务 5：验证、文档与提交

1. 运行格式检查、Feature 测试、完整 `flutter test`、`flutter analyze`。
2. 更新测试矩阵、任务、Feature 索引、README、追踪矩阵和开发日志。
3. 检查 `git diff`，确认无模拟器产物和无用户既有改动。
4. 暂存并提交一次完整变更。
