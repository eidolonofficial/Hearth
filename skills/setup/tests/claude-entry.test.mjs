import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync, existsSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import {dirname, resolve, join} from 'node:path';
const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const read = name => readFileSync(join(root, name), 'utf8');
test('CLAUDE.md is the Claude Code maintenance guide', () => {
  const text = read('CLAUDE.md');
  assert.match(text, /^# .+ for Claude Code/m);
  for (const phrase of ["The one place a work session starts from.", "write the least, and verify it the most", "references/interview.md", "The warmth stays the same at every level.", ".claude/session.yaml", "active index"]) assert.ok(text.includes(phrase), phrase);
});
test('CLAUDE.md reference paths resolve in the shipped repository', () => {
  const text = read('CLAUDE.md');
  for (const match of text.matchAll(/`(references\/[a-zA-Z0-9/_-]+\.md)`/g)) {
    assert.ok(existsSync(join(root, match[1])), match[1]);
  }
});
// Paths written in backticks must resolve in this repo, except runtime paths in the
// target project and paths owned by Eidolon (named in interview.md and session-workflow.md).
const RUNTIME_OR_EIDOLON = new Set([
  'docs/fixes', 'docs/insights', 'docs/memory-index.json',
  '.claude/session.yaml', '.claude/skills/', '.claude/skills/setup', '.claude/autopilot/<slug>.md',
  'references/persona-template.md', 'references/security-policy.md',
]);
test('every backticked references/docs/.claude path resolves or is allowlisted', async () => {
  const {readdirSync} = await import('node:fs');
  const files = ['SKILL.md', 'README.md', 'CLAUDE.md', ...readdirSync(join(root, 'references')).map(f => 'references/' + f)];
  for (const f of files) {
    for (const m of read(f).matchAll(/`((?:references\/[^`\s]+\.md)|(?:docs\/[^`\s]+)|(?:\.claude\/[^`\s]+))`/g)) {
      const p = m[1];
      if (RUNTIME_OR_EIDOLON.has(p)) continue;
      assert.ok(existsSync(join(root, p)), f + ' -> ' + p);
    }
  }
});
test('each SKILL.md opening question appears in references/interview.md', () => {
  const interview = read('references/interview.md');
  for (const q of ['Which parts do you want this session?', 'How should I treat your go ahead?', 'How far should I run before checking?', 'What kind of work is this?']) {
    assert.ok(read('SKILL.md').includes(q), 'SKILL.md: ' + q);
    assert.ok(interview.includes(q), 'interview.md: ' + q);
  }
});
