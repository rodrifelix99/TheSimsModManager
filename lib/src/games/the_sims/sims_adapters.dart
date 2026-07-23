import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/game.dart';
import '../../core/game_adapter.dart';
import '../../core/mod.dart';
import '../../core/mod_archive.dart';

/// Adapters for the four mainline Sims games and The Sims Medieval.
/// They differ only in where the mods folder lives and which file types
/// the game loads, so each one is a thin subclass of
/// [FolderBasedGameAdapter].
///
/// Folder resolution is a best-effort guess at the default install/user-data
/// locations, tolerant of localized folder names ("Los Sims 3", "Die Sims 2")
/// and of multiple copies of a game each with its own user-data folder.
/// A per-game user override in settings is the escape hatch when every
/// guess is wrong (custom install drives, OneDrive-relocated Documents,
/// Wine prefixes, …).

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

/// Shared behavior for the Sims games that keep user data under
/// `Documents/<vendor>/<game>` (Sims 2, 3 and 4).
///
/// The game folder name is localized per game language ("The Sims 3",
/// "Los Sims 3" and "Die Sims 3" are all real), so instead of expecting an
/// exact name we scan the vendor folder for anything that looks like this
/// game and rank exact-looking names first.
abstract class DocumentsSimsAdapter extends FolderBasedGameAdapter {
  const DocumentsSimsAdapter({this.documentsOverride});

  /// Test hook: pretend this is the user's Documents folder.
  final Directory? documentsOverride;

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

  /// User-data folders for this game, best match first.
  Future<List<Directory>> gameDataFolders() async {
    final docs = await documentsDir(override: documentsOverride);
    if (docs == null) return const [];
    final found = <Directory>[];
    for (final vendor in vendorFolders) {
      final parent = Directory(p.join(docs.path, vendor));
      if (!await parent.exists()) continue;
      await for (final entity in parent.list()) {
        if (entity is Directory && matchesGameFolder(p.basename(entity.path))) {
          found.add(entity);
        }
      }
    }
    // Exact canonical name first, then shorter (plainer) names.
    found.sort((a, b) {
      final an = p.basename(a.path), bn = p.basename(b.path);
      final aExact = an == canonicalFolderName ? 0 : 1;
      final bExact = bn == canonicalFolderName ? 0 : 1;
      if (aExact != bExact) return aExact - bExact;
      return an.length.compareTo(bn.length);
    });
    return found;
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
  const Sims4Adapter({super.documentsOverride});

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
  String get setupHelp =>
      'The Sims 4 loads mods from Documents > Electronic Arts >'
      ' The Sims 4 > Mods. The game creates this folder the '
      'first time it runs, so launch the game once if it is missing. '
      'Then, in the game, turn on Options > Game Options >'
      ' Other > "Enable Custom Content and Mods" (and "Script '
      'Mods Allowed" for .ts4script files) and restart the game.';

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
}

class Sims3Adapter extends DocumentsSimsAdapter {
  const Sims3Adapter({super.documentsOverride});

  @override
  Game get game =>
      const Game(id: 'sims3', name: 'The Sims 3', series: _series, year: 2009);

  @override
  Set<String> get modFileExtensions => const {'.package'};

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
  String get setupHelp =>
      'The Sims 3 does not create a mods folder on its own: it needs the '
      'community "framework": a Mods > Packages folder inside '
      'Documents > Electronic Arts > The Sims 3, plus a '
      'Resource.cfg file that tells the game to read it. This app can '
      'create both for you. On disc/Wine installs the folder can live '
      'inside the app bundle instead; use "Choose folder" to point at it.';

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
}

class Sims2Adapter extends DocumentsSimsAdapter {
  const Sims2Adapter({super.documentsOverride});

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
  String get setupHelp =>
      'The Sims 2 loads custom content from Documents > EA Games >'
      ' The Sims 2 > Downloads (the Ultimate Collection uses '
      '"The Sims 2 Ultimate Collection"; the 2025 Legacy Collection uses '
      '"The Sims 2 Legacy"). The folder may not exist until '
      'you create it or install content once. When the game starts, answer '
      '"Yes" to the custom content prompt so downloads are enabled.';
}

/// The Sims Medieval (2011) forked the Sims 3 engine *before* EA moved the
/// mod framework into Documents, so it still uses the old install-folder
/// framework: mods live in `<install>/Mods/Packages` and a `Resource.cfg`
/// in the install root tells the game to read them. The Documents folder
/// (`Documents/Electronic Arts/The Sims Medieval`) only holds saves and
/// caches; packages placed there do nothing. Pirates & Nobles patches the
/// same install in place, so one Mods folder serves both.
class SimsMedievalAdapter extends FolderBasedGameAdapter {
  const SimsMedievalAdapter(
      {this.programFilesOverride, this.homeOverride, this.documentsOverride});

