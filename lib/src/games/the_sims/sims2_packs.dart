import 'dart:io';

import 'package:win32_registry/win32_registry.dart';

import '../../core/app_message.dart';
import '../../core/game_pack.dart';

/// The Sims 2 Legacy Collection's packs, and - experimentally - a way to
/// leave one out.
///
/// The 2025 re-release keeps every pack in one folder and records them in
/// **HKEY_CURRENT_USER**, not the machine-wide hive the older releases
/// used, so nothing here needs administrator rights. The root holds an
/// `EPsInstalled` string listing the packs in the order the game loads
/// them, and a subkey per pack named after the executable that pack used
/// to ship (`Sims2EP1.exe`), carrying where it lives and whether it counts.
///
/// **Why this is experimental.** Disabling is done by taking the pack out
/// of that load order, which is the same lever AnyGameStarter has pulled
/// since 2007 and is how people have run subsets of The Sims 2 for years -
/// but nobody has published doing it to the Legacy Collection, and a
/// Sims 2 neighborhood that was played with a pack and then opened
/// without it is the series' most reliable way to corrupt a save. So the
/// switches are off unless the user turns them on, and the screen says
/// what the risk is rather than burying it.
///
/// Two packs can never be left out: the base game, and whichever pack
/// owns the executable the collection actually runs (Mansion & Garden,
/// `Sims2EP9.exe`). Taking either out of the list would be asking the
/// game to launch itself without itself.

/// Where the Legacy Collection registers itself. Named for the collection
/// rather than the game, which is what the installer writes.
const sims2RegistryRoot =
    r'Software\Electronic Arts\The Sims 2 Ultimate Collection 25';

/// The app's own note of the load order as it stood before anything was
/// switched off, so putting a pack back puts it back *where it was*: the
/// order is the order the game layers the packs in, not a set.
const sims2BackupValue = 'SmmOriginalEPsInstalled';

const _epsInstalledValue = 'EPsInstalled';

/// The executable a pack used to ship, which is what its subkey is named
/// after and what the load order lists. `Sims2EP1.exe` -> `EP01`.
final _packExe = RegExp(r'^Sims2(EP|SP)(\d{1,2})\.exe$', caseSensitive: false);

/// The pack whose executable the collection runs. It is listed like any
/// other and is the one entry that must never leave the list.
const sims2RunnerExe = 'Sims2EP9.exe';

/// `Sims2EP1.exe` -> `EP01`; null for the base game and anything else.
String? sims2CodeFromExe(String exeName) {
  final match = _packExe.firstMatch(exeName.trim());
  if (match == null) return null;
  final number = int.tryParse(match.group(2)!);
  if (number == null || number == 0) return null;
  return '${match.group(1)!.toUpperCase()}'
      '${number.toString().padLeft(2, '0')}';
}

/// Mansion & Garden ships as the ninth expansion slot rather than a stuff
/// pack, because it is the pack the collection's executable belongs to.
GamePackKind sims2PackKind(String code) =>
    code.toUpperCase().startsWith('EP') ? GamePackKind.expansion : GamePackKind.stuff;

/// The nine expansions and the stuff packs, in EA's own spelling.
///
/// SP3 (Happy Holiday Stuff) is deliberately absent: it never shipped
/// digitally, and its slot in the load order is the empty entry between
/// the two commas that every copy of this collection carries.
const sims2PackNames = <String, String>{
  'EP01': 'University',
  'EP02': 'Nightlife',
  'EP03': 'Open for Business',
  'EP04': 'Pets',
  'EP05': 'Seasons',
  'EP06': 'Bon Voyage',
  'EP07': 'FreeTime',
  'EP08': 'Apartment Life',
  'EP09': 'Mansion & Garden Stuff',
  'SP01': 'Family Fun Stuff',
  'SP02': 'Glamour Life Stuff',
  'SP04': 'Celebration! Stuff',
  'SP05': 'H&M Fashion Stuff',
  'SP06': 'Teen Style Stuff',
  'SP07': 'Kitchen & Bath Interior Design Stuff',
  'SP08': 'IKEA Home Stuff',
};

/// One pack as the collection's registry describes it.
class Sims2PackKey {
  const Sims2PackKey({
    required this.exe,
    required this.code,
    this.path,
    this.isListed = true,
  });

  /// The subkey's name, `Sims2EP1.exe`.
  final String exe;

  final String code;

  /// Where the pack's files are.
  final String? path;

  /// Whether the load order currently mentions it, which is what decides
  /// if the game reads the pack at all.
  final bool isListed;
}

/// Splits a load order into its entries, keeping the empty slot the
/// missing stuff pack leaves behind - it is part of the shape the game
/// wrote and putting it back differently is not this app's business.
List<String> parseSims2LoadOrder(String value) => value.split(',');

/// The load order with [disabled] taken out, and everything else exactly
/// where it was.
///
/// [original] is the order as it stood before anything was switched off,
/// so this is always computed from the full list rather than from an
/// already-shortened one - which is what keeps re-enabling a pack put it
/// back in its own place instead of at the end. Entries in [current] that
/// [original] has never heard of are appended: a pack installed while
/// another was switched off must not vanish.
String buildSims2LoadOrder(
  String original,
  String current,
  Set<String> disabled,
) {
  final off = {for (final exe in disabled) exe.toLowerCase()};
  final known = <String>{};
  final out = <String>[];
  for (final entry in parseSims2LoadOrder(original)) {
    known.add(entry.toLowerCase());
    if (entry.isNotEmpty && off.contains(entry.toLowerCase())) continue;
    out.add(entry);
  }
  for (final entry in parseSims2LoadOrder(current)) {
    if (entry.isEmpty || known.contains(entry.toLowerCase())) continue;
    if (off.contains(entry.toLowerCase())) continue;
    out.add(entry);
  }
  return out.join(',');
}

