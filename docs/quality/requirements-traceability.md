# 需求追踪矩阵

## 1. 功能需求

| 需求 | Feature | 主要验证 |
|---|---:|---|
| FR-ONB-001..002 | 001、010 | 首启/阶段状态 Widget；账号上线后的引导验收 |
| FR-ACC-001..002 | 010 | 账号、退出保留本地、安全测试 |
| FR-IMG-001 | 001、002 | 相册取消/成功；多选 |
| FR-IMG-002..005 | 009 | 相机与处理 Spike、设备测试 |
| FR-IMG-006..007 | 002、009 | 多图顺序、封面、原图/派生图 |
| FR-CARD-001..005 | 001、004、007 | 创建、编辑模型、查询、删除 |
| FR-SET-001..003 | 003 | [Feature 003 测试矩阵](../features/003-card-set-progress/test-matrix.md)：关系、完成度与 Widget 自动化通过；设备验收待执行 |
| FR-SER-001 | 004 | 多对多关联 |
| FR-TAG-001..002 | 004 | 标签合并、删除、筛选 |
| FR-CF-001 | 004 | 类型、值与删除影响 |
| FR-PUR-001..004 | 005 | 金额、分摊、退款、多币种 |
| FR-SCH-001..004 | 004、006 | 搜索正确性与 10,000 条性能 |
| FR-HOME-001..002 | 006 | 首页口径、空状态 |
| FR-STAT-001..002 | 006 | 聚合与下钻一致 |
| FR-DATA-001..002 | 008 | 导出/导入完整性与安全 |
| FR-DATA-003 | 007 | 软删除、恢复、永久删除 |
| FR-SYNC-001..003 | 010 | 离线队列、幂等、冲突副本 |

## 2. 业务规则

| 规则 | 所有者 | 验证焦点 |
|---|---:|---|
| BR-CARD-001..004 | 001、003、004 | 款式/藏品身份、数量、字段语义 |
| BR-SET-001..005 | 003、006、007 | 完成度、重复、删除/恢复 |
| BR-COST-001..006 | 005、006、008 | 金额口径、分摊、币种、恢复 |
| BR-IMG-001..003 | 001、002、008、009 | 原图、派生图、引用与删除 |
| BR-DEL-001..002 | 007 | 软删除、恢复、永久删除 |
| BR-SYNC-001..004 | 010 | 本地优先、版本、幂等、冲突 |

## 3. 非功能与安全

| 需求 | 主要文档 | 发布证据 |
|---|---|---|
| NFR-PERF-001..003、NFR-CAP-001 | [性能计划](performance-plan.md) | 固定设备和大数据基准 |
| NFR-DATA-001..003 | [测试策略](test-strategy.md)、[备份恢复](../operations/backup-and-recovery.md) | 事务、重启、迁移、导入恢复 |
| NFR-SYNC-001 | [Feature 010](../features/010-account-and-local-first-sync/README.md) | 重试/重放与无重复 |
| NFR-UX-001..002、NFR-A11Y-001..002 | [设计系统](../design/design-system.md) | Widget、语义、字体缩放、设备验收 |
| NFR-PLAT-001 | [设备矩阵](device-compatibility-matrix.md) | Android/iOS 指定版本记录 |
| NFR-ARCH-001 | [架构总览](../architecture/overview.md) | 依赖边界审查 |
| NFR-TEST-001 | [测试策略](test-strategy.md) | CI 测试报告 |
| NFR-OBS-001 | [可观测性](../operations/observability.md) | 脱敏事件与版本看板 |
| SEC-001..004 | [隐私设计](../security/privacy-design.md)、[威胁模型](../security/threat-model.md) | 安全评审与发布清单 |

## 4. 验收项

| 验收 | Feature | 证据 |
|---|---:|---|
| AC-P0-001..003 | 001 | [Feature 001 测试矩阵](../features/001-local-card-creation/test-matrix.md) |
| AC-P0-004 | 002 | [Feature 002 测试矩阵](../features/002-multi-image-management/test-matrix.md)；设备验收待执行 |
| AC-P0-005 | 003 | [Feature 003 测试矩阵](../features/003-card-set-progress/test-matrix.md) T07：4 个必需、3 个拥有、1 个重复仍为 3/4 |
| AC-P0-006 | 005 | 总价 500 与分摊不重复夹具 |
| AC-P0-007 | 007 | 删除/恢复前后数量与进度 |
| AC-P0-008 | 008 | 全实体导出导入一致性报告 |
| AC-V1-001..003 | 010 | 离线 20 条、双设备冲突、退出保留本地 |

该矩阵在每个 Feature 合并和每次发布前更新测试名称、构建号与结果；目前未实施项只定义证据类型，不标记为通过。
