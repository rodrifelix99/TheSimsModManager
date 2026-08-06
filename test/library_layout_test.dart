// The library's toolbar and its banners have to end where the page ends.
// Nothing fails when they don't: a Row hands a flexible child a share of
// the free space, and a child that draws narrower than its share (the
// search box stops at 210, a banner's actions at the width of their
// labels) leaves the difference sitting at the *end* of the row rather
// than giving it back. So the Install button and the banner buttons drift
// inwards on a wide window while every other test still passes and the
// only symptom is that it looks slightly wrong.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app.dart';

import 'until.dart';

/// Wide enough that the search box is well under its share of the row,
/// which is the state the drift shows up in.
const _wide = Size(1600, 900);

/// The library page's own left and right margin.
const _pagePadding = 28.0;

/// A banner's border and inner padding, between the page margin and the
/// content it draws.
const _bannerInset = 1.5 + 16.0;

class _FakeAdapter extends FolderBasedGameAdapter {
  _FakeAdapter(this.dir);

  final Directory dir;

  /// Real isolates can't finish inside the fake-async test zone.
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

void main() {
  testWidgets('the toolbar and the banners end where the page ends',
      (tester) async {
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    // Sync IO only outside runAsync; see widget_test.dart.
    final dir = Directory.systemTemp.createTempSync('mod_manager_layout');
    // Same bytes under two names, so the duplicate scan has something to
    // report and the banner draws its pair of actions.
    File(p.join(dir.path, 'cozy_sofa.package')).writeAsStringSync('x');
    File(p.join(dir.path, 'comfy_sofa.package')).writeAsStringSync('x');
    addTearDown(() => dir.deleteSync(recursive: true));

    await tester.binding.setSurfaceSize(_wide);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final registry = GameRegistry([_FakeAdapter(dir)]);
    final settings = SettingsStore(await SharedPreferences.getInstance());
    await tester.runAsync(() async {
      await tester
          .pumpWidget(ModManagerApp(registry: registry, settings: settings));
    });
    await until(tester, find.text('Fake Game Library'));
    await tester.pump(const Duration(milliseconds: 500));

    final header = find.byWidgetPredicate((w) =>
        w is Padding && w.padding == const EdgeInsets.fromLTRB(28, 22, 28, 0));
    final installButton = find
        .ancestor(
          of: find.text('Install'),
          matching: find.byType(AnimatedContainer),
        )
        .first;
    expect(
      tester.getBottomRight(installButton).dx,
      closeTo(tester.getBottomRight(header).dx - _pagePadding, 0.5),
      reason: 'the Install button left the right edge of the toolbar',
    );

    await tester.tap(find.byTooltip('Find duplicate mods'));
    await until(tester, find.text('Tick the spare copies'));
    await tester.pump(const Duration(milliseconds: 500));

    final banner = find.byWidgetPredicate((w) =>
        w is Padding && w.padding == const EdgeInsets.fromLTRB(28, 14, 28, 0));
    final actions =
        find.descendant(of: banner, matching: find.byType(Wrap)).first;
    expect(
      tester.getBottomRight(actions).dx,
      closeTo(
          tester.getBottomRight(banner).dx - _pagePadding - _bannerInset, 0.5),
      reason: "the banner's actions left the right edge of the banner",
    );
  });
}
