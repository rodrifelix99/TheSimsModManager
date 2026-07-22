import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../core/conflicts.dart';
import '../core/game_adapter.dart';
import '../core/game_registry.dart';
import '../core/mod.dart';
import '../core/mod_name.dart';
import '../core/package_insight.dart';
import '../services/disk_space.dart';
import '../services/settings_store.dart';
import '../services/sfx.dart';

enum AppScreen { library, detail, settings }

/// All UI state and actions. Views are dumb: they render this and call
/// its methods. Talks only to [GameRegistry]/[GameAdapter]/[Mod] plus the
/// settings store — never to a concrete game.
class AppController extends ChangeNotifier {
  AppController({required this.registry, required this.settings, Sfx? sfx})
      : _sfx = sfx ?? Sfx(),
        _adapter = registry.byGameId('sims4') ?? registry.adapters.first;

  final GameRegistry registry;
  final SettingsStore settings;
  final Sfx _sfx;

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
  /// localized names) — shown when the default guess fails or as choices.
  List<Directory> candidateDirs = const [];

  /// Where the mods folder is *supposed* to live, for the "create it"
  /// offer when nothing exists yet.
  String? defaultPath;

  /// The game's own folder when detected — even without a mods folder
  /// inside — so the setup screen can say "mods folder missing" instead
  /// of "game not found".
  Directory? gameFolder;

  /// Sidebar mod counts per game id (null = folder not found).
  final Map<String, int?> modCounts = {};

  /// Combined mod file size per game id, for the all-games storage total.
  final Map<String, int> modSizes = {};

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

  int categoryCount(String cat) => cat == 'All'
      ? mods.length
      : mods.where((m) => m.category == cat).length;

