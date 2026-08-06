import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/core/trivia.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims_adapters.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims_trivia.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';
import 'package:sims_mod_manager/src/ui/l10n.dart';
import 'dart:ui' show Locale;

import 'until.dart';

/// A game with facts of its own, so the buddy can be driven without
/// depending on which fact The Sims 4 happens to shuffle to the top.
class _FactfulAdapter extends FolderBasedGameAdapter {
  _FactfulAdapter(this.dir, {this.facts = _facts});

  final Directory dir;
  final List<TriviaFact> facts;

  static const _facts = <TriviaFact>[
    TriviaFact('a', 'lore'),
    TriviaFact('b', 'design'),
    TriviaFact('c', 'modding', context: TriviaContext.saves),
    TriviaFact('d', 'death'),
    TriviaFact('e', 'records', context: TriviaContext.packs),
  ];

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

  @override
  List<TriviaFact> get triviaFacts => facts;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const adapters = [
    Sims1Adapter(),
    Sims2Adapter(),
    Sims3Adapter(),
    SimsMedievalAdapter(),
    Sims4Adapter(),
  ];

  /// Every fact the app can draw, once each.
  final allFacts = <TriviaFact>{
    ...seriesTrivia,
    ...sims1Trivia,
    ...sims2Trivia,
    ...sims3Trivia,
    ...sims4Trivia,
    ...simsMedievalTrivia,
  };

  test('every fact is written in every language', () async {
    // The bodies live in the ARB files and travel as keys, so a fact
    // added to the table without wording, or worded in English only,
    // reaches the bubble as a blank. This is the only thing that catches
    // it, in all eleven languages at once.
    for (final language in appLanguages) {
      final strings = await L.delegate.load(Locale(language.code));
      for (final fact in allFacts) {
        expect(strings.triviaFact(fact.key), isNotEmpty,
            reason: '${language.name} has no wording for ${fact.key}');
      }
    }
  });

  test('every category chip is written in every language', () async {
    for (final language in appLanguages) {
      final strings = await L.delegate.load(Locale(language.code));
      for (final category in triviaCategories) {
        final drawn = strings.triviaCategory(category);
        expect(drawn, isNotEmpty);
        // An unknown key falls through to the key itself, which is the
        // English word and reads plausible - so the check is that it
        // actually resolved, not merely that something came back.
        expect(drawn, isNot(category),
            reason: '${language.name} has no chip for $category');
      }
    }
  });

  test('every fact carries a category the chips know', () {
    for (final fact in allFacts) {
      expect(triviaCategories, contains(fact.category),
          reason: '${fact.key} is filed under ${fact.category}');
    }
  });

  test('no fact key is used twice', () {
    final keys = [
      ...seriesTrivia,
      ...sims1Trivia,
      ...sims2Trivia,
      ...sims3Trivia,
      ...sims4Trivia,
      ...simsMedievalTrivia,
    ].map((f) => f.key).toList();
    expect(keys.toSet().length, keys.length);
  });

  test('every shipped game has facts, and gets the shared ones too', () {
    for (final adapter in adapters) {
      expect(adapter.triviaFacts, isNotEmpty, reason: adapter.game.name);
      for (final shared in seriesTrivia) {
        expect(adapter.triviaFacts, contains(shared),
            reason: '${adapter.game.name} is missing the shared facts');
      }
    }
  });

  test('a fact written for a screen only fits that screen', () {
    const anywhere = TriviaFact('x', 'lore');
    const savesOnly = TriviaFact('y', 'design', context: TriviaContext.saves);
    expect(anywhere.fitsContext(TriviaContext.library), isTrue);
    expect(anywhere.fitsContext(null), isTrue);
    expect(savesOnly.fitsContext(TriviaContext.saves), isTrue);
    expect(savesOnly.fitsContext(TriviaContext.library), isFalse);
    // Null is a screen the buddy stays off entirely.
    expect(savesOnly.fitsContext(null), isFalse);
  });

  test('every context has a fact written for it', () {
    // An enum value nothing can reach is a screen whose header string is
    // never drawn, which no other test would notice.
    for (final context in TriviaContext.values) {
      expect(seriesTrivia.where((f) => f.context == context), isNotEmpty,
          reason: 'nothing is written for $context');
    }
  });

