// Maintainer-only bundle regeneration from exact Git commits. Never used by installers.
import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, readFileSync, realpathSync, rmSync, writeFileSync, readdirSync, lstatSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createHash } from 'node:crypto';
import {isDeepStrictEqual} from 'node:util';
const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const pins = { eidolon: 'd663e571636801a1df17f7f1e1262d3641723454', setup: '5fa96f532bb65bc60484b86038a27157d4afd3fb' };
const skip = /^(?:\.git|\.github|\.claude|\.codex|\.agents|\.eidolon)(?:\/|$)/;
const lock = { sources: pins, excluded: skip.source, files: {} };
function countFiles(dir) {
  return readdirSync(dir).reduce((sum, name) => { const path = join(dir, name), stat = lstatSync(path); if (stat.isSymbolicLink()) throw Error('Unexpected bundled symlink'); return sum + (stat.isDirectory() ? countFiles(path) : 1); }, 0);
}
for (const name of ['eidolon', 'setup']) {
  const source = realpathSync(resolve(root, '.ci-source', name));
  const git = args => execFileSync('git', ['-C', source, ...args], { encoding: 'utf8' }).trim();
  if (git(['rev-parse', 'HEAD']) !== pins[name]) throw Error('Source commit does not match reviewed pin');
  const names = execFileSync('git', ['-C', source, 'ls-tree', '-rz', '--name-only', pins[name]], { encoding: 'utf8' }).split('\0').filter(n => n && !skip.test(n));
  const files = names.map(n => {
    if (n.startsWith('/') || n.split('/').includes('..')) throw Error('Unsafe source path');
    const bytes = execFileSync('git', ['-C', source, 'show', pins[name] + ':' + n], { maxBuffer: 32 * 1024 * 1024 });
    const mode = git(['ls-tree', pins[name], '--', n]).split(' ')[0];
    if (!['100644', '100755'].includes(mode)) throw Error('Only regular source files may be bundled');
    lock.files[name + '/' + n] = createHash('sha256').update(bytes).digest('hex');
    return { name: n, bytes, mode: mode === '100755' ? 0o755 : 0o644 };
  });
  const dest = join(root, 'skills', name);
  if (process.argv.includes('--check')) {
    if (countFiles(dest) !== files.length) throw Error('Unexpected bundled file count');
    for (const file of files) {
      if (!existsSync(join(dest, file.name)) || !readFileSync(join(dest, file.name)).equals(file.bytes)) throw Error('Bundled file differs from its pin: ' + name + '/' + file.name);
      if (process.platform !== 'win32' && (lstatSync(join(dest,file.name)).mode & 0o111) !== (file.mode & 0o111)) throw Error('Bundled executable mode differs: '+name+'/'+file.name);
    }
  } else {
    // Tracked source regeneration on a review branch; Git retains the prior bundle.
    rmSync(dest, { recursive: true, force: true });
    for (const file of files) { const path = join(dest, file.name); mkdirSync(dirname(path), { recursive: true }); writeFileSync(path, file.bytes, { mode: file.mode }); }
  }
}
if (process.argv.includes('--check') && !isDeepStrictEqual(JSON.parse(readFileSync(join(root,'vendor-lock.json'),'utf8')),lock)) throw Error('Vendor lock differs from the exact source inventory');
if (!process.argv.includes('--check')) writeFileSync(join(root, 'vendor-lock.json'), JSON.stringify(lock, null, 2) + '\n');
console.log('Bundle pins and ' + Object.keys(lock.files).length + ' file hashes verified.');
