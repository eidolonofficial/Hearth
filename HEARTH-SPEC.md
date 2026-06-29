# Hearth: design spec

Date: 2026-06-08
Author: Jonah Butterbaugh (with Claude)
Status: draft for review. Nothing gets built until Jonah approves this document.

---

## 1. What Hearth is

Hearth is a plain-language front door for Claude Code. A person who is nervous
around computers can open it, follow a clear conversation, and walk away with a
working setup. It installs Jonah's own Claude skills, and for the outside
tools they might also want, it explains each one in plain language and offers to
install it from its official source, only on a clear yes.

The name Hearth is the home. Setup and Eidolon are the skills it lays down.
Everything else is a guest it introduces you to, never a thing it smuggles in.

## 2. Who it is for

Everyday people trying to run their own business, who are not confident with
computers and would freeze at "open PowerShell and paste this command." The
whole tool is built so that person never feels lost and never feels small.

## 3. The voice

Warm and human, confident and concrete, with a light wit. Precision without
coldness, personality without noise.

- **Warm at the core.** You are glad the person is here and you are on their
  side. Never cold, never corporate, never talking down.
- **Confident and concrete.** Say what Hearth does in vivid, specific terms, with
  strong verbs and real nouns. "Give Claude a memory and a backbone," not "a calm
  way to set up Claude."
- **A light, dry wit.** About one wink per screen. Charm, not a comedy act, used
  to settle nerves rather than show off.
- **Safety through clarity, not mood.** Reassurance comes from "you say yes to
  every step" and "close it anytime, it cannot harm your computer," stated plainly,
  not from soothing adjectives. The person should feel capable, not coddled.
- **Honest.** Technically true, never overpromising. The trust model (the five W's
  card, official-source-only installs) stays in plain view.
- Second person, present tense. Plain language, never baby talk. Every step ends
  by saying what just happened and what comes next.
- **Banned crutch-words** (as filler): quietly, calm, gently, soft, mindful,
  breathing, seamless, "no fuss," "out of the way," "take it slowly together."
- Em dashes, once banned outright, are now allowed sparingly, for rhythm.

## 4. Design pillars

1. You are in control. Every real action is an explicit yes, no, or later.
   Nothing happens unless you say so. You can close it anytime and it cannot
   harm your computer.
2. No black boxes. Each outside tool gets a plain five W's and How card before
   the yes or no. Nothing opaque, nothing you are asked to blindly trust. This
   is the opposite of the base64 file that started all this.
3. Instant win first. Jonah's own two skills install right away, no questions,
   so the person sees success in the first few seconds and relaxes.
4. Failure is never your fault. No red ERROR. Instead: "That did not go through.
   Here is the one thing to try, or skip it for now. You have not broken anything."
5. End on "you did it." A warm summary of what they now have and how to use it.
6. Real progress. During any real wait, a true progress indicator advances,
   labeled with the step it is on. No frozen window, no mystery spinner.
7. Flowers. Everyone whose tools Hearth stands on is credited, in their own words.

## 5. What ships

A single folder, `Hearth/`, with human file names:

```
Hearth/
  Start Here.cmd        double-clickable Windows launcher (novices cannot double-click
                        a .ps1). Fully readable. Opens the graphical window, and falls
                        back to the text installer if the window cannot run.
  gui/                  the Windows installer window (WPF), plus the shared install core
                        the window and the text installer both call.
  welcome.ps1           the text installer, used as the fallback (and by anyone who
                        prefers plain text).
  macos/
    Hearth.app          the double-clickable macOS installer window.
    Welcome.command     the macOS text installer, used as the fallback.
    READ ME FIRST.txt   the macOS version of the printable guide.
  READ ME FIRST.txt     the same five W's and How in printable plain text, for someone
                        who would rather read before clicking anything.
  CREDITS.md            the complete "with thanks" record. Every contributor, linked.
  assets/
    EidolonLogo.png     Jonah's logo (1536 x 1024). The graphical installer renders it
                        directly; the text installer shows an ASCII wordmark.
```

## 6. What gets installed, and what gets pointed to

This is the line that keeps Jonah out of trouble, so it is a hard rule.

