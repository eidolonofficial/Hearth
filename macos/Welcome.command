#!/usr/bin/env bash
# Hearth: set Claude up right, no terminal required. macOS text installer.
# This whole file is plain, visible text. There is no hidden code, no base64.
# You can read every line. Nothing runs unless you say yes.
# This is the reliable fallback for the Hearth.app window, and it does the same work.
# The real logo lives in assets/EidolonLogo.png. The full thanks list is in CREDITS.md.

set -u
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export LANG="${LANG:-en_US.UTF-8}"

# Welcome.command lives in Hearth/macos, so the Hearth folder is one level up.
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
. "$HERE/hearth-core.sh"

CYAN=$'\033[36m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; GRAY=$'\033[90m'; RESET=$'\033[0m'
say()   { printf '%s%s%s\n' "$CYAN"   "$1" "$RESET"; }
warm()  { printf '%s%s%s\n' "$YELLOW" "$1" "$RESET"; }
soft()  { printf '%s%s%s\n' "$GRAY"   "$1" "$RESET"; }
win()   { printf '%s%s%s\n' "$GREEN"  "$1" "$RESET"; }
blank() { printf '\n'; }

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
  say  "       Give Claude a memory and a backbone."
  soft "       No terminal. No jargon. You say yes to every step."
  blank
}

show_skills_intro() {
  blank
  warm "    Your two skills, and why there are two."
  blank
  say  "      Setup gets a work session off to a strong start. It asks a few short"
  say  "      questions so Claude works the way you like, then it remembers what worked,"
  say  "      checks its own work before it says 'done,' and learns how you like to work."
  say  "      Setup is about the session: this visit, this stretch of work."
  blank
  say  "      Eidolon is about the project itself. Point it at a project folder and it"
  say  "      reads the whole thing, sets up what Claude needs to understand it, then"
  say  "      carries any change from a plain idea all the way to finished: it plans,"
  say  "      builds one careful piece at a time, checks for safety and mistakes, and"
  say  "      only then puts it in place. Nothing important ships or gets deleted"
  say  "      without your clear yes."
  blank
  say  "      Why both? Picture your project as a workshop. Eidolon gets the workshop"
  say  "      ready; Setup is how you settle in for a good session inside it. They hand"
  say  "      off to each other, so they work as a pair."
  blank
  warm "    The first time you work, Setup asks one thing:"
  blank
  say  '      "How familiar are you with coding and engineering?"'
  soft "         new to this            some familiarity"
  soft "         comfortable, I code    expert"
  blank
  say  "      There is no wrong answer, and you can change it any time."
  blank
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

# Prints 'yes', 'no', or 'later'. Prompts go to stderr so the answer is clean.
ask_ynl() {
  local q="$1" ans a
  while true; do
    { blank; warm "    $q  Type yes, no, or later, then press Enter."; printf '%s    your answer: %s' "$CYAN" "$RESET"; } >&2
    read -r ans
    a="$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]' | sed 's/^ *//; s/ *$//')"
    case "$a" in
      y|yes) printf 'yes'; return;;
      n|no) printf 'no'; return;;
      l|later|maybe|"maybe later") printf 'later'; return;;
    esac
    { blank; say "    I did not catch that. yes, no, or later. Nothing happens until you choose."; } >&2
  done
}

install_skills() {
  blank
  warm "    First, a gift that is already yours."
  say  "    These two skills were made for you, so they go in right away."
  blank
  local result
  HC_ON_FILE='printf "\r%s    Copying %3s of %-3s  %-44s%s" "$CYAN" "$HC_I" "$HC_N" "$HC_REL" "$RESET" >&2'
  result="$(hc_install_skills "$ROOT")"
  blank >&2
  case "$result" in
    OK\ *)
      blank
      win "    Done. Setup and Eidolon are in place (${result#OK } files)."
      say "    That is your first win, and it took only a few seconds." ;;
    *)
      say "    I could not finish the copy. Make sure the whole Hearth folder stayed"
      say "    together, then run this again. You have not broken anything." ;;
  esac
  blank
}

