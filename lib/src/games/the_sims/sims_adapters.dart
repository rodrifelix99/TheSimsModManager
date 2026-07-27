import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/app_message.dart';
import '../../core/game.dart';
import '../../core/game_adapter.dart';
import '../../core/install_path.dart';
import '../../core/mod.dart';
import '../../core/mod_archive.dart';
import '../../core/resource_cfg.dart';
import 'sims3pack.dart';

/// Adapters for the four mainline Sims games and The Sims Medieval.
/// The Documents games (Sims 2/3/4) share [DocumentsSimsAdapter]; the
/// install-folder games (The Sims, The Sims Medieval) share
/// [InstallFolderSimsAdapter], with Sims 1 adding its per-type install
/// routing on top.
///
/// Folder resolution is a best-effort guess at the default install/user-data
/// locations, tolerant of localized folder names ("Los Sims 3", "Die Sims 2")
/// and of multiple copies of a game each with its own user-data folder.
/// A per-game user override in settings is the escape hatch when every
/// guess is wrong (custom install drives, OneDrive-relocated Documents,
/// Wine prefixes, ...).

const _series = 'The Sims';

/// The user's Documents folder, where Sims 2/3/4 keep their user data.
Future<Directory?> documentsDir({Directory? override}) async {
  if (override != null) return await override.exists() ? override : null;
  final home = Platform.environment['USERPROFILE'] ?? // Windows
      Platform.environment['HOME']; // macOS / Linux
  if (home == null) return null;
  final docs = Directory(p.join(home, 'Documents'));
  return await docs.exists() ? docs : null;
}

/// Documents folders inside Wine/Proton prefixes under [home], for the
/// Windows games run through a compatibility layer on Linux (Steam Deck).
/// Each prefix holds a fake Windows home, so the Sims user data lives at
/// `<prefix>/drive_c/users/<user>/Documents/<vendor>/<game>` instead of
/// the native `~/Documents`. Covers the default prefix locations of the
/// common launchers (paths per the s4lt reference and launcher docs):
///
/// - Steam Proton: `<library>/steamapps/compatdata/<appid>/pfx`, for the
///   classic library locations plus the Flatpak Steam sandbox
/// - Heroic: `~/.config/heroic/prefixes/<game>[/pfx]` (also Flatpak and
///   the newer `~/Games/Heroic/Prefixes/default/<game>`)
/// - Lutris: `~/Games/<game>` (one prefix per game)
/// - plain Wine: `~/.wine`
Future<List<Directory>> winePrefixDocumentsDirs(String home) async {
  final prefixes = <Directory>[];

  Future<void> addChildren(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) return;
    // An unreadable folder costs its own prefixes, never the detection.
    await for (final entity in dir.list().handleError((Object _) {})) {
      if (entity is Directory) prefixes.add(entity);
    }
  }

  for (final library in linuxSteamRoots(home)) {
    await addChildren(p.join(library, 'steamapps', 'compatdata'));
  }
  await addChildren(p.join(home, '.config', 'heroic', 'prefixes'));
  await addChildren(p.join(home, '.var', 'app', 'com.heroicgameslauncher.hgl',
      'config', 'heroic', 'prefixes'));
  await addChildren(p.join(home, 'Games', 'Heroic', 'Prefixes', 'default'));
  await addChildren(p.join(home, 'Games'));
  prefixes.add(Directory(p.join(home, '.wine')));

  // The user folder inside a prefix is `steamuser` for Proton and the
  // login name for Wine, so enumerate instead of guessing names. Proton
  // and Heroic nest the actual prefix in a `pfx` subfolder; plain Wine
  // and Lutris don't - accept both layouts everywhere.
  final found = <Directory>[];
  final seen = <String>{};
  for (final prefix in prefixes) {
    for (final driveC in [
      p.join(prefix.path, 'drive_c'),
      p.join(prefix.path, 'pfx', 'drive_c'),
    ]) {
      final users = Directory(p.join(driveC, 'users'));
      if (!await users.exists()) continue;
      await for (final user in users.list().handleError((Object _) {})) {
        if (user is! Directory) continue;
        final docs = Directory(p.join(user.path, 'Documents'));
        if (!await docs.exists()) continue;
        // `~/.steam/steam` is usually a symlink to `~/.local/share/Steam`,
        // so the same prefix can be reached twice; dedupe on the real path.
        String key;
        try {
          key = await docs.resolveSymbolicLinks();
        } catch (_) {
          key = docs.path;
        }
        if (seen.add(key)) found.add(docs);
      }
    }
  }
  return found;
}

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

