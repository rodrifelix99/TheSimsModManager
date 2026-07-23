import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;

import 'game.dart';
import 'mod.dart';
import 'mod_archive.dart';
import 'package_insight.dart';

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
  /// when it doesn't exist yet, so the app can offer to create it.
  /// `null` when there is no way to guess (game not installed and no
  /// conventional location).
  Future<String?> defaultModsPath();

  /// Every plausible mods folder on this machine. Users can have several
  /// copies of a game (or localized folder names such as "Los Sims 3"),
  /// each with its own mods folder; [resolveModsDirectory] picks the
  /// first, this lists them all so the user can choose.
  Future<List<Directory>> findModsDirectoryCandidates();

  /// The game's own folder (user data or install directory) when it can
  /// be located, even if the mods folder inside it doesn't exist yet; this
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

  /// Unpacks [archive] (any format in [archiveFileExtensions]) into
  /// [modsDir] and returns the mod files it contained; everything else
  /// in the archive (readmes, screenshots) is skipped. Throws with a
  /// user-readable message when the archive can't be read or holds no
  /// mod files.
  Future<List<Mod>> installArchive(Directory modsDir, File archive);

  Future<void> removeMod(Mod mod);

  /// Enables or disables [mod] and returns its new state.
  Future<Mod> setEnabled(Mod mod, {required bool enabled});

  /// Cache files the game keeps that go stale when custom content is
  /// added or removed (e.g. Sims 3's `CASPartCache.package`); the game
  /// rebuilds them on its next launch, but until they're deleted new CC
  /// may not show up. Only files that currently exist are returned;
  /// games without such caches return an empty list.
  Future<List<File>> findCacheFiles();

  /// Deletes every file from [findCacheFiles] and returns what was
  /// deleted. Safe: the game regenerates these caches on launch.
  Future<List<File>> clearCaches();

  /// Looks inside every mod file for embedded artwork and a content
  /// summary, keyed by `mod.path`. Meant to run once per library load,
  /// off the UI thread; [onProgress] reports how many files have been
  /// inspected so far, and [onFound] delivers each batch's discoveries
  /// as they land (so the loading screen can show artwork mid-scan).
  /// Files that yield nothing are simply absent from the result. When
  /// [isCancelled] starts returning true the scan stops early (between
  /// batches) and returns whatever it has so far.
  /// Best-effort: must never throw.
  Future<Map<String, PackageInsight>> inspectMods(
    List<Mod> mods, {
    void Function(int done, int total)? onProgress,
    void Function(Map<String, PackageInsight> found)? onFound,
    bool Function()? isCancelled,
  });
}

/// Default implementation for games whose mods are plain files in a folder,
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

  /// Most games have no stale-cache problem; the ones that do (Sims 3,
  /// The Sims Medieval) override this with the well-known cache files.
  @override
  Future<List<File>> findCacheFiles() async => const [];

  @override
  Future<List<File>> clearCaches() async {
    final caches = await findCacheFiles();
    for (final file in caches) {
      await file.delete();
    }
    return caches;
  }

  @override
  Future<List<Mod>> listMods(Directory modsDir) async {
    if (!await modsDir.exists()) return const [];
    final mods = <Mod>[];
    await for (final entity in modsDir.list(recursive: true)) {
      if (entity is! File) continue;
      final mod = toMod(entity);
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
    return toMod(copied)!;
  }

  @override
  Future<List<Mod>> installArchive(Directory modsDir, File archive) async {
    await modsDir.create(recursive: true);
    final files = await extractModFiles(archive, modsDir, modFileExtensions);
    return [for (final file in files) toMod(file)!];
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
    return toMod(renamed)!;
  }

  /// Mod file extensions that *are* plain images (Sims 1 `.bmp` skins):
  /// the file itself is its own thumbnail.
  static const _imageExtensions = {'.bmp', '.png', '.jpg', '.jpeg'};

  /// Files scanned per isolate task: small enough for steady progress
  /// updates, large enough that isolate spawns stay negligible.
  static const _inspectBatchSize = 8;

  /// Concurrent scanner isolates.
  static const _inspectWorkers = 4;

  @override
  Future<Map<String, PackageInsight>> inspectMods(
    List<Mod> mods, {
    void Function(int done, int total)? onProgress,
    void Function(Map<String, PackageInsight> found)? onFound,
    bool Function()? isCancelled,
  }) async {
    final results = <String, PackageInsight>{};
    if (mods.isEmpty) return results;
    final work = [
      for (final mod in mods)
        (
          mod.path,
          _imageExtensions.contains(p.extension(mod.name).toLowerCase()),
        ),
    ];
    final batches = [
      for (var i = 0; i < work.length; i += _inspectBatchSize)
        work.sublist(
            i,
            i + _inspectBatchSize > work.length
                ? work.length
                : i + _inspectBatchSize),
    ];
    var done = 0;
    var next = 0;
    Future<void> worker() async {
      while (next < batches.length && !(isCancelled?.call() ?? false)) {
        final batch = batches[next++];
        Map<String, PackageInsight?> scanned;
        try {
          scanned = await _inspectBatch(batch);
        } catch (_) {
          scanned = const {};
        }
        final landed = <String, PackageInsight>{};
        for (final entry in scanned.entries) {
          final insight = entry.value;
          if (insight != null) {
            results[entry.key] = insight;
            landed[entry.key] = insight;
          }
        }
        if (landed.isNotEmpty) onFound?.call(landed);
        done += batch.length;
        onProgress?.call(done, mods.length);
      }
    }

    await Future.wait([
      for (var i = 0; i < _inspectWorkers && i < batches.length; i++) worker(),
    ]);
    return results;
  }

  /// Spawns the scan isolate from a static scope whose only local is
  /// [batch]. The closure must NOT be created inside [inspectMods]: a
  /// closure captures its enclosing contexts, and there that chain
  /// reaches the caller's `onProgress`, in the app a listener over the
  /// whole controller/widget tree, which is expensive to copy into the
  /// isolate message and fails outright on unsendable objects, silently
  /// killing every batch.
  static Future<Map<String, PackageInsight?>> _inspectBatch(
          List<(String, bool)> batch) =>
      Isolate.run(() => {
            for (final (path, isImage) in batch)
              path: _inspectFile(path, isImage),
          });

  static PackageInsight? _inspectFile(String path, bool isImage) {
    try {
      if (isImage) {
        final bytes = File(path).readAsBytesSync();
        return bytes.isEmpty ? null : PackageInsight(thumbnail: bytes);
      }
      // Non-DBPF files (.iff, .far, .ts4script…) fail the magic check
      // inside scanPackage and come back null almost for free.
      return scanPackage(File(path));
    } catch (_) {
      return null;
    }
  }

  /// Maps a file to a [Mod], or `null` if it isn't a mod file for this game.
  /// Protected: exposed so subclasses that route files into game-specific
  /// folders (Sims 1) can build [Mod]s for what they install.
  Mod? toMod(File file) {
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
