import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:win32_registry/win32_registry.dart';

import '../../core/app_message.dart';
import '../../core/bitmap.dart';
import '../../core/dbpf.dart' show imageArea;
import '../../core/game_pack.dart';

/// The Sims 3's packs: which are installed, and which the game will load.
///
/// Unlike The Sims 4, where a pack is a folder the game notices, The Sims 3
/// asks the registry. Each pack writes a key of its own naming where it
/// lives, and the launcher enumerates those keys - a pack folder with no
/// key is invisible to the game however complete it is, which is exactly
/// what makes a pack switchable without moving a single file.
///
/// So disabling means taking the pack's key out of the game's sight, and
/// enabling means putting it back. What is moved is copied to the app's
/// own key first, and everything in it can be rebuilt from the pack folder
/// anyway, so a lost backup is recoverable rather than fatal.
///
/// **The `ergc` sibling key is deliberately never touched.** The community
/// tools move it too, but it holds the pack's CD key - the one value here
/// that could not be reconstructed if the backup were ever lost, and the
/// launcher does not read it when deciding what is installed. Leaving it
/// where it is costs nothing and takes the only irreversible step off the
/// table. (It is also where expansion-editor has a real bug: it pairs the
/// two trees by enumeration order, and they disagree - one spells a pack
/// "High End Loft Stuff" and the other "High-End Loft Stuff" - so it can
/// move the wrong pack's CD key.)
///
/// The obvious cheaper alternative, emptying the key's `Install Dir`
/// rather than moving the key, is **not** what this does. It leaves the
/// key in place pointing at nothing, and a pack the game believes in but
/// cannot find is the documented way to get launch errors rather than a
/// game that quietly runs without it. A missing key is the state the
/// launcher is built to handle.
///
/// Windows only. The Mac keeps its add-ons as aliases inside the app
/// bundle and has no registry at all, so nothing here runs there.

/// Where the games register themselves. Retail and Steam installs use
/// different parents and both can be present on one machine; the 32-bit
/// view is where they land, since the games are 32-bit.
const sims3RegistryRoots = [
  r'SOFTWARE\Wow6432Node\Sims',
  r'SOFTWARE\Wow6432Node\Sims(Steam)',
  r'SOFTWARE\Sims',
  r'SOFTWARE\Sims(Steam)',
];

/// The app's own corner of the registry, holding the keys it has taken out
/// of the game's sight. Under `SOFTWARE` rather than beside the game's own
/// keys on purpose: the launcher enumerates whatever sits under `Sims`, so
/// a backup parked there would be read as a pack.
const sims3BackupRoot = r'SOFTWARE\The Sims Mod Manager\Sims3DisabledPacks';

/// A pack's executable, which is what names it: `TS3EP01.exe`. Every pack
/// ships one beside its own `Game\Bin`, on disc and on Steam alike, and
/// the base game's is plain `TS3.exe` - so this also tells the two apart
/// without knowing any product ids.
final _packExe = RegExp(r'^TS3(EP|SP)(\d{2})\.exe$', caseSensitive: false);

/// A pack's folder inside a Steam-shaped install: `EP1`, `SP07`. Written
/// unpadded by Steam and padded by nothing, so both are accepted.
final _packFolder = RegExp(r'^(EP|SP)(\d{1,2})$', caseSensitive: false);

/// The pack's icon, sitting inside the little Games Explorer definition
/// DLL beside its executable.
final _gdfDll = RegExp(r'^Sims3(EP|SP)\d{2}GDF\.dll$', caseSensitive: false);

/// `TS3EP01.exe` -> `EP01`. Null for the base game and anything else.
///
/// Read with Windows' path rules rather than the host's: what arrives
/// here is a value out of the Windows registry, so it is a Windows path
/// whatever machine is looking at it. On a Mac the host rules see no
/// separator in `C:\...\TS3EP01.exe` at all and the whole string arrives
/// at the regex as the file name, which matches nothing.
String? sims3CodeFromExePath(String? exePath) {
  if (exePath == null || exePath.trim().isEmpty) return null;
  final match = _packExe.firstMatch(p.windows.basename(exePath.trim()));
  if (match == null) return null;
  return '${match.group(1)!.toUpperCase()}${match.group(2)}';
}

