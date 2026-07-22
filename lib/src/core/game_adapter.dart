import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import 'game.dart';
import 'mod.dart';
import 'package_thumbnail.dart';

/// Suffix appended to a mod file to hide it from the game without deleting it.
const disabledSuffix = '.disabled';

/// Everything the manager needs to know to handle mods for one game.
///
/// This is the extension point of the whole app: to support a new game,
/// implement this interface (usually by extending [FolderBasedGameAdapter])
/// and register the adapter in [GameRegistry]. Nothing outside `src/games/`
/// should ever reference a concrete game.
abstract class GameAdapter {
  Game get game;

  /// File extensions this game accepts as mods (lowercase, with dot),
  /// e.g. `{'.package', '.ts4script'}`.
  Set<String> get modFileExtensions;

  /// Human-readable guidance shown when the mods folder can't be found:
  /// where the folder normally lives and what the game needs before it
  /// loads mods (in-game options, framework files, …).
  String get setupHelp;

  /// Best-guess mods directory on this machine, or `null` if the game
  /// (or its mods folder) can't be located. The user can override this
  /// per game in settings.
  Future<Directory?> resolveModsDirectory();

  /// The path where this game's mods folder is *expected* to live, even
  /// when it doesn't exist yet — so the app can offer to create it.
  /// `null` when there is no way to guess (game not installed and no
  /// conventional location).
  Future<String?> defaultModsPath();

  /// Every plausible mods folder on this machine. Users can have several
  /// copies of a game (or localized folder names such as "Los Sims 3"),
  /// each with its own mods folder; [resolveModsDirectory] picks the
  /// first, this lists them all so the user can choose.
  Future<List<Directory>> findModsDirectoryCandidates();

  /// The game's own folder (user data or install directory) when it can
  /// be located, even if the mods folder inside it doesn't exist yet —
  /// lets the UI tell "game not found" apart from "game found, mods
  /// folder missing". `null` when the game itself can't be found.
  Future<Directory?> findGameFolder();

  /// Creates the mods folder at [path], including any scaffolding the game
  /// needs before it loads mods from it (e.g. `Resource.cfg` for Sims 3).
  Future<Directory> createModsDirectory(String path);

  /// Coarse content-type label for a mod file extension (lowercase, with
  /// dot), e.g. `.ts4script` → `Script`.
  String categoryForExtension(String extension);

  Future<List<Mod>> listMods(Directory modsDir);

  /// Copies [source] into [modsDir].
  Future<Mod> installMod(Directory modsDir, File source);

  Future<void> removeMod(Mod mod);

  /// Enables or disables [mod] and returns its new state.
  Future<Mod> setEnabled(Mod mod, {required bool enabled});

  /// Artwork found inside the mod file (PNG/JPEG/BMP bytes) for the UI
  /// to show as the mod's thumbnail, or `null` when the file carries
  /// none. Best-effort: must never throw.
  Future<Uint8List?> loadThumbnail(Mod mod);
}

/// Default implementation for games whose mods are plain files in a folder —
/// which is every Sims game. Disabling works by appending [disabledSuffix]
/// to the file name so the game's loader skips it.
///
/// Subclasses supply [game], [modFileExtensions], [setupHelp], and
/// [defaultModsPath]; everything else has a sensible default. Override
/// [findModsDirectoryCandidates] when the game can live in several places,
/// and [scaffoldModsDirectory] when the game needs extra files (like a
/// `Resource.cfg`) before it reads the folder.
abstract class FolderBasedGameAdapter implements GameAdapter {
  const FolderBasedGameAdapter();

  /// Extension → category label used by [categoryForExtension].
  Map<String, String> get categoryByExtension => const {};

  @override
  String categoryForExtension(String extension) =>
      categoryByExtension[extension.toLowerCase()] ?? 'Package';

  @override
  Future<Directory?> resolveModsDirectory() async {
    final candidates = await findModsDirectoryCandidates();
    return candidates.isEmpty ? null : candidates.first;
  }

  @override
  Future<List<Directory>> findModsDirectoryCandidates() async {
    final path = await defaultModsPath();
    if (path == null) return const [];
    final dir = Directory(path);
    return await dir.exists() ? [dir] : const [];
  }

  /// Subclasses that can locate the game itself should override this so
  /// the UI can report "mods folder missing" instead of "game not found".
  @override
  Future<Directory?> findGameFolder() async => null;

  @override
  Future<Directory> createModsDirectory(String path) async {
    final dir = await Directory(path).create(recursive: true);
    await scaffoldModsDirectory(dir);
    return dir;
  }

  /// Hook for game-specific setup files the loader needs. Default: none.
  Future<void> scaffoldModsDirectory(Directory modsDir) async {}

  @override
  Future<List<Mod>> listMods(Directory modsDir) async {
    if (!await modsDir.exists()) return const [];
    final mods = <Mod>[];
    await for (final entity in modsDir.list(recursive: true)) {
      if (entity is! File) continue;
      final mod = _toMod(entity);
      if (mod != null) mods.add(mod);
    }
    mods.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return mods;
  }

  @override
  Future<Mod> installMod(Directory modsDir, File source) async {
    await modsDir.create(recursive: true);
    final target = p.join(modsDir.path, p.basename(source.path));
    final copied = await source.copy(target);
    return _toMod(copied)!;
  }

  @override
  Future<void> removeMod(Mod mod) => File(mod.path).delete();

  @override
  Future<Mod> setEnabled(Mod mod, {required bool enabled}) async {
    if (mod.isEnabled == enabled) return mod;
    final newPath = enabled
        ? mod.path.substring(0, mod.path.length - disabledSuffix.length)
        : '${mod.path}$disabledSuffix';
    final renamed = await File(mod.path).rename(newPath);
    return _toMod(renamed)!;
  }

  /// Mod file extensions that *are* plain images (Sims 1 `.bmp` skins):
  /// the file itself is its own thumbnail.
  static const _imageExtensions = {'.bmp', '.png', '.jpg', '.jpeg'};

  @override
  Future<Uint8List?> loadThumbnail(Mod mod) async {
    final path = mod.path;
    final isImage =
        _imageExtensions.contains(p.extension(mod.name).toLowerCase());
    try {
      // Parsing happens in an isolate: packages can be large, and the
      // library scrolls past dozens of them at once.
      return await Isolate.run(() {
        if (isImage) return File(path).readAsBytesSync();
        // Non-DBPF files (.iff, .far, .ts4script…) fail the magic check
        // inside and come back null almost for free.
        return extractPackageThumbnail(File(path));
      });
    } catch (_) {
      return null;
    }
  }

  /// Maps a file to a [Mod], or `null` if it isn't a mod file for this game.
  Mod? _toMod(File file) {
    var name = p.basename(file.path);
    var status = ModStatus.enabled;
    if (name.toLowerCase().endsWith(disabledSuffix)) {
      name = name.substring(0, name.length - disabledSuffix.length);
      status = ModStatus.disabled;
    }
    final extension = p.extension(name).toLowerCase();
    if (!modFileExtensions.contains(extension)) {
      return null;
    }
    final stat = file.statSync();
    return Mod(
      name: name,
      path: file.path,
      status: status,
      sizeBytes: stat.type == FileSystemEntityType.notFound ? null : stat.size,
      category: categoryForExtension(extension),
      modifiedAt:
          stat.type == FileSystemEntityType.notFound ? null : stat.modified,
    );
  }
}
