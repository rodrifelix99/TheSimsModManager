import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;

import 'app_message.dart';
import 'game.dart';
import 'game_pack.dart';
import 'install_destination.dart';
import 'install_path.dart';
import 'mod.dart';
import 'mod_archive.dart';
import 'package_insight.dart';
import 'resource_cfg.dart';
import 'save_game.dart';
import 'trivia.dart';

/// What gets appended to a mod file to hide it from the game without
/// deleting it, until something sets [disabledSuffix] otherwise.
const defaultDisabledSuffix = '.disabled';

/// The same idea in another manager's dialect, always recognized whatever
/// this app is set to write. CC Magic marks a package `.off`, and a lot of
/// Sims 3 libraries have been through it; without this those files match
/// no mod extension and the library simply doesn't mention them.
const foreignDisabledSuffixes = ['.off'];

String _disabledSuffix = defaultDisabledSuffix;
List<String> _knownSuffixes = _buildKnownSuffixes(defaultDisabledSuffix);

/// The marker [FolderBasedGameAdapter.setEnabled] appends when it disables
/// a mod. Settable rather than const because a library the user also feeds
/// to another manager has to be marked in a way that manager reads; what is
/// *recognized* never narrows with it (see [disabledSuffixes]), so changing
/// this leaves everything already disabled exactly where it is.
String get disabledSuffix => _disabledSuffix;

set disabledSuffix(String value) {
  final wanted = value.trim();
  _disabledSuffix =
      isValidDisabledSuffix(wanted) ? wanted : defaultDisabledSuffix;
  _knownSuffixes = _buildKnownSuffixes(_disabledSuffix);
}

/// Every marker a file on disk might be carrying, lowercase and longest
/// first so a suffix ending in another one is still matched whole.
List<String> get disabledSuffixes => _knownSuffixes;

List<String> _buildKnownSuffixes(String own) => <String>{
      own.toLowerCase(),
      defaultDisabledSuffix,
      ...foreignDisabledSuffixes,
    }.toList()
  ..sort((a, b) => b.length.compareTo(a.length));

/// Whether [value] can serve as the marker: a dot and then something a
/// file name can carry on every platform. Deliberately narrow - this is
/// typed into a text field, and a marker holding a path separator would
/// send the rename into another folder.
bool isValidDisabledSuffix(String value) =>
    RegExp(r'^\.[A-Za-z0-9_-]{1,15}$').hasMatch(value);

/// [path] without whichever marker it carries (unchanged when it carries
/// none), so a mod keeps one identity across toggles.
String enabledPathOf(String path) {
  final lower = path.toLowerCase();
  for (final suffix in _knownSuffixes) {
    if (lower.endsWith(suffix)) {
      return path.substring(0, path.length - suffix.length);
    }
  }
  return path;
}

