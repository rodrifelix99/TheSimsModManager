/// Finding the four SimCity installs, and telling their editions apart.
///
/// Every path here was read off a real machine (see
/// `docs/simcity-support-validation.md`); nothing is guessed from a
/// folder name. The registry is the fast answer on Windows and the
/// bounded install walk in `core/install_scan.dart` is the slow one,
/// which is also the only one a Wine or Proton prefix ever gets - the
/// games register themselves in the prefix's own hive, not in the
/// machine's.
///
/// The registry values differ per game in ways no shared shape would
/// survive: SimCity 4 keeps `Install Dir` under `Maxis`, SimCity 3000
/// Unlimited keeps `InstalledPath` under `Electronic Arts\Maxis` and
/// points at the `Apps` subfolder rather than the game root, and
/// Societies keeps `Install Dir` under `Electronic Arts` with the
/// expansion registered as a sibling key whose name carries a `(tm)`.
/// So each game states its own, and the only thing shared is the
/// reading.
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:win32_registry/win32_registry.dart';

import '../../core/install_scan.dart';

/// The franchise name every SimCity [Game] carries, and what the
/// sidebar groups them under.
const simCitySeries = 'SimCity';

/// One place a game's install root may be named, and which value in it
/// holds the path. [below] is a subfolder the value points at rather
/// than the game root - SimCity 3000 Unlimited's `InstalledPath` names
/// its `Apps` folder, so the root is one level up.
class RegistryInstallHint {
  const RegistryInstallHint(this.path, this.value, {this.below});

  final String path;
  final String value;
  final String? below;
}

/// The 32-bit and 64-bit views of one `SOFTWARE\...` path. Every one of
/// these games is a 32-bit application, so on a 64-bit Windows they land
/// under `Wow6432Node`; the plain path is kept for the 32-bit case and
/// for a machine where an installer wrote both.
List<String> _bothViews(String suffix) => [
      'SOFTWARE\\WOW6432Node\\$suffix',
      'SOFTWARE\\$suffix',
    ];

/// SimCity 4 (Deluxe and the base game). `IsDeluxe` and the `EP1`
/// subkey are what separate the editions; `Install Dir` is the game
/// root, whatever store it came from - the Steam copy on the reference
/// machine names its own steamapps folder here.
List<RegistryInstallHint> get simCity4Hints => [
      for (final path in _bothViews('Maxis\\SimCity 4'))
        RegistryInstallHint(path, 'Install Dir'),
    ];

/// SimCity 3000 Unlimited. The value names the `Apps` folder, so the
/// root is its parent - reading it as the root would put the mods
/// folder one level too deep and find nothing.
List<RegistryInstallHint> get simCity3000Hints => [
      for (final path in _bothViews('Electronic Arts\\Maxis\\SimCity 3000 Unlimited'))
        RegistryInstallHint(path, 'InstalledPath', below: 'Apps'),
      // The pre-Unlimited release registered itself without the vendor
      // level. Kept because the two editions share every mod folder.
      for (final path in _bothViews('Maxis\\SimCity 3000'))
        RegistryInstallHint(path, 'InstalledPath', below: 'Apps'),
      for (final path in _bothViews('Maxis\\SimCity 3000'))
        RegistryInstallHint(path, 'Install Dir'),
    ];

/// SimCity Societies. The expansion registers a key of its own whose
/// name carries the trademark sign, and it is installed *inside* the
/// base game's folder rather than beside it.
List<RegistryInstallHint> get simCitySocietiesHints => [
      for (final path in _bothViews('Electronic Arts\\SimCity Societies'))
        RegistryInstallHint(path, 'Install Dir'),
    ];

/// SimCity (2013). Registered under `Maxis\SimCity`, which is the same
/// vendor key SimCity 4 uses one level up - so the name is checked, not
/// the vendor.
List<RegistryInstallHint> get simCity2013Hints => [
      for (final path in _bothViews('Maxis\\SimCity'))
        RegistryInstallHint(path, 'Install Dir'),
    ];

/// The install roots [hints] name that exist on this machine, best
/// first. Empty off Windows and on a machine where none of them is
/// there; a value naming a folder that has since been deleted is
/// dropped rather than returned, because every caller goes on to look
/// inside it.
Future<List<Directory>> registryInstallDirs(
    List<RegistryInstallHint> hints) async {
  if (!Platform.isWindows) return const [];
  final found = <String, Directory>{};
  for (final hint in hints) {
    String? raw;
    try {
      final key = LOCAL_MACHINE.open(hint.path);
      try {
        raw = key.getString(hint.value);
      } finally {
        key.close();
      }
    } catch (_) {
      // Most of these keys are absent on most machines, and a
      // locked-down one may refuse a read outright.
      continue;
    }
    if (raw == null || raw.trim().isEmpty) continue;
    var path = raw.trim();
    // The installers write a trailing separator about half the time.
    while (path.length > 3 &&
        (path.endsWith('\\') || path.endsWith('/'))) {
      path = path.substring(0, path.length - 1);
    }
    if (hint.below != null &&
        p.basename(path).toLowerCase() == hint.below!.toLowerCase()) {
      path = p.dirname(path);
    }
    final key = p.canonicalize(path);
    if (found.containsKey(key)) continue;
    try {
      final dir = Directory(path);
      if (await dir.exists()) found[key] = dir;
    } catch (_) {
      // A path the OS refuses to address costs itself.
    }
  }
  return found.values.toList();
}

