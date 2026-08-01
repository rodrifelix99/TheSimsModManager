// Multi-select and the actions that work on a whole selection at once.
// The identity a tick is kept under is the point of most of this: mods
// are renamed when they're switched off, so a selection recorded by the
// path on disk would empty itself the moment a batch ran.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/services/analytics.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';

class _SpyAnalytics extends Analytics {
  _SpyAnalytics() : super.disabled();

  final events = <String, Map<String, Object?>>{};
  final exceptions = <Object>[];

  @override
  void capture(String event, [Map<String, Object?> properties = const {}]) {
    events[event] = properties;
  }

  @override
  void captureException(
    Object error,
    StackTrace? stack, {
    bool handled = true,
    String mechanism = 'generic',
    Map<String, Object?> properties = const {},
  }) {
    exceptions.add(error);
  }
}

class _Adapter extends FolderBasedGameAdapter {
  _Adapter(this.dir);

  final Directory dir;

  bool failToggle = false;
  bool failRemove = false;

  /// Run before each file of a batch, so a test can pull the handbrake
  /// halfway through one.
  void Function(Mod mod)? onToggle;

  /// The real scan reads files in isolates a test can't wait on.
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
  Future<Mod> setEnabled(Mod mod, {required bool enabled}) {
    onToggle?.call(mod);
    if (failToggle) throw Exception('toggle went sideways');
    return super.setEnabled(mod, enabled: enabled);
  }

