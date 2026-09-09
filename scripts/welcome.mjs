// Interactive, terminal-based host picker. Never installs runtimes or optional services.
import { createInterface } from 'node:readline/promises';
import { stdin, stdout } from 'node:process';
import { prepareHearth, applyHearth } from './install.mjs';
const rl = createInterface({ input: stdin, output: stdout });
try {
  console.log('Hearth: choose where Setup and Eidolon will run.');
  const choice = (await rl.question('1 Codex, 2 Claude Code, 3 Both: ')).trim();
  const host = { 1: 'codex', 2: 'claude', 3: 'both' }[choice];
  if (!host) throw Error('No valid choice; nothing installed');
  const project = (await rl.question('Project folder (leave blank for user skills only): ')).trim() || undefined;
  let replace = false, plan;
  try { plan = prepareHearth({ host, project }); applyHearth(plan,{dryRun:true}); }
  catch (e) {
    if (!e.message.includes('--replace')) throw e;
    console.log('An existing skill needs replacement. Your current version will be backed up, not deleted.');
    replace = (await rl.question('Type replace to review the replacement plan, or Enter to stop: ')).trim() === 'replace';
    if (!replace) throw Error('Stopped; nothing installed');
    plan = prepareHearth({ host, project, replace }); applyHearth(plan,{dryRun:true,replace});
  }
  console.log('Proposed locations:\n' + plan.items.map(item => '  ' + item.path).join('\n'));
  if ((await rl.question('Type yes to apply exactly this plan: ')).trim().toLowerCase() !== 'yes') throw Error('Stopped; nothing installed');
  const result = applyHearth(plan,{replace,dryRun:false});
  console.log('Verified skill files: ' + result.copied + '. Backup receipt: ' + (result.backups || 'no changes'));
  console.log(project ? 'Restart the selected client. In Codex, review project trust and /hooks before relying on enforcement.' : 'User skills installed. Project hooks require a separate project installation.');
} catch (e) { console.error(e.message); process.exitCode = 1; }
finally { rl.close(); }
