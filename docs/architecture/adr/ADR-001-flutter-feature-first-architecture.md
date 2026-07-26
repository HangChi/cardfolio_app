# ADR-001：Flutter 功能优先分层架构

日期：2026-07-26
状态：Accepted

## 背景

卡迹需要 Android/iOS 共享业务规则，并长期扩展套卡、成本、图片、导出和同步。默认 Flutter 模板无法提供清晰的业务与外部依赖边界。

## 决策

使用 Flutter，并按 Feature 组织代码；每个 Feature 内部分为 Domain、Data、Presentation。App 层承担启动、路由、主题和依赖装配，Core 存放跨 Feature 稳定值对象。

## 理由

- Flutter 项目已初始化，符合 PRD 的跨平台方向。
- Feature 边界让垂直切片可独立理解和测试。
- Domain 不依赖 Flutter、Drift 或云服务，便于替换和单元测试。
- 比按全局 `models/services/screens` 分类更能限制跨模块耦合。

## 后果

- 初期文件数量增加。
- 跨 Feature 依赖必须通过契约或稳定 Core 类型。
- 禁止 Widget 直接访问数据库或平台插件。
- 复杂度不足以形成独立 Domain 行为的简单展示不强制创建空层。

## 未采用

- React Native：会推翻已完成 Flutter 初始化，当前没有收益证据。
- 单文件/按技术层全局组织：早期简单，后续业务边界会快速模糊。
- 完整 Clean Architecture 模板：抽象层过多，不符合首个切片的 YAGNI。
