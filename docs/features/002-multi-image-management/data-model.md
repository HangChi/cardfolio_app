# Feature 002 数据模型

## 1. CardImage v2

| 字段 | 类型 | 约束 |
|---|---|---|
| `id` | text UUID | 主键 |
| `cardItemId` | text UUID | 外键、索引 |
| `kind` | text enum | `front/back/packaging/number/detail/other` |
| `relativePath` | text | 原图相对路径、全库唯一 |
| `derivedRelativePath` | nullable text | 派生图相对路径，不覆盖原图 |
| `sortOrder` | integer | 活跃图片内连续、非负 |
| `isCover` | integer bool | 每个藏品最多一个活跃真值 |
| `checksum` | text | 原图 SHA-256 |
| `createdAt` | UTC timestamp | 必填 |
| `deletedAt` | nullable UTC timestamp | 保留原图删除时写入 |

## 2. schema v1 → v2

增加 `derivedRelativePath`、`isCover` 和 `deletedAt`。既有行设置 `isCover = true`，因为 v1 每个藏品最多一张图；其余新增列为空。创建活跃封面部分唯一索引：

```sql
CREATE UNIQUE INDEX idx_card_images_active_cover
ON card_images(card_item_id)
WHERE is_cover = 1 AND deleted_at IS NULL;
```

## 3. 删除语义

保留原图时设置 `deletedAt` 并排除于默认查询，但 `referencedImagePaths` 继续包含它。删除原图时移除数据库行，再删除原图和派生图；文件删除失败由孤儿清理重试。

## 4. 顺序与封面

排序写入前要求 ID 集合与全部活跃图片完全一致。封面切换先清除当前封面，再设置目标图片；两个动作在同一事务中。删除封面时按剩余顺序选择新封面。
