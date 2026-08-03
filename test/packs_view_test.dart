import 'dart:io';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/app_message.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/bitmap.dart';
import 'package:sims_mod_manager/src/core/game_pack.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app.dart';
import 'package:sims_mod_manager/src/ui/packs_view.dart';
import 'package:sims_mod_manager/src/ui/widgets.dart';

import 'until.dart';

class _FakeAdapter extends FolderBasedGameAdapter {
  _FakeAdapter(
    this.dir, {
    this.packs = const [],
    this.demo = const [],
    this.hasPacks = true,
    this.canTogglePacks = true,
    this.packToggleNeedsAdmin = false,
    this.packToggleIsExperimental = false,
    this.failToggle = false,
    this.note,
  });

  /// The shelf this game invents for demo mode, when it has one.
  final List<GamePack> demo;

  @override
  List<GamePack> demoPacks() => demo;

  /// What this game has to say about the collection, if anything.
  final AppMessage? note;

  @override
  AppMessage? packCollectionNote(List<GamePack> packs) => note;

  @override
  final bool packToggleNeedsAdmin;

  @override
  final bool packToggleIsExperimental;

  final Directory dir;
  List<GamePack> packs;

  @override
  final bool hasPacks;

  @override
  final bool canTogglePacks;

  /// Stands in for a write the OS refused (the game holding the file).
  final bool failToggle;

  /// How often the packs were (re)read, for the lazy-load assertions.
  int packScans = 0;

  /// What the screen actually asked for, in order.
  final List<(String, bool)> toggles = [];

  @override
  Game get game =>
      const Game(id: 'fake', name: 'Fake Game', series: 'Test', year: 2024);

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  String get setupHelpKey => 'test adapter';

  @override
  Future<String?> defaultModsPath() async => dir.path;

  /// No isolates under the widget test's fake-async zone.
  @override
  Future<Map<String, PackageInsight>> inspectMods(
    List<Mod> mods, {
    void Function(int done, int total)? onProgress,
    void Function(Map<String, PackageInsight> found)? onFound,
    bool Function()? isCancelled,
  }) async =>
      const {};

  @override
  Future<List<GamePack>> listPacks() async {
    packScans++;
    return packs;
  }

  @override
  Future<void> setPackEnabled(GamePack pack, {required bool enabled}) async {
    toggles.add((pack.code, enabled));
    if (failToggle) {
      throw const PackActionException(AppMessage('errorPackNoUserData'));
    }
    packs = [
      for (final p in packs)
        p.code == pack.code ? p.copyWith(isEnabled: enabled) : p,
    ];
  }
}

const _packs = [
  GamePack(
    code: 'EP01',
    name: 'Get to Work',
    kind: GamePackKind.expansion,
    sizeBytes: 2 * 1000 * 1024 * 1024,
    localizedNames: {'de': 'An die Arbeit'},
  ),
  GamePack(code: 'GP04', name: 'Vampires', kind: GamePackKind.gamePack),
  GamePack(
    code: 'SP20',
    name: 'Throwback Fit Kit',
    kind: GamePackKind.kit,
    isEnabled: false,
  ),
];

Future<_FakeAdapter> _pumpApp(WidgetTester tester, _FakeAdapter adapter,
    {bool demoLibrary = false}) async {
  tester.view.physicalSize = const Size(1280, 824);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(
      {'soundEffects': false, if (demoLibrary) 'demoLibrary': true});
  final settings = await SettingsStore.load();
  await tester.runAsync(() async {
    await tester.pumpWidget(
        ModManagerApp(registry: GameRegistry([adapter]), settings: settings));
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });
  await until(tester, find.text('Fake Game Library'));
  await tester.pump(const Duration(milliseconds: 400));
  return adapter;
}

