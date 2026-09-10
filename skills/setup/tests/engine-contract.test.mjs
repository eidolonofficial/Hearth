import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
const text = name => readFileSync(new URL('../'+name, import.meta.url),'utf8');
test('both host entries load the same engine contract',()=>{
  assert.equal(text('SKILL.md'),text('codex/SKILL.md'));
  for(const file of ['SKILL.md','codex/SKILL.md']) assert.match(text(file),/references\/engine-contract\.md/);
});
test('engine contract separates approval, actors, evidence and optional services',()=>{
  const value=text('references/engine-contract.md');
  for(const phrase of ['exact digest','trusted-local','not an operating-system','controller and worker identity separate','Failed, interrupted, stale or non-finite','separate approval','Existing\nuser installations must not be removed','reachable-history']) assert.ok(value.includes(phrase),phrase);
});
