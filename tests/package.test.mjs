// The npm package is Hearth itself: the picker as the bin, the two bundles, the lock. The pack must carry
// every locked file (npm leaves .gitignore out of a package, so the bundles carry none) and no test or door scripts.
import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const pkg = JSON.parse(readFileSync(join(root, 'package.json'), 'utf8'));
test('package.json names the picker as the bin and needs Node 22', () => {
  assert.equal(pkg.name, 'eidolon-hearth');
  assert.deepEqual(pkg.bin, { 'eidolon-hearth': 'scripts/welcome.mjs' });
  assert.equal(pkg.engines.node, '>=22');
  assert.match(readFileSync(join(root, 'scripts/welcome.mjs'), 'utf8').split('\n')[0], /^#!\/usr\/bin\/env node/);
});
test('the pack carries every locked bundle file and nothing from tests or the doors', () => {
  const r = spawnSync(process.platform === 'win32' ? 'npm.cmd' : 'npm', ['pack', '--dry-run', '--json'], { cwd: root, encoding: 'utf8', shell: process.platform === 'win32' });
  assert.equal(r.status, 0, r.stderr);
  const [info] = JSON.parse(r.stdout);
  const packed = new Set(info.files.map(f => f.path));
  const lock = JSON.parse(readFileSync(join(root, 'vendor-lock.json'), 'utf8'));
  const missing = Object.keys(lock.files).filter(k => !packed.has('skills/' + k));
  assert.deepEqual(missing, [], 'locked files absent from the pack');
  for (const p of packed) {
    assert.ok(!p.startsWith('tests/') && !/\.(ps1|cmd|command)$/.test(p) && !p.startsWith('.ci-source'), 'unexpected file in the pack: ' + p);
  }
  for (const must of ['scripts/welcome.mjs', 'scripts/install.mjs', 'vendor-lock.json', 'README.md', 'LICENSE', 'CREDITS.md']) assert.ok(packed.has(must), must);
});
