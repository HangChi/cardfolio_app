# Feature 006 测试矩阵

| ID | 层级 | 覆盖 | 自动化 |
|---|---|---|---|
| T01 | Domain | 维度标签、月份标签、下钻条件 | 是 |
| T02 | Query | 实体/款式/月新增与软删除 | 是 |
| T03 | Query | 套卡完成、差 1 款、未知和重复持有 | 是 |
| T04 | Query | 年份、城市、机构、类型、标签分布 | 是 |
| T05 | Query | 多币种、运费/手续费选项、退款、月趋势 | 是 |
| T06 | Query | 源数据变化后响应式重算 | 是 |
| T07 | Repository | 正常读取和安全失败映射 | 是 |
| T08 | Widget | 首页成功、空、加载、错误 | 是 |
| T09 | Widget | 统计维度、趋势和下钻 | 是 |
| T10 | App | `/home`、`/stats` 替换阶段占位 | 是 |
| T11 | Device | 360/393/430 宽度与 200% 字体 | 手动，待执行 |
| T12 | Device | Android 返回、底栏分支状态与滚动 | 手动，待执行 |

## 自动化结果

- `flutter test test\features\dashboard test\features\organization\domain\organization_models_test.dart test\features\organization\data\card_search_database_test.dart test\app\cardfolio_app_test.dart`：42 项通过。
- `flutter test`：246 项通过。
- `flutter analyze`：0 个问题。
- T01..T10 已通过；10,000 款式聚合的 `< 1,200ms` 断言通过。

## 手动设备步骤（未执行）

1. 启动 Android 模拟器或连接真机，运行 `flutter run -d <device-id>`。
2. 准备至少两张不同城市、机构、类型和年份的卡片；给其中一张添加标签并标记待补资料。
3. 建立一个已集齐套卡、一个差 1 款套卡和一个总数未知套卡。
4. 添加 CNY 与 JPY 购买，并给其中一笔 CNY 购买添加退款。
5. 打开首页，核对实体/款式/套卡/已集齐/本月新增、多币种花费及三个行动区。
6. 打开统计，逐一切换六个维度；点击每个代表性桶，确认收藏页结果与桶口径一致。
7. 分别在 360、393、430 逻辑像素宽度和系统字体 200% 下检查无溢出且主要操作可完成。
8. 验证底部导航分支保持、统计下钻后的返回行为、长页滚动和应用重启后的数据恢复。

性能证据使用内存 SQLite 固定数据集，整个自动化过程未启动模拟器。T11..T12 保持待执行。
