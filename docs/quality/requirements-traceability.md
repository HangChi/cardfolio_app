# 需求追踪矩阵

更新日期：2026-08-09
说明：历史测试矩阵记录各 Feature 首次交付证据；后续 UI/口径变更需在当前 HEAD 重新执行
回归和设备验收，不能直接沿用旧“通过”结论。

当前限制：OCR 平台桥接与候选确认 UI 已存在，但运行时不可用且没有真机通过证据，因此
不计入 FR-IMG 或发布验收的“已通过”范围，详见[已知问题](../known-issues.md)。

## 1. 功能需求

| 需求 | Feature | 主要验证 |
|---|---:|---|
| FR-ONB-001..002 | 设置增强、010 | 三屏首次引导、跳过/完成持久化、重新查看引导；账号上线后的设备验收 |
| FR-ACC-001..002 | 010 | `rest_account_sync_remote_test.dart`、`secure_session_store_test.dart`、`account_sync_repository_impl_test.dart` 与 `profile_screen_test.dart`：账号、退出保留、删除选择和令牌生命周期 |
| FR-IMG-001 | 001、002 | 相册取消/成功；多选 |
| FR-IMG-002..005 | 009、图片编辑重做 | 相机接口、主动系统裁剪/旋转、亮度/对比度/清晰度、原图保留；历史四角/透视自动化仅作演进证据，当前设备验收待执行；不包含 OCR 可用性 |
| FR-IMG-006..007 | 002、009 | 多图顺序/封面及 [Feature 009 测试矩阵](../features/009-camera-and-image-processing/test-matrix.md) 的原图/派生图关联与补偿 |
| FR-CARD-001..005 | 001、004、007、卡片编辑增强 | 创建、可选字段编辑、正反面、查询、删除；见[卡片编辑与批量录入设计](../superpowers/specs/2026-07-29-card-editing-album-batch-entry-design.md) |
| FR-SET-001..003 | 003 | [Feature 003 测试矩阵](../features/003-card-set-progress/test-matrix.md)：关系、完成度与 Widget 自动化通过；设备验收待执行 |
| FR-SER-001 | 004、集卡册语义增强 | [Feature 004 测试矩阵](../features/004-tags-series-and-filters/test-matrix.md) T06：卡片/套卡多对多关联；用户界面以“集卡册”呈现且不提供标签；设备验收待执行 |
| FR-TAG-001..002 | 004 | [Feature 004 测试矩阵](../features/004-tags-series-and-filters/test-matrix.md) T03..T05、T10：标签管理、合并、影响预览与组合筛选自动化通过 |
| FR-CF-001 | 004 | [Feature 004 测试矩阵](../features/004-tags-series-and-filters/test-matrix.md) T07..T08：三类字段、原子保存、删除影响和值保留自动化通过 |
| FR-PUR-001..004 | 005、卡片成本增强 | 底层精确金额/分摊/退款/多币种测试为兼容证据；当前 UI 为每卡 CNY 金额+运费稳定 upsert，独立购买入口和成本排序已移除 |
| FR-SCH-001..004 | 004、006 | 搜索、组合筛选、稳定排序和统计下钻；入手日期月边界、重复卡、删除恢复需按当前 HEAD 复验；常用筛选 UI 已移除 |
| FR-HOME-001..002 | 006、首页增强 | 卡片/套卡/集卡册/本月新增、最近 10 条、人民币总花费和下钻；软删除和入手日期月边界已有当前自动化，设备状态待验收 |
| FR-STAT-001..002 | 006、消费日历增强 | 固定总卡片/总花费、六维聚合、成本趋势、月历日明细和共享查询下钻；设备验收待执行 |
| FR-DATA-001..002 | 008 | [Feature 008 测试矩阵](../features/008-import-export-and-migration/test-matrix.md) T01..T11：全实体 ZIP 往返、校验和、安全限制、原子导入、合并与 UI；当前基线另覆盖 schema v9、v1–v8 分步迁移和独立套卡封面备份；设备验收待执行 |
| FR-DATA-003 | 007 | [Feature 007 测试矩阵](../features/007-recycle-bin/test-matrix.md) T02..T10：软删除、恢复、永久删除、保留期和文件清理重试自动化通过；设备验收待执行 |
| FR-SYNC-001..003 | 010 | [Feature 010 测试矩阵](../features/010-account-and-local-first-sync/test-matrix.md) T01..T10：开关、离线队列、重放、游标、附件与冲突副本 |

## 2. 业务规则

