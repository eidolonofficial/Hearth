// Operator door: terminal picker for Claude Code. Shows the plan, asks, then applies that plan.
import { createInterface } from 'node:readline/promises';
import { stdin, stdout } from 'node:process';
import { join } from 'node:path';
import { prepareHearth, applyHearth } from './install.mjs';

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

const rl = createInterface({ input: stdin, output: stdout });
try {
  console.log('Hearth operator setup. This installs Setup and Eidolon for Claude Code.');
  const project = (await rl.question('Project folder (leave blank for user skills only): ')).trim() || undefined;
  let replace = false, plan, preview;
  try { plan = prepareHearth({ project }); preview = applyHearth(plan, { dryRun: true }); }
  catch (e) {
    if (!e.message.includes('--replace')) throw e;
    console.log('A skill is already installed there. Replacing it moves your current copy to .eidolon/backups in the target folder, with a receipt. Nothing is deleted.');
    replace = (await rl.question('Type replace to review the replacement plan, or press Enter to stop: ')).trim() === 'replace';
    if (!replace) throw Error('Stopped; nothing installed');
    plan = prepareHearth({ project, replace }); preview = applyHearth(plan, { dryRun: true, replace });
  }
  console.log('Proposed locations:');
  show(plan, preview.previews);
  if ((await rl.question('Type yes to apply exactly this plan: ')).trim() !== 'yes') throw Error('Stopped; nothing installed');
  const result = applyHearth(plan, { replace, dryRun: false });
  console.log('Verified skill files: ' + result.copied);
  console.log('Backup receipt: ' + (result.backups ? join(result.backups, 'receipt.json') : 'none, nothing was replaced'));
  console.log(project
    ? 'Next: restart Claude Code in that project. The project hooks are active in the next session.'
    : 'Next: open Claude Code and type /eidolon or /setup. Choose a project folder next time to wire project hooks.');
} catch (e) { console.error(e.message); process.exitCode = 1; }
finally { rl.close(); }