  /// Top-level subfolder of the mods directory holding [mod], or `null`
  /// when the file sits directly in the mods folder.
  String? folderOf(Mod mod) {
    final root = modsDir?.path;
    if (root == null) return null;
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
  /// position. Only the folder chips rearrange — category chips and every
  /// other filter keep their order. Remembered per game.
  Future<void> reorderFolder(String moved, String target) async {
    final order = folders.toList();
    final from = order.indexOf(moved);
    final to = order.indexOf(target);
    if (from < 0 || to < 0 || from == to) return;
    playSound(UiSound.click);
    order.removeAt(from);
    order.insert(to, moved);
    await settings.setFolderOrder(_adapter.game.id, order);
    notifyListeners();
  }

  int get enabledCount => mods.where((m) => m.isEnabled).length;
  int get conflictCount =>
      mods.where((m) => conflictPaths.contains(m.path)).length;
  int get totalSizeBytes =>
      mods.fold(0, (sum, m) => sum + (m.sizeBytes ?? 0));

  /// Combined size of every game's mods, for the sidebar storage card.
  int get allGamesSizeBytes =>
      modSizes.values.fold(0, (sum, size) => sum + size);

  bool isConflicted(Mod mod) => conflictPaths.contains(mod.path);

  /// Why [mod] is flagged: the other enabled mods sharing its file name
  /// (case-insensitive), matching [findConflicts]'s heuristic. Empty when
  /// the mod isn't conflicted.
  List<Mod> conflictingWith(Mod mod) {
    if (!conflictPaths.contains(mod.path)) return const [];
    final name = p.basename(mod.name).toLowerCase();
    return [
      for (final other in mods)
        if (other.path != mod.path &&
            other.isEnabled &&
            p.basename(other.name).toLowerCase() == name)
          other,
    ];
  }

  /// Narrows the library to conflicting mods, or back to all of them.
  /// No-op when there's nothing to narrow to.
  void toggleConflictsOnly() {
    if (!conflictsOnly && conflictCount == 0) return;
    playSound(UiSound.cycle);
    conflictsOnly = !conflictsOnly;
    notifyListeners();
  }

  /// Re-runs the conflict scan; releases the conflicts-only filter when
  /// nothing is flagged anymore, so the library never sticks on an
  /// inexplicably empty list.
  void _rescanConflicts() {
    conflictPaths = settings.warnConflicts ? findConflicts(mods) : const {};
    if (conflictPaths.isEmpty) conflictsOnly = false;
  }

  /// Per-file scan results (embedded artwork + content summary). Keyed by
  /// enabled-name path + size + mtime so a replaced file is re-scanned,
  /// while a plain enable/disable rename keeps its cached entry.
  final Map<String, PackageInsight> _insights = {};

  /// Bulk-scan progress for the loading screen: (inspected, total).
  /// Null when no scan is running.
  (int, int)? scanProgress;

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
  Future<void> _scanNewMods() async {
    final missing = [
      for (final mod in mods)
        if (!_insights.containsKey(_insightKey(mod))) mod,
    ];
    if (missing.isEmpty) return;
    scanProgress = (0, missing.length);
    notifyListeners();
    try {
      final found = await _adapter.inspectMods(missing,
          onProgress: (done, total) {
        scanProgress = (done, total);
        notifyListeners();
      });
      for (final mod in missing) {
        final insight = found[mod.path];
        if (insight != null) _insights[_insightKey(mod)] = insight;
      }
    } finally {
      scanProgress = null;
    }
  }

  /// Plays [sound] unless UI sounds are switched off in Settings.
  /// Fire-and-forget: playback never blocks or fails an action.
  void playSound(UiSound sound) {
    if (!settings.soundEffects) return;
    _sfx.play(sound);
  }

  Future<void> init() async {
    await refresh();
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
      modCounts[_adapter.game.id] = dir == null ? null : mods.length;
      modSizes[_adapter.game.id] = totalSizeBytes;
      // Not awaited: shells out to the OS, and the library shouldn't
      // wait on it — the card fills in when the answer arrives.
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
    if (screen != AppScreen.settings) playSound(UiSound.help);
    screen = AppScreen.settings;
    notifyListeners();
  }

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  void setCategory(String value) {
    if (value != category) playSound(UiSound.cycle);
    category = value;
    notifyListeners();
  }

  void setFolder(String value) {
    if (value != folder) playSound(UiSound.cycle);
    folder = value;
    notifyListeners();
  }

  Future<void> setListView(bool value) async {
    if (value != settings.listView) playSound(UiSound.cycle);
    await settings.setListView(value);
    notifyListeners();
  }

  Future<void> toggleMod(Mod mod) async {
    try {
      final updated = await _adapter.setEnabled(mod, enabled: !mod.isEnabled);
      playSound(updated.isEnabled ? UiSound.toggleOn : UiSound.toggleOff);
      mods = [for (final m in mods) m.path == mod.path ? updated : m];
      if (_selectedModPath == mod.path) _selectedModPath = updated.path;
      _rescanConflicts();
      modCounts[_adapter.game.id] = mods.length;
      notifyListeners();
    } catch (e) {
      lastError = e.toString();
      playSound(UiSound.error);
      await refresh();
    }
  }

  Future<void> removeMod(Mod mod) async {
    try {
      await _adapter.removeMod(mod);
      playSound(UiSound.uninstall);
    } catch (e) {
      lastError = e.toString();
      playSound(UiSound.error);
    }
    if (_selectedModPath == mod.path) {
      _selectedModPath = null;
      screen = AppScreen.library;
    }
    await refresh();
  }

  Future<void> installFiles(List<File> sources) async {
    final dir = modsDir;
    if (dir == null) return;
    try {
      for (final source in sources) {
        await _adapter.installMod(dir, source);
      }
      playSound(UiSound.install);
    } catch (e) {
      lastError = e.toString();
      playSound(UiSound.error);
    }
    await refresh();
  }

  /// Points the current game at a user-chosen mods folder.
  Future<void> setFolderOverride(String path) async {
    playSound(UiSound.select);
    await settings.setModsPathOverride(_adapter.game.id, path);
    await refresh();
  }

  /// Back to auto-detection for the current game.
  Future<void> clearFolderOverride() async {
    playSound(UiSound.click);
    await settings.setModsPathOverride(_adapter.game.id, null);
    await refresh();
  }

  /// Creates the game's default mods folder (with any scaffolding the
  /// game needs, e.g. Sims 3's Resource.cfg) and starts using it.
  Future<void> createDefaultFolder() async {
    final path = defaultPath;
    if (path == null) return;
    try {
      await _adapter.createModsDirectory(path);
      playSound(UiSound.install);
    } catch (e) {
      lastError = e.toString();
      playSound(UiSound.error);
    }
    await refresh();
  }

  Future<void> setPref(Future<void> Function() write, {UiSound? sound}) async {
    await write();
    // Played after the write so the sound-effects toggle gates itself:
    // switching sounds on confirms audibly, switching off is silent.
    if (sound != null) playSound(sound);
    // Conflict scanning and visibility react immediately.
    _rescanConflicts();
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
