---
name: setup
description: Begin a Claude Code or Codex work session with explicit working boundaries, evidence checks, and memory of what worked and what broke. Use at the start of sustained project work or when the user asks to improve session continuity.
---

# Setup for Claude Code and Codex

1. Read `references/session-workflow.md` from this skill's directory. It preserves
   the original session workflow, questions, interview, verification discipline,
   and three reference modules. Apply the host mapping below before executing it.
2. Use the current conversation to avoid repeating questions already answered.
   Do not reopen approved scope merely because this skill was loaded.
3. In Claude Code, use `/setup`, `CLAUDE.md` and `.claude/skills`. Use native
   question controls when available. Keep the original consent checkpoints.
4. In Codex, use `$setup`, `AGENTS.md` and `.agents/skills`. Ask using an available
   question tool or a plain conversation question and wait for the answer. Never
   invent `AskUserQuestion`, a `Task` tool, or Claude-only UI controls.
5. Keep the shared handoff at `.claude/session.yaml` for compatibility with existing
   Eidolon projects. The directory is legacy shared state, not a claim that Codex
   reads Claude settings. Never move or overwrite an existing session handoff
   without reviewing its current contents.
6. Preserve `docs/fixes`, `docs/insights`, the uncertainty/synthesis protocols,
   familiarity calibration, least-code rule, run boundaries and interview intent.
   Reference modules resolve from this skill's root, not the target project's root.
7. Setup is an instruction skill, not a running memory service or a security hook.
   Do not claim automatic restore, capture, blocking, or external memory access
   unless the corresponding installed integration has been observed working.
8. Use Eidolon's host installer when executable hooks are needed. In Codex, the
   operator must review and trust the project and hooks via `/hooks`. Never
   bypass hook trust. An Eidolon ask-tier hook remains blocked for manual review;
   a conversational yes is not a machine-verifiable bypass receipt.
9. Keep model/API credentials out of generated handoff files, logs and commits.
   External tools and services still require the user's separate installation
   approval. Neither this skill nor loading it authorizes deployments or deletion.
10. Before closeout, report what actually ran, what remains unverified, and the
    concrete evidence behind each completion claim. Let the user make the final call.

## Evals

- Codex session: `$setup` loads; instructions use AGENTS.md and do not call a
  nonexistent Claude question tool. The four working-boundary questions remain.
- Claude session: `/setup` retains the original workflow and references.
- Existing session handoff: preserve prior answers and do not repeat them.
- No memory backend installed: record explicit local notes, not a false capture claim.
- No trusted Codex hooks: report this limitation instead of promising enforcement.
