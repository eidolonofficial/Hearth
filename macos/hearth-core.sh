#!/usr/bin/env bash
# Shared mechanics for the legacy macOS Claude GUI. No optional install without caller consent.
hc_has() { command -v "$1" >/dev/null 2>&1; }
# Delegate to the byte-preserving transaction. No partial copy is success.
# Existing installations require explicit replacement through Start Agents.
hc_install_skills() {
  local root="$1" result count
  hc_has node || { echo "ERR Node.js 22 or newer is required; nothing installed"; return 1; }
  result="$(node "$root/scripts/install.mjs" --host claude --yes)" || { echo "ERR install refused or incomplete; use Start Agents for replacement"; return 1; }
  count="$(printf '%s' "$result" | node -e 'let s="";process.stdin.on("data",c=>s+=c);process.stdin.on("end",()=>{try{const r=JSON.parse(s);if(!r.ok)process.exit(1);console.log(r.copied)}catch{process.exit(1)}})')" || { echo "ERR verification"; return 1; }
  echo "OK $count"
}
hc_uv_ready() { hc_has uv; }
hc_install_tool() {
  local workdir="$1" verify="$2"; shift 2; [ "${1:-}" = "--" ] && shift
  local s
  for s in "$@"; do
    ( if [ -n "$workdir" ]; then cd "$workdir" || exit 1; fi; eval "$s" ) >/dev/null 2>&1 || return 1
  done
  if [ -n "$verify" ]; then hc_has "$verify" || return 1; fi
  return 0
}
