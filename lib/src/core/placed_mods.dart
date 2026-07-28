import 'dart:convert';

/// Mods the app put in folders the game keeps its own files in.
///
/// Most of what a game reads is a folder that belongs to the player, and
/// listing it is enough to know what is installed. Some folders are not:
/// The Sims 1 loads behaviour overrides out of `GameData\Global` and
/// per-expansion ones out of `ExpansionPack6`, and Maxis's own files sit
/// in there too. Sweeping those into the library would offer the user a
/// switch to turn off the base game, so instead the app remembers what it
/// put there and lists only that.
///
/// Paths are relative to the game's mods folder, which is how the shop's
/// install records store theirs - a sibling folder simply climbs out with
/// `..`. Storing them relative rather than absolute means a whole install
/// can be moved without the record going stale, and none of the user's
/// folder names end up in a preference.

/// The stored records by game id, or an empty map when there are none.
/// A record that doesn't parse costs only itself: this list is a
/// convenience, and losing all of it because one entry is malformed would
/// hide mods that are really there.
Map<String, Set<String>> parsePlacedMods(String? source) {
  if (source == null || source.isEmpty) return {};
  try {
    final json = jsonDecode(source);
    if (json is! Map) return {};
    final placed = <String, Set<String>>{};
    for (final entry in json.entries) {
      final gameId = entry.key;
      final paths = entry.value;
      if (gameId is! String || paths is! List) continue;
      final kept = <String>{
        for (final path in paths)
          if (path is String && path.isNotEmpty) path,
      };
      if (kept.isNotEmpty) placed[gameId] = kept;
    }
    return placed;
  } catch (_) {
    return {};
  }
}

String encodePlacedMods(Map<String, Set<String>> placed) => jsonEncode({
      for (final entry in placed.entries)
        if (entry.value.isNotEmpty) entry.key: entry.value.toList()..sort(),
    });
