#!/usr/bin/env bash
# Optional: give Hearth.app its logo as the Dock and Finder icon.
# Run this once on a Mac (double-click it). It builds Hearth.icns from
# assets/EidolonLogo.png with macOS's own tools, then drops it into the app.
# Safe to skip entirely; Hearth.app works fine without it.

set -eu
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
SRC="$ROOT/assets/EidolonLogo.png"
APP="$HERE/Hearth.app"

[ -f "$SRC" ] || { echo "Logo not found at $SRC"; exit 1; }

set="$(mktemp -d)/Hearth.iconset"
mkdir -p "$set"
for s in 16 32 64 128 256 512; do
  sips -z "$s" "$s"             "$SRC" --out "$set/icon_${s}x${s}.png"     >/dev/null
  sips -z "$((s*2))" "$((s*2))" "$SRC" --out "$set/icon_${s}x${s}@2x.png"  >/dev/null
done
iconutil -c icns "$set" -o "$APP/Contents/Resources/Hearth.icns"
echo "Done. Hearth.app now shows the Hearth logo as its icon."
