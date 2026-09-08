import http from 'node:http';
import { readFileSync, existsSync, statSync } from 'node:fs';
import { dirname, extname, join, normalize, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { randomBytes, timingSafeEqual } from 'node:crypto';
import { spawn } from 'node:child_process';
import { installHearth } from './install.mjs';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const INSTALLER = join(ROOT, 'installer');
const ASSETS = join(ROOT, 'assets');
const HOST = '127.0.0.1';
const token = randomBytes(32).toString('hex');
const MAX_BODY = 32 * 1024;
const MIME = new Map([
  ['.html','text/html; charset=utf-8'],['.css','text/css; charset=utf-8'],['.js','text/javascript; charset=utf-8'],
  ['.svg','image/svg+xml'],['.png','image/png'],['.jpg','image/jpeg'],['.jpeg','image/jpeg'],['.ico','image/x-icon']
]);

function json(res, status, value) {
  const body = JSON.stringify(value);
  res.writeHead(status, {'content-type':'application/json; charset=utf-8','content-length':Buffer.byteLength(body),'cache-control':'no-store','x-content-type-options':'nosniff'});
  res.end(body);
}
function trusted(req) {
  const provided = String(req.headers['x-hearth-token'] || '');
  if (provided.length !== token.length) return false;
  return timingSafeEqual(Buffer.from(provided), Buffer.from(token));
}
async function body(req) {
  let size = 0, text = '';
  for await (const chunk of req) {
    size += chunk.length;
    if (size > MAX_BODY) throw Error('Request is too large');
    text += chunk;
  }
  const value = text ? JSON.parse(text) : {};
  if (!value || Array.isArray(value) || typeof value !== 'object') throw Error('Invalid request');
  return value;
}
function optionsFrom(value, dryRun) {
  const host = String(value.host || 'claude');
  if (!['claude','codex','both'].includes(host)) throw Error('Choose Claude Code, Codex, or both');
  const project = String(value.project || '').trim();
  if (project.includes('\0')) throw Error('Invalid project path');
  return {host, ...(project ? {project} : {}), replace:value.replace === true, dryRun};
}
function confined(base, requestPath) {
  const clean = normalize(requestPath).replace(/^([/\\])+/, '');
  const target = resolve(base, clean);
  if (target !== base && !target.startsWith(base + sep)) return null;
  return target;
}
function serveFile(res, base, requestPath) {
  const file = confined(base, requestPath);
  if (!file || !existsSync(file) || !statSync(file).isFile()) return false;
  const bytes = readFileSync(file);
  res.writeHead(200, {'content-type':MIME.get(extname(file).toLowerCase()) || 'application/octet-stream','content-length':bytes.length,'cache-control':'no-store','x-content-type-options':'nosniff'});
  res.end(bytes); return true;
}
function openBrowser(url) {
  const platform = process.platform;
  const command = platform === 'win32' ? 'cmd' : platform === 'darwin' ? 'open' : 'xdg-open';
  const args = platform === 'win32' ? ['/c','start','',url] : [url];
  const child = spawn(command, args, {detached:true, stdio:'ignore'});
  child.unref();
}

export function createHearthServer() {
  return http.createServer(async (req,res) => {
    try {
      const url = new URL(req.url || '/', `http://${HOST}`);
      if (req.socket.remoteAddress && !['127.0.0.1','::1','::ffff:127.0.0.1'].includes(req.socket.remoteAddress)) return json(res,403,{error:'Loopback access only'});
      if (req.method === 'GET' && url.pathname === '/api/session') return json(res,200,{token});
      if (req.method === 'POST' && (url.pathname === '/api/preview' || url.pathname === '/api/install')) {
        if (!trusted(req)) return json(res,403,{error:'Installer session expired. Restart Hearth.'});
        const value = await body(req);
        if (url.pathname === '/api/install' && value.confirm !== true) return json(res,400,{error:'Explicit install confirmation is required'});
        const result = installHearth(optionsFrom(value, url.pathname === '/api/preview'));
        return json(res,200,result);
      }
      if (req.method !== 'GET') return json(res,405,{error:'Method not allowed'});
      if (url.pathname.startsWith('/assets/')) {
        if (serveFile(res, ASSETS, decodeURIComponent(url.pathname.slice('/assets/'.length)))) return;
        return json(res,404,{error:'Asset not found'});
      }
      const page = url.pathname === '/' ? 'index.html' : decodeURIComponent(url.pathname.slice(1));
      if (serveFile(res, INSTALLER, page)) return;
      return json(res,404,{error:'Not found'});
    } catch (error) {
      return json(res,400,{error:error?.message || 'Hearth could not complete the request'});
    }
  });
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  const server = createHearthServer();
  server.listen(0, HOST, () => {
    const address = server.address();
    const url = `http://${HOST}:${address.port}/`;
    console.log(`Hearth is open at ${url}`);
    console.log('Keep this window open while the installer is running. Press Ctrl+C to stop Hearth.');
    try { openBrowser(url); } catch { console.log('Open the address above in your browser.'); }
  });
}
