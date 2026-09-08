import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createHash } from 'node:crypto';
const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const text = name => readFileSync(join(root, name), 'utf8');
test('both hosts discover the same named skill', () => {
  for (const name of ['SKILL.md', 'codex/SKILL.md']) {
    assert.match(text(name), /^---\nname: setup\ndescription: .+/);
    assert.match(text(name), /\$setup/); assert.match(text(name), /\/setup/);
  }
});
test('original session workflow is preserved byte-for-byte', () => {
  const bytes = readFileSync(join(root, 'references/session-workflow.md'));
  const blob = createHash('sha1').update('blob ' + bytes.length + '\0').update(bytes).digest('hex');
  assert.equal(blob, 'e23c89d08dafb66779d364ab81c2600559781bea');
});
test('all referenced workflow modules are present', () => {
  for (const name of ['remember', 'verify', 'collaborate']) assert.ok(existsSync(join(root, 'references', name + '.md')));
});
test('shared handoff and consent remain explicit', () => {
  assert.match(text('SKILL.md'), /\.claude\/session\.yaml/);
  assert.match(text('SKILL.md'), /wait for the answer/);
  assert.match(text('SKILL.md'), /Never bypass hook trust/);
});
test('standalone setup does not claim installed automation', () => {
  assert.match(text('SKILL.md'), /not a running memory service/);
  assert.match(text('README.md'), /not live model behavior/);
});
test('instruction files preserve cross-host maintenance rules', () => {
  assert.match(text('CLAUDE.md'), /@AGENTS.md/);
  assert.match(text('AGENTS.md'), /current host capabilities/);
  assert.match(text('AGENTS.md'), /smallest sufficient set/);
});
test('skill selection is evidence-based and gap-aware', () => {
  for (const name of ['SKILL.md', 'codex/SKILL.md']) {
    const s = text(name);
    assert.match(s, /explicit user choice first/);
    assert.match(s, /inspected repository signals/);
    assert.match(s, /risk signals/);
    assert.match(s, /smallest sufficient non-conflicting set/);
    assert.match(s, /record a gap/);
    assert.match(s, /Generic words/);
  }
});
test('model and delegation behavior are capability based', () => {
  const s = text('SKILL.md');
  assert.match(s, /Never pin behavior to a remembered\n    Claude point release/);
  assert.match(s, /Skill selection does not imply delegation/);
  assert.match(s, /subagents when parallelism, isolated context, specialist work, or\n    independent verification creates real value/);
});
