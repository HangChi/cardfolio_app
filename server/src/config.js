const required = (env, name) => {
  const value = env[name]?.trim();
  if (!value) throw new Error(`Missing required environment variable: ${name}`);
  return value;
};

const preferred = (env, preferredName, legacyName) => {
  const value = env[preferredName]?.trim() || env[legacyName]?.trim();
  if (!value) {
    throw new Error(
      `Missing required environment variable: ${preferredName} (or legacy ${legacyName})`,
    );
  }
  return value;
};

const positiveInteger = (value, fallback, name) => {
  if (value == null || value === '') return fallback;
  const parsed = Number(value);
  if (!Number.isSafeInteger(parsed) || parsed <= 0) {
    throw new Error(`${name} must be a positive integer`);
  }
  return parsed;
};

export function loadConfig(env = process.env) {
  const supabaseUrl = new URL(required(env, 'SUPABASE_URL'));
  if (!['http:', 'https:'].includes(supabaseUrl.protocol)) {
    throw new Error('SUPABASE_URL must use http or https');
  }
  return Object.freeze({
    host: env.HOST?.trim() || '127.0.0.1',
    port: positiveInteger(env.PORT, 8080, 'PORT'),
    supabaseUrl,
    publishableKey: preferred(env, 'SUPABASE_PUBLISHABLE_KEY', 'SUPABASE_ANON_KEY'),
    secretKey: preferred(env, 'SUPABASE_SECRET_KEY', 'SUPABASE_SERVICE_ROLE_KEY'),
    maxJsonBytes: positiveInteger(env.MAX_JSON_BYTES, 2 * 1024 * 1024, 'MAX_JSON_BYTES'),
    maxAttachmentBytes: positiveInteger(
      env.MAX_ATTACHMENT_BYTES,
      64 * 1024 * 1024,
      'MAX_ATTACHMENT_BYTES',
    ),
    authRateLimit: positiveInteger(env.AUTH_RATE_LIMIT, 20, 'AUTH_RATE_LIMIT'),
    authRateWindowMs: positiveInteger(
      env.AUTH_RATE_WINDOW_MS,
      15 * 60 * 1000,
      'AUTH_RATE_WINDOW_MS',
    ),
    trustProxy: env.TRUST_PROXY === 'true',
  });
}
