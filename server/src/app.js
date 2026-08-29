import { createHash, randomUUID } from 'node:crypto';

const protocolVersion = 1;
const checksumPattern = /^[0-9a-f]{64}$/;
const uuidPattern = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const phonePattern = /^\+[1-9]\d{7,14}$/;
const otpPattern = /^\d{6,10}$/;
const entityTypes = new Set([
  'cardDefinitions',
  'cardItems',
  'cardImages',
  'cardSets',
  'cardSetMembers',
  'tags',
  'cardTags',
  'seriesRecords',
  'seriesCards',
  'seriesSets',
  'customFieldDefinitions',
  'customFieldValues',
  'purchases',
  'purchaseItems',
  'exchangeRates',
  'recycleBinSettings',
]);

class ApiError extends Error {
  constructor(status, code, message, retryable = false) {
    super(message);
    this.status = status;
    this.code = code;
    this.retryable = retryable;
  }
}

class SlidingWindowLimiter {
  constructor(limit, windowMs, now) {
    this.limit = limit;
    this.windowMs = windowMs;
    this.now = now;
    this.entries = new Map();
  }

  consume(key) {
    const current = this.now();
    const cutoff = current - this.windowMs;
    const recent = (this.entries.get(key) ?? []).filter((item) => item > cutoff);
    if (recent.length >= this.limit) return false;
    recent.push(current);
    this.entries.set(key, recent);
    if (this.entries.size > 10_000) {
      for (const [entryKey, values] of this.entries) {
        if (values.at(-1) <= cutoff) this.entries.delete(entryKey);
      }
    }
    return true;
  }
}

