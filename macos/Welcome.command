#!/usr/bin/env bash
# Hearth: a calm way to set up Claude. macOS version.
# This whole file is plain, visible text. There is no hidden code, no base64.
# You can read every line. Nothing runs unless you say yes.
# The real logo lives in assets/EidolonLogo.png. The full thank-you list lives in CREDITS.md.

set -u
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export LANG="${LANG:-en_US.UTF-8}"

# Welcome.command lives in Hearth/macos, so the Hearth folder is one level up.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Soft palette. Gentle colors. Green is a small win. Cyan is a calm voice.
CYAN=$'\033[36m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; GRAY=$'\033[90m'; RESET=$'\033[0m'

say()   { printf '%s%s%s\n' "$CYAN"   "$1" "$RESET"; }
warm()  { printf '%s%s%s\n' "$YELLOW" "$1" "$RESET"; }
soft()  { printf '%s%s%s\n' "$GRAY"   "$1" "$RESET"; }
win()   { printf '%s%s%s\n' "$GREEN"  "$1" "$RESET"; }
blank() { printf '\n'; }
pause() { sleep "${1:-0.35}"; }
have()  { command -v "$1" >/dev/null 2>&1; }

show_header() {
  blank
  printf '%s' "$YELLOW"
  cat <<'ART'
        _   _   _____      _      ____    _____   _   _
       | | | | | ____|    / \    |  _ \  |_   _| | | | |
       | |_| | |  _|     / _ \   | |_) |   | |   | |_| |
       |  _  | | |___   / ___ \  |  _ <    | |   |  _  |
       |_| |_| |_____| /_/   \_\ |_| \_\   |_|   |_| |_|
ART
  printf '%s' "$RESET"
  blank
  soft "    +----------------------------------------------------+"
  soft "    |                                                    |"
  say  "    |          a calm way to set up Claude               |"
  soft "    |                                                    |"
  soft "    +----------------------------------------------------+"
  blank
  soft "    (The real logo is in the assets folder. Full credits are in CREDITS.md.)"
  blank
}

show_skills_intro() {
  blank
  warm "    Your two skills, and why there are two."
  blank
  say  "      Setup is the calm start of a work session. When you sit down to a"
  say  "      piece of work, it asks a few short questions so Claude works the way"
  say  "      you like, it quietly remembers what helped and what did not, and it"
  say  "      double-checks its own work before calling anything done. Setup is"
  say  "      about the session: this visit, this stretch of work."
  blank
  say  "      Eidolon is about the project itself. It reads a whole project folder"
  say  "      and sets up what Claude needs to understand it, and when you want to"
  say  "      build or change something, it carries that work from a plain idea all"
  say  "      the way to finished: it plans the work, builds it a careful piece at a"
  say  "      time, checks it over for safety and mistakes, and only then puts it in place."
  blank
  say  "      And it looks out for you the whole way. Built-in helpers watch for the"
  say  "      risky moves, a safety check looks for ways a change could go wrong, and"
  say  "      nothing important is deleted or shipped without a clear yes from you."
  say  "      You always have the final say."
  blank
  say  "      Why both? Picture your project as a workshop. Eidolon gets the workshop"
  say  "      ready, so Claude knows where everything is and works safely in it."
  say  "      Setup is how you settle in for a good session once you are inside. One"
  say  "      makes the place ready, the other makes the visit go well, and they can"
  say  "      hand off to each other so they run as a pair."
  pause
  blank
  warm "    One gentle thing Setup will ask, the first time you work:"
  blank
  say  '      "People come to this at all different levels, and there is no wrong answer.'
  say  '       How familiar are you with coding and engineering?"'
  soft "         new to this            some familiarity"
  soft "         comfortable, I code    expert"
  blank
  say  "      There is no wrong answer, and you can change it any time. It just lets"
  say  "      Claude meet you where you are: plainly if that helps, or quickly if you"
  say  "      would rather move fast."
  blank
  pause
}

show_card() {
  local name="$1" what="$2" why="$3" who="$4" where="$5" when="$6" how="$7"
  blank
  soft "    +----------------------------------------------------------------+"
  warm "      $name"
  blank
  say  "      What:  $what"
  say  "      Why:   $why"
  say  "      Who:   $who"
  say  "      Where: $where"
  say  "      When:  $when"
  say  "      How:   $how"
  soft "    +----------------------------------------------------------------+"
  blank
}

# Asks a question, prints 'yes', 'no', or 'later' to stdout. Prompts go to stderr
# so the answer can be captured cleanly. Re-asks gently if the answer is unclear.
ask_ynl() {
  local q="$1" ans a
  while true; do
    { blank; warm "    $q"; soft "    Type yes, no, or later, then press Enter."; printf '%s    your answer: %s' "$CYAN" "$RESET"; } >&2
    read -r ans
    a="$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]' | sed 's/^ *//; s/ *$//')"
    case "$a" in
      y|yes) printf 'yes'; return;;
      n|no) printf 'no'; return;;
      l|later|maybe|"maybe later") printf 'later'; return;;
    esac
    { blank; say "    No worries. I did not quite catch that, so let us try once more."; say "    You can type yes, no, or later. Nothing happens until you choose."; } >&2
  done
}

