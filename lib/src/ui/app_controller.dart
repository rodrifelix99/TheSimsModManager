import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show Locale;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../core/app_message.dart';
import '../core/conflicts.dart';
import '../core/deep_link.dart';
import '../core/demo_library.dart';
import '../core/duplicates.dart';
import '../core/folder_access.dart';
import '../core/game_adapter.dart';
import '../core/game_pack.dart';
import '../core/game_registry.dart';
import '../core/ignored_conflicts.dart';
import '../core/mod.dart';
import '../core/install_destination.dart';
import '../core/install_path.dart';
import '../core/mod_advisories.dart';
import '../core/mod_archive.dart';
import '../core/mod_folder.dart';
import '../core/mod_name.dart';
import '../core/mod_kind.dart';
import '../core/mod_tags.dart';
import '../core/package_insight.dart';
import '../core/placed_mods.dart';
import '../core/save_game.dart';
import '../core/trivia.dart';
import '../services/analytics.dart';
import '../services/demo_shop.dart';
import '../services/disk_space.dart';
import '../services/elevation.dart';
import '../services/github.dart';
import '../services/mod_shop.dart';
import '../services/reachability.dart';
import '../services/settings_store.dart';
import '../services/sfx.dart';

enum AppScreen { library, detail, settings, shop, saves, packs }

/// Which half of the library the Enabled/Disabled stats are showing.
/// [all] is both, i.e. no narrowing at all.
enum ModStateFilter { all, enabled, disabled }

/// How the library draws the mods that got past the filters. [folders]
/// is [list] with the rows gathered under the subfolder each one sits
/// in - the shape of the mods directory, which the folder chips can only
/// filter by, one at a time.
enum LibraryLayout { grid, list, folders }

/// The order the mods that got past the filters are drawn in. [name] is
/// the file name A to Z, which is how the library read before there was
/// anything to choose.
enum LibrarySort { name, recent, size }

/// A page of the first-run walkthrough, in the order they are asked.
/// [favorite] is the one that isn't always there: with a single game
/// found there is nothing to choose between, so it drops out and the
/// dots below the card count one fewer.
enum OnboardingStep { welcome, games, favorite, look, library, done }

/// The saves screen's sub-tabs. Which ones a save actually offers depends
/// on what its files gave up ([AppController.availableSavesTabs]): every
/// game fills [households] differently, only some have photos, and
/// [stats] draws whatever numbers exist.
enum SavesTab { households, album, stats }

/// A section of the folder view: the mods sitting directly in [folder],
/// which is `null` for the ones in the mods directory itself. A mod
/// belongs to exactly one, so `cc` does not repeat what `cc/defaults`
/// already shows.
/// One section of the folder view: the folder ([folder] null for the mods
/// directory itself), the mods sitting directly in it, how far down the
/// tree it is, and what it holds all the way down - which is what its
/// header says, since a rolled-up folder is drawn instead of its
/// contents.
typedef ModFolderGroup = ({
  String? folder,
  List<Mod> mods,
  int sizeBytes,
  int depth,
  int totalMods,
  int totalSizeBytes,
});

/// What to tell the user when installing [error] failed on the file or
/// folder at [sourcePath]. Adapters raise [ModContentException] and
/// [ArchiveExtractionException] already carrying the message; everything
/// else is an OS failure, whose own wording (in the user's language,
/// because the OS wrote it) says more about it than we could.
AppMessage installFailureMessage(Object error, String? sourcePath,
    {String? destination}) {
  if (error is ModContentException) return error.detail;
  if (error is ArchiveExtractionException) return error.detail;
  // [destination], because a refused copy reports the file it was
  // reading, not the folder that turned it away.
  final denied = noWriteAccessMessage(error, folder: destination);
  if (denied != null) return denied;
  final String reason = error is FileSystemException
      ? error.osError?.message ?? error.message
      : '$error';
  final name = sourcePath == null ? null : p.basename(sourcePath);
  // Nothing to name it by (no source made it as far as the failure) and
  // the OS wording is all there is to pass on.
  if (name == null) return AppMessage.verbatim(reason);
  return AppMessage(
      error is FileSystemException ? 'installFailed' : 'installFailedRaw',
      [name, reason]);
}

/// The user-facing side of [error], for the actions that have nothing to
/// add to it: the exceptions we raise ourselves carry their own message,
/// anything else says what it says (an OS error, in the user's language;
/// an unforeseen exception, in none).
AppMessage errorMessage(Object error) => switch (error) {
      ModContentException(:final detail) => detail,
      ArchiveExtractionException(:final detail) => detail,
      // Before the permission check below: a rename the game itself is
      // blocking is a PathAccessException too, and the adapter has
      // already worded that one properly.
      ModActionException(:final detail) => detail,
      _ => noWriteAccessMessage(error) ?? AppMessage.verbatim('$error'),
    };

/// The message for a write the system refused, or `null` when [error] is
/// something else. Worth its own wording rather than the OS text: "Access
/// is denied" with a path after it tells a user nothing about what to do,
/// and the games whose mods live in their own install folder (The Sims 1,
/// The Sims Medieval) hit this on a stock Windows setup.
AppMessage? noWriteAccessMessage(Object error, {String? folder}) {
  if (error is! PathAccessException) return null;
  if (folder != null) return noWriteAccessTo(folder);
  final path = error.path;
  if (path == null || path.isEmpty) return null;
  // Name the folder that needs the permission, which is the failing path
  // itself when the refused write was into a folder, and its parent when
  // it was a file (or a folder that could not be created there).
  return noWriteAccessTo(
      Directory(path).existsSync() ? path : p.dirname(path));
}

/// The same message for a folder that is already known to be the problem,
/// so a check made before the write reads exactly like the failure would.
AppMessage noWriteAccessTo(String folder) =>
    AppMessage('errorNoWriteAccess', [folder]);

/// The system's Save-as dialog, offering [suggestedName]; null when the
/// user closed it. No file type filter: the download is whatever the
/// creator uploaded, and a filter would only fight the name it already
/// has.
Future<String?> pickSaveFilePath(String suggestedName) async =>
    (await getSaveLocation(suggestedName: suggestedName))?.path;

/// Coarse cause of an install failure, for the `mod_install_failed`
/// event: enough to tell a rejected archive from a filesystem problem
/// without sending anything about the file itself.
String installFailureReason(Object error) => switch (error) {
      // A zip nothing could read is still reported to the user as a
      // verdict on the file (see ModContentException), but in the tally
      // it belongs with the failed unpacks: it is a broken download, not
      // an archive that held nothing useful.
      ModContentException(detail: AppMessage(key: 'unreadableArchive')) ||
      ModContentException(detail: AppMessage(key: 'sims3PackUnreadable')) =>
        'unpack_failed',
      // A world or a lot is a perfectly good file that belongs somewhere
      // else, which is neither a broken download nor an empty archive.
      ModContentException(detail: AppMessage(key: 'sims3PackWorld')) ||
      ModContentException(detail: AppMessage(key: 'sims3PackLibrary')) =>
        'wrong_content',
      ModContentException() => 'no_mod_files',
      ArchiveExtractionException(cause: ArchiveExtractionFailure.noUnpacker) =>
        'no_unpacker',
      ArchiveExtractionException() => 'unpack_failed',
      PathAccessException() => 'access_denied',
      PathNotFoundException() => 'not_found',
      FileSystemException() => 'file_system',
      _ => 'unknown',
    };

/// All UI state and actions. Views are dumb: they render this and call
/// its methods. Talks only to [GameRegistry]/[GameAdapter]/[Mod] plus the
/// settings store, never to a concrete game.
class AppController extends ChangeNotifier {
  AppController({
    required this.registry,
    required this.settings,
    Sfx? sfx,
    Analytics? analytics,
    Future<UpdateInfo?> Function()? checkUpdates,
    Future<String?> Function()? loadAdvisories,
    Future<List<ShopMod>?> Function()? fetchShop,
    Future<ShopMod?> Function(String id)? fetchListing,
    Future<void> Function(ShopMod mod, File destination,
            {void Function(int received, int total)? onProgress})?
        downloadShop,
    Future<void> Function(String id)? reportDownload,
    Future<String?> Function(String suggestedName)? pickSavePath,
    Future<bool> Function()? checkElevated,
    Future<Reachability> Function(String? mirrorBase)? probeServices,
    int artworkBudgetBytes = defaultArtworkBudgetBytes,
  })  : _artworkBudgetBytes = artworkBudgetBytes,
        _sfx = sfx ?? Sfx(),
        analytics = analytics ?? Analytics.disabled(),
        _checkElevated = checkElevated ?? isRunningElevated,
        _checkUpdates = checkUpdates ?? fetchAvailableUpdate,
        _loadAdvisories = loadAdvisories ?? fetchAdvisories,
        _fetchShop = fetchShop ?? fetchShopListings,
        _fetchListing = fetchListing ?? fetchShopListing,
        _downloadShop = downloadShop ?? downloadShopFile,
        _reportDownload = reportDownload ?? reportShopDownload,
        _pickSavePath = pickSavePath ?? pickSaveFilePath,
        _probeServices = probeServices ?? probeReachability,
        _adapter = _startingAdapter(registry, settings) {
    // Before anything lists a folder: every read and write of the disabled
    // marker asks the core layer for it, and the answer is this preference.
    disabledSuffix = settings.disabledSuffix ?? defaultDisabledSuffix;
    // Here rather than in [init] for the same reason: the library reads
    // the labels as it is built ([_setMods]), so a refresh that beat the
    // load would draw a library with no tags on it and no chips for them.
    _modTags = parseModTags(settings.modTagsJson);
    // Remote flags may land after the first frame (announcement banner,
    // kill switches); repaint when they do.
    this.analytics.onFlagsChanged = _onFlagsChanged;
  }

  /// The game the app opens on: the one the user chose (in the
  /// walkthrough or in Settings), the Sims 4 if nobody ever said, and
  /// failing both whatever the registry lists first - which is what a
  /// test registry of one invented game gets.
  static GameAdapter _startingAdapter(
      GameRegistry registry, SettingsStore settings) {
    final chosen = settings.defaultGameId;
    return (chosen == null ? null : registry.byGameId(chosen)) ??
        registry.byGameId('sims4') ??
        registry.adapters.first;
  }

  final GameRegistry registry;
  final SettingsStore settings;
  final Sfx _sfx;

  /// PostHog events, flags and crash reports. A no-op instance in tests.
  /// Event properties never include mod names or file paths - only
  /// counts, sizes and which game is active.
  final Analytics analytics;

  /// Asks GitHub for a newer release; injectable so tests never touch
  /// the network.
  final Future<UpdateInfo?> Function() _checkUpdates;

  /// Downloads the published advisory list; injectable for the same
  /// reason as [_checkUpdates].
  final Future<String?> Function() _loadAdvisories;

  /// Whether this process has administrator rights; injectable so tests
  /// can have either answer without an elevated runner.
  final Future<bool> Function() _checkElevated;

  /// Fetches The Exchange's listings, every game at once; injectable for
  /// the same reason as [_checkUpdates].
  final Future<List<ShopMod>?> Function() _fetchShop;

  /// Fetches one listing by id, for a deep link naming a mod the catalog
  /// page didn't carry; injectable for the same reason as [_fetchShop].
  final Future<ShopMod?> Function(String id) _fetchListing;

  /// Downloads one listing's file; injectable so tests install from a
  /// local byte source instead of the network.
  final Future<void> Function(ShopMod mod, File destination,
      {void Function(int received, int total)? onProgress}) _downloadShop;

  /// Tells The Exchange that a listing was installed, which is where a
  /// creator's download count comes from; injectable so tests count
  /// nothing and touch no network.
  final Future<void> Function(String id) _reportDownload;

  /// Where the user wants a listing's file put, or null when they closed
  /// the dialog; injectable so tests answer without one opening.
  final Future<String?> Function(String suggestedName) _pickSavePath;

  /// Asks whether our own services answer from this machine; injectable
  /// for the same reason as [_checkUpdates].
  final Future<Reachability> Function(String? mirrorBase) _probeServices;

  /// What the last probe found, seeded in [init] from what the previous
  /// launch stored so the first frame is already right. Everything reads
  /// as reachable until something says otherwise.
  Reachability reachability = Reachability.unknown;

  /// Which run of the probe is the one still worth listening to. It is
  /// never awaited and takes seconds, and a scenario picked or a flag
  /// landing meanwhile starts another - so the launch probe can answer
  /// last and overwrite a newer answer with what it set out to find
  /// before any of that happened.
  int _reachabilityRun = 0;

  /// Whether to offer The Exchange at all. False hides the sidebar card,
  /// the shelves and the install buttons rather than letting the user
  /// find out by pressing them: from mainland China nothing Google-hosted
  /// answers, and retrying is the one thing that cannot help.
  bool get shopReachable => reachability.shop;

  /// Whether the website answers - the creator portal and the shareable
  /// page every listing has.
  bool get siteReachable => reachability.site;

  /// Whether a release's files can be fetched from where GitHub keeps
  /// them. False is what sends the update button through [downloadMirror].
  bool get downloadsReachable => reachability.downloads;

  /// Where to send a download that cannot be fetched from GitHub
  /// directly, from the `download-mirror` flag's payload
  /// (`{"base": "https://.../"}`). The base is prepended to the whole
  /// asset URL, which is the form every GitHub accelerator takes.
  ///
  /// Remote rather than built in, because the accelerators this points
  /// at are run by strangers and go down: a mirror that stops working is
  /// a payload edit, not a release. Off by default, so nothing is routed
  /// anywhere until someone sets one.
  String? get downloadMirror {
    final payload = analytics.payloadOf('download-mirror');
    if (payload is! Map) return null;
    final base = payload['base'];
    // Anything but https would be handing an installer to plain HTTP.
    return base is String && base.startsWith('https://') ? base : null;
  }

  /// The answer a developer picked in Settings instead of asking the
  /// network, or null to ask it. Null in a release build whatever is
  /// stored, since [SettingsStore.debugReachability] reads null there.
  ///
  /// What a scenario says about the mirror stands even where none is
  /// configured. Nulling it there collapsed the list into half its
  /// length - the scenarios pair off differing in that field alone - and
  /// bought nothing: [updateDownload] refuses a null base before it ever
  /// reads this. Watching a download actually take the mirror still
  /// needs a `download-mirror` payload for it to point at.
  Reachability? get _forcedReachability =>
      debugReachabilityFor(settings.debugReachability);

  /// Whether [reachability] holds something picked in Settings rather
  /// than found. Anything that reports or records a reachability-derived
  /// answer has to ask: an invented one must reach neither.
  bool get _reachabilityForced => _forcedReachability != null;

  /// Picks one of [debugReachabilityScenarios], or null to go back to
  /// asking the network - which re-probes, so clearing it restores the
  /// real answer rather than leaving the last invented one on screen.
  Future<void> setDebugReachability(String? id) async {
    final before = reachability;
    await settings.setDebugReachability(id);
    await _refreshReachability();
    // Only when it did not already: two scenarios can describe the same
    // answer, and the row still has to redraw with the new one ticked.
    if (reachability == before) notifyListeners();
  }

  GameAdapter _adapter;
  GameAdapter get adapter => _adapter;

  AppScreen screen = AppScreen.library;
  bool loading = true;
  String query = '';

  /// The categories and folders the library is narrowed to, empty
  /// meaning all of them.
  ///
  /// Sets rather than one chip each because ctrl/cmd-click lights another
  /// without putting the first one out - asked for by a user who wanted
  /// two folders on screen at once and could only ever have one or the
  /// whole library. Several folders are read as "any of these", which is
  /// the only reading that makes the count on the chips add up.
  final selectedCategories = <String>{};
  final selectedFolders = <String>{};

  String? _selectedModPath;

  /// Resolved mods folder for the current game (override wins), or null
  /// when the game/folder couldn't be located.
  Directory? modsDir;

  /// Whether [modsDir] will take a file at all. False on a stock Windows
  /// setup for the games that keep their mods inside the game's install
  /// folder, where every install and removal is going to be refused; the
  /// library says so rather than letting the user find out one failure at
  /// a time. True whenever there is no folder to judge.
  bool modsDirWritable = true;

  /// Whether the app is running as administrator, which on Windows costs
  /// it drag and drop: Explorer sits at medium integrity and cannot reach
  /// a high-integrity window, so a drag is refused by the OS before the
  /// app hears about it. The library says so, because the alternative is
  /// a window that ignores every file dropped on it for no visible
  /// reason. Installing still works - the picker runs in-process. False
  /// everywhere but Windows, and until [init] has asked.
  bool runningElevated = false;

  /// Whether this game reads mods from more than one folder, so an
  /// install has something to ask about. Only The Sims 1 ever does.
  bool hasInstallChoice = false;

  /// Answers cached per folder: the probe writes a file, and refresh runs
  /// after every toggle. Permissions do change (that is the whole point
  /// of telling the user about them), so the folder just told off is
  /// asked again on the next refresh.
  final Map<String, bool> _writableByPath = {};

  Future<bool> _isWritable(Directory dir) async {
    final cached = _writableByPath[dir.path];
    if (cached == true) return true;
    final writable = await canWriteInto(dir);
    _writableByPath[dir.path] = writable;
    return writable;
  }

  bool usingOverride = false;

  List<Mod> _mods = const [];

  /// The current game's library, as of the last [refresh]. Assign through
  /// [_setMods] only: everything derived from it ([folders], the per-chip
  /// counts, the filtered view) is precomputed there.
  List<Mod> get mods => _mods;

  Set<String> conflictPaths = const {};

  /// Why each flagged mod is flagged (see [ConflictReason]); the detail
  /// panel words its warning from this. Keys are exactly [conflictPaths].
  Map<String, ConflictReason> conflictReasons = const {};

  /// Who clashes with whom, minus the pairs the user has settled: mod
  /// path -> (the other mod's path -> why the two are paired). Everything
  /// the library says about conflicts comes from here.
  Map<String, Map<String, ConflictReason>> conflictPairs = const {};

  /// The same before the ignored pairs are taken out, so a mod's page can
  /// say how many of its clashes are being kept quiet - and so the count
  /// only ever mentions clashes the scan is still finding.
  Map<String, Map<String, ConflictReason>> _allConflictPairs = const {};

  /// Resource-key overlaps from the package scan: mod path -> (overlapping
  /// mod's path -> shared key count). See [findResourceOverlaps]. Empty
  /// when conflict warnings are off or nothing overlaps.
  Map<String, Map<String, int>> resourceOverlaps = const {};

  /// When set, [filteredMods] narrows to the mods flagged by the conflict
  /// scan. Toggled by tapping the Conflicts stat in the library header.
  bool conflictsOnly = false;

  /// Narrows [filteredMods] to one side of the switch. Toggled by tapping
  /// the Enabled and Disabled stats, the way [conflictsOnly] is toggled by
  /// the Conflicts one.
  ModStateFilter stateFilter = ModStateFilter.all;

  /// Enabled mods the published advisory list has something to say about:
  /// path -> the advisory covering it. See [matchAdvisories].
  Map<String, ModAdvisory> advisories = const {};

  /// Every advisory that was downloaded, by game id. Kept whole rather
  /// than narrowed to the current game so switching games doesn't need
  /// another download.
  Map<String, List<ModAdvisory>> _publishedAdvisories = const {};

  /// Narrows [filteredMods] to the mods an advisory names, the way
  /// [conflictsOnly] does. Toggled from the library banner.
  bool advisoriesOnly = false;

  /// Narrows [filteredMods] to the mods buried below what the game
  /// reads, the way [advisoriesOnly] does. Toggled from the banner.
  bool tooDeepOnly = false;

  /// The labels the player has put on this game's mods, as stored: mod
  /// path relative to the mods folder -> its tags. See `core/mod_tags.dart`.
  Map<String, Map<String, Set<String>>> _modTags = {};

  /// The invented library's tags. In memory only, and a separate bucket
  /// rather than a flag on the records, because these preferences are
  /// shared with the release build - the same bargain the demo library's
  /// settled clashes make.
  final Map<String, Map<String, Set<String>>> _demoModTags = {};

  /// The current game's tags by the path each mod sits at right now, so
  /// a card can ask for its labels without resolving a path per frame.
  Map<String, List<String>> _tagsByMod = const {};

  /// The tags in use in this library, in the order they are offered, with
  /// how many mods carry each. What the filter row draws its chips from.
  Map<String, int> tagCounts = const {};

  /// When set, [filteredMods] narrows to the mods carrying this tag.
  /// Null rather than an 'All' sentinel: unlike the file types, there is
  /// no chip standing for every tag at once.
  String? tagFilter;

  /// What each mod turns out to hold, by the path it sits at now. Worked
  /// out from the insight cache, so it fills in with the scan and is
  /// empty when the scan is off. See `core/mod_kind.dart`.
  Map<String, Set<String>> _kindsByMod = const {};

  /// The kinds present in this library, in [modKindOrder], with how many
  /// mods each covers. What the filter row draws its kind chips from.
  Map<String, int> kindCounts = const {};

  /// When set, [filteredMods] narrows to the mods of this kind. Null
  /// rather than an 'All' sentinel, like [tagFilter] and for the same
  /// reason.
  String? kindFilter;

  /// What the last duplicate scan found: sets of mods that are the same
  /// file, biggest saving first. Empty until [scanForDuplicates] runs -
  /// unlike the conflict scan this one reads whole files, so it happens
  /// when the user asks rather than on every load.
  List<DuplicateSet> duplicateSets = const [];

  /// Every path in [duplicateSets], for the filter and the card badge.
  Set<String> duplicatePaths = const {};

  /// Narrows [filteredMods] to [duplicatePaths], the way [conflictsOnly]
  /// does.
  bool duplicatesOnly = false;

  /// (hashed, to hash) while a duplicate scan runs, null otherwise.
  (int, int)? duplicateProgress;

  /// Whether a scan has finished since this game was opened, so the UI
  /// can tell "nothing is duplicated" from "nobody has looked yet". A
  /// cancelled scan doesn't get to claim the library is clean.
  bool duplicatesScanned = false;

  /// Set when the user stops a running scan; the workers give up between
  /// batches and whatever was hashed stays cached.
  bool _cancelDuplicateScan = false;

  /// SHA-256 per mod file, under the same key as the insight cache: the
  /// enabled name, the size and the mtime. A file whose bytes changed
  /// under a name that stayed put is a different file, and gets hashed
  /// again rather than answered from here.
  final Map<String, String> _digests = {};

  /// The other folders this game reads mods from, when its own manifest
  /// names any ([GameAdapter.extraModsDirectories]). Nothing chooses
  /// these and nothing installs into them; they are listed so Settings
  /// can say why the library holds more than the mods folder does.
  List<Directory> extraModsDirs = const [];

  /// Alternate mods folders found on this machine (multiple installs,
  /// localized names), shown when the default guess fails or as choices.
  List<Directory> candidateDirs = const [];

  /// Where the mods folder is supposed to live, for the "create it"
  /// offer when nothing exists yet.
  String? defaultPath;

  /// The game's own folder when detected (even without a mods folder
  /// inside), so the setup screen can say "mods folder missing" instead
  /// of "game not found".
  Directory? gameFolder;

  /// Sidebar mod counts per game id (null = folder not found).
  final Map<String, int?> modCounts = {};

  /// Combined mod file size per game id, for the all-games storage total.
  final Map<String, int> modSizes = {};

  /// Stale cache files the current game wants deleted after CC changes
  /// (the game rebuilds them on next launch). Empty for games without
  /// cache files; Settings shows a "Clear caches" card when non-empty.
  List<File> cacheFiles = const [];

  /// Combined size of [cacheFiles], computed once per refresh so
  /// rendering never stats files.
  int cacheSizeBytes = 0;

  /// Space on the volume holding [modsDir], or null while unknown /
  /// undetectable. Filled in asynchronously after [refresh].
  DiskSpace? diskSpace;
  String? _diskSpacePath;

  /// What went wrong with the last thing the user asked for, as a key the
  /// UI translates when it draws it (`AppText.errorText`) - the core layer
  /// that raises most of these has no localizations of its own.
  AppMessage? lastError;

  /// Waves the last failure's message away. The banner keeps it until
  /// then or until the next [refresh] clears it - a failed install is
  /// worth reading twice, and nothing else on the screen is blocked by it.
  void dismissError() {
    if (lastError == null) return;
    playSound(UiSound.click);
    lastError = null;
    notifyListeners();
  }

  LibraryLayout get layout => switch (settings.libraryLayout) {
        'list' => LibraryLayout.list,
        'folders' => LibraryLayout.folders,
        _ => LibraryLayout.grid,
      };

  LibrarySort get sort => switch (settings.librarySort) {
        'recent' => LibrarySort.recent,
        'size' => LibrarySort.size,
        _ => LibrarySort.name,
      };

  /// Whether the switched-off mods sink to the end of the library. Off by
  /// default: they sort in with the rest, which is where they always were.
  bool get disabledLast => settings.disabledLast;

  /// The language Settings is forcing, or null to follow the OS (which is
  /// what a fresh install does: Flutter resolves the system locale against
  /// the shipped translations and falls back to English).
  Locale? get locale {
    final code = settings.localeCode;
    return code == null ? null : Locale(code);
  }

  /// Switches the app's language; `null` hands the choice back to the OS.
  Future<void> setLocale(String? code) async {
    if (code == settings.localeCode) return;
    await settings.setLocaleCode(code);
    playSound(UiSound.select);
    analytics.capture('language_changed', {'language': code ?? 'system'});
    notifyListeners();
  }

  /// Switches between light and dark; `null` follows the OS, which is the
  /// default, so the app starts dark on a dark desktop without being told.
  Future<void> setThemeMode(String? name) async {
    if (name == settings.themeModeName) return;
    await settings.setThemeModeName(name);
    playSound(UiSound.select);
    analytics.capture('theme_changed', {'theme': name ?? 'system'});
    notifyListeners();
  }

  /// Mod by path, and the tallies and groupings the library header and
  /// filter row ask for. All of it is rebuilt once per [_setMods] rather
  /// than derived on demand: a chip that counts its own members walks the
  /// whole library, there is one per category and per subfolder, and every
  /// repaint asks them all again - fine for a few hundred mods, seconds of
  /// jank for the tens of thousands people actually keep.
  final Map<String, Mod> _byPath = {};
  final Map<String, String?> _folderOfPath = {};
  final Map<String, int> _folderCounts = {};

  /// Folder chips whose mods live outside the mods directory (Sims 1
  /// routes skins and walls into sibling game folders). They are grouped
  /// and filtered like the others, but nothing installs into them by
  /// name: the adapter decides where those files go.
  final Set<String> _externalFolders = {};
  final Map<String, int> _categoryCounts = {};
  List<String> _sortedFolders = const [];
  List<String> _sortedCategories = const [];
  int _enabledCount = 0;
  int _totalSizeBytes = 0;

  /// Bumped whenever [mods] or [conflictPaths] change, so [filteredMods]
  /// can tell a cached result from a stale one without every mutator
  /// having to remember to invalidate it.
  int _libraryStamp = 0;

  List<Mod>? _filtered;
  String? _filteredKey;

