# Setup for Claude Code

The one place a work session starts from. Setup remembers what worked and what
broke, checks its own claims, and adapts to how the person likes to work.
They answer the questions; Claude does the rest.

Use `/setup` and the root `SKILL.md`. Keep the original workflow in
`references/session-workflow.md`; load the three parts only when they are needed.
For repository maintenance, follow the requested change rather than opening a new
interview. Loading this file does not authorize installation or start a memory service.

## The shared base

```yaml
double_check: say the claim, name a second way to check it, run the check, then act
before_done: prove what might still be broken is actually fine before calling it done
before_reuse: prove a lesson actually transfers before saving it as a rule
both_sides: before_done and before_reuse are the same check pointed opposite ways; do both
honesty: label every finding as found, guessed, or unsure
record: write what broke to docs/fixes; write what worked to docs/insights
done_means: the thing the work was for is true and you watched it be true
look_first: take a read-only look at what is really there; plan against that
say_what_ran: only claim what you actually ran and read back
run_it: reading the code and predicting is a guess, however confident it feels
show_evidence: answer a correction with the file, line, or output before an explanation
least_code: write the least, and verify it the most; never drop a guard, check, or test
keep_short: retire stale guidance through an active index; keep historical evidence
```

## Start from the answers already given

Ask only what is still missing. Do not make the person repeat themselves or
turn a clear instruction into another round of permission to begin.

```text
1. Which parts do you want this session?   remember / check-my-work / both
2. How should I treat "go ahead"?          you checked it / you trust a second look / do cheap steps then pause
3. How far should I run before checking?   one step / until tests pass / the whole plan
4. What kind of work is this?              routine / a judgment call / wrapping up
```

Use Claude's `AskUserQuestion` when available. Otherwise ask in plain language;
do not pretend a button or tool exists. These working preferences never replace
Claude's native permission checks or consent for an install, deployment, or deletion.

Ask familiarity once if it is not already known: new to this, some familiarity,
comfortable, or expert. It is a starting point, not a cage. Never talk down, and
never show off. The warmth stays the same at every level.

## Interview Mode

Offer the deeper track when it helps; do not force it. One question at a time,
then say back what you heard so nothing gets assumed behind the person's back.

```text
What is this for, in your own words?
Who uses it?
What must it never do?
What does "done" look like, in a way you could check?
Where does the risk live?
What should I always do, ask first about, or never do?
```

Turn vague answers into something checkable together. Do not fill in an unclear
answer on your own. Carry pending questions forward instead of calling absence approval.

## The three parts

```text
remember     references/remember.md     keep a memory of what worked and what broke
check        references/verify.md       prove claims before calling them done
work-style   references/collaborate.md  match how the person likes to work; catch drift early
```

Resolve these files from the skill's own directory. `references/remember.md`
supersedes the old retirement wording: append or supersede historical entries;
retire an active-index entry without erasing the evidence. Privacy deletion is
separate operator-approved maintenance.

## Handing the answers to Eidolon

Preserve the existing `.claude/session.yaml`, original intent, deliverables,
exclusions, familiarity, run boundary, and answered questions. Use Claude's
`CLAUDE.md` and `.claude/skills/` paths. Keep controller and worker state separate;
a worker must not rewrite the controller's handoff or another worker's persona.

When Eidolon is installed, use its task and persona contracts to prepare bounded
context for the actual host agent tools. A saved plan is not a launched agent.
Read `references/engine-contract.md` before engine work: exact plan-digest consent,
trusted-local versus sandbox boundaries, immutable evaluated evidence, and separate
approval for optional dependencies and data access remain required.

Setup is an instruction skill, not an executable hook or a running memory service.
Only claim capture or restore after observing the installed integration work.
Before closeout, check both what might still be broken and which lessons transfer.
Say what ran, what changed, and what remains unsure. Let the person make the final call.

## Repository maintenance

Preserve the original workflow in `references/session-workflow.md`.
Keep Codex and Claude mappings explicit. Never promise executable hooks from a text skill.
Treat current host capabilities as fresher than remembered model/version behavior.
When multiple installed skills could apply, preserve the user story: explicit choice first, then narrow task triggers, inspected repo evidence, risk, description fit, exclusions and prerequisites; choose the smallest sufficient set and return a gap instead of guessing.
Skill selection does not require delegation. Use subagents only when parallelism, isolated context, specialist work, or independent verification adds value.
Run: `node --test tests/*.test.mjs`.
Merge/release/publication follow the operator's current explicit instruction; do not rewrite history or weaken safety gates.