export function createApp(config, dependencies = {}) {
  const fetchImpl = dependencies.fetchImpl ?? globalThis.fetch;
  const now = dependencies.now ?? Date.now;
  const limiter = new SlidingWindowLimiter(
    config.authRateLimit,
    config.authRateWindowMs,
    now,
  );

  async function handle(request) {
    const requestId = request.headers.get('x-request-id')?.slice(0, 128) || randomUUID();
    try {
      const url = new URL(request.url);
      const method = request.method.toUpperCase();

      if (method === 'OPTIONS') {
        return empty(204, requestId);
      }

      if (method === 'GET' && url.pathname === '/healthz') {
        return json({ status: 'ok' }, 200, requestId);
      }
      if (method === 'GET' && url.pathname === '/readyz') {
        const response = await upstream('/auth/v1/settings', {
          headers: serviceHeaders(),
        });
        if (!response.ok) throw upstreamError(response.status);
        return json({ status: 'ready' }, 200, requestId);
      }

      const authAction = /^\/v1\/auth\/(register|login|refresh)$/.exec(url.pathname);
      if (method === 'POST' && authAction) {
        const clientKey = clientAddress(request, config.trustProxy);
        if (!limiter.consume(`${clientKey}:${authAction[1]}`)) {
          throw new ApiError(429, 'rate_limited', '请求过于频繁，请稍后重试。', true);
        }
        const body = await readJson(request, config.maxJsonBytes);
        requireProtocol(body);
        return json(
          await authenticateAction(authAction[1], body),
          200,
          requestId,
        );
      }

      const phoneAction = /^\/v1\/auth\/phone\/(send|verify)$/.exec(url.pathname);
      if (method === 'POST' && phoneAction) {
        const body = await readJson(request, config.maxJsonBytes);
        requireProtocol(body);
        const phone = normalizePhone(body.phone);
        const clientKey = clientAddress(request, config.trustProxy);
        if (!limiter.consume(`${clientKey}:phone:${phone}:${phoneAction[1]}`)) {
          throw new ApiError(429, 'rate_limited', '请求过于频繁，请稍后重试。', true);
        }
        if (phoneAction[1] === 'send') {
          if (typeof body.createUser !== 'boolean') {
            throw new ApiError(400, 'invalid_request', '请求字段 createUser 无效。');
          }
          requireString(body.deviceId, 'deviceId', 200);
          const response = await upstream('/auth/v1/otp', {
            method: 'POST',
            headers: anonHeaders(true),
            body: JSON.stringify({
              phone,
              create_user: body.createUser,
              channel: 'sms',
              data: { initial_device_id: body.deviceId },
            }),
          });
          if (!response.ok) throw phoneAuthError(response.status);
          return json({ protocolVersion, resendAfterSeconds: 60 }, 200, requestId);
        }

        const code = requireString(body.code, 'code', 10).trim();
        requireString(body.deviceId, 'deviceId', 200);
        if (!otpPattern.test(code)) {
          throw new ApiError(400, 'invalid_otp', '请输入有效短信验证码。');
        }
        const response = await upstream('/auth/v1/verify', {
          method: 'POST',
          headers: anonHeaders(true),
          body: JSON.stringify({ phone, token: code, type: 'sms' }),
        });
        if (!response.ok) throw phoneAuthError(response.status);
        return json(session(await safeJson(response)), 200, requestId);
      }

      const emailAction = /^\/v1\/auth\/email\/(send|verify)$/.exec(url.pathname);
      if (method === 'POST' && emailAction) {
        const body = await readJson(request, config.maxJsonBytes);
        requireProtocol(body);
        const email = normalizeEmail(body.email);
        const clientKey = clientAddress(request, config.trustProxy);
        if (!limiter.consume(`${clientKey}:email:${email}:${emailAction[1]}`)) {
          throw new ApiError(429, 'rate_limited', '请求过于频繁，请稍后重试。', true);
        }
        if (emailAction[1] === 'send') {
          if (typeof body.createUser !== 'boolean') {
            throw new ApiError(400, 'invalid_request', '请求字段 createUser 无效。');
          }
          requireString(body.deviceId, 'deviceId', 200);
          const response = await upstream('/auth/v1/otp', {
            method: 'POST',
            headers: anonHeaders(true),
            body: JSON.stringify({
              email,
              create_user: body.createUser,
              data: { initial_device_id: body.deviceId },
            }),
          });
          if (!response.ok) throw emailOtpError(response.status);
          return json({ protocolVersion, resendAfterSeconds: 60 }, 200, requestId);
        }

        const code = requireString(body.code, 'code', 10).trim();
        requireString(body.deviceId, 'deviceId', 200);
        if (!otpPattern.test(code)) {
          throw new ApiError(400, 'invalid_otp', '请输入有效邮箱验证码。');
        }
        const response = await upstream('/auth/v1/verify', {
          method: 'POST',
          headers: anonHeaders(true),
          body: JSON.stringify({ email, token: code, type: 'email' }),
        });
        if (!response.ok) throw emailOtpError(response.status);
        return json(session(await safeJson(response)), 200, requestId);
      }

      const registrationAction = /^\/v1\/auth\/register\/(verify|resend)$/.exec(url.pathname);
      if (method === 'POST' && registrationAction) {
        const body = await readJson(request, config.maxJsonBytes);
        requireProtocol(body);
        const email = normalizeEmail(body.email);
        requireString(body.deviceId, 'deviceId', 200);
        const clientKey = clientAddress(request, config.trustProxy);
        if (!limiter.consume(`${clientKey}:register:${email}:${registrationAction[1]}`)) {
          throw new ApiError(429, 'rate_limited', '请求过于频繁，请稍后重试。', true);
        }
        if (registrationAction[1] === 'resend') {
          const response = await upstream('/auth/v1/resend', {
            method: 'POST',
            headers: anonHeaders(true),
            body: JSON.stringify({ email, type: 'signup' }),
          });
          if (!response.ok) throw emailOtpError(response.status);
          return json({ protocolVersion, resendAfterSeconds: 60 }, 200, requestId);
        }
        const code = requireString(body.code, 'code', 10).trim();
        if (!otpPattern.test(code)) {
          throw new ApiError(400, 'invalid_otp', '请输入有效邮箱验证码。');
        }
        const response = await upstream('/auth/v1/verify', {
          method: 'POST',
          headers: anonHeaders(true),
          body: JSON.stringify({ email, token: code, type: 'signup' }),
        });
        if (!response.ok) throw emailOtpError(response.status);
        return json(session(await safeJson(response)), 200, requestId);
      }

      const passwordResetAction = /^\/v1\/auth\/password\/reset\/(send|verify)$/.exec(url.pathname);
      if (method === 'POST' && passwordResetAction) {
        const body = await readJson(request, config.maxJsonBytes);
        requireProtocol(body);
        const email = normalizeEmail(body.email);
        requireString(body.deviceId, 'deviceId', 200);
        const clientKey = clientAddress(request, config.trustProxy);
        if (!limiter.consume(`${clientKey}:password-reset:${email}:${passwordResetAction[1]}`)) {
          throw new ApiError(429, 'rate_limited', '请求过于频繁，请稍后重试。', true);
        }
        if (passwordResetAction[1] === 'send') {
          const response = await upstream('/auth/v1/recover', {
            method: 'POST',
            headers: anonHeaders(true),
            body: JSON.stringify({ email }),
          });
          if (!response.ok) throw emailOtpError(response.status);
          return json({ protocolVersion, resendAfterSeconds: 60 }, 200, requestId);
        }
        const code = requireString(body.code, 'code', 10).trim();
        const password = requireString(body.newPassword, 'newPassword', 1024);
        if (!otpPattern.test(code) || password.length < 8) {
          throw new ApiError(400, 'invalid_password_reset', '请输入有效验证码和至少 8 位新密码。');
        }
        const verified = await upstream('/auth/v1/verify', {
          method: 'POST',
          headers: anonHeaders(true),
          body: JSON.stringify({ email, token: code, type: 'recovery' }),
        });
        if (!verified.ok) throw emailOtpError(verified.status);
        const verifiedSession = await safeJson(verified);
        const updated = await upstream('/auth/v1/user', {
          method: 'PUT',
          headers: userHeaders(verifiedSession.access_token, true),
          body: JSON.stringify({ password }),
        });
        if (!updated.ok) throw authError(updated.status);
        return json(session(verifiedSession), 200, requestId);
      }

      if (method === 'POST' && url.pathname === '/v1/auth/logout') {
        const token = bearer(request);
        const response = await upstream('/auth/v1/logout', {
          method: 'POST',
          headers: userHeaders(token),
        });
        if (!response.ok && response.status !== 401) throw upstreamError(response.status);
        return empty(204, requestId);
      }

      if (method === 'DELETE' && url.pathname === '/v1/account') {
        if (request.headers.get('x-account-deletion-confirmation') !== 'DELETE') {
          throw new ApiError(400, 'confirmation_required', '请确认账号删除操作。');
        }
        const token = bearer(request);
        const user = await currentUser(token);
        const cleanup = await upstream('/rest/v1/rpc/cardfolio_delete_my_cloud_data', {
          method: 'POST',
          headers: userHeaders(token, true),
          body: '{}',
        });
        if (!cleanup.ok) throw upstreamError(cleanup.status);
        const deletion = await upstream(`/auth/v1/admin/users/${encodeURIComponent(user.id)}`, {
          method: 'DELETE',
          headers: serviceHeaders(true),
        });
        if (!deletion.ok) throw upstreamError(deletion.status);
        return empty(204, requestId);
      }

      if (method === 'GET' && url.pathname === '/v1/account/export') {
        const token = bearer(request);
        await currentUser(token);
        const entitiesResponse = await upstream(
          '/rest/v1/cardfolio_sync_entities?select=entity_type,entity_id,payload,deleted,server_version,updated_at&order=entity_type.asc,entity_id.asc&limit=10000',
          { headers: userHeaders(token) },
        );
        if (!entitiesResponse.ok) throw upstreamError(entitiesResponse.status);
        const entities = await safeJson(entitiesResponse);
        if (!Array.isArray(entities)) throw new ApiError(502, 'upstream_protocol_error', '云端数据格式异常。', true);
        if (entities.length === 10_000) {
          throw new ApiError(413, 'export_too_large', '云端数据量过大，暂时无法直接导出。');
        }
        const contents = Buffer.from(JSON.stringify({
          protocolVersion,
          exportedAt: new Date(now()).toISOString(),
          entities,
        }));
        return new Response(contents, {
          status: 200,
          headers: responseHeaders(requestId, {
            'content-type': 'application/json; charset=utf-8',
            'content-disposition': 'attachment; filename="cardfolio-cloud-export.json"',
            'x-file-name': 'cardfolio-cloud-export.json',
            'x-content-sha256': sha256(contents),
          }),
        });
      }

      if (method === 'POST' && url.pathname === '/v1/sync/push') {
        const token = bearer(request);
        await currentUser(token);
        const body = await readJson(request, config.maxJsonBytes);
        requireProtocol(body);
        requireString(body.deviceId, 'deviceId', 200);
        if (!Array.isArray(body.mutations) || body.mutations.length < 1 || body.mutations.length > 100) {
          throw new ApiError(400, 'invalid_mutations', '同步批次必须包含 1 至 100 条操作。');
        }
        const acknowledgements = [];
        const changes = [];
        for (const mutation of body.mutations) {
          validateMutation(mutation);
          const response = await upstream('/rest/v1/rpc/cardfolio_apply_mutation', {
            method: 'POST',
            headers: userHeaders(token, true),
            body: JSON.stringify({ p_mutation: mutation }),
          });
          if (!response.ok) throw await mutationError(response);
          const result = await safeJson(response);
          if (result?.kind === 'ack') {
            acknowledgements.push({
              operationId: result.operationId,
              entityType: result.entityType,
              entityId: result.entityId,
              serverVersion: number(result.serverVersion, 'serverVersion'),
            });
          } else if (result?.kind === 'conflict' && result.change) {
            changes.push(normalizeChange(result.change));
          } else {
            throw new ApiError(502, 'upstream_protocol_error', '云端同步响应异常。', true);
          }
        }
        return json({
          protocolVersion,
          acks: acknowledgements,
          changes,
          cursor: null,
        }, 200, requestId);
      }

      if (method === 'GET' && url.pathname === '/v1/sync/pull') {
        const token = bearer(request);
        await currentUser(token);
        const limit = parseLimit(url.searchParams.get('limit'));
        const originalCursor = url.searchParams.get('cursor');
        const changeId = decodeCursor(originalCursor);
        const query = new URLSearchParams({
          select: 'change_id,entity_type,entity_id,operation,payload,server_version,changed_fields,occurred_at',
          change_id: `gt.${changeId}`,
          order: 'change_id.asc',
          limit: String(limit + 1),
        });
        const response = await upstream(`/rest/v1/cardfolio_sync_changes?${query}`, {
          headers: userHeaders(token),
        });
        if (!response.ok) throw upstreamError(response.status);
        const rows = await safeJson(response);
        if (!Array.isArray(rows)) throw new ApiError(502, 'upstream_protocol_error', '云端增量格式异常。', true);
        const hasMore = rows.length > limit;
        const page = rows.slice(0, limit);
        const changes = page.map((row) => normalizeDatabaseChange(row));
        const cursor = page.length === 0
          ? originalCursor
          : encodeCursor(number(page.at(-1).change_id, 'change_id'));
        return json({ protocolVersion, changes, cursor, hasMore }, 200, requestId);
      }

      const attachment = /^\/v1\/sync\/attachments\/([0-9a-f]{64})$/.exec(url.pathname);
      if (attachment && method === 'PUT') {
        const token = bearer(request);
        const user = await currentUser(token);
        const checksum = attachment[1];
        const bytes = await readBytes(request, config.maxAttachmentBytes);
        if (bytes.length === 0 || sha256(bytes) !== checksum) {
          throw new ApiError(400, 'attachment_checksum_mismatch', '同步图片校验失败。');
        }
        const response = await upstream(
          `/storage/v1/object/cardfolio-private/${encodeURIComponent(user.id)}/${checksum}`,
          {
            method: 'POST',
            headers: {
              ...userHeaders(token),
              'content-type': 'application/octet-stream',
              'x-upsert': 'true',
            },
            body: bytes,
          },
        );
        if (!response.ok) throw upstreamError(response.status);
        return empty(204, requestId);
      }

      if (attachment && method === 'GET') {
        const token = bearer(request);
        const user = await currentUser(token);
        const checksum = attachment[1];
        const response = await upstream(
          `/storage/v1/object/authenticated/cardfolio-private/${encodeURIComponent(user.id)}/${checksum}`,
          { headers: userHeaders(token) },
        );
        if (!response.ok) throw upstreamError(response.status);
        const bytes = Buffer.from(await response.arrayBuffer());
        if (bytes.length === 0 || bytes.length > config.maxAttachmentBytes || sha256(bytes) !== checksum) {
          throw new ApiError(502, 'attachment_checksum_mismatch', '云端图片校验失败。', true);
        }
        return new Response(bytes, {
          status: 200,
          headers: responseHeaders(requestId, {
            'content-type': 'application/octet-stream',
            'content-length': String(bytes.length),
            'x-content-sha256': checksum,
          }),
        });
      }

      throw new ApiError(404, 'not_found', '请求的接口不存在。');
    } catch (error) {
      const safe = error instanceof ApiError
        ? error
        : new ApiError(500, 'internal_error', '服务暂时不可用，请稍后重试。', true);
      return json({ code: safe.code, message: safe.message, retryable: safe.retryable }, safe.status, requestId);
    }
  }

  async function authenticateAction(action, body) {
    if (action === 'refresh') {
      requireString(body.refreshToken, 'refreshToken', 8192);
      requireString(body.deviceId, 'deviceId', 200);
      const response = await upstream('/auth/v1/token?grant_type=refresh_token', {
        method: 'POST',
        headers: anonHeaders(true),
        body: JSON.stringify({ refresh_token: body.refreshToken }),
      });
      if (!response.ok) throw authError(response.status);
      return session(await safeJson(response));
    }

    const email = requireString(body.email, 'email', 320).trim().toLowerCase();
    const password = requireString(body.password, 'password', 1024);
    const deviceId = requireString(body.deviceId, 'deviceId', 200);
    if (!email.includes('@') || password.length < 8) {
      throw new ApiError(400, 'invalid_credentials', '请输入有效邮箱和至少 8 位密码。');
    }
    if (action === 'register') {
      const created = await upstream('/auth/v1/signup', {
        method: 'POST',
        headers: anonHeaders(true),
        body: JSON.stringify({
          email,
          password,
          data: { initial_device_id: deviceId },
        }),
      });
      if (!created.ok) {
        if (created.status === 422 || created.status === 409) {
          throw new ApiError(409, 'account_exists', '该邮箱已注册。');
        }
        throw emailOtpError(created.status);
      }
      return { protocolVersion, resendAfterSeconds: 60 };
    }
    const response = await upstream('/auth/v1/token?grant_type=password', {
      method: 'POST',
      headers: anonHeaders(true),
      body: JSON.stringify({ email, password }),
    });
    if (!response.ok) throw authError(response.status);
    return session(await safeJson(response));
  }

  async function currentUser(token) {
    const response = await upstream('/auth/v1/user', { headers: userHeaders(token) });
    if (!response.ok) throw authError(response.status);
    const user = await safeJson(response);
    if (!user?.id || (!user?.email && !user?.phone)) {
      throw new ApiError(401, 'authentication_required', '登录已过期，请重新登录。');
    }
    return user;
  }

  function upstream(path, init = {}) {
    return fetchImpl(new URL(path, config.supabaseUrl), init);
  }

  function anonHeaders(jsonBody = false) {
    return {
      apikey: config.publishableKey,
      ...(jsonBody ? { 'content-type': 'application/json' } : {}),
    };
  }

  function userHeaders(token, jsonBody = false) {
    return {
      apikey: config.publishableKey,
      authorization: `Bearer ${token}`,
      ...(jsonBody ? { 'content-type': 'application/json' } : {}),
    };
  }

  function serviceHeaders(jsonBody = false) {
    return {
      apikey: config.secretKey,
      ...(jsonBody ? { 'content-type': 'application/json' } : {}),
    };
  }

  return Object.freeze({ handle });
}

