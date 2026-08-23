/// Finding a game's own installation on this machine, for the games
/// whose mods live in the install folder rather than under Documents.
///
/// Nothing here knows about a particular game: an [InstallSignature] is
/// handed in and the walk keeps whatever it recognises. It started life
/// inside the Sims adapters and moved here when SimCity needed the same
/// Steam libraries, the same Program Files roots and the same bounded
/// drive walk - two franchises asking the same question is what a core
/// helper is for.
library;

import 'dart:io';

import 'package:path/path.dart' as p;

/// Whether [dir] is an install of a particular game, told by a file only
/// that game ships. Folder names can't answer this: they're localized,
/// every re-release picks a new one, and a repack or a hand-moved copy
/// invents its own.
typedef InstallSignature = Future<bool> Function(Directory dir);

/// The Steam client roots a Linux machine may have: the classic symlinked
/// location, the XDG one, and the Flatpak sandbox. One list, because it
/// feeds the prefix scan, the library scan and the install-folder games
/// alike - the Flatpak path once lived in only two of the three.
List<String> linuxSteamRoots(String home) => [
      p.join(home, '.steam', 'steam'),
      p.join(home, '.local', 'share', 'Steam'),
      p.join(home, '.var', 'app', 'com.valvesoftware.Steam', '.local', 'share',
          'Steam'),
    ];

/// Every Steam library on a Linux machine: the client's own folders under
/// [home] plus whatever its `libraryfolders.vdf` registers. A second
/// library on a roomier drive (`/mnt/games/SteamLibrary`) is unguessable
/// from [home] alone, and Proton keeps a game's prefix - which is where
/// the Windows game's saves live - in the library the game was installed
/// into, so a shelf moved off the home drive takes its user data with it.
Future<List<String>> linuxSteamLibraries(String home) =>
    steamLibraries(steamRootsOverride: linuxSteamRoots(home));

/// The Program Files roots to look in, both architectures. The environment
/// variables come first so a Windows installed on another drive works.
Set<String> programFilesRoots({List<String>? override}) =>
    override?.toSet() ??
    [
      Platform.environment['ProgramFiles(x86)'],
      Platform.environment['ProgramFiles'],
      r'C:\Program Files (x86)',
      r'C:\Program Files',
    ].whereType<String>().toSet();

