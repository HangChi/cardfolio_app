import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import test from 'node:test';

import { createApp } from '../src/app.js';

const config = Object.freeze({
  supabaseUrl: new URL('https://supabase.example.test'),
  publishableKey: 'sb_publishable_test',
  secretKey: 'sb_secret_test',
  maxJsonBytes: 2 * 1024 * 1024,
  maxAttachmentBytes: 64 * 1024 * 1024,
  authRateLimit: 20,
  authRateWindowMs: 15 * 60 * 1000,
  trustProxy: true,
});

const jsonResponse = (value, status = 200) => new Response(JSON.stringify(value), {
  status,
  headers: { 'content-type': 'application/json' },
});

const request = (path, { method = 'GET', token, body, headers = {} } = {}) =>
  new Request(`https://sync.example.test${path}`, {
    method,
    headers: {
      ...(token ? { authorization: `Bearer ${token}` } : {}),
      ...(body == null ? {} : { 'content-type': 'application/json' }),
      ...headers,
    },
    body: body == null ? undefined : typeof body === 'string' || Buffer.isBuffer(body)
      ? body
      : JSON.stringify(body),
  });

test('health check does not depend on Supabase', async () => {
  const app = createApp(config, {
    fetchImpl: () => assert.fail('health check must not call upstream'),
  });

  const response = await app.handle(request('/healthz'));

  assert.equal(response.status, 200);
  assert.deepEqual(await response.json(), { status: 'ok' });
  assert.ok(response.headers.get('x-request-id'));
});

test('CORS preflight is answered without calling Supabase', async () => {
  const app = createApp(config, {
    fetchImpl: () => assert.fail('preflight must not call upstream'),
  });

  const response = await app.handle(request('/v1/sync/pull', { method: 'OPTIONS' }));

  assert.equal(response.status, 204);
  assert.equal(response.headers.get('access-control-allow-origin'), '*');
  assert.match(response.headers.get('access-control-allow-headers'), /Authorization/);
});

test('login proxies Supabase Auth and returns the Flutter session contract', async () => {
  let upstreamRequest;
  const app = createApp(config, {
    fetchImpl: async (url, init) => {
      upstreamRequest = { url: url.toString(), init };
      return jsonResponse({
        access_token: 'access-secret',
        refresh_token: 'refresh-secret',
        expires_at: 1_800_000_000,
        user: { id: 'user-1', email: 'collector@example.test' },
      });
    },
  });

  const response = await app.handle(request('/v1/auth/login', {
    method: 'POST',
    body: {
      protocolVersion: 1,
      email: ' Collector@Example.Test ',
      password: 'password-123',
      deviceId: 'device-1',
    },
  }));

  assert.equal(response.status, 200);
  assert.equal(upstreamRequest.url, 'https://supabase.example.test/auth/v1/token?grant_type=password');
  assert.equal(upstreamRequest.init.headers.apikey, 'sb_publishable_test');
  assert.equal(upstreamRequest.init.headers.authorization, undefined);
  assert.deepEqual(JSON.parse(upstreamRequest.init.body), {
    email: 'collector@example.test',
    password: 'password-123',
  });
  assert.deepEqual(await response.json(), {
    protocolVersion: 1,
    userId: 'user-1',
    email: 'collector@example.test',
    accessToken: 'access-secret',
    refreshToken: 'refresh-secret',
    expiresAt: '2027-01-15T08:00:00.000Z',
  });
});

