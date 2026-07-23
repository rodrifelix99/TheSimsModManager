import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sims_mod_manager/src/games/the_sims/sims_adapters.dart';

void main() {
  late Directory docs; // fake Documents folder

  setUp(() async {
    docs = await Directory.systemTemp.createTemp('mod_manager_docs');
  });

  tearDown(() async {
    await docs.delete(recursive: true);
  });

  Directory make(List<String> segments) =>
      Directory(p.joinAll([docs.path, ...segments]))
        ..createSync(recursive: true);

  File makeFile(List<String> segments) => File(p.joinAll([docs.path, ...segments]))
    ..createSync(recursive: true);

  group('Sims 3 folder resolution', () {
    test('finds localized game folders (e.g. Los Sims 3)', () async {
      make(['Electronic Arts', 'Los Sims 3', 'Mods', 'Packages']);
      final adapter = Sims3Adapter(documentsOverride: docs);

      final dir = await adapter.resolveModsDirectory();

      expect(dir, isNotNull);
      expect(dir!.path, contains('Los Sims 3'));
    });

    test('ignores side tools like Create a World', () async {
      make(['Electronic Arts', 'The Sims 3 Create a World Tool', 'Mods',
          'Packages']);
      final adapter = Sims3Adapter(documentsOverride: docs);

      expect(await adapter.resolveModsDirectory(), isNull);
    });

    test('prefers the canonical folder, lists every install', () async {
      make(['Electronic Arts', 'Los Sims 3', 'Mods', 'Packages']);
      make(['Electronic Arts', 'The Sims 3', 'Mods', 'Packages']);
      final adapter = Sims3Adapter(documentsOverride: docs);

      final candidates = await adapter.findModsDirectoryCandidates();

      expect(candidates, hasLength(2));
      expect(candidates.first.path, contains(p.join('The Sims 3', 'Mods')));
    });

    test('proposes the conventional path when nothing exists yet', () async {
      final adapter = Sims3Adapter(documentsOverride: docs);

      expect(
        await adapter.defaultModsPath(),
        p.join(docs.path, 'Electronic Arts', 'The Sims 3', 'Mods', 'Packages'),
      );
    });

    test('createModsDirectory scaffolds the Resource.cfg framework',
        () async {
      final adapter = Sims3Adapter(documentsOverride: docs);
      final path = (await adapter.defaultModsPath())!;

      final dir = await adapter.createModsDirectory(path);

      expect(dir.existsSync(), isTrue);
      final cfg = File(p.join(docs.path, 'Electronic Arts', 'The Sims 3',
          'Mods', 'Resource.cfg'));
      expect(cfg.existsSync(), isTrue);
      expect(cfg.readAsStringSync(),
          contains('PackedFile Packages/*.package'));
    });

    test('finds and clears the stale CC caches, leaving mods alone',
        () async {
      for (final name in [
        'CASPartCache.package',
        'compositorCache.package',
        'scriptCache.package',
        'simCompositorCache.package',
      ]) {
        makeFile(['Electronic Arts', 'The Sims 3', name]);
      }
      final mod = makeFile(
          ['Electronic Arts', 'The Sims 3', 'Mods', 'Packages',
              'mod.package']);
      final adapter = Sims3Adapter(documentsOverride: docs);

      final found = await adapter.findCacheFiles();
      expect(found, hasLength(4));

      final cleared = await adapter.clearCaches();

      expect(cleared, hasLength(4));
      for (final file in found) {
        expect(file.existsSync(), isFalse);
      }
      expect(mod.existsSync(), isTrue);
      expect(await adapter.findCacheFiles(), isEmpty);
    });
  });

  group('Sims 4', () {
    test('createModsDirectory writes the standard Resource.cfg', () async {
      final adapter = Sims4Adapter(documentsOverride: docs);
      final path = (await adapter.defaultModsPath())!;

      await adapter.createModsDirectory(path);

      final cfg = File(p.join(path, 'Resource.cfg'));
      expect(cfg.existsSync(), isTrue);
      expect(cfg.readAsStringSync(), contains('PackedFile *.package'));
    });

    test('categorizes script mods separately', () {
      const adapter = Sims4Adapter();
      expect(adapter.categoryForExtension('.ts4script'), 'Script');
      expect(adapter.categoryForExtension('.package'), 'Package');
    });

    test('has no stale caches to clear', () async {
      make(['Electronic Arts', 'The Sims 4', 'Mods']);
      final adapter = Sims4Adapter(documentsOverride: docs);
      expect(await adapter.findCacheFiles(), isEmpty);
      expect(await adapter.clearCaches(), isEmpty);
    });
  });

  group('Sims 2', () {
    test('finds the Ultimate Collection folder name', () async {
      make(['EA Games', 'The Sims™ 2 Ultimate Collection', 'Downloads']);
      final adapter = Sims2Adapter(documentsOverride: docs);

      final dir = await adapter.resolveModsDirectory();

      expect(dir, isNotNull);
      expect(dir!.path, contains('Ultimate Collection'));
    });

    test('finds the Legacy Collection folder names', () async {
      // The 2025 re-release; the folder name varies by installer.
      make(['EA Games', 'The Sims 2 Legacy', 'Downloads']);
      final adapter = Sims2Adapter(documentsOverride: docs);

      final dir = await adapter.resolveModsDirectory();

      expect(dir, isNotNull);
      expect(dir!.path, contains('The Sims 2 Legacy'));

      const bare = Sims2Adapter();
      expect(bare.matchesGameFolder('The Sims™ 2 Legacy Collection'), isTrue);
      expect(bare.matchesGameFolder('The Sims 2 Legacy'), isTrue);
      expect(bare.matchesGameFolder('The Sims 3 Legacy'), isFalse);
    });

    test('reports the game folder even when Downloads is missing', () async {
      make(['EA Games', 'The Sims 2 Legacy']); // no Downloads inside
      final adapter = Sims2Adapter(documentsOverride: docs);

      expect(await adapter.resolveModsDirectory(), isNull);
      final gameFolder = await adapter.findGameFolder();
      expect(gameFolder, isNotNull);
      expect(p.basename(gameFolder!.path), 'The Sims 2 Legacy');
      // The "create it" offer points inside the found game folder.
      expect(await adapter.defaultModsPath(),
          p.join(gameFolder.path, 'Downloads'));
    });
  });

  group('Sims Medieval', () {
    test('finds Origin and Steam installs', () async {
      // Reuse the temp dir as a fake Program Files root.
      make(['Origin Games', 'The Sims Medieval', 'Mods', 'Packages']);
      make(['Steam', 'steamapps', 'common', 'The Sims Medieval', 'Mods',
          'Packages']);
      final adapter = SimsMedievalAdapter(
          programFilesOverride: [docs.path], homeOverride: docs.path);

      final candidates = await adapter.findModsDirectoryCandidates();

      expect(candidates, hasLength(2));
      expect(candidates.first.path,
          contains(p.join('Origin Games', 'The Sims Medieval')));
    });

    test('finds localized disc installs by the TSM.exe signature', () async {
      makeFile(
          ['Electronic Arts', 'Die Sims Mittelalter', 'Game', 'Bin', 'TSM.exe']);
      // A Sims 3 disc install lives under the same vendor folder but has
      // no TSM.exe, so it must not be picked up.
      make(['Electronic Arts', 'The Sims 3', 'Game', 'Bin']);
      final adapter = SimsMedievalAdapter(
          programFilesOverride: [docs.path], homeOverride: docs.path);

      final install = await adapter.findGameFolder();

      expect(install, isNotNull);
      expect(p.basename(install!.path), 'Die Sims Mittelalter');
      expect(await adapter.defaultModsPath(),
          p.join(install.path, 'Mods', 'Packages'));
    });

    test('finds Linux native Steam library installs', () async {
      // Reuse the temp dir as a fake home; Proton games install outside
      // the wine prefix, in the regular Steam library.
      make(['.local', 'share', 'Steam', 'steamapps', 'common',
          'The Sims Medieval']);
      final adapter = SimsMedievalAdapter(
          programFilesOverride: const [], homeOverride: docs.path);

      final install = await adapter.findGameFolder();

      expect(install, isNotNull);
      expect(await adapter.defaultModsPath(),
          p.join(install!.path, 'Mods', 'Packages'));
    });

    test('proposes no path when the game is not installed', () async {
      final adapter = SimsMedievalAdapter(
          programFilesOverride: const [], homeOverride: docs.path);

      expect(await adapter.defaultModsPath(), isNull);
      expect(await adapter.findGameFolder(), isNull);
    });

    test('createModsDirectory writes Resource.cfg into the install root',
        () async {
      final install = make(['Origin Games', 'The Sims Medieval']);
      final adapter = SimsMedievalAdapter(
          programFilesOverride: [docs.path], homeOverride: docs.path);
      final path = (await adapter.defaultModsPath())!;

      final dir = await adapter.createModsDirectory(path);

      expect(dir.existsSync(), isTrue);
      expect(dir.path, p.join(install.path, 'Mods', 'Packages'));
      // The cfg is a sibling of Mods, not inside it.
      final cfg = File(p.join(install.path, 'Resource.cfg'));
      expect(cfg.existsSync(), isTrue);
      expect(cfg.readAsStringSync(),
          contains('PackedFile Mods/Packages/*.package'));
      expect(cfg.readAsStringSync(),
          contains('PackedFile Mods/Packages/*/*/*/*/*.package'));
    });

    test('finds CC caches in the localized Documents folder, skipping '
        'the numbered games', () async {
      // Caches live in Documents (not the install); the folder name is
      // localized, so they're found by the cache files themselves. A
      // Sims 3 folder under the same vendor holds the same cache names
      // but belongs to its own adapter and must be left alone.
      for (final name in [
        'CASPartCache.package',
        'compositorCache.package',
        'simCompositorCache.package',
      ]) {
        makeFile(['Electronic Arts', 'Die Sims Mittelalter', name]);
      }
      final save = makeFile(
          ['Electronic Arts', 'Die Sims Mittelalter', 'Saves', 'save.sav']);
      final sims3Cache =
          makeFile(['Electronic Arts', 'Los Sims 3', 'CASPartCache.package']);
      final adapter = SimsMedievalAdapter(
          programFilesOverride: const [],
          homeOverride: docs.path,
          documentsOverride: docs);

      final found = await adapter.findCacheFiles();

      expect(found, hasLength(3));
      expect(found.map((f) => f.path).join(), isNot(contains('Sims 3')));

      await adapter.clearCaches();

      expect(await adapter.findCacheFiles(), isEmpty);
      expect(save.existsSync(), isTrue);
      expect(sims3Cache.existsSync(), isTrue);
    });
  });

  group('Sims 1', () {
    test('finds the Legacy Collection install folders', () async {
      // Reuse the temp dir as a fake Program Files root.
      make(['EA Games', 'The Sims Legacy', 'Downloads']);
      make(['Steam', 'steamapps', 'common', 'The Sims Legacy Collection',
          'Downloads']);
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);

      final candidates = await adapter.findModsDirectoryCandidates();

      expect(candidates, hasLength(2));
      expect(candidates.map((d) => d.path).join(),
          contains(p.join('EA Games', 'The Sims Legacy', 'Downloads')));
    });

    /// A classic install: Downloads next to GameData, per the community
    /// install guides (parsimonious.org "Adding Downloads").
    Directory makeInstall() {
      make(['Maxis', 'The Sims', 'GameData']);
      return make(['Maxis', 'The Sims', 'Downloads']);
    }

    /// Writes a zip named [name] containing [entries] (path → content).
    File makeZip(String name, Map<String, String> entries) {
      final zip = Archive();
      entries.forEach((path, content) {
        zip.addFile(ArchiveFile.typedData(
            path, Uint8List.fromList(utf8.encode(content))));
      });
      final file = File(p.join(docs.path, name));
      file.writeAsBytesSync(ZipEncoder().encode(zip));
      return file;
    }

    test('routes single-file installs by type into the game folders',
        () async {
      final downloads = makeInstall();
      final install = downloads.parent;
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);

      for (final name in [
        'chair.iff',
        'xskin-b200fafit_bwar-PELVIS-BODY.skn',
        'B200FAFit_BWar.cmx',
        'b200fafitlgt_blackdress.bmp',
        'l204fafit_gown.bmp', // buyable clothing: L prefix
        'brick.wll',
        'tile.flr',
      ]) {
        await adapter.installMod(downloads, makeFile(['src', name]));
      }

      expect(File(p.join(downloads.path, 'chair.iff')).existsSync(), isTrue);
      final skins = p.join(install.path, 'GameData', 'Skins');
      for (final name in [
        'xskin-b200fafit_bwar-PELVIS-BODY.skn',
        'B200FAFit_BWar.cmx',
        'b200fafitlgt_blackdress.bmp',
      ]) {
        expect(File(p.join(skins, name)).existsSync(), isTrue,
            reason: '$name belongs in GameData/Skins');
      }
      expect(
          File(p.join(install.path, 'ExpansionShared', 'SkinsBuy',
                  'l204fafit_gown.bmp'))
              .existsSync(),
          isTrue);
      expect(
          File(p.join(install.path, 'GameData', 'Walls', 'brick.wll'))
              .existsSync(),
          isTrue);
      expect(
          File(p.join(install.path, 'GameData', 'Floors', 'tile.flr'))
              .existsSync(),
          isTrue);
    });

    test('does not route when the folder is not inside a Sims install',
        () async {
      // A custom override anywhere on disk: no GameData sibling, so
      // everything lands in the chosen folder like any other game.
      final custom = make(['just-a-folder']);
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);

      await adapter.installMod(custom, makeFile(['src', 'skin.skn']));

      expect(File(p.join(custom.path, 'skin.skn')).existsSync(), isTrue);
    });

    test('routes archive contents, keeping subfolders only in Downloads',
        () async {
      final downloads = makeInstall();
      final install = downloads.parent;
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);
      final zip = makeZip('cc.zip', {
        'furniture/chair.iff': 'object',
        'skins/b200fafitlgt_blackdress.bmp': 'texture',
        'skins/B200FAFit_BWar.cmx': 'animation',
        'readme.txt': 'skip me',
      });

      final mods = await adapter.installArchive(downloads, zip);

      expect(mods, hasLength(3));
      // Objects keep the archive's folder structure inside Downloads.
      expect(
          File(p.join(downloads.path, 'furniture', 'chair.iff')).existsSync(),
          isTrue);
      // Skins are flattened into GameData/Skins: the game does not read
      // subfolders there.
      final skins = p.join(install.path, 'GameData', 'Skins');
      expect(File(p.join(skins, 'b200fafitlgt_blackdress.bmp')).existsSync(),
          isTrue);
      expect(File(p.join(skins, 'B200FAFit_BWar.cmx')).existsSync(), isTrue);
      expect(File(p.join(skins, 'readme.txt')).existsSync(), isFalse);
    });

    test('lists routed content alongside Downloads and can toggle it',
        () async {
      final downloads = makeInstall();
      final install = downloads.parent;
      makeFile(['Maxis', 'The Sims', 'Downloads', 'chair.iff']);
      makeFile(['Maxis', 'The Sims', 'GameData', 'Skins', 'head.cmx']);
      makeFile(['Maxis', 'The Sims', 'GameData', 'Walls', 'brick.wll']);
      // Game files outside the content folders must not show up.
      makeFile(['Maxis', 'The Sims', 'GameData', 'Objects.far']);
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);

      final mods = await adapter.listMods(downloads);

      expect(mods.map((m) => m.name),
          unorderedEquals(['chair.iff', 'head.cmx', 'brick.wll']));

      final skin = mods.firstWhere((m) => m.name == 'head.cmx');
      final disabled = await adapter.setEnabled(skin, enabled: false);
      expect(
          File(p.join(install.path, 'GameData', 'Skins', 'head.cmx.disabled'))
              .existsSync(),
          isTrue);
      await adapter.setEnabled(disabled, enabled: true);
      expect(
          File(p.join(install.path, 'GameData', 'Skins', 'head.cmx'))
              .existsSync(),
          isTrue);
    });
  });
}
