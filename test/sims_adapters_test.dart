import 'dart:io';

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
  });
}
