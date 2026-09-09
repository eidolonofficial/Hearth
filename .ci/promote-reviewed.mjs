// Maintainer-only migration of the previously tested candidate into committed files.
// This never merges, releases, or modifies a user installation.
import {readFileSync,writeFileSync,readdirSync} from 'node:fs';
import {execFileSync} from 'node:child_process';
import {createHash} from 'node:crypto';
const read=p=>readFileSync(p,'utf8');
const write=(p,s)=>writeFileSync(p,s);
function patch(p,before,after){const s=read(p);if(s.includes(after))return;if(!s.includes(before))throw Error('Unexpected source shape: '+p);write(p,s.replace(before,after));}
function append(p,addition){const s=read(p);if(!s.includes(addition))write(p,s+addition);}
if(read('.ci/prepare-integration.mjs').includes('Test-only assembly'))execFileSync(process.execPath,['.ci/prepare-integration.mjs'],{stdio:'inherit'});
patch('scripts/hearth-ui.mjs',"JSON.parse(Buffer.concat(parts).toString('utf8')||'{}')","JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(Buffer.concat(parts))||'{}')");
for(const name of readdirSync('.github/workflows').filter(n=>n.endsWith('.yml'))){
 const path='.github/workflows/'+name;
 let text=read(path).replaceAll('a075bbb51cbd5e75330057191b8147fe42a667a0','54ded26e23b731c02eb5156d1304aa343c3ce0b1').replaceAll('ed077751d985b5b8154300e42b4bb48f1c8903ad','3e96e7119fd9778165063cdb0569c9b7a5891776');
 if(name==='integration-verification.yml'){
  text=text.replace('branches: [ci/github-verification-20260909]','branches: [main, ci/github-verification-20260909]');
  if(!text.includes('  pull_request:'))text=text.replace('  workflow_dispatch:','  pull_request:\n  workflow_dispatch:');
  text=text.replace('Assemble and verify the pending candidate without publishing it','Verify the committed distribution without rewriting it').replace('node .ci/prepare-integration.mjs','node scripts/sync-bundles.mjs --check').replace('tee .ci-evidence/assembly.txt','tee .ci-evidence/bundle-integrity.txt');
  if(!text.includes('git archive --format=tar HEAD'))text=text.replace('          cp vendor-lock.json .ci-evidence/vendor-lock.json','          cp vendor-lock.json .ci-evidence/vendor-lock.json\n          git diff --exit-code\n          git archive --format=tar HEAD > .ci-evidence/source.tar');
  const step='      - name: Tampered lock and mirror are refused without repairs\n        shell: bash\n        run: |\n          set -o pipefail\n          node --test --test-reporter=tap scripts/generator-regression.test.mjs 2>&1 | tee .ci-evidence/generator.tap\n';
  if(!text.includes('Tampered lock and mirror'))text=text.replace('      - name: Hearth real server, protocol and disposable installation tests',step+'      - name: Hearth real server, protocol and disposable installation tests');
 }
 if(name==='compatibility.yml'){
  text=text.replace('branches: [main, release/codex-claude-compat]','branches: [main, release/codex-claude-compat, ci/github-verification-20260909]');
  if(!text.includes('mkdir -p .ci-evidence'))text=text.replace('mkdir -p evidence','mkdir -p .ci-evidence').replaceAll('evidence/','.ci-evidence/');
  if(!text.includes('include-hidden-files: true'))text=text.replace('          path: .ci-evidence/','          path: .ci-evidence/\n          include-hidden-files: true');
 }
 write(path,text);
}
append('.gitattributes','\n# Vendored upstream source bytes are pinned, including original persona newlines.\nskills/** -text\n');
append('.gitignore','\n# Disposable bundle inputs and local test evidence.\n/.ci-source/\n/.ci-evidence/\n');
for(const path of ['README.md','Start Agents.cmd','macos/Start Agents.command','macos/hearth-core.sh','gui/HearthCore.ps1'])write(path,read(path).replaceAll('Node.js 18','Node.js 22'));
patch('scripts/sync-bundles.mjs',"import { createHash } from 'node:crypto';","import { createHash } from 'node:crypto';\nimport {isDeepStrictEqual} from 'node:util';");
const check="if (!existsSync(join(dest, file.name)) || !readFileSync(join(dest, file.name)).equals(file.bytes)) throw Error('Bundled file differs from its pin: ' + name + '/' + file.name);";
patch('scripts/sync-bundles.mjs',check,check+"\n      if (process.platform !== 'win32' && (lstatSync(join(dest,file.name)).mode & 0o111) !== (file.mode & 0o111)) throw Error('Bundled executable mode differs: '+name+'/'+file.name);");
patch('scripts/sync-bundles.mjs',"if (!process.argv.includes('--check')) writeFileSync","if (process.argv.includes('--check') && !isDeepStrictEqual(JSON.parse(readFileSync(join(root,'vendor-lock.json'),'utf8')),lock)) throw Error('Vendor lock differs from the exact source inventory');\nif (!process.argv.includes('--check')) writeFileSync");
write('.ci/prepare-integration.mjs',"// Compatibility helper: validation only. The tested distribution is committed.\nimport {execFileSync} from 'node:child_process';\nexecFileSync(process.execPath,['scripts/sync-bundles.mjs','--check'],{stdio:'inherit'});\n");
append('README.md','\n## Committed distribution checks\n\nThe browser and terminal apply the same plan the user reviewed. Confirmation cannot\nchange its target, and a stale or already consumed preview requires another review.\nThe browser page, scripts, styles and original artwork are served locally.\n\nThe distribution contains the pinned source files directly. CI verifies the\ncommitted bundle and its lock before testing; it does not patch the application\ninto a different passing program. Full policy, persona, routing and installation\ntests run on Linux, Windows and macOS. Optional services are not prerequisites.\n\nAutomated HTTP and installer tests are separate from real-client approval checks\nand native graphical acceptance. An interrupted installer retains its journal\nand backups for reviewed recovery; automatic crash recovery is not claimed.\n');
const expected=JSON.parse(read('.ci/reviewed-candidate-hashes.json'));
for(const [path,digest]of Object.entries(expected))if(createHash('sha256').update(readFileSync(path)).digest('hex')!==digest)throw Error('Generated candidate differs from locally reviewed bytes: '+path);
execFileSync(process.execPath,['scripts/sync-bundles.mjs','--check'],{stdio:'inherit'});
console.log('Promoted files match the reviewed local bytes and all pinned bundle files.');
