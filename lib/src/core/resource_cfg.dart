/// Reading the config files the games keep for themselves: the
/// `Resource.cfg` that says how deep mods may be nested, and the ini
/// where The Sims 4 records whether it will load them at all.
///
/// The Sims 3 engine (so The Sims 3, The Sims Medieval, and The Sims 4
/// with its own dialect) does not walk the mods folder. It reads a
/// manifest that spells out every depth it will look at, one line per
/// level:
///
/// ```
/// PackedFile Packages/*.package
/// PackedFile Packages/*/*.package
/// PackedFile Packages/*/*/*.package
/// ```
///
/// A mod below the deepest line is never loaded, and the game says
/// nothing about it. Reading the file that is really on disk rather than
/// assuming the stock one matters: people edit these to add a level, and
/// an older framework may have fewer.
library;

import 'dart:convert' show LineSplitter;
import 'dart:io';

/// The `key = value` lines of an ini-style settings file, lowercased
/// keys, or `null` when the file isn't there or won't be read. The Sims
/// 4 keeps whether mods are allowed at all in `Options.ini`, which is
/// the difference between a library that runs and one that doesn't.
///
/// Deliberately forgiving: this is the game's file, we only read it, and
/// a line we don't understand is not our business.
Future<Map<String, String>?> readIniSettings(File file) async {
  String text;
  try {
    if (!await file.exists()) return null;
    text = await file.readAsString();
  } catch (_) {
    return null;
  }
  final settings = <String, String>{};
  for (final line in const LineSplitter().convert(text)) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#') || trimmed.startsWith(';')) {
      continue;
    }
    final equals = trimmed.indexOf('=');
    if (equals <= 0) continue;
    settings[trimmed.substring(0, equals).trim().toLowerCase()] =
        trimmed.substring(equals + 1).trim();
  }
  return settings;
}

/// How many levels of subfolders the `PackedFile` lines in [cfg] reach,
/// or `null` when there are none to go on. 0 means the mods folder
/// itself and nothing below it.
///
/// Only the `*` path segments count: the literal ones are where the
/// mods folder sits relative to the cfg (`Packages/`, `Mods/Packages/`),
/// which is a different question. `DirectoryFiles` lines name a folder
/// to read rather than a depth to walk, so they are not part of this.
int? maxPackedFileDepth(String cfg) {
  int? deepest;
  for (final line in const LineSplitter().convert(cfg)) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final space = trimmed.indexOf(RegExp(r'\s'));
    if (space < 0) continue;
    if (trimmed.substring(0, space).toLowerCase() != 'packedfile') continue;
    final glob = trimmed.substring(space + 1).trim();
    if (glob.isEmpty) continue;
    // The last segment is the file itself; the wildcards before it are
    // the folders the game will descend into.
    final segments = glob.replaceAll('\\', '/').split('/');
    var depth = 0;
    for (final segment in segments.take(segments.length - 1)) {
      if (segment == '*') depth++;
    }
    if (deepest == null || depth > deepest) deepest = depth;
  }
  return deepest;
}
