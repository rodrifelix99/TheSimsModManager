import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sims_mod_manager/src/core/install_destination.dart';
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

  File makeFile(List<String> segments) =>
      File(p.joinAll([docs.path, ...segments]))..createSync(recursive: true);

  group('Sims 3 folder resolution', () {
    test('finds localized game folders (e.g. Los Sims 3)', () async {
      make(['Electronic Arts', 'Los Sims 3', 'Mods', 'Packages']);
      final adapter = Sims3Adapter(documentsOverride: docs);

      final dir = await adapter.resolveModsDirectory();

      expect(dir, isNotNull);
      expect(dir!.path, contains('Los Sims 3'));
    });

    test('ignores side tools like Create a World', () async {
      make([
        'Electronic Arts',
        'The Sims 3 Create a World Tool',
        'Mods',
        'Packages'
      ]);
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

    test('createModsDirectory scaffolds the Resource.cfg framework', () async {
      final adapter = Sims3Adapter(documentsOverride: docs);
      final path = (await adapter.defaultModsPath())!;

      final dir = await adapter.createModsDirectory(path);

      expect(dir.existsSync(), isTrue);
      final cfg = File(p.join(
          docs.path, 'Electronic Arts', 'The Sims 3', 'Mods', 'Resource.cfg'));
      expect(cfg.existsSync(), isTrue);
      expect(cfg.readAsStringSync(), contains('PackedFile Packages/*.package'));
    });

    test('finds and clears the stale CC caches, leaving mods alone', () async {
      for (final name in [
        'CASPartCache.package',
        'compositorCache.package',
        'scriptCache.package',
        'simCompositorCache.package',
      ]) {
        makeFile(['Electronic Arts', 'The Sims 3', name]);
      }
      final mod = makeFile(
          ['Electronic Arts', 'The Sims 3', 'Mods', 'Packages', 'mod.package']);
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

  group('game folders the name pass cannot read', () {
    test('finds a folder written in another script by what it holds', () async {
      // A folder name spelled in kana says nothing the regex can use, so
      // the tray and the version stamp answer instead.
      make(['Electronic Arts', 'ザ・シムズ4', 'Tray']);
      makeFile(['Electronic Arts', 'ザ・シムズ4', 'GameVersion.txt']);
      make(['Electronic Arts', 'ザ・シムズ4', 'Mods']);
      final adapter = Sims4Adapter(documentsOverride: docs);

      final dir = await adapter.resolveModsDirectory();

      expect(dir, isNotNull);
      expect(dir!.path, contains('ザ・シムズ4'));
    });

    test('finds a game folder sitting outside any known vendor folder',
        () async {
      // "EA" is not a vendor folder we know, and the fallback walks one
      // level, so nothing here is reachable.
      make(['EA', 'ザ・シムズ4', 'Tray']);
      makeFile(['EA', 'ザ・シムズ4', 'GameVersion.txt']);
      make(['EA', 'ザ・シムズ4', 'Mods']);
      final adapter = Sims4Adapter(documentsOverride: docs);

      expect(await adapter.findGameFolder(), isNull,
          reason: 'two levels down is past what the fallback walks');

      // Moved to Documents itself, as a hand-moved folder ends up.
      make(['ザ・シムズ4', 'Tray']);
      makeFile(['ザ・シムズ4', 'GameVersion.txt']);
      make(['ザ・シムズ4', 'Mods']);

      final dir = await adapter.resolveModsDirectory();
      expect(dir, isNotNull);
      expect(p.dirname(dir!.path), p.join(docs.path, 'ザ・シムズ4'));
    });

    test('one marker is not enough', () async {
      make(['Electronic Arts', 'Something Else', 'Tray']);
      make(['Electronic Arts', 'Something Else', 'Mods']);
      final adapter = Sims4Adapter(documentsOverride: docs);

      expect(await adapter.findGameFolder(), isNull);
    });

    test('never overrules a name, so entries cannot claim each other',
        () async {
      // A Sims 3 folder holding Options.ini next to Mods is exactly the
      // overlap the marker list is picked to survive - but the name pass
      // has already spoken for it either way.
      make(['Electronic Arts', 'The Sims 3', 'Mods', 'Packages']);
      makeFile(['Electronic Arts', 'The Sims 3', 'Options.ini']);
      make(['Electronic Arts', 'The Sims 3', 'DCCache']);

      expect(
          await Sims4Adapter(documentsOverride: docs).findGameFolder(), isNull);
      final sims3 =
          await Sims3Adapter(documentsOverride: docs).findGameFolder();
      expect(sims3, isNotNull);
      expect(p.basename(sims3!.path), 'The Sims 3');
    });

    test('the fallback stands down as soon as a name matches', () async {
      make(['Electronic Arts', 'The Sims 4', 'Mods']);
      make(['Electronic Arts', 'Backup', 'Tray']);
      makeFile(['Electronic Arts', 'Backup', 'GameVersion.txt']);
      final adapter = Sims4Adapter(documentsOverride: docs);

      final folders = await adapter.gameDataFolders();

      expect(folders, hasLength(1));
      expect(p.basename(folders.single.path), 'The Sims 4');
    });

    test('Sims 2 and Sims 3 have markers of their own', () async {
      make(['Electronic Arts', 'Симс 3', 'DCCache']);
      make(['Electronic Arts', 'Симс 3', 'InstalledWorlds']);
      make(['Electronic Arts', 'Симс 3', 'Mods', 'Packages']);
      make(['EA Games', '模拟人生2', 'Neighborhoods']);
      make(['EA Games', '模拟人生2', 'Storytelling']);
      make(['EA Games', '模拟人生2', 'Downloads']);

      expect(
          (await Sims3Adapter(documentsOverride: docs).resolveModsDirectory())
              ?.path,
          contains('Симс 3'));
      expect(
          (await Sims2Adapter(documentsOverride: docs).resolveModsDirectory())
              ?.path,
          contains('模拟人生2'));
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

  group('Wine/Proton prefix detection (Sims 2/3/4 on Linux)', () {
    // The temp dir doubles as a fake home; the native Documents override
    // points at an empty folder so only the prefixes can match.
    late Directory nativeDocs;

    setUp(() {
      nativeDocs = make(['native-docs']);
    });

    test('finds The Sims 4 in a Steam Proton compatdata prefix', () async {
      make([
        '.local', 'share', 'Steam', 'steamapps', 'compatdata', '1222670',
        'pfx', 'drive_c', 'users', 'steamuser', 'Documents',
        'Electronic Arts', 'The Sims 4', 'Mods', //
      ]);
      final adapter =
          Sims4Adapter(documentsOverride: nativeDocs, homeOverride: docs.path);

      final dir = await adapter.resolveModsDirectory();

      expect(dir, isNotNull);
      expect(dir!.path, contains(p.join('compatdata', '1222670')));
      expect(dir.path, endsWith('Mods'));
    });

    test('finds The Sims 4 in a Flatpak Steam prefix', () async {
      make([
        '.var', 'app', 'com.valvesoftware.Steam', '.local', 'share', 'Steam',
        'steamapps', 'compatdata', '1222670', 'pfx', 'drive_c', 'users',
        'steamuser', 'Documents', 'Electronic Arts', 'The Sims 4', 'Mods', //
      ]);
      final adapter =
          Sims4Adapter(documentsOverride: nativeDocs, homeOverride: docs.path);

      final dir = await adapter.resolveModsDirectory();

      expect(dir, isNotNull);
      expect(dir!.path, contains('com.valvesoftware.Steam'));
    });

    test('finds a Heroic prefix (extra pfx level)', () async {
      make([
        '.config', 'heroic', 'prefixes', 'The Sims 4', 'pfx', 'drive_c',
        'users', 'steamuser', 'Documents', 'Electronic Arts', 'The Sims 4',
        'Mods', //
      ]);
      final adapter =
          Sims4Adapter(documentsOverride: nativeDocs, homeOverride: docs.path);

      final dir = await adapter.resolveModsDirectory();

      expect(dir, isNotNull);
      expect(dir!.path, contains(p.join('heroic', 'prefixes')));
    });

    test('finds a Lutris prefix under ~/Games (no pfx level)', () async {
      make([
        'Games', 'the-sims-3', 'drive_c', 'users', 'rodri', 'Documents',
        'Electronic Arts', 'The Sims 3', 'Mods', 'Packages', //
      ]);
      final adapter =
          Sims3Adapter(documentsOverride: nativeDocs, homeOverride: docs.path);

      final dir = await adapter.resolveModsDirectory();

      expect(dir, isNotNull);
      expect(dir!.path, contains(p.join('Games', 'the-sims-3')));
    });

    test('finds The Sims 2 in a plain ~/.wine prefix', () async {
      make([
        '.wine', 'drive_c', 'users', 'rodri', 'Documents', 'EA Games',
        'The Sims 2', 'Downloads', //
      ]);
      final adapter =
          Sims2Adapter(documentsOverride: nativeDocs, homeOverride: docs.path);

      final dir = await adapter.resolveModsDirectory();

      expect(dir, isNotNull);
      expect(dir!.path, contains('.wine'));
    });

    test('prefers the native Documents install over prefix copies', () async {
      make(['native-docs', 'Electronic Arts', 'The Sims 4', 'Mods']);
      make([
        '.local', 'share', 'Steam', 'steamapps', 'compatdata', '1222670',
        'pfx', 'drive_c', 'users', 'steamuser', 'Documents',
        'Electronic Arts', 'The Sims 4', 'Mods', //
      ]);
      final adapter =
          Sims4Adapter(documentsOverride: nativeDocs, homeOverride: docs.path);

      final candidates = await adapter.findModsDirectoryCandidates();

      expect(candidates, hasLength(2));
      expect(candidates.first.path, contains('native-docs'));
    });

    test('does not double-count the ~/.steam/steam symlinked library',
        () async {
      make([
        '.local', 'share', 'Steam', 'steamapps', 'compatdata', '1222670',
        'pfx', 'drive_c', 'users', 'steamuser', 'Documents',
        'Electronic Arts', 'The Sims 4', 'Mods', //
      ]);
      Link(p.join(docs.path, '.steam', 'steam')).createSync(
          p.join(docs.path, '.local', 'share', 'Steam'),
          recursive: true);
      final adapter =
          Sims4Adapter(documentsOverride: nativeDocs, homeOverride: docs.path);

      expect(await adapter.findModsDirectoryCandidates(), hasLength(1));
    });
  });

  group('Sims Medieval', () {
    test('finds Origin and Steam installs', () async {
      // Reuse the temp dir as a fake Program Files root.
      make(['Origin Games', 'The Sims Medieval', 'Mods', 'Packages']);
      make([
        'Steam',
        'steamapps',
        'common',
        'The Sims Medieval',
        'Mods',
        'Packages'
      ]);
      final adapter = SimsMedievalAdapter(
          programFilesOverride: [docs.path], homeOverride: docs.path);

      final candidates = await adapter.findModsDirectoryCandidates();

      expect(candidates, hasLength(2));
      expect(candidates.first.path,
          contains(p.join('Origin Games', 'The Sims Medieval')));
    });

    test('finds localized disc installs by the TSM.exe signature', () async {
      makeFile([
        'Electronic Arts',
        'Die Sims Mittelalter',
        'Game',
        'Bin',
        'TSM.exe'
      ]);
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
      make([
        '.local',
        'share',
        'Steam',
        'steamapps',
        'common',
        'The Sims Medieval'
      ]);
      final adapter = SimsMedievalAdapter(
          programFilesOverride: const [], homeOverride: docs.path);

      final install = await adapter.findGameFolder();

      expect(install, isNotNull);
      expect(await adapter.defaultModsPath(),
          p.join(install!.path, 'Mods', 'Packages'));
    });

    test('proposes no path when the game is not installed', () async {
      final adapter = SimsMedievalAdapter(
          programFilesOverride: const [],
          homeOverride: docs.path,
          scanRootsOverride: const []);

      expect(await adapter.defaultModsPath(), isNull);
      expect(await adapter.findGameFolder(), isNull);
    });

    test('finds an install outside the launcher folders by signature',
        () async {
      // The install sits two levels under a scanned root, as bundled
      // downloads and hand-made game folders do.
      makeFile(
          ['Games', 'tsm-bundle', 'Mittelalter', 'Game', 'Bin', 'TSM.exe']);
      final adapter = SimsMedievalAdapter(
          programFilesOverride: const [],
          homeOverride: docs.path,
          scanRootsOverride: [docs.path]);

      final install = await adapter.findGameFolder();

      expect(install, isNotNull);
      expect(p.basename(install!.path), 'Mittelalter');
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

    test(
        'finds CC caches in the localized Documents folder, skipping '
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
      make([
        'Steam',
        'steamapps',
        'common',
        'The Sims Legacy Collection',
        'Downloads'
      ]);
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);

      final candidates = await adapter.findModsDirectoryCandidates();

      expect(candidates, hasLength(2));
      expect(candidates.map((d) => d.path).join(),
          contains(p.join('EA Games', 'The Sims Legacy', 'Downloads')));
    });

    test('finds an install outside the launcher folders by signature',
        () async {
      // What a bundled download looks like: the game inside the bundle's
      // own folder, inside whatever folder the user keeps games in.
      makeFile(['Games', 'sims-bundle', 'The Sims Legacy', 'Sims.exe']);
      final install =
          make(['Games', 'sims-bundle', 'The Sims Legacy', 'GameData']).parent;
      final downloads =
          make(['Games', 'sims-bundle', 'The Sims Legacy', 'Downloads']);
      final adapter = Sims1Adapter(
          programFilesOverride: const [], scanRootsOverride: [docs.path]);

      expect(await adapter.findGameFolder(), isNotNull);
      expect((await adapter.findGameFolder())!.path, install.path);
      expect(await adapter.defaultModsPath(), downloads.path);
      expect((await adapter.findModsDirectoryCandidates()).single.path,
          downloads.path);
    });

    test('ignores folders without the game executable', () async {
      // A folder named like the game but holding no game: the signature,
      // not the name, decides.
      make(['Games', 'The Sims Legacy Collection', 'GameData']);
      final adapter = Sims1Adapter(
          programFilesOverride: const [], scanRootsOverride: [docs.path]);

      expect(await adapter.findGameFolder(), isNull);
      expect(await adapter.defaultModsPath(), isNull);
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

    test('routes single-file installs by type into the game folders', () async {
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

    test('routes dropped-folder contents, keeping the folder in Downloads',
        () async {
      final downloads = makeInstall();
      final install = downloads.parent;
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);
      makeFile(['drop', 'MyCC', 'furniture', 'chair.iff']);
      makeFile(['drop', 'MyCC', 'skins', 'B200FAFit_BWar.cmx']);
      makeFile(['drop', 'MyCC', 'readme.txt']);
      final source = Directory(p.join(docs.path, 'drop', 'MyCC'));

      final mods = await adapter.installFolder(downloads, source);

      expect(mods, hasLength(2));
      // Objects keep the dropped folder (and its structure) in Downloads.
      expect(
          File(p.join(downloads.path, 'MyCC', 'furniture', 'chair.iff'))
              .existsSync(),
          isTrue);
      // Skins are flattened into GameData/Skins like archive installs.
      expect(
          File(p.join(install.path, 'GameData', 'Skins', 'B200FAFit_BWar.cmx'))
              .existsSync(),
          isTrue);
      expect(File(p.join(downloads.path, 'MyCC', 'readme.txt')).existsSync(),
          isFalse);
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

    // ------------------------------------------------------- destinations

    test('offers only the folders this install actually has', () async {
      final downloads = makeInstall();
      make(['Maxis', 'The Sims', 'GameData', 'Skins']);
      make(['Maxis', 'The Sims', 'GameData', 'Global']);
      make(['Maxis', 'The Sims', 'ExpansionPack6']);
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);

      final ids = [
        for (final d in await adapter.installDestinations(downloads)) d.id,
      ];

      expect(ids, contains('Downloads'));
      expect(ids, contains('GameData/Skins'));
      expect(ids, contains('GameData/Global'));
      expect(ids, contains('ExpansionPack6'));
      // Superstar is installed and Makin' Magic is not; offering a folder
      // that isn't there would send a mod into nowhere.
      expect(ids, isNot(contains('ExpansionPack7')));
      expect(ids, isNot(contains('GameData/Walls')));
    });

    test('a folder outside a Sims install has nothing to choose between',
        () async {
      final custom = make(['just-a-folder']);
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);

      expect(await adapter.installDestinations(custom), isEmpty);
    });

    test('the folders in a download decide where its files go', () async {
      // How TS1 hacks are actually handed out: the folder is already
      // around the file, because the readme has to say so anyway.
      final downloads = makeInstall();
      final install = downloads.parent;
      make(['Maxis', 'The Sims', 'GameData', 'Global']);
      make(['Maxis', 'The Sims', 'ExpansionPack6']);
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);
      final zip = makeZip('hack.zip', {
        'GameData/Global/marriage.iff': 'behaviour',
        'ExpansionPack6/GameData/booth.iff': 'a hacked phone booth',
        'loose.iff': 'no folder named, so it sorts by type',
      });

      await adapter.installArchive(downloads, zip);

      expect(
          File(p.join(install.path, 'GameData', 'Global', 'marriage.iff'))
              .existsSync(),
          isTrue);
      // The path below the folder it named is kept exactly as packaged:
      // the download knew, and flattening it would break the override.
      expect(
          File(p.join(
                  install.path, 'ExpansionPack6', 'GameData', 'booth.iff'))
              .existsSync(),
          isTrue);
      expect(File(p.join(downloads.path, 'loose.iff')).existsSync(), isTrue);
    });

    test('a wrapper folder around the download does not hide the folders',
        () async {
      // The ordinary shape of a hack download: one folder with the
      // creator's name on it, and the game's folders inside that.
      final downloads = makeInstall();
      final install = downloads.parent;
      make(['Maxis', 'The Sims', 'GameData', 'Global']);
      make(['Maxis', 'The Sims', 'ExpansionPack6']);
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);
      final zip = makeZip('super-hack.zip', {
        'SuperHack/GameData/Global/marriage.iff': 'behaviour',
        'SuperHack/ExpansionPack6/booth.iff': 'object',
      });

      await adapter.installArchive(downloads, zip);

      expect(
          File(p.join(install.path, 'GameData', 'Global', 'marriage.iff'))
              .existsSync(),
          isTrue);
      expect(
          File(p.join(install.path, 'ExpansionPack6', 'booth.iff'))
              .existsSync(),
          isTrue);
    });

    test('a dropped folder\'s own name does not hide the folders', () async {
      // installFolder measures paths from the folder's parent, so the
      // dropped folder's name is always in front of what it holds.
      final downloads = makeInstall();
      final install = downloads.parent;
      make(['Maxis', 'The Sims', 'GameData', 'Global']);
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);
      makeFile(['drop', 'MyHack', 'GameData', 'Global', 'marriage.iff']);
      makeFile(['drop', 'MyHack', 'chair.iff']);
      final source = Directory(p.join(docs.path, 'drop', 'MyHack'));

      await adapter.installFolder(downloads, source);

      expect(
          File(p.join(install.path, 'GameData', 'Global', 'marriage.iff'))
              .existsSync(),
          isTrue);
      // What the download said nothing about still keeps the dropped
      // folder around it, inside Downloads.
      expect(
          File(p.join(downloads.path, 'MyHack', 'chair.iff')).existsSync(),
          isTrue);
    });

    test('the deepest folder named wins', () async {
      final downloads = makeInstall();
      final install = downloads.parent;
      make(['Maxis', 'The Sims', 'GameData', 'Global']);
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);
      // Downloads is a destination too, and it comes first in the list;
      // the one nearest the file is the one the creator meant.
      final zip = makeZip('both.zip',
          {'Downloads/GameData/Global/x.iff': 'behaviour'});

      await adapter.installArchive(downloads, zip);

      expect(
          File(p.join(install.path, 'GameData', 'Global', 'x.iff'))
              .existsSync(),
          isTrue);
    });

    test('what a download names still goes through the path rules',
        () async {
      // The folders an archive names are someone else's text, so the
      // whole path is resolved through install_path rather than joined
      // raw. What that then does about reserved names and the length
      // limit is the platform's business and install_path_test's, so what
      // is pinned here is that it is reached at all.
      final downloads = makeInstall();
      final install = downloads.parent;
      make(['Maxis', 'The Sims', 'GameData', 'Global']);
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);
      final deep = List.filled(12, 'x' * 30).join('/');
      final zip = makeZip('nasty.zip', {
        'GameData/Global/CON/a.iff': 'reserved device name on Windows',
        'GameData/Global/$deep/b.iff': 'far past the Windows path limit',
        'GameData/Global/plain.iff': 'nothing wrong with this one',
      });

      final mods = await adapter.installArchive(downloads, zip);

      expect(mods, hasLength(3));
      final global = p.join(install.path, 'GameData', 'Global');
      for (final mod in mods) {
        expect(p.isWithin(global, mod.path), isTrue,
            reason: '${mod.path} should still land under Global');
        // p.join would have left a "/./" here for a file with no folder
        // below the one it named.
        expect(mod.path, isNot(contains('${p.separator}.${p.separator}')));
        expect(File(mod.path).existsSync(), isTrue);
      }
      expect(File(p.join(global, 'plain.iff')).existsSync(), isTrue);
    });

    test('a named folder keeps two same-named files apart', () async {
      // The folders above the one it named are dropped, so two files the
      // archive told apart that way arrive on the same path. Neither of
      // them asked to replace the other.
      final downloads = makeInstall();
      final install = downloads.parent;
      make(['Maxis', 'The Sims', 'GameData', 'Global']);
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);
      final zip = makeZip('two-hacks.zip', {
        'A/GameData/Global/x.iff': 'one',
        'B/GameData/Global/x.iff': 'the other',
      });

      final mods = await adapter.installArchive(downloads, zip);

      expect(mods, hasLength(2));
      expect(mods.map((m) => m.path).toSet(), hasLength(2));
      expect(
          Directory(p.join(install.path, 'GameData', 'Global'))
              .listSync()
              .whereType<File>()
              .length,
          2);
    });

    test('reinstalling the same download does not pile up copies', () async {
      final downloads = makeInstall();
      final install = downloads.parent;
      make(['Maxis', 'The Sims', 'GameData', 'Global']);
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);
      final zip = makeZip('again.zip', {'GameData/Global/x.iff': 'one'});
      final landed = p.join(install.path, 'GameData', 'Global', 'x.iff');

      await adapter.installArchive(downloads, zip);
      // What the app hands over on the second install: this file is on
      // record as one it put there itself, so it is a previous version
      // of the same mod rather than something of the game's to keep.
      await adapter
          .installArchive(downloads, zip, placed: {p.canonicalize(landed)});

      expect(
          Directory(p.join(install.path, 'GameData', 'Global'))
              .listSync()
              .whereType<File>()
              .length,
          1);
    });

    test('a hack that overrides a Maxis file keeps the original', () async {
      final downloads = makeInstall();
      final install = downloads.parent;
      make(['Maxis', 'The Sims', 'GameData', 'Global']);
      final global = p.join(install.path, 'GameData', 'Global');
      File(p.join(global, 'x.iff')).writeAsStringSync('what Maxis shipped');
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);
      final zip = makeZip('hack.zip', {'GameData/Global/x.iff': 'the hack'});

      final mods = await adapter.installArchive(downloads, zip);

      expect(File(p.join(global, 'x.iff')).readAsStringSync(), 'the hack');
      expect(File(p.join(global, 'x.iff.smmbak')).readAsStringSync(),
          'what Maxis shipped');

      // And uninstalling gives the game back its own file rather than
      // leaving a hole where a behaviour used to be.
      await adapter.removeMod(mods.single);

      expect(File(p.join(global, 'x.iff')).readAsStringSync(),
          'what Maxis shipped');
      expect(File(p.join(global, 'x.iff.smmbak')).existsSync(), isFalse);
    });

    test('a chosen folder keeps two same-named files apart', () async {
      final downloads = makeInstall();
      final install = downloads.parent;
      make(['Maxis', 'The Sims', 'GameData', 'Global']);
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);
      final zip = makeZip('twins.zip', {
        'a/x.iff': 'one',
        'b/x.iff': 'the other',
      });

      final mods = await adapter.installArchive(downloads, zip,
          placement: const ChosenPlacement('GameData/Global'));

      // Flattened into one folder, but not on top of each other.
      expect(mods, hasLength(2));
      expect(mods.map((m) => m.path).toSet(), hasLength(2));
      expect(
          Directory(p.join(install.path, 'GameData', 'Global'))
              .listSync()
              .whereType<File>()
              .length,
          2);
    });

    test('a named folder is matched whatever case it was packaged in',
        () async {
      final downloads = makeInstall();
      final install = downloads.parent;
      make(['Maxis', 'The Sims', 'GameData', 'Global']);
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);
      final zip = makeZip('shouty.zip', {'gamedata/GLOBAL/x.iff': 'behaviour'});

      await adapter.installArchive(downloads, zip);

      expect(
          File(p.join(install.path, 'GameData', 'Global', 'x.iff'))
              .existsSync(),
          isTrue);
    });

    test('a folder the install does not have is left to the type rule',
        () async {
      // No Superstar here, so ExpansionPack6 is not a folder to write to.
      final downloads = makeInstall();
      final install = downloads.parent;
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);
      final zip = makeZip('ep.zip', {'ExpansionPack6/booth.iff': 'object'});

      await adapter.installArchive(downloads, zip);

      expect(Directory(p.join(install.path, 'ExpansionPack6')).existsSync(),
          isFalse);
      expect(
          File(p.join(downloads.path, 'ExpansionPack6', 'booth.iff'))
              .existsSync(),
          isTrue);
    });

    test('a chosen folder overrules the type rule', () async {
      // The case the sorting cannot get right on its own: skins that are
      // meant to stay in Downloads so they never reach Create a Sim.
      final downloads = makeInstall();
      final install = downloads.parent;
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);

      await adapter.installMod(downloads, makeFile(['src', 'waiter.skn']),
          placement: const ChosenPlacement('Downloads'));

      expect(File(p.join(downloads.path, 'waiter.skn')).existsSync(), isTrue);
      expect(
          File(p.join(install.path, 'GameData', 'Skins', 'waiter.skn'))
              .existsSync(),
          isFalse);
    });

    test('a chosen folder takes the whole archive, flat', () async {
      final downloads = makeInstall();
      final install = downloads.parent;
      make(['Maxis', 'The Sims', 'GameData', 'Global']);
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);
      final zip = makeZip('mixed.zip', {
        'chair.iff': 'object',
        'skins/head.cmx': 'animation',
      });

      await adapter.installArchive(downloads, zip,
          placement: const ChosenPlacement('GameData/Global'));

      // Flat, because a folder someone picked by hand was picked for the
      // files rather than for the archive's own layout - "skins/" there is
      // how the author tidied their zip, not a path the game reads.
      final global = p.join(install.path, 'GameData', 'Global');
      expect(File(p.join(global, 'chair.iff')).existsSync(), isTrue);
      expect(File(p.join(global, 'head.cmx')).existsSync(), isTrue);
      expect(
          File(p.join(install.path, 'GameData', 'Skins', 'head.cmx'))
              .existsSync(),
          isFalse);
    });

    test('choosing Downloads keeps the archive\'s folders', () async {
      // The one folder the game does read subfolders in, and the reason
      // this choice exists: skins meant to stay out of Create a Sim.
      final downloads = makeInstall();
      final install = downloads.parent;
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);
      final zip = makeZip('npc.zip', {'waiters/head.cmx': 'animation'});

      await adapter.installArchive(downloads, zip,
          placement: const ChosenPlacement('Downloads'));

      expect(File(p.join(downloads.path, 'waiters', 'head.cmx')).existsSync(),
          isTrue);
      expect(
          File(p.join(install.path, 'GameData', 'Skins', 'head.cmx'))
              .existsSync(),
          isFalse);
    });

    test('a chosen folder that has gone falls back to the mods folder',
        () async {
      final downloads = makeInstall();
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);

      await adapter.installMod(downloads, makeFile(['src', 'chair.iff']),
          placement: const ChosenPlacement('ExpansionPack7'));

      expect(File(p.join(downloads.path, 'chair.iff')).existsSync(), isTrue);
    });

    test('the folders holding Maxis files stay out of the library',
        () async {
      final downloads = makeInstall();
      make(['Maxis', 'The Sims', 'GameData', 'Skins']);
      makeFile(['Maxis', 'The Sims', 'Downloads', 'chair.iff']);
      makeFile(['Maxis', 'The Sims', 'GameData', 'Skins', 'head.cmx']);
      // The game's own behaviour files. Sweeping these into the library
      // would hand the user a switch that turns off the base game.
      makeFile(['Maxis', 'The Sims', 'GameData', 'Global', 'Global.iff']);
      makeFile(['Maxis', 'The Sims', 'ExpansionPack6', 'Superstar.iff']);
      final adapter = Sims1Adapter(programFilesOverride: [docs.path]);

      final mods = await adapter.listMods(downloads);

      expect(mods.map((m) => m.name),
          unorderedEquals(['chair.iff', 'head.cmx']));
    });
  });

  group('every Sims adapter', () {
    test('has a save reader of its own', () {
      const adapters = [
        Sims1Adapter(),
        Sims2Adapter(),
        Sims3Adapter(),
        Sims4Adapter(),
        SimsMedievalAdapter(),
      ];
      for (final adapter in adapters) {
        expect(adapter.hasSaves, isTrue, reason: adapter.game.id);
      }
    });
  });

  group('Steam libraries', () {
    test('reads the extra libraries out of libraryfolders.vdf', () async {
      final steam = make(['Steam']);
      makeFile(['Steam', 'config', 'libraryfolders.vdf']).writeAsStringSync(r'''
"libraryfolders"
{
	"0"
	{
		"path"		"C:\\Program Files (x86)\\Steam"
		"label"		""
	}
	"1"
	{
		"path"		"D:\\SteamLibrary"
		"label"		""
	}
}
''');

      final libraries = await steamLibraries(steamRootsOverride: [steam.path]);

      // Steam's own folder counts as a library, and the escaped Windows
      // paths come back usable.
      expect(libraries, [
        steam.path,
        r'C:\Program Files (x86)\Steam',
        r'D:\SteamLibrary',
      ]);
    });

    test('ignores a Steam folder that is not there', () async {
      expect(
          await steamLibraries(steamRootsOverride: [p.join(docs.path, 'nope')]),
          isEmpty);
    });
  });
}
