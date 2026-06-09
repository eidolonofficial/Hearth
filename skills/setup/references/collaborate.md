# work-style

A few habits that make working with Claude smoother. This part is two-way: it
covers how you prompt and how Claude responds. It relies on the shared base in
SKILL.md.

## Six habits

The first four are the opening questions in SKILL.md. All six live here so the
intent is in one place.

1. Say which parts are on at the start. "Remember and check this session." A
   few seconds up front saves a mid-task correction.
2. Be clear what "go ahead" means. Three kinds: "I checked it, go"; "I trust a
   second look, go"; "do the cheap steps then stop before anything that changes
   state". The third is the safest default for any chain that ends in a write,
   a commit, or a delete.
3. Say where auto-mode stops. "Auto through the edits, stop before the commit."
   "Auto until tests pass, then check with me."
4. Send a whole thought at once. If it is long, say "three things coming, hold",
   and Claude waits until you signal done, instead of answering the first
   thought while you are still typing the fourth.
5. When you describe something visual, say what does NOT happen too. "It blinks
   three times then stops. No fourth blink." The thing that does not happen
   bounds the problem. Claude cannot see your screen.
6. For a risky ask (rebuild it, wipe it, "pull the lever"), expect Claude to
   prove it on a throwaway copy first, then show you the result and let you
   decide. Not blind obedience, not a flat refusal. A receipt.

## Match the work to the right amount of checking

```
routine        renames, simple refactors, deletions. Easy to verify with tests
               or types. Claude can run several steps and check in at the end.
judgment call  design choices, unclear specs, "one thing or two?". Needs
               reading to verify. Claude does one task, then shows you the result.
wrapping up    summaries, sign-off, commit messages. Claude is weakest here,
               because polished writing feels finished even when it is wrong.
               You make the final call; Claude drafts for you to approve.
```

Name which one you are in at the start, so it can be corrected before things
drift. When wrapping up matters, a fresh check helps: open a new session, give
it only the change and the question "what is overclaimed here?", with none of
the momentum to defend the work.

## The quick look

When Claude shows you a result for a judgment call, skim it for the gist: does
the framing match the work, does the test count make sense, is there a sentence
you disagree with. A fast pass is enough. If something looks off, redirect. If
not, go.

## Watch words

When Claude writes one of these, the work needs a second look. They are excuses
dressed up as reasons:

- "combined the review since the change is small"
- "covered by the new test" (when nothing actually asserts it)
- "leaving it in for now"
- "pre-existing" used on a problem it just introduced
- "shipped" or "proves" while wrapping up
- "run these three at once, it is faster" (state-changing commands in parallel
  without first checking there is enough memory and no file locks)
- "let me rebuild the whole thing" before cheaper causes have been ruled out

And the same for how things are said, not just what is claimed:

- a table or a multi-part report for a question that wanted a sentence
- explaining the approach before giving the answer
- re-explaining something you already established
- "for completeness" or "to be safe" used as padding

When you spot one, just point at it ("you said X, let me look"). If Claude
catches itself about to write one, it should stop and say so.

## When something goes wrong, do not just add a rule

Order of what to reach for, cheapest first:

1. Name the shape (add a watch word, one line).
2. Add a structural check (a hook or a script that catches it automatically).
3. Add a fresh check for that kind of work.
4. Last resort: a short note here, two sentences at most.

A handful of watch words beats a hundred rules. Adding rules is not a win; each
one is a tax on the moment the doc is read. Retire stale ones as new ones land.

## How Claude should adjust to you

```
short and direct ("just do it")      one path, act, no preamble
frustrated (caps, "stop", swearing)   drop the ceremony: plain words, one move, no tables
"what do you mean" / repeated "?"     you have lost them: simpler, one path
"explore" / "what do you think"       now options and depth are welcome
```

Read the tone and match it. You should not have to escalate to get a plain
answer.

## When a correction has time to land

A sharp "no, try again" fixes the moment. A correction with the reason behind
it fixes the next ten moments. When there is time, give the reason.

## Source

This is the plain-English version of your ai-pairing-playbook skill, which
stays the source of record (github.com/gmrmk/ai-pairing-playbook). Internal
names: the six habits are your 6 prompt-shifts, the three kinds of work are your
work-lanes, and the watch words are your drift-tell catalog.
