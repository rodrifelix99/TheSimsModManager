/// The facts the plumbob tells you while you work.
///
/// A fact is a key and a category, never wording: core has no
/// localizations, so what reaches the screen is resolved by
/// `AppText.triviaFact` at the moment it is drawn - the same bargain
/// [Mod.category] and [GameAdapter.setupHelpKey] make. That is also what
/// keeps a fact translatable: the eleven ARB files carry the prose and
/// this table carries only which fact goes with which game.
library;

/// Where a fact belongs, for the ones written about a particular corner
/// of the app rather than about a game.
///
/// Core names the screen because the fact is *about* that screen - what
/// a conflict is, what a pack switch actually changes - and the UI is
/// what decides you are looking at it. A fact with no context is fair
/// game anywhere the buddy appears, which is nearly all of them.
///
/// These are exactly the three screens the buddy shows on. It is kept
/// off the mod page, Settings and The Exchange, where the user came to
/// read or to decide something and a bubble in the corner is in the way.
enum TriviaContext { library, saves, packs }

/// One fact: an ARB key, the chip it draws under, and optionally the
/// screen it was written for.
class TriviaFact {
  const TriviaFact(this.key, this.category, {this.context});

  /// The ARB message holding the wording, in every language.
  final String key;

  /// A stable English key for the little chip above the fact, resolved
  /// by `AppText.triviaCategory`. Deliberately a short shared set rather
  /// than one label per fact: it groups, it doesn't caption.
  final String category;

  /// The screen this one was written for, or null for a fact about the
  /// game itself.
  final TriviaContext? context;

  /// Whether this fact may surface while the user is looking at [where].
  /// Facts with no context always may; null is a screen no fact was
  /// written about, which leaves only those.
  bool fitsContext(TriviaContext? where) => context == null || context == where;
}
