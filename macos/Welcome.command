#!/usr/bin/env bash
# Hearth, novice door for macOS. Pure bash. Copies the skills folder into your
# Claude Code skills folder and does nothing else.
# --yes        replace skills that already exist without asking (your old copy is still saved)
# --home PATH  use this folder in place of your user folder (for tests)

yes_all=0
home_dir="$HOME"
while [ $# -gt 0 ]; do
  case "$1" in
    --yes) yes_all=1 ;;
    --home) shift; home_dir="${1:-}"; [ -n "$home_dir" ] || { echo "--home needs a folder. Nothing was installed."; exit 2; } ;;
    *) echo "Unknown option: $1. Nothing was installed."; exit 2 ;;
  esac
  shift
done

root="$(cd "$(dirname "$0")/.." && pwd)"
src="$root/skills"
dest="$home_dir/.claude/skills"
stamp="$(date +%Y%m%d-%H%M%S)"
backup_root="$dest/.hearth-backups/$stamp"

fail_soft() {
  printf '\n%s\nTry this: %s\nNothing is broken. You can run this again.\n' "$1" "$2"
}

# Update notice. One request to GitHub for the latest Hearth release, three seconds at most, and
# silence when it fails. EIDOLON_UPDATE_CHECK=0 turns it off. HEARTH_RELEASE_API replaces the
# address (tests). Nothing changes unless you type yes.
version_of() {
  printf '%s\n' "$1" | sed -n 's/^[^0-9]*\([0-9][0-9]*\)\.\([0-9][0-9]*\)\.\([0-9][0-9]*\).*/\1 \2 \3/p' | head -n 1
}
newer_than() {
  set -- $1 $2
  [ "$1" -gt "$4" ] && return 0
  [ "$1" -lt "$4" ] && return 1
  [ "$2" -gt "$5" ] && return 0
  [ "$2" -lt "$5" ] && return 1
  [ "$3" -gt "$6" ]
}
update_notice() {
  [ "${EIDOLON_UPDATE_CHECK:-}" = "0" ] && return 0
  mine="$(version_of "$(grep -m1 '"version"' "$root/package.json" 2>/dev/null)")"
  api="${HEARTH_RELEASE_API:-https://api.github.com/repos/eidolonofficial/Hearth/releases/latest}"
  body="$(curl -fsS --max-time 3 -H 'User-Agent: hearth-update-check' "$api" 2>/dev/null)" || return 0
  tag="$(printf '%s\n' "$body" | sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
  page="$(printf '%s\n' "$body" | sed -n 's/.*"html_url"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
  theirs="$(version_of "$tag")"
  { [ -n "$mine" ] && [ -n "$theirs" ]; } || return 0
  newer_than "$theirs" "$mine" || return 0
  echo "Hearth v$(printf '%s' "$theirs" | tr ' ' '.') is available. This copy is v$(printf '%s' "$mine" | tr ' ' '.')."
  echo "Download: $page"
  if [ "$yes_all" -eq 1 ]; then echo; return 0; fi
  answer=""
  printf 'Type yes to open the download page and stop here, or press Enter to continue with this copy: '
  read -r answer
  echo
  if [ "$answer" = "yes" ]; then
    open "$page" 2>/dev/null || true
    echo "Run Welcome.command from the new download. Nothing was installed."
    exit 0
  fi
  return 0
}

echo "Hearth copies two skills, Eidolon and Setup, into your Claude Code skills folder."
echo "It writes only inside $dest. Nothing else is installed."
echo "If a skill is already there, I ask first and keep your old copy."
echo

update_notice

if [ ! -d "$src" ]; then
  fail_soft "The skills folder is not next to this file." "keep the whole Hearth folder together and open Welcome.command from inside macos/."
  exit 1
fi
if ! mkdir -p "$dest" 2>/dev/null; then
  fail_soft "I could not open $dest." "check that the folder is yours to write to, then run this again."
  exit 1
fi

installed=""
skipped=""
failures=0
found=0
for dir in "$src"/*/; do
  [ -d "$dir" ] || continue
  found=1
  name="$(basename "$dir")"
  target="$dest/$name"
  if [ -e "$target" ]; then
    replace=$yes_all
    if [ "$replace" -ne 1 ]; then
      answer=""
      printf '%s is already installed. Type replace to swap it, or press Enter to skip: ' "$name"
      read -r answer
      [ "$answer" = "replace" ] && replace=1
    fi
    if [ "$replace" -ne 1 ]; then
      echo "Skipped $name. Your copy is unchanged."
      skipped="$skipped $name"
      continue
    fi
    if mkdir -p "$backup_root" && mv "$target" "$backup_root/$name"; then
      echo "Saved your old $name to $backup_root/$name"
    else
      fail_soft "I could not save your old $name, so I left it alone." "close any program that has that folder open, then run this again."
      failures=$((failures + 1))
      continue
    fi
  fi
  bad=0
  while IFS= read -r -d '' file; do
    rel="${file#$src/}"
    if mkdir -p "$(dirname "$dest/$rel")" && cp -p "$file" "$dest/$rel"; then
      echo "  copied $rel"
    else
      echo "  did not copy $rel"
      bad=$((bad + 1))
    fi
  done < <(find "$src/$name" -type f -print0)
  if [ "$bad" -gt 0 ]; then
    fail_soft "$bad file(s) of $name did not copy." "run this again. Files already copied are safe to copy over."
    failures=$((failures + 1))
  else
    installed="$installed $name"
  fi
done

if [ "$found" -eq 0 ]; then
  fail_soft "The skills folder is empty." "download Hearth again and keep the whole folder."
  exit 1
fi

echo
[ -n "$installed" ] && echo "Installed now:$installed in $dest"
[ -n "$skipped" ] && echo "Skipped, still your own copy:$skipped"
[ "$failures" -gt 0 ] && exit 1
echo "To start: open Claude Code and type /eidolon or /setup."
exit 0
