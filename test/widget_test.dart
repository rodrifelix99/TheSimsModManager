import 'dart:io';
import 'dart:ui' show Size;

import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart' show EditableText, Text;
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
import 'package:sims_mod_manager/src/ui/widgets.dart';

import 'until.dart';

class _FakeAdapter extends FolderBasedGameAdapter {
  _FakeAdapter(this.dir, {this.gameFolder, this.lockRename = false});

  final Directory dir;

  /// Simulates the game's own folder being detected (mods dir missing).
  final Directory? gameFolder;

  /// Simulates the game holding the file open, the way Windows reports
  /// it: the rename behind every enable/disable fails.
  final bool lockRename;

  @override
  Duration get lockedFileRetryDelay => Duration.zero;

  @override
  Future<File> renameModFile(File file, String newPath) {
    if (lockRename) {
      throw PathAccessException(
          file.path, const OSError('file in use', 32), 'Cannot rename file');
    }
    return super.renameModFile(file, newPath);
  }

  @override
  Future<Directory?> findGameFolder() async => gameFolder;

  /// The real implementation reads files in [Isolate]s: threads the
  /// widget test's fake-async zone can't wait on, whose open handles make
  /// Windows fail the toggle rename and the temp-dir teardown delete.
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

/// Pumps the app and waits for the library to arrive, rather than for a
/// round number of milliseconds: loading one is real IO on a real disk, and
/// a wait that is generous when this test runs alone is a coin toss when
/// the rest of the suite runs beside it on a CI runner.
///
/// The delay inside runAsync is the head start rather than the guarantee -
/// boot wants a stretch of real time with nothing pumping the fake clock
/// underneath it - and [ready] is what says the machine is actually done:
/// the library's own header for most tests, a setup screen's headline for
/// the two games that have no mods folder.
Future<void> _pump(
  WidgetTester tester,
  GameRegistry registry,
  SettingsStore settings, {
  Finder? ready,
}) async {
  await tester.runAsync(() async {
    await tester
        .pumpWidget(ModManagerApp(registry: registry, settings: settings));
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });
  await until(tester, ready ?? find.text('Fake Game Library'));
  await tester.pump(const Duration(milliseconds: 400));
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

    await _pump(tester, registry, settings);

    expect(find.text('Fake Game Library'), findsOneWidget);
    // Display title is the humanized file name.
    expect(find.text('cozy sofa'), findsOneWidget);

    // Disable it via the card switch: the file gets the .disabled marker.
    final disabled =
        File(p.join(tempDir.path, 'cozy_sofa.package$disabledSuffix'));
    await tester.tap(find.byType(PillSwitch).first);
    await untilExists(tester, disabled);
    await tester.pump(const Duration(milliseconds: 400));

    expect(disabled.existsSync(), isTrue);
  });

  testWidgets('the refresh button picks up a mod copied in behind our back',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_reload');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    File(p.join(tempDir.path, 'cozy_sofa.package'))
        .writeAsStringSync('sofa bytes');

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await _pump(tester, registry, settings);

    // What the file manager does while the app is looking the other way.
    File(p.join(tempDir.path, 'retro_lamp.package'))
        .writeAsStringSync('lamp bytes');
    expect(find.text('retro lamp'), findsNothing);

    await tester.tap(find.byTooltip('Refresh'));
    await until(tester, find.text('retro lamp'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('retro lamp'), findsOneWidget);
    expect(find.text('cozy sofa'), findsOneWidget);
  });

  testWidgets('a failed action is named in the shell banner and dismissed',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_ui');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    File(p.join(tempDir.path, 'cozy_sofa.package')).writeAsStringSync('sofa');

    final registry = GameRegistry([_FakeAdapter(tempDir, lockRename: true)]);
    final settings = await SettingsStore.load();

    await _pump(tester, registry, settings);

    // The banner says which file and why, translated from the key the
    // core layer raised - not the raw exception, and not silence.
    final banner = find.textContaining('in use by another program');
    await tester.tap(find.byType(PillSwitch).first);
    await until(tester, banner);
    await tester.pump(const Duration(milliseconds: 400));

    expect(banner, findsOneWidget);
    expect(find.textContaining('cozy_sofa.package'), findsWidgets);

    // It lives in the shell, so it follows the user off the library.
    await tester.tap(find.text('cozy sofa'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(banner, findsOneWidget);

    await tester.tap(find.byTooltip('Dismiss'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(banner, findsNothing);
  });

  testWidgets('conflicts stat filters the library and detail names the clash',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_ui');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    // The same file name in two subfolders; the duplicate-name heuristic
    // flags both. A third mod is clean.
    for (final sub in ['A', 'B']) {
      Directory(p.join(tempDir.path, sub)).createSync();
      File(p.join(tempDir.path, sub, 'lamp.package')).writeAsStringSync('x');
    }
    File(p.join(tempDir.path, 'unique.package')).writeAsStringSync('x');

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await _pump(tester, registry, settings, ready: find.text('CONFLICTS'));

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
    // which card opened; mods sharing a name have no guaranteed order).
    final row = find.byWidgetPredicate((w) =>
        w is Text &&
        (w.data == p.join('A', 'lamp.package') ||
            w.data == p.join('B', 'lamp.package')));
    expect(row, findsOneWidget);

    // Settling the clash takes the whole warning with it - it was this
    // mod's only one - and leaves the way back on the mod's own page.
    await tester.tap(find.text('Ignore'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(
        find.text('Another enabled mod has the same file name:'), findsNothing);
    expect(find.text('IGNORED'), findsOneWidget);
    expect(find.text('1 conflict'), findsOneWidget);

    // And the library stops flagging either of them. The back button is
    // the arrow: the sidebar nav says "Library" too.
    await tester.tap(find.text('←'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('conflict'), findsNothing);

    // The other copy carries the way back too, wherever the cap put the
    // pair: both mods were told to keep the same clash quiet.
    await tester.tap(find.text('lamp').first);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Bring back'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Another enabled mod has the same file name:'),
        findsOneWidget);
    expect(find.text('IGNORED'), findsNothing);
  });

  testWidgets('the other three stats filter the library too', (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_ui');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    File(p.join(tempDir.path, 'lamp.package')).writeAsStringSync('x');
    File(p.join(tempDir.path, 'sofa.package.disabled')).writeAsStringSync('x');

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await _pump(tester, registry, settings, ready: find.text('lamp'));

    expect(find.text('lamp'), findsOneWidget);
    expect(find.text('sofa'), findsOneWidget);

    await tester.tap(find.text('ENABLED'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('lamp'), findsOneWidget);
    expect(find.text('sofa'), findsNothing);

    // The two are one filter, so Disabled takes over rather than adding.
    await tester.tap(find.text('DISABLED'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('lamp'), findsNothing);
    expect(find.text('sofa'), findsOneWidget);

    // And Total is the way out of it.
    await tester.tap(find.text('TOTAL'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('lamp'), findsOneWidget);
    expect(find.text('sofa'), findsOneWidget);
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

    // The subfolder shows up as a chip (label + count in one span);
    // filtering hides the root mod.
    final casChip = find.text('CAS  2');
    await _pump(tester, registry, settings, ready: casChip);
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

    // Overflowing chips stay in the tree but unpainted; the visible sign
    // of overflow is the "…" button at the end of the line, which only
    // appears once the folders have been read and the row has measured
    // what fits.
    await _pump(tester, registry, settings, ready: find.text('…'));

    expect(find.text('…'), findsOneWidget);

    // A hidden folder lives in the popup menu and still filters. Folder
    // "11" sorts near the top lexicographically, so its row is inside
    // the menu's scroll viewport. (Fixed pumps, not pumpAndSettle,
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

    final gamma = find.text('Gamma  1');
    final alpha = find.text('Alpha  1');
    await _pump(tester, registry, settings, ready: alpha);
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

  testWidgets('the folder view gathers mods under a header each',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(
        {'soundEffects': false, 'libraryLayout': 'folders'});
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_ui');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    File(p.join(tempDir.path, 'loose_mod.package')).writeAsStringSync('x');
    for (final name in ['Alpha', 'Beta']) {
      final dir = Directory(p.join(tempDir.path, name))..createSync();
      File(p.join(dir.path, '${name.toLowerCase()}_mod.package'))
          .writeAsStringSync('x');
    }

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    // A header per section, the mods folder itself above the subfolders.
    // The chips carry their count in the same string ('Alpha  1'), so
    // these bare labels are the headers.
    await _pump(tester, registry, settings, ready: find.text('Mods folder'));

    expect(find.text('Mods folder'), findsOneWidget);
    expect(find.text('Alpha'), findsOneWidget);
    expect(tester.getCenter(find.text('Mods folder')).dy,
        lessThan(tester.getCenter(find.text('Alpha')).dy));
    // A list row draws its title as Text.rich (the extension rides along
    // in a quieter span), so the title only matches through rich text.
    Finder row(String title) =>
        find.textContaining(title, findRichText: true);
    expect(row('loose mod'), findsOneWidget);
    expect(row('alpha mod'), findsOneWidget);

    // Rolling one up hides its mods and leaves the others alone.
    await tester.tap(find.text('Alpha'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(row('alpha mod'), findsNothing);
    expect(find.text('Alpha'), findsOneWidget);
    expect(row('beta mod'), findsOneWidget);
    expect(row('loose mod'), findsOneWidget);
    expect(settings.collapsedFolders('fake'), ['Alpha']);
  });

  testWidgets('a mod dragged onto a folder header moves into it',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(
        {'soundEffects': false, 'libraryLayout': 'folders'});
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_ui');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    File(p.join(tempDir.path, 'loose_mod.package')).writeAsStringSync('x');
    final alpha = Directory(p.join(tempDir.path, 'Alpha'))..createSync();
    File(p.join(alpha.path, 'alpha_mod.package')).writeAsStringSync('x');

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    final row = find.textContaining('loose mod', findRichText: true);
    await _pump(tester, registry, settings, ready: row);
    final gesture = await tester.startGesture(tester.getCenter(row));
    await tester.pump(const Duration(milliseconds: 100));
    // Sideways first, on purpose: a mod is only picked up by a horizontal
    // drag, so that dragging up or down still scrolls the shelf.
    await gesture.moveBy(const Offset(60, 0));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveTo(tester.getCenter(find.text('Alpha')));
    await tester.pump(const Duration(milliseconds: 100));
    // The drop renames a real file, which needs both real time to happen
    // and frames to be drawn.
    await gesture.up();
    final moved = File(p.join(alpha.path, 'loose_mod.package'));
    await untilExists(tester, moved);

    // The file has landed, but the library is told about it a moment
    // later: the rename's completion reaches the app on the event loop,
    // which only runs outside the fake-async zone.
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(moved.existsSync(), isTrue);
    expect(File(p.join(tempDir.path, 'loose_mod.package')).existsSync(),
        isFalse);
    // The mods folder's own section has nothing left in it, so it goes.
    expect(find.text('Mods folder'), findsNothing);
  });

  testWidgets('the selection bar files mods into a folder it just made',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_ui');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    File(p.join(tempDir.path, 'cozy_sofa.package')).writeAsStringSync('x');

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await _pump(tester, registry, settings, ready: find.text('cozy sofa'));

    // Ctrl-click ticks the mod, which brings the selection bar up in the
    // stats row's place.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.tap(find.text('cozy sofa'));
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Total'), findsNothing);
    expect(find.text('1 selected · 1 B'), findsOneWidget);

    // Its buttons are icons, so the tooltip is what names them.
    await tester.tap(find.byTooltip('Move to…'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Move 1 mod where?'), findsOneWidget);

    // Make a folder from inside the dialog; it becomes the destination.
    await tester.tap(find.text('New folder'));
    await tester.pump();
    await tester.enterText(find.byType(EditableText).last, 'CC');
    await tester.tap(find.text('Create'));
    final made = Directory(p.join(tempDir.path, 'CC'));
    await untilExists(tester, made);
    // Same again: the folder is on disk before the dialog has been told.
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(made.existsSync(), isTrue);
    // The new folder is in the list, and is what Move will use.
    expect(find.text('CC'), findsOneWidget);

    // The move needs both to make progress: frames for the dialog route to
    // close, and real time for the rename underneath it.
    await tester.tap(find.text('Move'));
    final moved = File(p.join(tempDir.path, 'CC', 'cozy_sofa.package'));
    await untilExists(tester, moved);

    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(moved.existsSync(), isTrue);
    // The tick followed the file, so the bar is still up and still says
    // one - a selection is kept by the name a mod carries, and that is
    // exactly what a move changes.
    expect(find.text('1 selected · 1 B'), findsOneWidget);
  });

  testWidgets('menu folders reorder in place and drag out onto the line',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_ui');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    // Names this long so the line can only hold one of them whatever
    // else is on it: with the Ahem test font every glyph is full width,
    // and the other two are pushed into the "…" menu, which is what this
    // test is about.
    const alpha = 'Alpha custom content';
    const beta = 'Beta custom content';
    const gamma = 'Gamma custom content';
    for (final name in [alpha, beta, gamma]) {
      final dir = Directory(p.join(tempDir.path, name))..createSync();
      File(p.join(dir.path, '${name.split(' ').first.toLowerCase()}.package'))
          .writeAsStringSync('x');
    }

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    // The overflow button only exists once the three folders have been
    // read off the disk and the row has measured what fits, so wait for
    // the button itself rather than for the library's header.
    await _pump(tester, registry, settings, ready: find.text('…'));

    expect(find.text('…'), findsOneWidget);
    await tester.tap(find.text('…'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    // Menu rows show the bare label; the line chips carry '  <count>'.
    // Which is also how the layout this test needs is pinned: Alpha on
    // the line, the other two in the menu.
    expect(find.text(beta), findsOneWidget);
    expect(find.text(gamma), findsOneWidget);
    expect(find.text(alpha), findsNothing);

    // Reorder inside the menu: drop Gamma onto Beta.
    var gesture = await tester.startGesture(tester.getCenter(find.text(gamma)));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.moveTo(tester.getCenter(find.text(beta)));
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pump(const Duration(milliseconds: 200));
    expect(settings.folderOrder('fake'), [alpha, gamma, beta]);

    // Drag Gamma out of the (still open) menu onto the line's Alpha chip.
    final lineAlpha = tester.getCenter(find.text('$alpha  1'));
    gesture = await tester.startGesture(tester.getCenter(find.text(gamma)));
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

    expect(settings.folderOrder('fake'), [gamma, alpha, beta]);
    // Gamma is now the folder chip on the line; the menu lists the rest.
    expect(find.text('$gamma  1'), findsOneWidget);
    expect(find.text(gamma), findsNothing);
    expect(find.text(alpha), findsOneWidget);
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

    await _pump(tester, registry, settings,
        ready: find.text('Fake Game mods folder not found'));

    expect(find.text('Fake Game mods folder not found'), findsOneWidget);
    expect(find.text('Check again'), findsOneWidget);

    // The user creates the folder outside the app, then rechecks.
    modsDir.createSync(recursive: true);
    await tester.tap(find.text('Check again'));
    await until(tester, find.text('Fake Game Library'));

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

    await _pump(tester, registry, settings,
        ready: find.text('Fake Game found, but no mods folder yet'));

    expect(find.text('Fake Game found, but no mods folder yet'), findsOneWidget);
    expect(find.text('Fake Game mods folder not found'), findsNothing);
    // The detected game folder is shown so the user can trust the guess.
    expect(find.text(tempDir.path), findsOneWidget);
  });

  testWidgets('an advisory banners the library, filters it and explains itself',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // The cache stands in for a download that already happened; fetchedAt
    // is now so the controller doesn't go looking for a fresher one.
    SharedPreferences.setMockInitialValues({
      'soundEffects': false,
      'advisories.cache': '{"version": 1, "games": {"fake": [{'
          '"id": "cozy-sofa", "title": "Cozy Sofa", "status": "broken", '
          '"since": "the 24 July 2026 patch", '
          '"identities": ["cozy sofa.package"]}]}}',
      'advisories.fetchedAt': DateTime.now().millisecondsSinceEpoch,
    });
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_advice');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    File(p.join(tempDir.path, 'cozy_sofa.package')).writeAsStringSync('sofa');
    File(p.join(tempDir.path, 'tidy_lamp.package')).writeAsStringSync('lamp');

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await _pump(tester, registry, settings,
        ready: find.text('One of your mods has a known issue'));

    expect(find.text('One of your mods has a known issue'), findsOneWidget);
    expect(find.text('tidy lamp'), findsOneWidget);

    // The banner's button is the filter: only the flagged mod survives it.
    await tester.tap(find.text('Take a look'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('cozy sofa'), findsOneWidget);
    expect(find.text('tidy lamp'), findsNothing);
    expect(find.text('Show all mods'), findsOneWidget);

    await tester.tap(find.text('cozy sofa'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('This mod is reported broken'), findsOneWidget);
    // The published title and date, and the reminder of where it came from.
    expect(find.text('Cozy Sofa · Since the 24 July 2026 patch'),
        findsOneWidget);
    expect(find.text('Reported by other players, not by the game.'),
        findsOneWidget);

    // Disabling the culprit is the way out of the warning, and the count
    // has to follow. Toggling updates the library in place rather than
    // reloading it, which is exactly where the banner used to go on
    // counting a mod that had already dropped out of the list.
    // The detail's switch is inside an IgnorePointer; the row around it
    // is what carries the tap.
    final warning = find.text('This mod is reported broken');
    await tester.tap(find.text('Enabled'));
    await untilGone(tester, warning);
    await tester.pump(const Duration(milliseconds: 400));

    expect(warning, findsNothing);
    // Both the sidebar nav and the detail's back button say "Library".
    await tester.tap(find.text('Library').last);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('One of your mods has a known issue'), findsNothing);
    expect(find.text('tidy lamp'), findsOneWidget);
  });

  /// Issue #5: Windows refuses a drag from Explorer to an elevated window,
  /// and there is no way to make it stop refusing, so the library says so
  /// instead of leaving a window that ignores every file dropped on it.
  /// Injected rather than detected, because a test runner is not elevated
  /// and that is the only case worth covering.
  group('running as administrator', () {
    Future<void> pumpLibrary(WidgetTester tester,
        {required bool elevated}) async {
      tester.view.physicalSize = const Size(1280, 824);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({'soundEffects': false});
      final tempDir = Directory.systemTemp.createTempSync('mod_manager_admin');
      addTearDown(() => tempDir.deleteSync(recursive: true));
      File(p.join(tempDir.path, 'cozy_sofa.package')).writeAsStringSync('sofa');

      final registry = GameRegistry([_FakeAdapter(tempDir)]);
      final settings = await SettingsStore.load();
      await tester.runAsync(() async {
        await tester.pumpWidget(ModManagerApp(
            registry: registry,
            settings: settings,
            checkElevated: () async => elevated));
      });
      // Wait for the library itself, so the absence asserted below is the
      // banner missing rather than the library not having arrived yet.
      await until(tester, find.text('Fake Game Library'));
      await tester.pump(const Duration(milliseconds: 400));
    }

    testWidgets('the library says drag and drop is off, and why',
        (tester) async {
      await pumpLibrary(tester, elevated: true);

      expect(find.textContaining('running as administrator'), findsOneWidget);
      // Points at the way in that still works rather than just complaining.
      expect(find.textContaining('Install button'), findsOneWidget);
    });

    testWidgets('an ordinary run says nothing', (tester) async {
      await pumpLibrary(tester, elevated: false);

      expect(find.textContaining('running as administrator'), findsNothing);
    });
  });

  testWidgets('the sort menu sinks the disabled mods to the bottom',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_sort_ui');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    // Named so that the switched-off one leads the library while the
    // order is alphabetical, and has to move to prove anything.
    File(p.join(tempDir.path, 'aaa.package$disabledSuffix'))
        .writeAsStringSync('bytes');
    File(p.join(tempDir.path, 'zzz.package')).writeAsStringSync('bytes');

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();
    await _pump(tester, registry, settings, ready: find.text('aaa'));

    double reading(String title) => tester.getTopLeft(find.text(title)).dx;
    expect(reading('aaa'), lessThan(reading('zzz')));

    // Frames rather than one long pump: the menu route ignores pointers
    // until its own animation reports itself finished, which takes a
    // frame after the clock says it should have.
    Future<void> frames() async {
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await tester.tap(find.byTooltip('Sort'));
    await frames();
    await tester.tap(find.text('Disabled ones last'));
    await frames();

    expect(reading('zzz'), lessThan(reading('aaa')));
  });
}
