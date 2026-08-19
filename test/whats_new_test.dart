import 'dart:io';
import 'dart:typed_data' show ByteData, Endian;
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/app_version.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/core/whats_new.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';
import 'package:sims_mod_manager/src/ui/l10n.dart';

import 'until.dart';

/// A game that needs no disk beyond the folder it is handed. The artwork
/// scan is stubbed for the reason every widget test stubs it: real
/// isolates can't finish inside the fake-async zone.
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
  Game get game => Game(id: 'fake', name: 'Fake Game', series: 'Test', year: 2024);

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  String get setupHelpKey => 'test adapter';

  @override
  Future<String?> defaultModsPath() async => dir.path;
}

/// A table of its own, because the shipped one names releases this build
/// may not have reached: `appVersion` is what the card is bounded by, so
/// every entry a test wants to see has to sit at or below it.
const _table = [
  WhatsNewEntry(
    version: '0.9.0',
    titleKey: 'whatsNew300RootTitle',
    bodyKey: 'whatsNew300RootBody',
  ),
  WhatsNewEntry(
    version: '1.0.0',
    titleKey: 'whatsNew300PacksTitle',
    bodyKey: 'whatsNew300PacksBody',
    // The headline carries a film, so the hero is built the way the
    // shipped card builds it. Nothing decodes: a film is over before it
    // starts under `flutter test`, which is exactly what the machine
    // that cannot decode one sees.
    image: 'assets/whatsnew/3.0.0.webp',
    film: 'assets/whatsnew/3.0.0-film.webp',
    audio: 'assets/whatsnew/3.0.0.mp3',
  ),
];

Map<String, Object> _prefs({String? lastSeen, bool onboarded = true}) => {
      'soundEffects': false,
      'analyticsEnabled': false,
      'onboardingDone': onboarded,
      if (lastSeen != null) 'lastSeenVersion': lastSeen,
    };

Future<(GameRegistry, SettingsStore)> _setUp(Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues(prefs);
  final dir = Directory.systemTemp.createTempSync('whats_new_test');
  addTearDown(() => dir.deleteSync(recursive: true));
  return (
    GameRegistry([_FakeAdapter(dir)]),
    await SettingsStore.load(),
  );
}

