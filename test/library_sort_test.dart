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

  group('the order the library is drawn in', () {
    late Directory modsDir;

    setUp(() {
      modsDir = Directory.systemTemp.createTempSync('mod_manager_sort');
    });

    tearDown(() => modsDir.deleteSync(recursive: true));

    /// A mod file of [bytes] bytes last touched [daysAgo] days ago, so
    /// each sort has something of its own to go on.
    void writeMod(String name, {required int bytes, required int daysAgo}) {
      final file = File(p.join(modsDir.path, name));
      file.writeAsStringSync('x' * bytes);
      file.setLastModifiedSync(
          DateTime(2026, 1, 1).subtract(Duration(days: daysAgo)));
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

    /// Three mods whose name, age and size each put them in a different
    /// order, and one of them switched off.
    void writeLibrary() {
      writeMod('alpha.package', bytes: 30, daysAgo: 1);
      writeMod('beta.package.disabled', bytes: 10, daysAgo: 20);
      writeMod('gamma.package', bytes: 20, daysAgo: 10);
    }

    List<String> namesOf(AppController c) =>
        [for (final mod in c.filteredMods) mod.name];

    test('is the file name, the way it always was', () async {
      writeLibrary();
      final c = await makeController();

      expect(c.sort, LibrarySort.name);
      expect(c.disabledLast, isFalse);
      expect(namesOf(c), ['alpha.package', 'beta.package', 'gamma.package']);
    });

    test('sinks the disabled ones without disturbing the rest', () async {
      writeLibrary();
      final c = await makeController();

      await c.setDisabledLast(true);

      expect(namesOf(c), ['alpha.package', 'gamma.package', 'beta.package']);
    });

    test('by date is newest first, and the grouping holds inside it',
        () async {
      writeLibrary();
      // A second disabled mod, so the bottom half has an order of its own.
      writeMod('delta.package.disabled', bytes: 40, daysAgo: 5);
      final c = await makeController();

      await c.setSort(LibrarySort.recent);
      expect(namesOf(c),
          ['alpha.package', 'delta.package', 'gamma.package', 'beta.package']);

      await c.setDisabledLast(true);
      expect(namesOf(c),
          ['alpha.package', 'gamma.package', 'delta.package', 'beta.package']);
    });

    test('by size is biggest first', () async {
      writeLibrary();
      final c = await makeController();

      await c.setSort(LibrarySort.size);

      expect(namesOf(c), ['alpha.package', 'gamma.package', 'beta.package']);
    });

    test('survives a restart', () async {
      writeLibrary();
      final first = await makeController();
      await first.setSort(LibrarySort.size);
      await first.setDisabledLast(true);

      final again = AppController(
        registry: GameRegistry([_Adapter(modsDir)]),
        settings: await SettingsStore.load(),
        checkUpdates: () async => null,
      );
      await again.refresh();

      expect(again.sort, LibrarySort.size);
      expect(again.disabledLast, isTrue);
    });

    test('holds inside the folder view too', () async {
      Directory(p.join(modsDir.path, 'cc')).createSync();
      writeMod(p.join('cc', 'one.package'), bytes: 10, daysAgo: 1);
      writeMod(p.join('cc', 'two.package.disabled'), bytes: 10, daysAgo: 2);
      writeMod(p.join('cc', 'three.package'), bytes: 10, daysAgo: 3);
      final c = await makeController();

      await c.setDisabledLast(true);

      final group = c.folderGroups.single;
      expect(group.folder, 'cc');
      expect([for (final mod in group.mods) mod.name],
          ['one.package', 'three.package', 'two.package']);
    });
  });
}