  void _setMods(List<Mod> value) {
    _mods = value;
    _byPath.clear();
    _folderOfPath.clear();
    _folderCounts.clear();
    _externalFolders.clear();
    _categoryCounts.clear();
    _enabledCount = 0;
    _totalSizeBytes = 0;
    final root = modsDir?.path;
    for (final mod in value) {
      _byPath[mod.path] = mod;
      final folder = root == null ? null : _resolveFolder(root, mod.path);
      _folderOfPath[mod.path] = folder;
      if (folder != null) {
        if (root != null && !p.isWithin(root, mod.path)) {
          _externalFolders.add(folder);
          _folderCounts[folder] = (_folderCounts[folder] ?? 0) + 1;
        } else if (settings.folderIncludesSubfolders) {
          // A folder counts everything below it too, and earns a chip
          // even when it holds no mod files of its own: a user who put
          // everything in cc/defaults still thinks of cc as a folder.
          for (final key in folderAncestry(folder)) {
            _folderCounts[key] = (_folderCounts[key] ?? 0) + 1;
          }
        } else {
          // Counting only its own files, which is the whole point of the
          // setting: the number on the chip has to be the number you get
          // when you press it. A parent still earns its chip - it is a
          // real folder either way - just not a count it didn't earn.
          _folderCounts[folder] = (_folderCounts[folder] ?? 0) + 1;
          for (final key in folderAncestry(folder)) {
            _folderCounts.putIfAbsent(key, () => 0);
          }
        }
      }
      _categoryCounts[mod.category] = (_categoryCounts[mod.category] ?? 0) + 1;
      if (mod.isEnabled) _enabledCount++;
      _totalSizeBytes += mod.sizeBytes ?? 0;
    }
    // Folders the user made and hasn't filled yet exist nowhere in the
    // library, so they are put back here: from this point on a chip, a
    // section and a move target all treat them like any other folder that
    // happens to be empty.
    for (final made in _madeFolders) {
      for (final key in folderAncestry(made)) {
        _folderCounts.putIfAbsent(key, () => 0);
      }
    }
    // Sorting the paths puts each folder straight above its own children.
    _sortedFolders = _folderCounts.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    _sortedCategories = _categoryCounts.keys.toList()..sort();
    // The chips these filters point at may have just gone away.
    selectedCategories.removeWhere((c) => !_categoryCounts.containsKey(c));
    selectedFolders.removeWhere((f) => !_folderCounts.containsKey(f));
    // So might the side of the switch the library is showing: enabling
    // the last disabled mod shouldn't leave an empty list behind.
    if (stateFilter == ModStateFilter.enabled && _enabledCount == 0 ||
        stateFilter == ModStateFilter.disabled && disabledCount == 0) {
      stateFilter = ModStateFilter.all;
    }
    // A tick on a mod that is no longer in the library would be a bulk
    // action reaching for a file nothing can find. Whatever renamed one
    // has already carried its tick over ([_repathSelected]).
    if (_selected.isNotEmpty) {
      final present = {for (final mod in value) mod.path};
      _selected.removeWhere((path) => !present.contains(path));
      if (!_selected.contains(_selectionAnchor)) _selectionAnchor = null;
    }
    // The labels are keyed by where a mod sits, so they are re-read from
    // the records here with the rest of the per-chip counts. So are the
    // kinds, off whatever the insight cache already holds - a game
    // revisited has its chips back before anything is scanned.
    _applyTags();
    _applyKinds();
    _libraryStamp++;
  }

  Mod? get selectedMod {
    final path = _selectedModPath;
    return path == null ? null : _byPath[path];
  }

  List<Mod> get filteredMods {
    final q = query.trim().toLowerCase();
    final key = '$_libraryStamp|${_filterKey(selectedCategories)}'
        '|${_filterKey(selectedFolders)}'
        '|${settings.folderIncludesSubfolders}|$conflictsOnly'
        '|$advisoriesOnly|$tooDeepOnly|$duplicatesOnly|$tagFilter|$kindFilter'
        '|$stateFilter'
        '|${settings.showDisabled}|${sort.name}|$disabledLast|$q';
    final cached = _filtered;
    if (cached != null && _filteredKey == key) return cached;
    // Asking for the disabled ones outranks the preference that hides
    // them: it was a click on that very number, so answering with an
    // empty library would be a joke at the user's expense.
    final hideDisabled =
        !settings.showDisabled && stateFilter != ModStateFilter.disabled;
    final result = [
      for (final mod in mods)
        if ((selectedCategories.isEmpty ||
                selectedCategories.contains(mod.category)) &&
            (selectedFolders.isEmpty ||
                selectedFolders.any((f) => _inFolder(folderOf(mod), f))) &&
            (!conflictsOnly || conflictPaths.contains(mod.path)) &&
            (!advisoriesOnly || advisories.containsKey(mod.path)) &&
            (!tooDeepOnly || tooDeepPaths.contains(mod.path)) &&
            (!duplicatesOnly || duplicatePaths.contains(mod.path)) &&
            (tagFilter == null || _hasTag(mod, tagFilter!)) &&
            (kindFilter == null ||
                (_kindsByMod[mod.path]?.contains(kindFilter) ?? false)) &&
            (stateFilter == ModStateFilter.all ||
                mod.isEnabled == (stateFilter == ModStateFilter.enabled)) &&
            (!hideDisabled || mod.isEnabled) &&
            (q.isEmpty ||
                mod.name.toLowerCase().contains(q) ||
                humanizeModName(mod.name).toLowerCase().contains(q)))
          mod,
    ]..sort(_compareForLibrary);
    _filtered = result;
    _filteredKey = key;
    return result;
  }

  /// The library's order: the disabled ones last when that is asked for,
  /// then whatever [sort] says, then the file name - which every mod has,
  /// so two mods never come out in an order that depends on the run.
  /// (Dart's sort isn't stable, so the tiebreak isn't decoration.)
  int _compareForLibrary(Mod a, Mod b) {
    if (disabledLast && a.isEnabled != b.isEnabled) return a.isEnabled ? -1 : 1;
    final ranked = switch (sort) {
      LibrarySort.name => 0,
      LibrarySort.recent => _byNewest(a.modifiedAt, b.modifiedAt),
      // A file whose size never got read sorts with the smallest rather
      // than jumping the queue.
      LibrarySort.size => (b.sizeBytes ?? -1).compareTo(a.sizeBytes ?? -1),
    };
    return ranked != 0
        ? ranked
        : a.name.toLowerCase().compareTo(b.name.toLowerCase());
  }

  static int _byNewest(DateTime? a, DateTime? b) {
    if (a == null || b == null) return a == b ? 0 : (a == null ? 1 : -1);
    return b.compareTo(a);
  }

  /// Reorders the library. The mods themselves are untouched: this is the
  /// order they are drawn in, so nothing needs re-reading from disk.
  Future<void> setSort(LibrarySort value) async {
    if (value != sort) {
      playSound(UiSound.cycle);
      analytics.capture('library_sorted',
          {'sort': value.name, 'disabled_last': disabledLast});
    }
    await settings.setLibrarySort(value.name);
    notifyListeners();
  }

  Future<void> setDisabledLast(bool value) async {
    if (value != disabledLast) {
      playSound(value ? UiSound.toggleOn : UiSound.toggleOff);
      analytics.capture(
          'library_sorted', {'sort': sort.name, 'disabled_last': value});
    }
    await settings.setDisabledLast(value);
    notifyListeners();
  }

  /// Category labels present in the current library, 'All' first. A game
  /// with one mod file extension (The Sims Medieval has only `.package`)
  /// gives every mod the same category, and a chip counting the whole
  /// library next to 'All' counting the whole library only invites the
  /// question of what it means - so it isn't offered.
  List<String> get categories =>
      _sortedCategories.length < 2 ? const ['All'] : ['All', ..._sortedCategories];

  int categoryCount(String cat) =>
      cat == 'All' ? mods.length : _categoryCounts[cat] ?? 0;

  /// Subfolder of the mods directory holding [mod], at whatever depth it
  /// sits, as a '/'-joined path ('cc', 'cc/defaults'); `null` when the
  /// file sits directly in the mods folder. Mods living outside the mods
  /// directory (Sims 1 routes skins/walls/floors into sibling game
  /// folders) group under their own folder's name instead.
  String? folderOf(Mod mod) {
    // containsKey, not a null check: sitting directly in the mods folder is
    // a cached answer of its own.
    if (_folderOfPath.containsKey(mod.path)) return _folderOfPath[mod.path];
    final root = modsDir?.path;
    return root == null ? null : _resolveFolder(root, mod.path);
  }

  String? _resolveFolder(String root, String path) {
    if (!p.isWithin(root, path)) return p.basename(p.dirname(path));
    final parts = p.split(p.relative(path, from: root));
    // Always '/', on Windows too: this is a key the app compares and
    // saves, not a path it hands back to the filesystem.
    return parts.length > 1
        ? parts.sublist(0, parts.length - 1).join('/')
        : null;
  }

  /// A stable key for a filter set, so [filteredMods] can cache on it.
  static String _filterKey(Set<String> chosen) =>
      (chosen.toList()..sort()).join(' ');

  /// Whether a mod in [actual] belongs under the chip for [selected]:
  /// its own folder, and any folder below it unless the user has asked
  /// for folders to stand for themselves alone
  /// ([SettingsStore.folderIncludesSubfolders]).
  bool _inFolder(String? actual, String selected) => actual != null &&
      (settings.folderIncludesSubfolders
          ? folderIsWithin(actual, selected)
          : actual == selected);

  /// Subfolder paths present in the current library, for the folder
  /// filter chips, parents included. Empty when every mod sits directly
  /// in the root. Follows the user's drag-and-drop arrangement when one
  /// is saved; folders it doesn't mention (new on disk) append
  /// alphabetically.
  List<String> get folders {
    final saved = settings.folderOrder(_adapter.game.id);
    if (saved == null) return _sortedFolders;
    final ordered = <String>[
      for (final f in saved)
        if (_folderCounts.containsKey(f)) f,
    ];
    final placed = ordered.toSet();
    return [...ordered, ..._sortedFolders.where((f) => !placed.contains(f))];
  }

  int folderCount(String f) => _folderCounts[f] ?? 0;

  /// Folders the user made in the app which nothing has landed in yet.
  /// Read from the preference at each [refresh] and dropped as soon as
  /// the folder isn't on disk (deleted in Explorer, or a different
  /// install of the game). See [SettingsStore.madeFolders].
  Set<String> _madeFolders = const {};

  /// Whether [folder] can take mods dropped or moved into it. False for
  /// the folders that aren't the user's arrangement to begin with: The
  /// Sims 1's skins and walls live in the game's own folders, and which
  /// file belongs in which is the adapter's answer rather than a place
  /// to file things.
  bool canMoveInto(String folder) => !_externalFolders.contains(folder);

  /// Every folder a move can send a mod to, in chip order, with `null`
  /// first for the mods folder itself.
  List<String?> get moveTargets =>
      [null, ...folders.where(canMoveInto)];

  /// Whether mods can be moved around at all right now: there has to be
  /// a folder to move them in, and it has to accept files.
  bool get canMoveMods => modsDir != null && modsDirWritable;

  /// Whether [mod] is somewhere a move can pick it up from - inside the
  /// mods folder. The Sims 1 routes skins and walls into folders of the
  /// game's own, and which file belongs in which of those is the
  /// adapter's answer rather than the user's filing, so a move never
  /// touches them. Asked before the gesture is offered, since a Move
  /// button that quietly does nothing is worse than no button.
  bool canMove(Mod mod) {
    final root = modsDir?.path;
    return root != null && p.isWithin(root, mod.path);
  }

  /// The key a collapsed section is remembered under when it is the mods
  /// directory itself, which has no folder name of its own.
  static const rootFolderKey = '';

  /// [filteredMods] gathered into the folder view's sections. Grouped on
  /// the folder each mod actually sits in rather than on the ancestry the
  /// chips count, so nothing is listed twice; the sections then follow
  /// [folders], which means rearranging the chips rearranges these too.
  /// The mods directory itself comes first whatever that order says.
  ///
  /// A tree, in tree order: every section is followed by its own
  /// subfolders before the next section at its level, and carries the
  /// [ModFolderGroup.depth] to draw that with. What it does *not* carry
  /// is which of them are on screen - a rolled-up section hides the ones
  /// below it, and that is the drawing's business. Keeping it out of
  /// here is what lets this stay cached against the library rather than
  /// being rebuilt every time a chevron is clicked.
  List<ModFolderGroup> get folderGroups {
    final visible = filteredMods;
    final cached = _folderGroups;
    if (cached != null && identical(_folderGroupsFrom, visible)) return cached;
    final byFolder = <String?, List<Mod>>{};
    for (final mod in visible) {
      (byFolder[folderOf(mod)] ??= []).add(mod);
    }

    // Who sits under whom, in the chip order, so siblings follow the
    // arrangement the user made. A folder whose parent is not itself a
    // chip hangs off the top rather than off nothing - the Sims 1's
    // external folders resolve to a bare name, and a section nobody can
    // reach is a mod nobody can reach.
    final known = folders.toSet();
    final children = <String?, List<String>>{};
    for (final f in folders) {
      final segments = folderSegments(f);
      final parent = segments.length > 1
          ? segments.sublist(0, segments.length - 1).join(folderSeparator)
          : null;
      (children[known.contains(parent) ? parent : null] ??= []).add(f);
    }

    // What a folder holds all the way down, which is what its header
    // says: a closed `cc` reading 0 while it hides two hundred mods is
    // the opposite of the point. Filled before anything is drawn,
    // because building a group takes its mods out of [byFolder].
    final totals = <String, ({int mods, int bytes})>{};
    ({int mods, int bytes}) totalOf(String f) {
      final memo = totals[f];
      if (memo != null) return memo;
      var mods = 0;
      var bytes = 0;
      for (final mod in byFolder[f] ?? const <Mod>[]) {
        mods++;
        bytes += mod.sizeBytes ?? 0;
      }
      for (final child in children[f] ?? const <String>[]) {
        final sub = totalOf(child);
        mods += sub.mods;
        bytes += sub.bytes;
      }
      return totals[f] = (mods: mods, bytes: bytes);
    }

    for (final f in folders) {
      totalOf(f);
    }

    ModFolderGroup group(String? folder, int depth) {
      final mods = byFolder.remove(folder) ?? const <Mod>[];
      final own = mods.fold<int>(0, (sum, m) => sum + (m.sizeBytes ?? 0));
      final total = folder == null
          ? (mods: mods.length, bytes: own)
          : totals[folder] ?? (mods: mods.length, bytes: own);
      return (
        folder: folder,
        mods: mods,
        sizeBytes: own,
        depth: depth,
        totalMods: total.mods,
        totalSizeBytes: total.bytes,
      );
    }

    // A folder the user just made draws its own empty section, which is
    // what makes it somewhere to drag mods to. Only while nothing is
    // filtered: an empty section under a search would say the folder
    // holds nothing rather than that nothing in it matched. A folder
    // holding one of those has to be drawn too, or the new folder is
    // somewhere the user cannot get to.
    final shows = <String, bool>{};
    bool showable(String f) => shows[f] ??= totals[f]!.mods > 0 ||
        (!isFiltering && _madeFolders.contains(f)) ||
        (children[f] ?? const <String>[]).any(showable);

    final result = <ModFolderGroup>[];
    void emit(String? parent, int depth) {
      for (final f in children[parent] ?? const <String>[]) {
        if (!showable(f)) continue;
        result.add(group(f, depth));
        emit(f, depth + 1);
      }
    }

    if (byFolder.containsKey(null)) result.add(group(null, 0));
    emit(null, 0);
    // Anything the chip order somehow missed still has to be drawn, for
    // the same reason.
    for (final f in byFolder.keys.toList()) {
      result.add(group(f, 0));
    }
    _folderGroups = result;
    _folderGroupsFrom = visible;
    return result;
  }

  List<ModFolderGroup>? _folderGroups;
  List<Mod>? _folderGroupsFrom;

  /// Whether [folder]'s section is rolled up.
  ///
  /// **A subfolder starts rolled up and a top-level one starts open.**
  /// Every level used to be drawn at once, so a library organised into
  /// `cc/hair/female` opened on a wall of headers with the mods pushed
  /// off the bottom of it - which is what a tree is for. What is stored
  /// is the sections the user has since flipped away from that, one list
  /// each way; see [SettingsStore.expandedFolders] for why it is two
  /// lists and not one.
  bool isFolderCollapsed(String? folder) {
    final key = folder ?? rootFolderKey;
    final gameId = _adapter.game.id;
    if (settings.collapsedFolders(gameId).contains(key)) return true;
    if (settings.expandedFolders(gameId).contains(key)) return false;
    return folder != null && folderSegments(folder).length > 1;
  }

  /// Rolls a folder view section up or down. Remembered per game, so a
  /// library someone has organised stays the way they left it.
  Future<void> toggleFolderCollapsed(String? folder) async {
    final key = folder ?? rootFolderKey;
    final gameId = _adapter.game.id;
    final collapse = !isFolderCollapsed(folder);
    final collapsed = settings.collapsedFolders(gameId).toSet();
    final expanded = settings.expandedFolders(gameId).toSet();
    // Recorded on the side it is now on and taken off the other, so the
    // two lists can never both claim the same section.
    (collapse ? collapsed : expanded).add(key);
    (collapse ? expanded : collapsed).remove(key);
    playSound(collapse ? UiSound.toggleOff : UiSound.toggleOn);
    await settings.setCollapsedFolders(gameId, collapsed.toList());
    await settings.setExpandedFolders(gameId, expanded.toList());
    notifyListeners();
  }

  /// Drops folder chip [moved] onto [target]: [moved] takes [target]'s
  /// position. Only the folder chips rearrange; category chips and every
  /// other filter keep their order. Remembered per game.
  Future<void> reorderFolder(String moved, String target) async {
    final order = folders.toList();
    final from = order.indexOf(moved);
    final to = order.indexOf(target);
    if (from < 0 || to < 0 || from == to) return;
    playSound(UiSound.click);
    analytics.capture('folders_reordered', {'game': _adapter.game.id});
    order.removeAt(from);
    order.insert(to, moved);
    await settings.setFolderOrder(_adapter.game.id, order);
    // The folder view's sections follow this order, and the mods they
    // hold haven't changed - the one way that cache goes stale without
    // the library underneath it moving.
    _folderGroups = null;
    notifyListeners();
  }

  int get enabledCount => _enabledCount;

  int get disabledCount => _mods.length - _enabledCount;
  int get conflictCount => conflictPaths.length;
  int get totalSizeBytes => _totalSizeBytes;

  /// Combined size of every game's mods, for the sidebar storage card.
  int get allGamesSizeBytes =>
      modSizes.values.fold(0, (sum, size) => sum + size);

  bool isConflicted(Mod mod) => conflictPaths.contains(mod.path);

  /// Why [mod] is flagged: the other enabled mods sharing its file name
  /// (case-insensitive), looking like another version of it, or carrying
  /// the same resource keys inside. Empty when the mod isn't conflicted.
  /// In library order, so the panel reads the way the shelf does.
  List<Mod> conflictingWith(Mod mod) {
    final partners = conflictPairs[mod.path];
    if (partners == null || partners.isEmpty) return const [];
    return [
      for (final other in mods)
        if (partners.containsKey(other.path)) other,
    ];
  }

  /// How many resource keys [mod] and [other] both carry (0 when they
  /// don't overlap or weren't scanned), for the conflict panel's
  /// "N shared resources" detail.
  int sharedResourcesWith(Mod mod, Mod other) =>
      resourceOverlaps[mod.path]?[other.path] ?? 0;

  /// Whether anything the user can switch off from the library is
  /// narrowing it right now - exactly what [clearFilters] clears, which
  /// is why the show-disabled preference isn't in it.
  bool get isFiltering =>
      query.isNotEmpty ||
      selectedCategories.isNotEmpty ||
      selectedFolders.isNotEmpty ||
      conflictsOnly ||
      advisoriesOnly ||
      tooDeepOnly ||
      duplicatesOnly ||
      tagFilter != null ||
      kindFilter != null ||
      stateFilter != ModStateFilter.all;

  /// Narrows the library to the enabled or the disabled mods, or back to
  /// all of them when [state] is already the one showing. No-op when that
  /// side of the library is empty.
  void showOnly(ModStateFilter state) {
    if (state == stateFilter) state = ModStateFilter.all;
    if (state == ModStateFilter.enabled && enabledCount == 0) return;
    if (state == ModStateFilter.disabled && disabledCount == 0) return;
    playSound(UiSound.cycle);
    stateFilter = state;
    if (state != ModStateFilter.all) {
      analytics.capture('state_filter_opened', {
        'state': state.name,
        'mods': state == ModStateFilter.enabled ? enabledCount : disabledCount,
      });
    }
    notifyListeners();
  }

  /// The Total stat's click: everything the library was narrowed by, off
  /// at once, so the count it shows is the count you get. The
  /// show-disabled preference is left alone - it's a setting the user
  /// chose, not a filter they left on.
  void clearFilters() {
    if (!isFiltering) return;
    playSound(UiSound.cycle);
    query = '';
    selectedCategories.clear();
    selectedFolders.clear();
    conflictsOnly = false;
    advisoriesOnly = false;
    tooDeepOnly = false;
    duplicatesOnly = false;
    tagFilter = null;
    kindFilter = null;
    stateFilter = ModStateFilter.all;
    notifyListeners();
  }

  /// Whether any chip on the filter line is lit - the four axes drawn
  /// there, and nothing else. What the 'All' chip reads to know whether
  /// to draw itself lit.
  bool get anyChipFilter =>
      selectedCategories.isNotEmpty ||
      selectedFolders.isNotEmpty ||
      kindFilter != null ||
      tagFilter != null;

  /// The 'All' chip's click: every chip on the filter line off at once.
  ///
  /// Narrower than [clearFilters], which is the Total stat's click and
  /// takes the search box, the stat filters and the state filter with
  /// it. Those are not chips on this line, and a click on one chip has
  /// no business emptying the search someone is halfway through.
  void clearChipFilters() {
    if (!anyChipFilter) return;
    playSound(UiSound.cycle);
    selectedCategories.clear();
    selectedFolders.clear();
    kindFilter = null;
    tagFilter = null;
    notifyListeners();
  }

  /// The mods ticked for a bulk action, by the path each one carries on
  /// disk right now - marker and all.
  ///
  /// Not the enabled-name path, which reads like the better identity and
  /// is not one: a folder can hold `hair.package` and `hair.package.disabled`
  /// at the same time (install over a mod you had switched off), and those
  /// two collapse onto a single enabled name. One tick would then have
  /// meant two files, and Delete would have taken both. So the key is the
  /// real path and every rename carries its tick across by hand
  /// ([_repathSelected]).
  final Set<String> _selected = {};

  /// Where a shift-click measures from: the last mod ticked on its own.
  /// Null once that mod leaves the library, or after a select-all, which
  /// leaves no single mod the range could start at.
  String? _selectionAnchor;

  bool get hasSelection => _selected.isNotEmpty;

  int get selectedCount => _selected.length;

  bool isSelected(Mod mod) => _selected.contains(mod.path);

  /// The ticked mods, in library order. Read off [mods] rather than
  /// [filteredMods]: a selection made before the filters changed is still
  /// the selection the user made, and a bulk action has to reach all of
  /// it rather than whatever half is on screen when the button is hit.
  List<Mod> get selectedMods => [
        for (final mod in mods)
          if (_selected.contains(mod.path)) mod,
      ];

  /// One pass rather than [selectedMods] plus a fold: this is drawn in the
  /// selection bar, which rebuilds on every notification a batch fires.
  int get selectedSizeBytes {
    var total = 0;
    for (final mod in mods) {
      if (_selected.contains(mod.path)) total += mod.sizeBytes ?? 0;
    }
    return total;
  }

  /// Whether at least one ticked mod is somewhere a move can pick it up
  /// from, so the bar can leave the button out rather than offer one that
  /// does nothing.
  bool get hasMovableSelection {
    for (final mod in mods) {
      if (_selected.contains(mod.path) && canMove(mod)) return true;
    }
    return false;
  }

  /// Whether everything the filters are showing is already ticked, so the
  /// bar can offer the other half of the deal.
  bool get allVisibleSelected {
    final visible = filteredMods;
    return visible.isNotEmpty &&
        visible.every((mod) => _selected.contains(mod.path));
  }

  /// The mods in the order they are actually drawn, which in the folder
  /// layout means section by section with the rolled-up ones left out.
  /// What a range has to be measured over: [filteredMods] is one flat run
  /// in a different order, and it holds mods no section is showing.
  List<Mod> get visibleMods {
    if (layout != LibraryLayout.folders) return filteredMods;
    return [
      for (final group in folderGroups)
        if (!isFolderCollapsed(group.folder)) ...group.mods,
    ];
  }

  /// Ticks or unticks [mod], and makes it what a following shift-click
  /// measures from.
  void toggleSelected(Mod mod) {
    if (!_selected.remove(mod.path)) _selected.add(mod.path);
    playSound(UiSound.click);
    _selectionAnchor = mod.path;
    notifyListeners();
  }

  /// Shift-click: [mod] and everything between it and the last mod ticked
  /// on its own, in the order the library is drawn in - so the range is
  /// the one on screen rather than the one on disk. Falls back to ticking
  /// [mod] alone when there is nothing to measure from, which is what the
  /// first shift-click of a session is.
  void selectTo(Mod mod) {
    final anchor = _selectionAnchor;
    if (anchor == null) return toggleSelected(mod);
    final visible = visibleMods;
    final from = visible.indexWhere((m) => m.path == anchor);
    final to = visible.indexWhere((m) => m.path == mod.path);
    if (from < 0 || to < 0) return toggleSelected(mod);
    for (var i = from < to ? from : to; i <= (from < to ? to : from); i++) {
      _selected.add(visible[i].path);
    }
    playSound(UiSound.click);
    notifyListeners();
  }

  /// Ticks everything the filters are showing, which is the promise the
  /// button makes: what is on screen, not what is on disk. Searching for
  /// "eyelashes" and hitting it is how a hundred files get switched off
  /// in one go.
  void selectAllVisible() {
    final visible = filteredMods;
    if (visible.isEmpty) return;
    playSound(UiSound.select);
    for (final mod in visible) {
      _selected.add(mod.path);
    }
    // No single mod for a range to start at.
    _selectionAnchor = null;
    analytics.capture(
        'mods_select_all', {'game': _adapter.game.id, 'mods': visible.length});
    notifyListeners();
  }

  /// Carries a tick from [from] to [to], for the renames that are what
  /// enabling, disabling and moving a mod all are on disk.
  void _repathSelected(String from, String to) {
    if (from == to) return;
    if (_selected.remove(from)) _selected.add(to);
    if (_selectionAnchor == from) _selectionAnchor = to;
  }

  void clearSelection() {
    if (_selected.isEmpty) return;
    playSound(UiSound.back);
    _selected.clear();
    _selectionAnchor = null;
    notifyListeners();
  }

  /// Narrows the library to conflicting mods, or back to all of them.
  /// No-op when there's nothing to narrow to.
  void toggleConflictsOnly() {
    if (!conflictsOnly && conflictCount == 0) return;
    playSound(UiSound.cycle);
    conflictsOnly = !conflictsOnly;
    if (conflictsOnly) {
      analytics.capture('conflicts_filter_opened', {'conflicts': conflictCount});
    }
    notifyListeners();
  }

