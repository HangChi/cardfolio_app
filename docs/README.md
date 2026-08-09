# Cardfolio 文档中心

状态：核心本地功能基线完成；OCR、设备验收与生产同步部署待完成
更新日期：2026-08-09

## 从这里开始

1. [项目 README](../README.md)：功能范围、运行、构建与手工冒烟。
2. [产品需求文档](product/卡迹App_PRD_v1.0.md)：最初产品目标和需求编号。
3. [当前路线图](product/roadmap.md)：已完成范围、剩余发布门禁和后续方向。
4. [Feature 索引](features/README.md)：Feature 001–010 与后续增强的当前状态。
5. [架构总览](architecture/overview.md)：运行时分层、依赖方向与启动流程。
6. [数据库模型](architecture/database-schema.md)：当前 schema v9、表关系和迁移策略。
7. [工程基线](engineering-baseline.md)：本地与 CI 的格式、分析、测试、迁移和构建门禁。
8. [已知问题](known-issues.md)：当前不可用能力、兼容预告和处置状态。
9. [开发日志](engineering/development-log.md)：按日期记录的实现演进。
10. [需求追踪矩阵](quality/requirements-traceability.md)：需求、实现和验证证据。

## 文档分区

| 分区 | 内容 |
|---|---|
| [product](product/) | PRD、路线图、词汇表、业务规则 |
| [design](design/) | 设计系统、导航、Figma 交付与品牌资源 |
| [architecture](architecture/) | 总体架构、领域模型、数据库、图片、错误处理、ADR |
| [features](features/) | Feature 001–010 的规格、验收、契约、数据、UX、错误和测试矩阵 |
| [engineering](engineering/) | 开发指南、Git 约定、开发日志 |
| [quality](quality/) | 测试策略、测试数据、性能、兼容性、追踪矩阵和发布清单 |
| [security](security/) | 权限、隐私、数据保护、数据处理清单和威胁模型 |
| [operations](operations/) | 环境、CI/CD、可观测性、备份、发布和回滚 |
| [superpowers](superpowers/) | 已执行的历史设计规格与实施计划，不代表当前 UI 一定仍保持原方案 |

## 当前实现边界

- 本地客户端已覆盖卡片、多图、套卡、集卡册、标签、自定义字段、筛选、人民币成本、
  首页/统计/消费日历、回收站、ZIP 备份、CSV 导出、相机、图片编辑、引导、主题和可选
  账号同步客户端。OCR 桥接与确认 UI 已存在，但当前运行时不可用，不能列为已交付能力。
- Drift 数据库当前为 schema v9；本地数据库和 App 私有图片目录始终是本地事实来源。
- 生产 REST 同步服务、Supabase 迁移落地、真实双设备同步、商店发布和完整设备矩阵仍是
  发布门禁，不能由宿主机测试结果替代。
- 历史 Feature 规格描述的是当时冻结范围。若与当前代码冲突，以本页、架构文档、开发
  日志和当前代码为准，并在后续需求评审中回写 PRD。

## 文档治理

- 改变用户行为时，至少更新 README、Feature 索引、开发日志和受影响的规范文档。
- 改变数据库或跨 Feature 规则时，更新数据库文档、业务规则、迁移快照和追踪矩阵。
- 架构决定发生变化时新增或替代 ADR，不静默改写已执行的历史计划。
- 只有本轮实际执行并观察到通过的验证，才能写成“通过”；设备验收必须注明设备和日期。
- `docs/local/` 专用于本机个人资料，已由 `.gitignore` 排除，不得暂存或推送。
