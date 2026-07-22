import 'package:shared_preferences/shared_preferences.dart';

/// Persisted user preferences: per-game mods-folder overrides and the
/// mod-management toggles from Settings. Pure key-value storage — no
/// game knowledge beyond the opaque game id.
class SettingsStore {
  SettingsStore(this._prefs);

  static Future<SettingsStore> load() async =>
      SettingsStore(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  static String _pathKey(String gameId) => 'modsPath.$gameId';

  /// User-chosen mods folder for [gameId], or `null` to auto-detect.
  String? modsPathOverride(String gameId) => _prefs.getString(_pathKey(gameId));

  Future<void> setModsPathOverride(String gameId, String? path) async {
    if (path == null) {
      await _prefs.remove(_pathKey(gameId));
    } else {
      await _prefs.setString(_pathKey(gameId), path);
    }
  }

  static String _folderOrderKey(String gameId) => 'folderOrder.$gameId';

  /// User-arranged order of the folder filter chips for [gameId], or
  /// `null` when the user never rearranged them (alphabetical).
  List<String>? folderOrder(String gameId) =>
      _prefs.getStringList(_folderOrderKey(gameId));

  Future<void> setFolderOrder(String gameId, List<String>? order) async {
    if (order == null) {
      await _prefs.remove(_folderOrderKey(gameId));
    } else {
      await _prefs.setStringList(_folderOrderKey(gameId), order);
    }
  }

  /// Scan enabled mods for duplicate-name conflicts and badge them.
  bool get warnConflicts => _prefs.getBool('warnConflicts') ?? true;
  Future<void> setWarnConflicts(bool value) =>
      _prefs.setBool('warnConflicts', value);

  /// Ask before deleting a mod file from disk.
  bool get confirmDelete => _prefs.getBool('confirmDelete') ?? true;
  Future<void> setConfirmDelete(bool value) =>
      _prefs.setBool('confirmDelete', value);

  /// Show disabled mods in the library (off = enabled mods only).
  bool get showDisabled => _prefs.getBool('showDisabled') ?? true;
  Future<void> setShowDisabled(bool value) =>
      _prefs.setBool('showDisabled', value);

  /// Library layout: `true` = list rows, `false` = grid cards.
  bool get listView => _prefs.getBool('listView') ?? false;
  Future<void> setListView(bool value) => _prefs.setBool('listView', value);

  /// Play the classic Sims UI sounds on clicks, toggles and alerts.
  bool get soundEffects => _prefs.getBool('soundEffects') ?? true;
  Future<void> setSoundEffects(bool value) =>
      _prefs.setBool('soundEffects', value);
}
