import 'package:path/path.dart' as p;

import 'mod.dart';
import 'mod_name.dart';
import 'package_insight.dart';

/// Why the conflict scan flagged a mod. The detail panel words its
/// warning from this, so what the user reads is always the reason the
/// scan actually had - it used to re-derive the reason lexically and
/// could drift out of step with the heuristics below.
///
/// Declared most specific first: a clash both a lexical heuristic and the
/// resource scan caught is reported as the lexical one, and [mostSpecificConflict]
/// is that rule.
enum ConflictReason {
  /// Another enabled mod is byte-for-byte the same file
  /// (`core/duplicates.dart`). The sharpest reason there is, and the only
  /// one that is a fact rather than a resemblance, so it outranks the
  /// three below: the same download saved twice reads as a name clash or
  /// a resource overlap to every one of them, and "these two files are
  /// identical" is both the truer sentence and the one with an obvious
  /// answer next to it.
  exactDuplicate,

  /// Another enabled mod carries the same file name.
  duplicateName,

  /// Another enabled mod looks like a different version of this one.
  versionPair,

  /// Another enabled package holds the same resource keys
  /// ([findResourceOverlaps]).
  resourceOverlap,
}

/// The sharpest of [reasons] - see [ConflictReason]'s declaration order.
ConflictReason mostSpecificConflict(Iterable<ConflictReason> reasons) =>
    reasons.reduce((a, b) => a.index <= b.index ? a : b);

/// Which enabled mods clash with which, and why: path -> (the other mod's
/// path -> the reason those two are paired).
///
/// Pairs rather than a flat list of flagged mods, because a clash is
/// always between two files and the user can settle one of them without
/// settling the rest (`core/ignored_conflicts.dart`). What a mod is
/// flagged *for* then follows from the pairs it has left, which is what
/// [conflictReasonsOf] derives.
///
/// Three signals feed it. Two are lexical, cheap and computed here:
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
/// The third is [overlaps], the real signal: packages that carry the same
/// resource keys, read off the DBPF index by [findResourceOverlaps]. Pass
/// `const {}` for the lexical pass alone (which is what the library falls
/// back to with the package scan switched off).
///
/// [digestOf] is the fourth and sharpest, and the only optional one: the
/// whole-file hashes the duplicate scan collected, answering null for
/// every mod it never read. Two enabled mods sharing a digest are the
/// same file, which is a fact rather than a resemblance - so they are
/// paired first, before any budget can be spent on the weaker signals
/// that were about to describe the same two files less well.
///
/// Lexical pairs are recorded next and against their own budget of
/// [_maxPartnersPerMod]; the overlaps then fill up to twice that. Sharing
/// one budget meant a mod with 32 same-named siblings lost the package
/// that really overrides its resources, which is the sharper signal of
/// the two and the one the scan went to the trouble of reading.
Map<String, Map<String, ConflictReason>> findConflictPairs(
  List<Mod> mods,
  Map<String, Map<String, int>> overlaps, {
  String? Function(Mod mod)? digestOf,
}) {
  final enabled = mods.where((m) => m.isEnabled).toList();
  final pairs = <String, Map<String, ConflictReason>>{};

  void pair(String path, String other, ConflictReason reason, int budget) {
    if (path == other) return;
    final row = pairs.putIfAbsent(path, () => {});
    final had = row[other];
    if (had == null && row.length >= budget) return;
    row[other] = had == null ? reason : mostSpecificConflict([had, reason]);
  }

  // Only the first few members of a group can ever be recorded as anyone's
  // partner, so the walk is bounded by the cap rather than by the size of
  // the group: one basename across a whole CC dump is a group of
  // thousands, and squaring it on every rescan froze the window on each
  // toggle.
  void pairAll(List<Mod> group, ConflictReason reason) {
    final partners = group.length > _maxPartnersPerMod + 1
        ? group.sublist(0, _maxPartnersPerMod + 1)
        : group;
    for (final mod in group) {
      for (final other in partners) {
        pair(mod.path, other.path, reason, _maxPartnersPerMod);
      }
    }
  }

  final byName = <String, List<Mod>>{};
  final byIdentity = <String, List<Mod>>{};
  final infoOf = {for (final mod in enabled) mod.path: parseModName(mod.name)};
  for (final mod in enabled) {
    byName.putIfAbsent(p.basename(mod.name).toLowerCase(), () => []).add(mod);
    byIdentity.putIfAbsent(infoOf[mod.path]!.identity, () => []).add(mod);
  }

  if (digestOf != null) {
    final byDigest = <String, List<Mod>>{};
    for (final mod in enabled) {
      final digest = digestOf(mod);
      if (digest != null) byDigest.putIfAbsent(digest, () => []).add(mod);
    }
    for (final group in byDigest.values) {
      if (group.length > 1) pairAll(group, ConflictReason.exactDuplicate);
    }
  }
  for (final group in byName.values) {
    if (group.length > 1) pairAll(group, ConflictReason.duplicateName);
  }
  for (final group in byIdentity.values) {
    if (group.length < 2) continue;
    final versions = {
      for (final mod in group)
        if (infoOf[mod.path]!.version != null) infoOf[mod.path]!.version,
    };
    if (versions.length > 1) pairAll(group, ConflictReason.versionPair);
  }
  for (final entry in overlaps.entries) {
    if (!infoOf.containsKey(entry.key)) continue;
    for (final other in entry.value.keys) {
      if (infoOf.containsKey(other)) {
        pair(entry.key, other, ConflictReason.resourceOverlap,
            _maxPartnersPerMod * 2);
      }
    }
  }
  return pairs;
}

