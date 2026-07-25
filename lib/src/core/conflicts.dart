import 'package:path/path.dart' as p;

import 'mod.dart';
import 'mod_name.dart';
import 'package_insight.dart';

/// Paths of enabled mods that look like they clash with another enabled
/// mod, on two heuristics:
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
/// Cheap and lexical (no package resource parsing), so it's a warning,
/// not a verdict. [findResourceOverlaps] is the real thing: it compares
/// the actual resource keys inside each package.
Set<String> findConflicts(List<Mod> mods) {
  final enabled = mods.where((m) => m.isEnabled).toList();
  final flagged = <String>{};

  final byName = <String, List<Mod>>{};
  final byIdentity = <String, List<Mod>>{};
  final infoOf = {for (final mod in enabled) mod.path: parseModName(mod.name)};
  for (final mod in enabled) {
    byName.putIfAbsent(p.basename(mod.name).toLowerCase(), () => []).add(mod);
    byIdentity.putIfAbsent(infoOf[mod.path]!.identity, () => []).add(mod);
  }

  for (final group in byName.values) {
    if (group.length > 1) flagged.addAll(group.map((m) => m.path));
  }
  for (final group in byIdentity.values) {
    if (group.length < 2) continue;
    final versions = {
      for (final mod in group)
        if (infoOf[mod.path]!.version != null) infoOf[mod.path]!.version,
    };
    if (versions.length > 1) flagged.addAll(group.map((m) => m.path));
  }
  return flagged;
}

/// DBPF resource types excluded from overlap detection because they sit
/// at the same key in nearly every package, so they'd flag the whole
/// library. 0xE86B1EEF is the Sims 2 DIR resource (the directory of
/// compressed entries every compressed package carries).
const _ignoredOverlapTypes = <int>{0xE86B1EEF};

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
Map<String, Map<String, int>> findResourceOverlaps(
  List<Mod> mods,
  PackageInsight? Function(Mod mod) insightOf,
) {
  // Key -> paths of the enabled packages carrying it (deduped per file:
  // a malformed package repeating a key must not flag itself).
  final owners = <ResourceKey, List<String>>{};
  for (final mod in mods) {
    if (!mod.isEnabled) continue;
    final keys = insightOf(mod)?.keys;
    if (keys == null || keys.isEmpty) continue;
    final seen = <ResourceKey>{};
    for (final key in keys) {
      if (_ignoredOverlapTypes.contains(key.type)) continue;
      if (seen.add(key)) owners.putIfAbsent(key, () => []).add(mod.path);
    }
  }

  final overlaps = <String, Map<String, int>>{};
  for (final paths in owners.values) {
    if (paths.length < 2) continue;
    for (final path in paths) {
      final row = overlaps.putIfAbsent(path, () => {});
      for (final other in paths) {
        if (other == path) continue;
        row[other] = (row[other] ?? 0) + 1;
      }
    }
  }
  return overlaps;
}
