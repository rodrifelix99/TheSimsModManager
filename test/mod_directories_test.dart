// The mods folder is not always the only folder a game reads. The Sims 3
// engine keeps the list in its own Resource.cfg, and the stock community
// framework names an Overrides folder beside Packages - mods that are
// installed, enabled and loaded by the game, and that the library was
// blind to until this was read.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/core/resource_cfg.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims_adapters.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';

/// A game shaped like The Sims 3: the cfg sits beside the mods folder.
class _CfgAdapter extends FolderBasedGameAdapter {
  _CfgAdapter(this.dir);

  final Directory dir;

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

  @override
  File? resourceCfgFile(Directory modsDir) =>
      File(p.join(modsDir.parent.path, 'Resource.cfg'));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('which folders a cfg names', () {
    test('the stock Sims 3 framework names Overrides beside Packages', () {
      expect(
        modFolderRoots('Priority 500\n'
            'DirectoryFiles Overrides autoupdate\n'
            'PackedFile Overrides/*.package\n'
            'Priority 1000\n'
            'PackedFile Packages/*.package\n'
            'PackedFile Packages/*/*.package\n'
            'PackedFile Packages/*/*/*.package\n'),
        ['Overrides', 'Packages'],
      );
    });

    test("The Sims 4's own cfg names the mods folder itself", () {
      expect(
        modFolderRoots('Priority 500\n'
            'PackedFile *.package\n'
            'PackedFile */*.package\n'
            'DirectoryFiles unpackedmod autoupdate\n'),
        ['', 'unpackedmod'],
      );
    });

    test('a trailing ... is "and below", not a folder', () {
      expect(
        modFolderRoots('DirectoryFiles Mods/Packages/... autoupdate\n'),
        ['Mods/Packages'],
      );
    });

    test('lines that name no folder are not folders', () {
      expect(modFolderRoots('Priority 500\nJunk\n\n# a comment\n'), isEmpty);
    });

    test('backslashes are separators too', () {
      expect(modFolderRoots(r'PackedFile Deep\Nested\*.package'),
          ['Deep/Nested']);
    });

    test('a path with no wildcard still names the folder, not the file', () {
      expect(modFolderRoots('PackedFile Overrides/one.package'), ['Overrides']);
    });

    // This file is written by other people's tools and edited by hand. A
    // line in it must never be able to point a sweep at the rest of the
    // machine.
    test('climbing out and absolute paths are refused', () {
      expect(modFolderRoots('PackedFile ../../../Windows/*.package'), isEmpty);
      expect(modFolderRoots('DirectoryFiles ../secrets autoupdate'), isEmpty);
      expect(modFolderRoots(r'PackedFile C:\Windows\*.package'), isEmpty);
      expect(modFolderRoots('PackedFile /etc/*.package'), isEmpty);
    });
  });

