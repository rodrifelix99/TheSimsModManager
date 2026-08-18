// Some of what people install does not go in the mods folder at all: a
// Sims 3 routing fix is a .world that replaces the one the game shipped,
// an ASI mod is a plugin beside the executable, a graphics fix is a .sgr
// in the folder the game reads its settings from (issue #22). These tests
// are about where those land, what happens to the file they replace, and
// that none of it changes where an ordinary .package goes.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/app_message.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/placed_mods.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims_adapters.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/l10n/app_localizations.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';
import 'package:sims_mod_manager/src/ui/mod_presentation.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('root_install');
  });

  tearDown(() => root.deleteSync(recursive: true));

  Directory make(List<String> segments) =>
      Directory(p.joinAll([root.path, ...segments]))
        ..createSync(recursive: true);

  File makeFile(List<String> segments, [String contents = 'bytes']) {
    final file = File(p.joinAll([root.path, ...segments]));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(contents);
    return file;
  }

  File makeZip(String name, Map<String, String> entries) {
    final archive = Archive();
    for (final entry in entries.entries) {
      final bytes = entry.value.codeUnits;
      archive.addFile(ArchiveFile(entry.key, bytes.length, bytes));
    }
    final file = File(p.join(root.path, name));
    file.writeAsBytesSync(ZipEncoder().encode(archive));
    return file;
  }

  /// A `.sims3pack` carrying a world, which is the one thing the reader
  /// refuses outright: the game's Launcher installs those, not this.
  File makeWorldPack(String name) {
    final payload = utf8.encode('a world');
    // One line, because nothing in the reader wants it laid out and a
    // manifest is only ever scanned for its four exporter-written tags.
    final xml = utf8.encode('<?xml version="1.0" encoding="UTF-8"?>'
        '<Sims3Package Type="world" SubType="0x00000000">'
        '<DisplayName>Riverview</DisplayName>'
        '<PackagedFile>'
        '<Name>0xaaa.package</Name>'
        '<Length>${payload.length}</Length>'
        '<Offset>0</Offset>'
        '<ContentType>world</ContentType>'
        '</PackagedFile>'
        '</Sims3Package>');
    final out = BytesBuilder()
      ..add((ByteData(4)..setUint32(0, 7, Endian.little)).buffer.asUint8List())
      ..add(ascii.encode('TS3Pack'))
      ..add([1, 1])
      ..add((ByteData(4)..setUint32(0, xml.length, Endian.little))
          .buffer
          .asUint8List())
      ..add(xml)
      ..add(payload);
    final file = File(p.join(root.path, name));
    file.writeAsBytesSync(out.takeBytes());
    return file;
  }

  /// A Sims 3 install: the base game with its plugin, world and settings
  /// folders, and one pack with a world of its own.
  ({Directory install, Directory pack, Directory mods}) makeSims3() {
    make(['Games', 'The Sims 3', 'Game', 'Bin']);
    make(['Games', 'The Sims 3', 'GameData', 'Shared', 'NonPackaged', 'Ini']);
    make(
        ['Games', 'The Sims 3', 'GameData', 'Shared', 'NonPackaged', 'Worlds']);
    make([
      'Games',
      'The Sims 3',
      'EP3',
      'GameData',
      'Shared',
      'NonPackaged',
      'Worlds'
    ]);
    return (
      install: Directory(p.join(root.path, 'Games', 'The Sims 3')),
      pack: Directory(p.join(root.path, 'Games', 'The Sims 3', 'EP3')),
      mods: make(['Docs', 'Electronic Arts', 'The Sims 3', 'Mods', 'Packages']),
    );
  }

  Sims3Adapter sims3(({Directory install, Directory pack, Directory mods}) at) =>
      Sims3Adapter(
        documentsOverride: Directory(p.join(root.path, 'Docs')),
        installOverride: at.install,
        packRootsOverride: [at.pack],
      );

  String worldsOf(Directory dir) =>
      p.joinAll([dir.path, 'GameData', 'Shared', 'NonPackaged', 'Worlds']);

  group('The Sims 3', () {
    test('a world replaces the one the pack shipped, and keeps it', () async {
      final at = makeSims3();
      final shipped = File(p.join(worldsOf(at.pack), 'Bridgeport.world'))
        ..writeAsStringSync('what EA shipped');
      final adapter = sims3(at);
      final fix = makeFile(['dl', 'Bridgeport.world'], 'the routing fix');

      final mod = await adapter.installMod(at.mods, fix);

      expect(mod.path, shipped.path);
      expect(shipped.readAsStringSync(), 'the routing fix');
      expect(
          File('${shipped.path}.smmbak').readAsStringSync(), 'what EA shipped');
      // Nothing landed in the mods folder, which is the whole point: a
      // world there is a file the game never looks at.
      expect(at.mods.listSync(), isEmpty);
    });

    test('uninstalling a routing fix gives the world back', () async {
      final at = makeSims3();
      final shipped = File(p.join(worldsOf(at.pack), 'Bridgeport.world'))
        ..writeAsStringSync('what EA shipped');
      final adapter = sims3(at);

      final mod = await adapter
          .installMod(at.mods, makeFile(['dl', 'Bridgeport.world'], 'fixed'));
      await adapter.removeMod(mod);

      expect(shipped.readAsStringSync(), 'what EA shipped');
      expect(File('${shipped.path}.smmbak').existsSync(), isFalse);
    });

    test('switching a routing fix off gives the world back, and on again',
        () async {
      final at = makeSims3();
      final shipped = File(p.join(worldsOf(at.pack), 'Bridgeport.world'))
        ..writeAsStringSync('what EA shipped');
      final adapter = sims3(at);

      final mod = await adapter
          .installMod(at.mods, makeFile(['dl', 'Bridgeport.world'], 'fixed'));

      // Off: the game gets its own world back rather than none at all,
      // which is what a plain rename would have left it with - and the
      // town it belongs to would not load.
      final off = await adapter.setEnabled(mod, enabled: false);

      expect(off.isEnabled, isFalse);
      expect(shipped.readAsStringSync(), 'what EA shipped');
      expect(File('${shipped.path}.disabled').readAsStringSync(), 'fixed');
      expect(File('${shipped.path}.smmbak').existsSync(), isFalse);

      // And back on, with EA's world parked again rather than written
      // over by the rename.
      final on = await adapter.setEnabled(off, enabled: true);

      expect(on.isEnabled, isTrue);
      expect(shipped.readAsStringSync(), 'fixed');
      expect(
          File('${shipped.path}.smmbak').readAsStringSync(), 'what EA shipped');
      expect(File('${shipped.path}.disabled').existsSync(), isFalse);
    });

    test('a world of nobody else\'s name goes to the base game', () async {
      final at = makeSims3();
      final adapter = sims3(at);

      final mod = await adapter
          .installMod(at.mods, makeFile(['dl', 'Moonlight Falls.world']));

      expect(p.dirname(mod.path), worldsOf(at.install));
      // Nothing was replaced, so there is nothing parked beside it.
      expect(File('${mod.path}.smmbak').existsSync(), isFalse);
    });

    test('a plugin and its loader go beside the executable', () async {
      final at = makeSims3();
      final adapter = sims3(at);

      final asi = await adapter
          .installMod(at.mods, makeFile(['dl', 'SmoothPatch.asi']));
      final loader = await adapter
          .installMod(at.mods, makeFile(['dl', 'd3dx9_31.dll']));

      final bin = p.join(at.install.path, 'Game', 'Bin');
      expect(p.dirname(asi.path), bin);
      expect(p.dirname(loader.path), bin);
    });

    test('a settings file replaces the one it is named after', () async {
      final at = makeSims3();
      final rules =
          File(p.join(at.install.path, 'Game', 'Bin', 'GraphicsRules.sgr'))
            ..writeAsStringSync('stock rules');
      final sky = File(p.joinAll([
        at.install.path,
        'GameData',
        'Shared',
        'NonPackaged',
        'Ini',
        'Sky_Clear1.ini'
      ]))
        ..writeAsStringSync('stock sky');
      final adapter = sims3(at);

      await adapter
          .installMod(at.mods, makeFile(['dl', 'GraphicsRules.sgr'], 'better'));
      await adapter
          .installMod(at.mods, makeFile(['dl', 'Sky_Clear1.ini'], 'prettier'));

      expect(rules.readAsStringSync(), 'better');
      expect(sky.readAsStringSync(), 'prettier');
      expect(File('${sky.path}.smmbak').readAsStringSync(), 'stock sky');
    });

    test('an archive splits between the mods folder and the game', () async {
      final at = makeSims3();
      File(p.join(worldsOf(at.install), 'Sunset Valley.world'))
          .writeAsStringSync('what EA shipped');
      final adapter = sims3(at);
      final zip = makeZip('fixes.zip', {
        'NoIntro/nointro.package': 'a mod',
        'NoIntro/Sunset Valley.world': 'the fix',
        'NoIntro/readme.txt': 'install instructions',
      });

      final mods = await adapter.installArchive(at.mods, zip);

      expect(mods, hasLength(2));
      expect(
          File(p.join(at.mods.path, 'NoIntro', 'nointro.package'))
              .readAsStringSync(),
          'a mod');
      expect(File(p.join(worldsOf(at.install), 'Sunset Valley.world'))
          .readAsStringSync(), 'the fix');
      // And the world is gone from where it was unpacked on the way.
      expect(File(p.join(at.mods.path, 'NoIntro', 'Sunset Valley.world'))
          .existsSync(), isFalse);
    });

    test('a refused container costs itself, not the world beside it',
        () async {
      // The folder install puts the game's own files aside before the
      // containers are opened, so the refusal must wait until they have
      // had their turn - or a dropped folder holding both installs
      // nothing at all.
      final at = makeSims3();
      File(p.join(worldsOf(at.install), 'Sunset Valley.world'))
          .writeAsStringSync('what EA shipped');
      final adapter = sims3(at);
      final dropped = make(['Downloads', 'Sunset Valley Fix']);
      makeFile(['Downloads', 'Sunset Valley Fix', 'Sunset Valley.world'],
          'the fix');
      makeWorldPack('Riverview.sims3pack')
          .renameSync(p.join(dropped.path, 'Riverview.sims3pack'));

      final mods = await adapter.installFolder(at.mods, dropped);

      expect(mods, hasLength(1));
      expect(
          File(p.join(worldsOf(at.install), 'Sunset Valley.world'))
              .readAsStringSync(),
          'the fix');
    });

    test('a refused container on its own is still refused', () async {
      final at = makeSims3();
      final adapter = sims3(at);
      final dropped = make(['Downloads', 'Riverview']);
      makeWorldPack('Riverview.sims3pack')
          .renameSync(p.join(dropped.path, 'Riverview.sims3pack'));

      await expectLater(
        adapter.installFolder(at.mods, dropped),
        throwsA(isA<ModContentException>()
            .having((e) => e.detail.key, 'key', 'sims3PackWorld')),
      );
    });

    test('an ini the game never heard of is left out', () async {
      final at = makeSims3();
      final adapter = sims3(at);
      final zip = makeZip('modwithconfig.zip', {
        'mod.package': 'a mod',
        'settings.ini': "the mod's own config",
      });

      final mods = await adapter.installArchive(at.mods, zip);

      expect(mods.map((m) => m.name), ['mod.package']);
      expect(File(p.join(at.mods.path, 'settings.ini')).existsSync(), isFalse);
      expect(
          Directory(p.join(at.install.path, 'GameData', 'Shared', 'NonPackaged',
                  'Ini'))
              .listSync(),
          isEmpty);
    });

    test('an ordinary package still goes to the mods folder', () async {
      final at = makeSims3();
      final adapter = sims3(at);

      final mod = await adapter
          .installMod(at.mods, makeFile(['dl', 'nointro.package']));

      expect(p.dirname(mod.path), at.mods.path);
    });

    test('a game the app cannot find takes nothing but packages', () async {
      final at = makeSims3();
      final adapter = Sims3Adapter(
          documentsOverride: Directory(p.join(root.path, 'Docs')),
          packRootsOverride: const []);

      expect(await adapter.installDestinations(at.mods), isEmpty);
      expect(await adapter.installableExtensions(at.mods), {'.package'});
      // So an archive holding only a world reports what it is: nothing
      // this machine can install, rather than a world dumped in Mods.
      await expectLater(
          adapter.installArchive(
              at.mods, makeZip('world.zip', {'A.world': 'bytes'})),
          throwsA(isA<Exception>()));
    });

    test('a world sitting in the mods folder is still not a mod', () async {
      final at = makeSims3();
      makeFile(['Docs', 'Electronic Arts', 'The Sims 3', 'Mods', 'Packages',
        'stray.world']);
      makeFile(['Docs', 'Electronic Arts', 'The Sims 3', 'Mods', 'Packages',
        'real.package']);

      expect((await sims3(at).listMods(at.mods)).map((m) => m.name),
          ['real.package']);
    });

    test('the install is never asked which folder it goes in', () async {
      // The question has an answer before anyone could be asked, so the
      // dialog that The Sims 1 shows stays out of the way here.
      expect(const Sims3Adapter().sortsModsAcrossFolders, isFalse);
      expect(const Sims1Adapter().sortsModsAcrossFolders, isTrue);
    });
  });

  group('The Sims 2', () {
    ({Directory pack, Directory mods}) makeSims2() {
      make(['Games', 'TS2', 'EP9', 'TSBin']);
      make(['Games', 'TS2', 'EP9', 'TSData', 'Res', 'Config']);
      // The pack the game does not run, whose identically named files
      // must be left alone.
      make(['Games', 'TS2', 'EP8', 'TSData', 'Res', 'Config']);
      return (
        pack: Directory(p.join(root.path, 'Games', 'TS2', 'EP9')),
        mods: make(['Docs', 'EA Games', 'The Sims 2', 'Downloads']),
      );
    }

    test('graphics rules replace the running pack\'s, and only those',
        () async {
      final at = makeSims2();
      final running =
          File(p.joinAll([at.pack.path, 'TSData', 'Res', 'Config',
              'Graphics Rules.sgr']))
            ..writeAsStringSync('stock rules');
      final other = File(p.joinAll([root.path, 'Games', 'TS2', 'EP8', 'TSData',
          'Res', 'Config', 'Graphics Rules.sgr']))
        ..writeAsStringSync('another pack, untouched');
      final adapter = Sims2Adapter(
          documentsOverride: Directory(p.join(root.path, 'Docs')),
          installOverride: at.pack);

      await adapter.installMod(
          at.mods, makeFile(['dl', 'Graphics Rules.sgr'], 'card fix'));

      expect(running.readAsStringSync(), 'card fix');
      expect(File('${running.path}.smmbak').readAsStringSync(), 'stock rules');
      expect(other.readAsStringSync(), 'another pack, untouched');
    });

    test('a wrapper goes beside the executable', () async {
      final at = makeSims2();
      final adapter = Sims2Adapter(
          documentsOverride: Directory(p.join(root.path, 'Docs')),
          installOverride: at.pack);

      final mod =
          await adapter.installMod(at.mods, makeFile(['dl', 'd3d9.dll']));

      expect(p.dirname(mod.path), p.join(at.pack.path, 'TSBin'));
    });
  });

  group('where a mod says it lives', () {
    test('a game folder is named, a sibling of the mods folder is not',
        () async {
      SharedPreferences.setMockInitialValues({'soundEffects': false});
      final at = makeSims3();
      // The framework's own Overrides folder, one step out of Packages,
      // which is where a lot of Sims 3 libraries keep half their mods.
      final overrides = make(
          ['Docs', 'Electronic Arts', 'The Sims 3', 'Mods', 'Overrides']);
      File(p.join(overrides.path, 'override.package'))
          .writeAsStringSync('a mod');
      // The game only reads that folder because its Resource.cfg names
      // it, and so does the app.
      File(p.joinAll([
        root.path,
        'Docs',
        'Electronic Arts',
        'The Sims 3',
        'Mods',
        'Resource.cfg'
      ])).writeAsStringSync('Priority 501\n'
          'PackedFile Overrides/*.package\n'
          'Priority 500\n'
          'PackedFile Packages/*.package\n');
      final adapter = sims3(at);
      final controller = AppController(
        registry: GameRegistry([adapter]),
        settings: await SettingsStore.load(),
        checkUpdates: () async => null,
        loadAdvisories: () async => null,
        fetchShop: () async => null,
      );
      await controller.init();
      await controller
          .installFiles([makeFile(['dl', 'Moonlight Falls.world'])]);

      final l = lookupL(const Locale('en'));
      String subtitleOf(String name) => modSubtitle(
          l, controller, controller.mods.firstWhere((m) => m.name == name));

      // Six levels up and across is a row of dots where a folder name
      // should be, so the folder itself is named instead.
      expect(subtitleOf('Moonlight Falls.world'),
          contains(p.join('NonPackaged', 'Worlds')));
      expect(subtitleOf('Moonlight Falls.world'), isNot(contains('..')));
      // One step out still reads as what it is.
      expect(subtitleOf('override.package'),
          l.modInFolder(p.join('..', 'Overrides')));
    });
  });

  group('the library', () {
    test('lists what was put in the game\'s folders, and lets it go',
        () async {
      SharedPreferences.setMockInitialValues({'soundEffects': false});
      final at = makeSims3();
      File(p.join(worldsOf(at.pack), 'Bridgeport.world'))
          .writeAsStringSync('what EA shipped');
      final adapter = sims3(at);
      final controller = AppController(
        registry: GameRegistry([adapter]),
        settings: await SettingsStore.load(),
        checkUpdates: () async => null,
        loadAdvisories: () async => null,
        fetchShop: () async => null,
      );
      await controller.init();
      expect(controller.modsDir?.path, at.mods.path);

      await controller
          .installFiles([makeFile(['dl', 'Bridgeport.world'], 'the fix')]);

      // Nothing sweeps that folder, so the record is the only way the
      // library knows the mod is there at all.
      expect(controller.mods.map((m) => m.name), ['Bridgeport.world']);
      final placed = parsePlacedMods(controller.settings.placedModsJson);
      expect(placed['sims3'], hasLength(1));

      // Switched off, the record still finds it - and finds the mod
      // rather than the game's own file, which is now sitting under the
      // name the record names.
      await controller.toggleMod(controller.mods.single);

      expect(controller.mods, hasLength(1));
      expect(controller.mods.single.isEnabled, isFalse);
      expect(File(p.join(worldsOf(at.pack), 'Bridgeport.world'))
          .readAsStringSync(), 'what EA shipped');

      await controller.toggleMod(controller.mods.single);
      expect(controller.mods.single.isEnabled, isTrue);

      // Installing it again is an update of the same mod, not a second
      // original to keep: the game's own file stays the parked one.
      await controller
          .installFiles([makeFile(['dl2', 'Bridgeport.world'], 'fixed again')]);

      final shipped = p.join(worldsOf(at.pack), 'Bridgeport.world');
      expect(File(shipped).readAsStringSync(), 'fixed again');
      expect(File('$shipped.smmbak').readAsStringSync(), 'what EA shipped');
      expect(
          Directory(worldsOf(at.pack))
              .listSync()
              .whereType<File>()
              .map((f) => p.basename(f.path))
              .toSet(),
          {'Bridgeport.world', 'Bridgeport.world.smmbak'});

      // And removing it puts EA's world back and drops the record.
      await controller.removeMod(controller.mods.single);

      expect(File(shipped).readAsStringSync(), 'what EA shipped');
      expect(parsePlacedMods(controller.settings.placedModsJson)['sims3'],
          anyOf(isNull, isEmpty));
    });
  });
}
