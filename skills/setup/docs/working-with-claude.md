# Working with Claude — partner notes

A quick reference for prompting Claude effectively on this project.
Reciprocal: Claude is keeping its own learnings in `docs/insights/`.
If something here feels wrong in practice, adapt it. This is a
working document, not commandments.

This repo is prose, not code. The examples below are tuned for
editing a published skill, where the product is the words themselves.

---

## The 6 shifts

### 1. Pre-name the active doctrine

Before substantive work, name which doctrines should be active.
Costs four seconds. Saves a mid-flight catch-and-correct.

Instead of: *"Let's tighten up the verify reference."*

Say: *"verify.md edit kickoff — run /skill-audit after, keep the
budget, references point at the shared base instead of restating it."*

Why it works: this repo has standing rules (budgets, register, the
no-restatement rule). Naming the relevant ones upfront preloads them.
Without naming, Claude relies on drift-prone defaults.

---

### 2. Three flavors of "proceed"

One word, three different states. Disambiguate to prevent
over-authorization on downstream state-mutating steps.

- **"Verified locally, proceed."** You read the diff yourself. Say what you checked.
- **"Trust the second opinion, proceed."** You delegated the check
  (the verifier agent, a research agent). Claude knows which risk
  surface remains unowned.
- **"Proceed with prep, yield before state-change."** Cheap steps
  auto. The commit, the push to the public repo, anything visible
  to cloners requires a manual confirm.

The third option is the safest default here, because every push is
instantly public.

---

### 3. Name auto-mode boundaries

Auto-mode is fuel and danger in the same can. Perfect for executing
a known-good plan. Dangerous at ambiguity points. Narrate the boundary.

*"Auto through the prose edits and the audit. Manual confirm on the commit."*

*"Auto until /skill-audit passes. Then yield."*

---

### 4. Stage multi-part thoughts

Rapid-fire interrupts cause Claude to start responding to thought #1
before thought #4 lands. Tokens wasted. Context drifts. Two options:

- Type the whole thought in one send.
- Lead with *"three thoughts coming, hold"* and Claude waits
  silently until you signal complete.

Either pattern works. Mixed-mode (interrupt every sentence) is the
one to avoid.

---

### 5. Make reports diagnostic

When you report a problem with the prose, include what it should
NOT read like, not just what it should. Claude cannot hear your ear.

Instead of: *"The remember section feels off."*

Say: *"The remember section drifted formal — 'utilize', 'leverage'.
It should read like the rest: short words, no jargon. The verify
section next to it is the register to match."*

The "what it should not be" half bounds the problem. With the second
phrasing, Claude fixes the register. With the first, Claude guesses.

---

### 6. Direct risky actions, expect a proof-on-a-copy

For a high-blast-radius ask (rewrite SKILL.md, restructure the
references), expect Claude to prove the change in isolation first:
a draft shown in chat or a side file, then the diff, then you decide.
You should get a receipt, not blind compliance and not a flat refusal.

*"Restructure the references — but show me the new shape before
touching the real files."*

---

## Bonus: texture beats brevity for corrections

When you push back, the *why* multiplies the lesson's reach.

Instead of: *"No. Try again."*

Say: *"Too long — every line in this repo is a cost the next reader
pays. Cut it to the one sentence that earns its place."*

Sharp corrections fix the immediate turn. Textured corrections fix
the next ten turns. When time is short, sharp is fine.

---

## Reciprocal

Claude is building `docs/insights/` in parallel, capturing register,
structure, and process learnings as they emerge. The dual log
(`docs/fixes/` for regret, `docs/insights/` for delight) is one
brain, both hemispheres.

Both halves share the same discipline: **trust, but verify — always**.
Claude routes every uncertain claim through the verification funnel
before acting on it. The 6 shifts above are the user-side
counterpart. Together they make the catch-and-correct loop cheap
enough that drift gets caught early instead of compounding.

You're adapting how you prompt. Claude is adapting what it remembers.
Both are required.

---

*Last updated: 2026-06-10. Adapt as the project evolves.*
