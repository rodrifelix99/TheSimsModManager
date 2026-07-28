import 'package:flutter/foundation.dart' show kDebugMode;
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

  /// Language the user picked in Settings as a bare language subtag
  /// ('de', 'pt', ...), or `null` to follow the operating system.
  String? get localeCode => _prefs.getString('localeCode');
  Future<void> setLocaleCode(String? code) async {
    if (code == null) {
      await _prefs.remove('localeCode');
    } else {
      await _prefs.setString('localeCode', code);
    }
  }

  /// Theme the user picked in Settings - 'light' or 'dark', or `null` to
  /// follow the operating system.
  String? get themeModeName => _prefs.getString('themeMode');
  Future<void> setThemeModeName(String? name) async {
    if (name == null) {
      await _prefs.remove('themeMode');
    } else {
      await _prefs.setString('themeMode', name);
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

  /// Library layout: 'grid' cards, 'list' rows, or 'folders' (rows under
  /// a header per subfolder). Falls back to the boolean this used to be,
  /// so an install that already picked a side keeps it.
  String get libraryLayout =>
      _prefs.getString('libraryLayout') ??
      ((_prefs.getBool('listView') ?? false) ? 'list' : 'grid');
  Future<void> setLibraryLayout(String value) =>
      _prefs.setString('libraryLayout', value);

  static String _collapsedFoldersKey(String gameId) =>
      'collapsedFolders.$gameId';

  /// Folder sections the user rolled up in the folder view. Per game,
  /// like the folder arrangement, since the folders themselves are.
  List<String> collapsedFolders(String gameId) =>
      _prefs.getStringList(_collapsedFoldersKey(gameId)) ?? const [];

  Future<void> setCollapsedFolders(String gameId, List<String> folders) =>
      _prefs.setStringList(_collapsedFoldersKey(gameId), folders);

  /// Look inside mod files for embedded artwork and content summaries
  /// while the library loads (the slow part of the loading screen).
  bool get scanArtwork => _prefs.getBool('scanArtwork') ?? true;
  Future<void> setScanArtwork(bool value) =>
      _prefs.setBool('scanArtwork', value);

  bool get soundEffects => _prefs.getBool('soundEffects') ?? true;
  Future<void> setSoundEffects(bool value) =>
      _prefs.setBool('soundEffects', value);

  /// Fills the library with invented mods for screenshots. Reads false in
  /// a release build whatever is stored, so a debug run of the app can't
  /// leave the shipped one showing mods nobody has.
  bool get demoLibrary =>
      kDebugMode && (_prefs.getBool('demoLibrary') ?? false);
  Future<void> setDemoLibrary(bool value) =>
      _prefs.setBool('demoLibrary', value);

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

  /// Raw JSON of the last successful advisory download, so the warnings
  /// are there on the first frame and survive a launch with no network.
  String? get advisoriesJson => _prefs.getString('advisories.cache');
  Future<void> setAdvisoriesJson(String value) =>
      _prefs.setString('advisories.cache', value);

  /// When that download happened, so launches don't each re-fetch a file
  /// that changes a few times a month.
  DateTime? get advisoriesFetchedAt {
    final millis = _prefs.getInt('advisories.fetchedAt');
    return millis == null ? null : DateTime.fromMillisecondsSinceEpoch(millis);
  }

  Future<void> setAdvisoriesFetchedAt(DateTime when) =>
      _prefs.setInt('advisories.fetchedAt', when.millisecondsSinceEpoch);

  /// What The Exchange has installed on this machine, as JSON: listing id
  /// -> the version installed and the files it put in the mods folder.
  /// Persisted because it is the only record connecting a file on disk to
  /// the listing it came from; without it a restart forgets that a mod
  /// came from the shop at all, and no update could ever be offered.
  String? get shopInstallsJson => _prefs.getString('shop.installs');
  Future<void> setShopInstallsJson(String value) =>
      _prefs.setString('shop.installs', value);

  /// Mods the app installed into folders the game also keeps its own
  /// files in, as JSON: game id -> paths relative to that game's mods
  /// folder. See `core/placed_mods.dart` for why those folders cannot
  /// simply be listed.
  String? get placedModsJson => _prefs.getString('placedMods');
  Future<void> setPlacedModsJson(String value) =>
      _prefs.setString('placedMods', value);

  /// Whether an install asks where to put things, for the games that read
  /// mods from more than one folder. On by default: the app's guess is
  /// right most of the time but wrong in ways only the user can see (a
  /// skin that is meant to stay out of Create-a-Sim looks exactly like
  /// one that isn't).
  bool get askWhereToInstall => _prefs.getBool('askWhereToInstall') ?? true;
  Future<void> setAskWhereToInstall(bool value) =>
      _prefs.setBool('askWhereToInstall', value);

  List<String> get dismissedAnnouncements =>
      _prefs.getStringList('dismissedAnnouncements') ?? const [];
  Future<void> addDismissedAnnouncement(String id) =>
      _prefs.setStringList(
          'dismissedAnnouncements', {...dismissedAnnouncements, id}.toList());
}