function session(value) {
  const user = value?.user;
  const expiresAt = value?.expires_at
    ? new Date(Number(value.expires_at) * 1000)
    : new Date(Date.now() + Number(value?.expires_in ?? 3600) * 1000);
  const accountIdentifier = user?.email || user?.phone;
  if (!user?.id || !accountIdentifier || !value?.access_token || !value?.refresh_token || Number.isNaN(expiresAt.valueOf())) {
    throw new ApiError(502, 'upstream_protocol_error', '认证服务响应异常。', true);
  }
  return {
    protocolVersion,
    userId: user.id,
    // Keep the v1 field name for existing clients; it contains the signed-in
    // account identifier and may therefore be an E.164 phone number.
    email: accountIdentifier,
    accessToken: value.access_token,
    refreshToken: value.refresh_token,
    expiresAt: expiresAt.toISOString(),
  };
}

function validateMutation(value) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    throw new ApiError(400, 'invalid_mutation', '同步操作格式无效。');
  }
  if (!uuidPattern.test(value.operationId ?? '') || !entityTypes.has(value.entityType)) {
    throw new ApiError(400, 'invalid_mutation', '同步操作标识无效。');
  }
  requireString(value.entityId, 'entityId', 2048);
  if (!['upsert', 'delete'].includes(value.operation) || !Number.isSafeInteger(value.baseServerVersion) || value.baseServerVersion < 0) {
    throw new ApiError(400, 'invalid_mutation', '同步操作版本无效。');
  }
  if ((value.operation === 'upsert') !== (value.payload != null) || (value.payload != null && (typeof value.payload !== 'object' || Array.isArray(value.payload)))) {
    throw new ApiError(400, 'invalid_mutation', '同步操作载荷无效。');
  }
  if (!Array.isArray(value.changedFields) || value.changedFields.some((field) => typeof field !== 'string' || field.length > 200)) {
    throw new ApiError(400, 'invalid_mutation', '同步字段列表无效。');
  }
  if (typeof value.createdAt !== 'string' || Number.isNaN(Date.parse(value.createdAt))) {
    throw new ApiError(400, 'invalid_mutation', '同步操作时间无效。');
  }
}

