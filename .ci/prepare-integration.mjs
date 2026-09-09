// Test-only assembly: no commit, merge, user installation or release is performed.
import {readFileSync,writeFileSync} from 'node:fs';
import {execFileSync} from 'node:child_process';
function replace(path,before,after){const source=readFileSync(path,'utf8');if(!source.includes(before))throw Error('Expected source shape changed: '+path);writeFileSync(path,source.replace(before,after));}
replace('scripts/sync-bundles.mjs','a075bbb51cbd5e75330057191b8147fe42a667a0','54ded26e23b731c02eb5156d1304aa343c3ce0b1');
replace('scripts/sync-bundles.mjs','ed077751d985b5b8154300e42b4bb48f1c8903ad','3e96e7119fd9778165063cdb0569c9b7a5891776');
execFileSync(process.execPath,['scripts/sync-bundles.mjs'],{stdio:'inherit'});
execFileSync(process.execPath,['scripts/sync-bundles.mjs','--check'],{stdio:'inherit'});
replace('installer/app.js',"let reviewedFingerprint = '';","let reviewedFingerprint = '';\nlet previewId = '';");
replace('installer/app.js','reviewedFingerprint = fingerprint(request);','reviewedFingerprint = fingerprint(request);\n    previewId = data.previewId;');
replace('installer/app.js',"api('/api/install', {...request, confirm:true})","api('/api/install', {confirm:true, previewId})");
replace('installer/app.js',"    setStatus(error.message, 'error');\n    installButton.disabled = false;","    setStatus(error.message + ' Review the plan before retrying.', 'error');\n    reviewedFingerprint = ''; previewId = ''; installButton.disabled = true;");
replace('installer/app.js',"import('https://cdn.jsdelivr.net/npm/three@0.180.0/build/three.module.js')","import('/assets/three.module.js')");
replace('installer/app.js','\nenhanceScene();',"\n// Optional local enhancement; the unchanged artwork remains the default.\nif(document.documentElement.dataset.enableLocalScene === 'true') enhanceScene();");
replace('tests/hearth-ui.test.mjs',"headers: {'content-type':'application/json','x-hearth-token':token}","headers: {'content-type':'application/json','x-hearth-token':token,'origin':new URL(base).origin}");
replace('tests/hearth-ui.test.mjs',"{host:'both',project,replace:false,confirm:true}","{confirm:true,previewId:plan.previewId}");
replace('scripts/welcome.mjs',"import { installHearth }", "import { prepareHearth, applyHearth }");
replace('scripts/welcome.mjs','plan = installHearth({ host, project });','plan = prepareHearth({ host, project }); applyHearth(plan,{dryRun:true});');
replace('scripts/welcome.mjs','plan = installHearth({ host, project, replace });','plan = prepareHearth({ host, project, replace }); applyHearth(plan,{dryRun:true,replace});');
replace('scripts/welcome.mjs',"plan.paths.map(p => '  ' + p)","plan.items.map(item => '  ' + item.path)");
replace('scripts/welcome.mjs','installHearth({ host, project, replace, dryRun: false })','applyHearth(plan,{replace,dryRun:false})');
console.log('Prepared candidate Hearth interface with exact, verified upstream bundles. This modifies only the disposable GitHub runner checkout.');
