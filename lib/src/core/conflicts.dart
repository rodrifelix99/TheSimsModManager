import 'package:path/path.dart' as p;

import 'mod.dart';
import 'mod_name.dart';

/// Paths of enabled mods that look like they clash with another enabled
/// mod, on two heuristics:
///
/// 1. **Duplicate file names** (case-insensitive) — the same mod
///    installed twice in different subfolders, or two creators' packages
///    sharing a name. The game then loads overlapping resources in an
///    unpredictable order.
/// 2. **Multiple versions of the same mod** — names identical except for
///    their version token ([parseModName]), e.g. `hair_v1.package` next
///    to `hair_v2.package`. Both versions require a recognizable version
///    marker; a versioned file next to an unversioned one is too
///    ambiguous to flag.
///
/// Cheap and lexical (no package resource parsing), so it's a warning,
/// not a verdict.
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
