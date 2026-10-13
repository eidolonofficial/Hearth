#!/usr/bin/env bash
# Terminal picker that wires project hooks. Needs Node 22 or newer.
if ! command -v node >/dev/null 2>&1 || [ "$(node -p 'process.versions.node.split(".")[0]')" -lt 22 ]; then
  echo "Operator setup needs Node 22 or newer, and it was not found."
  echo "Get it from https://nodejs.org and run this file again."
  echo "Nothing was installed."
  exit 1
fi
exec node "$(cd "$(dirname "$0")/.." && pwd)/scripts/welcome.mjs"
