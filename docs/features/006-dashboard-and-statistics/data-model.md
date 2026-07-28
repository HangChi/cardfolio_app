# Feature 006 数据模型

Feature 006 不新增持久化表，只定义可重建派生模型。

## HomeDashboard

包含实体数、款式数、套卡数、已集齐数、本月新增、分币种成本、最近卡片、差 1 款套卡和待补资料卡片。列表最多各 5 项。

## StatisticsSnapshot

包含六个数量维度的 `StatisticBucket` 列表和按月/币种的 `CostTrendPoint`。卡片维度的值是实体数量；套卡状态的值是套卡数量。

## StatisticBucket

包含稳定键、中文标签、计数和 `CardLibraryQuery` 下钻条件。标签维度使用标签 ID；其余维度使用规范化精确值。

## 删除与时间

所有卡片统计要求款式和藏品均活跃；套卡统计要求套卡和成员活跃；标签桶要求标签活跃。当前月边界由设备本地月初转换成 UTC，持久化时间仍保持 UTC。