# Draws one line of the breathing square.
breath_line() {
  local phase="$1" count="$2" n="$3" bar=""
  if [ "$n" -gt 0 ]; then bar="$(printf '#%.0s' $(seq 1 "$n"))"; fi
  printf '\r%s    %-12s %2s   %-16s%s' "$CYAN" "$phase" "$count" "$bar" "$RESET"
}

# Runs a real install command in the background and breathes a calm box on a four
# count while it runs. Returns the command's exit code (0 means it was happy).
run_with_breathing() {
  local cmd="$1" code=0 i
  ( cd "$ROOT" && eval "$cmd" ) >/dev/null 2>&1 &
  local pid=$!
  soft "    Box breathing while this finishes. Follow the count if you like."
  blank
  while kill -0 "$pid" 2>/dev/null; do
    for i in 1 2 3 4; do kill -0 "$pid" 2>/dev/null || break; breath_line "Breathe in"  "$i" "$i";          sleep 0.7; done
    for i in 1 2 3 4; do kill -0 "$pid" 2>/dev/null || break; breath_line "Hold"        "$i" 4;             sleep 0.7; done
    for i in 1 2 3 4; do kill -0 "$pid" 2>/dev/null || break; breath_line "Breathe out" "$i" "$((4 - i))";  sleep 0.7; done
    for i in 1 2 3 4; do kill -0 "$pid" 2>/dev/null || break; breath_line "Hold"        "$i" 0;             sleep 0.7; done
  done
  wait "$pid"; code=$?
  printf '\n'
  return $code
}

# Copy every file under skills/ into ~/.claude/skills, keeping the folder shape.
# The source files are already UTF-8 without a BOM, with LF endings, so a plain
# copy preserves them. This is the instant win. No questions asked.
install_skills() {
  blank
  warm "    First, a gift that is already yours."
  say  "    These two skills were made for you, so they go in right away."
  blank
  local src="$ROOT/skills" dest="$HOME/.claude/skills"
  if [ ! -d "$src" ]; then
    say "    The skills folder is not here beside me yet."
    say "    Here is the one thing to try: make sure the whole Hearth folder stayed together."
    say "    You have not broken anything. We can keep going."
    return
  fi
  if ! mkdir -p "$dest" 2>/dev/null; then
    say "    I could not open your skills home just now."
    say "    Here is the one thing to try: run this again in a moment. You have not broken anything."
    return
  fi
  local count=0 f rel td
  while IFS= read -r -d '' f; do
    rel="${f#$src/}"
    td="$(dirname "$dest/$rel")"
    mkdir -p "$td" 2>/dev/null
    if cp "$f" "$dest/$rel" 2>/dev/null; then
      win "    [ok]  $rel"
      count=$((count + 1))
      sleep 0.12
    else
      say "    One file did not copy: $(basename "$f")"
      say "    Here is the one thing to try: run this again. You have not broken anything."
    fi
  done < <(find "$src" -type f -print0)
  if [ "$count" -eq 0 ]; then
    say "    The skills folder is here, but it looks empty for now."
    say "    You have not broken anything. We can keep going."
    return
  fi
  blank
  win "    Done. Setup and Eidolon are in place."
  say "    That is your first win, and it took only a few seconds."
  blank
}

# Check and instruct only. Never installs system tooling itself.
# Returns 0 if uv is ready, 1 if it is missing (after showing the one command).
ensure_uv() {
  if have uv; then
    win "    Good. uv is already here, so we are ready."
    return 0
  fi
  blank
  say "    This tool leans on a small helper called uv, by a team named Astral."
  say "    uv is a fast, friendly installer for Python tools. It also brings Python along."
  say "    It is not on your computer yet, and I will not install it for you without asking."
  blank
  warm "    Here is the one official command to add it. You can copy and run it yourself:"
  blank
  win  "        curl -LsSf https://astral.sh/uv/install.sh | sh"
  blank
  soft "    (If you use Homebrew, brew install uv works too. Either one is fine.)"
  say  "    When uv is in, run Hearth again and pick this tool. You have not broken anything."
  return 1
}

