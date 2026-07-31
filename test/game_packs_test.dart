import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sims_mod_manager/src/core/game_pack.dart';
import 'package:win32_registry/win32_registry.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims1_packs.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims2_packs.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims3_packs.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims4_packs.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims_adapters.dart';
import 'package:sims_mod_manager/src/ui/pack_icons.dart';

/// The shape the game writes: CRLF, a blank line between every entry, and
/// the per-account section whose keys carry an id and a type.
const _realUserSetting = '[uiaccountsettings]\r\n'
    '1000200030000#firstlaunchtime#string = 1774889369\r\n'
    '\r\n'
    '1000200030000#playersessions#uint = 30\r\n'
    '\r\n'
    '[usersetting]\r\n'
    'fallbacks = 0xffffffffff78eb28\r\n'
    '\r\n'
    'tutorialtip_0x000000000004bc45 = 1\r\n'
    '\r\n'
    '[uisimsettings]\r\n'
    'somethingelse = 2\r\n';

void main() {
  group('packstoskipmount is read', () {
    test('as nothing when the line was never written', () {
      expect(parsePacksToSkip(_realUserSetting), isEmpty);
    });

    test('as nothing when the game blanked it', () {
      expect(parsePacksToSkip('[usersetting]\r\npackstoskipmount = \r\n'),
          isEmpty);
    });

    test('as the codes it lists', () {
      expect(parsePacksToSkip('packstoskipmount = EP01,GP02,SP05'),
          {'EP01', 'GP02', 'SP05'});
    });

    test('past whatever spacing and case it was written in', () {
      expect(parsePacksToSkip('  PacksToSkipMount=ep01 , gp02 ,\n'),
          {'EP01', 'GP02'});
    });
  });

  group('packstoskipmount is written', () {
    test('into the section the game reads it from', () {
      final updated = applyPacksToSkip(_realUserSetting, {'GP02'});
      final lines = updated.split('\r\n');
      final section = lines.indexOf('[usersetting]');
      final key = lines.indexWhere((l) => l.startsWith('packstoskipmount'));
      expect(section, isNonNegative);
      expect(key, greaterThan(section));
      // Every later section starts after it, so it belongs to this one.
      expect(lines.indexOf('[uisimsettings]'), greaterThan(key));
      expect(parsePacksToSkip(updated), {'GP02'});
    });

    test('without disturbing anything else in the file', () {
      final updated = applyPacksToSkip(_realUserSetting, {'EP01'});
      for (final line in _realUserSetting.split('\r\n')) {
        if (line.isEmpty) continue;
        expect(updated, contains(line));
      }
      expect(updated, contains('\r\n'));
    });

    test('over the existing line rather than beside it', () {
      final once = applyPacksToSkip(_realUserSetting, {'EP01'});
      final twice = applyPacksToSkip(once, {'SP20', 'EP01'});
      expect('packstoskipmount'.allMatches(twice).length, 1);
      expect(parsePacksToSkip(twice), {'EP01', 'SP20'});
    });

    test('as an empty value once the last pack is switched back on', () {
      final off = applyPacksToSkip(_realUserSetting, {'EP01'});
      final on = applyPacksToSkip(off, const <String>{});
      expect(parsePacksToSkip(on), isEmpty);
      expect(on, contains('packstoskipmount ='));
    });

    test('not at all when there is nothing to say', () {
      expect(applyPacksToSkip(_realUserSetting, const <String>{}),
          _realUserSetting);
    });

    test('with a section of its own when the file has none', () {
      final updated = applyPacksToSkip('', {'EP01'});
      expect(updated, contains('[usersetting]'));
      expect(parsePacksToSkip(updated), {'EP01'});
    });
  });

  group('a pack is named', () {
    test('by the manifest, in every language it ships', () {
      final titles = parseInstallerTitles('''
<DiPManifest version="4.0">
  <gameTitles>
    <gameTitle locale="en_US">The Sims&#8482; 4 Cats &amp; Dogs</gameTitle>
    <gameTitle locale="de_DE">Die Sims&#8482; 4 Hunde &amp; Katzen</gameTitle>
    <gameTitle locale="pt_BR">The Sims&#8482; 4 Gatos e Ces</gameTitle>
  </gameTitles>
</DiPManifest>''');
      expect(titles['en'], 'Cats & Dogs');
      expect(titles['de'], 'Hunde & Katzen');
      expect(titles['pt'], 'Gatos e Ces');
    });

    test('by the app when the manifest only repeats the code', () {
      // Six of the shipped manifests say "The Sims 4 GP06" and nothing more.
      final titles = parseInstallerTitles(
          '<gameTitle locale="en_US">The Sims 4 GP06</gameTitle>',
          code: 'GP06');
      expect(titles, isEmpty);
      expect(sims4PackNames['GP06'], 'Jungle Adventure');
    });

    test('without the game title in front of it, in any language', () {
      expect(stripGameTitle('The Sims™ 4 Get to Work'), 'Get to Work');
      expect(stripGameTitle('Die Sims™ 4 An die Arbeit'), 'An die Arbeit');
      expect(stripGameTitle('Los Sims™ 4 A Trabajar'), 'A Trabajar');
      // The one pack that puts the trademark after the number.
      expect(stripGameTitle('The Sims 4™ Holiday Celebration Pack'),
          'Holiday Celebration Pack');
      // The Chinese titles separate with a fullwidth colon.
      expect(stripGameTitle('The Sims™ 4：來去上班'),
          '來去上班');
    });

    test('as itself when nothing on the machine knows better', () {
      expect(sims4PackNames.containsKey('SP99'), isFalse);
      expect(stripGameTitle('SP99'), 'SP99');
    });
  });

  group('a pack code says what tier it is', () {
    test('from its prefix', () {
      expect(sims4PackKind('EP01'), GamePackKind.expansion);
      expect(sims4PackKind('GP04'), GamePackKind.gamePack);
      expect(sims4PackKind('FP01'), GamePackKind.free);
    });

    test('and, for the shared SP prefix, from its number', () {
      expect(sims4PackKind('SP18'), GamePackKind.stuff);
      expect(sims4PackKind('SP20'), GamePackKind.kit);
      // The two stuff packs EA released after switching to kits.
      expect(sims4PackKind('SP46'), GamePackKind.stuff);
      expect(sims4PackKind('SP49'), GamePackKind.stuff);
    });

    test('reading a pack released after this build as a kit', () {
      expect(sims4PackKind('SP99'), GamePackKind.kit);
    });

    test('and only pack folders are pack folders', () {
      for (final name in ['Game', 'Data', 'Delta', 'Support', '__Installer']) {
        expect(isSims4PackCode(name), isFalse, reason: name);
      }
      expect(isSims4PackCode('EP01'), isTrue);
    });
  });

  group('an install lists its packs', () {
    late Directory root;

    setUp(() => root = Directory.systemTemp.createTempSync('smm_packs'));
    tearDown(() => root.deleteSync(recursive: true));

    Directory pack(String code, {int bytes = 0}) {
      final dir = Directory(p.join(root.path, code))..createSync();
      File(p.join(dir.path, 'ClientFullBuild0.package'))
          .writeAsBytesSync(List.filled(bytes, 0));
      return dir;
    }

    void manifest(String code, String xml) {
      final dir = Directory(
          p.join(root.path, '__Installer', 'DLC', code, '__Installer'))
        ..createSync(recursive: true);
      File(p.join(dir.path, 'installerdata.xml')).writeAsStringSync(xml);
    }

    test('with what they are called, how big, and whether they are on',
        () async {
      pack('EP01', bytes: 2048);
      manifest('EP01',
          '<gameTitle locale="en_US">The Sims 4 Get to Work</gameTitle>');
      final settings = File(p.join(root.path, 'UserSetting.ini'))
        ..writeAsStringSync('[usersetting]\r\npackstoskipmount = EP01\r\n');

      final packs =
          await listSims4Packs(installDir: root, userSettings: settings);

      expect(packs, hasLength(1));
      expect(packs.single.code, 'EP01');
      expect(packs.single.name, 'Get to Work');
      expect(packs.single.kind, GamePackKind.expansion);
      expect(packs.single.isEnabled, isFalse);
      expect(packs.single.sizeBytes, 2048);
      expect(packs.single.path, endsWith('EP01'));
    });

    test('ignoring the folders that are not packs', () async {
      pack('EP01');
      Directory(p.join(root.path, 'Game')).createSync();
      Directory(p.join(root.path, 'Data')).createSync();
      File(p.join(root.path, 'EP99')).writeAsStringSync('a file, not a pack');

      final packs = await listSims4Packs(installDir: root);
      expect([for (final pack in packs) pack.code], ['EP01']);
    });

    test('every pack enabled when the game never wrote a settings file',
        () async {
      pack('EP01');
      pack('SP20');
      final packs = await listSims4Packs(
          installDir: root, userSettings: File(p.join(root.path, 'nope.ini')));
      expect(packs.every((pack) => pack.isEnabled), isTrue);
    });

    test('expansions first, then each tier in release order', () async {
      for (final code in ['SP21', 'GP02', 'EP05', 'SP01', 'EP01', 'FP01']) {
        pack(code);
      }
      final packs = await listSims4Packs(installDir: root);
      expect([for (final pack in packs) pack.code],
          ['EP01', 'EP05', 'GP02', 'SP01', 'SP21', 'FP01']);
    });

    test('naming a pack the manifest never mentioned', () async {
      pack('GP06');
      final packs = await listSims4Packs(installDir: root);
      expect(packs.single.name, 'Jungle Adventure');
    });

    test('and nothing at all when the game is not installed there', () async {
      expect(await listSims4Packs(installDir: Directory(p.join(root.path, 'x'))),
          isEmpty);
    });
  });

  group('a complete Sims 4 collection', () {
    List<GamePack> shelf(Iterable<String> codes) => [
          for (final code in codes)
            GamePack(code: code, name: code, kind: sims4PackKind(code)),
        ];

    /// Every expansion and game pack the shipped table knows, which is the
    /// bar - the stuff packs and kits below them are not part of it.
    final complete = [
      for (final code in sims4PackNames.keys)
        if (sims4PackKind(code) == GamePackKind.expansion ||
            sims4PackKind(code) == GamePackKind.gamePack)
          code,
    ];

    int countOf(GamePackKind kind) =>
        complete.where((code) => sims4PackKind(code) == kind).length;

    test('is remarked on without waiting for the kits nobody owns', () {
      final note = sims4CollectionNote(shelf(complete));
      expect(note?.key, 'packsAllOwnedSims4');
      expect(note?.args, [
        '${countOf(GamePackKind.expansion)}',
        '${countOf(GamePackKind.gamePack)}',
      ]);
    });

    test('is not remarked on while one is still missing', () {
      expect(sims4CollectionNote(shelf(complete.skip(1))), isNull);
      expect(sims4CollectionNote(const []), isNull);
    });

    test('counts what the shelf holds, not what the table knows', () {
      // A pack released after this build: the collection is still
      // complete, and the number says what the player actually has.
      final note = sims4CollectionNote(shelf([...complete, 'EP40']));
      expect(note?.args.first, '${countOf(GamePackKind.expansion) + 1}');
    });

    test('is not undone by a pack being switched off', () {
      final off = [
        for (final pack in shelf(complete)) pack.copyWith(isEnabled: false),
      ];
      expect(sims4CollectionNote(off)?.key, 'packsAllOwnedSims4');
    });
  });

  group('a pack is switched', () {
    late Directory root;
    late File settings;

    setUp(() {
      root = Directory.systemTemp.createTempSync('smm_toggle');
      settings = File(p.join(root.path, 'UserSetting.ini'))
        ..writeAsStringSync(_realUserSetting);
    });
    tearDown(() => root.deleteSync(recursive: true));

    test('off, and back on again, leaving the file as it found it',
        () async {
      await setSims4PackEnabled(settings, 'EP01', enabled: false);
      expect(parsePacksToSkip(settings.readAsStringSync()), {'EP01'});

      await setSims4PackEnabled(settings, 'GP02', enabled: false);
      expect(parsePacksToSkip(settings.readAsStringSync()), {'EP01', 'GP02'});

      await setSims4PackEnabled(settings, 'EP01', enabled: true);
      expect(parsePacksToSkip(settings.readAsStringSync()), {'GP02'});

      await setSims4PackEnabled(settings, 'GP02', enabled: true);
      expect(parsePacksToSkip(settings.readAsStringSync()), isEmpty);
    });

    test('without minding that it was already that way', () async {
      final before = settings.readAsStringSync();
      await setSims4PackEnabled(settings, 'EP01', enabled: true);
      expect(settings.readAsStringSync(), before);
    });

    test('into a settings file the game has not written yet', () async {
      final fresh = File(p.join(root.path, 'sub', 'UserSetting.ini'));
      await setSims4PackEnabled(fresh, 'SP20', enabled: false);
      expect(parsePacksToSkip(fresh.readAsStringSync()), {'SP20'});
    });
  });

  group('a Sims 3 pack is identified', () {
    test('by the executable its registry key names', () {
      expect(sims3CodeFromExePath(r'C:\Games\EP1\Game\Bin\TS3EP01.exe'),
          'EP01');
      expect(sims3CodeFromExePath(r'D:\x\TS3SP07.exe'), 'SP07');
    });

    test('and the base game is not one of them', () {
      // It registers itself the same way, beside the packs.
      expect(sims3CodeFromExePath(r'C:\Games\The Sims 3\Game\Bin\TS3.exe'),
          isNull);
      expect(sims3CodeFromExePath(r'C:\Games\TS3W.exe'), isNull);
      expect(sims3CodeFromExePath(null), isNull);
      expect(sims3CodeFromExePath(''), isNull);
    });

    test('or by its folder, which Steam writes unpadded', () {
      expect(sims3CodeFromFolder('EP1'), 'EP01');
      expect(sims3CodeFromFolder('EP11'), 'EP11');
      expect(sims3CodeFromFolder('SP9'), 'SP09');
      // So a folder and a registry key describe the same pack.
      expect(sims3CodeFromFolder('EP1'),
          sims3CodeFromExePath(r'x\TS3EP01.exe'));
    });

    test('and the folders that are not packs are left alone', () {
      for (final name in ['Game', 'GameData', 'Caches', 'Thumbnails', 'EP0']) {
        expect(sims3CodeFromFolder(name), isNull, reason: name);
      }
    });

    test('with its tier read off the prefix', () {
      expect(sims3PackKind('EP01'), GamePackKind.expansion);
      expect(sims3PackKind('SP09'), GamePackKind.stuff);
    });

    test('and named without the game saying its own name twenty times', () {
      // What the registry's DisplayName actually holds.
      expect(stripSims3GameTitle('The Sims 3 Ambitions'), 'Ambitions');
      expect(stripSims3GameTitle('The Sims™ 3 Late Night'), 'Late Night');
      expect(sims3PackNames['EP01'], 'World Adventures');
      expect(sims3PackNames['SP07'], 'Diesel Stuff');
    });

    test('covering every pack the game ever had', () {
      expect(sims3PackNames.keys.where((c) => c.startsWith('EP')), hasLength(11));
      expect(sims3PackNames.keys.where((c) => c.startsWith('SP')), hasLength(9));
    });
  });

  group('parking a registry key', () {
    // The real thing against the real registry, in the app's own corner of
    // HKEY_CURRENT_USER: the game's keys are in HKEY_LOCAL_MACHINE and
    // need administrator rights, but nothing about moving a key differs
    // between the two beyond who is allowed to.
    const base = r'Software\The Sims Mod Manager\PackKeyTest';
    const from = '$base\\Live';
    const to = '$base\\Parked';

    setUp(() {
      final key = CURRENT_USER.create(from,
          config: const RegistryOpenConfig(
              access: RegistryAccess.readWrite, create: true));
      key.setValue('DisplayName', const RegistryValue.string('The Sims 3 Pets'));
      key.setValue('Install Dir', const RegistryValue.string(r'C:\Games\EP5'));
      key.setValue('ProductID', const RegistryValue.dword(10));
      key.close();
    });

    tearDown(() {
      try {
        CURRENT_USER.removeSubkey(base);
      } catch (_) {}
    });

    test('takes every value with it, and brings them all back', () {
      moveRegistryKey(CURRENT_USER, from, to, origin: r'SOFTWARE\Sims');

      // Gone from where the game would look for it.
      expect(() => CURRENT_USER.open(from), throwsA(anything));
      final parked = CURRENT_USER.open(to);
      expect(parked.getString('DisplayName'), 'The Sims 3 Pets');
      expect(parked.getString('Install Dir'), r'C:\Games\EP5');
      expect(parked.getInt('ProductID'), 10);
      // And it remembers where it belongs.
      expect(parked.getString('SmmOriginRoot'), r'SOFTWARE\Sims');
      parked.close();

      moveRegistryKey(CURRENT_USER, to, from);

      expect(() => CURRENT_USER.open(to), throwsA(anything));
      final back = CURRENT_USER.open(from);
      expect(back.getString('DisplayName'), 'The Sims 3 Pets');
      expect(back.getString('Install Dir'), r'C:\Games\EP5');
      expect(back.getInt('ProductID'), 10);
      // The app's own note does not travel back into the game's key.
      expect(back.getString('SmmOriginRoot'), isNull);
      back.close();
    });
  }, skip: !Platform.isWindows);

  group('the adapter', () {
    test('says The Sims 4 can toggle packs', () {
      expect(const Sims4Adapter().canTogglePacks, isTrue);
      // And does it without needing rights the app usually lacks.
      expect(const Sims4Adapter().packToggleNeedsAdmin, isFalse);
    });

    test('says The Sims 3 can too, but only as an administrator', () {
      const adapter = Sims3Adapter();
      expect(adapter.hasPacks, Platform.isWindows);
      expect(adapter.canTogglePacks, Platform.isWindows);
      expect(adapter.packToggleNeedsAdmin, isTrue);
    });

    test('says The Sims 2 can, once someone has asked for it', () {
      const adapter = Sims2Adapter();
      expect(adapter.hasPacks, Platform.isWindows);
      expect(adapter.canTogglePacks, Platform.isWindows);
      // Its own hive, so no elevation - but nobody has proven it safe.
      expect(adapter.packToggleNeedsAdmin, isFalse);
      expect(adapter.packToggleIsExperimental, isTrue);
    });

    test('and that the game whose packs merged on install cannot', () {
      const adapter = Sims1Adapter();
      // It still lists; there is simply no switch to offer.
      expect(adapter.hasPacks, isTrue);
      expect(adapter.canTogglePacks, isFalse);
      expect(adapter.packToggleIsExperimental, isFalse);
    });

    test('and that The Sims Medieval has no packs screen at all', () {
      // One add-on, sharing the base game's patch level: a screen saying
      // "you have it" is a worse answer than no screen.
      expect(const SimsMedievalAdapter().hasPacks, isFalse);
    });

    test('and only the one game asks for administrator rights', () {
      final asking = [
        for (final adapter in [
          const Sims1Adapter(),
          const Sims2Adapter(),
          const Sims3Adapter(),
          const Sims4Adapter(),
          const SimsMedievalAdapter(),
        ])
          if (adapter.packToggleNeedsAdmin) adapter.game.id,
      ];
      expect(asking, ['sims3']);
    });

    test('finds the packs beside an install it was pointed at', () async {
      final install = Directory.systemTemp.createTempSync('smm_install');
      addTearDown(() => install.deleteSync(recursive: true));
      Directory(p.join(install.path, 'EP01')).createSync();
      Directory(p.join(install.path, 'GP01')).createSync();

      final packs = await Sims4Adapter(
        installOverride: install,
        documentsOverride: install, // no user data: everything reads as on
      ).listPacks();

      expect([for (final pack in packs) pack.code], ['EP01', 'GP01']);
      expect(packs.every((pack) => pack.isEnabled), isTrue);
    });

    test('and reports none when the install folder is gone', () async {
      final gone = Directory(p.join(Directory.systemTemp.path, 'smm_absent'));
      expect(
          await Sims4Adapter(
                  installOverride: gone, scanRootsOverride: const [])
              .listPacks(),
          isEmpty);
    });
  });

  group('The Sims 2 load order', () {
    // The shape the collection writes: release order, not numeric order,
    // with an empty slot where the stuff pack that never shipped
    // digitally would have gone.
    const order = 'Sims2EP1.exe,Sims2EP2.exe,Sims2SP1.exe,,Sims2EP9.exe';

    test('loses only the pack that was switched off', () {
      expect(buildSims2LoadOrder(order, order, {'Sims2SP1.exe'}),
          'Sims2EP1.exe,Sims2EP2.exe,,Sims2EP9.exe');
    });

    test('puts it back where it was, not at the end', () {
      final without = buildSims2LoadOrder(order, order, {'Sims2SP1.exe'});
      expect(buildSims2LoadOrder(order, without, const {}), order);
    });

    test('keeps the empty slot the missing stuff pack left behind', () {
      // It is part of the shape the game wrote; closing it up is not
      // this app's business.
      expect(buildSims2LoadOrder(order, order, const {}), contains(',,'));
    });

    test('does not drop a pack installed while another was switched off',
        () {
      final without = buildSims2LoadOrder(order, order, {'Sims2SP1.exe'});
      final andANewOne = '$without,Sims2SP8.exe';
      final back = buildSims2LoadOrder(order, andANewOne, const {});
      expect(back, contains('Sims2SP1.exe'));
      expect(back, contains('Sims2SP8.exe'));
    });

    test('names a pack from the executable its key is named after', () {
      expect(sims2CodeFromExe('Sims2EP1.exe'), 'EP01');
      expect(sims2CodeFromExe('Sims2SP8.exe'), 'SP08');
      // The base game and the language key are not packs.
      expect(sims2CodeFromExe('Sims2.exe'), isNull);
      expect(sims2CodeFromExe('1.0'), isNull);
    });

    test('and Mansion & Garden is the ninth expansion, not a stuff pack', () {
      // It is the pack whose executable the collection runs.
      expect(sims2PackKind('EP09'), GamePackKind.expansion);
      expect(sims2PackNames['EP09'], 'Mansion & Garden Stuff');
      expect(sims2RunnerExe, 'Sims2EP9.exe');
      // The stuff pack that never shipped digitally has no entry.
      expect(sims2PackNames.containsKey('SP03'), isFalse);
    });
  });

  group('switching a Sims 2 pack', () {
    // Against a key of the app's own with the collection's shape, so the
    // real code path runs without going near anybody's game.
    const root = r'Software\The Sims Mod Manager\Sims2PackTest';
    const order = 'Sims2EP1.exe,Sims2SP1.exe,,Sims2EP9.exe';

    setUp(() {
      final key = CURRENT_USER.create(root,
          config: const RegistryOpenConfig(
              access: RegistryAccess.readWrite, create: true));
      key.setValue('EPsInstalled', const RegistryValue.string(order));
      key.close();
      for (final exe in ['Sims2EP1.exe', 'Sims2SP1.exe', 'Sims2EP9.exe']) {
        final sub = CURRENT_USER.create('$root\\$exe',
            config: const RegistryOpenConfig(
                access: RegistryAccess.readWrite, create: true));
        sub.setValue('Installed', const RegistryValue.dword(1));
        sub.setValue('Path', RegistryValue.string('C:\\Games\\$exe'));
        sub.close();
      }
    });

    tearDown(() {
      try {
        CURRENT_USER.removeSubkey(root);
      } catch (_) {}
    });

    String currentOrder() {
      final key = CURRENT_USER.open(root);
      try {
        return key.getString('EPsInstalled') ?? '';
      } finally {
        key.close();
      }
    }

    test('takes it out of the load order and puts it back where it was', () {
      expect(
          readSims2PackKeys(registryRoot: root)
              .every((k) => k.isListed),
          isTrue);

      setSims2PackEnabled('SP01', enabled: false, registryRoot: root);
      expect(currentOrder(), 'Sims2EP1.exe,,Sims2EP9.exe');
      final off = readSims2PackKeys(registryRoot: root);
      expect(off.firstWhere((k) => k.code == 'SP01').isListed, isFalse);
      // The pack's own key is untouched: its files never moved.
      expect(off.firstWhere((k) => k.code == 'SP01').path, isNotNull);

      setSims2PackEnabled('SP01', enabled: true, registryRoot: root);
      expect(currentOrder(), order);
    });

    test('refuses the pack the collection actually runs from', () {
      expect(
          () => setSims2PackEnabled('EP09',
              enabled: false, registryRoot: root),
          throwsA(isA<PackActionException>()));
      expect(currentOrder(), order);
    });

    test('and forgets its note once everything is back on', () {
      setSims2PackEnabled('SP01', enabled: false, registryRoot: root);
      final key = CURRENT_USER.open(root);
      expect(key.getString(sims2BackupValue), order);
      key.close();

      setSims2PackEnabled('SP01', enabled: true, registryRoot: root);
      final after = CURRENT_USER.open(root);
      expect(after.getString(sims2BackupValue), isNull);
      after.close();
    });
  }, skip: !Platform.isWindows);

  group('The Sims 1 expansions', () {
    test('are read off the flag files the game keeps for them', () {
      expect(sims1PackNumberFromFile('Ranger.iff'), 1);
      expect(sims1PackNumberFromFile('Ranger7.iff'), 7);
      expect(sims1PackNames[1], 'Livin’ Large');
      expect(sims1PackNames[7], 'Makin’ Magic');
    });

    test('and the edition markers beside them are not expansions', () {
      // Ranger8 marks the Complete Collection, RangerD the Deluxe one.
      expect(sims1PackNumberFromFile('Ranger8.iff'), isNull);
      expect(sims1PackNumberFromFile('RangerD.iff'), isNull);
      expect(sims1PackNumberFromFile('Behavior.iff'), isNull);
    });

    test('never offering a switch, because they merged on install', () {
      const adapter = Sims1Adapter();
      expect(adapter.hasPacks, isTrue);
      expect(adapter.canTogglePacks, isFalse);
    });
  });

  group('the pack artwork the app ships', () {
    test('is exactly what the manifest claims', () {
      for (final entry in packIconFiles.entries) {
        final dir = Directory('assets/packs/${entry.key}');
        expect(dir.existsSync(), isTrue, reason: entry.key);
        final onDisk = dir
            .listSync()
            .whereType<File>()
            .map((f) => p.basename(f.path))
            .toSet();
        // Both ways: a claim with no file draws nothing, and a file no
        // claim mentions is weight in the bundle nobody asked for.
        expect(entry.value.values.toSet(), onDisk, reason: entry.key);
      }
    });

    test('names packs the games actually have', () {
      for (final code in packIconFiles['sims4']?.keys ?? const <String>[]) {
        expect(sims4PackNames.containsKey(code), isTrue, reason: code);
      }
      for (final code in packIconFiles['sims2']?.keys ?? const <String>[]) {
        expect(sims2PackNames.containsKey(code), isTrue, reason: code);
      }
      for (final code in packIconFiles['sims1']?.keys ?? const <String>[]) {
        final number = int.parse(code.substring(2));
        expect(sims1PackNames.containsKey(number), isTrue, reason: code);
      }
    });

    test('leaves The Sims 3 out, which has its own on disk', () {
      // Shipping artwork for it would override the icon sitting next to
      // the player's own copy of the pack.
      expect(packIconFiles.containsKey('sims3'), isFalse);
    });

    test('and every file is the image its name says it is', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      // What each format announces itself with, so a wiki that answered
      // with an error page - or a truncated write - is caught here
      // rather than as a blank tile on somebody's screen.
      const signatures = <String, List<int>>{
        '.png': [0x89, 0x50, 0x4E, 0x47],
        '.jpg': [0xFF, 0xD8, 0xFF],
        '.webp': [0x52, 0x49, 0x46, 0x46],
      };
      var checked = 0;
      for (final entry in packIconFiles.entries) {
        for (final code in entry.value.keys) {
          final asset = packIconAsset(entry.key, code)!;
          final extension = p.extension(asset);
          final expected = signatures[extension];
          expect(expected, isNotNull, reason: asset);
          final bytes = await rootBundle.load(asset);
          final head = bytes.buffer.asUint8List(0, 12);
          expect(head.sublist(0, expected!.length), expected, reason: asset);
          expect(bytes.lengthInBytes, greaterThan(200), reason: asset);
          checked++;
        }
      }
      expect(checked, greaterThan(90));
    });
  });
}