/// Whether every one of [names] sits directly inside [dir], case
/// insensitively. The signature check every SimCity adapter is built
/// on: a folder called "SimCity 4 Deluxe" proves nothing (a repack, a
/// hand-moved copy and a localized installer all invent their own), and
/// these files are what the game will not run without.
Future<bool> holdsAll(Directory dir, List<String> names) async {
  for (final name in names) {
    if (!await _hasEntry(dir, name)) return false;
  }
  return true;
}

/// Whether any one of [names] sits directly inside [dir]. For the
/// editions that ship different executables for the same game.
Future<bool> holdsAny(Directory dir, List<String> names) async {
  for (final name in names) {
    if (await _hasEntry(dir, name)) return true;
  }
  return false;
}

Future<bool> _hasEntry(Directory dir, String name) async {
  final path = p.joinAll([dir.path, ...p.split(name)]);
  try {
    if (await File(path).exists()) return true;
    if (await Directory(path).exists()) return true;
  } catch (_) {
    // errno 123 and friends: a name this filesystem cannot address is
    // a name the game does not have.
    return false;
  }
  // Windows is case insensitive and Linux is not; a Wine prefix or a
  // copy moved onto a case-sensitive volume keeps whatever case the
  // installer wrote. Only worth the listing when the direct hit missed.
  if (Platform.isWindows) return false;
  final segments = p.split(name);
  var here = dir;
  for (var i = 0; i < segments.length; i++) {
    final wanted = segments[i].toLowerCase();
    String? hit;
    try {
      await for (final entity in here.list(followLinks: false)) {
        if (p.basename(entity.path).toLowerCase() == wanted) {
          hit = entity.path;
          break;
        }
      }
    } catch (_) {
      return false;
    }
    if (hit == null) return false;
    if (i == segments.length - 1) return true;
    here = Directory(hit);
  }
  return false;
}

/// Install roots for a SimCity game: what the registry names first,
/// then the known launcher locations, then - only if both came up empty
/// - the bounded walk every install-folder game shares.
///
/// [signature] is what decides; a folder reached any of the three ways
/// still has to prove it is this game.
Future<List<Directory>> findSimCityInstalls({
  required String cacheKey,
  required List<RegistryInstallHint> hints,
  required InstallSignature signature,
  required List<String> folderNames,
  List<String>? scanRootsOverride,
  List<Directory>? searchOverride,
}) async {
  final found = <String, Directory>{};
  Future<void> keep(Directory dir) async {
    final key = p.canonicalize(dir.path);
    if (found.containsKey(key)) return;
    try {
      if (!await dir.exists()) return;
      if (!await signature(dir)) return;
    } catch (_) {
      return;
    }
    found[key] = dir;
  }

  if (searchOverride != null) {
    for (final dir in searchOverride) {
      await keep(dir);
    }
    return found.values.toList();
  }

  for (final dir in await registryInstallDirs(hints)) {
    await keep(dir);
  }
  for (final root in await _launcherRoots()) {
    for (final name in folderNames) {
      await keep(Directory(p.join(root, name)));
    }
  }
  if (found.isNotEmpty) return found.values.toList();
  for (final dir
      in await scanForInstalls(cacheKey, signature, rootsOverride: scanRootsOverride)) {
    await keep(dir);
  }
  return found.values.toList();
}

/// Where a launcher would have put one of these games. `EA Games` is
/// the folder the 2000s EA installers used and the one the reference
/// machine's SimCity 2013 and Societies are actually in; the rest are
/// the current stores' own layouts.
Future<List<String>> _launcherRoots() async => [
      for (final root in programFilesRoots()) ...[
        root,
        p.join(root, 'EA Games'),
        p.join(root, 'Electronic Arts'),
        p.join(root, 'Origin Games'),
        p.join(root, 'EA', 'EA Games'),
        p.join(root, 'GOG Galaxy', 'Games'),
        p.join(root, 'Maxis'),
      ],
      for (final library in await steamLibraries())
        p.join(library, 'steamapps', 'common'),
      for (final drive in await windowsDriveRoots()) ...[
        p.join(drive, 'Games'),
        p.join(drive, 'GOG Games'),
      ],
    ];