  /// Test hook: pretend these are the Program Files roots to scan.
  final List<String>? programFilesOverride;

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
  String get setupHelp =>
      'The Sims Medieval loads mods from its install folder, not '
      'Documents: a Mods > Packages folder next to the game files (e.g. '
      'C:\\Program Files (x86)\\Origin Games\\The Sims Medieval), plus a '
      'Resource.cfg file in the install folder that tells the game to '
      'read it. This app can create both for you (Windows may ask for '
      'administrator rights under Program Files). The Documents >'
      ' Electronic Arts > The Sims Medieval folder only holds saves; '
      'mods placed there do nothing. For Wine/CrossOver installs or a '
      'custom Steam library, use "Choose folder" to point at the '
      'Mods > Packages folder inside the game install.';

  /// Disc installs use localized folder names ("Die Sims Mittelalter"),
  /// so under the Electronic Arts vendor folder we verify candidates by
  /// the game's own signature file instead of the folder name (this also
  /// keeps disc installs of The Sims 3 out).
  static Future<bool> _looksLikeInstall(Directory dir) =>
      File(p.join(dir.path, 'Game', 'Bin', 'TSM.exe')).exists();

  /// Install directories on this machine: fixed English-named locations
  /// (Origin/EA App, Steam on Windows, native Steam libraries on Linux)
  /// plus a signature-checked scan of `Electronic Arts` for disc installs.
  Future<List<Directory>> _installCandidates() async {
    final found = <Directory>[];
    final programFiles = programFilesOverride?.toSet() ??
        [
          Platform.environment['ProgramFiles(x86)'],
          Platform.environment['ProgramFiles'],
          r'C:\Program Files (x86)',
          r'C:\Program Files',
        ].whereType<String>().toSet();
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
      await for (final entity in vendor.list()) {
        if (entity is Directory && await _looksLikeInstall(entity)) {
          found.add(entity);
        }
      }
    }
    // Steam Play/Proton installs the Windows game into the *native*
    // Linux Steam library (only the saves live inside the prefix).
    final home = homeOverride ?? Platform.environment['HOME'];
    if (home != null) {
      for (final library in [
        p.join(home, '.steam', 'steam'),
        p.join(home, '.local', 'share', 'Steam'),
      ]) {
        final dir = Directory(
            p.join(library, 'steamapps', 'common', 'The Sims Medieval'));
        if (await dir.exists()) found.add(dir);
      }
    }
    return found;
  }

  @override
  Future<List<Directory>> findModsDirectoryCandidates() async {
    final result = <Directory>[];
    for (final install in await _installCandidates()) {
      final mods = Directory(p.join(install.path, 'Mods', 'Packages'));
      if (await mods.exists()) result.add(mods);
    }
    return result;
  }

  @override
  Future<String?> defaultModsPath() async {
    final installs = await _installCandidates();
    if (installs.isEmpty) return null; // Not installed: nowhere sensible.
    return p.join(installs.first.path, 'Mods', 'Packages');
  }

  @override
  Future<Directory?> findGameFolder() async {
    final installs = await _installCandidates();
    return installs.isEmpty ? null : installs.first;
  }

  /// Caches that must be deleted after CC changes for the new content to
  /// show up. Unlike the mods, these live in the *Documents* user-data
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
    await for (final entity in vendor.list()) {
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
}

/// The original The Sims routes custom content by file type (per the
/// classic community guides — parsimonious.org "Adding Downloads", SiMania
/// "What Goes Where"), all relative to the install folder:
///
/// - objects (.iff/.far) → `Downloads` (subfolders fine)
/// - skins (.skn/.cmx/.bmp) → `GameData\Skins`, **flat** (the game does
///   not read subfolders there); buyable clothing (mesh names starting
///   L/S/W/H/F instead of B/C) → `ExpansionShared\SkinsBuy`, also flat
/// - walls (.wll) → `GameData\Walls`, floors (.flr) → `GameData\Floors`
///
/// The "mods folder" the app resolves/overrides is still `Downloads`; the
/// sibling folders are derived from it, and only when its parent really
/// looks like a Sims install (has a `GameData` folder) — a custom override
/// pointing anywhere else falls back to plain single-folder behavior.
/// The stock game keeps its own assets inside .far archives, so loose
/// files in these folders are custom content and safe to list as mods.
class Sims1Adapter extends FolderBasedGameAdapter {
  const Sims1Adapter({this.installOverride, this.programFilesOverride});