# Show the card, ask yes/no/later, and on yes ensure uv then run the official
# install with box breathing. Args: name what why who where when how runtime verify steps...
offer_tool() {
  local name="$1" what="$2" why="$3" who="$4" where="$5" when="$6" how="$7" runtime="$8" verify="$9"
  shift 9
  local steps=("$@")
  show_card "$name" "$what" "$why" "$who" "$where" "$when" "$how"
  local choice; choice="$(ask_ynl "Want this set up?")"
  if [ "$choice" = "no" ]; then
    blank; say "    That is perfectly fine. We will leave it for now and move on."
    return
  fi
  if [ "$choice" = "later" ]; then
    blank
    say "    Good choice to wait. It will be here whenever you are ready."
    say "    You can run Hearth again any time and pick it then."
    return
  fi
  # choice is yes.
  if [ "$runtime" = "uv" ]; then
    if ! ensure_uv; then return; fi
  fi
  blank
  warm "    Wonderful. Let us set it up. This part does real work, so breathe with me."
  blank
  local allgood=1 s
  for s in "${steps[@]}"; do
    run_with_breathing "$s"
    if [ $? -ne 0 ]; then allgood=0; break; fi
  done
  local landed=0
  if [ -n "$verify" ]; then
    if have "$verify"; then landed=1; fi
  else
    landed=$allgood
  fi
  blank
  if [ "$allgood" = "1" ] && [ "$landed" = "1" ]; then
    win "    [ok]  $name is set up and ready."
    say "    Nicely done. That is another piece in place."
  else
    say "    $name did not finish going in this time."
    say "    Here is the one thing to try: run Hearth again and choose it once more."
    say "    Sometimes a tool just needs a second pass. You have not broken anything."
  fi
  blank
}

# ============================================================================
# The flow.
# ============================================================================

clear 2>/dev/null || true

show_header

say "    Hello, and welcome. Take a breath. You are in the right place."
pause
blank
say "    Here is the shape of what happens next, so nothing is a surprise:"
blank
say "      You are safe here. Nothing happens without your yes."
say "      You can close this window any time you like."
say "      This cannot harm your computer."
say "      Every step tells you what just happened and what comes next."
pause
blank
say "    We start with a small gift, then I introduce a couple of helpers."
say "    For each helper you can say yes, no, or later. You are in control the whole time."

show_skills_intro

blank
printf '%s    Press Enter when you are ready %s' "$CYAN" "$RESET"; read -r _

# Instant win.
install_skills

# graphify. On macOS we install it with uv, which avoids the modern pip restriction.
offer_tool \
  "graphify" \
  "It turns a folder of work into a clear map you can explore." \
  "When your project grows, this helps you and Claude see how the pieces connect." \
  "Made by Safi Shamsi. The work is at https://github.com/safishamsi/graphify (MIT license)." \
  "Installed from its official package, named graphifyy, the same one the maker publishes." \
  "Reach for it when you want a birds eye view of a project folder." \
  "If you say yes: I run uv tool install graphifyy, then graphify install, in this Hearth folder." \
  "uv" "graphify" \
  "uv tool install graphifyy" "graphify install ."

# mempalace.
offer_tool \
  "mempalace" \
  "It gives Claude a searchable memory, so it can recall what you worked on before." \
  "Instead of repeating yourself each session, Claude can look things up and stay on the same page." \
  "Lead author igorls, with the Claude plugin published by milla-jovovich. https://github.com/MemPalace/mempalace (MIT license)." \
  "Installed from its official package using uv, the helper from Astral." \
  "Reach for it when you want Claude to remember context across days and projects." \
  "If you say yes: I run uv tool install mempalace, then mempalace init, then register its memory with Claude cleanly." \
  "uv" "mempalace" \
  "uv tool install mempalace" "mempalace init" "claude mcp add mempalace -- mempalace-mcp"

# Warm send-off.
blank
soft "    +----------------------------------------------------+"
win  "    |                  You did it.                       |"
soft "    +----------------------------------------------------+"
blank
warm "    Here is what you now have:"
blank
say  "      Setup and Eidolon, your two skills, ready in Claude."
say  "      Any helpers you said yes to, installed from their own makers."
blank
warm "    How to use your new skills:"
blank
say  "      Open Claude Code, and type a single slash, the / key."
say  "      A list of your skills appears. Pick one and follow along."
blank
warm "    If you ever feel unsure, help is close by:"
blank
say  "      READ ME FIRST.txt has the calm, printable version of all of this."
say  "      CREDITS.md names everyone whose work made Hearth possible."
blank

warm "    With thanks."
blank
say  "      Addy Osmani, first and foremost. He built the agent-skills harness"
say  "      that this whole pattern grows from. The idea starts with his work."
blank
say  "      And the makers of the tools Hearth points to, each from their own hands."
say  "      The full gallery, with everyone named and linked, is in CREDITS.md."
blank
win  "    Thank you for being here. Be gentle with yourself. You did well."
blank
printf '%s    Press Enter to close %s' "$CYAN" "$RESET"; read -r _
