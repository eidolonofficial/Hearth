# Hearth maintenance

Canonical sources are `eidolonofficial/eidolon` and `eidolonofficial/eidolon-setup`.
Update bundles only from explicit reviewed commit pins with `node scripts/sync-bundles.mjs`; never hand-edit anything under `skills/`.
Hearth supports Claude Code only. The installed result keeps explicit consent, shared safeguards, and evidence-based minimal skill selection with a gap path instead of guessing.
Run `node --test tests/*.test.mjs` and the bundled Eidolon/Setup test suites.
Keep the operator installer dry-run by default, verify all bytes, preserve backups and require replacement consent.
Keep the novice door free of Node: `welcome.ps1` and `macos/Welcome.command` must never call it.
A unit test is not a click-through on a real machine, and a run on Windows is not a run on a Mac.
Model names, skill activation behavior, hook schemas and subagent behavior are freshness-sensitive; bundled `references/current-platform-contract.md` is authoritative over older point-in-time notes.
Merge/release/publication follow the operator's current explicit instruction. Never rewrite history, bypass consent, or weaken a guard to make CI green.
