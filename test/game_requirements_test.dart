import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sims_mod_manager/src/core/resource_cfg.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims_adapters.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';

void main() {
  late Directory root;

  setUp(() => root = Directory.systemTemp.createTempSync('mod_manager_req'));
  tearDown(() => root.deleteSync(recursive: true));

  File write(String relative, String contents) {
    final file = File(p.join(root.path, p.joinAll(relative.split('/'))));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(contents);
    return file;
  }

  group('reading an ini', () {
    test('keys come back lowercased and trimmed', () async {
      final file = write('Options.ini', 'ModsDisabled = 1\n'
          'scriptmodsenabled=0\n');

      expect(await readIniSettings(file),
          {'modsdisabled': '1', 'scriptmodsenabled': '0'});
    });

    test('comments, blanks and junk lines are skipped', () async {
      final file = write('Options.ini', '; a comment\n'
          '\n'
          '# another\n'
          'nonsense\n'
          '=novalue\n'
          'modsdisabled=0\n');

      expect(await readIniSettings(file), {'modsdisabled': '0'});
    });

    test('a file that is not there is not an empty file', () async {
      expect(await readIniSettings(File(p.join(root.path, 'nope.ini'))), isNull);
    });
  });

  group('The Sims Medieval', () {
    late Directory modsDir;

    setUp(() {
      modsDir = Directory(p.join(root.path, 'Mods', 'Packages'))
        ..createSync(recursive: true);
      // The install signature, so this looks like the real game.
      write('Game/Bin/TSM.exe', 'exe');
    });

    test('asks for the loader when it is not there', () async {
      expect(await const SimsMedievalAdapter().unmetRequirements(modsDir),
          ['medievalModLoader']);
    });

    test('says nothing once the loader is in place', () async {
      write('Game/Bin/d3dx9_31.dll', 'dll');

      expect(await const SimsMedievalAdapter().unmetRequirements(modsDir),
          isEmpty);
    });

    test('says nothing about a folder that is not a game install', () async {
      // A mods folder the user pointed somewhere else entirely has no
      // Game\Bin to look in, so there is nothing to report on.
      final elsewhere =
          Directory(p.join(root.path, 'elsewhere', 'Mods', 'Packages'))
            ..createSync(recursive: true);

      expect(await const SimsMedievalAdapter().unmetRequirements(elsewhere),
          isEmpty);
    });

    test('the loader has somewhere to send people', () {
      expect(AppController.requirementHelpUrl('medievalModLoader'),
          startsWith('https://'));
    });
  });

  group('The Sims 4', () {
    late Directory modsDir;

    setUp(() {
      modsDir = Directory(p.join(root.path, 'Mods'))..createSync();
    });

    test('reports mods switched off in the game itself', () async {
      write('Options.ini', 'modsdisabled = 1\nscriptmodsenabled = 1\n');

      expect(await const Sims4Adapter().unmetRequirements(modsDir),
          ['sims4ModsOff']);
    });

    test('script mods off only matters when there are script mods',
        () async {
      write('Options.ini', 'modsdisabled = 0\nscriptmodsenabled = 0\n');
      expect(
          await const Sims4Adapter().unmetRequirements(modsDir), isEmpty);

      write('Mods/deeper/cheats.ts4script', 'script');
      expect(await const Sims4Adapter().unmetRequirements(modsDir),
          ['sims4ScriptModsOff']);
    });

    test('both at once are both reported', () async {
      write('Options.ini', 'modsdisabled = 1\nscriptmodsenabled = 0\n');
      write('Mods/cheats.ts4script', 'script');

      expect(await const Sims4Adapter().unmetRequirements(modsDir),
          ['sims4ModsOff', 'sims4ScriptModsOff']);
    });

    test('a game set up properly says nothing', () async {
      write('Options.ini', 'modsdisabled = 0\nscriptmodsenabled = 1\n');
      write('Mods/cheats.ts4script', 'script');

      expect(await const Sims4Adapter().unmetRequirements(modsDir), isEmpty);
    });

    test('no Options.ini yet means the game has not run, not that mods '
        'are off', () async {
      expect(await const Sims4Adapter().unmetRequirements(modsDir), isEmpty);
    });

    test('an in-game switch is fixed in the game, not through a link', () {
      expect(AppController.requirementHelpUrl('sims4ModsOff'), isNull);
    });
  });

  group('the other games', () {
    test('have nothing to ask for', () async {
      final mods = Directory(p.join(root.path, 'mods'))..createSync();

      expect(await const Sims3Adapter().unmetRequirements(mods), isEmpty);
      expect(await const Sims2Adapter().unmetRequirements(mods), isEmpty);
      expect(await const Sims1Adapter().unmetRequirements(mods), isEmpty);
    });
  });
}
