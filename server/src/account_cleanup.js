import { ApiError, upstreamError } from './api_error.js';

export async function deleteAccountAttachments({ token, userId, upstream, userHeaders }) {
  const prefix = `${userId}/`;
  for (let page = 0; page < 1000; page += 1) {
    const listed = await upstream('/storage/v1/object/list/cardfolio-private', {
      method: 'POST',
      headers: userHeaders(token, true),
      body: JSON.stringify({
        prefix: userId,
        limit: 1000,
        offset: 0,
        sortBy: { column: 'name', order: 'asc' },
      }),
    });
    if (!listed.ok) throw upstreamError(listed.status);
    const objects = await safeJson(listed);
    if (!Array.isArray(objects)) {
      throw new ApiError(502, 'upstream_protocol_error', '云端附件列表格式异常。', true);
    }
    if (objects.length === 0) return;
    const paths = objects.map((object) => {
      const name = object?.name;
      if (typeof name !== 'string' || name.length === 0 || name.includes('/')) {
        throw new ApiError(502, 'upstream_protocol_error', '云端附件路径格式异常。', true);
      }
      return `${prefix}${name}`;
    });
    const deleted = await upstream('/storage/v1/object/cardfolio-private', {
      method: 'DELETE',
      headers: userHeaders(token, true),
      body: JSON.stringify({ prefixes: paths }),
    });
    if (!deleted.ok) throw upstreamError(deleted.status);
    if (objects.length < 1000) return;
  }
  throw new ApiError(409, 'account_cleanup_incomplete', '云端附件过多，账号清理尚未完成。', true);
}

async function safeJson(response) {
  try {
    return await response.json();
  } catch {
    throw new ApiError(502, 'upstream_protocol_error', '上游服务响应异常。', true);
  }
}
