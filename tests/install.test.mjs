import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, mkdtempSync, mkdirSync, readFileSync, readdirSync, realpathSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { installHearth, prepareHearth } from '../scripts/install.mjs';
const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
function tmp(t) { const p = realpathSync(mkdtempSync(join(tmpdir(), 'hearth-test-'))); t.after(() => rmSync(p, { recursive: true, force: true })); return p; }
test('preview changes nothing', t => { const home = tmp(t); assert.equal(installHearth({ home }).dryRun, true); assert.deepEqual(readdirSync(home), []); });
test('every plan is made against vendor-lock.json: the source pins carry the locked commits', t => {
  const lock = JSON.parse(readFileSync(join(root, 'vendor-lock.json'), 'utf8'));
  const pins = prepareHearth({ home: tmp(t) }).sourcePins;
  for (const name of ['eidolon', 'setup']) assert.equal(pins.find(p => p.name === name).commit, lock.sources[name], name);
});
test('a project install lands both skills under .claude and nothing under .agents', t => {
  const project = tmp(t), result = installHearth({ project, dryRun: false });
  assert.ok(result.ok); assert.ok(result.copied > 100);
  for (const name of ['eidolon', 'setup']) assert.ok(existsSync(join(project, '.claude/skills', name, 'SKILL.md')));
  assert.equal(existsSync(join(project, '.agents')), false);
  assert.equal(existsSync(join(project, '.codex')), false);
});
test('a host option other than Claude is ignored, never honored', t => {
  const project = tmp(t); installHearth({ project, host: 'codex', dryRun: false });
  assert.ok(existsSync(join(project, '.claude/skills/setup/SKILL.md')));
  assert.equal(existsSync(join(project, '.agents')), false);
});
test('shipped Eidolon carries the platform contract, the pipeline references and the dispatch guard', () => {
  const base = join(root, 'skills/eidolon');
  for (const path of ['references/current-platform-contract.md', 'references/engineering-principles.md', 'references/autopilot-guide.md', 'references/interview.md', 'references/conductor-standard.md', 'hooks/guard-dispatch.mjs', 'hooks/lanes.mjs', 'scripts/hooks-readme-check.mjs']) assert.ok(existsSync(join(base, path)), path);
  assert.match(readFileSync(join(base, 'references/current-platform-contract.md'), 'utf8'), /Do not hardcode a point release/);
  assert.equal(existsSync(join(base, 'codex')), false);
  assert.equal(existsSync(join(base, 'engine')), false);
});
test('shipped Setup opens with the brain dump and carries evidence-based skill selection', () => {
  const s = readFileSync(join(root, 'skills/setup/SKILL.md'), 'utf8');
  assert.match(s, /brain dump/i);
  assert.match(s, /smallest sufficient non-conflicting set/);
  assert.match(s, /record a gap/);
  assert.match(s, /Never pin behavior to a remembered/);
  assert.equal(existsSync(join(root, 'skills/setup/codex')), false);
});
test('partial failure is never a success', t => {
  const project = tmp(t);
  mkdirSync(join(project, '.claude/skills/setup'), { recursive: true });
  writeFileSync(join(project, '.claude/skills/setup/SKILL.md'), 'existing');
  assert.throws(() => installHearth({ project, dryRun: false }), /replace/);
  assert.ok(!existsSync(join(project, '.claude/skills/eidolon')));
});
test('explicit replace keeps the old installation', t => {
  const home = tmp(t); installHearth({ home, dryRun: false });
  writeFileSync(join(home, '.claude/skills/setup/SKILL.md'), 'local edit');
  const result = installHearth({ home, dryRun: false, replace: true });
  const receipt = JSON.parse(readFileSync(join(result.backups, 'receipt.json')));
  const item = receipt.changes.find(x => x.path.endsWith('setup'));
  assert.equal(readFileSync(join(item.backup, 'SKILL.md'), 'utf8'), 'local edit');
});
test('CLI applies only the previewed plan and reports completion only after both skills land', t => {
  const home = tmp(t), cli = join(root, 'scripts/install.mjs');
  const bare = spawnSync(process.execPath, [cli, '--home', home, '--yes'], { encoding: 'utf8' });
  assert.notEqual(bare.status, 0); assert.match(bare.stderr, /--expect-plan/); assert.deepEqual(readdirSync(home), []);
  const preview = spawnSync(process.execPath, [cli, '--home', home], { encoding: 'utf8' });
  assert.equal(preview.status, 0, preview.stderr);
  const digest = JSON.parse(preview.stdout).planDigest;
  assert.match(digest, /^[0-9a-f]{64}$/);
  const result = spawnSync(process.execPath, [cli, '--home', home, '--yes', '--expect-plan', digest], { encoding: 'utf8' });
  assert.equal(result.status, 0, result.stderr);
  assert.equal(JSON.parse(result.stdout).ok, true);
  assert.ok(existsSync(join(home, '.claude/skills/setup/SKILL.md')));
});
test('CLI has no host option', () => {
  const result = spawnSync(process.execPath, [join(root, 'scripts/install.mjs'), '--host', 'codex'], { encoding: 'utf8' });
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /Unknown option/);
});
