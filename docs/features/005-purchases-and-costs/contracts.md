# Feature 005 契约

## 1. 仓储契约

```text
PurchaseRepository
  watchPurchases() -> Stream<List<PurchaseRecord>>
  watchCostSummary(options) -> Stream<CostSummary>
  watchTargetOptions() -> Stream<List<PurchaseTargetOption>>
  createPurchase(request) -> Future<String>
  createAdjustment(request) -> Future<String>
  saveExchangeRate(rate) -> Future<void>
```

契约只暴露领域对象，不暴露 Drift 行、SQL、Widget 或平台类型。

## 2. 写入契约

`CreatePurchaseRequest` 包含预生成 ID、日期、商品金额、币种、运费、手续费、可选文本及目标集合。请求规范化币种、UTC 日期和文本；目标去空白但不静默合并重复项。

`PurchaseTargetInput` 包含目标类型、目标 ID 和可空分摊。存在任一分摊时要求所有目标均分摊且合计等于默认累计金额。

`CreateAdjustmentRequest` 包含预生成 ID、原购买 ID、日期、正数退款金额和可空备注。仓储把退款保存为负向 `amountMinor`，币种取自原购买，运费和手续费为 0。

## 3. 查询契约

`PurchaseRecord` 同时返回原始金额字段、是否调整、关联目标快照和 `ledgerMinor(options)`。`CostSummary` 返回按币种排序的 `CostTotal` 集合；没有完整有效汇率时不提供合并总额。

目标查询只返回活跃卡片藏品与套卡。历史查询不因目标删除而隐藏购买。

## 4. 失败契约

- 空 ID、非法币种、负普通金额、非法分摊、无目标：`PurchaseValidationFailure`；
- 未知/已删除目标、未知调整原单、币种或调整规则冲突：`PurchaseValidationFailure`；
- 数据库读取失败：`DatabaseUnavailableFailure`；
- 事务写入失败：`PersistenceFailure`。

错误文案不得包含 SQL、绝对路径、堆栈、原始备注或购买内容。

## 5. 原子性与幂等

购买与全部购买项目在一个数据库事务中保存。已存在相同购买 ID 时返回该 ID 且不重复写入；调整同样使用预生成 ID 幂等。验证失败或任一关系写入失败时不产生可见半成品。
