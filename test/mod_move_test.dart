// Making subfolders and moving mods between them. Most of what is
// checked here is not the rename itself but what has to follow it: a mod
// is named by where it sits in the shop's install records, in the
// settled-conflict records and in the artwork cache, and a tidy-up that
// left those behind would cost the user an update badge, a decision they
// had already made, and a re-scan of everything they touched.
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/services/reachability.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';

class _Adapter extends FolderBasedGameAdapter {
  _Adapter(this.dir);

  final Directory dir;

  /// What the game's own cfg would say, when a test wants a limit.
  int? depthLimit;

  /// Thumbnails to hand back for the files named here, by file name.
  final Map<String, Uint8List> artwork = {};

  int scans = 0;

  @override
  Future<Map<String, PackageInsight>> inspectMods(
    List<Mod> mods, {
    void Function(int done, int total)? onProgress,
    void Function(Map<String, PackageInsight> found)? onFound,
    bool Function()? isCancelled,
  }) async {
    scans++;
    return {
      for (final mod in mods)
        if (artwork[p.basename(mod.path)] case final bytes?)
          mod.path: PackageInsight(thumbnail: bytes),
    };
  }

  @override
  Future<int?> modDepthLimit(Directory modsDir) async => depthLimit;

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

  late Directory modsDir;
  late _Adapter adapter;

  setUp(() {
    modsDir = Directory.systemTemp.createTempSync('mod_manager_move');
    adapter = _Adapter(modsDir);
  });

  tearDown(() => modsDir.deleteSync(recursive: true));

  File seedMod(String relative) {
    final file = File(p.join(modsDir.path, p.joinAll(relative.split('/'))));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync('bytes of $relative');
    return file;
  }

  /// [full] runs init() instead of refresh(): the records kept in
  /// preferences - the shop's installs among them - are read there, so a
  /// test about one of those has to start the controller properly. The
  /// Exchange is reported unreachable so nothing reaches for the network.
  Future<AppController> makeController(
      {Map<String, Object> prefs = const {}, bool full = false}) async {
    SharedPreferences.setMockInitialValues({
      'soundEffects': false,
      if (full) 'reachShop': false,
      ...prefs,
    });
    final controller = AppController(
      registry: GameRegistry([adapter]),
      settings: await SettingsStore.load(),
      checkUpdates: () async => null,
      checkElevated: () async => false,
      probeServices: (_) async =>
          const Reachability(shop: false, site: true, downloads: true),
    );
    if (full) {
      await controller.init();
    } else {
      await controller.refresh();
    }
    return controller;
  }

  Mod modNamed(AppController c, String name) =>
      c.mods.firstWhere((mod) => mod.name == name);

  bool exists(String relative) =>
      File(p.join(modsDir.path, p.joinAll(relative.split('/')))).existsSync();

  group('the adapter move', () {
    test('takes the file to the folder, making it on the way', () async {
      final file = seedMod('hair.package');
      final mod = adapter.modAt(file.path)!;

      final moved =
          await adapter.moveMod(mod, Directory(p.join(modsDir.path, 'cc')));

      expect(exists('cc/hair.package'), isTrue);
      expect(exists('hair.package'), isFalse);
      expect(moved.path, p.join(modsDir.path, 'cc', 'hair.package'));
      expect(moved.isEnabled, isTrue);
    });

    test('a disabled mod arrives disabled', () async {
      final file = seedMod('hair.package.disabled');
      final mod = adapter.modAt(file.path)!;

      final moved =
          await adapter.moveMod(mod, Directory(p.join(modsDir.path, 'cc')));

      expect(exists('cc/hair.package.disabled'), isTrue);
      expect(moved.isEnabled, isFalse);
      expect(moved.name, 'hair.package');
    });

    test('refuses rather than overwrite a file already there', () async {
      final file = seedMod('hair.package');
      seedMod('cc/hair.package');
      final mod = adapter.modAt(file.path)!;

      await expectLater(
        adapter.moveMod(mod, Directory(p.join(modsDir.path, 'cc'))),
        throwsA(isA<ModActionException>().having(
            (e) => e.reason, 'reason', ModActionFailure.nameTaken)),
      );
      // Both files are still where they were - nothing was half done.
      expect(exists('hair.package'), isTrue);
      expect(File(p.join(modsDir.path, 'cc', 'hair.package')).readAsStringSync(),
          'bytes of cc/hair.package');
    });
  });