Future<void> _pump(
  WidgetTester tester,
  GameRegistry registry,
  SettingsStore settings,
) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(ModManagerApp(
        registry: registry, settings: settings, whatsNewTable: _table));
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });
  await tester.pump(const Duration(milliseconds: 700));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('the debug preview', () {
    /// A controller on its own: the row this stands behind is in the
    /// developer card of Settings, and what is worth pinning is what it
    /// draws rather than that a button exists.
    Future<AppController> controllerWith(Map<String, Object> prefs) async {
      SharedPreferences.setMockInitialValues(prefs);
      final dir = Directory.systemTemp.createTempSync('whats_new_preview');
      addTearDown(() => dir.deleteSync(recursive: true));
      return AppController(
        registry: GameRegistry([_FakeAdapter(dir)]),
        settings: await SettingsStore.load(),
        checkUpdates: () async => null,
        whatsNewTable: _table,
      );
    }

    test('it opens on a copy that has already seen the release', () async {
      // The case the row exists for: on the machine the card is being
      // worked on, the launch check has nothing to say and a button
      // wired to it would look broken.
      final c = await controllerWith(_prefs(lastSeen: appVersion));
      expect(c.showWhatsNew, isFalse);

      c.previewWhatsNew();

      expect(c.showWhatsNew, isTrue);
      // The newest release in the table, not everything in it.
      expect([for (final e in c.whatsNew) e.version], ['1.0.0']);
    });

    test('it writes no version down', () async {
      final c = await controllerWith(_prefs());
      c.previewWhatsNew();
      c.dismissWhatsNew();
      // Still absent, so the next real update is still an update.
      expect(c.settings.lastSeenVersion, isNull);
    });

    test('an empty table has nothing to preview', () async {
      SharedPreferences.setMockInitialValues(_prefs());
      final dir = Directory.systemTemp.createTempSync('whats_new_empty');
      addTearDown(() => dir.deleteSync(recursive: true));
      final c = AppController(
        registry: GameRegistry([_FakeAdapter(dir)]),
        settings: await SettingsStore.load(),
        checkUpdates: () async => null,
        whatsNewTable: const [],
      );

      expect(c.canPreviewWhatsNew, isFalse);
      c.previewWhatsNew();
      expect(c.showWhatsNew, isFalse);
    });
  });

  group('what gets celebrated', () {
    test('a fresh install is welcomed, not briefed', () {
      expect(entriesSince(null, '2.6.0', entries: _table), isEmpty);
    });

    test('a launch on the version already seen says nothing', () {
      expect(entriesSince('1.0.0', '1.0.0', entries: _table), isEmpty);
    });

    test('an update carries everything missed, newest first', () {
      final entries = entriesSince('0.8.0', '1.0.0', entries: _table);
      expect([for (final e in entries) e.version], ['1.0.0', '0.9.0']);
    });

    test('a release the running build has not reached is left out', () {
      // The table is written when the feature lands, which is before the
      // release that carries it. Announcing one early is announcing a
      // feature that is not in this copy.
      final entries = entriesSince('0.8.0', '0.9.0', entries: _table);
      expect([for (final e in entries) e.version], ['0.9.0']);
    });

    test('a copy that has gone backwards says nothing', () {
      expect(entriesSince('2.0.0', '1.0.0', entries: _table), isEmpty);
    });

    test('an unreadable version on either side says nothing', () {
      expect(entriesSince('nightly', '1.0.0', entries: _table), isEmpty);
      expect(entriesSince('0.8.0', 'nightly', entries: _table), isEmpty);
    });

    test('entries sharing a version keep the order they were written in',
        () {
      // `List.sort` is unstable, so without the index tiebreak these two
      // could swap between builds and the card would pick a different
      // hero for the same release.
      const tied = [
        WhatsNewEntry(version: '1.0.0', titleKey: 'a', bodyKey: 'a'),
        WhatsNewEntry(version: '1.0.0', titleKey: 'b', bodyKey: 'b'),
        WhatsNewEntry(version: '1.0.0', titleKey: 'c', bodyKey: 'c'),
      ];
      for (var i = 0; i < 20; i++) {
        final entries = entriesSince('0.9.0', '1.0.0', entries: tied);
        expect([for (final e in entries) e.titleKey], ['a', 'b', 'c']);
      }
    });

    test('versions order by number, not by string', () {
      expect(compareVersions('2.10.0', '2.9.9'), greaterThan(0));
      expect(compareVersions('2.6', '2.6.0'), 0);
      expect(compareVersions('1.2.3', '1.2.3'), 0);
      expect(compareVersions('1.2.3.4', '1.2.3'), isNull);
      expect(compareVersions('v2', '2'), isNull);
    });
  });

  group('the card', () {
    testWidgets('an update opens it, and closing it puts it away',
        (tester) async {
      final (registry, settings) = await _setUp(_prefs(lastSeen: '0.8.0'));
      final l = await L.delegate.load(const Locale('en'));
      await _pump(tester, registry, settings);

      await until(tester, find.text(l.whatsNew300PacksTitle));
      // The newest release is the headline; what was missed on the way
      // is listed under it.
      expect(find.text(l.whatsNewAlsoSince), findsOneWidget);
      expect(find.text(l.whatsNew300RootTitle), findsOneWidget);

      await tester.tap(find.text(l.whatsNewDismiss));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      expect(find.text(l.whatsNew300PacksTitle), findsNothing);
    });

    testWidgets('the version is marked seen, so it is once per update',
        (tester) async {
      final (registry, settings) = await _setUp(_prefs(lastSeen: '0.8.0'));
      final l = await L.delegate.load(const Locale('en'));
      await _pump(tester, registry, settings);
      await until(tester, find.text(l.whatsNew300PacksTitle));
      expect(settings.lastSeenVersion, isNotNull);

      // What the next launch reads, on the same preferences.
      final next = await SettingsStore.load();
      expect(entriesSince(next.lastSeenVersion, appVersion,
              entries: _table),
          isEmpty);
    });

    testWidgets('a fresh install gets no card at all', (tester) async {
      final (registry, settings) = await _setUp(_prefs());
      final l = await L.delegate.load(const Locale('en'));
      await _pump(tester, registry, settings);
      expect(find.text(l.whatsNew300PacksTitle), findsNothing);
      // And it is written down, so the next launch is not briefed on
      // everything that ever shipped.
      expect(settings.lastSeenVersion, isNotNull);
    });

    testWidgets('the walkthrough wins, and settles the version with it',
        (tester) async {
      final (registry, settings) =
          await _setUp(_prefs(lastSeen: '0.8.0', onboarded: false));
      final l = await L.delegate.load(const Locale('en'));
      await _pump(tester, registry, settings);

      await until(tester, find.text(l.onboardingWelcomeTitle));
      expect(find.text(l.whatsNew300PacksTitle), findsNothing);
      // Marked seen rather than saved for tomorrow: being ambushed the
      // next morning by news of an update you were just welcomed into
      // is not an improvement.
      expect(settings.lastSeenVersion, isNotNull);
      final next = await SettingsStore.load();
      expect(entriesSince(next.lastSeenVersion, appVersion,
              entries: _table),
          isEmpty);
    });

    testWidgets('it lays out in every language at the minimum window size',
        (tester) async {
      // Translated bodies run longer than English, and this card is a
      // fixed hero over a column of them - which is where it breaks
      // first, exactly as the sidebar labels did.
      tester.view.physicalSize = kMinWindowSize;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      for (final language in appLanguages) {
        final (registry, settings) = await _setUp(_prefs(lastSeen: '0.8.0'));
        final overflows = <String>[];
        final previous = FlutterError.onError;
        FlutterError.onError = (details) {
          final text = details.exceptionAsString();
          if (text.contains('overflowed')) {
            overflows.add('${language.code}: $text');
          } else {
            previous?.call(details);
          }
        };
        await settings.setLocaleCode(language.code);
        await _pump(tester, registry, settings);
        await tester.pump(const Duration(milliseconds: 700));
        FlutterError.onError = previous;
        expect(overflows, isEmpty, reason: overflows.join('\n'));
      }
    });
  });

  test('every entry in the shipped table is worded in every language',
      () async {
    // The table is Dart and the words are ARB, so an entry can be added
    // with a key nobody ever wrote a string for. It would draw the key
    // itself rather than crash, which is worse: it ships.
    for (final language in appLanguages) {
      final l = await L.delegate.load(Locale(language.code));
      for (final entry in whatsNewEntries) {
        expect(l.whatsNewTitle(entry.titleKey), isNot(entry.titleKey),
            reason: '${entry.titleKey} is not written in ${language.code}');
        expect(l.whatsNewBody(entry.bodyKey), isNot(entry.bodyKey),
            reason: '${entry.bodyKey} is not written in ${language.code}');
      }
    }
  });

  test('every hero, film and sound the table names is shipped, and is one',
      () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    // What each format announces itself with, so a truncated write or a
    // file renamed rather than converted is caught here rather than as
    // a card with its gradient showing and nothing to say why.
    const signatures = <String, List<int>>{
      '.png': [0x89, 0x50, 0x4E, 0x47],
      '.jpg': [0xFF, 0xD8, 0xFF],
      '.webp': [0x52, 0x49, 0x46, 0x46],
      // An MP3 leads with an ID3 tag or, tagless, with a frame sync -
      // so this one is checked below rather than by prefix.
      '.mp3': [],
    };
    for (final entry in whatsNewEntries) {
      for (final asset in [entry.image, entry.film, entry.audio]) {
        if (asset == null) continue;
        final file = File(asset);
        expect(file.existsSync(), isTrue, reason: '$asset is missing');
        // The folder has to be declared or the asset is not in the
        // build, and the card falls back to its gradient with nothing
        // to say why.
        final folder = asset.substring(0, asset.lastIndexOf('/') + 1);
        expect(pubspec, contains(folder),
            reason: '$folder is not in pubspec');
        final extension = asset.substring(asset.lastIndexOf('.'));
        final expected = signatures[extension];
        expect(expected, isNotNull, reason: '$asset is not a format we use');
        final bytes = file.readAsBytesSync();
        if (extension == '.mp3') {
          final id3 = String.fromCharCodes(bytes.sublist(0, 3)) == 'ID3';
          final frame = bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0;
          expect(id3 || frame, isTrue, reason: '$asset is not really an MP3');
          continue;
        }
        expect(bytes.take(expected!.length), expected,
            reason: '$asset is not really $extension');
      }

      // A sound with no film has nothing to play over: it is cued off
      // the picture's own clock and stopped when the picture stops, so
      // on its own it would never start at all.
      expect(entry.audio == null || entry.film != null, isTrue,
          reason: '${entry.audio} has no film to play over');

      // A film has to be an animated WebP and nothing else: any other
      // format decodes to a single frame, which would draw the opening
      // shot over the hero and hold it there for good.
      final film = entry.film;
      if (film == null) continue;
      final bytes = File(film).readAsBytesSync();
      expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WEBP',
          reason: '$film is not a WebP');
      // The declared length has to agree with the file, which is what a
      // write that stopped early looks like.
      final declared =
          ByteData.sublistView(bytes, 4, 8).getUint32(0, Endian.little);
      expect(declared + 8, bytes.length, reason: '$film is truncated');
      expect(String.fromCharCodes(bytes.sublist(12, 16)), 'VP8X',
          reason: 'an animated WebP leads with its extended header');
      // ANMF is the per-frame chunk, and a still has none at all - so
      // two is the honest bar rather than the intro test's sixty. That
      // number was picked for a ten-second walkthrough film; a hero is
      // whatever length its release wanted, and a three-second one is a
      // perfectly good film that would have failed here.
      var frames = 0;
      for (var i = 12; i < bytes.length - 4; i++) {
        if (bytes[i] == 0x41 &&
            bytes[i + 1] == 0x4E &&
            bytes[i + 2] == 0x4D &&
            bytes[i + 3] == 0x46) {
          frames++;
        }
      }
      expect(frames, greaterThan(1), reason: '$film is a still, not a film');
    }
  });
}
