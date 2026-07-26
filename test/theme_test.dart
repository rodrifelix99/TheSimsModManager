import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
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

class _FakeAdapter extends FolderBasedGameAdapter {
  _FakeAdapter(this.dir);

  final Directory dir;

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
  String get setupHelpKey => 'fake';

  @override
  Future<String?> defaultModsPath() async => dir.path;
}

/// WCAG relative luminance of an opaque color.
double _luminance(Color color) {
  double channel(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

/// WCAG contrast ratio: 1 for two identical colors, 21 black on white.
double _contrast(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  const gameIds = ['sims1', 'sims2', 'sims3', 'sims4', 'simsmedieval'];
  Game game(String id) => Game(id: id, name: id, series: 'The Sims');

  test('every game has a palette that reads as the brightness asked for', () {
    for (final id in [...gameIds, 'simcity4']) {
      for (final brightness in Brightness.values) {
        final t = GameTheme.forGame(game(id), brightness);
        for (final (name, color) in [
          ('bg', t.bg),
          ('surface', t.surface),
          ('surfaceAlt', t.surfaceAlt),
          ('tint', t.tint),
        ]) {
          expect(ThemeData.estimateBrightnessForColor(color), brightness,
              reason: '$id $brightness $name is the wrong brightness');
        }
      }
    }
  });

  test('light and dark palettes differ for every game', () {
    for (final id in gameIds) {
      final light = GameTheme.forGame(game(id), Brightness.light);
      final dark = GameTheme.forGame(game(id), Brightness.dark);
      expect(dark.bg, isNot(light.bg), reason: '$id shares a background');
      expect(dark.text, isNot(light.text), reason: '$id shares a text color');
      expect(dark.accent, isNot(light.accent), reason: '$id shares an accent');
    }
  });

  // Body text clears WCAG AA (4.5) everywhere; the muted secondary text
  // is held to the 3.0 large-text bar. This is what a too-timid dark
  // palette fails first.
  test('text stays legible on its own background', () {
    for (final id in gameIds) {
      for (final brightness in Brightness.values) {
        final t = GameTheme.forGame(game(id), brightness);
        expect(_contrast(t.text, t.bg), greaterThan(4.5),
            reason: '$id $brightness text on bg');
        expect(_contrast(t.text, t.surface), greaterThan(4.5),
            reason: '$id $brightness text on surface');
        expect(_contrast(t.muted, t.surface), greaterThan(3.0),
            reason: '$id $brightness muted on surface');
      }
    }
  });

  // An accent both labels the surfaces it sits on and gets filled behind
  // white text (the Install button, the active chips) - and those are the
  // same contrast pair read from either side, so one bar covers both.
  // 3.0 is the WCAG figure for large text and UI components.
  test('accents stand clear of every surface they touch', () {
    for (final id in gameIds) {
      for (final brightness in Brightness.values) {
        final t = GameTheme.forGame(game(id), brightness);
        for (final (name, behind) in [
          ('bg', t.bg),
          ('surface', t.surface),
          ('tint', t.tint),
        ]) {
          expect(_contrast(t.accent, behind), greaterThan(3.0),
              reason: '$id $brightness accent on $name');
        }
      }
    }
  });

  // The warning pair is shared across games but split by brightness; the
  // panel text sits on the warning tint over a surface, the badge fill
  // reads as a UI component (3.0).
  test('the warning colors read on every surface they touch', () {
    for (final id in gameIds) {
      for (final brightness in Brightness.values) {
        final t = GameTheme.forGame(game(id), brightness);
        expect(_contrast(t.onWarningTint, t.surface), greaterThan(4.5),
            reason: '$id $brightness warning text on surface');
        expect(_contrast(t.warning, t.surface), greaterThan(3.0),
            reason: '$id $brightness warning on surface');
        expect(_contrast(t.warning, t.bg), greaterThan(3.0),
            reason: '$id $brightness warning on bg');
      }
    }
  });

  test('a game with no palette borrows one and keeps its own era label', () {
    for (final brightness in Brightness.values) {
      final fallback = GameTheme.forGame(game('simcity4'), brightness);
      expect(fallback.bg, GameTheme.forGame(game('sims4'), brightness).bg);
      expect(fallback.eraKey, isNull);
      expect(fallback.eraDetail, isNull);
    }
  });

  Future<SettingsStore> prefs(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues({'soundEffects': false, ...values});
    return SettingsStore.load();
  }

  // The app follows the desktop unless Settings says otherwise; both
  // paths end at the same place, the Scaffold painted in the palette.
  for (final probe in <({
    String name,
    Map<String, Object> prefs,
    Brightness system,
    Brightness want
  })>[
    (
      name: 'no preference on a light desktop stays light',
      prefs: {},
      system: Brightness.light,
      want: Brightness.light
    ),
    (
      name: 'no preference on a dark desktop goes dark',
      prefs: {},
      system: Brightness.dark,
      want: Brightness.dark
    ),
    (
      name: 'a saved dark theme wins over a light desktop',
      prefs: {'themeMode': 'dark'},
      system: Brightness.light,
      want: Brightness.dark
    ),
    (
      name: 'a saved light theme wins over a dark desktop',
      prefs: {'themeMode': 'light'},
      system: Brightness.dark,
      want: Brightness.light
    ),
  ]) {
    testWidgets(probe.name, (tester) async {
      tester.view.physicalSize = const Size(1280, 824);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.platformBrightnessTestValue = probe.system;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

      final tempDir = Directory.systemTemp.createTempSync('mod_manager_theme');
      addTearDown(() => tempDir.deleteSync(recursive: true));
      File('${tempDir.path}/cozy_sofa.package').writeAsStringSync('sofa');

      final settings = await prefs(probe.prefs);
      final registry = GameRegistry([_FakeAdapter(tempDir)]);
      await tester.runAsync(() async {
        await tester.pumpWidget(
            ModManagerApp(registry: registry, settings: settings));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor,
          GameTheme.forGame(_FakeAdapter(tempDir).game, probe.want).bg);
    });
  }
}
