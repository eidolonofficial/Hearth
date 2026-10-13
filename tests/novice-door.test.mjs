// The novice door must stay Node-free and must copy the skills exactly. Fixtures live in the OS temp dir.
import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, mkdtempSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync, mkdirSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, relative, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const ps1 = join(root, 'welcome.ps1');
const command = join(root, 'macos', 'Welcome.command');
const windows = process.platform === 'win32';
const bash = spawnSync('bash', ['--version'], { encoding: 'utf8' });
const hasBash = !bash.error && bash.status === 0;

function temp(t) { const p = mkdtempSync(join(tmpdir(), 'hearth-novice-')); t.after(() => rmSync(p, { recursive: true, force: true })); return p; }
function files(dir, base = dir, out = []) {
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) files(p, base, out); else out.push(relative(base, p).split('\\').join('/'));
  }
  return out;
}
function runPs(...args) {
  return spawnSync('powershell', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ps1, ...args], { encoding: 'utf8', timeout: 110000 });
}

test('the novice scripts never mention node', () => {
  for (const file of [ps1, command]) assert.doesNotMatch(readFileSync(file, 'utf8'), /\bnode\b/i, file);
});
test('welcome.ps1 is ASCII only', () => {
  assert.doesNotMatch(readFileSync(ps1, 'utf8'), /[^\x00-\x7F]/);
});
test('welcome.ps1 parses with zero errors', { skip: !windows && 'PowerShell parse check runs on Windows' }, () => {
  const script = '$e=$null;[System.Management.Automation.Language.Parser]::ParseFile($args[0],[ref]$null,[ref]$e)|Out-Null;$e.Count';
  const r = spawnSync('powershell', ['-NoProfile', '-Command', '& { ' + script + ' }', ps1], { encoding: 'utf8' });
  assert.equal(r.stdout.trim(), '0', r.stdout + r.stderr);
});
test('Welcome.command passes bash -n', { skip: !hasBash && 'bash is not available' }, () => {
  const r = spawnSync('bash', ['-n', command], { encoding: 'utf8' });
  assert.equal(r.status, 0, r.stderr);
});
test('welcome.ps1 copies every skill file byte for byte, then backs up on replace', { skip: !windows && 'PowerShell copy runs on Windows' }, t => {
  const home = temp(t), dest = join(home, '.claude', 'skills');
  let r = runPs('-Yes', '-Home', home);
  assert.equal(r.status, 0, r.stdout + r.stderr);
  const expected = files(join(root, 'skills')).sort();
  assert.deepEqual(files(dest).sort(), expected);
  for (const rel of expected) {
    const want = readFileSync(join(root, 'skills', rel)), got = readFileSync(join(dest, rel));
    assert.ok(want.equals(got), rel);
    assert.ok(!(got[0] === 0xEF && got[1] === 0xBB && got[2] === 0xBF), 'BOM in ' + rel);
    assert.ok(!got.includes(13), 'CR in ' + rel);
  }
  // A second run with an existing skill moves the old copy into a timestamped backup.
  writeFileSync(join(dest, 'setup', 'SKILL.md'), 'local edit');
  r = runPs('-Yes', '-Home', home);
  assert.equal(r.status, 0, r.stdout + r.stderr);
  const stamps = readdirSync(join(dest, '.hearth-backups'));
  assert.equal(stamps.length, 1);
  assert.match(stamps[0], /^\d{8}-\d{6}$/);
  assert.equal(readFileSync(join(dest, '.hearth-backups', stamps[0], 'setup', 'SKILL.md'), 'utf8'), 'local edit');
  assert.ok(readFileSync(join(dest, 'setup', 'SKILL.md')).equals(readFileSync(join(root, 'skills', 'setup', 'SKILL.md'))));
});
test('welcome.ps1 normalizes CRLF and BOM sources and leaves skip as the default', { skip: !windows && 'PowerShell copy runs on Windows' }, t => {
  // Copy the door and a one-skill tree into a fixture so the real skills/ stays untouched.
  const fixture = temp(t), home = temp(t);
  writeFileSync(join(fixture, 'welcome.ps1'), readFileSync(ps1));
  mkdirSync(join(fixture, 'skills', 'demo'), { recursive: true });
  writeFileSync(join(fixture, 'skills', 'demo', 'SKILL.md'), Buffer.concat([Buffer.from([0xEF, 0xBB, 0xBF]), Buffer.from('one\r\ntwo\r\n')]));
  const run = (...a) => spawnSync('powershell', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', join(fixture, 'welcome.ps1'), ...a], { encoding: 'utf8', input: '\n', timeout: 110000 });
  let r = run('-Home', home);
  assert.equal(r.status, 0, r.stdout + r.stderr);
  const target = join(home, '.claude', 'skills', 'demo', 'SKILL.md');
  assert.equal(readFileSync(target, 'latin1'), 'one\ntwo\n');
  writeFileSync(target, 'mine');
  r = run('-Home', home);  // no -Yes, Enter pressed: skip
  assert.match(r.stdout, /Skipped demo/);
  assert.equal(readFileSync(target, 'utf8'), 'mine');
  assert.equal(existsSync(join(home, '.claude', 'skills', '.hearth-backups')), false);
});

// The bash door, run for real wherever bash exists: Git Bash on Windows, and the Linux and macOS runners in CI.
const bashDoor = (args, home, input = '') => spawnSync('bash', [command, ...args, '--home', home], { encoding: 'utf8', input, timeout: 110000 });
test('Welcome.command copies every skill file byte for byte, keeps a skipped skill, then backs up on replace', { skip: !hasBash && 'bash is not available' }, t => {
  const home = temp(t), dest = join(home, '.claude', 'skills');
  let r = bashDoor(['--yes'], home);
  assert.equal(r.status, 0, r.stdout + r.stderr);
  assert.match(r.stdout, /Installed now: eidolon setup/);
  const expected = files(join(root, 'skills')).sort();
  assert.deepEqual(files(dest).sort(), expected);
  for (const rel of expected) {
    const want = readFileSync(join(root, 'skills', rel)), got = readFileSync(join(dest, rel));
    assert.ok(want.equals(got), rel);
    assert.ok(!got.includes(13), 'CR in ' + rel);
  }
  // Enter at the prompt keeps the existing copy.
  writeFileSync(join(dest, 'setup', 'SKILL.md'), 'local edit');
  r = bashDoor([], home, '\n\n');
  assert.equal(r.status, 0, r.stdout + r.stderr);
  assert.match(r.stdout, /Skipped, still your own copy/);
  assert.equal(readFileSync(join(dest, 'setup', 'SKILL.md'), 'utf8'), 'local edit');
  assert.equal(existsSync(join(dest, '.hearth-backups')), false);
  // --yes replaces, and the old copy moves to a stamped backup.
  r = bashDoor(['--yes'], home);
  assert.equal(r.status, 0, r.stdout + r.stderr);
  const stamps = readdirSync(join(dest, '.hearth-backups'));
  assert.equal(stamps.length, 1);
  assert.match(stamps[0], /^\d{8}-\d{6}$/);
  assert.equal(readFileSync(join(dest, '.hearth-backups', stamps[0], 'setup', 'SKILL.md'), 'utf8'), 'local edit');
  assert.ok(readFileSync(join(dest, 'setup', 'SKILL.md')).equals(readFileSync(join(root, 'skills', 'setup', 'SKILL.md'))));
});
test('Welcome.command refuses an unknown option and a missing --home value without writing', { skip: !hasBash && 'bash is not available' }, t => {
  const home = temp(t);
  for (const args of [['--frobnicate'], ['--home']]) {
    const r = spawnSync('bash', [command, ...args], { encoding: 'utf8', timeout: 30000, env: { ...process.env, HOME: home } });
    assert.equal(r.status, 2, args.join(' ') + ': ' + r.stdout + r.stderr);
    assert.match(r.stdout, /Nothing was installed/);
  }
  assert.equal(existsSync(join(home, '.claude')), false);
});
test('Operator Setup.command hands off to the picker and the picker stops cleanly on a blank answer', { skip: !hasBash && 'bash is not available' }, t => {
  // A blank project answer previews a home install, so the home is a temp folder, never the real one.
  const home = temp(t);
  const r = spawnSync('bash', [join(root, 'macos', 'Operator Setup.command')], { encoding: 'utf8', input: '\nno\n', timeout: 110000, env: { ...process.env, HOME: home, USERPROFILE: home } });
  assert.match(r.stdout, /Hearth operator setup/);
  assert.match(r.stdout, /Proposed locations:/);
  assert.notEqual(r.status, 0);
  assert.match(r.stderr, /Stopped; nothing installed/);
});