**Bundled (Jonah's own work, installed directly into `~/.claude/skills`):**

- **Setup** (trigger `/setup`). Formerly "basecamp". The start-of-session skill:
  a few short questions up front, then memory, self-checking, and attunement to how
  you like to work. Four files (SKILL.md plus three references).
- **Eidolon** (trigger `/eidolon`, display name capitalized). The repo setup skill,
  bundled as the full harness: its skill, hooks, references, scripts, and docs.

**Pointed to (other people's tools, never bundled, installed from the official
source only on an explicit yes):**

- **graphify** by Safi Shamsi.
- **mempalace** (lead author igorls, Claude plugin published by milla-jovovich).
- **uv** by Astral and **Python** by the Python Software Foundation, the runtimes
  the two tools above need.

Hearth carries none of these tools' code. It explains them and points to where the
person can get them, first hand, from the makers.

## 7. The flow

1. **Greeting.** Warm welcome. "Here is what this is. You are safe. You can stop
   anytime. Nothing here can hurt your computer."
2. **Instant win.** Install Setup and Eidolon. Show a green check for each.
3. **Power-ups, one at a time.** For graphify, then mempalace:
   a. Show the five W's and How card (section 8).
   b. Ask: yes, no, or later.
   c. On yes, check for the runtime it needs (uv, Python). If missing, explain it
      the same kind way and show the one verified command to install it, then stop
      and let the person run it or approve it. Never silently install system tooling
      (check-and-instruct, section 11).
   d. With the runtime present, run the official install for the tool. A progress
      indicator advances during the wait.
   e. On no or later, move on. No pressure.
4. **Send-off.** Warm summary: what you now have, how to use it (type `/` in Claude
   Code to see your skills), where help lives.
5. **With thanks.** Show the credits gallery (section 10), and write `CREDITS.md`.

## 8. The five W's and How card

Shown before every yes-or-no on an outside tool. Short, honest, true.

```
<Tool name>
  What:  one plain sentence on what it does.
  Why:   why you might want it, in your-business terms.
  Who:   who made it, with a link to their work.
  Where: the official source it installs from.
  When:  when you would reach for it.
  How:   what will happen if you say yes (the exact command, named plainly).
Want this set up?   [ yes ]   [ no ]   [ maybe later ]
```

## 9. Real progress, not a frozen window

During any real wait (an install or download), a determinate progress indicator
advances and names the step it is on ("Installing graphify..."). In the graphical
installer it is an ember progress bar; in the text fallback it is a single status
line that updates in place. It moves only while real work is happening, and it says
what finished when the work is done. No frozen window, no mystery spinner.

## 10. Credits: the "with thanks" gallery

On the warm screen: the leads and notable hands, named with a short line and a link
to their own page. In `CREDITS.md`: the complete record, every contributor by linked
handle, leads marked, bots left out since they are not people. The big foundations
are credited by linking their own thank-you pages.

The gallery features Addy Osmani first:

- **Addy Osmani**, who built the agent-skills harness this pattern grows from. He
  sits at the top because the pattern starts with his work. A clear, warm card like
  the others, just placed first. His deep bio folds in when the research panel lands.

Then the makers of the tools Hearth points to. Verified material in hand (sources
double-checked, including a second gh query):

- **graphify**: Safi Shamsi leads (557 of ~570 commits), 66 contributors total.
  github.com/safishamsi/graphify, MIT, PyPI `graphifyy`. Sponsor: github.com/sponsors/safishamsi.
- **mempalace**: igorls leads (568 commits), then bensig, mvalentsev, milla-jovovich
  (the Claude plugin's author of record), jphein, and a tail to 80 people.
  github.com/MemPalace/mempalace, MIT.
- **uv / Astral**: github.com/astral-sh/uv. **Python / PSF**: python.org/psf, CPython's
  own `Misc/ACKS`. **Chroma**: github.com/chroma-core/chroma. **Hugging Face**:
  the transformers contributors page. **NumPy**: its own `THANKS.txt`.

Jonah's own card (his work, his name):

> **Jonah Butterbaugh**
> Creator of Hearth, Setup, and Eidolon
> github.com/gmrmk · linkedin.com/in/jonah-butterbaugh-2288033b1
>
> A Trust and Safety investigator who spends his days reading the patterns most
> people never notice. Account takeovers, supplier fraud, collusion rings, the
> quiet signals that something is wrong. More than a decade of that work across
> consumer banking, property and casualty insurance, and platform risk, now at
> Expedia Group, with hands-on KYC, AML, and OFAC reporting along the way.
>
> Hearth grows straight out of that instinct. The same care he brings to
> protecting people from fraud, he brings to protecting a nervous beginner from
> feeling lost. He taught himself SQL, Splunk, PowerShell, and a whole stack of
> agentic AI workflows the way he has learned everything else, by paying close
> attention and refusing to leave anyone behind. His roots reach back into design
> too, real hands-on craft, page layout and offset presses and bookbinding, which
> is where the eye for warmth and shape comes from.
>
> He is quick to say he just wired these tools together. That undersells it.
> Hearth is his idea of what technology should feel like: kindness shaped, consent
> first, and generous with credit to everyone who made the parts. He built it
> alongside Claude, the two of them working together.

His private contact details stay off the public page.

## 11. Dependency commands (verified, and how they run)

On an explicit yes, and only then. Sources verified against primary docs.

- **mempalace**: `uv tool install mempalace` (official README), then `mempalace init`.
  Register its memory server cleanly with `claude mcp add mempalace -- mempalace-mcp`
  (the supported CLI, so we never hand-edit the large `~/.claude.json`), pointing at
  the portable uv-installed shim rather than any one machine's Python path.
- **graphify**: `pip install graphifyy && graphify install` (official README; the
  package is `graphifyy`, the command stays `graphify`). On Windows, if the command
  is not found, the script guides adding the Python Scripts folder to PATH, or uses
  `uv tool install graphifyy` which handles PATH.
- **Runtimes (uv, Python)**: check-and-instruct only. If missing, Hearth shows the
  one verified install command and stops, so the person installs it themselves or
  approves it. Python's winget id is verified (`Python.Python.3.13`). uv's exact
  install command will be confirmed against astral.sh docs at build time before it
  ships. Hearth never silently installs system tooling.

## 12. Safety, consent, and "no trouble" posture (hard requirements)

- Ship only Jonah's own code. Everything else installs from its official source.
- Never bundle or copy a third-party tool. Never silently install runtimes.
- Refer to tools by name (allowed). Do not use their logos. Do not imply endorsement.
- Note each tool's license. All involved are permissive (MIT, Apache, BSD, PSF).
- Never silently edit shared config. mempalace's server is registered through the
  supported `claude mcp add` command, on consent.
- The EidolonLogo is Jonah's own art. No third-party imagery is used.

## 13. Engineering discipline

- **No base64.** Every skill file is visible plain text in the installer. This is
  the fix for the original safety flag.
- **Encoding, the lesson learned the hard way.** The PowerShell scripts are saved
  as UTF-8 with a BOM so Windows PowerShell 5.1 reads their non-ASCII characters
  correctly (the eidolon arrow bug). The console output encoding is set to UTF-8 at
  startup so the text installer's glyphs render. Installed skill files are written
  UTF-8 without BOM, LF line endings, to match Jonah's originals exactly.
- **Verification.** Every generated command and path is checked against an
  independent second signal before it ships. The build will syntax-parse each script,
  dry-run the installers into a sandbox, and diff the result against the source files,
  exactly as we did for the first three installers.

## 14. Renames applied at build time (not to live files yet)

- basecamp becomes Setup: folder `~/.claude/skills/basecamp` to `setup`, frontmatter
  `name` and `trigger` to `setup` and `/setup`, and the in-text mentions of "basecamp"
  updated to "Setup".
- eidolon display name capitalized to Eidolon. Trigger stays `/eidolon`.

## 15. Scope

- The graphical window now ships: a native double-click installer on Windows (WPF)
  and macOS (a small app), with the text installer kept as the fallback. Code
  signing and notarization are the next polish step, not a v1 blocker.
- Still out of scope: auto-installing runtimes, editing arbitrary user config, and
  bundling third-party code, ever.

## 16. Open items

- The deep warm bios from the research panel (Addy first) fold into the credits when
  they land. The verified facts above are enough to write the gallery either way.
- uv's exact install command verified at build time.
- The logo is staged locally. It will sit in `Hearth/assets/` in the final build.
```
