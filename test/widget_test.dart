import 'dart:io';
import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app.dart';
import 'package:sims_mod_manager/src/ui/widgets.dart';

class _FakeAdapter extends FolderBasedGameAdapter {
  _FakeAdapter(this.dir);

  final Directory dir;

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
}
