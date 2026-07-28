# Feature 006 契约

## 仓储

```text
DashboardRepository
  watchHome(options) -> Stream<HomeDashboard>
  watchStatistics(options) -> Stream<StatisticsSnapshot>
```

仓储只暴露领域对象，不暴露 Drift 行、SQL、Widget 或平台类型。系统时钟由仓储注入，用于计算本地自然月。

## 下钻

`StatisticBucket.query` 是完整 `CardLibraryQuery`。点击桶时先替换 `cardLibraryQueryProvider`，再进入 `/library`。机构使用 `issuer` 精确匹配；套卡状态使用 `CardSetStatusFilter`。

## 失败

数据库读取失败映射为 `DatabaseUnavailableFailure('首页与统计暂时无法读取，请重试。')`，不得显示 SQL、路径、堆栈或原始异常。

## 响应

任一卡片、套卡、成员、标签或购买事实变化后，订阅流重新计算。统计不写入源表，不维护需要迁移的缓存。
