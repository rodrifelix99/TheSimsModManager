import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
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

  /// No description provided for @conflictTooltipActive.
  ///
  /// In en, this message translates to:
  /// **'Showing conflicting mods only. Click to show all mods again.'**
  String get conflictTooltipActive;

  /// No description provided for @conflictTooltip.
  ///
  /// In en, this message translates to:
  /// **'Enabled mods sharing a file name with another enabled mod, installed in more than one version, or overriding the same in-game resources. The game only keeps the copy it loads last — sometimes intentional (patch mods), often not.'**
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
  /// **'These packages contain resources with the same identifiers, so the game only keeps the copy it loads last. That can be intentional — patch and override mods shadow another mod\'s resources on purpose — but for unrelated mods it means one of them silently stops working: keep the one you want and disable the rest.'**
  String get conflictResourcesBody;

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
  /// **'The app speaks ten languages thanks to these simmers.'**
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

  /// No description provided for @errorInstallFailed.
  ///
  /// In en, this message translates to:
  /// **'“{name}” couldn’t be installed — {reason}. Unpack it manually and install the files inside if it keeps failing.'**
  String errorInstallFailed(String name, String reason);

  /// No description provided for @errorInstallFailedRaw.
  ///
  /// In en, this message translates to:
  /// **'“{name}” couldn’t be installed — {reason}'**
  String errorInstallFailedRaw(String name, String reason);

  /// No description provided for @errorFileInUseDelete.
  ///
  /// In en, this message translates to:
  /// **'“{name}” couldn’t be deleted — it’s in use by another program (is the game running?) or write-protected. Close anything using it and try again.'**
  String errorFileInUseDelete(String name);

  /// No description provided for @errorFileInUseRename.
  ///
  /// In en, this message translates to:
  /// **'“{name}” couldn’t be renamed — it’s in use by another program (is the game running?) or write-protected. Close anything using it and try again.'**
  String errorFileInUseRename(String name);

  /// No description provided for @errorFileMissing.
  ///
  /// In en, this message translates to:
  /// **'“{name}” is no longer in the mods folder — it may have been moved or deleted by another program.'**
  String errorFileMissing(String name);

  /// No description provided for @errorShopDownload.
  ///
  /// In en, this message translates to:
  /// **'“{name}” couldn’t be downloaded from The Exchange. Check your connection and try again.'**
  String errorShopDownload(String name);

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

  /// No description provided for @setupHelpSims1.
  ///
  /// In en, this message translates to:
  /// **'The original The Sims keeps custom content inside its install folder, not Documents: objects go in a Downloads folder next to the game executable (e.g. C:\\Program Files (x86)\\Maxis\\The Sims\\Downloads), and this app sorts the other types automatically — skins (.skn/.cmx/.bmp) into GameData\\Skins, walls and floors into GameData\\Walls and GameData\\Floors. The 2025 Legacy Collection works the same way from its own install folder (EA Games\\The Sims Legacy, or Steam\\steamapps\\common\\The Sims Legacy Collection). If the game is installed somewhere else (a different drive, a custom Steam library), pick its Downloads folder manually.'**
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
