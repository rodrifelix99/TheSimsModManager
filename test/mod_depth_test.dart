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

/// Reads a cfg the way the Sims 3 engine games do, one level below the
/// mods folder, so the controller has something to find.
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

  group('reading a Resource.cfg', () {
    test('the deepest PackedFile line is the limit', () {
      expect(
          maxPackedFileDepth('Priority 500\n'
              'PackedFile Packages/*.package\n'
              'PackedFile Packages/*/*.package\n'
              'PackedFile Packages/*/*/*.package\n'),
          2);
    });

    test('the literal path to the mods folder is not depth', () {
      // Medieval's: Mods/Packages is where the folder is, not how deep
      // the game will go inside it.
      expect(
          maxPackedFileDepth('Priority 500\n'
              'DirectoryFiles Mods/Packages/... autoupdate\n'
              'PackedFile Mods/Packages/*.package\n'
              'PackedFile Mods/Packages/*/*.package\n'),
          1);
    });

    test('a hand-added level counts', () {
      expect(
          maxPackedFileDepth('PackedFile */*/*/*/*.package\n'
              'PackedFile */*/*/*/*/*.package\n'),
          5);
    });

    test('lines out of order still give the deepest', () {
      expect(
          maxPackedFileDepth('PackedFile */*/*.package\n'
              'PackedFile *.package\n'),
          2);
    });

    test('a cfg with nothing to go on says so', () {
      expect(maxPackedFileDepth(''), isNull);
      expect(maxPackedFileDepth('Priority 500\n'), isNull);
      expect(maxPackedFileDepth('DirectoryFiles Overrides/ autoupdate\n'),
          isNull);
    });

    test('comments and stray whitespace are ignored', () {
      expect(
          maxPackedFileDepth('# mine\n'
              '\n'
              '   PackedFile   */*.package   \n'),
          1);
    });
  });

  group('the shipped adapters', () {
    late Directory root;

    setUp(() => root = Directory.systemTemp.createTempSync('mod_manager_cfg'));
    tearDown(() => root.deleteSync(recursive: true));

    test('The Sims 4 scaffolds four levels and reads them back', () async {
      final mods = Directory(p.join(root.path, 'Mods'));
      await const Sims4Adapter().createModsDirectory(mods.path);

      expect(await const Sims4Adapter().modDepthLimit(mods), 4);
    });

    test('The Sims 3 scaffolds four levels and reads them back', () async {
      final mods = Directory(p.join(root.path, 'Mods', 'Packages'));
      await const Sims3Adapter().createModsDirectory(mods.path);

      expect(await const Sims3Adapter().modDepthLimit(mods), 4);
    });

    test('The Sims Medieval scaffolds four levels and reads them back',
        () async {
      final mods = Directory(p.join(root.path, 'Mods', 'Packages'));
      await const SimsMedievalAdapter().createModsDirectory(mods.path);

      expect(await const SimsMedievalAdapter().modDepthLimit(mods), 4);
    });

    test('a game with no cfg has no limit', () async {
      final mods = Directory(p.join(root.path, 'Downloads'));
      await const Sims2Adapter().createModsDirectory(mods.path);

      expect(await const Sims2Adapter().modDepthLimit(mods), isNull);
    });

    test('no cfg on disk means no limit, whatever we would have written',
        () async {
      final mods = Directory(p.join(root.path, 'Mods'))
        ..createSync(recursive: true);

      expect(await const Sims4Adapter().modDepthLimit(mods), isNull);
    });
  });

  group('the library', () {
    late Directory root;
    late Directory modsDir;

    setUp(() {
      root = Directory.systemTemp.createTempSync('mod_manager_depth');
      modsDir = Directory(p.join(root.path, 'Mods', 'Packages'))
        ..createSync(recursive: true);
    });

    tearDown(() => root.deleteSync(recursive: true));

    void writeCfg(int levels) {
      final lines = [
        'Priority 500',
        for (var i = 0; i <= levels; i++)
          'PackedFile Packages/${'*/' * i}*.package',
      ];
      File(p.join(modsDir.parent.path, 'Resource.cfg'))
          .writeAsStringSync('${lines.join('\n')}\n');
    }

    void writeMod(String relative) {
      final file = File(p.join(modsDir.path, p.joinAll(relative.split('/'))));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('bytes');
    }

    Future<AppController> makeController() async {
      SharedPreferences.setMockInitialValues({'soundEffects': false});
      final controller = AppController(
        registry: GameRegistry([_CfgAdapter(modsDir)]),
        settings: await SettingsStore.load(),
        checkUpdates: () async => null,
      );
      await controller.refresh();
      return controller;
    }

    test('mods below what the game reads are named', () async {
      writeCfg(2);
      writeMod('shallow.package');
      writeMod('cc/hair.package');
      writeMod('cc/defaults/eyes.package');
      writeMod('cc/defaults/deep/buried.package');
      final c = await makeController();

      expect(c.modDepthLimit, 2);
      expect(c.tooDeepCount, 1);
      expect(c.mods.where(c.isTooDeep).single.name, 'buried.package');
    });

    test('the banner filter shows exactly those mods', () async {
      writeCfg(1);
      writeMod('cc/hair.package');
      writeMod('cc/defaults/eyes.package');
      final c = await makeController();

      c.toggleTooDeepOnly();
      expect(c.filteredMods.map((m) => m.name), ['eyes.package']);

      c.toggleTooDeepOnly();
      expect(c.filteredMods, hasLength(2));
    });

    test('a user who added a level to the cfg is believed', () async {
      writeCfg(3);
      writeMod('cc/defaults/deep/buried.package');
      final c = await makeController();

      expect(c.modDepthLimit, 3);
      expect(c.tooDeepCount, 0);
    });

    test('no cfg, no warning', () async {
      writeMod('cc/defaults/deep/very/buried.package');
      final c = await makeController();

      expect(c.modDepthLimit, isNull);
      expect(c.tooDeepCount, 0);
      // And the filter cannot be switched on with nothing to show.
      c.toggleTooDeepOnly();
      expect(c.tooDeepOnly, isFalse);
    });

    test('the warning goes away when the mod is moved up', () async {
      writeCfg(1);
      writeMod('cc/defaults/eyes.package');
      final c = await makeController();
      c.toggleTooDeepOnly();
      expect(c.tooDeepCount, 1);

      File(p.join(modsDir.path, 'cc', 'defaults', 'eyes.package'))
          .renameSync(p.join(modsDir.path, 'cc', 'eyes.package'));
      await c.refresh();

      expect(c.tooDeepCount, 0);
      // The filter cleared itself rather than leaving an empty library.
      expect(c.tooDeepOnly, isFalse);
      expect(c.filteredMods, hasLength(1));
    });
  });
}
