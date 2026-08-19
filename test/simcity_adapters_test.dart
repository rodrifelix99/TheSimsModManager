import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sims_mod_manager/src/core/app_message.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/games/simcity/sc4pac.dart';
import 'package:sims_mod_manager/src/games/simcity/simcity_adapters.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';

/// Every adapter here is handed its installs rather than left to find
/// them, so the tests say the same thing on a machine with none of these
/// games and on the one they were written against.
///
/// The layouts are the real ones, read off installed copies:
/// SimCity 4 Deluxe on Steam, SimCity 3000 Unlimited from GOG, SimCity
/// Societies with Destinations, and SimCity (2013) with Cities of
/// Tomorrow. See `docs/simcity-support-validation.md`.
void main() {
  late Directory temp;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('simcity_test');
  });

  tearDown(() async {
    if (await temp.exists()) await temp.delete(recursive: true);
  });

  Directory dir(List<String> segments) =>
      Directory(p.joinAll([temp.path, ...segments]));

  Future<Directory> makeDir(List<String> segments) =>
      dir(segments).create(recursive: true);

  Future<File> makeFile(List<String> segments, [String body = 'x']) async {
    final file = File(p.joinAll([temp.path, ...segments]));
    await file.parent.create(recursive: true);
    return file.writeAsString(body);
  }

  // -------------------------------------------------------------------
  // SimCity 4
  // -------------------------------------------------------------------

  /// A SimCity 4 Deluxe install and a Documents folder beside it.
  Future<
      ({
        Directory install,
        Directory documents,
        Directory plugins,
      })> sc4Layout() async {
    final install = await makeDir(['games', 'SimCity 4 Deluxe']);
    await makeFile(['games', 'SimCity 4 Deluxe', 'Apps', 'SimCity 4.exe']);
    await makeFile(['games', 'SimCity 4 Deluxe', 'Apps', 'SimCity 4.ini'],
        '[Directories]\nData=..\\\nPlugIn=..\\Plugins\\\n');
    await makeDir(['games', 'SimCity 4 Deluxe', 'Plugins']);
    final documents = await makeDir(['Documents']);
    final plugins = await makeDir(['Documents', 'SimCity 4', 'Plugins']);
    return (install: install, documents: documents, plugins: plugins);
  }

  SimCity4Adapter sc4(
    ({Directory install, Directory documents, Directory plugins}) layout, {
    List<Sc4pacProfile>? sc4pac,
  }) =>
      SimCity4Adapter(
        searchOverride: [layout.install],
        documentsOverride: layout.documents,
        sc4pacProfilesOverride: sc4pac ?? const <Sc4pacProfile>[],
      );

  group('SimCity 4 detection', () {
    test('finds the install by its executable, not its folder name',
        () async {
      final layout = await sc4Layout();
      expect((await sc4(layout).findGameFolder())?.path, layout.install.path);
    });

    test('refuses a folder that only looks like the game', () async {
      final layout = await sc4Layout();
      final decoy = await makeDir(['games', 'SimCity 4 Deluxe Backup']);
      await makeFile(['games', 'SimCity 4 Deluxe Backup', 'readme.txt']);
      final adapter = SimCity4Adapter(
          searchOverride: [decoy],
          documentsOverride: layout.documents,
          sc4pacProfilesOverride: const []);
      expect(await adapter.findGameFolder(), isNull);
    });

    test('the mods folder is the user one, the install one an extra root',
        () async {
      final layout = await sc4Layout();
      final adapter = sc4(layout);
      final mods = await adapter.resolveModsDirectory();
      expect(mods?.path, layout.plugins.path);
      final extras = await adapter.extraModsDirectories(mods!);
      expect(extras.map((d) => d.path),
          [p.join(layout.install.path, 'Plugins')]);
    });

    test('an sc4pac profile pointing elsewhere is where the user installs',
        () async {
      final layout = await sc4Layout();
      final custom = await makeDir(['Elsewhere', 'SC4', 'Plugins']);
      final adapter = sc4(layout, sc4pac: [
        Sc4pacProfile(pluginsRoot: custom.path, ownedPaths: const {}),
      ]);
      expect((await adapter.resolveModsDirectory())?.path, custom.path);
      expect(await adapter.defaultModsPath(), custom.path);
    });

    test('reads mods however deep the tree goes', () async {
      final layout = await sc4Layout();
      await makeFile([
        'Documents', 'SimCity 4', 'Plugins', //
        'Network Addon Mod', '8 Texture Support', 'US', 'Props', 'sign.dat',
      ]);
      final adapter = sc4(layout);
      final mods = await adapter.listMods(layout.plugins);
      expect(mods.map((m) => m.name), ['sign.dat']);
      expect(await adapter.modDepthLimit(layout.plugins), isNull,
          reason: 'the Network Addon Mod ships four levels and loads');
    });

    test('lists what is in the install Plugins folder too', () async {
      final layout = await sc4Layout();
      await makeFile(['games', 'SimCity 4 Deluxe', 'Plugins', 'fix.dat']);
      await makeFile(['Documents', 'SimCity 4', 'Plugins', 'mine.dat']);
      final mods = await sc4(layout).listMods(layout.plugins);
      expect(mods.map((m) => m.name).toSet(), {'fix.dat', 'mine.dat'});
    });
  });

  group('SimCity 4 and sc4pac', () {
    /// The exact trap this exists for, from the reference machine:
    /// sc4pac stores a DLL plugin in a versioned folder and symlinks it
    /// to the top of Plugins, because SimCity 4 loads DLLs from there
    /// and nowhere else. Both paths are real files with a mod
    /// extension, so a manager reading the folder alone shows two
    /// plugins as four - and then the duplicate scan hashes them, finds
    /// them identical, and offers to delete "the spare copies".
    Future<void> layOutSc4pac(Directory plugins) async {
      final owned = Directory(p.join(
          plugins.path, '150-mods', 'simmaster07.extra-cheats-dll.1.1.1-3.sc4pac'));
      await owned.create(recursive: true);
      await File(p.join(owned.path, 'ExtraExtraCheats.dll')).writeAsString('a');
      await File(p.join(plugins.path, 'ExtraExtraCheats.dll')).writeAsString('a');
      await Directory(p.join(plugins.path, '060-config',
              'config.sc4-edition.Windows-digital.1.sc4pac'))
          .create(recursive: true);
    }

    Sc4pacProfile profileFor(Directory plugins) => Sc4pacProfile(
          pluginsRoot: plugins.path,
          ownedPaths: ownedPathsIn(jsonDecode('''
{"installed":[
  {"files":["060-config/config.sc4-edition.Windows-digital.1.sc4pac"]},
  {"files":["150-mods/simmaster07.extra-cheats-dll.1.1.1-3.sc4pac",
            "ExtraExtraCheats.dll"]}
]}''') as Map<String, Object?>),
        );

    test('holds back everything the lock file claims', () async {
      final layout = await sc4Layout();
      await layOutSc4pac(layout.plugins);
      await makeFile(['Documents', 'SimCity 4', 'Plugins', 'mine.dat']);

      final unfiltered = await sc4(layout).listMods(layout.plugins);
      expect(unfiltered.length, 3,
          reason: 'the link, its target, and the user own mod');

      final filtered = await sc4(layout, sc4pac: [profileFor(layout.plugins)])
          .listMods(layout.plugins);
      expect(filtered.map((m) => m.name), ['mine.dat']);
    });

    test('a lock file that will not parse still stops at the suffix',
        () async {
      final layout = await sc4Layout();
      await layOutSc4pac(layout.plugins);
      await makeFile(['Documents', 'SimCity 4', 'Plugins', 'mine.dat']);
      final filtered = await sc4(layout, sc4pac: [
        Sc4pacProfile(pluginsRoot: layout.plugins.path, ownedPaths: const {}),
      ]).listMods(layout.plugins);
      // The suffix reaches sc4pac's storage folder and, without a lock
      // file, nothing else - so the symlink at the top of Plugins is
      // still listed. That is the safe half to get wrong: the file the
      // game actually loads stays visible, its stored twin does not, and
      // the pair the duplicate scan would have offered to delete is
      // never formed.
      expect(filtered.map((m) => m.name), ['ExtraExtraCheats.dll', 'mine.dat']);
      expect(
          filtered.every((m) => !m.path.contains('.sc4pac')), isTrue,
          reason: 'nothing inside an sc4pac package folder is ours');
    });

    test('reads the records sc4pac keeps beside the Plugins folder',
        () async {
      final layout = await sc4Layout();
      await layOutSc4pac(layout.plugins);
      await File(p.join(layout.plugins.path, 'sc4pac-plugins-lock.json'))
          .writeAsString('{"installed":[{"files":["ExtraExtraCheats.dll"]}]}');
      final beside = await readSc4pacProfileBeside(layout.plugins);
      expect(beside, isNotNull);
      expect(ownsPath(beside!, 'ExtraExtraCheats.dll'), isTrue);
    });

    test('ownership covers everything under a claimed folder', () {
      final profile = Sc4pacProfile(
          pluginsRoot: r'C:\Plugins', ownedPaths: const {'150-mods/a.sc4pac'});
      expect(ownsPath(profile, '150-mods/a.sc4pac'), isTrue);
      expect(ownsPath(profile, r'150-mods\a.sc4pac\thing.dat'), isTrue);
      expect(ownsPath(profile, '150-mods/a.sc4pac-other/thing.dat'), isFalse,
          reason: 'a prefix is not a parent folder');
      expect(ownsPath(profile, '150-mods/b.sc4pac'), isFalse);
    });

    test('a malformed lock file costs nothing', () {
      expect(ownedPathsIn(null), isEmpty);
      expect(ownedPathsIn(<String, Object?>{'installed': 'nope'}), isEmpty);
      expect(
          ownedPathsIn(<String, Object?>{
            'installed': [
              {'files': null},
              {'files': <Object?>['ok.dat', 7]},
            ],
          }),
          {'ok.dat'});
    });
  });

  group('SimCity 4 multi-file plugins', () {
    test('an .ini beside a .dll installs but is never a mod of its own',
        () async {
      final layout = await sc4Layout();
      final source = await makeDir(['download', 'SC4AutoSave']);
      await makeFile(['download', 'SC4AutoSave', 'SC4AutoSave.dll'], 'dll');
      await makeFile(['download', 'SC4AutoSave', 'SC4AutoSave.ini'], 'cfg');
      await makeFile(['download', 'SC4AutoSave', 'readme.txt'], 'hi');

      final adapter = sc4(layout);
      final installed = await adapter.installFolder(layout.plugins, source);
      expect(installed.map((m) => m.name), ['SC4AutoSave.dll'],
          reason: 'the settings file rides along, it is not a second mod');
      expect(
          File(p.join(layout.plugins.path, 'SC4AutoSave.ini')).existsSync(),
          isTrue);
      expect(
          File(p.join(layout.plugins.path, 'readme.txt')).existsSync(),
          isFalse);
    });

    test('a DLL is lifted to the top of the root, its settings with it',
        () async {
      final layout = await sc4Layout();
      final source = await makeDir(['download', 'SC4AutoSave']);
      await makeFile(['download', 'SC4AutoSave', 'SC4AutoSave.dll'], 'dll');
      await makeFile(['download', 'SC4AutoSave', 'SC4AutoSave.ini'], 'cfg');

      final installed = await sc4(layout).installFolder(layout.plugins, source);
      expect(p.dirname(installed.single.path), layout.plugins.path,
          reason: 'a DLL in a subfolder is a file the game never opens');
      expect(
          File(p.join(layout.plugins.path, 'SC4AutoSave.ini')).existsSync(),
          isTrue);
    });

    test('reinstalling a plugin replaces the stale copy at the top',
        () async {
      final layout = await sc4Layout();
      await makeFile(
          ['Documents', 'SimCity 4', 'Plugins', 'SC4AutoSave.dll'], 'old');
      final source = await makeDir(['download', 'SC4AutoSave']);
      await makeFile(['download', 'SC4AutoSave', 'SC4AutoSave.dll'], 'new');

      final installed = await sc4(layout).installFolder(layout.plugins, source);

      expect(p.dirname(installed.single.path), layout.plugins.path,
          reason: 'the update lifts to the only place SimCity 4 loads a '
              'DLL from, not left stranded beside the stale one');
      expect(
          File(p.join(layout.plugins.path, 'SC4AutoSave.dll'))
              .readAsStringSync(),
          'new');
    });

    test('a .dat keeps the folder the download put it in', () async {
      final layout = await sc4Layout();
      final source = await makeDir(['download', 'zzz_override']);
      await makeFile(['download', 'zzz_override', 'a.dat'], 'a');
      await makeFile(['download', 'zzz_override', 'deep', 'b.dat'], 'b');

      final installed = await sc4(layout).installFolder(layout.plugins, source);
      final relative = installed
          .map((m) => p.relative(m.path, from: layout.plugins.path))
          .map((r) => r.replaceAll(r'\', '/'))
          .toSet();
      expect(relative, {'zzz_override/a.dat', 'zzz_override/deep/b.dat'},
          reason: 'for this game the folder a file sits in is load order');
    });

    test('disabling a plugin takes its settings file with it', () async {
      final layout = await sc4Layout();
      final dll = await makeFile(
          ['Documents', 'SimCity 4', 'Plugins', 'SC4AutoSave.dll'], 'dll');
      await makeFile(
          ['Documents', 'SimCity 4', 'Plugins', 'SC4AutoSave.ini'], 'cfg');
      final adapter = sc4(layout);
      final mod = adapter.modAt(dll.path)!;

      final off = await adapter.setEnabled(mod, enabled: false);
      expect(off.status, ModStatus.disabled);
      expect(
          File(p.join(layout.plugins.path, 'SC4AutoSave.ini.disabled'))
              .existsSync(),
          isTrue,
          reason: 'a plugin that comes back reset is a plugin half switched');
      expect(File(p.join(layout.plugins.path, 'SC4AutoSave.ini')).existsSync(),
          isFalse);

      final on = await adapter.setEnabled(off, enabled: true);
      expect(on.status, ModStatus.enabled);
      expect(File(p.join(layout.plugins.path, 'SC4AutoSave.ini')).existsSync(),
          isTrue);
    });

    test('uninstalling a plugin takes the log it wrote with it', () async {
      // Found by the end-to-end cycle against the real game: the plugin
      // writes SC4AutoSave.log the first time it loads, `.log` is not a
      // mod extension, so uninstalling left a file the library could
      // not see and the user had no reason to keep.
      final layout = await sc4Layout();
      final dll = await makeFile(
          ['Documents', 'SimCity 4', 'Plugins', 'SC4AutoSave.dll'], 'dll');
      await makeFile(
          ['Documents', 'SimCity 4', 'Plugins', 'SC4AutoSave.log'], 'ran');
      await makeFile(
          ['Documents', 'SimCity 4', 'Plugins', 'Keep.log'], 'someone else');
      final adapter = sc4(layout);
      await adapter.removeMod(adapter.modAt(dll.path)!);
      expect(File(p.join(layout.plugins.path, 'SC4AutoSave.log')).existsSync(),
          isFalse);
      expect(File(p.join(layout.plugins.path, 'Keep.log')).existsSync(), isTrue,
          reason: 'only the log sharing the plugin name is the plugin own');
    });

    test('a log is not installed, and does not follow a disable', () async {
      final layout = await sc4Layout();
      final source = await makeDir(['download', 'plug']);
      await makeFile(['download', 'plug', 'Thing.dll'], 'dll');
      await makeFile(['download', 'plug', 'Thing.log'], 'stale log in the zip');
      final adapter = sc4(layout);
      final installed = await adapter.installFolder(layout.plugins, source);
      expect(File(p.join(layout.plugins.path, 'Thing.log')).existsSync(), isFalse,
          reason: 'a log is output, never something a download brings in');

      await makeFile(['Documents', 'SimCity 4', 'Plugins', 'Thing.log'], 'ran');
      await adapter.setEnabled(installed.single, enabled: false);
      expect(File(p.join(layout.plugins.path, 'Thing.log')).existsSync(), isTrue,
          reason: 'a log records what happened; it is not the mod state');
    });

    test('uninstalling a plugin takes its settings file with it', () async {
      final layout = await sc4Layout();
      final dll = await makeFile(
          ['Documents', 'SimCity 4', 'Plugins', 'SC4AutoSave.dll'], 'dll');
      await makeFile(
          ['Documents', 'SimCity 4', 'Plugins', 'SC4AutoSave.ini'], 'cfg');
      await makeFile(
          ['Documents', 'SimCity 4', 'Plugins', 'Other.ini'], 'unrelated');
      final adapter = sc4(layout);
      await adapter.removeMod(adapter.modAt(dll.path)!);
      expect(File(p.join(layout.plugins.path, 'SC4AutoSave.ini')).existsSync(),
          isFalse);
      expect(File(p.join(layout.plugins.path, 'Other.ini')).existsSync(), isTrue,
          reason: 'only the companion sharing the plugin name is its own');
    });
  });

  // -------------------------------------------------------------------
  // SimCity 3000
  // -------------------------------------------------------------------

  group('SimCity 3000', () {
    Future<Directory> layout({String exe = 'SC3U.exe'}) async {
      final install = await makeDir(['games', 'SimCity 3000 Unlimited']);
      await makeFile(['games', 'SimCity 3000 Unlimited', 'Apps', exe]);
      await makeDir(['games', 'SimCity 3000 Unlimited', 'Buildings']);
      return install;
    }

    SimCity3000Adapter adapterFor(Directory install) =>
        SimCity3000Adapter(searchOverride: [install]);

    test('finds either edition by its own executable', () async {
      final unlimited = await layout();
      expect(await adapterFor(unlimited).isUnlimited(), isTrue);
      expect((await adapterFor(unlimited).resolveModsDirectory())?.path,
          p.join(unlimited.path, 'Buildings'));
    });

    test('the base game is found and is not reported as Unlimited',
        () async {
      await temp.list().forEach((e) {});
      final base = await makeDir(['plain', 'SimCity 3000']);
      await makeFile(['plain', 'SimCity 3000', 'Apps', 'SC3.exe']);
      await makeDir(['plain', 'SimCity 3000', 'Buildings']);
      final adapter = SimCity3000Adapter(searchOverride: [base]);
      expect(await adapter.findGameFolder(), isNotNull);
      expect(await adapter.isUnlimited(), isFalse);
    });

    test('never offers to delete a building the game shipped', () async {
      final install = await layout();
      await makeFile(
          ['games', 'SimCity 3000 Unlimited', 'Buildings', 'Maxis Towers.bld']);
      await makeFile(
          ['games', 'SimCity 3000 Unlimited', 'Buildings', 'My Tower.bld']);
      final adapter = adapterFor(install);
      final mods =
          await adapter.listMods(Directory(p.join(install.path, 'Buildings')));
      expect(mods.map((m) => m.name), ['My Tower.bld']);
    });

    test('the buildings folder is flat, and says so', () async {
      final install = await layout();
      final adapter = adapterFor(install);
      expect(
          await adapter
              .modDepthLimit(Directory(p.join(install.path, 'Buildings'))),
          0,
          reason: 'a building in a subfolder is never loaded');
    });

    test('installs and removes a custom building', () async {
      final install = await layout();
      final buildings = Directory(p.join(install.path, 'Buildings'));
      final source = await makeFile(['download', 'Tower.bld'], 'bld');
      final adapter = adapterFor(install);
      final mod = await adapter.installMod(buildings, source);
      expect(mod.category, 'Building');
      expect(File(p.join(buildings.path, 'Tower.bld')).existsSync(), isTrue);
      await adapter.removeMod(mod);
      expect(File(p.join(buildings.path, 'Tower.bld')).existsSync(), isFalse);
    });
  });

  // -------------------------------------------------------------------
  // SimCity (2013)
  // -------------------------------------------------------------------

  group('SimCity (2013)', () {
    Future<Directory> layout({bool citiesOfTomorrow = false}) async {
      final install = await makeDir(['games', 'SimCity']);
      await makeFile(['games', 'SimCity', 'SimCity', 'SimCity.exe']);
      await makeFile(
          ['games', 'SimCity', 'SimCityData', 'SimCity_Game.package']);
      await makeDir(['games', 'SimCity', 'SimCityUserData', 'Packages']);
      if (citiesOfTomorrow) {
        await makeFile(
            ['games', 'SimCity', 'SimCityData', 'SimCityDataEP1.package']);
      }
      return install;
    }

    test('needs the executable and the data folder, not the name', () async {
      final install = await layout();
      final adapter = SimCity2013Adapter(searchOverride: [install]);
      expect(await adapter.findGameFolder(), isNotNull);
      expect((await adapter.resolveModsDirectory())?.path,
          p.join(install.path, 'SimCityUserData', 'Packages'));
    });

    test('a SimCity 4 install is not mistaken for this one', () async {
      final sc4Install = await makeDir(['games', 'SimCity']);
      await makeFile(['games', 'SimCity', 'Apps', 'SimCity 4.exe']);
      expect(
          await SimCity2013Adapter(searchOverride: [sc4Install])
              .findGameFolder(),
          isNull);
    });

    test('Cities of Tomorrow is read off the disk, never assumed', () async {
      expect(
          await SimCity2013Adapter(searchOverride: [await layout()])
              .hasCitiesOfTomorrow(),
          isFalse);
      await temp.delete(recursive: true);
      temp = await Directory.systemTemp.createTemp('simcity_test');
      expect(
          await SimCity2013Adapter(
                  searchOverride: [await layout(citiesOfTomorrow: true)])
              .hasCitiesOfTomorrow(),
          isTrue);
    });

    test('the game own data folder is never listed as mods', () async {
      final install = await layout();
      final adapter = SimCity2013Adapter(searchOverride: [install]);
      final mods = await adapter.resolveModsDirectory();
      expect(await adapter.extraModsDirectories(mods!), isEmpty,
          reason: 'SimCityData holds Maxis content and cannot be swept');
      await makeFile([
        'games', 'SimCity', 'SimCityUserData', 'Packages', 'mine.package',
      ]);
      expect((await adapter.listMods(mods)).map((m) => m.name),
          ['mine.package']);
    });
  });

  // -------------------------------------------------------------------
  // SimCity Societies
  // -------------------------------------------------------------------

  group('SimCity Societies', () {
    Future<({Directory install, Directory documents})> layout(
        {bool destinations = false}) async {
      final install = await makeDir(['games', 'SimCity Societies']);
      await makeFile(['games', 'SimCity Societies', 'SimCitySocieties.exe']);
      await makeDir(['games', 'SimCity Societies', 'Data', 'XMLDb']);
      if (destinations) {
        await makeFile([
          'games', 'SimCity Societies', //
          'SimCity Societies Destinations', 'SCSDestinations.exe',
        ]);
      }
      return (install: install, documents: await makeDir(['Documents']));
    }

    test('finds the install and its Import folder', () async {
      final l = await layout();
      await makeDir(['Documents', 'SimCity Societies', 'Import']);
      final adapter = SimCitySocietiesAdapter(
          searchOverride: [l.install], documentsOverride: l.documents);
      expect(await adapter.findGameFolder(), isNotNull);
      expect((await adapter.resolveModsDirectory())?.path,
          p.join(l.documents.path, 'SimCity Societies', 'Import'));
    });

    test('proposes the Import folder before it exists', () async {
      final l = await layout();
      final adapter = SimCitySocietiesAdapter(
          searchOverride: [l.install], documentsOverride: l.documents);
      expect(await adapter.resolveModsDirectory(), isNull,
          reason: 'the setup screen offers to create it rather than lying');
      expect(await adapter.defaultModsPath(),
          p.join(l.documents.path, 'SimCity Societies', 'Import'));
    });

    test('Destinations is detected inside the base install', () async {
      final without = await layout();
      expect(
          await SimCitySocietiesAdapter(
                  searchOverride: [without.install],
                  documentsOverride: without.documents)
              .hasDestinations(),
          isFalse);
      await temp.delete(recursive: true);
      temp = await Directory.systemTemp.createTemp('simcity_test');
      final with_ = await layout(destinations: true);
      expect(
          await SimCitySocietiesAdapter(
                  searchOverride: [with_.install],
                  documentsOverride: with_.documents)
              .hasDestinations(),
          isTrue);
    });

    test('the game own Data folder is never a mods folder', () async {
      final l = await layout();
      final adapter = SimCitySocietiesAdapter(
          searchOverride: [l.install], documentsOverride: l.documents);
      final path = await adapter.defaultModsPath();
      expect(p.isWithin(l.install.path, path!), isFalse);
    });
  });

  // -------------------------------------------------------------------
  // Shared expectations of every SimCity adapter
  // -------------------------------------------------------------------

  group('every SimCity adapter', () {
    // Documents is overridden to a folder that is not there, so the
    // machine this suite runs on cannot answer for it - these adapters
    // must be silent about a game that is not installed, and on the
    // reference machine SimCity 4 really is.
    late List<SimCityAdapter> adapters;

    setUp(() {
      final nowhere = Directory(p.join(temp.path, 'no-documents'));
      adapters = <SimCityAdapter>[
        const SimCity3000Adapter(searchOverride: []),
        SimCity4Adapter(
            searchOverride: const [],
            documentsOverride: nowhere,
            sc4pacProfilesOverride: const <Sc4pacProfile>[]),
        SimCitySocietiesAdapter(
            searchOverride: const [], documentsOverride: nowhere),
        const SimCity2013Adapter(searchOverride: []),
      ];
    });

    test('carries the franchise the sidebar groups on', () {
      for (final adapter in adapters) {
        expect(adapter.game.series, 'SimCity', reason: adapter.game.id);
        expect(adapter.game.year, isNotNull, reason: adapter.game.id);
      }
    });

    test('ids are stable, unique and not shared with The Sims', () {
      final ids = adapters.map((a) => a.game.id).toList();
      expect(ids.toSet().length, ids.length);
      expect(ids,
          containsAll(['simcity3000', 'simcity4', 'simcitysocieties', 'simcity2013']));
    });

    test('offers no saves screen - nobody has written a reader yet', () {
      for (final adapter in adapters) {
        expect(adapter.hasSaves, isFalse, reason: adapter.game.id);
      }
    });

    test('says nothing about a machine that has none of them', () async {
      for (final adapter in adapters) {
        expect(await adapter.findGameFolder(), isNull, reason: adapter.game.id);
        expect(await adapter.resolveModsDirectory(), isNull,
            reason: adapter.game.id);
        expect(await adapter.findModsDirectoryCandidates(), isEmpty,
            reason: adapter.game.id);
      }
    });

    test('every mod extension has a category and none is a container', () {
      for (final adapter in adapters) {
        for (final extension in adapter.modFileExtensions) {
          expect(adapter.categoryForExtension(extension), isNotEmpty,
              reason: '${adapter.game.id} $extension');
        }
        expect(
            adapter.modFileExtensions
                .intersection(adapter.containerFileExtensions),
            isEmpty,
            reason: adapter.game.id);
        expect(
            adapter.modFileExtensions
                .intersection(adapter.companionFileExtensions),
            isEmpty,
            reason: '${adapter.game.id}: a companion is not a mod');
      }
    });

    test('a folder the system will not write to is worded, not thrown',
        () async {
      // SimCity 2013 keeps its user data under Program Files, so an
      // unelevated install is refused there on a stock Windows - which
      // is the state most of its players are in. Verified against the
      // real install: the copy fails with PathAccessException carrying
      // the OS's own text ("Acesso negado" on this machine) and the
      // source path in it. What the user is shown must be neither.
      const refused = PathAccessException(
          r'C:\Program Files\EA Games\SimCity\SimCityUserData\Packages.package',
          OSError('Acesso negado', 5),
          'Cannot copy file to');
      final message = installFailureMessage(
        refused,
        r'D:\Downloads\some mod.package',
        destination:
            r'C:\Program Files\EA Games\SimCity\SimCityUserData\Packages',
      );
      expect(message.key, 'errorNoWriteAccess');
      expect(message.args.single,
          r'C:\Program Files\EA Games\SimCity\SimCityUserData\Packages',
          reason: 'a refused copy names the folder, not the file it read');
      for (final arg in message.args) {
        expect(arg, isNot(contains('Downloads')),
            reason: 'the user own source path is not part of the complaint');
        expect(arg.toLowerCase(), isNot(contains('acesso')),
            reason: 'the OS text is replaced, not passed through');
      }
    });

    test('refuses a download holding nothing it can use', () async {
      final mods = await makeDir(['mods']);
      final source = await makeFile(['drop', 'notes.txt'], 'hi');
      for (final adapter in adapters) {
        await expectLater(adapter.installMod(mods, source),
            throwsA(isA<ModContentException>()),
            reason: adapter.game.id);
      }
    });
  });
}
