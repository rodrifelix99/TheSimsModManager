import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// Longest path Windows accepts through its regular API, terminator
/// included. Tools that address files through the `\\?\` form (the
/// external unpackers that handle rar and 7z here) create longer ones
/// happily, and then nothing that doesn't use that form - Explorer, the
/// game's loader, this app - can open them again.
const windowsPathLimit = 259;

/// PATH_MAX is 1024 on macOS and 4096 on Linux; the tighter of the two
/// keeps one rule for both.
const posixPathLimit = 1023;

/// Longest single file or folder name, in bytes, on every platform the
/// app runs on.
const maxComponentBytes = 255;

/// Characters no Windows file name may contain. `\` and `/` are absent
/// on purpose: components are split on them before this is applied.
final _windowsIllegal = RegExp(r'[<>:"|?*\x00-\x1f]');

/// Names Windows reserves for devices at every level of a path, with or
/// without an extension: `CON.package` is as unusable as `CON`.
const _windowsReserved = {
  'con', 'prn', 'aux', 'nul', //
  'com1', 'com2', 'com3', 'com4', 'com5', 'com6', 'com7', 'com8', 'com9',
  'lpt1', 'lpt2', 'lpt3', 'lpt4', 'lpt5', 'lpt6', 'lpt7', 'lpt8', 'lpt9',
};

/// Stands in for a name made of nothing the platform accepts.
const _fallbackStem = 'mod';

/// One path component the host filesystem can actually store: illegal
/// characters replaced, trailing dots and spaces dropped (Windows
/// writes them through `\\?\` but normalises them away everywhere else,
/// so the path it just created is one it can no longer find), reserved
/// device names escaped, and the result trimmed to [maxComponentBytes].
/// The extension survives every step - without it a mod file stops being
/// one.
String sanitizeComponent(String name, {required bool windows}) {
  var clean = name;
  if (windows) {
    clean = clean
        .replaceAll(_windowsIllegal, '_')
        .replaceFirst(RegExp(r'[. ]+$'), '');
    if (_windowsReserved.contains(p.withoutExtension(clean).toLowerCase())) {
      clean = '_$clean';
    }
  } else {
    clean = clean.replaceAll('\u0000', '_');
  }
  return _trim(clean.trim(), bytes: maxComponentBytes);
}

/// Where a file whose path relative to its source root is [relative]
/// should land under [destination].
///
/// Archives and dropped folders regularly carry names and nesting the
/// host filesystem can't reproduce. Rather than let the copy fail (or,
/// worse, succeed into a path nothing can read back), the path is made
/// to fit: every component is sanitized, then, while the result is over
/// the platform's limit, the intermediate folders are dropped
/// deepest-first - the top one, which the library shows as a filter
/// chip, goes last - and only then is the file name itself trimmed. The
/// file always lands somewhere under [destination].
String installTargetPath(String destination, String relative,
    {bool? windows}) {
  final onWindows = windows ?? Platform.isWindows;
  final context = onWindows ? p.windows : p.posix;
  final limit = onWindows ? windowsPathLimit : posixPathLimit;

  final components = context.split(relative);
  final depth = components.isEmpty ? 0 : components.length - 1;
  final folders = <String>[];
  for (final raw in components.take(depth)) {
    final folder = sanitizeComponent(raw, windows: onWindows);
    if (folder.isNotEmpty && folder != '.' && folder != '..') {
      folders.add(folder);
    }
  }
  final raw = components.isEmpty ? '' : components.last;
  var name = sanitizeComponent(raw, windows: onWindows);
  // A name whose stem sanitized away ("   .package") would land as a
  // dotfile, which no longer reads as a mod file for the game or for
  // this app - give it a stem back.
  if (name.isEmpty ||
      name == '.' ||
      name == '..' ||
      p.extension(name) != p.extension(raw)) {
    name = '$_fallbackStem${p.extension(raw)}';
  }

  var target = context.joinAll([destination, ...folders, name]);
  while (target.length > limit && folders.isNotEmpty) {
    folders.removeLast();
    target = context.joinAll([destination, ...folders, name]);
  }
  if (target.length > limit) {
    name = _trim(name, chars: name.length - (target.length - limit));
    target = context.join(destination, name);
  }
  return target;
}

