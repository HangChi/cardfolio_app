# 数据库模型与迁移规范

状态：schema v4 已实现
日期：2026-07-28
存储实现：Drift + SQLite

## 1. 通用列

所有核心表遵循：

| 列 | 类型 | 规则 |
|---|---|---|
| id | TEXT | UUID 主键 |
| created_at | INTEGER | UTC epoch，非空 |
| updated_at | INTEGER | UTC epoch，非空 |
| version | INTEGER | 非空，默认 1，至少 1 |
| deleted_at | INTEGER | 可空，仅可删除实体 |

金额使用最小货币单位整数；部分日期使用规范化文本；布尔值使用受约束整数。

## 2. 逻辑表

### cards

| 表 | 关键列 | 约束/索引 |
|---|---|---|
| card_definitions | name, type, city, issuer, issued_at, issue_quantity, issue_price_minor, issue_currency, code, notes, needs_completion | name 非空；issue_quantity > 0；索引 name/city/issuer/issued_at/deleted_at |
| card_items | definition_id, quantity, condition, acquired_at, notes | FK definition；quantity >= 1；索引 definition_id/deleted_at |
| card_images | card_item_id, kind, relative_path, derived_relative_path, checksum, sort_order, is_cover, deleted_at | FK item；原图/派生图路径唯一；每个 item 最多一个活跃封面；索引 item/sort/deleted |

### organization

| 表 | 关键列 | 约束/索引 |
|---|---|---|
| card_sets | name, expected_count, count_known, issue_info, notes, cover_image_id, version, deleted_at | count_known=false 时 expected_count 为空；已知时 expected_count > 0；索引 created_at/deleted_at |
| card_set_members | set_id, definition_id, member_no, required, sort_order, version, deleted_at | FK set/definition；活跃 set+definition 部分唯一；索引 set、set+sort、deleted_at |
| series_records | name, description, version, deleted_at | 活跃系列按更新时间与 ID 稳定排序 |
| series_cards | series_id, definition_id, created_at | FK series/definition；组合主键 |
| series_sets | series_id, set_id, created_at | FK series/set；组合主键 |
| tags | name, normalized_name, version, deleted_at | 活跃 normalized_name 部分唯一 |
| card_tags | tag_id, definition_id, created_at | FK tag/definition；组合主键 |
| custom_field_definitions | name, normalized_name, field_type, version, deleted_at | 活跃名称部分唯一；field_type 限 text/number/date |
| custom_field_values | field_id, definition_id, text_value, number_value, date_value, updated_at | field+definition 组合主键；由仓储保证值类型匹配 |

### purchases

| 表 | 关键列 | 约束/索引 |
|---|---|---|
| purchases | purchased_at, amount_minor, currency, shipping_minor, fees_minor, channel, seller, notes, adjustment_of_id | 币种非空；普通购买 amount >= 0；调整允许负值 |
| purchase_items | purchase_id, target_type, target_id, allocated_minor | FK purchase；组合索引 |
| exchange_rates | base_currency, quote_currency, rate_date, numerator, denominator, source | 精确比率；组合唯一 |

### lifecycle and sync

| 表 | 关键列 | 约束/索引 |
|---|---|---|
| export_history | schema_version, manifest_checksum, destination_type, completed_at | 仅存元数据，不存外部路径凭证 |
| sync_records | entity_type, entity_id, operation, idempotency_key, entity_version, status, retry_count, next_attempt_at | idempotency_key 唯一 |
| sync_conflicts | entity_type, entity_id, local_payload, remote_payload, detected_at, resolved_at | 未解决索引 |
| app_metadata | key, value | key 主键 |

## 3. 外键与删除

- SQLite 启用 `PRAGMA foreign_keys = ON`。
- 默认不使用级联物理删除掩盖业务流程。
- 软删除由应用事务设置 `deleted_at`。
- 永久删除在专用用例中显式按依赖顺序执行。
- 文件删除发生在数据库确定不再引用之后，并具备失败重试记录。

## 4. 查询索引

MVP 必须覆盖：

- 活跃卡片按创建时间分页；
- 名称、编号、城市、机构和备注搜索；
- 标签、类型、年份、套卡状态、重复和待补全筛选；
- 套卡完成度聚合；
- 标签、系列和自定义字段关系写入：同一事务；
- 标签合并：迁移全部关联并软删除源标签，同一事务；
- 卡片整理信息（类型、入手日期、待完善、标签、系列、字段值）：同一事务；
- 购买按时间、币种和目标查询；
- 默认查询的 `deleted_at IS NULL`；
- 同步状态与重试时间。

索引以真实查询计划和性能测试验证，不为未出现的查询提前建立冗余索引。

## 5. 迁移策略

1. `schemaVersion` 从 1 单调增加。
2. 每个版本保存 Drift schema 快照。
3. 每次变更提供从所有受支持旧版本到新版本的迁移测试。
4. 迁移前不删除用户文件。
5. 迁移失败保留原数据库，并展示可重试错误。
6. 破坏性变更采用新列/新表、回填、验证、后续版本清理的分阶段方式。
7. 发布构建禁止使用自动清库作为迁移兜底。

## 6. 事务边界

- 卡片款式、实例和图片元数据：同一事务。
- 套卡及成员批量调整：同一事务。
- 删除被套卡引用的图片时，同一事务先清空 `card_sets.cover_image_id`，再软删或物理删除图片。
- 购买及购买项目：同一事务。
- 业务实体变更及同步记录：同一事务。
- 导入：先在隔离数据库或暂存表验证，最终合并为可回滚事务批次。

## 7. 备份兼容

导出清单包含：

- `schemaVersion`
- App 版本
- 导出时间
- 实体计数
- 每个文件的相对路径、大小和 SHA-256
- 数据文件校验值

导入器必须明确支持的 schema 范围，不得尝试猜测未知格式。