/// What each flagged mod is flagged for, from the pairs it has: the
/// sharpest reason among them.
Map<String, ConflictReason> conflictReasonsOf(
        Map<String, Map<String, ConflictReason>> pairs) =>
    {
      for (final entry in pairs.entries)
        if (entry.value.isNotEmpty)
          entry.key: mostSpecificConflict(entry.value.values),
    };

/// DBPF resource types excluded from overlap detection: bookkeeping the
/// editor or the launcher writes into a package, never content the game
/// looks up, so two packages carrying the same one override nothing a
/// player could notice.
///
/// The name map is why unrelated Sims 3 mods kept being reported as
/// clashing. It is the editor's own list of instance -> name pairs, and
/// both s3pe and Twallan's NRaasPacker add it at the fixed key
/// `0166038c-00000000-0000000000000000` - literally `TGIBlock(_KEY, 0, 0)`
/// in each of them - whenever a resource in the package is given a name.
/// Naming the script resource is step one of the pure-scripting tutorial,
/// so every script mod has one: every NRaas mod, and every hand-built
/// package next to them, shared that single key and flagged each other.
/// The Sims 3 merging tools drop both types for the same reason.
const _ignoredOverlapTypes = <int>{
  0xE86B1EEF, // Sims 2 DIR: the directory every compressed package carries.
  0x0166038C, // _KEY / NMAP: the editor's resource-name map.
  0x73E93EEB, // The launcher's package manifest.
};

/// A resource key held by more enabled packages than this is treated as
/// boilerplate rather than a clash - a fixed id some creator tool stamps
/// into everything it exports, the kind [_ignoredOverlapTypes] lists by
/// hand. Two reasons to drop them: "these 900 mods override each other"
/// is not a warning anyone can act on, and every such key costs a pair
/// per combination of its owners, so one popular key in a large library
/// is enough to grow the overlap map beyond what the machine has. Real
/// duplicates still surface - the same file installed twice is caught by
/// name in [findConflictPairs].
const _maxOwnersPerKey = 16;

/// Most partners recorded for one mod, per signal: the overlap map allows
/// this many, and [findConflictPairs] allows this many lexical ones and
/// twice this many in total. The detail panel lists them for the user to
/// review, which stops being useful long before this many, and the cap is
/// what keeps both maps' size linear in the size of the library. Rows
/// that fill up simply stop growing, so a mod can be listed as another's
/// partner without the reverse holding - which is why what a mod has been
/// told to ignore is answered from the records rather than from its row.
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
