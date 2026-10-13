# eidolon-setup — Engineering Doctrine

Read this before changing prose. This repo is a published Claude Code skill;
the prose IS the product. Where this conflicts with global instructions, this
file wins inside this repo.

## Stack

```yaml
kind:     claude-code skill (pure Markdown — no build, no tests, no runtime)
surface:  SKILL.md (the skill) · references/ (lazy-loaded parts) · README.md (public face)
publish:  github.com/eidolonofficial/eidolon-setup   # PUBLIC — everything committed is visible
upstream: # sources of record — Setup carries their intent, never replaces them
  remember:   github.com/gmrmk/dual-log-memory
  check:      github.com/gmrmk/trust-but-verify
  work-style: github.com/gmrmk/ai-pairing-playbook
```

## Commands

```yaml
audit: /skill-audit          # frontmatter, cross-pointers, hedge scan, README agreement, budgets
graph: graphify update .     # refresh graphify-out/graph.json (gitignored)
query: graphify query "<q>"  # ask the graph instead of re-reading files
test:  none                  # there is no code; /skill-audit is the gate
```

## Rules

- State the shared base once, in SKILL.md; references point to it, never restate it.
- Keep budgets: SKILL.md under 200 lines, each references file under 130; retire stale rules instead of piling on.
- Write in the plain-language register: no unexplained jargon, no em dashes, warm at every level.
- Label every claim found, guessed, or unsure, in the repo's prose and in work about it.
- Keep upstream source-of-record links cited; Setup is the plain-English face, not the record.
- Public repo: no machine paths, no secrets, no personal data in committed files.
- Run /skill-audit clean before calling any prose change done.
- Verify each claim against an independent second signal; a tool reading is a hypothesis until confirmed.
- Verify a tool CHANGED STATE (files, rows, tokens above zero), not that it reported success.
- Root-cause a failing tool before working around it; read its logs first.
- README and SKILL.md must agree; when they drift, SKILL.md is the record and README gets fixed.
- Orchestrate agents in controlled waves: define done-criteria and measure the baseline before any fan-out, verify each wave by state before the next. No headlong fan-out.
- Never force-push main. Never edit docs/fixes or docs/insights to shrink them (append-only).

## Memory

```yaml
fixes:    docs/fixes/FIX-YYYY-MM-DD-<slug>.md         # what broke and how it got fixed
insights: docs/insights/INSIGHT-YYYY-MM-DD-<slug>.md  # what worked and provably transfers
graph:    graphify-out/graph.json                     # structural; rebuild with graphify update .
prose:    mempalace wing eidolon_setup                # local wiring only — see hooks/README.md
```

## Pairing

- Partner notes (how to prompt on this project): docs/working-with-claude.md
- Lanes: routine work runs in batches with a check at the end; judgment calls go one step at a time with the result shown; wrapping up is drafted by Claude and signed off by the person.
