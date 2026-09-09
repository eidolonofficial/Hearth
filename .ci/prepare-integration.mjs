// Compatibility helper: validation only. The tested distribution is committed.
import {execFileSync} from 'node:child_process';
execFileSync(process.execPath,['scripts/sync-bundles.mjs','--check'],{stdio:'inherit'});
