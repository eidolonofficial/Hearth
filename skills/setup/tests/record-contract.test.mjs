import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const read=name=>readFileSync(new URL('../'+name,import.meta.url),'utf8');
test('active record guidance preserves history while retiring index entries',()=>{
 const text=read('references/remember.md');
 assert.match(text,/historical evidence append-only/);
 assert.match(text,/docs\/memory-index\.json/);
 assert.match(text,/privacy redaction or record deletion is a separate/);
 assert.doesNotMatch(text,/retire the entries that have stopped/);
});
test('both host skills preserve interview context in the persona handoff',()=>{
 for(const name of ['SKILL.md','codex/SKILL.md']){
  const text=read(name);assert.match(text,/answered and pending questions/);
  assert.match(text,/deploy-plan/);assert.match(text,/grants no permission/);
 }
});
