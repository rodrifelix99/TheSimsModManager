import '../../core/trivia.dart';

/// What the plumbob knows, per game.
///
/// This sits beside the adapters rather than in core for the same reason
/// [demoPacks] does: every one of these is about The Sims specifically,
/// and core is not allowed to know a game exists. Another series added
/// later brings its own table or none at all.
///
/// Only keys live here. The wording is in the twelve ARB files, resolved
/// by `AppText.triviaFact` when it is drawn, so a fact reaches a Polish
/// player in Polish. Adding one means a key here, a message in
/// `app_en.arb`, and the same message in the other eleven - `trivia_test`
/// fails on any of the three going missing.

/// The facts that hold for the whole franchise, mixed into every game's
/// deck. Four of them are written about a screen rather than a game (see
/// [TriviaContext]) and only surface while you are on it.
const seriesTrivia = <TriviaFact>[
  TriviaFact('triviaSeriesLlama', 'origins'),
  TriviaFact('triviaSeriesSimlish', 'language'),
  TriviaFact('triviaSeriesCheats', 'cheats'),
  TriviaFact('triviaSeriesRecords', 'records'),
  TriviaFact('triviaSeriesGoths', 'lore'),
  TriviaFact('triviaSeriesReaper', 'death'),
  TriviaFact('triviaSeriesSimCity', 'origins'),
  TriviaFact('triviaSeriesLegacy', 'records'),
  TriviaFact('triviaSeriesPlumbob', 'language'),
  TriviaFact('triviaSeriesModScene', 'modding'),
  TriviaFact('triviaSeriesConflicts', 'modding',
      context: TriviaContext.library),
  TriviaFact('triviaSeriesPackage', 'modding', context: TriviaContext.library),
  TriviaFact('triviaSeriesRename', 'modding', context: TriviaContext.library),
  TriviaFact('triviaSeriesSaves', 'design', context: TriviaContext.saves),
  TriviaFact('triviaSeriesPacks', 'design', context: TriviaContext.packs),
];

const sims1Trivia = <TriviaFact>[
  TriviaFact('triviaSims1Dollhouse', 'origins'),
  TriviaFact('triviaSims1Oakland', 'origins'),
  TriviaFact('triviaSims1Toilet', 'origins'),
  TriviaFact('triviaSims1HomeTactics', 'origins'),
  TriviaFact('triviaSims1Myst', 'records'),
  TriviaFact('triviaSims1Simlish', 'language'),
  TriviaFact('triviaSims1Architecture', 'design'),
  TriviaFact('triviaSims1Audience', 'records'),
  TriviaFact('triviaSims1Cowplant', 'lore'),
  TriviaFact('triviaSims1Plumbob', 'language'),
  TriviaFact('triviaSims1Release', 'records'),
  TriviaFact('triviaSims1Edith', 'design'),
  TriviaFact('triviaSims1Expansions', 'records'),
  TriviaFact('triviaSims1Unleashed', 'records'),
  TriviaFact('triviaSims1Clown', 'lore'),
  TriviaFact('triviaSims1Llama', 'lore'),
  TriviaFact('triviaSims1Superstar', 'design'),
  TriviaFact('triviaSims1Catalogue', 'design'),
];

const sims2Trivia = <TriviaFact>[
  TriviaFact('triviaSims2Aging', 'design'),
  TriviaFact('triviaSims2Memories', 'design'),
  TriviaFact('triviaSims2Bella', 'lore'),
  TriviaFact('triviaSims2Strangetown', 'lore'),
  TriviaFact('triviaSims2FamilyTrees', 'lore'),
  TriviaFact('triviaSims2Plead', 'death'),
  TriviaFact('triviaSims2ReaperRomance', 'death'),
  TriviaFact('triviaSims2Satellite', 'death'),
  TriviaFact('triviaSims2Therapist', 'design'),
  TriviaFact('triviaSims2WantsFears', 'design'),
  TriviaFact('triviaSims2FaceSculpt', 'design'),
  TriviaFact('triviaSims2Aliens', 'lore'),
  TriviaFact('triviaSims2FreezerBunny', 'lore'),
  TriviaFact('triviaSims2SocialBunny', 'lore'),
  TriviaFact('triviaSims2Giveaway', 'records'),
];

const sims3Trivia = <TriviaFact>[
  TriviaFact('triviaSims3SunsetValley', 'lore'),
  TriviaFact('triviaSims3Founders', 'lore'),
  TriviaFact('triviaSims3OpenWorld', 'design'),
  TriviaFact('triviaSims3Simulation', 'design'),
  TriviaFact('triviaSims3CreateAStyle', 'design'),
  TriviaFact('triviaSims3Exchange', 'community'),
  TriviaFact('triviaSims3Downloads', 'community'),
  TriviaFact('triviaSims3Traits', 'design'),
  TriviaFact('triviaSims3Kleptomaniac', 'lore'),
  TriviaFact('triviaSims3Simlish', 'music'),
  TriviaFact('triviaSims3Townies', 'design'),
  TriviaFact('triviaSims3Store', 'records'),
  TriviaFact('triviaSims3Launch', 'records'),
];

const sims4Trivia = <TriviaFact>[
  TriviaFact('triviaSims4Flies', 'death'),
  TriviaFact('triviaSims4Emotions', 'design'),
  TriviaFact('triviaSims4EmotionDeaths', 'death'),
  TriviaFact('triviaSims4CreateASim', 'design'),
  TriviaFact('triviaSims4Launch', 'records'),
  TriviaFact('triviaSims4Worlds', 'records'),
  TriviaFact('triviaSims4Gender', 'design'),
  TriviaFact('triviaSims4Newcrest', 'community'),
  TriviaFact('triviaSims4Naming', 'language'),
  TriviaFact('triviaSims4Goths', 'lore'),
  TriviaFact('triviaSims4FreeToPlay', 'records'),
  TriviaFact('triviaSims4Mccc', 'modding'),
  TriviaFact('triviaSims4Twallan', 'modding'),
  TriviaFact('triviaSims4Deaths', 'death'),
];

const simsMedievalTrivia = <TriviaFact>[
  TriviaFact('triviaMedievalWatcher', 'design'),
  TriviaFact('triviaMedievalHeroes', 'design'),
  TriviaFact('triviaMedievalStocks', 'design'),
  TriviaFact('triviaMedievalAmbition', 'design'),
  TriviaFact('triviaMedievalQuests', 'design'),
  TriviaFact('triviaMedievalPirates', 'records'),
  TriviaFact('triviaMedievalProxy', 'modding'),
  TriviaFact('triviaMedievalEngine', 'modding'),
];

/// The chips a fact can draw under. Ten of them on purpose: enough to
/// group a deck of eighty, few enough that the set stays translatable
/// and a reader learns them.
const triviaCategories = <String>[
  'origins',
  'design',
  'lore',
  'death',
  'music',
  'cheats',
  'records',
  'modding',
  'language',
  'community',
];
