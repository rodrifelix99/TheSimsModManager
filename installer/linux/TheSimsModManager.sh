#!/bin/sh
# What a double-click starts.
#
# The download is unpacked wherever the user likes, so the app is found
# relative to this script rather than to the working directory, and its
# own libraries are pointed at explicitly. The binary's RUNPATH says
# $ORIGIN/lib, which is enough right up until the binary is moved,
# copied or launched apart from the folder it came in - and then the
# only thing on screen is nothing at all.
#
# Which is the other half of why this exists: started from a desktop
# entry there is no terminal for the loader to complain to, so a
# download missing a piece of itself looked exactly like a click that
# did not register.

here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
app=$here/sims_mod_manager

say() {
  echo "The Sims Mod Manager: $1" >&2
  # A desktop entry has no terminal, so say it again where it can be
  # read. Only with a display to put it on: without one this is a
  # terminal after all, or a machine that cannot show a dialog anyway.
  [ -t 2 ] && return 0
  [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ] || return 0
  if command -v kdialog > /dev/null 2>&1; then
    kdialog --title "The Sims Mod Manager" --error "$1"
  elif command -v zenity > /dev/null 2>&1; then
    zenity --error --title="The Sims Mod Manager" --text="$1"
  fi
}

# A file from each part of the download rather than the folder it sits
# in: an extraction that stopped halfway leaves lib and data standing and
# empty, and a name that is only a name would let that through to exactly
# the loader error this is here to replace.
for piece in \
  sims_mod_manager \
  lib/libapp.so \
  data/flutter_assets/AssetManifest.bin
do
  [ -e "$here/$piece" ] && continue
  say "This folder is missing $piece. Extract the whole archive again and
keep sims_mod_manager, lib and data together in one folder."
  exit 1
done

# An archive unpacked by a file manager can arrive without it.
[ -x "$app" ] || chmod +x "$app" 2> /dev/null
if [ ! -x "$app" ]; then
  say "sims_mod_manager cannot be run from here. Give it permission with
chmod +x, or move the folder somewhere on your own disk."
  exit 1
fi

LD_LIBRARY_PATH=$here/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}
export LD_LIBRARY_PATH
exec "$app" "$@"
