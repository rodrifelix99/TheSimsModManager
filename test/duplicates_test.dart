import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/duplicates.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';

class _Adapter extends FolderBasedGameAdapter {
  _Adapter(this.dir);

  final Directory dir;

  /// The real one reads files in isolates; nothing here is testing the
  /// artwork scan, and the duplicate scan reads its own bytes.
  @override
  Future<Map<String, PackageInsight>> inspectMods(
    List<Mod> mods, {
    void Function(int done, int total)? onProgress,
    void Function(Map<String, PackageInsight> found)? onFound,
    bool Function()? isCancelled,
  }) async =>
      const {};

  @override
  Game get game =>
      const Game(id: 'fake', name: 'Fake Game', series: 'Test', year: 2024);

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  String get setupHelpKey => 'test adapter';

  @override
  Future<String?> defaultModsPath() async => dir.path;
}

Mod _mod(
  String path, {
  int? size = 100,
  ModStatus status = ModStatus.enabled,
  DateTime? modified,
}) =>
    Mod(
      name: p.basename(path),
      path: path,
      status: status,
      sizeBytes: size,
      modifiedAt: modified,
    );

void main() {
  group('the size pass', () {
    test('offers only the mods that share a size with another', () {
      final candidates = duplicateCandidates([
        _mod('/mods/a.package', size: 10),
        _mod('/mods/b.package', size: 10),
        _mod('/mods/c.package', size: 20),
      ]);
      expect(candidates.map((m) => m.name), unorderedEquals(['a.package', 'b.package']));
    });

    test('leaves out empty files and mods whose size never got read', () {
      final candidates = duplicateCandidates([
        _mod('/mods/a.package', size: 0),
        _mod('/mods/b.package', size: 0),
        _mod('/mods/c.package', size: null),
        _mod('/mods/d.package', size: null),
      ]);
      expect(candidates, isEmpty);
    });
  });

  group('grouping', () {
    test('groups by digest, never by name', () {
      final same1 = _mod('/mods/hair.package');
      final same2 = _mod('/mods/cc/other-name.package');
      final alone = _mod('/mods/hair.package', size: 100);
      final sets = duplicateSetsOf([same1, same2, alone], (mod) {
        if (identical(mod, alone)) return 'zzz';
        return 'aaa';
      });
      expect(sets, hasLength(1));
      expect(sets.single.mods, hasLength(2));
      expect(sets.single.digest, 'aaa');
    });

    test('a mod that was never hashed is in no set', () {
      final sets = duplicateSetsOf(
        [_mod('/mods/a.package'), _mod('/mods/b.package')],
        (_) => null,
      );
      expect(sets, isEmpty);
    });

    test('reports what deleting the extras would give back', () {
      final sets = duplicateSetsOf([
        _mod('/mods/a.package', size: 500),
        _mod('/mods/b.package', size: 500),
        _mod('/mods/c.package', size: 500),
      ], (_) => 'same');
      expect(sets.single.wastedBytes, 1000);
    });

    test('the biggest saving leads', () {
      final mods = [
        _mod('/mods/small-1.package', size: 10),
        _mod('/mods/small-2.package', size: 10),
        _mod('/mods/big-1.package', size: 900),
        _mod('/mods/big-2.package', size: 900),
      ];
      final sets = duplicateSetsOf(
          mods, (mod) => mod.name.startsWith('big') ? 'big' : 'small');
      expect(sets.first.digest, 'big');
    });
  });

  group('which copy is suggested', () {
    test('an enabled copy over a disabled one', () {
      final off = _mod('/mods/a.package.disabled', status: ModStatus.disabled);
      final on = _mod('/mods/deep/down/b.package');
      final sets = duplicateSetsOf([off, on], (_) => 'same');
      expect(sets.single.mods.first.path, on.path);
    });

    test('the copy nearest the top of the mods folder', () {
      final deep = _mod('/mods/cc/defaults/a.package');
      final shallow = _mod('/mods/b.package');
      final sets = duplicateSetsOf([deep, shallow], (_) => 'same');
      expect(sets.single.mods.first.path, shallow.path);
    });

    test('the older copy, then the path, so the order never depends on '
        'the run', () {
      final older = _mod('/mods/b.package', modified: DateTime(2024));
      final newer = _mod('/mods/a.package', modified: DateTime(2026));
      expect(duplicateSetsOf([newer, older], (_) => 'same').single.mods.first.path,
          older.path);

      final one = _mod('/mods/b.package', modified: DateTime(2024));
      final two = _mod('/mods/a.package', modified: DateTime(2024));
      expect(duplicateSetsOf([one, two], (_) => 'same').single.mods.first.path,
          two.path);
    });
  });

  group('hashing real files', () {
    late Directory root;

    setUp(() => root = Directory.systemTemp.createTempSync('smm_dupes_'));
    tearDown(() => root.deleteSync(recursive: true));

    Mod write(String name, List<int> bytes) {
      final file = File(p.join(root.path, name));
      file.parent.createSync(recursive: true);
      file.writeAsBytesSync(bytes);
      return _mod(file.path, size: bytes.length);
    }

    test('same bytes under different names hash the same, different bytes '
        'do not', () async {
      final a = write('hair.package', [1, 2, 3, 4]);
      final b = write('cc/copy of hair.package', [1, 2, 3, 4]);
      final c = write('other.package', [1, 2, 3, 5]);

      final digests = await hashModFiles([a, b, c]);

      expect(digests[a.path], isNotNull);
      expect(digests[a.path], digests[b.path]);
      expect(digests[a.path], isNot(digests[c.path]));
      // The whole point of the pass: the sets fall out of the digests.
      final sets = duplicateSetsOf([a, b, c], (mod) => digests[mod.path]);
      expect(sets.single.mods.map((m) => m.path),
          unorderedEquals([a.path, b.path]));
    });

    test('a file bigger than one read chunk hashes whole', () async {
      final size = (1 << 20) + 1234;
      final bytes = List<int>.generate(size, (i) => i % 251);
      final a = write('big-a.package', bytes);
      final b = write('big-b.package', bytes);
      final c = write('big-c.package', [...bytes.sublist(0, size - 1), 255]);

      final digests = await hashModFiles([a, b, c]);

      expect(digests[a.path], digests[b.path]);
      // Differs in the last byte only, which is what a truncated read or a
      // first-chunk shortcut would miss.
      expect(digests[a.path], isNot(digests[c.path]));
    });

    test('digests match the known SHA-256 of the bytes', () async {
      final mod = write('empty-ish.package', 'abc'.codeUnits);
      final digests = await hashModFiles([mod]);
      expect(digests[mod.path],
          'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad');
    });

    test('a file that cannot be read is left out rather than reported',
        () async {
      final gone = _mod(p.join(root.path, 'never-existed.package'));
      final real = write('real.package', [9, 9, 9]);
      final digests = await hashModFiles([gone, real]);
      expect(digests.containsKey(gone.path), isFalse);
      expect(digests[real.path], isNotNull);
    });

    test('reports progress and stops between batches when cancelled',
        () async {
      final mods = [
        for (var i = 0; i < 40; i++) write('m$i.package', [i, i, i]),
      ];
      final steps = <int>[];
      var cancel = false;
      final digests = await hashModFiles(
        mods,
        onProgress: (done, total) {
          steps.add(done);
          expect(total, mods.length);
          cancel = true;
        },
        isCancelled: () => cancel,
      );
      expect(steps, isNotEmpty);
      // Whatever the first batches did is kept; the rest never ran.
      expect(digests.length, lessThan(mods.length));
    });

    test('an empty library reads nothing', () async {
      expect(await hashModFiles(const []), isEmpty);
    });
  });

  group('the library', () {
    late Directory modsDir;

    setUp(() =>
        modsDir = Directory.systemTemp.createTempSync('mod_manager_dupes'));
    tearDown(() => modsDir.deleteSync(recursive: true));

    void writeMod(String relative, String bytes) {
      final file = File(p.join(modsDir.path, p.joinAll(relative.split('/'))));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync(bytes);
    }

    Future<AppController> makeController() async {
      SharedPreferences.setMockInitialValues({'soundEffects': false});
      final controller = AppController(
        registry: GameRegistry([_Adapter(modsDir)]),
        settings: await SettingsStore.load(),
        checkUpdates: () async => null,
      );
      await controller.refresh();
      return controller;
    }

    test('nobody has looked until the scan is run', () async {
      writeMod('hair.package', 'same');
      writeMod('cc/hair-copy.package', 'same');
      final c = await makeController();

      expect(c.duplicatesScanned, isFalse);
      expect(c.duplicateSets, isEmpty);
      expect(c.duplicateCount, 0);

      await c.scanForDuplicates();

      expect(c.duplicatesScanned, isTrue);
      expect(c.duplicateSets, hasLength(1));
      expect(c.duplicateCount, 2);
      expect(c.duplicateWastedBytes, 4);
    });

    test('a library with nothing duplicated says so rather than nothing',
        () async {
      writeMod('hair.package', 'one');
      writeMod('eyes.package', 'another');
      final c = await makeController();

      await c.scanForDuplicates();

      expect(c.duplicatesScanned, isTrue);
      expect(c.duplicateSets, isEmpty);
      c.dismissDuplicateResult();
      expect(c.duplicatesScanned, isFalse);
    });

    test('same size, different bytes is not a duplicate', () async {
      writeMod('a.package', 'abcd');
      writeMod('b.package', 'abce');
      final c = await makeController();

      await c.scanForDuplicates();

      expect(c.duplicateSets, isEmpty);
    });

    test('the filter narrows the library to the copies and back', () async {
      writeMod('hair.package', 'same');
      writeMod('cc/hair-copy.package', 'same');
      writeMod('eyes.package', 'unique');
      final c = await makeController();
      await c.scanForDuplicates();

      c.showOnlyDuplicates();
      expect(c.duplicatesOnly, isTrue);
      expect(c.filteredMods.map((m) => m.name),
          unorderedEquals(['hair.package', 'hair-copy.package']));

      c.showOnlyDuplicates();
      expect(c.duplicatesOnly, isFalse);
      expect(c.filteredMods, hasLength(3));
    });

    test('ticking the extras spares one copy of each set', () async {
      writeMod('hair.package', 'same');
      writeMod('cc/hair-copy.package', 'same');
      writeMod('cc/hair-copy-2.package', 'same');
      writeMod('eyes.package', 'other');
      writeMod('cc/eyes-copy.package', 'other');
      final c = await makeController();
      await c.scanForDuplicates();

      c.selectDuplicateExtras();

      // Three of the five files, so one of each pair-or-more survives.
      expect(c.selectedCount, 3);
      for (final set in c.duplicateSets) {
        expect(set.mods.where((m) => c.isSelected(m)).length,
            set.mods.length - 1);
        // The one spared is the copy at the top of the mods folder.
        expect(c.isSelected(set.mods.first), isFalse);
      }
    });

    test('deleting the extras leaves the survivor un-flagged, with no '
        'second scan', () async {
      writeMod('hair.package', 'same');
      writeMod('cc/hair-copy.package', 'same');
      final c = await makeController();
      await c.scanForDuplicates();
      c.selectDuplicateExtras();

      await c.removeSelected();

      expect(c.mods.map((m) => m.name), ['hair.package']);
      // The regroup runs off the digests already in hand: one copy left
      // is not a duplicate of anything, and the banner and the filter
      // have to stop saying it is without anyone rescanning.
      expect(c.duplicateSets, isEmpty);
      expect(c.duplicateCount, 0);
      expect(c.duplicatesOnly, isFalse);
    });

    test('a mod knows which files it is a copy of', () async {
      writeMod('hair.package', 'same');
      writeMod('cc/hair-copy.package', 'same');
      writeMod('eyes.package', 'alone');
      final c = await makeController();
      await c.scanForDuplicates();

      final hair = c.mods.firstWhere((m) => m.name == 'hair.package');
      final eyes = c.mods.firstWhere((m) => m.name == 'eyes.package');
      expect(c.isDuplicate(hair), isTrue);
      expect(c.duplicatesOf(hair).single.name, 'hair-copy.package');
      expect(c.isDuplicate(eyes), isFalse);
      expect(c.duplicatesOf(eyes), isEmpty);
    });

    test('a disabled copy is still a copy', () async {
      writeMod('hair.package', 'same');
      writeMod('cc/hair-copy.package.disabled', 'same');
      final c = await makeController();

      await c.scanForDuplicates();

      expect(c.duplicateCount, 2);
      // The one that is switched on is the one spared by default.
      expect(c.duplicateSets.single.mods.first.isEnabled, isTrue);
    });
  });
}