test('email registration sends a signup OTP and verifies it once', async () => {
  const calls = [];
  const app = createApp(config, {
    fetchImpl: async (url, init) => {
      calls.push({ url: url.toString(), init });
      if (new URL(url).pathname.endsWith('/signup')) return jsonResponse({ user: { id: 'pending-user' } });
      return jsonResponse({
        access_token: 'signup-access',
        refresh_token: 'signup-refresh',
        expires_in: 3600,
        user: { id: 'user-signup', email: 'new@example.test' },
      });
    },
  });

  const sent = await app.handle(request('/v1/auth/register', {
    method: 'POST',
    body: {
      protocolVersion: 1,
      email: ' New@Example.Test ',
      password: 'password-123',
      deviceId: 'device-1',
    },
  }));
  const verified = await app.handle(request('/v1/auth/register/verify', {
    method: 'POST',
    body: {
      protocolVersion: 1,
      email: 'new@example.test',
      code: '123456',
      deviceId: 'device-1',
    },
  }));

  assert.equal(sent.status, 200);
  assert.equal(calls[0].url, 'https://supabase.example.test/auth/v1/signup');
  assert.deepEqual(JSON.parse(calls[0].init.body), {
    email: 'new@example.test',
    password: 'password-123',
    data: { initial_device_id: 'device-1' },
  });
  assert.deepEqual(JSON.parse(calls[1].init.body), {
    email: 'new@example.test',
    token: '123456',
    type: 'signup',
  });
  assert.equal((await verified.json()).accessToken, 'signup-access');
});

test('password recovery verifies the OTP before changing the password', async () => {
  const calls = [];
  const app = createApp(config, {
    fetchImpl: async (url, init) => {
      calls.push({ url: url.toString(), init });
      const path = new URL(url).pathname;
      if (path.endsWith('/recover')) return jsonResponse({});
      if (path.endsWith('/verify')) return jsonResponse({
        access_token: 'recovery-access',
        refresh_token: 'recovery-refresh',
        expires_in: 3600,
        user: { id: 'user-recovery', email: 'collector@example.test' },
      });
      return jsonResponse({ id: 'user-recovery' });
    },
  });

  const sent = await app.handle(request('/v1/auth/password/reset/send', {
    method: 'POST',
    body: { protocolVersion: 1, email: 'collector@example.test', deviceId: 'device-1' },
  }));
  const verified = await app.handle(request('/v1/auth/password/reset/verify', {
    method: 'POST',
    body: {
      protocolVersion: 1,
      email: 'collector@example.test',
      code: '654321',
      newPassword: 'new-password-123',
      deviceId: 'device-1',
    },
  }));

  assert.equal(sent.status, 200);
  assert.equal(calls[0].url, 'https://supabase.example.test/auth/v1/recover');
  assert.deepEqual(JSON.parse(calls[1].init.body), {
    email: 'collector@example.test',
    token: '654321',
    type: 'recovery',
  });
  assert.equal(calls[2].url, 'https://supabase.example.test/auth/v1/user');
  assert.equal(calls[2].init.headers.authorization, 'Bearer recovery-access');
  assert.deepEqual(JSON.parse(calls[2].init.body), { password: 'new-password-123' });
  assert.equal((await verified.json()).accessToken, 'recovery-access');
});

test('admin calls send the secret key only in apikey', async () => {
  let upstreamRequest;
  const app = createApp(config, {
    fetchImpl: async (url, init) => {
      upstreamRequest = { url: url.toString(), init };
      return jsonResponse({ external: { email: true } });
    },
  });

  const response = await app.handle(request('/readyz'));

  assert.equal(response.status, 200);
  assert.equal(upstreamRequest.url, 'https://supabase.example.test/auth/v1/settings');
  assert.equal(upstreamRequest.init.headers.apikey, 'sb_secret_test');
  assert.equal(upstreamRequest.init.headers.authorization, undefined);
});

test('phone registration sends an SMS OTP without using bearer API keys', async () => {
  let upstreamRequest;
  const app = createApp(config, {
    fetchImpl: async (url, init) => {
      upstreamRequest = { url: url.toString(), init };
      return jsonResponse({});
    },
  });

  const response = await app.handle(request('/v1/auth/phone/send', {
    method: 'POST',
    body: {
      protocolVersion: 1,
      phone: '+86 13812345678',
      createUser: true,
      deviceId: 'device-1',
    },
  }));

  assert.equal(response.status, 200);
  assert.equal(upstreamRequest.url, 'https://supabase.example.test/auth/v1/otp');
  assert.equal(upstreamRequest.init.headers.apikey, 'sb_publishable_test');
  assert.equal(upstreamRequest.init.headers.authorization, undefined);
  assert.deepEqual(JSON.parse(upstreamRequest.init.body), {
    phone: '+8613812345678',
    create_user: true,
    channel: 'sms',
    data: { initial_device_id: 'device-1' },
  });
  assert.deepEqual(await response.json(), {
    protocolVersion: 1,
    resendAfterSeconds: 60,
  });
});

