# Changelog

## v0.1.0 (unreleased)

Removed

- The three graphical installers: the Windows WPF window (`gui/`), the macOS app
  (`macos/Hearth.app`), and the browser installer (`installer/`, `scripts/hearth-ui.mjs`,
  `scripts/graphical-installer.mjs`). Their legacy copy cores, launchers and tests went with them.
- Codex support. Hearth installs for Claude Code only.
- The optional tool cards and the dependency offers that went with them.
- `scripts/prepare-legacy.mjs`, `.ci/`, and the `apply-native-ui`, `ui-snapshot` and
  `regenerate-bundles` workflows.
- `AGENTS.md`. Claude Code reads `CLAUDE.md`, which carries the maintenance rules itself.

Added

- The novice door: `Start Here.cmd` with `welcome.ps1` (PowerShell 5.1) and
  `macos/Welcome.command` (bash). No Node, no hooks, no third-party tools. They ask
  `replace` or `skip` for an existing skill and back up the old folder to
  `.claude/skills/.hearth-backups/<yyyyMMdd-HHmmss>/<name>`.
- The operator door: `Operator Setup.cmd` and `macos/Operator Setup.command` check for
  Node 22 or newer, then run the Claude-only picker `scripts/welcome.mjs`.
- `tests/novice-door.test.mjs`: the novice scripts contain no `node` token, the
  PowerShell parser reports 0 errors, `bash -n` passes, and a real copy into a temp
  folder matches `skills/` byte for byte, then backs up on replace.
- `docs/decisions/2026-10-13-two-doors.md`.

Changed

- `scripts/install.mjs` is Claude-only. The `--host` option is gone. It passes `vendor-lock.json`
  to the bundled installer, so every bundled file is verified before a plan exists, and `--yes`
  needs `--expect-plan` with the digest the preview printed.
- `scripts/welcome.mjs` no longer asks for a host. It prints the proposed text, the settings
  diff and the replace lists (added, changed, removed) under their paths, and needs the literal `yes`.
- CI runs the Hearth tests, the bundled Eidolon and Setup suites, selfcheck and audit on
  Linux, Windows and macOS, and fails if the novice scripts mention Node.
- README, READ ME FIRST files, HEARTH-SPEC.md, CLAUDE.md and CREDITS.md describe what ships.
- `skills/` and `vendor-lock.json` regenerated with `node scripts/sync-bundles.mjs` from eidolon e8e586463e42c4828b8d1dd31fb60f3a932a7c10 and eidolon-setup 3255e07f00180b43936ffc86e72024613be64ce6; CI checks out those commits.

Not done

- The macOS doors have not been run on a Mac.
