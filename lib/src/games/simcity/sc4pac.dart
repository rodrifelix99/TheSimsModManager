/// Reading what sc4pac owns, so this app never claims it.
///
/// sc4pac (memo33/sc4pac-tools) is the established package manager for
/// SimCity 4 and it installs *into the same Plugins folder* this app
/// lists. It keeps an exact manifest of what it put there, so the
/// question "is this file mine to delete?" has a real answer and does
/// not have to be guessed from a folder name.
///
/// Two things it does that a manager reading the folder alone gets
/// badly wrong:
///
/// - A package is unpacked into `<category>/<group>.<name>.<version>.sc4pac`,
///   a folder whose name carries a version. Left to itself the library
///   would show a folder chip per package and offer a Delete that
///   breaks sc4pac's own lock file.
/// - A DLL plugin is **symlinked to the top of the Plugins folder**,
///   because SimCity 4 loads DLLs from there and nowhere else. Both the
///   link and its target are files with a mod extension, so the sweep
///   sees one plugin twice - and the duplicate scan, which hashes
///   bytes, then reports them as byte-identical copies with a delete
///   button next to them. On the reference machine that is exactly two
///   DLLs shown as four.
///
/// So the records are read and the paths they name are held out of the
/// library, with a count surfaced instead. Nothing here writes.
///
/// Verified against sc4pac 0.x on the reference machine: profiles at
/// `%APPDATA%\io.github.memo33\sc4pac\config\profiles\`, one folder per
/// profile holding `sc4pac-plugins.json` (which names `config.pluginsRoot`)
/// and `sc4pac-plugins-lock.json` (whose `installed[].files[]` are paths
/// relative to that root). Older builds kept both files in the Plugins
/// folder itself, which is what its README still documents, so both
/// locations are read.
library;

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

/// What one sc4pac profile manages: where its Plugins folder is, and
/// every path inside it that sc4pac put there.
class Sc4pacProfile {
  const Sc4pacProfile({required this.pluginsRoot, required this.ownedPaths});

  /// Absolute path of the Plugins folder this profile installs into.
  final String pluginsRoot;

  /// Paths relative to [pluginsRoot], separator-normalised to `/` and
  /// lowercased, of every file and folder sc4pac claims. A folder here
  /// owns everything below it.
  final Set<String> ownedPaths;

  bool get isEmpty => ownedPaths.isEmpty;
}

/// The suffix every sc4pac package folder carries. A folder wearing it
/// is sc4pac's even when the lock file could not be read - the last
/// line of defence, so a profile this app failed to parse still does
/// not end with the user deleting half a package.
const sc4pacFolderSuffix = '.sc4pac';

/// The config folders sc4pac keeps its profiles in, newest layout
/// first. Windows uses `%APPDATA%`; the JVM's own convention on the
/// other two is what sc4pac follows.
List<String> sc4pacConfigRoots({Map<String, String>? environment}) {
  final env = environment ?? Platform.environment;
  final roots = <String>[];
  void add(String? base, List<String> rest) {
    if (base == null || base.isEmpty) return;
    roots.add(p.joinAll([base, ...rest]));
  }

  add(env['APPDATA'], ['io.github.memo33', 'sc4pac', 'config']);
  add(env['XDG_CONFIG_HOME'], ['io.github.memo33', 'sc4pac']);
  final home = env['HOME'] ?? env['USERPROFILE'];
  add(home, ['.config', 'io.github.memo33', 'sc4pac']);
  add(home, [
    'Library',
    'Application Support',
    'io.github.memo33',
    'sc4pac',
    'config',
  ]);
  return roots;
}

/// Every sc4pac profile this machine has. Best-effort throughout: a
/// missing folder, a half-written JSON file or a profile pointing at a
/// Plugins folder that has since moved each costs itself and nothing
/// else. Never throws.
Future<List<Sc4pacProfile>> readSc4pacProfiles(
    {Map<String, String>? environment}) async {
  final profiles = <Sc4pacProfile>[];
  for (final root in sc4pacConfigRoots(environment: environment)) {
    final dir = Directory(p.join(root, 'profiles'));
    List<FileSystemEntity> entries;
    try {
      if (!await dir.exists()) continue;
      entries = await dir.list(followLinks: false).toList();
    } catch (_) {
      continue;
    }
    for (final entry in entries) {
      if (entry is! Directory) continue;
      final profile = await readSc4pacProfileAt(entry);
      if (profile != null) profiles.add(profile);
    }
  }
  return profiles;
}

