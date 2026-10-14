# Hearth

Hearth installs two skills for Claude Code: Setup and Eidolon.

Setup asks a few short questions at the start of a session and keeps notes for
you. Eidolon reads a project and writes the files Claude Code needs to work well
in it. In Claude Code you start them with `/setup` and `/eidolon`.

Hearth works with Claude Code only. It has two doors. Pick one.

## Door 1: the novice door

Use this if you want the skills and nothing else. No Node, no Git, no extra tools.

- Windows: double-click `Start Here.cmd`. It runs `welcome.ps1` in Windows PowerShell 5.1.
- macOS: open `macos/Welcome.command`. It is a plain bash script. Status: run on GitHub's macOS
  runner on 2026-10-13 (the test copies, skips and replaces there) and under WSL Ubuntu; not yet
  on a user's own Mac.

It copies the `skills/` folder into `.claude/skills` in your user folder, so you end up
with `.claude/skills/eidolon` and `.claude/skills/setup`. It writes nothing else.
It adds no hooks and installs no other tool.

If a skill is already there, it asks `replace` or `skip`. Skip is the default. On
replace, your old folder moves to `.claude/skills/.hearth-backups/<yyyyMMdd-HHmmss>/<name>`
before the new one is copied. Each file is printed as it lands.

Both scripts accept test flags: `-Yes -Home <path>` on Windows and
`--yes --home <path>` on macOS. `-Yes` replaces without asking. `-Home` swaps your user
folder for another one.

## Door 2: the operator door

Use this if you want project hooks. It needs Node 22 or newer.

- Windows: double-click `Operator Setup.cmd`.
- macOS: open `macos/Operator Setup.command`. Status: run on GitHub's macOS runner on 2026-10-13;
  not yet on a user's own Mac.
- Any terminal: `node scripts/welcome.mjs`.
- From npm, with Node 22: `npx eidolon-hearth` for user skills, or `npx eidolon-hearth .` inside a
  project to wire its hooks. It runs the same picker from the published package `eidolon-hearth`.

It checks your Node version first. If Node is missing or too old, it points you to
https://nodejs.org and stops. Then it asks for a project folder. Blank means user skills
only.

Before it plans, it checks every bundled file against `vendor-lock.json` and stops on a
mismatch. It shows every path it will write under "Proposed locations:", with the text it
will add, the settings diff, or the files a replacement adds, changes and removes. It writes
only after you type `yes`. Then it prints the verified file count, the path of the backup
receipt, and the next step.

A project install writes these inside the project:

- `.claude/skills/eidolon` and `.claude/skills/setup`
- `.claude/settings.json` with the hook entries, and `.claude/eidolon-manifest.yaml`
- `.eidolon/policy-manifest.json`
- marked sections in `CLAUDE.md` and `.gitignore`, between `eidolon:begin` and `eidolon:end` lines

Restart Claude Code in the project. The hooks are active in the next session. They run
Node, so keep Node installed for that project.

If a skill already exists, you must type `replace` to review a replacement plan.
Old files are kept under `.eidolon/backups/<id>/` in the target folder, with a
`receipt.json`. Nothing is deleted. A plan that changed after you reviewed it is
refused, and a failed install is never reported as a success.

For scripts, `node scripts/install.mjs [--project PATH | --home PATH] [--yes --expect-plan DIGEST] [--replace]`
previews by default. The preview prints a `planDigest`; `--yes` is refused unless `--expect-plan`
carries that digest, so only the previewed plan is applied.

## What is in this folder

- `skills/eidolon` and `skills/setup` are copies of the skills from their own repositories
  (`eidolonofficial/eidolon` and `eidolonofficial/eidolon-setup`). `vendor-lock.json` pins
  the exact commits and file hashes. Regenerate them only with `node scripts/sync-bundles.mjs`.
- `READ ME FIRST.txt` is the printable guide for the novice door. `macos/READ ME FIRST.txt`
  is the macOS copy.
- `HEARTH-SPEC.md` is the design record. `CHANGELOG.md` lists what changed.

## Check it

```sh
node --test tests/*.test.mjs
```

The bundled suites run with `node --test "skills/eidolon/hooks/*.test.mjs" "skills/eidolon/scripts/*.test.mjs"`
and `node --test skills/setup/tests/*.test.mjs`. A passing test is not a click-through on a
real machine. The bash door and the operator wrapper run for real in the test suite wherever
bash exists: Git Bash on Windows, and the Linux and macOS runners in CI. A run on a user's own
Mac is still to be recorded.

## License and credits

Hearth and the skills are MIT licensed. See `LICENSE`. `CREDITS.md` names the people whose
work Hearth stands on.
