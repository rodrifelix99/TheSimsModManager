import 'dart:async';
import 'dart:io';
import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/services/mod_shop.dart';
import 'package:sims_mod_manager/src/services/reachability.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app.dart';

import 'until.dart';

/// The blocked case is otherwise only reachable from inside a country,
/// which is the whole reason the probe is injectable.

class _FakeAdapter extends FolderBasedGameAdapter {
  _FakeAdapter(this.dir);

  final Directory dir;

  /// The real implementation reads files in isolates the widget test's
  /// fake-async zone can't wait on.
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
  String get setupHelpKey => 'test adapter';

  @override
  Future<String?> defaultModsPath() async => dir.path;
}

/// Builds the app with a probe that answers [reachability], and returns
/// once the launch path has settled.
Future<Directory> _pump(
  WidgetTester tester, {
  required Future<Reachability> Function(String? mirrorBase) probe,
  Map<String, Object> prefs = const {},
  Future<List<ShopMod>?> Function()? fetchShop,
}) async {
  tester.view.physicalSize = const Size(1280, 824);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({
    'soundEffects': false,
    ...prefs,
  });
  final tempDir = Directory.systemTemp.createTempSync('reach');
  addTearDown(() => tempDir.deleteSync(recursive: true));

  final registry = GameRegistry([_FakeAdapter(tempDir)]);
  final settings = await SettingsStore.load();

  await tester.runAsync(() async {
    await tester.pumpWidget(ModManagerApp(
      registry: registry,
      settings: settings,
      probeServices: probe,
      fetchShop: fetchShop ?? () async => const <ShopMod>[],
    ));
    await Future<void>.delayed(const Duration(milliseconds: 200));
  });
  await until(tester, find.text('Fake Game Library'));
  await tester.pump(const Duration(milliseconds: 400));
  return tempDir;
}

void main() {
  test('nothing asked yet reads as reachable', () {
    // The same bargain the feature flags make: a machine that never got
    // an answer keeps its features.
    expect(Reachability.unknown.shop, isTrue);
    expect(Reachability.unknown.site, isTrue);
  });

  testWidgets(
      'a catalog that cannot be reached takes The Exchange off the '
      'sidebar', (tester) async {
    await _pump(
      tester,
      probe: (_) async =>
          const Reachability(shop: false, site: false, downloads: false),
    );

    expect(find.text('The Exchange'), findsNothing);
  });

  testWidgets('everything answering leaves The Exchange where it was',
      (tester) async {
    await _pump(tester, probe: (_) async => Reachability.unknown);

    expect(find.text('The Exchange'), findsOneWidget);
  });

  testWidgets('a machine on a VPN keeps the shop, in the same country',
      (tester) async {
    // Nothing here knows or asks where the user is: the probe answered,
    // so the shop is offered. That is the whole point of asking the
    // socket rather than the country.
    await _pump(
      tester,
      probe: (_) async =>
          const Reachability(shop: true, site: true, downloads: true),
      prefs: {'reachShop': false, 'reachSite': false},
    );

    expect(find.text('The Exchange'), findsOneWidget);
  });

  testWidgets('the first frame follows what the last launch found',
      (tester) async {
    // A probe that never answers: what is drawn can only have come from
    // the stored result, which is the point of storing it.
    await _pump(
      tester,
      probe: (_) => Completer<Reachability>().future,
      prefs: {'reachShop': false, 'reachSite': false},
    );

    expect(find.text('The Exchange'), findsNothing);
  });

  testWidgets(
      'the launch poll for mod updates is skipped when the catalog '
      'is out of reach', (tester) async {
    var fetched = 0;
    await _pump(
      tester,
      probe: (_) async =>
          const Reachability(shop: false, site: false, downloads: false),
      prefs: {
        'reachShop': false,
        'shop.installs':
            '{"abc":{"game":"fake","version":"1.0","files":["a.package"]}}',
      },
      fetchShop: () async {
        fetched++;
        return const <ShopMod>[];
      },
    );

    // The fetch would have spent its whole timeout to learn what the
    // stored probe result already said.
    expect(fetched, 0);
  });

  testWidgets('a catalog that goes out of reach takes the screen with it',
      (tester) async {
    // The one case the Settings scenario picker cannot stage: the card
    // has to be openable when the answer lands, so the stored answer
    // says reachable and the probe disagrees a moment later.
    final probe = Completer<Reachability>();
    await _pump(tester, probe: (_) => probe.future);
    expect(find.text('The Exchange'), findsOneWidget);

    await tester.tap(find.text('The Exchange'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('ALPHA'), findsOneWidget);

    probe.complete(
        const Reachability(shop: false, site: false, downloads: false));
    await untilGone(tester, find.text('The Exchange'));
    await tester.pump(const Duration(milliseconds: 400));

    // The sidebar card is about to stop being drawn; leaving the user on
    // the shop would strand them on a screen with no way back to it.
    expect(find.text('The Exchange'), findsNothing);
    expect(find.textContaining('mods on the shelves'), findsNothing);
  });

  test('a scenario id names a state, and anything else names none', () {
    expect(debugReachabilityFor('china')?.shop, isFalse);
    expect(debugReachabilityFor('china')?.downloads, isFalse);
    // api.github.com is not among these: the update check finds a
    // release in China, which is why only the files need rerouting.
    expect(debugReachabilityFor('downloads')?.shop, isTrue);
    expect(debugReachabilityFor('downloads')?.downloads, isFalse);
    expect(debugReachabilityFor(null), isNull);
    expect(debugReachabilityFor('nonsense'), isNull);
  });

  testWidgets('a forced scenario answers instead of the network',
      (tester) async {
    var probed = 0;
    await _pump(
      tester,
      probe: (_) async {
        probed++;
        return Reachability.unknown;
      },
      // Everything says reachable: the stored answer, and the probe that
      // would overwrite it. Only the scenario says otherwise.
      prefs: {'debugReachability': 'china'},
    );

    expect(find.text('The Exchange'), findsNothing);
    // Not asked at all - a forced answer is not a probe with a thumb on
    // it, and a developer testing the blocked case should not be sending
    // HEAD requests to find out what they already decided.
    expect(probed, 0);
  });

  testWidgets('a forced scenario is never written down', (tester) async {
    await _pump(
      tester,
      probe: (_) async => Reachability.unknown,
      prefs: {'debugReachability': 'blocked'},
    );
    expect(find.text('The Exchange'), findsNothing);

    // The shipped build reads these same preferences and re-seeds from
    // them on launch. A scenario that persisted would open it with The
    // Exchange missing until its own probe answered.
    final prefs = await tester.runAsync(SharedPreferences.getInstance);
    expect(prefs!.getBool('reachShop'), isNull);
    expect(prefs.getBool('reachSite'), isNull);
    expect(prefs.getBool('reachDownloads'), isNull);
    expect(prefs.getBool('reachMirror'), isNull);
  });

  testWidgets('with no scenario picked the network is asked as before',
      (tester) async {
    var probed = 0;
    await _pump(
      tester,
      probe: (_) async {
        probed++;
        return const Reachability(shop: false, site: false, downloads: false);
      },
    );

    expect(probed, 1);
    expect(find.text('The Exchange'), findsNothing);
    // And that answer, being a real one, is the one that gets stored.
    final prefs = await tester.runAsync(SharedPreferences.getInstance);
    expect(prefs!.getBool('reachShop'), isFalse);
  });
}
