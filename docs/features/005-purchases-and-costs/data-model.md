# Feature 005 数据模型

## 1. Purchase

| 字段 | 类型 | 约束 |
|---|---|---|
| `id` | text | 本地生成主键/幂等键 |
| `purchasedAt` | UTC timestamp | 必填 |
| `amountMinor` | int64 | 普通购买非负；调整为负 |
| `currency` | text | 三位大写 ISO 代码 |
| `shippingMinor` | int64 | 普通购买非负；调整固定 0 |
| `feesMinor` | int64 | 普通购买非负；调整固定 0 |
| `channel/seller/notes` | nullable text | 去空白，分别限制长度 |
| `adjustmentOfId` | nullable text | 调整引用普通购买 |
| `version` | positive int | 默认 1 |
| `createdAt/updatedAt` | UTC timestamp | 必填 |

普通购买 `adjustmentOfId` 为空，累计值为 `amountMinor + shippingMinor + feesMinor`。调整不修改原行。

## 2. PurchaseItem

`purchase_items` 包含 `purchaseId`、`targetType(card|cardSet)`、`targetId`、`targetName`、可空 `allocatedMinor` 和 `createdAt`。`purchaseId + targetType + targetId` 为复合主键。

`targetId` 不使用目标外键：购买行通过 `purchaseId` 外键保证事务完整，目标名称快照保证关联对象删除后仍可审计。

## 3. ExchangeRate

`exchange_rates` 包含 `baseCurrency`、`quoteCurrency`、`rateDate`、正整数 `numerator/denominator`、`source` 和 `capturedAt`，复合主键为币种对、日期和来源。比率表达“一个 base 最小单位换算为多少 quote 最小单位”，禁止二进制浮点。

P0 只建立持久化与领域边界；自动抓取、主币种偏好和图表由 Feature 006 交付。

## 4. schema v4 → v5

新增 `purchases`、`purchase_items`、`exchange_rates` 三张表及购买时间、调整引用、目标和汇率索引，不修改 v4 卡片、图片、套卡、标签、系列或自定义字段行。升级失败不清库。
