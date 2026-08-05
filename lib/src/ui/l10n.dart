import 'dart:ui' show Locale;

import '../../l10n/app_localizations.dart';
import '../core/app_message.dart';
import '../core/game_pack.dart';
import '../core/mod_kind.dart';

export '../../l10n/app_localizations.dart' show L;

/// The languages the app ships, in the order the Settings picker lists
/// them: English first, then the rest by how many people the Sims
/// modding scene has in them. Each entry's [name] is written in that
/// language, because a picker that says "German" to someone who only
/// reads German is no help at all. [by] is the handle Settings credits
/// for the translation; the README table says the same thing and the two
/// are kept in step by hand.
const appLanguages = <({String code, String name, String by})>[
  (code: 'en', name: 'English', by: 'rodrifelix99'),
  (code: 'zh', name: '简体中文', by: 'xiaoyu_sims'),
  (code: 'es', name: 'Español', by: 'marisol_plumbob'),
  (code: 'pt', name: 'Português (Brasil)', by: 'rodrifelix99'),
  (code: 'fr', name: 'Français', by: 'clodesims'),
  (code: 'de', name: 'Deutsch', by: 'plumbobjonas'),
  (code: 'it', name: 'Italiano', by: 'giuliapixel89'),
  (code: 'ru', name: 'Русский', by: 'verasimka'),
  (code: 'pl', name: 'Polski', by: 'kasia_pxl'),
  (code: 'ja', name: '日本語', by: 'mochi_simjp'),
  (code: 'el', name: 'Ελληνικά', by: 'friendofbellas'),
];

/// What [MaterialApp.supportedLocales] gets, in [appLanguages] order rather
/// than the generated `L.supportedLocales` order. The generator sorts
/// alphabetically, which puts German first, and Flutter falls back to the
/// *first* supported locale when a system language matches nothing at all -
/// so shipping the generated list hands a Korean or Turkish machine a German
/// app. English first makes the fallback English.
final List<Locale> appSupportedLocales = [
  for (final language in appLanguages) Locale(language.code),
];

/// Lookups for the strings that don't live in the widget that shows them:
/// adapters hand out stable English keys ([Mod.category], the content
/// labels from the package scan, [GameAdapter.setupHelpKey]), and what
/// went wrong with an install or a mod file arrives as an [AppMessage].
/// The UI translates them here. Keys the ARB files don't know are shown
/// as-is, so a new game or a newly recognized resource type degrades to
/// English instead of blanking out.
extension AppText on L {
  String categoryName(String key) => switch (key) {
        'Package' => categoryPackage,
        'Script' => categoryScript,
        'Object' => categoryObject,
        'Archive' => categoryArchive,
        'Skin' => categorySkin,
        'Texture' => categoryTexture,
        'Wall' => categoryWall,
        'Floor' => categoryFloor,
        _ => key,
      };

  /// What to call a whole shelf of packs of one tier. Plural because it
  /// only ever heads a section; a pack says which tier it is by sitting
  /// under one.
  String packKindPlural(GamePackKind kind) => switch (kind) {
        GamePackKind.expansion => packKindExpansions,
        GamePackKind.gamePack => packKindGamePacks,
        GamePackKind.stuff => packKindStuffPacks,
        GamePackKind.kit => packKindKits,
        GamePackKind.free => packKindFreePacks,
      };

  /// What a game has to say about a collection, for the shelves that have
  /// earned a remark. Unlike everything else here an unknown key draws
  /// nothing rather than falling back to itself: a stray `packsAllOwned`
  /// on screen is worse than the joke going untold.
  String? packNote(AppMessage message) {
    String arg(int i) => i < message.args.length ? message.args[i] : '';
    return switch (message.key) {
      'packsAllOwnedSims4' => packsAllOwnedSims4(arg(0), arg(1)),
      _ => null,
    };
  }

