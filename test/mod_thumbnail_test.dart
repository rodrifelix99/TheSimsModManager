import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/bitmap.dart' show encodePng;
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/mod_thumbnails.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';

/// The game id the controller tests run under, which is also the folder
/// their copies land in - the same bargain save_edit_test.dart makes with
/// the backup folder, since the store is the real one.
const _gameId = 'thumbnail-test';

class _Adapter extends FolderBasedGameAdapter {
  _Adapter(this.dir, {this.artwork});

  final Directory dir;

  /// What the scan "finds" inside every mod, so a test can check that a
  /// picture the player picked beats one that was already there.
  final Uint8List? artwork;

  @override
  Future<Map<String, PackageInsight>> inspectMods(
    List<Mod> mods, {
    void Function(int done, int total)? onProgress,
    void Function(Map<String, PackageInsight> found)? onFound,
    bool Function()? isCancelled,
  }) async {
    final art = artwork;
    if (art == null) return const {};
    return {
      for (final mod in mods)
        mod.path: PackageInsight(resourceCount: 1, thumbnail: art),
    };
  }

  @override
  Game get game =>
      const Game(id: _gameId, name: 'Fake Game', series: 'Test', year: 2024);

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  String get setupHelpKey => 'test adapter';

  @override
  Future<String?> defaultModsPath() async => dir.path;
}

