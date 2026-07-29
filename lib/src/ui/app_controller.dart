import 'dart:async';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../core/app_message.dart';
import '../core/conflicts.dart';
import '../core/deep_link.dart';
import '../core/demo_library.dart';
import '../core/folder_access.dart';
import '../core/game_adapter.dart';
import '../core/game_registry.dart';
import '../core/mod.dart';
import '../core/install_destination.dart';
import '../core/mod_advisories.dart';
import '../core/mod_archive.dart';
import '../core/mod_folder.dart';
import '../core/mod_name.dart';
import '../core/package_insight.dart';
import '../core/placed_mods.dart';
import '../core/save_game.dart';
import '../services/analytics.dart';
import '../services/demo_shop.dart';
import '../services/disk_space.dart';
import '../services/elevation.dart';
import '../services/github.dart';
import '../services/mod_shop.dart';
import '../services/settings_store.dart';
import '../services/sfx.dart';

enum AppScreen { library, detail, settings, shop, saves }

/// Which half of the library the Enabled/Disabled stats are showing.
/// [all] is both, i.e. no narrowing at all.
enum ModStateFilter { all, enabled, disabled }

/// How the library draws the mods that got past the filters. [folders]
/// is [list] with the rows gathered under the subfolder each one sits
/// in - the shape of the mods directory, which the folder chips can only
/// filter by, one at a time.
enum LibraryLayout { grid, list, folders }

/// The saves screen's sub-tabs. Which ones a save actually offers depends
/// on what its files gave up ([AppController.availableSavesTabs]): every
/// game fills [households] differently, only some have photos, and
/// [stats] draws whatever numbers exist.
enum SavesTab { households, album, stats }

