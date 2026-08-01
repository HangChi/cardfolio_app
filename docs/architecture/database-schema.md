# 数据库模型与迁移规范

状态：schema v8
更新日期：2026-08-01
实现：Drift + SQLite

## 1. 核心约定

- 核心实体使用本地 UUID；时间由应用时钟生成并按 UTC 语义存储。
- 可同步实体包含 `version`、`created_at`、`updated_at`；可软删除实体包含 `deleted_at`。
- 金额使用最小货币单位整数；卡片直接录入成本固定使用 CNY 分，不使用二进制浮点数。
- 图片表只保存受管根目录下的相对路径和 SHA-256，不保存系统相册绝对路径。
- SQLite 开启外键；永久删除由专用事务显式按依赖顺序执行，不依赖无条件级联掩盖规则。

## 2. 当前 21 张表

### 收藏核心

| 表 | 作用 | 关键字段/约束 |
|---|---|---|
| `card_definitions` | 同款卡片的公共资料 | name、city、issuer、issued_at、code、notes、card_type、needs_completion、version、deleted_at |
| `card_items` | 实际持有的藏品实例 | definition_id、quantity > 0、acquired_at、version、deleted_at |
| `card_images` | 藏品的原图与活动派生图 | kind、relative_path(unique)、derived_relative_path、sort_order、is_cover、checksum、deleted_at |

品相、发行数量、发售价等保留扩展字段通过自定义字段定义/值保存，以避免为用户可扩展资料
频繁迁移 schema。创建与编辑层会过滤这些保留字段，防止重复创建同名定义。

### 套卡、集卡册与整理

| 表 | 作用 | 关键字段/约束 |
|---|---|---|
| `card_sets` | 有成员清单和完成度的套卡 | expected_count、count_known、issue_info、notes、cover_image_id、deleted_at |
| `card_set_members` | 套卡期望款式 | set_id、definition_id、member_no、required、sort_order、deleted_at |
| `tags` | 标签定义 | name、normalized_name、version、deleted_at |
| `card_tags` | 标签到卡片款式 | tag_id + definition_id 组合主键 |
| `series_records` | 当前 UI 中的“集卡册” | name、description、cover_relative_path、version、deleted_at |
| `series_cards` | 集卡册到卡片款式 | series_id + definition_id 组合主键 |
| `series_sets` | 集卡册到套卡 | series_id + set_id 组合主键 |
| `custom_field_definitions` | 文本/数字/日期字段定义 | normalized_name、field_type、version、deleted_at |
| `custom_field_values` | 款式的字段值 | field_id + definition_id；三种值列必须且只能有一个非空 |

集卡册详情和关联计数只展示至少存在一个未删除实体卡的款式；软删除时保留关系，恢复后关系
自动重新可见。套卡成员是应收集定义，不因实体卡删除而移除。

### 成本账本

| 表 | 作用 | 关键字段/约束 |
|---|---|---|
| `purchases` | 支付/退款事实 | purchased_at、amount_minor、currency、shipping_minor、fees_minor、adjustment_of_id |
| `purchase_items` | 成本到卡片/套卡的目标与名称快照 | purchase_id + target_type + target_id；allocated_minor |
| `exchange_rates` | 可选精确历史汇率 | base/quote/date/source 组合主键；numerator/denominator > 0 |

当前 UI 不提供独立购买列表和多币种录入；新建/编辑卡片会以稳定 ID
`card-entry-cost:<cardItemId>` 更新一条 CNY 成本记录，包含卡片金额和运费。旧账本结构继续保留，
以保证既有数据、备份和同步兼容。

### 回收站和文件清理

| 表 | 作用 | 关键字段/约束 |
|---|---|---|
| `recycle_bin_settings` | 单例保留期设置 | id = 1；retention_days ∈ 7/30/90 |
| `file_cleanup_queue` | 失败后可重试的相对路径删除 | relative_path 主键、attempt_count、last_attempt_at |

### 本地优先同步

| 表 | 作用 | 关键字段/约束 |
|---|---|---|
| `sync_settings` | 设备、账号、开关、增量游标和最近错误 | 单例 id = 1 |
| `sync_entity_states` | 最近确认的云端基线 | entity_type + entity_id、server_version、payload/deleted |
| `sync_outbox` | 每实体合并后的待发操作 | operation_id；entity 唯一索引；重试到期索引 |
| `sync_conflicts` | 未静默覆盖的双方副本 | local/remote operation + payload、conflicting_fields、resolved_at |

非数据库应用状态（引导完成、主题、诊断开关、兼容保留的旧筛选、批量草稿）保存在
`app-state.json`，不参与 Drift 迁移。

## 3. Schema 版本历史

| 版本 | 主要变化 |
|---:|---|
| 1 | 卡片定义、实体和单图基础 |
| 2 | 多图、用途、派生图、封面和图片软删除 |
| 3 | 套卡与成员 |
| 4 | 标签、集卡册（历史名 series）、自定义字段和查询索引 |
| 5 | 购买、目标快照和汇率 |
| 6 | 回收站设置与文件清理队列 |
| 7 | 同步设置、云端基线、outbox 和冲突副本 |
| 8 | 集卡册自定义封面相对路径 |

每次 schema 变化必须更新 `drift_schemas/app/` 快照、生成代码和迁移测试。发布构建禁止以
删库重建作为失败兜底。

## 4. 关键事务

- 建卡：款式、实例、图片元数据、整理关系与成本分别通过稳定 ID 编排，失败保留可重试草稿。
- 图片：文件先准备；数据库写入失败时补偿本批次文件。删除图片前清理套卡和集卡册封面引用。
- 套卡/集卡册：保存成员使用单事务；编辑集卡册时保留当前因回收站而隐藏的成员关系。
- 标签合并/删除、自定义字段删除：先生成影响预览，再以单事务迁移或清理关系。
- 永久删卡：事务内写文件清理意图并删除依赖数据；文件系统失败不回滚业务删除，改由队列重试。
- 导入：完整校验和文件 staging 先于数据库合并；冲突或失败时不留下部分可见数据。
- 同步：本地业务变更和 outbox 意图保持同一持久边界；网络失败只更新重试状态。

## 5. 查询口径

- 默认收藏、集卡册成员、标签计数、自定义字段计数、首页、统计和消费排除软删除实体。
- 重复卡：同一 `definition_id` 下未删除实体的 `quantity` 总和大于 1。
- “本月新增”：按设备本地自然月换算成 UTC 的 `acquired_at` 起始包含/结束不包含区间。
- 城市统计和筛选归一到市级，不把县/区拆成独立桶。
- 总卡片数：全部活跃实例 `quantity` 之和。
- 总花费：全部活跃收藏关联账本的人民币净额，含运费/手续费口径并扣除退款；删除后排除，恢复后重计。
