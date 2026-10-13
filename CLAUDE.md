# Hearth for Claude Code

Help a person get Eidolon and Setup into Claude Code without making them learn the
machinery first. Keep it plain. Show what will change, where it will land, and what
still needs their say-so. Keep the warmth; skip the sales pitch.

Hearth is the installer, not a second copy of the skills' design. It has two doors:
the novice door (`welcome.ps1` on Windows, `macos/Welcome.command` on a Mac, no Node)
and the operator door (`scripts/welcome.mjs`, a Node 22 terminal picker that wires
project hooks). Keep both. Do not add a third.

## Claude's working map

```yaml
claude:
  project_rules: CLAUDE.md
  skills: .claude/skills/
  settings: .claude/settings.json
  invoke: /eidolon and /setup
sources:
  eidolon: eidolonofficial/eidolon
  setup: eidolonofficial/eidolon-setup
bundled:
  eidolon: skills/eidolon/SKILL.md
  setup: skills/setup/SKILL.md
integrity: vendor-lock.json
```

For a policy or skill change, fix the canonical repository first, then regenerate from
its reviewed commit with `node scripts/sync-bundles.mjs`. Never hand-edit anything under
`skills/` and call the distribution synchronized. Read
`skills/eidolon/references/current-platform-contract.md` for current host behavior.

## Before touching the person's project

- Look at what is already there; keep their instructions and project choices.
- Loading this file is not consent to run an installer or change a local installation.
- Use the person's existing answers; do not ask again just because another file loaded.
- Preview first. Show the target paths and the exact installation plan.
- Apply only that approved plan; stop on stale sources, changed destinations, or replay.
- Require separate replacement consent; preserve backups and receipts.
- Never call a partial copy successful. Report the failed step and recovery state.
- Do not silently install Node or credentials.
- Do not remove automatic optional-service holds that a project already has.
- Preserve Claude's native permission checks.

## What counts as checked

```sh
node --test tests/*.test.mjs
node --test "skills/eidolon/hooks/*.test.mjs" "skills/eidolon/scripts/*.test.mjs"
node --test skills/setup/tests/*.test.mjs
```

Also check, fresh after the last edit: the PowerShell parser reports 0 errors for
`welcome.ps1`; `bash -n macos/Welcome.command` exits 0; `grep -iw node welcome.ps1
macos/Welcome.command` finds nothing; and no non-bundle text file contains an em or
en dash. Use `node scripts/sync-bundles.mjs --check` with the exact reviewed source
checkouts under `.ci-source/`. Compare bytes, modes, source pins, and the whole lock
inventory. Do not rewrite a failing bundle during verification.

A unit test is not a signed-in Claude session, and a run on Windows is not a run on a
Mac. The macOS doors stay marked untested on hardware until a Mac run is recorded.
Say what was checked and leave the remaining uncertainty visible.

## Repository maintenance

Canonical sources are `eidolonofficial/eidolon` and `eidolonofficial/eidolon-setup`.
Update bundles only from explicit reviewed commit pins with `node scripts/sync-bundles.mjs`; never hand-edit anything under `skills/`.
Hearth supports Claude Code only. The installed result keeps explicit consent, shared safeguards, and evidence-based minimal skill selection with a gap path instead of guessing.
Run `node --test tests/*.test.mjs` and the bundled Eidolon/Setup test suites.
Keep the operator installer dry-run by default, verify all bytes, preserve backups and require replacement consent.
Keep the novice door free of Node: `welcome.ps1` and `macos/Welcome.command` must never call it.
A unit test is not a click-through on a real machine, and a run on Windows is not a run on a Mac.
Model names, skill activation behavior, hook schemas and subagent behavior are freshness-sensitive; bundled `references/current-platform-contract.md` is authoritative over older point-in-time notes.
Merge/release/publication follow the operator's current explicit instruction. Never rewrite history, bypass consent, or weaken a guard to make CI green.
