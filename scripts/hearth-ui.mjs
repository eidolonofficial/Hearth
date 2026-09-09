// Local-only installer service. Previews are single-use and bound to source/target fingerprints.
import {createServer} from 'node:http';
import {readFileSync,statSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import {extname,resolve} from 'node:path';
import {randomBytes,timingSafeEqual} from 'node:crypto';
import {spawn} from 'node:child_process';
import {prepareHearth,applyHearth} from './install.mjs';
import {projectPath} from '../skills/eidolon/scripts/safe-paths.mjs';
const ROOT=fileURLToPath(new URL('../',import.meta.url));
const MAX_BODY=24000;
const MIME={'.html':'text/html; charset=utf-8','.js':'text/javascript; charset=utf-8','.css':'text/css; charset=utf-8','.svg':'image/svg+xml','.png':'image/png','.jpg':'image/jpeg','.jpeg':'image/jpeg','.webp':'image/webp'};
function headers(res){res.setHeader('cache-control','no-store');res.setHeader('x-content-type-options','nosniff');res.setHeader('referrer-policy','no-referrer');res.setHeader('content-security-policy',"default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; connect-src 'self'; frame-ancestors 'none'; base-uri 'none'; form-action 'self'");res.setHeader('x-frame-options','DENY');}
function json(res,status,value){const body=JSON.stringify(value);res.writeHead(status,{'content-type':'application/json; charset=utf-8','content-length':Buffer.byteLength(body)});res.end(body);}
async function readBody(req){let bytes=0;const parts=[];for await(const chunk of req){bytes+=chunk.length;if(bytes>MAX_BODY)throw Error('Request too large');parts.push(chunk);}const value=JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(Buffer.concat(parts))||'{}');if(!value||Array.isArray(value)||typeof value!=='object')throw Error('Invalid request');return value;}
function options(value){if(!['codex','claude','both'].includes(value.host)||value.project!=null&&typeof value.project!=='string')throw Error('Choose a host and target');return {host:value.host,project:value.project?.trim()||undefined,replace:value.replace===true};}
function authentic(req,token){const input=String(req.headers['x-hearth-token']||'');return /^[a-f0-9]{48}$/.test(input)&&timingSafeEqual(Buffer.from(input),Buffer.from(token));}
export function createHearthServer(){
  const token=randomBytes(24).toString('hex'), previews=new Map();
  const server=createServer(async(req,res)=>{
    headers(res);
    try {
      const origin='http://127.0.0.1:'+req.socket.localPort;
      if(req.headers.host!=='127.0.0.1:'+req.socket.localPort||req.headers.origin&&req.headers.origin!==origin||req.headers['sec-fetch-site']==='cross-site'||!['127.0.0.1','::ffff:127.0.0.1'].includes(req.socket.remoteAddress))return json(res,403,{error:'Only this local installer window may make requests'});
      const url=new URL(req.url,origin);
      if(url.origin!==origin)return json(res,403,{error:'Unexpected request authority'});
      if(req.method==='GET'&&url.pathname==='/api/session')return json(res,200,{token});
      if(req.method==='POST'&&['/api/preview','/api/install'].includes(url.pathname)){
        if(req.headers.origin!==origin)return json(res,403,{error:'A same-origin installer request is required'});
        if(!authentic(req,token))return json(res,403,{error:'Installer session expired'});
        const body=await readBody(req);
        if(url.pathname==='/api/preview'){
          for(const [id,item]of previews)if(item.expires<Date.now())previews.delete(id);
          if(previews.size>=16)throw Error('Too many open previews; restart Hearth');
          const opts=options(body),plan=prepareHearth(opts),summary=applyHearth(plan,{...opts,dryRun:true});
          const previewId=randomBytes(24).toString('hex');previews.set(previewId,{plan,options:opts,expires:Date.now()+300000});
          return json(res,200,{...summary,previewId});
        }
        if(body.confirm!==true)return json(res,400,{error:'Explicit install confirmation is required'});
        if(Object.keys(body).some(key=>!['confirm','previewId'].includes(key)))return json(res,409,{error:'Install accepts only the reviewed plan ID. Review changes again.'});
        const reviewed=previews.get(body.previewId);
        if(!reviewed||reviewed.expires<Date.now())return json(res,409,{error:'Review this exact installation plan again'});
        previews.delete(body.previewId);
        return json(res,200,applyHearth(reviewed.plan,{...reviewed.options,dryRun:false}));
      }
      if(req.method!=='GET')return json(res,405,{error:'Method not allowed'});
      const asset=url.pathname.startsWith('/assets/');
      const base=resolve(ROOT,asset?'assets':'installer');
      const name=url.pathname==='/'?'index.html':decodeURIComponent(url.pathname.slice(asset?8:1));
      const file=projectPath(base,name),info=statSync(file);
      if(!info.isFile()||info.size>8*1024*1024)return json(res,404,{error:'Not found'});
      const data=readFileSync(file);res.writeHead(200,{'content-type':MIME[extname(file).toLowerCase()]||'application/octet-stream','content-length':data.length});res.end(data);
    }catch(error){if(!res.headersSent)json(res,error?.code==='ENOENT'?404:/changed|preview|plan/i.test(error?.message||'')?409:400,{error:error?.code==='ENOENT'?'Not found':error.message||'Installation could not finish'});else res.end();}
  });
  server.requestTimeout=15000;server.headersTimeout=10000;server.keepAliveTimeout=1000;return server;
}
export function startHearth(){
 const server=createHearthServer();
 server.listen(0,'127.0.0.1',()=>{
  const url='http://127.0.0.1:'+server.address().port+'/';console.log('Hearth is ready at '+url);
  if(process.env.HEARTH_NO_OPEN==='1')return;
  const [cmd,args]=process.platform==='win32'?['cmd',['/c','start','',url]]:process.platform==='darwin'?['open',[url]]:['xdg-open',[url]];
  const child=spawn(cmd,args,{detached:true,stdio:'ignore'});child.on('error',()=>console.log('Open the local address above.'));child.on('exit',code=>{if(code)console.log('Browser did not open. Use the local address above.');});child.unref();
 });
 process.on('SIGINT',()=>server.close());process.on('SIGTERM',()=>server.close());
 return server;
}
if(process.argv[1]&&resolve(process.argv[1])===fileURLToPath(import.meta.url))startHearth();