  group('listing them', () {
    late Directory root;
    late Directory mods;

    setUp(() {
      root = Directory.systemTemp.createTempSync('mod_manager_dirs');
      mods = Directory(p.join(root.path, 'Packages'))..createSync();
    });
    tearDown(() => root.deleteSync(recursive: true));

    void writeCfg(String text) =>
        File(p.join(root.path, 'Resource.cfg')).writeAsStringSync(text);

    void writeMod(String relative) {
      final file = File(p.join(root.path, p.joinAll(relative.split('/'))));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('bytes');
    }

    test('a mod in Overrides is in the library', () async {
      writeCfg('PackedFile Packages/*.package\n'
          'PackedFile Overrides/*.package\n');
      writeMod('Packages/hair.package');
      writeMod('Overrides/nointro.package');

      final found = await _CfgAdapter(mods).listMods(mods);

      expect(found.map((m) => m.name),
          unorderedEquals(['hair.package', 'nointro.package']));
    });

    test('no cfg means the mods folder and nothing else', () async {
      writeMod('Packages/hair.package');
      writeMod('Overrides/nointro.package');

      final found = await _CfgAdapter(mods).listMods(mods);

      expect(found.map((m) => m.name), ['hair.package']);
    });

    test('a folder the cfg names but nobody made is not a problem',
        () async {
      writeCfg('PackedFile Packages/*.package\n'
          'PackedFile Overrides/*.package\n');
      writeMod('Packages/hair.package');

      expect(await _CfgAdapter(mods).extraModsDirectories(mods), isEmpty);
    });

    // The failure this guards against is a library that counts every mod
    // twice and a conflict scan that reports each one clashing with
    // itself.
    test('the mods folder is never swept twice', () async {
      writeCfg('PackedFile Packages/*.package\n'
          'PackedFile Packages/*/*.package\n'
          'DirectoryFiles Packages autoupdate\n');
      writeMod('Packages/hair.package');

      final found = await _CfgAdapter(mods).listMods(mods);

      expect(found, hasLength(1));
      expect(await _CfgAdapter(mods).extraModsDirectories(mods), isEmpty);
    });

    test('a folder holding the mods folder is refused, and so is one '
        'inside it', () async {
      // '' is the cfg's own folder, which holds Packages; 'Packages/Sub'
      // sits inside it. Sweeping either would list the same files again.
      writeCfg('PackedFile *.package\n'
          'PackedFile Packages/Sub/*.package\n');
      writeMod('Packages/Sub/hair.package');

      final found = await _CfgAdapter(mods).listMods(mods);

      expect(found, hasLength(1));
      expect(await _CfgAdapter(mods).extraModsDirectories(mods), isEmpty);
    });

    test('the real Sims 3 adapter finds the framework Overrides folder',
        () async {
      final docs = Directory(p.join(root.path, 'Documents'))..createSync();
      final game = Directory(
          p.join(docs.path, 'Electronic Arts', 'The Sims 3', 'Mods'))
        ..createSync(recursive: true);
      Directory(p.join(game.path, 'Packages')).createSync();
      Directory(p.join(game.path, 'Overrides')).createSync();
      File(p.join(game.path, 'Resource.cfg')).writeAsStringSync(
          'Priority 500\n'
          'DirectoryFiles Overrides autoupdate\n'
          'PackedFile Overrides/*.package\n'
          'Priority 1000\n'
          'PackedFile Packages/*.package\n');
      final adapter = Sims3Adapter(documentsOverride: docs);
      final modsDir = await adapter.resolveModsDirectory();

      final extras = await adapter.extraModsDirectories(modsDir!);

      expect(extras, hasLength(1));
      expect(p.basename(extras.single.path), 'Overrides');
    });
  });

  group('in the library', () {
    late Directory root;
    late Directory mods;

    setUp(() {
      root = Directory.systemTemp.createTempSync('mod_manager_dirs_ui');
      mods = Directory(p.join(root.path, 'Packages'))..createSync();
      File(p.join(root.path, 'Resource.cfg')).writeAsStringSync(
          'PackedFile Packages/*.package\n'
          'PackedFile Overrides/*.package\n');
    });
    tearDown(() => root.deleteSync(recursive: true));

    void writeMod(String relative) {
      final file = File(p.join(root.path, p.joinAll(relative.split('/'))));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('bytes');
    }

    Future<AppController> makeController() async {
      SharedPreferences.setMockInitialValues({'soundEffects': false});
      final controller = AppController(
        registry: GameRegistry([_CfgAdapter(mods)]),
        settings: await SettingsStore.load(),
        checkUpdates: () async => null,
      );
      await controller.refresh();
      return controller;
    }

    test('the other folder gets a chip of its own, and the counts include '
        'it', () async {
      writeMod('Packages/hair.package');
      writeMod('Overrides/nointro.package');
      final c = await makeController();

      expect(c.mods, hasLength(2));
      expect(c.folders, contains('Overrides'));
      expect(c.folderCount('Overrides'), 1);

      c.setFolder('Overrides');
      expect(c.filteredMods.map((m) => m.name), ['nointro.package']);
    });

    test('it is not somewhere the app files things by itself', () async {
      writeMod('Packages/hair.package');
      writeMod('Overrides/nointro.package');
      final c = await makeController();
      c.setFolder('Overrides');

      // Same rule The Sims 1's routed folders follow: a folder the app
      // does not own is not a destination it picks. An install with that
      // chip up still lands in the mods folder, and a mod already there
      // cannot be dragged out.
      expect(c.canMoveInto('Overrides'), isFalse);
      expect(c.moveTargets, isNot(contains('Overrides')));
      final override = c.mods.firstWhere((m) => m.name == 'nointro.package');
      expect(c.canMove(override), isFalse);
    });

    test('a mod in the other folder can still be switched off', () async {
      writeMod('Overrides/nointro.package');
      final c = await makeController();

      await c.toggleMod(c.mods.single);

      expect(c.mods.single.isEnabled, isFalse);
      expect(
          File(p.join(root.path, 'Overrides', 'nointro.package.disabled'))
              .existsSync(),
          isTrue);
    });

    test('the depth warning stays off files the limit was never about',
        () async {
      writeMod('Packages/hair.package');
      writeMod('Overrides/nointro.package');
      final c = await makeController();

      // The limit counts subfolders of the mods folder; a sibling folder
      // is not below it at any depth.
      expect(c.tooDeepPaths, isEmpty);
    });
  });
}
