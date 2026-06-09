# check

Prove a claim before calling it done. This is the shared base's double-check.
Do not restate the double-check steps as a separate thing; this file is how to
run them well.

## The move

For anything load-bearing:

1. Say the claim out loud (in chat, the doc, or the commit).
2. Name a second, independent way to check it. Not a re-run of the same thing.
   Something that could actually prove it wrong.
3. Decide what counts as pass or fail before you run it.
4. Run it, keep the result, and act on what you found.

This is the before_done check from the shared base (your uncertainty protocol).
A good check has three properties: it is independent of the first signal, it
rests on a real and current source, and you set pass or fail before running it.
Hedged words ("should work", "probably", "I think") are the tell that a claim
has not been checked yet. Either drop the hedge because you checked, or go check.

## No exemptions

The check applies to everything, including rules this skill itself wrote. A
claim you cannot test with an independent, real, pass-or-fail signal does not
ship as a finding. Drop it, or mark it unsure and hand it to a person.

## One at a time, root cause first

Surface findings one at a time, not as a wall. For a serious one, work out the
likely root cause and show it before offering any fix.

## Label honestly

```
found    you saw direct evidence
guessed  a reasonable inference, not yet confirmed
unsure   flagged for a person to confirm
```

A finding labeled unsure is not treated as done until it is resolved or the
person waives it.

## A checklist for code

When checking a code change, these are the usual places trouble hides:

```
security    leaked secrets, missing access checks, unsafe input handling
privacy     personal data in logs or in plain text
licenses    a dependency whose license clashes with the project
access      anyone can reach something only some people should
supply      unpinned versions, install scripts pulled from the internet
operations  crashes that leak internal details, no rate limit on a login
```

Cite a real, current source when you flag one of these (for example the OWASP
list for security, WCAG for accessibility). Do not invent a source.

## The other half

before_done has a mirror: before_reuse, in remember.md. One proves a worry is
handled before you call something done; the other proves a good pattern
transfers before you save it as a rule. Same check, opposite directions. Run
both.

## Source

This is the plain-English version of your trust-but-verify skill, which stays
the source of record (github.com/gmrmk/trust-but-verify). Internal name: the
before_done check is your uncertainty protocol.
