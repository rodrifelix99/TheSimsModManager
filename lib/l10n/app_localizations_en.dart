// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class LEn extends L {
  LEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sims Mod Manager';

  @override
  String get brandTitle => 'Mod Manager';

  @override
  String get brandSubtitle => 'for The Sims';

  @override
  String get navLibrary => 'Library';

  @override
  String get navSettings => 'Settings';

  @override
  String get sidebarGames => 'GAMES';

  @override
  String sidebarNotInstalled(String detail) {
    return 'not installed · $detail';
  }

  @override
  String sidebarModCount(int count, String detail) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods',
      one: '1 mod',
    );
    return '$_temp0 · $detail';
  }

  @override
  String get updateAvailable => 'Update available';

  @override
  String updateClickToDownload(String version) {
    return 'v$version: click to download';
  }

  @override
  String get storage => 'Storage';

  @override
  String storageInMods(String size) {
    return '$size in mods';
  }

  @override
  String storageFreeOf(String free, String total) {
    return '$free free of $total';
  }

  @override
  String dropToInstall(String game) {
    return 'Drop to install into $game';
  }

  @override
  String get dropFolders => 'folders';

  @override
  String scanningMods(int done, int total) {
    return 'Looking inside mods for artwork and conflicts… $done of $total';
  }

  @override
  String get skip => 'Skip';

  @override
  String libraryTitle(String game) {
    return '$game Library';
  }

  @override
  String modsShown(int count, String era) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods shown',
      one: '1 mod shown',
    );
    return '$_temp0 · $era';
  }

  @override
  String get learnMore => 'Learn more';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get searchMods => 'Search mods…';

  @override
  String get install => 'Install';

  @override
  String filePickerModsLabel(String game) {
    return '$game mods';
  }

  @override
  String get statTotal => 'Total';

  @override
  String get statEnabled => 'Enabled';

  @override
  String get statDisabled => 'Disabled';

  @override
  String get statConflicts => 'Conflicts';

  @override
  String get conflictTooltipActive =>
      'Showing conflicting mods only. Click to show all mods again.';

  @override
  String get conflictTooltip =>
      'Enabled mods sharing a file name with another enabled mod, installed in more than one version, or overriding the same in-game resources. The game only keeps the copy it loads last — sometimes intentional (patch mods), often not.';

  @override
  String get conflictTooltipClickHint => 'Click to show only these mods.';

  @override
  String get filterAll => 'All';

  @override
  String get emptyFiltered => 'No mods match your filters';

  @override
  String get emptyNoMods => 'No mods yet';

  @override
  String get emptyFilteredHint =>
      'Try clearing the search or picking another filter.';

  @override
  String emptyNoModsHint(String path) {
    return 'This folder is being watched:\n$path';
  }

  @override
  String get openFolder => 'Open folder';

  @override
  String get conflictBadge => 'conflict';

  @override
  String modInFolder(String folder) {
    return 'in $folder';
  }

  @override
  String get modInModsFolder => 'in Mods folder';

  @override
  String setupFoundNoModsFolder(String game) {
    return '$game found, but no mods folder yet';
  }

  @override
  String setupNotFound(String game) {
    return '$game mods folder not found';
  }

  @override
  String get setupFoundNoModsFolderBody =>
      'The game\'s folder is on this computer; it just doesn\'t contain a mods folder yet. Create it below, or point at one manually.';

  @override
  String get setupNotFoundBody =>
      'The game may not be installed, may live somewhere unusual, or its mods folder may not exist yet.';

  @override
  String get foundOnThisComputer => 'FOUND ON THIS COMPUTER';

  @override
  String get chooseFolder => 'Choose folder…';

  @override
  String get createItForMe => 'Create it for me';

  @override
  String willBeCreatedAt(String path) {
    return 'Will be created at:\n$path';
  }

  @override
  String get checkAgain => 'Check again';

  @override
  String get useThis => 'Use this';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get showInFileManager => 'Show in file manager';

  @override
  String get uninstallMod => 'Uninstall mod';

  @override
  String uninstallConfirmTitle(String title) {
    return 'Uninstall $title?';
  }

  @override
  String uninstallConfirmBody(String path) {
    return 'The file will be deleted from disk:\n$path';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get uninstall => 'Uninstall';

  @override
  String conflictSameNameHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count other enabled mods have the same file name:',
      one: 'Another enabled mod has the same file name:',
    );
    return '$_temp0';
  }

  @override
  String conflictVersionHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count other enabled mods look like different versions of this mod:',
      one: 'Another enabled mod looks like a different version of this mod:',
    );
    return '$_temp0';
  }

  @override
  String conflictResourcesHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count other enabled mods override the same in-game resources:',
      one: 'Another enabled mod overrides the same in-game resources:',
    );
    return '$_temp0';
  }

  @override
  String sharedResources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count shared resources',
      one: '1 shared resource',
    );
    return '$_temp0';
  }

  @override
  String get conflictSameNameBody =>
      'Identical names usually mean the same mod is installed twice, or two creators\' packages clash. The game loads their overlapping resources in an unpredictable order: keep one and disable or remove the rest.';

  @override
  String get conflictVersionBody =>
      'Having several versions of a mod installed means the game loads their overlapping resources in an unpredictable order: keep the newest and disable or remove the rest.';

  @override
  String get conflictResourcesBody =>
      'These packages contain resources with the same identifiers, so the game only keeps the copy it loads last. That can be intentional — patch and override mods shadow another mod\'s resources on purpose — but for unrelated mods it means one of them silently stops working: keep the one you want and disable the rest.';

  @override
  String modInDirectory(String dir) {
    return 'in $dir';
  }

  @override
  String get factVersion => 'Version';

  @override
  String get factFormat => 'Format';

  @override
  String get factSize => 'Size';

  @override
  String get factType => 'Type';

  @override
  String get factModified => 'Modified';

  @override
  String get statusHeading => 'Status';

  @override
  String get statusEnabledBody =>
      'This mod is active: the game will load it on next launch.';

  @override
  String statusDisabledBody(String marker) {
    return 'This mod is disabled: the file is kept on disk with a \"$marker\" marker so the game skips it. Enable it any time; nothing is deleted.';
  }

  @override
  String get fileOnDisk => 'File on disk';

  @override
  String get insideThePackage => 'Inside the package';

  @override
  String resourcesTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resources total',
      one: '1 resource total',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionModManagement => 'MOD MANAGEMENT';

  @override
  String get sectionAppearance => 'APPEARANCE';

  @override
  String get sectionLanguage => 'LANGUAGE';

  @override
  String get sectionPrivacy => 'PRIVACY';

  @override
  String sectionModsFolder(String game) {
    return 'MODS FOLDER · $game';
  }

  @override
  String sectionGameCaches(String game) {
    return 'GAME CACHES · $game';
  }

  @override
  String get sectionFeedback => 'FEEDBACK';

  @override
  String get sectionAbout => 'ABOUT';

  @override
  String get prefWarnConflictsTitle => 'Warn about conflicts';

  @override
  String get prefWarnConflictsDesc =>
      'Badge enabled mods that duplicate a file name or override the same in-game resources as another mod';

  @override
  String get prefConfirmDeleteTitle => 'Confirm before uninstalling';

  @override
  String get prefConfirmDeleteDesc =>
      'Ask before a mod file is deleted from disk';

  @override
  String get prefShowDisabledTitle => 'Show disabled mods';

  @override
  String get prefShowDisabledDesc =>
      'Keep disabled mods visible in the library instead of hiding them';

  @override
  String get prefScanArtworkTitle => 'Scan inside mods';

  @override
  String get prefScanArtworkDesc =>
      'Look inside mod files while the library loads for embedded artwork, content details and mods that override the same resources';

  @override
  String get prefSoundEffectsTitle => 'UI sound effects';

  @override
  String get prefSoundEffectsDesc =>
      'Play the classic Sims interface sounds on clicks, toggles and alerts';

  @override
  String get prefAnalyticsTitle => 'Share anonymous usage data';

  @override
  String get prefAnalyticsDesc =>
      'Send anonymous usage statistics and crash reports to help improve the app. Never includes mod names, file paths or anything personal';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeDesc =>
      'Light or dark. “System” follows your computer\'s setting.';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageTitle => 'App language';

  @override
  String get languageDesc =>
      'Choose the language the app is shown in. “System” follows your computer\'s language.';

  @override
  String get languageSystem => 'System';

  @override
  String get folderNotFound => 'Not found. Choose a folder';

  @override
  String get folderNotLocated =>
      'The game (or its mods folder) was not located automatically';

  @override
  String folderSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods',
      one: '1 mod',
    );
    return '$_temp0 · $size on disk';
  }

  @override
  String get customFolder => 'custom folder';

  @override
  String get change => 'Change…';

  @override
  String get resetToAuto => 'Reset to auto';

  @override
  String createDefaultFolderAt(String path) {
    return 'Create the default folder (with the files the game needs) at:\n$path';
  }

  @override
  String get createFolder => 'Create folder';

  @override
  String get alsoFoundOnThisComputer => 'Also found on this computer:';

  @override
  String get clearCacheTitle => 'Clear cache files';

  @override
  String clearCacheDesc(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count cache files ($size)',
      one: 'Delete 1 cache file ($size)',
    );
    return '$_temp0 so newly added or removed content shows up; the game rebuilds them on its next launch';
  }

  @override
  String get clearCaches => 'Clear caches';

  @override
  String get reportBugTitle => 'Report a bug';

  @override
  String get reportBugDesc =>
      'Open a bug report on GitHub; your app version, OS and current game come prefilled';

  @override
  String get reportBugButton => 'Report…';

  @override
  String get suggestFeatureTitle => 'Suggest a feature';

  @override
  String get suggestFeatureDesc =>
      'Missing something? Tell us what would make the mod manager better';

  @override
  String get suggestFeatureButton => 'Suggest…';

  @override
  String get wikiTitle => 'User guide & FAQ';

  @override
  String get wikiDesc =>
      'How to install mods, fix folder detection, and more, on the project wiki';

  @override
  String get wikiButton => 'Open wiki';

  @override
  String aboutTagline(String version) {
    return 'Version $version · The Sims 1–4 supported · SimCity coming soon';
  }

  @override
  String updateIsAvailable(String version) {
    return 'Version $version is available';
  }

  @override
  String get noUpdateFound => 'No update found';

  @override
  String getVersion(String version) {
    return 'Get v$version';
  }

  @override
  String get checkingForUpdates => 'Checking…';

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get categoryPackage => 'Package';

  @override
  String get categoryScript => 'Script';

  @override
  String get categoryObject => 'Object';

  @override
  String get categoryArchive => 'Archive';

  @override
  String get categorySkin => 'Skin';

  @override
  String get categoryTexture => 'Texture';

  @override
  String get categoryWall => 'Wall';

  @override
  String get categoryFloor => 'Floor';

  @override
  String get contentCasParts => 'CAS parts';

  @override
  String get contentObjects => 'objects';

  @override
  String get contentTunings => 'tunings';

  @override
  String get contentBehaviors => 'behaviors';

  @override
  String get contentTextTables => 'text tables';

  @override
  String get contentTextures => 'textures';

  @override
  String get contentMeshes => 'meshes';

  @override
  String get eraClassic => 'Classic';

  @override
  String get eraNightlife => 'Nightlife';

  @override
  String get eraAmbitions => 'Ambitions';

  @override
  String get eraModern => 'Modern';

  @override
  String get eraMedieval => 'Medieval';

  @override
  String get setupHelpSims1 =>
      'The original The Sims keeps custom content inside its install folder, not Documents: objects go in a Downloads folder next to the game executable (e.g. C:\\Program Files (x86)\\Maxis\\The Sims\\Downloads), and this app sorts the other types automatically — skins (.skn/.cmx/.bmp) into GameData\\Skins, walls and floors into GameData\\Walls and GameData\\Floors. The 2025 Legacy Collection works the same way from its own install folder (EA Games\\The Sims Legacy, or Steam\\steamapps\\common\\The Sims Legacy Collection). If the game is installed somewhere else (a different drive, a custom Steam library), pick its Downloads folder manually.';

  @override
  String get setupHelpSims2 =>
      'The Sims 2 loads custom content from Documents > EA Games > The Sims 2 > Downloads (the Ultimate Collection uses “The Sims 2 Ultimate Collection”; the 2025 Legacy Collection uses “The Sims 2 Legacy”). The folder may not exist until you create it or install content once. When the game starts, answer “Yes” to the custom content prompt so downloads are enabled.';

  @override
  String get setupHelpSims3 =>
      'The Sims 3 does not create a mods folder on its own: it needs the community “framework”: a Mods > Packages folder inside Documents > Electronic Arts > The Sims 3, plus a Resource.cfg file that tells the game to read it. This app can create both for you. On disc/Wine installs the folder can live inside the app bundle instead; use “Choose folder” to point at it.';

  @override
  String get setupHelpSims4 =>
      'The Sims 4 loads mods from Documents > Electronic Arts > The Sims 4 > Mods. The game creates this folder the first time it runs, so launch the game once if it is missing. Then, in the game, turn on Options > Game Options > Other > “Enable Custom Content and Mods” (and “Script Mods Allowed” for .ts4script files) and restart the game.';

  @override
  String get setupHelpSimsMedieval =>
      'The Sims Medieval loads mods from its install folder, not Documents: a Mods > Packages folder next to the game files (e.g. C:\\Program Files (x86)\\Origin Games\\The Sims Medieval), plus a Resource.cfg file in the install folder that tells the game to read it. This app can create both for you (Windows may ask for administrator rights under Program Files). The Documents > Electronic Arts > The Sims Medieval folder only holds saves; mods placed there do nothing. For Wine/CrossOver installs or a custom Steam library, use “Choose folder” to point at the Mods > Packages folder inside the game install.';
}