/// [path], or the first `name-2`, `name-3`... variant of it that isn't
/// already in [taken]. Used where two files could otherwise collapse
/// onto one path and silently overwrite each other; the variants stay
/// within the platform's path limit.
String _unusedVariantOf(String path, Set<String> taken, {bool? windows}) {
  final onWindows = windows ?? Platform.isWindows;
  if (!taken.contains(_key(path, onWindows))) return path;
  final context = onWindows ? p.windows : p.posix;
  final limit = onWindows ? windowsPathLimit : posixPathLimit;
  final directory = context.dirname(path);
  final name = context.basename(path);
  final extension = p.extension(name);
  final stem = name.substring(0, name.length - extension.length);
  for (var n = 2;; n++) {
    final suffix = '-$n$extension';
    final room = limit - context.join(directory, suffix).length;
    final trimmed = _trim(stem, chars: room, bytes: maxComponentBytes);
    final candidate = context.join(directory, '$trimmed$suffix');
    if (!taken.contains(_key(candidate, onWindows))) return candidate;
  }
}

/// Resolves [relative] under [destination] with [installTargetPath],
/// avoids any path already handed out in [taken], and records the result
/// there. One call per file installed.
String claimInstallTarget(
    String destination, String relative, Set<String> taken,
    {bool? windows}) {
  final onWindows = windows ?? Platform.isWindows;
  final context = onWindows ? p.windows : p.posix;
  final target = installTargetPath(destination, relative, windows: onWindows);
  // Only a path the platform's rules forced us to change can collide
  // with another file from the same install; an untouched one repeats
  // the source layout, where overwriting is what the user asked for.
  final claimed = target == context.join(destination, relative)
      ? target
      : _unusedVariantOf(target, taken, windows: onWindows);
  taken.add(_key(claimed, onWindows));
  return claimed;
}

/// The `\\?\` form of [path], which lifts [windowsPathLimit] and turns
/// off the name normalisation that otherwise hides files whose names end
/// in a dot or a space. Only meaningful for absolute Windows paths;
/// anything else comes back untouched, so callers still have to guard on
/// the platform.
String windowsExtendedPath(String path) {
  const prefix = r'\\?\';
  if (path.startsWith(prefix)) return path;
  final full = path.replaceAll('/', r'\');
  // A UNC share becomes `\\?\UNC\server\share`.
  if (full.startsWith(r'\\')) return '${prefix}UNC\\${full.substring(2)}';
  // The prefix only takes a fully qualified path, drive letter and all.
  if (!_windowsDrivePath.hasMatch(full)) return path;
  return '$prefix$full';
}

final _windowsDrivePath = RegExp(r'^[A-Za-z]:\\');

/// Case-insensitive on Windows, where two spellings name one file.
String _key(String path, bool windows) => windows ? path.toLowerCase() : path;

/// [name] cut down to [chars] characters and [bytes] UTF-8 bytes (the
/// unit filesystems count names in, which stops matching characters as
/// soon as a mod is named in Cyrillic), keeping the extension so the
/// game still recognises the file.
String _trim(String name, {int? chars, int? bytes}) {
  final extension = p.extension(name);
  var stem = name.substring(0, name.length - extension.length);
  if (chars != null) {
    final room = chars - extension.length;
    if (room <= 0) return name.length <= chars ? name : extension;
    if (stem.length > room) stem = stem.substring(0, room);
  }
  if (bytes != null) {
    final room = bytes - utf8.encode(extension).length;
    if (room <= 0) return name;
    while (utf8.encode(stem).length > room) {
      stem = stem.substring(0, stem.length - 1);
    }
  }
  return '$stem$extension';
}
