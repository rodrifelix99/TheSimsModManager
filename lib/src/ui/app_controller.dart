import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../core/conflicts.dart';
import '../core/game_adapter.dart';
import '../core/game_registry.dart';
import '../core/mod.dart';
import '../core/mod_archive.dart';
import '../core/mod_name.dart';
import '../core/package_insight.dart';
import '../services/analytics.dart';
import '../services/disk_space.dart';
import '../services/github.dart';
import '../services/settings_store.dart';
import '../services/sfx.dart';

enum AppScreen { library, detail, settings }

/// What to show the user when installing [error] failed on the file or
/// folder at [sourcePath]. Adapters raise [FormatException] with a
/// message written for the user; everything else is an OS failure, whose
/// own wording (localized by the OS) says more than we could.
String installFailureMessage(Object error, String? sourcePath) {
  if (error is FormatException) return error.message;
  final name = sourcePath == null ? null : p.basename(sourcePath);
  final subject = name == null ? 'That' : '"$name"';
  if (error is FileSystemException) {
    final reason = error.osError?.message ?? error.message;
    return '$subject couldn\'t be installed — $reason. Unpack it manually '
        'and install the files inside if it keeps failing.';
  }
  return '$subject couldn\'t be installed — $error';
}

/// Coarse cause of an install failure, for the `mod_install_failed`
/// event: enough to tell a rejected archive from a filesystem problem
/// without sending anything about the file itself.
String installFailureReason(Object error) => switch (error) {
      FormatException() => 'no_mod_files',
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
    int artworkBudgetBytes = defaultArtworkBudgetBytes,
  })  : _artworkBudgetBytes = artworkBudgetBytes,
        _sfx = sfx ?? Sfx(),
        analytics = analytics ?? Analytics.disabled(),
        _checkUpdates = checkUpdates ?? fetchAvailableUpdate,
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

  bool usingOverride = false;

  List<Mod> _mods = const [];

  /// The current game's library, as of the last [refresh]. Assign through
  /// [_setMods] only: everything derived from it ([folders], the per-chip
  /// counts, the filtered view) is precomputed there.
  List<Mod> get mods => _mods;

  Set<String> conflictPaths = const {};

  /// Resource-key overlaps from the package scan: mod path -> (overlapping
  /// mod's path -> shared key count). See [findResourceOverlaps]. Empty
  /// when conflict warnings are off or nothing overlaps.
  Map<String, Map<String, int>> resourceOverlaps = const {};

  /// When set, [filteredMods] narrows to the mods flagged by the conflict
  /// scan. Toggled by tapping the Conflicts stat in the library header.
  bool conflictsOnly = false;

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

  String? lastError;

  bool get listView => settings.listView;

  /// Mod by path, and the tallies and groupings the library header and
  /// filter row ask for. All of it is rebuilt once per [_setMods] rather
  /// than derived on demand: a chip that counts its own members walks the
  /// whole library, there is one per category and per subfolder, and every
  /// repaint asks them all again - fine for a few hundred mods, seconds of
  /// jank for the tens of thousands people actually keep.
  final Map<String, Mod> _byPath = {};
  final Map<String, String?> _folderOfPath = {};
  final Map<String, int> _folderCounts = {};
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
    _categoryCounts.clear();
    _enabledCount = 0;
    _totalSizeBytes = 0;
    final root = modsDir?.path;
    for (final mod in value) {
      _byPath[mod.path] = mod;
      final folder = root == null ? null : _resolveFolder(root, mod.path);
      _folderOfPath[mod.path] = folder;
      if (folder != null) {
        _folderCounts[folder] = (_folderCounts[folder] ?? 0) + 1;
      }
      _categoryCounts[mod.category] = (_categoryCounts[mod.category] ?? 0) + 1;
      if (mod.isEnabled) _enabledCount++;
      _totalSizeBytes += mod.sizeBytes ?? 0;
    }
    _sortedFolders = _folderCounts.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    _sortedCategories = _categoryCounts.keys.toList()..sort();
    _libraryStamp++;
  }

  Mod? get selectedMod {
    final path = _selectedModPath;
    return path == null ? null : _byPath[path];
  }

  List<Mod> get filteredMods {
    final q = query.trim().toLowerCase();
    final key = '$_libraryStamp|$category|$folder|$conflictsOnly'
        '|${settings.showDisabled}|$q';
    final cached = _filtered;
    if (cached != null && _filteredKey == key) return cached;
    final result = [
      for (final mod in mods)
        if ((category == 'All' || mod.category == category) &&
            (folder == 'All' || folderOf(mod) == folder) &&
            (!conflictsOnly || conflictPaths.contains(mod.path)) &&
            (settings.showDisabled || mod.isEnabled) &&
            (q.isEmpty ||
                mod.name.toLowerCase().contains(q) ||
                humanizeModName(mod.name).toLowerCase().contains(q)))
          mod,
    ];
    _filtered = result;
    _filteredKey = key;
    return result;
  }

  /// Category labels present in the current library, 'All' first.
  List<String> get categories => ['All', ..._sortedCategories];

  int categoryCount(String cat) =>
      cat == 'All' ? mods.length : _categoryCounts[cat] ?? 0;

  /// Top-level subfolder of the mods directory holding [mod], or `null`
  /// when the file sits directly in the mods folder. Mods living outside
  /// the mods directory (Sims 1 routes skins/walls/floors into sibling
  /// game folders) group under their own folder's name instead.
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
    return parts.length > 1 ? parts.first : null;
  }

  /// Top-level subfolder names present in the current library, for the
  /// folder filter chips. Empty when every mod sits directly in the root.
  /// Follows the user's drag-and-drop arrangement when one is saved;
  /// folders it doesn't mention (new on disk) append alphabetically.
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
    notifyListeners();
  }

  int get enabledCount => _enabledCount;
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
    conflictPaths =
        scan ? {...findConflicts(mods), ...resourceOverlaps.keys} : const {};
    if (conflictPaths.isEmpty) conflictsOnly = false;
    _libraryStamp++;
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
      // away; keep only what the lexical heuristics can still see.
      _rescanConflicts();
      notifyListeners();
    }
  }

  String _insightKey(Mod mod) {
    var path = mod.path;
    if (path.toLowerCase().endsWith(disabledSuffix)) {
      path = path.substring(0, path.length - disabledSuffix.length);
    }
    return '$path|${mod.sizeBytes ?? 0}'
        '|${mod.modifiedAt?.millisecondsSinceEpoch ?? 0}';
  }

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
        if (!_insights.containsKey(_insightKey(mod))) mod,
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
    await refresh();
    _captureLibraryOpened();
    // Not awaited: a network round-trip the library shouldn't wait on;
    // the Settings card and sidebar fill in when the answer arrives.
    // Remote kill switch: skip the check entirely if a release's check
    // ever needs to be silenced (e.g. a bad tag confusing everyone).
    if (analytics.isEnabled('update-check', fallback: true)) {
      checkForUpdates();
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
    _selectedModPath = null;
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
      'folders': folders.length,
      'total_size_mb': (totalSizeBytes / (1024 * 1024)).round(),
    });
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
      modsDir = dir;
      _setMods(dir == null ? const [] : await _adapter.listMods(dir));
      // The filtered folder may have been renamed/emptied on disk.
      if (folder != 'All' && !folders.contains(folder)) folder = 'All';
      // Artwork/content scan happens here, under the loading screen,
      // so the library renders instantly from cache afterwards. It must
      // land before the conflict scan: resource-overlap detection reads
      // the packages' resource keys out of the insight cache.
      await _scanNewMods();
      _rescanConflicts();
      candidateDirs = await _adapter.findModsDirectoryCandidates();
      defaultPath = await _adapter.defaultModsPath();
      gameFolder = await _adapter.findGameFolder();
      await _refreshCacheFiles();
      modCounts[_adapter.game.id] = dir == null ? null : mods.length;
      modSizes[_adapter.game.id] = totalSizeBytes;
      // Not awaited: shells out to the OS, and the library shouldn't
      // wait on it; the card fills in when the answer arrives.
      _updateDiskSpace();
    } catch (e) {
      lastError = e.toString();
      playSound(UiSound.error);
    }
    loading = false;
    notifyListeners();
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
      try {
        final override = settings.modsPathOverride(other.game.id);
        final dir = override != null && await Directory(override).exists()
            ? Directory(override)
            : await other.resolveModsDirectory();
        final otherMods = dir == null ? null : await other.listMods(dir);
        modCounts[other.game.id] = otherMods?.length;
        modSizes[other.game.id] =
            otherMods?.fold(0, (sum, m) => sum! + (m.sizeBytes ?? 0)) ?? 0;
      } catch (_) {
        modCounts[other.game.id] = null;
        modSizes[other.game.id] = 0;
      }
    }
    notifyListeners();
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

  Future<void> setListView(bool value) async {
    if (value != settings.listView) {
      playSound(UiSound.cycle);
      analytics
          .capture('view_mode_changed', {'mode': value ? 'list' : 'grid'});
    }
    await settings.setListView(value);
    notifyListeners();
  }

  Future<void> toggleMod(Mod mod) async {
    try {
      final updated = await _adapter.setEnabled(mod, enabled: !mod.isEnabled);
      playSound(updated.isEnabled ? UiSound.toggleOn : UiSound.toggleOff);
      analytics.capture(updated.isEnabled ? 'mod_enabled' : 'mod_disabled',
          {'game': _adapter.game.id, 'category': mod.category});
      _setMods([for (final m in mods) m.path == mod.path ? updated : m]);
      if (_selectedModPath == mod.path) _selectedModPath = updated.path;
      _rescanConflicts();
      modCounts[_adapter.game.id] = mods.length;
      notifyListeners();
    } catch (e, stack) {
      final error = e.toString();
      // Environmental failures (game holding the file open, file moved)
      // are expected and user-actionable - they'd bury real bugs in error
      // tracking, and their messages carry file paths the privacy contract
      // forbids sending.
      final reason = e is ModToggleException ? e.reason.name : null;
      if (reason == null) {
        analytics.captureException(e, stack, mechanism: 'toggleMod');
      }
      analytics.capture('mod_action_failed', {
        'action': 'toggle',
        'game': _adapter.game.id,
        if (reason != null) 'reason': reason,
      });
      playSound(UiSound.error);
      await refresh();
      // refresh() clears lastError, so the error must be restored after it
      // or the UI never shows it.
      lastError = error;
      notifyListeners();
    }
  }

  Future<void> removeMod(Mod mod) async {
    String? error;
    try {
      await _adapter.removeMod(mod);
      playSound(UiSound.uninstall);
      analytics.capture('mod_removed', {
        'game': _adapter.game.id,
        'category': mod.category,
        'size_kb': ((mod.sizeBytes ?? 0) / 1024).round(),
      });
    } catch (e, stack) {
      error = e.toString();
      analytics.captureException(e, stack, mechanism: 'removeMod');
      analytics.capture('mod_action_failed',
          {'action': 'remove', 'game': _adapter.game.id});
      playSound(UiSound.error);
    }
    if (_selectedModPath == mod.path) {
      _selectedModPath = null;
      screen = AppScreen.library;
    }
    await refresh();
    // refresh() clears lastError, so the removal error must be restored
    // after it or the UI never shows it.
    if (error != null) {
      lastError = error;
      notifyListeners();
    }
  }

  Future<void> installFiles(List<FileSystemEntity> sources,
      {String method = 'picker'}) async {
    final dir = modsDir;
    if (dir == null) return;
    String? error;
    var folders = 0, archives = 0, files = 0;
    FileSystemEntity? failing;
    try {
      for (final source in sources) {
        failing = source;
        if (source is Directory) {
          folders++;
          await _adapter.installFolder(dir, source);
        } else if (isArchivePath(source.path)) {
          archives++;
          await _adapter.installArchive(dir, File(source.path));
        } else {
          files++;
          await _adapter.installMod(dir, File(source.path));
        }
      }
      playSound(UiSound.install);
      analytics.capture('mod_installed', {
        'game': _adapter.game.id,
        'method': method,
        'files': files,
        'archives': archives,
        'folders': folders,
      });
    } catch (e, stack) {
      error = installFailureMessage(e, failing?.path);
      // A FormatException is the adapter reporting that the archive or
      // folder held nothing this game can use - a verdict on the file,
      // not a bug to investigate.
      if (e is! FormatException) {
        analytics.captureException(e, stack, mechanism: 'installFiles');
      }
      analytics.capture('mod_install_failed', {
        'game': _adapter.game.id,
        'method': method,
        'reason': installFailureReason(e),
      });
      playSound(UiSound.error);
    }
    await refresh();
    // refresh() clears lastError, so the install error must be restored
    // after it or the UI never shows it.
    if (error != null) {
      lastError = error;
      notifyListeners();
    }
  }

  /// Installs files and folders dropped onto the window, ignoring
  /// anything the current game can't use (readmes, screenshots...).
  Future<void> installDroppedPaths(List<String> paths) async {
    final accepted = {
      ..._adapter.modFileExtensions,
      ...archiveFileExtensions,
    };
    final sources = <FileSystemEntity>[];
    for (final path in paths) {
      if (await FileSystemEntity.isDirectory(path)) {
        sources.add(Directory(path));
      } else if (accepted.contains(p.extension(path).toLowerCase())) {
        sources.add(File(path));
      }
    }
    if (sources.isEmpty) {
      playSound(UiSound.alert);
      analytics.capture('mod_drop_rejected',
          {'game': _adapter.game.id, 'dropped': paths.length});
      return;
    }
    await installFiles(sources, method: 'drop');
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
      lastError = e.toString();
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
    try {
      await _adapter.createModsDirectory(path);
      playSound(UiSound.install);
      analytics.capture('mods_folder_created', {'game': _adapter.game.id});
    } catch (e, stack) {
      lastError = e.toString();
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
    _rescanConflicts();
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

  void openAnnouncementUrl() {
    final url = announcement?['url'];
    if (url is! String || !url.startsWith('https://')) return;
    analytics.capture(
        'announcement_clicked', {'announcement': announcement?['id']});
    openUrl(Uri.parse(url));
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