| 规则 | 所有者 | 验证焦点 |
|---|---:|---|
| BR-CARD-001..004 | 001、003、004 | 款式/藏品身份、数量、字段语义 |
| BR-SET-001..005 | 003、006、007 | [Feature 003 测试矩阵](../features/003-card-set-progress/test-matrix.md) 与 [Feature 006 测试矩阵](../features/006-dashboard-and-statistics/test-matrix.md) T03、T09：完成度、重复、删除与统计下钻口径自动化通过；恢复属于 Feature 007 |
| BR-COST-001..006 | 005、006、008 | 账本兼容旧分摊/退款/多币种；当前入口固定 CNY，每卡稳定成本记录；审计快照保留、软删除排除和恢复重计已有当前数据库自动化，消费日历设备验收待执行 |
| BR-IMG-001..003 | 001、002、008、009 | 原图不变、系统裁剪派生引用、JPEG 直通、取消/失败清理；软删、封面引用清理和永久删除沿用 Feature 007 |
| BR-DEL-001..002 | 007 | [Feature 007 测试矩阵](../features/007-recycle-bin/test-matrix.md) T02..T07：默认查询排除、关联恢复、影响预览与依赖顺序自动化通过 |
| BR-SYNC-001..004 | 010 | `sync_models_test.dart`、`sync_local_store_test.dart`、`account_sync_repository_impl_test.dart`：本地优先、版本、幂等、同字段及删除冲突 |

## 3. 非功能与安全

| 需求 | 主要文档 | 发布证据 |
|---|---|---|
| NFR-PERF-001..003、NFR-CAP-001 | [性能计划](performance-plan.md)、[Feature 006 测试矩阵](../features/006-dashboard-and-statistics/test-matrix.md)、[Feature 009 测试矩阵](../features/009-camera-and-image-processing/test-matrix.md) | 10,000 款式无设备聚合门槛和图片 worker isolate 自动化通过；固定设备与真实图片基准待执行 |
| NFR-DATA-001..003 | [测试策略](test-strategy.md)、[备份恢复](../operations/backup-and-recovery.md)、[Feature 008 测试矩阵](../features/008-import-export-and-migration/test-matrix.md) | 事务回滚、格式迁移、导入恢复自动化通过；设备重启验收待执行 |
| NFR-SYNC-001 | [Feature 010](../features/010-account-and-local-first-sync/README.md) | 20 条离线创建与响应丢失重放复用同一操作 ID，服务端实体不重复 |
| NFR-UX-001..002、NFR-A11Y-001..002 | [设计系统](../design/design-system.md) | Widget、语义、字体缩放、设备验收 |
| NFR-PLAT-001 | [设备矩阵](device-compatibility-matrix.md) | Android/iOS 指定版本记录 |
| NFR-ARCH-001 | [架构总览](../architecture/overview.md) | 依赖边界审查 |
| NFR-TEST-001 | [测试策略](test-strategy.md) | CI 测试报告 |
| NFR-OBS-001 | [可观测性](../operations/observability.md) | 脱敏事件与版本看板 |
| SEC-001..004 | [隐私设计](../security/privacy-design.md)、[隐私政策](../security/privacy-policy.md)、[数据处理清单](../security/data-processing-inventory.md)、[威胁模型](../security/threat-model.md) | 平台安全存储测试、HTTPS/RLS/私有对象/删除基线；生产专项评审仍为发布门禁 |

## 4. 验收项

| 验收 | Feature | 证据 |
|---|---:|---|
| AC-P0-001..003 | 001 | [Feature 001 测试矩阵](../features/001-local-card-creation/test-matrix.md) |
| AC-P0-004 | 002 | [Feature 002 测试矩阵](../features/002-multi-image-management/test-matrix.md)；设备验收待执行 |
| AC-P0-005 | 003 | [Feature 003 测试矩阵](../features/003-card-set-progress/test-matrix.md) T07：4 个必需、3 个拥有、1 个重复仍为 3/4 |
| AC-P0-006 | 005 | [Feature 005 测试矩阵](../features/005-purchases-and-costs/test-matrix.md) T05：总价 500、分摊合计 500，累计只增加 500 |
| AC-P0-007 | 007 | [Feature 007 测试矩阵](../features/007-recycle-bin/test-matrix.md) T02..T04：删除/恢复前后同一查询、数量与套卡进度口径自动化通过 |
| AC-P0-008 | 008 | [Feature 008 测试矩阵](../features/008-import-export-and-migration/test-matrix.md) T06：17 类实体、金额、时间、关系和图片字节往返一致 |
| AC-V1-001..003 | 010 | `account_sync_repository_impl_test.dart` 20 条重放与退出保留；`sync_local_store_test.dart` 双设备同字段冲突；设备验收待执行 |

该矩阵在每个 Feature 合并和每次发布前更新测试名称、构建号与结果；目前未实施项只定义证据类型，不标记为通过。
