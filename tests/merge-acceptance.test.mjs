// Acceptance cases for the operator door. All writes are disposable fixtures.
import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, writeFileSync, readFileSync, readdirSync, rmSync, existsSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { spawnSync, spawn } from 'node:child_process';
import { prepareHearth, applyHearth } from '../scripts/install.mjs';
function temporary(t) { const root = mkdtempSync(join(tmpdir(), 'hearth-acceptance-')); t.after(() => rmSync(root, { recursive: true, force: true })); return root; }
// Drive scripts/welcome.mjs: send each answer once its prompt text has appeared.
function drive(prompts, answers) {
  const child = spawn(process.execPath, [resolve('scripts/welcome.mjs')], { stdio: ['pipe', 'pipe', 'pipe'] });
  let output = '', errors = '', step = 0;
  const done = new Promise((ok, fail) => {
    child.on('error', fail);
    child.stderr.on('data', b => errors += b);
    child.stdout.on('data', b => { output += b; if (step < answers.length && output.includes(prompts[step])) child.stdin.write(answers[step++]); });
    child.on('close', code => ok({ code, output, errors, step }));
  });
  const timer = setTimeout(() => child.kill(), 30000);
  return done.finally(() => { clearTimeout(timer); if (child.exitCode === null) child.kill(); });
}
test('preview/apply preserves a concurrent human instruction edit', t => {
  const project = temporary(t); writeFileSync(join(project, 'CLAUDE.md'), 'before\n');
  const plan = prepareHearth({ project });
  assert.equal(applyHearth(plan).dryRun, true);
  writeFileSync(join(project, 'CLAUDE.md'), 'human after preview\n');
  assert.throws(() => applyHearth(plan, { dryRun: false }), /changed/);
  assert.equal(readFileSync(join(project, 'CLAUDE.md'), 'utf8'), 'human after preview\n');
  assert.equal(existsSync(join(project, '.claude/skills')), false);
});
test('CLI help and preview do not install skills', t => {
  const home = temporary(t), executable = resolve('scripts/install.mjs');
  const help = spawnSync(process.execPath, [executable, '--help'], { encoding: 'utf8' });
  assert.equal(help.status, 0); assert.doesNotMatch(help.stdout, /--host/);
  const preview = spawnSync(process.execPath, [executable, '--home', home], { encoding: 'utf8' });
  assert.equal(preview.status, 0, preview.stderr);
  assert.equal(JSON.parse(preview.stdout).dryRun, true);
  assert.deepEqual(readdirSync(home), []);
});
test('terminal cancellation leaves the chosen project untouched', async t => {
  const project = temporary(t);
  const r = await drive(['Project folder', 'Type yes to apply exactly this plan:'], [project + '\n', 'no\n']);
  assert.equal(r.code, 1, r.output + r.errors); assert.equal(r.step, 2);
  assert.match(r.output, /Proposed locations:/);
  assert.deepEqual(readdirSync(project), []);
});
test('only the literal yes applies; the receipt and next step are printed', async t => {
  const project = temporary(t);
  const r = await drive(['Project folder', 'Type yes to apply exactly this plan:'], [project + '\n', 'yes\n']);
  assert.equal(r.code, 0, r.output + r.errors);
  assert.match(r.output, /Verified skill files: \d{3,}/);
  assert.match(r.output, /Backup receipt: .*receipt\.json/);
  assert.match(r.output, /restart Claude Code/i);
  assert.ok(existsSync(join(project, '.claude/skills/eidolon/SKILL.md')));
  assert.ok(existsSync(join(project, '.claude/settings.json')));
});
test('an existing skill needs the word replace and is backed up', async t => {
  const project = temporary(t);
  const apply = ['Project folder', 'Type yes to apply exactly this plan:'];
  const first = await drive(apply, [project + '\n', 'yes\n']);
  assert.equal(first.code, 0, first.output + first.errors);
  const setupSkill = join(project, '.claude/skills/setup/SKILL.md');
  writeFileSync(setupSkill, 'local edit');
  const stopped = await drive(['Project folder', 'Type replace'], [project + '\n', '\n']);
  assert.equal(stopped.code, 1);
  assert.match(stopped.output, /moves your current copy to \.eidolon\/backups/);
  assert.equal(readFileSync(setupSkill, 'utf8'), 'local edit');
  const replaced = await drive(['Project folder', 'Type replace', 'Type yes to apply exactly this plan:'], [project + '\n', 'replace\n', 'yes\n']);
  assert.equal(replaced.code, 0, replaced.output + replaced.errors);
  assert.notEqual(readFileSync(setupSkill, 'utf8'), 'local edit');
  assert.ok(readdirSync(join(project, '.eidolon/backups')).length >= 2);
});
