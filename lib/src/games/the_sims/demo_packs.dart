import '../../core/game_pack.dart';
import 'sims1_packs.dart';
import 'sims2_packs.dart';
import 'sims3_packs.dart';
import 'sims4_packs.dart';

/// Invented pack shelves, the packs screen's half of the demo library.
///
/// The names are the real ones - a pack is the publisher's own product and
/// there is nothing to make up about it, unlike a mod's creator - so these
/// are built from the same shipped tables the adapters fall back on when an
/// install names a pack only by its code. What is invented is the
/// collection: which packs this pretend player owns, which ones they have
/// switched off, and what each costs on disk.
///
/// Nothing here reads the registry or the disk, and the lists are built
/// once per run, so a shot retaken tomorrow shows the same shelf.

const _mb = 1024 * 1024;

/// A plausible size for a pack of this [kind], varied by [i] so a shelf
/// doesn't read as generated. [percent] scales a whole game's shelf: a
/// Sims 2 expansion is a fraction of a Sims 4 one, and a screenshot that
/// says otherwise is the kind of detail people notice.
int _size(GamePackKind kind, int i, {int percent = 100}) {
  final spread = (i * 29 % 100) + 1;
  final bytes = switch (kind) {
    GamePackKind.expansion => (1500 + spread * 24) * _mb,
    GamePackKind.gamePack => (700 + spread * 6) * _mb,
    GamePackKind.stuff => (180 + spread * 2) * _mb,
    GamePackKind.kit => (60 + spread) * _mb,
    GamePackKind.free => (40 + spread) * _mb,
  };
  return bytes * percent ~/ 100;
}

/// The Sims 4: every expansion, game pack and stuff pack, and a third of
/// the kits. Nobody owns all hundred-odd of those, and a shelf that says
/// they do is the one thing about this screen a real player would not
/// recognise.
List<GamePack> _buildSims4() {
  final packs = <GamePack>[];
  var i = 0;
  for (final entry in sims4PackNames.entries) {
    final n = i++;
    final kind = sims4PackKind(entry.key);
    if (kind == GamePackKind.kit && n % 3 != 0) continue;
    packs.add(GamePack(
      code: entry.key,
      name: entry.value,
      kind: kind,
      isEnabled: n % 9 != 4,
      sizeBytes: _size(kind, n),
    ));
  }
  return packs;
}

/// The Sims 3: the eleven expansions and the nine stuff packs, two of them
/// switched off. Its packs draw no artwork here - the real screen reads
/// each icon out of the pack's own DLL beside the game, so an invented
/// shelf has none to show and falls back to the code tiles.
List<GamePack> _buildSims3() {
  final packs = <GamePack>[];
  var i = 0;
  for (final entry in sims3PackNames.entries) {
    final n = i++;
    final kind = sims3PackKind(entry.key);
    packs.add(GamePack(
      code: entry.key,
      name: entry.value,
      kind: kind,
      isEnabled: n % 8 != 5,
      sizeBytes: _size(kind, n, percent: 65),
    ));
  }
  return packs;
}

/// The Sims 2 Legacy Collection, which ships as everything at once - so
/// unlike the other shelves this one is the whole table. Mansion & Garden
/// comes back as a fact rather than a switch, because its executable is
/// what the collection actually runs.
List<GamePack> _buildSims2() {
  final packs = <GamePack>[];
  var i = 0;
  for (final entry in sims2PackNames.entries) {
    final n = i++;
    final locked = entry.key == 'EP09';
    packs.add(GamePack(
      code: entry.key,
      name: entry.value,
      kind: sims2PackKind(entry.key),
      isEnabled: locked || n % 7 != 3,
      canToggle: !locked,
      sizeBytes: _size(sims2PackKind(entry.key), n, percent: 35),
    ));
  }
  return packs;
}

/// The Sims 1: all seven expansions, all on, no sizes. Everything about
/// that is what the real screen says too - the expansions merged into the
/// base game on install, so being listed is the whole of what the app can
/// know about one.
List<GamePack> _buildSims1() => [
      for (final entry in sims1PackNames.entries)
        GamePack(
          code: 'EP${entry.key.toString().padLeft(2, '0')}',
          name: entry.value,
          kind: GamePackKind.expansion,
        ),
    ];

final List<GamePack> demoSims4Packs = _buildSims4();
final List<GamePack> demoSims3Packs = _buildSims3();
final List<GamePack> demoSims2Packs = _buildSims2();
final List<GamePack> demoSims1Packs = _buildSims1();
