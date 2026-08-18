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
  String get shopSaveFile => 'Download';

  @override
  String get shopSaving => 'Downloading…';

  @override
  String get shopSaved => 'Saved';

  @override
  String get shopSaveHint =>
      'Install drops the files straight into your mods folder. Download just saves the file, wherever you want it.';

  @override
  String get shopDestination => 'Installs into';

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
  String get installFolderTitle => 'Which folder?';

  @override
  String installFolderBody(String game) {
    return 'Where the files land inside your mods folder for $game.';
  }

  @override
  String get installFolderChoose => 'Choose';

  @override
  String get installFolderEmpty =>
      'No subfolders yet. Make one, or leave everything in the mods folder.';

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
  String get duplicateBadge => 'copy';

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
  String conflictSameFileHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count other enabled mods are exactly the same file:',
      one: 'Another enabled mod is exactly the same file:',
    );
    return '$_temp0';
  }

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
  String get conflictSameFileBody =>
      'The duplicate scan read these files and they match byte for byte, so this isn\'t two mods arguing - it\'s the same download sitting in your folder more than once. Keeping one and removing the rest changes nothing in the game and gives you the space back.';

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
  String sectionShopFolder(String game) {
    return 'THE EXCHANGE · $game';
  }

  @override
  String get prefShopFolderTitle => 'Where mods from The Exchange go';

  @override
  String prefShopFolderDesc(String folder) {
    return 'Installs land in $folder';
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
  String get prefConflictKindsTitle => 'Which conflicts to warn about';

  @override
  String get prefConflictKindsDesc =>
      'Switch off the kinds you don\'t want flagged. The rest carry on as they are';

  @override
  String get conflictKindSameFile => 'Identical copies';

  @override
  String get conflictKindSameName => 'Same file name';

  @override
  String get conflictKindVersions => 'Different versions';

  @override
  String get conflictKindResources => 'Shared resources';

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
      'The app speaks twelve languages thanks to these simmers.';

  @override
  String get sectionStartup => 'STARTUP';

  @override
  String get prefDefaultGameTitle => 'Game to open on';

  @override
  String get prefDefaultGameDesc =>
      'Which library the app starts on when you launch it';

  @override
  String get defaultGameAuto => 'Automatic';

  @override
  String get prefSetupGuideTitle => 'Setup guide';

  @override
  String get prefSetupGuideDesc => 'Walk through the first-run questions again';

  @override
  String get onboardingReplay => 'Run it again';

  @override
  String get onboardingSkip => 'Skip setup';

  @override
  String get onboardingSkipIntro => 'Skip intro';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingFinish => 'Open my library';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingWelcomeTitle => 'Hey! Let’s get you set up';

  @override
  String get onboardingWelcomeBody =>
      'A few quick questions and your mods are ready to go. It takes under a minute, and everything here can be changed later in Settings.';

  @override
  String get onboardingGamesTitle => 'Looking for your games';

  @override
  String get onboardingGamesBody =>
      'Checking the usual places for each game and the folder it reads mods from.';

  @override
  String get onboardingScanning => 'Still looking…';

  @override
  String onboardingGamesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count games found',
      one: '1 game found',
      zero: 'Nothing found yet',
    );
    return '$_temp0';
  }

  @override
  String onboardingGameMods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods already installed',
      one: '1 mod already installed',
      zero: 'Mods folder ready',
    );
    return '$_temp0';
  }

  @override
  String get onboardingGameMissing => 'Not on this computer';

  @override
  String get onboardingNoGamesTitle => 'Couldn’t find a thing';

  @override
  String get onboardingNoGamesBody =>
      'No drama. Point the app at a mods folder yourself in Settings and everything works exactly the same.';

  @override
  String get onboardingFavoriteTitle => 'Which one do you play most?';

  @override
  String get onboardingFavoriteBody =>
      'The app opens on this game every time. You can jump between games whenever you like from the sidebar.';

  @override
  String get onboardingLookTitle => 'Make it feel like yours';

  @override
  String get onboardingLookBody =>
      'The whole app re-tints itself for the game you’re on. Pick how it should look and sound.';

  @override
  String get onboardingLibraryTitle => 'How your library reads';

  @override
  String get onboardingLibraryBody =>
      'Two things worth deciding now, because they change what the library shows you.';

  @override
  String get onboardingDoneTitle => 'All set!';

  @override
  String get onboardingDoneBody =>
      'Your library is loaded and waiting. Drop a mod file onto the window whenever you want to install one, and change any of this in Settings.';

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
  String get categoryWorld => 'World';

  @override
  String get categorySettings => 'Settings';

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
  String get modKindCas => 'CAS';

  @override
  String get modKindBuildBuy => 'Build & Buy';

  @override
  String get modKindGameplay => 'Gameplay';

  @override
  String get modKindScript => 'Script';

  @override
  String errorNoModFiles(String extensions, String name) {
    return 'No mod files ($extensions) found inside $name.';
  }

  @override
  String errorUnreadableArchive(String name) {
    return '$name isn’t an archive this app can read.';
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
  String get duplicatesFind => 'Find duplicate mods';

  @override
  String duplicatesScanning(int done, int total) {
    return 'Reading the mods that could be copies… $done of $total';
  }

  @override
  String get duplicatesStop => 'Stop';

  @override
  String duplicatesBanner(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods are the same file as another one',
      one: 'One mod is the same file as another one',
    );
    return '$_temp0 - that’s $size you could have back.';
  }

  @override
  String get duplicatesShow => 'Show them';

  @override
  String get duplicatesSelectExtras => 'Tick the spare copies';

  @override
  String get duplicatesClean => 'Nothing in here is a copy of anything else.';

  @override
  String get duplicatesDismiss => 'Got it';

  @override
  String tagTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tags for $count mods',
      one: 'Tags for this mod',
    );
    return '$_temp0';
  }

  @override
  String get tagBody =>
      'Your own labels, for finding things later. Tap one to put it on or take it off.';

  @override
  String get tagHint => 'New tag';

  @override
  String get tagAdd => 'Add';

  @override
  String get tagDone => 'Done';

  @override
  String get tagHeading => 'Tags';

  @override
  String get tagAddFirst => 'Add a tag';

  @override
  String tagRemove(String tag) {
    return 'Remove “$tag”';
  }

  @override
  String get selectionTag => 'Tag…';

  @override
  String folderAlsoReading(String folders) {
    return 'Your game reads $folders as well, so mods in there are in this library too.';
  }

  @override
  String errorFolderUnreadable(String folder) {
    return 'Couldn’t open “$folder”. Pick a folder on a drive this computer can reach - a phone, a camera or a disconnected network drive can’t hold your mods.';
  }

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
  String errorShopNoModFiles(String name) {
    return 'There’s nothing this game can install inside “$name”. It might not be a mod at all - use Download to save the file wherever you want it.';
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

  @override
  String get prefSubfoldersTitle => 'Folders include their subfolders';

  @override
  String get prefSubfoldersDesc =>
      'A folder shows everything below it too. Off, cc and cc/defaults are separate shelves.';

  @override
  String deleteFolderTitle(String folder) {
    return 'Delete $folder?';
  }

  @override
  String get deleteFolderBody =>
      'The folder and everything in it goes, subfolders and all. This cannot be undone.';

  @override
  String deleteFolderMods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods will be deleted',
      one: '1 mod will be deleted',
    );
    return '$_temp0';
  }

  @override
  String get deleteFolderEmpty => 'It holds no mods.';

  @override
  String get deleteFolder => 'Delete folder';

  @override
  String triviaTitle(String game) {
    return 'Plumbob knows · $game';
  }

  @override
  String get triviaContextLibrary => 'It looks like you’re browsing mods';

  @override
  String get triviaContextSaves => 'It looks like you’re in your saves';

  @override
  String get triviaContextPacks =>
      'It looks like you’re sorting out your packs';

  @override
  String triviaCounter(int index, int total) {
    return 'Fact $index of $total';
  }

  @override
  String get triviaOpen => 'Ask the plumbob';

  @override
  String get triviaClose => 'Not now';

  @override
  String get triviaPrevious => 'Previous fact';

  @override
  String get triviaNext => 'Next fact';

  @override
  String get triviaAnother => 'Another one';

  @override
  String get triviaToSettings =>
      'Had enough? Switch the plumbob off in Settings';

  @override
  String get prefTriviaTitle => 'Plumbob trivia';

  @override
  String get prefTriviaDesc =>
      'Let the plumbob pop up now and then with a fact about the game you’re in';

  @override
  String get triviaCategoryOrigins => 'Origins';

  @override
  String get triviaCategoryDesign => 'Design';

  @override
  String get triviaCategoryLore => 'Lore';

  @override
  String get triviaCategoryDeath => 'Death';

  @override
  String get triviaCategoryMusic => 'Music';

  @override
  String get triviaCategoryCheats => 'Cheats';

  @override
  String get triviaCategoryRecords => 'Records';

  @override
  String get triviaCategoryModding => 'Modding';

  @override
  String get triviaCategoryLanguage => 'Language';

  @override
  String get triviaCategoryCommunity => 'Community';

  @override
  String get triviaSeriesLlama =>
      'Maxis once held a studio-wide vote for an unofficial mascot. The candidates were a Boston tree fern, a beef tapeworm and a llama. The llama won, and it has been turning up in the games ever since.';

  @override
  String get triviaSeriesSimlish =>
      'Simlish was co-created at the microphone. Stephen Kearin and Gerri Lawlor were handed prompts like “hungry” or “lonely” and improvised what those ought to sound like, for hours.';

  @override
  String get triviaSeriesCheats =>
      'rosebud and klapaucius both pay out §1,000. Rosebud is Citizen Kane; Klapaucius is a robot constructor from Stanisław Lem’s The Cyberiad, a book Will Wright has credited as an influence since SimCity.';

  @override
  String get triviaSeriesRecords =>
      'Guinness lists The Sims as the best-selling PC game series of all time. It passed 125 million copies more than a decade ago and has been translated into 60 languages.';

  @override
  String get triviaSeriesGoths =>
      'The Goths are among the longest-running families in games. Mortimer and Bella have turned up in every mainline entry since 2000.';

  @override
  String get triviaSeriesReaper =>
      'The Grim Reaper has a biography ordinary play never shows you. Among other things, it names his favourite band: Styx.';

  @override
  String get triviaSeriesSimCity =>
      'The Sims grew out of SimCity. Will Wright kept wanting to zoom in on the little people the city was being built for.';

  @override
  String get triviaSeriesLegacy =>
      'In January 2025 EA put The Sims and The Sims 2 back on sale as Legacy Collections, every expansion included. They are compatibility fixes rather than remasters, so both games play exactly as they did.';

  @override
  String get triviaSeriesPlumbob =>
      'The green diamond has been spelled three ways: PlumbBob in The Sims, Plum Bob in The Sims 2, and plumbob since The Sims 4. Maxis says all three were used during development.';

  @override
  String get triviaSeriesModScene =>
      'The mod scene is nearly as old as the series. Skin and object editors were circulating within months of the first game shipping in 2000, long before there were official tools.';

  @override
  String get triviaSeriesConflicts =>
      'A conflict is simpler than it sounds. Two mods claim the same resource, both load, and whichever the game reads last wins. Nothing is broken, something is just overruled.';

  @override
  String get triviaSeriesPackage =>
      'A .package file is a DBPF archive, short for Database Packed File. Maxis has used the same container since SimCity 4, which is why one tool can open twenty years of custom content.';

  @override
  String get triviaSeriesRename =>
      'Switching a mod off by renaming it is the oldest trick in the scene. The game only loads files it recognises, so a renamed package stays exactly where it is and stays quiet.';

  @override
  String get triviaSeriesSaves =>
      'Sims saves are neighbourhoods, not slots. The families, the lots, the memories and the gossip all live in one folder that grows for as long as you keep playing.';

  @override
  String get triviaSeriesPacks =>
      'Switching a pack off never moves a file. Every game in the series keeps its own list of what to load somewhere else, a settings line or a registry key, and hiding one just means editing that list.';

  @override
  String get triviaSims1Dollhouse =>
      'The Sims started life as an architecture simulator called Project Dollhouse. The Sims themselves were added only so players could judge whether a house was any good to live in.';

  @override
  String get triviaSims1Oakland =>
      'Will Wright lost his home in the 1991 Oakland firestorm. Rebuilding a household from scratch, furniture and appliances and routines, became the seed of the game.';

  @override
  String get triviaSims1Toilet =>
      'Executives were famously unconvinced by the pitch, dismissing it as a “toilet game” because Sims needed bathrooms.';

  @override
  String get triviaSims1HomeTactics =>
      'Before it was The Sims it was pitched as Home Tactics: The Experimental Domestic Simulator. The focus groups disliked that version too.';

  @override
  String get triviaSims1Myst =>
      'In 2002 The Sims passed Myst to become the best-selling PC game of all time.';

  @override
  String get triviaSims1Simlish =>
      'Simlish was improvised by voice actors riffing on fragments of Ukrainian, Navajo, Tagalog and Estonian, deliberately kept meaningless so the language never dates.';

  @override
  String get triviaSims1Architecture =>
      'The building tools were so unusual for 2000 that some players never placed a Sim at all and used the game as free architecture software.';

  @override
  String get triviaSims1Audience =>
      'Unusually for its era, the majority of the players were women, which is part of why the marketing looked like nothing else on the shelf.';

  @override
  String get triviaSims1Cowplant =>
      'The cowplant debuted here under the in-game name Laganaphyllis Simnovorii, and has quietly eaten Sims in every generation since.';

  @override
  String get triviaSims1Plumbob =>
      'The word plumbob comes from the plumb bob, a weighted pointer builders hang on a string to find true vertical. This was an architecture game first.';

  @override
  String get triviaSims1Release =>
      'The game shipped on 4 February 2000 and outsold every expansion prediction EA had made for it.';

  @override
  String get triviaSims1Edith =>
      'Every object in the game was scripted in a language called SimAntics, through an in-house tool named Edith after Edith Bunker: the first character ever built for The Sims.';

  @override
  String get triviaSims1Expansions =>
      'Seven expansions in three and a half years, one each spring and autumn, from Livin’ Large in August 2000 to Makin’ Magic in October 2003.';

  @override
  String get triviaSims1Unleashed =>
      'Unleashed brought pets to the series in 2002 and took Computer Simulation Game of the Year at the Interactive Achievement Awards.';

  @override
  String get triviaSims1Clown =>
      'The Tragic Clown turns up to cheer a sad Sim who owns his painting. He is comprehensively bad at it, which is the entire joke.';

  @override
  String get triviaSims1Llama =>
      'The original printed manual contained a book called Making the Most of Your Llama. Nobody has ever explained it.';

  @override
  String get triviaSims1Superstar =>
      'Superstar let a Sim become an actor, a model or a singer with a working fame meter, eleven years before The Sims 4 tried celebrity again.';

  @override
  String get triviaSims1Catalogue =>
      'Rebuilding after the fire, Will Wright kept asking which parts of a home were essential and which could wait. That question is more or less the buy-mode catalogue.';

  @override
  String get triviaSims2Aging =>
      'The Sims 2 was the first game in the series where Sims aged, died of old age and passed genetics down. Eyes, noses and chins are inherited from both parents.';

  @override
  String get triviaSims2Memories =>
      'Every Sim carries a hidden memory list. Witnessing a death, a first kiss or a promotion is stored and shapes later moods.';

  @override
  String get triviaSims2Bella =>
      'Bella Goth vanishes from Pleasantview at the start of the game, and the disappearance has never been officially explained in twenty years.';

  @override
  String get triviaSims2Strangetown =>
      'Bella turns up alive in Strangetown with no memory of Pleasantview at all. Maxis has said both Bellas are real and left it there.';

  @override
  String get triviaSims2FamilyTrees =>
      'Sims 2 neighbourhoods run on a real family tree: Pleasantview, Strangetown and Veronaville are all connected by marriage and rumour.';

  @override
  String get triviaSims2Plead =>
      'The Grim Reaper can be pleaded with. Talk to him at the right moment and he may hand your Sim back, occasionally in exchange for someone else.';

  @override
  String get triviaSims2ReaperRomance =>
      'You can romance the Grim Reaper. Play it well enough and the relationship produces a ghost baby.';

  @override
  String get triviaSims2Satellite =>
      'A Sim who stargazes has a very small chance of being hit by a falling satellite. It is one of the rarest deaths in the series.';

  @override
  String get triviaSims2Therapist =>
      'Aspiration failure sends a Sim to the therapist, one of the few times the game breaks its own fourth wall for laughs.';

  @override
  String get triviaSims2WantsFears =>
      'Wants and fears run the whole game. The aspiration meter reacts as strongly to the thing a Sim was dreading as to the thing they were hoping for.';

  @override
  String get triviaSims2FaceSculpt =>
      'The game shipped with a full body-shape and face-sculpting system, which is why Sims 2 faces still look more varied than later entries.';

  @override
  String get triviaSims2Aliens =>
      'Alien abduction only happens to male Sims who stargaze too long, and yes, they come back pregnant.';

  @override
  String get triviaSims2FreezerBunny =>
      'The Freezer Bunny was drawn by artist Emmy Toyonaga for The Sims 2 and first appeared hiding inside a community lot freezer. It has been smuggled into every game since.';

  @override
  String get triviaSims2SocialBunny =>
      'The Social Bunny replaced the Tragic Clown, and unlike the clown it actually works. Plenty of players found the competent version more unsettling.';

  @override
  String get triviaSims2Giveaway =>
      'EA gave the Ultimate Collection away free through Origin in July 2014, redeemed with the code I-LOVE-THE-SIMS. For the decade until the Legacy Collection, that giveaway was the only copy going.';

  @override
  String get triviaSims3SunsetValley =>
      'Sunset Valley is Pleasantview from The Sims 2 roughly 25 years earlier, so you can meet the grandparents of Sims you already played.';

  @override
  String get triviaSims3Founders =>
      'Sunset Valley was founded by the Goths and built up by the Landgraabs. You can play Mortimer Goth as a child and watch him meet Bella Bachelor.';

  @override
  String get triviaSims3OpenWorld =>
      'The Sims 3 dropped loading screens entirely. The whole town simulates at once, with every Sim aging and working in the background.';

  @override
  String get triviaSims3Simulation =>
      'Every Sim in town is simulated at once, which is why a long save slows down. The game is quietly running lives you have never met.';

  @override
  String get triviaSims3CreateAStyle =>
      'Create-a-Style let players recolour and re-pattern almost any object, a feature so demanding it was never brought back.';

  @override
  String get triviaSims3Exchange =>
      'The Sims 3 shipped with a real online exchange where players traded lots, Sims and patterns directly from the launcher.';

  @override
  String get triviaSims3Downloads =>
      'In its first week alone, players downloaded more than seven million user-made items straight from that launcher.';

  @override
  String get triviaSims3Traits =>
      'Traits replaced the old personality sliders, and some of them, like Kleptomaniac and Insane, quietly break the rules of ordinary life.';

  @override
  String get triviaSims3Kleptomaniac =>
      'A kleptomaniac Sim comes home with other people’s furniture, unprompted, and will keep doing it until you notice.';

  @override
  String get triviaSims3Simlish =>
      'Katy Perry, Lily Allen, Depeche Mode and dozens of other artists re-recorded their own songs in Simlish for the soundtracks.';

  @override
  String get triviaSims3Townies =>
      'Because the open world simulated off-screen Sims, players regularly found townies had married and had children without any input.';

  @override
  String get triviaSims3Store =>
      'The Sims 3 Store sold more objects than the game itself contained at launch.';

  @override
  String get triviaSims3Launch =>
      'The Sims 3 sold 1.4 million copies in its first week in June 2009, the biggest PC launch EA had ever had.';

  @override
  String get triviaSims4Flies =>
      'Death by flies is real. Leave a lot filthy enough and a swarm can finish a Sim off.';

  @override
  String get triviaSims4Emotions =>
      'Emotions drive everything here. A Sim who is Inspired paints better; one who is Enraged can die of anger.';

  @override
  String get triviaSims4EmotionDeaths =>
      'A Sim can die of laughter, of anger and of embarrassment. Emotion is not decoration in this one, it is a hazard.';

  @override
  String get triviaSims4CreateASim =>
      'Create-a-Sim replaced sliders with direct pulling and pushing on the face, which is why Sims 4 faces are so quick to make.';

  @override
  String get triviaSims4Launch =>
      'The Sims 4 launched without pools or toddlers. Both were patched in free of charge after sustained player pressure.';

  @override
  String get triviaSims4Worlds =>
      'Willow Creek and Oasis Springs were the only two worlds at launch in September 2014. There are dozens now, and almost all of them arrived with a pack.';

  @override
  String get triviaSims4Gender =>
      'Gender was fully unlocked in a 2016 patch: any Sim can wear any clothing, take any voice, and get pregnant or not.';

  @override
  String get triviaSims4Newcrest =>
      'Newcrest shipped completely empty on purpose. Fifteen lots, no buildings, and an open invitation to the community to fill it.';

  @override
  String get triviaSims4Naming =>
      'Neighbourhood names like Willow Creek and Oasis Springs follow a house rule from early Maxis: two plain English words, no invented spellings.';

  @override
  String get triviaSims4Goths =>
      'The Goth family appears here too, which makes them one of the longest-running families in games, present in every mainline entry.';

  @override
  String get triviaSims4FreeToPlay =>
      'The base game went free in October 2022 on PC, PlayStation and Xbox at once. The packs stayed paid.';

  @override
  String get triviaSims4Mccc =>
      'MC Command Center, the first mod most Sims 4 players install, has passed 14 million downloads on CurseForge alone. Deaderpool has been updating it since 2015.';

  @override
  String get triviaSims4Twallan =>
      'MCCC exists because of The Sims 3. It picks up where Twallan’s Master Controller and Story Progression left off, carrying a decade-old idea into a new engine.';

  @override
  String get triviaSims4Deaths =>
      'Sims can be killed by a cowplant, a vending machine, a llama-shaped stereo and laughter. Not all at once.';

  @override
  String get triviaMedievalWatcher =>
      'You are not a household here, you are the Watcher: a benign deity who nudges heroes around a kingdom rather than running one family’s day.';

  @override
  String get triviaMedievalHeroes =>
      'A kingdom holds up to ten hero Sims across ten professions, and each of them levels from 1 to 10 with new abilities and grander titles on the way up.';

  @override
  String get triviaMedievalStocks =>
      'Every hero wakes up with two responsibilities and a deadline. Skip them often enough and you are punished for it, and that includes the monarch, who can be put in the stocks.';

  @override
  String get triviaMedievalAmbition =>
      'You pick an Ambition for the whole kingdom before you start, and the quests you take are scored against it. It is the closest The Sims has come to a win condition.';

  @override
  String get triviaMedievalQuests =>
      'This is a total conversion rather than a spin-off. The sandbox is replaced by a chain of quests, which is why it is the only Sims game you can actually finish.';

  @override
  String get triviaMedievalPirates =>
      'Pirates and Nobles, from August 2011, was the only add-on it ever got: falcons and parrots, treasure maps and shovels, and a war between two arriving factions.';

  @override
  String get triviaMedievalProxy =>
      'The game was never built to load mods. Script and core mods need the community’s d3dx9_31.dll proxy dropped into Game/Bin before the game will read them at all, though custom content works without it.';

  @override
  String get triviaMedievalEngine =>
      'It runs on The Sims 3’s engine, which is why the Resource.cfg and the .package files look so familiar to anyone who has modded that game.';

  @override
  String get navCreations => 'Creations';

  @override
  String creationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count creations',
      one: '1 creation',
      zero: 'Nothing saved yet',
    );
    return '$_temp0';
  }

  @override
  String get creationsScanning => 'Reading your lots and households…';

  @override
  String get creationsRefresh => 'Refresh';

  @override
  String get creationsAll => 'All';

  @override
  String get creationsBack => '← Back to everything';

  @override
  String get creationsNoneOfKind => 'Nothing of that kind here.';

  @override
  String get creationsEmptyTitle => 'Nothing here yet';

  @override
  String get creationsEmptyBody =>
      'Lots, rooms, households and sims you save in the game show up here — and so does anything you download and drop onto the window.';

  @override
  String creationsBy(String creator) {
    return 'by $creator';
  }

  @override
  String get creationsWhoLivesHere => 'WHO COMES WITH IT';

  @override
  String get creationsShowInFolder => 'Show in folder';

  @override
  String get creationsDelete => 'Delete';

  @override
  String creationsDeleteTitle(String name) {
    return 'Delete “$name”?';
  }

  @override
  String get creationsDeleteBody =>
      'It goes from the game’s folder for good. There’s no undo.';

  @override
  String creationsFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '1 file',
    );
    return '$_temp0';
  }

  @override
  String get creationKindLot => 'Lot';

  @override
  String get creationKindRoom => 'Room';

  @override
  String get creationKindHousehold => 'Household';

  @override
  String get creationKindSim => 'Sim';

  @override
  String get creationFolderSims4Tray => 'Tray';

  @override
  String get creationFolderSims3Library => 'Library';

  @override
  String get creationFolderSims2LotCatalog => 'Lots & Houses bin';

  @override
  String get creationFolderSims2SavedSims => 'Packaged Sims';

  @override
  String creationFolderSims1Houses(String number) {
    return 'Neighborhood $number';
  }

  @override
  String creationBadFileName(String name) {
    return '“$name” has characters this system can’t use in a file name, so the game would never find it. Rename it and try again.';
  }

  @override
  String creationFileInUse(String name) {
    return '“$name” is in use. Close the game and try again.';
  }

  @override
  String get creationSims1PickLot =>
      'The Sims 1 numbers its lots by position on the map, so a house has to take over a lot that\'s already there - and that wipes whatever is on it. Pick the lot yourself: back it up, then rename the download to that lot\'s House number in the Houses folder.';

  @override
  String creationInstallFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Those $count files couldn’t be added.',
      one: 'That file couldn’t be added.',
    );
    return '$_temp0';
  }

  @override
  String creationRemoveFailed(String name) {
    return '“$name” couldn’t be deleted.';
  }

  @override
  String get creationsAdd => 'Add';

  @override
  String get creationsAdding => 'Adding…';

  @override
  String creationsPickerLabel(String game) {
    return '$game lots, rooms, households and Sims';
  }

  @override
  String get creationsNothingToAdd =>
      'Nothing in there was a lot, a room, a household or a Sim this game can use. Custom content and mods go in through the library instead.';

  @override
  String get householdEdit => 'Edit';

  @override
  String get householdEditTitle => 'Edit household';

  @override
  String householdEditBody(String name) {
    return 'Change what the save says about “$name”.';
  }

  @override
  String get householdEditName => 'Name';

  @override
  String get householdEditFunds => 'Funds';

  @override
  String householdEditFundsMax(String max) {
    return 'Up to $max, which is as much as this game will hold.';
  }

  @override
  String get householdEditSave => 'Save changes';

  @override
  String get householdEditNotice =>
      'Close the game first: it writes its own save back when it quits. A copy of the file is kept before anything changes.';

  @override
  String get errorSaveEditHouseholdGone =>
      'That household isn’t in the save any more. Refresh the list and try again.';

  @override
  String errorSaveEditUnreadable(String file) {
    return '“$file” isn’t laid out the way this app knows how to rewrite, so nothing was changed.';
  }

  @override
  String errorSaveEditVerification(String file) {
    return 'The rewritten “$file” didn’t read back the way it should have, so it was thrown away. Your save is untouched.';
  }

  @override
  String get errorSaveEditUnsupported =>
      'This game’s saves can be read, but not changed.';
}
