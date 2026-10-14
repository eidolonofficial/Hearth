// Every door checks GitHub for a newer Hearth release before it installs, asks before it acts on one,
// and stays silent when the check is off or GitHub does not answer. The API is a local server here, in
// this process, so the doors run asynchronously: a blocking spawn would starve the server. The picker's
// questions are answered as each prompt appears, since readline drops lines that arrive before a question.
import test from 'node:test';
import assert from 'node:assert/strict';
import { createServer } from 'node:http';
import { mkdtempSync, rmSync, readFileSync, writeFileSync, existsSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawn, spawnSync } from 'node:child_process';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const pkg = JSON.parse(readFileSync(join(root, 'package.json'), 'utf8'));
const ps1 = join(root, 'welcome.ps1');
const command = join(root, 'macos', 'Welcome.command');
const picker = join(root, 'scripts', 'welcome.mjs');
const windows = process.platform === 'win32';
const hasBash = !spawnSync('bash', ['--version'], { encoding: 'utf8' }).error;
const CLOSED = 'http://127.0.0.1:9/latest';

function temp(t) { const p = mkdtempSync(join(tmpdir(), 'hearth-update-')); t.after(() => rmSync(p, { recursive: true, force: true })); return p; }
function serve(t, tag = 'v99.0.0') {
  return new Promise(ok => {
    const server = createServer((req, res) => { res.writeHead(200, { 'content-type': 'application/json' }); res.end(JSON.stringify({ tag_name: tag, html_url: 'https://example.invalid/r/' + tag })); });
    server.listen(0, '127.0.0.1', () => ok('http://127.0.0.1:' + server.address().port + '/latest'));
    t.after(() => server.close());
  });
}
function env(api, extra = {}) {
  const e = { ...process.env };
  delete e.EIDOLON_UPDATE_CHECK;
  Object.assign(e, { HEARTH_RELEASE_API: api, EIDOLON_RELEASE_API: api }, extra);
  for (const k of Object.keys(extra)) if (extra[k] === undefined) delete e[k];
  return e;
}
// input: a string written at once (the shell doors read lines when they ask), or a list of
// [prompt regex, reply] pairs, each reply written when its prompt has appeared on stdout.
function run(cmd, cmdArgs, e, input = '') {
  return new Promise(ok => {
    const p = spawn(cmd, cmdArgs, { env: e });
    let stdout = '', stderr = '';
    const script = Array.isArray(input) ? [...input] : null;
    const feed = () => {
      while (script.length && script[0][0].test(stdout)) p.stdin.write(script.shift()[1]);
      if (!script.length) p.stdin.end();
    };
    p.stdout.on('data', d => { stdout += d; if (script) feed(); });
    p.stderr.on('data', d => { stderr += d; });
    const timer = setTimeout(() => p.kill(), 110000);
    p.on('close', status => { clearTimeout(timer); ok({ status, stdout, stderr }); });
    p.stdin.on('error', () => {});
    if (script) feed(); else p.stdin.end(input);
  });
}
const runPs = (e, input, ...args) => run('powershell', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', ps1, ...args], e, input);
const runSh = (e, input, ...args) => run('bash', [command, ...args], e, input);
const runNode = (e, input, ...args) => run(process.execPath, [picker, ...args], e, input);
const cacheIn = dir => ({ EIDOLON_UPDATE_CACHE: join(dir, 'update-cache.json') });

test('welcome.ps1 names the newer release, keeps the install on Enter, opens nothing on -Yes', { skip: !windows && 'runs on Windows' }, async t => {
  const api = await serve(t);
  const home = temp(t);
  let r = await runPs(env(api), '\n', '-Home', home);
  assert.equal(r.status, 0, r.stdout + r.stderr);
  assert.match(r.stdout, /Hearth v99\.0\.0 is available\. This copy is v\d+\.\d+\.\d+\./);
  assert.match(r.stdout, /Installed now: eidolon, setup/);
  r = await runPs(env(api), '', '-Yes', '-Home', temp(t));
  assert.equal(r.status, 0, r.stdout + r.stderr);
  assert.match(r.stdout, /Hearth v99\.0\.0 is available/);
  assert.match(r.stdout, /https:\/\/example\.invalid\/r\/v99\.0\.0/);
});
test('welcome.ps1 says nothing when the check is off, GitHub does not answer, or the release is older', { skip: !windows && 'runs on Windows' }, async t => {
  const api = await serve(t);
  let r = await runPs(env(api, { EIDOLON_UPDATE_CHECK: '0' }), '', '-Yes', '-Home', temp(t));
  assert.equal(r.status, 0, r.stdout + r.stderr);
  assert.doesNotMatch(r.stdout, /is available/);
  const started = Date.now();
  r = await runPs(env(CLOSED), '', '-Yes', '-Home', temp(t));
  assert.equal(r.status, 0, r.stdout + r.stderr);
  assert.doesNotMatch(r.stdout + r.stderr, /is available|Exception|error/i);
  assert.ok(Date.now() - started < 60000);
  r = await runPs(env(await serve(t, 'v0.0.1')), '', '-Yes', '-Home', temp(t));
  assert.doesNotMatch(r.stdout, /is available/, 'an older release is not an update');
});
test('Welcome.command names the newer release and stays quiet when off or unanswered', { skip: !hasBash && 'bash is not available' }, async t => {
  const api = await serve(t);
  let r = await runSh(env(api), '\n', '--home', temp(t));
  assert.equal(r.status, 0, r.stdout + r.stderr);
  assert.match(r.stdout, /Hearth v99\.0\.0 is available\. This copy is v\d+\.\d+\.\d+\./);
  assert.match(r.stdout, /Installed now: eidolon setup/);
  r = await runSh(env(api, { EIDOLON_UPDATE_CHECK: '0' }), '', '--yes', '--home', temp(t));
  assert.doesNotMatch(r.stdout, /is available/);
  r = await runSh(env(CLOSED), '', '--yes', '--home', temp(t));
  assert.equal(r.status, 0, r.stdout + r.stderr);
  assert.doesNotMatch(r.stdout + r.stderr, /is available|curl:/);
  r = await runSh(env(await serve(t, 'v0.0.1')), '', '--yes', '--home', temp(t));
  assert.doesNotMatch(r.stdout, /is available/, 'an older release is not an update');
});
test('welcome.mjs prints its version, installs user skills with --yes --home, and names the newer release', async t => {
  let r = await runNode(env(CLOSED), '', '--version');
  assert.equal(r.stdout.trim(), pkg.version);
  const api = await serve(t);
  const home = temp(t);
  r = await runNode(env(api, cacheIn(home)), '', '--yes', '--home', home);
  assert.equal(r.status, 0, r.stdout + r.stderr);
  assert.match(r.stdout, /Hearth v99\.0\.0 is available\. This copy is v\d+\.\d+\.\d+\./);
  assert.ok(existsSync(join(home, '.claude', 'skills', 'eidolon', 'SKILL.md')));
  assert.ok(existsSync(join(home, '.claude', 'skills', 'setup', 'SKILL.md')));
  // Enter at the update question continues with this copy; Enter at replace stops; a second --yes run replaces with a backup.
  writeFileSync(join(home, '.claude', 'skills', 'setup', 'SKILL.md'), 'mine');
  r = await runNode(env(api, cacheIn(home)), [[/Update now\?/, '\n'], [/Project folder/, '\n'], [/Type replace/, '\n']], '--home', home);
  assert.match(r.stdout, /Update now\?/);
  assert.match(r.stdout + r.stderr, /Stopped; nothing installed/);
  assert.equal(readFileSync(join(home, '.claude', 'skills', 'setup', 'SKILL.md'), 'utf8'), 'mine');
  r = await runNode(env(api, cacheIn(home)), '', '--yes', '--home', home);
  assert.equal(r.status, 0, r.stdout + r.stderr);
  assert.notEqual(readFileSync(join(home, '.claude', 'skills', 'setup', 'SKILL.md'), 'utf8'), 'mine');
  assert.match(r.stdout, /Backup receipt: .*receipt\.json/);
});
test('welcome.mjs yes to the update runs the update command and installs nothing itself', async t => {
  const api = await serve(t);
  const home = temp(t), log = join(home, 'ran.txt');
  const fake = join(home, 'fake-update.mjs');
  writeFileSync(fake, "import{writeFileSync}from'node:fs';writeFileSync(process.argv[2],process.argv.slice(3).join(' '));");
  const yes = [[/Update now\?/, 'yes\n']];
  let r = await runNode(env(api, { ...cacheIn(home), HEARTH_UPDATE_COMMAND: JSON.stringify([process.execPath, fake, log]) }), yes, '--home', home);
  assert.equal(r.status, 0, r.stdout + r.stderr);
  assert.equal(readFileSync(log, 'utf8'), '--home ' + home);
  assert.ok(!existsSync(join(home, '.claude', 'skills', 'eidolon')), 'the old copy installed nothing');
  // A failing update command leaves a clear message with the release page and a nonzero exit.
  r = await runNode(env(api, { ...cacheIn(home), HEARTH_UPDATE_COMMAND: JSON.stringify([process.execPath, '-e', 'process.exit(3)']) }), yes, '--home', home);
  assert.notEqual(r.status, 0);
  assert.match(r.stdout + r.stderr, /did not start|did not finish/);
  assert.match(r.stdout + r.stderr, /https:\/\/example\.invalid\/r\/v99\.0\.0/);
  assert.ok(!existsSync(join(home, '.claude', 'skills', 'eidolon')));
});
test('the check is off: no network, no question', async t => {
  const home = temp(t);
  const r = await runNode(env(CLOSED, { ...cacheIn(home), EIDOLON_UPDATE_CHECK: '0' }), '', '--yes', '--home', home);
  assert.equal(r.status, 0, r.stdout + r.stderr);
  assert.doesNotMatch(r.stdout, /is available|Update now/);
});