test('phone OTP verification returns a session for a phone-only user', async () => {
  let upstreamRequest;
  const app = createApp(config, {
    fetchImpl: async (url, init) => {
      upstreamRequest = { url: url.toString(), init };
      return jsonResponse({
        access_token: 'phone-access',
        refresh_token: 'phone-refresh',
        expires_in: 3600,
        user: { id: 'user-phone', phone: '+8613812345678' },
      });
    },
  });

  const response = await app.handle(request('/v1/auth/phone/verify', {
    method: 'POST',
    body: {
      protocolVersion: 1,
      phone: '+8613812345678',
      code: '123456',
      deviceId: 'device-1',
    },
  }));

  assert.equal(response.status, 200);
  assert.equal(upstreamRequest.url, 'https://supabase.example.test/auth/v1/verify');
  assert.deepEqual(JSON.parse(upstreamRequest.init.body), {
    phone: '+8613812345678',
    token: '123456',
    type: 'sms',
  });
  const body = await response.json();
  assert.equal(body.userId, 'user-phone');
  assert.equal(body.email, '+8613812345678');
  assert.equal(body.accessToken, 'phone-access');
});

test('email registration sends and verifies an OTP', async () => {
  const calls = [];
  const app = createApp(config, {
    fetchImpl: async (url, init) => {
      calls.push({ url: url.toString(), init });
      if (new URL(url).pathname.endsWith('/otp')) return jsonResponse({});
      return jsonResponse({
        access_token: 'email-access',
        refresh_token: 'email-refresh',
        expires_in: 3600,
        user: { id: 'user-email', email: 'collector@example.test' },
      });
    },
  });

  const sent = await app.handle(request('/v1/auth/email/send', {
    method: 'POST',
    body: {
      protocolVersion: 1,
      email: ' Collector@Example.Test ',
      createUser: true,
      deviceId: 'device-1',
    },
  }));
  const verified = await app.handle(request('/v1/auth/email/verify', {
    method: 'POST',
    body: {
      protocolVersion: 1,
      email: 'collector@example.test',
      code: '123456',
      deviceId: 'device-1',
    },
  }));

  assert.equal(sent.status, 200);
  assert.deepEqual(JSON.parse(calls[0].init.body), {
    email: 'collector@example.test',
    create_user: true,
    data: { initial_device_id: 'device-1' },
  });
  assert.equal(verified.status, 200);
  assert.deepEqual(JSON.parse(calls[1].init.body), {
    email: 'collector@example.test',
    token: '123456',
    type: 'email',
  });
  assert.equal((await verified.json()).accessToken, 'email-access');
});

test('pull keeps the public cursor opaque and requests one lookahead row', async () => {
  const calls = [];
  const app = createApp(config, {
    fetchImpl: async (url, init) => {
      calls.push({ url: new URL(url), init });
      if (new URL(url).pathname === '/auth/v1/user') {
        return jsonResponse({ id: 'user-1', email: 'collector@example.test' });
      }
      return jsonResponse([
        {
          change_id: 41,
          entity_type: 'cardDefinitions',
          entity_id: 'definition-1',
          operation: 'upsert',
          payload: { id: 'definition-1', name: '测试卡' },
          server_version: 2,
          changed_fields: ['name'],
          occurred_at: '2026-08-29T01:00:00.000Z',
        },
        {
          change_id: 42,
          entity_type: 'cardDefinitions',
          entity_id: 'definition-2',
          operation: 'delete',
          payload: null,
          server_version: 3,
          changed_fields: [],
          occurred_at: '2026-08-29T01:01:00.000Z',
        },
      ]);
    },
  });

  const response = await app.handle(request('/v1/sync/pull?limit=1', { token: 'access-secret' }));
  const body = await response.json();

  assert.equal(response.status, 200);
  assert.equal(body.protocolVersion, 1);
  assert.equal(body.hasMore, true);
  assert.equal(body.changes.length, 1);
  assert.equal(body.changes[0].changeId, '41');
  assert.equal(Buffer.from(body.cursor, 'base64url').toString(), 'v1:41');
  const query = calls[1].url.searchParams;
  assert.equal(query.get('change_id'), 'gt.0');
  assert.equal(query.get('limit'), '2');
});

