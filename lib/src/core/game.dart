/// Identity and metadata for a moddable game supported by the manager.
///
/// A [Game] is pure data; all game-specific behavior lives in its
/// [GameAdapter]. New games (SimCity, or anything else) are added by
/// creating a new adapter and registering it — this class never changes.
class Game {
  const Game({
    required this.id,
    required this.name,
    required this.series,
    this.year,
  });

  /// Stable machine identifier, e.g. `sims4`. Used for settings keys.
  final String id;

  /// Display name, e.g. `The Sims 4`.
  final String name;

  /// Franchise grouping for the UI, e.g. `The Sims` or `SimCity`.
  final String series;

  /// Original release year, e.g. 2014. Display-only.
  final int? year;

  @override
  bool operator ==(Object other) => other is Game && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
