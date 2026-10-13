# Setup

A session-start skill for Claude Code. It opens real work with a brain dump, asks the few questions still missing, keeps a memory of what worked and what broke, and double-checks its own claims before calling anything done.

Setup is the quiet beginning of the Eidolon family. Hearth installs the system, Setup prepares the worktable, Eidolon does the deeper repository-aware work.

## Install

```sh
git clone https://github.com/eidolonofficial/eidolon-setup.git ~/.claude/skills/setup
```

Or copy the folder to `~/.claude/skills/setup`, or to `.claude/skills/setup` inside one project. On Windows PowerShell, use `$HOME` in place of `~`. Then run `/setup` in Claude Code.

## What it asks

```yaml
brain_dump: "Tell me about it the way you would tell a coworker. Rant, infodump, jump around. I will sort it."
chips: [Start talking, Ask me questions instead, Skip]
reflect_back: under 10 lines, then [That's it, Fix something, Add more]
then: four chip questions (parts, "go ahead", how far, kind of work) and familiarity
rule: a field the dump filled is never asked again
```

The wording and schema live in [`references/interview.md`](references/interview.md), a vendored copy of Eidolon's question bank so Setup installs alone.

## Where answers land

```yaml
session_answers: .claude/session.yaml
what_broke: docs/fixes
what_worked: docs/insights
workflow: references/session-workflow.md
```

## Skill selection

Setup picks the smallest sufficient set of installed skills: explicit user choice first, then narrow triggers, repository evidence, risk, description fit, exclusions and prerequisites. With no clear fit it records a gap and works directly. Selecting a skill is not delegation.

## Limits

Setup is an instruction skill. It installs no memory server, hook or security service; Eidolon's installer provides hooks where needed.

## Verify

```sh
node --test tests/*.test.mjs
```

The tests check packaging and instruction contracts, not live model behavior.

## License

MIT. Created by Jonah Butterbaugh, alongside Claude. The original memory, verification and pairing skills remain credited in the preserved workflow.
