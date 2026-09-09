// Preserve and apply the actual plan that the operator reviewed.
import {dirname,resolve,join} from 'node:path';
import {fileURLToPath} from 'node:url';
import {planInstall,applyPlan} from '../skills/eidolon/scripts/install.mjs';
const ROOT=resolve(dirname(fileURLToPath(import.meta.url)),'..');
export function prepareHearth(options={}) {
  return planInstall({...options,sources:[{name:'eidolon',source:join(ROOT,'skills/eidolon')},{name:'setup',source:join(ROOT,'skills/setup')}]});
}
export function applyHearth(plan,options={}) {
  const result=applyPlan(plan,options);
  const count=plan.items.reduce((sum,item)=>sum+(item.files?.size||0),0);
  return {...result,ok:!result.dryRun,copied:result.dryRun?0:count};
}
export function installHearth(options={}) {
  const plan=prepareHearth(options);
  if(options.expectedPlan && options.expectedPlan!==plan.digest) throw Error('Installation changed since preview; review a new plan');
  return applyHearth(plan,options);
}
export const planHearth=prepareHearth;
export const applyHearthPlan=applyHearth;
if(process.argv[1]&&resolve(process.argv[1])===fileURLToPath(import.meta.url)) {
  try {
    const args=process.argv.slice(2),options={dryRun:true};
    for(let i=0;i<args.length;i++) {
      const flag=args[i];
      if(flag==='--yes') options.dryRun=false;
      else if(flag==='--replace') options.replace=true;
      else if(['--host','--project','--home','--expect-plan'].includes(flag)) {
        const value=args[++i]; if(!value||value.startsWith('--')) throw Error('Missing option value');
        options[flag==='--expect-plan'?'expectedPlan':flag.slice(2)]=value;
      } else if(flag==='--help') {
        console.log('node scripts/install.mjs --host codex|claude|both [--project PATH | --home PATH] [--yes] [--replace] [--expect-plan DIGEST]'); process.exit(0);
      } else throw Error('Unknown option');
    }
    if(options.project&&options.home) throw Error('Choose project or home, not both');
    console.log(JSON.stringify(installHearth(options),null,2));
  } catch(e) { console.error('HEARTH INSTALL: '+e.message);process.exitCode=1; }
}
