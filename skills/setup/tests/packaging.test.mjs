import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createHash } from 'node:crypto';
const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const INVITATION = 'Tell me about it the way you would tell a coworker. Rant, infodump, jump around. I will sort it.';
const text = name => readFileSync(join(root, name), 'utf8');
test('the skill is named setup and invoked with /setup', () => {
  assert.match(text('SKILL.md'), /^---\nname: setup\ndescription: .+/);
  assert.match(text('SKILL.md'), /\/setup/);
});
test('session workflow matches its pinned hash (update the hash when you edit it on purpose)', () => {
  const bytes = readFileSync(join(root, 'references/session-workflow.md'));
  const blob = createHash('sha1').update('blob ' + bytes.length + '\0').update(bytes).digest('hex');
  assert.equal(blob, 'd195c9c0843a8fc3a821c4190053b6b84cc2684b');
});
test('all referenced workflow modules are present', () => {
  for (const name of ['remember', 'verify', 'collaborate']) assert.ok(existsSync(join(root, 'references', name + '.md')));
});
test('handoff and consent remain explicit', () => {
  assert.match(text('SKILL.md'), /\.claude\/session\.yaml/);
  assert.match(text('SKILL.md'), /wait for the answer/);
  assert.match(text('SKILL.md'), /Never bypass Claude Code's hook trust/);
});
test('standalone setup does not claim installed automation', () => {
  assert.match(text('SKILL.md'), /not a running memory service/);
  assert.match(text('README.md'), /not live model behavior/);
});
test('CLAUDE.md is Claude-only maintenance guidance', () => {
  assert.match(text('CLAUDE.md'), /# Setup for Claude Code/);
  assert.match(text('CLAUDE.md'), /current Claude Code capabilities/);
});
test('the vendored question bank exists and carries the invitation', () => {
  assert.ok(existsSync(join(root, 'references/interview.md')));
  assert.ok(text('references/interview.md').includes(INVITATION));
});
test('SKILL.md opens with the brain dump and the four questions', () => {
  const s = text('SKILL.md');
  assert.ok(s.includes(INVITATION));
  for (const chip of ['Start talking', 'Ask me questions instead', 'Skip', "That's it", 'Fix something', 'Add more']) assert.ok(s.includes(chip), chip);
  for (const q of ['Which parts do you want this session?', 'How should I treat your go ahead?', 'How far should I run before checking?', 'What kind of work is this?']) assert.ok(s.includes(q), q);
  assert.ok(s.indexOf(INVITATION) < s.indexOf('Which parts do you want'), 'dump comes first');
});
const flat = () => text('SKILL.md').replace(/\s+/g, ' ');
test('skill selection is evidence-based and gap-aware', () => {
  const s = flat();
  for (const phrase of ['explicit user choice first', 'inspected repository signals', 'risk signals', 'smallest sufficient non-conflicting set', 'record a gap', 'Generic words']) assert.ok(s.includes(phrase), phrase);
});
test('model and delegation behavior are capability based', () => {
  const s = flat();
  for (const phrase of ['Never pin behavior to a remembered Claude point release', 'Skill selection does not imply delegation', 'subagents when parallelism, isolated context, specialist work, or independent verification creates real value']) assert.ok(s.includes(phrase), phrase);
});
