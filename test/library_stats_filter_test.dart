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

  group('the header stats as filters', () {
    late Directory modsDir;

    setUp(() {
      modsDir = Directory.systemTemp.createTempSync('mod_manager_stats');
    });

    tearDown(() => modsDir.deleteSync(recursive: true));

    void writeMod(String relative) {
      final file = File(p.join(modsDir.path, p.joinAll(relative.split('/'))));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('bytes');
    }

    Future<AppController> makeController([Map<String, Object> prefs =
        const {}]) async {
      SharedPreferences.setMockInitialValues(
          {'soundEffects': false, ...prefs});
      final controller = AppController(
        registry: GameRegistry([_Adapter(modsDir)]),
        settings: await SettingsStore.load(),
        checkUpdates: () async => null,
      );
      await controller.refresh();
      return controller;
    }

    test('Enabled and Disabled show their own half', () async {
      writeMod('hair.package');
      writeMod('eyes.package.disabled');
      final c = await makeController();

      expect(c.enabledCount, 1);
      expect(c.disabledCount, 1);

      c.showOnly(ModStateFilter.enabled);
      expect(c.filteredMods.map((m) => m.name), ['hair.package']);

      c.showOnly(ModStateFilter.disabled);
      expect(c.filteredMods.map((m) => m.name), ['eyes.package']);

      // Clicking the one already showing lets go of it.
      c.showOnly(ModStateFilter.disabled);
      expect(c.stateFilter, ModStateFilter.all);
      expect(c.filteredMods, hasLength(2));
    });

    test('an empty half cannot be switched on', () async {
      writeMod('hair.package');
      final c = await makeController();

      c.showOnly(ModStateFilter.disabled);
      expect(c.stateFilter, ModStateFilter.all);
    });

    test('asking for the disabled ones beats the preference hiding them',
        () async {
      writeMod('hair.package');
      writeMod('eyes.package.disabled');
      final c = await makeController({'showDisabled': false});

      expect(c.filteredMods.map((m) => m.name), ['hair.package']);

      c.showOnly(ModStateFilter.disabled);
      expect(c.filteredMods.map((m) => m.name), ['eyes.package']);

      // And the preference is back in force once the filter is dropped.
      c.showOnly(ModStateFilter.disabled);
      expect(c.filteredMods.map((m) => m.name), ['hair.package']);
    });

    test('the filter clears itself when its half empties out', () async {
      writeMod('hair.package');
      writeMod('eyes.package.disabled');
      final c = await makeController();
      c.showOnly(ModStateFilter.disabled);

      await c.toggleMod(c.mods.firstWhere((m) => !m.isEnabled));

      expect(c.disabledCount, 0);
      expect(c.stateFilter, ModStateFilter.all);
      expect(c.filteredMods, hasLength(2));
    });

    test('Total drops the search and every filter at once', () async {
      writeMod('cc/hair.package');
      writeMod('eyes.package.disabled');
      final c = await makeController();

      expect(c.isFiltering, isFalse);

      c.showOnly(ModStateFilter.enabled);
      c.setQuery('hair');
      c.setFolder('cc');
      expect(c.isFiltering, isTrue);

      c.clearFilters();
      expect(c.isFiltering, isFalse);
      expect(c.query, isEmpty);
      expect(c.selectedFolders, isEmpty);
      expect(c.stateFilter, ModStateFilter.all);
      expect(c.filteredMods, hasLength(c.mods.length));
    });

    test('Total leaves the show-disabled preference alone', () async {
      writeMod('hair.package');
      writeMod('eyes.package.disabled');
      final c = await makeController({'showDisabled': false});

      c.clearFilters();
      expect(c.settings.showDisabled, isFalse);
      expect(c.filteredMods.map((m) => m.name), ['hair.package']);
    });
  });
}
