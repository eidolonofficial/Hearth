# Hearth for Claude Code

Help a person get their project ready for Claude Code without making them learn
the machinery first. Keep it plain. Show what will change, where it will land,
and what still needs their say-so. Keep the warmth; skip the sales pitch.

Hearth brings Eidolon and Setup together. It is the installer, not a second copy
of their design. Keep the three repositories separate and the original artwork,
welcome flow, and working parts intact.

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

Read the bundled Claude workflows when working on their behavior. For a policy or
skill change, fix the canonical repository first, then regenerate from its reviewed
commit. Never hand-edit the mirrored files and call the distribution synchronized.
Read `skills/eidolon/references/current-platform-contract.md` for current host behavior
and `skills/setup/references/engine-contract.md` before engine or optional-service work.

## Before touching the person's project

- Look at what is already there; keep their instructions and project choices.
- Loading this file is not consent to run an installer or change a local installation.
- Use the person's existing answers; do not ask again just because another file loaded.
- Preview first. Show the selected host, target paths, and exact installation plan.
- Apply only that approved plan; stop on stale sources, changed destinations, or replay.
- Require separate replacement consent; preserve backups and receipts.
- Never call a partial copy successful. Report the failed step and recovery state.
- Do not silently install Node, credentials, models, Graphify, or MemPalace.
- Keep automatic optional-service holds intact; do not remove or reconfigure existing services.
- Preserve Claude's native permission checks. Another host's adapter is not a substitute.

Claude Code and Codex are both supported. Preserve each host's own workflow,
configuration, and approval behavior. Neither host delegates its project
instructions to the other.

## What counts as checked

```sh
node --test tests/*.test.mjs
node --test skills/eidolon/hooks/*.test.mjs skills/eidolon/scripts/*.test.mjs
node --test skills/setup/tests/*.test.mjs
python -m unittest discover -s skills/eidolon/engine/tests -v
```

Use `node scripts/sync-bundles.mjs --check` with the exact reviewed source checkouts
under `.ci-source/`. Compare bytes, modes, source pins, and the entire lock inventory;
do not rewrite a failing bundle during verification. Keep the POSIX and PowerShell
approval and replacement tests. Verify the actual page and installed output, not
just that a helper returned success.

A unit test is not a clicked-through window or a signed-in Claude session. Report
those observations separately. A supervised process is not an operating-system
sandbox, and a clean scan does not prove that every dependency or historical object
is safe. Say what was checked and leave the remaining uncertainty visible.

## Repository maintenance

Canonical sources are `eidolonofficial/eidolon` and `eidolonofficial/eidolon-setup`.
Update bundles only from explicit reviewed commit pins; never hand-edit mirrored policy.
The installed result must preserve the cross-host user story: Claude, Codex, or both; shared safeguards; explicit consent; current-host capability detection; and evidence-based minimal skill selection with a gap path instead of guessing.
Run `node --test tests/*.test.mjs` and the bundled Eidolon/Setup test suites.
Keep installers dry-run by default, verify all bytes, preserve backups and require replacement consent.
Native GUI smoke tests and authenticated client tests must not be inferred from unit tests.
Model names, skill activation behavior, hook schemas and subagent behavior are freshness-sensitive; bundled `references/current-platform-contract.md` is authoritative over older point-in-time notes.
Merge/release/publication follow the operator's current explicit instruction. Never rewrite history, bypass consent, or weaken a guard to make CI green.
