# Feature 007 实施计划

> 本计划在当前会话内联执行；禁止创建分支、禁止子智能体、禁止启动模拟器。

## 目标与架构

以 `card_items.deleted_at` 作为回收站根状态，新增 Drift 设置表与持久化文件清理队列。`RecycleBinRepository` 组合数据库事务、受管图片存储和时钟；UI 通过 Riverpod 订阅仓储，详情页只负责发起软删除，回收站页负责恢复、预览、永久删除和保留期配置。

## 技术栈与全局约束

- Flutter、Riverpod、go_router、Drift/SQLite。
- 所有新行为先写失败测试并确认失败原因，再写最小实现。
- 只执行内存 SQLite、单元、Widget 和静态分析，不启动模拟器。
- 永久删除必须先在数据库事务内持久化文件清理意图。

## 任务 1：领域与数据库回收站查询

**文件：** 新增 `lib/features/recycle_bin/domain/recycle_bin_models.dart`、`lib/features/recycle_bin/data/local/recycle_bin_database.dart`；修改 `card_database.dart`；新增对应 domain/database 测试。

1. 写保留期验证、剩余天数、软删除/恢复和列表排序失败测试。
2. 运行目标测试，确认因类型/API 缺失失败。
3. 实现领域模型、schema v6、设置表、队列表和基础事务。
4. 生成 Drift 代码并运行目标测试至通过。

## 任务 2：永久删除、队列与自动过期

**文件：** 修改数据库扩展、`ManagedImageStore`；新增队列和到期测试。

1. 写影响计数、定义保留、购买目标清理、路径去重和到期边界失败测试。
2. 运行目标测试，确认行为断言失败。
3. 实现永久删除事务、队列 API 和过期 ID 查询。
4. 运行目标测试至通过并重构重复 fixture。

## 任务 3：仓储与启动恢复

**文件：** 新增 repository 接口/实现/providers；修改 `app_bootstrap.dart`；新增仓储和启动测试。

1. 写软删除/恢复、文件成功出队、失败留队和启动自动清理失败测试。
2. 运行并确认预期失败。
3. 实现仓储错误映射、文件队列 drain、`purgeExpired` 和启动调用。
4. 运行目标测试至通过。

## 任务 4：UI 与路由

**文件：** 新增 `recycle_bin_screen.dart`；修改详情、设置页和路由；新增 Widget/App 测试。

1. 写详情删除确认、回收站空/列表/恢复/永久删除/保留期与路由失败测试。
2. 运行并确认预期失败。
3. 实现最小交互和安全反馈。
4. 运行 Widget/App 测试至通过。

## 任务 5：全量验证与文档

1. 运行格式化检查、Feature 目标测试、完整 `flutter test` 和 `flutter analyze`。
2. 更新测试矩阵、任务状态、Feature 索引、README 与开发日志。
3. 检查 `git diff`、确认不含用户既有改动或生成垃圾。
4. 暂存并提交一次完整变更。