  /// What a mod turns out to be, worked out from what is inside it. The
  /// keys are `core/mod_kind.dart`'s and stay English as they travel;
  /// an unknown one draws as itself, like the content labels below.
  String modKind(String key) => switch (key) {
        kindCasPart => modKindCas,
        kindBuildBuy => modKindBuildBuy,
        kindGameplay => modKindGameplay,
        kindScript => modKindScript,
        _ => key,
      };

  String contentLabel(String key) => switch (key) {
        'CAS parts' => contentCasParts,
        'objects' => contentObjects,
        'tunings' => contentTunings,
        'behaviors' => contentBehaviors,
        'text tables' => contentTextTables,
        'textures' => contentTextures,
        'meshes' => contentMeshes,
        _ => key,
      };

  /// What the game still needs before it runs any of this. The adapter
  /// names the requirement, not the wording; a key with no translation
  /// yet is not worth a banner, so it draws nothing.
  String? requirement(String key) => switch (key) {
        'medievalModLoader' => requirementMedievalModLoader,
        'sims4ModsOff' => requirementSims4ModsOff,
        'sims4ScriptModsOff' => requirementSims4ScriptModsOff,
        _ => null,
      };

  String eraName(String key) => switch (key) {
        'classic' => eraClassic,
        'nightlife' => eraNightlife,
        'ambitions' => eraAmbitions,
        'modern' => eraModern,
        'medieval' => eraMedieval,
        _ => key,
      };

  /// What went wrong, in the user's language. The failing layer is core,
  /// which has no localizations, so it hands over a key and the values
  /// that go in it (see [AppMessage]); wording it had no key for - an OS
  /// error, an exception nobody foresaw - comes through untouched.
  String errorText(AppMessage message) {
    final text = message.text;
    if (text != null) return text;
    String arg(int i) => i < message.args.length ? message.args[i] : '';
    return switch (message.key) {
      'noModFiles' => errorNoModFiles(arg(0), arg(1)),
      'unreadableArchive' => errorUnreadableArchive(arg(0)),
      'noUnpacker' => errorNoUnpacker(arg(0), arg(1)),
      'noUnpackerLinux' => errorNoUnpackerLinux(arg(0), arg(1)),
      'noUnpackerLinuxRar' => errorNoUnpackerLinuxRar(arg(0), arg(1)),
      'unpackFailed' => errorUnpackFailed(arg(0)),
      'sims3PackUnreadable' => errorSims3PackUnreadable(arg(0)),
      'sims3PackWorld' => errorSims3PackWorld(arg(0)),
      'sims3PackLibrary' => errorSims3PackLibrary(arg(0)),
      'installFailed' => errorInstallFailed(arg(0), arg(1)),
      'installFailedRaw' => errorInstallFailedRaw(arg(0), arg(1)),
      'fileInUseDelete' => errorFileInUseDelete(arg(0)),
      'fileInUseRename' => errorFileInUseRename(arg(0)),
      'fileMissing' => errorFileMissing(arg(0)),
      // A batch says how many refused rather than naming them: the count
      // travels as a string like every other argument core hands up.
      'bulkToggleFailed' =>
        errorBulkToggleFailed(int.tryParse(arg(0)) ?? 0),
      'bulkRemoveFailed' =>
        errorBulkRemoveFailed(int.tryParse(arg(0)) ?? 0),
      'bulkMoveFailed' => errorBulkMoveFailed(int.tryParse(arg(0)) ?? 0),
      'fileNameTaken' => errorFileNameTaken(arg(0)),
      'folderNameBad' => errorFolderNameBad(arg(0)),
      'folderTooDeep' => errorFolderTooDeep(int.tryParse(arg(0)) ?? 0),
      'errorNoWriteAccess' => errorNoWriteAccess(arg(0)),
      'shopDownloadFailed' => errorShopDownload(arg(0)),
      'shopNoModFiles' => errorShopNoModFiles(arg(0)),
      'shopNeedsFolder' => shopNeedsFolder(arg(0)),
      'shopListingNotFound' => errorShopListingNotFound,
      'shopListingUnknownGame' => errorShopListingUnknownGame,
      'errorPackToggleFailed' => errorPackToggleFailed(arg(0)),
      'errorPackNoUserData' => errorPackNoUserData,
      'errorPackNeedsAdmin' => errorPackNeedsAdmin,
      'errorPackNotSupported' => errorPackNotSupported,
      'errorPackIsTheGame' => errorPackIsTheGame,
      'errorPackToggleRefused' => errorPackToggleRefused,
      _ => '$message',
    };
  }

