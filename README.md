# Hearth

A calm, plain-language front door for setting up Claude. Made for people running
their own business, not just people who are good with computers. You double-click
one file, and a warm window walks you through the rest, one gentle step at a time.

Nothing happens without your yes.

## How to start

- **Windows:** double-click **Start Here**, or run `welcome.ps1`.
- **macOS:** double-click **macos/Welcome.command**. The first time, macOS may ask
  you to confirm it; the macOS `READ ME FIRST.txt` has the one-time steps.

You do not need to type any commands or know anything technical. If you would
rather read first, open `READ ME FIRST.txt`.

## What it sets up

Two skills come with Hearth and go in right away:

- **Setup** is the calm start of a work session. It asks a few short questions so
  Claude works the way you like, quietly remembers what helped and what did not, and
  double-checks its own work before calling anything done. Setup is about the
  session: this visit, this stretch of work.
- **Eidolon** is about the project itself. It reads a whole project folder and sets
  up what Claude needs to understand it, and when you want to build or change
  something, it carries that work from a plain idea all the way to finished: it
  plans the work, builds it a careful piece at a time, checks it over for safety and
  mistakes, and only then puts it in place. It looks out for you the whole way, with
  built-in helpers that watch for the risky moves and a safety check that looks for
  ways a change could go wrong. Nothing important is deleted or shipped without a
  clear yes from you.

One makes the place ready, the other makes the visit go well. They can hand off to
each other, so they run as a pair.

The very first time you work, Setup also asks one gentle question, how familiar you
are with coding and engineering, so Claude can meet you where you are. There is no
wrong answer, and you can change it any time.

## What you can add, only if you want

After the quick win, Hearth offers a couple of optional helpers, one at a time. You
are free to skip either, now or forever. If you say yes, Hearth installs it from the
maker's own official source, in the open.

- **graphify**, which maps how the pieces of a project connect, so Claude can see
  the bigger picture. Made by Safi Shamsi.
- **mempalace**, which gives Claude a longer, searchable memory across sessions,
  like a tidy filing cabinet. Led by a maker who goes by igorls, with many hands
  helping.

If one needs a small piece of background software, Hearth shows you the one official
command and then stops, so you stay in charge.

## You are safe

- Nothing happens without your yes. Every real step pauses and asks.
- You can close the window at any moment, and it cannot harm your computer.
- Your own tools come included, in plain view, with nothing hidden. Any tool made by
  someone else is never carried inside Hearth; if you say yes to one, it is fetched
  fresh from the maker's own official source, and only then.

## What is in here

```
Start Here.cmd          double-click this on Windows
welcome.ps1             the Windows installer it runs
macos/Welcome.command   the macOS installer
READ ME FIRST.txt       the calm, printable guide (macos/ has a Mac version)
HEARTH-SPEC.md          the design spec
CREDITS.md              everyone whose work made Hearth possible, in their own words
assets/                 the logo
skills/setup/           the Setup skill
skills/eidolon/         the full Eidolon harness: its skill, hooks, references,
                        scripts, and its own spec and decision logs
```

## Credits

Hearth stands on the work of many generous people, each credited by name and link in
`CREDITS.md`, in their own words. Addy Osmani first and foremost, whose agent-skills
harness is the pattern this grows from. None of their code is copied into Hearth;
their tools are theirs, fetched from their own sources, with thanks.

Hearth and Eidolon were made by Jonah Butterbaugh, working alongside Claude.

## License

Hearth's installers and the bundled skills are MIT licensed (see
`skills/eidolon/LICENSE`). The third-party tools Hearth points to keep their own
licenses, named in `CREDITS.md`.

---

When you feel ready, double-click **Start Here**. We will take it slowly, together.
