// Requires the pinned .ci-source checkouts. Runs in a separate disposable mirror.
import test from 'node:test';import assert from 'node:assert/strict';
import {mkdtempSync,mkdirSync,cpSync,readFileSync,writeFileSync,rmSync,existsSync} from 'node:fs';
import {join,resolve,dirname} from 'node:path';import {tmpdir} from 'node:os';import {spawnSync} from 'node:child_process';
test('bundle check rejects lock and mirror drift without repairing either',t=>{
 const original=resolve('.');const fixture=mkdtempSync(join(tmpdir(),'hearth-generator-'));t.after(()=>rmSync(fixture,{recursive:true,force:true}));
 mkdirSync(join(fixture,'scripts'));cpSync('scripts/sync-bundles.mjs',join(fixture,'scripts/sync-bundles.mjs'));cpSync('skills',join(fixture,'skills'),{recursive:true});cpSync('vendor-lock.json',join(fixture,'vendor-lock.json'));mkdirSync(join(fixture,'.ci-source'));
 const lock=JSON.parse(readFileSync('vendor-lock.json','utf8'));
 for(const name of ['eidolon','setup']){const source=join(original,'.ci-source',name);assert.ok(existsSync(source),'Pinned source fixture is required');const result=spawnSync('git',['clone','--quiet','--no-hardlinks',source,join(fixture,'.ci-source',name)],{encoding:'utf8',timeout:30000});assert.equal(result.status,0,result.stderr);}
 const check=()=>spawnSync(process.execPath,['scripts/sync-bundles.mjs','--check'],{cwd:fixture,encoding:'utf8',timeout:120000});
 let result=check();assert.equal(result.status,0,result.stderr);
 const lockFile=join(fixture,'vendor-lock.json'),originalLock=readFileSync(lockFile);const altered=structuredClone(lock);altered.files[Object.keys(altered.files)[0]]='0'.repeat(64);writeFileSync(lockFile,JSON.stringify(altered));
 result=check();assert.notEqual(result.status,0);assert.match(result.stderr,/Vendor lock differs/);assert.deepEqual(JSON.parse(readFileSync(lockFile,'utf8')),altered);writeFileSync(lockFile,originalLock);
 const target=join(fixture,'skills/eidolon/SKILL.md');writeFileSync(target,'changed fixture, never the live bundle\n');result=check();assert.notEqual(result.status,0);assert.match(result.stderr,/Bundled file differs/);assert.equal(readFileSync(target,'utf8'),'changed fixture, never the live bundle\n');
});
