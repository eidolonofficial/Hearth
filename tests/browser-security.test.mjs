import test from 'node:test';import assert from 'node:assert/strict';
import {mkdtempSync,writeFileSync,readFileSync,rmSync,existsSync} from 'node:fs';import {join,resolve} from 'node:path';import {tmpdir} from 'node:os';
import http from 'node:http';import {spawn} from 'node:child_process';
import {createHearthServer} from '../scripts/hearth-ui.mjs';
function request(base,path,method='GET',headers={},body){return new Promise((done,reject)=>{const req=http.request(new URL(path,base),{method,headers},res=>{let text='';res.on('data',c=>text+=c);res.on('end',()=>done({status:res.statusCode,headers:res.headers,text,json:()=>JSON.parse(text)}));});req.on('error',reject);req.end(body?JSON.stringify(body):undefined);});}
async function fixture(t){const server=createHearthServer();await new Promise(r=>server.listen(0,'127.0.0.1',r));t.after(()=>server.close());const base='http://127.0.0.1:'+server.address().port,root=mkdtempSync(join(tmpdir(),'hearth-protocol-'));t.after(()=>rmSync(root,{recursive:true,force:true}));const token=(await request(base,'/api/session')).json().token;return {base,root,headers:{origin:base,'x-hearth-token':token,'content-type':'application/json'}};}
test('R14 unexpected authority or origin receives no session token',async t=>{
 const {base,root,headers}=await fixture(t);
 for(const changed of [{Host:'untrusted.example'},{Origin:'https://untrusted.example'},{'sec-fetch-site':'cross-site'}]){const r=await request(base,'/api/session','GET',changed);assert.equal(r.status,403);assert.equal(r.json().token,undefined);}
 assert.equal((await request(base,'/api/preview','POST',{'x-hearth-token':headers['x-hearth-token']},{host:'both',project:root})).status,403);
 assert.equal((await request(base,'/api/preview','POST',{...headers,'x-hearth-token':'bad'},{host:'both',project:root})).status,403);
 assert.equal(existsSync(join(root,'.claude')),false);
});
test('R11 server-held approval rejects drift, retargeting and replay',async t=>{
 const {base,root,headers}=await fixture(t);const preview=await request(base,'/api/preview','POST',headers,{host:'codex',project:root});assert.equal(preview.status,200,preview.text);const plan=preview.json();assert.ok(plan.previewId);
 assert.equal((await request(base,'/api/install','POST',headers,{confirm:true,previewId:'not-a-plan'})).status,409);
 assert.equal((await request(base,'/api/install','POST',headers,{confirm:true,previewId:plan.previewId,project:root+'-other'})).status,409);
 writeFileSync(join(root,'AGENTS.md'),'Human update after preview\n');
 const stale=await request(base,'/api/install','POST',headers,{confirm:true,previewId:plan.previewId});assert.equal(stale.status,409,stale.text);assert.match(readFileSync(join(root,'AGENTS.md'),'utf8'),/Human update/);
 assert.equal((await request(base,'/api/install','POST',headers,{confirm:true,previewId:plan.previewId})).status,409);
});
test('R13 default server serves HTML, script, stylesheet and art with confined paths',async t=>{
 const {base}=await fixture(t);const page=await request(base,'/');assert.equal(page.status,200);assert.match(page.headers['content-type'],/text\/html/);assert.match(page.headers['content-security-policy'],/frame-ancestors 'none'/);assert.equal(page.headers['x-frame-options'],'DENY');
 for(const [url,mime]of [['/app.js','text/javascript'],['/styles.css','text/css'],['/assets/EidolonLogo.png','image/png']]){const r=await request(base,url);assert.equal(r.status,200,url);assert.ok(r.headers['content-type'].startsWith(mime));}
 for(const path of ['/assets/%2e%2e%5cREADME.md','/%2e%2e%5cREADME.md','/assets/%00'])assert.ok((await request(base,path)).status>=400,path);
});
test('R15 missing Linux browser opener leaves the local URL available',async t=>{
 if(process.platform!=='linux'){t.skip('Linux-only opener fixture');return;}
 const child=spawn(process.execPath,[resolve('scripts/hearth-ui.mjs')],{cwd:resolve('.'),env:{...process.env,PATH:'/nonexistent-hearth-programs',HEARTH_NO_OPEN:''},stdio:['ignore','pipe','pipe']});t.after(()=>child.kill('SIGTERM'));
 const base=await new Promise((done,reject)=>{let text='';const timer=setTimeout(()=>reject(Error('No installer URL')),10000);child.stdout.on('data',b=>{text+=b;const m=text.match(/http:\/\/127\.0\.0\.1:\d+\//);if(m){clearTimeout(timer);done(m[0]);}});child.once('error',reject);child.once('exit',code=>{clearTimeout(timer);reject(Error('Installer exited '+code));});});
 await new Promise(r=>setTimeout(r,150));assert.equal(child.exitCode,null);assert.equal((await request(base,'/')).status,200);
});
