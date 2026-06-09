---
name: setup
description: Asks you a few quick questions when you start real work on a project, so Claude knows how you want to work that session. It then keeps a running memory of what worked and what broke, and double-checks its own claims before calling anything done. Use it at the start of a work session, when you want Claude to remember things between sessions, or when you want it to check its own work as it goes. You do not need to say the word Setup.
trigger: /setup
---

# Setup

The one place a work session starts from. Setup asks you a few short
questions up front, then runs three things underneath: it remembers what
happens, it checks its own claims, and it adjusts to how you like to work.
You only see the questions. The rest runs quietly.

## The shared base

These rules are stated once, here. The three parts below all rely on them
and never repeat them.

```yaml
double_check: say the claim, name a second way to check it, run the check, then act
before_done:  prove what might still be broken is actually fine before calling it done
before_reuse: prove a lesson actually transfers before saving it as a rule
both_sides:   before_done and before_reuse are the same check pointed opposite ways; do both
honesty:      label every finding as found, guessed, or unsure
keep_short:   a rules doc stops getting read once it gets too long; retire stale rules instead of piling on
record:       write what broke to docs/fixes, write what worked to docs/insights
```

Your names for these: before_done is your "uncertainty protocol", before_reuse
is your "synthesis protocol". They are kept as one pair on purpose, because they
only work together. Checking what broke without also checking that good patterns
actually transfer is only half the discipline.

## When it runs: the opening questions

At the start of real work, ask a few short questions. Use tap-to-answer
buttons, not a wall of text. Match the person's tone: if they are short and
direct, give one path and act; if they say "let's explore", offer options.

```
1. Which parts do you want this session?   remember / check-my-work / both
2. How should I treat "go ahead"?          you checked it / you trust a second look / do cheap steps then pause
3. How far should I run before checking?   one step / until tests pass / the whole plan
4. What kind of work is this?              routine / a judgment call / wrapping up
```

The answers are not thrown away. They set what loads and how careful to be,
and the work itself gets recorded (see "the shared base").

## The three parts (each loads only when needed)

```
remember     references/remember.md     keep a memory of what worked and what broke
check        references/verify.md       prove claims before calling them done
work-style   references/collaborate.md  match how you like to work, catch drift early
```

Read a part's file only when that part is in use. This keeps the main file
short enough to actually get read at the moment a decision is made.

## Handing the answers to eidolon

If the project also uses eidolon (the setup tool), write the answers to a
small file it can read. eidolon does not need to know how the answers were
collected.

```yaml
# .claude/session.yaml
parts:     [remember, check]
go_ahead:  cheap-steps-then-pause
run_until: "tests pass"
work_type: judgment
```

## Keeping context across long sessions

When a session runs long, Claude's working context can get trimmed. Two
small hooks prevent losing your place:

```
session-save       before context is trimmed   save a short note of where things stand
session-restore    when a session starts        bring that note back
```

## Where this comes from

Setup does not replace your three skills. It carries their intent in one
place. Each part is the plain-English version of one skill, and the original
stays the source of record:

```
remember     dual-log-memory       github.com/gmrmk/dual-log-memory
check        trust-but-verify      github.com/gmrmk/trust-but-verify
work-style   ai-pairing-playbook   github.com/gmrmk/ai-pairing-playbook
```

The opening questions are the first four of the playbook's six habits. The
other two (sending a whole thought at once, and proving risky changes on a copy
first) live in references/collaborate.md.

## How to use this in a conversation

1. At the start of real work, ask the four questions above. Keep it short.
2. Match the person's tone. Do not over-explain.
3. Load only the parts they picked.
4. Record decisions and corrections as you go (what broke to docs/fixes,
   what worked to docs/insights).
5. Before saying anything is done, run the double-check from the shared base.
6. When wrapping up, let the person make the final call. Draft the summary
   for them to approve. Do not declare it done yourself.
