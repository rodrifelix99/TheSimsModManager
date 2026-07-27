import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;

import 'app_message.dart';
import 'game.dart';
import 'install_path.dart';
import 'mod.dart';
import 'mod_archive.dart';
import 'package_insight.dart';
import 'resource_cfg.dart';

/// Suffix appended to a mod file to hide it from the game without deleting it.
const disabledSuffix = '.disabled';

/// [path] without the [disabledSuffix] (unchanged when it isn't there),
/// so a mod keeps one identity across toggles.
String enabledPathOf(String path) =>
    path.toLowerCase().endsWith(disabledSuffix)
        ? path.substring(0, path.length - disabledSuffix.length)
        : path;

/// Why an action on a mod file failed for a reason that isn't an app bug:
/// the user's environment got in the way (game running, file moved). Lets
/// the UI show a helpful message and keeps these out of error tracking.
enum ModActionFailure { fileInUse, fileMissing }

/// An enable/disable/remove that failed for a known environmental
/// [reason]. [detail] is what to tell the user about it.
class ModActionException implements Exception {
  const ModActionException(this.reason, this.detail);

  final ModActionFailure reason;
  final AppMessage detail;

  @override
  String toString() => '$detail';
}

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

  /// File extensions that hold mods inside them and are unpacked on
  /// install rather than copied ([installArchive]). Every game takes the
  /// compressed formats mods are shared in ([archiveFileExtensions]); a
  /// game whose publisher had a container of its own adds it here, which
  /// is what keeps the file picker, the drop overlay and the install
  /// routing agreeing about what that game accepts.
  Set<String> get containerFileExtensions;

  /// Which piece of "where do mods live" guidance the UI should show when
  /// the mods folder can't be found: where the folder normally lives and
  /// what the game needs before it loads mods (in-game options, framework
  /// files, ...). A key rather than the text itself, because that text is
  /// translated and the core layer has no localizations - the UI resolves
  /// it (see `AppText.setupHelp`). Usually just the game id.
  String get setupHelpKey;

  /// Best-guess mods directory on this machine, or `null` if the game
  /// (or its mods folder) can't be located. The user can override this
  /// per game in settings.
  Future<Directory?> resolveModsDirectory();

  /// The path where this game's mods folder is expected to live, even
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
  /// dot), e.g. `.ts4script` -> `Script`.
  String categoryForExtension(String extension);

  Future<List<Mod>> listMods(Directory modsDir);

  Future<Mod> installMod(Directory modsDir, File source);

  /// Unpacks [archive] (any format in [archiveFileExtensions]) into
  /// [modsDir] and returns the mod files it contained; everything else
  /// in the archive (readmes, screenshots) is skipped. Throws an
  /// [AppMessage]-carrying exception when the archive can't be read or
  /// holds no mod files.
  Future<List<Mod>> installArchive(Directory modsDir, File archive);

  /// Installs every mod file found anywhere under [source] (a folder the
  /// user dropped or picked) into [modsDir]. The folder itself becomes a
  /// subfolder of [modsDir] with its internal structure preserved - so in
  /// the library it shows up as a filter chip named after the folder.
  /// Everything that isn't a mod file is skipped. Throws an
  /// [AppMessage]-carrying exception when the folder holds no mod files.
  Future<List<Mod>> installFolder(Directory modsDir, Directory source);

  Future<void> removeMod(Mod mod);

  Future<Mod> setEnabled(Mod mod, {required bool enabled});

  /// Cache files the game keeps that go stale when custom content is
  /// added or removed (e.g. Sims 3's `CASPartCache.package`); the game
  /// rebuilds them on its next launch, but until they're deleted new CC
  /// may not show up. Only files that currently exist are returned;
  /// games without such caches return an empty list.
  Future<List<File>> findCacheFiles();

  /// How many levels of subfolders inside the mods folder this game will
  /// actually read, or `null` when it reads however deep you go. The
  /// Sims 3 engine reads a `Resource.cfg` listing every depth it will
  /// look at, so anything below the deepest line is on disk and invisible
  /// to the game.
  Future<int?> modDepthLimit(Directory modsDir);

  /// What this game still needs before it will run the mods in [modsDir],
  /// as stable keys the UI translates ([AppText.requirement]) - the same
  /// bargain as [setupHelpKey], since core has no localizations.
  ///
  /// This is for the things that live outside the mods folder and leave
  /// a perfectly good library completely inert: a loader DLL that isn't
  /// there, a switch inside the game turned off. Empty when the game is
  /// ready, which is every game most of the time.
  Future<List<String>> unmetRequirements(Directory modsDir);

  /// Safe to call: the game regenerates these on its next launch.
  Future<List<File>> clearCaches();

  /// Looks inside every mod file for embedded artwork and a content
  /// summary, keyed by `mod.path`. Runs once per library load, off the UI
  /// thread. [onFound] delivers each batch as it lands so the loading
  /// screen can show artwork mid-scan; once [isCancelled] returns true the
  /// scan stops between batches and returns what it has. Files that yield
  /// nothing are absent from the result. Must never throw.
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
/// Subclasses supply [game], [modFileExtensions], [setupHelpKey], and
/// [defaultModsPath]; everything else has a sensible default. Override
/// [findModsDirectoryCandidates] when the game can live in several places,
/// and [scaffoldModsDirectory] when the game needs extra files (like a
/// `Resource.cfg`) before it reads the folder.
abstract class FolderBasedGameAdapter implements GameAdapter {
  const FolderBasedGameAdapter();

