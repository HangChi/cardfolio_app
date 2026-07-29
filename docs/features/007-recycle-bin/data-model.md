# Feature 007 数据模型

## 既有列

`card_items.deleted_at` 作为回收站根标记。软删除不修改关联表，因此恢复只需清空该列并更新 `updated_at` 与 `version`。

## `recycle_bin_settings`

| 列 | 类型 | 约束 |
|---|---|---|
| `id` | INTEGER | 主键，固定为 1 |
| `retention_days` | INTEGER | 仅 7、30、90，默认 30 |
| `updated_at` | DATETIME | UTC |

没有设置行时读取默认 30 天；首次修改使用 upsert。

## `file_cleanup_queue`

| 列 | 类型 | 约束 |
|---|---|---|
| `relative_path` | TEXT | 主键，受管目录相对路径 |
| `created_at` | DATETIME | UTC |
| `attempt_count` | INTEGER | 非负，默认 0 |
| `last_attempt_at` | DATETIME? | UTC |

永久删除事务先写队列再删除图片行。每次清理失败递增 `attempt_count` 并记录时间，成功或文件不存在则删除队列行。

## 派生领域模型

`RecycleBinEntry` 包含藏品 ID、名称、封面相对路径、删除时间、图片数和剩余天数。`PermanentDeletionImpact` 包含图片行数、唯一文件数和购买目标关联数。

## 迁移

Schema v5 → v6 仅创建两张新表及队列创建时间索引，不改写既有卡片数据。
