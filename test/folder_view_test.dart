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

  group('the folder view', () {
    late Directory modsDir;

    setUp(() {
      modsDir = Directory.systemTemp.createTempSync('mod_manager_folders');
    });

    tearDown(() => modsDir.deleteSync(recursive: true));

    void writeMod(String relative) {
      final file = File(p.join(modsDir.path, p.joinAll(relative.split('/'))));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('bytes');
    }

    Future<AppController> makeController([
      Map<String, Object> prefs = const {},
    ]) async {
      SharedPreferences.setMockInitialValues({'soundEffects': false, ...prefs});
      final controller = AppController(
        registry: GameRegistry([_Adapter(modsDir)]),
        settings: await SettingsStore.load(),
        checkUpdates: () async => null,
      );
      await controller.refresh();
      return controller;
    }

    test('every mod lands in exactly one section', () async {
      writeMod('loose.package');
      writeMod('cc/hair.package');
      writeMod('cc/defaults/eyes.package');
      final c = await makeController();

      // 'cc' counts its child for the filter chip, but the section shows
      // only what sits in cc itself - otherwise hair.package would be
      // drawn twice.
      expect(c.folderCount('cc'), 2);
      expect(
        {
          for (final g in c.folderGroups)
            g.folder: g.mods.map((m) => m.name).toList(),
        },
        {
          null: ['loose.package'],
          'cc': ['hair.package'],
          'cc/defaults': ['eyes.package'],
        },
      );
      expect(c.folderGroups.map((g) => g.mods.length).reduce((a, b) => a + b),
          c.filteredMods.length);
    });

    test('the mods folder itself comes first, then the chip order',
        () async {
      writeMod('loose.package');
      writeMod('a/one.package');
      writeMod('b/two.package');
      final c = await makeController();

      expect(c.folderGroups.map((g) => g.folder), [null, 'a', 'b']);

      // Rearranging the folder chips rearranges the sections with them.
      await c.reorderFolder('b', 'a');
      expect(c.folderGroups.map((g) => g.folder), [null, 'b', 'a']);
    });

    test('sections carry their own size', () async {
      writeMod('cc/one.package');
      writeMod('cc/two.package');
      final c = await makeController();

      final group = c.folderGroups.single;
      expect(group.folder, 'cc');
      expect(group.sizeBytes, 'bytes'.length * 2);
    });

    test('the filters narrow the sections rather than sidestep them',
        () async {
      writeMod('cc/hair.package');
      writeMod('cc/eyes.package.disabled');
      writeMod('scripts/cheats.package');
      final c = await makeController();

      c.showOnly(ModStateFilter.disabled);
      expect(
        {
          for (final g in c.folderGroups)
            g.folder: g.mods.map((m) => m.name).toList(),
        },
        {
          'cc': ['eyes.package'],
        },
      );
    });

    test('a rolled-up section is remembered per game', () async {
      writeMod('cc/hair.package');
      final c = await makeController();

      expect(c.isFolderCollapsed('cc'), isFalse);
      await c.toggleFolderCollapsed('cc');
      expect(c.isFolderCollapsed('cc'), isTrue);
      expect(c.settings.collapsedFolders('fake'), ['cc']);

      await c.toggleFolderCollapsed('cc');
      expect(c.isFolderCollapsed('cc'), isFalse);
    });

    test('the mods folder rolls up under a key of its own', () async {
      writeMod('loose.package');
      writeMod('cc/hair.package');
      final c = await makeController();

      await c.toggleFolderCollapsed(null);
      expect(c.isFolderCollapsed(null), isTrue);
      expect(c.isFolderCollapsed('cc'), isFalse);
    });

    test('a subfolder sits under its parent, in tree order', () async {
      writeMod('loose.package');
      writeMod('cc/hair.package');
      writeMod('cc/defaults/eyes.package');
      writeMod('scripts/cheats.package');
      final c = await makeController();

      expect(
        c.folderGroups.map((g) => (g.folder, g.depth)),
        [(null, 0), ('cc', 0), ('cc/defaults', 1), ('scripts', 0)],
      );
    });

    // The complaint this answers: a library organised into cc/hair/female
    // opened on every level at once, headers all the way down before a
    // single mod.
    test('subfolders start rolled up and top-level ones start open',
        () async {
      writeMod('cc/hair.package');
      writeMod('cc/defaults/eyes.package');
      final c = await makeController();

      expect(c.isFolderCollapsed(null), isFalse);
      expect(c.isFolderCollapsed('cc'), isFalse);
      expect(c.isFolderCollapsed('cc/defaults'), isTrue);
    });

    test('opening a subfolder is remembered, and so is closing it again',
        () async {
      writeMod('cc/defaults/eyes.package');
      final c = await makeController();

      await c.toggleFolderCollapsed('cc/defaults');
      expect(c.isFolderCollapsed('cc/defaults'), isFalse);
      expect(c.settings.expandedFolders('fake'), ['cc/defaults']);
      expect(c.settings.collapsedFolders('fake'), isEmpty);

      await c.toggleFolderCollapsed('cc/defaults');
      expect(c.isFolderCollapsed('cc/defaults'), isTrue);
      // Never on both lists at once, whichever way it was flipped.
      expect(c.settings.expandedFolders('fake'), isEmpty);
      expect(c.settings.collapsedFolders('fake'), ['cc/defaults']);
    });

    // An install that had already rolled sections up keeps them rolled
    // up: the stored list is what the user did, not what differs from a
    // default that has since changed.
    test('a section an older install collapsed stays collapsed', () async {
      writeMod('cc/hair.package');
      final c = await makeController({'collapsedFolders.fake': ['cc']});

      expect(c.isFolderCollapsed('cc'), isTrue);
    });

    test('a header counts everything below it, not just what sits in it',
        () async {
      writeMod('cc/hair.package');
      writeMod('cc/defaults/eyes.package');
      writeMod('cc/defaults/deep/skin.package');
      final c = await makeController();

      final cc = c.folderGroups.firstWhere((g) => g.folder == 'cc');
      expect(cc.mods, hasLength(1));
      expect(cc.totalMods, 3);
      expect(cc.sizeBytes, 'bytes'.length);
      expect(cc.totalSizeBytes, 'bytes'.length * 3);
    });

    // A folder with nothing of its own is still the way to the mods
    // underneath it.
    test('a folder holding only subfolders is still a section', () async {
      writeMod('cc/defaults/eyes.package');
      final c = await makeController();

      expect(c.folderGroups.map((g) => g.folder), ['cc', 'cc/defaults']);
      expect(c.folderGroups.first.mods, isEmpty);
      expect(c.folderGroups.first.totalMods, 1);
    });

    test('an install that already picked list or grid keeps it', () async {
      expect((await makeController()).layout, LibraryLayout.grid);
      expect((await makeController({'listView': true})).layout,
          LibraryLayout.list);

      final c = await makeController({'listView': true});
      await c.setLayout(LibraryLayout.folders);
      expect(c.layout, LibraryLayout.folders);
      expect(c.settings.libraryLayout, 'folders');
    });
  });
}
