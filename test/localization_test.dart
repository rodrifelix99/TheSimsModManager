import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale, Size;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/material.dart' show OutlinedButton;
import 'package:flutter/widgets.dart' show Directionality, Localizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/app_message.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/core/save_game.dart';
import 'package:sims_mod_manager/src/core/trivia.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims_adapters.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims_trivia.dart';
import 'package:sims_mod_manager/src/services/mod_shop.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app.dart';
import 'package:sims_mod_manager/src/ui/l10n.dart';

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

  /// The shared franchise facts, so the plumbob's bubble is drawn and
  /// measured by the minimum-window sweep below. Those are the wordiest
  /// strings the app has, and the bubble is a fixed 348px wide.
  @override
  List<TriviaFact> get triviaFacts => seriesTrivia;

  @override
  Future<String?> defaultModsPath() async => dir.path;

  /// A save touching every translated saves label: stat tiles, life
  /// stages, skills, personality, relationship flags, photo kinds.
  @override
  Future<List<SaveGame>> listSaveGames() async => [
        SaveGame(
          name: 'Legacy',
          path: dir.path,
          modifiedAt: DateTime(2026, 7, 20),
          sizeBytes: 12 << 20,
          backupCount: 2,
          gameVersion: '1.0',
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
                  ageKey: 'youngAdult',
                  genderKey: 'female',
                  zodiacKey: 'sagittarius',
                  aspirationKey: 'grilledCheese',
                  skills: {
                    'cooking': 900,
                    'mechanical': 800,
                    'charisma': 700,
                    'body': 600,
                    'logic': 500,
                    'creativity': 400,
                    'cleaning': 300,
                  },
                  personality: {
                    'neat': 900,
                    'outgoing': 800,
                    'active': 700,
                    'playful': 600,
                    'nice': 500,
                  },
                  hobbies: {'cuisine': 900, 'film': 700, 'music': 500},
                  predestinedHobbyKey: 'film',
                  education: SaveEducation(
                      major: 'Political Science', gpa: 3.4, semester: 5),
                  familyTies: [
                    SaveFamilyTie(kindKey: 'mother', name: 'Jocasta Goth'),
                    SaveFamilyTie(kindKey: 'child', name: 'Alexander Goth'),
                    SaveFamilyTie(kindKey: 'child', name: 'Cassandra Goth'),
                  ],
                ),
                SaveSim(firstName: 'Alexander', ageKey: 'child'),
              ],
              relationships: [
                SaveRelationship(
                    nameA: 'Bella',
                    nameB: 'Alexander',
                    score: 80,
                    labelKeys: ['friends', 'married']),
              ],
            ),
            SaveHousehold(name: 'Townie', isPlayed: false),
          ],
          photos: const [SavePhoto(kindKey: 'familyPortrait')],
        ),
      ];
}

Map<String, Object?> _arb(String locale) =>
    (jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
        as Map<String, Object?>);

