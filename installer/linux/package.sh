#!/bin/sh
# Packages a built Linux bundle into the tar.gz the release hands out.
#
# Usage: package.sh <output.tar.gz> <bundle-dir> <version>
#
# The archive carries a folder of its own. `tar -C bundle .` wrote the
# binary, lib and data loose at the top, so unpacking it in Downloads
# strewed three entries across whatever else was already there - and a
# binary that ends up parted from lib cannot start, with the loader's
# complaint going to a terminal nobody opened.
set -eu

out=$1
bundle=$2
version=$3
here=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
name=TheSimsModManager-$version

stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT
mkdir -p "$stage/$name"
cp -R "$bundle"/. "$stage/$name"/
cp "$here/TheSimsModManager.sh" "$stage/$name"/
chmod +x "$stage/$name/TheSimsModManager.sh" "$stage/$name/sims_mod_manager"

mkdir -p "$(dirname "$out")"
tar -czf "$out" -C "$stage" "$name"