  group('moving mods around the library', () {
    test('the folder chips and counts follow', () async {
      seedMod('hair.package');
      seedMod('eyes.package');
      final c = await makeController();
      expect(c.folders, isEmpty);

      await c.moveMods(c.mods, 'cc', method: 'test');

      expect(exists('cc/hair.package'), isTrue);
      expect(c.folders, ['cc']);
      expect(c.folderCount('cc'), 2);
      expect(c.lastError, isNull);
    });

    test('and back out to the mods folder again', () async {
      seedMod('cc/hair.package');
      final c = await makeController();

      await c.moveMods(c.mods, null, method: 'test');

      expect(exists('hair.package'), isTrue);
      expect(c.folderCount('cc'), 0);
    });

    test('a mod already in that folder is left where it is', () async {
      seedMod('cc/hair.package');
      final c = await makeController();

      await c.moveMods(c.mods, 'cc', method: 'test');

      expect(exists('cc/hair.package'), isTrue);
      expect(c.lastError, isNull);
    });

    test('the ticks follow their mods', () async {
      seedMod('hair.package');
      seedMod('eyes.package');
      final c = await makeController();
      c.selectAllVisible();

      await c.moveMods(c.selectedMods, 'cc', method: 'test');

      expect(c.selectedCount, 2);
      expect(c.selectedMods.every((m) => c.folderOf(m) == 'cc'), isTrue);
    });

    test('the scan result travels with the file', () async {
      seedMod('hair.package');
      adapter.artwork['hair.package'] = Uint8List.fromList([1, 2, 3]);
      final c = await makeController();
      expect(c.thumbnailOf(c.mods.single), [1, 2, 3]);
      final scansBefore = adapter.scans;

      await c.moveMods(c.mods, 'cc', method: 'test');

      // Same bytes, and nothing was read off the disk again to get them.
      expect(c.thumbnailOf(c.mods.single), [1, 2, 3]);
      expect(adapter.scans, scansBefore);
    });

    test("the shop's install record follows", () async {
      seedMod('hair.package');
      final c = await makeController(full: true, prefs: {
        'shop.installs': '{"listing-1": {"game": "fake", "version": "1.0", '
            '"name": "Hair", "files": ["hair.package"]}}',
      });

      await c.moveMods(c.mods, 'cc', method: 'test');

      final saved = c.settings.shopInstallsJson;
      expect(saved, contains('cc${p.separator == r'\' ? r'\\' : '/'}'
          'hair.package'));
      expect(saved, isNot(contains('"hair.package"')));
    });

    test('a settled conflict stays settled', () async {
      seedMod('hair.package');
      seedMod('other/hair.package');
      final c = await makeController();
      final flagged = c.mods.where((m) => c.isConflicted(m)).toList();
      expect(flagged, hasLength(2));

      await c.ignoreConflict(flagged.first, flagged.last);
      expect(c.conflictCount, 0);

      // One of the pair moves; the clash is still the same two files and
      // the user has already said it's fine.
      await c.moveMods([modNamed(c, 'hair.package')], 'cc', method: 'test');

      expect(c.conflictCount, 0);
      expect(c.ignoredConflictCount, 1);
    });

    test('what refuses is counted and keeps its tick', () async {
      seedMod('hair.package');
      seedMod('cc/hair.package');
      final c = await makeController();
      final blocked = c.mods.firstWhere((m) => c.folderOf(m) == null);
      c.toggleSelected(blocked);

      await c.moveMods([blocked], 'cc', method: 'test');

      expect(c.lastError?.key, 'fileNameTaken');
      expect(c.selectedCount, 1);
      expect(exists('hair.package'), isTrue);
    });
  });

  group('making a folder', () {
    test('it exists, and it has a chip before anything is in it', () async {
      seedMod('hair.package');
      final c = await makeController();

      final made = await c.createFolder(null, 'cc');

      expect(made, 'cc');
      expect(Directory(p.join(modsDir.path, 'cc')).existsSync(), isTrue);
      expect(c.folders, ['cc']);
      expect(c.folderCount('cc'), 0);
      // And it draws a section of its own, so there is somewhere to drop.
      expect(c.folderGroups.map((g) => g.folder), [null, 'cc']);
    });

    test('and it is still there after a reload', () async {
      seedMod('hair.package');
      final c = await makeController();
      await c.createFolder(null, 'cc');

      await c.refresh();

      expect(c.folders, ['cc']);
    });

    test('one made inside another nests', () async {
      seedMod('hair.package');
      final c = await makeController();

      final made = await c.createFolder('cc', 'defaults');

      expect(made, 'cc/defaults');
      expect(
          Directory(p.join(modsDir.path, 'cc', 'defaults')).existsSync(), isTrue);
      // The parent earns a chip too, the way it does for a mod inside it.
      expect(c.folders, ['cc', 'cc/defaults']);
    });

    test('a folder deleted behind our back stops being listed', () async {
      seedMod('hair.package');
      final c = await makeController();
      await c.createFolder(null, 'cc');

      Directory(p.join(modsDir.path, 'cc')).deleteSync();
      await c.refresh();

      expect(c.folders, isEmpty);
    });

    test('a name with a separator in it is refused', () async {
      seedMod('hair.package');
      final c = await makeController();

      expect(await c.createFolder(null, 'cc/defaults'), isNull);
      expect(c.lastError?.key, 'folderNameBad');
      expect(c.folders, isEmpty);
    });

    test('an empty name is refused', () async {
      seedMod('hair.package');
      final c = await makeController();

      expect(await c.createFolder(null, '   '), isNull);
      expect(c.lastError?.key, 'folderNameBad');
    });

    test('one the game would never read is refused', () async {
      seedMod('hair.package');
      adapter.depthLimit = 1;
      final c = await makeController();
      expect(await c.createFolder(null, 'cc'), 'cc');

      expect(await c.createFolder('cc', 'defaults'), isNull);
      expect(c.lastError?.key, 'folderTooDeep');
      expect(c.lastError?.args, ['1']);
      expect(Directory(p.join(modsDir.path, 'cc', 'defaults')).existsSync(),
          isFalse);
    });
  });
}
