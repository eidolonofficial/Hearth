#!/usr/bin/env bash
ROOT="$(cd "$(dirname "$0")/.." && pwd)" || exit 1
if ! command -v node >/dev/null 2>&1; then
  echo "Node.js 18 or newer is required. Nothing was installed. See README.md."
  read -r -p "Press Return to close. " _
  exit 1
fi
if [ "${HEARTH_TEXT:-}" = "1" ]; then
  node "$ROOT/scripts/welcome.mjs"
else
  node "$ROOT/scripts/hearth-ui.mjs"
fi
