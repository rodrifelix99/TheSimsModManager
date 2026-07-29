import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/core/save_game.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app.dart';

class _FakeAdapter extends FolderBasedGameAdapter {
  _FakeAdapter(this.dir, {this.saves = const []});

  final Directory dir;
  final List<SaveGame> saves;

  /// How often the saves were (re)read, for the lazy-load assertions.
  int saveScans = 0;

  @override
  Game get game =>
      const Game(id: 'fake', name: 'Fake Game', series: 'Test', year: 2024);

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  String get setupHelpKey => 'test adapter';

  @override
  Future<String?> defaultModsPath() async => dir.path;

  /// No isolates under the widget test's fake-async zone.
  @override
  Future<Map<String, PackageInsight>> inspectMods(
    List<Mod> mods, {
    void Function(int done, int total)? onProgress,
    void Function(Map<String, PackageInsight> found)? onFound,
    bool Function()? isCancelled,
  }) async =>
      const {};

  @override
  Future<List<SaveGame>> listSaveGames() async {
    saveScans++;
    return saves;
  }
}

final _legacySave = SaveGame(
  name: 'Legacy run',
  path: r'C:\saves\Slot_00000001.save',
  modifiedAt: DateTime(2026, 7, 20, 21, 4),
  sizeBytes: 12 << 20,
  backupCount: 3,
  gameVersion: '1.125.59',
  worldsVisited: const ['Willow Creek'],
  households: const [
    SaveHousehold(
      name: 'Goth',
      funds: 45500,
      lotName: 'Ophelia Villa',
      bedrooms: 3,
      bathrooms: 2,
      members: [
        SaveSim(
          firstName: 'Bella',
          lastName: 'Goth',
          ageKey: 'adult',
          genderKey: 'female',
          skills: {'cooking': 900, 'logic': 350},
          personality: {'nice': 750},
        ),
        SaveSim(firstName: 'Alexander', lastName: 'Goth', ageKey: 'child'),
      ],
      relationships: [
        SaveRelationship(
            nameA: 'Bella Goth',
            nameB: 'Alexander Goth',
            score: 80,
            labelKeys: ['friends']),
      ],
    ),
    SaveHousehold(name: 'Landgraab', funds: 100, isPlayed: false),
  ],
);

Future<_FakeAdapter> _pumpApp(WidgetTester tester,
    {required List<SaveGame> saves}) async {
  tester.view.physicalSize = const Size(1280, 824);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({'soundEffects': false});
  final tempDir = Directory.systemTemp.createTempSync('saves_view');
  addTearDown(() => tempDir.deleteSync(recursive: true));
  File(p.join(tempDir.path, 'a_mod.package')).writeAsStringSync('bytes');

  final adapter = _FakeAdapter(tempDir, saves: saves);
  final settings = await SettingsStore.load();
  await tester.runAsync(() async {
    await tester.pumpWidget(
        ModManagerApp(registry: GameRegistry([adapter]), settings: settings));
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });
  await tester.pump(const Duration(milliseconds: 400));
  return adapter;
}

void main() {
  testWidgets('the saves screen shows households, members and stats',
      (tester) async {
    final adapter = await _pumpApp(tester, saves: [_legacySave]);

    // Nothing is read from disk until the screen is opened.
    expect(adapter.saveScans, 0);
    await tester.runAsync(() async {
      await tester.tap(find.text('Saves'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump(const Duration(milliseconds: 400));
    expect(adapter.saveScans, 1);

    // The header carries the save's own name; the households tab is up.
    expect(find.text('Legacy run'), findsOneWidget);
    expect(find.text('Goth'), findsWidgets);
    expect(find.text('§45,500'), findsWidgets);
    // The townie household sits in its own section.
    expect(find.text('Townies & other households'), findsOneWidget);
    // The detail panel lists the members with their stats.
    expect(find.text('Bella Goth'), findsWidgets);
    expect(find.text('Cooking 9'), findsOneWidget);
    expect(find.text('Nice 7'), findsOneWidget);
    // And the family bond.
    expect(find.text('Bella Goth & Alexander Goth'), findsOneWidget);
    expect(find.text('friends'), findsOneWidget);

    // No photos in this save: the album tab is not offered at all.
    expect(find.text('Photo album'), findsNothing);

    // The stats tab shows the numbers the save actually has.
    await tester.tap(find.text('World stats'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('SIMS'), findsOneWidget);
    expect(find.text('NET WORTH'), findsOneWidget);
    expect(find.text('§45,600'), findsOneWidget);
    expect(find.text('3 backups'), findsOneWidget);
    expect(find.text('Willow Creek'), findsOneWidget);
    expect(find.text('1.125.59'), findsOneWidget);
    // Life stages, counted across households.
    expect(find.text('Adult'), findsOneWidget);
    expect(find.text('Child'), findsOneWidget);
    // The bars are drawn, not just their tracks: a fill laid out loose
    // collapses to nothing and every row reads as empty.
    final fills = find.descendant(
        of: find.byType(FractionallySizedBox),
        matching: find.byType(DecoratedBox));
    expect(fills, findsWidgets);
    for (var i = 0; i < fills.evaluate().length; i++) {
      final size = tester.getSize(fills.at(i));
      expect(size.height, greaterThan(0));
      expect(size.width, greaterThan(0));
    }

    // Reopening the screen does not rescan; that is the refresh button's
    // job.
    await tester.tap(find.text('Library'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Saves'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(adapter.saveScans, 1);
  });

  testWidgets('a game without saves gets the empty state', (tester) async {
    final adapter = await _pumpApp(tester, saves: const []);

    await tester.runAsync(() async {
      await tester.tap(find.text('Saves'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('No saves found'), findsOneWidget);
    expect(find.text('Rescan saves'), findsOneWidget);

    // Rescanning asks the adapter again.
    await tester.runAsync(() async {
      await tester.tap(find.text('Rescan saves'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump(const Duration(milliseconds: 400));
    expect(adapter.saveScans, 2);
  });
}
