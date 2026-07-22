import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/game.dart';
import '../../core/game_adapter.dart';

/// Adapters for the four mainline Sims games. They differ only in where
/// the mods folder lives and which file types the game loads, so each one
/// is a thin subclass of [FolderBasedGameAdapter].
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
/// The game folder name is localized per game language — "The Sims 3",
/// "Los Sims 3" and "Die Sims 3" are all real — so instead of expecting an
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

  @override
  String get setupHelp =>
      'The Sims 3 does not create a mods folder on its own — it needs the '
      'community "framework": a Mods > Packages folder inside '
      'Documents > Electronic Arts > The Sims 3, plus a '
      'Resource.cfg file that tells the game to read it. This app can '
      'create both for you. On disc/Wine installs the folder can live '
      'inside the app bundle instead — use "Choose folder" to point at it.';

  /// The standard Sims 3 framework (per NRaas/TSR): Resource.cfg lives in
  /// the Mods folder and points the game at Packages/, up to five levels
  /// of subfolders deep.
  @override
  Future<void> scaffoldModsDirectory(Directory modsDir) async {
    // modsDir is <game>/Mods/Packages — the cfg belongs in Mods.
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
  Set<String> get modFileExtensions => const {'.iff', '.far', '.skn', '.bmp'};

  @override
  Map<String, String> get categoryByExtension => const {
        '.iff': 'Object',
        '.far': 'Archive',
        '.skn': 'Skin',
        '.bmp': 'Texture',
      };

  @override
  String get setupHelp =>
      'The original The Sims keeps custom content inside its install '
      'folder, not Documents: a Downloads folder next to the game '
      'executable (e.g. C:\\Program Files (x86)\\Maxis\\The Sims\\Downloads). '
      'Skins (.skn/.bmp) go in GameData\\Skins instead. The 2025 Legacy '
      'Collection works the same way from its own install folder '
      '(EA Games\\The Sims Legacy, or Steam\\steamapps\\common\\'
      'The Sims Legacy Collection). If the game is installed somewhere '
      'else — a different drive, a custom Steam library — pick its '
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
        p.join(root, 'Steam', 'steamapps', 'common',
            'The Sims Legacy Collection'),
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
}
