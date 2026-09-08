import test from 'node:test';
import assert from 'node:assert/strict';
import { readdirSync, readFileSync, statSync } from 'node:fs';
import { join, relative } from 'node:path';
import { fileURLToPath } from 'node:url';

const ROOT = fileURLToPath(new URL('..', import.meta.url));
const SKIP_DIRS = new Set(['.git', 'node_modules', '.ci-source']);
const BINARY_EXT = /\.(png|jpg|jpeg|gif|webp|ico|icns|pdf|zip|tar|gz|woff2?|ttf|otf)$/i;
const legacyName = ['Fable', 'fox'].join('');
const legacyPattern = new RegExp(legacyName, 'i');

function walk(dir, hits = []) {
  for (const name of readdirSync(dir)) {
    if (SKIP_DIRS.has(name)) continue;
    const path = join(dir, name);
    const stat = statSync(path);
    if (stat.isDirectory()) { walk(path, hits); continue; }
    if (BINARY_EXT.test(name)) continue;
    let text;
    try { text = readFileSync(path, 'utf8'); } catch { continue; }
    const lines = text.split(/\r?\n/);
    lines.forEach((line, index) => {
      if (legacyPattern.test(line)) hits.push(`${relative(ROOT, path)}:${index + 1}: ${line.trim()}`);
    });
    if (legacyPattern.test(name)) hits.push(`${relative(ROOT, path)}: filename contains legacy character name`);
  }
  return hits;
}

test('user-facing character name is Eidolon everywhere', () => {
  const hits = walk(ROOT);
  assert.deepEqual(hits, [], `Legacy character-name references remain:\n${hits.join('\n')}`);
});
