import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L of(BuildContext context) {
    return Localizations.of<L>(context, L)!;
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('el'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Sims Mod Manager'**
  String get appName;

  /// No description provided for @brandTitle.
  ///
  /// In en, this message translates to:
  /// **'Mod Manager'**
  String get brandTitle;

  /// No description provided for @brandSubtitle.
  ///
  /// In en, this message translates to:
  /// **'for The Sims'**
  String get brandSubtitle;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// No description provided for @navShop.
  ///
  /// In en, this message translates to:
  /// **'The Exchange'**
  String get navShop;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @shopAlphaBadge.
  ///
  /// In en, this message translates to:
  /// **'ALPHA'**
  String get shopAlphaBadge;

  /// No description provided for @shopTagline.
  ///
  /// In en, this message translates to:
  /// **'Mods from the community, installed in one click.'**
  String get shopTagline;

  /// No description provided for @shopListingCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 mod on the shelves} other{{count} mods on the shelves}}'**
  String shopListingCount(int count);

  /// No description provided for @shopRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get shopRefresh;

  /// No description provided for @shopPublish.
  ///
  /// In en, this message translates to:
  /// **'Publish your mods'**
  String get shopPublish;

  /// No description provided for @shopLoadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'The Exchange isn’t answering'**
  String get shopLoadFailedTitle;

  /// No description provided for @shopLoadFailedBody.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t load the shelves. Check your connection and give it another try.'**
  String get shopLoadFailedBody;

  /// No description provided for @shopRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get shopRetry;

  /// No description provided for @shopEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'The shelves are still empty'**
  String get shopEmptyTitle;

  /// No description provided for @shopEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'The Exchange just opened its doors and nobody has published anything yet. That’s how new this is. Made a mod yourself? Be the first on the shelves!'**
  String get shopEmptyBody;

  /// No description provided for @shopAllGames.
  ///
  /// In en, this message translates to:
  /// **'All games'**
  String get shopAllGames;

  /// No description provided for @shopShowAllGames.
  ///
  /// In en, this message translates to:
  /// **'Show every game'**
  String get shopShowAllGames;

  /// No description provided for @shopEmptyGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing for {game} yet'**
  String shopEmptyGameTitle(String game);

  /// No description provided for @shopEmptyGameBody.
  ///
  /// In en, this message translates to:
  /// **'Other games have mods on the shelves, but nobody has published a {game} one yet. Made one? Be the first!'**
  String shopEmptyGameBody(String game);

  /// No description provided for @shopBy.
  ///
  /// In en, this message translates to:
  /// **'by {author}'**
  String shopBy(String author);

  /// No description provided for @shopInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get shopInstalled;

  /// No description provided for @shopUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get shopUpdate;

  /// No description provided for @shopUpdateBadge.
  ///
  /// In en, this message translates to:
  /// **'update'**
  String get shopUpdateBadge;

  /// No description provided for @shopUpdatesWaiting.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 of your mods has a new version on The Exchange} other{{count} of your mods have new versions on The Exchange}}'**
  String shopUpdatesWaiting(int count);

  /// No description provided for @shopUpdateHeading.
  ///
  /// In en, this message translates to:
  /// **'There’s a new version of this one'**
  String get shopUpdateHeading;

  /// No description provided for @shopUpdateBody.
  ///
  /// In en, this message translates to:
  /// **'{author} has published v{version} on The Exchange. Updating replaces the files you have now.'**
  String shopUpdateBody(String version, String author);

  /// No description provided for @shopUpdateSeeListing.
  ///
  /// In en, this message translates to:
  /// **'See the listing'**
  String get shopUpdateSeeListing;

  /// No description provided for @shopInstalling.
  ///
  /// In en, this message translates to:
  /// **'Installing…'**
  String get shopInstalling;

  /// No description provided for @shopInstallNotes.
  ///
  /// In en, this message translates to:
  /// **'Install notes'**
  String get shopInstallNotes;

  /// No description provided for @shopCreatorNudge.
  ///
  /// In en, this message translates to:
  /// **'Made mods yourself? Publishing on The Exchange is free, and players install your work in one click.'**
  String get shopCreatorNudge;

  /// No description provided for @shopNeedsFolder.
  ///
  /// In en, this message translates to:
  /// **'Set up {game}’s mods folder first. The Library tab walks you through it.'**
  String shopNeedsFolder(String game);

  /// No description provided for @shopVariations.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 variation} other{{count} variations}}'**
  String shopVariations(int count);

  /// No description provided for @shopSaveFile.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get shopSaveFile;

  /// No description provided for @shopSaving.
  ///
  /// In en, this message translates to:
  /// **'Downloading…'**
  String get shopSaving;

  /// No description provided for @shopSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get shopSaved;

  /// No description provided for @shopSaveHint.
  ///
  /// In en, this message translates to:
  /// **'Install drops the files straight into your mods folder. Download just saves the file, wherever you want it.'**
  String get shopSaveHint;

  /// No description provided for @shopVariationPick.
  ///
  /// In en, this message translates to:
  /// **'Pick a variation'**
  String get shopVariationPick;

  /// No description provided for @shopBack.
  ///
  /// In en, this message translates to:
  /// **'Back to the shelves'**
  String get shopBack;

  /// No description provided for @shopCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get shopCopyLink;

  /// No description provided for @shopLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get shopLinkCopied;

  /// No description provided for @sidebarGames.
  ///
  /// In en, this message translates to:
  /// **'GAMES'**
  String get sidebarGames;

  /// No description provided for @sidebarNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'not installed · {detail}'**
  String sidebarNotInstalled(String detail);

  /// No description provided for @sidebarModCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 mod} other{{count} mods}} · {detail}'**
  String sidebarModCount(int count, String detail);

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailable;

  /// No description provided for @updateClickToDownload.
  ///
  /// In en, this message translates to:
  /// **'v{version}: click to download'**
  String updateClickToDownload(String version);

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @storageInMods.
  ///
  /// In en, this message translates to:
  /// **'{size} in mods'**
  String storageInMods(String size);

  /// No description provided for @storageFreeOf.
  ///
  /// In en, this message translates to:
  /// **'{free} free of {total}'**
  String storageFreeOf(String free, String total);

  /// No description provided for @dropToInstall.
  ///
  /// In en, this message translates to:
  /// **'Drop to install into {game}'**
  String dropToInstall(String game);

  /// No description provided for @dropFolders.
  ///
  /// In en, this message translates to:
  /// **'folders'**
  String get dropFolders;

  /// No description provided for @scanningMods.
  ///
  /// In en, this message translates to:
  /// **'Looking inside mods for artwork and conflicts… {done} of {total}'**
  String scanningMods(int done, int total);

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'{game} Library'**
  String libraryTitle(String game);

  /// No description provided for @modsShown.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 mod shown} other{{count} mods shown}} · {era}'**
  String modsShown(int count, String era);

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get learnMore;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @searchMods.
  ///
  /// In en, this message translates to:
  /// **'Search mods…'**
  String get searchMods;

  /// No description provided for @viewGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get viewGrid;

  /// No description provided for @viewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get viewList;

  /// No description provided for @viewFolders.
  ///
  /// In en, this message translates to:
  /// **'Folders'**
  String get viewFolders;

  /// No description provided for @sortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortTooltip;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'Name (A–Z)'**
  String get sortByName;

  /// No description provided for @sortByRecent.
  ///
  /// In en, this message translates to:
  /// **'Recently changed'**
  String get sortByRecent;

  /// No description provided for @sortBySize.
  ///
  /// In en, this message translates to:
  /// **'Biggest first'**
  String get sortBySize;

  /// No description provided for @sortDisabledLast.
  ///
  /// In en, this message translates to:
  /// **'Disabled ones last'**
  String get sortDisabledLast;

  /// No description provided for @libraryRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get libraryRefresh;

  /// No description provided for @libraryRootFolder.
  ///
  /// In en, this message translates to:
  /// **'Mods folder'**
  String get libraryRootFolder;

  /// No description provided for @selectionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectionTooltip;

  /// No description provided for @selectionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 selected} other{{count} selected}}'**
  String selectionCount(int count);

  /// No description provided for @selectionSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectionSelectAll;

  /// No description provided for @selectionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get selectionClear;

  /// No description provided for @selectionEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get selectionEnable;

  /// No description provided for @selectionDisable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get selectionDisable;

  /// No description provided for @selectionProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String selectionProgress(int done, int total);

  /// No description provided for @selectionDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Uninstall 1 mod?} other{Uninstall {count} mods?}}'**
  String selectionDeleteTitle(int count);

  /// No description provided for @selectionDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The file will be deleted from disk. There’s no undo.} other{All {count} files will be deleted from disk. There’s no undo.}}'**
  String selectionDeleteBody(int count);

  /// No description provided for @selectionMove.
  ///
  /// In en, this message translates to:
  /// **'Move to…'**
  String get selectionMove;

  /// No description provided for @newFolder.
  ///
  /// In en, this message translates to:
  /// **'New folder'**
  String get newFolder;

  /// No description provided for @newFolderIn.
  ///
  /// In en, this message translates to:
  /// **'Inside {folder}'**
  String newFolderIn(String folder);

  /// No description provided for @newFolderHint.
  ///
  /// In en, this message translates to:
  /// **'Folder name'**
  String get newFolderHint;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @move.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get move;

  /// No description provided for @moveTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Move 1 mod where?} other{Move {count} mods where?}}'**
  String moveTitle(int count);

  /// No description provided for @moveBody.
  ///
  /// In en, this message translates to:
  /// **'The files move on disk. Nothing else about them changes - anything switched off stays off.'**
  String get moveBody;

  /// No description provided for @folderEmptySection.
  ///
  /// In en, this message translates to:
  /// **'Nothing in here yet'**
  String get folderEmptySection;

  /// No description provided for @install.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get install;

  /// No description provided for @filePickerModsLabel.
  ///
  /// In en, this message translates to:
  /// **'{game} mods'**
  String filePickerModsLabel(String game);

  /// No description provided for @installWhereTitle.
  ///
  /// In en, this message translates to:
  /// **'Where should this go?'**
  String get installWhereTitle;

  /// No description provided for @installWhereBody.
  ///
  /// In en, this message translates to:
  /// **'{game} reads mods from several folders. The app can work it out from the file itself, or you can say where it belongs.'**
  String installWhereBody(String game);

  /// No description provided for @installWhereSorted.
  ///
  /// In en, this message translates to:
  /// **'Sort it out for me'**
  String get installWhereSorted;

  /// No description provided for @installWhereSortedDesc.
  ///
  /// In en, this message translates to:
  /// **'Follow the folders the download names, then place the rest by file type.'**
  String get installWhereSortedDesc;

  /// No description provided for @installWhereRemember.
  ///
  /// In en, this message translates to:
  /// **'Don’t ask again'**
  String get installWhereRemember;

  /// No description provided for @destinationSims1Downloads.
  ///
  /// In en, this message translates to:
  /// **'Objects, hacks and most downloads.'**
  String get destinationSims1Downloads;

  /// No description provided for @destinationSims1Global.
  ///
  /// In en, this message translates to:
  /// **'Overrides that change the base game everywhere.'**
  String get destinationSims1Global;

  /// No description provided for @destinationSims1Objects.
  ///
  /// In en, this message translates to:
  /// **'Overrides for the game’s own object files.'**
  String get destinationSims1Objects;

  /// No description provided for @destinationSims1Skins.
  ///
  /// In en, this message translates to:
  /// **'Everyday skins and heads. These show up in Create a Sim.'**
  String get destinationSims1Skins;

  /// No description provided for @destinationSims1SkinsBuy.
  ///
  /// In en, this message translates to:
  /// **'Clothing sold in community lot stores.'**
  String get destinationSims1SkinsBuy;

  /// No description provided for @destinationSims1Walls.
  ///
  /// In en, this message translates to:
  /// **'Wall coverings.'**
  String get destinationSims1Walls;

  /// No description provided for @destinationSims1Floors.
  ///
  /// In en, this message translates to:
  /// **'Floor tiles.'**
  String get destinationSims1Floors;

  /// No description provided for @destinationSims1Roofs.
  ///
  /// In en, this message translates to:
  /// **'Roof textures.'**
  String get destinationSims1Roofs;

  /// No description provided for @prefAskWhereTitle.
  ///
  /// In en, this message translates to:
  /// **'Ask where to install'**
  String get prefAskWhereTitle;

  /// No description provided for @prefAskWhereDesc.
  ///
  /// In en, this message translates to:
  /// **'This game reads mods from more than one folder. Choose the folder each time instead of letting the app decide'**
  String get prefAskWhereDesc;

  /// No description provided for @statTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get statTotal;

  /// No description provided for @statEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get statEnabled;

  /// No description provided for @statDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get statDisabled;

  /// No description provided for @statConflicts.
  ///
  /// In en, this message translates to:
  /// **'Conflicts'**
  String get statConflicts;

  /// No description provided for @statTotalTooltip.
  ///
  /// In en, this message translates to:
  /// **'Every mod in this folder, switched on or off.'**
  String get statTotalTooltip;

  /// No description provided for @statTotalTooltipClear.
  ///
  /// In en, this message translates to:
  /// **'Every mod in this folder. Click to drop the search and every filter.'**
  String get statTotalTooltipClear;

  /// No description provided for @statEnabledTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mods the game loads.'**
  String get statEnabledTooltip;

  /// No description provided for @statEnabledTooltipActive.
  ///
  /// In en, this message translates to:
  /// **'Showing enabled mods only. Click to show all mods again.'**
  String get statEnabledTooltipActive;

  /// No description provided for @statDisabledTooltip.
  ///
  /// In en, this message translates to:
  /// **'Mods sitting in the folder switched off.'**
  String get statDisabledTooltip;

  /// No description provided for @statDisabledTooltipActive.
  ///
  /// In en, this message translates to:
  /// **'Showing disabled mods only. Click to show all mods again.'**
  String get statDisabledTooltipActive;

  /// No description provided for @conflictTooltipActive.
  ///
  /// In en, this message translates to:
  /// **'Showing conflicting mods only. Click to show all mods again.'**
  String get conflictTooltipActive;

  /// No description provided for @conflictTooltip.
  ///
  /// In en, this message translates to:
  /// **'Enabled mods sharing a file name with another enabled mod, installed in more than one version, or overriding the same in-game resources. The game only keeps the copy it loads last, sometimes intentional (patch mods), often not.'**
  String get conflictTooltip;

  /// No description provided for @conflictTooltipClickHint.
  ///
  /// In en, this message translates to:
  /// **'Click to show only these mods.'**
  String get conflictTooltipClickHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @emptyFiltered.
  ///
  /// In en, this message translates to:
  /// **'No mods match your filters'**
  String get emptyFiltered;

  /// No description provided for @emptyNoMods.
  ///
  /// In en, this message translates to:
  /// **'No mods yet'**
  String get emptyNoMods;

  /// No description provided for @emptyFilteredHint.
  ///
  /// In en, this message translates to:
  /// **'Try clearing the search or picking another filter.'**
  String get emptyFilteredHint;

  /// No description provided for @emptyNoModsHint.
  ///
  /// In en, this message translates to:
  /// **'This folder is being watched:\n{path}'**
  String emptyNoModsHint(String path);

  /// No description provided for @openFolder.
  ///
  /// In en, this message translates to:
  /// **'Open folder'**
  String get openFolder;

  /// No description provided for @conflictBadge.
  ///
  /// In en, this message translates to:
  /// **'conflict'**
  String get conflictBadge;

  /// No description provided for @modInFolder.
  ///
  /// In en, this message translates to:
  /// **'in {folder}'**
  String modInFolder(String folder);

  /// No description provided for @modInModsFolder.
  ///
  /// In en, this message translates to:
  /// **'in Mods folder'**
  String get modInModsFolder;

  /// No description provided for @setupFoundNoModsFolder.
  ///
  /// In en, this message translates to:
  /// **'{game} found, but no mods folder yet'**
  String setupFoundNoModsFolder(String game);

  /// No description provided for @setupNotFound.
  ///
  /// In en, this message translates to:
  /// **'{game} mods folder not found'**
  String setupNotFound(String game);

  /// No description provided for @setupFoundNoModsFolderBody.
  ///
  /// In en, this message translates to:
  /// **'The game\'s folder is on this computer; it just doesn\'t contain a mods folder yet. Create it below, or point at one manually.'**
  String get setupFoundNoModsFolderBody;

  /// No description provided for @setupNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'The game may not be installed, may live somewhere unusual, or its mods folder may not exist yet.'**
  String get setupNotFoundBody;

  /// No description provided for @foundOnThisComputer.
  ///
  /// In en, this message translates to:
  /// **'FOUND ON THIS COMPUTER'**
  String get foundOnThisComputer;

  /// No description provided for @chooseFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose folder…'**
  String get chooseFolder;

  /// No description provided for @createItForMe.
  ///
  /// In en, this message translates to:
  /// **'Create it for me'**
  String get createItForMe;

  /// No description provided for @willBeCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Will be created at:\n{path}'**
  String willBeCreatedAt(String path);

  /// No description provided for @checkAgain.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get checkAgain;

  /// No description provided for @useThis.
  ///
  /// In en, this message translates to:
  /// **'Use this'**
  String get useThis;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @showInFileManager.
  ///
  /// In en, this message translates to:
  /// **'Show in file manager'**
  String get showInFileManager;

  /// No description provided for @uninstallMod.
  ///
  /// In en, this message translates to:
  /// **'Uninstall mod'**
  String get uninstallMod;

  /// No description provided for @uninstallConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Uninstall {title}?'**
  String uninstallConfirmTitle(String title);

  /// No description provided for @uninstallConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'The file will be deleted from disk:\n{path}'**
  String uninstallConfirmBody(String path);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @uninstall.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get uninstall;

  /// No description provided for @conflictSameNameHeading.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Another enabled mod has the same file name:} other{{count} other enabled mods have the same file name:}}'**
  String conflictSameNameHeading(int count);

  /// No description provided for @conflictVersionHeading.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Another enabled mod looks like a different version of this mod:} other{{count} other enabled mods look like different versions of this mod:}}'**
  String conflictVersionHeading(int count);

  /// No description provided for @conflictResourcesHeading.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Another enabled mod overrides the same in-game resources:} other{{count} other enabled mods override the same in-game resources:}}'**
  String conflictResourcesHeading(int count);

  /// No description provided for @sharedResources.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 shared resource} other{{count} shared resources}}'**
  String sharedResources(int count);

  /// No description provided for @conflictSameNameBody.
  ///
  /// In en, this message translates to:
  /// **'Identical names usually mean the same mod is installed twice, or two creators\' packages clash. The game loads their overlapping resources in an unpredictable order: keep one and disable or remove the rest.'**
  String get conflictSameNameBody;

  /// No description provided for @conflictVersionBody.
  ///
  /// In en, this message translates to:
  /// **'Having several versions of a mod installed means the game loads their overlapping resources in an unpredictable order: keep the newest and disable or remove the rest.'**
  String get conflictVersionBody;

  /// No description provided for @conflictResourcesBody.
  ///
  /// In en, this message translates to:
  /// **'These packages contain resources with the same identifiers, so the game only keeps the copy it loads last. That can be intentional (patch and override mods shadow another mod\'s resources on purpose), but for unrelated mods it means one of them silently stops working: keep the one you want and disable the rest.'**
  String get conflictResourcesBody;

  /// No description provided for @conflictIgnore.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get conflictIgnore;

  /// No description provided for @conflictIgnoreTooltip.
  ///
  /// In en, this message translates to:
  /// **'If this conflict is on purpose, hide it. Nothing about the mod changes, and you can bring the warning back from this page or from Settings.'**
  String get conflictIgnoreTooltip;

  /// No description provided for @conflictRestore.
  ///
  /// In en, this message translates to:
  /// **'Bring back'**
  String get conflictRestore;

  /// No description provided for @advisoryBanner.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{One of your mods has a known issue} other{{count} of your mods have known issues}}'**
  String advisoryBanner(int count);

  /// No description provided for @advisoryShow.
  ///
  /// In en, this message translates to:
  /// **'Take a look'**
  String get advisoryShow;

  /// No description provided for @advisoryShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all mods'**
  String get advisoryShowAll;

  /// No description provided for @advisoryBadge.
  ///
  /// In en, this message translates to:
  /// **'issue'**
  String get advisoryBadge;

  /// No description provided for @advisoryBrokenHeading.
  ///
  /// In en, this message translates to:
  /// **'This mod is reported broken'**
  String get advisoryBrokenHeading;

  /// No description provided for @advisoryBrokenBody.
  ///
  /// In en, this message translates to:
  /// **'Other players are reporting that this one stops the game working. Disabling it is the quickest way to find out if it\'s behind your problem.'**
  String get advisoryBrokenBody;

  /// No description provided for @advisoryOutdatedHeading.
  ///
  /// In en, this message translates to:
  /// **'There\'s a newer version of this mod'**
  String get advisoryOutdatedHeading;

  /// No description provided for @advisoryOutdatedBody.
  ///
  /// In en, this message translates to:
  /// **'The version you\'ve got is the one people are having trouble with. Grabbing the creator\'s latest should sort it.'**
  String get advisoryOutdatedBody;

  /// No description provided for @advisoryCautionHeading.
  ///
  /// In en, this message translates to:
  /// **'Worth keeping an eye on'**
  String get advisoryCautionHeading;

  /// No description provided for @advisoryCautionBody.
  ///
  /// In en, this message translates to:
  /// **'This one works for most people, but it\'s been known to misbehave. Worth disabling if you\'re hunting down a problem.'**
  String get advisoryCautionBody;

  /// No description provided for @advisorySince.
  ///
  /// In en, this message translates to:
  /// **'Since {since}'**
  String advisorySince(String since);

  /// No description provided for @advisoryOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Open the creator\'s page'**
  String get advisoryOpenLink;

  /// No description provided for @advisorySource.
  ///
  /// In en, this message translates to:
  /// **'Reported by other players, not by the game.'**
  String get advisorySource;

  /// No description provided for @modInDirectory.
  ///
  /// In en, this message translates to:
  /// **'in {dir}'**
  String modInDirectory(String dir);

  /// No description provided for @factVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get factVersion;

  /// No description provided for @factFormat.
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get factFormat;

  /// No description provided for @factSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get factSize;

  /// No description provided for @factType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get factType;

  /// No description provided for @factModified.
  ///
  /// In en, this message translates to:
  /// **'Modified'**
  String get factModified;

  /// No description provided for @factDownloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get factDownloads;

  /// No description provided for @factIgnoredConflicts.
  ///
  /// In en, this message translates to:
  /// **'Ignored'**
  String get factIgnoredConflicts;

  /// No description provided for @ignoredConflictsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 conflict} other{{count} conflicts}}'**
  String ignoredConflictsCount(int count);

  /// No description provided for @statusHeading.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusHeading;

  /// No description provided for @statusEnabledBody.
  ///
  /// In en, this message translates to:
  /// **'This mod is active: the game will load it on next launch.'**
  String get statusEnabledBody;

  /// No description provided for @statusDisabledBody.
  ///
  /// In en, this message translates to:
  /// **'This mod is disabled: the file is kept on disk with a \"{marker}\" marker so the game skips it. Enable it any time; nothing is deleted.'**
  String statusDisabledBody(String marker);

  /// No description provided for @fileOnDisk.
  ///
  /// In en, this message translates to:
  /// **'File on disk'**
  String get fileOnDisk;

  /// No description provided for @insideThePackage.
  ///
  /// In en, this message translates to:
  /// **'Inside the package'**
  String get insideThePackage;

  /// No description provided for @resourcesTotal.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 resource total} other{{count} resources total}}'**
  String resourcesTotal(int count);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @sectionModManagement.
  ///
  /// In en, this message translates to:
  /// **'MOD MANAGEMENT'**
  String get sectionModManagement;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get sectionAppearance;

  /// No description provided for @sectionLanguage.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get sectionLanguage;

  /// No description provided for @sectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY'**
  String get sectionPrivacy;

  /// No description provided for @sectionModsFolder.
  ///
  /// In en, this message translates to:
  /// **'MODS FOLDER · {game}'**
  String sectionModsFolder(String game);

  /// No description provided for @sectionGameCaches.
  ///
  /// In en, this message translates to:
  /// **'GAME CACHES · {game}'**
  String sectionGameCaches(String game);

  /// No description provided for @sectionIgnoredConflicts.
  ///
  /// In en, this message translates to:
  /// **'IGNORED CONFLICTS · {game}'**
  String sectionIgnoredConflicts(String game);

  /// No description provided for @sectionFeedback.
  ///
  /// In en, this message translates to:
  /// **'FEEDBACK'**
  String get sectionFeedback;

  /// No description provided for @sectionAbout.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get sectionAbout;

  /// No description provided for @prefWarnConflictsTitle.
  ///
  /// In en, this message translates to:
  /// **'Warn about conflicts'**
  String get prefWarnConflictsTitle;

  /// No description provided for @prefWarnConflictsDesc.
  ///
  /// In en, this message translates to:
  /// **'Badge enabled mods that duplicate a file name or override the same in-game resources as another mod'**
  String get prefWarnConflictsDesc;

  /// No description provided for @prefConfirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm before uninstalling'**
  String get prefConfirmDeleteTitle;

  /// No description provided for @prefConfirmDeleteDesc.
  ///
  /// In en, this message translates to:
  /// **'Ask before a mod file is deleted from disk'**
  String get prefConfirmDeleteDesc;

  /// No description provided for @prefShowDisabledTitle.
  ///
  /// In en, this message translates to:
  /// **'Show disabled mods'**
  String get prefShowDisabledTitle;

  /// No description provided for @prefShowDisabledDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep disabled mods visible in the library instead of hiding them'**
  String get prefShowDisabledDesc;

  /// No description provided for @prefDisabledSuffixTitle.
  ///
  /// In en, this message translates to:
  /// **'Disabled mod marker'**
  String get prefDisabledSuffixTitle;

  /// No description provided for @prefDisabledSuffixDesc.
  ///
  /// In en, this message translates to:
  /// **'What gets added to a file name when you switch a mod off. Change it to match another manager (CC Magic uses .off); the app reads both either way, and mods you already disabled keep the name they have'**
  String get prefDisabledSuffixDesc;

  /// No description provided for @prefDisabledSuffixInvalid.
  ///
  /// In en, this message translates to:
  /// **'Needs to be a dot and a few letters or numbers, like .off'**
  String get prefDisabledSuffixInvalid;

  /// No description provided for @prefExperimentalPacksTitle.
  ///
  /// In en, this message translates to:
  /// **'Experimental pack switches'**
  String get prefExperimentalPacksTitle;

  /// No description provided for @prefExperimentalPacksDesc.
  ///
  /// In en, this message translates to:
  /// **'Let this game’s packs be switched off. Untested on this release, and a neighbourhood played with a pack can break without it — back your saves up first'**
  String get prefExperimentalPacksDesc;

  /// No description provided for @prefScanArtworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan inside mods'**
  String get prefScanArtworkTitle;

  /// No description provided for @prefScanArtworkDesc.
  ///
  /// In en, this message translates to:
  /// **'Look inside mod files while the library loads for embedded artwork, content details and mods that override the same resources'**
  String get prefScanArtworkDesc;

  /// No description provided for @prefSoundEffectsTitle.
  ///
  /// In en, this message translates to:
  /// **'UI sound effects'**
  String get prefSoundEffectsTitle;

  /// No description provided for @prefSoundEffectsDesc.
  ///
  /// In en, this message translates to:
  /// **'Play the classic Sims interface sounds on clicks, toggles and alerts'**
  String get prefSoundEffectsDesc;

  /// No description provided for @prefAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Share anonymous usage data'**
  String get prefAnalyticsTitle;

  /// No description provided for @prefAnalyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Send anonymous usage statistics and crash reports to help improve the app. Never includes mod names, file paths or anything personal'**
  String get prefAnalyticsDesc;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @themeDesc.
  ///
  /// In en, this message translates to:
  /// **'Light or dark. “System” follows your computer\'s setting.'**
  String get themeDesc;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get languageTitle;

  /// No description provided for @languageDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose the language the app is shown in. “System” follows your computer\'s language.'**
  String get languageDesc;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @translatorsTitle.
  ///
  /// In en, this message translates to:
  /// **'Translated by'**
  String get translatorsTitle;

  /// No description provided for @translatorsDesc.
  ///
  /// In en, this message translates to:
  /// **'The app speaks eleven languages thanks to these simmers.'**
  String get translatorsDesc;

  /// No description provided for @folderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found. Choose a folder'**
  String get folderNotFound;

  /// No description provided for @folderNotLocated.
  ///
  /// In en, this message translates to:
  /// **'The game (or its mods folder) was not located automatically'**
  String get folderNotLocated;

  /// No description provided for @folderSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 mod} other{{count} mods}} · {size} on disk'**
  String folderSummary(int count, String size);

  /// No description provided for @customFolder.
  ///
  /// In en, this message translates to:
  /// **'custom folder'**
  String get customFolder;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change…'**
  String get change;

  /// No description provided for @resetToAuto.
  ///
  /// In en, this message translates to:
  /// **'Reset to auto'**
  String get resetToAuto;

  /// No description provided for @createDefaultFolderAt.
  ///
  /// In en, this message translates to:
  /// **'Create the default folder (with the files the game needs) at:\n{path}'**
  String createDefaultFolderAt(String path);

  /// No description provided for @createFolder.
  ///
  /// In en, this message translates to:
  /// **'Create folder'**
  String get createFolder;

  /// No description provided for @alsoFoundOnThisComputer.
  ///
  /// In en, this message translates to:
  /// **'Also found on this computer:'**
  String get alsoFoundOnThisComputer;

  /// No description provided for @clearCacheTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear cache files'**
  String get clearCacheTitle;

  /// No description provided for @clearCacheDesc.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Delete 1 cache file ({size})} other{Delete {count} cache files ({size})}} so newly added or removed content shows up; the game rebuilds them on its next launch'**
  String clearCacheDesc(int count, String size);

  /// No description provided for @clearCaches.
  ///
  /// In en, this message translates to:
  /// **'Clear caches'**
  String get clearCaches;

  /// No description provided for @ignoredConflictsTitle.
  ///
  /// In en, this message translates to:
  /// **'Conflicts you\'re ignoring'**
  String get ignoredConflictsTitle;

  /// No description provided for @ignoredConflictsDesc.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{One conflict you told the app to stop reporting. Bring it back to see it in the library again} other{{count} conflicts you told the app to stop reporting. Bring them back to see them in the library again}}'**
  String ignoredConflictsDesc(int count);

  /// No description provided for @ignoredConflictsReset.
  ///
  /// In en, this message translates to:
  /// **'Bring them back'**
  String get ignoredConflictsReset;

  /// No description provided for @reportBugTitle.
  ///
  /// In en, this message translates to:
  /// **'Report a bug'**
  String get reportBugTitle;

  /// No description provided for @reportBugDesc.
  ///
  /// In en, this message translates to:
  /// **'Open a bug report on GitHub; your app version, OS and current game come prefilled'**
  String get reportBugDesc;

  /// No description provided for @reportBugButton.
  ///
  /// In en, this message translates to:
  /// **'Report…'**
  String get reportBugButton;

  /// No description provided for @suggestFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Suggest a feature'**
  String get suggestFeatureTitle;

  /// No description provided for @suggestFeatureDesc.
  ///
  /// In en, this message translates to:
  /// **'Missing something? Tell us what would make the mod manager better'**
  String get suggestFeatureDesc;

  /// No description provided for @suggestFeatureButton.
  ///
  /// In en, this message translates to:
  /// **'Suggest…'**
  String get suggestFeatureButton;

  /// No description provided for @wikiTitle.
  ///
  /// In en, this message translates to:
  /// **'User guide & FAQ'**
  String get wikiTitle;

  /// No description provided for @wikiDesc.
  ///
  /// In en, this message translates to:
  /// **'How to install mods, fix folder detection, and more, on the project wiki'**
  String get wikiDesc;

  /// No description provided for @wikiButton.
  ///
  /// In en, this message translates to:
  /// **'Open wiki'**
  String get wikiButton;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Version {version} · The Sims 1–4 supported · SimCity coming soon'**
  String aboutTagline(String version);

  /// No description provided for @updateIsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Version {version} is available'**
  String updateIsAvailable(String version);

  /// No description provided for @noUpdateFound.
  ///
  /// In en, this message translates to:
  /// **'No update found'**
  String get noUpdateFound;

  /// No description provided for @getVersion.
  ///
  /// In en, this message translates to:
  /// **'Get v{version}'**
  String getVersion(String version);

  /// No description provided for @checkingForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get checkingForUpdates;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// No description provided for @categoryPackage.
  ///
  /// In en, this message translates to:
  /// **'Package'**
  String get categoryPackage;

  /// No description provided for @categoryScript.
  ///
  /// In en, this message translates to:
  /// **'Script'**
  String get categoryScript;

  /// No description provided for @categoryObject.
  ///
  /// In en, this message translates to:
  /// **'Object'**
  String get categoryObject;

  /// No description provided for @categoryArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get categoryArchive;

  /// No description provided for @categorySkin.
  ///
  /// In en, this message translates to:
  /// **'Skin'**
  String get categorySkin;

  /// No description provided for @categoryTexture.
  ///
  /// In en, this message translates to:
  /// **'Texture'**
  String get categoryTexture;

  /// No description provided for @categoryWall.
  ///
  /// In en, this message translates to:
  /// **'Wall'**
  String get categoryWall;

  /// No description provided for @categoryFloor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get categoryFloor;

  /// No description provided for @contentCasParts.
  ///
  /// In en, this message translates to:
  /// **'CAS parts'**
  String get contentCasParts;

  /// No description provided for @contentObjects.
  ///
  /// In en, this message translates to:
  /// **'objects'**
  String get contentObjects;

  /// No description provided for @contentTunings.
  ///
  /// In en, this message translates to:
  /// **'tunings'**
  String get contentTunings;

  /// No description provided for @contentBehaviors.
  ///
  /// In en, this message translates to:
  /// **'behaviors'**
  String get contentBehaviors;

  /// No description provided for @contentTextTables.
  ///
  /// In en, this message translates to:
  /// **'text tables'**
  String get contentTextTables;

  /// No description provided for @contentTextures.
  ///
  /// In en, this message translates to:
  /// **'textures'**
  String get contentTextures;

  /// No description provided for @contentMeshes.
  ///
  /// In en, this message translates to:
  /// **'meshes'**
  String get contentMeshes;

  /// No description provided for @errorNoModFiles.
  ///
  /// In en, this message translates to:
  /// **'No mod files ({extensions}) found inside {name}.'**
  String errorNoModFiles(String extensions, String name);

  /// No description provided for @errorUnreadableArchive.
  ///
  /// In en, this message translates to:
  /// **'{name} isn’t a zip archive this app can read.'**
  String errorUnreadableArchive(String name);

  /// No description provided for @errorNoUnpacker.
  ///
  /// In en, this message translates to:
  /// **'Nothing on this computer can unpack {format} archives. Unpack {name} yourself and install the files inside.'**
  String errorNoUnpacker(String format, String name);

  /// No description provided for @errorNoUnpackerLinux.
  ///
  /// In en, this message translates to:
  /// **'Nothing on this computer can unpack {format} archives. Install p7zip and try again, or unpack {name} yourself and install the files inside.'**
  String errorNoUnpackerLinux(String format, String name);

  /// No description provided for @errorNoUnpackerLinuxRar.
  ///
  /// In en, this message translates to:
  /// **'Nothing on this computer can unpack {format} archives. Install p7zip or unrar and try again, or unpack {name} yourself and install the files inside.'**
  String errorNoUnpackerLinuxRar(String format, String name);

  /// No description provided for @errorUnpackFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t unpack {name}. It may be password-protected, one part of a split archive, or a damaged download. Unpack it manually and install the files inside.'**
  String errorUnpackFailed(String name);

  /// No description provided for @errorSims3PackUnreadable.
  ///
  /// In en, this message translates to:
  /// **'{name} isn’t a Sims 3 package this app can read.'**
  String errorSims3PackUnreadable(String name);

  /// No description provided for @errorSims3PackWorld.
  ///
  /// In en, this message translates to:
  /// **'{name} is a world, not custom content. Install it with The Sims 3 Launcher - the game keeps worlds outside the mods folder.'**
  String errorSims3PackWorld(String name);

  /// No description provided for @errorSims3PackLibrary.
  ///
  /// In en, this message translates to:
  /// **'{name} is a lot or a household, not custom content. Install it with The Sims 3 Launcher - it lands in your in-game Library.'**
  String errorSims3PackLibrary(String name);

  /// No description provided for @errorInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'“{name}” couldn’t be installed - {reason}. Unpack it manually and install the files inside if it keeps failing.'**
  String errorInstallFailed(String name, String reason);

  /// No description provided for @errorInstallFailedRaw.
  ///
  /// In en, this message translates to:
  /// **'“{name}” couldn’t be installed - {reason}'**
  String errorInstallFailedRaw(String name, String reason);

  /// No description provided for @errorFileInUseDelete.
  ///
  /// In en, this message translates to:
  /// **'“{name}” couldn’t be deleted - it’s in use by another program (is the game running?) or write-protected. Close anything using it and try again.'**
  String errorFileInUseDelete(String name);

  /// No description provided for @errorFileInUseRename.
  ///
  /// In en, this message translates to:
  /// **'“{name}” couldn’t be renamed - it’s in use by another program (is the game running?) or write-protected. Close anything using it and try again.'**
  String errorFileInUseRename(String name);

  /// No description provided for @errorFileNameTaken.
  ///
  /// In en, this message translates to:
  /// **'“{name}” is already in that folder. Rename one of the two and try again.'**
  String errorFileNameTaken(String name);

  /// No description provided for @errorFolderNameBad.
  ///
  /// In en, this message translates to:
  /// **'“{name}” won’t work as a folder name. Try one without slashes or characters your system keeps for itself.'**
  String errorFolderNameBad(String name);

  /// No description provided for @errorFolderTooDeep.
  ///
  /// In en, this message translates to:
  /// **'The game only looks {levels} folders deep inside the mods folder, so nothing you put below that would ever load.'**
  String errorFolderTooDeep(int levels);

  /// No description provided for @errorBulkMoveFailed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 mod couldn’t be moved} other{{count} mods couldn’t be moved}} - they may be in use by another program (is the game running?), write-protected, or already in that folder under the same name.'**
  String errorBulkMoveFailed(int count);

  /// No description provided for @errorBulkToggleFailed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 mod couldn’t be switched over} other{{count} mods couldn’t be switched over}} - they may be in use by another program (is the game running?) or write-protected.'**
  String errorBulkToggleFailed(int count);

  /// No description provided for @errorBulkRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 mod couldn’t be deleted} other{{count} mods couldn’t be deleted}} - they may be in use by another program (is the game running?) or write-protected.'**
  String errorBulkRemoveFailed(int count);

  /// No description provided for @errorFileMissing.
  ///
  /// In en, this message translates to:
  /// **'“{name}” is no longer in the mods folder - it may have been moved or deleted by another program.'**
  String errorFileMissing(String name);

  /// No description provided for @requirementMedievalModLoader.
  ///
  /// In en, this message translates to:
  /// **'The Sims Medieval can’t run script or core mods without the community’s loader file in the game’s Game\\Bin folder. Custom content works without it; everything else doesn’t.'**
  String get requirementMedievalModLoader;

  /// No description provided for @requirementSims4ModsOff.
  ///
  /// In en, this message translates to:
  /// **'The game has custom content and mods switched off in its own Game Options, so none of this is loading. Turn it back on under Options → Game Options → Other, then restart the game.'**
  String get requirementSims4ModsOff;

  /// No description provided for @requirementSims4ScriptModsOff.
  ///
  /// In en, this message translates to:
  /// **'You have script mods here, but the game has “Script Mods Allowed” switched off in its own Game Options. Game updates reset that.'**
  String get requirementSims4ScriptModsOff;

  /// No description provided for @requirementGetFile.
  ///
  /// In en, this message translates to:
  /// **'Where to get it'**
  String get requirementGetFile;

  /// No description provided for @tooDeepBanner.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{One mod is} other{{count} mods are}} in a subfolder the game doesn’t read. It only looks {levels} folders deep inside the mods folder - move them higher up and they’ll load.'**
  String tooDeepBanner(int count, int levels);

  /// No description provided for @tooDeepShow.
  ///
  /// In en, this message translates to:
  /// **'Show them'**
  String get tooDeepShow;

  /// No description provided for @errorNoWriteAccess.
  ///
  /// In en, this message translates to:
  /// **'The app isn’t allowed to write to “{folder}”. Your system protects that folder - give your account write access to it, or point the app somewhere else in Settings.'**
  String errorNoWriteAccess(String folder);

  /// No description provided for @folderReadOnlyBanner.
  ///
  /// In en, this message translates to:
  /// **'This mods folder is read-only, so installing and removing mods won’t work until your account can write to it.'**
  String get folderReadOnlyBanner;

  /// No description provided for @elevatedNoDropBanner.
  ///
  /// In en, this message translates to:
  /// **'You’re running as administrator, so Windows won’t let you drag files onto the window. Use the Install button instead - that still works.'**
  String get elevatedNoDropBanner;

  /// No description provided for @errorShopDownload.
  ///
  /// In en, this message translates to:
  /// **'“{name}” couldn’t be downloaded from The Exchange. Check your connection and try again.'**
  String errorShopDownload(String name);

  /// No description provided for @errorShopNoModFiles.
  ///
  /// In en, this message translates to:
  /// **'There’s nothing this game can install inside “{name}”. It might not be a mod at all - use Download to save the file wherever you want it.'**
  String errorShopNoModFiles(String name);

  /// No description provided for @errorShopListingNotFound.
  ///
  /// In en, this message translates to:
  /// **'That mod isn’t on The Exchange any more. It may have been taken down.'**
  String get errorShopListingNotFound;

  /// No description provided for @errorShopListingUnknownGame.
  ///
  /// In en, this message translates to:
  /// **'That mod is for a game this version of the app doesn’t know yet. Try updating.'**
  String get errorShopListingUnknownGame;

  /// No description provided for @errorPackToggleFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t switch {pack}. Close the game and try again.'**
  String errorPackToggleFailed(String pack);

  /// No description provided for @errorPackNoUserData.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t find the game’s own settings folder, so there’s nowhere to note which packs to skip. Run the game once first.'**
  String get errorPackNoUserData;

  /// No description provided for @errorPackNeedsAdmin.
  ///
  /// In en, this message translates to:
  /// **'Windows wouldn’t let the app change that. Restart it as an administrator and try again.'**
  String get errorPackNeedsAdmin;

  /// No description provided for @errorPackNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Packs can’t be switched on this system.'**
  String get errorPackNotSupported;

  /// No description provided for @errorPackIsTheGame.
  ///
  /// In en, this message translates to:
  /// **'That’s the pack the game actually runs from, so it has to stay on.'**
  String get errorPackIsTheGame;

  /// No description provided for @errorPackToggleRefused.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t change that pack. Close the game and try again.'**
  String get errorPackToggleRefused;

  /// No description provided for @eraClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get eraClassic;

  /// No description provided for @eraNightlife.
  ///
  /// In en, this message translates to:
  /// **'Nightlife'**
  String get eraNightlife;

  /// No description provided for @eraAmbitions.
  ///
  /// In en, this message translates to:
  /// **'Ambitions'**
  String get eraAmbitions;

  /// No description provided for @eraModern.
  ///
  /// In en, this message translates to:
  /// **'Modern'**
  String get eraModern;

  /// No description provided for @eraMedieval.
  ///
  /// In en, this message translates to:
  /// **'Medieval'**
  String get eraMedieval;

  /// No description provided for @navPacks.
  ///
  /// In en, this message translates to:
  /// **'Packs'**
  String get navPacks;

  /// No description provided for @packsScanning.
  ///
  /// In en, this message translates to:
  /// **'Looking for your packs…'**
  String get packsScanning;

  /// No description provided for @packsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No packs found'**
  String get packsEmptyTitle;

  /// No description provided for @packsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Either {game} isn\'t installed where the app can see it, or there are no packs alongside it yet.'**
  String packsEmptyBody(String game);

  /// No description provided for @packsRescan.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get packsRescan;

  /// No description provided for @packsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pack installed} other{{count} packs installed}}'**
  String packsSummary(int count);

  /// No description provided for @packsSummaryWithOff.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pack on} other{{count} packs on}}, {off} switched off'**
  String packsSummaryWithOff(int count, int off);

  /// No description provided for @packsOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get packsOff;

  /// No description provided for @packsInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get packsInstalled;

  /// No description provided for @packsNeedAdmin.
  ///
  /// In en, this message translates to:
  /// **'Switching these packs on and off needs administrator rights, because that’s where the game keeps its list. Restart the app as an administrator to change them — drag and drop stops working while you do, so it’s worth switching back afterwards.'**
  String get packsNeedAdmin;

  /// No description provided for @packsExperimentalTitle.
  ///
  /// In en, this message translates to:
  /// **'Switching these off is experimental'**
  String get packsExperimentalTitle;

  /// No description provided for @packsExperimentalOff.
  ///
  /// In en, this message translates to:
  /// **'It works the way it always has for this game, but nobody has tested it on this release — and a neighbourhood you’ve played with a pack can break when you open it without one. Listing is safe. Turn on experimental pack switches in Settings if you want to try it anyway.'**
  String get packsExperimentalOff;

  /// No description provided for @packsExperimentalOn.
  ///
  /// In en, this message translates to:
  /// **'Back up your neighbourhoods first. A neighbourhood you’ve played with a pack can break when you open it without one, and there’s no undoing that from here — switching the pack back on doesn’t always bring the save back.'**
  String get packsExperimentalOn;

  /// No description provided for @packsRestartNotice.
  ///
  /// In en, this message translates to:
  /// **'Restart {game} for this to take effect. Your packs stay installed either way.'**
  String packsRestartNotice(String game);

  /// Easter egg on the packs screen, shown only to a Sims 4 install holding every expansion and game pack. Give it its own joke in each language rather than translating this one, and keep the numbers away from anything that has to agree with them.
  ///
  /// In en, this message translates to:
  /// **'{expansions} expansions. {gamePacks} game packs. Sure you bought them all.'**
  String packsAllOwnedSims4(String expansions, String gamePacks);

  /// No description provided for @packKindExpansions.
  ///
  /// In en, this message translates to:
  /// **'Expansion packs'**
  String get packKindExpansions;

  /// No description provided for @packKindGamePacks.
  ///
  /// In en, this message translates to:
  /// **'Game packs'**
  String get packKindGamePacks;

  /// No description provided for @packKindStuffPacks.
  ///
  /// In en, this message translates to:
  /// **'Stuff packs'**
  String get packKindStuffPacks;

  /// No description provided for @packKindKits.
  ///
  /// In en, this message translates to:
  /// **'Kits'**
  String get packKindKits;

  /// No description provided for @packKindFreePacks.
  ///
  /// In en, this message translates to:
  /// **'Free packs'**
  String get packKindFreePacks;

  /// No description provided for @navSaves.
  ///
  /// In en, this message translates to:
  /// **'Saves'**
  String get navSaves;

  /// No description provided for @savesScanning.
  ///
  /// In en, this message translates to:
  /// **'Reading your saves…'**
  String get savesScanning;

  /// No description provided for @savesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saves found'**
  String get savesEmptyTitle;

  /// No description provided for @savesEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Once you play {game} and save, your worlds show up here - families, photos and all.'**
  String savesEmptyBody(String game);

  /// No description provided for @savesRescan.
  ///
  /// In en, this message translates to:
  /// **'Rescan saves'**
  String get savesRescan;

  /// No description provided for @savesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 save found} other{{count} saves found}}'**
  String savesCount(int count);

  /// No description provided for @savesLastSaved.
  ///
  /// In en, this message translates to:
  /// **'Last saved {date}'**
  String savesLastSaved(String date);

  /// No description provided for @savesShowInFolder.
  ///
  /// In en, this message translates to:
  /// **'Show in folder'**
  String get savesShowInFolder;

  /// No description provided for @savesBackups.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 backup} other{{count} backups}}'**
  String savesBackups(int count);

  /// No description provided for @savesTabHouseholds.
  ///
  /// In en, this message translates to:
  /// **'Households'**
  String get savesTabHouseholds;

  /// No description provided for @savesTabAlbum.
  ///
  /// In en, this message translates to:
  /// **'Photo album'**
  String get savesTabAlbum;

  /// No description provided for @savesTabStats.
  ///
  /// In en, this message translates to:
  /// **'World stats'**
  String get savesTabStats;

  /// No description provided for @savesNeighborhood.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood {number}'**
  String savesNeighborhood(int number);

  /// No description provided for @savesOtherHouseholds.
  ///
  /// In en, this message translates to:
  /// **'Townies & other households'**
  String get savesOtherHouseholds;

  /// No description provided for @savesSimCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Sim} other{{count} Sims}}'**
  String savesSimCount(int count);

  /// No description provided for @savesFunds.
  ///
  /// In en, this message translates to:
  /// **'Funds'**
  String get savesFunds;

  /// No description provided for @savesRooms.
  ///
  /// In en, this message translates to:
  /// **'Rooms'**
  String get savesRooms;

  /// No description provided for @savesBedsBaths.
  ///
  /// In en, this message translates to:
  /// **'{beds} bed · {baths} bath'**
  String savesBedsBaths(int beds, int baths);

  /// No description provided for @savesByCreator.
  ///
  /// In en, this message translates to:
  /// **'by {name}'**
  String savesByCreator(String name);

  /// No description provided for @savesMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get savesMembers;

  /// No description provided for @savesRelationships.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get savesRelationships;

  /// No description provided for @savesUnknownSim.
  ///
  /// In en, this message translates to:
  /// **'Unknown Sim'**
  String get savesUnknownSim;

  /// No description provided for @savesStatSims.
  ///
  /// In en, this message translates to:
  /// **'Sims'**
  String get savesStatSims;

  /// No description provided for @savesStatHouseholds.
  ///
  /// In en, this message translates to:
  /// **'Households'**
  String get savesStatHouseholds;

  /// No description provided for @savesStatNetWorth.
  ///
  /// In en, this message translates to:
  /// **'Net worth'**
  String get savesStatNetWorth;

  /// No description provided for @savesStatWorlds.
  ///
  /// In en, this message translates to:
  /// **'Worlds'**
  String get savesStatWorlds;

  /// No description provided for @savesStatPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get savesStatPhotos;

  /// No description provided for @savesAcrossHouseholds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{in 1 household} other{across {count} households}}'**
  String savesAcrossHouseholds(int count);

  /// No description provided for @savesPlayedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 played} other{{count} played}}'**
  String savesPlayedCount(int count);

  /// No description provided for @savesSizeOnDisk.
  ///
  /// In en, this message translates to:
  /// **'Size on disk'**
  String get savesSizeOnDisk;

  /// No description provided for @savesLifeStages.
  ///
  /// In en, this message translates to:
  /// **'Life stages'**
  String get savesLifeStages;

  /// No description provided for @savesTopSkills.
  ///
  /// In en, this message translates to:
  /// **'Highest skills in this save'**
  String get savesTopSkills;

  /// No description provided for @savesSaveInfo.
  ///
  /// In en, this message translates to:
  /// **'Save file'**
  String get savesSaveInfo;

  /// No description provided for @savesLastSavedLabel.
  ///
  /// In en, this message translates to:
  /// **'Last saved'**
  String get savesLastSavedLabel;

  /// No description provided for @savesGameVersion.
  ///
  /// In en, this message translates to:
  /// **'Game version'**
  String get savesGameVersion;

  /// No description provided for @savesDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get savesDescription;

  /// No description provided for @savesAgeInfant.
  ///
  /// In en, this message translates to:
  /// **'Infant'**
  String get savesAgeInfant;

  /// No description provided for @savesAgeBaby.
  ///
  /// In en, this message translates to:
  /// **'Baby'**
  String get savesAgeBaby;

  /// No description provided for @savesAgeToddler.
  ///
  /// In en, this message translates to:
  /// **'Toddler'**
  String get savesAgeToddler;

  /// No description provided for @savesAgeChild.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get savesAgeChild;

  /// No description provided for @savesAgeTeen.
  ///
  /// In en, this message translates to:
  /// **'Teen'**
  String get savesAgeTeen;

  /// No description provided for @savesAgeYoungAdult.
  ///
  /// In en, this message translates to:
  /// **'Young adult'**
  String get savesAgeYoungAdult;

  /// No description provided for @savesAgeAdult.
  ///
  /// In en, this message translates to:
  /// **'Adult'**
  String get savesAgeAdult;

  /// No description provided for @savesAgeElder.
  ///
  /// In en, this message translates to:
  /// **'Elder'**
  String get savesAgeElder;

  /// No description provided for @savesGenderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get savesGenderMale;

  /// No description provided for @savesGenderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get savesGenderFemale;

  /// No description provided for @savesSkillCooking.
  ///
  /// In en, this message translates to:
  /// **'Cooking'**
  String get savesSkillCooking;

  /// No description provided for @savesSkillMechanical.
  ///
  /// In en, this message translates to:
  /// **'Mechanical'**
  String get savesSkillMechanical;

  /// No description provided for @savesSkillCharisma.
  ///
  /// In en, this message translates to:
  /// **'Charisma'**
  String get savesSkillCharisma;

  /// No description provided for @savesSkillBody.
  ///
  /// In en, this message translates to:
  /// **'Body'**
  String get savesSkillBody;

  /// No description provided for @savesSkillLogic.
  ///
  /// In en, this message translates to:
  /// **'Logic'**
  String get savesSkillLogic;

  /// No description provided for @savesSkillCreativity.
  ///
  /// In en, this message translates to:
  /// **'Creativity'**
  String get savesSkillCreativity;

  /// No description provided for @savesSkillCleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get savesSkillCleaning;

  /// No description provided for @savesPersonalityNeat.
  ///
  /// In en, this message translates to:
  /// **'Neat'**
  String get savesPersonalityNeat;

  /// No description provided for @savesPersonalityOutgoing.
  ///
  /// In en, this message translates to:
  /// **'Outgoing'**
  String get savesPersonalityOutgoing;

  /// No description provided for @savesPersonalityActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get savesPersonalityActive;

  /// No description provided for @savesPersonalityPlayful.
  ///
  /// In en, this message translates to:
  /// **'Playful'**
  String get savesPersonalityPlayful;

  /// No description provided for @savesPersonalityNice.
  ///
  /// In en, this message translates to:
  /// **'Nice'**
  String get savesPersonalityNice;

  /// No description provided for @savesZodiacAries.
  ///
  /// In en, this message translates to:
  /// **'Aries'**
  String get savesZodiacAries;

  /// No description provided for @savesZodiacTaurus.
  ///
  /// In en, this message translates to:
  /// **'Taurus'**
  String get savesZodiacTaurus;

  /// No description provided for @savesZodiacGemini.
  ///
  /// In en, this message translates to:
  /// **'Gemini'**
  String get savesZodiacGemini;

  /// No description provided for @savesZodiacCancer.
  ///
  /// In en, this message translates to:
  /// **'Cancer'**
  String get savesZodiacCancer;

  /// No description provided for @savesZodiacLeo.
  ///
  /// In en, this message translates to:
  /// **'Leo'**
  String get savesZodiacLeo;

  /// No description provided for @savesZodiacVirgo.
  ///
  /// In en, this message translates to:
  /// **'Virgo'**
  String get savesZodiacVirgo;

  /// No description provided for @savesZodiacLibra.
  ///
  /// In en, this message translates to:
  /// **'Libra'**
  String get savesZodiacLibra;

  /// No description provided for @savesZodiacScorpio.
  ///
  /// In en, this message translates to:
  /// **'Scorpio'**
  String get savesZodiacScorpio;

  /// No description provided for @savesZodiacSagittarius.
  ///
  /// In en, this message translates to:
  /// **'Sagittarius'**
  String get savesZodiacSagittarius;

  /// No description provided for @savesZodiacCapricorn.
  ///
  /// In en, this message translates to:
  /// **'Capricorn'**
  String get savesZodiacCapricorn;

  /// No description provided for @savesZodiacAquarius.
  ///
  /// In en, this message translates to:
  /// **'Aquarius'**
  String get savesZodiacAquarius;

  /// No description provided for @savesZodiacPisces.
  ///
  /// In en, this message translates to:
  /// **'Pisces'**
  String get savesZodiacPisces;

  /// No description provided for @savesAspirationRomance.
  ///
  /// In en, this message translates to:
  /// **'Romance'**
  String get savesAspirationRomance;

  /// No description provided for @savesAspirationFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get savesAspirationFamily;

  /// No description provided for @savesAspirationFortune.
  ///
  /// In en, this message translates to:
  /// **'Fortune'**
  String get savesAspirationFortune;

  /// No description provided for @savesAspirationPopularity.
  ///
  /// In en, this message translates to:
  /// **'Popularity'**
  String get savesAspirationPopularity;

  /// No description provided for @savesAspirationKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Knowledge'**
  String get savesAspirationKnowledge;

  /// No description provided for @savesAspirationGrowUp.
  ///
  /// In en, this message translates to:
  /// **'Grow up'**
  String get savesAspirationGrowUp;

  /// No description provided for @savesAspirationPleasure.
  ///
  /// In en, this message translates to:
  /// **'Pleasure'**
  String get savesAspirationPleasure;

  /// No description provided for @savesAspirationGrilledCheese.
  ///
  /// In en, this message translates to:
  /// **'Grilled cheese'**
  String get savesAspirationGrilledCheese;

  /// No description provided for @savesRelCrush.
  ///
  /// In en, this message translates to:
  /// **'crush'**
  String get savesRelCrush;

  /// No description provided for @savesRelLove.
  ///
  /// In en, this message translates to:
  /// **'in love'**
  String get savesRelLove;

  /// No description provided for @savesRelEngaged.
  ///
  /// In en, this message translates to:
  /// **'engaged'**
  String get savesRelEngaged;

  /// No description provided for @savesRelMarried.
  ///
  /// In en, this message translates to:
  /// **'married'**
  String get savesRelMarried;

  /// No description provided for @savesRelFriends.
  ///
  /// In en, this message translates to:
  /// **'friends'**
  String get savesRelFriends;

  /// No description provided for @savesRelBestFriends.
  ///
  /// In en, this message translates to:
  /// **'best friends'**
  String get savesRelBestFriends;

  /// No description provided for @savesRelSteady.
  ///
  /// In en, this message translates to:
  /// **'going steady'**
  String get savesRelSteady;

  /// No description provided for @savesRelEnemies.
  ///
  /// In en, this message translates to:
  /// **'enemies'**
  String get savesRelEnemies;

  /// No description provided for @savesPhotoFamilyPortrait.
  ///
  /// In en, this message translates to:
  /// **'Family portrait'**
  String get savesPhotoFamilyPortrait;

  /// No description provided for @savesPhotoLot.
  ///
  /// In en, this message translates to:
  /// **'Lot'**
  String get savesPhotoLot;

  /// No description provided for @savesPhotoSim.
  ///
  /// In en, this message translates to:
  /// **'Sim portrait'**
  String get savesPhotoSim;

  /// No description provided for @savesPhotoSnapshot.
  ///
  /// In en, this message translates to:
  /// **'Snapshot'**
  String get savesPhotoSnapshot;

  /// No description provided for @savesProperty.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get savesProperty;

  /// No description provided for @savesGhost.
  ///
  /// In en, this message translates to:
  /// **'ghost'**
  String get savesGhost;

  /// No description provided for @savesCareerLevel.
  ///
  /// In en, this message translates to:
  /// **'{career} · level {level}'**
  String savesCareerLevel(String career, int level);

  /// No description provided for @savesSpeciesLargeDog.
  ///
  /// In en, this message translates to:
  /// **'dog'**
  String get savesSpeciesLargeDog;

  /// No description provided for @savesSpeciesSmallDog.
  ///
  /// In en, this message translates to:
  /// **'small dog'**
  String get savesSpeciesSmallDog;

  /// No description provided for @savesSpeciesCat.
  ///
  /// In en, this message translates to:
  /// **'cat'**
  String get savesSpeciesCat;

  /// No description provided for @savesOccultVampire.
  ///
  /// In en, this message translates to:
  /// **'vampire'**
  String get savesOccultVampire;

  /// No description provided for @savesOccultZombie.
  ///
  /// In en, this message translates to:
  /// **'zombie'**
  String get savesOccultZombie;

  /// No description provided for @savesOccultWerewolf.
  ///
  /// In en, this message translates to:
  /// **'werewolf'**
  String get savesOccultWerewolf;

  /// No description provided for @savesOccultPlantSim.
  ///
  /// In en, this message translates to:
  /// **'PlantSim'**
  String get savesOccultPlantSim;

  /// No description provided for @savesOccultAlien.
  ///
  /// In en, this message translates to:
  /// **'alien'**
  String get savesOccultAlien;

  /// No description provided for @savesOccultServo.
  ///
  /// In en, this message translates to:
  /// **'servo'**
  String get savesOccultServo;

  /// No description provided for @savesOccultWitch.
  ///
  /// In en, this message translates to:
  /// **'witch'**
  String get savesOccultWitch;

  /// No description provided for @savesOccultBigfoot.
  ///
  /// In en, this message translates to:
  /// **'bigfoot'**
  String get savesOccultBigfoot;

  /// No description provided for @savesOccultFairy.
  ///
  /// In en, this message translates to:
  /// **'fairy'**
  String get savesOccultFairy;

  /// No description provided for @savesOccultGenie.
  ///
  /// In en, this message translates to:
  /// **'genie'**
  String get savesOccultGenie;

  /// No description provided for @savesOccultMermaid.
  ///
  /// In en, this message translates to:
  /// **'mermaid'**
  String get savesOccultMermaid;

  /// No description provided for @savesLotResidential.
  ///
  /// In en, this message translates to:
  /// **'Residential'**
  String get savesLotResidential;

  /// No description provided for @savesLotCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community lot'**
  String get savesLotCommunity;

  /// No description provided for @savesLotDorm.
  ///
  /// In en, this message translates to:
  /// **'Dorm'**
  String get savesLotDorm;

  /// No description provided for @savesLotSecretSociety.
  ///
  /// In en, this message translates to:
  /// **'Secret society'**
  String get savesLotSecretSociety;

  /// No description provided for @savesLotGreekHouse.
  ///
  /// In en, this message translates to:
  /// **'Greek house'**
  String get savesLotGreekHouse;

  /// No description provided for @savesLotHotel.
  ///
  /// In en, this message translates to:
  /// **'Hotel'**
  String get savesLotHotel;

  /// No description provided for @savesLotSecret.
  ///
  /// In en, this message translates to:
  /// **'Secret lot'**
  String get savesLotSecret;

  /// No description provided for @savesLotBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get savesLotBusiness;

  /// No description provided for @savesLotApartment.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get savesLotApartment;

  /// No description provided for @savesGpa.
  ///
  /// In en, this message translates to:
  /// **'{gpa} GPA'**
  String savesGpa(String gpa);

  /// No description provided for @savesSemester.
  ///
  /// In en, this message translates to:
  /// **'semester {number}'**
  String savesSemester(int number);

  /// No description provided for @savesPredestinedHobby.
  ///
  /// In en, this message translates to:
  /// **'Born for {hobby}'**
  String savesPredestinedHobby(String hobby);

  /// No description provided for @savesHobbyCuisine.
  ///
  /// In en, this message translates to:
  /// **'Cuisine'**
  String get savesHobbyCuisine;

  /// No description provided for @savesHobbyArts.
  ///
  /// In en, this message translates to:
  /// **'Arts & crafts'**
  String get savesHobbyArts;

  /// No description provided for @savesHobbyFilm.
  ///
  /// In en, this message translates to:
  /// **'Film & literature'**
  String get savesHobbyFilm;

  /// No description provided for @savesHobbySports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get savesHobbySports;

  /// No description provided for @savesHobbyGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get savesHobbyGames;

  /// No description provided for @savesHobbyNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get savesHobbyNature;

  /// No description provided for @savesHobbyTinkering.
  ///
  /// In en, this message translates to:
  /// **'Tinkering'**
  String get savesHobbyTinkering;

  /// No description provided for @savesHobbyFitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get savesHobbyFitness;

  /// No description provided for @savesHobbyScience.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get savesHobbyScience;

  /// No description provided for @savesHobbyMusic.
  ///
  /// In en, this message translates to:
  /// **'Music & dance'**
  String get savesHobbyMusic;

  /// No description provided for @savesTieMother.
  ///
  /// In en, this message translates to:
  /// **'mother'**
  String get savesTieMother;

  /// No description provided for @savesTieFather.
  ///
  /// In en, this message translates to:
  /// **'father'**
  String get savesTieFather;

  /// No description provided for @savesTieSpouse.
  ///
  /// In en, this message translates to:
  /// **'married to'**
  String get savesTieSpouse;

  /// No description provided for @savesTieSibling.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{sibling} other{siblings}}'**
  String savesTieSibling(int count);

  /// No description provided for @savesTieChild.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{child} other{children}}'**
  String savesTieChild(int count);

  /// No description provided for @savesInterestPolitics.
  ///
  /// In en, this message translates to:
  /// **'Politics'**
  String get savesInterestPolitics;

  /// No description provided for @savesInterestMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get savesInterestMoney;

  /// No description provided for @savesInterestEnvironment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get savesInterestEnvironment;

  /// No description provided for @savesInterestCrime.
  ///
  /// In en, this message translates to:
  /// **'Crime'**
  String get savesInterestCrime;

  /// No description provided for @savesInterestEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get savesInterestEntertainment;

  /// No description provided for @savesInterestCulture.
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get savesInterestCulture;

  /// No description provided for @savesInterestFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get savesInterestFood;

  /// No description provided for @savesInterestHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get savesInterestHealth;

  /// No description provided for @savesInterestFashion.
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get savesInterestFashion;

  /// No description provided for @savesInterestSports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get savesInterestSports;

  /// No description provided for @savesInterestParanormal.
  ///
  /// In en, this message translates to:
  /// **'Paranormal'**
  String get savesInterestParanormal;

  /// No description provided for @savesInterestTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get savesInterestTravel;

  /// No description provided for @savesInterestWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get savesInterestWork;

  /// No description provided for @savesInterestWeather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get savesInterestWeather;

  /// No description provided for @savesInterestAnimals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get savesInterestAnimals;

  /// No description provided for @savesInterestSchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get savesInterestSchool;

  /// No description provided for @savesInterestToys.
  ///
  /// In en, this message translates to:
  /// **'Toys'**
  String get savesInterestToys;

  /// No description provided for @savesInterestSciFi.
  ///
  /// In en, this message translates to:
  /// **'Sci-fi'**
  String get savesInterestSciFi;

  /// No description provided for @savesInterestMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get savesInterestMusic;

  /// No description provided for @savesInterestOutdoors.
  ///
  /// In en, this message translates to:
  /// **'Outdoors'**
  String get savesInterestOutdoors;

  /// No description provided for @setupHelpSims1.
  ///
  /// In en, this message translates to:
  /// **'The original The Sims keeps custom content inside its install folder, not Documents: objects go in a Downloads folder next to the game executable (e.g. C:\\Program Files (x86)\\Maxis\\The Sims\\Downloads), and this app sorts the other types automatically - skins (.skn/.cmx/.bmp) into GameData\\Skins, walls and floors into GameData\\Walls and GameData\\Floors. The 2025 Legacy Collection works the same way from its own install folder (EA Games\\The Sims Legacy, or Steam\\steamapps\\common\\The Sims Legacy Collection). If the game is installed somewhere else (a different drive, a custom Steam library), pick its Downloads folder manually.'**
  String get setupHelpSims1;

  /// No description provided for @setupHelpSims2.
  ///
  /// In en, this message translates to:
  /// **'The Sims 2 loads custom content from Documents > EA Games > The Sims 2 > Downloads (the Ultimate Collection uses “The Sims 2 Ultimate Collection”; the 2025 Legacy Collection uses “The Sims 2 Legacy”). The folder may not exist until you create it or install content once. When the game starts, answer “Yes” to the custom content prompt so downloads are enabled.'**
  String get setupHelpSims2;

  /// No description provided for @setupHelpSims3.
  ///
  /// In en, this message translates to:
  /// **'The Sims 3 does not create a mods folder on its own: it needs the community “framework”: a Mods > Packages folder inside Documents > Electronic Arts > The Sims 3, plus a Resource.cfg file that tells the game to read it. This app can create both for you. On disc/Wine installs the folder can live inside the app bundle instead; use “Choose folder” to point at it.'**
  String get setupHelpSims3;

  /// No description provided for @setupHelpSims4.
  ///
  /// In en, this message translates to:
  /// **'The Sims 4 loads mods from Documents > Electronic Arts > The Sims 4 > Mods. The game creates this folder the first time it runs, so launch the game once if it is missing. Then, in the game, turn on Options > Game Options > Other > “Enable Custom Content and Mods” (and “Script Mods Allowed” for .ts4script files) and restart the game.'**
  String get setupHelpSims4;

  /// No description provided for @setupHelpSimsMedieval.
  ///
  /// In en, this message translates to:
  /// **'The Sims Medieval loads mods from its install folder, not Documents: a Mods > Packages folder next to the game files (e.g. C:\\Program Files (x86)\\Origin Games\\The Sims Medieval), plus a Resource.cfg file in the install folder that tells the game to read it. This app can create both for you (Windows may ask for administrator rights under Program Files). The Documents > Electronic Arts > The Sims Medieval folder only holds saves; mods placed there do nothing. For Wine/CrossOver installs or a custom Steam library, use “Choose folder” to point at the Mods > Packages folder inside the game install.'**
  String get setupHelpSimsMedieval;
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'el',
        'en',
        'es',
        'fr',
        'it',
        'ja',
        'pl',
        'pt',
        'ru',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return LDe();
    case 'el':
      return LEl();
    case 'en':
      return LEn();
    case 'es':
      return LEs();
    case 'fr':
      return LFr();
    case 'it':
      return LIt();
    case 'ja':
      return LJa();
    case 'pl':
      return LPl();
    case 'pt':
      return LPt();
    case 'ru':
      return LRu();
    case 'zh':
      return LZh();
  }

  throw FlutterError(
      'L.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
