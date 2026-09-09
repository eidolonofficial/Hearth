import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtempSync, existsSync, readFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { spawn } from 'node:child_process';

function waitForUrl(child) {
  return new Promise((resolveUrl, reject) => {
    let output = '';
    const timer = setTimeout(() => reject(Error('Hearth UI service did not start')), 8000);
    child.stdout.setEncoding('utf8');
    child.stderr.setEncoding('utf8');
    child.stdout.on('data', chunk => {
      output += chunk;
      const match = output.match(/Hearth is ready at (http:\/\/127\.0\.0\.1:\d+\/)/);
      if (match) { clearTimeout(timer); resolveUrl(match[1]); }
    });
    child.stderr.on('data', chunk => { output += chunk; });
    child.once('exit', code => { clearTimeout(timer); reject(Error(`Hearth UI exited early (${code}): ${output}`)); });
  });
}

async function post(base, path, token, body) {
  return fetch(new URL(path, base), {
    method: 'POST',
    headers: {'content-type':'application/json','x-hearth-token':token,'origin':new URL(base).origin},
    body: JSON.stringify(body)
  });
}

test('graphical installer previews before explicit install and uses the real engine', async t => {
  const project = mkdtempSync(join(tmpdir(), 'hearth-ui-'));
  const child = spawn(process.execPath, [resolve('scripts/hearth-ui.mjs')], {
    cwd: resolve('.'), env: {...process.env, HEARTH_NO_OPEN:'1'}, stdio:['ignore','pipe','pipe']
  });
  t.after(() => { child.kill('SIGTERM'); rmSync(project, {recursive:true, force:true}); });

  const base = await waitForUrl(child);
  const sessionResponse = await fetch(new URL('/api/session', base));
  assert.equal(sessionResponse.status, 200);
  const {token} = await sessionResponse.json();
  assert.match(token, /^[a-f0-9]{48}$/);

  const denied = await post(base, '/api/install', token, {host:'both',project});
  assert.equal(denied.status, 400);
  assert.match((await denied.json()).error, /confirmation/i);
  assert.equal(existsSync(join(project,'.agents')), false);
  assert.equal(existsSync(join(project,'.claude')), false);

  const preview = await post(base, '/api/preview', token, {host:'both',project,replace:false});
  assert.equal(preview.status, 200);
  const plan = await preview.json();
  assert.equal(plan.dryRun, true);
  assert.ok(plan.paths.some(path => path.includes('.agents')));
  assert.ok(plan.paths.some(path => path.includes('.claude')));
  assert.equal(existsSync(join(project,'.agents')), false, 'preview must not write Codex files');
  assert.equal(existsSync(join(project,'.claude')), false, 'preview must not write Claude files');

  const install = await post(base, '/api/install', token, {confirm:true,previewId:plan.previewId});
  assert.equal(install.status, 200);
  const result = await install.json();
  assert.equal(result.dryRun, false);
  assert.ok(result.changed > 0);
  assert.ok(existsSync(join(project,'.agents','skills','eidolon','SKILL.md')));
  assert.ok(existsSync(join(project,'.agents','skills','setup','SKILL.md')));
  assert.ok(existsSync(join(project,'.claude','skills','eidolon','SKILL.md')));
  assert.ok(existsSync(join(project,'.claude','skills','setup','SKILL.md')));
  assert.match(readFileSync(join(project,'AGENTS.md'),'utf8'), /Preserve human consent gates/);
});

test('installer UI keeps the visual layer progressive and user intent explicit', () => {
  const html = readFileSync(resolve('installer/index.html'),'utf8');
  const css = readFileSync(resolve('installer/styles.css'),'utf8');
  const js = readFileSync(resolve('installer/app.js'),'utf8');
  assert.match(html, /Review changes/);
  assert.match(html, /Nothing consequential happens without your approval/);
  assert.match(html, /paw-trail/);
  assert.doesNotMatch(html, /Breathe with Eidolon/i);
  assert.match(css, /prefers-reduced-motion/);
  assert.match(css, /paw-step/);
  assert.match(js, /cinematic layer unavailable; using static fallback/);
  assert.match(js, /fireflies/);
});
