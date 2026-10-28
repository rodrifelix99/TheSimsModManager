// Where the shelf was left (issue #26): opening a mod and coming back
// used to land on the first row, because the library view is rebuilt from
// scratch every time the screen switches and a fresh ListView starts at
// the top. The offset now lives in the route's page-storage bucket, keyed
// by [AppController.libraryPositionKey] - which is what makes the trip to
// a mod's page free while narrowing to a folder still opens at the top of
// that folder.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';

import 'until.dart';

class _FakeAdapter extends FolderBasedGameAdapter {
  _FakeAdapter(this.dir);

  final Directory dir;

  /// Real isolates can't finish inside the fake-async test zone.
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
  group('the key the position is saved under', () {
    late Directory modsDir;

    setUp(() {
      modsDir = Directory.systemTemp.createTempSync('mod_manager_position');
      for (final name in ['a.package', 'b.package']) {
        File(p.join(modsDir.path, name)).writeAsStringSync('bytes');
      }
      File(p.join(modsDir.path, 'cc', 'c.package'))
        ..parent.createSync(recursive: true)
        ..writeAsStringSync('bytes');
    });

    tearDown(() => modsDir.deleteSync(recursive: true));

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

    test('is the same list after a trip to a mod’s page and back',
        () async {
      final c = await makeController();
      final was = c.libraryPositionKey;

      c.openMod(c.mods.first);
      c.backToLibrary();

      expect(c.libraryPositionKey, was);
    });

    test('survives a refresh, which is the same list rebuilt', () async {
      final c = await makeController();
      final was = c.libraryPositionKey;
      await c.refresh();
      expect(c.libraryPositionKey, was);
    });

    test('is a different list once a folder is the one showing', () async {
      final c = await makeController();
      final whole = c.libraryPositionKey;

      c.setFolder('cc');
      expect(c.libraryPositionKey, isNot(whole));

      // And letting the chip go again comes back to the key the old
      // position was saved under.
      c.setFolder('cc');
      expect(c.libraryPositionKey, whole);
    });

    test('is a different list for another layout, sort or search', () async {
      final c = await makeController();
      final keys = <String>{c.libraryPositionKey};

      await c.setLayout(LibraryLayout.list);
      keys.add(c.libraryPositionKey);
      await c.setLayout(LibraryLayout.folders);
      keys.add(c.libraryPositionKey);
      await c.setSort(LibrarySort.recent);
      keys.add(c.libraryPositionKey);
      c.setQuery('hair');
      keys.add(c.libraryPositionKey);

      expect(keys, hasLength(5));
    });
  });

  testWidgets('the shelf comes back where it was left', (tester) async {
    SharedPreferences.setMockInitialValues(
        {'soundEffects': false, 'libraryLayout': 'list'});
    // Sync IO only outside runAsync; see widget_test.dart.
    final dir = Directory.systemTemp.createTempSync('mod_manager_position');
    // Enough rows that there is somewhere to scroll to. Named in letters
    // rather than digits because a number in a file name is read as a
    // version and stripped off the title.
    for (var i = 0; i < 60; i++) {
      final name = 'mod_${String.fromCharCode(97 + i ~/ 26)}'
          '${String.fromCharCode(97 + i % 26)}';
      File(p.join(dir.path, '$name.package')).writeAsStringSync('x');
    }
    addTearDown(() => dir.deleteSync(recursive: true));

    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final registry = GameRegistry([_FakeAdapter(dir)]);
    final settings = SettingsStore(await SharedPreferences.getInstance());
    await tester.runAsync(() async {
      await tester
          .pumpWidget(ModManagerApp(registry: registry, settings: settings));
    });
    await until(tester, find.text('Fake Game Library'));
    await tester.pump(const Duration(milliseconds: 500));

    // The shelf is the last scroll view on the page; the filter chips
    // above it are the other one.
    double shelfOffset() => tester
        .state<ScrollableState>(find.byType(Scrollable).last)
        .position
        .pixels;

    await tester.drag(find.byType(Scrollable).last, const Offset(0, -600));
    // The offset reaches the storage bucket when the scroll activity
    // ends, so the gesture has to be allowed to settle.
    await tester.pumpAndSettle();
    final left = shelfOffset();
    expect(left, greaterThan(0));

    // Whichever row the scroll left in the middle of the window. By
    // position rather than by name: a row draws its title as a rich text
    // span, which a text finder does not see.
    await tester.tapAt(tester.getCenter(find.byType(Scrollable).last));
    // The back button's arrow, which only the mod's own page has.
    await until(tester, find.text('←'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('←'));
    await until(tester, find.text('Fake Game Library'));
    await tester.pumpAndSettle();

    expect(shelfOffset(), closeTo(left, 0.5),
        reason: 'the shelf went back to the first row');
  });
}
