import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sims_mod_manager/src/core/dbpf.dart';
import 'package:sims_mod_manager/src/core/protobuf_wire.dart';
import 'package:sims_mod_manager/src/core/save_edit.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims2_saves.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims4_saves.dart';

import 'dbpf_fixtures.dart';
import 'save_games_test.dart' show Pb;

/// Editing a household inside a save, per game.
///
/// The stakes here are different from the rest of the suite: these are
/// the only writes the app makes into a file the user cannot download
/// again, so what is pinned is not only "the change landed" but "nothing
/// else did". Every game's group ends by reading the whole save back and
/// holding it against what it said before.
void main() {
  late Directory tempDir;

  setUp(() => tempDir = Directory.systemTemp.createTempSync('save_edit'));
  tearDown(() => tempDir.deleteSync(recursive: true));

  group('protobuf splicing', () {
    test('replaces a varint and leaves every other field alone', () {
      final message = (Pb()
            ..varintField(1, 7)
            ..stringField(3, 'Goth')
            ..varintField(5, 45500)
            ..stringField(21, 'MadameCreator'))
          .bytes();
      final edited = setVarintField(message, 5, 9999999);
      final fields = readProtoFields(edited);
      expect(fields.firstInt(5), 9999999);
      expect(fields.firstInt(1), 7);
      expect(fields.firstString(3), 'Goth');
      expect(fields.firstString(21), 'MadameCreator');
    });

    test('appends a field the message never carried', () {
      final message = (Pb()..stringField(3, 'Goth')).bytes();
      expect(readProtoFields(setVarintField(message, 5, 12)).firstInt(5), 12);
      expect(
          readProtoFields(setBytesField(message, 9, utf8.encode('hi')))
              .firstString(9),
          'hi');
    });

    test('carries through a field type the walker does not understand', () {
      // A group-encoded field (wire types 3 and 4), which the reader
      // skips: a writer that re-encoded what it parsed would drop it.
      final b = BytesBuilder()
        ..add((Pb()..varintField(5, 1)).bytes())
        ..addByte((6 << 3) | 3) // start group 6
        ..add((Pb()..varintField(1, 42)).bytes())
        ..addByte((6 << 3) | 4) // end group 6
        ..add((Pb()..stringField(3, 'Goth')).bytes());
      final message = b.toBytes();
      final edited = setVarintField(message, 5, 500);
      expect(readProtoFields(edited).firstInt(5), 500);
      expect(readProtoFields(edited).firstString(3), 'Goth');
      // The group's bytes are still in there, byte for byte.
      expect(edited.length, message.length + 1);
      expect(
          edited.sublist(edited.length - 8), message.sublist(message.length - 8));
    });

    test('encodes a varint the way protobuf does', () {
      expect(encodeVarint(0), [0]);
      expect(encodeVarint(127), [127]);
      expect(encodeVarint(128), [0x80, 0x01]);
      expect(encodeVarint(9999999), [0xFF, 0xAC, 0xE2, 0x04]);
      // A negative number is the ten-byte form, not a hang.
      expect(encodeVarint(-1), hasLength(10));
    });
  });

  group('The Sims 4', () {
    const gothId = 0x2001;
    const townieId = 0x2002;

    Uint8List worldBlob({int gothFunds = 45500}) => (Pb()
          ..messageField(2, Pb()..stringField(9, 'Legacy run'))
          ..messageField(3, Pb()..stringField(10, '1.125.59.1030'))
          ..messageField(4, Pb()..stringField(3, 'Willow Creek'))
          ..messageField(
              5,
              Pb()
                ..varintField(2, gothId)
                ..stringField(3, 'Goth')
                ..varintField(5, gothFunds)
                ..stringField(21, 'MadameCreator')
                ..varintField(31, 1))
          ..messageField(
              5,
              Pb()
                ..varintField(2, townieId)
                ..stringField(3, 'Landgraab')
                ..varintField(5, 100))
          ..messageField(
              6,
              Pb()
                ..varintField(1, 0x4001)
                ..varintField(4, gothId)
                ..stringField(5, 'Bella')
                ..stringField(6, 'Goth')
                ..varintField(7, 8192)
                ..varintField(8, 32)))
        .bytes();

    File writeSlot({int gothFunds = 45500}) {
      final saves = Directory(p.join(tempDir.path, 'saves'))
        ..createSync(recursive: true);
      final bytes = buildV2Package([
        Res(0x0000000D, refpackLiterals(worldBlob(gothFunds: gothFunds)),
            compression: 0xFFFF),
        Res(0x00000014, fakeJpeg(300, 200), instance: 0),
        Res(0x0000000F, fakeJpeg(256, 256), instance: 0x3001),
      ]);
      return File(p.join(saves.path, 'Slot_00000001.save'))
        ..writeAsBytesSync(bytes);
    }

    test('changes the name and the funds, and keeps the rest of the save', () {
      final file = writeSlot();
      final before = scanSims4Saves(file.parent.path).single;

      file.writeAsBytesSync(editSims4Save(file, gothId,
          const HouseholdEdit(name: 'Goth Trust', funds: 9999999)));

      final after = scanSims4Saves(file.parent.path).single;
      final goth = after.households.firstWhere((h) => h.id == gothId);
      expect(goth.name, 'Goth Trust');
      expect(goth.funds, 9999999);
      // The household's other fields, its sim, and the neighbours.
      expect(goth.creatorName, 'MadameCreator');
      expect(goth.isPlayed, isTrue);
      expect(goth.members.single.fullName, 'Bella Goth');
      final townie = after.households.firstWhere((h) => h.id == townieId);
      expect(townie.name, 'Landgraab');
      expect(townie.funds, 100);
      // And the save around them.
      expect(after.name, before.name);
      expect(after.gameVersion, before.gameVersion);
      expect(after.worldsVisited, before.worldsVisited);
      expect(after.thumbnail, before.thumbnail);
      expect(after.photos, hasLength(before.photos.length));
    });

    test('a name alone leaves the funds where they were', () {
      final file = writeSlot();
      file.writeAsBytesSync(
          editSims4Save(file, gothId, const HouseholdEdit(name: 'Goths')));
      final goth = scanSims4Saves(file.parent.path)
          .single
          .households
          .firstWhere((h) => h.id == gothId);
      expect(goth.name, 'Goths');
      expect(goth.funds, 45500);
    });

    test('edits again on a save it already rewrote', () {
      final file = writeSlot();
      file.writeAsBytesSync(
          editSims4Save(file, gothId, const HouseholdEdit(funds: 1)));
      file.writeAsBytesSync(
          editSims4Save(file, gothId, const HouseholdEdit(funds: 222)));
      final goth = scanSims4Saves(file.parent.path)
          .single
          .households
          .firstWhere((h) => h.id == gothId);
      expect(goth.funds, 222);
    });

    test('keeps a name written outside ASCII', () {
      final file = writeSlot();
      file.writeAsBytesSync(editSims4Save(
          file, gothId, const HouseholdEdit(name: 'Família Contrário')));
      final goth = scanSims4Saves(file.parent.path)
          .single
          .households
          .firstWhere((h) => h.id == gothId);
      expect(goth.name, 'Família Contrário');
    });

    test('refuses a household the save does not have', () {
      final file = writeSlot();
      expect(
          () => editSims4Save(file, 0xDEAD, const HouseholdEdit(funds: 1)),
          throwsA(isA<SaveEditException>()));
    });

    test('refuses a file that is not a save', () {
      final file = File(p.join(tempDir.path, 'Slot_00000009.save'))
        ..writeAsBytesSync(Uint8List.fromList(List.filled(200, 7)));
      expect(() => editSims4Save(file, 1, const HouseholdEdit(funds: 1)),
          throwsA(isA<SaveEditException>()));
    });
  });

  group('The Sims 2', () {
    Uint8List strResource(List<String> values, {int language = 1}) {
      final b = BytesBuilder()..add(Uint8List(0x40));
      u16(b, 0xFFFD);
      u16(b, values.length);
      for (final value in values) {
        b
          ..addByte(language)
          ..add(utf8.encode(value))
          ..addByte(0)
          ..addByte(0);
      }
      return b.toBytes();
    }

    /// The shipped hoods keep the family's name and their lot's blurb in
    /// one table, one pair per language.
    Uint8List multilingualStr(Map<int, (String, String)> byLanguage) {
      final b = BytesBuilder()..add(Uint8List(0x40));
      u16(b, 0xFFFD);
      u16(b, byLanguage.length * 2);
      for (final entry in byLanguage.entries) {
        b
          ..addByte(entry.key)
          ..add(utf8.encode(entry.value.$1))
          ..addByte(0)
          ..addByte(0) // no description on the name row
          ..addByte(entry.key)
          ..add(utf8.encode(entry.value.$2))
          ..addByte(0)
          ..addByte(0);
      }
      return b.toBytes();
    }

    Uint8List fami({required int lot, required int money, int version = 0x4E}) {
      final b = BytesBuilder();
      u32(b, 0x46414D49);
      u32(b, version);
      u32(b, 0);
      u32(b, lot);
      if (version >= 0x51) u32(b, lot);
      if (version >= 0x55) u32(b, 0);
      u32(b, 0);
      u32(b, money);
      u32(b, 1);
      u32(b, 0);
      u32(b, 0);
      u32(b, 0);
      return b.toBytes();
    }

    Uint8List sdsc({required int instance, required int family}) {
      final b = BytesBuilder();
      u32(b, 0);
      u32(b, 0x20);
      u32(b, 0);
      final data = List<int>.filled(170, 0);
      data[58] = 5; // an adult
      data[61] = family;
      for (final value in data) {
        u16(b, value);
      }
      u16(b, instance);
      u32(b, 0x1234);
      u32(b, 0);
      return b.toBytes();
    }

    /// The DIR resource: one record per compressed resource, naming what
    /// it decompresses to.
    Uint8List dir(List<(int, int, int, int)> records) {
      final b = BytesBuilder();
      for (final (type, group, instance, size) in records) {
        u32(b, type);
        u32(b, group);
        u32(b, instance);
        u32(b, size);
      }
      return b.toBytes();
    }

    /// A neighborhood whose name table is RefPack'd and listed in the
    /// DIR, which is how the game itself writes one.
    File writeHood({int version = 0x4E, Uint8List? nameTable}) {
      final folder = Directory(p.join(tempDir.path, 'Neighborhoods', 'N001'))
        ..createSync(recursive: true);
      final names = nameTable ?? strResource(['Pleasant']);
      final bytes = buildV1Package([
        Res(0x46414D49, fami(lot: 9, money: 1234, version: version),
            instance: 1),
        Res(0x53545223, refpackLiterals(names, sizePrefix: true),
            instance: 1),
        Res(0x46414D49, fami(lot: 4, money: 20000, version: version),
            instance: 2),
        Res(0x53545223, strResource(['Broke']), instance: 2),
        Res(0xAACE2EFB, sdsc(instance: 0x101, family: 1), instance: 0x101),
        Res(0xAACE2EFB, sdsc(instance: 0x102, family: 2), instance: 0x102),
        Res(0x43545353, strResource(['Vistalegre', 'A quiet hood.']),
            instance: 1),
        Res(
            0xE86B1EEF,
            dir([(0x53545223, 0, 1, names.length)]),
            instance: 0x286B1F03),
      ]);
      File(p.join(folder.path, 'N001_Neighborhood.package'))
          .writeAsBytesSync(bytes);
      return File(p.join(folder.path, 'N001_Neighborhood.package'));
    }

    test('changes the name and the funds, and keeps the rest of the hood', () {
      final package = writeHood();
      final hoods = Directory(p.join(tempDir.path, 'Neighborhoods'));
      final before = scanSims2Saves(hoods.path).single;

      package.writeAsBytesSync(editSims2Hood(package, 1,
          const HouseholdEdit(name: 'Pleasant Trust', funds: 99999999)));

      final after = scanSims2Saves(hoods.path).single;
      final family = after.households.firstWhere((h) => h.id == 1);
      expect(family.name, 'Pleasant Trust');
      expect(family.funds, 99999999);
      expect(family.members, hasLength(1));
      // The hood, the other family, and the sims.
      expect(after.name, before.name);
      expect(after.description, before.description);
      expect(after.households, hasLength(before.households.length));
      final broke = after.households.firstWhere((h) => h.id == 2);
      expect(broke.name, 'Broke');
      expect(broke.funds, 20000);
      expect(after.simCount, before.simCount);
    });

    test('funds land at the right offset on every FAMI version', () {
      for (final version in [0x4E, 0x51, 0x55]) {
        final package = writeHood(version: version);
        package.writeAsBytesSync(
            editSims2Hood(package, 1, const HouseholdEdit(funds: 4242)));
        final family = scanSims2Saves(p.join(tempDir.path, 'Neighborhoods'))
            .single
            .households
            .firstWhere((h) => h.id == 1);
        expect(family.funds, 4242, reason: 'FAMI version 0x${version.toRadixString(16)}');
        // The lot the family lives on is read from the same record and
        // must not have moved.
        expect(family.isPlayed, isTrue);
        Directory(p.join(tempDir.path, 'Neighborhoods')).deleteSync(recursive: true);
      }
    });

    test('renames the family in every language the table carries', () {
      final package = writeHood(
          nameTable: multilingualStr({
        1: ('Goth', 'A gloomy mansion.'),
        4: ('Grusel', 'Eine düstere Villa.'),
        14: ('Goth', 'Uma mansão sombria.'),
      }));
      package.writeAsBytesSync(
          editSims2Hood(package, 1, const HouseholdEdit(name: 'Gothier')));

      // Read the table straight out of the package: the scanner only
      // ever shows the first language.
      final raf = package.openSync();
      final entries = readDbpfIndex(raf)!;
      final table = readDbpfResource(
          raf,
          entries.firstWhere(
              (e) => e.type == 0x53545223 && (e.instance & 0xFFFFFFFF) == 1))!;
      raf.closeSync();
      final text = utf8.decode(table.sublist(0x44), allowMalformed: true);
      expect('Gothier '.allMatches(text), hasLength(3));
      expect(text, isNot(contains('Grusel')));
      // Every blurb survives.
      expect(text, contains('A gloomy mansion.'));
      expect(text, contains('Eine düstere Villa.'));
      expect(text, contains('Uma mansão sombria.'));
    });

    test('strikes the edited resource from the DIR', () {
      final package = writeHood();
      package.writeAsBytesSync(
          editSims2Hood(package, 1, const HouseholdEdit(name: 'Longer name')));
      final raf = package.openSync();
      final int dirBytes;
      try {
        final entries = readDbpfIndex(raf)!;
        dirBytes =
            entries.firstWhere((e) => e.type == 0xE86B1EEF).fileSize;
      } finally {
        raf.closeSync();
      }
      // The one record it held named the name table, which is now stored
      // plainly and has no business claiming otherwise.
      expect(dirBytes, 0);
    });

    test('refuses a family the hood does not have', () {
      final package = writeHood();
      expect(() => editSims2Hood(package, 0xBEEF, const HouseholdEdit(funds: 1)),
          throwsA(isA<SaveEditException>()));
    });
  });

  group('backups', () {
    test('keeps the file that was there, outside the game folder', () async {
      final gameFolder = Directory(p.join(tempDir.path, 'Neighborhoods', 'N001'))
        ..createSync(recursive: true);
      final target = File(p.join(gameFolder.path, 'N001_Neighborhood.package'))
        ..writeAsBytesSync(Uint8List.fromList([1, 2, 3]));

      final backup = await replaceSaveFile(
          target, Uint8List.fromList([4, 5, 6]),
          gameId: 'save-edit-test');
      addTearDown(() {
        final folder = saveBackupFolder('save-edit-test');
        if (folder != null && folder.existsSync()) {
          folder.deleteSync(recursive: true);
        }
      });

      expect(target.readAsBytesSync(), [4, 5, 6]);
      expect(backup, isNotNull);
      expect(backup!.readAsBytesSync(), [1, 2, 3]);
      // Not next to the save: the game reads its own folder and a spare
      // package in there is a second neighborhood.
      expect(gameFolder.listSync(), hasLength(1));
      // And no part file left behind.
      expect(File('${target.path}.smmpart').existsSync(), isFalse);
    });
  });
}