_FakeAdapter _adapter({
  List<GamePack> packs = _packs,
  List<GamePack> demo = const [],
  bool hasPacks = true,
  bool canTogglePacks = true,
  bool packToggleNeedsAdmin = false,
  bool packToggleIsExperimental = false,
  bool failToggle = false,
  AppMessage? note,
}) {
  final dir = Directory.systemTemp.createTempSync('packs_view');
  addTearDown(() => dir.deleteSync(recursive: true));
  File(p.join(dir.path, 'a_mod.package')).writeAsStringSync('bytes');
  return _FakeAdapter(dir,
      packs: packs,
      demo: demo,
      hasPacks: hasPacks,
      canTogglePacks: canTogglePacks,
      packToggleNeedsAdmin: packToggleNeedsAdmin,
      packToggleIsExperimental: packToggleIsExperimental,
      failToggle: failToggle,
      note: note);
}

/// Taps a sidebar entry and waits for the screen to settle: the switcher
/// to finish its fade (until then the outgoing screen's header shares a
/// word with the sidebar) and the packs to finish loading.
///
/// Waits for the screen rather than for a fixed number of milliseconds,
/// because the load is real async work and a machine running the whole
/// suite at once does not finish it on any schedule worth guessing at.
Future<void> _tapNav(WidgetTester tester, String label, {Finder? ready}) async {
  await tester.tap(find.text(label).first);
  await tester.pump();
  if (ready != null) await until(tester, ready);
  await untilGone(
      tester,
      find.descendant(
          of: find.byType(PacksView),
          matching: find.byType(CircularProgressIndicator)));
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _openPacks(WidgetTester tester) =>
    _tapNav(tester, 'Packs', ready: find.byType(PacksView));

/// The switches on the packs screen itself. Scoped, because the library
/// the screen switcher is fading out has switches of its own.
Finder get _packSwitches => find.descendant(
    of: find.byType(PacksView), matching: find.byType(PillSwitch));

void main() {
  testWidgets('the packs screen lists each tier with what it holds',
      (tester) async {
    final adapter = await _pumpApp(tester, _adapter());

    // Nothing is read from disk until the screen is opened.
    expect(adapter.packScans, 0);
    await _openPacks(tester);
    expect(adapter.packScans, 1);

    // A section per tier, in the order the game's own list uses.
    expect(find.text('Expansion packs'), findsOneWidget);
    expect(find.text('Game packs'), findsOneWidget);
    expect(find.text('Kits'), findsOneWidget);
    // Tiers nothing is installed for are not drawn at all.
    expect(find.text('Stuff packs'), findsNothing);

    // The packs themselves, with the code and size the install reported.
    expect(find.text('Get to Work'), findsOneWidget);
    expect(find.text('Vampires'), findsOneWidget);
    expect(find.textContaining('EP01'), findsWidgets);
    expect(find.textContaining('2.0 GB'), findsOneWidget);

    // Two on, one off - and the one that is off says so.
    expect(find.text('2 packs on, 1 switched off'), findsOneWidget);
    expect(find.textContaining('Off'), findsWidgets);

    // Reopening does not rescan; that is the refresh button's job.
    await _tapNav(tester, 'Library');
    await _openPacks(tester);
    expect(adapter.packScans, 1);
  });

  testWidgets('switching a pack off asks the adapter and says to restart',
      (tester) async {
    final adapter = await _pumpApp(tester, _adapter());
    await _openPacks(tester);

    // Nothing to restart for until something is actually changed.
    expect(find.textContaining('Restart'), findsNothing);

    await tester.runAsync(() async {
      await tester.tap(_packSwitches.first);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump(const Duration(milliseconds: 400));

    expect(adapter.toggles, [('EP01', false)]);
    expect(find.textContaining('Restart Fake Game'), findsOneWidget);
    // The switch moved with the press rather than waiting for a rescan.
    expect(find.text('1 pack on, 2 switched off'), findsOneWidget);
  });

  testWidgets('a refused switch goes back and says what went wrong',
      (tester) async {
    final adapter = await _pumpApp(tester, _adapter(failToggle: true));
    await _openPacks(tester);

    await tester.runAsync(() async {
      await tester.tap(_packSwitches.first);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump(const Duration(milliseconds: 400));

    expect(adapter.toggles, [('EP01', false)]);
    // Put back the way it was, and the reason is on screen.
    expect(find.text('2 packs on, 1 switched off'), findsOneWidget);
    expect(find.textContaining('settings folder'), findsOneWidget);
    // Nothing to restart for: nothing actually changed.
    expect(find.textContaining('Restart Fake Game'), findsNothing);
  });

  testWidgets('a game that only lists packs shows no switches',
      (tester) async {
    await _pumpApp(tester, _adapter(canTogglePacks: false));
    await _openPacks(tester);

    expect(find.text('Get to Work'), findsOneWidget);
    expect(_packSwitches, findsNothing);
    expect(find.text('Installed'), findsWidgets);
  });

  testWidgets('and the one pack that cannot be switched gets no switch',
      (tester) async {
    // The Sims 2's Mansion & Garden owns the executable the collection
    // runs from, so asking for it is refused - a switch that moves and
    // then snaps back is a worse answer than a fact.
    final adapter = await _pumpApp(
        tester,
        _adapter(packs: const [
          GamePack(code: 'EP01', name: 'University', kind: GamePackKind.expansion),
          GamePack(
            code: 'EP09',
            name: 'Mansion & Garden Stuff',
            kind: GamePackKind.expansion,
            canToggle: false,
          ),
        ]));
    await _openPacks(tester);

    expect(find.text('Mansion & Garden Stuff'), findsOneWidget);
    // One switch for the pack that has one, and none for the other.
    expect(_packSwitches, findsOneWidget);
    expect(find.text('Installed'), findsOneWidget);
    expect(adapter.toggles, isEmpty);
  });

  testWidgets('a game with no packs at all has no packs screen',
      (tester) async {
    await _pumpApp(tester, _adapter(hasPacks: false));
    expect(find.text('Packs'), findsNothing);
  });

  testWidgets('an install the app cannot see gets the empty state',
      (tester) async {
    final adapter = await _pumpApp(tester, _adapter(packs: const []));
    await _openPacks(tester);

    expect(find.text('No packs found'), findsOneWidget);
    expect(find.text('Check again'), findsOneWidget);

    await tester.runAsync(() async {
      await tester.tap(find.text('Check again'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump(const Duration(milliseconds: 400));
    expect(adapter.packScans, 2);
  });

  testWidgets('a pack draws its own artwork when the install ships some',
      (tester) async {
    // A real (tiny) PNG, so the widget decodes rather than falls back.
    final icon = encodePng(
        1, 1, Uint8List.fromList([0x20, 0x40, 0x60, 0xFF]),
        hasAlpha: true);
    await _pumpApp(
        tester,
        _adapter(packs: [
          GamePack(
              code: 'EP01',
              name: 'World Adventures',
              kind: GamePackKind.expansion,
              icon: icon),
          const GamePack(
              code: 'SP01', name: 'High-End Loft', kind: GamePackKind.stuff),
        ]));
    await _openPacks(tester);

    final images = find.descendant(
        of: find.byType(PacksView), matching: find.byType(Image));
    // Exactly the one pack that has artwork; the other keeps its code.
    expect(images, findsOneWidget);
    expect(find.textContaining('SP01'), findsWidgets);
  });

  testWidgets('a game whose packs need admin says so instead of switching',
      (tester) async {
    // Tests never run elevated, so this is the state a normal launch is in.
    final adapter =
        await _pumpApp(tester, _adapter(packToggleNeedsAdmin: true));
    await _openPacks(tester);

    expect(find.textContaining('administrator'), findsOneWidget);
    // No switch to press, so nothing can snap back under the finger.
    expect(_packSwitches, findsNothing);
    expect(adapter.toggles, isEmpty);
    // The packs are still all there to look at.
    expect(find.text('Get to Work'), findsOneWidget);
  });

  testWidgets('an experimental game warns and offers no switches until asked',
      (tester) async {
    final adapter = await _pumpApp(
        tester, _adapter(packToggleIsExperimental: true));
    await _openPacks(tester);

    // The warning is up, and it points at where to turn them on.
    expect(find.text('Switching these off is experimental'), findsOneWidget);
    expect(find.textContaining('Settings'), findsWidgets);
    // Nothing to press, so nothing can be lost by pressing it.
    expect(_packSwitches, findsNothing);
    expect(adapter.toggles, isEmpty);
    // The packs themselves still list, which is the safe half.
    expect(find.text('Get to Work'), findsOneWidget);
  });

  testWidgets('and once it is asked for, the warning stays and the switches work',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {'soundEffects': false, 'experimentalPackToggles': true});
    final adapter = _adapter(packToggleIsExperimental: true);
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final settings = await SettingsStore.load();
    await tester.runAsync(() async {
      await tester.pumpWidget(
          ModManagerApp(registry: GameRegistry([adapter]), settings: settings));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await until(tester, find.text('Fake Game Library'));
    await tester.pump(const Duration(milliseconds: 400));
    await _openPacks(tester);

    // Agreeing to a risk does not make it go away, so it still says so -
    // but now it says what to do rather than where the switch is.
    expect(find.text('Switching these off is experimental'), findsOneWidget);
    expect(find.textContaining('Back up your neighbourhoods'), findsOneWidget);
    expect(_packSwitches, findsWidgets);

    await tester.runAsync(() async {
      await tester.tap(_packSwitches.first);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump(const Duration(milliseconds: 400));
    expect(adapter.toggles, [('EP01', false)]);
  });

  testWidgets('a pack is named in the language the app is running in',
      (tester) async {
    SharedPreferences.setMockInitialValues(
        {'soundEffects': false, 'localeCode': 'de'});
    final adapter = _adapter();
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final settings = await SettingsStore.load();
    await tester.runAsync(() async {
      await tester.pumpWidget(
          ModManagerApp(registry: GameRegistry([adapter]), settings: settings));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await until(tester, find.text('Fake Game-Bibliothek'));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Packs'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // The install's own translation wins for the pack that has one.
    expect(find.text('An die Arbeit'), findsOneWidget);
    // The one that has none stays in English rather than blanking out.
    expect(find.text('Vampires'), findsOneWidget);
  });

  testWidgets('demo mode shelves invented packs and writes nothing',
      (tester) async {
    const invented = [
      GamePack(
          code: 'EP05',
          name: 'Seasons',
          kind: GamePackKind.expansion,
          sizeBytes: 3 * 1024 * 1024 * 1024),
      GamePack(
          code: 'GP08',
          name: 'Realm of Magic',
          kind: GamePackKind.gamePack,
          isEnabled: false),
    ];
    // A machine with the game nowhere to be found, which is the one demo
    // mode exists for: the real read would answer with nothing.
    final adapter = await _pumpApp(
        tester, _adapter(packs: const [], demo: invented),
        demoLibrary: true);
    await _openPacks(tester);

    expect(find.text('Seasons'), findsOneWidget);
    expect(find.text('Realm of Magic'), findsOneWidget);
    // Nothing was read off the disk to put them there.
    expect(adapter.packScans, 0);

    // And a switch on an invented pack moves without a write behind it.
    await tester.runAsync(() async {
      await tester.tap(_packSwitches.first);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump(const Duration(milliseconds: 400));
    expect(adapter.toggles, isEmpty);
    expect(find.textContaining('Restart'), findsWidgets);
  });

  testWidgets('a collection worth remarking on gets remarked on',
      (tester) async {
    await _pumpApp(
        tester,
        _adapter(
            note: const AppMessage('packsAllOwnedSims4', ['21', '12'])));
    await _openPacks(tester);

    expect(find.textContaining('Sure you bought them all'), findsOneWidget);
    expect(find.textContaining('21 expansions'), findsOneWidget);
  });

  testWidgets('and a game with nothing to say says nothing', (tester) async {
    await _pumpApp(tester, _adapter());
    await _openPacks(tester);
    expect(find.textContaining('Sure you bought'), findsNothing);
  });

  testWidgets('a remark nobody has worded yet draws nothing', (tester) async {
    // The wording is looked up when it is drawn, so an adapter can hand
    // over a key the ARB files have never heard of - and the screen must
    // not put that key on it.
    await _pumpApp(tester, _adapter(note: const AppMessage('somethingNew')));
    await _openPacks(tester);
    expect(find.textContaining('somethingNew'), findsNothing);
  });
}
