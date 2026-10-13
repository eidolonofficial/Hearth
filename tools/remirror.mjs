#!/usr/bin/env node
// remirror.mjs - regenerate the bundled skills from their live source repos.
//
// This is a maintainer tool; novices never run it. It closes the staleness
// failure mode where the bundle silently ships an ever-older Eidolon: every
// run replaces the mirror wholesale and records the exact source commit in a
// MIRROR file inside the mirrored skill, so "current with the source" is
// checkable rather than promised.
//
// Usage: node tools/remirror.mjs

import { cpSync, rmSync, existsSync, writeFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { join, dirname, relative } from 'node:path';
import { fileURLToPath } from 'node:url';

const bundleRoot = dirname(dirname(fileURLToPath(import.meta.url)));

// Repo plumbing, internal records, and tests never ship into a novice's
// ~/.claude/skills. Directory entries match as path prefixes from the repo
// root; *.test.mjs matches anywhere in the tree.
const EXCLUDED_DIRS = [
  '.git',
  '.claude',
  'tasks',
  'graphify-out',
  'docs/decisions',
  'docs/spec',
  'engine',
];
const EXCLUDED_NOTE =
  '.git, .claude, tasks/, graphify-out/, docs/decisions/, docs/spec/, engine/, *.test.mjs';

function shouldCopy(srcRoot, srcPath) {
  const rel = relative(srcRoot, srcPath).replace(/\\/g, '/');
  if (rel === '') return true;
  if (rel.endsWith('.test.mjs')) return false;
  return !EXCLUDED_DIRS.some((d) => rel === d || rel.startsWith(d + '/'));
}

function mirror(srcRepo, destDir, label) {
  if (!existsSync(srcRepo)) {
    console.error(`skip ${label}: source repo not found at ${srcRepo}`);
    process.exitCode = 1;
    return;
  }
  const sha = execFileSync('git', ['-C', srcRepo, 'rev-parse', 'HEAD'], {
    encoding: 'utf8',
  }).trim();
  rmSync(destDir, { recursive: true, force: true });
  cpSync(srcRepo, destDir, {
    recursive: true,
    filter: (src) => shouldCopy(srcRepo, src),
  });
  const stamp = [
    `source: ${srcRepo}`,
    `commit: ${sha}`,
    `date: ${new Date().toISOString().slice(0, 10)}`,
    `excluded: ${EXCLUDED_NOTE}`,
    'regenerate with: node tools/remirror.mjs',
    '',
  ].join('\n');
  writeFileSync(join(destDir, 'MIRROR'), stamp);
  console.log(`${label}: mirrored ${sha.slice(0, 7)} into ${relative(bundleRoot, destDir)}`);
}

mirror(
  'C:/Users/strid/projects/eidolon',
  join(bundleRoot, 'skills', 'eidolon'),
  'eidolon'
);
if (existsSync(join(bundleRoot, 'skills', 'setup'))) {
  mirror(
    'C:/Users/strid/projects/eidolon-setup',
    join(bundleRoot, 'skills', 'setup'),
    'setup'
  );
}
