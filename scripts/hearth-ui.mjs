import { createServer } from 'node:http';
import { readFile, stat } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { extname, join, normalize, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { randomBytes } from 'node:crypto';
import { spawn } from 'node:child_process';
import { installHearth } from './install.mjs';

const ROOT = resolve(fileURLToPath(new URL('..', import.meta.url)));
const INSTALLER = join(ROOT, 'installer');
const ASSETS = join(ROOT, 'assets');
const token = randomBytes(24).toString('hex');

const types = {
  '.html': 'text/html; charset=utf-8', '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8', '.svg': 'image/svg+xml', '.png': 'image/png',
  '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.webp': 'image/webp', '.json': 'application/json; charset=utf-8'
};

function json(res, status, value) {
  const body = JSON.stringify(value);
  res.writeHead(status, {'content-type':'application/json; charset=utf-8','cache-control':'no-store','content-length':Buffer.byteLength(body)});
  res.end(body);
}
function safeBody(req, limit = 24_000) {
  return new Promise((resolveBody, reject) => {
    let size = 0, text = '';
    req.setEncoding('utf8');
    req.on('data', chunk => {
      size += Buffer.byteLength(chunk);
      if (size > limit) { reject(Error('Request too large')); req.destroy(); return; }
      text += chunk;
    });
    req.on('end', () => {
      try { resolveBody(text ? JSON.parse(text) : {}); } catch { reject(Error('Invalid JSON')); }
    });
    req.on('error', reject);
  });
}
function options(body, dryRun) {
  if (!body || !['claude','codex','both'].includes(body.host)) throw Error('Choose Claude Code, Codex, or both');
  if (body.project != null && typeof body.project !== 'string') throw Error('Project path must be text');
  return { host: body.host, project: body.project?.trim() || undefined, replace: body.replace === true, dryRun };
}
function authorized(req) { return req.headers['x-hearth-token'] === token; }
function local(req) {
  const addr = req.socket.remoteAddress || '';
  return addr === '127.0.0.1' || addr === '::1' || addr === '::ffff:127.0.0.1';
}
async function staticFile(req, res) {
  let path = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
  let base = INSTALLER;
  if (path.startsWith('/assets/')) { base = ASSETS; path = path.slice('/assets'.length); }
  if (path === '/') path = '/index.html';
  const target = resolve(base, '.' + normalize(path));
  if (!(target === base || target.startsWith(base + '/')) || !existsSync(target)) return false;
  const info = await stat(target);
  if (!info.isFile()) return false;
  const bytes = await readFile(target);
  res.writeHead(200, {'content-type':types[extname(target).toLowerCase()] || 'application/octet-stream','cache-control':'no-store','content-length':bytes.length});
  res.end(bytes); return true;
}

const server = createServer(async (req, res) => {
  try {
    if (!local(req)) return json(res, 403, {error:'Hearth only accepts local connections'});
    const url = new URL(req.url, 'http://localhost');
    if (req.method === 'GET' && url.pathname === '/api/session') return json(res, 200, {token});
    if (req.method === 'POST' && ['/api/preview','/api/install'].includes(url.pathname)) {
      if (!authorized(req)) return json(res, 403, {error:'Installer session expired'});
      const body = await safeBody(req);
      if (url.pathname === '/api/preview') return json(res, 200, installHearth(options(body, true)));
      if (body.confirm !== true) return json(res, 400, {error:'Explicit install confirmation is required'});
      return json(res, 200, installHearth(options(body, false)));
    }
    if (req.method === 'GET' && await staticFile(req, res)) return;
    json(res, 404, {error:'Not found'});
  } catch (error) {
    json(res, 400, {error:error?.message || 'Hearth could not complete that request'});
  }
});

server.listen(0, '127.0.0.1', () => {
  const {port} = server.address();
  const url = `http://127.0.0.1:${port}/`;
  console.log(`Hearth is ready at ${url}`);
  if (process.env.HEARTH_NO_OPEN === '1') return;
  const open = process.platform === 'win32' ? ['cmd',['/c','start','',url]] : process.platform === 'darwin' ? ['open',[url]] : ['xdg-open',[url]];
  try { spawn(open[0], open[1], {detached:true, stdio:'ignore'}).unref(); }
  catch { console.log('Open the address above in your browser.'); }
});

process.on('SIGINT', () => server.close(() => process.exit(0)));
process.on('SIGTERM', () => server.close(() => process.exit(0)));