/// `EP1` -> `EP01`, so a folder and a registry key describe one pack.
String? sims3CodeFromFolder(String name) {
  final match = _packFolder.firstMatch(name.trim());
  if (match == null) return null;
  final number = int.tryParse(match.group(2)!);
  if (number == null || number == 0) return null;
  return '${match.group(1)!.toUpperCase()}'
      '${number.toString().padLeft(2, '0')}';
}

GamePackKind sims3PackKind(String code) =>
    code.toUpperCase().startsWith('EP')
        ? GamePackKind.expansion
        : GamePackKind.stuff;

/// The eleven expansions and nine stuff packs, in EA's own spelling.
///
/// Needed even though the registry carries a `DisplayName`: that value is
/// the full product name ("The Sims 3 World Adventures"), and a shelf of
/// those reads as the game's name twenty times over. It is also the only
/// source at all when a pack is found by its folder because the registry
/// could not be read.
const sims3PackNames = <String, String>{
  'EP01': 'World Adventures',
  'EP02': 'Ambitions',
  'EP03': 'Late Night',
  'EP04': 'Generations',
  'EP05': 'Pets',
  'EP06': 'Showtime',
  'EP07': 'Supernatural',
  'EP08': 'Seasons',
  'EP09': 'University Life',
  'EP10': 'Island Paradise',
  'EP11': 'Into the Future',
  'SP01': 'High-End Loft Stuff',
  'SP02': 'Fast Lane Stuff',
  'SP03': 'Outdoor Living Stuff',
  'SP04': 'Town Life Stuff',
  'SP05': 'Master Suite Stuff',
  'SP06': "Katy Perry's Sweet Treats",
  'SP07': 'Diesel Stuff',
  'SP08': '70s, 80s & 90s Stuff',
  'SP09': 'Movie Stuff',
};

/// The game's own name for a pack, with its own title taken off the
/// front - "The Sims 3 Ambitions" is a shelf full of "The Sims 3".
final _gameTitlePrefix = RegExp(r'^The\s+Sims\s*™?\s*3\s*™?\s*[:\-–]?\s*');

String stripSims3GameTitle(String title) {
  final stripped = title.replaceFirst(_gameTitlePrefix, '').trim();
  return stripped.isEmpty ? title.trim() : stripped;
}

/// The value the app writes into a key it has parked, remembering which
/// root it came out of. Named so it cannot collide with the game's own
/// values, and read back rather than guessed at, so a pack put away by an
/// older build still goes home to the right place.
const _originValue = 'SmmOriginRoot';

/// One pack as the registry describes it.
class Sims3PackKey {
  const Sims3PackKey({
    required this.root,
    required this.name,
    required this.code,
    this.originRoot,
    this.displayName,
    this.installDir,
  });

  /// The registry path the key is under right now - one of
  /// [sims3RegistryRoots] for a pack the game can see, and
  /// [sims3BackupRoot] for one the app has parked.
  final String root;

  /// The key's own name, `The Sims 3 Ambitions`.
  final String name;

  final String code;

  /// Where the key belongs when the game is meant to see it, as the app
  /// wrote it down when it parked the key. Null for a pack the game can
  /// already see, and for a parked key whose note never got written -
  /// which must not be read as "it belongs in the backup root", or
  /// putting it back would mean moving it onto itself.
  final String? originRoot;

  final String? displayName;
  final String? installDir;

  String get path => '$root\\$name';
}

/// Every pack the registry currently shows the game, plus every pack the
/// app has taken out of its sight, as (code -> key).
///
/// Reading both is what lets a disabled pack still be listed: once its key
/// is gone the game cannot see it, and neither could this app if it did
/// not keep its own note.
({Map<String, Sims3PackKey> enabled, Map<String, Sims3PackKey> disabled})
    readSims3PackKeys() {
  if (!Platform.isWindows) return (enabled: const {}, disabled: const {});
  return (
    enabled: _readKeysUnder(sims3RegistryRoots),
    disabled: _readKeysUnder(const [sims3BackupRoot]),
  );
}

