import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/mod_folder.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';
import 'package:sims_mod_manager/src/ui/mod_presentation.dart';

class _FakeAdapter extends FolderBasedGameAdapter {
  _FakeAdapter(this.dir, {this.extensions = const {'.package'}});

  final Directory dir;
  final Set<String> extensions;

  /// The real implementation reads files in isolates the test can't wait on.
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
  Set<String> get modFileExtensions => extensions;

  @override
  Map<String, String> get categoryByExtension =>
      const {'.package': 'Package', '.ts4script': 'Script'};

  @override
  String get setupHelpKey => 'test adapter';

  @override
  Future<String?> defaultModsPath() async => dir.path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('folder keys', () {
    test('a nested folder contributes to every folder above it', () {
      expect(folderAncestry('cc'), ['cc']);
      expect(folderAncestry('cc/defaults'), ['cc', 'cc/defaults']);
      expect(folderAncestry('cc/defaults/hair'),
          ['cc', 'cc/defaults', 'cc/defaults/hair']);
    });

    test('a folder is within itself and its parents, not its namesakes', () {
      expect(folderIsWithin('cc/defaults', 'cc'), isTrue);
      expect(folderIsWithin('cc', 'cc'), isTrue);
      expect(folderIsWithin('ccc/defaults', 'cc'), isFalse);
      expect(folderIsWithin('cc', 'cc/defaults'), isFalse);
    });

    test('a chip spells a nested folder out', () {
      expect(folderChipLabel('cc'), 'cc');
      expect(folderChipLabel('cc/defaults'), 'cc / defaults');
    });
  });

  group('the library', () {
    late Directory modsDir;
    late Directory dropDir;

    setUp(() {
      modsDir = Directory.systemTemp.createTempSync('mod_manager_folders');
      dropDir = Directory.systemTemp.createTempSync('mod_manager_folder_src');
    });

    tearDown(() {
      modsDir.deleteSync(recursive: true);
      dropDir.deleteSync(recursive: true);
    });

    void writeMod(String relative) {
      final file = File(p.join(modsDir.path, p.joinAll(relative.split('/'))));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('bytes');
    }

    Future<AppController> makeController(
        {Set<String> extensions = const {'.package'}}) async {
      SharedPreferences.setMockInitialValues({'soundEffects': false});
      final controller = AppController(
        registry:
            GameRegistry([_FakeAdapter(modsDir, extensions: extensions)]),
        settings: await SettingsStore.load(),
        checkUpdates: () async => null,
      );
      await controller.refresh();
      return controller;
    }

    test('every subfolder gets a chip, however deep it sits', () async {
      writeMod('cc/defaults/eyes.package');
      writeMod('cc/hair.package');
      writeMod('mods/tuning.package');
      writeMod('loose.package');
      final c = await makeController();

      expect(c.folders, ['cc', 'cc/defaults', 'mods']);
      // A folder counts what is under it, not only what it holds itself.
      expect(c.folderCount('cc'), 2);
      expect(c.folderCount('cc/defaults'), 1);
      expect(c.folderCount('mods'), 1);
    });

    test('a folder with nothing of its own still gets a chip', () async {
      writeMod('cc/defaults/eyes.package');
      final c = await makeController();

      expect(c.folders, ['cc', 'cc/defaults']);
      expect(c.folderCount('cc'), 1);
    });

    test('picking a folder shows what is below it too', () async {
      writeMod('cc/defaults/eyes.package');
      writeMod('cc/hair.package');
      writeMod('loose.package');
      final c = await makeController();

      c.setFolder('cc');
      expect(c.filteredMods.map((m) => m.name),
          containsAll(['eyes.package', 'hair.package']));
      expect(c.filteredMods, hasLength(2));

      c.setFolder('cc/defaults');
      expect(c.filteredMods.map((m) => m.name), ['eyes.package']);
    });

    test('a folder that is gone stops filtering the library', () async {
      writeMod('cc/hair.package');
      final c = await makeController();
      c.setFolder('cc');

      Directory(p.join(modsDir.path, 'cc')).deleteSync(recursive: true);
      writeMod('loose.package');
      await c.refresh();

      expect(c.folder, 'All');
      expect(c.filteredMods, hasLength(1));
    });

    test('a drop lands in the folder that is selected', () async {
      writeMod('cc/defaults/eyes.package');
      final c = await makeController();
      final source = File(p.join(dropDir.path, 'hair.package'))
        ..writeAsStringSync('bytes');

      c.setFolder('cc/defaults');
      await c.installDroppedPaths([source.path]);

      expect(
          File(p.join(modsDir.path, 'cc', 'defaults', 'hair.package'))
              .existsSync(),
          isTrue);
      expect(File(p.join(modsDir.path, 'hair.package')).existsSync(), isFalse);
    });

    test('a drop with no folder selected lands at the top', () async {
      writeMod('cc/hair.package');
      final c = await makeController();
      final source = File(p.join(dropDir.path, 'eyes.package'))
        ..writeAsStringSync('bytes');

      await c.installDroppedPaths([source.path]);

      expect(
          File(p.join(modsDir.path, 'eyes.package')).existsSync(), isTrue);
    });

    test('a drop into a folder the user made on the spot creates it',
        () async {
      writeMod('cc/hair.package');
      final c = await makeController();
      c.setFolder('cc');
      Directory(p.join(modsDir.path, 'cc')).deleteSync(recursive: true);
      final source = File(p.join(dropDir.path, 'eyes.package'))
        ..writeAsStringSync('bytes');

      await c.installDroppedPaths([source.path]);

      expect(File(p.join(modsDir.path, 'cc', 'eyes.package')).existsSync(),
          isTrue);
    });

    test('one file type means no category chip to choose from', () async {
      writeMod('hair.package');
      writeMod('eyes.package');
      final c = await makeController();

      expect(c.categories, ['All']);
      expect(c.categoryCount('All'), 2);
    });

    test('two file types are worth choosing between', () async {
      writeMod('hair.package');
      writeMod('cheats.ts4script');
      final c = await makeController(
          extensions: const {'.package', '.ts4script'});

      expect(c.categories, ['All', 'Package', 'Script']);
    });
  });
}
