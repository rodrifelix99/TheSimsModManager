import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/game_pack.dart';

/// The Sims 1's expansions, which can be listed and nothing more.
///
/// Every expansion this game ever had installed itself *into* the base
/// game: the objects went into `GameData\Objects`, the skins into
/// `GameData\Skins`, and the 2025 Legacy Collection ships the lot already
/// merged. There is no folder to hide and no key to move, so there is
/// nothing here that could turn one off - and the community's answer to
/// wanting a smaller game has always been to install from the discs again
/// rather than to unpick a merged one.
///
/// What the game does keep is a flag file per expansion in `GameData`,
/// named `Ranger.iff` through `Ranger7.iff`, which is how it knows which
/// content to switch on. Reading those is enough to say what is
/// installed, which is what this screen is for.

/// `Ranger.iff` is the first expansion and carries no number; the rest
/// count up from two.
final _rangerFile = RegExp(r'^Ranger(\d?)\.iff$', caseSensitive: false);

/// Expansion number -> name, in release order.
///
/// `Ranger8.iff` and `RangerD.iff` are deliberately absent: they mark the
/// Complete Collection and the Deluxe edition, which are ways of buying
/// the game rather than expansions of it.
const sims1PackNames = <int, String>{
  1: 'Livin’ Large',
  2: 'House Party',
  3: 'Hot Date',
  4: 'Vacation',
  5: 'Unleashed',
  6: 'Superstar',
  7: 'Makin’ Magic',
};

/// The same seven under the codes the rest of the app speaks, so a mod
/// on The Exchange can name one the way it names a Sims 4 pack.
final sims1PackCatalog = <String, String>{
  for (final entry in sims1PackNames.entries)
    'EP${entry.key.toString().padLeft(2, '0')}': entry.value,
};

/// The expansion a `Ranger*.iff` stands for, or null when the file is one
/// of the edition markers or not a flag file at all.
int? sims1PackNumberFromFile(String fileName) {
  final match = _rangerFile.firstMatch(fileName.trim());
  if (match == null) return null;
  final digits = match.group(1)!;
  final number = digits.isEmpty ? 1 : int.parse(digits);
  return sims1PackNames.containsKey(number) ? number : null;
}

/// Every expansion installed into [installRoot], in release order.
///
/// All of them read as enabled, because for this game that is simply
/// what being installed means.
Future<List<GamePack>> listSims1Packs(Directory installRoot) async {
  final gameData = Directory(p.join(installRoot.path, 'GameData'));
  if (!await gameData.exists()) return const [];
  final found = <int>{};
  try {
    await for (final entity in gameData.list().handleError((Object _) {})) {
      if (entity is! File) continue;
      final number = sims1PackNumberFromFile(p.basename(entity.path));
      if (number != null) found.add(number);
    }
  } catch (_) {
    return const [];
  }
  final numbers = found.toList()..sort();
  return [
    for (final number in numbers)
      GamePack(
        code: 'EP${number.toString().padLeft(2, '0')}',
        name: sims1PackNames[number]!,
        kind: GamePackKind.expansion,
      ),
  ];
}
