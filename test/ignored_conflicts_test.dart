import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/ignored_conflicts.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';

class _Adapter extends FolderBasedGameAdapter {
  _Adapter(this.dir, {this.id = 'fake'});

  final Directory dir;
  final String id;

  @override
  Future<Map<String, PackageInsight>> inspectMods(
    List<Mod> mods, {
    void Function(int done, int total)? onProgress,
    void Function(Map<String, PackageInsight> found)? onFound,
    bool Function()? isCancelled,
  }) async =>
      const {};

  @override
  Game get game => Game(id: id, name: 'Fake Game', series: 'Test', year: 2024);

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  String get setupHelpKey => 'test adapter';

  @override
  Future<String?> defaultModsPath() async => dir.path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('the pair records', () {
    test('a pair reads the same whichever way round it is written', () {
      expect(conflictPairKey('a.package', 'sub/b.package'),
          conflictPairKey('sub/b.package', 'a.package'));
      expect(conflictPairKey('a.package', 'b.package'),
          isNot(conflictPairKey('a.package', 'c.package')));
    });

    test('records survive a round trip, by game', () {
      final ignored = {
        'sims4': {
          conflictPairKey('a.package', r'cc\b.package'),
          conflictPairKey('c.package', 'd.package'),
        },
        'sims2': {conflictPairKey('e.package', 'f.package')},
      };

      expect(parseIgnoredConflicts(encodeIgnoredConflicts(ignored)), ignored);
    });

    test('a game with nothing left is not written down', () {
      expect(encodeIgnoredConflicts({'sims4': {}}), '{}');
    });

    test('junk costs only itself', () {
      expect(parseIgnoredConflicts(null), isEmpty);
      expect(parseIgnoredConflicts('not json'), isEmpty);
      expect(parseIgnoredConflicts('[]'), isEmpty);
      expect(
        parseIgnoredConflicts(
            '{"sims4": [["a.package"], ["b.package", "c.package"], 7]}'),
        {
          'sims4': {conflictPairKey('b.package', 'c.package')},
        },
      );
    });
  });

