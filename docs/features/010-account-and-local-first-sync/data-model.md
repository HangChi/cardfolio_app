# Feature 010 数据模型

## 本地 v7

| 表 | 主键 | 用途 |
|---|---|---|
| `sync_settings` | 固定 `id=1` | device UUID、开关、游标、账号非敏感摘要、最近成功/错误 |
| `sync_entity_states` | `entity_type, entity_id` | 最近确认的服务端版本与完整规范载荷 |
| `sync_outbox` | `operation_id` | 待发送操作、base 版本、载荷、字段、次数、下次重试 |
| `sync_conflicts` | UUID | 本地/远端操作和载荷、远端版本、发现/解决时间 |

`sync_outbox(entity_type, entity_id)` 唯一，避免扫描重复入队。令牌不在以上表中。

## 服务端

每个用户实体行包含 `user_id`、`entity_type`、`entity_id`、`payload jsonb`、
`server_version bigint`、`deleted boolean`、`updated_at timestamptz`。`sync_operations`
以 `(user_id, operation_id)` 唯一；`sync_changes` 的单调 `change_id` 形成 pull 游标。
对象路径为 `<user_id>/<sha256>`，私有 bucket 禁止跨用户读取。

## 合并

`sync_entity_states.payload` 是共同基线。若本地和远端字段变化集合不交叉则字段级合并；
交叉字段值相同可收敛；不同则建冲突。任一侧是物理删除、另一侧是修改时建冲突。
软删除实体通过包含 `deletedAt` 的 upsert 传播，保留可恢复语义。
