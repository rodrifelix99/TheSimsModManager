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
  String get navShop => 'The Exchange';

  @override
  String get navSettings => 'Settings';

  @override
  String get shopAlphaBadge => 'ALPHA';

  @override
  String get shopTagline => 'Mods from the community, installed in one click.';

  @override
  String shopListingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods on the shelves',
      one: '1 mod on the shelves',
    );
    return '$_temp0';
  }

  @override
  String get shopRefresh => 'Refresh';

  @override
  String get shopPublish => 'Publish your mods';

  @override
  String get shopLoadFailedTitle => 'The Exchange isn’t answering';

  @override
  String get shopLoadFailedBody =>
      'Couldn’t load the shelves. Check your connection and give it another try.';

  @override
  String get shopRetry => 'Try again';

  @override
  String get shopEmptyTitle => 'The shelves are still empty';

  @override
  String get shopEmptyBody =>
      'The Exchange just opened its doors and nobody has published anything yet. That’s how new this is. Made a mod yourself? Be the first on the shelves!';

  @override
  String get shopAllGames => 'All games';

  @override
  String get shopShowAllGames => 'Show every game';

  @override
  String shopEmptyGameTitle(String game) {
    return 'Nothing for $game yet';
  }

  @override
  String shopEmptyGameBody(String game) {
    return 'Other games have mods on the shelves, but nobody has published a $game one yet. Made one? Be the first!';
  }

  @override
  String shopBy(String author) {
    return 'by $author';
  }

  @override
  String get shopInstalled => 'Installed';

  @override
  String get shopUpdate => 'Update';

  @override
  String get shopUpdateBadge => 'update';

  @override
  String shopUpdatesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count of your mods have new versions on The Exchange',
      one: '1 of your mods has a new version on The Exchange',
    );
    return '$_temp0';
  }

  @override
  String get shopUpdateHeading => 'There’s a new version of this one';

  @override
  String shopUpdateBody(String version, String author) {
    return '$author has published v$version on The Exchange. Updating replaces the files you have now.';
  }

  @override
  String get shopUpdateSeeListing => 'See the listing';

  @override
  String get shopInstalling => 'Installing…';

  @override
  String get shopInstallNotes => 'Install notes';

  @override
  String get shopCreatorNudge =>
      'Made mods yourself? Publishing on The Exchange is free, and players install your work in one click.';

  @override
  String shopNeedsFolder(String game) {
    return 'Set up $game’s mods folder first. The Library tab walks you through it.';
  }

  @override
  String shopVariations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count variations',
      one: '1 variation',
    );
    return '$_temp0';
  }

  @override
  String get shopVariationPick => 'Pick a variation';

  @override
  String get shopBack => 'Back to the shelves';

  @override
  String get shopCopyLink => 'Copy link';

  @override
  String get shopLinkCopied => 'Link copied';

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
  String get viewGrid => 'Grid';

  @override
  String get viewList => 'List';

  @override
  String get viewFolders => 'Folders';

  @override
  String get sortTooltip => 'Sort';

  @override
  String get sortByName => 'Name (A–Z)';

  @override
  String get sortByRecent => 'Recently changed';

  @override
  String get sortBySize => 'Biggest first';

  @override
  String get sortDisabledLast => 'Disabled ones last';

  @override
  String get libraryRefresh => 'Refresh';

  @override
  String get libraryRootFolder => 'Mods folder';

  @override
  String get selectionTooltip => 'Select';

  @override
  String selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
    );
    return '$_temp0';
  }

  @override
  String get selectionSelectAll => 'Select all';

  @override
  String get selectionClear => 'Clear';

  @override
  String get selectionEnable => 'Enable';

  @override
  String get selectionDisable => 'Disable';

  @override
  String selectionProgress(int done, int total) {
    return '$done of $total';
  }

  @override
  String selectionDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Uninstall $count mods?',
      one: 'Uninstall 1 mod?',
    );
    return '$_temp0';
  }

  @override
  String selectionDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'All $count files will be deleted from disk. There’s no undo.',
      one: 'The file will be deleted from disk. There’s no undo.',
    );
    return '$_temp0';
  }

  @override
  String get selectionMove => 'Move to…';

  @override
  String get newFolder => 'New folder';

  @override
  String newFolderIn(String folder) {
    return 'Inside $folder';
  }

  @override
  String get newFolderHint => 'Folder name';

  @override
  String get create => 'Create';

  @override
  String get move => 'Move';

  @override
  String moveTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Move $count mods where?',
      one: 'Move 1 mod where?',
    );
    return '$_temp0';
  }

  @override
  String get moveBody =>
      'The files move on disk. Nothing else about them changes - anything switched off stays off.';

  @override
  String get folderEmptySection => 'Nothing in here yet';

  @override
  String get install => 'Install';

  @override
  String filePickerModsLabel(String game) {
    return '$game mods';
  }

  @override
  String get installWhereTitle => 'Where should this go?';

  @override
  String installWhereBody(String game) {
    return '$game reads mods from several folders. The app can work it out from the file itself, or you can say where it belongs.';
  }

  @override
  String get installWhereSorted => 'Sort it out for me';

  @override
  String get installWhereSortedDesc =>
      'Follow the folders the download names, then place the rest by file type.';

  @override
  String get installWhereRemember => 'Don’t ask again';

  @override
  String get destinationSims1Downloads => 'Objects, hacks and most downloads.';

  @override
  String get destinationSims1Global =>
      'Overrides that change the base game everywhere.';

  @override
  String get destinationSims1Objects =>
      'Overrides for the game’s own object files.';

  @override
  String get destinationSims1Skins =>
      'Everyday skins and heads. These show up in Create a Sim.';

  @override
  String get destinationSims1SkinsBuy =>
      'Clothing sold in community lot stores.';

  @override
  String get destinationSims1Walls => 'Wall coverings.';

  @override
  String get destinationSims1Floors => 'Floor tiles.';

  @override
  String get destinationSims1Roofs => 'Roof textures.';

  @override
  String get prefAskWhereTitle => 'Ask where to install';

  @override
  String get prefAskWhereDesc =>
      'This game reads mods from more than one folder. Choose the folder each time instead of letting the app decide';

  @override
  String get statTotal => 'Total';

  @override
  String get statEnabled => 'Enabled';

  @override
  String get statDisabled => 'Disabled';

  @override
  String get statConflicts => 'Conflicts';

  @override
  String get statTotalTooltip =>
      'Every mod in this folder, switched on or off.';

  @override
  String get statTotalTooltipClear =>
      'Every mod in this folder. Click to drop the search and every filter.';

  @override
  String get statEnabledTooltip => 'Mods the game loads.';

  @override
  String get statEnabledTooltipActive =>
      'Showing enabled mods only. Click to show all mods again.';

  @override
  String get statDisabledTooltip => 'Mods sitting in the folder switched off.';

  @override
  String get statDisabledTooltipActive =>
      'Showing disabled mods only. Click to show all mods again.';

  @override
  String get conflictTooltipActive =>
      'Showing conflicting mods only. Click to show all mods again.';

  @override
  String get conflictTooltip =>
      'Enabled mods sharing a file name with another enabled mod, installed in more than one version, or overriding the same in-game resources. The game only keeps the copy it loads last, sometimes intentional (patch mods), often not.';

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
      'These packages contain resources with the same identifiers, so the game only keeps the copy it loads last. That can be intentional (patch and override mods shadow another mod\'s resources on purpose), but for unrelated mods it means one of them silently stops working: keep the one you want and disable the rest.';

  @override
  String get conflictIgnore => 'Ignore';

  @override
  String get conflictIgnoreTooltip =>
      'If this conflict is on purpose, hide it. Nothing about the mod changes, and you can bring the warning back from this page or from Settings.';

  @override
  String get conflictRestore => 'Bring back';

  @override
  String advisoryBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count of your mods have known issues',
      one: 'One of your mods has a known issue',
    );
    return '$_temp0';
  }

  @override
  String get advisoryShow => 'Take a look';

  @override
  String get advisoryShowAll => 'Show all mods';

  @override
  String get advisoryBadge => 'issue';

  @override
  String get advisoryBrokenHeading => 'This mod is reported broken';

  @override
  String get advisoryBrokenBody =>
      'Other players are reporting that this one stops the game working. Disabling it is the quickest way to find out if it\'s behind your problem.';

  @override
  String get advisoryOutdatedHeading => 'There\'s a newer version of this mod';

  @override
  String get advisoryOutdatedBody =>
      'The version you\'ve got is the one people are having trouble with. Grabbing the creator\'s latest should sort it.';

  @override
  String get advisoryCautionHeading => 'Worth keeping an eye on';

  @override
  String get advisoryCautionBody =>
      'This one works for most people, but it\'s been known to misbehave. Worth disabling if you\'re hunting down a problem.';

  @override
  String advisorySince(String since) {
    return 'Since $since';
  }

  @override
  String get advisoryOpenLink => 'Open the creator\'s page';

  @override
  String get advisorySource => 'Reported by other players, not by the game.';

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
  String get factDownloads => 'Downloads';

  @override
  String get factIgnoredConflicts => 'Ignored';

  @override
  String ignoredConflictsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conflicts',
      one: '1 conflict',
    );
    return '$_temp0';
  }

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
  String sectionIgnoredConflicts(String game) {
    return 'IGNORED CONFLICTS · $game';
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
  String get prefDisabledSuffixTitle => 'Disabled mod marker';

  @override
  String get prefDisabledSuffixDesc =>
      'What gets added to a file name when you switch a mod off. Change it to match another manager (CC Magic uses .off); the app reads both either way, and mods you already disabled keep the name they have';

  @override
  String get prefDisabledSuffixInvalid =>
      'Needs to be a dot and a few letters or numbers, like .off';

  @override
  String get prefExperimentalPacksTitle => 'Experimental pack switches';

  @override
  String get prefExperimentalPacksDesc =>
      'Let this game’s packs be switched off. Untested on this release, and a neighbourhood played with a pack can break without it — back your saves up first';

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
  String get translatorsTitle => 'Translated by';

  @override
  String get translatorsDesc =>
      'The app speaks eleven languages thanks to these simmers.';

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
  String get ignoredConflictsTitle => 'Conflicts you\'re ignoring';

  @override
  String ignoredConflictsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count conflicts you told the app to stop reporting. Bring them back to see them in the library again',
      one:
          'One conflict you told the app to stop reporting. Bring it back to see it in the library again',
    );
    return '$_temp0';
  }

  @override
  String get ignoredConflictsReset => 'Bring them back';

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
  String errorNoModFiles(String extensions, String name) {
    return 'No mod files ($extensions) found inside $name.';
  }

  @override
  String errorUnreadableArchive(String name) {
    return '$name isn’t a zip archive this app can read.';
  }

  @override
  String errorNoUnpacker(String format, String name) {
    return 'Nothing on this computer can unpack $format archives. Unpack $name yourself and install the files inside.';
  }

  @override
  String errorNoUnpackerLinux(String format, String name) {
    return 'Nothing on this computer can unpack $format archives. Install p7zip and try again, or unpack $name yourself and install the files inside.';
  }

  @override
  String errorNoUnpackerLinuxRar(String format, String name) {
    return 'Nothing on this computer can unpack $format archives. Install p7zip or unrar and try again, or unpack $name yourself and install the files inside.';
  }

  @override
  String errorUnpackFailed(String name) {
    return 'Couldn’t unpack $name. It may be password-protected, one part of a split archive, or a damaged download. Unpack it manually and install the files inside.';
  }

  @override
  String errorSims3PackUnreadable(String name) {
    return '$name isn’t a Sims 3 package this app can read.';
  }

  @override
  String errorSims3PackWorld(String name) {
    return '$name is a world, not custom content. Install it with The Sims 3 Launcher - the game keeps worlds outside the mods folder.';
  }

  @override
  String errorSims3PackLibrary(String name) {
    return '$name is a lot or a household, not custom content. Install it with The Sims 3 Launcher - it lands in your in-game Library.';
  }

  @override
  String errorInstallFailed(String name, String reason) {
    return '“$name” couldn’t be installed - $reason. Unpack it manually and install the files inside if it keeps failing.';
  }

  @override
  String errorInstallFailedRaw(String name, String reason) {
    return '“$name” couldn’t be installed - $reason';
  }

  @override
  String errorFileInUseDelete(String name) {
    return '“$name” couldn’t be deleted - it’s in use by another program (is the game running?) or write-protected. Close anything using it and try again.';
  }

  @override
  String errorFileInUseRename(String name) {
    return '“$name” couldn’t be renamed - it’s in use by another program (is the game running?) or write-protected. Close anything using it and try again.';
  }

  @override
  String errorFileNameTaken(String name) {
    return '“$name” is already in that folder. Rename one of the two and try again.';
  }

  @override
  String errorFolderNameBad(String name) {
    return '“$name” won’t work as a folder name. Try one without slashes or characters your system keeps for itself.';
  }

  @override
  String errorFolderTooDeep(int levels) {
    return 'The game only looks $levels folders deep inside the mods folder, so nothing you put below that would ever load.';
  }

  @override
  String errorBulkMoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods couldn’t be moved',
      one: '1 mod couldn’t be moved',
    );
    return '$_temp0 - they may be in use by another program (is the game running?), write-protected, or already in that folder under the same name.';
  }

  @override
  String errorBulkToggleFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods couldn’t be switched over',
      one: '1 mod couldn’t be switched over',
    );
    return '$_temp0 - they may be in use by another program (is the game running?) or write-protected.';
  }

  @override
  String errorBulkRemoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods couldn’t be deleted',
      one: '1 mod couldn’t be deleted',
    );
    return '$_temp0 - they may be in use by another program (is the game running?) or write-protected.';
  }

  @override
  String errorFileMissing(String name) {
    return '“$name” is no longer in the mods folder - it may have been moved or deleted by another program.';
  }

  @override
  String get requirementMedievalModLoader =>
      'The Sims Medieval can’t run script or core mods without the community’s loader file in the game’s Game\\Bin folder. Custom content works without it; everything else doesn’t.';

  @override
  String get requirementSims4ModsOff =>
      'The game has custom content and mods switched off in its own Game Options, so none of this is loading. Turn it back on under Options → Game Options → Other, then restart the game.';

  @override
  String get requirementSims4ScriptModsOff =>
      'You have script mods here, but the game has “Script Mods Allowed” switched off in its own Game Options. Game updates reset that.';

  @override
  String get requirementGetFile => 'Where to get it';

  @override
  String tooDeepBanner(int count, int levels) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods are',
      one: 'One mod is',
    );
    return '$_temp0 in a subfolder the game doesn’t read. It only looks $levels folders deep inside the mods folder - move them higher up and they’ll load.';
  }

  @override
  String get tooDeepShow => 'Show them';

  @override
  String errorNoWriteAccess(String folder) {
    return 'The app isn’t allowed to write to “$folder”. Your system protects that folder - give your account write access to it, or point the app somewhere else in Settings.';
  }

  @override
  String get folderReadOnlyBanner =>
      'This mods folder is read-only, so installing and removing mods won’t work until your account can write to it.';

  @override
  String get elevatedNoDropBanner =>
      'You’re running as administrator, so Windows won’t let you drag files onto the window. Use the Install button instead - that still works.';

  @override
  String errorShopDownload(String name) {
    return '“$name” couldn’t be downloaded from The Exchange. Check your connection and try again.';
  }

  @override
  String get errorShopListingNotFound =>
      'That mod isn’t on The Exchange any more. It may have been taken down.';

  @override
  String get errorShopListingUnknownGame =>
      'That mod is for a game this version of the app doesn’t know yet. Try updating.';

  @override
  String errorPackToggleFailed(String pack) {
    return 'Couldn’t switch $pack. Close the game and try again.';
  }

  @override
  String get errorPackNoUserData =>
      'Couldn’t find the game’s own settings folder, so there’s nowhere to note which packs to skip. Run the game once first.';

  @override
  String get errorPackNeedsAdmin =>
      'Windows wouldn’t let the app change that. Restart it as an administrator and try again.';

  @override
  String get errorPackNotSupported => 'Packs can’t be switched on this system.';

  @override
  String get errorPackIsTheGame =>
      'That’s the pack the game actually runs from, so it has to stay on.';

  @override
  String get errorPackToggleRefused =>
      'Couldn’t change that pack. Close the game and try again.';

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
  String get navPacks => 'Packs';

  @override
  String get packsScanning => 'Looking for your packs…';

  @override
  String get packsEmptyTitle => 'No packs found';

  @override
  String packsEmptyBody(String game) {
    return 'Either $game isn\'t installed where the app can see it, or there are no packs alongside it yet.';
  }

  @override
  String get packsRescan => 'Check again';

  @override
  String packsSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count packs installed',
      one: '1 pack installed',
    );
    return '$_temp0';
  }

  @override
  String packsSummaryWithOff(int count, int off) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count packs on',
      one: '1 pack on',
    );
    return '$_temp0, $off switched off';
  }

  @override
  String get packsOff => 'Off';

  @override
  String get packsInstalled => 'Installed';

  @override
  String get packsNeedAdmin =>
      'Switching these packs on and off needs administrator rights, because that’s where the game keeps its list. Restart the app as an administrator to change them — drag and drop stops working while you do, so it’s worth switching back afterwards.';

  @override
  String get packsExperimentalTitle => 'Switching these off is experimental';

  @override
  String get packsExperimentalOff =>
      'It works the way it always has for this game, but nobody has tested it on this release — and a neighbourhood you’ve played with a pack can break when you open it without one. Listing is safe. Turn on experimental pack switches in Settings if you want to try it anyway.';

  @override
  String get packsExperimentalOn =>
      'Back up your neighbourhoods first. A neighbourhood you’ve played with a pack can break when you open it without one, and there’s no undoing that from here — switching the pack back on doesn’t always bring the save back.';

  @override
  String packsRestartNotice(String game) {
    return 'Restart $game for this to take effect. Your packs stay installed either way.';
  }

  @override
  String packsAllOwnedSims4(String expansions, String gamePacks) {
    return '$expansions expansions. $gamePacks game packs. Sure you bought them all.';
  }

  @override
  String get packKindExpansions => 'Expansion packs';

  @override
  String get packKindGamePacks => 'Game packs';

  @override
  String get packKindStuffPacks => 'Stuff packs';

  @override
  String get packKindKits => 'Kits';

  @override
  String get packKindFreePacks => 'Free packs';

  @override
  String get navSaves => 'Saves';

  @override
  String get savesScanning => 'Reading your saves…';

  @override
  String get savesEmptyTitle => 'No saves found';

  @override
  String savesEmptyBody(String game) {
    return 'Once you play $game and save, your worlds show up here - families, photos and all.';
  }

  @override
  String get savesRescan => 'Rescan saves';

  @override
  String savesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saves found',
      one: '1 save found',
    );
    return '$_temp0';
  }

  @override
  String savesLastSaved(String date) {
    return 'Last saved $date';
  }

  @override
  String get savesShowInFolder => 'Show in folder';

  @override
  String savesBackups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count backups',
      one: '1 backup',
    );
    return '$_temp0';
  }

  @override
  String get savesTabHouseholds => 'Households';

  @override
  String get savesTabAlbum => 'Photo album';

  @override
  String get savesTabStats => 'World stats';

  @override
  String savesNeighborhood(int number) {
    return 'Neighborhood $number';
  }

  @override
  String get savesOtherHouseholds => 'Townies & other households';

  @override
  String savesSimCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sims',
      one: '1 Sim',
    );
    return '$_temp0';
  }

  @override
  String get savesFunds => 'Funds';

  @override
  String get savesRooms => 'Rooms';

  @override
  String savesBedsBaths(int beds, int baths) {
    return '$beds bed · $baths bath';
  }

  @override
  String savesByCreator(String name) {
    return 'by $name';
  }

  @override
  String get savesMembers => 'Members';

  @override
  String get savesRelationships => 'Relationships';

  @override
  String get savesUnknownSim => 'Unknown Sim';

  @override
  String get savesStatSims => 'Sims';

  @override
  String get savesStatHouseholds => 'Households';

  @override
  String get savesStatNetWorth => 'Net worth';

  @override
  String get savesStatWorlds => 'Worlds';

  @override
  String get savesStatPhotos => 'Photos';

  @override
  String savesAcrossHouseholds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'across $count households',
      one: 'in 1 household',
    );
    return '$_temp0';
  }

  @override
  String savesPlayedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count played',
      one: '1 played',
    );
    return '$_temp0';
  }

  @override
  String get savesSizeOnDisk => 'Size on disk';

  @override
  String get savesLifeStages => 'Life stages';

  @override
  String get savesTopSkills => 'Highest skills in this save';

  @override
  String get savesSaveInfo => 'Save file';

  @override
  String get savesLastSavedLabel => 'Last saved';

  @override
  String get savesGameVersion => 'Game version';

  @override
  String get savesDescription => 'Description';

  @override
  String get savesAgeInfant => 'Infant';

  @override
  String get savesAgeBaby => 'Baby';

  @override
  String get savesAgeToddler => 'Toddler';

  @override
  String get savesAgeChild => 'Child';

  @override
  String get savesAgeTeen => 'Teen';

  @override
  String get savesAgeYoungAdult => 'Young adult';

  @override
  String get savesAgeAdult => 'Adult';

  @override
  String get savesAgeElder => 'Elder';

  @override
  String get savesGenderMale => 'Male';

  @override
  String get savesGenderFemale => 'Female';

  @override
  String get savesSkillCooking => 'Cooking';

  @override
  String get savesSkillMechanical => 'Mechanical';

  @override
  String get savesSkillCharisma => 'Charisma';

  @override
  String get savesSkillBody => 'Body';

  @override
  String get savesSkillLogic => 'Logic';

  @override
  String get savesSkillCreativity => 'Creativity';

  @override
  String get savesSkillCleaning => 'Cleaning';

  @override
  String get savesPersonalityNeat => 'Neat';

  @override
  String get savesPersonalityOutgoing => 'Outgoing';

  @override
  String get savesPersonalityActive => 'Active';

  @override
  String get savesPersonalityPlayful => 'Playful';

  @override
  String get savesPersonalityNice => 'Nice';

  @override
  String get savesZodiacAries => 'Aries';

  @override
  String get savesZodiacTaurus => 'Taurus';

  @override
  String get savesZodiacGemini => 'Gemini';

  @override
  String get savesZodiacCancer => 'Cancer';

  @override
  String get savesZodiacLeo => 'Leo';

  @override
  String get savesZodiacVirgo => 'Virgo';

  @override
  String get savesZodiacLibra => 'Libra';

  @override
  String get savesZodiacScorpio => 'Scorpio';

  @override
  String get savesZodiacSagittarius => 'Sagittarius';

  @override
  String get savesZodiacCapricorn => 'Capricorn';

  @override
  String get savesZodiacAquarius => 'Aquarius';

  @override
  String get savesZodiacPisces => 'Pisces';

  @override
  String get savesAspirationRomance => 'Romance';

  @override
  String get savesAspirationFamily => 'Family';

  @override
  String get savesAspirationFortune => 'Fortune';

  @override
  String get savesAspirationPopularity => 'Popularity';

  @override
  String get savesAspirationKnowledge => 'Knowledge';

  @override
  String get savesAspirationGrowUp => 'Grow up';

  @override
  String get savesAspirationPleasure => 'Pleasure';

  @override
  String get savesAspirationGrilledCheese => 'Grilled cheese';

  @override
  String get savesRelCrush => 'crush';

  @override
  String get savesRelLove => 'in love';

  @override
  String get savesRelEngaged => 'engaged';

  @override
  String get savesRelMarried => 'married';

  @override
  String get savesRelFriends => 'friends';

  @override
  String get savesRelBestFriends => 'best friends';

  @override
  String get savesRelSteady => 'going steady';

  @override
  String get savesRelEnemies => 'enemies';

  @override
  String get savesPhotoFamilyPortrait => 'Family portrait';

  @override
  String get savesPhotoLot => 'Lot';

  @override
  String get savesPhotoSim => 'Sim portrait';

  @override
  String get savesPhotoSnapshot => 'Snapshot';

  @override
  String get savesProperty => 'Property';

  @override
  String get savesGhost => 'ghost';

  @override
  String savesCareerLevel(String career, int level) {
    return '$career · level $level';
  }

  @override
  String get savesSpeciesLargeDog => 'dog';

  @override
  String get savesSpeciesSmallDog => 'small dog';

  @override
  String get savesSpeciesCat => 'cat';

  @override
  String get savesOccultVampire => 'vampire';

  @override
  String get savesOccultZombie => 'zombie';

  @override
  String get savesOccultWerewolf => 'werewolf';

  @override
  String get savesOccultPlantSim => 'PlantSim';

  @override
  String get savesOccultAlien => 'alien';

  @override
  String get savesOccultServo => 'servo';

  @override
  String get savesOccultWitch => 'witch';

  @override
  String get savesOccultBigfoot => 'bigfoot';

  @override
  String get savesOccultFairy => 'fairy';

  @override
  String get savesOccultGenie => 'genie';

  @override
  String get savesOccultMermaid => 'mermaid';

  @override
  String get savesLotResidential => 'Residential';

  @override
  String get savesLotCommunity => 'Community lot';

  @override
  String get savesLotDorm => 'Dorm';

  @override
  String get savesLotSecretSociety => 'Secret society';

  @override
  String get savesLotGreekHouse => 'Greek house';

  @override
  String get savesLotHotel => 'Hotel';

  @override
  String get savesLotSecret => 'Secret lot';

  @override
  String get savesLotBusiness => 'Business';

  @override
  String get savesLotApartment => 'Apartment';

  @override
  String savesGpa(String gpa) {
    return '$gpa GPA';
  }

  @override
  String savesSemester(int number) {
    return 'semester $number';
  }

  @override
  String savesPredestinedHobby(String hobby) {
    return 'Born for $hobby';
  }

  @override
  String get savesHobbyCuisine => 'Cuisine';

  @override
  String get savesHobbyArts => 'Arts & crafts';

  @override
  String get savesHobbyFilm => 'Film & literature';

  @override
  String get savesHobbySports => 'Sports';

  @override
  String get savesHobbyGames => 'Games';

  @override
  String get savesHobbyNature => 'Nature';

  @override
  String get savesHobbyTinkering => 'Tinkering';

  @override
  String get savesHobbyFitness => 'Fitness';

  @override
  String get savesHobbyScience => 'Science';

  @override
  String get savesHobbyMusic => 'Music & dance';

  @override
  String get savesTieMother => 'mother';

  @override
  String get savesTieFather => 'father';

  @override
  String get savesTieSpouse => 'married to';

  @override
  String savesTieSibling(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'siblings',
      one: 'sibling',
    );
    return '$_temp0';
  }

  @override
  String savesTieChild(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'children',
      one: 'child',
    );
    return '$_temp0';
  }

  @override
  String get savesInterestPolitics => 'Politics';

  @override
  String get savesInterestMoney => 'Money';

  @override
  String get savesInterestEnvironment => 'Environment';

  @override
  String get savesInterestCrime => 'Crime';

  @override
  String get savesInterestEntertainment => 'Entertainment';

  @override
  String get savesInterestCulture => 'Culture';

  @override
  String get savesInterestFood => 'Food';

  @override
  String get savesInterestHealth => 'Health';

  @override
  String get savesInterestFashion => 'Fashion';

  @override
  String get savesInterestSports => 'Sports';

  @override
  String get savesInterestParanormal => 'Paranormal';

  @override
  String get savesInterestTravel => 'Travel';

  @override
  String get savesInterestWork => 'Work';

  @override
  String get savesInterestWeather => 'Weather';

  @override
  String get savesInterestAnimals => 'Animals';

  @override
  String get savesInterestSchool => 'School';

  @override
  String get savesInterestToys => 'Toys';

  @override
  String get savesInterestSciFi => 'Sci-fi';

  @override
  String get savesInterestMusic => 'Music';

  @override
  String get savesInterestOutdoors => 'Outdoors';

  @override
  String get setupHelpSims1 =>
      'The original The Sims keeps custom content inside its install folder, not Documents: objects go in a Downloads folder next to the game executable (e.g. C:\\Program Files (x86)\\Maxis\\The Sims\\Downloads), and this app sorts the other types automatically - skins (.skn/.cmx/.bmp) into GameData\\Skins, walls and floors into GameData\\Walls and GameData\\Floors. The 2025 Legacy Collection works the same way from its own install folder (EA Games\\The Sims Legacy, or Steam\\steamapps\\common\\The Sims Legacy Collection). If the game is installed somewhere else (a different drive, a custom Steam library), pick its Downloads folder manually.';

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