ensure_uv() {
  if hc_uv_ready; then
    win "    Good. uv is already here, so we are ready."
    return 0
  fi
  blank
  say  "    This tool needs uv, a small helper by a team named Astral. It is a fast"
  say  "    installer for Python tools, and it brings Python along. It is not on your"
  say  "    computer yet, and Hearth will not install it for you without asking."
  blank
  warm "    Here is the one official command. Copy it and run it yourself:"
  blank
  win  "        curl -LsSf https://astral.sh/uv/install.sh | sh"
  blank
  soft "    (If you use Homebrew, brew install uv works too. Either one is fine.)"
  say  "    Once it is in, run Hearth again and pick this tool. You have not broken anything."
  return 1
}

# Args: name what why who where when how runtime verify -- step...
offer_tool() {
  local name="$1" what="$2" why="$3" who="$4" where="$5" when="$6" how="$7" runtime="$8" verify="$9"
  shift 9; [ "${1:-}" = "--" ] && shift
  local steps=("$@")
  show_card "$name" "$what" "$why" "$who" "$where" "$when" "$how"
  local choice; choice="$(ask_ynl "Want this set up?")"
  if [ "$choice" = "no" ];    then blank; say "    That is fine. We will leave it and move on."; return; fi
  if [ "$choice" = "later" ]; then blank; say "    Good call. It will be here whenever you are ready. Run Hearth again any time."; return; fi
  if [ "$runtime" = "uv" ]; then ensure_uv || return; fi
  blank
  warm "    Setting it up now. This does real work and can take a minute."
  blank
  if hc_install_tool "$ROOT" "$verify" -- "${steps[@]}"; then
    win "    [ok]  $name is set up and ready."
    say "    Nicely done. Another piece in place."
  else
    say "    $name did not finish this time. Run Hearth again and choose it once more."
    say "    Sometimes a tool needs a second pass. You have not broken anything."
  fi
  blank
}

# ============================================================================
# The flow.
# ============================================================================

clear 2>/dev/null || true
show_header

say "    Hello, and welcome. You are in the right place."
blank
say "    Here is the shape of what happens next, so nothing is a surprise:"
blank
say "      You are safe here. Nothing happens without your yes."
say "      Close this window any time you like."
say "      This cannot harm your computer."
say "      Every step says what just happened and what comes next."
blank
say "    We start with a quick win, then I introduce two optional helpers."
say "    For each one you can say yes, no, or later. You are in control the whole time."

show_skills_intro

blank
printf '%s    Press Enter when you are ready %s' "$CYAN" "$RESET"; read -r _

install_skills

offer_tool \
  "graphify" \
  "It turns a folder of work into a clear map you can explore." \
  "As your project grows, this helps you and Claude see how the pieces connect." \
  "Made by Safi Shamsi. github.com/safishamsi/graphify (MIT license)." \
  "Its official package, named graphifyy, the one the maker publishes." \
  "Reach for it when you want a birds-eye view of a project folder." \
  "Say yes and Hearth runs: uv tool install graphifyy, then graphify install, here." \
  "uv" "graphify" -- \
  "uv tool install graphifyy" "graphify install ."

offer_tool \
  "mempalace" \
  "It gives Claude a searchable memory, so it can recall what you worked on before." \
  "Instead of repeating yourself each session, Claude looks things up and keeps up." \
  "Lead author igorls; Claude plugin by milla-jovovich. github.com/MemPalace/mempalace (MIT license)." \
  "Its official package, installed with uv (the helper from Astral)." \
  "Reach for it when you want Claude to remember context across days and projects." \
  "Say yes and Hearth runs: uv tool install mempalace, mempalace init, then registers its memory with Claude." \
  "uv" "mempalace" -- \
  "uv tool install mempalace" "mempalace init" "claude mcp add mempalace -- mempalace-mcp"

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
warm "    How to use them:"
blank
say  "      Open Claude Code and type a single slash, the / key."
say  "      Your skills appear in the list. Pick one and follow along."
blank
warm "    If you ever feel unsure:"
blank
say  "      READ ME FIRST.txt has the printable version of all of this."
say  "      CREDITS.md names everyone whose work made Hearth possible."
blank
warm "    With thanks."
blank
say  "      Addy Osmani, first of all. He built the agent-skills harness this whole"
say  "      pattern grows from. The idea starts with his work."
say  "      And the makers of the tools Hearth points to, each from their own hands."
blank
win  "    Thank you for being here. You did well."
blank
printf '%s    Press Enter to close %s' "$CYAN" "$RESET"; read -r _
