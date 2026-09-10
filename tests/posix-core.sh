#!/usr/bin/env bash
# Exercise the real POSIX copy core in a disposable home, never a user's install.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
export HOME="$scratch/home"
mkdir -p "$HOME"
source "$root/macos/hearth-core.sh"

# A native dialog is declined in this fixture. Production consent is unchanged.
osascript() { echo 'TEST: native confirmation declined' >&2; return 1; }
fail() { echo "FAIL: $*" >&2; exit 1; }
plan_digest() {
  node -e 'const p=JSON.parse(require("node:fs").readFileSync(0,"utf8"));if(p.dryRun!==true||!/^[0-9a-f]{64}$/.test(p.planDigest))throw Error("Invalid preview");console.log(p.planDigest);'
}
file_hash() {
  node -e 'const fs=require("node:fs"),crypto=require("node:crypto");console.log(crypto.createHash("sha256").update(fs.readFileSync(process.argv[1])).digest("hex"));' "$1"
}

if hc_install_skills "$root" >"$scratch/decline.log" 2>&1; then
  fail 'Installation succeeded without approval'
fi
[[ ! -e "$HOME/.claude/skills" ]] || fail 'Declined installation changed a skill target'

preview="$(node "$root/scripts/install.mjs" --host claude)"
digest="$(printf '%s' "$preview" | plan_digest)"
[[ ! -e "$HOME/.claude/skills" ]] || fail 'Preview installed skills'
if node "$root/scripts/install.mjs" --host claude --expect-plan wrong --yes >"$scratch/wrong-plan.log" 2>&1; then
  fail 'An incorrect approval digest was accepted'
fi
grep -q 'Installation changed since preview' "$scratch/wrong-plan.log" || fail 'Wrong digest failed for an unrelated reason'
[[ ! -e "$HOME/.claude/skills" ]] || fail 'Rejected digest installed skills'

result="$(hc_install_skills "$root" "$digest")"
[[ "$result" == OK\ * ]] || fail 'Approved installation did not report success'
for name in eidolon setup; do
  [[ -f "$HOME/.claude/skills/$name/SKILL.md" ]] || fail "Missing installed skill: $name"
done
installed="$HOME/.claude/skills/eidolon/SKILL.md"
before="$(file_hash "$installed")"
if hc_install_skills "$root" "$digest" >"$scratch/replacement.log" 2>&1; then
  fail 'Existing skills were replaced without replacement consent'
fi
grep -q -- '--replace' "$scratch/replacement.log" || fail 'Replacement failed for an unrelated reason'
[[ "$(file_hash "$installed")" == "$before" ]] || fail 'Refused replacement changed existing bytes'

# A real intervening human edit must invalidate the exact project plan.
project="$scratch/project"
mkdir -p "$project"
printf 'Original instructions\n' >"$project/AGENTS.md"
stale="$(node "$root/scripts/install.mjs" --host claude --project "$project" | plan_digest)"
printf 'Intervening human instructions\n' >"$project/AGENTS.md"
cp "$project/AGENTS.md" "$scratch/expected-instructions"
if node "$root/scripts/install.mjs" --host claude --project "$project" --expect-plan "$stale" --yes >"$scratch/stale-plan.log" 2>&1; then
  fail 'An outdated plan overwrote an intervening human edit'
fi
grep -q 'Installation changed since preview' "$scratch/stale-plan.log" || fail 'Stale plan failed for an unrelated reason'
cmp "$project/AGENTS.md" "$scratch/expected-instructions" || fail 'Human instructions changed'
[[ ! -e "$project/.claude/skills" ]] || fail 'An outdated plan partially installed skills'

if hc_install_tool "$scratch" ignored -- "touch '$scratch/optional-ran'" >"$scratch/optional.log" 2>&1; then
  fail 'Held optional service reported success'
fi
[[ ! -e "$scratch/optional-ran" ]] || fail 'Held optional service executed a step'
echo 'PASS: POSIX decline, exact approval, stale-plan rejection, replacement preservation and optional-service hold.'
