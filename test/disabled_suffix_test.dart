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

class _Adapter extends FolderBasedGameAdapter {
  _Adapter(this.dir);

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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('the marker that means disabled', () {
    late Directory modsDir;

    setUp(() {
      modsDir = Directory.systemTemp.createTempSync('mod_manager_marker');
    });

    tearDown(() {
      modsDir.deleteSync(recursive: true);
      disabledSuffix = defaultDisabledSuffix;
    });

    void writeMod(String name) =>
        File(p.join(modsDir.path, name)).writeAsStringSync('bytes');

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

    test('lists what another manager switched off', () async {
      writeMod('hair.package');
      writeMod('eyes.package.off');
      final c = await makeController();

      expect(c.mods, hasLength(2));
      expect(c.disabledCount, 1);
      expect(c.mods.firstWhere((m) => m.name == 'eyes.package').isEnabled,
          isFalse);
    });

    test('is the stored one from the first listing on', () async {
      writeMod('hair.package.no-load');
      final c = await makeController({'disabledSuffix': '.no-load'});

      expect(disabledSuffix, '.no-load');
      expect(c.mods.single.name, 'hair.package');
      expect(c.mods.single.isEnabled, isFalse);
    });

    test('is what switching a mod off writes', () async {
      writeMod('lamp.package');
      final c = await makeController();

      await c.setDisabledSuffix('.off');
      await c.toggleMod(c.mods.single);

      expect(File(p.join(modsDir.path, 'lamp.package.off')).existsSync(),
          isTrue);
      expect(c.mods.single.isEnabled, isFalse);
      // And back on, the marker comes off again.
      await c.toggleMod(c.mods.single);
      expect(File(p.join(modsDir.path, 'lamp.package')).existsSync(), isTrue);
    });

    test('takes effect on a library that was already open', () async {
      writeMod('hair.package.no-load');
      final c = await makeController();
      // Nobody's marker yet, so the file is not a mod as far as we know.
      expect(c.mods, isEmpty);

      await c.setDisabledSuffix('.no-load');

      expect(c.mods.single.name, 'hair.package');
      expect(c.mods.single.isEnabled, isFalse);
    });

    test('refuses one the library could not survive', () async {
      final c = await makeController();

      expect(c.canUseDisabledSuffix('.package'), isFalse);
      expect(c.canUseDisabledSuffix('.zip'), isFalse);
      expect(c.canUseDisabledSuffix('off'), isFalse);
      expect(c.canUseDisabledSuffix('.off'), isTrue);

      await c.setDisabledSuffix('.package');

      expect(c.settings.disabledSuffix, isNull);
      expect(disabledSuffix, defaultDisabledSuffix);
    });

    test('empty hands it back to the app default', () async {
      final c = await makeController({'disabledSuffix': '.off'});
      expect(disabledSuffix, '.off');

      await c.setDisabledSuffix('');

      expect(c.settings.disabledSuffix, isNull);
      expect(disabledSuffix, defaultDisabledSuffix);
    });
  });
}
