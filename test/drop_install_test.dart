import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';

class _FakeAdapter extends FolderBasedGameAdapter {
  _FakeAdapter(this.dir);

  final Directory dir;

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
  Set<String> get modFileExtensions => const {'.package'};

  @override
  String get setupHelp => 'test adapter';

  @override
  Future<String?> defaultModsPath() async => dir.path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory modsDir;
  late Directory dropDir;

  setUp(() {
    modsDir = Directory.systemTemp.createTempSync('mod_manager_drop_mods');
    dropDir = Directory.systemTemp.createTempSync('mod_manager_drop_src');
  });

  tearDown(() {
    modsDir.deleteSync(recursive: true);
    dropDir.deleteSync(recursive: true);
  });

  Future<AppController> makeController() async {
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final controller = AppController(
      registry: GameRegistry([_FakeAdapter(modsDir)]),
      settings: await SettingsStore.load(),
      checkUpdates: () async => null,
    );
    await controller.refresh();
    return controller;
  }

  File dropFile(String name) {
    final file = File(p.join(dropDir.path, name));
    file.writeAsStringSync('bytes of $name');
    return file;
  }

  test('dropped mod files install; junk alongside them is skipped', () async {
    final c = await makeController();
    final mod = dropFile('cozy_sofa.package');
    final readme = dropFile('readme.txt');

    await c.installDroppedPaths([mod.path, readme.path]);

    expect(
        File(p.join(modsDir.path, 'cozy_sofa.package')).existsSync(), isTrue);
    expect(File(p.join(modsDir.path, 'readme.txt')).existsSync(), isFalse);
    expect(c.mods, hasLength(1));
  });

  test('extension match is case-insensitive', () async {
    final c = await makeController();
    final mod = dropFile('SHINY_LAMP.PACKAGE');

    await c.installDroppedPaths([mod.path]);

    expect(c.mods, hasLength(1));
  });

  test('a drop with nothing installable changes nothing', () async {
    final c = await makeController();
    final screenshot = dropFile('preview.jpg');

    await c.installDroppedPaths([screenshot.path]);

    expect(c.mods, isEmpty);
    expect(c.lastError, isNull);
    expect(modsDir.listSync(), isEmpty);
  });

  test('a dropped folder installs as a subfolder, structure preserved',
      () async {
    final c = await makeController();
    final folder = Directory(p.join(dropDir.path, 'GrungeCC'))..createSync();
    File(p.join(folder.path, 'sofa.package')).writeAsStringSync('sofa');
    Directory(p.join(folder.path, 'chairs')).createSync();
    File(p.join(folder.path, 'chairs', 'stool.package'))
        .writeAsStringSync('stool');
    File(p.join(folder.path, 'readme.txt')).writeAsStringSync('skip me');

    await c.installDroppedPaths([folder.path]);

    expect(File(p.join(modsDir.path, 'GrungeCC', 'sofa.package')).existsSync(),
        isTrue);
    expect(
        File(p.join(modsDir.path, 'GrungeCC', 'chairs', 'stool.package'))
            .existsSync(),
        isTrue);
    expect(File(p.join(modsDir.path, 'GrungeCC', 'readme.txt')).existsSync(),
        isFalse);
    expect(c.mods, hasLength(2));
    // The folder name becomes a library filter chip.
    expect(c.folders, contains('GrungeCC'));
  });

  test('a dropped folder with no mod files surfaces a readable error',
      () async {
    final c = await makeController();
    final folder = Directory(p.join(dropDir.path, 'JustDocs'))..createSync();
    File(p.join(folder.path, 'notes.txt')).writeAsStringSync('nothing here');

    await c.installDroppedPaths([folder.path]);

    expect(c.mods, isEmpty);
    expect(c.lastError, contains('JustDocs'));
  });
}
