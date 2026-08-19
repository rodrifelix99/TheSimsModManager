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
import 'app_localizations_nl.dart';
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
    Locale('nl'),
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
  /// **'for The Sims and SimCity'**
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

  /// No description provided for @shopRequires.
  ///
  /// In en, this message translates to:
  /// **'Needs these packs'**
  String get shopRequires;

  /// No description provided for @shopRequirementMet.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get shopRequirementMet;

  /// No description provided for @shopRequirementDisabled.
  ///
  /// In en, this message translates to:
  /// **'Switched off'**
  String get shopRequirementDisabled;

  /// No description provided for @shopRequirementMissing.
  ///
  /// In en, this message translates to:
  /// **'Not installed'**
  String get shopRequirementMissing;

  /// No description provided for @shopRequirementUnknown.
  ///
  /// In en, this message translates to:
  /// **'Not checked'**
  String get shopRequirementUnknown;

  /// No description provided for @shopRequirementsNote.
  ///
  /// In en, this message translates to:
  /// **'You can install it either way — it just won’t do much until the packs are there.'**
  String get shopRequirementsNote;

  /// No description provided for @shopRequirementsOffNote.
  ///
  /// In en, this message translates to:
  /// **'One of these is switched off. Turn it back on from the Packs tab.'**
  String get shopRequirementsOffNote;

  /// No description provided for @shopRequirementsUnknownNote.
  ///
  /// In en, this message translates to:
  /// **'We couldn’t check this game’s packs on this computer, so this is the creator’s word for it.'**
  String get shopRequirementsUnknownNote;

  /// No description provided for @shopDestination.
  ///
  /// In en, this message translates to:
  /// **'Installs into'**
  String get shopDestination;

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

  /// No description provided for @installFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Which folder?'**
  String get installFolderTitle;

  /// No description provided for @installFolderBody.
  ///
  /// In en, this message translates to:
  /// **'Where the files land inside your mods folder for {game}.'**
  String installFolderBody(String game);

  /// No description provided for @installFolderChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get installFolderChoose;

  /// No description provided for @installFolderEmpty.
  ///
  /// In en, this message translates to:
  /// **'No subfolders yet. Make one, or leave everything in the mods folder.'**
  String get installFolderEmpty;

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

  /// No description provided for @duplicateBadge.
  ///
  /// In en, this message translates to:
  /// **'copy'**
  String get duplicateBadge;

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

  /// No description provided for @conflictSameFileHeading.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Another enabled mod is exactly the same file:} other{{count} other enabled mods are exactly the same file:}}'**
  String conflictSameFileHeading(int count);

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

  /// No description provided for @conflictSameFileBody.
  ///
  /// In en, this message translates to:
  /// **'The duplicate scan read these files and they match byte for byte, so this isn\'t two mods arguing - it\'s the same download sitting in your folder more than once. Keeping one and removing the rest changes nothing in the game and gives you the space back.'**
  String get conflictSameFileBody;

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

  /// No description provided for @sectionShopFolder.
  ///
  /// In en, this message translates to:
  /// **'THE EXCHANGE · {game}'**
  String sectionShopFolder(String game);

  /// No description provided for @prefShopFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Where mods from The Exchange go'**
  String get prefShopFolderTitle;

  /// No description provided for @prefShopFolderDesc.
  ///
  /// In en, this message translates to:
  /// **'Installs land in {folder}'**
  String prefShopFolderDesc(String folder);

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

  /// No description provided for @prefConflictKindsTitle.
  ///
  /// In en, this message translates to:
  /// **'Which conflicts to warn about'**
  String get prefConflictKindsTitle;

  /// No description provided for @prefConflictKindsDesc.
  ///
  /// In en, this message translates to:
  /// **'Switch off the kinds you don\'t want flagged. The rest carry on as they are'**
  String get prefConflictKindsDesc;

  /// No description provided for @conflictKindSameFile.
  ///
  /// In en, this message translates to:
  /// **'Identical copies'**
  String get conflictKindSameFile;

  /// No description provided for @conflictKindSameName.
  ///
  /// In en, this message translates to:
  /// **'Same file name'**
  String get conflictKindSameName;

  /// No description provided for @conflictKindVersions.
  ///
  /// In en, this message translates to:
  /// **'Different versions'**
  String get conflictKindVersions;

  /// No description provided for @conflictKindResources.
  ///
  /// In en, this message translates to:
  /// **'Shared resources'**
  String get conflictKindResources;

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

  /// No description provided for @appThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'App theme'**
  String get appThemeTitle;

  /// No description provided for @appThemeDesc.
  ///
  /// In en, this message translates to:
  /// **'The look the whole app wears. It stays put whichever game you’re managing.'**
  String get appThemeDesc;

  /// No description provided for @appThemeDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get appThemeDefault;

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
  /// **'The app speaks twelve languages thanks to these simmers.'**
  String get translatorsDesc;

  /// No description provided for @sectionStartup.
  ///
  /// In en, this message translates to:
  /// **'STARTUP'**
  String get sectionStartup;

  /// No description provided for @prefDefaultGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Game to open on'**
  String get prefDefaultGameTitle;

  /// No description provided for @prefDefaultGameDesc.
  ///
  /// In en, this message translates to:
  /// **'Which library the app starts on when you launch it'**
  String get prefDefaultGameDesc;

  /// No description provided for @defaultGameAuto.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get defaultGameAuto;

  /// No description provided for @prefSetupGuideTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup guide'**
  String get prefSetupGuideTitle;

  /// No description provided for @prefSetupGuideDesc.
  ///
  /// In en, this message translates to:
  /// **'Walk through the first-run questions again'**
  String get prefSetupGuideDesc;

  /// No description provided for @onboardingReplay.
  ///
  /// In en, this message translates to:
  /// **'Run it again'**
  String get onboardingReplay;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip setup'**
  String get onboardingSkip;

  /// No description provided for @onboardingSkipIntro.
  ///
  /// In en, this message translates to:
  /// **'Skip intro'**
  String get onboardingSkipIntro;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingFinish.
  ///
  /// In en, this message translates to:
  /// **'Open my library'**
  String get onboardingFinish;

  /// No description provided for @onboardingStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStepOf(int current, int total);

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Hey! Let’s get you set up'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'A few quick questions and your mods are ready to go. It takes under a minute, and everything here can be changed later in Settings.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingGamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Looking for your games'**
  String get onboardingGamesTitle;

  /// No description provided for @onboardingGamesBody.
  ///
  /// In en, this message translates to:
  /// **'Checking the usual places for each game and the folder it reads mods from.'**
  String get onboardingGamesBody;

  /// No description provided for @onboardingScanning.
  ///
  /// In en, this message translates to:
  /// **'Still looking…'**
  String get onboardingScanning;

  /// No description provided for @onboardingGamesFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing found yet} =1{1 game found} other{{count} games found}}'**
  String onboardingGamesFound(int count);

  /// No description provided for @onboardingGameMods.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Mods folder ready} =1{1 mod already installed} other{{count} mods already installed}}'**
  String onboardingGameMods(int count);

  /// No description provided for @onboardingGameMissing.
  ///
  /// In en, this message translates to:
  /// **'Not on this computer'**
  String get onboardingGameMissing;

  /// No description provided for @onboardingNoGamesTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t find a thing'**
  String get onboardingNoGamesTitle;

  /// No description provided for @onboardingNoGamesBody.
  ///
  /// In en, this message translates to:
  /// **'No drama. Point the app at a mods folder yourself in Settings and everything works exactly the same.'**
  String get onboardingNoGamesBody;

  /// No description provided for @onboardingFavoriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Which one do you play most?'**
  String get onboardingFavoriteTitle;

  /// No description provided for @onboardingFavoriteBody.
  ///
  /// In en, this message translates to:
  /// **'The app opens on this game every time. You can jump between games whenever you like from the sidebar.'**
  String get onboardingFavoriteBody;

  /// No description provided for @onboardingLookTitle.
  ///
  /// In en, this message translates to:
  /// **'Make it feel like yours'**
  String get onboardingLookTitle;

  /// No description provided for @onboardingLookBody.
  ///
  /// In en, this message translates to:
  /// **'The whole app wears the look you pick, whichever game you’re managing. Choose how it should look and sound.'**
  String get onboardingLookBody;

  /// No description provided for @onboardingLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'How your library reads'**
  String get onboardingLibraryTitle;

  /// No description provided for @onboardingLibraryBody.
  ///
  /// In en, this message translates to:
  /// **'Two things worth deciding now, because they change what the library shows you.'**
  String get onboardingLibraryBody;

  /// No description provided for @onboardingDoneTitle.
  ///
  /// In en, this message translates to:
  /// **'All set!'**
  String get onboardingDoneTitle;

  /// No description provided for @onboardingDoneBody.
  ///
  /// In en, this message translates to:
  /// **'Your library is loaded and waiting. Drop a mod file onto the window whenever you want to install one, and change any of this in Settings.'**
  String get onboardingDoneBody;

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
  /// **'Version {version} · Mod manager for {series}'**
  String aboutTagline(String version, String series);

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

  /// No description provided for @categoryWorld.
  ///
  /// In en, this message translates to:
  /// **'World'**
  String get categoryWorld;

  /// No description provided for @categorySettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get categorySettings;

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

  /// No description provided for @modKindCas.
  ///
  /// In en, this message translates to:
  /// **'CAS'**
  String get modKindCas;

  /// No description provided for @modKindBuildBuy.
  ///
  /// In en, this message translates to:
  /// **'Build & Buy'**
  String get modKindBuildBuy;

  /// No description provided for @modKindGameplay.
  ///
  /// In en, this message translates to:
  /// **'Gameplay'**
  String get modKindGameplay;

  /// No description provided for @modKindScript.
  ///
  /// In en, this message translates to:
  /// **'Script'**
  String get modKindScript;

  /// No description provided for @errorNoModFiles.
  ///
  /// In en, this message translates to:
  /// **'No mod files ({extensions}) found inside {name}.'**
  String errorNoModFiles(String extensions, String name);

  /// No description provided for @errorUnreadableArchive.
  ///
  /// In en, this message translates to:
  /// **'{name} isn’t an archive this app can read.'**
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

  /// No description provided for @duplicatesFind.
  ///
  /// In en, this message translates to:
  /// **'Find duplicate mods'**
  String get duplicatesFind;

  /// No description provided for @duplicatesScanning.
  ///
  /// In en, this message translates to:
  /// **'Reading the mods that could be copies… {done} of {total}'**
  String duplicatesScanning(int done, int total);

  /// No description provided for @duplicatesStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get duplicatesStop;

  /// No description provided for @duplicatesBanner.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{One mod is the same file as another one} other{{count} mods are the same file as another one}} - that’s {size} you could have back.'**
  String duplicatesBanner(int count, String size);

  /// No description provided for @duplicatesShow.
  ///
  /// In en, this message translates to:
  /// **'Show them'**
  String get duplicatesShow;

  /// No description provided for @duplicatesSelectExtras.
  ///
  /// In en, this message translates to:
  /// **'Tick the spare copies'**
  String get duplicatesSelectExtras;

  /// No description provided for @duplicatesClean.
  ///
  /// In en, this message translates to:
  /// **'Nothing in here is a copy of anything else.'**
  String get duplicatesClean;

  /// No description provided for @duplicatesDismiss.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get duplicatesDismiss;

  /// No description provided for @tagTitle.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Tags for this mod} other{Tags for {count} mods}}'**
  String tagTitle(int count);

  /// No description provided for @tagBody.
  ///
  /// In en, this message translates to:
  /// **'Your own labels, for finding things later. Tap one to put it on or take it off.'**
  String get tagBody;

  /// No description provided for @tagHint.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get tagHint;

  /// No description provided for @tagAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get tagAdd;

  /// No description provided for @tagDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tagDone;

  /// No description provided for @tagHeading.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagHeading;

  /// No description provided for @tagAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Add a tag'**
  String get tagAddFirst;

  /// No description provided for @tagRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove “{tag}”'**
  String tagRemove(String tag);

  /// No description provided for @selectionTag.
  ///
  /// In en, this message translates to:
  /// **'Tag…'**
  String get selectionTag;

  /// No description provided for @folderAlsoReading.
  ///
  /// In en, this message translates to:
  /// **'Your game reads {folders} as well, so mods in there are in this library too.'**
  String folderAlsoReading(String folders);

  /// No description provided for @errorFolderUnreadable.
  ///
  /// In en, this message translates to:
  /// **'Couldn’t open “{folder}”. Pick a folder on a drive this computer can reach - a phone, a camera or a disconnected network drive can’t hold your mods.'**
  String errorFolderUnreadable(String folder);

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

  /// No description provided for @prefSubfoldersTitle.
  ///
  /// In en, this message translates to:
  /// **'Folders include their subfolders'**
  String get prefSubfoldersTitle;

  /// No description provided for @prefSubfoldersDesc.
  ///
  /// In en, this message translates to:
  /// **'A folder shows everything below it too. Off, cc and cc/defaults are separate shelves.'**
  String get prefSubfoldersDesc;

  /// No description provided for @deleteFolderTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {folder}?'**
  String deleteFolderTitle(String folder);

  /// No description provided for @deleteFolderBody.
  ///
  /// In en, this message translates to:
  /// **'The folder and everything in it goes, subfolders and all. This cannot be undone.'**
  String get deleteFolderBody;

  /// No description provided for @deleteFolderMods.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 mod will be deleted} other{{count} mods will be deleted}}'**
  String deleteFolderMods(int count);

  /// No description provided for @deleteFolderEmpty.
  ///
  /// In en, this message translates to:
  /// **'It holds no mods.'**
  String get deleteFolderEmpty;

  /// No description provided for @deleteFolder.
  ///
  /// In en, this message translates to:
  /// **'Delete folder'**
  String get deleteFolder;

  /// No description provided for @triviaTitle.
  ///
  /// In en, this message translates to:
  /// **'Plumbob knows · {game}'**
  String triviaTitle(String game);

  /// No description provided for @triviaContextLibrary.
  ///
  /// In en, this message translates to:
  /// **'It looks like you’re browsing mods'**
  String get triviaContextLibrary;

  /// No description provided for @triviaContextSaves.
  ///
  /// In en, this message translates to:
  /// **'It looks like you’re in your saves'**
  String get triviaContextSaves;

  /// No description provided for @triviaContextPacks.
  ///
  /// In en, this message translates to:
  /// **'It looks like you’re sorting out your packs'**
  String get triviaContextPacks;

  /// No description provided for @triviaCounter.
  ///
  /// In en, this message translates to:
  /// **'Fact {index} of {total}'**
  String triviaCounter(int index, int total);

  /// No description provided for @triviaOpen.
  ///
  /// In en, this message translates to:
  /// **'Ask the plumbob'**
  String get triviaOpen;

  /// No description provided for @triviaClose.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get triviaClose;

  /// No description provided for @triviaPrevious.
  ///
  /// In en, this message translates to:
  /// **'Previous fact'**
  String get triviaPrevious;

  /// No description provided for @triviaNext.
  ///
  /// In en, this message translates to:
  /// **'Next fact'**
  String get triviaNext;

  /// No description provided for @triviaAnother.
  ///
  /// In en, this message translates to:
  /// **'Another one'**
  String get triviaAnother;

  /// No description provided for @triviaToSettings.
  ///
  /// In en, this message translates to:
  /// **'Had enough? Switch the plumbob off in Settings'**
  String get triviaToSettings;

  /// No description provided for @prefTriviaTitle.
  ///
  /// In en, this message translates to:
  /// **'Plumbob trivia'**
  String get prefTriviaTitle;

  /// No description provided for @prefTriviaDesc.
  ///
  /// In en, this message translates to:
  /// **'Let the plumbob pop up now and then with a fact about the game you’re in'**
  String get prefTriviaDesc;

  /// No description provided for @triviaCategoryOrigins.
  ///
  /// In en, this message translates to:
  /// **'Origins'**
  String get triviaCategoryOrigins;

  /// No description provided for @triviaCategoryDesign.
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get triviaCategoryDesign;

  /// No description provided for @triviaCategoryLore.
  ///
  /// In en, this message translates to:
  /// **'Lore'**
  String get triviaCategoryLore;

  /// No description provided for @triviaCategoryDeath.
  ///
  /// In en, this message translates to:
  /// **'Death'**
  String get triviaCategoryDeath;

  /// No description provided for @triviaCategoryMusic.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get triviaCategoryMusic;

  /// No description provided for @triviaCategoryCheats.
  ///
  /// In en, this message translates to:
  /// **'Cheats'**
  String get triviaCategoryCheats;

  /// No description provided for @triviaCategoryRecords.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get triviaCategoryRecords;

  /// No description provided for @triviaCategoryModding.
  ///
  /// In en, this message translates to:
  /// **'Modding'**
  String get triviaCategoryModding;

  /// No description provided for @triviaCategoryLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get triviaCategoryLanguage;

  /// No description provided for @triviaCategoryCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get triviaCategoryCommunity;

  /// No description provided for @triviaSeriesLlama.
  ///
  /// In en, this message translates to:
  /// **'Maxis once held a studio-wide vote for an unofficial mascot. The candidates were a Boston tree fern, a beef tapeworm and a llama. The llama won, and it has been turning up in the games ever since.'**
  String get triviaSeriesLlama;

  /// No description provided for @triviaSeriesSimlish.
  ///
  /// In en, this message translates to:
  /// **'Simlish was co-created at the microphone. Stephen Kearin and Gerri Lawlor were handed prompts like “hungry” or “lonely” and improvised what those ought to sound like, for hours.'**
  String get triviaSeriesSimlish;

  /// No description provided for @triviaSeriesCheats.
  ///
  /// In en, this message translates to:
  /// **'rosebud and klapaucius both pay out §1,000. Rosebud is Citizen Kane; Klapaucius is a robot constructor from Stanisław Lem’s The Cyberiad, a book Will Wright has credited as an influence since SimCity.'**
  String get triviaSeriesCheats;

  /// No description provided for @triviaSeriesRecords.
  ///
  /// In en, this message translates to:
  /// **'Guinness lists The Sims as the best-selling PC game series of all time. It passed 125 million copies more than a decade ago and has been translated into 60 languages.'**
  String get triviaSeriesRecords;

  /// No description provided for @triviaSeriesGoths.
  ///
  /// In en, this message translates to:
  /// **'The Goths are among the longest-running families in games. Mortimer and Bella have turned up in every mainline entry since 2000.'**
  String get triviaSeriesGoths;

  /// No description provided for @triviaSeriesReaper.
  ///
  /// In en, this message translates to:
  /// **'The Grim Reaper has a biography ordinary play never shows you. Among other things, it names his favourite band: Styx.'**
  String get triviaSeriesReaper;

  /// No description provided for @triviaSeriesSimCity.
  ///
  /// In en, this message translates to:
  /// **'The Sims grew out of SimCity. Will Wright kept wanting to zoom in on the little people the city was being built for.'**
  String get triviaSeriesSimCity;

  /// No description provided for @triviaSeriesLegacy.
  ///
  /// In en, this message translates to:
  /// **'In January 2025 EA put The Sims and The Sims 2 back on sale as Legacy Collections, every expansion included. They are compatibility fixes rather than remasters, so both games play exactly as they did.'**
  String get triviaSeriesLegacy;

  /// No description provided for @triviaSeriesPlumbob.
  ///
  /// In en, this message translates to:
  /// **'The green diamond has been spelled three ways: PlumbBob in The Sims, Plum Bob in The Sims 2, and plumbob since The Sims 4. Maxis says all three were used during development.'**
  String get triviaSeriesPlumbob;

  /// No description provided for @triviaSeriesModScene.
  ///
  /// In en, this message translates to:
  /// **'The mod scene is nearly as old as the series. Skin and object editors were circulating within months of the first game shipping in 2000, long before there were official tools.'**
  String get triviaSeriesModScene;

  /// No description provided for @triviaSeriesConflicts.
  ///
  /// In en, this message translates to:
  /// **'A conflict is simpler than it sounds. Two mods claim the same resource, both load, and whichever the game reads last wins. Nothing is broken, something is just overruled.'**
  String get triviaSeriesConflicts;

  /// No description provided for @triviaSeriesPackage.
  ///
  /// In en, this message translates to:
  /// **'A .package file is a DBPF archive, short for Database Packed File. Maxis has used the same container since SimCity 4, which is why one tool can open twenty years of custom content.'**
  String get triviaSeriesPackage;

  /// No description provided for @triviaSeriesRename.
  ///
  /// In en, this message translates to:
  /// **'Switching a mod off by renaming it is the oldest trick in the scene. The game only loads files it recognises, so a renamed package stays exactly where it is and stays quiet.'**
  String get triviaSeriesRename;

  /// No description provided for @triviaSeriesSaves.
  ///
  /// In en, this message translates to:
  /// **'Sims saves are neighbourhoods, not slots. The families, the lots, the memories and the gossip all live in one folder that grows for as long as you keep playing.'**
  String get triviaSeriesSaves;

  /// No description provided for @triviaSeriesPacks.
  ///
  /// In en, this message translates to:
  /// **'Switching a pack off never moves a file. Every game in the series keeps its own list of what to load somewhere else, a settings line or a registry key, and hiding one just means editing that list.'**
  String get triviaSeriesPacks;

  /// No description provided for @triviaSims1Dollhouse.
  ///
  /// In en, this message translates to:
  /// **'The Sims started life as an architecture simulator called Project Dollhouse. The Sims themselves were added only so players could judge whether a house was any good to live in.'**
  String get triviaSims1Dollhouse;

  /// No description provided for @triviaSims1Oakland.
  ///
  /// In en, this message translates to:
  /// **'Will Wright lost his home in the 1991 Oakland firestorm. Rebuilding a household from scratch, furniture and appliances and routines, became the seed of the game.'**
  String get triviaSims1Oakland;

  /// No description provided for @triviaSims1Toilet.
  ///
  /// In en, this message translates to:
  /// **'Executives were famously unconvinced by the pitch, dismissing it as a “toilet game” because Sims needed bathrooms.'**
  String get triviaSims1Toilet;

  /// No description provided for @triviaSims1HomeTactics.
  ///
  /// In en, this message translates to:
  /// **'Before it was The Sims it was pitched as Home Tactics: The Experimental Domestic Simulator. The focus groups disliked that version too.'**
  String get triviaSims1HomeTactics;

  /// No description provided for @triviaSims1Myst.
  ///
  /// In en, this message translates to:
  /// **'In 2002 The Sims passed Myst to become the best-selling PC game of all time.'**
  String get triviaSims1Myst;

  /// No description provided for @triviaSims1Simlish.
  ///
  /// In en, this message translates to:
  /// **'Simlish was improvised by voice actors riffing on fragments of Ukrainian, Navajo, Tagalog and Estonian, deliberately kept meaningless so the language never dates.'**
  String get triviaSims1Simlish;

  /// No description provided for @triviaSims1Architecture.
  ///
  /// In en, this message translates to:
  /// **'The building tools were so unusual for 2000 that some players never placed a Sim at all and used the game as free architecture software.'**
  String get triviaSims1Architecture;

  /// No description provided for @triviaSims1Audience.
  ///
  /// In en, this message translates to:
  /// **'Unusually for its era, the majority of the players were women, which is part of why the marketing looked like nothing else on the shelf.'**
  String get triviaSims1Audience;

  /// No description provided for @triviaSims1Cowplant.
  ///
  /// In en, this message translates to:
  /// **'The cowplant debuted here under the in-game name Laganaphyllis Simnovorii, and has quietly eaten Sims in every generation since.'**
  String get triviaSims1Cowplant;

  /// No description provided for @triviaSims1Plumbob.
  ///
  /// In en, this message translates to:
  /// **'The word plumbob comes from the plumb bob, a weighted pointer builders hang on a string to find true vertical. This was an architecture game first.'**
  String get triviaSims1Plumbob;

  /// No description provided for @triviaSims1Release.
  ///
  /// In en, this message translates to:
  /// **'The game shipped on 4 February 2000 and outsold every expansion prediction EA had made for it.'**
  String get triviaSims1Release;

  /// No description provided for @triviaSims1Edith.
  ///
  /// In en, this message translates to:
  /// **'Every object in the game was scripted in a language called SimAntics, through an in-house tool named Edith after Edith Bunker: the first character ever built for The Sims.'**
  String get triviaSims1Edith;

  /// No description provided for @triviaSims1Expansions.
  ///
  /// In en, this message translates to:
  /// **'Seven expansions in three and a half years, one each spring and autumn, from Livin’ Large in August 2000 to Makin’ Magic in October 2003.'**
  String get triviaSims1Expansions;

  /// No description provided for @triviaSims1Unleashed.
  ///
  /// In en, this message translates to:
  /// **'Unleashed brought pets to the series in 2002 and took Computer Simulation Game of the Year at the Interactive Achievement Awards.'**
  String get triviaSims1Unleashed;

  /// No description provided for @triviaSims1Clown.
  ///
  /// In en, this message translates to:
  /// **'The Tragic Clown turns up to cheer a sad Sim who owns his painting. He is comprehensively bad at it, which is the entire joke.'**
  String get triviaSims1Clown;

  /// No description provided for @triviaSims1Llama.
  ///
  /// In en, this message translates to:
  /// **'The original printed manual contained a book called Making the Most of Your Llama. Nobody has ever explained it.'**
  String get triviaSims1Llama;

  /// No description provided for @triviaSims1Superstar.
  ///
  /// In en, this message translates to:
  /// **'Superstar let a Sim become an actor, a model or a singer with a working fame meter, eleven years before The Sims 4 tried celebrity again.'**
  String get triviaSims1Superstar;

  /// No description provided for @triviaSims1Catalogue.
  ///
  /// In en, this message translates to:
  /// **'Rebuilding after the fire, Will Wright kept asking which parts of a home were essential and which could wait. That question is more or less the buy-mode catalogue.'**
  String get triviaSims1Catalogue;

  /// No description provided for @triviaSims2Aging.
  ///
  /// In en, this message translates to:
  /// **'The Sims 2 was the first game in the series where Sims aged, died of old age and passed genetics down. Eyes, noses and chins are inherited from both parents.'**
  String get triviaSims2Aging;

  /// No description provided for @triviaSims2Memories.
  ///
  /// In en, this message translates to:
  /// **'Every Sim carries a hidden memory list. Witnessing a death, a first kiss or a promotion is stored and shapes later moods.'**
  String get triviaSims2Memories;

  /// No description provided for @triviaSims2Bella.
  ///
  /// In en, this message translates to:
  /// **'Bella Goth vanishes from Pleasantview at the start of the game, and the disappearance has never been officially explained in twenty years.'**
  String get triviaSims2Bella;

  /// No description provided for @triviaSims2Strangetown.
  ///
  /// In en, this message translates to:
  /// **'Bella turns up alive in Strangetown with no memory of Pleasantview at all. Maxis has said both Bellas are real and left it there.'**
  String get triviaSims2Strangetown;

  /// No description provided for @triviaSims2FamilyTrees.
  ///
  /// In en, this message translates to:
  /// **'Sims 2 neighbourhoods run on a real family tree: Pleasantview, Strangetown and Veronaville are all connected by marriage and rumour.'**
  String get triviaSims2FamilyTrees;

  /// No description provided for @triviaSims2Plead.
  ///
  /// In en, this message translates to:
  /// **'The Grim Reaper can be pleaded with. Talk to him at the right moment and he may hand your Sim back, occasionally in exchange for someone else.'**
  String get triviaSims2Plead;

  /// No description provided for @triviaSims2ReaperRomance.
  ///
  /// In en, this message translates to:
  /// **'You can romance the Grim Reaper. Play it well enough and the relationship produces a ghost baby.'**
  String get triviaSims2ReaperRomance;

  /// No description provided for @triviaSims2Satellite.
  ///
  /// In en, this message translates to:
  /// **'A Sim who stargazes has a very small chance of being hit by a falling satellite. It is one of the rarest deaths in the series.'**
  String get triviaSims2Satellite;

  /// No description provided for @triviaSims2Therapist.
  ///
  /// In en, this message translates to:
  /// **'Aspiration failure sends a Sim to the therapist, one of the few times the game breaks its own fourth wall for laughs.'**
  String get triviaSims2Therapist;

  /// No description provided for @triviaSims2WantsFears.
  ///
  /// In en, this message translates to:
  /// **'Wants and fears run the whole game. The aspiration meter reacts as strongly to the thing a Sim was dreading as to the thing they were hoping for.'**
  String get triviaSims2WantsFears;

  /// No description provided for @triviaSims2FaceSculpt.
  ///
  /// In en, this message translates to:
  /// **'The game shipped with a full body-shape and face-sculpting system, which is why Sims 2 faces still look more varied than later entries.'**
  String get triviaSims2FaceSculpt;

  /// No description provided for @triviaSims2Aliens.
  ///
  /// In en, this message translates to:
  /// **'Alien abduction only happens to male Sims who stargaze too long, and yes, they come back pregnant.'**
  String get triviaSims2Aliens;

  /// No description provided for @triviaSims2FreezerBunny.
  ///
  /// In en, this message translates to:
  /// **'The Freezer Bunny was drawn by artist Emmy Toyonaga for The Sims 2 and first appeared hiding inside a community lot freezer. It has been smuggled into every game since.'**
  String get triviaSims2FreezerBunny;

  /// No description provided for @triviaSims2SocialBunny.
  ///
  /// In en, this message translates to:
  /// **'The Social Bunny replaced the Tragic Clown, and unlike the clown it actually works. Plenty of players found the competent version more unsettling.'**
  String get triviaSims2SocialBunny;

  /// No description provided for @triviaSims2Giveaway.
  ///
  /// In en, this message translates to:
  /// **'EA gave the Ultimate Collection away free through Origin in July 2014, redeemed with the code I-LOVE-THE-SIMS. For the decade until the Legacy Collection, that giveaway was the only copy going.'**
  String get triviaSims2Giveaway;

  /// No description provided for @triviaSims3SunsetValley.
  ///
  /// In en, this message translates to:
  /// **'Sunset Valley is Pleasantview from The Sims 2 roughly 25 years earlier, so you can meet the grandparents of Sims you already played.'**
  String get triviaSims3SunsetValley;

  /// No description provided for @triviaSims3Founders.
  ///
  /// In en, this message translates to:
  /// **'Sunset Valley was founded by the Goths and built up by the Landgraabs. You can play Mortimer Goth as a child and watch him meet Bella Bachelor.'**
  String get triviaSims3Founders;

  /// No description provided for @triviaSims3OpenWorld.
  ///
  /// In en, this message translates to:
  /// **'The Sims 3 dropped loading screens entirely. The whole town simulates at once, with every Sim aging and working in the background.'**
  String get triviaSims3OpenWorld;

  /// No description provided for @triviaSims3Simulation.
  ///
  /// In en, this message translates to:
  /// **'Every Sim in town is simulated at once, which is why a long save slows down. The game is quietly running lives you have never met.'**
  String get triviaSims3Simulation;

  /// No description provided for @triviaSims3CreateAStyle.
  ///
  /// In en, this message translates to:
  /// **'Create-a-Style let players recolour and re-pattern almost any object, a feature so demanding it was never brought back.'**
  String get triviaSims3CreateAStyle;

  /// No description provided for @triviaSims3Exchange.
  ///
  /// In en, this message translates to:
  /// **'The Sims 3 shipped with a real online exchange where players traded lots, Sims and patterns directly from the launcher.'**
  String get triviaSims3Exchange;

  /// No description provided for @triviaSims3Downloads.
  ///
  /// In en, this message translates to:
  /// **'In its first week alone, players downloaded more than seven million user-made items straight from that launcher.'**
  String get triviaSims3Downloads;

  /// No description provided for @triviaSims3Traits.
  ///
  /// In en, this message translates to:
  /// **'Traits replaced the old personality sliders, and some of them, like Kleptomaniac and Insane, quietly break the rules of ordinary life.'**
  String get triviaSims3Traits;

  /// No description provided for @triviaSims3Kleptomaniac.
  ///
  /// In en, this message translates to:
  /// **'A kleptomaniac Sim comes home with other people’s furniture, unprompted, and will keep doing it until you notice.'**
  String get triviaSims3Kleptomaniac;

  /// No description provided for @triviaSims3Simlish.
  ///
  /// In en, this message translates to:
  /// **'Katy Perry, Lily Allen, Depeche Mode and dozens of other artists re-recorded their own songs in Simlish for the soundtracks.'**
  String get triviaSims3Simlish;

  /// No description provided for @triviaSims3Townies.
  ///
  /// In en, this message translates to:
  /// **'Because the open world simulated off-screen Sims, players regularly found townies had married and had children without any input.'**
  String get triviaSims3Townies;

  /// No description provided for @triviaSims3Store.
  ///
  /// In en, this message translates to:
  /// **'The Sims 3 Store sold more objects than the game itself contained at launch.'**
  String get triviaSims3Store;

  /// No description provided for @triviaSims3Launch.
  ///
  /// In en, this message translates to:
  /// **'The Sims 3 sold 1.4 million copies in its first week in June 2009, the biggest PC launch EA had ever had.'**
  String get triviaSims3Launch;

  /// No description provided for @triviaSims4Flies.
  ///
  /// In en, this message translates to:
  /// **'Death by flies is real. Leave a lot filthy enough and a swarm can finish a Sim off.'**
  String get triviaSims4Flies;

  /// No description provided for @triviaSims4Emotions.
  ///
  /// In en, this message translates to:
  /// **'Emotions drive everything here. A Sim who is Inspired paints better; one who is Enraged can die of anger.'**
  String get triviaSims4Emotions;

  /// No description provided for @triviaSims4EmotionDeaths.
  ///
  /// In en, this message translates to:
  /// **'A Sim can die of laughter, of anger and of embarrassment. Emotion is not decoration in this one, it is a hazard.'**
  String get triviaSims4EmotionDeaths;

  /// No description provided for @triviaSims4CreateASim.
  ///
  /// In en, this message translates to:
  /// **'Create-a-Sim replaced sliders with direct pulling and pushing on the face, which is why Sims 4 faces are so quick to make.'**
  String get triviaSims4CreateASim;

  /// No description provided for @triviaSims4Launch.
  ///
  /// In en, this message translates to:
  /// **'The Sims 4 launched without pools or toddlers. Both were patched in free of charge after sustained player pressure.'**
  String get triviaSims4Launch;

  /// No description provided for @triviaSims4Worlds.
  ///
  /// In en, this message translates to:
  /// **'Willow Creek and Oasis Springs were the only two worlds at launch in September 2014. There are dozens now, and almost all of them arrived with a pack.'**
  String get triviaSims4Worlds;

  /// No description provided for @triviaSims4Gender.
  ///
  /// In en, this message translates to:
  /// **'Gender was fully unlocked in a 2016 patch: any Sim can wear any clothing, take any voice, and get pregnant or not.'**
  String get triviaSims4Gender;

  /// No description provided for @triviaSims4Newcrest.
  ///
  /// In en, this message translates to:
  /// **'Newcrest shipped completely empty on purpose. Fifteen lots, no buildings, and an open invitation to the community to fill it.'**
  String get triviaSims4Newcrest;

  /// No description provided for @triviaSims4Naming.
  ///
  /// In en, this message translates to:
  /// **'Neighbourhood names like Willow Creek and Oasis Springs follow a house rule from early Maxis: two plain English words, no invented spellings.'**
  String get triviaSims4Naming;

  /// No description provided for @triviaSims4Goths.
  ///
  /// In en, this message translates to:
  /// **'The Goth family appears here too, which makes them one of the longest-running families in games, present in every mainline entry.'**
  String get triviaSims4Goths;

  /// No description provided for @triviaSims4FreeToPlay.
  ///
  /// In en, this message translates to:
  /// **'The base game went free in October 2022 on PC, PlayStation and Xbox at once. The packs stayed paid.'**
  String get triviaSims4FreeToPlay;

  /// No description provided for @triviaSims4Mccc.
  ///
  /// In en, this message translates to:
  /// **'MC Command Center, the first mod most Sims 4 players install, has passed 14 million downloads on CurseForge alone. Deaderpool has been updating it since 2015.'**
  String get triviaSims4Mccc;

  /// No description provided for @triviaSims4Twallan.
  ///
  /// In en, this message translates to:
  /// **'MCCC exists because of The Sims 3. It picks up where Twallan’s Master Controller and Story Progression left off, carrying a decade-old idea into a new engine.'**
  String get triviaSims4Twallan;

  /// No description provided for @triviaSims4Deaths.
  ///
  /// In en, this message translates to:
  /// **'Sims can be killed by a cowplant, a vending machine, a llama-shaped stereo and laughter. Not all at once.'**
  String get triviaSims4Deaths;

  /// No description provided for @triviaMedievalWatcher.
  ///
  /// In en, this message translates to:
  /// **'You are not a household here, you are the Watcher: a benign deity who nudges heroes around a kingdom rather than running one family’s day.'**
  String get triviaMedievalWatcher;

  /// No description provided for @triviaMedievalHeroes.
  ///
  /// In en, this message translates to:
  /// **'A kingdom holds up to ten hero Sims across ten professions, and each of them levels from 1 to 10 with new abilities and grander titles on the way up.'**
  String get triviaMedievalHeroes;

  /// No description provided for @triviaMedievalStocks.
  ///
  /// In en, this message translates to:
  /// **'Every hero wakes up with two responsibilities and a deadline. Skip them often enough and you are punished for it, and that includes the monarch, who can be put in the stocks.'**
  String get triviaMedievalStocks;

  /// No description provided for @triviaMedievalAmbition.
  ///
  /// In en, this message translates to:
  /// **'You pick an Ambition for the whole kingdom before you start, and the quests you take are scored against it. It is the closest The Sims has come to a win condition.'**
  String get triviaMedievalAmbition;

  /// No description provided for @triviaMedievalQuests.
  ///
  /// In en, this message translates to:
  /// **'This is a total conversion rather than a spin-off. The sandbox is replaced by a chain of quests, which is why it is the only Sims game you can actually finish.'**
  String get triviaMedievalQuests;

  /// No description provided for @triviaMedievalPirates.
  ///
  /// In en, this message translates to:
  /// **'Pirates and Nobles, from August 2011, was the only add-on it ever got: falcons and parrots, treasure maps and shovels, and a war between two arriving factions.'**
  String get triviaMedievalPirates;

  /// No description provided for @triviaMedievalProxy.
  ///
  /// In en, this message translates to:
  /// **'The game was never built to load mods. Script and core mods need the community’s d3dx9_31.dll proxy dropped into Game/Bin before the game will read them at all, though custom content works without it.'**
  String get triviaMedievalProxy;

  /// No description provided for @triviaMedievalEngine.
  ///
  /// In en, this message translates to:
  /// **'It runs on The Sims 3’s engine, which is why the Resource.cfg and the .package files look so familiar to anyone who has modded that game.'**
  String get triviaMedievalEngine;

  /// No description provided for @navCreations.
  ///
  /// In en, this message translates to:
  /// **'Creations'**
  String get navCreations;

  /// No description provided for @creationsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing saved yet} =1{1 creation} other{{count} creations}}'**
  String creationsCount(int count);

  /// No description provided for @creationsScanning.
  ///
  /// In en, this message translates to:
  /// **'Reading your lots and households…'**
  String get creationsScanning;

  /// No description provided for @creationsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get creationsRefresh;

  /// No description provided for @creationsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get creationsAll;

  /// No description provided for @creationsBack.
  ///
  /// In en, this message translates to:
  /// **'← Back to everything'**
  String get creationsBack;

  /// No description provided for @creationsNoneOfKind.
  ///
  /// In en, this message translates to:
  /// **'Nothing of that kind here.'**
  String get creationsNoneOfKind;

  /// No description provided for @creationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get creationsEmptyTitle;

  /// No description provided for @creationsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Lots, rooms, households and sims you save in the game show up here — and so does anything you download and drop onto the window.'**
  String get creationsEmptyBody;

  /// No description provided for @creationsBy.
  ///
  /// In en, this message translates to:
  /// **'by {creator}'**
  String creationsBy(String creator);

  /// No description provided for @creationsWhoLivesHere.
  ///
  /// In en, this message translates to:
  /// **'WHO COMES WITH IT'**
  String get creationsWhoLivesHere;

  /// No description provided for @creationsShowInFolder.
  ///
  /// In en, this message translates to:
  /// **'Show in folder'**
  String get creationsShowInFolder;

  /// No description provided for @creationsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get creationsDelete;

  /// No description provided for @creationsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”?'**
  String creationsDeleteTitle(String name);

  /// No description provided for @creationsDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'It goes from the game’s folder for good. There’s no undo.'**
  String get creationsDeleteBody;

  /// No description provided for @creationsFileCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 file} other{{count} files}}'**
  String creationsFileCount(int count);

  /// No description provided for @creationKindLot.
  ///
  /// In en, this message translates to:
  /// **'Lot'**
  String get creationKindLot;

  /// No description provided for @creationKindRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get creationKindRoom;

  /// No description provided for @creationKindHousehold.
  ///
  /// In en, this message translates to:
  /// **'Household'**
  String get creationKindHousehold;

  /// No description provided for @creationKindSim.
  ///
  /// In en, this message translates to:
  /// **'Sim'**
  String get creationKindSim;

  /// No description provided for @creationFolderSims4Tray.
  ///
  /// In en, this message translates to:
  /// **'Tray'**
  String get creationFolderSims4Tray;

  /// No description provided for @creationFolderSims3Library.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get creationFolderSims3Library;

  /// No description provided for @creationFolderSims2LotCatalog.
  ///
  /// In en, this message translates to:
  /// **'Lots & Houses bin'**
  String get creationFolderSims2LotCatalog;

  /// No description provided for @creationFolderSims2SavedSims.
  ///
  /// In en, this message translates to:
  /// **'Packaged Sims'**
  String get creationFolderSims2SavedSims;

  /// No description provided for @creationFolderSims1Houses.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood {number}'**
  String creationFolderSims1Houses(String number);

  /// No description provided for @creationBadFileName.
  ///
  /// In en, this message translates to:
  /// **'“{name}” has characters this system can’t use in a file name, so the game would never find it. Rename it and try again.'**
  String creationBadFileName(String name);

  /// No description provided for @creationFileInUse.
  ///
  /// In en, this message translates to:
  /// **'“{name}” is in use. Close the game and try again.'**
  String creationFileInUse(String name);

  /// No description provided for @creationSims1PickLot.
  ///
  /// In en, this message translates to:
  /// **'The Sims 1 numbers its lots by position on the map, so a house has to take over a lot that\'s already there - and that wipes whatever is on it. Pick the lot yourself: back it up, then rename the download to that lot\'s House number in the Houses folder.'**
  String get creationSims1PickLot;

  /// No description provided for @creationInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{That file couldn’t be added.} other{Those {count} files couldn’t be added.}}'**
  String creationInstallFailed(int count);

  /// No description provided for @creationRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'“{name}” couldn’t be deleted.'**
  String creationRemoveFailed(String name);

  /// No description provided for @creationsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get creationsAdd;

  /// No description provided for @creationsAdding.
  ///
  /// In en, this message translates to:
  /// **'Adding…'**
  String get creationsAdding;

  /// No description provided for @creationsPickerLabel.
  ///
  /// In en, this message translates to:
  /// **'{game} lots, rooms, households and Sims'**
  String creationsPickerLabel(String game);

  /// No description provided for @creationsNothingToAdd.
  ///
  /// In en, this message translates to:
  /// **'Nothing in there was a lot, a room, a household or a Sim this game can use. Custom content and mods go in through the library instead.'**
  String get creationsNothingToAdd;

  /// No description provided for @householdEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get householdEdit;

  /// No description provided for @householdEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit household'**
  String get householdEditTitle;

  /// No description provided for @householdEditBody.
  ///
  /// In en, this message translates to:
  /// **'Change what the save says about “{name}”.'**
  String householdEditBody(String name);

  /// No description provided for @householdEditName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get householdEditName;

  /// No description provided for @householdEditFunds.
  ///
  /// In en, this message translates to:
  /// **'Funds'**
  String get householdEditFunds;

  /// No description provided for @householdEditFundsMax.
  ///
  /// In en, this message translates to:
  /// **'Up to {max}, which is as much as this game will hold.'**
  String householdEditFundsMax(String max);

  /// No description provided for @householdEditSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get householdEditSave;

  /// No description provided for @householdEditNotice.
  ///
  /// In en, this message translates to:
  /// **'Close the game first: it writes its own save back when it quits. A copy of the file is kept before anything changes.'**
  String get householdEditNotice;

  /// No description provided for @errorSaveEditHouseholdGone.
  ///
  /// In en, this message translates to:
  /// **'That household isn’t in the save any more. Refresh the list and try again.'**
  String get errorSaveEditHouseholdGone;

  /// No description provided for @errorSaveEditUnreadable.
  ///
  /// In en, this message translates to:
  /// **'“{file}” isn’t laid out the way this app knows how to rewrite, so nothing was changed.'**
  String errorSaveEditUnreadable(String file);

  /// No description provided for @errorSaveEditVerification.
  ///
  /// In en, this message translates to:
  /// **'The rewritten “{file}” didn’t read back the way it should have, so it was thrown away. Your save is untouched.'**
  String errorSaveEditVerification(String file);

  /// No description provided for @errorSaveEditUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This game’s saves can be read, but not changed.'**
  String get errorSaveEditUnsupported;

  /// No description provided for @whatsNewEyebrow.
  ///
  /// In en, this message translates to:
  /// **'New in {version}'**
  String whatsNewEyebrow(String version);

  /// No description provided for @whatsNewAlsoSince.
  ///
  /// In en, this message translates to:
  /// **'Also in this update'**
  String get whatsNewAlsoSince;

  /// No description provided for @whatsNewDismiss.
  ///
  /// In en, this message translates to:
  /// **'Let’s go'**
  String get whatsNewDismiss;

  /// No description provided for @whatsNew300RootTitle.
  ///
  /// In en, this message translates to:
  /// **'Mods that live in the game’s own folders'**
  String get whatsNew300RootTitle;

  /// No description provided for @whatsNew300RootBody.
  ///
  /// In en, this message translates to:
  /// **'Worlds, graphics tweaks and script loaders never worked from the Mods folder. Now they install straight into the folders the game reads, and whatever they replace is kept safe, so uninstalling gives you the original back.'**
  String get whatsNew300RootBody;

  /// No description provided for @whatsNew300PacksTitle.
  ///
  /// In en, this message translates to:
  /// **'Listings can say which packs they need'**
  String get whatsNew300PacksTitle;

  /// No description provided for @whatsNew300PacksBody.
  ///
  /// In en, this message translates to:
  /// **'Creators can tag a mod with the packs it was built for, and The Exchange checks them against yours before you install. It’s always a heads-up, never a locked door.'**
  String get whatsNew300PacksBody;

  /// No description provided for @whatsNew300ContainersTitle.
  ///
  /// In en, this message translates to:
  /// **'A zip full of .sims3pack files just works'**
  String get whatsNew300ContainersTitle;

  /// No description provided for @whatsNew300ContainersBody.
  ///
  /// In en, this message translates to:
  /// **'Drop the whole set on the window. The Sims 3 containers tucked inside an archive are opened where they’re found, and the lot installs in one go.'**
  String get whatsNew300ContainersBody;

  /// No description provided for @whatsNew300SimCityTitle.
  ///
  /// In en, this message translates to:
  /// **'SimCity 3000, 4, Societies and 2013'**
  String get whatsNew300SimCityTitle;

  /// No description provided for @whatsNew300SimCityBody.
  ///
  /// In en, this message translates to:
  /// **'Four more games in the sidebar. SimCity 4 reads both of its Plugins folders, keeps the load order your folder and file names spell out, and leaves anything sc4pac installed alone. Settings can hide the games you don’t play.'**
  String get whatsNew300SimCityBody;

  /// No description provided for @whatsNew300CatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Thousands of SimCity 4 mods to browse'**
  String get whatsNew300CatalogTitle;

  /// No description provided for @whatsNew300CatalogBody.
  ///
  /// In en, this message translates to:
  /// **'The Exchange now carries the sc4pac channels beside our own listings, credited to the project that keeps them. A download brings everything it depends on or nothing at all, and where a host won’t let an app fetch a file, the button says so up front.'**
  String get whatsNew300CatalogBody;

  /// No description provided for @whatsNew300ThemeTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick the look you like'**
  String get whatsNew300ThemeTitle;

  /// No description provided for @whatsNew300ThemeBody.
  ///
  /// In en, this message translates to:
  /// **'The app used to change colour with whichever game you had open. Now you pick the look you want in Settings, and it stays put whichever game you’re managing.'**
  String get whatsNew300ThemeBody;

  /// No description provided for @categoryLot.
  ///
  /// In en, this message translates to:
  /// **'Lot'**
  String get categoryLot;

  /// No description provided for @categoryModel.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get categoryModel;

  /// No description provided for @categoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get categoryDescription;

  /// No description provided for @categoryBuilding.
  ///
  /// In en, this message translates to:
  /// **'Building'**
  String get categoryBuilding;

  /// No description provided for @setupHelpSimCity4.
  ///
  /// In en, this message translates to:
  /// **'SimCity 4 reads plugins from two folders at once: Documents > SimCity 4 > Plugins (yours, and the one this app manages) and a Plugins folder inside the game install. Folder and file names are the load order, so leave the structure a download arrives with alone - that is why sc4pac uses numbered folders and why overrides are named \"zzz...\". DLL plugins only load from the top level of a Plugins folder, never from a subfolder, so this app puts them there for you. Anything sc4pac installed stays sc4pac\'s: it is listed by that app, not this one.'**
  String get setupHelpSimCity4;

  /// No description provided for @setupHelpSimCity2013.
  ///
  /// In en, this message translates to:
  /// **'SimCity loads mods as .package files from SimCityUserData > Packages inside the game install (usually under Program Files, so Windows may ask for administrator rights). This app manages that folder only. The game also reads its own SimCityData folder, but that one holds Maxis\'s content, so a mod whose readme says it must load before the game\'s own packages has to go there by hand. Plenty of mods are marked offline-only: try them on a city you can afford to lose.'**
  String get setupHelpSimCity2013;

  /// No description provided for @setupHelpSimCity3000.
  ///
  /// In en, this message translates to:
  /// **'SimCity 3000 loads custom buildings (.bld files, made with the Building Architect Tool) from a Buildings folder inside the game install. It is a flat folder - a building in a subfolder is never loaded. The buildings that came with the game are hidden here so you cannot delete them by accident. Resolution and compatibility fixes that patch SC3U.exe itself are not something this app installs; follow their own instructions for those.'**
  String get setupHelpSimCity3000;

  /// No description provided for @setupHelpSimCitySocieties.
  ///
  /// In en, this message translates to:
  /// **'SimCity Societies keeps custom content in Documents > SimCity Societies > Import, which is where the game\'s own Package Installer puts it. This app can create the folder for you. Content comes as .SCSPack files - that is the extension the game itself looks for. Heads up: Societies was made to be edited rather than to load packaged mods - most of what the scene did was edit the C# and XML inside the game\'s own Data folder, which this app deliberately never touches.'**
  String get setupHelpSimCitySocieties;

  /// No description provided for @sectionManagedGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get sectionManagedGames;

  /// No description provided for @prefManageGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage {game}'**
  String prefManageGameTitle(String game);

  /// No description provided for @prefManageGameDesc.
  ///
  /// In en, this message translates to:
  /// **'Show it in the sidebar. Hiding a game keeps every setting it has.'**
  String get prefManageGameDesc;

  /// No description provided for @errorLastManagedGame.
  ///
  /// In en, this message translates to:
  /// **'That’s the only game left in your sidebar, so it has to stay. Turn on another one first if you want to hide it.'**
  String get errorLastManagedGame;

  /// No description provided for @catalogCount.
  ///
  /// In en, this message translates to:
  /// **'{count} mods'**
  String catalogCount(int count);

  /// No description provided for @catalogCuratedBy.
  ///
  /// In en, this message translates to:
  /// **'Catalog by {project}'**
  String catalogCuratedBy(String project);

  /// No description provided for @catalogOpenPage.
  ///
  /// In en, this message translates to:
  /// **'Open page'**
  String get catalogOpenPage;

  /// No description provided for @catalogBlocked.
  ///
  /// In en, this message translates to:
  /// **'{host} doesn\'t let apps download for you. Grab it from the mod\'s own page instead.'**
  String catalogBlocked(String host);

  /// No description provided for @catalogUnresolvedNote.
  ///
  /// In en, this message translates to:
  /// **'This one couldn\'t be read from the catalog.'**
  String get catalogUnresolvedNote;

  /// No description provided for @catalogDependencies.
  ///
  /// In en, this message translates to:
  /// **'Comes with'**
  String get catalogDependencies;

  /// No description provided for @catalogFileCount.
  ///
  /// In en, this message translates to:
  /// **'{count} files'**
  String catalogFileCount(int count);

  /// No description provided for @catalogDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading {current} of {total}'**
  String catalogDownloading(int current, int total);

  /// No description provided for @catalogWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Heads up'**
  String get catalogWarningTitle;

  /// No description provided for @catalogConflictsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clashes with'**
  String get catalogConflictsTitle;

  /// No description provided for @catalogSourceFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach {source}'**
  String catalogSourceFailed(String source);

  /// No description provided for @catalogEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches that.'**
  String get catalogEmpty;

  /// No description provided for @catalogRefresh.
  ///
  /// In en, this message translates to:
  /// **'Reload the catalog'**
  String get catalogRefresh;

  /// No description provided for @catalogOptions.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get catalogOptions;

  /// No description provided for @catalogBy.
  ///
  /// In en, this message translates to:
  /// **'by {author}'**
  String catalogBy(String author);

  /// No description provided for @errorCatalogUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the catalog. Check your connection and try again.'**
  String get errorCatalogUnreachable;

  /// No description provided for @errorCatalogUnreadable.
  ///
  /// In en, this message translates to:
  /// **'The catalog answered with something this version can\'t read.'**
  String get errorCatalogUnreadable;

  /// No description provided for @errorCatalogDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'{host} refused the download.'**
  String errorCatalogDownloadFailed(String host);

  /// No description provided for @errorCatalogInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong installing that.'**
  String get errorCatalogInstallFailed;

  /// No description provided for @errorCatalogInstallCancelled.
  ///
  /// In en, this message translates to:
  /// **'Install cancelled.'**
  String get errorCatalogInstallCancelled;

  /// No description provided for @catalogLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading the catalog…'**
  String get catalogLoading;

  /// No description provided for @catalogBack.
  ///
  /// In en, this message translates to:
  /// **'← Back to the catalog'**
  String get catalogBack;

  /// No description provided for @catalogPromoTitle.
  ///
  /// In en, this message translates to:
  /// **'Made a mod yourself?'**
  String get catalogPromoTitle;

  /// No description provided for @catalogPromoBody.
  ///
  /// In en, this message translates to:
  /// **'Put it on The Exchange and it installs in one click, gets its own page and link, and everyone who already has it hears about updates.'**
  String get catalogPromoBody;
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
        'nl',
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
    case 'nl':
      return LNl();
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
