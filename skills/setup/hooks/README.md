# Hooks

Governance gates for this repo, wired in `.claude/settings.json`. Each gate
exists in two forms: `.mjs` (Node, the wired default) and `.ps1` (PowerShell
mirror for machines without Node — swap the command in settings.json to
`powershell -ExecutionPolicy Bypass -File hooks/<name>.ps1`).

| Hook | Trigger | Enforcement |
|---|---|---|
| protected-paths-guard | PreToolUse(Bash) | BLOCK (exit 2) rm/del/git-rm aimed at LICENSE, SKILL.md, references/, .git |
| commit-quality-guard | PreToolUse(Bash) | BLOCK (exit 2) `--no-verify`/`--no-gpg-sign` commits and any force-push |
| doc-integrity-guard | PreToolUse(Write\|Edit) | BLOCK (exit 2) shrinking an entry under docs/fixes/ or docs/insights/ (append-only) |
| hedge-guard | PreToolUse(Write\|Edit) | ADVISORY — injects context when a hedged phrase ships into published prose; never blocks |
| post-commit-capture | PostToolUse(Bash), local wiring only | ADVISORY — fires graphify + mempalace capture after a `git commit`; lives in `.claude/settings.local.json` because the capture tools are machine-specific |

Design notes, stated once:

- Block = stderr + exit 2. Advisory = stdout JSON with
  `hookSpecificOutput.additionalContext` + exit 0. No other channels.
- hedge-guard is advisory because the repo's own doctrine
  (references/collaborate.md) says a watch word earns a second look, not a
  ban — and two of the published files legitimately enumerate watch words.
- Paths in `.claude/settings.json` are relative to the repo root. Start
  Claude Code at the repo root (the normal case) for the gates to fire.
- A gate is changed in the open, in its own commit, never bypassed. The
  commit-quality-guard enforces this for everyone, including the gates'
  author.