  /// What belongs in one of a game's install folders. [key] comes from
  /// the adapter, so the install dialog can list The Sims 1's folders
  /// without knowing which game it is looking at; a folder the ARB files
  /// have nothing to say about is drawn as its path alone.
  String destinationDescription(String key) => switch (key) {
        'sims1Downloads' => destinationSims1Downloads,
        'sims1Global' => destinationSims1Global,
        'sims1Objects' => destinationSims1Objects,
        'sims1Skins' => destinationSims1Skins,
        'sims1SkinsBuy' => destinationSims1SkinsBuy,
        'sims1Walls' => destinationSims1Walls,
        'sims1Floors' => destinationSims1Floors,
        'sims1Roofs' => destinationSims1Roofs,
        _ => '',
      };

  /// The game's "where do mods live" guidance. [key] comes from the
  /// adapter, so the UI still knows nothing about concrete games; an
  /// adapter without a translation yet falls back to the empty string
  /// and the surrounding cards simply have nothing to say.
  String setupHelp(String key) => switch (key) {
        'sims1' => setupHelpSims1,
        'sims2' => setupHelpSims2,
        'sims3' => setupHelpSims3,
        'sims4' => setupHelpSims4,
        'simsmedieval' => setupHelpSimsMedieval,
        _ => '',
      };

  // What the save scanners report travels as stable keys too (they name
  // the games' own enums); like everything else here, an unknown key -
  // a life stage or skill a future game adds - degrades to the key
  // itself instead of blanking.

  String savesAge(String key) => switch (key) {
        'infant' => savesAgeInfant,
        'baby' => savesAgeBaby,
        'toddler' => savesAgeToddler,
        'child' => savesAgeChild,
        'teen' => savesAgeTeen,
        'youngAdult' => savesAgeYoungAdult,
        'adult' => savesAgeAdult,
        'elder' => savesAgeElder,
        _ => key,
      };

  String savesGender(String key) => switch (key) {
        'male' => savesGenderMale,
        'female' => savesGenderFemale,
        _ => key,
      };

  String savesSkill(String key) => switch (key) {
        'cooking' => savesSkillCooking,
        'mechanical' => savesSkillMechanical,
        'charisma' => savesSkillCharisma,
        'body' => savesSkillBody,
        'logic' => savesSkillLogic,
        'creativity' => savesSkillCreativity,
        'cleaning' => savesSkillCleaning,
        _ => key,
      };

  String savesPersonality(String key) => switch (key) {
        'neat' => savesPersonalityNeat,
        'outgoing' => savesPersonalityOutgoing,
        'active' => savesPersonalityActive,
        'playful' => savesPersonalityPlayful,
        'nice' => savesPersonalityNice,
        _ => key,
      };

  String savesZodiac(String key) => switch (key) {
        'aries' => savesZodiacAries,
        'taurus' => savesZodiacTaurus,
        'gemini' => savesZodiacGemini,
        'cancer' => savesZodiacCancer,
        'leo' => savesZodiacLeo,
        'virgo' => savesZodiacVirgo,
        'libra' => savesZodiacLibra,
        'scorpio' => savesZodiacScorpio,
        'sagittarius' => savesZodiacSagittarius,
        'capricorn' => savesZodiacCapricorn,
        'aquarius' => savesZodiacAquarius,
        'pisces' => savesZodiacPisces,
        _ => key,
      };

  String savesAspiration(String key) => switch (key) {
        'romance' => savesAspirationRomance,
        'family' => savesAspirationFamily,
        'fortune' => savesAspirationFortune,
        'popularity' => savesAspirationPopularity,
        'knowledge' => savesAspirationKnowledge,
        'growUp' => savesAspirationGrowUp,
        'pleasure' => savesAspirationPleasure,
        'grilledCheese' => savesAspirationGrilledCheese,
        _ => key,
      };

