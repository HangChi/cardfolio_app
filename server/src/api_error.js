export class ApiError extends Error {
  constructor(status, code, message, retryable = false) {
    super(message);
    this.status = status;
    this.code = code;
    this.retryable = retryable;
  }
}

export function upstreamError(status) {
  if (status === 401) return new ApiError(401, 'authentication_required', '登录已过期，请重新登录。');
  if (status === 403) return new ApiError(403, 'forbidden', '没有权限访问这份云端数据。');
  if (status === 404) return new ApiError(404, 'not_found', '请求的数据不存在。');
  if (status === 409) return new ApiError(409, 'conflict', '云端数据存在冲突。');
  if (status === 429) return new ApiError(429, 'rate_limited', '请求过于频繁，请稍后重试。', true);
  return new ApiError(502, 'upstream_unavailable', '云端服务暂时不可用。', true);
}
