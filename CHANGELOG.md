# Changelog

## v0.1.2 (2026-10-14)

Bundles

- Eidolon at v0.1.3 (40bee9b). Setup stays at v0.1.0. Nothing in Hearth's own doors or picker changed.

## v0.1.1 (2026-10-14)

Bundles

- Eidolon at v0.1.2 (6a416f0): hook review rounds 5 and 6, the update check, the house persona's
  problem-solving method, the token economy reference. Setup stays at v0.1.0 (2733f2e). The lock
  lists 164 files.

Added

- The npm package `eidolon-hearth`: `npx eidolon-hearth` runs the operator picker from npm, and
  `npx eidolon-hearth .` installs into the current project with its hooks. The package ships the
  picker, the installer, the two bundles and the lock; `tests/package.test.mjs` checks the pack
  against the lock.
- An update check in every door. Each door asks GitHub once for the latest Hearth release
  (three seconds at most, silent on failure, `EIDOLON_UPDATE_CHECK=0` turns it off) and asks
  before it acts: the novice doors open the download page on `yes`, the picker runs the newer
  version through `npm exec` with the same arguments. The Eidolon skill runs the same check at
  its start (`scripts/check-updates.mjs`, cached for a day) and asks before updating.
  `tests/update-notice.test.mjs` drives all three doors against a local release server.
- Picker flags `--yes` (apply without typed answers; replaces with a backup), `--home <path>`
  and `--version`.

Changed

- Bundles leave out each source repository's root `.gitignore`, because npm renames that file
  inside a published package.

## v0.1.0 (2026-10-13)

Removed

- The three graphical installers: the Windows WPF window (`gui/`), the macOS app
  (`macos/Hearth.app`), and the browser installer (`installer/`, `scripts/hearth-ui.mjs`,
  `scripts/graphical-installer.mjs`). Their legacy copy cores, launchers and tests went with them.
- Support for a second host. Hearth installs for Claude Code only.
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
- `skills/` and `vendor-lock.json` regenerated with `node scripts/sync-bundles.mjs` from eidolon 067434664e3630b52ef1f1d4460bafd2c5c9274a and eidolon-setup 2733f2e9c5d09c26040c2348ad082b2adf93513d; CI checks out those commits.
- `tests/novice-door.test.mjs` also runs the bash door and the operator wrapper for real
  wherever bash exists, so the Linux and macOS CI runners exercise the macOS door (copy,
  skip, replace with backup, option refusals, picker handoff).

Not done

- The macOS doors have run on GitHub's macOS runner and under WSL Ubuntu, not yet on a
  user's own Mac.