function normalizeDatabaseChange(row) {
  return normalizeChange({
    changeId: String(number(row.change_id, 'change_id')),
    entityType: row.entity_type,
    entityId: row.entity_id,
    operation: row.operation,
    payload: row.payload,
    serverVersion: row.server_version,
    changedFields: row.changed_fields,
    occurredAt: row.occurred_at,
  });
}

function normalizeChange(value) {
  if (!value || !entityTypes.has(value.entityType) || !['upsert', 'delete'].includes(value.operation)) {
    throw new ApiError(502, 'upstream_protocol_error', '云端变更格式异常。', true);
  }
  return {
    changeId: String(value.changeId),
    entityType: value.entityType,
    entityId: requireString(value.entityId, 'entityId', 2048),
    operation: value.operation,
    serverVersion: number(value.serverVersion, 'serverVersion'),
    payload: value.payload ?? null,
    changedFields: Array.isArray(value.changedFields) ? value.changedFields : [],
    occurredAt: new Date(value.occurredAt).toISOString(),
  };
}

function encodeCursor(changeId) {
  return Buffer.from(`v1:${changeId}`).toString('base64url');
}

function decodeCursor(cursor) {
  if (cursor == null || cursor === '') return 0;
  try {
    const decoded = Buffer.from(cursor, 'base64url').toString('utf8');
    if (!decoded.startsWith('v1:')) throw new Error();
    const value = Number(decoded.slice(3));
    if (!Number.isSafeInteger(value) || value < 0) throw new Error();
    return value;
  } catch {
    throw new ApiError(400, 'invalid_cursor', '同步游标无效。');
  }
}

