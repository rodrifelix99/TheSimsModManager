// What a mod turns out to be, read off the resources inside it. The
// category chips answer from the file extension, which for The Sims 2, 3
// and 4 means the whole library reads "Package"; this is the axis that
// answers from the contents instead, and nobody has to type it.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/mod_kind.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';

PackageInsight _holding(Map<String, int> contents) =>
    PackageInsight(resourceCount: 1, contents: contents);

/// Serves whatever contents a test names, by file name, so a library can
/// be made of CAS parts and objects without a real DBPF in sight.
class _Adapter extends FolderBasedGameAdapter {
  _Adapter(this.dir);

  final Directory dir;

  /// File name -> what a scan of it reports. A name absent from here is
  /// a mod the scan could not read.
  Map<String, Map<String, int>> contents = const {};

  @override
  Future<Map<String, PackageInsight>> inspectMods(
    List<Mod> mods, {
    void Function(int done, int total)? onProgress,
    void Function(Map<String, PackageInsight> found)? onFound,
    bool Function()? isCancelled,
  }) async =>
      {
        for (final mod in mods)
          if (contents.containsKey(mod.name))
            mod.path: _holding(contents[mod.name]!),
      };

  @override
  Game get game =>
      const Game(id: 'fake', name: 'Fake Game', series: 'Test', year: 2024);

  @override
  Set<String> get modFileExtensions => const {'.package', '.ts4script'};

  @override
  String get setupHelpKey => 'test adapter';

  @override
  Future<String?> defaultModsPath() async => dir.path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('working out what a mod is', () {
    test('CAS parts make it CAS, objects make it Build/Buy', () {
      expect(modKindsOf(_holding({'CAS parts': 4, 'textures': 9}),
              extension: '.package'),
          {kindCasPart});
      expect(
          modKindsOf(_holding({'objects': 2, 'meshes': 3}),
              extension: '.package'),
          {kindBuildBuy});
    });

    // Content that also brings the tuning wiring it needs is not a mod
    // that changes the rules; if it were, every piece of custom content
    // in the library would wear the Gameplay chip and the chip would
    // mean nothing.
    test('tuning counts only on its own', () {
      expect(modKindsOf(_holding({'tunings': 6}), extension: '.package'),
          {kindGameplay});
      expect(modKindsOf(_holding({'behaviors': 2}), extension: '.package'),
          {kindGameplay});
      expect(
          modKindsOf(_holding({'CAS parts': 1, 'tunings': 3}),
              extension: '.package'),
          {kindCasPart});
    });

    // A set that dresses a Sim and furnishes the room is both, and
    // appears under both chips. That is not a failure to decide.
    test('a mod can be more than one thing', () {
      expect(
        modKindsOf(_holding({'CAS parts': 1, 'objects': 1}),
            extension: '.package'),
        {kindCasPart, kindBuildBuy},
      );
    });

    test('a script is a script by its file, whatever is inside it', () {
      expect(modKindsOf(null, extension: '.ts4script'), {kindScript});
      expect(modKindsOf(_holding({'tunings': 1}), extension: '.ts4script'),
          {kindScript, kindGameplay});
    });

    // Which is every mod in the library while the scan that reads inside
    // files is switched off, and the honest answer for a package of
    // nothing but textures.
    test('nothing to go on is no kind at all, never a guess', () {
      expect(modKindsOf(null, extension: '.package'), isEmpty);
      expect(modKindsOf(_holding(const {}), extension: '.package'), isEmpty);
      expect(modKindsOf(_holding({'textures': 40}), extension: '.package'),
          isEmpty);
    });

    test('the chips are counted and offered in a fixed order', () {
      final counts = countKinds([
        {kindScript},
        {kindCasPart, kindBuildBuy},
        {kindCasPart},
      ]);
      expect(counts.keys.toList(), [kindCasPart, kindBuildBuy, kindScript]);
      expect(counts[kindCasPart], 2);
      expect(counts[kindBuildBuy], 1);
    });
  });

  group('in the library', () {
    late Directory modsDir;
    late _Adapter adapter;

    setUp(() {
      modsDir = Directory.systemTemp.createTempSync('mod_manager_kinds');
      adapter = _Adapter(modsDir);
    });
    tearDown(() => modsDir.deleteSync(recursive: true));

    void writeMod(String name) =>
        File(p.join(modsDir.path, name)).writeAsStringSync('bytes');

    Future<AppController> makeController() async {
      SharedPreferences.setMockInitialValues({'soundEffects': false});
      final c = AppController(
        registry: GameRegistry([adapter]),
        settings: await SettingsStore.load(),
        checkUpdates: () async => null,
      );
      await c.refresh();
      return c;
    }

    test('the chips are there without anyone tagging anything', () async {
      writeMod('hair.package');
      writeMod('sofa.package');
      writeMod('chair.package');
      adapter.contents = {
        'hair.package': {'CAS parts': 3},
        'sofa.package': {'objects': 1},
        'chair.package': {'objects': 1},
      };
      final c = await makeController();

      expect(c.kindCounts, {kindCasPart: 1, kindBuildBuy: 2});
      expect(c.kindsOf(c.mods.firstWhere((m) => m.name == 'hair.package')),
          {kindCasPart});
    });

    test('picking one narrows the library, and picking it again lets go',
        () async {
      writeMod('hair.package');
      writeMod('sofa.package');
      adapter.contents = {
        'hair.package': {'CAS parts': 3},
        'sofa.package': {'objects': 1},
      };
      final c = await makeController();

      c.setKindFilter(kindCasPart);
      expect(c.filteredMods.map((m) => m.name), ['hair.package']);
      expect(c.isFiltering, isTrue);

      c.setKindFilter(kindCasPart);
      expect(c.kindFilter, isNull);
      expect(c.filteredMods, hasLength(2));
    });

    test('clearing the filters clears it too', () async {
      writeMod('hair.package');
      adapter.contents = {
        'hair.package': {'CAS parts': 1},
      };
      final c = await makeController();

      c.setKindFilter(kindCasPart);
      c.clearFilters();
      expect(c.kindFilter, isNull);
      expect(c.isFiltering, isFalse);
    });

    // The 'All' category chip is the way back for every chip on the
    // line, not just the category run of it - a kind lit behind it used
    // to survive the click with nothing on screen to say so.
    test("the category chip 'All' lets go of a lit kind too", () async {
      writeMod('hair.package');
      writeMod('sofa.package');
      adapter.contents = {
        'hair.package': {'CAS parts': 1},
        'sofa.package': {'objects': 1},
      };
      final c = await makeController();

      c.setKindFilter(kindCasPart);
      c.setCategory('All');

      expect(c.kindFilter, isNull);
      expect(c.filteredMods, hasLength(2));
    });

    // A mod switched off is the same mod, and its file keeps its
    // contents; the chip must not lose it because the name gained a
    // marker.
    test('a mod keeps its kind across a disable', () async {
      writeMod('hair.package');
      adapter.contents = {
        'hair.package': {'CAS parts': 1},
      };
      final c = await makeController();

      await c.toggleMod(c.mods.single);
      expect(c.mods.single.isEnabled, isFalse);
      expect(c.kindsOf(c.mods.single), {kindCasPart});
      expect(c.kindCounts, {kindCasPart: 1});
    });

    test('a library the scan read nothing in draws no chips', () async {
      writeMod('mystery.package');
      final c = await makeController();

      expect(c.kindCounts, isEmpty);
      expect(c.kindsOf(c.mods.single), isEmpty);
    });
  });
}
