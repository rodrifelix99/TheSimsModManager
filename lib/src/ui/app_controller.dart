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
  })  : _sfx = sfx ?? Sfx(),
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
  /// Event properties never include mod names or file paths — only
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

  /// Whether [modsDir] came from the user's settings override.
  bool usingOverride = false;

  List<Mod> mods = const [];
  Set<String> conflictPaths = const {};

  /// When set, [filteredMods] narrows to the mods flagged by the conflict
  /// scan. Toggled by tapping the Conflicts stat in the library header.
  bool conflictsOnly = false;

  /// Alternate mods folders found on this machine (multiple installs,
  /// localized names), shown when the default guess fails or as choices.
  List<Directory> candidateDirs = const [];

  /// Where the mods folder is *supposed* to live, for the "create it"
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

  Mod? get selectedMod {
    final path = _selectedModPath;
    if (path == null) return null;
    for (final mod in mods) {
      if (mod.path == path) return mod;
    }
    return null;
  }

  /// Mods after search/category/folder/visibility filters.
  List<Mod> get filteredMods {
    final q = query.trim().toLowerCase();
    return [
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
  }

  /// Category labels present in the current library, 'All' first.
  List<String> get categories {
    final seen = <String>{for (final mod in mods) mod.category};
    final sorted = seen.toList()..sort();
    return ['All', ...sorted];
  }

  int categoryCount(String cat) =>
      cat == 'All' ? mods.length : mods.where((m) => m.category == cat).length;

  /// Top-level subfolder of the mods directory holding [mod], or `null`
  /// when the file sits directly in the mods folder. Mods living outside
  /// the mods directory (Sims 1 routes skins/walls/floors into sibling
  /// game folders) group under their own folder's name instead.
  String? folderOf(Mod mod) {
    final root = modsDir?.path;
    if (root == null) return null;
    if (!p.isWithin(root, mod.path)) return p.basename(p.dirname(mod.path));
    final parts = p.split(p.relative(mod.path, from: root));
    return parts.length > 1 ? parts.first : null;
  }

  /// Top-level subfolder names present in the current library, for the
  /// folder filter chips. Empty when every mod sits directly in the root.
  /// Follows the user's drag-and-drop arrangement when one is saved;
  /// folders it doesn't mention (new on disk) append alphabetically.
  List<String> get folders {
    final seen = <String>{};
    for (final mod in mods) {
      final f = folderOf(mod);
      if (f != null) seen.add(f);
    }
    final sorted = seen.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final saved = settings.folderOrder(_adapter.game.id);
    if (saved == null) return sorted;
    final ordered = <String>[
      for (final f in saved)
        if (seen.contains(f)) f,
    ];
    final placed = ordered.toSet();
    return [...ordered, ...sorted.where((f) => !placed.contains(f))];
  }

  int folderCount(String f) => mods.where((m) => folderOf(m) == f).length;

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

  int get enabledCount => mods.where((m) => m.isEnabled).length;
  int get conflictCount =>
      mods.where((m) => conflictPaths.contains(m.path)).length;
  int get totalSizeBytes => mods.fold(0, (sum, m) => sum + (m.sizeBytes ?? 0));

  /// Combined size of every game's mods, for the sidebar storage card.
  int get allGamesSizeBytes =>
      modSizes.values.fold(0, (sum, size) => sum + size);

  bool isConflicted(Mod mod) => conflictPaths.contains(mod.path);

  /// Why [mod] is flagged: the other enabled mods sharing its file name
  /// (case-insensitive) or looking like another version of it, matching
  /// [findConflicts]'s heuristics. Empty when the mod isn't conflicted.
  List<Mod> conflictingWith(Mod mod) {
    if (!conflictPaths.contains(mod.path)) return const [];
    final name = p.basename(mod.name).toLowerCase();
    final identity = parseModName(mod.name).identity;
    return [
      for (final other in mods)
        if (other.path != mod.path &&
            other.isEnabled &&
            (p.basename(other.name).toLowerCase() == name ||
                (conflictPaths.contains(other.path) &&
                    parseModName(other.name).identity == identity)))
          other,
    ];
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
  void _rescanConflicts() {
    final scan = settings.warnConflicts &&
        analytics.isEnabled('conflict-detection', fallback: true);
    conflictPaths = scan ? findConflicts(mods) : const {};
    if (conflictPaths.isEmpty) conflictsOnly = false;
  }

  /// Per-file scan results (embedded artwork + content summary). Keyed by
  /// enabled-name path + size + mtime so a replaced file is re-scanned,
  /// while a plain enable/disable rename keeps its cached entry. A null
  /// value means the file was scanned and yielded nothing — cached too,
  /// so revisiting a game never re-scans files known to be empty.
  final Map<String, PackageInsight?> _insights = {};

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
    scanProgress = (0, missing.length);
    notifyListeners();
    final byPath = {for (final mod in missing) mod.path: mod};
    try {
      final found = await _adapter.inspectMods(missing,
          onProgress: (done, total) {
            scanProgress = (done, total);
            notifyListeners();
          },
          onFound: (found) {
            // Cache mid-scan so the loading screen's floating backdrop can
            // show artwork as it's discovered.
            for (final entry in found.entries) {
              final mod = byPath[entry.key];
              if (mod != null) _insights[_insightKey(mod)] = entry.value;
            }
          },
          isCancelled: () => _skipScan);
      for (final mod in missing) {
        final insight = found[mod.path];
        if (insight != null) {
          _insights[_insightKey(mod)] = insight;
        } else if (!_skipScan) {
          // Nothing usable inside (script mod, .far, corrupt file) — a
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
        });
      }
    } finally {
      scanProgress = null;
    }
  }

  /// Feed for the loading screen's floating backdrop: every mod's
  /// cleaned-up title plus whatever artwork the scan has cached so far
  /// (more appears as batches finish).
  List<(String, Uint8List?)> get scanShowcase => [
        for (final mod in mods) (humanizeModName(mod.name), thumbnailOf(mod)),
      ];

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

  /// Opens the newer release's download page. No-op when up to date.
  void openReleasePage() {
    final update = availableUpdate;
    if (update == null) return;
    analytics.capture(
        'update_download_clicked', {'latest_version': update.version});
    openUrl(Uri.parse(update.url));
  }

  /// Opens a new bug report with version/OS/current game prefilled.
  void reportBug() {
    analytics.capture('feedback_opened', {'type': 'bug_report'});
    openUrl(bugReportUrl(gameName: _adapter.game.name));
  }

  /// Opens a new feature request with the current game prefilled.
  void suggestFeature() {
    analytics.capture('feedback_opened', {'type': 'feature_request'});
    openUrl(featureRequestUrl(gameName: _adapter.game.name));
  }

  /// Opens the project wiki (user guide & FAQ).
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
  /// Counts and sizes only — never mod names or paths.
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
      mods = dir == null ? const [] : await _adapter.listMods(dir);
      // The filtered folder may have been renamed/emptied on disk.
      if (folder != 'All' && !folders.contains(folder)) folder = 'All';
      _rescanConflicts();
      // Artwork/content scan happens here, under the loading screen,
      // so the library renders instantly from cache afterwards.
      await _scanNewMods();
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
      mods = [for (final m in mods) m.path == mod.path ? updated : m];
      if (_selectedModPath == mod.path) _selectedModPath = updated.path;
      _rescanConflicts();
      modCounts[_adapter.game.id] = mods.length;
      notifyListeners();
    } catch (e, stack) {
      final error = e.toString();
      analytics.captureException(e, stack, mechanism: 'toggleMod');
      analytics.capture('mod_action_failed',
          {'action': 'toggle', 'game': _adapter.game.id});
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
    try {
      for (final source in sources) {
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
      error = e.toString();
      analytics.captureException(e, stack, mechanism: 'installFiles');
      analytics.capture('mod_install_failed',
          {'game': _adapter.game.id, 'method': method});
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
  /// anything the current game can't use (readmes, screenshots…).
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

  /// Points the current game at a user-chosen mods folder.
  Future<void> setFolderOverride(String path) async {
    playSound(UiSound.select);
    analytics.capture('mods_folder_overridden', {'game': _adapter.game.id});
    await settings.setModsPathOverride(_adapter.game.id, path);
    await refresh();
  }

  /// Back to auto-detection for the current game.
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

  /// Follows the announcement's link, when it has one.
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