function parseLimit(raw) {
  const value = raw == null ? 100 : Number(raw);
  if (!Number.isSafeInteger(value) || value < 1 || value > 100) {
    throw new ApiError(400, 'invalid_limit', '同步分页大小必须在 1 至 100 之间。');
  }
  return value;
}

async function readJson(request, maxBytes) {
  const bytes = await readBytes(request, maxBytes);
  try {
    const value = JSON.parse(bytes.toString('utf8'));
    if (!value || typeof value !== 'object' || Array.isArray(value)) throw new Error();
    return value;
  } catch {
    throw new ApiError(400, 'invalid_json', '请求内容不是有效 JSON。');
  }
}

async function readBytes(request, maxBytes) {
  const declared = Number(request.headers.get('content-length'));
  if (Number.isFinite(declared) && declared > maxBytes) {
    throw new ApiError(413, 'payload_too_large', '请求内容超过大小限制。');
  }
  if (!request.body) return Buffer.alloc(0);
  const reader = request.body.getReader();
  const chunks = [];
  let size = 0;
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    size += value.byteLength;
    if (size > maxBytes) {
      await reader.cancel();
      throw new ApiError(413, 'payload_too_large', '请求内容超过大小限制。');
    }
    chunks.push(Buffer.from(value));
  }
  return Buffer.concat(chunks, size);
}

