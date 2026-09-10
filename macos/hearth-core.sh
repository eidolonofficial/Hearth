#!/usr/bin/env bash
# Legacy GUI mechanics. An exact preview digest is required before writing.
hc_has() { command -v "$1" >/dev/null 2>&1; }
hc_install_skills() {
  local root="$1" plan digest approved result count
  hc_has node || { echo 'ERR Node.js 22 or newer is required; nothing installed'; return 1; }
  plan="$(node "$root/scripts/install.mjs" --host claude 2>&1)" || { echo "$plan"; return 1; }
  digest="$(printf '%s' "$plan" | node -e 'let s="";process.stdin.on("data",c=>s+=c);process.stdin.on("end",()=>{const p=JSON.parse(s);if(!p.dryRun||! /^[0-9a-f]{64}$/.test(p.planDigest))process.exit(1);console.log(p.planDigest);});')" || return 1
  if [[ "${2:-}" == "$digest" ]]; then approved=yes
  elif [[ "$(uname -s)" == Darwin ]]; then
    approved="$(osascript - "$plan" <<'APPLESCRIPT'
on run argv
  set answer to display dialog ("Review these exact installation paths and plan before writing:" & return & item 1 of argv) buttons {"Cancel", "Install"} default button "Cancel" with title "Hearth"
  if button returned of answer is "Install" then return "yes"
end run
APPLESCRIPT
)" || return 1
  else echo 'ERR Explicit preview digest is required; nothing installed'; return 1
  fi
  [[ "$approved" == yes ]] || return 1
  result="$(node "$root/scripts/install.mjs" --host claude --expect-plan "$digest" --yes)" || { echo 'ERR Plan changed or installation failed; review a new preview'; return 1; }
  count="$(printf '%s' "$result" | node -e 'let s="";process.stdin.on("data",c=>s+=c);process.stdin.on("end",()=>{const r=JSON.parse(s);if(!r.ok)process.exit(1);console.log(r.copied);});')" || return 1
  echo "OK $count"
}
hc_uv_ready() { hc_has uv; }
hc_install_tool() {
  echo 'Optional-service automatic installation is held pending a reviewed, hash-pinned dependency and data-access plan.' >&2
  return 1
}
