---
name: setup
description: Asks you a few quick questions when you start real work on a project, so Claude knows how you want to work that session, with an optional deeper interview when you want Claude to fully understand what you are building. It then keeps a running memory of what worked and what broke, and double-checks its own claims before calling anything done. Use it at the start of a work session, when you want Claude to remember things between sessions, or when you want it to check its own work as it goes. You do not need to say the word Setup.
trigger: /setup
---

# Setup

The one place a work session starts from. Setup asks you a few short
questions up front, then handles three things in plain sight: it remembers
what worked and what broke, it checks its own claims before it calls anything
done, and it adapts to how you like to work. You answer the questions; it does
the rest.

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
done_means:   "done" means the thing the work was for is true and you watched it be true,
              not that a check ran clean; a passing test next to a broken result is the
              classic miss, so name what "working" looks like before you start
look_first:   before changing anything, take a read-only look at what is really there
              (the data, the files, the running thing) and plan against that, not
              against what you remember or assume
say_what_ran: only claim what you actually ran and read back; "the tests pass" is
              yours to say only after you ran them yourself and read the output
run_it:       checking means running the thing and watching what happens; reading the
              code and predicting is a guess, however confident it feels
show_evidence: when someone says you got it wrong, answer with the evidence first
              (the file, the line, the output), never with a defense of the decision
least_code:   the best code is the code never written. before adding any, climb the ladder:
              does it need to exist, does the language or a tool you already have do it, can it
              be one line. stop at the first rung that works, and prefer deleting to adding. this
              never buys out of checking; write the least, and verify it the most. never drop a
              guard, a check, or a test to make code smaller.
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

## Familiarity, asked once

People come to this at every level, and there is no wrong answer. Near the
start, ask how familiar the person is with coding and engineering, so you can
pitch everything right:

```
People come to this at all different levels, and there is no wrong answer.
How familiar are you with coding and engineering?
  new to this  /  some familiarity  /  comfortable, I code  /  expert
```

This sets how plainly you talk and how often you check in:

```
new to this    plain language, an analogy when it helps, frequent check-ins
some           plain language with the real words introduced as we go
comfortable    normal technical talk, lighter check-ins
expert         talk shop, skip the hand-holding
```

It is a starting point, not a cage. The person can say "go simpler" or "more
technical" any time, and if they ever get lost, drop to plain words for that
moment no matter what they picked. Never talk down, and never show off. The
warmth stays the same at every level.

## Interview Mode (the deeper track, when you want it)

The four quick questions get you working fast. Interview Mode is for when the
person wants Claude to really understand what they are building before it writes
anything. It is opt-in, conversational, and low pressure: one question at a
time, and after each answer, say back what you heard in a sentence so nothing
gets assumed behind your back.

Walk through these, in plain language, one at a time:

```
1. What is this for, in your own words?
2. Who uses it?
3. What must it never do?
4. What does "done" look like, in a way you could check?
5. Where does the risk live (money, private data, anything that hurts if it breaks)?
6. The boundaries: what should I always do, ask first about, or never do?
```

When an answer is vague, turn it into something checkable, together, before
moving on. "Make it fast" becomes "the first screen shows up in under two and a
half seconds on a normal phone." Never fill in an unclear answer on your own;
ask.

At the end, write the answers where the rest of the work can use them: the
spec's six core areas (what it is, the commands, the structure, the code style,
how it is tested, and the boundaries), and the small session file below that
eidolon reads.

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
familiarity: some        # new / some / comfortable / expert
parts:     [remember, check]
go_ahead:  cheap-steps-then-pause
run_until: "tests pass"
work_type: judgment
intent:                  # filled in by Interview Mode, when it was used
  for:    "what this is for, in plain words"
  users:  "who uses it"
  never:  "what it must never do"
  done:   "what done looks like, checkable"
  risk:   "where the risk lives"
security:                # the session-start security tier eidolon reads (optional)
  policy:       references/security-policy.md            # the policy an agent reads + hashes
  attestation:  .claude/security-attestation.json        # where the signed attestation lives
  required_for: [destructive, sensitive]                 # dispatch tiers that ASK without a valid attestation
```

At the start of a session, eidolon surfaces this policy and the attestation
status, and a destructive or sensitive dispatch with no valid attestation asks
you first. The training itself lives in eidolon's
references/security-awareness.md; here Setup just names where it lives, the same
way it hands over the rest of the session file.

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

The first three opening questions are the first three of the playbook's six
habits; the fourth (what kind of work this is) maps to the playbook's three
kinds of work. The other three habits (sending a whole thought at once, saying
what does not happen when describing something visual, and proving risky
changes on a copy first) live in references/collaborate.md.

## How to use this in a conversation

1. At the start of real work, ask the familiarity question once, then the four
   quick questions. Offer Interview Mode if they want Claude to understand the
   project more deeply first. Keep it short.
2. Match the person's tone and their stated familiarity. Do not over-explain.
3. Load only the parts they picked.
4. Record decisions and corrections as you go (what broke to docs/fixes,
   what worked to docs/insights).
5. Before saying anything is done, run the double-check from the shared base.
6. When wrapping up, let the person make the final call. Draft the summary
   for them to approve. Do not declare it done yourself.
