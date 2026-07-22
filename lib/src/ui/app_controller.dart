import 'dart:io';

import 'package:flutter/foundation.dart';

import '../core/conflicts.dart';
import '../core/game_adapter.dart';
import '../core/game_registry.dart';
import '../core/mod.dart';
import '../core/mod_name.dart';
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
  String? _selectedModPath;

  /// Resolved mods folder for the current game (override wins), or null
  /// when the game/folder couldn't be located.
  Directory? modsDir;

  /// Whether [modsDir] came from the user's settings override.
  bool usingOverride = false;

  List<Mod> mods = const [];
  Set<String> conflictPaths = const {};

  /// Alternate mods folders found on this machine (multiple installs,
  /// localized names) — shown when the default guess fails or as choices.
  List<Directory> candidateDirs = const [];

  /// Where the mods folder is *supposed* to live, for the "create it"
  /// offer when nothing exists yet.
  String? defaultPath;

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

  /// Mods after search/category/visibility filters.
  List<Mod> get filteredMods {
    final q = query.trim().toLowerCase();
    return [
      for (final mod in mods)
        if ((category == 'All' || mod.category == category) &&
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

  int get enabledCount => mods.where((m) => m.isEnabled).length;
  int get conflictCount =>
      mods.where((m) => conflictPaths.contains(m.path)).length;
  int get totalSizeBytes =>
      mods.fold(0, (sum, m) => sum + (m.sizeBytes ?? 0));

  /// Combined size of every game's mods, for the sidebar storage card.
  int get allGamesSizeBytes =>
      modSizes.values.fold(0, (sum, size) => sum + size);

  bool isConflicted(Mod mod) => conflictPaths.contains(mod.path);

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
    playSound(UiSound.select);
    _adapter = next;
    screen = AppScreen.library;
    query = '';
    category = 'All';
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
      conflictPaths =
          settings.warnConflicts ? findConflicts(mods) : const {};
      candidateDirs = await _adapter.findModsDirectoryCandidates();
      defaultPath = await _adapter.defaultModsPath();
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
      conflictPaths = settings.warnConflicts ? findConflicts(mods) : const {};
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
    conflictPaths = settings.warnConflicts ? findConflicts(mods) : const {};
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
