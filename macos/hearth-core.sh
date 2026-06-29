#!/usr/bin/env bash
# Hearth: the shared install core (macOS).
#
# Mechanics only, no on-screen voice. The app (Hearth.app) and the text installer
# (Welcome.command) both source this, so the real work lives in exactly one place.
# Plain, visible text. There is no hidden code, no base64. Nothing here installs
# anything without a yes from the caller.

hc_has() { command -v "$1" >/dev/null 2>&1; }

# Copy skills/ -> ~/.claude/skills, keeping the folder shape. The source files are
# already UTF-8 without a BOM, LF endings, so a plain copy preserves them.
# Echoes "OK <count>" on success, or "ERR <reason>" and returns non-zero.
# If HC_ON_FILE is set, it is eval'd once per file with HC_REL, HC_I, HC_N set.
hc_install_skills() {
  local root="$1" src dest count=0 total f rel td i=0
  src="$root/skills"; dest="$HOME/.claude/skills"
  [ -d "$src" ] || { echo "ERR missing"; return 1; }
  mkdir -p "$dest" 2>/dev/null || { echo "ERR home"; return 1; }
  total="$(find "$src" -type f | wc -l | tr -d ' ')"
  while IFS= read -r -d '' f; do
    rel="${f#"$src"/}"; td="$(dirname "$dest/$rel")"
    mkdir -p "$td" 2>/dev/null
    if cp "$f" "$dest/$rel" 2>/dev/null; then
      count=$((count + 1)); i=$((i + 1))
      if [ -n "${HC_ON_FILE:-}" ]; then HC_REL="$rel" HC_I="$i" HC_N="$total" eval "$HC_ON_FILE"; fi
    fi
  done < <(find "$src" -type f -print0)
  [ "$count" -gt 0 ] && echo "OK $count" || { echo "ERR empty"; return 1; }
}

hc_uv_ready() { hc_has uv; }

# Run a tool's steps in order, from an optional workdir. Args: workdir verify -- step...
# Returns 0 only if every step succeeds AND verify (when given) is found afterward.
hc_install_tool() {
  local workdir="$1" verify="$2"; shift 2; [ "${1:-}" = "--" ] && shift
  local s
  for s in "$@"; do
    ( [ -n "$workdir" ] && cd "$workdir"; eval "$s" ) >/dev/null 2>&1 || return 1
  done
  if [ -n "$verify" ]; then hc_has "$verify" || return 1; fi
  return 0
}
