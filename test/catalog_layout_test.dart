import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/mod_catalog.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app.dart';
import 'package:sims_mod_manager/src/ui/l10n.dart';

import 'until.dart';

/// The source row puts a series heading and three store names on one
/// line, and the promo puts a button beside a paragraph. Both are new
/// shapes for this app, and translations run longer than English - which
/// is where a layout gives way first. Same sweep the rest of the screens
/// get in localization_test, run here so the catalog is measured too.

/// A catalog answering from memory: this is a layout test, and a real
/// channel would make it a network test that sometimes fails.
class _Catalog extends ModCatalog {
  const _Catalog(this.label);

  final String label;

  @override
  CatalogSource get source => CatalogSource(
        id: 'fake-$label',
        gameId: 'fake',
        label: label,
        projectName: 'sc4pac',
        projectUrl: Uri.parse('https://example.test/'),
      );

  @override
  Future<List<CatalogEntry>?> fetchEntries() async => [
        for (var i = 0; i < 6; i++)
          CatalogEntry(
            sourceId: source.id,
            id: 'fake:entry$i',
            name: 'A Reasonably Long Mod Name $i',
            version: '1.0',
            summary: 'Something to look at.',
            categories: const ['100-props-textures'],
          ),
      ];

  @override
  Future<CatalogListing?> fetchListing(
    CatalogEntry entry, {
    Map<String, String> selection = const {},
  }) async =>
      CatalogListing(entry: entry, reach: CatalogReach.direct);

  /// No pictures, so the shelf draws its fallback and nothing here waits
  /// on a network image that will never arrive.
  @override
  Future<List<Uri>> fetchImages(CatalogEntry entry) async => const [];
}

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

  /// Three of them, because the row that has to fit is the one with a
  /// series heading and every store name on it.
  @override
  List<ModCatalog> catalogs() => const [
        _Catalog('Main'),
        _Catalog('Simtropolis'),
        _Catalog('SC4Evermore'),
      ];
}

void main() {
  for (final language in appLanguages) {
    testWidgets('${language.name} fits the catalog shelf at the minimum size',
        (tester) async {
      tester.view.physicalSize = kMinWindowSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues({
        'soundEffects': false,
        'localeCode': language.code,
      });
      final tempDir = Directory.systemTemp.createTempSync('catalog_layout');
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
          fetchShop: () async => const [],
        ));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });

      final strings = await L.delegate.load(Locale(language.code));
      await until(tester, find.text(strings.libraryTitle('Fake Game')));
      await tester.tap(find.text(strings.navShop).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Onto the catalog shelf, which is what brings the series heading
      // and the promo up.
      await tester.tap(find.text('Main'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text(strings.catalogPromoTitle), findsOneWidget,
          reason: 'the promo only shows on somebody else\'s shelf');
      expect(overflows, isEmpty,
          reason: '${language.name} overflows the catalog shelf');

      // And the detail page, where the paragraph and the buttons sit.
      await tester.tap(find.text('A Reasonably Long Mod Name 0'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(overflows, isEmpty,
          reason: '${language.name} overflows a catalog entry page');
    });
  }
}