  /// Test hook / future settings hook: explicit install folder.
  final Directory? installOverride;

  /// Test hook: pretend these are the Program Files roots to scan.
  final List<String>? programFilesOverride;

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
  String get setupHelp =>
      'The original The Sims keeps custom content inside its install '
      'folder, not Documents: objects go in a Downloads folder next to '
      'the game executable (e.g. C:\\Program Files (x86)\\Maxis\\The Sims\\'
      'Downloads), and this app sorts the other types automatically — '
      'skins (.skn/.cmx/.bmp) into GameData\\Skins, walls and floors into '
      'GameData\\Walls and GameData\\Floors. The 2025 Legacy Collection '
      'works the same way from its own install folder (EA Games\\'
      'The Sims Legacy, or Steam\\steamapps\\common\\'
      'The Sims Legacy Collection). If the game is installed somewhere '
      'else (a different drive, a custom Steam library), pick its '
      'Downloads folder manually.';

  /// The Sims 1 lives in the install directory, so scan the usual ones:
  /// the classic disc/Complete Collection path plus the 2025 Legacy
  /// Collection's EA App and Steam locations.
  List<String> get _installCandidates {
    final override = installOverride;
    if (override != null) return [override.path];
    final programFiles = programFilesOverride?.toSet() ??
        [
          Platform.environment['ProgramFiles(x86)'],
          Platform.environment['ProgramFiles'],
          r'C:\Program Files (x86)',
          r'C:\Program Files',
        ].whereType<String>().toSet();
    return [
      for (final root in programFiles) ...[
        p.join(root, 'Maxis', 'The Sims'),
        p.join(root, 'EA Games', 'The Sims Legacy'),
        p.join(
            root, 'Steam', 'steamapps', 'common', 'The Sims Legacy Collection'),
      ],
    ];
  }

  @override
  Future<List<Directory>> findModsDirectoryCandidates() async {
    final result = <Directory>[];
    for (final install in _installCandidates) {
      final downloads = Directory(p.join(install, 'Downloads'));
      if (await downloads.exists()) result.add(downloads);
    }
    return result;
  }

  @override
  Future<String?> defaultModsPath() async {
    for (final install in _installCandidates) {
      if (await Directory(install).exists()) {
        return p.join(install, 'Downloads');
      }
    }
    return null; // Game not installed: nowhere sensible to create it.
  }

  @override
  Future<Directory?> findGameFolder() async {
    for (final install in _installCandidates) {
      final dir = Directory(install);
      if (await dir.exists()) return dir;
    }
    return null;
  }

  /// File types that belong in a skins folder. A skin is a trio: the
  /// .bmp texture, the .cmx animation link and the .skn mesh — all three
  /// must land together or the Sim shows up invisible in game.
  static const _skinExtensions = {'.skn', '.cmx', '.bmp'};

  /// Buyable clothing (sold in community clothing stores) uses mesh
  /// names starting with L/S/W/H/F plus the age/body code digits
  /// ("l200fa…"); everyday wear starts with B, heads with C. Mesh .skn
  /// files carry an "xskin-" prefix before the same name.
  static final _buyableName = RegExp(r'^(xskin-)?[lswhf]\d{3}');

  /// The install root [modsDir] (the Downloads folder) sits in, or null
  /// when its parent doesn't look like a Sims install — e.g. the user
  /// pointed the app at an arbitrary folder — in which case everything
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
      final wanted = modFileExtensions.join(', ');
      throw FormatException(
          'No mod files ($wanted) found inside ${p.basename(source.path)}.');
    }
    // Relative to the folder's *parent* so the folder name itself is kept
    // for the files that stay in Downloads.
    return _installRoutedFiles(modsDir, root, files, source.parent.path);
  }

  /// Copies [files] into their per-type folders. Files bound for
  /// Downloads keep their path relative to [from]; the routed folders
  /// are flat (the game ignores their subfolders).
  Future<List<Mod>> _installRoutedFiles(
      Directory modsDir, Directory root, List<File> files, String from) async {
    final mods = <Mod>[];
    for (final file in files) {
      final targetDir = _targetDirFor(modsDir, root, p.basename(file.path));
      final target = p.equals(targetDir.path, modsDir.path)
          ? p.join(modsDir.path, p.relative(file.path, from: from))
          : p.join(targetDir.path, p.basename(file.path));
      await File(target).parent.create(recursive: true);
      final copied = await file.copy(target);
      mods.add(toMod(copied)!);
    }
    return mods;
  }
}
