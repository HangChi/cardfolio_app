# 卡迹领域模型

状态：M0 基线
日期：2026-07-26
关联：[领域词汇表](../product/glossary.md)、[业务规则](../product/business-rules.md)

## 1. 聚合边界

```text
CardDefinition
├── CardItem
│   └── CardImage
└── CardSetMember ── CardSet

CardDefinition / CardSet ── SeriesCard / SeriesSet ── Series
CardDefinition ── CardTag ── Tag
CardDefinition ── CustomFieldValue ── CustomFieldDefinition

Purchase
└── PurchaseItem ── CardItem / CardSet

SyncRecord ── any syncable entity
```

## 2. 实体

### CardDefinition

描述一种卡片款式，负责发行资料，不负责用户实际拥有数量。

关键不变量：

- `name.trim()` 非空且不超过 120 个字符；
- `issueQuantity` 为空或大于 0；
- `issuedAt` 为有效部分日期；
- `issuePrice` 不进入累计花费。

### CardItem

描述用户实际持有的实体。

关键不变量：

- 必须引用存在的 `CardDefinition`；
- `quantity >= 1`；
- 不同品相或来源需要独立追踪时拆分实例；
- 软删除后退出默认查询和统计。

### CardImage

描述受管理的原图或派生图。

关键不变量：

- 必须引用存在的 `CardItem`；
- 原图不可被派生处理覆盖；
- 路径在图片根目录内且唯一；
- 校验值与文件内容一致；
- 排序稳定，封面选择明确。

### CardSet / CardSetMember

`CardSet` 描述固定或预期集合，`CardSetMember` 描述成员关系。

关键不变量：

- `expectedCount` 仅在 `countKnown=true` 时生效；
- 同一款式在一个套卡中最多一个成员定义；
- 完成度按不同必需款式计算，不按实体数量计算；
- 总数未知时不产生百分比；
- 套卡封面必须来自活跃成员的活跃图片，图片或成员失效后不得继续解析为封面。

### Series

宽泛归类，可包含多个卡片款式或套卡，不承担完成度。同一款式或套卡可属于多个系列；保存系列时完整替换两类成员关系。

### Tag

用户自定义轻量分类。规范化名称在同一收藏库中唯一；合并标签迁移全部关联。

### CustomFieldDefinition / CustomFieldValue

字段定义和值分离，当前作用域为 `CardDefinition`。值类型必须与定义类型一致；删除定义前展示影响，定义软删除但既有值保留。

### Purchase / PurchaseItem

`Purchase` 是付款事实，`PurchaseItem` 是对象关联和分析分摊。

关键不变量：

- 金额使用精确表示；
- 原始购买不可通过退款直接改写；
- 分摊合计可校验但不重复进入累计花费；
- 原币种永久保留。

### SyncRecord

描述本地变更的同步状态和幂等信息，不替代业务实体版本字段。

## 3. 值对象

| 值对象 | 表示 | 验证 |
|---|---|---|
| UUID | 本地实体身份 | RFC 兼容且非空 |
| PartialDate | 年、年月或完整日期 | 不猜测缺失部分 |
| Money | 最小货币单位 + ISO 4217 | 币种有效、整数金额 |
| Checksum | 文件 SHA-256 | 固定格式 |
| Quantity | 实体数量 | 整数且至少 1 |
| EntityVersion | 乐观版本 | 单调增加 |
| RelativeImagePath | 图片相对路径 | 不允许绝对路径或目录逃逸 |

## 4. 聚合写入原则

- 创建卡片时 `CardDefinition`、`CardItem` 和首图是一个可见原子操作。
- 文件系统与数据库无法共享事务时，使用确定路径、数据库事务、失败补偿和启动恢复。
- 购买与购买项目在一个数据库事务中写入。
- 套卡成员调整与完成度查询不存储互相矛盾的派生值。
- 同步队列与业务变更在同一本地事务内落盘。

## 5. 删除原则

- 默认使用软删除。
- 软删除保留关系，默认查询统一排除。
- 恢复时验证依赖关系；缺失依赖不自动猜测。
- 永久删除按依赖顺序清理关系、缩略图、派生图和原图。
- 同步启用后，永久删除必须等待删除墓碑达到保留条件。

## 6. 版本策略

所有可同步实体具备：

- `createdAt`
- `updatedAt`
- `version`
- `deletedAt`（可删除实体）

时间以 UTC 持久化、界面按本地时区展示。版本由本地事务递增，不能用时间戳替代并发版本。
