// Acceptance cases for the committed candidate. All writes are disposable fixtures.
import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync,mkdirSync,writeFileSync,readFileSync,readdirSync,rmSync,existsSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join,resolve} from 'node:path';
import {spawnSync,spawn} from 'node:child_process';
import http from 'node:http';
import {createHearthServer} from '../scripts/hearth-ui.mjs';
import {prepareHearth,applyHearth} from '../scripts/install.mjs';
function temporary(t){const root=mkdtempSync(join(tmpdir(),'hearth-acceptance-'));t.after(()=>rmSync(root,{recursive:true,force:true}));return root;}
async function service(t){const server=createHearthServer();await new Promise(r=>server.listen(0,'127.0.0.1',r));t.after(()=>new Promise(r=>server.close(r)));const base='http://127.0.0.1:'+server.address().port;const {token}=await(await fetch(base+'/api/session')).json();return {base,headers:{origin:base,'x-hearth-token':token,'content-type':'application/json'}};}
async function post(s,path,body){return fetch(s.base+path,{method:'POST',headers:s.headers,body:JSON.stringify(body)});}
test('changed host or target cannot be smuggled into confirmation',async t=>{
 const s=await service(t),project=temporary(t),other=temporary(t);
 const preview=await post(s,'/api/preview',{host:'codex',project});assert.equal(preview.status,200);const {previewId}=await preview.json();
 for(const change of [{project:other},{host:'claude'},{replace:true}])assert.equal((await post(s,'/api/install',{confirm:true,previewId,...change})).status,409);
 assert.deepEqual(readdirSync(project),[]);assert.deepEqual(readdirSync(other),[]);
 const valid=await post(s,'/api/install',{confirm:true,previewId});assert.equal(valid.status,200);assert.ok(existsSync(join(project,'.agents/skills/setup/SKILL.md')));assert.deepEqual(readdirSync(other),[]);
});
test('concurrent requests consume one plan only once',async t=>{
 const s=await service(t),project=temporary(t);const {previewId}=await(await post(s,'/api/preview',{host:'claude',project})).json();
 const replies=await Promise.all([post(s,'/api/install',{confirm:true,previewId}),post(s,'/api/install',{confirm:true,previewId})]);
 assert.deepEqual(replies.map(r=>r.status).sort(),[200,409]);
 assert.equal(readdirSync(join(project,'.eidolon/backups')).length,1);
});
test('a UTF-8 project path survives network chunk boundaries',async t=>{
 const s=await service(t),base=temporary(t),project=join(base,'review-caf\u00e9-\u0394');mkdirSync(project);
 const payload=Buffer.from(JSON.stringify({host:'claude',project}));const marker=payload.indexOf(Buffer.from('\u00e9'));assert.ok(marker>=0);
 const result=await new Promise((ok,fail)=>{const request=http.request(s.base+'/api/preview',{method:'POST',headers:s.headers},res=>{let data='';res.on('data',b=>data+=b);res.on('end',()=>ok({status:res.statusCode,body:JSON.parse(data)}));});request.on('error',fail);request.write(payload.subarray(0,marker+1));setTimeout(()=>request.end(payload.subarray(marker+1)),10);});
 assert.equal(result.status,200);assert.ok(result.body.paths.some(p=>p.includes('caf\u00e9-\u0394')));assert.deepEqual(readdirSync(project),[]);
});
test('invalid UTF-8 is refused rather than silently changing the path',async t=>{
 const s=await service(t);const response=await fetch(s.base+'/api/preview',{method:'POST',headers:s.headers,body:Buffer.from([123,34,104,111,115,116,34,58,34,99,108,97,117,100,101,34,44,34,112,114,111,106,101,99,116,34,58,34,255,34,125])});assert.equal(response.status,400);
});
test('preview/apply API preserves a concurrent human instruction edit',t=>{
 const project=temporary(t);writeFileSync(join(project,'AGENTS.md'),'before\n');const plan=prepareHearth({host:'both',project});
 assert.equal(applyHearth(plan).dryRun,true);writeFileSync(join(project,'AGENTS.md'),'human after preview\n');
 assert.throws(()=>applyHearth(plan,{dryRun:false}),/changed/);assert.equal(readFileSync(join(project,'AGENTS.md'),'utf8'),'human after preview\n');assert.equal(existsSync(join(project,'.agents')),false);
});
test('CLI help and preview do not install skills',t=>{
 const home=temporary(t);const executable=resolve('scripts/install.mjs');
 const help=spawnSync(process.execPath,[executable,'--help'],{encoding:'utf8'});assert.equal(help.status,0);assert.match(help.stdout,/--host/);
 const preview=spawnSync(process.execPath,[executable,'--host','both','--home',home],{encoding:'utf8'});assert.equal(preview.status,0,preview.stderr);assert.equal(JSON.parse(preview.stdout).dryRun,true);assert.deepEqual(readdirSync(home),[]);
});
test('terminal cancellation leaves the chosen project untouched',async t=>{
 const project=temporary(t);const child=spawn(process.execPath,[resolve('scripts/welcome.mjs')],{stdio:['pipe','pipe','pipe']});
 let output='',errors='',step=0;
 const done=new Promise((ok,fail)=>{child.on('error',fail);child.stderr.on('data',b=>errors+=b);child.stdout.on('data',b=>{output+=b;const expected=['1 Codex, 2 Claude Code, 3 Both:','Project folder','Type yes to apply exactly this plan:'];const answers=['3\n',project+'\n','no\n'];if(step<3&&output.includes(expected[step]))child.stdin.write(answers[step++]);});child.on('close',code=>ok(code));});
 const timer=setTimeout(()=>child.kill(),15000);t.after(()=>{clearTimeout(timer);if(child.exitCode===null)child.kill();});
 const code=await done;assert.equal(code,1,output+errors);assert.equal(step,3);assert.deepEqual(readdirSync(project),[]);
});
