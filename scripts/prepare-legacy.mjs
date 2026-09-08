// Narrow, idempotent maintenance migration. Keeps the original GUI layouts intact.
import { readFileSync, writeFileSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
function update(name, pairs) {
  const path = resolve(root, name); let text = readFileSync(path, 'utf8');
  for (const [before, after] of pairs) {
    if (text.includes(before)) text = text.replaceAll(before, after);
    else if (!text.includes(after)) throw Error('Unexpected legacy text in ' + name);
  }
  writeFileSync(path, text);
}
update('gui/MainWindow.xaml', [['Close this window any time. It cannot harm your computer.', 'Review the listed changes before approving. Replacements require separate consent.']]);
update('gui/Hearth.ps1', [['I could not finish the copy. Make sure the whole Hearth folder stayed together, then run this again. You have not broken anything.', 'Installation stopped: $($result.error). Use Start Agents for an explicitly backed-up replacement.']]);
update('Start Here.cmd', [['It cannot harm your computer, and nothing happens without your yes.', 'Review the listed changes before approving.']]);
update('macos/Hearth.app/Contents/MacOS/Hearth', [
  ['It cannot harm your computer.', 'Review the listed changes before approving.'],
  ['dialog "$SKILLS" "Back" "Set up my skills" >/dev/null || true', 'choice="$(dialog "$SKILLS" "Back" "Set up my skills")" || exit 0\n[ "$choice" = "Set up my skills" ] || exit 0'],
  ['I could not finish the copy. Make sure the whole Hearth folder stayed together, then open Hearth again. You have not broken anything.', 'Installation stopped: $result. Use Start Agents for prerequisites or an explicitly backed-up replacement.'],
  ['You now have: ${installed:-your skills}, ready in Claude.', 'Completed installations: ${installed:-none}.']
]);
console.log('Legacy consent and completion text migrated.');
