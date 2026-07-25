import 'package:shared_preferences/shared_preferences.dart';

/// Persisted user preferences: per-game mods-folder overrides and the
/// mod-management toggles from Settings. Pure key-value storage with no
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

  List<String>? folderOrder(String gameId) =>
      _prefs.getStringList(_folderOrderKey(gameId));

  Future<void> setFolderOrder(String gameId, List<String>? order) async {
    if (order == null) {
      await _prefs.remove(_folderOrderKey(gameId));
    } else {
      await _prefs.setStringList(_folderOrderKey(gameId), order);
    }
  }

  bool get warnConflicts => _prefs.getBool('warnConflicts') ?? true;
  Future<void> setWarnConflicts(bool value) =>
      _prefs.setBool('warnConflicts', value);

  bool get confirmDelete => _prefs.getBool('confirmDelete') ?? true;
  Future<void> setConfirmDelete(bool value) =>
      _prefs.setBool('confirmDelete', value);

  bool get showDisabled => _prefs.getBool('showDisabled') ?? true;
  Future<void> setShowDisabled(bool value) =>
      _prefs.setBool('showDisabled', value);

  /// Library layout: `true` = list rows, `false` = grid cards.
  bool get listView => _prefs.getBool('listView') ?? false;
  Future<void> setListView(bool value) => _prefs.setBool('listView', value);

  /// Look inside mod files for embedded artwork and content summaries
  /// while the library loads (the slow part of the loading screen).
  bool get scanArtwork => _prefs.getBool('scanArtwork') ?? true;
  Future<void> setScanArtwork(bool value) =>
      _prefs.setBool('scanArtwork', value);

  bool get soundEffects => _prefs.getBool('soundEffects') ?? true;
  Future<void> setSoundEffects(bool value) =>
      _prefs.setBool('soundEffects', value);

  bool get analyticsEnabled => _prefs.getBool('analyticsEnabled') ?? true;
  Future<void> setAnalyticsEnabled(bool value) =>
      _prefs.setBool('analyticsEnabled', value);

  /// Random anonymous id identifying this install to analytics; never
  /// derived from anything personal. Null until analytics first runs.
  String? get analyticsDistinctId => _prefs.getString('analytics.distinctId');
  Future<void> setAnalyticsDistinctId(String value) =>
      _prefs.setString('analytics.distinctId', value);

  /// App version seen on the previous launch; null on the very first run.
  /// Analytics compares it to the running version to tell installs from
  /// updates from plain launches.
  String? get lastRunVersion => _prefs.getString('analytics.lastRunVersion');
  Future<void> setLastRunVersion(String value) =>
      _prefs.setString('analytics.lastRunVersion', value);

  int get launchCount => _prefs.getInt('analytics.launchCount') ?? 0;
  Future<void> setLaunchCount(int value) =>
      _prefs.setInt('analytics.launchCount', value);

  /// Raw JSON of the last successful feature-flag fetch, so flags keep
  /// their last known values when the app starts offline.
  String? get cachedFlagsJson => _prefs.getString('analytics.flagsCache');
  Future<void> setCachedFlagsJson(String value) =>
      _prefs.setString('analytics.flagsCache', value);

  List<String> get dismissedAnnouncements =>
      _prefs.getStringList('dismissedAnnouncements') ?? const [];
  Future<void> addDismissedAnnouncement(String id) =>
      _prefs.setStringList(
          'dismissedAnnouncements', {...dismissedAnnouncements, id}.toList());
}