test('push returns acknowledgements and conflict changes without bypassing the user JWT', async () => {
  const calls = [];
  const app = createApp(config, {
    fetchImpl: async (url, init) => {
      calls.push({ url: new URL(url), init });
      if (new URL(url).pathname === '/auth/v1/user') {
        return jsonResponse({ id: 'user-1', email: 'collector@example.test' });
      }
      return jsonResponse({
        kind: 'ack',
        operationId: '4f8d7a3e-28c2-4aa2-94b8-a08f2248d64c',
        entityType: 'cardDefinitions',
        entityId: 'definition-1',
        serverVersion: 3,
      });
    },
  });
  const mutation = {
    operationId: '4f8d7a3e-28c2-4aa2-94b8-a08f2248d64c',
    entityType: 'cardDefinitions',
    entityId: 'definition-1',
    operation: 'upsert',
    baseServerVersion: 2,
    payload: { id: 'definition-1', name: '本地名称' },
    changedFields: ['name'],
    createdAt: '2026-08-29T01:00:00.000Z',
  };

  const response = await app.handle(request('/v1/sync/push', {
    method: 'POST',
    token: 'access-secret',
    body: { protocolVersion: 1, deviceId: 'device-1', mutations: [mutation] },
  }));
  const body = await response.json();

  assert.equal(response.status, 200);
  assert.equal(body.acks[0].serverVersion, 3);
  assert.deepEqual(body.changes, []);
  assert.equal(calls[1].url.pathname, '/rest/v1/rpc/cardfolio_apply_mutation');
  assert.equal(calls[1].init.headers.authorization, 'Bearer access-secret');
  assert.deepEqual(JSON.parse(calls[1].init.body), { p_mutation: mutation });
});

test('attachment upload verifies SHA-256 before touching Storage', async () => {
  const bytes = Buffer.from([1, 2, 3, 4]);
  const checksum = createHash('sha256').update(bytes).digest('hex');
  const calls = [];
  const app = createApp(config, {
    fetchImpl: async (url, init) => {
      calls.push({ url: new URL(url), init });
      if (new URL(url).pathname === '/auth/v1/user') {
        return jsonResponse({ id: 'user-1', email: 'collector@example.test' });
      }
      return jsonResponse({}, 200);
    },
  });

  const response = await app.handle(request(`/v1/sync/attachments/${checksum}`, {
    method: 'PUT',
    token: 'access-secret',
    body: bytes,
    headers: { 'content-type': 'application/octet-stream' },
  }));

  assert.equal(response.status, 204);
  assert.equal(calls[1].url.pathname, `/storage/v1/object/cardfolio-private/user-1/${checksum}`);
  assert.equal(calls[1].init.headers['x-upsert'], 'true');
  assert.deepEqual(Buffer.from(calls[1].init.body), bytes);
});

test('errors never expose an upstream response body', async () => {
  const app = createApp(config, {
    fetchImpl: async () => jsonResponse({
      message: 'database card name and service role secret',
    }, 503),
  });

  const response = await app.handle(request('/v1/auth/login', {
    method: 'POST',
    body: {
      protocolVersion: 1,
      email: 'collector@example.test',
      password: 'password-123',
      deviceId: 'device-1',
    },
  }));
  const body = await response.json();

  assert.equal(response.status, 502);
  assert.equal(body.code, 'upstream_unavailable');
  assert.equal(body.retryable, true);
  assert.doesNotMatch(body.message, /database|secret/i);
});