/// Shared behavior for the Sims games that keep user data under
/// `Documents/<vendor>/<game>` (Sims 2, 3 and 4).
///
/// The game folder name is localized per game language ("The Sims 3",
/// "Los Sims 3" and "Die Sims 3" are all real), so instead of expecting an
/// exact name we scan the vendor folder for anything that looks like this
/// game and rank exact-looking names first.
abstract class DocumentsSimsAdapter extends FolderBasedGameAdapter {
  const DocumentsSimsAdapter({this.documentsOverride, this.homeOverride});

  /// Test hook: pretend this is the user's Documents folder.
  final Directory? documentsOverride;

  /// Test hook: pretend this is the user's home (for the Wine/Proton
  /// prefix scan, which otherwise only runs on Linux).
  final String? homeOverride;

  /// Vendor folders to scan under Documents, e.g. `['Electronic Arts']`.
  List<String> get vendorFolders;

  /// Canonical (English) game folder name, used when nothing exists yet
  /// and we must propose a path to create.
  String get canonicalFolderName;

  /// The mainline entry number this adapter matches ("2", "3", "4").
  String get gameNumber;

  /// Path of the mods folder inside the game's user-data folder,
  /// e.g. `['Mods', 'Packages']`.
  List<String> get modsSegments;

  /// Cache files in the game's user-data folder that go stale when
  /// custom content changes; empty for games that manage their caches
  /// themselves (Sims 2/4).
  List<String> get cacheFileNames => const [];

  @override
  Future<List<File>> findCacheFiles() async {
    if (cacheFileNames.isEmpty) return const [];
    final found = <File>[];
    for (final gameDir in await gameDataFolders()) {
      for (final name in cacheFileNames) {
        final file = File(p.join(gameDir.path, name));
        if (await file.exists()) found.add(file);
      }
    }
    return found;
  }

  /// Whether [name] is this game's user-data folder in any language:
  /// it mentions "sims", ends with the game number (allowing "™" and
  /// spacing quirks), and isn't a side tool like "The Sims 3 Create a
  /// World Tool".
  bool matchesGameFolder(String name) {
    final normalized = name.toLowerCase().replaceAll('™', '').trim();
    if (!normalized.contains('sims')) return false;
    return RegExp('sims[^0-9]*$gameNumber(\\s|\$)').hasMatch(normalized) &&
        normalized.endsWith(gameNumber);
  }

  /// Documents folders to scan for user data: the native one plus, on
  /// Linux, any Wine/Proton prefix Documents (Steam Deck & co.), native
  /// first.
  Future<List<Directory>> _documentsDirs() async {
    final dirs = <Directory>[];
    final docs = await documentsDir(override: documentsOverride);
    if (docs != null) dirs.add(docs);
    final home = homeOverride ??
        (Platform.isLinux ? Platform.environment['HOME'] : null);
    if (home != null) dirs.addAll(await winePrefixDocumentsDirs(home));
    return dirs;
  }

  /// User-data folders for this game, best match first.
  Future<List<Directory>> gameDataFolders() async {
    final found = <Directory>[];
    for (final docs in await _documentsDirs()) {
      for (final vendor in vendorFolders) {
        final parent = Directory(p.join(docs.path, vendor));
        if (!await parent.exists()) continue;
        // An unreadable vendor folder must not take down the refresh.
        await for (final entity in parent.list().handleError((Object _) {})) {
          if (entity is Directory &&
              matchesGameFolder(p.basename(entity.path))) {
            found.add(entity);
          }
        }
      }
    }
    // Exact canonical name first, then shorter (plainer) names; on ties
    // keep the scan order, which puts the native Documents install ahead
    // of same-named prefix ones (List.sort alone isn't stable).
    final indexed = found.asMap().entries.toList();
    indexed.sort((a, b) {
      final an = p.basename(a.value.path), bn = p.basename(b.value.path);
      final aExact = an == canonicalFolderName ? 0 : 1;
      final bExact = bn == canonicalFolderName ? 0 : 1;
      if (aExact != bExact) return aExact - bExact;
      if (an.length != bn.length) return an.length.compareTo(bn.length);
      return a.key - b.key;
    });
    return [for (final entry in indexed) entry.value];
  }

