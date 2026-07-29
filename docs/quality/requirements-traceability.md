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
| FR-SER-001 | 004 | [Feature 004 测试矩阵](../features/004-tags-series-and-filters/test-matrix.md) T06：卡片/套卡多对多关联与系列页面自动化通过；设备验收待执行 |
| FR-TAG-001..002 | 004 | [Feature 004 测试矩阵](../features/004-tags-series-and-filters/test-matrix.md) T03..T05、T10：标签管理、合并、影响预览与组合筛选自动化通过 |
| FR-CF-001 | 004 | [Feature 004 测试矩阵](../features/004-tags-series-and-filters/test-matrix.md) T07..T08：三类字段、原子保存、删除影响和值保留自动化通过 |
| FR-PUR-001..004 | 005 | [Feature 005 测试矩阵](../features/005-purchases-and-costs/test-matrix.md) T01..T11：精确金额、分摊、退款、多币种、删除审计与成本排序自动化通过；设备验收待执行 |
| FR-SCH-001..004 | 004、006 | [Feature 004 测试矩阵](../features/004-tags-series-and-filters/test-matrix.md) T09..T14 与 [Feature 006 测试矩阵](../features/006-dashboard-and-statistics/test-matrix.md) T01、T09：搜索、组合筛选、稳定排序、共享统计下钻与 10,000 款式性能通过 |
| FR-HOME-001..002 | 006 | [Feature 006 测试矩阵](../features/006-dashboard-and-statistics/test-matrix.md) T02..T03、T05..T08：摘要口径、软删除、多币种、响应式查询和页面状态自动化通过；设备验收待执行 |
| FR-STAT-001..002 | 006 | [Feature 006 测试矩阵](../features/006-dashboard-and-statistics/test-matrix.md) T01、T03..T07、T09..T10：六维聚合、成本趋势与共享查询下钻自动化通过；设备验收待执行 |
| FR-DATA-001..002 | 008 | [Feature 008 测试矩阵](../features/008-import-export-and-migration/test-matrix.md) T01..T11：全实体 ZIP 往返、校验和、安全限制、原子导入、合并与 UI 自动化通过；设备验收待执行 |
| FR-DATA-003 | 007 | [Feature 007 测试矩阵](../features/007-recycle-bin/test-matrix.md) T02..T10：软删除、恢复、永久删除、保留期和文件清理重试自动化通过；设备验收待执行 |
| FR-SYNC-001..003 | 010 | 离线队列、幂等、冲突副本 |

## 2. 业务规则

| 规则 | 所有者 | 验证焦点 |
|---|---:|---|
| BR-CARD-001..004 | 001、003、004 | 款式/藏品身份、数量、字段语义 |
| BR-SET-001..005 | 003、006、007 | [Feature 003 测试矩阵](../features/003-card-set-progress/test-matrix.md) 与 [Feature 006 测试矩阵](../features/006-dashboard-and-statistics/test-matrix.md) T03、T09：完成度、重复、删除与统计下钻口径自动化通过；恢复属于 Feature 007 |
| BR-COST-001..006 | 005、006、008 | [Feature 005 测试矩阵](../features/005-purchases-and-costs/test-matrix.md) 与 [Feature 006 测试矩阵](../features/006-dashboard-and-statistics/test-matrix.md) T05：购买事实、费用口径、分摊、原币种和调整自动化通过 |
| BR-IMG-001..003 | 001、002、008、009 | 原图、派生图、引用与删除 |
| BR-DEL-001..002 | 007 | [Feature 007 测试矩阵](../features/007-recycle-bin/test-matrix.md) T02..T07：默认查询排除、关联恢复、影响预览与依赖顺序自动化通过 |
| BR-SYNC-001..004 | 010 | 本地优先、版本、幂等、冲突 |

## 3. 非功能与安全

| 需求 | 主要文档 | 发布证据 |
|---|---|---|
| NFR-PERF-001..003、NFR-CAP-001 | [性能计划](performance-plan.md)、[Feature 006 测试矩阵](../features/006-dashboard-and-statistics/test-matrix.md) | 10,000 款式无设备聚合门槛通过；固定设备与真实图片基准待执行 |
| NFR-DATA-001..003 | [测试策略](test-strategy.md)、[备份恢复](../operations/backup-and-recovery.md)、[Feature 008 测试矩阵](../features/008-import-export-and-migration/test-matrix.md) | 事务回滚、格式迁移、导入恢复自动化通过；设备重启验收待执行 |
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
| AC-P0-006 | 005 | [Feature 005 测试矩阵](../features/005-purchases-and-costs/test-matrix.md) T05：总价 500、分摊合计 500，累计只增加 500 |
| AC-P0-007 | 007 | [Feature 007 测试矩阵](../features/007-recycle-bin/test-matrix.md) T02..T04：删除/恢复前后同一查询、数量与套卡进度口径自动化通过 |
| AC-P0-008 | 008 | [Feature 008 测试矩阵](../features/008-import-export-and-migration/test-matrix.md) T06：17 类实体、金额、时间、关系和图片字节往返一致 |
| AC-V1-001..003 | 010 | 离线 20 条、双设备冲突、退出保留本地 |

该矩阵在每个 Feature 合并和每次发布前更新测试名称、构建号与结果；目前未实施项只定义证据类型，不标记为通过。
