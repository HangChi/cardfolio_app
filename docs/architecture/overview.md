# 卡迹总体架构

状态：M0 基线
日期：2026-07-26

## 1. 架构目标

卡迹是本地优先的 Flutter 移动应用。架构优先保证：

- 无账号、无网络仍可完成核心收藏操作；
- 卡片、套卡、购买和图片规则可以独立测试；
- 数据库、文件系统、相册、相机和未来云服务可替换；
- Android 与 iOS 共享业务行为；
- 数据迁移、导出和同步不会绕过业务不变量。

## 2. 分层

```text
Presentation
  Screens / Widgets / Controllers / UI State
                  │
                  ▼
Domain
  Entities / Value Objects / Repository Contracts / Rules
                  │
                  ▼
Data
  Repository Implementations / Drift / Files / Platform Plugins
                  │
                  ▼
Platform & External
  SQLite / App Storage / Photo Picker / Camera / Cloud
```

依赖方向只允许向内：

- Domain 不依赖 Flutter Widget、Drift、平台插件或云 SDK。
- Presentation 依赖 Domain 契约，不直接执行 SQL 或文件操作。
- Data 实现 Domain 契约，负责外部异常映射和一致性补偿。
- App 层负责依赖注入、路由、主题和启动门禁。

## 3. 推荐目录

```text
lib/
├── app/
│   ├── bootstrap/
│   ├── navigation/
│   ├── cardfolio_app.dart
│   ├── app_router.dart
│   └── app_theme.dart
├── core/
│   ├── errors/
│   ├── id/
│   ├── money/
│   └── time/
└── features/
    ├── cards/
    ├── images/
    ├── sets/
    ├── organization/
    ├── purchases/
    ├── dashboard/
    ├── recycle_bin/
    ├── transfer/
    └── sync/
```

每个 Feature 内按 `domain/`、`data/`、`presentation/` 组织；跨 Feature 的稳定值对象放入 `core/`。

## 4. 运行时数据流

### 本地读取

```text
Drift query stream
→ Repository maps rows
→ Domain read model
→ Riverpod provider/controller
→ Widget render
```

### 本地写入

```text
User action
→ Controller validation and save guard
→ Repository command
→ File operation + Drift transaction + compensation
→ Local success
→ Reactive query refresh
→ UI navigation or confirmation
```

### 未来同步

```text
Local transaction
→ business rows + durable sync operation
→ background sync worker
→ service acknowledgement/version
→ local sync status update
```

云端失败不得回滚已经成功的本地用户操作。

## 5. 关键组件

| 组件 | 职责 | 禁止承担 |
|---|---|---|
| Screen/Widget | 布局、语义、输入转发 | 业务规则、SQL |
| Controller/ViewModel | UI 状态、校验触发、操作编排 | 具体数据库结构 |
| Domain entity/value | 不变量和业务含义 | Flutter/platform 类型 |
| Repository contract | 用例需要的读写接口 | 具体存储选择 |
| Repository implementation | 事务、映射、补偿 | 展示文案布局 |
| Drift database | schema、索引、迁移、查询 | UI 状态 |
| Managed image store | 文件导入、解析、校验、清理 | 业务实体决策 |
| Sync engine | 队列、幂等、重试、冲突 | 本地保存成功判定 |

## 6. 启动门禁

启动顺序：

1. Flutter binding；
2. 应用支持目录；
3. 数据库打开和迁移；
4. 图片目录初始化；
5. 文件一致性恢复；
6. 依赖注入容器；
7. 路由和 UI。

任一步失败时展示可重试的阻断状态。禁止静默删除数据库或重新生成空收藏库。

## 7. 跨平台边界

- 业务层和数据库 schema 在 Android/iOS 一致。
- 权限、选择器、相机、安全存储等差异封装为平台适配器。
- 平台适配器返回稳定 Domain 结果或 `AppFailure`。
- Android 先验收不等于允许引入 Android 专属业务分支。

## 8. 架构验证

每个 Feature 评审时检查：

- UI 是否直接依赖 Data 实现；
- 业务层是否导入 Flutter、Drift 或平台 SDK；
- 写操作是否有事务和跨文件补偿；
- 默认查询是否一致处理软删除；
- 时间、UUID、汇率和外部服务是否可注入测试；
- 规格、测试和需求 ID 是否可追溯。