  @override
  Future<List<Directory>> findModsDirectoryCandidates() async {
    final result = <Directory>[];
    for (final gameDir in await gameDataFolders()) {
      final mods = Directory(p.joinAll([gameDir.path, ...modsSegments]));
      if (await mods.exists()) result.add(mods);
    }
    return result;
  }

  @override
  Future<Directory?> findGameFolder() async {
    final dirs = await gameDataFolders();
    return dirs.isEmpty ? null : dirs.first;
  }

  @override
  Future<String?> defaultModsPath() async {
    final gameDirs = await gameDataFolders();
    if (gameDirs.isNotEmpty) {
      return p.joinAll([gameDirs.first.path, ...modsSegments]);
    }
    // Game folder not found: propose the conventional location so the
    // user can still scaffold it (the game recreates its folder anyway).
    final docs = await documentsDir(override: documentsOverride);
    if (docs == null) return null;
    return p.joinAll(
        [docs.path, vendorFolders.first, canonicalFolderName, ...modsSegments]);
  }
}

class Sims4Adapter extends DocumentsSimsAdapter {
  const Sims4Adapter({super.documentsOverride, super.homeOverride});

  @override
  Game get game =>
      const Game(id: 'sims4', name: 'The Sims 4', series: _series, year: 2014);

  @override
  Set<String> get modFileExtensions => const {'.package', '.ts4script'};

  @override
  Map<String, String> get categoryByExtension =>
      const {'.package': 'Package', '.ts4script': 'Script'};

  @override
  List<String> get vendorFolders => const ['Electronic Arts', 'EA Games'];

  @override
  String get canonicalFolderName => 'The Sims 4';

  @override
  String get gameNumber => '4';

  @override
  List<String> get modsSegments => const ['Mods'];

  @override
  String get setupHelpKey => 'sims4';

  /// The game generates this exact Resource.cfg on first launch; writing
  /// it up front makes a hand-created folder work immediately.
  @override
  Future<void> scaffoldModsDirectory(Directory modsDir) async {
    final cfg = File(p.join(modsDir.path, 'Resource.cfg'));
    if (await cfg.exists()) return;
    await cfg.writeAsString('Priority 500\n'
        'PackedFile *.package\n'
        'PackedFile */*.package\n'
        'PackedFile */*/*.package\n'
        'PackedFile */*/*/*.package\n'
        'PackedFile */*/*/*/*.package\n'
        'DirectoryFiles unpackedmod autoupdate\n');
  }

  @override
  File? resourceCfgFile(Directory modsDir) =>
      File(p.join(modsDir.path, 'Resource.cfg'));

  /// The game has its own two switches for this, in Game Options, and a
  /// patch resets them: mods off is the most common reason a Sims 4
  /// library does nothing. Both live in Options.ini next to the Mods
  /// folder, so the app can read what the game is set to.
  @override
  Future<List<String>> unmetRequirements(Directory modsDir) async {
    final options = File(p.join(modsDir.parent.path, 'Options.ini'));
    final settings = await readIniSettings(options);
    // No file yet means the game has not been run since the folder was
    // made; it writes its defaults (mods on) on first launch.
    if (settings == null) return const [];
    return [
      if (settings['modsdisabled'] == '1') 'sims4ModsOff',
      // Only worth raising when there are script mods to run.
      if (settings['scriptmodsenabled'] == '0' &&
          await _hasScriptMods(modsDir))
        'sims4ScriptModsOff',
    ];
  }