  Map<String, String> get categoryByExtension => const {};

  /// The shared compressed formats. Games with a container of their own
  /// (The Sims 3's `.sims3pack`) add it to this.
  @override
  Set<String> get containerFileExtensions => archiveFileExtensions;

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

  /// The game's `Resource.cfg` for a library rooted at [modsDir], for the
  /// games that read one. Every game that writes one in
  /// [scaffoldModsDirectory] should say where it put it.
  File? resourceCfgFile(Directory modsDir) => null;

  /// Most games are ready once their mods folder exists.
  @override
  Future<List<String>> unmetRequirements(Directory modsDir) async => const [];

  /// Read out of the cfg on disk rather than assumed from the one we
  /// would have written: people add a level to these by hand, and an
  /// older framework may have fewer than the current one.
  @override
  Future<int?> modDepthLimit(Directory modsDir) async {
    final cfg = resourceCfgFile(modsDir);
    if (cfg == null) return null;
    try {
      if (!await cfg.exists()) return null;
      return maxPackedFileDepth(await cfg.readAsString());
    } catch (_) {
      // An unreadable cfg is not worth a warning about depth.
      return null;
    }
  }

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
    // A subfolder the OS refuses to open (a name another tool wrote that
    // Windows can't address, a permission wall) must cost its own mods,
    // not the whole library.
    await for (final entity
        in modsDir.list(recursive: true).handleError((Object _) {})) {
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
  Future<List<Mod>> installFolder(Directory modsDir, Directory source) async {
    final files = await modFilesIn(source);
    if (files.isEmpty) {
      throw ModContentException.noModFiles(
          modFileExtensions, p.basename(source.path));
    }
    final mods = <Mod>[];
    final taken = <String>{};
    for (final file in files) {
      final target = claimInstallTarget(modsDir.path,
          p.relative(file.path, from: source.parent.path), taken);
      await File(target).parent.create(recursive: true);
      final copied = await file.copy(target);
      mods.add(toMod(copied)!);
    }
    return mods;
  }

  /// Every mod file anywhere under [source], best-effort: unreadable
  /// entries are skipped, symlinks are not followed. Protected: exposed
  /// so subclasses that route files into game-specific folders (Sims 1)
  /// can collect what a dropped folder holds.
  Future<List<File>> modFilesIn(Directory source) async {
    final files = <File>[];
    await for (final entity
        in source.list(recursive: true, followLinks: false).handleError(
              (Object _) {},
            )) {
      if (entity is File &&
          modFileExtensions.contains(p.extension(entity.path).toLowerCase())) {
        files.add(entity);
      }
    }
    return files;
  }

  @override
  Future<void> removeMod(Mod mod) async {
    final name = p.basename(mod.path);
    try {
      await _retryWhileLocked(() => deleteModFile(File(mod.path)),
          giveUp: () => AppMessage('fileInUseDelete', [name]));
    } on PathNotFoundException {
      // Already off the disk (a second window, the user's own file
      // manager). That is what the caller asked for; nothing to report.
    }
  }

  /// Runs [action], retrying with a growing pause while the OS reports
  /// the file as locked: Windows refuses to delete or rename a file the
  /// game or an antivirus scan still has open (sharing violation), and
  /// those locks usually clear within a moment. After the last attempt
  /// the failure is worded by [giveUp].
  Future<T> _retryWhileLocked<T>(Future<T> Function() action,
      {required AppMessage Function() giveUp}) async {
    for (var attempt = 1;; attempt++) {
      try {
        return await action();
      } on PathAccessException {
        if (attempt < _lockedFileAttempts) {
          await Future<void>.delayed(lockedFileRetryDelay * attempt);
          continue;
        }
        throw ModActionException(ModActionFailure.fileInUse, giveUp());
      }
    }
  }

  /// The on-disk delete behind [removeMod]; a seam for tests to simulate
  /// OS failures (locked or vanished files).
  Future<void> deleteModFile(File file) => file.delete();

  /// Attempts before a locked file is given up on; antivirus and indexer
  /// locks are usually released within a second.
  static const _lockedFileAttempts = 4;

  /// Base wait between retries on a locked file; grows linearly per
  /// attempt. Overridable so tests don't sit through real delays.
  Duration get lockedFileRetryDelay => const Duration(milliseconds: 250);

  @override
  Future<Mod> setEnabled(Mod mod, {required bool enabled}) async {
    if (mod.isEnabled == enabled) return mod;
    final newPath =
        enabled ? enabledPathOf(mod.path) : '${mod.path}$disabledSuffix';
    final name = p.basename(enabled ? newPath : mod.path);
    return _retryWhileLocked(() async {
      try {
        return toMod(await renameModFile(File(mod.path), newPath))!;
      } on FileSystemException {
        if (!File(mod.path).existsSync()) {
          // Already carrying the target name (double toggle, an external
          // rename): the work is done, report the new state as success.
          final already = File(newPath);
          if (already.existsSync()) return toMod(already)!;
          throw ModActionException(
            ModActionFailure.fileMissing,
            AppMessage('fileMissing', [name]),
          );
        }
        rethrow;
      }
    }, giveUp: () => AppMessage('fileInUseRename', [name]));
  }

  /// The on-disk rename behind [setEnabled]; a seam for tests to simulate
  /// OS failures (locked or vanished files).
  Future<File> renameModFile(File file, String newPath) =>
      file.rename(newPath);

  /// Mod file extensions that are plain images (Sims 1 `.bmp` skins):
  /// the file itself is its own thumbnail.
  static const _imageExtensions = {'.bmp', '.png', '.jpg', '.jpeg'};

  /// Files scanned per isolate task: small enough for steady progress
  /// updates, large enough that isolate spawns stay negligible. Scales
  /// with the library, because a fixed eight files means several thousand
  /// isolate spawns for a folder holding tens of thousands of mods.
  static int _inspectBatchSize(int mods) => (mods ~/ 512).clamp(8, 64);

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
    final batchSize = _inspectBatchSize(work.length);
    final batches = [
      for (var i = 0; i < work.length; i += batchSize)
        work.sublist(
            i, i + batchSize > work.length ? work.length : i + batchSize),
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
      // Non-DBPF files (.iff, .far, .ts4script...) fail the magic check
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
    final marked = p.basename(file.path);
    final name = enabledPathOf(marked);
    final status = name == marked ? ModStatus.enabled : ModStatus.disabled;
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
