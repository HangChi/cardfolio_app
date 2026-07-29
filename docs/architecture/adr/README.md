# 架构决策记录索引

状态：M0 基线
日期：2026-07-26

| ADR | 决策 | 状态 |
|---|---|---|
| [ADR-001](./ADR-001-flutter-feature-first-architecture.md) | Flutter 功能优先分层架构 | Accepted |
| [ADR-002](./ADR-002-riverpod-state-management.md) | Riverpod 状态管理与依赖注入 | Accepted |
| [ADR-003](./ADR-003-drift-sqlite.md) | Drift/SQLite 本地持久化 | Accepted |
| [ADR-004](./ADR-004-go-router.md) | go_router 声明式路由 | Accepted |
| [ADR-005](./ADR-005-managed-image-storage.md) | App 私有目录管理图片 | Accepted |
| [ADR-006](./ADR-006-uuid-time-versioning.md) | UUID、UTC 时间和实体版本 | Accepted |
| [ADR-007](./ADR-007-local-first-sync-boundary.md) | 本地优先同步边界 | Accepted |
| [ADR-008](./ADR-008-local-image-processing-pipeline.md) | 系统相机与本地图片处理管线 | Accepted |

状态定义：

- Proposed：已形成方案，尚未进入实现基线。
- Accepted：后续实现必须遵守。
- Superseded：被新的 ADR 替代，保留历史。
- Rejected：评估后不采用。

ADR 修改结论时新增 ADR 或明确 `Superseded by`，不重写历史理由。