/// A section of the folder view: the mods sitting directly in [folder],
/// which is `null` for the ones in the mods directory itself. A mod
/// belongs to exactly one, so `cc` does not repeat what `cc/defaults`
/// already shows.
typedef ModFolderGroup = ({String? folder, List<Mod> mods, int sizeBytes});

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
    Future<bool> Function()? checkElevated,
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
        _adapter = registry.byGameId('sims4') ?? registry.adapters.first {
    // Remote flags may land after the first frame (announcement banner,
    // kill switches); repaint when they do.
    this.analytics.onFlagsChanged = notifyListeners;
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

  GameAdapter _adapter;
  GameAdapter get adapter => _adapter;

  AppScreen screen = AppScreen.library;
  bool loading = true;
  String query = '';
  String category = 'All';
  String folder = 'All';
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
        } else {
          // A folder counts everything below it too, and earns a chip
          // even when it holds no mod files of its own: a user who put
          // everything in cc/defaults still thinks of cc as a folder.
          for (final key in folderAncestry(folder)) {
            _folderCounts[key] = (_folderCounts[key] ?? 0) + 1;
          }
        }
      }
      _categoryCounts[mod.category] = (_categoryCounts[mod.category] ?? 0) + 1;
      if (mod.isEnabled) _enabledCount++;
      _totalSizeBytes += mod.sizeBytes ?? 0;
    }
    // Sorting the paths puts each folder straight above its own children.
    _sortedFolders = _folderCounts.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    _sortedCategories = _categoryCounts.keys.toList()..sort();
    // The chips these filters point at may have just gone away.
    if (!categories.contains(category)) category = 'All';
    if (folder != 'All' && !_folderCounts.containsKey(folder)) folder = 'All';
    // So might the side of the switch the library is showing: enabling
    // the last disabled mod shouldn't leave an empty list behind.
    if (stateFilter == ModStateFilter.enabled && _enabledCount == 0 ||
        stateFilter == ModStateFilter.disabled && disabledCount == 0) {
      stateFilter = ModStateFilter.all;
    }
    _libraryStamp++;
  }

  Mod? get selectedMod {
    final path = _selectedModPath;
    return path == null ? null : _byPath[path];
  }

  List<Mod> get filteredMods {
    final q = query.trim().toLowerCase();
    final key = '$_libraryStamp|$category|$folder|$conflictsOnly'
        '|$advisoriesOnly|$tooDeepOnly|$stateFilter'
        '|${settings.showDisabled}|$q';
    final cached = _filtered;
    if (cached != null && _filteredKey == key) return cached;
    // Asking for the disabled ones outranks the preference that hides
    // them: it was a click on that very number, so answering with an
    // empty library would be a joke at the user's expense.
    final hideDisabled =
        !settings.showDisabled && stateFilter != ModStateFilter.disabled;
    final result = [
      for (final mod in mods)
        if ((category == 'All' || mod.category == category) &&
            (folder == 'All' || _inFolder(folderOf(mod), folder)) &&
            (!conflictsOnly || conflictPaths.contains(mod.path)) &&
            (!advisoriesOnly || advisories.containsKey(mod.path)) &&
            (!tooDeepOnly || tooDeepPaths.contains(mod.path)) &&
            (stateFilter == ModStateFilter.all ||
                mod.isEnabled == (stateFilter == ModStateFilter.enabled)) &&
            (!hideDisabled || mod.isEnabled) &&
            (q.isEmpty ||
                mod.name.toLowerCase().contains(q) ||
                humanizeModName(mod.name).toLowerCase().contains(q)))
          mod,
    ];
    _filtered = result;
    _filteredKey = key;
    return result;
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

  /// Whether a mod in [actual] belongs under the chip for [selected]:
  /// its own folder, or any folder below it.
  bool _inFolder(String? actual, String selected) =>
      actual != null && folderIsWithin(actual, selected);

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

  /// The key a collapsed section is remembered under when it is the mods
  /// directory itself, which has no folder name of its own.
  static const rootFolderKey = '';

  /// [filteredMods] gathered into the folder view's sections. Grouped on
  /// the folder each mod actually sits in rather than on the ancestry the
  /// chips count, so nothing is listed twice; the sections then follow
  /// [folders], which means rearranging the chips rearranges these too.
  /// The mods directory itself comes first whatever that order says.
  List<ModFolderGroup> get folderGroups {
    final visible = filteredMods;
    final cached = _folderGroups;
    if (cached != null && identical(_folderGroupsFrom, visible)) return cached;
    final byFolder = <String?, List<Mod>>{};
    for (final mod in visible) {
      (byFolder[folderOf(mod)] ??= []).add(mod);
    }
    ModFolderGroup group(String? folder) {
      final mods = byFolder.remove(folder)!;
      return (
        folder: folder,
        mods: mods,
        sizeBytes: mods.fold(0, (sum, m) => sum + (m.sizeBytes ?? 0)),
      );
    }

    final result = [
      if (byFolder.containsKey(null)) group(null),
      for (final f in folders)
        if (byFolder.containsKey(f)) group(f),
      // Anything the chip order somehow missed still has to be drawn:
      // a section the user cannot see is a mod the user cannot reach.
      for (final f in byFolder.keys.toList()) group(f),
    ];
    _folderGroups = result;
    _folderGroupsFrom = visible;
    return result;
  }

  List<ModFolderGroup>? _folderGroups;
  List<Mod>? _folderGroupsFrom;

  bool isFolderCollapsed(String? folder) =>
      settings.collapsedFolders(_adapter.game.id).contains(folder ?? rootFolderKey);

  /// Rolls a folder view section up or down. Remembered per game, so a
  /// library someone has organised stays the way they left it.
  Future<void> toggleFolderCollapsed(String? folder) async {
    final key = folder ?? rootFolderKey;
    final collapsed = settings.collapsedFolders(_adapter.game.id).toSet();
    final wasCollapsed = collapsed.remove(key);
    if (!wasCollapsed) collapsed.add(key);
    playSound(wasCollapsed ? UiSound.toggleOn : UiSound.toggleOff);
    await settings.setCollapsedFolders(_adapter.game.id, collapsed.toList());
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
  List<Mod> conflictingWith(Mod mod) {
    if (!conflictPaths.contains(mod.path)) return const [];
    final name = p.basename(mod.name).toLowerCase();
    final identity = parseModName(mod.name).identity;
    final overlapping = resourceOverlaps[mod.path] ?? const {};
    return [
      for (final other in mods)
        if (other.path != mod.path &&
            other.isEnabled &&
            (p.basename(other.name).toLowerCase() == name ||
                overlapping.containsKey(other.path) ||
                (conflictPaths.contains(other.path) &&
                    parseModName(other.name).identity == identity)))
          other,
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
      category != 'All' ||
      folder != 'All' ||
      conflictsOnly ||
      advisoriesOnly ||
      tooDeepOnly ||
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
    category = 'All';
    folder = 'All';
    conflictsOnly = false;
    advisoriesOnly = false;
    tooDeepOnly = false;
    stateFilter = ModStateFilter.all;
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
  /// Two signals feed the flag set: the lexical heuristics
  /// ([findConflicts]) and real resource-key overlaps from the package
  /// scan ([findResourceOverlaps], via the insight cache - so with the
  /// artwork scan off only the lexical pass runs).
  void _rescanConflicts() {
    final scan = settings.warnConflicts &&
        analytics.isEnabled('conflict-detection', fallback: true);
    resourceOverlaps = scan ? findResourceOverlaps(mods, insightFor) : const {};
    // The lexical reasons spread last: a mod both signals flag reports
    // the more specific lexical one.
    conflictReasons = !scan
        ? const {}
        : {
            for (final path in resourceOverlaps.keys)
              path: ConflictReason.resourceOverlap,
            ...findConflicts(mods),
          };
    conflictPaths = conflictReasons.keys.toSet();
    if (conflictPaths.isEmpty) conflictsOnly = false;
    _libraryStamp++;
  }

  /// Why the scan flagged [mod], or null when it didn't.
  ConflictReason? conflictReasonOf(Mod mod) => conflictReasons[mod.path];

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

  void openReleasePage() {
    final update = availableUpdate;
    if (update == null) return;
    analytics.capture(
        'update_download_clicked', {'latest_version': update.version});
    openUrl(Uri.parse(update.url));
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
    // Before the first refresh, so the library's very first frame already
    // carries whatever the last download knew.
    _loadCachedAdvisories();
    // Same reason: the update badges are drawn from these records, and
    // the first library frame should already have them.
    _shopInstalls = parseShopInstalls(settings.shopInstallsJson);
    // Same again: mods sitting in folders the library cannot sweep are
    // only known from here, and the first frame should show them.
    _placedMods = parsePlacedMods(settings.placedModsJson);
    // Before the refresh, so the first library frame already carries the
    // banner instead of adding it a moment later. It cannot change while
    // the app is open, so it is asked once.
    runningElevated = await _checkElevated();
    await refresh();
    _captureLibraryOpened();
    // Not awaited, like the update check below it.
    _refreshAdvisories();
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
    if (_shopInstalls.isNotEmpty &&
        analytics.isEnabled('shop-update-check', fallback: true)) {
      refreshShop();
    }
    await _refreshCounts();
  }

  Future<void> selectGame(String gameId) async {
    final next = registry.byGameId(gameId);
    if (next == null) return;
    playSound(UiSound.click);
    _adapter = next;
    screen = AppScreen.library;
    query = '';
    category = 'All';
    folder = 'All';
    conflictsOnly = false;
    advisoriesOnly = false;
    tooDeepOnly = false;
    stateFilter = ModStateFilter.all;
    _selectedModPath = null;
    // Another game's saves are another set of files; they are read when
    // the user next opens the Saves screen, not eagerly on every switch.
    saveGames = null;
    savesLoading = false;
    _selectedSaveIndex = 0;
    _selectedHouseholdIndex = 0;
    savesPhotoIndex = 0;
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
    if (!settings.demoLibrary) return real;
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
    await refresh();
    await _refreshCounts();
  }

  /// Enable/disable for an invented mod: the same state change the real
  /// path makes on disk, done in memory. Like every edit to the demo
  /// library it lasts until the next refresh, which rebuilds it.
  void _toggleDemoMod(Mod mod) {
    final enabled = !mod.isEnabled;
    final updated = Mod(
      name: mod.name,
      path: enabled ? enabledPathOf(mod.path) : '${mod.path}$disabledSuffix',
      status: enabled ? ModStatus.enabled : ModStatus.disabled,
      sizeBytes: mod.sizeBytes,
      category: mod.category,
      modifiedAt: mod.modifiedAt,
    );
    playSound(enabled ? UiSound.toggleOn : UiSound.toggleOff);
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
      // Settings only offers to ask where mods go when there is somewhere
      // else for them to go, which for The Sims 1 depends on the install
      // being found and on which expansions are in it.
      hasInstallChoice = dir != null &&
          (await _adapter.installDestinations(dir)).length > 1;
      _setMods(_withDemoMods(dir == null
          ? const []
          : await _withPlacedMods(_adapter, dir, await _adapter.listMods(dir))));
      _findTooDeepMods();
      // Artwork/content scan happens here, under the loading screen,
      // so the library renders instantly from cache afterwards. It must
      // land before the conflict scan: resource-overlap detection reads
      // the packages' resource keys out of the insight cache.
      await _scanNewMods();
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

  void setCategory(String value) {
    if (value != category) {
      playSound(UiSound.cycle);
      // Categories are the adapter's fixed taxonomy (not user data).
      analytics.capture('category_filter_used',
          {'game': _adapter.game.id, 'category': value});
    }
    category = value;
    notifyListeners();
  }

  void setFolder(String value) {
    if (value != folder) {
      playSound(UiSound.cycle);
      // Folder names are the user's own; only the fact is captured.
      analytics.capture('folder_filter_used', {'game': _adapter.game.id});
    }
    folder = value;
    notifyListeners();
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
    if (isDemoMod(mod)) return _toggleDemoMod(mod);
    try {
      final updated = await _adapter.setEnabled(mod, enabled: !mod.isEnabled);
      playSound(updated.isEnabled ? UiSound.toggleOn : UiSound.toggleOff);
      analytics.capture(updated.isEnabled ? 'mod_enabled' : 'mod_disabled',
          {'game': _adapter.game.id, 'category': mod.category});
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
    }
    await _refreshKeepingError(error);
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
    if (folder == 'All' || _externalFolders.contains(folder)) return modsFolder;
    return Directory(p.joinAll([modsFolder.path, ...folderSegments(folder)]));
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
      // mod carries while it is switched on and both are tried here.
      final mod = adapter.modAt(path) ?? adapter.modAt('$path$disabledSuffix');
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
  Future<List<Mod>> installFiles(List<FileSystemEntity> sources,
      {String method = 'picker',
      GameAdapter? into,
      Directory? target,
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

  /// Back to the shelves.
  void closeShopListing() {
    if (_shopSelectedId == null) return;
    playSound(UiSound.back);
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

  /// Downloads [mod] from The Exchange and installs it through the same
  /// pipeline as a picked file, so archives unpack and files land where
  /// the adapter routes them. The listing names its own game, which need
  /// not be the one in the sidebar: the file goes to that game's folder
  /// either way. One listing at a time per id; the button shows
  /// [shopProgress] while this runs.
  Future<void> installShopMod(ShopMod mod,
      {InstallPlacement placement = const SortedPlacement()}) async {
    final into = registry.byGameId(mod.gameId);
    if (into == null || shopProgress.containsKey(mod.id)) return;
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
      final installed = await installFiles([file],
          method: 'shop', into: into, target: dir, placement: placement);
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