  String savesRelationshipFlag(String key) => switch (key) {
        'crush' => savesRelCrush,
        'love' => savesRelLove,
        'engaged' => savesRelEngaged,
        'married' => savesRelMarried,
        'friends' => savesRelFriends,
        'bestFriends' => savesRelBestFriends,
        'steady' => savesRelSteady,
        'enemies' => savesRelEnemies,
        _ => key,
      };

  String savesPhotoKind(String key) => switch (key) {
        'familyPortrait' => savesPhotoFamilyPortrait,
        'lot' => savesPhotoLot,
        'sim' => savesPhotoSim,
        'snapshot' => savesPhotoSnapshot,
        _ => key,
      };

  /// What a household member is when it isn't an ordinary living sim -
  /// the pets share this slot, since it is the same question.
  String savesOccult(String key) => switch (key) {
        'largeDog' => savesSpeciesLargeDog,
        'smallDog' => savesSpeciesSmallDog,
        'cat' => savesSpeciesCat,
        'vampire' => savesOccultVampire,
        'zombie' => savesOccultZombie,
        'werewolf' => savesOccultWerewolf,
        'plantSim' => savesOccultPlantSim,
        'alien' => savesOccultAlien,
        'servo' => savesOccultServo,
        'witch' => savesOccultWitch,
        'bigfoot' => savesOccultBigfoot,
        'fairy' => savesOccultFairy,
        'genie' => savesOccultGenie,
        'mermaid' => savesOccultMermaid,
        _ => key,
      };

  String savesLotType(String key) => switch (key) {
        'residential' => savesLotResidential,
        'community' => savesLotCommunity,
        'dorm' => savesLotDorm,
        'secretSociety' => savesLotSecretSociety,
        'greekHouse' => savesLotGreekHouse,
        'hotel' => savesLotHotel,
        'secret' => savesLotSecret,
        'ownableBusiness' => savesLotBusiness,
        'apartment' => savesLotApartment,
        _ => key,
      };

  String savesHobby(String key) => switch (key) {
        'cuisine' => savesHobbyCuisine,
        'arts' => savesHobbyArts,
        'film' => savesHobbyFilm,
        'sports' => savesHobbySports,
        'games' => savesHobbyGames,
        'nature' => savesHobbyNature,
        'tinkering' => savesHobbyTinkering,
        'fitness' => savesHobbyFitness,
        'science' => savesHobbyScience,
        'music' => savesHobbyMusic,
        _ => key,
      };

  /// How a sim's relatives of one kind are introduced. [count] picks the
  /// plural, so one child reads "child" and three read "children".
  String savesFamilyTie(String key, int count) => switch (key) {
        'mother' => savesTieMother,
        'father' => savesTieFather,
        'spouse' => savesTieSpouse,
        'sibling' => savesTieSibling(count),
        'child' => savesTieChild(count),
        _ => key,
      };

  String savesInterest(String key) => switch (key) {
        'politics' => savesInterestPolitics,
        'money' => savesInterestMoney,
        'environment' => savesInterestEnvironment,
        'crime' => savesInterestCrime,
        'entertainment' => savesInterestEntertainment,
        'culture' => savesInterestCulture,
        'food' => savesInterestFood,
        'health' => savesInterestHealth,
        'fashion' => savesInterestFashion,
        'sports' => savesInterestSports,
        'paranormal' => savesInterestParanormal,
        'travel' => savesInterestTravel,
        'work' => savesInterestWork,
        'weather' => savesInterestWeather,
        'animals' => savesInterestAnimals,
        'school' => savesInterestSchool,
        'toys' => savesInterestToys,
        'sciFi' => savesInterestSciFi,
        'music' => savesInterestMusic,
        'outdoors' => savesInterestOutdoors,
        _ => key,
      };
}
