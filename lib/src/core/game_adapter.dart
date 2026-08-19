import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;

import 'app_message.dart';
import 'creation.dart';
import 'game.dart';
import 'game_pack.dart';
import 'install_destination.dart';
import 'install_path.dart';
import 'mod.dart';
import 'mod_archive.dart';
import 'mod_catalog.dart';
import 'package_insight.dart';
import 'resource_cfg.dart';
import 'save_edit.dart';
import 'save_game.dart';
import 'stock_backup.dart';
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

/// Attempts before a locked file is given up on; antivirus and indexer
/// locks are usually released within a second.
const lockedFileAttempts = 4;

/// Runs [action], retrying with a growing pause while the OS reports the
/// file as locked: Windows refuses to delete or rename a file the game or
/// an antivirus scan still has open (sharing violation), and those locks
/// usually clear within a moment. After the last attempt the failure is
/// worded by [giveUp].
///
/// Top-level rather than a method because the creation actions need the
/// same patience for the same reason, and a game with the Tray open is
/// exactly when someone reaches for the app.
Future<T> retryWhileLocked<T>(
  Future<T> Function() action, {
  required AppMessage Function() giveUp,
  Duration delay = const Duration(milliseconds: 250),
}) async {
  for (var attempt = 1;; attempt++) {
    try {
      return await action();
    } on PathAccessException {
      if (attempt < lockedFileAttempts) {
        await Future<void>.delayed(delay * attempt);
        continue;
      }
      throw ModActionException(ModActionFailure.fileInUse, giveUp());
    }
  }
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

  /// File extensions that belong in the game's own folders and nowhere
  /// else (lowercase, with dot): The Sims 3's `.world` and `.asi`, the
  /// `.sgr` a graphics fix rewrites. Empty for most games.
  ///
  /// Deliberately apart from [modFileExtensions] rather than added to it.
  /// A mod file is something the mods folder holds and the library lists
  /// wherever it sits; one of these is only ever a file in a folder the
  /// game keeps its own content in - it has no home in the mods folder,
  /// the sweep would never find it there, and a download that happens to
  /// carry one must not have it installed unless [rootDestinationFor]
  /// says where it goes.
  Set<String> get rootFileExtensions;

  /// Extensions that are part of another mod rather than a mod of their
  /// own: a SimCity 4 DLL plugin's `.ini`, which the plugin reads its
  /// settings out of and which its README says to copy in beside it.
  ///
  /// They are taken out of a download and installed, and they follow the
  /// mod they belong to when it is switched off or uninstalled, but they
  /// are never listed as mods and never counted as one. Belonging is
  /// decided by the file name alone - `SC4AutoSave.ini` beside
  /// `SC4AutoSave.dll` - because that is the rule the plugins themselves
  /// use to find their own settings, and because nothing else in the
  /// folder could say so.
  ///
  /// Empty for every Sims game: a `.package` is one file and always was.
  Set<String> get companionFileExtensions => const {};

  /// Extensions a mod *writes* beside itself once the game has run it,
  /// rather than ones it arrives with: a SimCity 4 DLL plugin's `.log`.
  ///
  /// Never installed, never listed, and deliberately **not** moved when
  /// a mod is switched off - a log is a record of what happened, not
  /// part of the mod's state. They are deleted with the mod, because a
  /// plugin that is gone leaves a log the library cannot see and the
  /// user has no reason to keep.
  ///
  /// Kept apart from [companionFileExtensions] on purpose. A companion
  /// is something the download carried and the mod needs; this is
  /// output. Getting the two the same way round would either install a
  /// log or delete a settings file somebody edited.
  Set<String> get generatedFileExtensions => const {};

  /// Whether one download's mod files can be split across several of
  /// [installDestinations].
  ///
  /// True for The Sims 1, where a skin, a wall and an object out of the
  /// same zip each belong somewhere different and no extension reliably
  /// says which - so the app sorts them and offers the user the last
  /// word before the install starts. False for a game whose extra
  /// folders only take files the mods folder never could ([rootFileExtensions]):
  /// there the question has an answer before anyone could be asked, and
  /// putting a dialog in front of every `.package` install would be noise
  /// charged to the many for the sake of the few.
  bool get sortsModsAcrossFolders;

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

  /// Which of the game's own folders a file named [fileName] belongs in,
  /// or null when this game has nothing to do with it.
  ///
  /// Only ever asked about a file whose extension is in
  /// [rootFileExtensions], and answered from [destinations] so one
  /// install pays for the lookup once. Null is a real answer and the
  /// common one: an `.ini` that matches nothing the game ships is a
  /// mod's own config file rather than a replacement for a setting, and
  /// it is left where it was found instead of guessed at.
  Future<Directory?> rootDestinationFor(
          String fileName, List<InstallDestination> destinations) async =>
      null;

  /// Everything an install may take out of a download on this machine:
  /// [modFileExtensions], plus [rootFileExtensions] when the game's own
  /// folders were actually found. The file picker and the drop handler
  /// read it, so what they accept and what an install does with it can't
  /// drift apart.
  Future<Set<String>> installableExtensions(Directory modsDir) async =>
      {...modFileExtensions, ...companionFileExtensions};

  /// One file described as a mod of this game, or null when it isn't one
  /// (wrong extension, or no longer on disk). Lets a caller holding a
  /// path rather than a folder - the record of what was installed into a
  /// folder that can't be listed - put it back in the library.
  Mod? modAt(String path);

  /// [placed] is what this app has already put in the folders the game
  /// keeps its own content in, as absolute paths - the caller's record
  /// (`core/placed_mods.dart`), since nothing on disk says who wrote a
  /// file. A file about to be written over is parked first
  /// (`core/stock_backup.dart`) unless it is one of these: parking an
  /// earlier install of the same mod would throw the game's own file
  /// away and leave the user a copy of their own mod as the way back.
  /// Empty is right for every game that installs nowhere but its mods
  /// folder, and harmless on the first install of anything.
  Future<Mod> installMod(Directory modsDir, File source,
      {InstallPlacement placement = const SortedPlacement(),
      Set<String> placed = const {}});

  /// Unpacks [archive] (any format in [archiveFileExtensions]) into
  /// [modsDir] and returns the mod files it contained; everything else
  /// in the archive (readmes, screenshots) is skipped. Throws an
  /// [AppMessage]-carrying exception when the archive can't be read or
  /// holds no mod files.
  Future<List<Mod>> installArchive(Directory modsDir, File archive,
      {InstallPlacement placement = const SortedPlacement(),
      Set<String> placed = const {}});

  /// Installs every mod file found anywhere under [source] (a folder the
  /// user dropped or picked) into [modsDir]. The folder itself becomes a
  /// subfolder of [modsDir] with its internal structure preserved - so in
  /// the library it shows up as a filter chip named after the folder.
  /// Everything that isn't a mod file is skipped. Throws an
  /// [AppMessage]-carrying exception when the folder holds no mod files.
  Future<List<Mod>> installFolder(Directory modsDir, Directory source,
      {InstallPlacement placement = const SortedPlacement(),
      Set<String> placed = const {}});

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

  /// Whether [listSaveGames] knows how to read anything for this game,
  /// known without going to the disk so the UI can decide whether to
  /// offer the screen at all. The same split [hasPacks] and [hasCreations]
  /// make: false means nobody has written a reader for this game's saves
  /// yet, not that this player happens to have none.
  bool get hasSaves => false;

  /// What this game lets the app change about a household in one of its
  /// saves. Empty - which is the answer for a game nobody has written an
  /// editor for, and for The Sims 3, whose households live inside a
  /// serialized blob nobody outside the game has parsed - means the save
  /// is readable and not writable, and the UI offers no button at all.
  Set<SaveEditField> get editableSaveFields => const {};

  /// The most simoleons this game will hold, for the field that offers
  /// to fill a household's coffers. Games clamp or misdraw past their
  /// own ceiling, and each one's is different.
  int get maxHouseholdFunds => 0;

  /// Applies [edit] to the household [SaveHousehold.id] names inside
  /// [save], writing the file back.
  ///
  /// Unlike everything else on this class, this one throws: it is the
  /// only place the app writes into a file the user cannot download
  /// again, and an edit that half happened has to be heard about. The
  /// contract is in `save_edit.dart` - a copy is kept first, the result
  /// is proved before it replaces anything, and a failure leaves the
  /// save exactly as it was. Runs off the UI thread.
  Future<void> editSaveHousehold(
          SaveGame save, SaveHousehold household, HouseholdEdit edit) async =>
      throw const SaveEditException(AppMessage('saveEditUnsupported'));

  /// Whether this game keeps player-built lots, rooms, households and
  /// sims somewhere of its own, known without going to the disk so the UI
  /// can decide whether to offer the screen at all. The same split
  /// [hasPacks] makes: false means the game has no such folder, not that
  /// the folder happens to be empty today.
  bool get hasCreations => false;

  /// Extensions that could be player-built content and are nothing else,
  /// so the drop overlay and the file picker let them through.
  ///
  /// Empty for the games whose creations wear the same extension as their
  /// mods - a Sims 3 lot is a `.package`, which [modFileExtensions]
  /// already accepts, and only [routeCreations] can tell the two apart.
  /// This is for the game that gave its tray files names of their own.
  Set<String> get creationFileExtensions => const {};

  /// Where this game reads player-built content from - the Sims 4 Tray,
  /// the Sims 3 Library, the Sims 2 bins, the Sims 1 Houses folder.
  ///
  /// More than one for a game that files lots and sims apart, and the
  /// order is the order the UI offers them in. Empty when the game isn't
  /// installed or has no such folder, which is what makes this the one
  /// question [installCreations] has to answer before it can do anything.
  /// Never throws.
  Future<List<CreationFolder>> creationFolders() async => const [];

  /// This game's player-built content as found on this machine, newest
  /// first - a best-effort read of whatever each format gives up (see
  /// [Creation]). Empty when the game or its folders can't be located.
  /// Runs off the UI thread and must never throw.
  Future<List<Creation>> listCreations() async => const [];

  /// Whether [paths] look like content for this game's creation folders
  /// rather than mods, and if so which folder they belong in.
  ///
  /// This is what stands between a downloaded lot and the mods folder,
  /// where it would sit forever doing nothing. Deliberately a question
  /// about the *files*, asked before an install picks a destination: a
  /// Sims 4 tray set announces itself by extension, while a Sims 3 lot is
  /// a `.package` like every mod in the library and can only be told
  /// apart by what is inside it. Returns null when nothing here is a
  /// creation, which is the answer for almost every install.
  ///
  /// Reads the files it is given and must never throw.
  Future<CreationRouting?> routeCreations(List<String> paths) async => null;

  /// Copies [paths] into [folder].
  ///
  /// Separate from [installFiles] because none of that machinery applies:
  /// there is no enable marker, no subfolder to file into, no conflict
  /// scan, and a set of files that belong together must land whole or not
  /// at all. Says nothing about what arrived - the caller re-lists, which
  /// it has to do anyway and which is the only answer that agrees with
  /// the disk. Throws [ModActionException] the way the mod actions do.
  Future<void> installCreations(
    List<String> paths,
    CreationFolder folder,
  ) async =>
      throw UnsupportedError('${game.id} cannot install creations');

  /// Deletes [creation] and every file it is made of.
  ///
  /// Takes the whole of [Creation.allFiles] rather than one path, because
  /// a Sims 4 tray item is a set and leaving the rest behind gives the
  /// game a half-item to trip over. Throws [ModActionException].
  Future<void> removeCreation(Creation creation) async =>
      throw UnsupportedError('${game.id} cannot remove creations');

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

  /// Every pack this game has ever shipped, code to English name, as far
  /// as this build knows.
  ///
  /// The catalog rather than the inventory: [listPacks] says what is on
  /// the disk, and this says what a pack is *called* when it isn't - which
  /// is the whole question a mod's requirements ask ("needs Get to Work",
  /// on a machine that hasn't got it). It is the same shipped table the
  /// adapters already fall back on when an install can't name a pack for
  /// itself, so nothing new is being maintained here.
  ///
  /// Empty is a fine answer, and means requirements for this game are
  /// drawn under their codes.
  Map<String, String> get knownPackNames => const {};

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

  /// The catalogs somebody else curates for this game, browsable in the
  /// app and never written to (see `mod_catalog.dart`).
  ///
  /// Empty for every game but SimCity 4, and empty is the right default:
  /// a catalog worth reading is years of a community's unpaid curation,
  /// and there is no generic one to fall back on. A game gets an entry
  /// here when such a project exists and publishes its index openly.
  ///
  /// Built fresh per call rather than held const, because a catalog
  /// caches what it has fetched and the cache belongs to the session
  /// rather than to the adapter.
  List<ModCatalog> catalogs() => const [];

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

  /// The game's own containers, as opposed to the compressed formats
  /// every game takes. Empty for every game but The Sims 3.
  ///
  /// A download is as likely to be a zip of these as a bare one - the
  /// scene shares a set of recolours as one archive - so an install
  /// takes them out of an archive or a folder alongside the mod files
  /// and unpacks each where it found it ([unpackContainer]). Nested
  /// archives are deliberately not in it: a zip inside a zip is a
  /// rabbit hole with no bottom, and nobody ships CC that way.
  Set<String> get nestedContainerExtensions =>
      containerFileExtensions.difference(archiveFileExtensions);

  /// Unpacks the game's own container [file] into [destination], taking
  /// what [fileExtensions] names. Only ever asked of a file
  /// [nestedContainerExtensions] recognises, so the games without one
  /// have nothing to answer.
  ///
  /// Throws a [ModContentException] the way the archive reader does when
  /// the container holds nothing this game can use, or holds something
  /// it must not scatter through the mods folder (a sims3pack carrying a
  /// world).
  Future<List<File>> unpackContainer(
          File file, Directory destination, Set<String> fileExtensions) async =>
      const [];

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

  /// And nothing belongs outside the mods folder until one says so.
  /// Repeated from the interface for the same reason.
  @override
  Set<String> get rootFileExtensions => const {};

  /// And nothing rides along with a mod until one says so.
  @override
  Set<String> get companionFileExtensions => const {};

  /// And nothing is left behind by one either.
  @override
  Set<String> get generatedFileExtensions => const {};

  /// Whether [path] is a companion rather than a mod in its own right.
  bool isCompanionFile(String path) => companionFileExtensions
      .contains(p.extension(enabledPathOf(path)).toLowerCase());

  /// The companion files sitting beside [modPath] under its own base
  /// name, as they are on disk right now. A companion follows the mod
  /// through a disable, so it is looked for wearing the marker as well
  /// as without it.
  ///
  /// Reads the folder rather than probing each extension: a plugin's
  /// settings file is written by the plugin itself and the case it
  /// chooses is not always the case the download had.
  Future<List<File>> companionsOf(String modPath) =>
      _besideMod(modPath, companionFileExtensions);

  /// The files [modPath]'s mod has written beside itself
  /// ([generatedFileExtensions]), as they are on disk right now.
  Future<List<File>> generatedBesideMod(String modPath) =>
      _besideMod(modPath, generatedFileExtensions);

  Future<List<File>> _besideMod(String modPath, Set<String> extensions) async {
    if (extensions.isEmpty) return const [];
    final enabled = enabledPathOf(modPath);
    final stem = p.basenameWithoutExtension(enabled).toLowerCase();
    if (stem.isEmpty) return const [];
    final dir = Directory(p.dirname(enabled));
    final found = <File>[];
    try {
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is! File) continue;
        final bare = enabledPathOf(p.basename(entity.path));
        if (p.basenameWithoutExtension(bare).toLowerCase() != stem) continue;
        if (!extensions.contains(p.extension(bare).toLowerCase())) continue;
        found.add(entity);
      }
    } catch (_) {
      // A folder that cannot be listed costs the companions, not the
      // action the caller is in the middle of.
    }
    return found;
  }

  @override
  bool get sortsModsAcrossFolders => false;

  @override
  Future<Directory?> rootDestinationFor(
          String fileName, List<InstallDestination> destinations) async =>
      null;

  /// No saves until a subclass knows how to read this game's. Repeated
  /// from the interface for the same reason as [installDestinations].
  @override
  Future<List<SaveGame>> listSaveGames() async => const [];

  /// Repeated from the interface for the same reason as above.
  @override
  bool get hasSaves => false;

  /// And nothing to write into them until one knows how to read them.
  @override
  Set<SaveEditField> get editableSaveFields => const {};

  @override
  int get maxHouseholdFunds => 0;

  @override
  Future<void> editSaveHousehold(
          SaveGame save, SaveHousehold household, HouseholdEdit edit) async =>
      throw const SaveEditException(AppMessage('saveEditUnsupported'));

  /// No player-built content until a subclass knows where this game keeps
  /// it. Repeated from the interface for the same reason as above.
  @override
  bool get hasCreations => false;

  @override
  Set<String> get creationFileExtensions => const {};

  @override
  Future<List<CreationFolder>> creationFolders() async => const [];

  @override
  Future<List<Creation>> listCreations() async => const [];

  @override
  Future<CreationRouting?> routeCreations(List<String> paths) async => null;

  @override
  Future<void> installCreations(
    List<String> paths,
    CreationFolder folder,
  ) async =>
      throw UnsupportedError('${game.id} cannot install creations');

  @override
  Future<void> removeCreation(Creation creation) async =>
      throw UnsupportedError('${game.id} cannot remove creations');

  /// No packs, and nothing to toggle, until a subclass knows this game's.
  /// Repeated from the interface for the same reason as above.
  @override
  Future<List<GamePack>> listPacks() async => const [];

  @override
  List<GamePack> demoPacks() => const [];

  @override
  Map<String, String> get knownPackNames => const {};

  @override
  AppMessage? packCollectionNote(List<GamePack> packs) => null;

  /// No facts until a subclass brings a table of its own, which means no
  /// plumbob in the corner rather than one with nothing to say.
  @override
  List<TriviaFact> get triviaFacts => const [];

  @override
  List<ModCatalog> catalogs() => const [];

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

  /// What an install may take out of a download on this machine: this
  /// game's mod files, plus the ones its own folders accept when those
  /// folders were actually found.
  ///
  /// The second half is conditional on purpose. A `.world` is only worth
  /// unpacking if there is a Worlds folder to put it in; without one the
  /// game is not installed where the app can see it, and the honest
  /// answer to an archive holding nothing else is that this download has
  /// nothing in it for us.
  @override
  Future<Set<String>> installableExtensions(Directory modsDir) async {
    final base = {...modFileExtensions, ...companionFileExtensions};
    if (rootFileExtensions.isEmpty) return base;
    final destinations = await installDestinations(modsDir);
    if (destinations.isEmpty) return base;
    return {...base, ...rootFileExtensions};
  }

  /// Whether [path] names a file that belongs in one of the game's own
  /// folders rather than in the mods folder.
  bool isRootFile(String path) => rootFileExtensions
      .contains(p.extension(enabledPathOf(p.basename(path))).toLowerCase());

  @override
  Future<Mod> installMod(Directory modsDir, File source,
      {InstallPlacement placement = const SortedPlacement(),
      Set<String> placed = const {}}) async {
    // The file picker filters by extension but does not enforce it
    // (Windows lets a name be typed past the filter), so a file this game
    // cannot read can arrive here. Refuse it before it lands in the mods
    // folder as a file the library would never list.
    if (toMod(source) == null && !isRootFile(source.path)) {
      throw ModContentException.noModFiles(
          modFileExtensions, p.basename(source.path));
    }
    if (isRootFile(source.path) && placement is! ChosenPlacement) {
      final into = await _rootDirectoryFor(modsDir, source.path);
      // Picked by hand, one file at a time: a shrug is the wrong answer.
      // Whatever this is, this game has no folder that takes it.
      if (into == null) {
        throw ModContentException.noModFiles(
            modFileExtensions, p.basename(source.path));
      }
      return installIntoStock(source, into, placed);
    }
    final dir = await resolvePlacement(modsDir, placement);
    await dir.create(recursive: true);
    final target = p.join(dir.path, p.basename(source.path));
    final copied = await copyOnto(source, target);
    return toRootMod(copied)!;
  }

  @override
  Future<List<Mod>> installArchive(Directory modsDir, File archive,
      {InstallPlacement placement = const SortedPlacement(),
      Set<String> placed = const {}}) async {
    final dir = await resolvePlacement(modsDir, placement);
    await dir.create(recursive: true);
    final wanted = await installableExtensions(modsDir);
    final unpacked = await _unpackNested(
        await extractModFiles(
            archive, dir, {...wanted, ...nestedContainerExtensions}),
        wanted);
    if (unpacked.files.isEmpty && unpacked.refused != null) {
      throw unpacked.refused!;
    }
    return _placeInstalled(modsDir, _withoutCompanions(unpacked.files),
        placement, p.basename(archive.path), placed);
  }

  @override
  Future<List<Mod>> installFolder(Directory modsDir, Directory source,
      {InstallPlacement placement = const SortedPlacement(),
      Set<String> placed = const {}}) async {
    final dir = await resolvePlacement(modsDir, placement);
    final wanted = await installableExtensions(modsDir);
    final files = await modFilesIn(source,
        extensions: {...wanted, ...nestedContainerExtensions});
    if (files.isEmpty) {
      throw ModContentException.noModFiles(
          modFileExtensions, p.basename(source.path));
    }
    final copied = <File>[];
    final taken = <String>{};
    final stray = <File>[];
    for (final file in files) {
      // Read out of the folder the user dropped, so a file that belongs
      // in the game's own is copied there straight from the download
      // rather than through the mods folder on the way.
      if (isRootFile(file.path) && placement is! ChosenPlacement) {
        stray.add(file);
        continue;
      }
      final target = claimInstallTarget(
          dir.path, p.relative(file.path, from: source.parent.path), taken);
      await File(target).parent.create(recursive: true);
      copied.add(await copyOnto(file, target));
    }
    final unpacked = await _unpackNested(copied, wanted);
    final mods = [
      for (final file in _withoutCompanions(unpacked.files)) toRootMod(file)!,
    ];
    // After the strays, because a folder holding a world beside a
    // container this game refuses still has the world to install: what
    // the refusal costs is itself, and it is only worth raising once
    // everything else has had its turn.
    mods.addAll(await _intoStockFolders(modsDir, stray, placed,
        discard: false));
    if (mods.isEmpty) {
      throw unpacked.refused ??
          ModContentException.noModFiles(
              modFileExtensions, p.basename(source.path));
    }
    return mods;
  }

  /// The files an install wrote that are mods in their own right. A
  /// companion ([companionFileExtensions]) was copied in because the mod
  /// beside it needs it, and it is not something to list, count or hand
  /// back as installed.
  List<File> _withoutCompanions(List<File> files) => companionFileExtensions
          .isEmpty
      ? files
      : [
          for (final file in files)
            if (!isCompanionFile(file.path)) file,
        ];

  /// What an install really has, once the game's own containers it
  /// unpacked along with the mod files have been opened: everything else
  /// as it was, plus what came out of them.
  ///
  /// Each is unpacked into the folder it was found in, so a zip's
  /// structure survives the container inside it, and the container is
  /// then deleted - the game reads none of these out of the mods folder,
  /// and a file the library cannot list is one nobody would find again.
  ///
  /// A container this game can make nothing of is skipped the way an
  /// unusable file in an archive is, and its refusal is handed back
  /// rather than thrown: a download of eight recolours and one world
  /// should cost the world rather than the download, and only the caller
  /// knows whether anything else in it survived - the folder install has
  /// the files bound for the game's own folders put aside by then, and
  /// they install perfectly well beside a container that did not. When
  /// several refuse, the first is the one the user hears.
  Future<({List<File> files, ModContentException? refused})> _unpackNested(
      List<File> files, Set<String> wanted) async {
    final containers = nestedContainerExtensions;
    if (containers.isEmpty) return (files: files, refused: null);
    final installed = <File>[];
    ModContentException? refused;
    for (final file in files) {
      if (!containers.contains(p.extension(file.path).toLowerCase())) {
        installed.add(file);
        continue;
      }
      try {
        installed.addAll(await unpackContainer(file, file.parent, wanted));
      } on ModContentException catch (e) {
        refused ??= e;
      }
      try {
        await file.delete();
      } catch (_) {} // Unpacked or refused, it has no business staying.
    }
    return (files: installed, refused: refused);
  }

  /// Files an install has just written into the mods folder, with the
  /// ones that belong in the game's own folders moved on to them.
  ///
  /// An archive is unpacked before anything can be known about what it
  /// holds, so a `.world` lands in the mods folder for as long as it
  /// takes to copy it out again. That is cheaper than unpacking every
  /// download to a scratch folder first for the sake of the few that
  /// carry one, and the mods folder never lists these anyway.
  Future<List<Mod>> _placeInstalled(
    Directory modsDir,
    List<File> files,
    InstallPlacement placement,
    String from,
    Set<String> placed,
  ) async {
    final stray = [
      for (final file in files)
        if (isRootFile(file.path)) file,
    ];
    if (stray.isEmpty || placement is ChosenPlacement) {
      return [
        for (final file in files) toRootMod(file)!,
      ];
    }
    final mods = [
      for (final file in files)
        if (!isRootFile(file.path)) toMod(file)!,
    ];
    mods.addAll(await _intoStockFolders(modsDir, stray, placed,
        discard: true));
    if (mods.isEmpty) {
      throw ModContentException.noModFiles(modFileExtensions, from);
    }
    return mods;
  }

  /// Copies each of [files] into the folder this game keeps that kind of
  /// file in, dropping the ones it has no folder for.
  ///
  /// [discard] deletes the source afterwards, for the caller that had to
  /// unpack into the mods folder to find out what it had.
  Future<List<Mod>> _intoStockFolders(
    Directory modsDir,
    List<File> files,
    Set<String> placed, {
    required bool discard,
  }) async {
    if (files.isEmpty) return const [];
    final destinations = await installDestinations(modsDir);
    final mods = <Mod>[];
    for (final file in files) {
      final into = destinations.isEmpty
          ? null
          : await rootDestinationFor(p.basename(file.path), destinations);
      // A file this game does nothing with is left out of the install
      // the way a readme is, rather than guessed a home for.
      if (into != null) mods.add(await installIntoStock(file, into, placed));
      if (discard) {
        try {
          await file.delete();
        } catch (_) {
          // It has been copied where it belongs; a stray in the mods
          // folder is inert, since nothing lists it.
        }
      }
    }
    return mods;
  }

  /// Where a file called [path] goes among the game's own folders, or
  /// null when it has no place in any of them.
  Future<Directory?> _rootDirectoryFor(Directory modsDir, String path) async {
    final destinations = await installDestinations(modsDir);
    if (destinations.isEmpty) return null;
    return rootDestinationFor(p.basename(path), destinations);
  }

  /// Copies [source] into one of the folders the game keeps its own
  /// content in, parking whatever it replaces ([backUpStockFile]).
  ///
  /// Protected: the routing games (Sims 1 by file type, Sims 3 and Sims 2
  /// by what the file replaces) all arrive here, so the backup is taken
  /// in one place and cannot be forgotten in another.
  Future<Mod> installIntoStock(
      File source, Directory into, Set<String> placed) async {
    await into.create(recursive: true);
    final target = installTargetPath(into.path, p.basename(source.path));
    // Only the game's own file is worth keeping. What is there because
    // an earlier install put it there is this mod's previous version,
    // and parking that would lose the original for good.
    if (!placed.contains(p.canonicalize(target))) {
      await backUpStockFile(target);
    }
    final copied = await copyOnto(source, target);
    return toRootMod(copied)!;
  }

  /// Every file anywhere under [source] this game can install,
  /// best-effort: unreadable entries are skipped, symlinks are not
  /// followed. Protected: exposed so subclasses that route files into
  /// game-specific folders (Sims 1) can collect what a dropped folder
  /// holds.
  Future<List<File>> modFilesIn(Directory source,
      {Set<String>? extensions}) async {
    final wanted = extensions ?? modFileExtensions;
    final files = <File>[];
    await for (final entity
        in source.list(recursive: true, followLinks: false).handleError(
              (Object _) {},
            )) {
      if (entity is File &&
          wanted.contains(p.extension(entity.path).toLowerCase())) {
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
    // A mod that replaced one of the game's own files leaves a hole
    // rather than a gap: uninstalling a routing fix must give the game
    // back the world it shipped, not take the world away. Only ever
    // finds anything where [installIntoStock] put it, so the mods folder
    // is unaffected. Under the enabled name, since a disabled mod is the
    // same file wearing a marker.
    await restoreStockFile(enabledPathOf(mod.path));
    // A DLL plugin's settings file is part of the plugin, and leaving it
    // behind means the next install of that plugin silently inherits
    // settings the user does not remember writing. After the mod, never
    // before: a companion that could not be deleted must not be the
    // reason a mod stays in the library.
    for (final beside in [
      ...await companionsOf(mod.path),
      ...await generatedBesideMod(mod.path),
    ]) {
      try {
        await deleteModFile(beside);
      } catch (_) {
        // The mod is gone, which is what was asked for.
      }
    }
  }

  Future<T> _retryWhileLocked<T>(Future<T> Function() action,
          {required AppMessage Function() giveUp}) =>
      retryWhileLocked(action, giveUp: giveUp, delay: lockedFileRetryDelay);

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

  /// Base wait between retries on a locked file; grows linearly per
  /// attempt. Overridable so tests don't sit through real delays.
  Duration get lockedFileRetryDelay => const Duration(milliseconds: 250);

  @override
  Future<Mod> setEnabled(Mod mod, {required bool enabled}) async {
    if (mod.isEnabled == enabled) return mod;
    final newPath =
        enabled ? enabledPathOf(mod.path) : '${mod.path}$disabledSuffix';
    final name = p.basename(enabled ? newPath : mod.path);
    // A mod that replaced one of the game's own files is switched off by
    // swapping the two, not by leaving the game with neither: disabling a
    // routing fix has to give back the world it fixed, or the town it
    // belongs to stops loading at all. Both of these find nothing for an
    // ordinary mod, which is every mod in the mods folder.
    if (enabled) await backUpStockFile(enabledPathOf(mod.path));
    final moved = await _retryWhileLocked(() async {
      try {
        return toRootMod(await renameModFile(File(mod.path), newPath))!;
      } on FileSystemException {
        if (!File(mod.path).existsSync()) {
          // Already carrying the target name (double toggle, an external
          // rename): the work is done, report the new state as success.
          final already = File(newPath);
          if (already.existsSync()) return toRootMod(already)!;
          throw ModActionException(
            ModActionFailure.fileMissing,
            AppMessage('fileMissing', [name]),
          );
        }
        rethrow;
      }
    }, giveUp: () => AppMessage('fileInUseRename', [name]));
    // The other half of the swap, once the mod is out of the way.
    if (!enabled) await restoreStockFile(enabledPathOf(mod.path));
    // A plugin switched off with its settings file still sitting there
    // is a plugin that comes back configured; one whose settings file
    // went missing is one that comes back reset. Both halves move.
    // Looked up from where the mod now is, so the stems still match.
    for (final companion in await companionsOf(moved.path)) {
      final target = enabled
          ? enabledPathOf(companion.path)
          : '${enabledPathOf(companion.path)}$disabledSuffix';
      if (p.equals(target, companion.path)) continue;
      try {
        await renameModFile(companion, target);
      } catch (_) {
        // The mod itself has already moved; a companion that would not
        // is worth less than an exception thrown over it.
      }
    }
    return moved;
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
        // Only what the game reads as a mod. A Sims 3 world is a DBPF
        // too and would be parsed like one - eighty megabytes of it, for
        // a thumbnail nothing draws and resource keys that would then be
        // reported as clashing with somebody's custom content.
        if (!isRootFile(mod.path))
          (
            mod.path,
            _imageExtensions.contains(p.extension(mod.name).toLowerCase()),
          ),
    ];
    if (work.isEmpty) return results;
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

  /// Reads the union, unlike the folder sweep: this is how the records of
  /// what the app put in the game's own folders are turned back into
  /// library entries, and those are the only place a [rootFileExtensions]
  /// file is ever listed. A `.world` someone dropped in the mods folder
  /// by hand still shows up nowhere, which is the truth about it.
  @override
  Mod? modAt(String path) {
    final file = File(path);
    return file.existsSync() ? toRootMod(file) : null;
  }

  /// Maps a file to a [Mod], or `null` if it isn't a mod file for this game.
  /// Protected: exposed so subclasses that route files into game-specific
  /// folders (Sims 1) can build [Mod]s for what they install.
  Mod? toMod(File file) => _describe(file, modFileExtensions);

  /// The same, for a file sitting in one of the game's own folders: those
  /// hold what [rootFileExtensions] names as well as ordinary mods.
  /// Protected, and used only where the folder is already known to be one
  /// of them.
  Mod? toRootMod(File file) => rootFileExtensions.isEmpty
      ? _describe(file, modFileExtensions)
      : _describe(file, {...modFileExtensions, ...rootFileExtensions});

  Mod? _describe(File file, Set<String> extensions) {
    final marked = p.basename(file.path);
    final name = enabledPathOf(marked);
    final status = name == marked ? ModStatus.enabled : ModStatus.disabled;
    final extension = p.extension(name).toLowerCase();
    if (!extensions.contains(extension)) {
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
