# 卡迹总体架构

状态：当前实现基线
更新日期：2026-08-09

## 1. 架构目标

卡迹是本地优先的 Flutter 应用。架构首先保证无账号、无网络仍能完成收藏全流程，其次
才通过可替换 REST 协议提供同步。数据库和 App 私有文件是本地事实来源；云端失败不能
撤销已经成功的本地写入。

## 2. 技术栈

| 层面 | 实现 |
|---|---|
| UI | Flutter Material 3、亮暗主题、响应式手机/宽屏导航 |
| 状态与依赖注入 | Riverpod 3，手写 Provider/Notifier |
| 路由 | go_router，`StatefulShellRoute.indexedStack` 保留五入口状态 |
| 本地数据 | Drift 2 + SQLite，schema v9 |
| 文件 | `path_provider` 应用支持目录、受管原图/派生图、SHA-256 |
| 图片输入/编辑 | image_picker、image_cropper、`image` isolate 处理 |
| 导入导出 | archive、file_picker、share_plus |
| 网络与账号 | http、flutter_secure_storage、可替换 REST v1 |
| OCR | Android ML Kit/iOS Vision MethodChannel 桥接已接入；当前运行时不可用，待诊断与真机验收 |

## 3. 分层与依赖方向

```text
Presentation (Screen / Widget / Controller / Provider)
                         │
                         ▼
Domain (Model / Value / Repository interface / Rule)
                         │
                         ▼
Data (Repository impl / Drift query / File store / Adapter)
                         │
                         ▼
Platform & External (SQLite / filesystem / camera / OCR / REST)
```

- Domain 不依赖 Widget、Drift 行、XFile 或平台通道。
- Presentation 依赖领域契约和 Provider，不直接拼 SQL 或删除文件。
- Data 层负责行映射、事务、文件补偿、异常到 `AppFailure` 的转换。
- App 层只负责启动门、依赖注入、主题、路由和主导航。

## 4. 当前目录

```text
lib/
├── app/                    # 启动门、路由、主题、五入口壳
├── core/                   # 错误、UUID、时间、本地偏好、共用 UI
└── features/
    ├── cards/              # 卡片、多图、拍摄、编辑、OCR、批量录入
    ├── card_sets/          # 套卡、成员与完成度
    ├── organization/       # 标签、集卡册、自定义字段、搜索筛选
    ├── purchases/          # 精确金额与卡片成本账本
    ├── dashboard/          # 首页、统计、消费趋势和消费日历
    ├── recycle_bin/        # 软删除、恢复、永久删除、文件清理队列
    ├── backup/             # 版本化 ZIP 备份、校验、恢复与合并
    ├── export/             # CSV 导出
    ├── settings/           # 引导、主题、权限/存储/诊断设置
    └── sync/               # 账号、安全会话、outbox、游标和冲突
```

## 5. 启动流程

```text
WidgetsFlutterBinding
→ 应用支持目录/cardfolio
→ 读取 app-state.json
→ 清空可重建的 backup-work / image-processing-work
→ 后台打开 cardfolio.sqlite 并执行迁移
→ 初始化受管图片、仓储、回收站、备份和同步适配器
→ 恢复安全会话并按配置静默继续同步
→ 清理到期回收站与持久文件清理队列
→ 读取数据库图片引用并清理孤儿文件
→ ProviderScope 注入依赖
→ 首次使用进入引导，否则进入首页
```

任何阻断失败都展示可重试启动页；数据库打不开时不删除或重建原文件，也不扫描删除图片。

## 6. 典型数据流

### 响应式读取

```text
Drift watch query → Data read model → Riverpod StreamProvider → Widget
```

卡片、套卡、集卡册、统计和同步状态均使用响应式查询。默认业务查询必须显式排除
`deleted_at IS NOT NULL`；回收站使用独立查询。

### 本地写入

```text
用户操作 → UI 校验/防重复 → Repository command
→ 文件暂存/复制 → Drift transaction → 失败补偿
→ 查询流自动刷新 → 导航或反馈
```

建卡使用稳定 UUID 作为幂等键；跨数据库与文件系统的写入采用“文件准备 + 数据库事务 +
失败补偿”，永久删除则先写入可重试的清理意图。

### 同步

```text
本地业务事务 → sync_outbox
→ 上传附件并校验 → REST push/pull(cursor)
→ 三方合并或 sync_conflicts → 更新云端基线
```

未配置 `CARD_FOLIO_API_BASE_URL` 时使用不可用远端适配器，但不影响任何本地能力。

## 7. 跨 Feature 一致性

- 卡片软删除后从收藏、集卡册可见成员、标签计数、统计和消费中排除；恢复后重新计入。
- 套卡成员表示“应收集款式”，实体卡删除只把拥有数量降为零，不删除套卡定义。
- 硬删图片前清理套卡/集卡册封面引用；文件删除失败进入持久队列。
- 卡片成本使用 `purchases` 表的稳定内部记录，UI 在卡片新建/编辑页维护，金额为人民币分。
- `series_*` 是兼容历史 schema 的存储名，当前产品语义是“集卡册”。

## 8. 当前发布边界

宿主机自动化不能代替相机、相册、OCR、系统裁剪、HEIC、分享、低存储、无障碍、
大字体、真实 ZIP 往返和双设备同步验收。生产同步服务、RLS、监控、回滚和商店签名仍需
独立完成。
