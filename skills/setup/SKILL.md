---
name: setup
description: Begin a Claude Code work session with explicit working boundaries, evidence checks, memory of what worked and what broke, and deliberate selection of installed skills. Use at the start of sustained project work or when the user asks to improve session continuity.
---

# Setup for Claude Code

1. Read `references/session-workflow.md` from this skill's directory. It holds the
   session workflow, the verification discipline and the three reference modules.
   Resolve `references/` from this skill's root, not the target project's root.
2. Reuse answers already given in the conversation or in `.claude/session.yaml`.
   Do not reopen approved scope merely because this skill was loaded.

## 1. The brain dump (at the start of real work, before the four questions)

Read `references/interview.md` first. It owns the wording, the schema and the chips.

```yaml
offer: "Tell me about it the way you would tell a coworker. Rant, infodump, jump around. I will sort it."
chips: [Start talking, Ask me questions instead, Skip]
on_start_talking: extract into the schema in references/interview.md; leave a field null when the dump did not say
reflect_back: under 10 lines, one line per filled field, in the person's words
reflect_chips: ["That's it", Fix something, Add more]
```

Rule: never re-ask a field the dump filled; a null field becomes a chip question.
Rule: "Fix something" asks one chip question per wrong line; "Add more" returns to the dump and re-extracts.
Rule: "Skip" or "Ask me questions instead" goes straight to the four questions.

## 2. The four opening questions and familiarity

Ask only what is still missing, as `AskUserQuestion` chips with the recommended option
first, exactly as `references/interview.md` lists them. Without that tool, ask in plain
text with lettered options and wait for the answer. Do not invent controls.

```yaml
questions:
  - "Which parts do you want this session?"
  - "How should I treat your go ahead?"
  - "How far should I run before checking?"
  - "What kind of work is this?"
then: familiarity, asked once
```

## 3. Rules that always apply

Rule: keep the handoff at `.claude/session.yaml`; never move or overwrite an existing one without reading it first.
Rule: preserve `docs/fixes`, `docs/insights`, the uncertainty and synthesis protocols, familiarity calibration, the least-code rule, run boundaries and interview intent.
Rule: retire guidance through an active index, never by deleting evidence; `references/remember.md` resolves the old retirement wording in the workflow. Privacy deletion is separate, operator-approved maintenance.
Rule: Setup is an instruction skill, not a running memory service or a security hook. Claim no automatic restore, capture or blocking unless the installed integration was observed working.
Rule: use Eidolon's installer when hooks are needed. Never bypass Claude Code's hook trust or permission checks.
Rule: keep model and API credentials out of handoff files, logs and commits. Installs, deployments and deletion need the person's separate approval; loading this skill authorizes none of them.

## 4. Choose skills

Before substantive work, inventory the installed skills when several could apply.
Order of evidence: explicit user choice first, then narrow trigger phrases, inspected
repository signals, risk signals, description fit, exclusions and prerequisites. Pick
the smallest sufficient non-conflicting set. Generic words such as `api`, `auth`, `git`,
`test`, `json`, `react` or `python` never justify a skill by themselves. If no candidate
clearly fits, record a gap and work directly rather than guess.

Skill selection does not imply delegation. Work directly on simple sequential tasks;
use subagents when parallelism, isolated context, specialist work, or independent
verification creates real value. Never pin behavior to a remembered Claude point
release; resolve capabilities from the current session.

## 5. Closeout

Report what actually ran, what remains unverified, which skills were used and why,
and the evidence behind each completion claim. Let the person make the final call.

## Evals

- `/setup` at the start of real work: the brain dump is offered first, with its three chips.
- Dump filled `outcome` and `done_signal`: neither is asked again.
- Existing `.claude/session.yaml`: prior answers are reused, not repeated.
- Multiple installed skills: the narrowest sufficient set is chosen and explained.
- Generic token only (`auth`, `react`): no specialist skill is forced.
- No matching skill: a gap is recorded, not a fabricated skill.
- No memory backend installed: explicit local notes, no false capture claim.
