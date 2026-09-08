import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync, mkdtempSync, mkdirSync, readFileSync, readdirSync, realpathSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { installHearth } from '../scripts/install.mjs';
const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
function tmp(t) { const p=realpathSync(mkdtempSync(join(tmpdir(),'hearth-test-')));t.after(()=>rmSync(p,{recursive:true,force:true}));return p; }
test('preview changes nothing', t=>{const home=tmp(t); assert.equal(installHearth({home}).dryRun,true);assert.deepEqual(readdirSync(home),[])});
for(const host of ['codex','claude','both']) test('complete bundle for '+host,t=>{
  const project=tmp(t),result=installHearth({project,host,dryRun:false});assert.ok(result.ok);assert.ok(result.copied>100);
  for(const dir of host==='both'?['.agents','.claude']:[host==='codex'?'.agents':'.claude']){
    for(const name of ['eidolon','setup'])assert.ok(existsSync(join(project,dir,'skills',name,'SKILL.md')));
  }
});
test('shipped Eidolon contains current platform and intelligent skill routing',()=>{
  const base=join(root,'skills/eidolon');
  for(const path of ['references/current-platform-contract.md','references/skill-selection.md','scripts/skill-router.mjs','scripts/skill-router.test.mjs','docs/spec/2026-09-08-cross-host-user-story.md']) assert.ok(existsSync(join(base,path)),path);
  assert.match(readFileSync(join(base,'references/skill-selection.md'),'utf8'),/smallest non-conflicting set/i);
  assert.match(readFileSync(join(base,'references/current-platform-contract.md'),'utf8'),/Do not hardcode a Claude point release/);
});
test('shipped Setup carries evidence-based skill selection and gap behavior',()=>{
  for(const path of ['skills/setup/SKILL.md','skills/setup/codex/SKILL.md']){
    const s=readFileSync(join(root,path),'utf8');
    assert.match(s,/smallest sufficient non-conflicting set/);
    assert.match(s,/record a gap/);
    assert.match(s,/Never pin behavior to a remembered/);
  }
});
test('partial failure is never a success',t=>{const project=tmp(t);mkdirSync(join(project,'.agents/skills/setup'),{recursive:true});writeFileSync(join(project,'.agents/skills/setup/SKILL.md'),'existing');assert.throws(()=>installHearth({project,dryRun:false}),/replace/);assert.ok(!existsSync(join(project,'.agents/skills/eidolon')))});
test('explicit replace keeps the old installation',t=>{const home=tmp(t);installHearth({home,dryRun:false});const p=join(home,'.agents/skills/setup/SKILL.md');writeFileSync(p,'local edit');const result=installHearth({home,dryRun:false,replace:true});const receipt=JSON.parse(readFileSync(join(result.backups,'receipt.json')));const item=receipt.changes.find(x=>x.path.endsWith('setup'));assert.equal(readFileSync(join(item.backup,'SKILL.md'),'utf8'),'local edit')});
test('CLI reports completion only after both skills land',t=>{const home=tmp(t);const result=spawnSync(process.execPath,[join(root,'scripts/install.mjs'),'--home',home,'--host','codex','--yes'],{encoding:'utf8'});assert.equal(result.status,0,result.stderr);assert.equal(JSON.parse(result.stdout).ok,true);assert.ok(existsSync(join(home,'.agents/skills/setup/SKILL.md')))});
test('legacy copy cores delegate instead of text-decoding every file',()=>{assert.match(readFileSync(join(root,'gui/HearthCore.ps1'),'utf8'),/scripts\/install.mjs/);assert.doesNotMatch(readFileSync(join(root,'gui/HearthCore.ps1'),'utf8'),/ReadAllText/);assert.match(readFileSync(join(root,'macos/hearth-core.sh'),'utf8'),/scripts\/install.mjs/)});
