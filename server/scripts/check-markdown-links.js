import { access, readFile, readdir } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const serverRoot = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
const projectRoot = path.dirname(serverRoot);
const docsRoot = path.join(projectRoot, 'docs');

async function markdownFiles(directory) {
  const entries = await readdir(directory, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    const target = path.join(directory, entry.name);
    if (entry.isDirectory()) files.push(...await markdownFiles(target));
    if (entry.isFile() && entry.name.endsWith('.md')) files.push(target);
  }
  return files;
}

const files = [
  path.join(projectRoot, 'README.md'),
  path.join(projectRoot, 'MIGRATION.md'),
  path.join(serverRoot, 'README.md'),
  ...await markdownFiles(docsRoot),
];
const failures = [];

for (const file of files) {
  const source = await readFile(file, 'utf8');
  const prose = source.replace(/^```[^\n]*\n[\s\S]*?^```\s*$/gm, '');
  const targets = [
    ...[...prose.matchAll(/\[[^\]]*\]\(([^)]+)\)/g)].map((match) => match[1]),
    ...[...prose.matchAll(/<img\s+[^>]*src="([^"]+)"/g)].map((match) => match[1]),
  ];
  for (const rawTarget of targets) {
    const withoutTitle = rawTarget.trim().replace(/^<|>$/g, '').split(/\s+["']/)[0];
    const localTarget = withoutTitle.split('#', 1)[0];
    if (!localTarget || /^(https?:|mailto:)/.test(localTarget)) continue;
    const resolved = path.resolve(path.dirname(file), decodeURIComponent(localTarget));
    try {
      await access(resolved);
    } catch {
      failures.push(
        `${path.relative(projectRoot, file)}: ${rawTarget} -> ${path.relative(projectRoot, resolved)}`,
      );
    }
  }
}

if (failures.length > 0) {
  console.error(`Found ${failures.length} broken local Markdown link(s):`);
  for (const failure of failures) console.error(`- ${failure}`);
  process.exitCode = 1;
} else {
  console.log(`Checked ${files.length} Markdown files; local links are valid.`);
}
