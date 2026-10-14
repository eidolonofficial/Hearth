#!/usr/bin/env node
// Operator door: terminal picker for Claude Code. Shows the plan, asks, then applies that plan.
//   eidolon-hearth              user skills, with questions
//   eidolon-hearth <project>    the project copy and its hooks (. for the current folder)
//   --yes        no typed answers: an existing copy is replaced (a backup is kept) and the update question is skipped
//   --home PATH  use PATH in place of the user folder (tests)
//   --version    print the version and stop
import { createInterface } from 'node:readline/promises';
import { stdin, stdout } from 'node:process';
import { join, dirname, resolve } from 'node:path';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { prepareHearth, applyHearth } from './install.mjs';
import { checkForUpdate } from '../skills/eidolon/scripts/check-updates.mjs';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const VERSION = JSON.parse(readFileSync(join(ROOT, 'package.json'), 'utf8')).version;
const args = process.argv.slice(2);
const yes = args.includes('--yes');
const homeAt = args.indexOf('--home');
const home = homeAt >= 0 ? args[homeAt + 1] : undefined;
const positional = args.filter((a, i) => !a.startsWith('-') && !(homeAt >= 0 && i === homeAt + 1));
if (args.includes('--version')) { console.log(VERSION); process.exit(0); }

// Under each path: the text a plan will write, the settings diff, or the files a replacement adds, changes and removes.
function show(plan, previews) {
  for (const item of plan.items) {
    console.log('  ' + item.path);
    const preview = previews.find(p => p.path === item.path);
    if (!preview) continue;
    if (preview.files) { for (const [kind, list] of Object.entries(preview.files)) if (list.length) console.log('      ' + kind + ' (' + list.length + '): ' + list.join(', ')); }
    else console.log((preview.diff ?? preview.text).trimEnd().replace(/^/gm, '      '));
  }
}

// One request to GitHub for the latest Hearth release (cached for a day), silent when it fails;
// EIDOLON_UPDATE_CHECK=0 turns it off. On yes the newer version runs in place of this one, with the
// same arguments. HEARTH_UPDATE_COMMAND (a JSON array) replaces the npm command in tests.
async function updated(rl) {
  const result = await checkForUpdate({ current: VERSION });
  if (!result.newer) return false;
  console.log('Hearth v' + result.latest + ' is available. This copy is v' + VERSION + '.');
  console.log('Release: ' + result.url);
  if (yes) return false;
  if ((await rl.question('Update now? Type yes to run the newer version, or press Enter to continue with this copy: ')).trim() !== 'yes') return false;
  const npm = process.env.npm_execpath ? [process.execPath, process.env.npm_execpath] : [process.platform === 'win32' ? 'npm.cmd' : 'npm'];
  const command = process.env.HEARTH_UPDATE_COMMAND ? JSON.parse(process.env.HEARTH_UPDATE_COMMAND) : [...npm, 'exec', '--yes', '--', 'eidolon-hearth@' + result.latest];
  const viaCmd = command[0].endsWith('.cmd');
  const quote = a => (viaCmd && /\s/.test(a) ? '"' + a + '"' : a);
  const r = spawnSync(quote(command[0]), [...command.slice(1), ...args].map(quote), { stdio: 'inherit', shell: viaCmd });
  if (r.error || r.status !== 0) throw Error('The newer version did not ' + (r.error ? 'start' : 'finish') + ' (' + (r.error ? r.error.message : 'exit code ' + r.status) + '). Download it from ' + result.url + '. Nothing was installed by this copy.');
  return true;
}

const rl = createInterface({ input: stdin, output: stdout });
try {
  if (await updated(rl)) process.exit(0);
  console.log('Hearth operator setup. This installs Setup and Eidolon for Claude Code.');
  const given = positional[0];
  const project = given !== undefined ? (given === '.' ? process.cwd() : given)
    : yes ? undefined : ((await rl.question('Project folder (leave blank for user skills only): ')).trim() || undefined);
  if (given !== undefined) console.log('Project folder: ' + project);
  let replace = yes, plan, preview;
  try { plan = prepareHearth({ project, home, replace }); preview = applyHearth(plan, { dryRun: true, replace }); }
  catch (e) {
    if (!e.message.includes('--replace') || yes) throw e;
    console.log('A skill is already installed there. Replacing it moves your current copy to .eidolon/backups in the target folder, with a receipt. Nothing is deleted.');
    replace = (await rl.question('Type replace to review the replacement plan, or press Enter to stop: ')).trim() === 'replace';
    if (!replace) throw Error('Stopped; nothing installed');
    plan = prepareHearth({ project, home, replace }); preview = applyHearth(plan, { dryRun: true, replace });
  }
  console.log('Proposed locations:');
  show(plan, preview.previews);
  if (!yes && (await rl.question('Type yes to apply exactly this plan: ')).trim() !== 'yes') throw Error('Stopped; nothing installed');
  const result = applyHearth(plan, { replace, dryRun: false });
  console.log('Verified skill files: ' + result.copied);
  console.log('Backup receipt: ' + (result.backups ? join(result.backups, 'receipt.json') : 'none, nothing was replaced'));
  console.log(project
    ? 'Next: restart Claude Code in that project. The project hooks are active in the next session.'
    : 'Next: open Claude Code and type /eidolon or /setup. Choose a project folder next time to wire project hooks.');
} catch (e) { console.error(e.message); process.exitCode = 1; }
finally { rl.close(); }