  /// Re-runs the conflict scan; releases the conflicts-only filter when
  /// nothing is flagged anymore, so the library never sticks on an
  /// inexplicably empty list. The remote kill switch can turn the scan
  /// off for everyone if the heuristic ever misbehaves.
  ///
  /// [findConflictPairs] folds every signal there is: its own lexical
  /// heuristics, the real resource-key overlaps handed to it
  /// ([findResourceOverlaps], via the insight cache - so with the artwork
  /// scan off only the lexical pass runs), and the whole-file digests
  /// ([digestOf], which answers for nothing until the user has run the
  /// duplicate scan). What each mod is flagged for then follows from the
  /// pairs it has left once [_applyIgnored] has taken out the ones the
  /// user settled.
  void _rescanConflicts() {
    resourceOverlaps = _conflictScanOn
        ? findResourceOverlaps(mods, insightFor)
        : const {};
    _rebuildConflictPairs();
  }

  bool get _conflictScanOn =>
      settings.warnConflicts &&
      analytics.isEnabled('conflict-detection', fallback: true);

  /// The pairs again from the overlaps already in hand.
  ///
  /// Split off [_rescanConflicts] for the duplicate scan's sake: finishing
  /// one changes what [digestOf] can answer, so the pairs have to be
  /// rebuilt for the identical files to be reported as identical rather
  /// than as whatever they resembled. Nothing it reads has moved, though -
  /// the packages, the library and the insight cache are where they were -
  /// so redoing the resource pass would be several seconds of frozen
  /// window bought for an answer that cannot have changed.
  void _rebuildConflictPairs() {
    _allConflictPairs = _conflictScanOn
        ? findConflictPairs(mods, resourceOverlaps, digestOf: digestOf)
        : const {};
    _applyIgnored();
  }

  /// The scan already in hand, minus the clashes this game's player has
  /// settled. A mod whose last pair goes stops being flagged at all -
  /// which is the point of the whole thing: the count, the badge and the
  /// filter are then about the conflicts that are still a question.
  ///
  /// Separate from [_rescanConflicts] because ignoring a clash changes
  /// none of the things a scan reads: the packages, the library and the
  /// insight cache are all where they were, so re-running the resource
  /// pass - the work [refresh] does under the loading screen - would be
  /// several seconds of frozen window per click.
  void _applyIgnored() {
    final ignored = _ignoredKeys();
    final root = modsDir?.path;
    // The mods folder is what every record is measured from, so one pass
    // over the library answers for every pair below instead of two path
    // resolutions each.
    _recordPaths = ignored.isEmpty || root == null
        ? const {}
        : {
            for (final mod in mods)
              mod.path: p.relative(enabledPathOf(mod.path), from: root),
          };
    _ignoredByMod = _ignoredRecordsByMod(ignored);
    conflictPairs = _withoutIgnored(_allConflictPairs);
    conflictReasons = conflictReasonsOf(conflictPairs);
    conflictPaths = conflictReasons.keys.toSet();
    if (conflictPaths.isEmpty) conflictsOnly = false;
    _libraryStamp++;
  }

  /// Which settled clashes name each mod in the library, by its path.
  ///
  /// Read off the records and the library rather than off the pairs: a
  /// clash the partner cap recorded on one side only ([_maxPartnersPerMod])
  /// is still one both of its mods were told to keep quiet, and the mod
  /// whose row is full has to be able to say so and to take it back.
  Map<String, Set<String>> _ignoredRecordsByMod(Set<String> ignored) {
    if (ignored.isEmpty || _recordPaths.isEmpty) return const {};
    final byRecord = <String, String>{
      for (final entry in _recordPaths.entries) entry.value: entry.key,
    };
    final byMod = <String, Set<String>>{};
    for (final key in ignored) {
      for (final record in conflictPairPaths(key) ?? const <String>[]) {
        final path = byRecord[record];
        if (path != null) byMod.putIfAbsent(path, () => {}).add(key);
      }
    }
    return byMod;
  }

  Map<String, Map<String, ConflictReason>> _withoutIgnored(
      Map<String, Map<String, ConflictReason>> pairs) {
    final ignored = _ignoredKeys();
    if (ignored.isEmpty || pairs.isEmpty) return pairs;
    final kept = <String, Map<String, ConflictReason>>{};
    for (final entry in pairs.entries) {
      final row = {
        for (final partner in entry.value.entries)
          if (!ignored.contains(_pairKey(entry.key, partner.key)))
            partner.key: partner.value,
      };
      if (row.isNotEmpty) kept[entry.key] = row;
    }
    return kept;
  }

  /// Why the scan flagged [mod], or null when it didn't.
  ConflictReason? conflictReasonOf(Mod mod) => conflictReasons[mod.path];

  /// Clashes the user has settled, by game id, as the pair keys of
  /// `core/ignored_conflicts.dart`.
  Map<String, Set<String>> _ignoredConflicts = {};

  /// The same for the invented library, which is never written down: its
  /// mods do not exist, and the two builds share these preferences, so a
  /// screenshot session must not leave records the shipped app reads.
  /// Dropped with the rest of the invented state when demo mode goes off
  /// (see [_withDemoMods]), the way the demo shop's install records are.
  final Map<String, Set<String>> _demoIgnoredConflicts = {};

  /// Each mod's path as its records spell it: relative to the mods folder
  /// and always the switched-on name. Built once per scan, empty when
  /// nothing is ignored and there is nothing to match.
  Map<String, String> _recordPaths = const {};

  /// The settled clashes naming each mod, by its path. See
  /// [_ignoredRecordsByMod].
  Map<String, Set<String>> _ignoredByMod = const {};

  Set<String> _ignoredKeys() {
    final gameId = _adapter.game.id;
    final real = _ignoredConflicts[gameId] ?? const <String>{};
    final demo = _demoIgnoredConflicts[gameId] ?? const <String>{};
    if (demo.isEmpty) return real;
    return {...real, ...demo};
  }

  /// The stored key for the clash between two mods, or null when there is
  /// no mods folder to measure from. Relative and always the switched-on
  /// name, so the record survives a disable and a whole install moving.
  String? _pairKey(String path, String other) {
    final root = modsDir?.path;
    if (root == null) return null;
    String record(String of) =>
        _recordPaths[of] ?? p.relative(enabledPathOf(of), from: root);
    return conflictPairKey(record(path), record(other));
  }

  /// How many of [mod]'s clashes are being kept quiet.
  int ignoredConflictsOf(Mod mod) => _ignoredByMod[mod.path]?.length ?? 0;

  /// Every clash settled for the game on screen, the number Settings
  /// offers to undo. Counts the records naming a mod that is actually
  /// here: one whose files have since gone would be a card the user
  /// cannot act on, offering to bring back a warning nothing would draw.
  int get ignoredConflictCount =>
      _ignoredByMod.values.fold(<String>{}, (keys, held) => keys..addAll(held))
          .length;

  /// Stops reporting the clash between [mod] and [other]. The pair, not
  /// the mod: whatever else either of them clashes with is still flagged.
  Future<void> ignoreConflict(Mod mod, Mod other) async {
    final key = _pairKey(mod.path, other.path);
    if (key == null) return;
    final gameId = _adapter.game.id;
    playSound(UiSound.toggleOff);
    analytics.capture('conflict_ignored', {
      'reason': (_allConflictPairs[mod.path]?[other.path] ??
              ConflictReason.resourceOverlap)
          .name,
      'game': gameId,
    });
    final invented = isDemoMod(mod) || isDemoMod(other);
    final bucket = invented ? _demoIgnoredConflicts : _ignoredConflicts;
    bucket[gameId] = {...?bucket[gameId], key};
    await _rememberIgnored(persist: !invented);
  }

  /// Brings back everything [mod] was keeping quiet.
  Future<void> restoreConflicts(Mod mod) async {
    final back = _ignoredByMod[mod.path];
    if (back == null || back.isEmpty) return;
    playSound(UiSound.toggleOn);
    analytics.capture('conflicts_restored', {'scope': 'mod'});
    await _dropIgnored(back);
  }

  /// Every settled clash for this game, back. The way out from Settings,
  /// and the only one for a mod whose page shows nothing anymore because
  /// its last flagged clash was the one that got ignored. Takes the
  /// records naming mods that are no longer here with it: they are the
  /// ones nothing else can reach.
  Future<void> restoreAllConflicts() async {
    final ignored = _ignoredKeys();
    if (ignored.isEmpty) return;
    playSound(UiSound.toggleOn);
    analytics.capture('conflicts_restored', {'scope': 'game'});
    await _dropIgnored(ignored);
  }

  Future<void> _dropIgnored(Set<String> keys, {bool notify = true}) async {
    final gameId = _adapter.game.id;
    var persist = false;
    for (final bucket in [_ignoredConflicts, _demoIgnoredConflicts]) {
      final held = bucket[gameId];
      if (held == null) continue;
      final kept = held.difference(keys);
      if (kept.length == held.length) continue;
      persist |= identical(bucket, _ignoredConflicts);
      if (kept.isEmpty) {
        bucket.remove(gameId);
      } else {
        bucket[gameId] = kept;
      }
    }
    await _rememberIgnored(persist: persist, notify: notify);
  }

  /// Drops every record naming [mod], for when it is uninstalled - the
  /// way [_forgetPlaced] and the shop's install record are dropped. A
  /// kept record would outlive the file and, since a record is a path,
  /// silently apply to whatever is installed there next.
  Future<void> _forgetIgnored(Mod mod) async {
    final held = _ignoredByMod[mod.path];
    if (held == null || held.isEmpty) return;
    await _dropIgnored(held, notify: false);
  }

  /// The labels on [mod], in the order they are drawn. Empty for most
  /// mods, which is why this answers from a map built once per library
  /// rather than resolving a path: it is asked on every card of every
  /// frame.
  List<String> tagsOf(Mod mod) => _tagsByMod[mod.path] ?? const [];

  bool _hasTag(Mod mod, String tag) {
    final held = _tagsByMod[mod.path];
    if (held == null) return false;
    final key = tagKey(tag);
    return held.any((one) => tagKey(one) == key);
  }

  /// How many mods carry [tag], for its chip.
  int tagCount(String tag) => tagCounts[tag] ?? 0;

  /// Narrows the library to one tag, or lets go of it when [tag] is
  /// already the one showing.
  void setTagFilter(String? tag) {
    if (tag != null && tagKey(tag) == tagKey(tagFilter ?? '')) tag = null;
    if (tag == tagFilter) return;
    playSound(UiSound.cycle);
    tagFilter = tag;
    if (tag != null) {
      // The tag itself is the user's own words and never leaves the
      // machine; how many mods wear it is ours to count.
      analytics.capture(
          'tag_filtered', {'game': _adapter.game.id, 'mods': tagCount(tag)});
    }
    notifyListeners();
  }

  /// Which bucket [mod]'s labels belong in: the invented library's stay
  /// in memory, everything else is written down.
  Map<String, Map<String, Set<String>>> _tagBucketFor(Mod mod) =>
      isDemoMod(mod) ? _demoModTags : _modTags;

  /// Where a mod is written down in the records: its path while switched
  /// on, relative to the mods folder. Null when there is no folder to
  /// measure from, which is a library nothing can be tagged in anyway.
  String? _tagRecordPath(Mod mod) {
    final root = modsDir?.path;
    if (root == null) return null;
    return p.relative(enabledPathOf(mod.path), from: root);
  }

  /// Rebuilds what the library draws from the records: every mod's
  /// labels by the path it sits at now, and the vocabulary with its
  /// counts. Runs whenever the library or the records change, which is
  /// what keeps a chip's count honest after a delete.
  void _applyTags() {
    final gameId = _adapter.game.id;
    final stored = _modTags[gameId];
    final invented = _demoModTags[gameId];
    if ((stored == null || stored.isEmpty) &&
        (invented == null || invented.isEmpty)) {
      if (_tagsByMod.isNotEmpty || tagCounts.isNotEmpty) {
        _tagsByMod = const {};
        tagCounts = const {};
        _libraryStamp++;
      }
      tagFilter = null;
      return;
    }
    final root = modsDir?.path;
    final byMod = <String, List<String>>{};
    if (root != null) {
      for (final mod in mods) {
        final record = p.relative(enabledPathOf(mod.path), from: root);
        final held = (isDemoMod(mod) ? invented : stored)?[record];
        if (held == null || held.isEmpty) continue;
        byMod[mod.path] = sortTags(held);
      }
    }
    _tagsByMod = byMod;
    tagCounts = countTags(byMod.values);
    // A tag whose last mod was deleted or moved out of sight leaves with
    // it; a filter still pointing at it would show an empty library and
    // no chip to explain why.
    final filter = tagFilter;
    if (filter != null && !tagCounts.keys.any((t) => tagKey(t) == tagKey(filter))) {
      tagFilter = null;
    }
    _libraryStamp++;
  }

  /// What [mod] turns out to hold, in [modKindOrder]. Empty for a mod
  /// the scan could not read, and for every mod while the scan that
  /// reads inside files is switched off - which is why nothing in the UI
  /// says "none", it just has no chips to draw.
  Set<String> kindsOf(Mod mod) => _kindsByMod[mod.path] ?? const {};

  /// How many mods are of [kind], for its chip.
  int kindCount(String kind) => kindCounts[kind] ?? 0;

  /// Narrows the library to one kind, or lets go of it when [kind] is
  /// already the one showing.
  void setKindFilter(String? kind) {
    if (kind == kindFilter) {
      kind = null;
    }
    playSound(UiSound.cycle);
    kindFilter = kind;
    if (kind != null) {
      // The kind is our own vocabulary of four rather than the user's
      // words, so it travels with the count the way a category does.
      analytics.capture('kind_filtered',
          {'game': _adapter.game.id, 'kind': kind, 'mods': kindCount(kind)});
    }
    notifyListeners();
  }

  /// Rebuilds what each mod turns out to hold, from the insight cache.
  /// Runs wherever [_applyTags] does, and again as the scan fills the
  /// cache in - a library opens with no kind chips and grows them as the
  /// files are read, the same way the artwork appears.
  void _applyKinds() {
    final byMod = <String, Set<String>>{};
    for (final mod in mods) {
      final kinds = modKindsOf(insightFor(mod),
          extension: p.extension(enabledPathOf(mod.path)).toLowerCase());
      if (kinds.isNotEmpty) byMod[mod.path] = kinds;
    }
    if (byMod.isEmpty && _kindsByMod.isEmpty) {
      kindFilter = null;
      return;
    }
    _kindsByMod = byMod;
    kindCounts = countKinds(byMod.values);
    // A kind whose last mod was deleted, or that the scan stopped
    // finding, leaves with it: a filter pointing at it would show an
    // empty library and no chip to explain why.
    if (kindFilter != null && !kindCounts.containsKey(kindFilter)) {
      kindFilter = null;
    }
    _libraryStamp++;
  }

  /// Puts [raw] on every mod in [targets]. The spelling already in use
  /// wins over the one just typed, so "Spooky" typed over a library of
  /// "spooky" mods joins that chip instead of starting a second one.
  /// A mod already carrying the tag, and one already at [maxTagsPerMod],
  /// are both left alone.
  Future<void> addTag(List<Mod> targets, String raw) async {
    final tag = sanitizeTag(raw);
    if (tag == null || targets.isEmpty) return;
    final existing = tagCounts.keys.firstWhere(
        (held) => tagKey(held) == tagKey(tag),
        orElse: () => tag);
    var added = 0;
    var persist = false;
    for (final mod in targets) {
      final record = _tagRecordPath(mod);
      if (record == null) continue;
      final bucket = _tagBucketFor(mod);
      final gameId = _adapter.game.id;
      final held = bucket[gameId]?[record] ?? const <String>{};
      if (held.any((t) => tagKey(t) == tagKey(existing))) continue;
      if (held.length >= maxTagsPerMod) continue;
      (bucket[gameId] ??= {})[record] = {...held, existing};
      added++;
      persist |= identical(bucket, _modTags);
    }
    if (added == 0) return;
    playSound(UiSound.click);
    analytics.capture('mods_tagged',
        {'game': _adapter.game.id, 'mods': added, 'tags': tagCounts.length});
    await _rememberTags(persist: persist);
  }

  /// Takes [tag] off every mod in [targets] - which is also the only way
  /// a tag itself goes away, since a tag nothing carries is not a thing
  /// the app keeps.
  Future<void> removeTag(List<Mod> targets, String tag) async {
    final key = tagKey(tag);
    var removed = 0;
    var persist = false;
    final gameId = _adapter.game.id;
    for (final mod in targets) {
      final record = _tagRecordPath(mod);
      if (record == null) continue;
      final bucket = _tagBucketFor(mod);
      final held = bucket[gameId]?[record];
      if (held == null) continue;
      final kept = {
        for (final tag in held)
          if (tagKey(tag) != key) tag,
      };
      if (kept.length == held.length) continue;
      if (kept.isEmpty) {
        bucket[gameId]!.remove(record);
        if (bucket[gameId]!.isEmpty) bucket.remove(gameId);
      } else {
        bucket[gameId]![record] = kept;
      }
      removed++;
      persist |= identical(bucket, _modTags);
    }
    if (removed == 0) return;
    playSound(UiSound.click);
    analytics.capture(
        'mods_untagged', {'game': _adapter.game.id, 'mods': removed});
    await _rememberTags(persist: persist);
  }

  Future<void> _rememberTags({required bool persist}) async {
    if (persist) await settings.setModTagsJson(encodeModTags(_modTags));
    _applyTags();
    notifyListeners();
  }

  /// Drops the labels of a mod that has been uninstalled, the way
  /// [_forgetIgnored] drops its settled clashes: a record is a path, and
  /// a kept one would silently land on whatever is installed there next.
  Future<void> _forgetTags(Mod mod) async {
    final record = _tagRecordPath(mod);
    if (record == null) return;
    final gameId = _adapter.game.id;
    var persist = false;
    var changed = false;
    for (final bucket in [_modTags, _demoModTags]) {
      final held = bucket[gameId];
      if (held == null || !held.containsKey(record)) continue;
      held.remove(record);
      if (held.isEmpty) bucket.remove(gameId);
      changed = true;
      persist |= identical(bucket, _modTags);
    }
    if (!changed) return;
    if (persist) await settings.setModTagsJson(encodeModTags(_modTags));
  }

  /// Labels follow their mods through a move, like every other record
  /// keyed by where a mod sits.
  Future<void> _repathTags(Map<String, String> renamed) async {
    final gameId = _adapter.game.id;
    var persist = false;
    var changed = false;
    for (final bucket in [_modTags, _demoModTags]) {
      final held = bucket[gameId];
      if (held == null || held.isEmpty) continue;
      final rebuilt = <String, Set<String>>{};
      var touched = false;
      for (final entry in held.entries) {
        final to = renamed[entry.key];
        touched |= to != null;
        rebuilt[to ?? entry.key] = entry.value;
      }
      if (!touched) continue;
      bucket[gameId] = rebuilt;
      changed = true;
      persist |= identical(bucket, _modTags);
    }
    if (!changed) return;
    if (persist) await settings.setModTagsJson(encodeModTags(_modTags));
    _applyTags();
  }

  Future<void> _rememberIgnored(
      {required bool persist, bool notify = true}) async {
    if (persist) {
      await settings
          .setIgnoredConflictsJson(encodeIgnoredConflicts(_ignoredConflicts));
    }
    // The scan itself is untouched: only which of its clashes are drawn
    // has changed.
    _applyIgnored();
    if (notify) notifyListeners();
  }

  /// Re-derives every per-mod warning from the library as it stands now.
  ///
  /// The conflict scan and the advisory match read the same two things -
  /// [mods] and the insight cache - so anything that disturbs either has
  /// to run both. Running only one leaves them disagreeing: disabling a
  /// flagged mod used to drop it out of the filtered list (its path had
  /// changed) while the banner went on counting it.
  void _rescanWarnings() {
    _rescanConflicts();
    _rematchAdvisories();
    _regroupDuplicates();
  }

  /// Rebuilds the duplicate sets from the digests already in hand. Cheap
  /// and synchronous, which is the whole reason the hashes are cached:
  /// deleting one copy of a pair has to stop the other being called a
  /// duplicate, and re-reading the files to work that out would be
  /// seconds of frozen window per click.
  void _regroupDuplicates() {
    final sets = _digests.isEmpty
        ? const <DuplicateSet>[]
        : duplicateSetsOf([
            for (final mod in mods)
              // Invented mods have no file behind them, so nothing was
              // ever hashed for one.
              if (!isDemoMod(mod)) mod,
          ], digestOf);
    duplicateSets = sets;
    duplicatePaths = {
      for (final set in sets)
        for (final mod in set.mods) mod.path,
    };
    if (duplicatePaths.isEmpty) duplicatesOnly = false;
    _libraryStamp++;
  }

  int get advisoryCount => advisories.length;

  /// How deep this game reads inside the mods folder, or null when it
  /// reads however deep you go. See [GameAdapter.modDepthLimit].
  int? modDepthLimit;

  /// What the game still needs before it will run any of this, as the
  /// adapter's own keys. See [GameAdapter.unmetRequirements].
  List<String> unmetRequirements = const [];

  /// Mods sitting below [modDepthLimit]: on disk, listed here, and never
  /// loaded by the game. Rebuilt with the library.
  Set<String> tooDeepPaths = const {};

  int get tooDeepCount => tooDeepPaths.length;

  bool isTooDeep(Mod mod) => tooDeepPaths.contains(mod.path);

  void _findTooDeepMods() {
    final limit = modDepthLimit;
    if (limit == null) {
      tooDeepPaths = const {};
      tooDeepOnly = false;
      return;
    }
    tooDeepPaths = {
      for (final mod in mods)
        if (_depthOf(mod) > limit) mod.path,
    };
    if (tooDeepPaths.isEmpty) tooDeepOnly = false;
  }

  /// Levels of subfolder between the mods folder and [mod]. A file
  /// sitting straight in the mods folder is 0. Mods outside the mods
  /// folder entirely (Sims 1's routed skins) are the adapter's business,
  /// not the cfg's.
  int _depthOf(Mod mod) {
    final root = modsDir?.path;
    if (root == null || !p.isWithin(root, mod.path)) return 0;
    final folder = folderOf(mod);
    return folder == null ? 0 : folderSegments(folder).length;
  }

  /// Narrows the library to the mods the game is too shallow to read, or
  /// back to all of them; the same shape as [toggleAdvisoriesOnly].
  void toggleTooDeepOnly() {
    if (!tooDeepOnly && tooDeepCount == 0) return;
    playSound(UiSound.cycle);
    tooDeepOnly = !tooDeepOnly;
    if (tooDeepOnly) {
      analytics.capture('too_deep_filter_opened', {
        'game': _adapter.game.id,
        'mods': tooDeepCount,
        'limit': modDepthLimit ?? -1,
      });
    }
    notifyListeners();
  }

  /// What the published list says about [mod], or null when it says
  /// nothing about it.
  ModAdvisory? advisoryOf(Mod mod) => advisories[mod.path];

  /// Narrows the library to the mods an advisory names, or back to all of
  /// them; the mirror of [toggleConflictsOnly], driven by the banner.
  void toggleAdvisoriesOnly() {
    if (!advisoriesOnly && advisoryCount == 0) return;
    playSound(UiSound.cycle);
    advisoriesOnly = !advisoriesOnly;
    if (advisoriesOnly) {
      analytics
          .capture('advisories_filter_opened', {'advisories': advisoryCount});
    }
    notifyListeners();
  }

  /// Re-matches the downloaded advisories against the library. Local and
  /// cheap - the download is a separate, best-effort thing that may never
  /// have happened. Runs after the package scan for the same reason the
  /// conflict scan does: fingerprints come out of the insight cache.
  void _rematchAdvisories() {
    final on = analytics.isEnabled('mod-signal', fallback: true);
    advisories = !on
        ? const {}
        : matchAdvisories(mods,
            _publishedAdvisories[_adapter.game.id] ?? const [], insightFor);
    if (advisories.isEmpty) advisoriesOnly = false;
    _libraryStamp++;
  }

  /// How long a downloaded advisory list is considered current. The file
  /// changes a few times a month; every launch re-fetching it would be
  /// traffic for nothing.
  static const _advisoryMaxAge = Duration(hours: 6);

  /// Parses the advisory list saved by the last successful download, so
  /// warnings are on screen from the first frame and a launch with no
  /// network still has them.
  void _loadCachedAdvisories() {
    final cached = settings.advisoriesJson;
    if (cached != null) _publishedAdvisories = parseAdvisories(cached);
  }

  /// Downloads a fresh advisory list unless the cached one is still
  /// young. Best-effort throughout: a failure leaves the cache alone.
  ///
  /// Whatever arrives is cached, even when it parses to nothing. A
  /// captive portal answering with its own page would cost one quiet
  /// six-hour window on a machine that had no real network anyway, and
  /// "the list is empty now" is a state the file reaches legitimately
  /// every time the mods it named get fixed.
  Future<void> _refreshAdvisories() async {
    if (!analytics.isEnabled('mod-signal', fallback: true)) return;
    final fetchedAt = settings.advisoriesFetchedAt;
    if (fetchedAt != null &&
        DateTime.now().difference(fetchedAt) < _advisoryMaxAge) {
      return;
    }
    final body = await _loadAdvisories();
    if (body == null) return;
    await settings.setAdvisoriesJson(body);
    await settings.setAdvisoriesFetchedAt(DateTime.now());
    _publishedAdvisories = parseAdvisories(body);
    _rematchAdvisories();
    notifyListeners();
  }

  /// Per-file scan results (embedded artwork + content summary). Keyed by
  /// enabled-name path + size + mtime so a replaced file is re-scanned,
  /// while a plain enable/disable rename keeps its cached entry. A null
  /// value means the file was scanned and yielded nothing - cached too,
  /// so revisiting a game never re-scans files known to be empty.
  final Map<String, PackageInsight?> _insights = {};

  /// How much embedded artwork the insight cache may hold. Past it mods
  /// are still scanned and still get their content summary and conflict
  /// keys, but their thumbnail is dropped and the card falls back to
  /// stripe art. Cards render from this cache without touching the disk,
  /// which is what keeps scrolling smooth, but it also means every image
  /// stays in memory for the session and across every game visited - and
  /// a library can hold 45,000 packages. Unbounded, that is gigabytes.
  static const defaultArtworkBudgetBytes = 128 << 20;

  /// Lowered by tests, which can't afford to allocate the real budget.
  final int _artworkBudgetBytes;

  int _artworkBytes = 0;

  /// Whether the artwork budget ran out during the last scan, so the
  /// completion event can say how often real libraries reach it.
  bool _artworkBudgetSpent = false;

  /// Caches [insight] for [mod], keeping its artwork only while the
  /// budget allows.
  void _cacheInsight(Mod mod, PackageInsight insight) {
    final key = _insightKey(mod);
    // The scan reports each batch through onFound and then again in its
    // final result; the repeat must not charge the same image twice.
    if (identical(_insights[key], insight)) return;
    final art = insight.thumbnail;
    if (art == null) {
      _insights[key] = insight;
    } else if (_artworkBytes + art.length > _artworkBudgetBytes) {
      _artworkBudgetSpent = true;
      _insights[key] = PackageInsight(
        resourceCount: insight.resourceCount,
        contents: insight.contents,
        keys: insight.keys,
      );
    } else {
      _artworkBytes += art.length;
      _insights[key] = insight;
    }
  }

  /// Bulk-scan progress for the loading screen: (inspected, total).
  /// Null when no scan is running.
  (int, int)? scanProgress;

