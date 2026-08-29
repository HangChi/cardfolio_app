import http from 'node:http';

import { createApp } from './app.js';
import { loadConfig } from './config.js';

const config = loadConfig();
const app = createApp(config);
const absoluteRequestLimit = Math.max(config.maxJsonBytes, config.maxAttachmentBytes) + 1024;

const server = http.createServer(async (incoming, outgoing) => {
  try {
    const chunks = [];
    let size = 0;
    for await (const chunk of incoming) {
      size += chunk.length;
      if (size > absoluteRequestLimit) {
        outgoing.writeHead(413, { 'content-type': 'application/json; charset=utf-8' });
        outgoing.end(JSON.stringify({
          code: 'payload_too_large',
          message: '请求内容超过大小限制。',
          retryable: false,
        }));
        return;
      }
      chunks.push(chunk);
    }
    const host = incoming.headers.host || `${config.host}:${config.port}`;
    const request = new Request(`http://${host}${incoming.url || '/'}`, {
      method: incoming.method,
      headers: incoming.headers,
      body: chunks.length === 0 ? undefined : Buffer.concat(chunks, size),
    });
    const response = await app.handle(request);
    outgoing.writeHead(response.status, Object.fromEntries(response.headers));
    outgoing.end(Buffer.from(await response.arrayBuffer()));
  } catch {
    if (!outgoing.headersSent) {
      outgoing.writeHead(500, { 'content-type': 'application/json; charset=utf-8' });
    }
    outgoing.end(JSON.stringify({
      code: 'internal_error',
      message: '服务暂时不可用，请稍后重试。',
      retryable: true,
    }));
  }
});

server.requestTimeout = 120_000;
server.headersTimeout = 15_000;
server.keepAliveTimeout = 5_000;

server.on('error', (error) => {
  console.error(`gateway failed to listen: ${error.code ?? 'unknown'}`);
  process.exit(1);
});

server.listen(config.port, config.host, () => {
  console.log(`cardfolio-sync-gateway listening on ${config.host}:${config.port}`);
});

const shutdown = (signal) => {
  console.log(`received ${signal}, shutting down`);
  server.close((error) => process.exit(error ? 1 : 0));
  setTimeout(() => process.exit(1), 10_000).unref();
};

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