  Future<bool> _hasScriptMods(Directory modsDir) async {
    try {
      await for (final entity in modsDir.list(recursive: true).handleError(
        (Object _) {},
      )) {
        if (entity is File &&
            p.extension(entity.path).toLowerCase() == '.ts4script') {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }
}

class Sims3Adapter extends DocumentsSimsAdapter {
  const Sims3Adapter({super.documentsOverride, super.homeOverride});

  @override
  Game get game =>
      const Game(id: 'sims3', name: 'The Sims 3', series: _series, year: 2009);

  @override
  Set<String> get modFileExtensions => const {'.package'};

  /// The game's own container, alongside the formats every game takes.
  @override
  Set<String> get containerFileExtensions =>
      const {...archiveFileExtensions, sims3PackExtension};

  @override
  List<String> get vendorFolders => const ['Electronic Arts', 'EA Games'];

  @override
  String get canonicalFolderName => 'The Sims 3';

  @override
  String get gameNumber => '3';

  @override
  List<String> get modsSegments => const ['Mods', 'Packages'];

  /// The well-known stale caches (per NRaas/MTS guides): the game
  /// rebuilds them on launch, but new or removed CC only shows up
  /// reliably after they're deleted.
  @override
  List<String> get cacheFileNames => const [
        'CASPartCache.package',
        'compositorCache.package',
        'scriptCache.package',
        'simCompositorCache.package',
      ];

  @override
  String get setupHelpKey => 'sims3';

  /// The standard Sims 3 framework (per NRaas/TSR): Resource.cfg lives in
  /// the Mods folder and points the game at Packages/, up to five levels
  /// of subfolders deep.
  @override
  Future<void> scaffoldModsDirectory(Directory modsDir) async {
    // modsDir is <game>/Mods/Packages; the cfg belongs in Mods.
    final cfg = File(p.join(modsDir.parent.path, 'Resource.cfg'));
    if (await cfg.exists()) return;
    await cfg.writeAsString('Priority 500\n'
        'PackedFile Packages/*.package\n'
        'PackedFile Packages/*/*.package\n'
        'PackedFile Packages/*/*/*.package\n'
        'PackedFile Packages/*/*/*/*.package\n'
        'PackedFile Packages/*/*/*/*/*.package\n');
  }

  @override
  File? resourceCfgFile(Directory modsDir) =>
      File(p.join(modsDir.parent.path, 'Resource.cfg'));

  /// A sims3pack is unpacked by its own reader; everything else is one of
  /// the shared archive formats and goes the usual way.
  @override
  Future<List<Mod>> installArchive(Directory modsDir, File archive) async {
    if (!isSims3PackPath(archive.path)) {
      return super.installArchive(modsDir, archive);
    }
    await modsDir.create(recursive: true);
    final files = await extractSims3Pack(archive, modsDir, modFileExtensions);
    return [for (final file in files) toMod(file)!];
  }
}

class Sims2Adapter extends DocumentsSimsAdapter {
  const Sims2Adapter({super.documentsOverride, super.homeOverride});

  @override
  Game get game =>
      const Game(id: 'sims2', name: 'The Sims 2', series: _series, year: 2004);

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  List<String> get vendorFolders => const ['EA Games', 'Electronic Arts'];

  @override
  String get canonicalFolderName => 'The Sims 2';

  @override
  String get gameNumber => '2';

  @override
  List<String> get modsSegments => const ['Downloads'];

  /// Re-releases use folder names the number-suffix rule would miss:
  /// the Ultimate Collection ("The Sims 2 Ultimate Collection") and the
  /// 2025 Legacy Collection ("The Sims 2 Legacy" / "The Sims 2 Legacy
  /// Collection" depending on the installer), each with or without the
  /// trademark sign.
  @override
  bool matchesGameFolder(String name) {
    final normalized = name.toLowerCase().replaceAll('™', '');
    if (super.matchesGameFolder(name)) return true;
    if (!RegExp(r'sims[^0-9]*2(\s|$)').hasMatch(normalized)) return false;
    return normalized.contains('ultimate collection') ||
        normalized.contains('legacy');
  }

  @override
  String get setupHelpKey => 'sims2';
}

/// Shared resolution for the games whose mods live inside the install
/// folder itself: find the install directories, and the mods folder is a
/// fixed subpath ([modsSegments]) inside each. The known launcher
/// locations ([knownInstallLocations]) are checked first; only when all
/// of them come up empty does the wider signature scan
/// ([scanForInstalls]) run, because that is the slow path.
abstract class InstallFolderSimsAdapter extends FolderBasedGameAdapter {
  const InstallFolderSimsAdapter(
      {this.installOverride, this.programFilesOverride, this.scanRootsOverride});

  /// Test hook / future settings hook: explicit install folder.
  final Directory? installOverride;

  /// Test hook: pretend these are the Program Files roots to scan.
  final List<String>? programFilesOverride;

  /// Test hook: pretend these are the drives to scan for installs (pass an
  /// empty list to keep a test off the real machine's drives).
  final List<String>? scanRootsOverride;

  /// Path of the mods folder inside an install, e.g. `['Downloads']`.
  List<String> get modsSegments;

  /// Whether [dir] is an install of this game (see [InstallSignature]).
  Future<bool> looksLikeInstall(Directory dir);

  /// The fixed locations launchers put this game, checked before the
  /// signature scan is paid for.
  Future<List<Directory>> knownInstallLocations();

  /// Install directories on this machine, launcher locations first.
  Future<List<Directory>> installCandidates() async {
    final override = installOverride;
    if (override != null) return [override];
    final found = await knownInstallLocations();
    if (found.isEmpty) {
      found.addAll(await scanForInstalls(game.id, looksLikeInstall,
          rootsOverride: scanRootsOverride));
    }
    return found;
  }

  @override
  Future<List<Directory>> findModsDirectoryCandidates() async {
    final result = <Directory>[];
    for (final install in await installCandidates()) {
      final mods = Directory(p.joinAll([install.path, ...modsSegments]));
      if (await mods.exists()) result.add(mods);
    }
    return result;
  }

  @override
  Future<String?> defaultModsPath() async {
    final installs = await installCandidates();
    if (installs.isEmpty) return null; // Not installed: nowhere sensible.
    return p.joinAll([installs.first.path, ...modsSegments]);
  }

  @override
  Future<Directory?> findGameFolder() async {
    final installs = await installCandidates();
    return installs.isEmpty ? null : installs.first;
  }
}

/// The Sims Medieval (2011) forked the Sims 3 engine before EA moved the
/// mod framework into Documents, so it still uses the old install-folder
/// framework: mods live in `<install>/Mods/Packages` and a `Resource.cfg`
/// in the install root tells the game to read them. The Documents folder
/// (`Documents/Electronic Arts/The Sims Medieval`) only holds saves and
/// caches; packages placed there do nothing. Pirates & Nobles patches the
/// same install in place, so one Mods folder serves both.
class SimsMedievalAdapter extends InstallFolderSimsAdapter {
  const SimsMedievalAdapter(
      {super.programFilesOverride,
      this.homeOverride,
      this.documentsOverride,
      super.scanRootsOverride});

  /// Test hook: pretend this is the user's home (for Linux Steam libraries).
  final String? homeOverride;

  /// Test hook: pretend this is the user's Documents folder (where the
  /// stale cache files live).
  final Directory? documentsOverride;

  @override
  Game get game => const Game(
      id: 'simsmedieval',
      name: 'The Sims Medieval',
      series: _series,
      year: 2011);

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  String get setupHelpKey => 'simsmedieval';

  @override
  List<String> get modsSegments => const ['Mods', 'Packages'];

  /// Disc installs use localized folder names ("Die Sims Mittelalter"),
  /// so under the Electronic Arts vendor folder we verify candidates by
  /// the game's own signature file instead of the folder name (this also
  /// keeps disc installs of The Sims 3 out).
  @override
  Future<bool> looksLikeInstall(Directory dir) =>
      File(p.join(dir.path, 'Game', 'Bin', 'TSM.exe')).exists();

  /// Fixed English-named locations (Origin/EA App, Steam on Windows,
  /// native Steam libraries on Linux) plus a signature-checked scan of
  /// `Electronic Arts` for disc installs.
  @override
  Future<List<Directory>> knownInstallLocations() async {
    final found = <Directory>[];
    final programFiles = programFilesRoots(override: programFilesOverride);
    for (final root in programFiles) {
      for (final fixed in [
        p.join(root, 'Origin Games', 'The Sims Medieval'),
        p.join(root, 'Steam', 'steamapps', 'common', 'The Sims Medieval'),
      ]) {
        final dir = Directory(fixed);
        if (await dir.exists()) found.add(dir);
      }
      final vendor = Directory(p.join(root, 'Electronic Arts'));
      if (!await vendor.exists()) continue;
      // An unreadable vendor folder must not take down the refresh.
      await for (final entity in vendor.list().handleError((Object _) {})) {
        if (entity is Directory && await looksLikeInstall(entity)) {
          found.add(entity);
        }
      }
    }
    // Steam Play/Proton installs the Windows game into the native
    // Linux Steam library (only the saves live inside the prefix).
    final home = homeOverride ?? Platform.environment['HOME'];
    if (home != null) {
      for (final library in linuxSteamRoots(home)) {
        final dir = Directory(
            p.join(library, 'steamapps', 'common', 'The Sims Medieval'));
        if (await dir.exists()) found.add(dir);
      }
    }
    return found;
  }

  /// Caches that must be deleted after CC changes for the new content to
  /// show up. Unlike the mods, these live in the Documents user-data
  /// folder, whose name is localized like the disc installs.
  static const _cacheFileNames = [
    'CASPartCache.package',
    'compositorCache.package',
    'simCompositorCache.package',
  ];

  /// A numbered mainline game's user-data folder in any language
  /// ("Los Sims 3"): those hold the same cache file names but belong to
  /// their own adapters, so the Medieval scan must skip them.
  static final _numberedSims = RegExp(r'sims[^0-9]*[0-9]');

  /// The Documents folder name is localized ("Die Sims Mittelalter"), so
  /// instead of guessing names we scan the vendor folder for the cache
  /// files themselves; only Sims-3-engine games produce them, and the
  /// numbered ones are excluded above.
  @override
  Future<List<File>> findCacheFiles() async {
    final docs = await documentsDir(override: documentsOverride);
    if (docs == null) return const [];
    final vendor = Directory(p.join(docs.path, 'Electronic Arts'));
    if (!await vendor.exists()) return const [];
    final found = <File>[];
    await for (final entity in vendor.list().handleError((Object _) {})) {
      if (entity is! Directory) continue;
      final name = p.basename(entity.path).toLowerCase().replaceAll('™', '');
      if (_numberedSims.hasMatch(name)) continue;
      for (final cache in _cacheFileNames) {
        final file = File(p.join(entity.path, cache));
        if (await file.exists()) found.add(file);
      }
    }
    return found;
  }

  /// The community framework (per the TSM setup packs): Resource.cfg goes
  /// in the install root, a sibling of Mods, pointing at Mods/Packages up
  /// to four subfolder levels deep. Forward slashes are the engine's own
  /// path syntax, correct on Windows too.
  @override
  Future<void> scaffoldModsDirectory(Directory modsDir) async {
    // modsDir is <install>/Mods/Packages; the cfg belongs in <install>.
    final cfg = File(p.join(modsDir.parent.parent.path, 'Resource.cfg'));
    if (await cfg.exists()) return;
    await cfg.writeAsString('Priority 500\n'
        'DirectoryFiles Mods/Packages/... autoupdate\n'
        'PackedFile Mods/Packages/*.package\n'
        'PackedFile Mods/Packages/*/*.package\n'
        'PackedFile Mods/Packages/*/*/*.package\n'
        'PackedFile Mods/Packages/*/*/*/*.package\n'
        'PackedFile Mods/Packages/*/*/*/*/*.package\n');
  }

  @override
  File? resourceCfgFile(Directory modsDir) =>
      File(p.join(modsDir.parent.parent.path, 'Resource.cfg'));

  /// The game was never built to load mods. The community's way in is a
  /// proxy DLL next to the executable, and without it custom content
  /// still works while script and core mods quietly do nothing - so a
  /// library that looks perfectly healthy is half inert. Only checked
  /// against a real install: a custom mods folder somewhere else has no
  /// Game/Bin to look in.
  @override
  Future<List<String>> unmetRequirements(Directory modsDir) async {
    final root = modsDir.parent.parent;
    if (!await File(p.join(root.path, 'Game', 'Bin', 'TSM.exe')).exists()) {
      return const [];
    }
    final loader = File(p.join(root.path, 'Game', 'Bin', 'd3dx9_31.dll'));
    return await loader.exists() ? const [] : const ['medievalModLoader'];
  }
}

/// The original The Sims routes custom content by file type (per the
/// classic community guides - parsimonious.org "Adding Downloads", SiMania
/// "What Goes Where"), all relative to the install folder:
///
/// - objects (.iff/.far) -> `Downloads` (subfolders fine)
/// - skins (.skn/.cmx/.bmp) -> `GameData\Skins`, flat (the game does
///   not read subfolders there); buyable clothing (mesh names starting
///   L/S/W/H/F instead of B/C) -> `ExpansionShared\SkinsBuy`, also flat
/// - walls (.wll) -> `GameData\Walls`, floors (.flr) -> `GameData\Floors`
///
/// The "mods folder" the app resolves/overrides is still `Downloads`; the
/// sibling folders are derived from it, and only when its parent really
/// looks like a Sims install (has a `GameData` folder) - a custom override
/// pointing anywhere else falls back to plain single-folder behavior.
/// The stock game keeps its own assets inside .far archives, so loose
/// files in these folders are custom content and safe to list as mods.
class Sims1Adapter extends InstallFolderSimsAdapter {
  const Sims1Adapter(
      {super.installOverride,
      super.programFilesOverride,
      super.scanRootsOverride});

  @override
  Game get game =>
      const Game(id: 'sims1', name: 'The Sims', series: _series, year: 2000);

  @override
  Set<String> get modFileExtensions =>
      const {'.iff', '.far', '.skn', '.cmx', '.bmp', '.wll', '.flr'};

  @override
  Map<String, String> get categoryByExtension => const {
        '.iff': 'Object',
        '.far': 'Archive',
        '.skn': 'Skin',
        '.cmx': 'Skin',
        '.bmp': 'Texture',
        '.wll': 'Wall',
        '.flr': 'Floor',
      };

  @override
  String get setupHelpKey => 'sims1';

  @override
  List<String> get modsSegments => const ['Downloads'];

  /// The game ships its executable next to the GameData folder holding the
  /// stock content - true of every release, from the 2000 discs to the 2025
  /// Legacy Collection, wherever the folder ended up and whatever it's
  /// called. `Downloads` is deliberately not part of the signature: a fresh
  /// install has none, and creating it is the setup screen's job.
  @override
  Future<bool> looksLikeInstall(Directory dir) async =>
      await File(p.join(dir.path, 'Sims.exe')).exists() &&
      await Directory(p.join(dir.path, 'GameData')).exists();

  /// The classic disc/Complete Collection path plus the 2025 Legacy
  /// Collection's EA App and Steam locations.
  @override
  Future<List<Directory>> knownInstallLocations() async {
    final found = <Directory>[];
    for (final root in programFilesRoots(override: programFilesOverride)) {
      for (final fixed in [
        p.join(root, 'Maxis', 'The Sims'),
        p.join(root, 'EA Games', 'The Sims Legacy'),
        p.join(
            root, 'Steam', 'steamapps', 'common', 'The Sims Legacy Collection'),
      ]) {
        final dir = Directory(fixed);
        if (await dir.exists()) found.add(dir);
      }
    }
    return found;
  }

  /// File types that belong in a skins folder. A skin is a trio: the
  /// .bmp texture, the .cmx animation link and the .skn mesh - all three
  /// must land together or the Sim shows up invisible in game.
  static const _skinExtensions = {'.skn', '.cmx', '.bmp'};

  /// Buyable clothing (sold in community clothing stores) uses mesh
  /// names starting with L/S/W/H/F plus the age/body code digits
  /// ("l200fa..."); everyday wear starts with B, heads with C. Mesh .skn
  /// files carry an "xskin-" prefix before the same name.
  static final _buyableName = RegExp(r'^(xskin-)?[lswhf]\d{3}');

  /// The install root [modsDir] (the Downloads folder) sits in, or null
  /// when its parent doesn't look like a Sims install - e.g. the user
  /// pointed the app at an arbitrary folder - in which case everything
  /// installs into [modsDir] unrouted, like any other game.
  Future<Directory?> _installRootOf(Directory modsDir) async {
    final root = modsDir.parent;
    final gameData = Directory(p.join(root.path, 'GameData'));
    return await gameData.exists() ? root : null;
  }

  /// The folder [fileName] belongs in per its type. Skins folders are
  /// flat (the game ignores their subfolders), so callers must install
  /// by basename there; Downloads keeps archive structure.
  Directory _targetDirFor(Directory modsDir, Directory root, String fileName) {
    final extension = p.extension(fileName).toLowerCase();
    if (_skinExtensions.contains(extension)) {
      return Directory(p.joinAll([
        root.path,
        ...(_buyableName.hasMatch(fileName.toLowerCase())
            ? ['ExpansionShared', 'SkinsBuy']
            : ['GameData', 'Skins']),
      ]));
    }
    if (extension == '.wll') {
      return Directory(p.join(root.path, 'GameData', 'Walls'));
    }
    if (extension == '.flr') {
      return Directory(p.join(root.path, 'GameData', 'Floors'));
    }
    return modsDir;
  }

  /// Sibling folders that hold routed custom content, listed alongside
  /// Downloads so skins/walls/floors show in the library and can be
  /// disabled or removed like any mod.
  List<Directory> _routedContentDirs(Directory root) => [
        Directory(p.join(root.path, 'GameData', 'Skins')),
        Directory(p.join(root.path, 'GameData', 'Walls')),
        Directory(p.join(root.path, 'GameData', 'Floors')),
        Directory(p.join(root.path, 'ExpansionShared', 'SkinsBuy')),
      ];

  @override
  Future<List<Mod>> listMods(Directory modsDir) async {
    final mods = [...await super.listMods(modsDir)];
    final root = await _installRootOf(modsDir);
    if (root != null) {
      for (final dir in _routedContentDirs(root)) {
        mods.addAll(await super.listMods(dir));
      }
      mods.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    return mods;
  }

  @override
  Future<Mod> installMod(Directory modsDir, File source) async {
    final root = await _installRootOf(modsDir);
    if (root == null) return super.installMod(modsDir, source);
    final target = _targetDirFor(modsDir, root, p.basename(source.path));
    return super.installMod(target, source);
  }

  @override
  Future<List<Mod>> installArchive(Directory modsDir, File archive) async {
    final root = await _installRootOf(modsDir);
    if (root == null) return super.installArchive(modsDir, archive);
    // Unpack to a scratch folder first, then route each file. Downloads
    // keeps the archive's structure; the routed folders are flat.
    final scratch = await Directory.systemTemp.createTemp('sims1_install');
    try {
      final files = await extractModFiles(archive, scratch, modFileExtensions);
      return await _installRoutedFiles(modsDir, root, files, scratch.path);
    } finally {
      try {
        await scratch.delete(recursive: true);
      } catch (_) {} // Best-effort cleanup of our own temp folder.
    }
  }

  @override
  Future<List<Mod>> installFolder(Directory modsDir, Directory source) async {
    final root = await _installRootOf(modsDir);
    if (root == null) return super.installFolder(modsDir, source);
    final files = await modFilesIn(source);
    if (files.isEmpty) {
      throw ModContentException.noModFiles(
          modFileExtensions, p.basename(source.path));
    }
    // Relative to the folder's parent so the folder name itself is kept
    // for the files that stay in Downloads.
    return _installRoutedFiles(modsDir, root, files, source.parent.path);
  }

  /// Copies [files] into their per-type folders. Files bound for
  /// Downloads keep their path relative to [from]; the routed folders
  /// are flat (the game ignores their subfolders).
  Future<List<Mod>> _installRoutedFiles(
      Directory modsDir, Directory root, List<File> files, String from) async {
    final mods = <Mod>[];
    final taken = <String>{};
    for (final file in files) {
      final targetDir = _targetDirFor(modsDir, root, p.basename(file.path));
      final target = p.equals(targetDir.path, modsDir.path)
          ? claimInstallTarget(
              modsDir.path, p.relative(file.path, from: from), taken)
          // The routed folders are flat by design, so same-named files
          // overwrite each other there as they always have.
          : installTargetPath(targetDir.path, p.basename(file.path));
      await File(target).parent.create(recursive: true);
      final copied = await file.copy(target);
      mods.add(toMod(copied)!);
    }
    return mods;
  }
}