Uint8List _png(int width, int height) =>
    encodePng(width, height, Uint8List(width * height * 3));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('what a picture may be', () {
    test('the format is read off the signature, not off the name', () {
      expect(thumbnailExtensionOf(_png(2, 2)), 'png');
      expect(
          thumbnailExtensionOf(
              Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0, 0])),
          'jpg');
      expect(thumbnailExtensionOf(Uint8List.fromList('GIF89a..'.codeUnits)),
          'gif');
      expect(
          thumbnailExtensionOf(
              Uint8List.fromList('RIFF....WEBPVP8 '.codeUnits)),
          'webp');
      expect(thumbnailExtensionOf(Uint8List.fromList('BM......'.codeUnits)),
          'bmp');
    });

    test('anything else is no picture at all', () {
      expect(thumbnailExtensionOf(Uint8List.fromList('not a png'.codeUnits)),
          isNull);
      expect(thumbnailExtensionOf(Uint8List(0)), isNull);
      // RIFF without WEBP behind it is a wav file.
      expect(
          thumbnailExtensionOf(
              Uint8List.fromList('RIFF....WAVEfmt '.codeUnits)),
          isNull);
    });

    test('a stored name may not climb out of the folder', () {
      expect(isThumbnailFileName('0123456789abcdef.png'), isTrue);
      expect(isThumbnailFileName('../../secrets.png'), isFalse);
      expect(isThumbnailFileName(r'sub\thing.png'), isFalse);
      expect(isThumbnailFileName('thing.exe'), isFalse);
      expect(isThumbnailFileName(''), isFalse);
    });

    test('one mod gets one file, whatever its own name is', () {
      final a = thumbnailFileName('cc/hair.package', 'png');
      expect(a, thumbnailFileName('cc/hair.package', 'png'));
      expect(a, isNot(thumbnailFileName('cc/eyes.package', 'png')));
      expect(isThumbnailFileName(a), isTrue);
    });
  });

  group('the records', () {
    test('survive a round trip', () {
      final stored = {
        'sims2': {'cc/hair.package': 'abc123.png'},
      };
      expect(parseModThumbnails(encodeModThumbnails(stored)), stored);
    });

    test('a record that does not parse costs only itself', () {
      expect(parseModThumbnails('not json'), isEmpty);
      expect(parseModThumbnails(null), isEmpty);
      final kept = parseModThumbnails('{"sims2": {"a.package": "../x.png", '
          '"b.package": "ok.png", "c.package": 7}}');
      expect(kept, {
        'sims2': {'b.package': 'ok.png'},
      });
    });
  });

  group('a mod wearing a picture of the player’s own', () {
    late Directory modsDir;

    setUp(() {
      modsDir = Directory.systemTemp.createTempSync('mod_manager_thumbs');
    });

    tearDown(() {
      modsDir.deleteSync(recursive: true);
      final store = modThumbnailFolder(_gameId);
      if (store != null && store.existsSync()) {
        store.deleteSync(recursive: true);
      }
    });

    void writeMod(String relative) {
      final file = File(p.join(modsDir.path, p.joinAll(relative.split('/'))));
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('bytes');
    }

    /// A picture sitting somewhere the user might have picked it from.
    File writePicture(String name, Uint8List bytes) {
      final file = File(p.join(modsDir.parent.path, name))
        ..writeAsBytesSync(bytes);
      addTearDown(() {
        if (file.existsSync()) file.deleteSync();
      });
      return file;
    }

    Future<AppController> makeController({
      Map<String, Object> prefs = const {},
      String? picks,
      Uint8List? artwork,
    }) async {
      SharedPreferences.setMockInitialValues({'soundEffects': false, ...prefs});
      final controller = AppController(
        registry: GameRegistry([_Adapter(modsDir, artwork: artwork)]),
        settings: await SettingsStore.load(),
        checkUpdates: () async => null,
        pickImagePath: (_) async => picks,
      );
      await controller.refresh();
      return controller;
    }

    Mod modNamed(AppController c, String name) =>
        c.mods.firstWhere((m) => m.name == name);

    test('is drawn with it, and in place of what was inside the file',
        () async {
      writeMod('hair.package');
      final chosen = _png(4, 4);
      final picture = writePicture('chosen.png', chosen);
      final inside = _png(8, 8);
      final c = await makeController(picks: picture.path, artwork: inside);
      final mod = modNamed(c, 'hair.package');
      // What the scan found, until the player says otherwise.
      expect(c.thumbnailOf(mod), inside);

      await c.setCustomThumbnail(mod, pickerLabel: 'Images');

      expect(c.hasCustomThumbnail(mod), isTrue);
      expect(c.thumbnailOf(mod), chosen);
    });

    test('keeps it when the mod is switched off', () async {
      writeMod('hair.package');
      final chosen = _png(4, 4);
      final c = await makeController(
          picks: writePicture('chosen.png', chosen).path);
      await c.setCustomThumbnail(modNamed(c, 'hair.package'),
          pickerLabel: 'Images');

      await c.toggleMod(modNamed(c, 'hair.package'));

      final off = modNamed(c, 'hair.package');
      expect(off.isEnabled, isFalse);
      expect(c.thumbnailOf(off), chosen);
    });

    test('keeps it across a restart, out of the app’s own store',
        () async {
      writeMod('hair.package');
      final chosen = _png(4, 4);
      final first = await makeController(
          picks: writePicture('chosen.png', chosen).path);
      await first.setCustomThumbnail(modNamed(first, 'hair.package'),
          pickerLabel: 'Images');

      // The same preferences, a new controller, and the picture the user
      // picked is long gone from wherever they picked it.
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString('modThumbnails');
      expect(stored, isNotNull);
      File(p.join(modsDir.parent.path, 'chosen.png')).deleteSync();

      final second = await makeController(prefs: {'modThumbnails': stored!});

      expect(second.thumbnailOf(modNamed(second, 'hair.package')), chosen);
    });

    test('follows the mod into another folder', () async {
      writeMod('hair.package');
      final chosen = _png(4, 4);
      final c = await makeController(
          picks: writePicture('chosen.png', chosen).path);
      await c.setCustomThumbnail(modNamed(c, 'hair.package'),
          pickerLabel: 'Images');

      await c.moveMods([modNamed(c, 'hair.package')], 'cc', method: 'test');

      final moved = modNamed(c, 'hair.package');
      expect(c.folderOf(moved), 'cc');
      expect(c.thumbnailOf(moved), chosen);
      expect(parseModThumbnails(
              (await SharedPreferences.getInstance())
                  .getString('modThumbnails'))[_gameId]!
          .keys
          .single,
          p.join('cc', 'hair.package'));
    });

    test('loses it when the mod is uninstalled, copy and all', () async {
      writeMod('hair.package');
      final c = await makeController(
          picks: writePicture('chosen.png', _png(4, 4)).path);
      await c.setCustomThumbnail(modNamed(c, 'hair.package'),
          pickerLabel: 'Images');
      final store = modThumbnailFolder(_gameId)!;
      expect(store.listSync(), hasLength(1));

      await c.removeMod(modNamed(c, 'hair.package'));

      expect(c.mods, isEmpty);
      // A copy nothing can name again would sit in the store for ever.
      expect(store.listSync(), isEmpty);
      expect(
          parseModThumbnails((await SharedPreferences.getInstance())
              .getString('modThumbnails')),
          isEmpty);
    });

    test('goes back to what was inside the file when the picture is taken off',
        () async {
      writeMod('hair.package');
      final inside = _png(8, 8);
      final c = await makeController(
          picks: writePicture('chosen.png', _png(4, 4)).path,
          artwork: inside);
      final mod = modNamed(c, 'hair.package');
      await c.setCustomThumbnail(mod, pickerLabel: 'Images');

      await c.clearCustomThumbnail(mod);

      expect(c.hasCustomThumbnail(mod), isFalse);
      expect(c.thumbnailOf(mod), inside);
      expect(modThumbnailFolder(_gameId)!.listSync(), isEmpty);
    });

    test('is refused when the file is not a picture, and nothing changes',
        () async {
      writeMod('hair.package');
      final notAPicture = File(p.join(modsDir.parent.path, 'readme.txt'))
        ..writeAsStringSync('this is not a png');
      addTearDown(notAPicture.deleteSync);
      final c = await makeController(picks: notAPicture.path);

      await c.setCustomThumbnail(modNamed(c, 'hair.package'),
          pickerLabel: 'Images');

      expect(c.lastError?.key, 'thumbnailUnreadable');
      expect(c.hasCustomThumbnail(modNamed(c, 'hair.package')), isFalse);
    });

    test('is refused when the picture is bigger than the cap', () async {
      writeMod('hair.package');
      // A real PNG, just far too much of one to hold in memory for a
      // whole session - the cap is read off the file's length before
      // anything is loaded, which is the point of asking first.
      final big = writePicture(
          'huge.png',
          Uint8List.fromList([..._png(2, 2), ...Uint8List(maxThumbnailBytes)]));
      final c = await makeController(picks: big.path);

      await c.setCustomThumbnail(modNamed(c, 'hair.package'),
          pickerLabel: 'Images');

      expect(c.lastError?.key, 'thumbnailTooBig');
      expect(c.hasCustomThumbnail(modNamed(c, 'hair.package')), isFalse);
    });

    test('is left alone by a picker nobody picked anything in', () async {
      writeMod('hair.package');
      final c = await makeController(picks: null);

      await c.setCustomThumbnail(modNamed(c, 'hair.package'),
          pickerLabel: 'Images');

      expect(c.lastError, isNull);
      expect(c.hasCustomThumbnail(modNamed(c, 'hair.package')), isFalse);
    });
  });
}
