# Hearth

Install **Eidolon and Setup for Codex, Claude Code, or both**. The new host picker
and command-line installer share one tested copy engine. The existing graphical
installers remain Claude-only; they now use that engine too.

## Start here

Requires Node.js 22 or newer on PATH and Git. Hearth does not silently install
Node, API credentials, or optional services.

- Windows: double-click **Start Agents.cmd** to choose Codex, Claude, or both.
- macOS: open **macos/Start Agents.command** for the same terminal-based picker.
- Linux or any terminal: `node scripts/welcome.mjs`.

The picker shows the target paths and requires an explicit yes before writing.
A blank project path installs user skills only. A project path also installs
project-local instructions and hook configuration.

For a non-interactive preview, from this checkout:

```sh
node scripts/install.mjs --host codex --project /path/to/project
node scripts/install.mjs --host both --project /path/to/project --yes
```

Omit `--project` for user skills only. Existing skill directories are refused
unless `--replace` is explicitly supplied. Replaced files remain under
`.eidolon/backups/` with a receipt. Byte verification must succeed for the whole
bundle before targets change; a failed transaction attempts rollback and reports
any recovery work rather than calling a partial copy successful.

After a Codex project install, restart Codex, review project trust, then inspect
and trust `/hooks`. User skill installation alone does not enable project hooks.
Invoke `$eidolon` and `$setup` in Codex; `/eidolon` and `/setup` in Claude Code.

## Compatibility boundary

The shared policy evaluators retain the Claude behavior. Codex edits are parsed
as patches, not shell commands. Unsupported or ambiguous patch formats fail
closed. Codex does not support the same native ask response: ask-tier operations
stay blocked for operator review outside the agent or until the documented
prerequisite is satisfied. No bypass receipt is manufactured from a chat yes.
See `skills/eidolon/codex/README.md` for the exact boundary and test checklist.

The original GUI launchers remain Claude-specific; their text fallback now uses
the host picker. Their visual behavior still needs real Windows/macOS acceptance
testing; automated installer tests are not a claim that the windows have been
clicked through.

## What is bundled

Setup establishes the session's working boundaries and project notes. Eidolon
provides setup/build/evolve workflows, shared policy checks and host adapters.
The source-of-record repositories remain `eidolonofficial/eidolon` and
`eidolonofficial/eidolon-setup`. `vendor-lock.json` records exact commits and
per-file hashes; `scripts/sync-bundles.mjs` regenerates tracked bundles from those
reviewed pins, not from moving default branches.

The new picker installs no third-party optional services. The legacy GUI's
Graphify and MemPalace offers remain separate and Claude-specific. Verify each
optional tool's current official instructions before use.

## Verification

```sh
node --test tests/*.test.mjs
node --test skills/eidolon/hooks/*.test.mjs skills/eidolon/scripts/*.test.mjs
node --test skills/setup/tests/*.test.mjs
```

See `gui/TESTING.md` for the real-client and GUI acceptance checks that remain
separate from automated tests.

## License and credits

Hearth and the authored skills are MIT licensed; see the root `LICENSE`.
The vendored ASI-Evolve engine retains its Apache-2.0 `LICENSE`, `NOTICE`,
and provenance inside `skills/eidolon/engine/asi-evolve/`.
`CREDITS.md` preserves the upstream acknowledgments.

## Committed distribution checks

The browser and terminal apply the same plan the user reviewed. Confirmation cannot
change its target, and a stale or already consumed preview requires another review.
The browser page, scripts, styles and original artwork are served locally.

The distribution contains the pinned source files directly. CI verifies the
committed bundle and its lock before testing; it does not patch the application
into a different passing program. Full policy, persona, routing and installation
tests run on Linux, Windows and macOS. Optional services are not prerequisites.

Automated HTTP and installer tests are separate from real-client approval checks
and native graphical acceptance. An interrupted installer retains its journal
and backups for reviewed recovery; automatic crash recovery is not claimed.
