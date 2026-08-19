import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod_catalog.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';

/// A catalog that answers from memory, so the rule under test is the
/// visibility rule and not the network.
class _Catalog extends ModCatalog {
  const _Catalog(this.gameId, this.label);

  final String gameId;
  final String label;

  @override
  CatalogSource get source => CatalogSource(
        id: '$gameId-$label',
        gameId: gameId,
        label: label,
        projectName: 'testpac',
        projectUrl: Uri.parse('https://example.test/'),
      );

  @override
  Future<List<CatalogEntry>?> fetchEntries() async => [
        CatalogEntry(
          sourceId: source.id,
          id: '$gameId:one',
          name: 'One',
          version: '1.0',
        ),
      ];

  @override
  Future<CatalogListing?> fetchListing(
    CatalogEntry entry, {
    Map<String, String> selection = const {},
  }) async =>
      CatalogListing(entry: entry, reach: CatalogReach.direct);
}

class _Adapter extends FolderBasedGameAdapter {
  const _Adapter(this.dir, this.id, this.catalogList, {this.series = 'test'});

  final Directory dir;
  final String id;
  final List<ModCatalog> catalogList;
  final String series;

  @override
  Game get game => Game(id: id, name: id, series: series, year: 2000);

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  String get setupHelpKey => 'sims4';

  @override
  Future<String?> defaultModsPath() async => dir.path;

  @override
  List<ModCatalog> catalogs() => catalogList;
}

void main() {
  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('catalog_vis_');
  });

  tearDown(() {
    try {
      root.deleteSync(recursive: true);
    } catch (_) {}
  });

  Future<AppController> makeController() async {
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final controller = AppController(
      // The game with a catalog is deliberately not the one the sidebar
      // opens on, which is the whole case this rule is about.
      registry: GameRegistry([
        _Adapter(root, 'plain', const []),
        _Adapter(root, 'withcatalog', const [_Catalog('withcatalog', 'Main')]),
      ]),
      settings: await SettingsStore.load(),
      checkUpdates: () async => null,
    );
    await controller.refresh();
    return controller;
  }

  test('a catalog is found even when the sidebar is on another game',
      () async {
    final c = await makeController();
    expect(c.adapter.game.id, 'plain', reason: 'sidebar is on the other game');
    expect(c.catalogs, hasLength(1),
        reason: 'catalogs come off the registry, not the selected game');
  });

  test('All games shows the chips', () async {
    final c = await makeController();
    expect(c.shopGameFilter, isNull);
    expect(c.visibleCatalogs.map((x) => x.source.gameId), ['withcatalog']);
    expect(c.hasCatalogs, isTrue);
  });

  test('filtering to the catalog\'s own game shows the chips', () async {
    final c = await makeController();
    c.setShopGameFilter('withcatalog');
    expect(c.hasCatalogs, isTrue);
    expect(c.visibleCatalogs, hasLength(1));
  });

  test('filtering to another game hides them', () async {
    final c = await makeController();
    c.setShopGameFilter('plain');
    expect(c.visibleCatalogs, isEmpty);
    expect(c.hasCatalogs, isFalse);
  });

  test('narrowing away from the shelf you are on drops back to The Exchange',
      () async {
    final c = await makeController();
    c.setShopCatalogSource('withcatalog-Main');
    expect(c.showingCatalog, isTrue);

    c.setShopGameFilter('plain');
    expect(c.showingCatalog, isFalse,
        reason: 'a shelf with no chip selecting it must not stay up');
    expect(c.selectedCatalogEntry, isNull);
  });

  test('narrowing to the catalog\'s own game leaves the shelf up', () async {
    final c = await makeController();
    c.setShopCatalogSource('withcatalog-Main');
    c.setShopGameFilter('withcatalog');
    expect(c.showingCatalog, isTrue);
  });

  test('an entry resolves to the adapter of its own game', () async {
    final c = await makeController();
    await c.refreshCatalog();
    final entry = c.catalogEntries!.single;
    expect(c.catalogAdapterOf(entry)?.game.id, 'withcatalog',
        reason: 'installs must land in the folder of the game that reads them');
  });

  group('grouping', () {
    Future<AppController> twoSeries() async {
      SharedPreferences.setMockInitialValues({'soundEffects': false});
      final controller = AppController(
        registry: GameRegistry([
          _Adapter(root, 'older', const [_Catalog('older', 'Attic')],
              series: 'Older Series'),
          _Adapter(root, 'newer', const [
            _Catalog('newer', 'Main'),
            _Catalog('newer', 'Second'),
          ], series: 'Newer Series'),
        ]),
        settings: await SettingsStore.load(),
        checkUpdates: () async => null,
      );
      await controller.refresh();
      return controller;
    }

    test('chips gather under the series of the game they index', () async {
      final c = await twoSeries();
      final grouped = c.catalogsBySeries;
      expect(grouped.keys, ['Older Series', 'Newer Series'],
          reason: 'registry order, which is by release year');
      expect(grouped['Newer Series']!.map((x) => x.source.label),
          ['Main', 'Second']);
      expect(grouped['Older Series']!, hasLength(1));
    });

    test('narrowing to one game leaves only that series', () async {
      final c = await twoSeries();
      c.setShopGameFilter('newer');
      expect(c.catalogsBySeries.keys, ['Newer Series']);
    });

    test('a game with no catalog contributes no group', () async {
      final c = await makeController();
      expect(c.catalogsBySeries.keys, hasLength(1),
          reason: 'the plain game has no catalogs and so no heading');
    });
  });
}
