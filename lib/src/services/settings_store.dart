import 'dart:io' show Platform;

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

  /// Whether the first-run walkthrough has already been through.
  ///
  /// Absent means it hasn't - except under `flutter test`, where absent
  /// reads as done. Every widget test in the suite pumps the app against
  /// empty preferences, and a walkthrough covering the window on the
  /// first frame would be the answer to all of them; a test that wants
  /// the walkthrough asks for it by storing `false`, which is a thing
  /// only a test ever does (the app writes true and never writes false
  /// except when the user asks to see it again, and that path sets it
  /// back to true at the end).
  bool get onboardingDone =>
      _prefs.getBool('onboardingDone') ??
      Platform.environment.containsKey('FLUTTER_TEST');

  Future<void> setOnboardingDone(bool value) =>
      _prefs.setBool('onboardingDone', value);

  /// The game the app opens on, picked in the walkthrough or in Settings.
  /// Null is the app's own choice - see `AppController`'s constructor.
  String? get defaultGameId => _prefs.getString('defaultGame');

  Future<void> setDefaultGameId(String? gameId) async {
    if (gameId == null) {
      await _prefs.remove('defaultGame');
    } else {
      await _prefs.setString('defaultGame', gameId);
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

  /// The kinds of clash the user told the scan to stop reporting, as the
  /// `ConflictReason` names - this class knows nothing about mods, the
  /// same bargain [disabledSuffix] makes.
  ///
  /// The muted ones rather than the wanted ones, so a signal added later
  /// starts on for everybody instead of off for everyone who ever opened
  /// this row.
  Set<String> get mutedConflictKinds =>
      (_prefs.getStringList('mutedConflictKinds') ?? const <String>[]).toSet();

  Future<void> setMutedConflictKinds(Set<String> kinds) =>
      _prefs.setStringList('mutedConflictKinds', kinds.toList()..sort());

  bool get confirmDelete => _prefs.getBool('confirmDelete') ?? true;
  Future<void> setConfirmDelete(bool value) =>
      _prefs.setBool('confirmDelete', value);

  bool get showDisabled => _prefs.getBool('showDisabled') ?? true;
  Future<void> setShowDisabled(bool value) =>
      _prefs.setBool('showDisabled', value);

  /// The marker written at the end of a mod file's name when it is
  /// switched off, or `null` for the app's own. Stored as typed and
  /// checked where it is applied: this class knows nothing about mods.
  String? get disabledSuffix => _prefs.getString('disabledSuffix');
  Future<void> setDisabledSuffix(String? value) async {
    if (value == null) {
      await _prefs.remove('disabledSuffix');
    } else {
      await _prefs.setString('disabledSuffix', value);
    }
  }

  /// How the library orders the mods a filter left standing: 'name',
  /// 'recent' or 'size'.
  String get librarySort => _prefs.getString('librarySort') ?? 'name';
  Future<void> setLibrarySort(String value) =>
      _prefs.setString('librarySort', value);

  /// Whether the disabled mods sink below the enabled ones, keeping
  /// [librarySort] within each half.
  bool get disabledLast => _prefs.getBool('disabledLast') ?? false;
  Future<void> setDisabledLast(bool value) =>
      _prefs.setBool('disabledLast', value);

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
  ///
  /// Only sections that would otherwise be open: a subfolder starts
  /// closed, so the ones the user closed by hand are the top-level
  /// sections and the root. See [expandedFolders] for the other half.
  List<String> collapsedFolders(String gameId) =>
      _prefs.getStringList(_collapsedFoldersKey(gameId)) ?? const [];

  Future<void> setCollapsedFolders(String gameId, List<String> folders) =>
      _prefs.setStringList(_collapsedFoldersKey(gameId), folders);

  static String _expandedFoldersKey(String gameId) =>
      'expandedFolders.$gameId';

  /// Folder sections the user opened that start closed - the subfolders.
  ///
  /// Two lists rather than one holding "not the default", because that
  /// single list would read every section an existing install had
  /// already rolled up as one to open instead, and silently unfold the
  /// libraries this was written to tidy.
  List<String> expandedFolders(String gameId) =>
      _prefs.getStringList(_expandedFoldersKey(gameId)) ?? const [];

  Future<void> setExpandedFolders(String gameId, List<String> folders) =>
      _prefs.setStringList(_expandedFoldersKey(gameId), folders);

  static String _madeFoldersKey(String gameId) => 'madeFolders.$gameId';

  /// Folders the user made in the app. Everything else the library knows
  /// about folders it works out from where the mods are, which is why
  /// these have to be written down: a folder made a moment ago holds
  /// nothing, and would go off screen before anything could be put in
  /// it. Dropped again once the folder isn't on disk any more.
  List<String> madeFolders(String gameId) =>
      _prefs.getStringList(_madeFoldersKey(gameId)) ?? const [];

  Future<void> setMadeFolders(String gameId, List<String> folders) =>
      folders.isEmpty
          ? _prefs.remove(_madeFoldersKey(gameId))
          : _prefs.setStringList(_madeFoldersKey(gameId), folders);

  /// Whether a folder chip stands for everything below it or only for
  /// the files sitting in that folder itself.
  ///
  /// On by default, which is what it has always done: someone who keeps
  /// everything under `cc/defaults` still thinks of `cc` as holding it.
  /// Off is for the opposite habit - `cc` and `cc/defaults` as two
  /// separate shelves, which is how the user who asked for this reads
  /// their own library.
  bool get folderIncludesSubfolders =>
      _prefs.getBool('folderIncludesSubfolders') ?? true;

  Future<void> setFolderIncludesSubfolders(bool value) =>
      _prefs.setBool('folderIncludesSubfolders', value);

  static String _shopFolderKey(String gameId) => 'shopFolder.$gameId';

  /// Which subfolder of a game's mods folder an install from The
  /// Exchange lands in by default.
  ///
  /// Absent and empty are different answers on purpose: absent means
  /// nobody has said, and the install follows the selected folder chip
  /// the way it always did, while the empty string is someone choosing
  /// the mods folder itself and meaning it.
  String? shopFolder(String gameId) => _prefs.getString(_shopFolderKey(gameId));

  Future<void> setShopFolder(String gameId, String folder) =>
      _prefs.setString(_shopFolderKey(gameId), folder);

  /// Look inside mod files for embedded artwork and content summaries
  /// while the library loads (the slow part of the loading screen).
  bool get scanArtwork => _prefs.getBool('scanArtwork') ?? true;
  Future<void> setScanArtwork(bool value) =>
      _prefs.setBool('scanArtwork', value);

  /// Whether to offer the pack switches for the games where turning one
  /// off is known to work but has not been proven safe by anybody -
  /// today The Sims 2, whose neighborhoods are famous for minding.
  /// Off by default: those packs still list either way, and a library
  /// that shows what is installed is worth having without the risk.
  bool get experimentalPackToggles =>
      _prefs.getBool('experimentalPackToggles') ?? false;
  Future<void> setExperimentalPackToggles(bool value) =>
      _prefs.setBool('experimentalPackToggles', value);

  bool get soundEffects => _prefs.getBool('soundEffects') ?? true;
  Future<void> setSoundEffects(bool value) =>
      _prefs.setBool('soundEffects', value);

  /// Whether the plumbob in the corner offers facts about the game on
  /// screen. On by default: it is the one thing here that is purely for
  /// the fun of it, and something nobody ever finds is not much of one.
  bool get triviaBuddy => _prefs.getBool('triviaBuddy') ?? true;
  Future<void> setTriviaBuddy(bool value) =>
      _prefs.setBool('triviaBuddy', value);

  /// What the last reachability probe found. Stored so the first frame of
  /// the next launch already knows, rather than offering The Exchange for
  /// the second the probe takes and then taking it away. All default to
  /// reachable, so a machine that has never probed keeps everything.
  bool get shopReachable => _prefs.getBool('reachShop') ?? true;
  Future<void> setShopReachable(bool value) =>
      _prefs.setBool('reachShop', value);

  bool get siteReachable => _prefs.getBool('reachSite') ?? true;
  Future<void> setSiteReachable(bool value) =>
      _prefs.setBool('reachSite', value);

  bool get downloadsReachable => _prefs.getBool('reachDownloads') ?? true;
  Future<void> setDownloadsReachable(bool value) =>
      _prefs.setBool('reachDownloads', value);

  /// The download mirror, which is the one of these that has three
  /// answers: null means no mirror was configured when the probe last
  /// ran, so it has never been asked. Kept apart from "unreachable" so a
  /// launch that has not yet asked cannot read as a refusal.
  bool? get mirrorReachable => _prefs.getBool('reachMirror');
  Future<void> setMirrorReachable(bool? value) async {
    if (value == null) {
      await _prefs.remove('reachMirror');
    } else {
      await _prefs.setBool('reachMirror', value);
    }
  }

  /// Which way the last update download was sent, `github` or `mirror`.
  /// Written when the button is pressed and read back by the next
  /// launch's update detection: the app opens a browser rather than
  /// fetching the file itself, so whether a download worked is only ever
  /// answerable afterwards, by the update having happened.
  String? get lastUpdatePath => _prefs.getString('update.path');
  Future<void> setLastUpdatePath(String value) =>
      _prefs.setString('update.path', value);
  Future<void> clearLastUpdatePath() => _prefs.remove('update.path');

  /// Forces what the reachability probe "finds", by scenario id. Reads
  /// null in a release build whatever is stored - the same bargain
  /// [demoLibrary] makes, and for a sharper reason: the two builds share
  /// these preferences, so a debug run left on "everything blocked"
  /// could otherwise open the shipped app with The Exchange missing.
  String? get debugReachability =>
      kDebugMode ? _prefs.getString('debugReachability') : null;
  Future<void> setDebugReachability(String? value) async {
    if (value == null) {
      await _prefs.remove('debugReachability');
    } else {
      await _prefs.setString('debugReachability', value);
    }
  }

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

  /// Clashes the user told the app to stop reporting, as JSON: game id ->
  /// the pairs of mods, each path relative to that game's mods folder.
  /// See `core/ignored_conflicts.dart` for why a pair rather than a mod.
  String? get ignoredConflictsJson => _prefs.getString('ignoredConflicts');
  Future<void> setIgnoredConflictsJson(String value) =>
      _prefs.setString('ignoredConflicts', value);

  /// The labels the player has put on their own mods, as JSON: game id ->
  /// mod path (relative to that game's mods folder) -> the tags on it.
  /// See `core/mod_tags.dart`.
  String? get modTagsJson => _prefs.getString('modTags');
  Future<void> setModTagsJson(String value) =>
      _prefs.setString('modTags', value);

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
