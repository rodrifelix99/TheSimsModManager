import 'dart:io';
import 'dart:typed_data' show ByteData, Endian;
import 'dart:ui' show Locale, Size;

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/widgets.dart' show GestureDetector;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app.dart';
import 'package:sims_mod_manager/src/ui/intro_video.dart';
import 'package:sims_mod_manager/src/ui/l10n.dart';

import 'until.dart';

/// A game the walkthrough can find. Nothing here reads the disk beyond
/// the folder it is handed, and the artwork scan is stubbed out for the
/// same reason every other widget test stubs it: real isolates can't
/// finish inside the fake-async zone.
class _FakeAdapter extends FolderBasedGameAdapter {
  _FakeAdapter(this.dir, {this.id = 'fake', this.title = 'Fake Game'});

  final Directory? dir;
  final String id;
  final String title;

  @override
  Future<Map<String, PackageInsight>> inspectMods(
    List<Mod> mods, {
    void Function(int done, int total)? onProgress,
    void Function(Map<String, PackageInsight> found)? onFound,
    bool Function()? isCancelled,
  }) async =>
      const {};

  @override
  Game get game => Game(id: id, name: title, series: 'Test', year: 2024);

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  String get setupHelpKey => 'test adapter';

  @override
  Future<String?> defaultModsPath() async => dir?.path;
}

/// Pumps the app on a machine that has never run it, and waits for the
/// walkthrough's first page.
Future<void> _pumpFirstRun(
  WidgetTester tester,
  GameRegistry registry,
  SettingsStore settings,
  L strings,
) async {
  await tester.runAsync(() async {
    await tester
        .pumpWidget(ModManagerApp(registry: registry, settings: settings));
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });
  await until(tester, find.text(strings.onboardingWelcomeTitle));
  await tester.pump(const Duration(milliseconds: 700));
}

/// Presses Next and lets the page change land. The games page holds the
/// button until the launch scan has answered, so this waits for the
/// button to actually do something rather than assuming it did.
Future<void> _next(WidgetTester tester, L strings) async {
  await until(tester, find.text(strings.onboardingNext));
  await tester.tap(find.text(strings.onboardingNext));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 700));
}

/// The film is the one thing here `flutter test` never plays - it is ten
/// seconds long and the suite pumps the app in a fake clock - so what it
/// is made of is checked rather than watched. A re-encode that answered
/// with an error page, a still where the animation should be, or a file
/// renamed out from under the constant would all pass every other test
/// in this file.
void _pinsTheFilm() {
  test('the film and its last frame are shipped, and are what they claim',
      () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('assets/intro/'),
        reason: 'the folder is declared, or the app cannot read either');

    for (final asset in [introAsset, introStillAsset]) {
      final file = File(asset);
      expect(file.existsSync(), isTrue, reason: '$asset is missing');
      final bytes = file.readAsBytesSync();
      expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF',
          reason: '$asset is not a RIFF container');
      expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WEBP',
          reason: '$asset is not a WebP');
      // The declared length has to agree with the file, which is what a
      // download that stopped early looks like.
      final declared = ByteData.sublistView(bytes, 4, 8)
          .getUint32(0, Endian.little);
      expect(declared + 8, bytes.length, reason: '$asset is truncated');
    }

    // ANMF is the per-frame chunk: without one this is a picture, and
    // the walkthrough would open on a frozen plumbob.
    final film = File(introAsset).readAsBytesSync();
    expect(String.fromCharCodes(film.sublist(12, 16)), 'VP8X',
        reason: 'an animated WebP leads with its extended header');
    var frames = 0;
    for (var i = 12; i < film.length - 4; i++) {
      if (film[i] == 0x41 &&
          film[i + 1] == 0x4E &&
          film[i + 2] == 0x4D &&
          film[i + 3] == 0x46) {
        frames++;
      }
    }
    expect(frames, greaterThan(60), reason: 'the film is barely a film');

    // And the still really is a still, so nothing decodes twice.
    final last = File(introStillAsset).readAsBytesSync();
    expect(String.fromCharCodes(last.sublist(12, 16)), isNot('VP8X'));
  });

  test('the music is shipped, and starts inside the film', () {
    // introAudioAsset is written the way AssetSource wants it - relative
    // to `assets/` - so the file it names is one level up from the path
    // itself. Getting that wrong is silence and nothing else: playback
    // failures are swallowed by design.
    final file = File('assets/$introAudioAsset');
    expect(file.existsSync(), isTrue, reason: '${file.path} is missing');
    final bytes = file.readAsBytesSync();
    final id3 = String.fromCharCodes(bytes.sublist(0, 3)) == 'ID3';
    final frame = bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0;
    expect(id3 || frame, isTrue, reason: 'not an MP3');

    // The cue has to land inside the film, or the music plays over a
    // walkthrough that has already started - or never plays at all.
    expect(introAudioCue, greaterThan(Duration.zero));
    expect(introAudioCue, lessThan(const Duration(seconds: 9)));
  });
}

