# Hearth: design spec

Date: 2026-06-08
Author: Jonah Butterbaugh (with Claude)
Status: shipped as described, 2026-10-13. Section numbers are kept from the first
spec so older references still resolve. Sections 8 to 11 and 14 were removed in the
2026-10-13 re-cut, and section 16 went with them.

---

## 1. What Hearth is

Hearth is a plain-language front door for Claude Code. A person who is nervous
around computers can open it, read a few short lines, and walk away with two
skills installed: Setup and Eidolon.

The name Hearth is the home. Setup and Eidolon are the skills it lays down.
It installs nothing else.

## 2. Who it is for

Everyday people running their own business, who are not confident with
computers and would stop at "open PowerShell and paste this command." Hearth is
built so that person is never lost and never made to feel small.

A second, smaller group is operators who want project hooks wired in. They get
their own door.

## 3. The voice

Plain and warm. Short sentences. Second person, present tense.

- Say what will happen before it happens. Say what happened after.
- Say where files will go, with the full path.
- Safety comes from stating the facts: you say yes to every change, and skipping
  is always allowed. Do not soothe. Do not sell.
- Every failure says the one thing to try and that nothing is broken.
- No promotional adjectives. No taglines.
- No filler words such as calm, gently, quietly, mindful, or breathing.
- No em dashes and no en dashes, in any file outside the bundled skills.
  A test script can check this with a regular expression for the characters U+2013 and U+2014.
- Be true. Do not promise more than a check has shown.

## 4. Design pillars

1. You are in control. Every change to your machine waits for your answer.
   The novice door asks before it replaces anything. The operator door shows the
   plan and needs the word `yes`.
2. Two skills, nothing else. Hearth copies Setup and Eidolon. It installs no other
   tool, service, or runtime.
3. Your old copy is kept. A replaced skill moves to a backup folder first. Nothing
   is deleted.
4. The novice door needs nothing. It is pure PowerShell on Windows and pure bash on
   macOS. It has no Node, no hooks, and no third-party tools.
5. Failure is never your fault. A failure message names the one thing to try and
   says nothing is broken.
6. Every file is plain text you can read. No encoded blobs.

## 5. What ships

```
Start Here.cmd               Windows novice door. Runs welcome.ps1 and pauses.
welcome.ps1                  Windows novice door script. PowerShell 5.1, ASCII only.
Operator Setup.cmd           Windows operator door. Checks for Node 22, runs scripts/welcome.mjs.
READ ME FIRST.txt            Printable guide for the novice door.
macos/
  Welcome.command            macOS novice door. Bash.
  Operator Setup.command     macOS operator door. Checks for Node 22, runs scripts/welcome.mjs.
  READ ME FIRST.txt          Printable guide, macOS version.
scripts/
  welcome.mjs                Operator picker: project folder, preview, yes, apply.
  install.mjs                Claude-only wrapper over the bundled Eidolon installer.
  sync-bundles.mjs           Regenerates skills/ from the pinned commits in vendor-lock.json.
  generator-regression.test.mjs  Checks that tampered bundles are refused. Needs .ci-source/.
skills/
  eidolon/                   The Eidolon skill, as pinned in vendor-lock.json.
  setup/                     The Setup skill, as pinned in vendor-lock.json.
tests/                       install, merge-acceptance, novice-door, claude-entry, branding-name.
assets/                      EidolonLogo.png, lantern.svg.
vendor-lock.json             Commit pins and per-file hashes for skills/.
README.md  CLAUDE.md  AGENTS.md  CHANGELOG.md  CREDITS.md  LICENSE  HEARTH-SPEC.md
docs/decisions/              Dated decision records.
.github/workflows/           compatibility.yml and integration-verification.yml.
```

## 6. What is bundled

Bundled: Setup (`/setup`) and Eidolon (`/eidolon`). Both are the author's own work,
copied into `skills/` from their repositories at pinned commits.

Nothing is pointed to. Nothing is bundled from third parties. Hearth does not name,
offer, or install any outside tool.

## 7. The flow

Novice door:

1. A greeting of three lines: what will happen, where, and that nothing else is installed.
2. For each skill that already exists at the destination: `replace` or `skip`, skip by default.
   Replace moves the old folder to `.claude/skills/.hearth-backups/<yyyyMMdd-HHmmss>/<name>`.
3. Each file is printed as it lands.
4. A closing line says what is installed and how to start: open Claude Code, type `/eidolon` or `/setup`.

Operator door:

1. Check that `node` exists and is version 22 or newer. If not, print where to get it and stop.
2. Ask for a project folder. Blank means user skills only.
3. Run a preview. If a skill exists, ask for `replace` and explain the backup.
4. Print `Proposed locations:` and every path, with the text to be written under it.
5. Require the literal `yes`. Apply the same plan that was previewed.
6. Print the verified file count, the backup receipt path, and the next step: restart
   Claude Code. Project hooks are active in the next session.

## 12. Safety and consent

- Hearth ships the author's two skills and no one else's code.
- The novice door writes only under `.claude/skills` in the chosen home folder.
- The operator door previews first, applies only the previewed plan, and refuses a
  plan whose targets changed after the preview.
- Replacement needs its own answer. Old files are kept with a receipt.
- A partial copy is never reported as a success.
- Hearth does not install Node, credentials, models, or any service.
- The EidolonLogo is the author's own art. No third-party imagery is used.
- A test is not a click-through on a real machine. The macOS doors are marked
  untested on hardware until a Mac run is recorded.

## 13. Engineering discipline

- No base64. Every file is readable text.
- Skill files are written UTF-8 without a BOM, with LF line endings. `welcome.ps1` is
  ASCII only, so Windows PowerShell 5.1 reads it correctly with no BOM.
- `skills/` is never edited by hand. It is regenerated with `node scripts/sync-bundles.mjs`
  from the commits pinned in `vendor-lock.json`.
- Verification uses a second signal. The PowerShell parser must report zero errors,
  `bash -n` must pass, the novice scripts must not contain the word node, and a real copy
  into a temp folder must match the source byte for byte.
- Tests write to the OS temp folder, never to a real user folder.

## 15. Scope

- Two doors: the novice door (PowerShell on Windows, bash on macOS) and the operator
  door (a Node terminal picker).
- Claude Code only.
- The three graphical installers (WPF window, macOS app, browser page) were removed on
  2026-10-13, along with Codex support and the optional tool cards.
- Out of scope, always: installing runtimes, editing user configuration beyond the
  previewed plan, and bundling third-party code.
