# Testing the Hearth installers on real machines

The text installers and the file-copy core are verified on Linux (syntax + a
sandbox copy). The graphical windows draw native UI, so they have to be tried on
a real Windows and a real Mac. Here is the click-through to confirm before ship.

## Windows (WPF window)

1. Double-click **Start Here**. The window opens with no black console flash.
2. The Hearth logo renders top-left. Try display scaling 100% / 150% / 200%; it
   stays crisp.
3. **Begin** -> the two-skills screen -> **Set up my skills**: the ember progress
   bar fills as files copy, then "Done. Setup and Eidolon are in place (N files)."
4. **graphify** card -> **Yes**. With Python present it installs and reports ready;
   with Python absent it shows the one `winget` command and a Skip button (no
   silent install). Test both by temporarily removing Python from PATH.
5. **mempalace** card -> the three install paths (Yes / No thanks / Maybe later).
6. "You did it." lists what went in; **Close** closes.
7. Fallback: on a box without WPF (Server Core), or if you click **Use text
   version**, it drops to `welcome.ps1` in a normal console and behaves the same.
8. Confirm the copy is byte-faithful: the installed files under
   `~/.claude/skills` match `skills/` (LF endings, no BOM).

## macOS (Hearth.app)

1. First launch: right-click **Hearth** -> Open -> Open (the one-time Gatekeeper
   step for an unsigned app; documented in `macos/READ ME FIRST.txt`).
2. The welcome dialog appears with no Terminal window. **Begin** walks the same
   flow: skills copy, then the graphify and mempalace cards.
3. uv-missing path shows the `curl ... | sh` command with a **Copy command**
   button (puts it on the clipboard), and never installs uv on its own.
4. Fallback: from an SSH session with no desktop, or via **Use text version**, it
   opens `Welcome.command` in Terminal instead.
5. Optional: double-click `build-icon.command` once to give the app its logo icon.

## Next polish (not v1 blockers)

- Windows: an Authenticode signature softens the SmartScreen prompt.
- macOS: enrolling in the Apple Developer Program to codesign + notarize + staple
  Hearth.app removes the right-click-Open step entirely.
