import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/creation.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app.dart';

import 'until.dart';

class _FakeAdapter extends FolderBasedGameAdapter {
  _FakeAdapter(this.dir, {this.items = const [], this.creations_ = true});

  final Directory dir;
  final List<Creation> items;
  // ignore: non_constant_identifier_names
  final bool creations_;

  /// How often the folders were read, for the lazy-load assertion.
  int scans = 0;

  /// What was asked to be deleted, so the dialog can be checked without
  /// touching a disk.
  final removed = <Creation>[];

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
  bool get hasCreations => creations_;

  @override
  Future<List<Creation>> listCreations() async {
    scans++;
    return [
      for (final item in items)
        if (!removed.contains(item)) item,
    ];
  }

  @override
  Future<void> removeCreation(Creation creation) async {
    removed.add(creation);
  }

  /// No isolates under the widget test's fake-async zone.
  @override
  Future<Map<String, PackageInsight>> inspectMods(
    List<Mod> mods, {
    void Function(int done, int total)? onProgress,
    void Function(Map<String, PackageInsight> found)? onFound,
    bool Function()? isCancelled,
  }) async =>
      const {};
}

final _house = Creation(
  name: 'Gothique Library',
  kindKey: kindLot,
  path: r'C:\library\Gothique Library.package',
  files: const [r'C:\library\Gothique Library.package'],
  sizeBytes: 3 << 20,
  modifiedAt: DateTime(2026, 7, 20),
  description: 'Built by the very first Goths that ever settled here.',
  worldName: 'Sunset Valley',
);

final _family = Creation(
  name: 'Riley',
  kindKey: kindHousehold,
  path: r'C:\tray\0x01!0xaa.trayitem',
  files: const [
    r'C:\tray\0x01!0xaa.trayitem',
    r'C:\tray\0x00!0xaa.householdbinary',
    r'C:\tray\0xb7!0xaa.hhi',
  ],
  sizeBytes: 120 << 10,
  modifiedAt: DateTime(2026, 8, 1),
  creatorName: 'anadius',
  sims: const [
    CreationSim(
      firstName: 'Connor',
      lastName: 'Riley',
      ageKey: 'youngAdult',
      genderKey: 'male',
      traits: ['Creative', 'Ambitious'],
      aspiration: 'Eco Innovator',
    ),
  ],
);

Future<_FakeAdapter> _pumpApp(
  WidgetTester tester, {
  List<Creation> items = const [],
  bool hasCreations = true,
}) async {
  tester.view.physicalSize = const Size(1280, 824);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({'soundEffects': false});
  final tempDir = Directory.systemTemp.createTempSync('creations_view');
  addTearDown(() => tempDir.deleteSync(recursive: true));
  File(p.join(tempDir.path, 'a_mod.package')).writeAsStringSync('bytes');

  final adapter = _FakeAdapter(tempDir, items: items, creations_: hasCreations);
  final settings = await SettingsStore.load();
  await tester.runAsync(() async {
    await tester.pumpWidget(
        ModManagerApp(registry: GameRegistry([adapter]), settings: settings));
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });
  await until(tester, find.text('Fake Game Library'));
  await tester.pump(const Duration(milliseconds: 400));
  return adapter;
}

Future<void> _openCreations(WidgetTester tester) async {
  await tester.runAsync(() async {
    await tester.tap(find.text('Creations'));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('the shelf lists what is installed, newest first',
      (tester) async {
    final adapter = await _pumpApp(tester, items: [_house, _family]);

    // Nothing is read from disk until the screen is opened.
    expect(adapter.scans, 0);
    await _openCreations(tester);
    expect(adapter.scans, 1);

    expect(find.text('Gothique Library'), findsOneWidget);
    expect(find.text('Riley'), findsOneWidget);
    expect(find.text('2 creations'), findsOneWidget);
  });

  testWidgets('the kind chips narrow the shelf and the way back is All',
      (tester) async {
    await _pumpApp(tester, items: [_house, _family]);
    await _openCreations(tester);

    // The chip carries its count, which is also what tells it apart from
    // the word on the card beneath it.
    await tester.tap(find.text('Household  1'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Riley'), findsOneWidget);
    expect(find.text('Gothique Library'), findsNothing);

    await tester.tap(find.text('All'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Gothique Library'), findsOneWidget);
  });

  testWidgets('a creation opens its own page with what the format gave up',
      (tester) async {
    await _pumpApp(tester, items: [_family]);
    await _openCreations(tester);

    await tester.tap(find.text('Riley'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('anadius'), findsOneWidget);
    expect(find.text('Connor Riley'), findsOneWidget);
    expect(find.text('Eco Innovator'), findsOneWidget);
    expect(find.text('Creative, Ambitious'), findsOneWidget);
    // A set is more than one file, and the page says so before Delete is
    // pressed.
    expect(find.text('3 files'), findsOneWidget);
  });

  testWidgets('deleting asks first, and says how many files go', (tester) async {
    final adapter = await _pumpApp(tester, items: [_house, _family]);
    await _openCreations(tester);
    await tester.tap(find.text('Riley'));
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Delete'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('Delete “Riley”?'), findsOneWidget);
    expect(find.text('3 files'), findsWidgets);

    // Backing out changes nothing.
    await tester.tap(find.text('Cancel'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(adapter.removed, isEmpty);

    await tester.tap(find.text('Delete'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.runAsync(() async {
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump(const Duration(milliseconds: 400));

    expect(adapter.removed.single.name, 'Riley');
    // The page it was open on goes with it, back to the shelf.
    expect(find.text('Gothique Library'), findsOneWidget);
  });

  testWidgets('an empty folder says so rather than showing nothing',
      (tester) async {
    await _pumpApp(tester, items: const []);
    await _openCreations(tester);
    expect(find.text('Nothing here yet'), findsOneWidget);
  });

  /// A game with no such folder gets no entry at all - the same split the
  /// packs screen makes between "empty" and "not a thing this game has".
  testWidgets('a game without a creations folder has no sidebar entry',
      (tester) async {
    await _pumpApp(tester, hasCreations: false);
    expect(find.text('Creations'), findsNothing);
  });
}
