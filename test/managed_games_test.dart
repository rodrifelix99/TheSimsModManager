import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';
import 'package:sims_mod_manager/src/ui/plumbob_icons.dart';
import 'package:sims_mod_manager/src/ui/widgets.dart';

/// Which games the sidebar shows, which one the app opens on, and what a
/// game without artwork of its own is drawn with.
///
/// The registry here is invented rather than the real one, so these hold
/// whatever games ship: what is being pinned is the rule, not the roster.
class _Adapter extends FolderBasedGameAdapter {
  const _Adapter(this.id, this.title, this.franchise, this.released);

  final String id;
  final String title;
  final String franchise;
  final int released;

  @override
  Game get game =>
      Game(id: id, name: title, series: franchise, year: released);

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  String get setupHelpKey => 'test';

  @override
  Future<String?> defaultModsPath() async => null;
}

const _sims = [
  _Adapter('sims1', 'The Sims', 'The Sims', 2000),
  _Adapter('sims4', 'The Sims 4', 'The Sims', 2014),
];
const _simcity = [
  _Adapter('simcity4', 'SimCity 4', 'SimCity', 2003),
  _Adapter('simcity2013', 'SimCity', 'SimCity', 2013),
];

Future<AppController> controllerWith(Map<String, Object> prefs) async {
  SharedPreferences.setMockInitialValues({'soundEffects': false, ...prefs});
  return AppController(
    registry: GameRegistry([..._sims, ..._simcity]),
    settings: await SettingsStore.load(),
    checkUpdates: () async => null,
  );
}

