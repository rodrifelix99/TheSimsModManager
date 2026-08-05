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

/// Every folder [cfg] tells the game to read mods from, relative to the
/// cfg's own folder, in the order the lines appear and without repeats.
/// `''` is that folder itself, which is what The Sims 4's bare
/// `PackedFile *.package` means.
///
/// The point of asking is that the mods folder is not always the only
/// one. A stock Sims 3 framework names `Packages` and `Overrides` in the
/// same file, and until this was read the app listed the first and was
/// blind to the second - mods installed, enabled, loaded by the game and
/// in no library the user could see.
///
/// Both kinds of line count. `PackedFile Overrides/*.package` names the
/// folder in front of its wildcards; `DirectoryFiles Overrides autoupdate`
/// names one outright, with the mode after it and sometimes a trailing
/// `...` for "and below". A path is taken only as far as its first
/// wildcard, since that is where the folder stops and the pattern begins.
///
/// Anything absolute, or climbing out with `..`, is refused outright.
/// This is a file on the player's disk that other people's tools write,
/// and a line in it must never be able to point the sweep at the rest of
/// the machine.
List<String> modFolderRoots(String cfg) {
  final roots = <String>[];
  for (final line in const LineSplitter().convert(cfg)) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final space = trimmed.indexOf(RegExp(r'\s'));
    if (space < 0) continue;
    final keyword = trimmed.substring(0, space).toLowerCase();
    final rest = trimmed.substring(space + 1).trim();
    if (rest.isEmpty) continue;
    final String value;
    final List<String> segments;
    switch (keyword) {
      case 'packedfile':
        value = _unquoted(rest);
        final all = value.replaceAll('\\', '/').split('/');
        // The last segment is the file, never a folder.
        segments = all.sublist(0, all.length - 1);
      case 'directoryfiles':
        value = _firstValue(rest);
        segments = value.replaceAll('\\', '/').split('/');
      default:
        continue;
    }
    final literal = <String>[];
    var refused = false;
    for (final segment in segments) {
      if (segment.isEmpty || segment == '.') continue;
      // '...' is the engine's "and everything below", so the folder in
      // front of it is the answer; a wildcard ends the path the same way.
      if (segment == '...' || segment.contains('*')) break;
      if (segment == '..' || segment.contains(':')) {
        refused = true;
        break;
      }
      literal.add(segment);
    }
    if (refused) continue;
    // A leading separator made the first segment empty and was skipped
    // above, so an absolute path would arrive here looking relative.
    if (value.startsWith('/') || value.startsWith(r'\')) continue;
    final root = literal.join('/');
    if (!roots.contains(root)) roots.add(root);
  }
  return roots;
}

/// A value with one matched pair of surrounding quotes taken off.
///
/// Quoting is what a person reaches for when a path has a space in it,
/// and these files are written by hand and by other people's tools. A
/// quote left on the front of a folder name is not a folder that fails
/// to be found - on Windows it is a name the OS refuses to address at
/// all, and `Directory.exists()` throws instead of answering false.
/// That is how one such line ended a launch rather than a lookup.
String _unquoted(String value) {
  if (value.length < 2) return value;
  final quote = value[0];
  if ((quote == '"' || quote == "'") && value.endsWith(quote)) {
    return value.substring(1, value.length - 1);
  }
  return value;
}

/// The first value of a line that carries more after it - the folder of
/// a `DirectoryFiles`, with its mode following. A quoted value is taken
/// whole, so a folder with a space in its name survives the split.
String _firstValue(String rest) {
  final quote = rest[0];
  if (quote == '"' || quote == "'") {
    final close = rest.indexOf(quote, 1);
    if (close > 0) return rest.substring(1, close);
  }
  return rest.split(RegExp(r'\s')).first;
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
    final glob = _unquoted(trimmed.substring(space + 1).trim());
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
