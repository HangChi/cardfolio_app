# ADR-009：账号同步服务与可替换协议

状态：Accepted
日期：2026-07-29
关联：FR-ACC-001..002、FR-SYNC-001..003、BR-SYNC-001..004、SEC-001..004

## 背景

卡迹需要关系数据、私有大附件、租户隔离、幂等重放和显式冲突副本。客户端已经以
Drift 作为完整本地事实源，不能改成某个云 SDK 的缓存视图。

## 证据

| 维度 | Supabase | Firebase |
|---|---|---|
| 离线 | 需自建 outbox，策略完全可控 | Firestore SDK 支持离线，但同文档并发默认 last-write-wins |
| 关系/冲突 | Postgres 适配现有关系模型，可用函数实现版本与幂等 | 文档模型需重塑关系，显式冲突副本需额外协议 |
| 附件 | 私有 Storage、RLS、签名 URL、可恢复上传 | 私有 Cloud Storage 与 Rules |
| 权限 | Auth JWT + Postgres RLS | Auth + Firestore/Storage Rules |
| 地区 | 项目单主区域，可选择具体 AWS 区域 | Firestore/Storage 分资源选择区域 |
| 成本 | 订阅、计算、存储、出站和 MAU 配额 | 文档读写删、索引、存储和网络按量 |
| 锁定 | 可导出 Postgres，托管 API 仍有锁定 | 客户端 SDK、规则和文档模型锁定较强 |

官方证据：

- Supabase [平台组成](https://supabase.com/docs/guides/platform)、
  [地区](https://supabase.com/docs/guides/platform/regions)、
  [计费](https://supabase.com/docs/guides/platform/billing-on-supabase)、
  [Auth/RLS](https://supabase.com/docs/guides/auth) 和
  [Storage](https://supabase.com/docs/guides/storage)。
- Firebase [离线与 last-write-wins](https://firebase.google.com/docs/firestore/manage-data/enable-offline)、
  [事务离线限制](https://firebase.google.com/docs/firestore/manage-data/transactions)、
  [计费](https://firebase.google.com/docs/firestore/pricing) 和
  [资源地区](https://firebase.google.com/docs/projects/locations)。

以上价格与地区是 2026-07-29 的调研快照，生产采购前重新核对。

## 决策

首个服务端实现采用 Supabase Postgres/Auth/Storage；App 只依赖 Cardfolio REST v1，
不直接引入 Supabase SDK。协议固定操作 UUID、实体/字段版本、增量游标、私有附件校验和、
租户所有权和账号删除语义。客户端 outbox 与三方合并是权威同步策略。

## 权限模型

- 每个业务行、变更、幂等操作和对象路径都带 `user_id`，RLS 只允许
  `user_id = auth.uid()`。
- 客户端不得写 `user_id`、服务端版本、游标或其他用户前缀。
- 服务角色只在受控服务端函数使用，不进入 App、日志或构建参数。
- 账号删除函数锁定账号新写入，删除附件和业务行，最后删除 Auth 用户。

## 后果

客户端离线行为和冲突规则可测试、可迁移，代价是维护协议与 outbox。Supabase 不可用时
本地功能不受影响；更换服务端只需实现 REST v1。生产发布仍需部署、地区/DPA/费用复核、
安全评审和删除演练。