void main() {
  _pinsTheFilm();

  testWidgets('the first run walks through and lands on the library',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // onboardingDone false is how a test asks for the walkthrough: absent
    // reads as done under flutter test, so the rest of the suite keeps
    // pumping straight into the library.
    SharedPreferences.setMockInitialValues(
        {'soundEffects': false, 'onboardingDone': false});
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_intro');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    File('${tempDir.path}/cozy_sofa.package').writeAsStringSync('sofa bytes');

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();
    final strings = await L.delegate.load(const Locale('en'));

    await _pumpFirstRun(tester, registry, settings, strings);

    // One game found, so it never asks which to open on: welcome, games,
    // look, library, done.
    expect(find.text(strings.onboardingFavoriteTitle), findsNothing);
    await _next(tester, strings); // games
    expect(find.text(strings.onboardingGamesTitle), findsOneWidget);
    // The scan has to answer before the walkthrough will move on.
    await until(tester, find.text(strings.onboardingGamesFound(1)));
    await _next(tester, strings); // look
    expect(find.text(strings.onboardingFavoriteTitle), findsNothing);
    await _next(tester, strings); // library
    await _next(tester, strings); // done
    expect(find.text(strings.onboardingDoneTitle), findsOneWidget);

    await tester.tap(find.text(strings.onboardingFinish));
    await until(tester, find.text(strings.libraryTitle('Fake Game')));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(strings.onboardingDoneTitle), findsNothing);
    expect(find.text('cozy sofa'), findsOneWidget);
    // And it is not asked again.
    expect(settings.onboardingDone, isTrue);
  });

  testWidgets('two games ask which one to open on, and it sticks',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(
        {'soundEffects': false, 'onboardingDone': false});
    final one = Directory.systemTemp.createTempSync('mod_manager_g1');
    final two = Directory.systemTemp.createTempSync('mod_manager_g2');
    addTearDown(() => one.deleteSync(recursive: true));
    addTearDown(() => two.deleteSync(recursive: true));
    File('${one.path}/cozy_sofa.package').writeAsStringSync('sofa');
    File('${two.path}/tall_lamp.package').writeAsStringSync('lamp');

    final registry = GameRegistry([
      _FakeAdapter(one, id: 'fake1', title: 'Fake One'),
      _FakeAdapter(two, id: 'fake2', title: 'Fake Two'),
    ]);
    final settings = await SettingsStore.load();
    final strings = await L.delegate.load(const Locale('en'));

    await _pumpFirstRun(tester, registry, settings, strings);

    await _next(tester, strings); // games
    await until(tester, find.text(strings.onboardingGamesFound(2)));
    await _next(tester, strings); // favorite, because there are two
    expect(find.text(strings.onboardingFavoriteTitle), findsOneWidget);

    // The app opened on the first game; the second is the one played.
    // `.last` because the sidebar behind the card names it too, and the
    // card is drawn over it.
    await tester.tap(find.text('Fake Two').last);
    await tester.pump(const Duration(milliseconds: 400));
    expect(settings.defaultGameId, 'fake2');

    await _next(tester, strings); // look
    await _next(tester, strings); // library
    await _next(tester, strings); // done
    await tester.tap(find.text(strings.onboardingFinish));
    // Finishing is what actually switches games, so this waits for the
    // second game's library rather than the first's.
    await until(tester, find.text(strings.libraryTitle('Fake Two')));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('tall lamp'), findsOneWidget);
  });

  testWidgets('a later launch opens on the game that was chosen',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'soundEffects': false,
      'onboardingDone': true,
      'defaultGame': 'fake2',
    });
    final one = Directory.systemTemp.createTempSync('mod_manager_open1');
    final two = Directory.systemTemp.createTempSync('mod_manager_open2');
    addTearDown(() => one.deleteSync(recursive: true));
    addTearDown(() => two.deleteSync(recursive: true));
    File('${two.path}/tall_lamp.package').writeAsStringSync('lamp');

    final registry = GameRegistry([
      _FakeAdapter(one, id: 'fake1', title: 'Fake One'),
      _FakeAdapter(two, id: 'fake2', title: 'Fake Two'),
    ]);
    final settings = await SettingsStore.load();
    final strings = await L.delegate.load(const Locale('en'));

    await tester.runAsync(() async {
      await tester
          .pumpWidget(ModManagerApp(registry: registry, settings: settings));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await until(tester, find.text(strings.libraryTitle('Fake Two')));
    await tester.pump(const Duration(milliseconds: 400));

    // Straight into the second game's library: no walkthrough, and not
    // the first adapter in the registry.
    expect(find.text(strings.onboardingWelcomeTitle), findsNothing);
    expect(find.text('tall lamp'), findsOneWidget);
  });

  testWidgets('skipping counts as having been through it', (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(
        {'soundEffects': false, 'onboardingDone': false});
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_skip');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();
    final strings = await L.delegate.load(const Locale('en'));

    await _pumpFirstRun(tester, registry, settings, strings);

    await tester.tap(find.text(strings.onboardingSkip));
    await until(tester, find.text(strings.libraryTitle('Fake Game')));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(strings.onboardingWelcomeTitle), findsNothing);
    expect(settings.onboardingDone, isTrue);
  });

  testWidgets('the footer buttons are a pair, flush with the card',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(
        {'soundEffects': false, 'onboardingDone': false});
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_footer');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();
    final strings = await L.delegate.load(const Locale('en'));

    await _pumpFirstRun(tester, registry, settings, strings);
    await _next(tester, strings); // games
    await until(tester, find.text(strings.onboardingGamesFound(1)));
    await _next(tester, strings); // look
    await _next(tester, strings); // library, which has Back, Next and a
    await tester.pump(const Duration(milliseconds: 700)); // full-width row

    final back = tester.getRect(
        find.widgetWithText(GestureDetector, strings.onboardingBack));
    final next = tester.getRect(
        find.widgetWithText(GestureDetector, strings.onboardingNext));
    // The card's own content width, measured off something that spans it.
    final row = tester.getRect(
        find.widgetWithText(GestureDetector, strings.prefScanArtworkTitle));

    expect(back.height, next.height, reason: 'the pair is one height');
    expect(back.center.dy, next.center.dy, reason: 'the pair sits on a line');
    expect(back.right, lessThan(next.left), reason: 'Back leads Next');
    expect(next.right, moreOrLessEquals(row.right, epsilon: 0.5),
        reason: 'the pair is flush with the right edge of the card');
  });

  testWidgets('an install that has run before is never asked', (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // Never answered, but this copy of the app has a history: the
    // walkthrough shipped in an update, and this user has been here for
    // months.
    SharedPreferences.setMockInitialValues({
      'soundEffects': false,
      'onboardingDone': false,
      'analytics.launchCount': 37,
    });
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_old');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();
    final strings = await L.delegate.load(const Locale('en'));

    await tester.runAsync(() async {
      await tester
          .pumpWidget(ModManagerApp(registry: registry, settings: settings));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await until(tester, find.text(strings.libraryTitle('Fake Game')));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(strings.onboardingWelcomeTitle), findsNothing);
    // And the question is settled rather than asked again next launch.
    expect(settings.onboardingDone, isTrue);
  });

  testWidgets('a machine with no game gets told so', (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(
        {'soundEffects': false, 'onboardingDone': false});

    // No folder at all: defaultModsPath answers null, which is what a
    // game nobody has installed looks like.
    final registry = GameRegistry([_FakeAdapter(null)]);
    final settings = await SettingsStore.load();
    final strings = await L.delegate.load(const Locale('en'));

    await _pumpFirstRun(tester, registry, settings, strings);
    await _next(tester, strings);

    await until(tester, find.text(strings.onboardingNoGamesTitle));
    expect(find.text(strings.onboardingGameMissing), findsOneWidget);
    // Still a way forward: nothing here is a wall.
    expect(find.text(strings.onboardingNext), findsOneWidget);
  });

  // Every page of it in every language at the narrowest the window goes.
  // Translations run longer than English and the card is the whole
  // window's worth of copy, so this is where one that doesn't fit shows.
  for (final language in appLanguages) {
    testWidgets('${language.name} fits the walkthrough at the minimum size',
        (tester) async {
      tester.view.physicalSize = kMinWindowSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({
        'soundEffects': false,
        'onboardingDone': false,
        'localeCode': language.code,
      });
      final one = Directory.systemTemp.createTempSync('mod_manager_intro_l1');
      final two = Directory.systemTemp.createTempSync('mod_manager_intro_l2');
      addTearDown(() => one.deleteSync(recursive: true));
      addTearDown(() => two.deleteSync(recursive: true));

      final overflows = <String>[];
      final priorOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        final text = details.exceptionAsString();
        if (text.contains('overflowed')) {
          overflows.add(text.split('\n').first);
        } else {
          priorOnError?.call(details);
        }
      };
      addTearDown(() => FlutterError.onError = priorOnError);

      // Two games, so the page asking which to open on is measured too.
      final registry = GameRegistry([
        _FakeAdapter(one, id: 'fake1', title: 'The Sims Fake One'),
        _FakeAdapter(two, id: 'fake2', title: 'The Sims Fake Two'),
      ]);
      final settings = await SettingsStore.load();
      final strings = await L.delegate.load(Locale(language.code));

      await _pumpFirstRun(tester, registry, settings, strings);
      expect(overflows, isEmpty, reason: 'welcome in ${language.name}');

      await _next(tester, strings);
      await until(tester, find.text(strings.onboardingGamesFound(2)));
      await tester.pump(const Duration(milliseconds: 700));
      expect(overflows, isEmpty, reason: 'games in ${language.name}');

      for (final page in [
        strings.onboardingFavoriteTitle,
        strings.onboardingLookTitle,
        strings.onboardingLibraryTitle,
        strings.onboardingDoneTitle,
      ]) {
        await _next(tester, strings);
        expect(find.text(page), findsOneWidget,
            reason: '$page in ${language.name}');
        expect(overflows, isEmpty, reason: '$page in ${language.name}');
      }
    });
  }
}
