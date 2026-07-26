# Feature 001 数据模型

## 1. CardDefinition

| 字段 | 类型 | 约束 |
|---|---|---|
| `id` | text UUID | 主键 |
| `name` | text | 去空白后非空 |
| `city` | nullable text | 空字符串转 null |
| `issuer` | nullable text | 空字符串转 null |
| `issuedAt` | nullable text | `YYYY`、`YYYY-MM` 或 `YYYY-MM-DD` |
| `code` | nullable text | 业务编号 |
| `notes` | nullable text | 用户备注 |
| `createdAt` / `updatedAt` | UTC timestamp | 必填 |

## 2. CardItem

| 字段 | 类型 | 约束 |
|---|---|---|
| `id` | text UUID | 主键、创建幂等键 |
| `definitionId` | text UUID | 外键 |
| `quantity` | integer | `> 0`，初始 1 |
| `createdAt` / `updatedAt` | UTC timestamp | 必填 |
| `deletedAt` | nullable UTC timestamp | Feature 001 恒为 null |

## 3. CardImage

| 字段 | 类型 | 约束 |
|---|---|---|
| `id` | text UUID | 主键 |
| `cardItemId` | text UUID | 外键 |
| `kind` | text enum | Feature 001 为 `front` |
| `relativePath` | text | 唯一、根目录内 |
| `sortOrder` | integer | Feature 001 为 0 |
| `checksum` | text | SHA-256 |
| `createdAt` | UTC timestamp | 必填 |

## 4. 索引与删除

- 为 `CardItem.definitionId`、`CardImage.cardItemId`、`CardItem.deletedAt` 建索引。
- 外键在连接打开时启用。
- Feature 001 不提供删除；后续删除必须遵循业务规则与回收站语义。

## 5. 写入原子性

图片先复制到确定的受管路径，再在单个 SQLite 事务插入三张表。事务失败则补偿删除本次图片。进程级中断由下次启动的引用集合清理处理。