/// Steam libraries on this machine, read out of Steam's own
/// `libraryfolders.vdf`. Steam only keeps its default library beside the
/// client; a second one on a roomier drive is registered in that file and
/// is otherwise unguessable.
Future<List<String>> steamLibraries({List<String>? steamRootsOverride}) async {
  final roots = steamRootsOverride ??
      [
        for (final root in programFilesRoots()) p.join(root, 'Steam'),
        for (final drive in await windowsDriveRoots()) ...[
          p.join(drive, 'Steam'),
          p.join(drive, 'SteamLibrary'),
        ],
        if (Platform.environment['HOME'] case final home?) ...[
          ...linuxSteamRoots(home),
          p.join(home, 'Library', 'Application Support', 'Steam'),
        ],
      ];
  final found = <String>[];
  for (final root in roots) {
    if (!await Directory(root).exists()) continue;
    found.add(root); // Steam's own folder is always a library.
    for (final vdf in [
      // Current Steam keeps it in config/; older clients in steamapps/.
      File(p.join(root, 'config', 'libraryfolders.vdf')),
      File(p.join(root, 'steamapps', 'libraryfolders.vdf')),
    ]) {
      String text;
      try {
        if (!await vdf.exists()) continue;
        text = await vdf.readAsString();
      } on FileSystemException {
        continue;
      }
      // Deliberately not a VDF parser: the library paths are the only
      // thing wanted out of the file, and they are the only "path" keys
      // in it. Windows paths come out doubly escaped.
      for (final match in RegExp(r'"path"\s*"([^"]*)"').allMatches(text)) {
        found.add(match.group(1)!.replaceAll(r'\\', r'\'));
      }
    }
  }
  // The default library is both a probed root and its own entry in the file.
  return found.toSet().toList();
}

/// Drive roots that exist right now (`C:\`, `D:\`, ...); empty off Windows.
/// Dart has no drive-enumeration API, so probe the letters - an unmapped
/// letter or an empty optical drive just doesn't exist.
Future<List<String>> windowsDriveRoots() async {
  if (!Platform.isWindows) return const [];
  final found = <String>[];
  for (var letter = 'C'.codeUnitAt(0); letter <= 'Z'.codeUnitAt(0); letter++) {
    final root = '${String.fromCharCode(letter)}:\\';
    if (await Directory(root).exists()) found.add(root);
  }
  return found;
}

/// First-level folders the scan below never needs to walk into: they hold
/// no games and some of them (profiles, OneDrive placeholders) cost real
/// time to enumerate.
const _unscannedFolders = {
  r'$recycle.bin',
  'system volume information',
  'windows',
  'programdata',
  'appdata',
  'users',
  'onedrive',
  'proc',
  'sys',
  'dev',
};

/// A hung network drive must not hang the library behind it; whatever the
/// scan has found by then is good enough.
const _scanTimeout = Duration(seconds: 10);

/// Folder levels below a scan root to look at. Three, so that a bundled
/// download's own folder (`C:\Games\<bundle>\<game>`) is still reached.
const _scanDepth = 3;

final _installScans = <String, Future<List<Directory>>>{};

/// Game installs found by their own files instead of a known path, for the
/// games whose mods live in the install folder. Launchers put games under
/// Program Files, but an install can sit anywhere - a second drive, a
/// custom Steam library, a folder the user moved by hand - so probe a
/// bounded set of roots and keep whatever [signature] recognizes:
///
/// - every Steam library Steam itself lists, at `steamapps/common`
/// - each drive root on Windows, the home folder elsewhere
///
/// [_scanDepth] levels deep, which is what reaches the real layouts:
/// `D:\<game>`, `D:\EA Games\<game>`, and the bundled downloads that put
/// the game inside their own folder inside a games folder
/// (`C:\Games\<bundle>\<game>`). Anything more buried is what the manual
/// folder picker in Settings is for.
///
/// Memoized per [cacheKey] for the run: it's the slow path, only reached
/// when the known locations come up empty, and installs don't move while
/// the app is open - a game installed mid-session shows up on restart.
Future<List<Directory>> scanForInstalls(
  String cacheKey,
  InstallSignature signature, {
  List<String>? rootsOverride,
}) {
  if (rootsOverride != null) return _scanForInstalls(signature, rootsOverride);
  return _installScans.putIfAbsent(cacheKey, () {
    // The walk fills [found] as it goes, so hitting the timeout hands
    // over the installs located so far instead of discarding them. A
    // snapshot, because the abandoned walk keeps appending behind it.
    final found = <Directory>[];
    return _scanRoots()
        .then((roots) => _scanForInstalls(signature, roots, into: found))
        .timeout(_scanTimeout, onTimeout: () => List.of(found));
  });
}

Future<List<String>> _scanRoots() async => [
      for (final library in await steamLibraries())
        p.join(library, 'steamapps', 'common'),
      ...await windowsDriveRoots(),
      if (!Platform.isWindows)
        if (Platform.environment['HOME'] case final home?) home,
    ];

Future<List<Directory>> _scanForInstalls(
    InstallSignature signature, List<String> roots,
    {List<Directory>? into}) async {
  final found = into ?? <Directory>[];
  final seen = <String>{};

  Future<void> visit(Directory dir, int depth) async {
    if (!seen.add(p.canonicalize(dir.path))) return;
    if (await signature(dir)) {
      found.add(dir); // An install holds no other install.
      return;
    }
    if (depth == 0) return;
    try {
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is! Directory) continue;
        if (_unscannedFolders.contains(p.basename(entity.path).toLowerCase())) {
          continue;
        }
        await visit(entity, depth - 1);
      }
    } on FileSystemException {
      // Unreadable folder: not somewhere the user installed a game.
    }
  }

  for (final root in roots) {
    await visit(Directory(root), _scanDepth);
  }
  return found;
}