Map<String, Sims3PackKey> _readKeysUnder(List<String> roots) {
  final found = <String, Sims3PackKey>{};
  for (final root in roots) {
    RegistryKey parent;
    try {
      parent = LOCAL_MACHINE.open(root);
    } catch (_) {
      // Not every root exists, and a locked-down machine may refuse one.
      continue;
    }
    try {
      for (final name in parent.keys) {
        try {
          final key = parent.open(name);
          try {
            final code = sims3CodeFromExePath(key.getString('ExePath'));
            // No pack executable means the base game, or something else
            // that registered itself under the same parent.
            if (code == null) continue;
            found.putIfAbsent(
                code,
                () => Sims3PackKey(
                      root: root,
                      name: name,
                      code: code,
                      originRoot: key.getString(_originValue),
                      displayName: key.getString('DisplayName'),
                      installDir: key.getString('Install Dir'),
                    ));
          } finally {
            key.close();
          }
        } catch (_) {
          // One unreadable key costs that pack, not the whole list.
        }
      }
    } catch (_) {
      // An unreadable root is one we have nothing to say about.
    } finally {
      parent.close();
    }
  }
  return found;
}

/// Where the base game is installed, as the game itself recorded it.
///
/// The base game registers alongside the packs but names a plain `TS3.exe`
/// rather than a numbered one, which is exactly how it is told apart. Used
/// to find pack folders the registry never mentioned; null off Windows and
/// on a machine that has nothing registered.
Directory? readSims3InstallRoot() {
  if (!Platform.isWindows) return null;
  for (final root in sims3RegistryRoots) {
    RegistryKey parent;
    try {
      parent = LOCAL_MACHINE.open(root);
    } catch (_) {
      continue;
    }
    try {
      for (final name in parent.keys) {
        try {
          final key = parent.open(name);
          try {
            final exe = key.getString('ExePath');
            if (exe == null) continue;
            final file = p.basename(exe).toLowerCase();
            // The launcher-bypass builds name themselves TS3W.exe.
            if (file != 'ts3.exe' && file != 'ts3w.exe') continue;
            final dir = key.getString('Install Dir');
            if (dir != null && dir.trim().isNotEmpty) {
              return Directory(dir.trim());
            }
          } finally {
            key.close();
          }
        } catch (_) {
          // One unreadable key is not the answer to this question.
        }
      }
    } catch (_) {
      // Nothing readable under this root.
    } finally {
      parent.close();
    }
  }
  return null;
}

/// The pack's icon, or null when there is none to be had.
///
/// It lives inside `Sims3EP01GDF.dll`, the Games Explorer definition file
/// beside the pack's executable, as ordinary PNGs; the biggest of them is
/// the one worth drawing.
Uint8List? readSims3PackIcon(Directory installDir) {
  try {
    final bin = Directory(p.join(installDir.path, 'Game', 'Bin'));
    if (!bin.existsSync()) return null;
    for (final entity in bin.listSync()) {
      if (entity is! File || !_gdfDll.hasMatch(p.basename(entity.path))) {
        continue;
      }
      final bytes = entity.readAsBytesSync();
      final images = embeddedPngs(bytes);
      if (images.isEmpty) {
        // The oldest packs keep theirs as a Windows icon instead.
        return largestEmbeddedIcon(bytes);
      }
      images.sort((a, b) => imageArea(b).compareTo(imageArea(a)));
      return images.first;
    }
  } catch (_) {
    // Artwork is decoration; nothing here is worth failing a list over.
  }
  return null;
}

/// Every pack installed for this copy of the game.
///
/// [installRoot] is the base game's own folder, used to find packs whose
/// registry keys could not be read at all - a Steam install keeps them as
/// `EP1`..`SP9` beside the base game, and a library that lists nothing
/// would be a worse answer than one that cannot offer switches.
Future<List<GamePack>> listSims3Packs({Directory? installRoot}) async {
  final root = installRoot ?? readSims3InstallRoot();
  final keys = readSims3PackKeys();
  final packs = <String, GamePack>{};

  void add(String code, {Sims3PackKey? key, Directory? dir, required bool on}) {
    if (packs.containsKey(code)) return;
    final folder = dir ??
        (key?.installDir != null ? Directory(key!.installDir!) : null);
    final registryName = key?.displayName;
    packs[code] = GamePack(
      code: code,
      name: sims3PackNames[code] ??
          (registryName != null ? stripSims3GameTitle(registryName) : code),
      kind: sims3PackKind(code),
      isEnabled: on,
      path: folder?.path,
      sizeBytes: folder == null ? null : _folderSize(folder),
      icon: folder == null ? null : readSims3PackIcon(folder),
    );
  }

  for (final entry in keys.enabled.entries) {
    add(entry.key, key: entry.value, on: true);
  }
  for (final entry in keys.disabled.entries) {
    add(entry.key, key: entry.value, on: false);
  }

  // Packs the registry never mentioned. Present on disk and unknown to
  // the game, which on a Steam install usually means Steam failed to
  // write the keys - a well-known state worth showing rather than hiding.
  if (root != null && await root.exists()) {
    await for (final entity in root.list().handleError((Object _) {})) {
      if (entity is! Directory) continue;
      final code = sims3CodeFromFolder(p.basename(entity.path));
      if (code == null) continue;
      add(code, dir: entity, on: keys.enabled.containsKey(code));
    }
  }

  final sorted = packs.values.toList()
    ..sort((a, b) {
      final tier = a.kind.index.compareTo(b.kind.index);
      return tier != 0 ? tier : a.code.compareTo(b.code);
    });
  return sorted;
}

