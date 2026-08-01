import 'dart:convert';

/// Clashes the user has told the app to stop reporting.
///
/// The conflict scan is a warning, not a verdict: patch mods, overrides
/// and multi-part sets are built to shadow each other's resources, and a
/// load order the player arranged on purpose looks exactly like an
/// accident from the outside. Only the player knows which is which, so
/// they can settle one, and what is settled is remembered here.
///
/// The unit is the pair, never the mod. A package overlapping five others
/// may have one deliberate partner among them, and dismissing the mod
/// would hide the four that are really a problem. A pair is unordered -
/// the same clash is drawn on both mods' pages and either side may be the
/// one the user opened - which is what [conflictPairKey] is for.
///
/// Paths are relative to the game's mods folder and are the name the mod
/// carries while it is switched on, like the shop's install records: a
/// pair survives being disabled and re-enabled, and a whole install can
/// move without the record going stale. Renaming or reinstalling a mod
/// does lose it, which is honest - that is a different file, and whether
/// its clash is deliberate is a fresh question.

/// Separates the two paths of a pair in memory. A NUL byte is the one
/// character no file name on any of our platforms can hold.
const _separator = '\u0000';

/// The key for the clash between [a] and [b], whichever way round it is
/// asked.
String conflictPairKey(String a, String b) =>
    a.compareTo(b) <= 0 ? '$a$_separator$b' : '$b$_separator$a';

/// The two paths behind [key], or null when it isn't one of ours.
List<String>? conflictPairPaths(String key) {
  final parts = key.split(_separator);
  if (parts.length != 2 || parts.any((part) => part.isEmpty)) return null;
  return parts;
}

/// The stored pairs by game id, or an empty map when there are none. A
/// record that doesn't parse costs only itself: the worst it can do is
/// report a clash the user had already settled.
Map<String, Set<String>> parseIgnoredConflicts(String? source) {
  if (source == null || source.isEmpty) return {};
  try {
    final json = jsonDecode(source);
    if (json is! Map) return {};
    final ignored = <String, Set<String>>{};
    for (final entry in json.entries) {
      final gameId = entry.key;
      final pairs = entry.value;
      if (gameId is! String || pairs is! List) continue;
      final kept = <String>{};
      for (final pair in pairs) {
        if (pair is! List || pair.length != 2) continue;
        final a = pair[0], b = pair[1];
        if (a is! String || b is! String || a.isEmpty || b.isEmpty) continue;
        kept.add(conflictPairKey(a, b));
      }
      if (kept.isNotEmpty) ignored[gameId] = kept;
    }
    return ignored;
  } catch (_) {
    return {};
  }
}

String encodeIgnoredConflicts(Map<String, Set<String>> ignored) => jsonEncode({
      for (final entry in ignored.entries)
        if (entry.value.isNotEmpty)
          entry.key: [
            for (final key in entry.value.toList()..sort())
              if (conflictPairPaths(key) case final paths?) paths,
          ],
    });
