// A mod's page draws its artwork in a frame the artwork's own shape.
//
// It used to be a fixed 300x220 landscape box with the picture cropped to
// fill it, and Sims 4 CAS thumbnails are portrait - so the middle band of
// a render was all anybody ever saw of the mod, on the one screen they
// opened to look at it properly (issue #23).
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/bitmap.dart' show encodePng;
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app.dart';
import 'package:sims_mod_manager/src/ui/widgets.dart' show ModThumb;

import 'until.dart';

/// The width of the mod page's left column, which the frame fills.
const _column = 300.0;

class _FakeAdapter extends FolderBasedGameAdapter {
  _FakeAdapter(this.dir, this.artwork);

  final Directory dir;

  /// What the scan "finds" inside every mod, or null for a mod with no
  /// artwork of its own.
  final Uint8List? artwork;

  /// Real isolates can't finish inside the fake-async test zone.
  @override
  Future<Map<String, PackageInsight>> inspectMods(
    List<Mod> mods, {
    void Function(int done, int total)? onProgress,
    void Function(Map<String, PackageInsight> found)? onFound,
    bool Function()? isCancelled,
  }) async =>
      {
        for (final mod in mods)
          mod.path: PackageInsight(thumbnail: artwork, resourceCount: 2),
      };

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

/// A real PNG of the given shape, so the widget decodes it rather than
/// falling back to the generated stripes.
Uint8List _png(int width, int height) =>
    encodePng(width, height, Uint8List(width * height * 3));

/// Opens the one mod's page and answers how tall its artwork frame is.
Future<double> _frameHeight(WidgetTester tester, Uint8List? artwork) async {
  SharedPreferences.setMockInitialValues({'soundEffects': false});
  // Sync IO only outside runAsync; see widget_test.dart.
  final dir = Directory.systemTemp.createTempSync('mod_manager_artwork');
  File(p.join(dir.path, 'goggles.package')).writeAsStringSync('x');
  addTearDown(() => dir.deleteSync(recursive: true));

  await tester.binding.setSurfaceSize(const Size(1400, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final registry = GameRegistry([_FakeAdapter(dir, artwork)]);
  final settings = SettingsStore(await SharedPreferences.getInstance());
  await tester.runAsync(() async {
    await tester
        .pumpWidget(ModManagerApp(registry: registry, settings: settings));
  });
  await until(tester, find.text('Fake Game Library'));
  await tester.pump(const Duration(milliseconds: 500));

  await tester.tap(find.text('goggles'));
  await until(tester, find.text('goggles.package'));
  await tester.pump(const Duration(milliseconds: 500));

  // Contained, not cropped: with the frame the artwork's own shape the
  // two draw the same picture, and only contain still does at the ends
  // of the clamp.
  expect(tester.widget<ModThumb>(find.byType(ModThumb)).fit, BoxFit.contain);
  final size = tester.getSize(find.byType(ModThumb));
  expect(size.width, _column);
  return size.height;
}

/// Where the picture itself is drawn inside the frame, which is the
/// whole frame unless the clamp letterboxed it.
Rect _pictureRect(WidgetTester tester, int width, int height) {
  final frame = tester.getRect(find.byType(ModThumb));
  final scale =
      (frame.width / width).clamp(0.0, frame.height / height).toDouble();
  return Rect.fromCenter(
      center: frame.center, width: width * scale, height: height * scale);
}

void main() {
  testWidgets('a portrait thumbnail gets a portrait frame', (tester) async {
    // The shape a Sims 4 CAS render arrives in.
    expect(await _frameHeight(tester, _png(300, 400)), closeTo(400, 0.5));
  });

  testWidgets('a square thumbnail gets a square frame', (tester) async {
    expect(await _frameHeight(tester, _png(128, 128)), closeTo(300, 0.5));
  });

  testWidgets('a picture taller than the frame may get is contained',
      (tester) async {
    // 1:4 would be 1200px of one mod's page, so it stops at the ceiling
    // and the well behind it shows at the sides - still the whole
    // picture, which is the point.
    expect(await _frameHeight(tester, _png(100, 400)), closeTo(420, 0.5));
    // The file name captions the picture, so it has to be on it: laid
    // out against the frame it would have sat on the well beside it,
    // white lettering on a pale panel.
    final caption = tester.getRect(find.byKey(const Key('mod-artwork-caption')));
    final picture = _pictureRect(tester, 100, 400);
    expect(caption.left, greaterThanOrEqualTo(picture.left));
    expect(caption.right, lessThanOrEqualTo(picture.right + 0.5));
  });

  testWidgets('a panorama stops at the floor', (tester) async {
    expect(await _frameHeight(tester, _png(800, 100)), closeTo(140, 0.5));
  });

  testWidgets('a picture too narrow to caption still gets a caption',
      (tester) async {
    // A strip texture, which is what a package with no real thumbnail
    // in it can end up offering. Inset onto a picture 21px wide the
    // chip is squeezed to nothing and the file name disappears, so the
    // frame's own corner is where it goes.
    expect(await _frameHeight(tester, _png(20, 400)), closeTo(420, 0.5));
    final caption = tester.getSize(find.byKey(const Key('mod-artwork-caption')));
    expect(caption.width, greaterThan(0));
  });

  testWidgets('a mod with no artwork keeps the box it always had',
      (tester) async {
    // Nothing to take a shape from: the stripes fill whatever they are
    // given, so the page draws the frame it drew before any of this.
    expect(await _frameHeight(tester, null), closeTo(220, 0.5));
  });
}