async function safeJson(response) {
  try {
    return await response.json();
  } catch {
    throw new ApiError(502, 'upstream_protocol_error', '上游服务响应异常。', true);
  }
}

async function mutationError(response) {
  let code = '';
  try {
    const body = await response.json();
    code = `${body?.message ?? ''} ${body?.code ?? ''}`;
  } catch {
    // Never expose an upstream response body.
  }
  if (code.includes('idempotency_mismatch')) {
    return new ApiError(409, 'idempotency_mismatch', '同步操作校验不一致，本地更改已保留。');
  }
  if (code.includes('invalid_mutation')) {
    return new ApiError(400, 'invalid_mutation', '同步操作格式无效。');
  }
  return upstreamError(response.status);
}

function requireProtocol(body) {
  if (body.protocolVersion !== protocolVersion) {
    throw new ApiError(400, 'unsupported_protocol', '客户端同步协议版本不受支持。');
  }
}

function requireString(value, name, maxLength) {
  if (typeof value !== 'string' || value.length === 0 || value.length > maxLength) {
    throw new ApiError(400, 'invalid_request', `请求字段 ${name} 无效。`);
  }
  return value;
}

function normalizePhone(value) {
  const phone = requireString(value, 'phone', 16).replace(/[\s()-]/g, '');
  if (!phonePattern.test(phone)) {
    throw new ApiError(400, 'invalid_phone', '手机号必须使用国际格式，例如 +8613812345678。');
  }
  return phone;
}

