import 'dart:convert';

/// Labels the player puts on their own mods, and the third axis the
/// library can be narrowed by - beside the file type, which the adapter
/// decides, and the subfolder, which the disk decides. This one is the
/// only vocabulary in the app that is entirely the user's: "wcif",
/// "testing", "alpha cc", "keep for the legacy save". Nothing here reads
/// a tag or acts on it; it exists to be written down and filtered by.
///
/// Records are per game and keyed by the path a mod carries while it is
/// switched on, relative to that game's mods folder - the same identity
/// the shop's install records and the settled clashes use, and for the
/// same reasons: a tag survives being disabled and re-enabled, and it
/// follows a mod that is moved into another folder (`_repathRecords`
/// rewrites it). Renaming or reinstalling the file loses it, which is
/// honest, since that is a different file.
///
/// Matching folds case and outside whitespace so the same word typed
/// again weeks later lands on the chip that already exists, while what
/// is drawn is always the spelling its writer used.

/// The most a tag may carry. Long enough for a phrase, short enough that
/// a chip stays a chip: this is drawn on a row that already holds the
/// file types and every subfolder.
const maxTagLength = 24;

/// The most tags one mod may hold. A card with thirty labels on it is a
/// card nobody can read, and the filter row is the place to look things
/// up rather than the mod itself.
const maxTagsPerMod = 12;

/// [raw] as it will be stored, or null when it isn't a usable tag.
/// Outside whitespace goes, runs of whitespace inside become one space,
/// and anything a text field should never have accepted (control
/// characters, which arrive by paste) is dropped rather than stored.
String? sanitizeTag(String raw) {
  final cleaned = raw
      .replaceAll(RegExp(r'[\x00-\x1f\x7f]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (cleaned.isEmpty) return null;
  return cleaned.cutToRunes(maxTagLength);
}

/// What two spellings of the same tag agree on. Case-folded, so "Spooky"
/// finds the mods tagged "spooky"; [sanitizeTag] has already settled the
/// whitespace.
String tagKey(String tag) => tag.toLowerCase();

/// Tags in the order they are offered: alphabetical, and ignoring case
/// so "Alpha" and "beta" sit where a reader expects rather than in code
/// point order.
List<String> sortTags(Iterable<String> tags) {
  final sorted = tags.toList()
    ..sort((a, b) {
      final folded = a.toLowerCase().compareTo(b.toLowerCase());
      return folded != 0 ? folded : a.compareTo(b);
    });
  return sorted;
}

/// The stored tags by game id, then by mod path. A record that doesn't
/// parse costs only itself: the worst it can do is lose one mod's
/// labels, which is why nothing here throws on bad input.
Map<String, Map<String, Set<String>>> parseModTags(String? source) {
  if (source == null || source.isEmpty) return {};
  try {
    final json = jsonDecode(source);
    if (json is! Map) return {};
    final tags = <String, Map<String, Set<String>>>{};
    for (final game in json.entries) {
      final gameId = game.key;
      final mods = game.value;
      if (gameId is! String || mods is! Map) continue;
      final kept = <String, Set<String>>{};
      for (final mod in mods.entries) {
        final path = mod.key;
        final labels = mod.value;
        if (path is! String || path.isEmpty || labels is! List) continue;
        final onMod = <String>[];
        for (final label in labels) {
          if (label is! String) continue;
          final tag = sanitizeTag(label);
          if (tag == null) continue;
          if (onMod.any((held) => tagKey(held) == tagKey(tag))) continue;
          onMod.add(tag);
          if (onMod.length >= maxTagsPerMod) break;
        }
        if (onMod.isNotEmpty) kept[path] = onMod.toSet();
      }
      if (kept.isNotEmpty) tags[gameId] = kept;
    }
    return tags;
  } catch (_) {
    return {};
  }
}

String encodeModTags(Map<String, Map<String, Set<String>>> tags) => jsonEncode({
      for (final game in tags.entries)
        if (game.value.isNotEmpty)
          game.key: {
            for (final mod in game.value.entries)
              if (mod.value.isNotEmpty) mod.key: sortTags(mod.value),
          },
    });

/// Every tag across [perMod] - one entry per mod in the library - with
/// how many mods carry it, folded so two spellings of one tag count as
/// one. The spelling reported is the one that sorts first among those in
/// use, so the chip a user sees doesn't change with the order the
/// records happen to be in.
///
/// Taken from the mods on screen rather than from the records, because
/// a record outlives the file it names: uninstalling by hand and
/// reinstalling gets a mod its labels back, and in between there must be
/// no chip standing for a mod nobody has.
Map<String, int> countTags(Iterable<Iterable<String>> perMod) {
  final byKey = <String, ({List<String> spellings, int count})>{};
  for (final held in perMod) {
    for (final tag in held) {
      final key = tagKey(tag);
      final held = byKey[key];
      byKey[key] = held == null
          ? (spellings: [tag], count: 1)
          : (spellings: [...held.spellings, tag], count: held.count + 1);
    }
  }
  final counts = <String, int>{};
  for (final key in sortTags(byKey.keys)) {
    final held = byKey[key]!;
    counts[sortTags(held.spellings).first] = held.count;
  }
  return counts;
}

extension on String {
  /// Cut to [limit] code points rather than code units: an emoji or an
  /// accented letter is more than one unit, and a tag ending in half of
  /// one is a tag that draws as a box.
  String cutToRunes(int limit) {
    if (length <= limit) return this;
    final points = runes.toList();
    if (points.length <= limit) return this;
    return String.fromCharCodes(points.take(limit)).trimRight();
  }
}