  /// Set when the user hits "Skip" on the loading screen; the running
  /// scan stops between batches and the library opens without waiting.
  bool _skipScan = false;

  /// Abandons the in-flight artwork scan. Whatever was already inspected
  /// stays cached; the rest falls back to stripe art and is picked up
  /// again on the next library load. No-op when no scan is running.
  void skipArtworkScan() {
    final progress = scanProgress;
    if (progress == null) return;
    playSound(UiSound.click);
    analytics.capture('artwork_scan_skipped',
        {'inspected': progress.$1, 'total': progress.$2});
    _skipScan = true;
  }

  /// Turns the artwork/content scan on or off from Settings. Switching
  /// it off clears the cache so every card falls back to stripe art;
  /// switching it on rescans the current library.
  Future<void> setScanArtwork(bool value) async {
    if (value == settings.scanArtwork) return;
    await settings.setScanArtwork(value);
    analytics.capture(
        'setting_changed', {'setting': 'scanArtwork', 'value': value});
    playSound(value ? UiSound.toggleOn : UiSound.toggleOff);
    if (value) {
      await refresh();
    } else {
      _insights.clear();
      _artworkBytes = 0;
      // Resource-overlap conflicts came from the cache that just went
      // away; keep only what the lexical heuristics can still see. The
      // advisory match loses its fingerprints to the same clearing and
      // falls back to matching on names.
      _rescanWarnings();
      notifyListeners();
    }
  }

  String _insightKey(Mod mod) => '${enabledPathOf(mod.path)}'
      '|${mod.sizeBytes ?? 0}'
      '|${mod.modifiedAt?.millisecondsSinceEpoch ?? 0}';

  /// What the bulk scan found inside [mod], or null when the file has
  /// been scanned and yielded nothing (or isn't scanned yet).
  PackageInsight? insightFor(Mod mod) => _insights[_insightKey(mod)];

  /// Embedded artwork for [mod]'s thumbnail slots; views fall back to
  /// generated stripe art on null.
  Uint8List? thumbnailOf(Mod mod) => insightFor(mod)?.thumbnail;

  /// Scans any mods that aren't in the insight cache yet, updating
  /// [scanProgress] as batches finish. Runs during [refresh] while the
  /// loading screen is up, so scrolling never triggers per-card IO.
  /// Skipped entirely when the pref is off; skippable mid-run via
  /// [skipArtworkScan].
  Future<void> _scanNewMods() async {
    if (!settings.scanArtwork) return;
    // Remote kill switch: the DBPF parser reads untrusted files, so a
    // crash-causing mod in the wild can be mitigated without a release.
    if (!analytics.isEnabled('artwork-scan', fallback: true)) return;
    final missing = [
      for (final mod in mods)
        // Demo mods have no file to look inside; their insights are
        // seeded when the library is built.
        if (!isDemoMod(mod) && !_insights.containsKey(_insightKey(mod))) mod,
    ];
    if (missing.isEmpty) return;
    _skipScan = false;
    _artworkBudgetSpent = false;
    scanProgress = (0, missing.length);
    notifyListeners();
    final byPath = {for (final mod in missing) mod.path: mod};
    // Repainting per batch means tens of thousands of frames across a big
    // library, all of them to move a progress bar by a hair.
    final notifyEvery = (missing.length / 200).ceil();
    var lastNotified = 0;
    try {
      final found = await _adapter.inspectMods(missing,
          onProgress: (done, total) {
            scanProgress = (done, total);
            if (done - lastNotified < notifyEvery && done < total) return;
            lastNotified = done;
            notifyListeners();
          },
          onFound: (found) {
            // Cache mid-scan so the loading screen's floating backdrop can
            // show artwork as it's discovered.
            for (final entry in found.entries) {
              final mod = byPath[entry.key];
              if (mod != null) _cacheInsight(mod, entry.value);
            }
          },
          isCancelled: () => _skipScan);
      for (final mod in missing) {
        final insight = found[mod.path];
        if (insight != null) {
          _cacheInsight(mod, insight);
        } else if (!_skipScan) {
          // Nothing usable inside (script mod, .far, corrupt file) - a
          // skipped scan can't tell "empty" from "never reached", so only
          // a completed scan records the negative.
          _insights[_insightKey(mod)] = null;
        }
      }
      if (!_skipScan) {
        analytics.capture('artwork_scan_completed', {
          'game': _adapter.game.id,
          'scanned': missing.length,
          'with_artwork': found.values.where((i) => i.thumbnail != null).length,
          'artwork_budget_spent': _artworkBudgetSpent,
        });
      }
    } finally {
      scanProgress = null;
    }
  }

  /// The digest of [mod]'s file, or null when nothing has hashed it: the
  /// size pass ruled it out, the scan hasn't run, or the file could not
  /// be read.
  String? digestOf(Mod mod) => _digests[_insightKey(mod)];

  /// How many mods are a copy of another mod.
  int get duplicateCount => duplicatePaths.length;

  /// What deleting all but one copy of everything would give back.
  int get duplicateWastedBytes {
    var total = 0;
    for (final set in duplicateSets) {
      total += set.wastedBytes;
    }
    return total;
  }

  bool isDuplicate(Mod mod) => duplicatePaths.contains(mod.path);

  /// The other copies of [mod], for its page. Empty for a mod nothing is
  /// duplicating.
  List<Mod> duplicatesOf(Mod mod) {
    for (final set in duplicateSets) {
      if (set.mods.any((m) => m.path == mod.path)) {
        return [
          for (final other in set.mods)
            if (other.path != mod.path) other,
        ];
      }
    }
    return const [];
  }

  /// Reads every mod that shares a size with another and works out which
  /// of them are the same file. The one scan in the app the user starts
  /// themselves: it reads whole files rather than headers, so putting it
  /// on the library load would make every launch pay for a question most
  /// people ask once.
  ///
  /// Only the files no digest is held for are opened, so running it again
  /// after deleting a few copies costs almost nothing.
  Future<void> scanForDuplicates() async {
    if (duplicateProgress != null) return;
    // Remote kill switch, like the other scans: this one reads whole
    // files off an untrusted disk and can be stopped without a release.
    if (!analytics.isEnabled('duplicate-scan', fallback: true)) return;
    final real = [
      for (final mod in mods)
        if (!isDemoMod(mod)) mod,
    ];
    final candidates = duplicateCandidates(real);
    final missing = [
      for (final mod in candidates)
        if (!_digests.containsKey(_insightKey(mod))) mod,
    ];
    _cancelDuplicateScan = false;
    playSound(UiSound.click);
    if (missing.isEmpty) {
      // Everything worth reading was read on an earlier run - or there is
      // nothing to read at all, which is still an answer and has to leave
      // the screen saying so rather than saying nothing happened.
      duplicatesScanned = true;
      _regroupDuplicates();
      _rebuildConflictPairs();
      notifyListeners();
      return;
    }
    duplicateProgress = (0, missing.length);
    notifyListeners();
    // Repainting per batch is thousands of frames to move a bar by a
    // hair; the artwork scan settled on the same ceiling.
    final notifyEvery = (missing.length / 200).ceil();
    var lastNotified = 0;
    var hashed = 0;
    try {
      final found = await hashModFiles(
        missing,
        onProgress: (done, total) {
          duplicateProgress = (done, total);
          if (done - lastNotified < notifyEvery && done < total) return;
          lastNotified = done;
          notifyListeners();
        },
        isCancelled: () => _cancelDuplicateScan,
      );
      for (final mod in missing) {
        final digest = found[mod.path];
        if (digest != null) {
          _digests[_insightKey(mod)] = digest;
          hashed++;
        }
      }
    } catch (e, stack) {
      analytics.captureException(e, stack);
      lastError = errorMessage(e);
      playSound(UiSound.error);
    } finally {
      duplicateProgress = null;
    }
    // A scan that was stopped halfway has looked at some of the library,
    // which is not the same as having looked at it.
    duplicatesScanned = !_cancelDuplicateScan;
    _regroupDuplicates();
    // A stopped scan still hashed some of the library, and the pairs it
    // did settle are as true as a finished scan's.
    _rebuildConflictPairs();
    analytics.capture('duplicate_scan_completed', {
      'game': _adapter.game.id,
      'mods': real.length,
      'hashed': hashed,
      'sets': duplicateSets.length,
      'duplicates': duplicateCount,
      'wasted_bytes': duplicateWastedBytes,
      'cancelled': _cancelDuplicateScan,
    });
    if (!_cancelDuplicateScan) {
      playSound(duplicateSets.isEmpty ? UiSound.click : UiSound.alert);
    }
    notifyListeners();
  }

  /// Puts away a finished scan's "nothing is duplicated" answer. The
  /// found-something version of that banner has no dismiss: it describes
  /// the library as it is, and leaves on its own when the copies do.
  void dismissDuplicateResult() {
    if (!duplicatesScanned || duplicateSets.isNotEmpty) return;
    playSound(UiSound.click);
    duplicatesScanned = false;
    notifyListeners();
  }

  /// Stops a running scan. What was already hashed stays cached, so
  /// starting again picks up where this left off.
  void cancelDuplicateScan() {
    if (duplicateProgress == null) return;
    playSound(UiSound.click);
    _cancelDuplicateScan = true;
  }

  /// Narrows the library to the mods that have a copy, or back to all of
  /// them. No-op when nothing is duplicated.
  void showOnlyDuplicates() {
    if (!duplicatesOnly && duplicatePaths.isEmpty) return;
    playSound(UiSound.cycle);
    duplicatesOnly = !duplicatesOnly;
    if (duplicatesOnly) {
      analytics.capture('duplicates_filtered', {
        'game': _adapter.game.id,
        'sets': duplicateSets.length,
        'duplicates': duplicateCount,
      });
    }
    notifyListeners();
  }

  /// Ticks every copy but one in each set, so the extras go through the
  /// same confirmed, cancellable delete as any other selection rather
  /// than through a second remover written for this screen. Which copy
  /// is spared is [DuplicateSet.mods]' first, and the user is free to
  /// untick and choose another - the bytes cannot say which copy of an
  /// identical pair someone meant to keep.
  void selectDuplicateExtras() {
    if (duplicateSets.isEmpty) return;
    final extras = [
      for (final set in duplicateSets) ...set.mods.skip(1),
    ];
    if (extras.isEmpty) return;
    playSound(UiSound.select);
    for (final mod in extras) {
      _selected.add(mod.path);
    }
    _selectionAnchor = null;
    analytics.capture('duplicate_extras_selected', {
      'game': _adapter.game.id,
      'mods': extras.length,
      'bytes': duplicateWastedBytes,
    });
    notifyListeners();
  }

  /// Feed for the loading screen's floating backdrop: any mod's cleaned-up
  /// title plus whatever artwork the scan has cached for it so far (more
  /// appears as batches finish). One item at a time, because the backdrop
  /// wants one per floater and building the whole library's worth several
  /// times a second is real work when the library is large.
  int get scanShowcaseCount => mods.length;

  (String, Uint8List?) scanShowcaseItem(int index) {
    final mod = mods[index];
    return (humanizeModName(mod.name), thumbnailOf(mod));
  }

  /// Plays [sound] unless UI sounds are switched off in Settings.
  /// Fire-and-forget: playback never blocks or fails an action.
  void playSound(UiSound sound) {
    if (!settings.soundEffects) return;
    _sfx.play(sound);
  }

  /// A newer GitHub release, or null when up to date / not checked /
  /// the check failed (best-effort, like disk space).
  UpdateInfo? availableUpdate;

  /// True while an update check is in flight (Settings shows a spinner
  /// label on the button).
  bool checkingForUpdates = false;

  /// True once at least one check has finished, so Settings can say
  /// "no update found" instead of staying silent.
  bool updateCheckDone = false;

  /// Whether the update-found alert sound has played already; a manual
  /// re-check shouldn't re-announce the same release.
  bool _updateAnnounced = false;

  /// Asks GitHub whether a newer release exists. Safe to call any time;
  /// overlapping calls collapse into one.
  Future<void> checkForUpdates() async {
    if (checkingForUpdates) return;
    checkingForUpdates = true;
    notifyListeners();
    availableUpdate = await _checkUpdates();
    checkingForUpdates = false;
    updateCheckDone = true;
    analytics.capture('update_check_completed', {
      'update_available': availableUpdate != null,
      if (availableUpdate != null) 'latest_version': availableUpdate!.version,
    });
    if (availableUpdate != null && !_updateAnnounced) {
      _updateAnnounced = true;
      playSound(UiSound.alert);
    }
    notifyListeners();
  }

  /// Opens [url] in the system browser. Best-effort, like
  /// [revealInFileManager]: failures are non-fatal.
  Future<void> openUrl(Uri url) async {
    playSound(UiSound.click);
    try {
      if (Platform.isWindows) {
        await Process.start(
            'rundll32', ['url.dll,FileProtocolHandler', url.toString()]);
      } else if (Platform.isMacOS) {
        await Process.start('open', [url.toString()]);
      } else {
        await Process.start('xdg-open', [url.toString()]);
      }
    } catch (_) {}
  }

  /// Where the update button goes, and whether that is a mirror.
  ///
  /// GitHub is where every download goes unless it is known not to work
  /// here - including before anything has been probed at all. The
  /// release page is the right answer wherever it can be opened: the
  /// notes are on it and the choice of file is the user's. It is only a
  /// dead end where the files themselves cannot be fetched, since
  /// proxying the page would leave every link on it still pointing at
  /// the host that is refusing - so that case, and only that case, hands
  /// the mirror this platform's installer directly. A mirror the probe
  /// could not reach either is no answer: it would swap one dead link
  /// for another, so the page stays.
  ({String url, bool mirrored})? get updateDownload {
    final update = availableUpdate;
    if (update == null) return null;
    final mirror = downloadMirror;
    final asset = update.assetUrl;
    if (downloadsReachable ||
        mirror == null ||
        asset == null ||
        reachability.mirror == false) {
      return (url: update.url, mirrored: false);
    }
    return (url: '$mirror$asset', mirrored: true);
  }

  void openReleasePage() {
    final update = availableUpdate;
    final target = updateDownload;
    if (update == null || target == null) return;
    // Every one of these is a verdict on a reachability the developer
    // wrote, when one is forced: which way it routed, what it routed on,
    // and the path the next launch reads back to say how the update
    // arrived. The link still opens - that is what was being tested.
    if (!_reachabilityForced) {
      analytics.capture('update_download_clicked', {
        'latest_version': update.version,
        'mirrored': target.mirrored,
        // The conditions the routing was decided on, so a click that went
        // the wrong way can be explained rather than guessed at.
        'downloads_reachable': downloadsReachable,
        'mirror_configured': downloadMirror != null,
        if (reachability.mirror != null)
          'mirror_reachable': reachability.mirror,
        'has_platform_asset': update.assetUrl != null,
      });
      // Read back by the next launch, where the update either happened or
      // didn't. That is the only place the answer exists.
      unawaited(
          settings.setLastUpdatePath(target.mirrored ? 'mirror' : 'github'));
    }
    openUrl(Uri.parse(target.url));
  }

  /// Opens the fix link an advisory carries. The event records the kind
  /// of advisory, never which one - see [advisoryCount].
  void openAdvisoryUrl(ModAdvisory advisory) {
    final url = advisory.url;
    if (url == null) return;
    analytics.capture('advisory_link_clicked', {'status': advisory.status.name});
    openUrl(Uri.parse(url));
  }

  void reportBug() {
    analytics.capture('feedback_opened', {'type': 'bug_report'});
    openUrl(bugReportUrl(gameName: _adapter.game.name));
  }

  void suggestFeature() {
    analytics.capture('feedback_opened', {'type': 'feature_request'});
    openUrl(featureRequestUrl(gameName: _adapter.game.name));
  }

  void openWiki() {
    analytics.capture('feedback_opened', {'type': 'wiki'});
    openUrl(wikiUrl);
  }

  Future<void> init() async {
    // Before everything else, so the very first frame is the walkthrough
    // rather than a library flashing up behind it for a moment.
    //
    // Whoever has never answered this sees it, launch history and all:
    // the walkthrough shipped in an update, so an install that has been
    // running for months has still never seen the screen, and every page
    // reads current settings rather than assuming a blank install - there
    // is nothing on it that only makes sense the very first time. The
    // source just says which of the two happened.
    if (!settings.onboardingDone) {
      _onboarding = true;
      analytics.capture('onboarding_started', {
        'source': settings.launchCount > 1 ? 'update' : 'first_run',
      });
    }
    // Before the first refresh, so the library's very first frame already
    // carries whatever the last download knew.
    _loadCachedAdvisories();
    // Same reason: the update badges are drawn from these records, and
    // the first library frame should already have them.
    _shopInstalls = parseShopInstalls(settings.shopInstallsJson);
    // Same again: mods sitting in folders the library cannot sweep are
    // only known from here, and the first frame should show them.
    _placedMods = parsePlacedMods(settings.placedModsJson);
    // And the clashes the user has already settled, before the first scan
    // runs - otherwise the library opens on warnings it was told to drop.
    _ignoredConflicts = parseIgnoredConflicts(settings.ignoredConflictsJson);
    // And again: what answered last time, so the sidebar doesn't offer
    // The Exchange for the second the probe takes and then withdraw it.
    // A forced answer wins here too, or a debug run would open on the
    // real one and swap a moment later - the exact flicker the stored
    // answer exists to avoid.
    reachability = _forcedReachability ??
        Reachability(
          shop: settings.shopReachable,
          site: settings.siteReachable,
          downloads: settings.downloadsReachable,
          mirror: settings.mirrorReachable,
        );
    // Before the refresh, so the first library frame already carries the
    // banner instead of adding it a moment later. It cannot change while
    // the app is open, so it is asked once.
    runningElevated = await _checkElevated();
    // The buddy's own clock. Started before the refresh so the first fact
    // is timed from launch rather than from however long the library took
    // to scan, which on a big folder is most of a minute.
    _armTrivia();
    await refresh();
    _captureLibraryOpened();
    // Not awaited, like the update check below it.
    _refreshAdvisories();
    // Asked every launch rather than remembered for good: a VPN going up
    // or down is exactly the change worth noticing, and it costs a few
    // HEAD requests.
    _refreshReachability();
    // Not awaited: a network round-trip the library shouldn't wait on;
    // the Settings card and sidebar fill in when the answer arrives.
    // Remote kill switch: skip the check entirely if a release's check
    // ever needs to be silenced (e.g. a bad tag confusing everyone).
    if (analytics.isEnabled('update-check', fallback: true)) {
      checkForUpdates();
    }
    // Mod updates, the same way: only worth a fetch when something was
    // installed from the shop, and killable remotely if the catalog ever
    // needs to stop being polled on launch.
    // Skipped outright where the catalog cannot be reached - the fetch
    // would spend its whole timeout to learn what the probe already knows.
    if (_shopInstalls.isNotEmpty &&
        shopReachable &&
        analytics.isEnabled('shop-update-check', fallback: true)) {
      refreshShop();
    }
    await _refreshCounts();
    // Every game has now been asked whether it is here, which is what the
    // walkthrough's second page is waiting to hear.
    scanningGames = false;
    notifyListeners();
  }

  /// Remote flags landing after the first frame. Beyond the repaint: a
  /// `download-mirror` arriving now was not configured when the probe
  /// ran this launch (a cold start reads cached flags, and the launch a
  /// mirror is first switched on has none), so the mirror has never been
  /// asked. Ask it, or [updateDownload] will route to a mirror nothing
  /// has checked and the event will go up without `mirror_reachable`.
  void _onFlagsChanged() {
    notifyListeners();
    if (downloadMirror != null && reachability.mirror == null) {
      _refreshReachability();
    }
  }

  /// Asks whether our services answer from here and repaints if the
  /// answer changed. Best-effort and never awaited: the library does not
  /// wait on it, and a probe that cannot run leaves everything offered.
  Future<void> _refreshReachability() async {
    final run = ++_reachabilityRun;
    final before = reachability;
    final forced = _forcedReachability;
    final now = forced ?? await _probeServices(downloadMirror);
    // Overtaken while it was in flight: something newer has already
    // answered, and this one would put back what was true before it.
    // Silent all the way down - reporting it would count a launch twice.
    if (run != _reachabilityRun) return;
    // A forced answer reports nothing. It is a developer asking what the
    // UI does, not what this machine found, and `services_reachable` is
    // the denominator the whole routing decision is judged on - a
    // handful of invented blocked launches is exactly the noise that
    // would make it unreadable.
    if (forced == null) {
      // Captured every launch rather than only when it changes: a rate
      // needs a denominator, and "how many machines could reach GitHub's
      // files today" is the whole question this turns on.
      analytics.capture('services_reachable', {
        'shop': now.shop,
        'site': now.site,
        'downloads': now.downloads,
        if (now.mirror != null) 'mirror': now.mirror,
        'mirror_configured': downloadMirror != null,
        'changed': now != before,
        for (final entry in now.millis.entries) 'ms_${entry.key}': entry.value,
      });
    }
    reachability = now;
    if (now == before) return;
    // Nor is it written down. The next launch re-seeds from these, and a
    // scenario picked once would otherwise be what the app believed
    // until the probe answered - in the shipped build too, which reads
    // the same preferences.
    if (forced == null) {
      await settings.setShopReachable(now.shop);
      await settings.setSiteReachable(now.site);
      await settings.setDownloadsReachable(now.downloads);
      // Persisted like the rest, or `before` would start every launch with
      // a null mirror the probe then fills in - which reads as the answer
      // having changed on every single launch, and leaves the guard in
      // [updateDownload] with nothing to go on until the probe returns.
      await settings.setMirrorReachable(now.mirror);
    }
    // A shop that just went out of reach cannot stay on screen: the
    // sidebar card is about to stop being drawn under whoever is on it.
    if (!now.shop && screen == AppScreen.shop) screen = AppScreen.library;
    notifyListeners();
  }

  Future<void> selectGame(String gameId) async {
    final next = registry.byGameId(gameId);
    if (next == null) return;
    playSound(UiSound.click);
    _adapter = next;
    screen = AppScreen.library;
    query = '';
    selectedCategories.clear();
    selectedFolders.clear();
    conflictsOnly = false;
    advisoriesOnly = false;
    tooDeepOnly = false;
    duplicatesOnly = false;
    // Another game, another deck. The bubble closes rather than carrying
    // a fact about The Sims 2 into The Sims 4, and the index goes back to
    // the top of that game's own shuffle.
    _triviaIndex = 0;
    _triviaOpen = false;
    _triviaBadge = false;
    // Another game's library, another set of labels on it - and another
    // set of things they turn out to be.
    tagFilter = null;
    kindFilter = null;
    stateFilter = ModStateFilter.all;
    // The digests were another game's files, and the answer they add up
    // to is about a library that is no longer on screen.
    _digests.clear();
    duplicateSets = const [];
    duplicatePaths = const {};
    duplicatesScanned = false;
    _selectedModPath = null;
    // The ticks were on another game's files.
    _selected.clear();
    _selectionAnchor = null;
    // Another game's saves are another set of files; they are read when
    // the user next opens the Saves screen, not eagerly on every switch.
    saveGames = null;
    savesLoading = false;
    _selectedSaveIndex = 0;
    _selectedHouseholdIndex = 0;
    savesPhotoIndex = 0;
    // Same for the packs, and the restart notice goes with them: it was
    // about the game the user was looking at.
    gamePacks = null;
    packCollectionNote = null;
    packsLoading = false;
    _packsAreDemo = false;
    _packsChanged.clear();
    // The Exchange is deliberately left alone: its shelves span every
    // game, so switching the library doesn't re-shelve them.
    await refresh();
    _captureLibraryOpened();
  }

  /// One event per library visit (launch or game switch) summarizing
  /// what the user has: library size, health, whether detection worked.
  /// Counts and sizes only - never mod names or paths.
  void _captureLibraryOpened() {
    analytics.capture('library_opened', {
      'game': _adapter.game.id,
      'folder_found': modsDir != null,
      'using_override': usingOverride,
      'mods': mods.length,
      'enabled_mods': enabledCount,
      'conflicts': conflictCount,
      // How many mods the advisory list names, never which ones: an
      // advisory id next to a distinct id would say that this user has
      // that mod.
      'advisories': advisoryCount,
      'folders': folders.length,
      'total_size_mb': (totalSizeBytes / (1024 * 1024)).round(),
    });
  }

  /// Enabled-name paths of the mods the demo library invented, so actions
  /// on them stay in memory instead of reaching for files that don't
  /// exist. Empty unless demo mode is on.
  Set<String> _demoPaths = const {};

  bool get demoLibrary => settings.demoLibrary;

  /// Whether [mod] came from the demo library rather than the disk.
  bool isDemoMod(Mod mod) => _demoPaths.contains(enabledPathOf(mod.path));

