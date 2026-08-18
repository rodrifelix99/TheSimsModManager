import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/install_destination.dart';
import 'sims2_packs.dart';
import 'sims3_packs.dart';

/// The folders inside a game's own installation that mods are put in.
///
/// The Sims 2 and 3 keep their mods in Documents, and everything the
/// library does assumes that: one folder that belongs to the player,
/// swept whole, safe to list and switch off. A handful of the things
/// people install are not like that at all. A routing fix is a `.world`
/// that goes over the one the game shipped; an ASI mod is a plugin beside
/// the executable; a graphics fix is a `.sgr` in the folder the game
/// reads its settings from. None of them work anywhere else, so before
/// this the answer was a file manager and a readme (issue #22).
///
/// Two things make it safe to write there. The folders are declared as
/// holding the game's own files ([InstallDestination.holdsStockFiles]),
/// so the library lists only what the app itself put in them rather than
/// offering to disable half of Maxis's content; and anything written over
/// is parked first (`core/stock_backup.dart`), so uninstalling gives the
/// game its own file back.
///
/// Both games are found through the registry rather than by walking the
/// disk. The Sims 3 registers every pack's install folder, and the Sims 2
/// Legacy Collection registers every pack of its own - the same keys the
/// pack manager already reads, which is also why neither of these answers
/// anything off Windows.

/// `Game/Bin`, where the executable and its plugins live.
const sims3BinSegments = ['Game', 'Bin'];

/// The worlds a copy of the game ships, one folder per pack.
const sims3WorldsSegments = ['GameData', 'Shared', 'NonPackaged', 'Worlds'];

/// Sky, sea and camera settings, as loose `.ini` files.
const sims3IniSegments = ['GameData', 'Shared', 'NonPackaged', 'Ini'];

/// Files The Sims 3 loads from its own folders and never from Mods.
const sims3RootExtensions = {'.world', '.asi', '.dll', '.sgr', '.ini'};

/// The pack executable's own folder, where a wrapper `.dll` goes.
const sims2BinSegments = ['TSBin'];

/// Graphics rules, video cards, and the rest of what the game reads
/// before it draws anything.
const sims2ConfigSegments = ['TSData', 'Res', 'Config'];

/// Files The Sims 2 loads from its own folders and never from Downloads.
const sims2RootExtensions = {'.asi', '.dll', '.sgr'};

/// Where The Sims 3 is installed, base game first and then every pack.
///
/// The base game is the one that matters for plugins and settings - it
/// owns the executable the launcher runs - while the packs matter for
/// worlds, because Bridgeport belongs to Late Night and a fix for it has
/// to go in Late Night's own folder. Read once per run: the registry
/// cannot say anything different while the app is open, and this is asked
/// again on every install.
Future<({Directory? base, List<Directory> packs})> sims3InstallDirs() =>
    _sims3Dirs ??= _readSims3InstallDirs();

Future<({Directory? base, List<Directory> packs})>? _sims3Dirs;

Future<({Directory? base, List<Directory> packs})>
    _readSims3InstallDirs() async {
  if (!Platform.isWindows) return (base: null, packs: const <Directory>[]);
  try {
    final base = readSims3InstallRoot();
    final keys = readSims3PackKeys();
    final seen = <String>{};
    final packs = <Directory>[];
    // A pack the app has parked is still on disk and still holds its
    // worlds, and it can be switched back on at any moment, so it is
    // listed like the rest.
    for (final key in [...keys.enabled.values, ...keys.disabled.values]) {
      final dir = key.installDir?.trim();
      if (dir == null || dir.isEmpty) continue;
      if (!seen.add(p.canonicalize(dir))) continue;
      packs.add(Directory(dir));
    }
    return (base: base, packs: packs);
  } catch (_) {
    // A registry this app cannot read is a game it cannot offer these
    // folders for, which is what every machine had before.
    return (base: null, packs: const <Directory>[]);
  }
}

/// The Sims 3's own folders that exist on this machine.
///
/// [installRoot] and [packRoots] are parameters rather than read here so
/// the whole thing can be exercised against folders of a test's making
/// instead of somebody's game.
Future<List<InstallDestination>> sims3RootDestinations({
  required Directory? installRoot,
  required List<Directory> packRoots,
}) async {
  final found = <InstallDestination>[];
  final seen = <String>{};

  Future<void> offer(Directory root, List<String> segments,
      {String? under}) async {
    final dir = Directory(p.joinAll([root.path, ...segments]));
    try {
      if (!await dir.exists()) return;
    } catch (_) {
      return;
    }
    if (!seen.add(p.canonicalize(dir.path))) return;
    final id = [if (under != null) under, ...segments].join('/');
    found.add(InstallDestination(
      id: id,
      directory: dir,
      label: p.joinAll(id.split('/')),
      holdsStockFiles: true,
    ));
  }

  if (installRoot != null) {
    await offer(installRoot, sims3BinSegments);
    await offer(installRoot, sims3WorldsSegments);
    await offer(installRoot, sims3IniSegments);
  }
  for (final pack in packRoots) {
    // Only the worlds. A pack's own `Game/Bin` holds a few helper files
    // and nothing that loads a plugin, and the settings are the base
    // game's; offering twenty more of each would be twenty more ways to
    // put a file where the game never looks.
    await offer(pack, sims3WorldsSegments, under: p.basename(pack.path));
  }
  return found;
}

