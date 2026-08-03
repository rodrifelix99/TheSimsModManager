import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app.dart';
import 'package:sims_mod_manager/src/ui/game_theme.dart';

import 'until.dart';

/// A game we ship artwork for, so the shell reaches for the real assets.
class _Sims4Adapter extends FolderBasedGameAdapter {
  _Sims4Adapter(this.dir);

  final Directory dir;

  @override
  Game get game => const Game(
      id: 'sims4', name: 'The Sims 4', series: 'The Sims', year: 2014);

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  String get setupHelpKey => 'setupHelpSims4';

  @override
  Future<String?> defaultModsPath() async => dir.path;

  /// Real isolates can't finish inside the fake-async zone.
  @override
  Future<Map<String, PackageInsight>> inspectMods(
    List<Mod> mods, {
    void Function(int done, int total)? onProgress,
    void Function(Map<String, PackageInsight> found)? onFound,
    bool Function()? isCancelled,
  }) async =>
      const {};
}

/// Refuses the game artwork the way a machine whose antivirus is still
/// working through a fresh install does, and hands everything else - the
/// asset manifest above all - to the real bundle.
class _ScanningBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) {
    if (key.startsWith('assets/games/')) {
      throw FlutterError('Unable to load asset: "$key".');
    }
    return rootBundle.load(key);
  }
}

void main() {
  Game game(String id) => Game(id: id, name: id, series: 'The Sims');

  test('every registered icon/logo asset exists on disk', () {
    for (final id in ['sims1', 'sims2', 'sims3', 'sims4', 'simsmedieval']) {
      final icon = GameTheme.iconAsset(game(id));
      expect(icon, isNotNull, reason: '$id has no icon');
      expect(File(icon!).existsSync(), isTrue, reason: 'missing $icon');
      for (final brightness in Brightness.values) {
        final logo = GameTheme.logoAsset(game(id), brightness);
        expect(logo, isNotNull, reason: '$id has no $brightness logo');
        expect(File(logo!).existsSync(), isTrue, reason: 'missing $logo');
      }
    }
  });

  test('the Sims 4 wordmark swaps for the dark theme', () {
    expect(GameTheme.logoAsset(game('sims4'), Brightness.dark),
        isNot(GameTheme.logoAsset(game('sims4'), Brightness.light)));
    // Everything else is one artwork that reads on either background.
    for (final id in ['sims1', 'sims2', 'sims3', 'simsmedieval']) {
      expect(GameTheme.logoAsset(game(id), Brightness.dark),
          GameTheme.logoAsset(game(id), Brightness.light));
    }
  });

  test('unknown games have no assets and fall back gracefully', () {
    expect(GameTheme.iconAsset(game('simcity4')), isNull);
    for (final brightness in Brightness.values) {
      expect(GameTheme.logoAsset(game('simcity4'), brightness), isNull);
    }
  });

  testWidgets('artwork the bundle refuses falls back instead of throwing',
      (tester) async {
    // Reported from the wild: the first launch after an install drew the
    // sidebar while the antivirus still held the freshly written files,
    // every icon failed at once, and with nothing catching them the
    // failures reached FlutterError.onError as crash reports.
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_assets');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final registry = GameRegistry([_Sims4Adapter(tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(DefaultAssetBundle(
        bundle: _ScanningBundle(),
        child: ModManagerApp(registry: registry, settings: settings),
      ));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await until(tester, find.text('The Sims 4 Library'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(tester.takeException(), isNull,
        reason: 'artwork that will load next run is not a crash report');
    // The sidebar's lettered badge and the header's text title, the same
    // answers a game we ship no artwork for gets.
    expect(find.text('4'), findsWidgets);
    expect(find.text('The Sims 4 Library'), findsOneWidget);
  });
}
