# Hearth maintenance

Canonical sources are `eidolonofficial/eidolon` and `eidolonofficial/eidolon-setup`.
Update bundles only from explicit reviewed commit pins; never hand-edit mirrored policy.
The installed result must preserve the cross-host user story: Claude, Codex, or both; shared safeguards; explicit consent; current-host capability detection; and evidence-based minimal skill selection with a gap path instead of guessing.
Run `node --test tests/*.test.mjs` and the bundled Eidolon/Setup test suites.
Keep installers dry-run by default, verify all bytes, preserve backups and require replacement consent.
Native GUI smoke tests and authenticated client tests must not be inferred from unit tests.
Model names, skill activation behavior, hook schemas and subagent behavior are freshness-sensitive; bundled `references/current-platform-contract.md` is authoritative over older point-in-time notes.
Merge/release/publication follow the operator's current explicit instruction. Never rewrite history, bypass consent, or weaken a guard to make CI green.
