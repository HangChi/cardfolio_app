# Feature 004 数据模型

## 1. CardDefinition / CardItem 增量

| 表 | 字段 | 类型 | 约束 |
|---|---|---|---|
| `card_definitions` | `cardType` | nullable text | 最多 100 |
| `card_definitions` | `needsCompletion` | bool | 默认 false |
| `card_items` | `acquiredAt` | nullable UTC timestamp | 空值允许 |

## 2. Tag / CardTag

`tags`：`id`、`name`、`normalizedName`、`version`、`createdAt/updatedAt/deletedAt`。活跃 `normalizedName` 使用部分唯一索引。

`card_tags`：`tagId`、`definitionId`、`createdAt`，复合主键；两个方向均建立索引。

## 3. Series

`series_records`：`id`、`name`、`description`、`version`、`createdAt/updatedAt/deletedAt`。

`series_cards`：`seriesId`、`definitionId`、`createdAt`，复合主键。

`series_sets`：`seriesId`、`setId`、`createdAt`，复合主键。

## 4. CustomFieldDefinition / Value

`custom_field_definitions`：`id`、`name`、`normalizedName`、`fieldType(text|number|date)`、`version`、时间戳和 `deletedAt`。P0 作用域固定为卡片款式。

`custom_field_values`：`fieldId`、`definitionId`、可空 `textValue/numberValue/dateValue`、`updatedAt`，复合主键。应用层保证只有与定义类型匹配的一列非空。

## 5. schema v3 → v4

新增三列、七张表及查询索引，不修改 v3 卡片、图片、套卡和成员行。升级后新列使用空/false 默认值，既有列表行为保持不变。升级失败不清库。

## 6. 查询索引

- 卡片类型、待补全、发行日期、入手日期；
- 标签规范化名称、卡片标签双向外键；
- 系列名称及卡片/套卡关系双向外键；
- 自定义字段名称及值的字段/款式外键；
- 既有活跃卡片、套卡成员和创建时间索引继续使用。
