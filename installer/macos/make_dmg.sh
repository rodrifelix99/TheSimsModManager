#!/usr/bin/env bash
#
# Builds the disk image macOS users get handed: a window with the app on the
# left, the Applications folder on the right, and the artwork under both.
#
#   installer/macos/make_dmg.sh <output.dmg> <path to the built .app>
#
# The release workflow runs it on a tag and signs/notarizes what comes out;
# CI runs it unsigned on every push, so a layout that no longer assembles is
# a push away rather than a tag away. Needs create-dmg (brew install
# create-dmg); the icon coordinates below and the slots the background art
# draws (installer/macos/make_background.py) have to move together.
set -euo pipefail

OUT="$1"
APP="$2"
NAME="The Sims Mod Manager"
HERE="$(cd "$(dirname "$0")" && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

mkdir -p "$WORK/stage" "$(dirname "$OUT")"
cp -R "$APP" "$WORK/stage/$NAME.app"

# Finder reads the 2x representation out of a multi-page TIFF. The generator
# writes two PNGs instead, because a PNG is what a diff and a preview can
# show; they are folded together here.
tiffutil -cathidpicheck \
  "$HERE/dmg-background.png" "$HERE/dmg-background@2x.png" \
  -out "$WORK/background.tiff"

rm -f "$OUT"
create-dmg \
  --volname "$NAME" \
  --volicon "$APP/Contents/Resources/AppIcon.icns" \
  --background "$WORK/background.tiff" \
  --window-pos 200 120 \
  --window-size 660 420 \
  --icon-size 128 \
  --text-size 13 \
  --icon "$NAME.app" 170 232 \
  --hide-extension "$NAME.app" \
  --app-drop-link 490 232 \
  --no-internet-enable \
  "$OUT" "$WORK/stage"