void main() {
  group('which games are managed', () {
    test('nobody has answered: every registered game, as before', () async {
      final c = await controllerWith({});
      expect(c.managedAdapters.map((a) => a.game.id),
          ['sims1', 'sims4', 'simcity4', 'simcity2013']);
    });

    test('an existing Sims user keeps every Sims game after the update',
        () async {
      // The migration case: an install with settings but no answer to a
      // question that did not exist. Nothing may disappear from their
      // sidebar because a franchise was added.
      final c = await controllerWith({
        'onboardingDone': true,
        'defaultGame': 'sims4',
        'modsPath.sims4': r'C:\somewhere',
      });
      expect(c.managedAdapters.map((a) => a.game.id),
          containsAll(['sims1', 'sims4']));
      expect(c.adapter.game.id, 'sims4');
    });

    test('a SimCity-only user sees only SimCity', () async {
      final c = await controllerWith({
        'managedGames': ['simcity4', 'simcity2013'],
      });
      expect(c.managedAdapters.map((a) => a.game.id),
          ['simcity4', 'simcity2013']);
      expect(c.adapter.game.id, 'simcity4',
          reason: 'no franchise is preferred when nobody named a default');
    });

    test('a mixed user gets both, in registry order', () async {
      final c = await controllerWith({
        'managedGames': ['simcity4', 'sims4'],
      });
      expect(c.managedAdapters.map((a) => a.game.id), ['sims4', 'simcity4']);
    });

    test('one managed game is a legitimate answer', () async {
      final c = await controllerWith({
        'managedGames': ['simcity2013'],
      });
      expect(c.managedAdapters.map((a) => a.game.id), ['simcity2013']);
      expect(c.adapter.game.id, 'simcity2013');
    });

    test('an id from a build that had a game this one does not is dropped',
        () async {
      final c = await controllerWith({
        'managedGames': ['sims4', 'simcity5000', ''],
      });
      expect(c.managedAdapters.map((a) => a.game.id), ['sims4']);
    });

    test('a stored list that leaves nothing standing falls back to all',
        () async {
      final c = await controllerWith({
        'managedGames': ['a-game-that-was-removed'],
      });
      expect(c.managedAdapters.length, 4,
          reason: 'an app with no games in it is no way to say anything');
    });

    test('a default game that is no longer managed is not opened', () async {
      final c = await controllerWith({
        'defaultGame': 'sims1',
        'managedGames': ['simcity4', 'simcity2013'],
      });
      expect(c.adapter.game.id, 'simcity4');
    });

    test('hiding a game keeps every setting it had', () async {
      final c = await controllerWith({
        'modsPath.sims1': r'C:\sims1\Downloads',
        'ignoredConflicts': '{"sims1":["a|b"]}',
      });
      await c.setGameManaged('sims1', false);
      expect(c.isManagedGame('sims1'), isFalse);
      expect(c.settings.modsPathOverride('sims1'), r'C:\sims1\Downloads',
          reason: 'hiding a game is about the sidebar, not about its files');

      await c.setGameManaged('sims1', true);
      expect(c.isManagedGame('sims1'), isTrue);
    });

    test('the last game cannot be hidden, and says so', () async {
      final c = await controllerWith({'managedGames': ['sims4']});
      await c.setGameManaged('sims4', false);
      expect(c.managedAdapters.map((a) => a.game.id), ['sims4']);
      expect(c.lastError, isNotNull,
          reason: 'a switch that silently refuses to move looks broken');
    });

    test('hiding the game on screen moves to one that is left', () async {
      final c = await controllerWith({'defaultGame': 'sims1'});
      expect(c.adapter.game.id, 'sims1');
      await c.setGameManaged('sims1', false);
      expect(c.adapter.game.id, isNot('sims1'));
      expect(c.settings.defaultGameId, isNull,
          reason: 'a default nobody can see is not a default');
    });

    test('the stored order is the registry order, not the click order',
        () async {
      final c = await controllerWith({'managedGames': ['simcity2013']});
      await c.setGameManaged('sims1', true);
      await c.setGameManaged('simcity4', true);
      expect(c.settings.managedGameIds, ['sims1', 'simcity4', 'simcity2013']);
    });
  });

  group('how the sidebar groups them', () {
    test('one franchise is not drawn as a group', () async {
      final c = await controllerWith({'managedGames': ['sims1', 'sims4']});
      expect(c.managedGroups.length, 1);
      expect(c.managedGroups.single.series, 'The Sims');
    });

    test('two franchises keep registry order, and their games with them',
        () async {
      final c = await controllerWith({});
      expect(c.managedGroups.map((g) => g.series), ['The Sims', 'SimCity']);
      expect(c.managedGroups.first.adapters.map((a) => a.game.id),
          ['sims1', 'sims4']);
      expect(c.managedGroups.last.adapters.map((a) => a.game.id),
          ['simcity4', 'simcity2013']);
    });

    test('a franchise with nothing managed does not draw a heading',
        () async {
      final c = await controllerWith({'managedGames': ['simcity4']});
      expect(c.managedGroups.map((g) => g.series), ['SimCity']);
    });
  });

  group('what a game without artwork is drawn with', () {
    test('the Sims games keep their own plumbobs', () {
      for (final id in ['sims1', 'sims2', 'sims3', 'sims4', 'simsmedieval']) {
        expect(plumbobAsset(id), isNotNull, reason: id);
      }
    });

    test('a SimCity game is never handed The Sims own emblem', () {
      for (final id in [
        'simcity3000',
        'simcity4',
        'simcitysocieties',
        'simcity2013',
      ]) {
        expect(plumbobAsset(id), isNull,
            reason: '$id must not borrow a plumbob');
      }
    });

    test('a game nobody has shipped art for degrades to null, not to Sims 4',
        () {
      expect(plumbobAsset('a-game-from-next-year'), isNull);
      expect(brandMarkAsset('a-game-from-next-year'), isNull);
    });

    test('every SimCity game draws the series own mark', () {
      for (final id in [
        'simcity3000',
        'simcity4',
        'simcitysocieties',
        'simcity2013',
      ]) {
        expect(brandMarkAsset(id),
            'assets/games/logos/simcity_manager_logo.webp',
            reason: id);
      }
    });

    test('a Sims game keeps its plumbob as its mark', () {
      expect(brandMarkAsset('sims4'), plumbobAsset('sims4'));
    });

    testWidgets('the neutral badge draws the game initial in both themes',
        (tester) async {
      for (final brightness in Brightness.values) {
        await tester.pumpWidget(MaterialApp(
          theme: ThemeData(brightness: brightness),
          home: const Scaffold(
            body: BrandMark(
                gameId: 'a-game-from-next-year', name: 'Spore', size: 30),
          ),
        ));
        expect(find.text('S'), findsOneWidget);
        expect(find.byType(Image), findsNothing,
            reason: 'nothing is loaded for a game with no artwork');
      }
    });

    testWidgets('a game with no name at all still draws something',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: BrandMark(gameId: 'unknown', size: 30)),
      ));
      expect(tester.takeException(), isNull);
    });
  });
}
