import 'package:path/path.dart' as p;

import 'mod.dart';
import 'mod_name.dart';
import 'package_insight.dart';

/// Why the conflict scan flagged a mod. The detail panel words its
/// warning from this, so what the user reads is always the reason the
/// scan actually had - it used to re-derive the reason lexically and
/// could drift out of step with the heuristics below.
enum ConflictReason {
  /// Another enabled mod carries the same file name.
  duplicateName,

  /// Another enabled mod looks like a different version of this one.
  versionPair,

  /// Another enabled package holds the same resource keys
  /// ([findResourceOverlaps]).
  resourceOverlap,
}

/// Enabled mods that look like they clash with another enabled mod, and
/// why, on two heuristics:
///
/// 1. Duplicate file names (case-insensitive) - the same mod
///    installed twice in different subfolders, or two creators' packages
///    sharing a name. The game then loads overlapping resources in an
///    unpredictable order.
/// 2. Multiple versions of the same mod - names identical except for
///    their version token ([parseModName]), e.g. `hair_v1.package` next
///    to `hair_v2.package`. Both versions require a recognizable version
///    marker; a versioned file next to an unversioned one is too
///    ambiguous to flag.
///
/// A mod both heuristics catch reports the name clash - the more
/// specific signal. Cheap and lexical (no package resource parsing), so
/// it's a warning, not a verdict. [findResourceOverlaps] is the real
/// thing: it compares the actual resource keys inside each package.
Map<String, ConflictReason> findConflicts(List<Mod> mods) {
  final enabled = mods.where((m) => m.isEnabled).toList();
  final flagged = <String, ConflictReason>{};

  final byName = <String, List<Mod>>{};
  final byIdentity = <String, List<Mod>>{};
  final infoOf = {for (final mod in enabled) mod.path: parseModName(mod.name)};
  for (final mod in enabled) {
    byName.putIfAbsent(p.basename(mod.name).toLowerCase(), () => []).add(mod);
    byIdentity.putIfAbsent(infoOf[mod.path]!.identity, () => []).add(mod);
  }

  for (final group in byIdentity.values) {
    if (group.length < 2) continue;
    final versions = {
      for (final mod in group)
        if (infoOf[mod.path]!.version != null) infoOf[mod.path]!.version,
    };
    if (versions.length > 1) {
      for (final mod in group) {
        flagged[mod.path] = ConflictReason.versionPair;
      }
    }
  }
  for (final group in byName.values) {
    if (group.length > 1) {
      for (final mod in group) {
        flagged[mod.path] = ConflictReason.duplicateName;
      }
    }
  }
  return flagged;
}

/// DBPF resource types excluded from overlap detection because they sit
/// at the same key in nearly every package, so they'd flag the whole
/// library. 0xE86B1EEF is the Sims 2 DIR resource (the directory of
/// compressed entries every compressed package carries).
const _ignoredOverlapTypes = <int>{0xE86B1EEF};

/// A resource key held by more enabled packages than this is treated as
/// boilerplate rather than a clash - a fixed id some creator tool stamps
/// into everything it exports, the kind [_ignoredOverlapTypes] lists by
/// hand. Two reasons to drop them: "these 900 mods override each other"
/// is not a warning anyone can act on, and every such key costs a pair
/// per combination of its owners, so one popular key in a large library
/// is enough to grow the overlap map beyond what the machine has. Real
/// duplicates still surface - the same file installed twice is caught by
/// name in [findConflicts].
const _maxOwnersPerKey = 16;

/// Most overlap partners recorded for one mod. The detail panel lists
/// them for the user to review, which stops being useful long before this
/// many, and the cap is what keeps the map's size linear in the size of
/// the library. Rows that fill up simply stop growing, so a mod can be
/// listed as another's partner without the reverse holding.
const _maxPartnersPerMod = 32;

/// Enabled mods whose packages carry the same resource keys, from the
/// DBPF index headers collected by the package scan: path -> (overlapping
/// mod's path -> how many keys the two share).
///
/// This is the real conflict signal - the game looks resources up by
/// Type/Group/Instance and keeps whichever copy it loads last, so two
/// enabled packages sharing a key silently override each other. It can
/// still be intentional: patch/override mods and multi-part CC sets are
/// built to shadow resources, which is why the UI presents overlaps as
/// a warning to review, not an error.
///
/// [insightOf] supplies each mod's scan result (null when the file wasn't
/// scanned or isn't a DBPF package); such mods simply can't participate.
///
/// Two passes over the keys rather than one, because a library of tens of
/// thousands of packages carries millions of resource keys and almost all
/// of them are held by exactly one file: counting first means only the
/// keys that turned out to be shared ever get an owner list built for
/// them. See [_maxOwnersPerKey] and [_maxPartnersPerMod] for the bounds
/// that keep the result proportional to the library.
Map<String, Map<String, int>> findResourceOverlaps(
  List<Mod> mods,
  PackageInsight? Function(Mod mod) insightOf,
) {
  // Pass 1: how many enabled packages carry each key (deduped per file:
  // a malformed package repeating a key must not flag itself).
  final holders = <ResourceKey, int>{};
  for (final mod in mods) {
    if (!mod.isEnabled) continue;
    final keys = insightOf(mod)?.keys;
    if (keys == null || keys.isEmpty) continue;
    final seen = <ResourceKey>{};
    for (final key in keys) {
      if (_ignoredOverlapTypes.contains(key.type)) continue;
      if (seen.add(key)) holders[key] = (holders[key] ?? 0) + 1;
    }
  }

  // Pass 2: owners of the keys that are actually shared, and not shared so
  // widely that they say nothing.
  final owners = <ResourceKey, List<String>>{};
  for (final mod in mods) {
    if (!mod.isEnabled) continue;
    final keys = insightOf(mod)?.keys;
    if (keys == null || keys.isEmpty) continue;
    final seen = <ResourceKey>{};
    for (final key in keys) {
      final count = holders[key] ?? 0;
      if (count < 2 || count > _maxOwnersPerKey) continue;
      if (seen.add(key)) owners.putIfAbsent(key, () => []).add(mod.path);
    }
  }

  final overlaps = <String, Map<String, int>>{};
  for (final paths in owners.values) {
    for (final path in paths) {
      final row = overlaps.putIfAbsent(path, () => {});
      for (final other in paths) {
        if (other == path) continue;
        final shared = row[other];
        if (shared == null && row.length >= _maxPartnersPerMod) continue;
        row[other] = (shared ?? 0) + 1;
      }
    }
  }
  return overlaps;
}
