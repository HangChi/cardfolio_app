# Feature 006 实施计划

1. 先扩展 `CardLibraryQuery`，以失败测试锁定机构和套卡状态语义。
2. 新增 dashboard 领域模型和只读 Drift 聚合，以内存 SQLite 验证口径。
3. 新增仓储与 Riverpod provider，统一安全错误映射。
4. 替换首页和统计占位页，实现空、加载、成功、失败与下钻。
5. 运行格式化、目标测试、全量 `flutter test` 和 `flutter analyze`。
6. 更新证据文档，保留设备验收为待执行，最后提交一次完整变更。
