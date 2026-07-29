# Cardfolio 文档中心

状态：M1 本地卡片闭环实现中
更新日期：2026-07-29

## 从这里开始

1. [产品需求文档](product/卡迹App_PRD_v1.0.md)
2. [产品路线图](product/roadmap.md)
3. [Feature 索引](features/README.md)
4. [架构总览](architecture/overview.md)
5. [需求追踪矩阵](quality/requirements-traceability.md)

## 产品

- [PRD v1.0](product/卡迹App_PRD_v1.0.md)
- [路线图](product/roadmap.md)
- [术语表](product/glossary.md)
- [业务规则](product/business-rules.md)

## 设计

- [Figma 设计交付基线](design/figma-handoff.md)
- [设计系统基线](design/design-system.md)
- [导航与信息架构](design/navigation.md)

## 架构

- [架构总览](architecture/overview.md)
- [领域模型](architecture/domain-model.md)
- [数据库 Schema](architecture/database-schema.md)
- [图片存储](architecture/image-storage.md)
- [错误处理](architecture/error-handling.md)
- [架构决策记录](architecture/adr/README.md)

## Feature

- [Feature 总索引](features/README.md)
- [Feature 001 九件套](features/001-local-card-creation/spec.md)
- [Feature 002 九件套](features/002-multi-image-management/spec.md)
- Feature 003–008 已建立九件套并完成实现；Feature 009–010 保留开发门禁。

## 工程

- [开发指南](engineering/development-guide.md)
- [Git 协作约定](engineering/git-conventions.md)
- [开发日志](engineering/development-log.md)

## 质量

- [测试策略](quality/test-strategy.md)
- [测试数据指南](quality/test-data-guide.md)
- [性能计划](quality/performance-plan.md)
- [设备兼容性矩阵](quality/device-compatibility-matrix.md)
- [需求追踪矩阵](quality/requirements-traceability.md)
- [发布检查清单](quality/release-checklist.md)

## 安全

- [隐私设计](security/privacy-design.md)
- [权限策略](security/permission-policy.md)
- [数据保护](security/data-protection.md)
- [威胁模型](security/threat-model.md)

## 运维与发布

- [CI/CD](operations/ci-cd.md)
- [环境与配置](operations/environments.md)
- [可观测性](operations/observability.md)
- [备份与恢复](operations/backup-and-recovery.md)
- [发布流程](operations/release-process.md)
- [回滚计划](operations/rollback-plan.md)

## 文档治理

- PRD 和业务规则发生变化时，同步更新路线图、Feature 规格和追踪矩阵。
- 架构决定发生变化时新增或替代 ADR，不静默改写历史决定。
- 每个 Feature 进入开发前完成九件套并满足 Definition of Ready。
- 合并实现时更新对应测试证据；未执行的测试不得标记通过。
- 发布后文档与代码使用同一版本标签归档。

## 当前边界

Feature 001–008 已完成本地建卡、多图、套卡、整理、购买、统计、回收站与可验证备份自动化闭环，设备验收仍待执行。相机、裁切增强和真实大图性能属于 Feature 009。
