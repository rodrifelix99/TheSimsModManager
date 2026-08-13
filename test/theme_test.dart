import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

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
import 'package:sims_mod_manager/src/ui/game_skin.dart';
import 'package:sims_mod_manager/src/ui/game_theme.dart';

import 'until.dart';

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

  test('only the games with a skin of their own wear one', () {
    const skins = {
      'sims1': Sims1Skin,
      'sims2': Sims2Skin,
      'sims3': Sims3Skin,
      'simsmedieval': SimsMedievalSkin,
    };
    for (final id in gameIds) {
      final skin = GameTheme.forGame(game(id), Brightness.light).skin;
      expect(skin.runtimeType, skins[id] ?? FlatSkin,
          reason: '$id wears the wrong skin');
    }
    // A game that borrows the Sims 4 palette must not borrow its chrome
    // along with it, and a skin is per id rather than per palette so it
    // doesn't.
    expect(GameTheme.forGame(game('simcity4'), Brightness.dark).skin,
        isA<FlatSkin>());
  });

  // Every raised control in a hand-painted skin is a coloured plate with
  // a word across it, in a light theme as much as a dark one. The word is
  // what has to survive whatever colour a call site brings, and
  // `bearsLabel` is what makes sure of it. Which word - white on the
  // three skins whose plates are dark, brown ink on the Medieval's
  // parchment - is the skin's own answer, so the test asks rather than
  // assuming: `ink` is the public form of exactly that question.
  /// The flat skin fills two of its surfaces with the accent, and until
  /// this test reached it the label on them was assumed to be white. The
  /// Sims 4's mint is bright enough that white measured 1.92 on the
  /// primary button, on a lit chip and on the detail panel's enable slab.
  /// It is the only game wearing this skin, so nothing else was affected
  /// and nothing else was watching.
  test('a label reads on the flat skin too', () {
    for (final brightness in Brightness.values) {
      final t = GameTheme.forGame(game('sims4'), brightness);
      expect(t.skin, isA<FlatSkin>());
      for (final (name, surface, decoration) in [
        ('primary', SkinSurface.primary,
            t.skin.decorate(t, SkinSurface.primary)),
        ('chip on', SkinSurface.chip,
            t.skin.decorate(t, SkinSurface.chip, state: SkinState.active)),
      ]) {
        final label = t.skin.ink(t, surface, state: SkinState.active);
        final stops = (decoration.gradient as LinearGradient?)?.colors ??
            [decoration.color!];
        for (final stop in stops) {
          expect(_contrast(label, stop), greaterThan(3.0),
              reason: 'sims4 $brightness label on $name');
        }
      }
      // The slab the detail panel fills itself, both ways round. The ink
      // is white there like every other loud control, so it is the plate
      // that has to move.
      for (final fill in [t.accent, t.switchOff]) {
        expect(_contrast(Colors.white, bearsWhite(fill)), greaterThan(3.0),
            reason: 'sims4 $brightness white on a filled slab');
      }
    }
  });

  test('a label reads on every raised plate', () {
    for (final (id, brightness) in [
      for (final id in ['sims1', 'sims2', 'sims3', 'simsmedieval'])
        for (final b in Brightness.values) (id, b)
    ]) {
      final t = GameTheme.forGame(game(id), brightness);
      for (final (name, surface, decoration) in [
        ('button', SkinSurface.button, t.skin.decorate(t, SkinSurface.button)),
        ('button on', SkinSurface.button,
            t.skin.decorate(t, SkinSurface.button, state: SkinState.active)),
        // The colours a call site brings: the warning orange on an
        // uninstall button, the accent on an enabled mod's slab. Both are
        // the material rather than the label, so both have to hold one.
        ('button warning', SkinSurface.button,
            t.skin.decorate(t, SkinSurface.button, accent: t.warning)),
        ('primary', SkinSurface.primary,
            t.skin.decorate(t, SkinSurface.primary)),
        ('primary warning', SkinSurface.primary,
            t.skin.decorate(t, SkinSurface.primary, accent: t.warning)),
        ('chip', SkinSurface.chip, t.skin.decorate(t, SkinSurface.chip)),
        ('chip on', SkinSurface.chip,
            t.skin.decorate(t, SkinSurface.chip, state: SkinState.active)),
        ('row on', SkinSurface.row,
            t.skin.decorate(t, SkinSurface.row, state: SkinState.active)),
        ('row filled', SkinSurface.row,
            t.skin.decorate(t, SkinSurface.row,
                state: SkinState.active, fill: t.accent)),
        ('row off', SkinSurface.row,
            t.skin.decorate(t, SkinSurface.row,
                state: SkinState.active, fill: t.switchOff)),
        // A segment raised out of a track says so by asking for the
        // panel colour, which a skin reads as "on" and answers with its
        // lit plate. It was missing here, and the saves tab strip drew
        // its label in the accent on top of it - 1.02 against the plate
        // on the Sims 3 in daylight, which is the same colour twice.
        ('row selected', SkinSurface.row,
            t.skin.decorate(t, SkinSurface.row,
                state: SkinState.active, fill: t.surface)),
      ]) {
        final label = t.skin.ink(t, surface, state: SkinState.active);
        // The label ends up on top of any texture, not on top of the
        // gradient, so the check has to see what the user does.
        final grain = (t.skin as PlateSkin).grainOf(t, surface);
        // Every stop but the first: the top of a plate is a highlight
        // along its edge that no word crosses, and it is the one stop a
        // pale label is allowed to lose against. A dark label's own
        // extreme is the bottom stop, which is checked - that is what
        // `faceShadowroom` is for.
        final stops = (decoration.gradient! as LinearGradient).colors.skip(1);
        for (final stop in stops) {
          final under = grain?.over(stop) ?? stop;
          expect(_contrast(label, under), greaterThan(3.0),
              reason: '$id $brightness label on $name');
        }
      }
    }
  });

  // Both of the ways a flat call site says "nothing here" used to poison
  // the gloss: `Colors.transparent` (a flat outline button's background)
  // made every stop a wash of black over whatever was behind, and a
  // tenth-alpha tint came out a different strength at the top of the
  // window than at the bottom. A bevel is four shades of one *opaque*
  // colour, and nothing a call site passes may change that.
  test('a plate gradient is opaque whatever fill it was handed', () {
    for (final (id, brightness) in [
      for (final id in ['sims1', 'sims2', 'sims3', 'simsmedieval'])
        for (final b in Brightness.values) (id, b)
    ]) {
      final t = GameTheme.forGame(game(id), brightness);
      for (final fill in [
        Colors.transparent,
        t.warning.withValues(alpha: .08),
        t.tint,
      ]) {
        for (final surface in SkinSurface.values) {
          final gradient = t.skin
              .decorate(t, surface, state: SkinState.active, fill: fill)
              .gradient;
          for (final color in (gradient! as LinearGradient).colors) {
            expect(color.a, 1.0,
                reason: '$id $brightness $surface with $fill translucent');
          }
        }
      }
    }
  });

  // A skin carries the colour its texture averages to, because nothing
  // in the app can decode an image and that mean is what `bearsLabel`
  // reasons about. Here is the one place that *can* decode it: swap the
  // asset for a different picture and the declared mean stops matching,
  // which is the whole safety of laying grain over a plate at all.
  testWidgets('a declared grain mean matches the asset it names',
      (tester) async {
    final t = GameTheme.forGame(game('simsmedieval'), Brightness.dark);
    final grain =
        (t.skin as PlateSkin).grainOf(t, SkinSurface.button)!;

    late final Color measured;
    await tester.runAsync(() async {
      final bytes = File(grain.asset).readAsBytesSync();
      final codec = await ui.instantiateImageCodec(bytes,
          targetWidth: 64, targetHeight: 64);
      final frame = await codec.getNextFrame();
      final data =
          await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
      var r = 0, g = 0, b = 0, n = 0;
      for (var i = 0; i + 3 < data!.lengthInBytes; i += 4) {
        r += data.getUint8(i);
        g += data.getUint8(i + 1);
        b += data.getUint8(i + 2);
        n++;
      }
      measured = Color.fromARGB(255, r ~/ n, g ~/ n, b ~/ n);
    });

    // Loosely: the mean is a stand-in for a whole photograph and the
    // decode is resampled, so what matters is that it is still the same
    // picture rather than that it is exact to the byte.
    expect(_contrast(measured, grain.mean), lessThan(1.2),
        reason: 'the declared mean is no longer what the asset averages to');
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
      await until(tester, find.text('Fake Game Library'));
      await tester.pump(const Duration(milliseconds: 400));

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor,
          GameTheme.forGame(_FakeAdapter(tempDir).game, probe.want).bg);
    });
  }
}
