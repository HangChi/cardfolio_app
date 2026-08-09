# Feature 003 数据模型

## 1. CardSet

| 字段 | 类型 | 约束 |
|---|---|---|
| `id` | text UUID | 主键 |
| `name` | text | 1..100 |
| `expectedCount` | nullable integer | 已知时大于 0 |
| `countKnown` | bool | 未知时 expected 为空 |
| `issueInfo` | nullable text | 最多 1000 |
| `notes` | nullable text | 最多 1000 |
| `coverImageId` | nullable text UUID | 活跃成员图片 |
| `coverRelativePath` | nullable text | schema v9 独立受管封面；优先展示 |
| `version` | integer | 至少 1 |
| `createdAt/updatedAt` | UTC timestamp | 必填 |
| `deletedAt` | nullable UTC timestamp | Feature 007 使用 |

## 2. CardSetMember

| 字段 | 类型 | 约束 |
|---|---|---|
| `id` | text UUID | 主键 |
| `setId` | text UUID | 外键、索引 |
| `definitionId` | text UUID | 外键 |
| `memberNo` | nullable text | 最多 100 |
| `required` | bool | 默认 true |
| `sortOrder` | integer | 活跃成员内连续 |
| `version` | integer | 至少 1 |
| `createdAt/updatedAt` | UTC timestamp | 必填 |
| `deletedAt` | nullable UTC timestamp | 移除成员时写入 |

活跃 `(setId, definitionId)` 使用部分唯一索引；同一套卡可在历史中保留已移除关系。

## 3. schema v2 → v3

只新增 `card_sets` 和 `card_set_members` 两张表及索引，不修改 v2 卡片和图片行。升级失败保留原数据库，不清库。

### schema v8 → v9

为 `card_sets` 新增可空 `cover_relative_path`。旧数据保持 `cover_image_id` 语义；读取时独立
封面优先，否则回退到仍有效的成员图片。迁移不得提前执行到 Drift 请求的中间目标版本，
并由 v1–v8 到 v9 的分步迁移测试覆盖。

## 4. 完成度查询

以套卡成员左连接活跃 `CardItem`：

- `ownedQuantity = SUM(active CardItem.quantity)`；
- `ownedRequired = COUNT(required member WHERE ownedQuantity > 0)`；
- `requiredTotal = COUNT(required member)`；
- `missingRequired = requiredTotal - ownedRequired`；
- `duplicateMembers = COUNT(member WHERE ownedQuantity > 1)`。

已知总数且 `requiredTotal > 0` 时，`progress = ownedRequired / requiredTotal`，`isComplete = ownedRequired == requiredTotal`；未知总数时两者均为空。
