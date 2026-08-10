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

/// chmod is the only way to build a folder this process may not write to,
/// and Windows doesn't have it.
const _posixOnly = 'read-only folders are built with chmod here';

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

    // The user who asked for this keeps a `defaults` folder inside `cc`
    // and reads them as two shelves, not one holding the other.
    group('when folders do not include their subfolders', () {
      Future<AppController> makeNarrow() async {
        SharedPreferences.setMockInitialValues(
            {'soundEffects': false, 'folderIncludesSubfolders': false});
        final controller = AppController(
          registry: GameRegistry([_FakeAdapter(modsDir)]),
          settings: await SettingsStore.load(),
          checkUpdates: () async => null,
        );
        await controller.refresh();
        return controller;
      }

      test('a folder shows only what sits in it', () async {
        writeMod('cc/defaults/eyes.package');
        writeMod('cc/hair.package');
        final c = await makeNarrow();

        c.setFolder('cc');
        expect(c.filteredMods.map((m) => m.name), ['hair.package']);

        c.setFolder('cc/defaults');
        expect(c.filteredMods.map((m) => m.name), ['eyes.package']);
      });

      // The number on the chip has to be the number you get when you
      // press it, or the two answers argue with each other on screen.
      test('the count on the chip matches what pressing it shows', () async {
        writeMod('cc/defaults/eyes.package');
        writeMod('cc/hair.package');
        final c = await makeNarrow();

        expect(c.folderCount('cc'), 1);
        expect(c.folderCount('cc/defaults'), 1);
        c.setFolder('cc');
        expect(c.filteredMods, hasLength(c.folderCount('cc')));
      });

      test('a folder holding nothing of its own still gets its chip',
          () async {
        writeMod('cc/defaults/eyes.package');
        final c = await makeNarrow();

        expect(c.folders, ['cc', 'cc/defaults']);
        expect(c.folderCount('cc'), 0);
      });

      test('turning it back on counts the subfolders again', () async {
        writeMod('cc/defaults/eyes.package');
        writeMod('cc/hair.package');
        final c = await makeNarrow();
        expect(c.folderCount('cc'), 1);

        await c.setFolderIncludesSubfolders(true);

        expect(c.folderCount('cc'), 2);
        c.setFolder('cc');
        expect(c.filteredMods, hasLength(2));
      });
    });

    group('more than one folder at once', () {
      test('ctrl-clicking a second folder shows both', () async {
        writeMod('cc/hair.package');
        writeMod('mods/tuning.package');
        writeMod('loose.package');
        final c = await makeController();

        c.setFolder('cc');
        c.setFolder('mods', add: true);

        expect(c.selectedFolders, {'cc', 'mods'});
        expect(c.filteredMods.map((m) => m.name),
            containsAll(['hair.package', 'tuning.package']));
        expect(c.filteredMods, hasLength(2));
      });

      test('ctrl-clicking a lit folder puts just that one out', () async {
        writeMod('cc/hair.package');
        writeMod('mods/tuning.package');
        final c = await makeController();

        c.setFolder('cc');
        c.setFolder('mods', add: true);
        c.setFolder('cc', add: true);

        expect(c.selectedFolders, {'mods'});
        expect(c.filteredMods.map((m) => m.name), ['tuning.package']);
      });

      // Without the modifier a chip still means "just this one", which is
      // what it has always meant.
      test('a plain click replaces the selection rather than adding to it',
          () async {
        writeMod('cc/hair.package');
        writeMod('mods/tuning.package');
        final c = await makeController();

        c.setFolder('cc');
        c.setFolder('mods', add: true);
        c.setFolder('cc');

        expect(c.selectedFolders, {'cc'});
      });

      test('clicking the only lit folder again clears the filter', () async {
        writeMod('cc/hair.package');
        writeMod('loose.package');
        final c = await makeController();

        c.setFolder('cc');
        c.setFolder('cc');

        expect(c.selectedFolders, isEmpty);
        expect(c.filteredMods, hasLength(2));
      });

      test('categories light up together the same way', () async {
        writeMod('one.package');
        writeMod('two.ts4script');
        final c = await makeController(extensions: {'.package', '.ts4script'});

        c.setCategory('Package');
        c.setCategory('Script', add: true);

        expect(c.selectedCategories, {'Package', 'Script'});
        expect(c.filteredMods, hasLength(2));
        // 'All' is the way back whatever is lit.
        c.setCategory('All');
        expect(c.selectedCategories, isEmpty);
      });

      // 'All' heads every chip on the line, folders included - a folder
      // lit behind it used to survive the click.
      test("'All' lets go of a lit folder too", () async {
        writeMod('cc/hair.package');
        writeMod('loose.package');
        final c = await makeController();

        c.setFolder('cc');
        c.setCategory('All');

        expect(c.selectedFolders, isEmpty);
        expect(c.filteredMods, hasLength(2));
      });

      // An install has to land somewhere, and two lit chips is no answer
      // to which of them - so it falls back to the mods folder.
      test('two folders lit is no destination for an install', () async {
        writeMod('cc/hair.package');
        writeMod('mods/tuning.package');
        final c = await makeController();

        c.setFolder('cc');
        expect(c.installFolder, 'cc');

        c.setFolder('mods', add: true);
        expect(c.installFolder, isNull);
      });
    });

    group('deleting a folder', () {
      test('takes the folder, its mods and its subfolders', () async {
        writeMod('cc/defaults/eyes.package');
        writeMod('cc/hair.package');
        writeMod('loose.package');
        final c = await makeController();

        await c.deleteFolder('cc');

        expect(Directory(p.join(modsDir.path, 'cc')).existsSync(), isFalse);
        expect(c.mods.map((m) => m.name), ['loose.package']);
        expect(c.folders, isEmpty);
      });

      // Whatever the chip is set to count, the disk has no way to keep a
      // subfolder of a folder that is gone.
      test('takes the subfolders even when chips do not count them',
          () async {
        SharedPreferences.setMockInitialValues(
            {'soundEffects': false, 'folderIncludesSubfolders': false});
        writeMod('cc/defaults/eyes.package');
        writeMod('cc/hair.package');
        final c = AppController(
          registry: GameRegistry([_FakeAdapter(modsDir)]),
          settings: await SettingsStore.load(),
          checkUpdates: () async => null,
        );
        await c.refresh();

        expect(c.modsInFolder('cc'), hasLength(2));
        await c.deleteFolder('cc');

        expect(Directory(p.join(modsDir.path, 'cc')).existsSync(), isFalse);
        expect(c.mods, isEmpty);
      });

      test('it stops filtering the library on the way out', () async {
        writeMod('cc/hair.package');
        writeMod('loose.package');
        final c = await makeController();
        c.setFolder('cc');

        await c.deleteFolder('cc');

        expect(c.selectedFolders, isEmpty);
        expect(c.filteredMods.map((m) => m.name), ['loose.package']);
      });

      test('the readme that came with the mods goes too', () async {
        writeMod('cc/hair.package');
        File(p.join(modsDir.path, 'cc', 'readme.txt'))
            .writeAsStringSync('instructions');
        final c = await makeController();

        await c.deleteFolder('cc');

        expect(Directory(p.join(modsDir.path, 'cc')).existsSync(), isFalse);
      });

      // A folder the system won't part with is a verdict on the machine
      // rather than a bug: the mods inside are already gone, and what is
      // left is a folder that is still there and has to keep saying so.
      test('a folder the system refuses to remove is reported, not thrown',
          () async {
        writeMod('loose.package');
        final c = await makeController();
        await c.createFolder(null, 'cc');
        expect(c.folders, ['cc']);

        // Removing an entry needs write permission on the folder holding
        // it, so it is the mods folder that goes read-only here, not the
        // one being deleted.
        Process.runSync('chmod', ['500', modsDir.path]);
        addTearDown(() => Process.runSync('chmod', ['700', modsDir.path]));

        await c.deleteFolder('cc');

        expect(c.lastError, isNotNull);
        expect(Directory(p.join(modsDir.path, 'cc')).existsSync(), isTrue);
        expect(c.folders, ['cc']);
      }, skip: Platform.isWindows ? _posixOnly : false);

      test('an empty folder the user made is forgotten as well', () async {
        writeMod('loose.package');
        final c = await makeController();
        await c.createFolder(null, 'cc');
        expect(c.folders, ['cc']);

        await c.deleteFolder('cc');
        await c.refresh();

        expect(c.folders, isEmpty);
        expect(c.settings.madeFolders('fake'), isEmpty);
      });
    });

    test('a folder that is gone stops filtering the library', () async {
      writeMod('cc/hair.package');
      final c = await makeController();
      c.setFolder('cc');

      Directory(p.join(modsDir.path, 'cc')).deleteSync(recursive: true);
      writeMod('loose.package');
      await c.refresh();

      expect(c.selectedFolders, isEmpty);
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