function normalizeEmail(value) {
  const email = requireString(value, 'email', 320).trim().toLowerCase();
  if (!email.includes('@') || email.startsWith('@') || email.endsWith('@')) {
    throw new ApiError(400, 'invalid_email', '请输入有效邮箱地址。');
  }
  return email;
}

function number(value, name) {
  const parsed = typeof value === 'number' ? value : Number(value);
  if (!Number.isSafeInteger(parsed) || parsed < 0) {
    throw new ApiError(502, 'upstream_protocol_error', `云端字段 ${name} 无效。`, true);
  }
  return parsed;
}

function bearer(request) {
  const value = request.headers.get('authorization') ?? '';
  if (!value.startsWith('Bearer ') || value.length <= 7) {
    throw new ApiError(401, 'authentication_required', '请先登录。');
  }
  return value.slice(7);
}

function clientAddress(request, trustProxy) {
  if (trustProxy) {
    const realIp = request.headers.get('x-real-ip')?.trim();
    if (realIp) return realIp.slice(0, 128);
    const forwarded = request.headers.get('x-forwarded-for')?.split(',').at(-1)?.trim();
    if (forwarded) return forwarded.slice(0, 128);
  }
  return 'unknown';
}

function authError(status) {
  if (status === 400 || status === 401 || status === 403) {
    return new ApiError(401, 'authentication_required', '邮箱、密码或登录状态无效。');
  }
  return upstreamError(status);
}

function phoneAuthError(status) {
  if (status === 400 || status === 401 || status === 403 || status === 422) {
    return new ApiError(401, 'phone_auth_failed', '手机号或短信验证码无效。');
  }
  return upstreamError(status);
}

function emailOtpError(status) {
  if (status === 400 || status === 401 || status === 403 || status === 422) {
    return new ApiError(401, 'email_auth_failed', '邮箱或验证码无效。');
  }
  return upstreamError(status);
}

function upstreamError(status) {
  if (status === 401) return new ApiError(401, 'authentication_required', '登录已过期，请重新登录。');
  if (status === 403) return new ApiError(403, 'forbidden', '没有权限访问这份云端数据。');
  if (status === 404) return new ApiError(404, 'not_found', '请求的数据不存在。');
  if (status === 409) return new ApiError(409, 'conflict', '云端数据存在冲突。');
  if (status === 429) return new ApiError(429, 'rate_limited', '请求过于频繁，请稍后重试。', true);
  return new ApiError(502, 'upstream_unavailable', '云端服务暂时不可用。', true);
}

function sha256(bytes) {
  return createHash('sha256').update(bytes).digest('hex');
}

function responseHeaders(requestId, extra = {}) {
  return {
    'cache-control': 'no-store',
    'access-control-allow-origin': '*',
    'access-control-allow-methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'access-control-allow-headers': [
      'Authorization',
      'Content-Type',
      'Idempotency-Key',
      'X-Account-Deletion-Confirmation',
      'X-Content-SHA256',
      'X-Request-ID',
    ].join(', '),
    'access-control-expose-headers': 'X-Content-SHA256, X-File-Name, X-Request-ID',
    'x-content-type-options': 'nosniff',
    'x-request-id': requestId,
    ...extra,
  };
}

function json(value, status, requestId) {
  return new Response(JSON.stringify(value), {
    status,
    headers: responseHeaders(requestId, { 'content-type': 'application/json; charset=utf-8' }),
  });
}

function empty(status, requestId) {
  return new Response(null, { status, headers: responseHeaders(requestId) });
}
