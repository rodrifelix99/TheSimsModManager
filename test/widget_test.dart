import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Size;

import 'package:flutter/widgets.dart' show Text;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app.dart';
import 'package:sims_mod_manager/src/ui/widgets.dart';

class _FakeAdapter extends FolderBasedGameAdapter {
  _FakeAdapter(this.dir, {this.gameFolder});

  final Directory dir;

  /// Simulates the game's own folder being detected (mods dir missing).
  final Directory? gameFolder;

  @override
  Future<Directory?> findGameFolder() async => gameFolder;

  /// The real implementation reads the file in an [Isolate]: a thread the
  /// widget test's fake-async zone can't wait on, whose open handle makes
  /// Windows fail the toggle rename and the temp-dir teardown delete.
  @override
  Future<Uint8List?> loadThumbnail(Mod mod) async => null;

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
  testWidgets('shell renders mods from disk and toggles them',
      (tester) async {
    // The design targets a 1280×824 desktop window.
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // Sounds off: the audioplayers plugin has no test backend, and the
    // controller shouldn't even try to reach it under flutter test.
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    // Sync IO only outside runAsync: awaiting real file IO inside the
    // test's fake-async zone deadlocks.
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_ui');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    File(p.join(tempDir.path, 'cozy_sofa.package'))
        .writeAsStringSync('sofa bytes');

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(
          ModManagerApp(registry: registry, settings: settings));
      // Let the controller finish its real file IO.
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Fake Game Library'), findsOneWidget);
    // Display title is the humanized file name.
    expect(find.text('cozy sofa'), findsOneWidget);

    // Disable it via the card switch: the file gets the .disabled marker.
    await tester.runAsync(() async {
      await tester.tap(find.byType(PillSwitch).first);
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      File(p.join(tempDir.path, 'cozy_sofa.package$disabledSuffix'))
          .existsSync(),
      isTrue,
    );
  });

  testWidgets('conflicts stat filters the library and detail names the clash',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_ui');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    // The same file name in two subfolders — the duplicate-name heuristic
    // flags both. A third mod is clean.
    for (final sub in ['A', 'B']) {
      Directory(p.join(tempDir.path, sub)).createSync();
      File(p.join(tempDir.path, sub, 'lamp.package')).writeAsStringSync('x');
    }
    File(p.join(tempDir.path, 'unique.package')).writeAsStringSync('x');

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(
          ModManagerApp(registry: registry, settings: settings));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Both duplicates count; tapping the stat narrows the library to them.
    expect(find.text('CONFLICTS'), findsOneWidget);
    expect(find.text('unique'), findsOneWidget);
    await tester.tap(find.text('CONFLICTS'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('lamp'), findsNWidgets(2));
    expect(find.text('unique'), findsNothing);

    // Tapping again clears the filter.
    await tester.tap(find.text('CONFLICTS'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('unique'), findsOneWidget);

    // The detail view explains the flag and names the clashing file.
    await tester.tap(find.text('lamp').first);
    await tester.pump(const Duration(milliseconds: 400));
    expect(
        find.text('Another enabled mod has the same file name:'),
        findsOneWidget);
    // One panel row pointing at the *other* copy, as a path relative to
    // the mods folder ("A\lamp.package" or "B\lamp.package" depending on
    // which card opened — mods sharing a name have no guaranteed order).
    final row = find.byWidgetPredicate((w) =>
        w is Text &&
        (w.data == p.join('A', 'lamp.package') ||
            w.data == p.join('B', 'lamp.package')));
    expect(row, findsOneWidget);
  });

  testWidgets('subfolders become filter chips that narrow the library',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_ui');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    // One mod in the root, two in a "CAS" subfolder (nested files count
    // toward their top-level folder).
    File(p.join(tempDir.path, 'root_mod.package')).writeAsStringSync('x');
    Directory(p.join(tempDir.path, 'CAS', 'hair')).createSync(recursive: true);
    File(p.join(tempDir.path, 'CAS', 'skin_tone.package'))
        .writeAsStringSync('x');
    File(p.join(tempDir.path, 'CAS', 'hair', 'long_hair.package'))
        .writeAsStringSync('x');

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(
          ModManagerApp(registry: registry, settings: settings));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // The subfolder shows up as a chip (label + count in one span);
    // filtering hides the root mod.
    final casChip = find.text('CAS  2');
    expect(casChip, findsOneWidget);
    await tester.tap(casChip);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('skin tone'), findsOneWidget);
    expect(find.text('long hair'), findsOneWidget);
    expect(find.text('root mod'), findsNothing);

    // Tapping the active chip clears the filter again.
    await tester.tap(casChip);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('root mod'), findsOneWidget);
  });

  testWidgets('folder chips overflow into the "…" menu when the line is full',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_ui');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    // Enough wide-named folders that the single-line filter row can't
    // hold them all.
    for (var i = 0; i < 12; i++) {
      final dir = Directory(p.join(tempDir.path, 'Creator Folder Number $i'))
        ..createSync();
      File(p.join(dir.path, 'mod_$i.package')).writeAsStringSync('x');
    }

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(
          ModManagerApp(registry: registry, settings: settings));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Overflowing chips stay in the tree but unpainted; the visible sign
    // of overflow is the "…" button at the end of the line.
    expect(find.text('…'), findsOneWidget);

    // A hidden folder lives in the popup menu and still filters. Folder
    // "11" sorts near the top lexicographically, so its row is inside
    // the menu's scroll viewport. (Fixed pumps, not pumpAndSettle —
    // matching the rest of this file.)
    await tester.tap(find.text('…'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Creator Folder Number 11'), findsOneWidget);
    await tester.tap(find.text('Creator Folder Number 11'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('mod 11'), findsOneWidget);
    expect(find.text('mod 0'), findsNothing);
  });

  testWidgets('dragging a folder chip onto another reorders only folders',
      (tester) async {
    // Wider than the design's 1280: the test's Ahem font renders every
    // glyph full-width, and all chips must fit on the line to be dragged.
    tester.view.physicalSize = const Size(1700, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_ui');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    for (final name in ['Alpha', 'Beta', 'Gamma']) {
      final dir = Directory(p.join(tempDir.path, name))..createSync();
      File(p.join(dir.path, '${name.toLowerCase()}_mod.package'))
          .writeAsStringSync('x');
    }

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(
          ModManagerApp(registry: registry, settings: settings));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final gamma = find.text('Gamma  1');
    final alpha = find.text('Alpha  1');
    expect(tester.getCenter(alpha).dx, lessThan(tester.getCenter(gamma).dx));

    // Drag Gamma onto Alpha: Gamma takes Alpha's spot.
    final gesture = await tester.startGesture(tester.getCenter(gamma));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveTo(tester.getCenter(alpha));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 400));

    // The arrangement is persisted, and category chips are untouched
    // ('All' still first, before every folder chip).
    expect(settings.folderOrder('fake'), ['Gamma', 'Alpha', 'Beta']);
    expect(tester.getCenter(find.text('Gamma  1')).dx,
        lessThan(tester.getCenter(find.text('Alpha  1')).dx));
    expect(tester.getCenter(find.text('All  3')).dx <
        tester.getCenter(find.text('Gamma  1')).dx, isTrue);
  });

  testWidgets('menu folders reorder in place and drag out onto the line',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_ui');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    // At 1280 with the Ahem test font, one folder chip fits on the line
    // and the other two overflow into the "…" menu.
    for (final name in ['Alpha', 'Beta', 'Gamma']) {
      final dir = Directory(p.join(tempDir.path, name))..createSync();
      File(p.join(dir.path, '${name.toLowerCase()}_mod.package'))
          .writeAsStringSync('x');
    }

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(
          ModManagerApp(registry: registry, settings: settings));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('…'), findsOneWidget);
    await tester.tap(find.text('…'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    // Menu rows show the bare label; the line chips carry '  <count>'.
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Gamma'), findsOneWidget);

    // Reorder inside the menu: drop Gamma onto Beta.
    var gesture = await tester.startGesture(tester.getCenter(find.text('Gamma')));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveTo(tester.getCenter(find.text('Beta')));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 200));
    expect(settings.folderOrder('fake'), ['Alpha', 'Gamma', 'Beta']);

    // Drag Gamma out of the (still open) menu onto the line's Alpha chip.
    final lineAlpha = tester.getCenter(find.text('Alpha  1'));
    gesture = await tester.startGesture(tester.getCenter(find.text('Gamma')));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveTo(lineAlpha);
    // Extra nudge: the dismiss barrier turns hit-test-transparent on the
    // frame after the drag starts, and targets register on move events.
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveBy(const Offset(1, 0));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(settings.folderOrder('fake'), ['Gamma', 'Alpha', 'Beta']);
    // Gamma is now the folder chip on the line; the menu lists the rest.
    expect(find.text('Gamma  1'), findsOneWidget);
    expect(find.text('Gamma'), findsNothing);
    expect(find.text('Alpha'), findsOneWidget);
  });

  testWidgets('setup view recheck button finds a newly created folder',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    // The mods folder does not exist yet, so the app opens on the
    // folder-setup screen.
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_ui');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    final modsDir = Directory(p.join(tempDir.path, 'Mods'));

    final registry = GameRegistry([_FakeAdapter(modsDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(
          ModManagerApp(registry: registry, settings: settings));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Fake Game mods folder not found'), findsOneWidget);
    expect(find.text('Check again'), findsOneWidget);

    // The user creates the folder outside the app, then rechecks.
    modsDir.createSync(recursive: true);
    await tester.runAsync(() async {
      await tester.tap(find.text('Check again'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Fake Game mods folder not found'), findsNothing);
    expect(find.text('Fake Game Library'), findsOneWidget);
  });

  testWidgets('setup view distinguishes a found game with no mods folder',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    // Game folder exists, mods folder inside it does not.
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_ui');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    final modsDir = Directory(p.join(tempDir.path, 'Mods'));

    final registry =
        GameRegistry([_FakeAdapter(modsDir, gameFolder: tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(
          ModManagerApp(registry: registry, settings: settings));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Fake Game found — no mods folder yet'), findsOneWidget);
    expect(find.text('Fake Game mods folder not found'), findsNothing);
    // The detected game folder is shown so the user can trust the guess.
    expect(find.text(tempDir.path), findsOneWidget);
  });
}
