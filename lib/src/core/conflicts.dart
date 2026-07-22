import 'package:path/path.dart' as p;

import 'mod.dart';

/// Paths of enabled mods whose file name appears more than once in the
/// library (case-insensitive).
///
/// Duplicate file names are the most common real-world mod conflict: the
/// same mod installed twice in different subfolders, or two creators'
/// packages sharing a name. The game then loads overlapping resources in
/// an unpredictable order. This is a cheap heuristic (it doesn't parse
/// package resource tables), so it's a warning, not a verdict.
Set<String> findConflicts(List<Mod> mods) {
  final byName = <String, List<Mod>>{};
  for (final mod in mods.where((m) => m.isEnabled)) {
    byName.putIfAbsent(p.basename(mod.name).toLowerCase(), () => []).add(mod);
  }
  return {
    for (final group in byName.values)
      if (group.length > 1)
        for (final mod in group) mod.path,
  };
}