/// Why an action on a mod file failed for a reason that isn't an app bug:
/// the user's environment got in the way (game running, file moved), or
/// what was asked for would have cost a file ([nameTaken]). Lets the UI
/// show a helpful message and keeps these out of error tracking.
enum ModActionFailure { fileInUse, fileMissing, nameTaken }

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

  /// Other folders this game loads mods from besides its mods folder,
  /// and that hold nothing but the player's own files - so unlike The
  /// Sims 1's routed folders ([installDestinations], `placed_mods.dart`)
  /// they can be listed whole rather than remembered file by file.
  ///
  /// Empty for most games. The Sims 3 engine reads its list of folders
  /// out of the Resource.cfg on disk, so the games that keep one answer
  /// this from the file itself rather than from anything assumed here.
  Future<List<Directory>> extraModsDirectories(Directory modsDir) async =>
      const [];

  /// Every folder this game reads mods from, when that is more than one.
  ///
  /// Empty for every game whose mods all live in the mods folder, which is
  /// all of them but The Sims 1 - and the UI reads it that way, never
  /// asking where anything goes unless there is more than one answer.
  /// Only folders that exist on this machine are returned: which
  /// expansions someone installed decides which of them there are.
  Future<List<InstallDestination>> installDestinations(Directory modsDir) async =>
      const [];

  /// One file described as a mod of this game, or null when it isn't one
  /// (wrong extension, or no longer on disk). Lets a caller holding a
  /// path rather than a folder - the record of what was installed into a
  /// folder that can't be listed - put it back in the library.
  Mod? modAt(String path);

  Future<Mod> installMod(Directory modsDir, File source,
      {InstallPlacement placement = const SortedPlacement()});

  /// Unpacks [archive] (any format in [archiveFileExtensions]) into
  /// [modsDir] and returns the mod files it contained; everything else
  /// in the archive (readmes, screenshots) is skipped. Throws an
  /// [AppMessage]-carrying exception when the archive can't be read or
  /// holds no mod files.
  Future<List<Mod>> installArchive(Directory modsDir, File archive,
      {InstallPlacement placement = const SortedPlacement()});

  /// Installs every mod file found anywhere under [source] (a folder the
  /// user dropped or picked) into [modsDir]. The folder itself becomes a
  /// subfolder of [modsDir] with its internal structure preserved - so in
  /// the library it shows up as a filter chip named after the folder.
  /// Everything that isn't a mod file is skipped. Throws an
  /// [AppMessage]-carrying exception when the folder holds no mod files.
  Future<List<Mod>> installFolder(Directory modsDir, Directory source,
      {InstallPlacement placement = const SortedPlacement()});

  Future<void> removeMod(Mod mod);

  /// Moves [mod] into [destination] and returns it where it now sits.
  ///
  /// Nothing about the file changes but which folder holds it - the
  /// marker it may be wearing included, so a disabled mod arrives
  /// disabled. Callers are expected to keep this inside the mods folder:
  /// the folders a game reads for itself (The Sims 1 routes skins and
  /// walls into the game's own) are the adapter's arrangement rather than
  /// the user's, and rearranging those is not what this is for.
  ///
  /// Refuses rather than overwrites when [destination] already holds a
  /// file of that name, or renames around it: two same-named mods is
  /// precisely what the conflict scan exists to warn about, and losing
  /// one of them silently is worse than saying so.
  Future<Mod> moveMod(Mod mod, Directory destination);

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

  /// This game's saves as found on this machine, newest first - a
  /// best-effort read of whatever the save files give up (see [SaveGame]:
  /// every game stores something different). Empty when the game or its
  /// saves can't be located, and for games without a save reader yet.
  /// Runs off the UI thread and must never throw.
  Future<List<SaveGame>> listSaveGames() async => const [];

  /// The publisher's own packs installed beside this game - expansions,
  /// stuff packs, kits - as the install describes them.
  ///
  /// Empty for a game whose expansions cannot be told apart once
  /// installed (The Sims 1 merges them into shared folders), for one
  /// that isn't installed, and for one whose adapter has no pack reader
  /// yet. Runs off the UI thread and must never throw.
  Future<List<GamePack>> listPacks() async => const [];

  /// What a well-stocked copy of this game would have on the packs shelf,
  /// for the invented screenshot library. Never asks the disk, and only
  /// ever read when demo mode is on (a debug-only setting).
  ///
  /// It invents what is *installed*, not what the app can do about it:
  /// [hasPacks], [canTogglePacks] and the rest still answer for the real
  /// machine, so a shot never shows a switch this platform doesn't have.
  List<GamePack> demoPacks() => const [];

  /// A remark about the collection itself, for a shelf worth one. Null on
  /// nearly every machine, and nothing acts on it: this is an easter egg
  /// rather than a capability.
  ///
  /// Carries an [AppMessage] like every other wording core hands up, so
  /// the joke gets told in the language the user is reading.
  AppMessage? packCollectionNote(List<GamePack> packs) => null;

  /// What the plumbob knows about this game, as keys rather than wording
  /// (see [TriviaFact]).
  ///
  /// Empty means this game has no trivia written for it yet, and the
  /// buddy simply isn't offered - which is the honest answer for a game
  /// added before anybody sat down and researched it.
  List<TriviaFact> get triviaFacts => const [];

  /// Whether [listPacks] can say anything at all about this game, known
  /// without going to the disk so the UI can decide whether to offer the
  /// screen at all. False means the packs screen is not a thing this
  /// game has, rather than one that happens to be empty today - which is
  /// the honest answer for a game whose expansions merge on install.
  bool get hasPacks => false;

  /// Whether [setPackEnabled] can actually turn a pack off for this game.
  ///
  /// Listing and toggling are separate capabilities on purpose: a game
  /// can be perfectly able to say what it has installed and have no safe
  /// way to run without one of them, and the UI reads this to decide
  /// whether it is drawing a switch or a fact.
  bool get canTogglePacks => false;

  /// Whether switching a pack off works for this game but has never been
  /// shown to be safe, so the app must not offer it until the user has
  /// asked for it and been told why. True for The Sims 2, whose engine
  /// runs happily on a subset of its packs and whose neighborhoods are
  /// the series' most reliable way to lose a save.
  bool get packToggleIsExperimental => false;

  /// Whether [setPackEnabled] needs the app to be running as
  /// administrator. True for the games that keep their pack list in a
  /// part of the machine a normal process may read but not write - The
  /// Sims 3 records its packs in HKEY_LOCAL_MACHINE. The UI asks up
  /// front so it can say so, rather than letting a switch snap back.
  bool get packToggleNeedsAdmin => false;

  /// Tells the game to load [pack] or leave it alone from now on.
  ///
  /// Never touches the pack's own files: what changes is the game's own
  /// record of what it should load, so the pack is still installed and
  /// the switch is reversible. Takes effect the next time the game
  /// starts, and callers are expected to have told the user that.
  /// Only ever called when [canTogglePacks] is true.
  Future<void> setPackEnabled(GamePack pack, {required bool enabled}) async {
    throw UnsupportedError('${game.id} cannot toggle packs');
  }
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
    final mods = <Mod>[];
    // The mods folder first, then whatever else the game says it reads.
    // Those extras are folders of the player's own, so they are swept
    // exactly like the main one; where a mod sits is then the library's
    // business rather than this one's.
    await _sweep(modsDir, mods);
    for (final extra in await extraModsDirectories(modsDir)) {
      await _sweep(extra, mods);
    }
    mods.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return mods;
  }

  Future<void> _sweep(Directory dir, List<Mod> into) async {
    if (!await dir.exists()) return;
    // A subfolder the OS refuses to open (a name another tool wrote that
    // Windows can't address, a permission wall) must cost its own mods,
    // not the whole library.
    await for (final entity
        in dir.list(recursive: true).handleError((Object _) {})) {
      if (entity is! File) continue;
      final mod = toMod(entity);
      if (mod != null) into.add(mod);
    }
  }

  /// Read off the cfg the game actually has, like [modDepthLimit]: the
  /// stock Sims 3 framework names an `Overrides` folder beside
  /// `Packages`, people edit these by hand, and a game with no cfg at all
  /// has only its mods folder.
  @override
  Future<List<Directory>> extraModsDirectories(Directory modsDir) async {
    final cfg = resourceCfgFile(modsDir);
    if (cfg == null) return const [];
    String text;
    try {
      if (!await cfg.exists()) return const [];
      text = await cfg.readAsString();
    } catch (_) {
      return const [];
    }
    final base = cfg.parent.path;
    final found = <String, Directory>{};
    for (final root in modFolderRoots(text)) {
      final dir = Directory(
          root.isEmpty ? base : p.joinAll([base, ...root.split('/')]));
      // The mods folder is where the sweep already starts. A folder
      // inside it, or one holding it, would hand back the same files a
      // second time - which is a library counting every mod twice, and a
      // conflict scan reporting every mod as a clash with itself.
      if (p.equals(dir.path, modsDir.path)) continue;
      if (p.isWithin(modsDir.path, dir.path)) continue;
      if (p.isWithin(dir.path, modsDir.path)) continue;
      final key = p.canonicalize(dir.path);
      if (found.containsKey(key)) continue;
      // Asking whether a folder is there can itself fail: a name the OS
      // refuses to address (Windows answers errno 123 rather than false)
      // throws out of exists(). The line named a folder we cannot reach
      // either way, which is worth exactly one skipped folder and not a
      // refresh that ends in an error banner.
      try {
        if (!await dir.exists()) continue;
      } catch (_) {
        continue;
      }
      found[key] = dir;
    }
    return found.values.toList();
  }

  /// One folder holds everything, unless a subclass says otherwise. The
  /// interface's own default cannot reach here - this class implements
  /// [GameAdapter] rather than extending it - so it is repeated.
  @override
  Future<List<InstallDestination>> installDestinations(
      Directory modsDir) async =>
      const [];

  /// No saves until a subclass knows how to read this game's. Repeated
  /// from the interface for the same reason as [installDestinations].
  @override
  Future<List<SaveGame>> listSaveGames() async => const [];

  /// No packs, and nothing to toggle, until a subclass knows this game's.
  /// Repeated from the interface for the same reason as above.
  @override
  Future<List<GamePack>> listPacks() async => const [];

  @override
  List<GamePack> demoPacks() => const [];

  @override
  AppMessage? packCollectionNote(List<GamePack> packs) => null;

  /// No facts until a subclass brings a table of its own, which means no
  /// plumbob in the corner rather than one with nothing to say.
  @override
  List<TriviaFact> get triviaFacts => const [];

  @override
  bool get hasPacks => false;

  @override
  bool get canTogglePacks => false;

  @override
  bool get packToggleNeedsAdmin => false;

  @override
  bool get packToggleIsExperimental => false;

  @override
  Future<void> setPackEnabled(GamePack pack, {required bool enabled}) async {
    throw UnsupportedError('${game.id} cannot toggle packs');
  }

  /// Where an install actually writes: the folder the user chose, when
  /// they chose one and this game has it, and the mods folder otherwise.
  /// A game with no destinations of its own always lands on [modsDir],
  /// which is why the placement argument costs those adapters nothing.
  Future<Directory> resolvePlacement(
      Directory modsDir, InstallPlacement placement) async {
    if (placement is! ChosenPlacement) return modsDir;
    for (final destination in await installDestinations(modsDir)) {
      if (destination.id == placement.destinationId) return destination.directory;
    }
    // A folder that was there when the dialog opened and isn't now (an
    // expansion uninstalled mid-session, a path typed into the prefs by
    // hand). The mods folder is where the game looks anyway.
    return modsDir;
  }

  @override
  Future<Mod> installMod(Directory modsDir, File source,
      {InstallPlacement placement = const SortedPlacement()}) async {
    // The file picker filters by extension but does not enforce it
    // (Windows lets a name be typed past the filter), so a file this game
    // cannot read can arrive here. Refuse it before it lands in the mods
    // folder as a file the library would never list.
    if (toMod(source) == null) {
      throw ModContentException.noModFiles(
          modFileExtensions, p.basename(source.path));
    }
    final dir = await resolvePlacement(modsDir, placement);
    await dir.create(recursive: true);
    final target = p.join(dir.path, p.basename(source.path));
    final copied = await source.copy(target);
    return toMod(copied)!;
  }

  @override
  Future<List<Mod>> installArchive(Directory modsDir, File archive,
      {InstallPlacement placement = const SortedPlacement()}) async {
    final dir = await resolvePlacement(modsDir, placement);
    await dir.create(recursive: true);
    final files = await extractModFiles(archive, dir, modFileExtensions);
    return [for (final file in files) toMod(file)!];
  }

  @override
  Future<List<Mod>> installFolder(Directory modsDir, Directory source,
      {InstallPlacement placement = const SortedPlacement()}) async {
    final dir = await resolvePlacement(modsDir, placement);
    final files = await modFilesIn(source);
    if (files.isEmpty) {
      throw ModContentException.noModFiles(
          modFileExtensions, p.basename(source.path));
    }
    final mods = <Mod>[];
    final taken = <String>{};
    for (final file in files) {
      final target = claimInstallTarget(
          dir.path, p.relative(file.path, from: source.parent.path), taken);
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

  @override
  Future<Mod> moveMod(Mod mod, Directory destination) async {
    final name = p.basename(mod.path);
    final target = p.join(destination.path, name);
    if (p.equals(target, mod.path)) return mod;
    // Asked before the folder is created, so a refusal leaves nothing
    // behind. Either kind of entry counts: a folder named like the file
    // would take the rename just as fatally.
    if (await File(target).exists() || await Directory(target).exists()) {
      throw ModActionException(
          ModActionFailure.nameTaken, AppMessage('fileNameTaken', [name]));
    }
    await destination.create(recursive: true);
    return _retryWhileLocked(() async {
      try {
        return toMod(await renameModFile(File(mod.path), target))!;
      } on FileSystemException {
        if (!File(mod.path).existsSync()) {
          throw ModActionException(
            ModActionFailure.fileMissing,
            AppMessage('fileMissing', [name]),
          );
        }
        rethrow;
      }
    }, giveUp: () => AppMessage('fileInUseRename', [name]));
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

  @override
  Mod? modAt(String path) {
    final file = File(path);
    return file.existsSync() ? toMod(file) : null;
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