  @override
  Future<void> removeMod(Mod mod) {
    if (failRemove) throw Exception('removal went sideways');
    return super.removeMod(mod);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory modsDir;
  late _Adapter adapter;

  setUp(() {
    modsDir = Directory.systemTemp.createTempSync('mod_manager_selection');
    adapter = _Adapter(modsDir);
  });

  tearDown(() => modsDir.deleteSync(recursive: true));

  void seedMod(String relative) {
    final file = File(p.join(modsDir.path, p.joinAll(relative.split('/'))));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync('bytes of $relative');
  }

  Future<AppController> makeController({Analytics? analytics}) async {
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final controller = AppController(
      registry: GameRegistry([adapter]),
      settings: await SettingsStore.load(),
      checkUpdates: () async => null,
      analytics: analytics,
    );
    await controller.refresh();
    return controller;
  }

  Mod modNamed(AppController c, String name) =>
      c.mods.firstWhere((mod) => mod.name == name);

  group('picking mods out of the library', () {
    test('a tick goes on and off again', () async {
      seedMod('hair.package');
      final c = await makeController();

      expect(c.hasSelection, isFalse);
      c.toggleSelected(c.mods.single);
      expect(c.selectedCount, 1);
      expect(c.isSelected(c.mods.single), isTrue);

      c.toggleSelected(c.mods.single);
      expect(c.hasSelection, isFalse);
    });

    test('shift takes the range in the order on screen, not on disk',
        () async {
      for (final name in ['a', 'b', 'c', 'd']) {
        seedMod('$name.package');
      }
      final c = await makeController();
      // Biggest first, so the shelf reads d, c, b, a - and the range has
      // to follow that rather than the alphabet.
      seedFileSizes(modsDir);
      await c.refresh();
      await c.setSort(LibrarySort.size);

      c.toggleSelected(modNamed(c, 'd.package'));
      c.selectTo(modNamed(c, 'b.package'));

      expect(c.selectedMods.map((m) => m.name),
          containsAll(['d.package', 'c.package', 'b.package']));
      expect(c.isSelected(modNamed(c, 'a.package')), isFalse);
    });

    test('a first shift-click with nothing to measure from just ticks',
        () async {
      seedMod('hair.package');
      seedMod('eyes.package');
      final c = await makeController();

      c.selectTo(modNamed(c, 'eyes.package'));
      expect(c.selectedMods.map((m) => m.name), ['eyes.package']);
    });

    test('select all means what the filters are showing', () async {
      seedMod('long_eyelashes.package');
      seedMod('short_eyelashes.package');
      seedMod('cozy_sofa.package');
      final c = await makeController();

      c.setQuery('eyelashes');
      c.selectAllVisible();

      expect(c.selectedCount, 2);
      expect(c.allVisibleSelected, isTrue);
      // And the ticks stay on when the search that made them goes away.
      c.setQuery('');
      expect(c.selectedCount, 2);
      expect(c.allVisibleSelected, isFalse);
    });

    test('an enabled mod and its disabled twin are two separate ticks',
        () async {
      // One folder can hold both at once - install over a mod you had
      // switched off and this is exactly what you get - and the two share
      // an enabled name. Ticking one must not reach the other.
      seedMod('hair.package');
      seedMod('hair.package.disabled');
      final c = await makeController();
      expect(c.mods, hasLength(2));

      c.toggleSelected(c.mods.firstWhere((mod) => mod.isEnabled));
      expect(c.selectedCount, 1);
      expect(c.selectedMods.single.isEnabled, isTrue);

      await c.removeSelected();

      expect(modsDir.listSync().map((e) => p.basename(e.path)),
          ['hair.package.disabled']);
    });

    test('a tick survives its mod being switched off on its own', () async {
      seedMod('hair.package');
      final c = await makeController();
      c.toggleSelected(c.mods.single);

      // A single toggle renames the file under the tick, the way a batch
      // does; the tick has to follow either way.
      await c.toggleMod(c.mods.single);

      expect(c.selectedCount, 1);
      expect(c.isSelected(c.mods.single), isTrue);
      expect(c.mods.single.isEnabled, isFalse);
    });

    test('a tick on a mod that has left the library goes with it', () async {
      seedMod('hair.package');
      seedMod('eyes.package');
      final c = await makeController();
      c.selectAllVisible();
      expect(c.selectedCount, 2);

      File(p.join(modsDir.path, 'eyes.package')).deleteSync();
      await c.refresh();

      expect(c.selectedMods.map((m) => m.name), ['hair.package']);
    });

    test('switching game drops the ticks', () async {
      seedMod('hair.package');
      final c = await makeController();
      c.selectAllVisible();

      await c.selectGame('fake');
      expect(c.hasSelection, isFalse);
    });
  });

  group('switching a whole selection over', () {
    test('every ticked mod is renamed, and stays ticked afterwards',
        () async {
      seedMod('hair.package');
      seedMod('eyes.package');
      seedMod('cozy_sofa.package');
      final c = await makeController();

      c.toggleSelected(modNamed(c, 'hair.package'));
      c.toggleSelected(modNamed(c, 'eyes.package'));
      await c.setSelectedEnabled(false);

      expect(File(p.join(modsDir.path, 'hair.package.disabled')).existsSync(),
          isTrue);
      expect(File(p.join(modsDir.path, 'eyes.package.disabled')).existsSync(),
          isTrue);
      expect(File(p.join(modsDir.path, 'cozy_sofa.package')).existsSync(),
          isTrue);
      expect(c.enabledCount, 1);
      // The files were renamed under them; the ticks are kept by the name
      // each mod carries while it's on, so they survive.
      expect(c.selectedCount, 2);
      expect(c.selectedMods.every((mod) => !mod.isEnabled), isTrue);

      // And back again, from the same selection.
      await c.setSelectedEnabled(true);
      expect(c.enabledCount, 3);
      expect(c.selectedCount, 2);
    });

    test('mods already on the wanted side are left alone', () async {
      seedMod('hair.package');
      seedMod('eyes.package.disabled');
      final spy = _SpyAnalytics();
      final c = await makeController(analytics: spy);
      c.selectAllVisible();

      await c.setSelectedEnabled(false);

      expect(spy.events['mods_bulk_toggled'], {
        'game': 'fake',
        'enabled': false,
        'mods': 1,
        'failed': 0,
      });
    });

    test('nothing left to do is not a batch at all', () async {
      seedMod('hair.package');
      final spy = _SpyAnalytics();
      final c = await makeController(analytics: spy);
      c.selectAllVisible();

      await c.setSelectedEnabled(true);

      expect(spy.events.containsKey('mods_bulk_toggled'), isFalse);
      expect(c.lastError, isNull);
    });

    test('one refusal speaks for itself', () async {
      seedMod('hair.package');
      final c = await makeController();
      c.selectAllVisible();
      adapter.failToggle = true;

      await c.setSelectedEnabled(false);

      expect('${c.lastError}', contains('toggle went sideways'));
    });

    test('several refusals report a tally, and one exception', () async {
      for (final name in ['a', 'b', 'c']) {
        seedMod('$name.package');
      }
      final spy = _SpyAnalytics();
      final c = await makeController(analytics: spy);
      c.selectAllVisible();
      adapter.failToggle = true;

      await c.setSelectedEnabled(false);

      // A key and a count, not three file names: the UI words it.
      expect(c.lastError?.key, 'bulkToggleFailed');
      expect(c.lastError?.args, ['3']);
      expect(spy.events['mods_bulk_toggled']?['failed'], 3);
      // Three files refused for the same reason is one report worth
      // sending, not three.
      expect(spy.exceptions, hasLength(1));
    });

    test('cancelling stops the batch where it is', () async {
      for (final name in ['a', 'b', 'c', 'd']) {
        seedMod('$name.package');
      }
      final c = await makeController();
      c.selectAllVisible();
      var seen = 0;
      adapter.onToggle = (_) {
        if (++seen == 2) c.cancelBulk();
      };

      await c.setSelectedEnabled(false);

      // The two it reached are off; the rest were never touched.
      expect(seen, 2);
      expect(c.disabledCount, 2);
      expect(c.bulkProgress, isNull);
      expect(c.lastError, isNull);
    });
  });

  group('deleting a whole selection', () {
    test('the files go, and so do their ticks', () async {
      seedMod('hair.package');
      seedMod('eyes.package');
      seedMod('cozy_sofa.package');
      final spy = _SpyAnalytics();
      final c = await makeController(analytics: spy);

      c.toggleSelected(modNamed(c, 'hair.package'));
      c.toggleSelected(modNamed(c, 'eyes.package'));
      await c.removeSelected();

      expect(modsDir.listSync().map((e) => p.basename(e.path)),
          ['cozy_sofa.package']);
      expect(c.mods.map((m) => m.name), ['cozy_sofa.package']);
      expect(c.hasSelection, isFalse);
      expect(spy.events['mods_bulk_removed']?['mods'], 2);
    });

    test('what refused keeps its tick and gets counted', () async {
      seedMod('hair.package');
      seedMod('eyes.package');
      final c = await makeController();
      c.selectAllVisible();
      adapter.failRemove = true;

      await c.removeSelected();

      expect(modsDir.listSync(), hasLength(2));
      expect(c.lastError?.key, 'bulkRemoveFailed');
      expect(c.lastError?.args, ['2']);
      // Nothing was deleted, so nothing was unticked: the selection is
      // still there to try again with.
      expect(c.selectedCount, 2);
    });

    test('a disabled mod is deleted under the name it actually carries',
        () async {
      seedMod('hair.package.disabled');
      final c = await makeController();
      c.selectAllVisible();

      await c.removeSelected();

      expect(modsDir.listSync(), isEmpty);
    });
  });
}

/// Gives the seeded files distinct sizes, a to d ascending, so a
/// size-sorted shelf has an order worth taking a range out of.
void seedFileSizes(Directory dir) {
  var size = 100;
  for (final name in ['a', 'b', 'c', 'd']) {
    File(p.join(dir.path, '$name.package')).writeAsStringSync('x' * size);
    size += 100;
  }
}