  group('the buddy', () {
    late Directory modsDir;

    setUp(() {
      SharedPreferences.setMockInitialValues({'soundEffects': false});
      modsDir = Directory.systemTemp.createTempSync('mod_manager_trivia');
    });

    tearDown(() => modsDir.deleteSync(recursive: true));

    Future<AppController> build({List<TriviaFact>? facts}) async {
      final settings = await SettingsStore.load();
      return AppController(
        registry: GameRegistry([
          if (facts == null)
            _FactfulAdapter(modsDir)
          else
            _FactfulAdapter(modsDir, facts: facts),
        ]),
        settings: settings,
      );
    }

    test('is offered for a game with facts and withheld from one without',
        () async {
      expect((await build()).showTrivia, isTrue);
      expect((await build(facts: const [])).showTrivia, isFalse);
    });

    test('the Settings switch takes it away and gives it back', () async {
      final c = await build();
      expect(c.showTrivia, isTrue);
      await c.setTriviaBuddy(false);
      expect(c.showTrivia, isFalse);
      expect(c.triviaOpen, isFalse);
      await c.setTriviaBuddy(true);
      expect(c.showTrivia, isTrue);
    });

    test('the plumbob opens the bubble and puts it away again', () async {
      final c = await build();
      expect(c.triviaOpen, isFalse);
      c.toggleTrivia();
      expect(c.triviaOpen, isTrue);
      c.toggleTrivia();
      expect(c.triviaOpen, isFalse);
      c.toggleTrivia();
      c.closeTrivia();
      expect(c.triviaOpen, isFalse);
    });

    test('stepping walks the whole pool and comes back around', () async {
      final c = await build();
      // Three of the five facts have no context, so the library sees
      // exactly those three.
      expect(c.triviaTotal, 3);
      final seen = <String>[];
      for (var i = 0; i < 3; i++) {
        seen.add(c.triviaFact!.key);
        c.stepTrivia(1);
      }
      expect(seen.toSet(), {'a', 'b', 'd'});
      expect(c.triviaFact!.key, seen.first, reason: 'wrapped to the start');
    });

    test('stepping back is the way it came', () async {
      final c = await build();
      final first = c.triviaFact!.key;
      c.stepTrivia(1);
      expect(c.triviaFact!.key, isNot(first));
      c.stepTrivia(-1);
      expect(c.triviaFact!.key, first);
    });

    test('the counter counts what this screen can actually show', () async {
      final c = await build();
      expect(c.triviaNumber, inInclusiveRange(1, c.triviaTotal));
      c.stepTrivia(1);
      expect(c.triviaNumber, inInclusiveRange(1, c.triviaTotal));
    });

    test('a screen with its own fact can reach it, and others cannot',
        () async {
      final c = await build();
      c.openSaves();
      expect(c.triviaTotal, 4, reason: 'three general facts plus the one');
      final reachable = <String>{};
      for (var i = 0; i < 4; i++) {
        reachable.add(c.triviaFact!.key);
        c.stepTrivia(1);
      }
      expect(reachable, contains('c'));
      expect(reachable, isNot(contains('e')),
          reason: 'that one belongs to the packs shelf');
    });

    test('walking onto another screen steps off a fact that no longer fits',
        () async {
      final c = await build();
      c.openSaves();
      // Land on the saves-only fact.
      while (c.triviaFact!.key != 'c') {
        c.stepTrivia(1);
      }
      c.backToLibrary();
      expect(c.triviaFact!.key, isNot('c'));
      expect(c.triviaFact!.context, isNull);
    });

    test('it shows on the library, the saves and the packs shelf only',
        () async {
      final c = await build();
      expect(c.showTrivia, isTrue, reason: 'library');
      c.openSaves();
      expect(c.showTrivia, isTrue, reason: 'saves');
      // The three it stays off: you came to read or to decide something.
      c.openSettings();
      expect(c.showTrivia, isFalse, reason: 'settings');
      expect(c.triviaOpen, isFalse);
      c.backToLibrary();
      c.toggleTrivia();
      expect(c.triviaOpen, isTrue);
      // Open on the library, then walk to Settings: it goes away rather
      // than following you there, and comes back when you return.
      c.openSettings();
      expect(c.triviaOpen, isFalse);
      c.backToLibrary();
      expect(c.triviaOpen, isTrue);
      // Still "available" throughout, which is what keeps the clock running.
      expect(c.triviaAvailable, isTrue);
    });

    test('another one is always another one', () async {
      final c = await build();
      for (var i = 0; i < 12; i++) {
        final before = c.triviaFact!.key;
        c.shuffleTrivia();
        expect(c.triviaFact!.key, isNot(before));
      }
    });

    test('a deck of one has nowhere to go and says so quietly', () async {
      final c = await build(facts: const [TriviaFact('only', 'lore')]);
      expect(c.triviaTotal, 1);
      c.shuffleTrivia();
      expect(c.triviaFact!.key, 'only');
      c.stepTrivia(1);
      expect(c.triviaFact!.key, 'only');
    });

    // The bubble is a fixed 348px wide regardless of window size, and its
    // header row used to split evenly between the heading and the
    // hairline beside it - two flex children of the same weight, so the
    // heading was capped at *half* the row whatever it said. A lean boot
    // rather than piggybacking on the localization sweep's giant harness:
    // this bug is about layout mechanics, not about a translated dialog,
    // and the fewer moving parts around the assertion the better.
    //
    // One `testWidgets` per language rather than a loop inside one: a
    // `ModManagerApp` rebuilt via `pumpWidget` with a fresh-but-keyless
    // instance is an *update*, not a remount, so its `late final`
    // controller never rebuilds and every iteration past the first would
    // silently keep going against the previous language's tree. Separate
    // tests get a genuinely fresh binding each, which is what the rest of
    // this suite's own per-language sweeps rely on already.
    for (final language in appLanguages) {
      testWidgets('the heading gets the row, not half of it (${language.name})',
          (tester) async {
        // The default test viewport is narrower than kMinWindowSize, and
        // the library toolbar is only guaranteed to fit at that size -
        // an unrelated overflow there would otherwise be mistaken for
        // one this test is actually looking for.
        tester.view.physicalSize = kMinWindowSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        // One real mod, so the library actually finishes loading (an
        // empty folder can leave the setup/scan chrome up, which sits
        // over the corner where the plumbob lives and swallows the tap).
        File('${modsDir.path}/cozy_sofa.package').writeAsStringSync('x');

        SharedPreferences.setMockInitialValues(
            {'soundEffects': false, 'localeCode': language.code});
        final settings = await SettingsStore.load();
        await tester.runAsync(() async {
          await tester.pumpWidget(ModManagerApp(
              registry: GameRegistry([_FactfulAdapter(modsDir)]),
              settings: settings,
              fetchShop: () async => const []));
          await Future<void>.delayed(const Duration(milliseconds: 200));
        });
        await until(tester, find.text('cozy sofa'));
        await tester.pump(const Duration(milliseconds: 500));

        final strings = await L.delegate.load(Locale(language.code));
        await tester.tap(find.byTooltip(strings.triviaOpen));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Whichever fact the shuffle opened on, its heading is either
        // the branded title or the library context line - the only two
        // this deck can show on the library screen.
        final headings = [
          strings.triviaTitle('Fake Game').toUpperCase(),
          strings.triviaContextLibrary.toUpperCase(),
        ];
        final shown = headings
            .where((h) => find.text(h).evaluate().isNotEmpty)
            .toList();
        expect(shown, hasLength(1), reason: 'heading in ${language.name}');
        // Half the bubble's content width (348 minus its side insets) is
        // exactly what the old two-flex-children row would have allowed.
        // Every heading here is longer than that under the test font, so
        // anything at or below it means the half-row cap is back.
        expect(tester.getSize(find.text(shown.single)).width,
            greaterThan((348 - 17 * 2) / 2),
            reason: 'heading width in ${language.name}');

        await tester.tap(find.byTooltip(strings.triviaClose));
        await tester.pump();
      });
    }
  });
}
