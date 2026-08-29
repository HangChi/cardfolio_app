# Cardfolio Sync Gateway

Cardfolio 的 REST v1 网关。它不保存用户业务状态，而是把客户端协议映射到 Supabase
Auth、PostgREST RPC 和私有 Storage。所有业务表请求携带用户 JWT，由 RLS 保证租户隔离；
secret key 只用于服务就绪检查和删除 Auth 用户。

## 已实现接口

- `GET /healthz`、`GET /readyz`
- `POST /v1/auth/register`、`register/verify|resend`
- `POST /v1/auth/login|refresh|logout`
- `POST /v1/auth/password/reset/send|verify`
- `POST /v1/auth/email/send|verify`（兼容旧版邮件 OTP 客户端）
- `POST /v1/auth/phone/send|verify`（短信验证码注册/登录）
- `DELETE /v1/account`
- `GET /v1/account/export`
- `POST /v1/sync/push`
- `GET /v1/sync/pull`
- `PUT|GET /v1/sync/attachments/{sha256}`

网关要求 Node.js 22+，运行时不依赖第三方 npm 包。默认容器只映射到宿主机
`127.0.0.1:18080`，必须由已有的 HTTPS 反向代理对外提供服务。

## 1. 准备 Supabase

按顺序执行：

1. `supabase/migrations/202607290010_account_sync.sql`
2. `supabase/migrations/202608290020_sync_gateway_rls.sql`

需要取得项目 URL、publishable key 和 secret key。secret key 只能保存在服务器，绝不能
写入 Flutter `--dart-define`、Git、日志或反向代理配置。

配置变量为 `SUPABASE_URL`、`SUPABASE_PUBLISHABLE_KEY` 和 `SUPABASE_SECRET_KEY`。网关也兼容
旧项目的 `SUPABASE_ANON_KEY` / `SUPABASE_SERVICE_ROLE_KEY`，但新旧两套不要同时配置。新式
API key 只放入 `apikey` 请求头；只有登录用户的访问令牌会放入 `Authorization: Bearer`。

邮箱注册使用“邮箱 + 密码 + 一次性验证码”：`register` 发送注册验证码，
`register/verify` 验证后返回会话；后续 `login` 只使用邮箱和密码。忘记密码通过
`password/reset/send|verify` 发送恢复验证码并设置新密码。

手机号使用密码无关的短信 OTP：`phone/send` 的 `createUser=true` 用于注册，`false` 仅允许
已有用户登录；`phone/verify` 校验验证码并返回标准会话。上线前必须在 Supabase 的
Authentication → Providers → Phone 中启用 Phone，并配置短信供应商，否则验证码无法送达。

Supabase 的 Confirm signup 和 Reset password 邮件模板必须包含 `{{ .Token }}`，不能只保留
`{{ .ConfirmationURL }}`，否则用户收到的是链接而不是验证码。兼容接口 `email/send|verify`
仍支持密码无关的邮件 OTP，但当前 Flutter 客户端不再将其作为默认邮箱登录方式。

## 2. 本地验证

```bash
cd server
npm ci
npm test
npm run check
```

复制环境文件并填入真实值：

```bash
cp .env.example .env
docker compose up -d --build
curl http://127.0.0.1:18080/healthz
curl http://127.0.0.1:18080/readyz
```

`healthz` 只检查进程；`readyz` 还会检查 Supabase Auth 是否可达。

若服务器无法访问 Docker Hub，可直接使用官方 Node 二进制，并通过 systemd 运行。当前部署
模板固定使用 `/home/ubuntu/opt/node-v24.19.0-linux-x64/bin/node`：

```bash
sudo cp deploy/cardfolio-sync.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now cardfolio-sync
sudo systemctl status cardfolio-sync
curl http://127.0.0.1:18080/healthz
curl http://127.0.0.1:18080/readyz
```

启动前必须先创建权限为 `600` 的 `/home/ubuntu/cardfolio-sync/.env`。缺少真实 Supabase
配置时服务会拒绝启动，不能使用 `.env.example` 中的占位值上线。

## 3. Nginx 与 HTTPS

在宝塔创建独立站点，例如 `sync.example.com`，启用有效 TLS 证书，然后加入
[`deploy/nginx-cardfolio.conf`](deploy/nginx-cardfolio.conf) 中的 `location`。不要直接把
18080 端口开放到公网。

客户端使用：

```bash
flutter run \
  --dart-define=CARD_FOLIO_API_BASE_URL=https://sync.example.com
```

## 4. 上线检查

- 服务器防火墙只开放 SSH、自有管理端口和 HTTPS；
- `.env` 权限设为 `600`，并确保不进入备份日志或面板截图；
- Nginx `client_max_body_size` 与 `MAX_ATTACHMENT_BYTES` 一致；
- secret key 定期轮换；
- PostgreSQL 和 Storage 做异机备份；
- 日志只保留 request ID、状态码、阶段和耗时；
- 使用两台设备执行 Feature 010 测试矩阵；
- 部署后验证账号删除同时移除 Auth 用户、RLS 行和私有对象。

## 5. 当前边界

- 云端导出目前只包含逻辑实体；含图片的完整可恢复备份仍使用 App 内 ZIP 导出；
- 网关进程内登录限流适用于单实例；多实例部署需改为共享限流存储；
- `sync_changes`、`sync_operations` 尚未自动清理，上线初期保留完整记录，后续应结合每台
  设备的确认游标设计安全压缩策略；
- 网关会在校验附件时短暂占用最多一个附件大小的内存，因此容器并发和 64 MiB 上限不可
  随意提高。