int? _folderSize(Directory dir) {
  var total = 0;
  try {
    if (!dir.existsSync()) return null;
    for (final entity in dir.listSync(recursive: true, followLinks: false)) {
      if (entity is File) {
        try {
          total += entity.lengthSync();
        } catch (_) {
          // A file the OS will not stat costs its own bytes only.
        }
      }
    }
  } catch (_) {
    return null;
  }
  return total;
}

/// Shows the game a pack again, or takes it out of sight.
///
/// Moves the whole key rather than flipping a value inside it, because
/// the launcher goes by which keys exist. Throws [PackActionException]
/// when the registry refuses the write, which on a machine that is not
/// running as administrator is what will happen: these keys live in
/// HKEY_LOCAL_MACHINE and writing there is not a thing a normal user
/// process may do.
void setSims3PackEnabled(String code, {required bool enabled}) {
  if (!Platform.isWindows) {
    throw const PackActionException(AppMessage('errorPackNotSupported'));
  }
  final keys = readSims3PackKeys();
  final from = enabled ? keys.disabled[code] : keys.enabled[code];
  // Already where it was asked to be.
  if (from == null) return;
  // Going back where it came from, which the backup key remembers, or
  // into the app's own corner where the launcher will not enumerate it.
  final to = enabled
      ? '${from.originRoot ?? sims3RegistryRoots.first}\\${from.name}'
      : '$sims3BackupRoot\\${from.name}';
  try {
    moveRegistryKey(LOCAL_MACHINE, from.path, to,
        origin: enabled ? null : from.root);
  } catch (_) {
    // These keys live in HKEY_LOCAL_MACHINE, so much the likeliest
    // reason to land here is that the app is not running as
    // administrator and Windows refused the write.
    throw const PackActionException(AppMessage('errorPackNeedsAdmin'));
  }
}

/// Copies every value of [fromPath] to [toPath] under [hive] and deletes
/// the original. The registry has no move of its own, and these keys are a
/// handful of strings, so a copy is the whole job.
///
/// [origin] is remembered alongside the values under [_originValue], so a
/// key that has been parked knows where it came from; passing null clears
/// it, which is what putting one back amounts to.
///
/// [hive] is a parameter rather than always HKEY_LOCAL_MACHINE so this can
/// be exercised for real against a key of the app's own, without asking a
/// test for administrator rights or going near anybody's game.
void moveRegistryKey(BaseRegistryKey hive, String fromPath, String toPath,
    {String? origin}) {
  // Copying a key onto itself and then deleting the original deletes the
  // key. Nothing asks for that on purpose, so refuse rather than obey.
  if (fromPath.toLowerCase() == toPath.toLowerCase()) return;
  final source = hive.open(fromPath);
  final List<({String name, RegistryValue value})> values;
  try {
    values = source.values;
  } finally {
    source.close();
  }

  final target = hive.create(toPath,
      config: const RegistryOpenConfig(
          access: RegistryAccess.readWrite, create: true));
  try {
    for (final entry in values) {
      // A key parked by an older build carries this already; it is ours
      // rather than the game's and must not travel back with it.
      if (entry.name == _originValue) continue;
      target.setValue(entry.name, entry.value);
    }
    if (origin != null) {
      target.setValue(_originValue, RegistryValue.string(origin));
    }
  } finally {
    target.close();
  }
  // Only once the copy is safely written: a failure above leaves the pack
  // exactly where it was rather than losing it between the two.
  hive.removeSubkey(fromPath);
}
