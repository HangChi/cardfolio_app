# Feature 010 契约

## REST v1

```text
POST   /v1/auth/register       {email,password,deviceId} -> Session
POST   /v1/auth/login          {email,password,deviceId} -> Session
POST   /v1/auth/refresh        {refreshToken,deviceId} -> Session
POST   /v1/auth/logout         Authorization: Bearer <token> -> 204
DELETE /v1/account            Authorization + confirmation -> 204
POST   /v1/sync/push           {deviceId,mutations[]} -> {acks[],changes[],cursor}
GET    /v1/sync/pull           ?cursor=<opaque>&limit=100 -> {changes[],cursor,hasMore}
PUT    /v1/sync/attachments/{sha256}  binary + Idempotency-Key -> 204
GET    /v1/sync/attachments/{sha256}  -> binary
```

所有成功 JSON 返回 `protocolVersion: 1`。错误返回
`{code,message,retryable}`；`message` 不含表名、SQL、令牌或用户内容。

## Mutation

```text
operationId: UUID
entityType: 固定白名单
entityId: 单主键或 \u0000 分隔复合主键
operation: upsert | delete
baseServerVersion: 非负整数
payload: upsert 时为完整规范 JSON，delete 时为 null
changedFields: 相对最近确认服务端基线变化的字段名
createdAt: UTC
```

服务端按 `(user_id, operation_id)` 去重。相同 ID 与相同载荷返回原 ack；相同 ID 与不同
载荷返回 `idempotency_mismatch`。游标是不透明字符串，客户端不得解析或按设备时间构造。

## 客户端仓储

```text
AccountSyncRepository
  register(email, password)
  login(email, password)
  setSyncEnabled(enabled)
  syncNow()
  signOut()
  deleteAccount(deleteLocalCopy)
  resolveConflict(id, resolution, mergedPayload?)
  watchOverview() -> Stream<SyncOverview>
```

`signOut()` 永远保留本地业务数据。`deleteAccount` 只有远端确认后才清令牌；选择删除本地
时，业务表事务清空后再以空引用清理受管图片。
