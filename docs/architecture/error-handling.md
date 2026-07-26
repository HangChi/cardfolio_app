# 错误处理规范

状态：M0 基线
日期：2026-07-26
关联需求：NFR-UX-002、NFR-DATA-001、NFR-OBS-001

## 1. 原则

- 领域和 UI 只处理稳定错误类型，不依赖 SQLite、平台通道或云 SDK 文案。
- 错误必须说明发生了什么、数据是否安全、用户能做什么。
- 可恢复错误提供重试或替代路径。
- 数据完整性错误优先保护原数据，不自动清库。
- 日志不得包含图片、自由备注、卖家联系方式、令牌或导出内容。

## 2. 错误分类

| 分类 | 例子 | UI 行为 | 日志级别 |
|---|---|---|---|
| ValidationFailure | 名称为空、数量小于 1 | 字段级提示 | 默认不记录 |
| Cancelled | 取消选图、取消导出 | 静默返回或轻提示 | 不记录 |
| PermissionFailure | 相机/照片权限拒绝 | 说明用途、重试、设置入口 | info |
| ImageImportFailure | 文件不可读、格式异常 | 保留上下文、重新选择 | warning |
| StorageFailure | 空间不足、复制失败 | 阻止保存、说明数据未创建 | error |
| PersistenceFailure | 事务或查询失败 | 保留输入、允许重试 | error |
| MigrationFailure | schema 升级失败 | 阻断启动、保留原库 | critical |
| IntegrityFailure | 校验值或关联不一致 | 隔离数据、停止危险操作 | critical |
| NetworkFailure | 无网、超时 | 本地继续、同步稍后重试 | info/warning |
| AuthenticationFailure | 令牌失效 | 暂停同步、要求重新认证 | warning |
| SyncConflict | 无法自动合并 | 保留双方、进入冲突处理 | warning |
| ExportImportFailure | 清单错误、版本不支持 | 不修改现有库、给出报告 | warning/error |
| UnexpectedFailure | 未分类异常 | 通用恢复提示和错误编号 | error |

## 3. 稳定错误契约

每个 `AppFailure` 至少包含：

- `code`：稳定机器码；
- `userMessage`：不暴露内部信息的中文文案；
- `recoverability`：retry、alternative、settings、support、none；
- `cause`：仅供日志和调试；
- `context`：非敏感操作阶段和实体类型；
- `correlationId`：一次操作的匿名关联 ID。

UI 不根据 `cause.runtimeType` 决定行为。

## 4. 页面状态

所有数据页面具备：

- `initial`
- `loading`
- `data`
- `empty`
- `recoverableError`
- `blockingError`

写操作额外具备：

- `editing`
- `submitting`
- `success`
- `failure`

保存期间禁止重复提交，但允许系统返回和无损恢复输入。

## 5. 一致性失败

### 数据库打开/迁移

- 不自动删除数据库；
- 展示重试；
- 记录版本、阶段和匿名错误；
- 提供后续导出诊断能力；
- 只有用户明确执行恢复操作才允许替换数据库。

### 文件与数据库

- 文件先写时，数据库失败补偿删除；
- 数据库先写时，文件失败必须回滚或记录不可见恢复状态；
- 进程中断由启动恢复扫描处理；
- 无法判断安全性的文件进入 quarantine。

### 导入

- 验证完成前不修改现有收藏；
- 合并在事务批次中执行；
- 任一阻断错误回滚整个批次；
- 返回逐项报告但不泄露敏感字段。

## 6. 用户文案模板

| 场景 | 标题 | 行动 |
|---|---|---|
| 图片不可读 | 无法读取这张图片 | 重新选择 |
| 空间不足 | 设备空间不足 | 管理空间 / 取消 |
| 保存失败 | 暂时无法保存，已保留填写内容 | 重试 |
| 数据库失败 | 无法打开收藏库，现有数据未被删除 | 重试 |
| 权限拒绝 | 需要访问你选择的照片 | 重新授权 / 系统设置 |
| 版本不支持 | 这个备份版本暂不支持 | 查看详情 / 取消 |
| 同步冲突 | 发现两个不同版本 | 稍后处理 / 查看冲突 |

## 7. 测试门禁

- 每个错误分支至少有一项自动化测试；
- 补偿失败也有测试和可观测记录；
- Widget 测试验证原因与下一步操作同时出现；
- 日志测试验证敏感字段被排除；
- 迁移、导入和同步错误具备真实存储集成测试。