/// The load order exactly as the collection wrote it, or empty when there
/// is none to read. The order is what the game layers packs in, so its
/// last entry is the pack whose executable actually runs.
String readSims2LoadOrder({String registryRoot = sims2RegistryRoot}) {
  if (!Platform.isWindows) return '';
  try {
    final root = CURRENT_USER.open(registryRoot);
    try {
      return root.getString(_epsInstalledValue) ?? '';
    } finally {
      root.close();
    }
  } catch (_) {
    return '';
  }
}

/// Every pack this copy of the collection has, whether or not the game is
/// currently loading it.
///
/// The subkeys are the inventory - they stay put whatever the load order
/// says - and the load order is what decides [Sims2PackKey.isListed].
/// [registryRoot] is a parameter rather than always the collection's own
/// key so the whole path can be exercised against a key of the app's
/// making, instead of a test having to write into somebody's game.
List<Sims2PackKey> readSims2PackKeys({
  String registryRoot = sims2RegistryRoot,
}) {
  if (!Platform.isWindows) return const [];
  RegistryKey root;
  try {
    root = CURRENT_USER.open(registryRoot);
  } catch (_) {
    return const [];
  }
  try {
    final listed = {
      for (final entry in parseSims2LoadOrder(
          root.getString(_epsInstalledValue) ?? ''))
        if (entry.isNotEmpty) entry.toLowerCase(),
    };
    final found = <Sims2PackKey>[];
    for (final name in root.keys) {
      final code = sims2CodeFromExe(name);
      // `Sims2.exe` is the base game and `1.0` holds the language; neither
      // is a pack.
      if (code == null) continue;
      String? path;
      try {
        final key = root.open(name);
        try {
          path = key.getString('Path');
        } finally {
          key.close();
        }
      } catch (_) {
        // An unreadable subkey still tells us the pack is there.
      }
      found.add(Sims2PackKey(
        exe: name,
        code: code,
        path: path,
        isListed: listed.contains(name.toLowerCase()),
      ));
    }
    return found;
  } catch (_) {
    return const [];
  } finally {
    root.close();
  }
}

Future<List<GamePack>> listSims2Packs() async {
  final packs = <GamePack>[];
  for (final key in readSims2PackKeys()) {
    final dir = key.path == null ? null : Directory(key.path!);
    packs.add(GamePack(
      code: key.code,
      name: sims2PackNames[key.code] ?? key.code,
      kind: sims2PackKind(key.code),
      isEnabled: key.isListed,
      // The pack whose executable the collection runs cannot be left out
      // of the load order, so it is drawn as a fact rather than offered.
      canToggle: key.exe.toLowerCase() != sims2RunnerExe.toLowerCase(),
      path: key.path,
      sizeBytes: dir == null ? null : _folderSize(dir),
    ));
  }
  packs.sort((a, b) {
    final tier = a.kind.index.compareTo(b.kind.index);
    return tier != 0 ? tier : a.code.compareTo(b.code);
  });
  return packs;
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

/// Adds a pack back to the game's load order, or takes it out.
///
/// The pack's own subkey is left exactly as it is - its files never move
/// and the collection still knows where they are - so this is reversible
/// by putting the entry back, which is what the remembered original order
/// is for.
void setSims2PackEnabled(
  String code, {
  required bool enabled,
  String registryRoot = sims2RegistryRoot,
}) {
  if (!Platform.isWindows) {
    throw const PackActionException(AppMessage('errorPackNotSupported'));
  }
  final keys = readSims2PackKeys(registryRoot: registryRoot);
  final target = keys.where((k) => k.code == code.toUpperCase()).firstOrNull;
  if (target == null || target.isListed == enabled) return;
  if (!enabled && target.exe.toLowerCase() == sims2RunnerExe.toLowerCase()) {
    // This is the pack whose executable runs the whole collection.
    throw const PackActionException(AppMessage('errorPackIsTheGame'));
  }
  try {
    final root = CURRENT_USER.open(registryRoot,
        config: const RegistryOpenConfig(access: RegistryAccess.readWrite));
    try {
      final current = root.getString(_epsInstalledValue) ?? '';
      // Snapshotted the first time anything is switched off, and cleared
      // once everything is back on, so it never goes stale for long.
      final original = root.getString(sims2BackupValue) ?? current;
      final disabled = <String>{
        for (final key in keys)
          if (!key.isListed) key.exe,
      };
      if (enabled) {
        disabled.removeWhere(
            (exe) => exe.toLowerCase() == target.exe.toLowerCase());
      } else {
        disabled.add(target.exe);
      }
      root.setValue(_epsInstalledValue,
          RegistryValue.string(buildSims2LoadOrder(original, current, disabled)));
      if (disabled.isEmpty) {
        try {
          root.removeValue(sims2BackupValue);
        } catch (_) {
          // Never written, which is the usual case.
        }
      } else {
        root.setValue(sims2BackupValue, RegistryValue.string(original));
      }
    } finally {
      root.close();
    }
  } on PackActionException {
    rethrow;
  } catch (_) {
    throw const PackActionException(AppMessage('errorPackToggleRefused'));
  }
}
