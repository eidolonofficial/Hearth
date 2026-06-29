# Hearth

Hearth is the front door to a smarter Claude. Double-click one file and it sets
everything up for you, asking before every step. Built for people who run a
business, not a server room.

No terminal. No jargon. You say yes to every step.

## How to start

- **Windows:** double-click **Start Here**. A window opens and walks you through
  the rest. No PowerShell, no typing.
- **macOS:** double-click **macos/Hearth**. The first time, macOS may ask you to
  confirm it once; `macos/READ ME FIRST.txt` has the one step.

Would rather read before clicking anything? Open `READ ME FIRST.txt`. It says
the same thing in plain text.

## What it sets up

Two skills come with Hearth and go in right away:

- **Setup** gets a work session off to a strong start. It asks a few short
  questions so Claude works the way you like, then it remembers what worked,
  checks its own work before it says "done," and learns how you like to work.
  Setup is about the session: this visit, this stretch of work.
- **Eidolon** is about the project itself. Point it at a project folder and it
  reads the whole thing, works out what Claude needs to understand it, and then
  carries any change from a plain idea all the way to finished: it plans the
  work, builds it one careful piece at a time, checks it for safety and
  mistakes, and only then puts it in place. Built-in guards watch for the risky
  moves, and a safety review hunts for ways a change could go wrong. Nothing
  important ships or gets deleted without a clear yes from you.

One gets the place ready; the other makes the visit go well. They hand off to
each other, so they work as a pair.

The first time you work, Setup asks one thing: how familiar you are with coding
and engineering, so Claude can meet you where you are. There is no wrong answer,
and you can change it any time.

## What you can add, only if you want

After the first win, Hearth offers two optional helpers, one at a time. Skip
either, now or forever. Say yes and Hearth installs it from the maker's own
official source, out in the open:

- **graphify** maps how the pieces of a project connect, so Claude can see the
  whole shape of your code. Made by Safi Shamsi.
- **mempalace** gives Claude a longer, searchable memory across sessions, like a
  filing cabinet that actually stays organized. Led by a maker who goes by
  igorls, with many hands helping.

If one needs a small piece of background software, Hearth shows you the one
official command and stops there, so you stay in charge.

## You are safe

- Nothing happens without your yes. Every real step pauses and asks.
- Close the window whenever you want. It cannot harm your computer.
- Your own tools ship inside, in plain view. Anyone else's tool is never carried
  inside Hearth; say yes to one and it is fetched fresh from the maker's own
  official source, and only then.

## What is in here

```
Start Here.cmd          double-click this on Windows
gui/                    the Windows installer window
welcome.ps1             the text installer Windows falls back to
macos/Hearth.app        double-click this on macOS
macos/Welcome.command   the text installer macOS falls back to
READ ME FIRST.txt       the printable guide (macos/ has a Mac version)
HEARTH-SPEC.md          the design spec
CREDITS.md              everyone whose work made Hearth possible, in their words
assets/                 the logo
skills/setup/           the Setup skill
skills/eidolon/         the full Eidolon harness: its skill, hooks, references,
                        scripts, and its own spec and decision logs
```

## Credits

Hearth stands on the work of many generous people, each credited by name and
link in `CREDITS.md`, in their own words. Addy Osmani first of all, whose
agent-skills harness is the pattern this grows from. None of their code is
copied into Hearth; their tools stay theirs, fetched from their own sources,
with thanks.

Hearth and Eidolon were made by Jonah Butterbaugh, working alongside Claude.

## License

Hearth's installers and the bundled skills are MIT licensed (see
`skills/eidolon/LICENSE`). The third-party tools Hearth points to keep their own
licenses, named in `CREDITS.md`.

---

When you're ready, double-click **Start Here**. The first win takes about a
minute.