  /// Today at midnight. The demo library's dates count back from here
  /// rather than from the current instant, so a mod's insight-cache key
  /// (which includes its mtime) survives a refresh.
  static DateTime _demoAnchor() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// [real] plus the invented library when demo mode is on, with the fake
  /// insights seeded so the detail panel has contents to show. Anything
  /// occupying a path a real mod already holds is dropped, so the demo
  /// never shadows a file that actually exists.
  List<Mod> _withDemoMods(List<Mod> real) {
    _demoPaths = const {};
    if (!settings.demoLibrary) {
      // The clashes settled on invented mods go with them: they name
      // files that were never there, and left behind they would count
      // against the real library in Settings.
      _demoIgnoredConflicts.clear();
      return real;
    }
    final demo = buildDemoLibrary(_adapter, modsDir?.path ?? 'Mods',
        today: _demoAnchor());
    final taken = {for (final mod in real) enabledPathOf(mod.path)};
    final invented = [
      for (final mod in demo.mods)
        if (!taken.contains(enabledPathOf(mod.path))) mod,
    ];
    _demoPaths = {for (final mod in invented) enabledPathOf(mod.path)};
    for (final mod in invented) {
      final insight = demo.insights[mod.path];
      if (insight != null) _insights[_insightKey(mod)] = insight;
    }
    return [...real, ...invented]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  /// Turns the invented screenshot library on or off (debug builds only -
  /// [SettingsStore.demoLibrary] reads false in a release build).
  Future<void> setDemoLibrary(bool value) async {
    if (value == settings.demoLibrary) return;
    await settings.setDemoLibrary(value);
    playSound(value ? UiSound.toggleOn : UiSound.toggleOff);
    // What is on the packs shelf was either invented or read off the
    // disk, and which of the two it should be has just changed. Dropped
    // rather than reloaded, so it is read when the screen is next opened.
    gamePacks = null;
    packCollectionNote = null;
    _packsAreDemo = false;
    _packsChanged.clear();
    await refresh();
    await _refreshCounts();
  }

  /// What an invented mod looks like once switched on or off: the rename
  /// the disk would have done, done to the snapshot instead.
  Mod _demoModToggled(Mod mod, bool enabled) => Mod(
        name: mod.name,
        path: enabled ? enabledPathOf(mod.path) : '${mod.path}$disabledSuffix',
        status: enabled ? ModStatus.enabled : ModStatus.disabled,
        sizeBytes: mod.sizeBytes,
        category: mod.category,
        modifiedAt: mod.modifiedAt,
      );

  /// Enable/disable for an invented mod: the same state change the real
  /// path makes on disk, done in memory. Like every edit to the demo
  /// library it lasts until the next refresh, which rebuilds it.
  void _toggleDemoMod(Mod mod) {
    final enabled = !mod.isEnabled;
    final updated = _demoModToggled(mod, enabled);
    playSound(enabled ? UiSound.toggleOn : UiSound.toggleOff);
    _repathSelected(mod.path, updated.path);
    _setMods([for (final m in mods) m.path == mod.path ? updated : m]);
    if (_selectedModPath == mod.path) _selectedModPath = updated.path;
    _rescanWarnings();
    notifyListeners();
  }

  void _removeDemoMod(Mod mod) {
    playSound(UiSound.uninstall);
    _demoPaths = {..._demoPaths}..remove(enabledPathOf(mod.path));
    _setMods([for (final m in mods) if (m.path != mod.path) m]);
    if (_selectedModPath == mod.path) {
      _selectedModPath = null;
      screen = AppScreen.library;
    }
    _rescanWarnings();
    modCounts[_adapter.game.id] = mods.length;
    modSizes[_adapter.game.id] = totalSizeBytes;
    notifyListeners();
  }

  Future<void> refresh() async {
    loading = true;
    lastError = null;
    notifyListeners();
    try {
      final override = settings.modsPathOverride(_adapter.game.id);
      Directory? dir;
      if (override != null && await Directory(override).exists()) {
        dir = Directory(override);
        usingOverride = true;
      } else {
        dir = await _adapter.resolveModsDirectory();
        usingOverride = false;
      }
      // A machine without the game has no folder to put the demo library
      // in, and the library screen would give way to the setup screen -
      // which is not what anyone turned demo mode on to photograph. Borrow
      // the folder the game would have used.
      if (dir == null && settings.demoLibrary) {
        final fallback = await _adapter.defaultModsPath();
        if (fallback != null) dir = Directory(fallback);
      }
      modsDir = dir;
      modsDirWritable = dir == null || await _isWritable(dir);
      modDepthLimit = dir == null ? null : await _adapter.modDepthLimit(dir);
      unmetRequirements =
          dir == null ? const [] : await _adapter.unmetRequirements(dir);
      extraModsDirs =
          dir == null ? const [] : await _adapter.extraModsDirectories(dir);
      // Settings only offers to ask where mods go when there is somewhere
      // else for them to go, which for The Sims 1 depends on the install
      // being found and on which expansions are in it.
      hasInstallChoice = dir != null &&
          (await _adapter.installDestinations(dir)).length > 1;
      // Before the library is built: _setMods folds these into the folder
      // counts, so a folder made and not yet filled keeps its chip.
      _madeFolders = dir == null ? const {} : await _readMadeFolders(dir);
      _setMods(_withDemoMods(dir == null
          ? const []
          : await _withPlacedMods(_adapter, dir, await _adapter.listMods(dir))));
      _findTooDeepMods();
      // Artwork/content scan happens here, under the loading screen,
      // so the library renders instantly from cache afterwards. It must
      // land before the conflict scan: resource-overlap detection reads
      // the packages' resource keys out of the insight cache.
      await _scanNewMods();
      // What each mod turns out to hold is read from that cache, so it
      // is worked out once the scan has filled it rather than from the
      // empty one _setMods saw.
      _applyKinds();
      _rescanWarnings();
      candidateDirs = await _adapter.findModsDirectoryCandidates();
      defaultPath = await _adapter.defaultModsPath();
      gameFolder = await _adapter.findGameFolder();
      await _refreshCacheFiles();
      // Demo mode fills the shelves here rather than on first visit, so
      // the sidebar's update count is in the shot before anyone opens
      // The Exchange. It also has to run after the library is built: the
      // pretend records point at one of its files.
      if (settings.demoLibrary) {
        _loadDemoShop();
      } else if (_demoShopInstalls.isNotEmpty) {
        // Demo mode was just switched off.
        _demoShopInstalls = const {};
        shopMods = null;
      }
      // The library just changed under the update badges, and the mods
      // folder may be a different game's than last time.
      _rebuildShopUpdates();
      modCounts[_adapter.game.id] = dir == null ? null : mods.length;
      modSizes[_adapter.game.id] = totalSizeBytes;
      // Not awaited: shells out to the OS, and the library shouldn't
      // wait on it; the card fills in when the answer arrives.
      _updateDiskSpace();
    } catch (e) {
      lastError = errorMessage(e);
      playSound(UiSound.error);
    }
    loading = false;
    notifyListeners();
  }

  /// Re-reads the library after a failed action and restores [error]:
  /// [refresh] clears [lastError], so the failure that forced the reload
  /// has to be put back afterwards or the banner never shows it.
  Future<void> _refreshKeepingError(AppMessage? error) async {
    await refresh();
    if (error != null) {
      lastError = error;
      notifyListeners();
    }
  }

  Future<void> _updateDiskSpace() async {
    final path = modsDir?.path;
    if (path == null) {
      _diskSpacePath = null;
      diskSpace = null;
      return;
    }
    if (_diskSpacePath != path) diskSpace = null; // may be another volume
    _diskSpacePath = path;
    final space = await diskSpaceFor(path);
    if (_diskSpacePath == path) {
      diskSpace = space;
      notifyListeners();
    }
  }

  Future<void> _refreshCounts() async {
    for (final other in registry.adapters) {
      if (other.game.id == _adapter.game.id) continue;
      await _refreshCountFor(other, notify: false);
    }
    notifyListeners();
  }

  /// Re-reads one other game's folder for the sidebar's count and size.
  /// The game on screen keeps its numbers from [refresh] instead.
  Future<void> _refreshCountFor(GameAdapter other, {bool notify = true}) async {
    try {
      final dir = await modsDirFor(other);
      // Through _withPlacedMods like the game on screen: a mod in one of
      // the folders listMods can't sweep is still installed, and a sidebar
      // that counted it only once its game was selected was off by it on
      // every launch that started somewhere else.
      final otherMods = dir == null
          ? null
          : await _withPlacedMods(other, dir, await other.listMods(dir));
      modCounts[other.game.id] = otherMods?.length;
      modSizes[other.game.id] =
          otherMods?.fold(0, (sum, m) => sum! + (m.sizeBytes ?? 0)) ?? 0;
      // The sidebar counts every game, so demo mode has to reach them
      // all - a screenshot with one full game and four empty ones is
      // the shot nobody wanted.
      if (settings.demoLibrary) {
        final root = dir?.path ?? await other.defaultModsPath() ?? 'Mods';
        final demo = buildDemoLibrary(other, root, today: _demoAnchor());
        modCounts[other.game.id] =
            (modCounts[other.game.id] ?? 0) + demo.mods.length;
        modSizes[other.game.id] = modSizes[other.game.id]! +
            demo.mods.fold(0, (sum, m) => sum + (m.sizeBytes ?? 0));
      }
    } catch (_) {
      modCounts[other.game.id] = null;
      modSizes[other.game.id] = 0;
    }
    if (notify) notifyListeners();
  }

  void openMod(Mod mod) {
    playSound(UiSound.open);
    analytics.capture('mod_details_opened', {
      'game': _adapter.game.id,
      'category': mod.category,
      'enabled': mod.isEnabled,
      'conflicted': isConflicted(mod),
    });
    _selectedModPath = mod.path;
    screen = AppScreen.detail;
    notifyListeners();
  }

  void backToLibrary() {
    if (screen != AppScreen.library) playSound(UiSound.back);
    screen = AppScreen.library;
    notifyListeners();
  }

  void openSettings() {
    if (screen != AppScreen.settings) {
      playSound(UiSound.help);
      analytics.capture('settings_opened');
    }
    screen = AppScreen.settings;
    notifyListeners();
  }

  void setQuery(String value) {
    // One event per search "session", never the typed text.
    if (query.isEmpty && value.isNotEmpty) {
      analytics.capture('library_searched', {'game': _adapter.game.id});
    }
    query = value;
    notifyListeners();
  }

  /// Narrows the library to [value], or widens it back.
  ///
  /// [add] is a ctrl/cmd-click: it lights [value] alongside whatever is
  /// already lit instead of replacing it, the same chord that ticks a mod
  /// card. Without it a plain click is the old behaviour - this chip
  /// alone, or the whole library again when it was the only one lit.
  /// 'All' is the explicit way back.
  void setCategory(String value, {bool add = false}) {
    // 'All' heads the whole chip line rather than the category run of
    // it, so it puts out every chip on the line. It counts the whole
    // library and draws itself lit whenever nothing is narrowing one,
    // and a kind or a tag still burning behind it is a filter with
    // nothing on screen to say so - the chips overflow into a menu on
    // any library with a few folders, which is where the last one to
    // arrive, the kind, spends most of its life. A game whose mods all
    // share one extension has no category chips at all (see
    // [categories]), and there 'All' clearing only categories was a
    // chip that did nothing whatever was lit.
    if (value == 'All') {
      clearChipFilters();
      return;
    }
    if (_narrow(selectedCategories, value, add: add, all: 'All')) {
      // Categories are the adapter's fixed taxonomy (not user data).
      analytics.capture('category_filter_used',
          {'game': _adapter.game.id, 'category': value});
    }
  }

  void setFolder(String value, {bool add = false}) {
    if (_narrow(selectedFolders, value, add: add, all: 'All')) {
      // Folder names are the user's own; only the fact is captured, plus
      // how many are lit, which is what says the feature gets used.
      analytics.capture('folder_filter_used',
          {'game': _adapter.game.id, 'folders': selectedFolders.length});
    }
  }

  /// Applies a chip click to [chosen] and reports whether anything moved.
  bool _narrow(Set<String> chosen, String value,
      {required bool add, required String all}) {
    final before = chosen.toSet();
    if (value == all) {
      chosen.clear();
    } else if (add) {
      if (!chosen.remove(value)) chosen.add(value);
    } else if (chosen.length == 1 && chosen.contains(value)) {
      chosen.clear();
    } else {
      chosen
        ..clear()
        ..add(value);
    }
    final moved = before.length != chosen.length || !before.containsAll(chosen);
    if (moved) playSound(UiSound.cycle);
    notifyListeners();
    return moved;
  }

  /// Whether a folder chip stands for everything below it or only for
  /// its own files. Rebuilds the library rather than just redrawing it:
  /// the counts on the chips are worked out as the mods are read, and a
  /// chip whose number disagrees with what pressing it shows is worse
  /// than either answer on its own.
  Future<void> setFolderIncludesSubfolders(bool value) async {
    if (settings.folderIncludesSubfolders == value) return;
    await settings.setFolderIncludesSubfolders(value);
    playSound(value ? UiSound.toggleOn : UiSound.toggleOff);
    analytics.capture('folder_subfolders_set', {'on': value});
    _setMods(mods);
    _folderGroups = null;
    notifyListeners();
  }

  /// Whether [value] can serve as the disabled marker on this machine:
  /// the shape core insists on, and nothing one of the installed games
  /// reads as a mod or an archive - a marker of `.package` would rename
  /// every mod straight out of the library it is meant to stay in.
  bool canUseDisabledSuffix(String value) {
    final wanted = value.trim().toLowerCase();
    if (!isValidDisabledSuffix(wanted)) return false;
    return !registry.adapters.any((a) =>
        a.modFileExtensions.contains(wanted) ||
        a.containerFileExtensions.contains(wanted));
  }

  /// Changes what disabling a mod writes at the end of its name; empty or
  /// null goes back to the app's own. Refuses a marker the library
  /// couldn't live with rather than half-applying it. Refreshes because
  /// files carrying the new marker were, until this moment, files the
  /// library had no reason to look at.
  Future<void> setDisabledSuffix(String? value) async {
    final typed = value?.trim();
    final wanted = typed == null || typed.isEmpty ? null : typed;
    if (wanted != null && !canUseDisabledSuffix(wanted)) return;
    if (wanted == settings.disabledSuffix) return;
    await settings.setDisabledSuffix(wanted);
    disabledSuffix = wanted ?? defaultDisabledSuffix;
    playSound(UiSound.select);
    // The marker itself is the user's own text and stays on their
    // machine; whether they needed one of their own is the useful part.
    analytics.capture('disabled_suffix_changed', {'custom': wanted != null});
    await refresh();
  }

  Future<void> setLayout(LibraryLayout value) async {
    if (value != layout) {
      playSound(UiSound.cycle);
      analytics.capture('view_mode_changed', {'mode': value.name});
    }
    await settings.setLibraryLayout(value.name);
    notifyListeners();
  }

  Future<void> toggleMod(Mod mod) async {
    if (bulkRunning) return;
    if (isDemoMod(mod)) return _toggleDemoMod(mod);
    try {
      final updated = await _adapter.setEnabled(mod, enabled: !mod.isEnabled);
      playSound(updated.isEnabled ? UiSound.toggleOn : UiSound.toggleOff);
      analytics.capture(updated.isEnabled ? 'mod_enabled' : 'mod_disabled',
          {'game': _adapter.game.id, 'category': mod.category});
      // The file was renamed; the tick on it has to follow.
      _repathSelected(mod.path, updated.path);
      _setMods([for (final m in mods) m.path == mod.path ? updated : m]);
      if (_selectedModPath == mod.path) _selectedModPath = updated.path;
      _rescanWarnings();
      modCounts[_adapter.game.id] = mods.length;
      notifyListeners();
    } catch (e, stack) {
      await _refreshKeepingError(
          _reportModActionFailure(e, stack, action: 'toggle'));
    }
  }

  /// The shared verdict on a failed toggle or remove: sound the error,
  /// count it, and hand back what to tell the user. Environmental
  /// failures (game holding the file open, file moved) are expected and
  /// user-actionable - they'd bury real bugs in error tracking, and
  /// their messages carry file paths the privacy contract forbids
  /// sending - so only what arrives without a [ModActionException]
  /// reason is reported as an exception.
  AppMessage _reportModActionFailure(Object e, StackTrace stack,
      {required String action}) {
    final reason = e is ModActionException ? e.reason.name : null;
    if (reason == null) {
      analytics.captureException(e, stack, mechanism: '${action}Mod');
    }
    analytics.capture('mod_action_failed', {
      'action': action,
      'game': _adapter.game.id,
      if (reason != null) 'reason': reason,
    });
    playSound(UiSound.error);
    return errorMessage(e);
  }

  Future<void> removeMod(Mod mod) async {
    if (bulkRunning) return;
    if (isDemoMod(mod)) return _removeDemoMod(mod);
    AppMessage? error;
    try {
      await _adapter.removeMod(mod);
      playSound(UiSound.uninstall);
      analytics.capture('mod_removed', {
        'game': _adapter.game.id,
        'category': mod.category,
        'size_kb': ((mod.sizeBytes ?? 0) / 1024).round(),
      });
    } catch (e, stack) {
      error = _reportModActionFailure(e, stack, action: 'remove');
    }
    if (_selectedModPath == mod.path) {
      _selectedModPath = null;
      screen = AppScreen.library;
    }
    // Whatever the shop thought it had installed, this file is no longer
    // part of it, and nor is it something the library has to be told
    // about any more.
    if (error == null) {
      await _forgetShopFile(mod);
      await _forgetPlaced(_adapter, modsDir, mod);
      await _forgetIgnored(mod);
      await _forgetTags(mod);
    }
    await _refreshKeepingError(error);
  }

  /// How far the running bulk action has got, as (done, total); null when
  /// none is running, which is also how the selection bar knows whether
  /// to draw its buttons or a progress strip.
  (int, int)? bulkProgress;

  bool get bulkRunning => bulkProgress != null;

  bool _bulkCancelled = false;

  /// Stops the batch after the file it is on. What has already happened
  /// stays done: these are renames and deletes on the user's disk, and an
  /// undo is not something the app can honestly offer.
  void cancelBulk() {
    if (bulkRunning) _bulkCancelled = true;
  }

  /// Walks [targets] through [step], keeping [bulkProgress] current
  /// without a rebuild per file - a selection of thousands would spend
  /// longer drawing the counter than moving the files - and stopping
  /// early once [cancelBulk] has been called. Returns how many it got
  /// through.
  /// Every mod [folder] holds, its subfolders included.
  ///
  /// Always everything below it, whatever
  /// [SettingsStore.folderIncludesSubfolders] is set to: that setting is
  /// about what a chip stands for on screen, and this is about what is
  /// on the disk. Deleting `cc` and leaving `cc/defaults` behind is not
  /// something the filesystem offers.
  List<Mod> modsInFolder(String folder) => [
        for (final mod in mods)
          if (folderOf(mod) case final own?)
            if (folderIsWithin(own, folder)) mod,
      ];

  /// Whether [folder] is the app's to delete. The Sims 1's routed skins
  /// and walls are the game's own folders drawn as chips; removing one
  /// would take Maxis's files with it.
  bool canDeleteFolder(String folder) =>
      canMoveInto(folder) && _folderCounts.containsKey(folder);

  /// Deletes [folder] and everything inside it - the mods it holds, the
  /// subfolders below it, and the readmes and screenshots that came with
  /// them. There is no undo, which is why the dialog that calls this
  /// counts the mods out first.
  Future<void> deleteFolder(String folder) async {
    final root = modsDir;
    if (bulkRunning || root == null || !canDeleteFolder(folder)) return;
    final targets = modsInFolder(folder);
    var failed = 0;
    AppMessage? failure;
    final removed = <String>{};
    final invented = <String>{};
    await _runBatch(targets, (mod) async {
      if (isDemoMod(mod)) {
        invented.add(mod.path);
        removed.add(mod.path);
        return;
      }
      try {
        await _adapter.removeMod(mod);
      } catch (e, stack) {
        failure ??= _bulkFailure(e, stack, action: 'remove');
        failed++;
        return;
      }
      removed.add(mod.path);
      try {
        await _forgetShopFile(mod);
        await _forgetPlaced(_adapter, modsDir, mod);
        await _forgetIgnored(mod);
        await _forgetTags(mod);
      } catch (e, stack) {
        analytics.captureException(e, stack, mechanism: 'deleteFolderRecords');
      }
    });
    // The folder itself goes only once its mods are out of the way: a
    // file that refused to be deleted is a reason to leave the folder
    // standing, not to take it and everything left in it anyway.
    final pretend = isDemoFolder(folder);
    if (failed == 0 && !pretend) {
      try {
        final dir =
            Directory(p.joinAll([root.path, ...folderSegments(folder)]));
        if (dir.existsSync()) await dir.delete(recursive: true);
      } catch (e, stack) {
        analytics.captureException(e, stack, mechanism: 'deleteFolder');
        failure ??= errorMessage(e);
        failed++;
      }
    }
    playSound(failed > 0 ? UiSound.error : UiSound.uninstall);
    // The folder's name is the user's own; how big it was is the part
    // worth knowing.
    analytics.capture('folder_deleted', {
      'game': _adapter.game.id,
      'mods': removed.length,
      'failed': failed,
      'depth': folderSegments(folder).length,
    });
    if (failed == 0) await _forgetFolder(folder);
    _selected.removeWhere(removed.contains);
    if (invented.isNotEmpty) {
      final gone = {for (final path in invented) enabledPathOf(path)};
      _demoPaths = {..._demoPaths}..removeWhere(gone.contains);
    }
    final open = _selectedModPath;
    if (open != null && removed.contains(open)) {
      _selectedModPath = null;
      screen = AppScreen.library;
    }
    await _refreshKeepingError(_batchError(failure, failed, 'bulkRemoveFailed'));
  }

  /// Whether [folder] holds nothing but invented mods, so deleting it
  /// must not reach for the disk. The demo library is drawn in a mods
  /// folder that may be borrowed from a machine with no game in it.
  bool isDemoFolder(String folder) {
    final held = modsInFolder(folder);
    return settings.demoLibrary && held.isNotEmpty && held.every(isDemoMod);
  }

  /// Drops [folder] and everything under it from what the app remembers
  /// about folders: the made-and-empty record, the chip arrangement, and
  /// the filter itself, which would otherwise be pointing at a folder
  /// that no longer exists.
  Future<void> _forgetFolder(String folder) async {
    bool gone(String f) => folderIsWithin(f, folder);
    final gameId = _adapter.game.id;
    selectedFolders.removeWhere(gone);
    if (_madeFolders.any(gone)) {
      _madeFolders = {..._madeFolders}..removeWhere(gone);
      if (!settings.demoLibrary) {
        await settings.setMadeFolders(gameId, _madeFolders.toList());
      }
    }
    final order = settings.folderOrder(gameId);
    if (order != null && order.any(gone)) {
      await settings.setFolderOrder(gameId, [
        for (final f in order)
          if (!gone(f)) f,
      ]);
    }
    final collapsed = settings.collapsedFolders(gameId);
    if (collapsed.any(gone)) {
      await settings.setCollapsedFolders(gameId, [
        for (final f in collapsed)
          if (!gone(f)) f,
      ]);
    }
    final expanded = settings.expandedFolders(gameId);
    if (expanded.any(gone)) {
      await settings.setExpandedFolders(gameId, [
        for (final f in expanded)
          if (!gone(f)) f,
      ]);
    }
  }

  Future<int> _runBatch<T>(
      List<T> targets, Future<void> Function(T) step) async {
    _bulkCancelled = false;
    bulkProgress = (0, targets.length);
    notifyListeners();
    // A hundred repaints whatever the size of the batch.
    final every = (targets.length / 100).ceil();
    var done = 0;
    try {
      for (final target in targets) {
        if (_bulkCancelled) break;
        await step(target);
        done++;
        if (done % every == 0) {
          bulkProgress = (done, targets.length);
          notifyListeners();
        }
      }
    } finally {
      // In a finally because bulkRunning is what locks out every other
      // mod action: a step that threw its way out of here would leave
      // the app refusing to toggle, delete or move anything at all until
      // it was restarted, with a progress strip on screen and a Cancel
      // button read by nothing.
      bulkProgress = null;
    }
    return done;
  }

  /// The same verdict [_reportModActionFailure] reaches, for one file
  /// inside a batch: no sound and no per-file event, because a selection
  /// of three hundred would fire three hundred of each. Only ever called
  /// for the first failure of a batch - a batch that refuses one file
  /// usually refuses the rest for the same reason, and the reports after
  /// the first say nothing the first didn't.
  AppMessage _bulkFailure(Object e, StackTrace stack,
      {required String action}) {
    if (e is! ModActionException) {
      analytics.captureException(e, stack, mechanism: '${action}Selected');
    }
    return errorMessage(e);
  }

  /// One banner for a whole batch: the file's own reason when a single
  /// one refused, and a tally under [key] when several did. Those
  /// messages name the file they are about, and thirty file names is not
  /// something anybody reads.
  AppMessage? _batchError(AppMessage? first, int failed, String key) =>
      switch (failed) {
        0 => null,
        1 => first,
        _ => AppMessage(key, ['$failed']),
      };

  /// Switches every selected mod on or off.
  ///
  /// One pass over the disk and one rebuild at the end, rather than a
  /// loop over [toggleMod]: that path rebuilds every derived count and
  /// re-runs the conflict scan per file, which for a selection of
  /// hundreds is minutes of frozen window for seconds of actual work.
  Future<void> setSelectedEnabled(bool enabled) async {
    if (bulkRunning) return;
    final targets = [
      for (final mod in selectedMods)
        if (mod.isEnabled != enabled) mod,
    ];
    if (targets.isEmpty) return;
    final updated = <String, Mod>{};
    var failed = 0;
    AppMessage? failure;
    await _runBatch(targets, (mod) async {
      if (isDemoMod(mod)) {
        updated[mod.path] = _demoModToggled(mod, enabled);
        return;
      }
      try {
        updated[mod.path] = await _adapter.setEnabled(mod, enabled: enabled);
      } catch (e, stack) {
        failure ??= _bulkFailure(e, stack, action: 'toggle');
        failed++;
      }
    });
    if (updated.isNotEmpty) {
      // Before _setMods, which drops ticks it no longer recognises: every
      // one of these files was just renamed.
      for (final entry in updated.entries) {
        _repathSelected(entry.key, entry.value.path);
      }
      _setMods([for (final mod in mods) updated[mod.path] ?? mod]);
      final open = _selectedModPath;
      if (open != null && updated.containsKey(open)) {
        _selectedModPath = updated[open]!.path;
      }
      _rescanWarnings();
      modCounts[_adapter.game.id] = mods.length;
    }
    playSound(failed > 0
        ? UiSound.error
        : enabled
            ? UiSound.toggleOn
            : UiSound.toggleOff);
    analytics.capture('mods_bulk_toggled', {
      'game': _adapter.game.id,
      'enabled': enabled,
      'mods': updated.length,
      'failed': failed,
    });
    final error = _batchError(failure, failed, 'bulkToggleFailed');
    if (failed > 0) {
      // Something refused, which means the folder is not what the app
      // thought it was - a file moved, deleted or locked by another
      // window. Re-read it rather than leave those mods on screen in a
      // state they no longer have, which is what toggleMod does for one.
      await _refreshKeepingError(error);
      return;
    }
    lastError = error;
    notifyListeners();
  }

  /// Deletes every selected mod. Each one drops out of the shop, placed
  /// and ignored-conflict records the way a single uninstall does; the
  /// library is re-read once at the end rather than once per file.
  Future<void> removeSelected() async {
    if (bulkRunning) return;
    final targets = selectedMods;
    if (targets.isEmpty) return;
    var failed = 0;
    var bytes = 0;
    AppMessage? failure;
    final removed = <String>{};
    final invented = <String>{};
    await _runBatch(targets, (mod) async {
      if (isDemoMod(mod)) {
        invented.add(mod.path);
        removed.add(mod.path);
        bytes += mod.sizeBytes ?? 0;
        return;
      }
      try {
        await _adapter.removeMod(mod);
      } catch (e, stack) {
        failure ??= _bulkFailure(e, stack, action: 'remove');
        failed++;
        return;
      }
      // The file is gone; that is recorded before the records that named
      // it are updated, because a preference that refuses to save must
      // not report a delete that happened as a delete that didn't - and
      // leave the library still listing a file nothing can open.
      removed.add(mod.path);
      bytes += mod.sizeBytes ?? 0;
      try {
        await _forgetShopFile(mod);
        await _forgetPlaced(_adapter, modsDir, mod);
        await _forgetIgnored(mod);
        await _forgetTags(mod);
      } catch (e, stack) {
        analytics.captureException(e, stack, mechanism: 'removeSelectedRecords');
      }
    });
    playSound(failed > 0 ? UiSound.error : UiSound.uninstall);
    analytics.capture('mods_bulk_removed', {
      'game': _adapter.game.id,
      'mods': removed.length,
      'failed': failed,
      'size_mb': (bytes / (1024 * 1024)).round(),
    });
    _selected.removeWhere(removed.contains);
    if (invented.isNotEmpty) {
      // _demoPaths is keyed by enabled name; the removals are real paths.
      final gone = {for (final path in invented) enabledPathOf(path)};
      _demoPaths = {..._demoPaths}..removeWhere(gone.contains);
    }
    final open = _selectedModPath;
    if (open != null && removed.contains(open)) {
      _selectedModPath = null;
      screen = AppScreen.library;
    }
    final error = _batchError(failure, failed, 'bulkRemoveFailed');
    if (removed.length > invented.length) {
      await _refreshKeepingError(error);
      return;
    }
    // Nothing left the disk, so nothing has to be re-read - and a refresh
    // would rebuild the invented library and bring these back. (It still
    // does when a batch held real files too, exactly as it does today
    // when a demo mod is removed and a real one follows it.)
    _setMods([
      for (final mod in mods)
        if (!removed.contains(mod.path)) mod,
    ]);
    _rescanWarnings();
    modCounts[_adapter.game.id] = mods.length;
    modSizes[_adapter.game.id] = totalSizeBytes;
    lastError = error;
    notifyListeners();
  }

  /// The folders on record as made-and-still-empty, minus any that are
  /// no longer on disk. A folder that has gone was deleted outside the
  /// app, or the mods folder now points at another copy of the game;
  /// either way there is nothing left to draw a chip for.
  Future<Set<String>> _readMadeFolders(Directory root) async {
    final saved = settings.madeFolders(_adapter.game.id);
    if (saved.isEmpty) return const {};
    final kept = <String>{
      for (final folder in saved)
        if (Directory(p.joinAll([root.path, ...folderSegments(folder)]))
            .existsSync())
          folder,
    };
    if (kept.length != saved.length) {
      await settings.setMadeFolders(_adapter.game.id, kept.toList());
    }
    return kept;
  }

  /// Makes [name] a subfolder of [parent] - a folder key, or null for the
  /// mods folder itself - and returns its key, or null when it was
  /// refused with the banner saying why.
  ///
  /// The folder is remembered ([SettingsStore.madeFolders]) because
  /// everything the library knows about folders it works out from where
  /// the mods are: a folder made a second ago holds nothing, and would
  /// leave the screen before anything could be put in it.
  ///
  /// [into] is for the install-folder dialog, which The Exchange opens
  /// for whichever game the listing names - not necessarily the one in
  /// the sidebar. For another game nothing on screen changes: there are
  /// no chips to add it to and no library to rebuild, so only the record
  /// is kept.
  Future<String?> createFolder(String? parent, String name,
      {GameAdapter? into}) async {
    final adapter = into ?? _adapter;
    final onScreen = adapter.game.id == _adapter.game.id;
    final root = onScreen ? modsDir : await modsDirFor(adapter);
    if (root == null) return null;
    final typed = name.trim();
    final clean = sanitizeComponent(typed, windows: Platform.isWindows);
    // One level at a time. A separator would quietly make two folders,
    // and neither of them would be the one the user thought they named.
    if (clean.isEmpty ||
        clean == '.' ||
        clean == '..' ||
        typed.contains('/') ||
        typed.contains(r'\')) {
      return _refuseFolder(AppMessage('folderNameBad', [typed]));
    }
    final key = parent == null ? clean : '$parent$folderSeparator$clean';
    // The game reads a fixed number of levels into the mods folder and
    // nothing below them. Offering to make a folder past that would be
    // the app building, by hand, the very state its too-deep banner
    // exists to warn about. Another game's limit is its own to answer.
    final limit = onScreen ? modDepthLimit : await adapter.modDepthLimit(root);
    if (limit != null && folderSegments(key).length > limit) {
      return _refuseFolder(AppMessage('folderTooDeep', ['$limit']));
    }
    // The invented library never touches the disk, and the mods folder it
    // is drawn in may be one this machine has no game for - borrowed from
    // defaultModsPath so the shot has a library in it. So a folder made
    // for a screenshot is made in memory only, and goes with the next
    // refresh like every other edit to the demo library. It must not be
    // written down either: these preferences are shared with the release
    // build, and madeFolders has no debug-only guard the way demoLibrary
    // does.
    final pretend = settings.demoLibrary;
    if (!pretend) {
      try {
        await Directory(p.joinAll([root.path, ...folderSegments(key)]))
            .create(recursive: true);
      } catch (e, stack) {
        analytics.captureException(e, stack, mechanism: 'createFolder');
        return _refuseFolder(errorMessage(e));
      }
    }
    playSound(UiSound.install);
    // The name is the user's own; how deep they went is the useful part.
    analytics.capture('folder_created', {
      'game': adapter.game.id,
      'depth': folderSegments(key).length,
    });
    if (!onScreen) {
      // No chips to add it to and no library to rebuild - the record is
      // all there is to keep, so that the folder still exists as far as
      // that game is concerned when the sidebar next lands on it.
      if (!pretend) {
        final recorded = settings.madeFolders(adapter.game.id);
        if (!recorded.contains(key)) {
          await settings.setMadeFolders(adapter.game.id, [...recorded, key]);
        }
      }
      return key;
    }
    if (!_folderCounts.containsKey(key)) {
      _madeFolders = {..._madeFolders, key};
      if (!pretend) {
        await settings.setMadeFolders(_adapter.game.id, _madeFolders.toList());
      }
      // The chips and the folder sections are both built off the library,
      // so it has to be rebuilt for the new folder to turn up in them.
      _setMods(mods);
      _folderGroups = null;
    }
    notifyListeners();
    return key;
  }

  String? _refuseFolder(AppMessage why) {
    lastError = why;
    playSound(UiSound.error);
    notifyListeners();
    return null;
  }

  /// Moves [targets] into [folder] - a folder key, or null for the mods
  /// folder itself - and puts the records that named them by where they
  /// sat back in step.
  ///
  /// [method] is for tracking only: which gesture asked (`selection`,
  /// `drag`, `detail`).
  Future<void> moveMods(List<Mod> targets, String? folder,
      {required String method}) async {
    if (bulkRunning) return;
    final root = modsDir;
    if (root == null || targets.isEmpty) return;
    if (folder != null && !canMoveInto(folder)) return;
    final destination = folder == null
        ? root
        : Directory(p.joinAll([root.path, ...folderSegments(folder)]));
    final movable = [
      for (final mod in targets)
        // Both ends inside the mods folder ([canMove]), and not already
        // where it is being sent.
        if (canMove(mod) && !p.equals(p.dirname(mod.path), destination.path))
          mod,
    ];
    if (movable.isEmpty) {
      // Nothing to do. Silent on purpose, and only reachable as such:
      // what cannot be moved is never offered the gesture ([canMove]
      // gates the tick, the drag and both Move buttons), so the case
      // left here is a mod already sitting in the folder it was sent to,
      // which is not a failure worth a banner.
      return;
    }
    var failed = 0;
    AppMessage? failure;
    final moved = <(Mod, Mod)>[];
    await _runBatch(movable, (mod) async {
      try {
        final to = isDemoMod(mod)
            ? _demoModMoved(mod, destination)
            : await _adapter.moveMod(mod, destination);
        moved.add((mod, to));
      } catch (e, stack) {
        failure ??= _bulkFailure(e, stack, action: 'move');
        failed++;
      }
    });
    if (moved.isNotEmpty) {
      // All of this before _setMods, which prunes anything whose path it
      // no longer recognises - and every one of these mods has a new one.
      _repathInsights(moved);
      _repathDigests(moved);
      _repathSelection(moved);
      await _repathRecords(moved);
      final byOldPath = {for (final (from, to) in moved) from.path: to};
      final open = _selectedModPath;
      if (open != null && byOldPath.containsKey(open)) {
        _selectedModPath = byOldPath[open]!.path;
      }
      _setMods([for (final mod in mods) byOldPath[mod.path] ?? mod]);
      // Depth is what a move changes most obviously: a mod can land
      // below the level the game reads, or climb back out of it.
      _findTooDeepMods();
      _rescanWarnings();
      _folderGroups = null;
      modSizes[_adapter.game.id] = totalSizeBytes;
    }
    playSound(failed > 0 ? UiSound.error : UiSound.install);
    analytics.capture('mods_moved', {
      'game': _adapter.game.id,
      'method': method,
      'mods': moved.length,
      'failed': failed,
      'to_root': folder == null,
    });
    final error = _batchError(failure, failed, 'bulkMoveFailed');
    if (failed > 0) {
      // Same bargain as the bulk toggle: a refusal means the folder is
      // not what the app thought it was, so re-read it rather than leave
      // those mods drawn where they no longer are.
      await _refreshKeepingError(error);
      return;
    }
    lastError = error;
    notifyListeners();
  }

  /// An invented mod's move: the rename the disk would have done, done to
  /// the snapshot. Like every edit to the demo library it lasts until the
  /// next refresh, which builds it again from scratch.
  Mod _demoModMoved(Mod mod, Directory destination) {
    final moved = Mod(
      name: mod.name,
      path: p.join(destination.path, p.basename(mod.path)),
      status: mod.status,
      sizeBytes: mod.sizeBytes,
      category: mod.category,
      modifiedAt: mod.modifiedAt,
    );
    _demoPaths = {..._demoPaths}
      ..remove(enabledPathOf(mod.path))
      ..add(enabledPathOf(moved.path));
    return moved;
  }

  /// Carries the scan results across with the files. A move keeps a
  /// file's size and date, so only the path part of the key changes -
  /// and without this a tidy-up would send every mod it touched back
  /// through the artwork scan on the next launch.
  /// Digests follow their mods for the same reason the insights do: the
  /// cache key is built from where a mod sits, and a move that dropped it
  /// would re-read every moved file the next time anyone looked for
  /// duplicates.
  void _repathDigests(List<(Mod, Mod)> moved) {
    for (final (from, to) in moved) {
      final was = _insightKey(from);
      final digest = _digests.remove(was);
      if (digest != null) _digests[_insightKey(to)] = digest;
    }
  }

  void _repathInsights(List<(Mod, Mod)> moved) {
    for (final (from, to) in moved) {
      final was = _insightKey(from);
      // containsKey, not a null check: "scanned and found nothing" is a
      // cached answer of its own and worth keeping too.
      if (_insights.containsKey(was)) {
        _insights[_insightKey(to)] = _insights.remove(was);
      }
    }
  }

  /// Ticks follow their mods. A selection is kept by the path a mod sits
  /// at, which is exactly what a move changes, so without this "move
  /// these thirty" would end with nothing selected.
  void _repathSelection(List<(Mod, Mod)> moved) {
    for (final (from, to) in moved) {
      _repathSelected(from.path, to.path);
    }
  }

  /// Rewrites the records that name a mod by where it sits.
  ///
  /// The shop's install records and the settled clashes are both kept as
  /// paths relative to the mods folder, so a tidy-up that skipped this
  /// would quietly cost the user the update badge on everything they
  /// moved, and every conflict they had already decided about.
  Future<void> _repathRecords(List<(Mod, Mod)> moved) async {
    final root = modsDir?.path;
    if (root == null) return;
    final renamed = {
      for (final (from, to) in moved)
        p.relative(enabledPathOf(from.path), from: root):
            p.relative(enabledPathOf(to.path), from: root),
    };
    await _repathShopInstalls(renamed);
    await _repathIgnored(renamed);
    await _repathTags(renamed);
  }

  Future<void> _repathShopInstalls(Map<String, String> renamed) async {
    if (_shopInstalls.isEmpty) return;
    final gameId = _adapter.game.id;
    var changed = false;
    final updated = <String, ShopInstall>{};
    for (final entry in _shopInstalls.entries) {
      final install = entry.value;
      if (install.gameId != gameId || !install.files.any(renamed.containsKey)) {
        updated[entry.key] = install;
        continue;
      }
      changed = true;
      updated[entry.key] = install
          .copyWith(files: [for (final f in install.files) renamed[f] ?? f]);
    }
    if (!changed) return;
    _shopInstalls = updated;
    await settings.setShopInstallsJson(encodeShopInstalls(_shopInstalls));
    _rebuildShopUpdates();
  }

  Future<void> _repathIgnored(Map<String, String> renamed) async {
    final gameId = _adapter.game.id;
    var persist = false;
    var changed = false;
    for (final bucket in [_ignoredConflicts, _demoIgnoredConflicts]) {
      final held = bucket[gameId];
      if (held == null || held.isEmpty) continue;
      final rebuilt = <String>{};
      var touched = false;
      for (final key in held) {
        final paths = conflictPairPaths(key);
        if (paths == null) {
          rebuilt.add(key);
          continue;
        }
        final a = renamed[paths[0]] ?? paths[0];
        final b = renamed[paths[1]] ?? paths[1];
        touched |= a != paths[0] || b != paths[1];
        rebuilt.add(conflictPairKey(a, b));
      }
      if (!touched) continue;
      changed = true;
      bucket[gameId] = rebuilt;
      persist |= identical(bucket, _ignoredConflicts);
    }
    if (changed) await _rememberIgnored(persist: persist, notify: false);
  }

  /// Where [adapter]'s mods live right now: the folder already loaded for
  /// the game on screen, resolved from scratch for any other (The
  /// Exchange installs for games the sidebar isn't pointing at).
  Future<Directory?> modsDirFor(GameAdapter adapter) async {
    if (adapter.game.id == _adapter.game.id) return modsDir;
    final override = settings.modsPathOverride(adapter.game.id);
    if (override != null && await Directory(override).exists()) {
      return Directory(override);
    }
    return adapter.resolveModsDirectory();
  }

  /// Where an install lands: the selected folder chip, so that what you
  /// are looking at is what you install into, and the mods folder itself
  /// when the filter is off. Only for the game on screen (no other game
  /// has a chip selected) and only for folders that really are
  /// subfolders of it - Sims 1's routed skins and walls are chips too,
  /// and the adapter decides what goes in those.
  Directory _installDestination(GameAdapter adapter, Directory modsFolder) {
    if (adapter.game.id != _adapter.game.id) return modsFolder;
    final only = installFolder;
    if (only == null) return modsFolder;
    return Directory(p.joinAll([modsFolder.path, ...folderSegments(only)]));
  }

  /// The one folder chip an install follows, or null when there isn't
  /// one. Two chips lit is no answer to which of them a new file belongs
  /// in, so the install goes to the mods folder rather than picking for
  /// the user - and Sims 1's routed skins and walls are chips too, which
  /// the adapter fills for itself.
  String? get installFolder {
    if (selectedFolders.length != 1) return null;
    final only = selectedFolders.first;
    return _externalFolders.contains(only) ? null : only;
  }

  /// Mods the app put in folders that hold the game's own files too, by
  /// game id, each relative to that game's mods folder. The library has
  /// no other way to know about them - see `core/placed_mods.dart`.
  Map<String, Set<String>> _placedMods = {};

  /// [mods] plus whatever is on record in folders [GameAdapter.listMods]
  /// cannot sweep, minus the records whose file has since gone.
  Future<List<Mod>> _withPlacedMods(
      GameAdapter adapter, Directory modsDir, List<Mod> mods) async {
    final recorded = _placedMods[adapter.game.id];
    if (recorded == null || recorded.isEmpty) return mods;
    final seen = {for (final mod in mods) enabledPathOf(mod.path)};
    final kept = <String>{};
    final placed = <Mod>[];
    for (final relative in recorded) {
      final path = p.normalize(p.join(modsDir.path, relative));
      // Disabling renames the file, so a record points at the name the
      // mod carries while it is switched on; every marker a file could be
      // wearing (ours, an older one, another manager's) is tried too.
      var mod = adapter.modAt(path);
      for (final suffix in disabledSuffixes) {
        if (mod != null) break;
        mod = adapter.modAt('$path$suffix');
      }
      if (mod == null) {
        // Not there. Only forget it if the folder it lived in is, because
        // otherwise this is a different install (the user re-pointed the
        // mods folder, or has two copies of the game) and the mod is
        // still sitting where it was put, still loading in the game.
        if (Directory(p.dirname(path)).existsSync()) continue;
        kept.add(relative);
        continue;
      }
      kept.add(relative);
      if (seen.add(enabledPathOf(mod.path))) placed.add(mod);
    }
    await _rememberPlaced(adapter.game.id, kept);
    if (placed.isEmpty) return mods;
    return [...mods, ...placed]
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  /// Remembers any of [installed] that landed somewhere the library can't
  /// sweep. Nothing to do for a game whose folders are all its player's.
  Future<void> _recordPlaced(
      GameAdapter adapter, Directory modsDir, List<Mod> installed) async {
    if (installed.isEmpty) return;
    final stock = [
      for (final destination in await adapter.installDestinations(modsDir))
        if (destination.holdsStockFiles) destination.directory.path,
    ];
    if (stock.isEmpty) return;
    final paths = {...?_placedMods[adapter.game.id]};
    for (final mod in installed) {
      if (!stock.any((dir) => p.isWithin(dir, mod.path))) continue;
      paths.add(p.relative(enabledPathOf(mod.path), from: modsDir.path));
    }
    await _rememberPlaced(adapter.game.id, paths);
  }

  /// Drops [mod] from the records, for when it is uninstalled.
  Future<void> _forgetPlaced(GameAdapter adapter, Directory? modsDir, Mod mod) {
    final recorded = _placedMods[adapter.game.id];
    if (modsDir == null || recorded == null) return Future<void>.value();
    final relative = p.relative(enabledPathOf(mod.path), from: modsDir.path);
    if (!recorded.contains(relative)) return Future<void>.value();
    return _rememberPlaced(adapter.game.id, {...recorded}..remove(relative));
  }

  Future<void> _rememberPlaced(String gameId, Set<String> paths) async {
    final before = _placedMods[gameId] ?? const <String>{};
    if (before.length == paths.length && before.containsAll(paths)) return;
    if (paths.isEmpty) {
      _placedMods.remove(gameId);
    } else {
      _placedMods[gameId] = paths;
    }
    await settings.setPlacedModsJson(encodePlacedMods(_placedMods));
  }

  /// Installs [sources] into [into]'s mods folder, the game on screen
  /// unless a caller says otherwise ([target] is that game's folder, so
  /// the resolution isn't done twice).
  /// Returns the mods that reached disk, which is not something the
  /// library can always work out for itself afterwards: a file placed in a
  /// folder the game keeps its own files in is invisible to [listMods].
  ///
  /// [destination] is a folder key below [target] to install into, which
  /// The Exchange works out for itself ([shopDestinationOf]) because it
  /// has no folder chips to read an answer off. The empty string is the
  /// mods folder itself. Left out, the library's own rule applies: the
  /// selected chip. A folder named here that has since been deleted is
  /// made again on the way in rather than refused - the adapters create
  /// their destination, and an install is a bad moment to find out a
  /// folder set months ago is gone.
  Future<List<Mod>> installFiles(List<FileSystemEntity> sources,
      {String method = 'picker',
      GameAdapter? into,
      Directory? target,
      String? destination,
      InstallPlacement placement = const SortedPlacement()}) async {
    final adapter = into ?? _adapter;
    final modsFolder = target ?? modsDir;
    if (modsFolder == null) return const [];
    // A chosen folder is an answer about the whole install, so the
    // selected chip does not get to narrow it - and the adapter has to be
    // handed the mods folder itself, or it cannot recognise the install
    // the chosen folder belongs to.
    final dir = placement is ChosenPlacement
        ? modsFolder
        : destination != null
            ? (destination.isEmpty
                ? modsFolder
                : Directory(p.joinAll(
                    [modsFolder.path, ...folderSegments(destination)])))
            : _installDestination(adapter, modsFolder);
    AppMessage? error;
    var folders = 0, archives = 0, files = 0;
    final installed = <Mod>[];
    FileSystemEntity? failing;
    try {
      for (final source in sources) {
        failing = source;
        if (source is Directory) {
          folders++;
          installed.addAll(
              await adapter.installFolder(dir, source, placement: placement));
        } else if (adapter.containerFileExtensions
            .contains(p.extension(source.path).toLowerCase())) {
          archives++;
          installed.addAll(await adapter
              .installArchive(dir, File(source.path), placement: placement));
        } else {
          files++;
          installed.add(await adapter.installMod(dir, File(source.path),
              placement: placement));
        }
      }
      playSound(UiSound.install);
      analytics.capture('mod_installed', {
        'game': adapter.game.id,
        'method': method,
        'files': files,
        'archives': archives,
        'folders': folders,
        'placement': placement is ChosenPlacement ? 'chosen' : 'sorted',
      });
    } catch (e, stack) {
      error = installFailureMessage(e, failing?.path, destination: dir.path);
      // A ModContentException is the adapter reporting that the archive or
      // folder held nothing this game can use, an ArchiveExtractionException
      // that the archive wouldn't open at all - verdicts on the file, not
      // bugs to investigate. A refused or vanished path is the same kind
      // of verdict on the machine (the game holding a file open, a cloud
      // drive offloading one, Program Files ACLs): the banner already
      // words it and mod_install_failed counts it under its own reason,
      // so reporting it as an exception too only buries real bugs - the
      // same bargain _reportModActionFailure strikes for toggle/remove.
      if (e is! ModContentException &&
          e is! ArchiveExtractionException &&
          e is! PathAccessException &&
          e is! PathNotFoundException) {
        analytics.captureException(e, stack, mechanism: 'installFiles');
      }
      analytics.capture('mod_install_failed', {
        'game': adapter.game.id,
        'method': method,
        'reason': installFailureReason(e),
      });
      playSound(UiSound.error);
    }
    // Before the refresh, which is what draws them: anything that landed
    // in a folder holding the game's own files is only findable from the
    // record. Whatever did install is worth remembering even when a later
    // file in the same batch failed.
    await _recordPlaced(adapter, modsFolder, installed);
    // Another game's library isn't on screen to reload - only its sidebar
    // count moved, and the error (if any) still has to reach the banner.
    if (adapter.game.id == _adapter.game.id) {
      await _refreshKeepingError(error);
    } else {
      lastError = error;
      await _refreshCountFor(adapter);
    }
    return installed;
  }

  /// Installs files and folders dropped onto the window, ignoring
  /// anything the current game can't use (readmes, screenshots...).
  /// The dropped paths this game can do something with: its own mod files
  /// and any archive. Separate from installing them so the UI can ask
  /// where they go before deciding there is nothing to install.
  Future<List<FileSystemEntity>> acceptedDrops(List<String> paths) async {
    final accepted = {
      ..._adapter.modFileExtensions,
      ..._adapter.containerFileExtensions,
    };
    final sources = <FileSystemEntity>[];
    for (final path in paths) {
      if (await FileSystemEntity.isDirectory(path)) {
        sources.add(Directory(path));
      } else if (accepted.contains(p.extension(path).toLowerCase())) {
        sources.add(File(path));
      }
    }
    return sources;
  }

  Future<void> installDroppedPaths(List<String> paths,
      {InstallPlacement placement = const SortedPlacement()}) async {
    final sources = await acceptedDrops(paths);
    if (sources.isEmpty) {
      playSound(UiSound.alert);
      analytics.capture('mod_drop_rejected',
          {'game': _adapter.game.id, 'dropped': paths.length});
      return;
    }
    await installFiles(sources, method: 'drop', placement: placement);
  }

  /// Asks the user for a mods folder and makes it the override. Both the
  /// setup screen and Settings offer this; a cancelled dialog (or a folder
  /// gone by the time it lands) changes nothing.
  Future<void> pickFolderOverride() async {
    final path = await getDirectoryPath();
    if (path == null) return;
    if (!await Directory(path).exists()) return;
    await setFolderOverride(path);
  }

  Future<void> setFolderOverride(String path) async {
    playSound(UiSound.select);
    analytics.capture('mods_folder_overridden', {'game': _adapter.game.id});
    await settings.setModsPathOverride(_adapter.game.id, path);
    await refresh();
  }

  Future<void> clearFolderOverride() async {
    playSound(UiSound.click);
    analytics.capture('mods_folder_reset', {'game': _adapter.game.id});
    await settings.setModsPathOverride(_adapter.game.id, null);
    await refresh();
  }

  Future<void> _refreshCacheFiles() async {
    cacheFiles = await _adapter.findCacheFiles();
    var total = 0;
    for (final file in cacheFiles) {
      try {
        total += await file.length();
      } catch (_) {} // Racing the game/user; the size is cosmetic.
    }
    cacheSizeBytes = total;
  }

  /// Deletes the game's stale cache files so freshly added/removed CC
  /// shows up; the game rebuilds them on next launch. No-op when the
  /// adapter reports none.
  Future<void> clearCaches() async {
    if (cacheFiles.isEmpty) return;
    try {
      analytics.capture('caches_cleared', {
        'game': _adapter.game.id,
        'files': cacheFiles.length,
        'size_kb': (cacheSizeBytes / 1024).round(),
      });
      await _adapter.clearCaches();
      playSound(UiSound.uninstall);
    } catch (e, stack) {
      lastError = errorMessage(e);
      analytics.captureException(e, stack, mechanism: 'clearCaches');
      playSound(UiSound.error);
    }
    try {
      await _refreshCacheFiles();
    } catch (_) {}
    notifyListeners();
  }

  /// Creates the game's default mods folder (with any scaffolding the
  /// game needs, e.g. Sims 3's Resource.cfg) and starts using it.
  Future<void> createDefaultFolder() async {
    final path = defaultPath;
    if (path == null) return;
    // Asked before the attempt rather than after it: creating this folder
    // is recursive, so a run that gets halfway up a protected path leaves
    // folders behind and still fails.
    if (!await canWriteInto(Directory(path))) {
      lastError = noWriteAccessTo(path);
      analytics.capture(
          'mods_folder_create_denied', {'game': _adapter.game.id});
      playSound(UiSound.error);
      notifyListeners();
      return;
    }
    try {
      await _adapter.createModsDirectory(path);
      playSound(UiSound.install);
      analytics.capture('mods_folder_created', {'game': _adapter.game.id});
    } catch (e, stack) {
      lastError = errorMessage(e);
      analytics.captureException(e, stack, mechanism: 'createDefaultFolder');
      playSound(UiSound.error);
    }
    await refresh();
  }

  Future<void> setPref(Future<void> Function() write,
      {UiSound? sound, String? setting, Object? value}) async {
    await write();
    if (setting != null) {
      analytics
          .capture('setting_changed', {'setting': setting, 'value': value});
    }
    // Played after the write so the sound-effects toggle gates itself:
    // switching sounds on confirms audibly, switching off is silent.
    if (sound != null) playSound(sound);
    // Conflict scanning and visibility react immediately.
    _rescanWarnings();
    notifyListeners();
  }

  /// Flips the anonymous-analytics opt-in (the analytics service sends
  /// its own farewell/return events around the change).
  Future<void> setAnalyticsEnabled(bool value) async {
    await analytics.setEnabled(value);
    playSound(value ? UiSound.toggleOn : UiSound.toggleOff);
    notifyListeners();
  }

  /// Remote announcement from the `announcement` feature flag's JSON
  /// payload ({id, title, message, url?}), or null when there's nothing
  /// to show / the user dismissed it.
  Map<String, Object?>? get announcement {
    final payload = analytics.payloadOf('announcement');
    if (payload is! Map) return null;
    final message = payload['message'];
    if (message is! String || message.isEmpty) return null;
    final id = (payload['id'] ?? message).toString();
    if (settings.dismissedAnnouncements.contains(id)) return null;
    return {...payload.cast<String, Object?>(), 'id': id};
  }

  /// Hides the current announcement for good (per announcement id).
  Future<void> dismissAnnouncement() async {
    final current = announcement;
    if (current == null) return;
    playSound(UiSound.click);
    analytics
        .capture('announcement_dismissed', {'announcement': current['id']});
    await settings.addDismissedAnnouncement(current['id'].toString());
    notifyListeners();
  }

  /// Where a user gets what the game is missing, for the requirements
  /// that are a file somebody else distributes. Null for the ones that
  /// are a switch inside the game: those are fixed where they are.
  ///
  /// The app links to it and does not fetch it. A loader DLL goes next
  /// to the game's own executable, and downloading and installing one of
  /// those on someone's behalf is not the app's business.
  static String? requirementHelpUrl(String key) => switch (key) {
        'medievalModLoader' => 'https://modthesims.info/showthread.php?t=438344',
        _ => null,
      };

  void openRequirementHelp(String key) {
    final url = requirementHelpUrl(key);
    if (url == null) return;
    playSound(UiSound.click);
    analytics.capture('requirement_help_opened',
        {'game': _adapter.game.id, 'requirement': key});
    openUrl(Uri.parse(url));
  }

  void openAnnouncementUrl() {
    final url = announcement?['url'];
    if (url is! String || !url.startsWith('https://')) return;
    analytics.capture(
        'announcement_clicked', {'announcement': announcement?['id']});
    openUrl(Uri.parse(url));
  }

  /// Every game's listings, as of the last [refreshShop]. Null before the
  /// first successful load. The Exchange is not tied to the game in the
  /// sidebar: the whole catalog is fetched once and narrowed here.
  List<ShopMod>? shopMods;

  bool shopLoading = false;

  /// True when a load failed and there's nothing cached to show instead;
  /// the shop screen offers a retry.
  bool shopLoadFailed = false;

  /// Which game's shelf the user is looking at, or null for all of them
  /// (the default - the shop opens on everything).
  String? shopGameFilter;

  /// Listings this build can actually do something with: a game the
  /// registry doesn't know has no folder to install into and no name to
  /// caption, so it stays off the shelves rather than showing as a dead
  /// card.
  List<ShopMod> get shopKnownMods => [
        for (final mod in shopMods ?? const <ShopMod>[])
          if (registry.byGameId(mod.gameId) != null) mod,
      ];

  /// What the shelves draw: [shopKnownMods] narrowed by [shopGameFilter].
  List<ShopMod> get visibleShopMods {
    final filter = shopGameFilter;
    final known = shopKnownMods;
    if (filter == null) return known;
    return [
      for (final mod in known)
        if (mod.gameId == filter) mod,
    ];
  }

  /// What the shelves actually lay out: [visibleShopMods] with each
  /// creator's sets folded into one entry. The counts above and the
  /// filter chips still count listings, because that is what is on offer
  /// - a set of eight is eight mods behind one card, and the card says so.
  List<ShopGroup> get visibleShopGroups => groupShopListings(visibleShopMods);

  /// The set the open listing belongs to, or null when it belongs to
  /// none. Drawn from the whole catalog rather than the filtered shelves:
  /// a deep link clears the game filter, and the picker has to offer the
  /// siblings either way. A deep-linked listing the catalog page didn't
  /// carry is added to them for this one purpose - it is kept out of the
  /// shelves and the counts so they agree with the query, but a link to
  /// one colour still has to find the other seven.
  ShopGroup? get selectedShopGroup {
    final mod = selectedShopListing;
    if (mod == null || shopGroupKey(mod) == null) return null;
    final known = shopKnownMods;
    final catalog = known.any((other) => other.id == mod.id)
        ? known
        : [mod, ...known];
    for (final group in groupShopListings(catalog)) {
      if (group.isSet && group.contains(mod.id)) return group;
    }
    return null;
  }

  /// How many listings each game has, for the shop's filter chips.
  Map<String, int> get shopCountsByGame {
    final counts = <String, int>{};
    for (final mod in shopKnownMods) {
      counts[mod.gameId] = (counts[mod.gameId] ?? 0) + 1;
    }
    return counts;
  }

  void setShopGameFilter(String? gameId) {
    if (shopGameFilter == gameId) return;
    playSound(UiSound.click);
    shopGameFilter = gameId;
    analytics.capture('shop_filtered', {'game': gameId ?? 'all'});
    notifyListeners();
  }

  /// Download progress per listing id, 0..1, or null while the size is
  /// still unknown. A listing appears here only while installing.
  final Map<String, double?> shopProgress = {};

  /// The same, for a listing being saved to a folder of the user's
  /// choosing rather than installed. Its own map because the two say
  /// different things on screen, and a listing can be doing either.
  final Map<String, double?> shopSaveProgress = {};

  /// Listings with a save under way, the Save-as dialog included.
  /// [shopSaveProgress] only fills once bytes are moving, and the dialog
  /// is a long wait in front of that - long enough to press the button
  /// again, which is exactly what this stops.
  final Set<String> _shopSaving = {};

  /// Whether this listing is already doing something: installing, or
  /// saving (dialog included). One predicate for both, because the two
  /// actions are the same download twice and neither button should start
  /// while the other is running.
  bool shopBusy(ShopMod mod) =>
      shopProgress.containsKey(mod.id) || _shopSaving.contains(mod.id);

  /// What The Exchange has installed on this machine, by listing id.
  /// Survives restarts (see [SettingsStore.shopInstallsJson]) - it is
  /// what makes "you have v1.2, the creator published v1.3" a question
  /// the app can answer at all.
  Map<String, ShopInstall> _shopInstalls = {};

  /// Pretend install records for the invented shelves, so demo mode can
  /// photograph the Installed and Update states as well as the plain
  /// one. Kept apart from [_shopInstalls] because nothing about the demo
  /// library is ever written to disk.
  Map<String, ShopInstall> _demoShopInstalls = const {};

  /// The records everything reads: what was really installed, plus
  /// whatever demo mode is pretending.
  Map<String, ShopInstall> get _installRecords =>
      _demoShopInstalls.isEmpty
          ? _shopInstalls
          : {..._shopInstalls, ..._demoShopInstalls};

  /// Which listing each installed file belongs to, for the files whose
  /// listing has a newer version on the shelves. Keyed by enabled-name
  /// path so a disabled mod still matches. Current game only: the other
  /// games' libraries aren't in memory to badge.
  Map<String, ShopMod> _shopUpdateByPath = const {};

  /// A newer version than the installed one, or null when the listing is
  /// unknown, unchanged, or was never installed from here. Version
  /// strings are compared for difference rather than order: creators
  /// write them freely ("1.2", "2026-05-01", "final"), and the honest
  /// claim is "this isn't what you installed", not "this is higher".
  ShopMod? shopUpdateFor(ShopMod mod) {
    final install = _installRecords[mod.id];
    if (install == null || install.version == mod.version) return null;
    return mod;
  }

  /// The listing offering a newer version of [mod], or null. Drives the
  /// library's update badge.
  ShopMod? shopUpdateForMod(Mod mod) =>
      _shopUpdateByPath[enabledPathOf(mod.path)];

  /// How many installed listings have a newer version waiting, across
  /// every game. The sidebar badges The Exchange with this, so nobody has
  /// to open the shop to find out.
  int get shopUpdateCount {
    final byId = {for (final mod in shopKnownMods) mod.id: mod};
    var count = 0;
    for (final install in _installRecords.values) {
      final listing = byId[install.listingId];
      if (listing != null && listing.version != install.version) count++;
    }
    return count;
  }

  /// Re-derives [_shopUpdateByPath] from the records and the catalog.
  /// Cheap (there are as many records as the user has installed from the
  /// shop), but it runs on library and catalog changes rather than per
  /// card: the grid asks about every mod it draws.
  void _rebuildShopUpdates() {
    final root = modsDir?.path;
    if (root == null) {
      _shopUpdateByPath = const {};
      return;
    }
    final byId = {for (final mod in shopKnownMods) mod.id: mod};
    final result = <String, ShopMod>{};
    for (final install in _installRecords.values) {
      if (install.gameId != _adapter.game.id) continue;
      final listing = byId[install.listingId];
      if (listing == null || listing.version == install.version) continue;
      for (final file in install.files) {
        result[p.normalize(p.join(root, file))] = listing;
      }
    }
    _shopUpdateByPath = result;
  }

  Future<void> _rememberShopInstall(ShopInstall install) async {
    _shopInstalls = {..._shopInstalls, install.listingId: install};
    await settings.setShopInstallsJson(encodeShopInstalls(_shopInstalls));
    _rebuildShopUpdates();
  }

  /// Drops [mod]'s file from whichever install record claims it, so a mod
  /// the user uninstalled stops reading as "Installed" on the shelves. A
  /// record left with no files at all goes too.
  Future<void> _forgetShopFile(Mod mod) async {
    final root = modsDir?.path;
    if (root == null || _shopInstalls.isEmpty) return;
    final gone = enabledPathOf(mod.path);
    final updated = <String, ShopInstall>{};
    var changed = false;
    for (final entry in _shopInstalls.entries) {
      final install = entry.value;
      if (install.gameId != _adapter.game.id) {
        updated[entry.key] = install;
        continue;
      }
      final kept = [
        for (final file in install.files)
          if (p.normalize(p.join(root, file)) != gone) file,
      ];
      if (kept.length == install.files.length) {
        updated[entry.key] = install;
        continue;
      }
      changed = true;
      // Files it no longer has any of: the mod is gone from this machine.
      if (kept.isNotEmpty) updated[entry.key] = install.copyWith(files: kept);
    }
    if (!changed) return;
    _shopInstalls = updated;
    await settings.setShopInstallsJson(encodeShopInstalls(_shopInstalls));
    _rebuildShopUpdates();
  }

  /// Whether [mod]'s download already sits in the library: installed from
  /// the shop before, or a file with the same name (a plain .package
  /// published under its own name; archives can only be recognized from
  /// the install records).
  bool isShopModInstalled(ShopMod mod) {
    if (_installRecords.containsKey(mod.id)) return true;
    // The name check can only speak for the library that's loaded -
    // another game's files were never read into memory.
    if (mod.gameId != _adapter.game.id) return false;
    final name = mod.fileName.toLowerCase();
    return mods
        .any((m) => p.basename(enabledPathOf(m.path)).toLowerCase() == name);
  }

  /// Whether [gameId]'s mods folder is known, so a listing for it has
  /// somewhere to land. [modCounts] holds null for a game whose folder
  /// never resolved, which is the same question asked once already.
  bool hasModsFolder(String gameId) =>
      gameId == _adapter.game.id ? modsDir != null : modCounts[gameId] != null;

  /// Switches to The Exchange, loading the shelves on first visit.
  /// [gameId] narrows them to one game (the sidebar's per-game shortcuts);
  /// passing nothing leaves whichever filter was last chosen.
  void openShop({String? gameId}) {
    if (screen != AppScreen.shop) {
      playSound(UiSound.open);
      analytics.capture('shop_opened', {'game': _adapter.game.id});
    }
    if (gameId != null) {
      shopGameFilter = shopGameFilter == gameId ? null : gameId;
    }
    screen = AppScreen.shop;
    notifyListeners();
    if (shopMods == null && !shopLoading) refreshShop();
  }

  /// Which listing the shop is showing the detail of, or null for the
  /// shelves. It lives here rather than inside the shop screen for the
  /// same reason [selectedMod] does, and one more: a deep link can name a
  /// listing while the user is somewhere else entirely, and the screen
  /// that would have held the selection has not been built yet.
  String? _shopSelectedId;

  /// A listing a deep link named that the catalog page didn't carry - it
  /// is capped at 300, and a link can outlive a listing's place on the
  /// front page. Kept beside [shopMods] rather than merged into it: the
  /// shelves, the per-game counts and the update badges are all derived
  /// from the catalog as fetched, and slipping in a row the query never
  /// returned would make them disagree with it.
  ShopMod? _shopSelectedFetched;

  /// True while a deep-linked listing is being looked up.
  bool shopOpeningListing = false;

  /// The listing on screen, or null when the shelves are. Resolved by id
  /// on every read, so a listing that vanished from a refresh mid-visit
  /// puts the user back on the shelves instead of drawing a stale copy.
  ShopMod? get selectedShopListing {
    final id = _shopSelectedId;
    if (id == null) return null;
    for (final mod in shopMods ?? const <ShopMod>[]) {
      if (mod.id == id) return mod;
    }
    return _shopSelectedFetched?.id == id ? _shopSelectedFetched : null;
  }

  /// Opens a listing the user picked off the shelves.
  void openShopListing(ShopMod mod) {
    playSound(UiSound.open);
    analytics.capture('shop_listing_opened',
        {'game': mod.gameId, 'listing': mod.id, 'source': 'shelf'});
    _shopSelectedId = mod.id;
    notifyListeners();
  }

  /// Swaps which variation of the open set is showing. The same screen
  /// either way, so it makes no sound and takes no journey: the user is
  /// picking a colour, not opening a mod.
  void openShopVariant(ShopMod mod) {
    if (_shopSelectedId == mod.id) return;
    playSound(UiSound.click);
    analytics.capture('shop_listing_opened',
        {'game': mod.gameId, 'listing': mod.id, 'source': 'variant'});
    _shopSelectedId = mod.id;
    notifyListeners();
  }

  /// Back to the shelves. The folder picked on the listing goes with it:
  /// it was an answer about that mod, not about the game.
  void closeShopListing() {
    if (_shopSelectedId == null) return;
    playSound(UiSound.back);
    _shopFolderChoices.remove(_shopSelectedId);
    _shopSelectedId = null;
    _shopSelectedFetched = null;
    notifyListeners();
  }

  /// Opens a listing named by nothing but its id - what a
  /// `simsmodmanager://mod/<id>` link from the website resolves to. It
  /// shows the listing; installing stays a button the user presses.
  Future<void> openShopListingById(String id) async {
    // The kill switch. On a cold start the flags may not have landed yet
    // and the fallback lets the first link through, which is the right
    // default (a machine that never reaches PostHog keeps its features)
    // but does mean this takes hold from the second link on.
    if (!analytics.isEnabled('deep-links', fallback: true)) return;
    if (!isShopListingId(id)) {
      analytics.capture('deep_link_failed', {'reason': 'invalid'});
      return;
    }
    // The Exchange is not on screen anywhere on this machine, so a link
    // must not put the user on it: the fetch behind it cannot succeed,
    // and the sidebar has no card to navigate back with. Silent rather
    // than a banner, which is what hiding the card already decided.
    if (!shopReachable) {
      // Unless it was unreachable because someone said so in Settings,
      // in which case the refusal is the scenario working, not a link
      // that failed.
      if (!_reachabilityForced) {
        analytics.capture(
            'deep_link_failed', {'reason': 'unreachable', 'listing': id});
      }
      return;
    }

    if (screen != AppScreen.shop) playSound(UiSound.open);
    screen = AppScreen.shop;
    _shopSelectedId = null;
    _shopSelectedFetched = null;
    shopOpeningListing = true;
    lastError = null;
    notifyListeners();

    var resolved = 'catalog';
    var mod = _listingById(id);
    if (mod == null && shopMods == null) {
      await refreshShop();
      mod = _listingById(id);
    }
    if (mod == null) {
      // Not on the shelves we hold, which is not the same as gone: the
      // catalog is one page deep and this link may be older than it.
      mod = await _fetchListing(id);
      resolved = 'fetched';
    }

    shopOpeningListing = false;
    if (mod == null) {
      lastError = const AppMessage('shopListingNotFound');
      playSound(UiSound.error);
      analytics.capture('deep_link_failed', {'reason': 'not_found'});
      notifyListeners();
      return;
    }
    if (registry.byGameId(mod.gameId) == null) {
      // A listing for a game this build has never heard of has no folder
      // to install into and no name to caption, so the shelves already
      // keep it off. Saying so beats a detail page that can do nothing.
      lastError = const AppMessage('shopListingUnknownGame');
      playSound(UiSound.error);
      analytics.capture('deep_link_failed', {'reason': 'unknown_game'});
      notifyListeners();
      return;
    }

    _shopSelectedFetched = mod;
    _shopSelectedId = mod.id;
    // Back has to land on shelves that could have held this listing.
    if (shopGameFilter != null && shopGameFilter != mod.gameId) {
      shopGameFilter = null;
    }
    analytics.capture('shop_listing_opened',
        {'game': mod.gameId, 'listing': mod.id, 'source': 'deep_link'});
    analytics.capture('deep_link_opened',
        {'game': mod.gameId, 'listing': mod.id, 'resolved': resolved});
    notifyListeners();
  }

  ShopMod? _listingById(String id) {
    for (final mod in shopMods ?? const <ShopMod>[]) {
      if (mod.id == id) return mod;
    }
    return null;
  }

  /// Fills the shelves with the invented catalog and pretends a couple
  /// of its listings are already installed - one at its current version
  /// ("Installed") and one at an older one ("Update"), the second
  /// pointing at a file the demo library actually shows so the library
  /// badge and the detail panel have something to sit on.
  void _loadDemoShop() {
    final games = [
      for (final adapter in registry.adapters)
        (
          id: adapter.game.id,
          fileExtension: adapter.modFileExtensions.contains('.package')
              ? '.package'
              : (adapter.modFileExtensions.toList()..sort()).firstOrNull ??
                  '.package',
        ),
    ];
    final listings = buildDemoShop(games, today: _demoAnchor());
    shopMods = listings;
    shopLoadFailed = false;
    final mine = [
      for (final listing in listings)
        if (listing.gameId == _adapter.game.id) listing,
    ];
    // The mod the "update" listing claims to have installed: a real file
    // from the invented library, and deliberately not one of the planted
    // conflicts - the card shows the most serious badge it has, and a
    // conflict would hide the update.
    final root = modsDir?.path;
    final host = mods.where((mod) {
      return mod.isEnabled &&
          !conflictPaths.contains(mod.path) &&
          advisories[mod.path] == null &&
          isDemoMod(mod);
    }).firstOrNull;
    // The invented set, so the shelf card and the variation picker have
    // their states too: one colour taken and current, the next one taken
    // and since republished.
    final variations = [
      for (final listing in mine)
        if (listing.group != null) listing,
    ];
    _demoShopInstalls = {
      if (variations.length > 1) ...{
        variations.first.id: ShopInstall(
          listingId: variations.first.id,
          gameId: variations.first.gameId,
          version: variations.first.version,
          name: variations.first.name,
          files: const [],
        ),
        variations[1].id: ShopInstall(
          listingId: variations[1].id,
          gameId: variations[1].gameId,
          version: 'demo-older',
          name: variations[1].name,
          files: const [],
        ),
      },
      if (mine.length > 1)
        mine[1].id: ShopInstall(
          listingId: mine[1].id,
          gameId: mine[1].gameId,
          version: mine[1].version,
          name: mine[1].name,
          files: const [],
        ),
      if (mine.isNotEmpty && host != null && root != null)
        mine.first.id: ShopInstall(
          listingId: mine.first.id,
          gameId: mine.first.gameId,
          // Anything but the listing's own version reads as an update.
          version: 'demo-older',
          name: mine.first.name,
          files: [p.relative(enabledPathOf(host.path), from: root)],
        ),
    };
    _rebuildShopUpdates();
  }

  /// Re-fetches the catalog. Best-effort: a failure keeps whatever was
  /// already on screen, or flips the shop to its retry state when there
  /// was nothing.
  Future<void> refreshShop() {
    // Handing back the load already running, rather than dropping the
    // caller on the floor: a deep link arriving during the launch fetch
    // has to be able to wait for the catalog it needs.
    final running = _shopLoad;
    if (running != null) return running;
    // Demo mode never reaches the network: the invented shelves are the
    // whole point, and a real (empty) catalog would replace them.
    if (settings.demoLibrary) {
      _loadDemoShop();
      notifyListeners();
      return Future<void>.value();
    }
    final load = _loadShop();
    _shopLoad = load;
    return load.whenComplete(() => _shopLoad = null);
  }

  /// The load [refreshShop] hands out and waits on.
  Future<void>? _shopLoad;

  Future<void> _loadShop() async {
    shopLoading = true;
    shopLoadFailed = false;
    notifyListeners();
    final fetched = await _fetchShop();
    shopLoading = false;
    if (fetched != null) {
      shopMods = fetched;
      _rebuildShopUpdates();
      analytics.capture('shop_loaded', {
        'listings': fetched.length,
        'updates': shopUpdateCount,
      });
    } else {
      shopLoadFailed = shopMods == null;
    }
    notifyListeners();
  }

  /// Folders picked on a listing's own page, by listing id. Dropped by
  /// [closeShopListing]: the answer is about the mod on screen, not about
  /// the game, and the next listing gets to be asked afresh.
  final _shopFolderChoices = <String, String>{};

  /// Whether the shop may ask which subfolder a listing installs into.
  ///
  /// False for a game that routes its own installs. The Sims 1 works out
  /// which of its folders a file belongs in *from the mods folder*,
  /// reaching siblings with `..`, so putting the install a level down
  /// would send every routed file somewhere the game never reads. No row
  /// on the listing, no card in Settings, and [shopDestinationFolder]
  /// ignores a saved answer from before that game's install was found.
  Future<bool> canChooseShopFolder(GameAdapter into) async {
    final dir = await modsDirFor(into);
    if (dir == null) return false;
    return (await into.installDestinations(dir)).length <= 1;
  }

  /// The subfolder an install from The Exchange lands in for [gameId]:
  /// the game's saved default, and failing that the folder chip the
  /// library has selected - which is what every Exchange install followed
  /// before there was a default, and only ever says anything for the game
  /// the sidebar is on. The empty string is the mods folder itself.
  ///
  /// Synchronous because it is called from `build`, so it cannot itself
  /// ask whether this game routes its own installs - the views draw the
  /// row only once [canChooseShopFolder] has said yes, and the install
  /// asks again before it uses any of this.
  String shopDestinationFolder(String gameId) {
    // Absent and empty are different answers: absent is nobody having
    // said, empty is someone choosing the mods folder and meaning it.
    final saved = settings.shopFolder(gameId);
    if (saved != null) return saved;
    if (gameId != _adapter.game.id) return '';
    return installFolder ?? '';
  }

  /// Where [mod] would install: what was picked on the listing itself,
  /// then its game's answer. The destination row on the listing draws
  /// exactly this, so what it says is where the file goes.
  String shopDestinationOf(ShopMod mod) =>
      _shopFolderChoices[mod.id] ?? shopDestinationFolder(mod.gameId);

  /// Remembers the folder picked on [mod]'s own page.
  void chooseShopFolder(ShopMod mod, String folder) {
    if (_shopFolderChoices[mod.id] == folder) return;
    _shopFolderChoices[mod.id] = folder;
    playSound(UiSound.click);
    notifyListeners();
  }

  /// Sets the folder Exchange installs for [gameId] land in from now on.
  Future<void> setShopFolder(String gameId, String folder) async {
    await settings.setShopFolder(gameId, folder);
    playSound(UiSound.click);
    // Never the folder's name, which is the user's own.
    analytics.capture('shop_folder_set', {
      'game': gameId,
      'depth': folder.isEmpty ? 0 : folderSegments(folder).length,
      'cleared': folder.isEmpty,
    });
    notifyListeners();
  }

  /// The subfolders an install into [into] could go to, for the picker.
  ///
  /// The loaded library's own chips for the game on screen; for any other
  /// game a bounded walk of its mods folder, which is why the dialog
  /// opens on a spinner. Depth is the game's own limit where it reads one
  /// out of its config, and three levels where it doesn't.
  Future<List<String>> installFolderChoices(GameAdapter into) async {
    if (into.game.id == _adapter.game.id) {
      return [
        for (final folder in folders)
          if (canMoveInto(folder)) folder,
      ];
    }
    final dir = await modsDirFor(into);
    if (dir == null) return const [];
    final limit = await into.modDepthLimit(dir) ?? 3;
    final found = <String>[];
    await _walkFolders(dir, const [], limit, found);
    found.sort();
    // A folder made in the app and still empty is on record rather than
    // on the chips, and the walk finds it on disk anyway - but a game
    // whose folder has since gone would otherwise offer nothing at all.
    for (final made in settings.madeFolders(into.game.id)) {
      if (!found.contains(made)) found.add(made);
    }
    return found;
  }

  /// Every subfolder under [dir], [depth] levels down, as folder keys.
  /// A folder the OS won't open costs what is inside it and nothing else,
  /// the way listing a library does.
  Future<void> _walkFolders(
      Directory dir, List<String> parents, int depth, List<String> found) async {
    if (depth <= 0) return;
    final List<FileSystemEntity> entries;
    try {
      entries = await dir.list(followLinks: false).toList();
    } catch (_) {
      return;
    }
    for (final entry in entries) {
      if (entry is! Directory) continue;
      final segments = [...parents, p.basename(entry.path)];
      found.add(segments.join(folderSeparator));
      await _walkFolders(entry, segments, depth - 1, found);
    }
  }

  /// Downloads [mod] from The Exchange and installs it through the same
  /// pipeline as a picked file, so archives unpack and files land where
  /// the adapter routes them. The listing names its own game, which need
  /// not be the one in the sidebar: the file goes to that game's folder
  /// either way. One listing at a time per id; the button shows
  /// [shopProgress] while this runs.
  Future<void> installShopMod(ShopMod mod,
      {InstallPlacement placement = const SortedPlacement()}) async {
    final into = registry.byGameId(mod.gameId);
    if (into == null || shopBusy(mod)) return;
    playSound(UiSound.click);
    shopProgress[mod.id] = null;
    notifyListeners();
    Directory? scratch;
    try {
      final dir = await modsDirFor(into);
      if (dir == null) {
        lastError = AppMessage('shopNeedsFolder', [into.game.name]);
        playSound(UiSound.error);
        return;
      }
      scratch = await Directory.systemTemp.createTemp('exchange_');
      // The stored name is the security rules' problem; the local path is
      // ours. basename strips anything path-like that slipped through.
      final file = File(p.join(scratch.path, p.basename(mod.fileName)));
      await _downloadShop(mod, file, onProgress: (received, total) {
        shopProgress[mod.id] = total > 0
            ? (received / total).clamp(0.0, 1.0)
            : null;
        notifyListeners();
      });
      shopProgress.remove(mod.id);
      final previous = _shopInstalls[mod.id];
      // Asked here rather than read off the screen: a deep link can
      // install a listing whose destination row was never drawn, and a
      // game that routes its own installs must ignore any folder on
      // record from before its install was found.
      final folder = await canChooseShopFolder(into)
          ? shopDestinationOf(mod)
          : '';
      final installed = await installFiles([file],
          method: 'shop',
          into: into,
          target: dir,
          destination: folder,
          placement: placement);
      // A listing holding nothing this game can install is not
      // necessarily a broken listing - it can be a tool, a spreadsheet,
      // something that was never a mod (issue #16). The generic wording
      // is a dead end there, so on the one screen that has an answer it
      // says what the answer is.
      if (lastError case AppMessage(key: 'noModFiles')) {
        lastError = AppMessage('shopNoModFiles', [mod.name]);
      }
      // installFiles reports its own failures through lastError rather
      // than throwing; only a clean run counts as installed.
      if (lastError == null) {
        // Straight from the install rather than by diffing the folder
        // either side of it: a listing placed in one of the folders the
        // game keeps its own files in never shows up in a listing of that
        // folder, and its record would come back empty.
        final added = [
          for (final placed in installed)
            p.relative(enabledPathOf(placed.path), from: dir.path),
        ];
        await _rememberShopInstall(ShopInstall(
          listingId: mod.id,
          gameId: mod.gameId,
          version: mod.version,
          name: mod.name,
          files: added,
        ));
        analytics.capture(previous == null ? 'shop_mod_installed'
            : 'shop_mod_updated', {
          'game': mod.gameId,
          'listing': mod.id,
          'size_kb': (mod.fileSizeBytes / 1024).round(),
        });
        // The creator's download count, and the one thing here that is
        // reported whether or not analytics are on: it is a fact about
        // their listing rather than anything about this machine, and a
        // creator's number should not depend on who has which toggle on.
        // Not awaited - the install is finished and this is nobody's
        // business but the server's. Demo listings are invented, so they
        // count nothing.
        if (!settings.demoLibrary) unawaited(_reportDownload(mod.id));
      }
    } catch (e) {
      // Only the download can throw here; installs report themselves.
      lastError = AppMessage('shopDownloadFailed', [mod.name]);
      analytics.capture(
          'shop_install_failed', {'game': mod.gameId, 'reason': 'download'});
      playSound(UiSound.error);
    } finally {
      shopProgress.remove(mod.id);
      try {
        await scratch?.delete(recursive: true);
      } catch (_) {}
      notifyListeners();
    }
  }

  /// Downloads [mod]'s file to a folder the user picks and installs
  /// nothing. Asked for by someone whose listing was a Microsoft Access
  /// database rather than a mod file (issue #16): the app had no way to
  /// hand over a download it could not also file away, and "no mod files
  /// found" was the only answer a perfectly good listing got. It is also
  /// the answer to not knowing where Install puts things - here the user
  /// says where.
  ///
  /// The file is written straight to the chosen path rather than through
  /// a scratch copy, so a failed download leaves nothing behind (see
  /// [downloadShopFile], which deletes its own partial file). Needs no
  /// mods folder, which is why it works on a game that has none set up.
  /// Returns whether a file was actually written - the button says
  /// "Saved" on the strength of it.
  Future<bool> saveShopMod(ShopMod mod) async {
    if (shopBusy(mod)) return false;
    playSound(UiSound.click);
    // Marked busy before the dialog opens rather than after it closes:
    // the picker is the longest await here, and until something lands in
    // one of these the button is still live and a second press starts a
    // second download.
    _shopSaving.add(mod.id);
    notifyListeners();
    try {
      final path = await _pickSavePath(p.basename(mod.fileName));
      if (path == null) return false;
      shopSaveProgress[mod.id] = null;
      notifyListeners();
      try {
        await _downloadShop(mod, File(path), onProgress: (received, total) {
          shopSaveProgress[mod.id] =
              total > 0 ? (received / total).clamp(0.0, 1.0) : null;
          notifyListeners();
        });
        analytics.capture('shop_mod_saved', {
          'game': mod.gameId,
          'listing': mod.id,
          'size_kb': (mod.fileSizeBytes / 1024).round(),
        });
        playSound(UiSound.install);
        // A take is a take, whether or not the app filed it away for
        // them; the mod's own page on the website counts its download
        // button the same way. Same bargain as the install: not awaited,
        // and never for an invented listing.
        if (!settings.demoLibrary) unawaited(_reportDownload(mod.id));
        return true;
      } catch (e) {
        // Only the download is worded as a failed download - a picker
        // that threw is not one, and is caught by the outer finally.
        lastError = AppMessage('shopDownloadFailed', [mod.name]);
        analytics.capture(
            'shop_save_failed', {'game': mod.gameId, 'reason': 'download'});
        playSound(UiSound.error);
        return false;
      }
    } finally {
      _shopSaving.remove(mod.id);
      shopSaveProgress.remove(mod.id);
      notifyListeners();
    }
  }

  /// Opens the creator portal in the browser - the "publish your mods"
  /// nudge on the shop screen.
  void openShopPortal() {
    analytics.capture('shop_publish_clicked', {'game': _adapter.game.id});
    openUrl(Uri.parse(shopPortalUrl));
  }

  // =========================================================================
  // Saves

  /// The current game's saves, or null before the first look (switching
  /// game clears it, so each game's saves are read when first asked for
  /// rather than on every launch).
  List<SaveGame>? saveGames;

  bool savesLoading = false;

  SavesTab savesTab = SavesTab.households;

  int _selectedSaveIndex = 0;
  int _selectedHouseholdIndex = 0;

  /// Which album photo is on the easel.
  int savesPhotoIndex = 0;

  SaveGame? get selectedSave {
    final saves = saveGames;
    if (saves == null || saves.isEmpty) return null;
    return saves[_selectedSaveIndex.clamp(0, saves.length - 1)];
  }

  SaveHousehold? get selectedSaveHousehold {
    final households = selectedSave?.households;
    if (households == null || households.isEmpty) return null;
    return households[_selectedHouseholdIndex.clamp(0, households.length - 1)];
  }

  /// The sub-tabs this save has anything to show on, in display order.
  /// A save with no readable content still offers [SavesTab.stats]: size,
  /// backups and dates exist for any file the scanner could list.
  List<SavesTab> get availableSavesTabs {
    final save = selectedSave;
    if (save == null) return const [];
    return [
      if (save.households.isNotEmpty) SavesTab.households,
      if (save.photos.isNotEmpty) SavesTab.album,
      SavesTab.stats,
    ];
  }

  /// [savesTab], unless the selected save doesn't offer it (a Sims 3 save
  /// has no album when its world file was unreadable), in which case the
  /// first tab it does.
  SavesTab get effectiveSavesTab {
    final available = availableSavesTabs;
    if (available.isEmpty || available.contains(savesTab)) return savesTab;
    return available.first;
  }

  void openSaves() {
    if (screen != AppScreen.saves) {
      playSound(UiSound.open);
      analytics.capture('saves_opened', {'game': _adapter.game.id});
    }
    screen = AppScreen.saves;
    if (saveGames == null && !savesLoading) {
      _loadSaves();
    }
    notifyListeners();
  }

  /// Re-reads the saves from disk - the refresh button, and the way the
  /// list catches a save written while the app was open.
  Future<void> refreshSaves() {
    playSound(UiSound.click);
    return _loadSaves();
  }

  Future<void> _loadSaves() async {
    final scanned = _adapter;
    savesLoading = true;
    notifyListeners();
    List<SaveGame> saves = const [];
    try {
      saves = await scanned.listSaveGames();
    } catch (_) {
      // The adapter contract says never throw; a surprise here still
      // must not take the screen down.
    }
    // The user may have switched games mid-scan; those results belong to
    // the game that was asked.
    if (!identical(scanned, _adapter)) return;
    saveGames = saves;
    savesLoading = false;
    _selectedSaveIndex = 0;
    _selectedHouseholdIndex = 0;
    savesPhotoIndex = 0;
    analytics.capture('saves_loaded', {
      'game': scanned.game.id,
      'saves': saves.length,
      'households': saves.isEmpty ? 0 : saves.first.households.length,
      'sims': saves.isEmpty ? 0 : saves.first.simCount,
      'photos': saves.isEmpty ? 0 : saves.first.photos.length,
    });
    notifyListeners();
  }

  void selectSave(int index) {
    final saves = saveGames;
    if (saves == null || index < 0 || index >= saves.length) return;
    if (index == _selectedSaveIndex) return;
    playSound(UiSound.select);
    _selectedSaveIndex = index;
    _selectedHouseholdIndex = 0;
    savesPhotoIndex = 0;
    notifyListeners();
  }

  int get selectedSaveIndex => _selectedSaveIndex;

  void selectSaveHousehold(int index) {
    final households = selectedSave?.households;
    if (households == null || index < 0 || index >= households.length) return;
    if (index == _selectedHouseholdIndex) return;
    playSound(UiSound.click);
    _selectedHouseholdIndex = index;
    notifyListeners();
  }

  int get selectedSaveHouseholdIndex => _selectedHouseholdIndex;

  void setSavesTab(SavesTab tab) {
    if (tab == savesTab) return;
    playSound(UiSound.cycle);
    savesTab = tab;
    notifyListeners();
  }

  void selectSavePhoto(int index) {
    final photos = selectedSave?.photos;
    if (photos == null || index < 0 || index >= photos.length) return;
    if (index == savesPhotoIndex) return;
    playSound(UiSound.click);
    savesPhotoIndex = index;
    notifyListeners();
  }

  // =========================================================================
  // Packs

  /// The current game's installed packs, or null before the first look.
  /// Cleared on game switch like the saves, so each game's packs are read
  /// when the screen is first opened rather than on every launch.
  List<GamePack>? gamePacks;

  bool packsLoading = false;

  /// What the game has to say about this particular collection, which on
  /// nearly every machine is nothing. Worked out once when the shelf is
  /// read rather than on every build: it is about what is installed, and
  /// switching a pack off does not uninstall it.
  AppMessage? packCollectionNote;

  /// Whether the shelf on screen was invented rather than read off the
  /// disk, so a switch on it stays in memory the way the demo library's
  /// mods do.
  bool _packsAreDemo = false;

  /// Packs the user has switched this session whose new state the running
  /// game has not picked up yet. The game reads its pack list once at
  /// startup, so the screen has to say "restart the game" rather than
  /// pretend the change already happened.
  final Set<String> _packsChanged = {};

  bool get hasPendingPackChanges => _packsChanged.isNotEmpty;

  /// Whether this game has a packs screen at all. Behind a kill switch
  /// because the toggle writes into the game's own settings file, and a
  /// patch that changes how the game reads that file is something we
  /// would want to stop doing before shipping a fix.
  bool get showPacks =>
      _adapter.hasPacks && analytics.isEnabled('pack-manager', fallback: true);

  /// Whether the switches are worth drawing at all. A game whose packs
  /// need administrator rights the app does not have gets the facts and
  /// an explanation instead of switches that would snap back, and so
  /// does one whose switches nobody has turned on yet.
  bool get canTogglePacks =>
      _adapter.canTogglePacks &&
      showPacks &&
      !packsNeedAdmin &&
      !packsNeedOptIn;

  /// This game's switches work but have never been shown to be safe, and
  /// the user has not said they want them anyway.
  bool get packsNeedOptIn =>
      _adapter.packToggleIsExperimental && !experimentalPackToggles;

  /// Whether the packs on screen are the experimental kind, opted in or
  /// not - the warning stands either way, because agreeing to the risk
  /// does not make it go away.
  bool get packsAreExperimental => _adapter.packToggleIsExperimental;

  bool get experimentalPackToggles => settings.experimentalPackToggles;

  /// The app is looking at a game it could switch packs for, if only it
  /// were elevated. Deliberately not a nudge to always run as
  /// administrator: doing that costs drag and drop from Explorer, which
  /// Windows refuses to deliver to an elevated window.
  bool get packsNeedAdmin =>
      _adapter.packToggleNeedsAdmin && !runningElevated;

  /// The packs the game will load, and the ones it will skip.
  int get enabledPackCount =>
      gamePacks?.where((pack) => pack.isEnabled).length ?? 0;

  int get disabledPackCount =>
      gamePacks?.where((pack) => !pack.isEnabled).length ?? 0;

  void openPacks() {
    if (screen != AppScreen.packs) {
      playSound(UiSound.open);
      analytics.capture('packs_opened', {'game': _adapter.game.id});
    }
    screen = AppScreen.packs;
    if (gamePacks == null && !packsLoading) {
      _loadPacks();
    }
    notifyListeners();
  }

  /// Re-reads the packs from disk - the refresh button, and how a pack
  /// installed while the app was open shows up.
  Future<void> refreshPacks() {
    playSound(UiSound.click);
    return _loadPacks();
  }

  Future<void> _loadPacks() async {
    final scanned = _adapter;
    // Demo mode invents what is installed, not what the platform can do
    // about it: the shelf is filled from the game's own catalog, and
    // everything that decides whether a switch is drawn at all - this
    // game can toggle, it needs administrator rights, it needs the
    // experimental opt-in - is left answering for the real machine. So a
    // screenshot never shows a switch this copy of the app wouldn't have.
    // No spinner either; nothing here goes to the disk.
    if (settings.demoLibrary) {
      final demo = scanned.demoPacks();
      if (demo.isNotEmpty) {
        gamePacks = demo;
        packCollectionNote = scanned.packCollectionNote(demo);
        _packsAreDemo = true;
        packsLoading = false;
        notifyListeners();
        return;
      }
    }
    _packsAreDemo = false;
    packsLoading = true;
    notifyListeners();
    List<GamePack> packs = const [];
    try {
      packs = await scanned.listPacks();
    } catch (_) {
      // The adapter contract says never throw; a surprise here still must
      // not take the screen down.
    }
    // The user may have switched games mid-scan; those results belong to
    // the game that was asked.
    if (!identical(scanned, _adapter)) return;
    gamePacks = packs;
    packCollectionNote = scanned.packCollectionNote(packs);
    packsLoading = false;
    analytics.capture('packs_loaded', {
      'game': scanned.game.id,
      'packs': packs.length,
      'disabled': packs.where((pack) => !pack.isEnabled).length,
    });
    notifyListeners();
  }

  /// Switches one pack on or off. The pack's own files are never touched:
  /// what changes is the game's record of what to load, so this is
  /// reversible and takes effect at the game's next start.
  Future<void> setPackEnabled(GamePack pack, {required bool enabled}) async {
    if (!_adapter.canTogglePacks ||
        !pack.canToggle ||
        pack.isEnabled == enabled) {
      return;
    }
    final packs = gamePacks;
    if (packs == null) return;
    playSound(enabled ? UiSound.toggleOn : UiSound.toggleOff);
    // Optimistic, and put back if the write fails: the switch has to move
    // under the finger that pressed it.
    final index = packs.indexWhere((p) => p.code == pack.code);
    if (index < 0) return;
    gamePacks = [...packs]..[index] = pack.copyWith(isEnabled: enabled);
    _packsChanged.add(pack.code);
    notifyListeners();
    // An invented pack has no settings file to write and no key to move,
    // so the switch stops here - as does the restart notice, which is
    // part of the screen worth photographing. Like every edit to the demo
    // library it lasts until the shelf is next read.
    if (_packsAreDemo) return;
    try {
      await _adapter.setPackEnabled(pack, enabled: enabled);
    } catch (error, stack) {
      // The shelf may have been cleared or rebuilt while the write was in
      // flight - a game switch, a rescan - so put the pack back where it
      // sits now rather than where it sat when the switch was pressed.
      final current = gamePacks;
      final at = current == null
          ? -1
          : current.indexWhere((p) => p.code == pack.code);
      if (current != null && at >= 0) {
        gamePacks = [...current]..[at] = pack;
      }
      _packsChanged.remove(pack.code);
      lastError = error is PackActionException
          ? error.detail
          : AppMessage('errorPackToggleFailed', [pack.name]);
      playSound(UiSound.error);
      if (error is! PackActionException) {
        analytics.captureException(error, stack);
      }
      notifyListeners();
      return;
    }
    analytics.capture('pack_toggled', {
      'game': _adapter.game.id,
      'pack': pack.code,
      'kind': pack.kind.name,
      'enabled': enabled,
    });
  }

  // ——— the first-run walkthrough ———

  bool _onboarding = false;
  int _onboardingAt = 0;

  /// Whether the walkthrough is covering the window. The library loads
  /// behind it either way: the questions it asks are about which game to
  /// open and how things should look, and none of them is a reason to
  /// keep the app from doing what it was started to do.
  bool get showOnboarding => _onboarding;

  /// Whether the launch scan is still working out which games this
  /// machine has. The walkthrough's second page waits on it rather than
  /// telling the user "no games found" while it is still looking.
  bool scanningGames = true;

  /// The games whose mods folder was found. Empty is a real answer - the
  /// walkthrough says so and points at Settings.
  List<GameAdapter> get installedGames => [
        for (final adapter in registry.adapters)
          if (hasModsFolder(adapter.game.id)) adapter,
      ];

  /// The pages this walkthrough actually has. Worked out per read rather
  /// than fixed at the start, because [installedGames] fills in while the
  /// user is reading page one.
  List<OnboardingStep> get onboardingSteps => [
        OnboardingStep.welcome,
        OnboardingStep.games,
        if (installedGames.length > 1) OnboardingStep.favorite,
        OnboardingStep.look,
        OnboardingStep.library,
        OnboardingStep.done,
      ];

  /// Which page is up. Clamped rather than stored as a step, so a page
  /// that appears or disappears under the user (the scan finishing while
  /// they read) can never leave the index pointing past the end.
  int get onboardingAt =>
      _onboardingAt.clamp(0, onboardingSteps.length - 1);

  OnboardingStep get onboardingStep => onboardingSteps[onboardingAt];

  /// Whether Next means anything yet: the games page holds the walkthrough
  /// until the scan has answered, since the page after it is built out of
  /// what the scan found.
  bool get canAdvanceOnboarding =>
      onboardingStep != OnboardingStep.games || !scanningGames;

  void nextOnboardingStep() {
    if (!canAdvanceOnboarding) return;
    if (onboardingAt >= onboardingSteps.length - 1) {
      // Not awaited: the last press is "let me in", and what it waits on
      // is a preference write and a folder scan.
      unawaited(finishOnboarding());
      return;
    }
    playSound(UiSound.click);
    _onboardingAt = onboardingAt + 1;
    analytics.capture('onboarding_step', {'step': onboardingStep.name});
    notifyListeners();
  }

  void backOnboardingStep() {
    if (onboardingAt == 0) return;
    playSound(UiSound.click);
    _onboardingAt = onboardingAt - 1;
    notifyListeners();
  }

  /// The game to open on from now on. Written down and nothing more: the
  /// switch itself happens at the end of the walkthrough (and at the next
  /// launch when it is Settings asking), because loading a library is a
  /// folder scan and a page of cards is somewhere people click about.
  Future<void> setDefaultGame(String? gameId) async {
    if (gameId == settings.defaultGameId) return;
    await settings.setDefaultGameId(gameId);
    playSound(UiSound.select);
    analytics.capture('default_game_set', {'game': gameId ?? 'auto'});
    notifyListeners();
  }

  /// The game the walkthrough's cards show as picked: what the user chose,
  /// or the one the app happens to have loaded.
  String get defaultGameId => settings.defaultGameId ?? _adapter.game.id;

  /// Puts the walkthrough away for good, opening the game it was told to
  /// open. [skipped] only colours the report - a walkthrough somebody
  /// walked out of has still been through, and asking again next launch
  /// would be arguing with them.
  Future<void> finishOnboarding({bool skipped = false}) async {
    if (!_onboarding) return;
    playSound(skipped ? UiSound.click : UiSound.select);
    analytics.capture('onboarding_finished', {
      'skipped': skipped,
      'step': onboardingStep.name,
      'games': installedGames.length,
      'default_game': settings.defaultGameId ?? 'auto',
    });
    _onboarding = false;
    await settings.setOnboardingDone(true);
    final chosen = settings.defaultGameId;
    // selectGame notifies and reloads on its own; the plain notify is for
    // the case where there is nothing to switch to.
    if (chosen != null && chosen != _adapter.game.id) {
      await selectGame(chosen);
    } else {
      notifyListeners();
    }
  }

  /// The Settings row: run it again. Nothing is reset - the answers it
  /// asks about are the settings themselves, and it opens showing what
  /// they currently are.
  void restartOnboarding() {
    if (_onboarding) return;
    playSound(UiSound.click);
    _onboarding = true;
    _onboardingAt = 0;
    screen = AppScreen.library;
    analytics.capture('onboarding_started', {'source': 'settings'});
    notifyListeners();
  }

  // ——— the plumbob's trivia ———

  /// How long the buddy waits before offering the next fact, and how long
  /// the badge sits on the plumbob before the bubble follows it up. Four
  /// minutes because this is a mod manager and not a quiz: often enough
  /// to be a companion, rare enough that nobody reaches for the off
  /// switch on the first afternoon.
  static const _triviaEvery = Duration(minutes: 4);
  static const _triviaBadgeLead = Duration(milliseconds: 1400);

  /// One shuffled deck per game, built the first time that game's buddy
  /// is asked and kept for the run. Shuffled rather than ordered so two
  /// launches don't open on the same fact, and kept rather than
  /// reshuffled so stepping back really does go back.
  final Map<String, List<TriviaFact>> _triviaDecks = {};
  final math.Random _triviaShuffle = math.Random();

  int _triviaIndex = 0;
  bool _triviaOpen = false;
  bool _triviaBadge = false;
  Timer? _triviaTimer;
  Timer? _triviaOpenTimer;

  /// Whether the buddy exists at all: the player hasn't switched it off,
  /// and this game has facts written for it. A game added before anybody
  /// researched it gets no plumbob rather than an empty bubble.
  ///
  /// Separate from [showTrivia] because the timer runs off this one: the
  /// buddy is still *there* while you are reading a mod, it just isn't
  /// drawn, and stopping the clock every time somebody opens Settings
  /// would be a different thing entirely.
  bool get triviaAvailable =>
      settings.triviaBuddy && _adapter.triviaFacts.isNotEmpty;

  /// Whether to draw it right now. Library, saves and packs only: those
  /// are the screens you browse, where a plumbob in the corner is
  /// company. The mod page, Settings and The Exchange are screens you
  /// came to read or to decide something on, and it would be in the way -
  /// and so is the walkthrough, which is a plumbob's worth of window
  /// covered by a card the user is reading.
  bool get showTrivia =>
      triviaAvailable && triviaContext != null && !_onboarding;

  bool get triviaOpen => showTrivia && _triviaOpen;

  /// The little "!" on the plumbob: something new is waiting, and the
  /// bubble isn't already showing it.
  bool get triviaBadge => showTrivia && _triviaBadge && !_triviaOpen;

  /// Which of the three screens the buddy lives on is up, and so which
  /// facts written about a screen are allowed. Null is one of the
  /// screens it stays off, which is also what [showTrivia] reads.
  TriviaContext? get triviaContext => switch (screen) {
        AppScreen.library => TriviaContext.library,
        AppScreen.saves => TriviaContext.saves,
        AppScreen.packs => TriviaContext.packs,
        AppScreen.detail || AppScreen.settings || AppScreen.shop => null,
      };

  List<TriviaFact> get _triviaDeck => _triviaDecks.putIfAbsent(
      _adapter.game.id, () => [..._adapter.triviaFacts]..shuffle(_triviaShuffle));

  /// The facts that may be drawn on the screen the user is actually on.
  List<TriviaFact> get _triviaPool =>
      [for (final f in _triviaDeck) if (f.fitsContext(triviaContext)) f];

  /// Where the bubble actually is, which is not always [_triviaIndex]:
  /// walking onto another screen can make the fact you were reading
  /// ineligible, and sliding to the next one that fits is a better answer
  /// than blanking the bubble. Everything else works off this, so the
  /// arrows step from what is on screen rather than from a stale index.
  int? get _triviaShownIndex {
    final deck = _triviaDeck;
    if (deck.isEmpty) return null;
    final at = _triviaIndex % deck.length;
    for (var k = 0; k < deck.length; k++) {
      final i = (at + k) % deck.length;
      if (deck[i].fitsContext(triviaContext)) return i;
    }
    return null;
  }

  /// The fact on the bubble, or null when this game has none.
  TriviaFact? get triviaFact {
    final at = _triviaShownIndex;
    return at == null ? null : _triviaDeck[at];
  }

  /// Where the current fact sits in what this screen can show, 1-based,
  /// and how many that is. The count is the pool rather than the deck so
  /// "fact 3 of 24" is a number the buttons can actually reach.
  int get triviaNumber {
    final fact = triviaFact;
    if (fact == null) return 0;
    return _triviaPool.indexOf(fact) + 1;
  }

  int get triviaTotal => _triviaPool.length;

  /// The next index in [direction] whose fact fits the screen, wrapping.
  /// Returns the index it started from when nothing else fits, which
  /// only happens with a deck of one.
  int? _triviaStep(int direction) {
    final deck = _triviaDeck;
    final from = _triviaShownIndex;
    if (from == null) return null;
    for (var k = 1; k <= deck.length; k++) {
      final at = (from + direction * k) % deck.length;
      final wrapped = at < 0 ? at + deck.length : at;
      if (deck[wrapped].fitsContext(triviaContext)) return wrapped;
    }
    return from;
  }

  /// Starts (or stops) the timer that offers facts on its own. Called
  /// from [init] and whenever the setting flips.
  ///
  /// Never runs under `flutter test`: a periodic timer outlives the
  /// widget tree and every test that pumps the app would fail on a
  /// pending one, which is a high price for a bubble no test is watching.
  void _armTrivia() {
    _triviaTimer?.cancel();
    _triviaOpenTimer?.cancel();
    _triviaTimer = null;
    _triviaOpenTimer = null;
    if (!triviaAvailable) return;
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    _triviaTimer = Timer.periodic(_triviaEvery, (_) {
      // Nothing to interrupt: a bubble already up is the user reading,
      // and a screen the buddy stays off is not somewhere to queue one
      // up to spring on them when they come back.
      if (!showTrivia || _triviaOpen) return;
      final next = _triviaStep(1);
      if (next == null) return;
      _triviaIndex = next;
      _triviaBadge = true;
      notifyListeners();
      _triviaOpenTimer = Timer(_triviaBadgeLead, () {
        if (!showTrivia || _triviaOpen) return;
        _triviaOpen = true;
        _triviaBadge = false;
        notifyListeners();
      });
    });
  }

  /// The plumbob was clicked: show the bubble, or put it away.
  void toggleTrivia() {
    if (!showTrivia) return;
    playSound(UiSound.click);
    _triviaOpen = !_triviaOpen;
    _triviaBadge = false;
    if (_triviaOpen) {
      analytics.capture('trivia_opened',
          {'game': _adapter.game.id, 'source': 'plumbob'});
    }
    notifyListeners();
  }

  /// The ✕ on the bubble. Puts this one away without switching the buddy
  /// off - that is what the Settings row is for, and the bubble links to
  /// it so the difference is findable.
  void closeTrivia() {
    if (!_triviaOpen) return;
    playSound(UiSound.click);
    _triviaOpen = false;
    _triviaBadge = false;
    notifyListeners();
  }

  /// Steps to the next or previous fact this screen can show.
  void stepTrivia(int direction) {
    final next = _triviaStep(direction);
    if (next == null) return;
    playSound(UiSound.click);
    _triviaIndex = next;
    _triviaBadge = false;
    analytics.capture('trivia_advanced',
        {'game': _adapter.game.id, 'direction': direction > 0 ? 'next' : 'back'});
    notifyListeners();
  }

  /// "Another one": somewhere else in the pool entirely, never the fact
  /// already on screen.
  void shuffleTrivia() {
    final pool = _triviaPool;
    final deck = _triviaDeck;
    if (pool.length < 2) return stepTrivia(1);
    final current = triviaFact;
    final choices = [for (final f in pool) if (f != current) f];
    final pick = choices[_triviaShuffle.nextInt(choices.length)];
    playSound(UiSound.click);
    _triviaIndex = deck.indexOf(pick);
    _triviaBadge = false;
    analytics.capture(
        'trivia_advanced', {'game': _adapter.game.id, 'direction': 'shuffle'});
    notifyListeners();
  }

  /// The Settings toggle, and the only way the buddy goes away for good.
  /// Switching it back on re-arms the timer, so it isn't a one-way door.
  Future<void> setTriviaBuddy(bool value) async {
    await settings.setTriviaBuddy(value);
    _triviaOpen = false;
    _triviaBadge = false;
    _armTrivia();
    analytics.capture('trivia_toggled', {'enabled': value});
    notifyListeners();
  }

  /// Opens the system file manager at [path] (selecting it when it's a
  /// file). Desktop-only convenience; failures are non-fatal.
  Future<void> revealInFileManager(String path) async {
    playSound(UiSound.click);
    try {
      if (Platform.isWindows) {
        final isDir = await Directory(path).exists();
        await Process.start(
            'explorer.exe', isDir ? [path] : ['/select,', path]);
      } else if (Platform.isMacOS) {
        await Process.start('open', ['-R', path]);
      } else {
        final dir =
            await Directory(path).exists() ? path : File(path).parent.path;
        await Process.start('xdg-open', [dir]);
      }
    } catch (_) {}
  }
}