void main() {
  test('every shipped language has a translation file', () {
    for (final language in appLanguages) {
      expect(File('lib/l10n/app_${language.code}.arb').existsSync(), isTrue,
          reason: 'missing ARB for ${language.name}');
    }
    // And nothing ships that the picker can't reach, in either direction.
    final codes = [for (final l in appLanguages) l.code];
    expect([for (final l in appSupportedLocales) l.languageCode], codes);
    expect({for (final l in L.supportedLocales) l.languageCode}, codes.toSet());
    // English has to come first: Flutter falls back to the first supported
    // locale, and the generated list is alphabetical (German).
    expect(appSupportedLocales.first.languageCode, 'en');
  });

  test('translations cover every message in the English template', () {
    final template = _arb('en').keys.where((k) => !k.startsWith('@')).toSet();
    for (final language in appLanguages.where((l) => l.code != 'en')) {
      final translated =
          _arb(language.code).keys.where((k) => !k.startsWith('@')).toSet();
      expect(template.difference(translated), isEmpty,
          reason: '${language.name} is missing messages');
      expect(translated.difference(template), isEmpty,
          reason: '${language.name} has messages English does not');
    }
  });

  test('every game adapter has setup help in every language', () async {
    // The adapters hand out keys and the UI resolves them; a key the
    // resolver never heard of renders an empty help card, which is the
    // one failure mode the type system can't catch here.
    final adapters = GameRegistry(const [
      Sims1Adapter(),
      Sims2Adapter(),
      Sims3Adapter(),
      SimsMedievalAdapter(),
      Sims4Adapter(),
    ]).adapters;
    for (final language in appLanguages) {
      final strings = await L.delegate.load(Locale(language.code));
      for (final adapter in adapters) {
        expect(strings.setupHelp(adapter.setupHelpKey), isNotEmpty,
            reason: '${language.name} has no setup help for '
                '${adapter.game.name}');
      }
    }
  });

  // Everything the core layer can raise, with stand-in values. It travels
  // as a key because core has no localizations of its own, and the
  // resolver is a switch over strings: a key it never heard of falls
  // through to the bare `key(args)` form, in every language at once.
  const errors = <AppMessage>[
    AppMessage('noModFiles', ['.package', 'peggy_hair.zip']),
    AppMessage('unreadableArchive', ['peggy_hair.zip']),
    AppMessage('noUnpacker', ['RAR', 'peggy_hair.rar']),
    AppMessage('noUnpackerLinux', ['7Z', 'peggy_hair.7z']),
    AppMessage('noUnpackerLinuxRar', ['RAR', 'peggy_hair.rar']),
    AppMessage('unpackFailed', ['peggy_hair.rar']),
    AppMessage('installFailed', ['peggy_hair.package', 'Access is denied']),
    AppMessage('installFailedRaw', ['peggy_hair.package', 'Bad state']),
    AppMessage('fileInUseDelete', ['peggy_hair.package']),
    AppMessage('fileInUseRename', ['peggy_hair.package']),
    AppMessage('fileMissing', ['peggy_hair.package']),
  ];

  test('every error message is written in every language', () async {
    for (final language in appLanguages) {
      final strings = await L.delegate.load(Locale(language.code));
      for (final error in errors) {
        final text = strings.errorText(error);
        expect(text, isNot(contains(error.key)),
            reason: '${language.name} has no wording for ${error.key}');
        // The file name is the whole point of the message; a translation
        // that drops the placeholder leaves the user guessing.
        for (final argument in error.args) {
          expect(text, contains(argument),
              reason: '${language.name} loses "$argument" '
                  'from ${error.key}');
        }
      }
    }
  });

  test('wording the OS already wrote is shown as it came', () async {
    final strings = await L.delegate.load(const Locale('fr'));
    expect(strings.errorText(const AppMessage.verbatim('Access is denied')),
        'Access is denied');
  });

  // No saved preference is the default, so this is what almost everyone
  // gets: the OS language, matched on the language subtag so regional
  // variants land somewhere sensible, and English when nothing matches.
  for (final probe in <({List<Locale> system, String want})>[
    (system: [Locale('de')], want: 'de'),
    (system: [Locale('es', 'MX')], want: 'es'),
    (system: [Locale('pt', 'PT')], want: 'pt'),
    (
      system: [Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')],
      want: 'zh'
    ),
    // Nothing we ship: English, not whichever language sorts first.
    (system: [Locale('ko')], want: 'en'),
    // Second choice counts when the first is unsupported.
    (system: [Locale('ko'), Locale('fr')], want: 'fr'),
  ]) {
    testWidgets('system ${probe.system} runs the app in ${probe.want}',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 824);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.localesTestValue = probe.system;
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      SharedPreferences.setMockInitialValues({'soundEffects': false});
      final tempDir = Directory.systemTemp.createTempSync('mod_manager_auto');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final settings = await SettingsStore.load();
      await tester.runAsync(() async {
        await tester.pumpWidget(ModManagerApp(
            registry: GameRegistry([_FakeAdapter(tempDir)]),
            settings: settings));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      final context = tester.element(find.byType(Directionality).first);
      expect(Localizations.localeOf(context).languageCode, probe.want);
    });
  }

  testWidgets('the saved language wins over the system one', (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(
        {'soundEffects': false, 'localeCode': 'de'});
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_l10n');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    File('${tempDir.path}/cozy_sofa.package').writeAsStringSync('sofa bytes');

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester
          .pumpWidget(ModManagerApp(registry: registry, settings: settings));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await until(tester, find.text('Fake Game-Bibliothek'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Fake Game-Bibliothek'), findsOneWidget);
    expect(find.text('Einstellungen'), findsOneWidget);
    expect(find.text('Installieren'), findsOneWidget);
    expect(
      Localizations.localeOf(tester.element(find.text('Installieren')))
          .languageCode,
      'de',
    );
  });

  // Translations are longer than their English originals more often than
  // not, and the window can be squeezed to kMinWindowSize; a label that
  // only fits in English is a bug the English tests can never see.
  for (final language in appLanguages) {
    testWidgets('${language.name} fits the minimum window size',
        (tester) async {
      tester.view.physicalSize = kMinWindowSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      // Seeded so the advisory banner and the detail panel are both on
      // screen while the layout is measured: they are the wordiest thing
      // the library draws, and a translation that doesn't fit here is
      // exactly what this test exists to catch. fetchedAt is now, so the
      // controller doesn't reach for the network on top of it.
      SharedPreferences.setMockInitialValues({
        'soundEffects': false,
        'localeCode': language.code,
        'advisories.cache': '{"version": 1, "games": {"fake": [{'
            '"id": "cozy-sofa", "title": "Cozy Sofa", "status": "broken", '
            '"since": "the 24 July 2026 patch", '
            '"note": "Started right after the patch landed.", '
            '"url": "https://example.com", '
            '"identities": ["cozy sofa.package"]}]}}',
        'advisories.fetchedAt': DateTime.now().millisecondsSinceEpoch,
      });
      final tempDir = Directory.systemTemp.createTempSync('mod_manager_size');
      addTearDown(() => tempDir.deleteSync(recursive: true));
      File('${tempDir.path}/cozy_sofa.package').writeAsStringSync('x');
      // Byte for byte the first one, so the duplicate banner below has
      // something to report.
      File('${tempDir.path}/cozy_sofa_copy.package').writeAsStringSync('x');

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

      final registry = GameRegistry([_FakeAdapter(tempDir)]);
      final settings = await SettingsStore.load();
      await tester.runAsync(() async {
        await tester.pumpWidget(ModManagerApp(
            registry: registry,
            settings: settings,
            // Empty shelves on purpose: the shop's alpha empty state is
            // its wordiest layout.
            fetchShop: () async => const []));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      // Everything below here needs the mod on screen, and loading the
      // library is real IO on a real disk.
      final sofa = find.text('cozy sofa');
      await until(tester, sofa);
      await tester.pump(const Duration(milliseconds: 500));
      expect(sofa, findsOneWidget, reason: 'library in ${language.name}');
      expect(overflows, isEmpty, reason: 'library in ${language.name}');

      final strings = await L.delegate.load(Locale(language.code));

      // The plumbob's bubble, every fact it can show on this screen. It
      // is a fixed 348px wide carrying the longest prose in the app, and
      // its footer puts a counter and three buttons on one row - which is
      // where a translation runs out of room. Stepping through the whole
      // pool measures the longest one rather than whichever the shuffle
      // happened to open on.
      await tester.tap(find.byTooltip(strings.triviaOpen));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byTooltip(strings.triviaNext), findsOneWidget,
          reason: 'trivia bubble in ${language.name}');
      // "Another one" sits between the arrows, and left to its own
      // intrinsic height it came out two pixels short of them, which
      // reads as a misalignment rather than as a style. Its label is
      // what sizes it, so this is a per-language check.
      final arrow = find.byTooltip(strings.triviaNext);
      final another =
          find.widgetWithText(OutlinedButton, strings.triviaAnother);
      expect(tester.getSize(another).height, tester.getSize(arrow).height,
          reason: 'footer heights in ${language.name}');
      expect(tester.getTopLeft(another).dy, tester.getTopLeft(arrow).dy,
          reason: 'footer baseline in ${language.name}');
      for (var i = 0; i < seriesTrivia.length; i++) {
        await tester.tap(find.byTooltip(strings.triviaNext));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(overflows, isEmpty, reason: 'trivia in ${language.name}');
      }
      // Out of the way again: it floats over every screen, and the taps
      // below are aimed at what is underneath it.
      await tester.tap(find.byTooltip(strings.triviaClose));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // The duplicate banner in its wordiest state: a sentence carrying a
      // count and a size, with two actions beside it. Run from its own
      // button, so a header that no longer has room for one fails here
      // rather than in a screenshot. The scan reads real files, so it
      // goes outside the fake-async zone like the library load above.
      await tester.runAsync(() async {
        await tester.tap(find.byTooltip(strings.duplicatesFind));
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(strings.duplicatesSelectExtras), findsOneWidget,
          reason: 'duplicate banner in ${language.name}');
      expect(overflows, isEmpty, reason: 'duplicates in ${language.name}');

      // The selection bar drops in under the filters, carrying the count
      // in words as well as five buttons; ctrl-click is how the library
      // gets into it. Finding one of its buttons is what says it worked -
      // a modifier that never registered would leave this test passing
      // on a bar it never drew.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.tap(find.text('cozy sofa'));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byTooltip(strings.selectionClear), findsOneWidget,
          reason: 'selection bar in ${language.name}');
      expect(overflows, isEmpty, reason: 'selection in ${language.name}');

      // The move dialog, and the folder name field inside it - the two
      // wordiest things the folder half of this draws.
      await tester.tap(find.byTooltip(strings.selectionMove));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(strings.moveBody), findsOneWidget);
      expect(overflows, isEmpty, reason: 'move dialog in ${language.name}');
      await tester.tap(find.text(strings.newFolder));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(overflows, isEmpty, reason: 'new folder in ${language.name}');
      await tester.tap(find.text(strings.cancel).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // The tag dialog: a field, a button beside it and a row per tag,
      // all of them labelled in words that run long.
      await tester.tap(find.byTooltip(strings.selectionTag));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(strings.tagBody), findsOneWidget);
      expect(overflows, isEmpty, reason: 'tag dialog in ${language.name}');
      await tester.tap(find.text(strings.tagDone));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Back out of the selection, so the tap below opens the mod rather
      // than ticking a second one.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.tap(find.text('cozy sofa'));
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      await tester.tap(find.text('cozy sofa'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(overflows, isEmpty, reason: 'mod details in ${language.name}');

      await tester.tap(find.text(strings.navSettings).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      // The Exchange's folder card asks the disk before it draws, so it
      // is waited for rather than assumed: it is a label and a button on
      // one row, which is where a long translation shows.
      await until(tester, find.text(strings.prefShopFolderTitle));
      await tester.pump(const Duration(milliseconds: 500));
      expect(overflows, isEmpty, reason: 'settings in ${language.name}');

      await tester.tap(find.text(strings.navShop).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(overflows, isEmpty, reason: 'shop in ${language.name}');

      // The saves screen and each of its tabs, seeded with every kind of
      // stat the scanners produce.
      await tester.runAsync(() async {
        await tester.tap(find.text(strings.navSaves).last);
        await Future<void>.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump(const Duration(milliseconds: 500));
      expect(overflows, isEmpty, reason: 'saves in ${language.name}');
      await tester.tap(find.text(strings.savesTabAlbum));
      await tester.pump(const Duration(milliseconds: 500));
      expect(overflows, isEmpty, reason: 'saves album in ${language.name}');
      await tester.tap(find.text(strings.savesTabStats));
      await tester.pump(const Duration(milliseconds: 500));
      expect(overflows, isEmpty, reason: 'saves stats in ${language.name}');
    });
  }

  // The sweep above stocks no listings, because the shop's wordiest
  // layout is its empty state - which leaves a listing's own page, the
  // one screen carrying two buttons side by side and a line of prose
  // under them, drawn in English only. Its own pass rather than a
  // listing added up there, so neither layout costs the other its
  // coverage.
  for (final language in appLanguages) {
    testWidgets('${language.name} fits a listing page at the minimum size',
        (tester) async {
      tester.view.physicalSize = kMinWindowSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({
        'soundEffects': false,
        'localeCode': language.code,
      });
      final tempDir = Directory.systemTemp.createTempSync('mod_manager_shop');
      addTearDown(() => tempDir.deleteSync(recursive: true));

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

      final settings = await SettingsStore.load();
      await tester.runAsync(() async {
        await tester.pumpWidget(ModManagerApp(
          registry: GameRegistry([_FakeAdapter(tempDir)]),
          settings: settings,
          fetchShop: () async => [
            const ShopMod(
              id: 'l1',
              gameId: 'fake',
              name: 'Cozy Sofa',
              version: '1.0',
              description: 'A sofa.',
              instructions: 'Unzip it.',
              authorName: 'plumbob_pat',
              authorUid: 'u1',
              fileName: 'cozy_sofa.package',
              filePath: 'mods/u1/l1/cozy_sofa.package',
              fileSizeBytes: 11,
            ),
          ],
        ));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      final strings = await L.delegate.load(Locale(language.code));
      await until(tester, find.text(strings.libraryTitle('Fake Game')));
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text(strings.navShop).last);
      await until(tester, find.text('Cozy Sofa'));
      await tester.pump(const Duration(milliseconds: 500));

      // Onto the listing's own page: Install and Download share a row
      // there, with the line explaining the difference under them.
      await tester.tap(find.text('Cozy Sofa').last);
      await until(tester, find.text(strings.shopSaveFile));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text(strings.shopSaveFile), findsOneWidget,
          reason: 'listing page in ${language.name}');
      // And the line under them saying which folder Install will use,
      // which is a label, a folder name and a button on one row.
      await until(tester, find.text(strings.shopDestination.toUpperCase()));
      expect(find.text(strings.shopDestination.toUpperCase()), findsOneWidget,
          reason: 'listing destination in ${language.name}');
      expect(overflows, isEmpty, reason: 'listing page in ${language.name}');
    });
  }
}
