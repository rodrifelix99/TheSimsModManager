// Pins kMinWindowSize: at the enforced minimum window size, every screen
// must lay out without RenderFlex overflows and the library must still
// build mod cards (a squeezed grid silently building zero items is as
// broken as an overflow). If a layout change fails this, either fix the
// layout or consciously raise kMinWindowSize in app.dart.
import 'dart:io';

import 'package:flutter/foundation.dart';
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

class _FakeAdapter extends FolderBasedGameAdapter {
  _FakeAdapter(this.dir);

  final Directory dir;

  /// Real isolates can't finish inside the fake-async test zone.
  @override
  Future<Map<String, PackageInsight>> inspectMods(
    List<Mod> mods, {
    void Function(int done, int total)? onProgress,
  }) async =>
      const {};

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
  late Directory tempDir;
  late List<String> overflows;
  late FlutterExceptionHandler? priorOnError;

  setUp(() {
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    // Sync IO only outside runAsync — see widget_test.dart.
    tempDir = Directory.systemTemp.createTempSync('mod_manager_minsize');
    File(p.join(tempDir.path, 'cozy_sofa.package')).writeAsStringSync('x');
    final sub = Directory(p.join(tempDir.path, 'CAS'))..createSync();
    File(p.join(sub.path, 'long_hair.package')).writeAsStringSync('x');

    // Overflow reports arrive via FlutterError.onError during layout;
    // collect them so one test can assert on all screens at once.
    overflows = [];
    priorOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final text = details.exceptionAsString();
      if (text.contains('overflowed')) {
        overflows.add(text.split('\n').first);
      } else {
        priorOnError?.call(details);
      }
    };
  });

  tearDown(() {
    FlutterError.onError = priorOnError;
    tempDir.deleteSync(recursive: true);
  });

  testWidgets('every screen fits the minimum window size', (tester) async {
    tester.view.physicalSize = kMinWindowSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(
          ModManagerApp(registry: registry, settings: settings));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Library: toolbar, chips, stats, and at least one real card built.
    expect(find.text('Fake Game Library'), findsOneWidget);
    expect(find.text('cozy sofa'), findsOneWidget,
        reason: 'the grid must still build cards at the minimum size');
    expect(overflows, isEmpty,
        reason: 'library overflowed at $kMinWindowSize');

    // Detail: fixed 300px left column + facts column.
    await tester.tap(find.text('cozy sofa'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Enabled'), findsWidgets);
    expect(overflows, isEmpty,
        reason: 'detail view overflowed at $kMinWindowSize');

    // Settings.
    await tester.tap(find.text('Settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(overflows, isEmpty,
        reason: 'settings overflowed at $kMinWindowSize');
  });
}
