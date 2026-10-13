import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync, existsSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import {dirname, resolve, join} from 'node:path';
const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const read = name => readFileSync(join(root, name), 'utf8');
test('Claude has a direct native entry point, not an AGENTS import', () => {
  const text = read('CLAUDE.md');
  assert.doesNotMatch(text, /@(?:\.\/)?AGENTS\.md/i);
  assert.match(text, /^# .+ for Claude Code/m);
  for (const phrase of ["Keep the warmth; skip the sales pitch.", "exact installation plan", "vendor-lock.json", ".claude/skills/", "automatic optional-service holds", "canonical repository first"]) assert.ok(text.includes(phrase), phrase);
});
test('Hearth has no AGENTS.md; CLAUDE.md carries the maintenance rules itself', () => {
  assert.equal(existsSync(join(root, 'AGENTS.md')), false);
  const text = read('CLAUDE.md');
  for (const phrase of ['never hand-edit anything under `skills/`', 'Keep the novice door free of Node', 'Never rewrite history']) assert.ok(text.includes(phrase), phrase);
});
test('Claude instruction references resolve in the shipped repository', () => {
  const text = read('CLAUDE.md');
  for (const match of text.matchAll(/`((?:references|skills\/(?:eidolon|setup)\/references|engine)\/[a-zA-Z0-9/_-]+\.md)`/g)) {
    const path = match[1].startsWith('references/') ? 'skills/eidolon/' + match[1] : match[1];
    assert.ok(existsSync(join(root, path)), path);
  }
});