  group('ignoring a clash', () {
    late Directory modsDir;

    setUp(() {
      modsDir = Directory.systemTemp.createTempSync('mod_manager_ignored');
    });

    tearDown(() => modsDir.deleteSync(recursive: true));

    void writeMod(String relative) {
      final file = File(p.join(modsDir.path, p.joinAll(relative.split('/'))));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('bytes');
    }

    Future<AppController> makeController(
        [Map<String, Object> prefs = const {}]) async {
      SharedPreferences.setMockInitialValues({'soundEffects': false, ...prefs});
      final controller = AppController(
        registry: GameRegistry([_Adapter(modsDir)]),
        settings: await SettingsStore.load(),
        checkUpdates: () async => null,
      );
      await controller.refresh();
      return controller;
    }

    // By the name the mod carries while it is on, so a test can reach for
    // the same mod after switching it off.
    Mod modNamed(AppController c, String relative) => c.mods.firstWhere((m) =>
        p.relative(enabledPathOf(m.path), from: modsDir.path) ==
        p.joinAll(relative.split('/')));

    test('the pair goes quiet on both mods, and the count with it', () async {
      writeMod('hair.package');
      writeMod('sub/hair.package');
      final c = await makeController();
      expect(c.conflictCount, 2);

      final a = modNamed(c, 'hair.package');
      final b = modNamed(c, 'sub/hair.package');
      await c.ignoreConflict(a, b);

      expect(c.conflictCount, 0);
      expect(c.isConflicted(a), isFalse);
      // Ignored from a's page, gone from b's too: a pair is one thing.
      expect(c.conflictingWith(b), isEmpty);
      expect(c.ignoredConflictsOf(a), 1);
      expect(c.ignoredConflictsOf(b), 1);
      expect(c.ignoredConflictCount, 1);
    });

    test('the mod stays flagged for whatever else it clashes with', () async {
      writeMod('hair.package');
      writeMod('sub/hair.package');
      writeMod('deep/hair.package');
      final c = await makeController();
      expect(c.conflictCount, 3);

      final a = modNamed(c, 'hair.package');
      final b = modNamed(c, 'sub/hair.package');
      final third = modNamed(c, 'deep/hair.package');
      await c.ignoreConflict(a, b);

      expect(c.isConflicted(a), isTrue);
      expect(c.conflictingWith(a).map((m) => m.path), [third.path]);
      expect(c.conflictingWith(b).map((m) => m.path), [third.path]);
      // Nothing was said about b and the third one.
      expect(c.conflictingWith(third), hasLength(2));
      expect(c.conflictCount, 3);
    });

    test('the record survives the mod being switched off and on', () async {
      writeMod('hair.package');
      writeMod('sub/hair.package');
      final c = await makeController();
      final a = modNamed(c, 'hair.package');
      await c.ignoreConflict(a, modNamed(c, 'sub/hair.package'));

      await c.toggleMod(modNamed(c, 'hair.package'));
      await c.toggleMod(modNamed(c, 'hair.package'));

      expect(c.conflictCount, 0);
      expect(c.ignoredConflictCount, 1);
    });

    test('a restart reads the records back', () async {
      writeMod('hair.package');
      writeMod('sub/hair.package');
      final c = await makeController();
      await c.ignoreConflict(
          modNamed(c, 'hair.package'), modNamed(c, 'sub/hair.package'));

      final prefs = await SharedPreferences.getInstance();
      final again = AppController(
        registry: GameRegistry([_Adapter(modsDir)]),
        settings: SettingsStore(prefs),
        checkUpdates: () async => null,
      );
      await again.init();

      expect(again.conflictCount, 0);
      expect(again.ignoredConflictCount, 1);
    });

    test('restoring one mod brings its clashes back', () async {
      writeMod('hair.package');
      writeMod('sub/hair.package');
      final c = await makeController();
      final a = modNamed(c, 'hair.package');
      await c.ignoreConflict(a, modNamed(c, 'sub/hair.package'));
      expect(c.conflictCount, 0);

      await c.restoreConflicts(a);

      expect(c.conflictCount, 2);
      expect(c.ignoredConflictCount, 0);
      expect(c.ignoredConflictsOf(a), 0);
    });

    test('Settings brings back everything this game was keeping quiet',
        () async {
      writeMod('hair.package');
      writeMod('sub/hair.package');
      writeMod('eyes.package');
      writeMod('sub/eyes.package');
      final c = await makeController();
      await c.ignoreConflict(
          modNamed(c, 'hair.package'), modNamed(c, 'sub/hair.package'));
      await c.ignoreConflict(
          modNamed(c, 'eyes.package'), modNamed(c, 'sub/eyes.package'));
      expect(c.conflictCount, 0);
      expect(c.ignoredConflictCount, 2);

      await c.restoreAllConflicts();

      expect(c.conflictCount, 4);
      expect(c.ignoredConflictCount, 0);
    });

    // The partner cap records a big group's pairs one way round, so the
    // mod whose row filled first never lists the one that ignored it.
    // What each mod is keeping quiet is read off the records instead.
    test('a pair the cap recorded one way round is answerable from both',
        () async {
      for (var i = 0; i < 40; i++) {
        writeMod('m$i/same.package');
      }
      final c = await makeController();
      final first = modNamed(c, 'm0/same.package');
      final last = modNamed(c, 'm39/same.package');

      await c.ignoreConflict(last, first);

      expect(c.ignoredConflictsOf(last), 1);
      expect(c.ignoredConflictsOf(first), 1);
      expect(c.conflictingWith(first), isNot(contains(last)));

      // And the way back works from the side the cap left out.
      await c.restoreConflicts(first);
      expect(c.ignoredConflictCount, 0);
      expect(c.ignoredConflictsOf(last), 0);
    });

    test('uninstalling a mod forgets what it was keeping quiet', () async {
      writeMod('hair.package');
      writeMod('sub/hair.package');
      final c = await makeController();
      await c.ignoreConflict(
          modNamed(c, 'hair.package'), modNamed(c, 'sub/hair.package'));
      expect(c.ignoredConflictCount, 1);

      await c.removeMod(modNamed(c, 'sub/hair.package'));

      // The record is gone rather than waiting to be inherited by
      // whatever gets installed at that path next.
      expect(c.ignoredConflictCount, 0);
      writeMod('sub/hair.package');
      await c.refresh();
      expect(c.conflictCount, 2);
    });

    test('another game keeps its own records', () async {
      writeMod('hair.package');
      writeMod('sub/hair.package');
      SharedPreferences.setMockInitialValues({'soundEffects': false});
      final c = AppController(
        registry:
            GameRegistry([_Adapter(modsDir), _Adapter(modsDir, id: 'other')]),
        settings: await SettingsStore.load(),
        checkUpdates: () async => null,
      );
      await c.refresh();
      await c.ignoreConflict(
          modNamed(c, 'hair.package'), modNamed(c, 'sub/hair.package'));

      await c.selectGame('other');

      // Same files on disk, a different game: nothing was settled here.
      expect(c.ignoredConflictCount, 0);
      expect(c.conflictCount, 2);
    });
  });
}
