# Setup

A session-start skill for **Claude Code and Codex**. It establishes working
boundaries, checks claims before calling them done, and keeps a record of both
mistakes and useful patterns. Eidolon prepares the project; Setup prepares the
session inside it.

## Install

For Codex, clone into a skill directory named `setup`:

```sh
mkdir -p ~/.agents/skills
git clone https://github.com/eidolonofficial/eidolon-setup.git ~/.agents/skills/setup
```

For Claude Code, use `~/.claude/skills/setup` instead. For a project-local install,
use `.agents/skills/setup` or `.claude/skills/setup` inside that project.
On Windows PowerShell, use `$HOME` in place of `~` if needed.
An existing destination makes Git stop rather than overwrite your installation.
For a backed-up replacement or a combined install, use Hearth's installer.

Invoke `$setup` in Codex or `/setup` in Claude Code. Both use the same workflow.
The original workflow is preserved in `references/session-workflow.md`; the
small root skill supplies the host mapping before it is loaded.

## Opening questions

Which parts should run: memory, verification, or both? How should “go ahead” be
interpreted? How far should the agent run before checking in? Is this routine
work, a judgment call, or closeout? Existing answers are reused rather than asked
again. The optional interview records purpose, users, risks and observable done
criteria.

## Scope and limits

This is an instruction skill. Installing it does not automatically install a
memory server, lifecycle hooks, external tools, or a security boundary. Eidolon's
separate installer provides host hook wiring. Codex hooks require operator trust;
its ask-tier operations remain blocked for manual operator review.

The shared `.claude/session.yaml` path is retained so existing Eidolon projects
continue to work. Codex does not thereby inherit `.claude/settings.json`.

## Verification

```sh
node --test tests/*.test.mjs
```

These tests validate packaging and preservation, not live model behavior.
Check both clients with the Evals in `SKILL.md` before claiming an end-to-end pass.

Sources: OpenAI's official [skills](https://learn.chatgpt.com/docs/build-skills)
and [hooks](https://learn.chatgpt.com/docs/hooks), checked September 8, 2026.

## License

MIT. Created by Jonah Butterbaugh, alongside Claude. The original memory,
verification, and pairing skills remain credited in the preserved workflow.
