/// Identity and metadata for a moddable game supported by the manager.
///
/// A [Game] is pure data; all game-specific behavior lives in its
/// [GameAdapter]. New games (SimCity, or anything else) are added by
/// creating a new adapter and registering it; this class never changes.
class Game {
  const Game({
    required this.id,
    required this.name,
    required this.series,
    this.year,
  });

  /// Stable machine identifier, e.g. `sims4`. Used for settings keys, so
  /// changing one orphans that game's saved folder override.
  final String id;

  final String name;

  /// Franchise grouping for the sidebar, e.g. `The Sims` or `SimCity`.
  final String series;

  final int? year;

  @override
  bool operator ==(Object other) => other is Game && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