/// One profile read out of [dir], which holds the two JSON files.
/// `null` when it has no usable plugins root.
Future<Sc4pacProfile?> readSc4pacProfileAt(Directory dir) async {
  final config = await _readJsonMap(File(p.join(dir.path, 'sc4pac-plugins.json')));
  final root = _pluginsRootOf(config);
  if (root == null) return null;
  final lock = await _readJsonMap(File(p.join(dir.path, 'sc4pac-plugins-lock.json')));
  return Sc4pacProfile(pluginsRoot: root, ownedPaths: ownedPathsIn(lock));
}

/// The profile whose two JSON files sit in the Plugins folder itself,
/// which is what sc4pac's README documents and what its older builds
/// wrote. [pluginsRoot] is that folder.
Future<Sc4pacProfile?> readSc4pacProfileBeside(Directory pluginsRoot) async {
  final lockFile = File(p.join(pluginsRoot.path, 'sc4pac-plugins-lock.json'));
  try {
    if (!await lockFile.exists()) return null;
  } catch (_) {
    return null;
  }
  final lock = await _readJsonMap(lockFile);
  return Sc4pacProfile(
      pluginsRoot: pluginsRoot.path, ownedPaths: ownedPathsIn(lock));
}

/// The paths a lock file claims, from `installed[].files[]`. Pure, so
/// the shape is pinned by a test rather than by a machine that happens
/// to have sc4pac on it.
Set<String> ownedPathsIn(Map<String, Object?>? lock) {
  final owned = <String>{};
  final installed = lock?['installed'];
  if (installed is! List) return owned;
  for (final entry in installed) {
    if (entry is! Map) continue;
    final files = entry['files'];
    if (files is! List) continue;
    for (final file in files) {
      if (file is! String) continue;
      final key = normalizeOwnedPath(file);
      if (key.isNotEmpty) owned.add(key);
    }
  }
  return owned;
}

/// One record's path in the form the lookup compares: forward slashes,
/// lowercase, no leading or trailing separator. Case is folded because
/// the lock file is written by a JVM on a case-insensitive filesystem
/// and the case it records is not always the case on disk.
String normalizeOwnedPath(String path) {
  var value = path.replaceAll('\\', '/').trim();
  while (value.startsWith('/')) {
    value = value.substring(1);
  }
  while (value.endsWith('/')) {
    value = value.substring(0, value.length - 1);
  }
  return value.toLowerCase();
}

/// Whether [relative] - a path below the Plugins root, in any
/// separator - is one sc4pac owns, either because it is named outright
/// or because it sits inside a folder that is.
bool ownsPath(Sc4pacProfile profile, String relative) {
  final key = normalizeOwnedPath(relative);
  if (key.isEmpty) return false;
  if (profile.ownedPaths.contains(key)) return true;
  for (final owned in profile.ownedPaths) {
    if (key.length > owned.length && key.startsWith('$owned/')) return true;
  }
  return false;
}

/// Whether any segment of [relative] is an sc4pac package folder. The
/// fallback for a Plugins folder whose lock file could not be read at
/// all: the suffix is sc4pac's own and nothing else writes it, so a
/// path carrying it is not this app's to touch.
bool looksSc4pacManaged(String relative) {
  for (final segment in relative.replaceAll('\\', '/').split('/')) {
    if (segment.toLowerCase().endsWith(sc4pacFolderSuffix)) return true;
  }
  return false;
}

String? _pluginsRootOf(Map<String, Object?>? config) {
  final section = config?['config'];
  if (section is! Map) return null;
  final root = section['pluginsRoot'];
  if (root is! String || root.trim().isEmpty) return null;
  return root.trim();
}

Future<Map<String, Object?>?> _readJsonMap(File file) async {
  try {
    if (!await file.exists()) return null;
    // A lock file for a large profile is still tens of kilobytes; the
    // cap is there because this is read off the user's disk.
    if (await file.length() > 8 << 20) return null;
    final decoded = jsonDecode(await file.readAsString());
    return decoded is Map<String, Object?> ? decoded : null;
  } catch (_) {
    return null;
  }
}