/// The Sims 2 Legacy Collection's own folders, which are the folders of
/// the pack the collection actually runs.
///
/// Every pack ships a `TSData/Res/Config` of its own and they all hold a
/// `Graphics Rules.sgr` with the same name - seventeen copies of it here -
/// but the game reads the last pack in the load order and only that one,
/// which is exactly the ambiguity issue #22 warned about. So one pack is
/// offered rather than all of them, and it is the one the game runs.
Future<List<InstallDestination>> sims2RootDestinations({
  required Directory? runningPack,
}) async {
  if (runningPack == null) return const [];
  final found = <InstallDestination>[];
  final name = p.basename(runningPack.path);
  for (final segments in const [sims2BinSegments, sims2ConfigSegments]) {
    final dir = Directory(p.joinAll([runningPack.path, ...segments]));
    try {
      if (!await dir.exists()) continue;
    } catch (_) {
      continue;
    }
    final id = [name, ...segments].join('/');
    found.add(InstallDestination(
      id: id,
      directory: dir,
      label: p.joinAll(id.split('/')),
      holdsStockFiles: true,
    ));
  }
  return found;
}

/// The folder of the pack whose executable the collection runs, which is
/// the last one its load order names.
///
/// The load order is release order rather than pack number, and the
/// entry that ends it is the pack whose `.exe` the launcher starts - so
/// this is read off the order rather than assumed to be the highest EP.
Future<Directory?> sims2RunningPackDir() => _sims2Pack ??= _readSims2Pack();

Future<Directory?>? _sims2Pack;

Future<Directory?> _readSims2Pack() async {
  if (!Platform.isWindows) return null;
  try {
    final order = [
      for (final entry in parseSims2LoadOrder(readSims2LoadOrder()))
        if (entry.trim().isNotEmpty) entry.trim().toLowerCase(),
    ];
    if (order.isEmpty) return null;
    final keys = readSims2PackKeys();
    for (final exe in order.reversed) {
      final key =
          keys.where((k) => k.exe.toLowerCase() == exe).firstOrNull;
      final path = key?.path?.trim();
      if (path == null || path.isEmpty) continue;
      final dir = Directory(path);
      if (await dir.exists()) return dir;
    }
    return null;
  } catch (_) {
    return null;
  }
}

/// Which of [destinations] already holds a file called [fileName].
///
/// This is what "replace the original" means in practice: a routing fix
/// carries the world's own name because that is the only way the game
/// loads it instead, and a rewritten `Graphics Rules.sgr` is that file or
/// it is nothing. Matching on the name is therefore not a heuristic about
/// what the download meant - it is the mechanism the mod itself relies
/// on. Where nothing matches, the file is new, and the callers below
/// decide by type instead.
Future<Directory?> destinationHolding(
    String fileName, List<InstallDestination> destinations) async {
  for (final destination in destinations) {
    try {
      if (await File(p.join(destination.directory.path, fileName)).exists()) {
        return destination.directory;
      }
    } catch (_) {
      // A folder that cannot be asked is not the answer.
    }
  }
  return null;
}

Directory? _endingIn(List<InstallDestination> destinations, String tail) =>
    destinations
        .where((d) => d.id.toLowerCase().endsWith(tail.toLowerCase()))
        .firstOrNull
        ?.directory;

/// Where a Sims 3 file that is not a `.package` goes.
Future<Directory?> sims3RootDestinationFor(
    String fileName, List<InstallDestination> destinations) async {
  final replacing = await destinationHolding(fileName, destinations);
  if (replacing != null) return replacing;
  return switch (p.extension(fileName).toLowerCase()) {
    // Plugins and the loaders that start them: always beside the
    // executable, and never a replacement for anything, since the game
    // ships none of them.
    '.asi' || '.dll' || '.sgr' =>
      _endingIn(destinations, sims3BinSegments.join('/')),
    // A world nothing here is called: a custom one. The base game's
    // folder is where the game looks for worlds that belong to no pack.
    '.world' => _endingIn(destinations, sims3WorldsSegments.join('/')),
    // An `.ini` matching nothing the game ships is a mod's own config
    // file, and the game folder is the last place it belongs.
    _ => null,
  };
}

/// Where a Sims 2 file that is not a `.package` goes.
Future<Directory?> sims2RootDestinationFor(
    String fileName, List<InstallDestination> destinations) async {
  final replacing = await destinationHolding(fileName, destinations);
  if (replacing != null) return replacing;
  return switch (p.extension(fileName).toLowerCase()) {
    '.asi' || '.dll' => _endingIn(destinations, sims2BinSegments.join('/')),
    '.sgr' => _endingIn(destinations, sims2ConfigSegments.join('/')),
    _ => null,
  };
}
