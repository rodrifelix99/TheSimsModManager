import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sims_mod_manager/src/games/the_sims/sims1_saves.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims2_saves.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims3_saves.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims4_saves.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims_adapters.dart';

import 'bitmap_test.dart' show buildBmp;
import 'dbpf_fixtures.dart';

/// Minimal protobuf writer, enough to serialize the Sims 4 save fixture
/// the way the game's own FileSerialization does.
class Pb {
  final BytesBuilder _b = BytesBuilder();

  void _varint(int value) {
    var v = value;
    while (v >= 0x80) {
      _b.addByte((v & 0x7F) | 0x80);
      v >>>= 7;
    }
    _b.addByte(v);
  }

  Pb varintField(int number, int value) {
    _varint((number << 3) | 0);
    _varint(value);
    return this;
  }

  Pb bytesField(int number, List<int> bytes) {
    _varint((number << 3) | 2);
    _varint(bytes.length);
    _b.add(bytes);
    return this;
  }

  Pb stringField(int number, String value) =>
      bytesField(number, utf8.encode(value));

  Pb messageField(int number, Pb message) =>
      bytesField(number, message.bytes());

  Uint8List bytes() => _b.toBytes();
}

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('save_scan');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('The Sims 4', () {
    Uint8List worldBlob() {
      const gothId = 0x2001;
      const townieId = 0x2002;
      const homeZone = 0x3001;
      const bellaId = 0x4001;
      final world = Pb()
        ..messageField(
            2,
            Pb()
              ..stringField(9, 'Legacy run')
              ..varintField(11, gothId))
        ..messageField(3, Pb()..stringField(10, '1.125.59.1030'))
        ..messageField(4, Pb()..stringField(3, 'Willow Creek'))
        ..messageField(4, Pb()..stringField(3, 'Oasis Springs'))
        ..messageField(
            5,
            Pb()
              ..varintField(2, gothId)
              ..stringField(3, 'Goth')
              ..varintField(4, homeZone)
              ..varintField(5, 45500)
              ..stringField(21, 'MadameCreator')
              ..varintField(31, 1))
        ..messageField(
            5,
            Pb()
              ..varintField(2, townieId)
              ..stringField(3, 'Landgraab')
              ..varintField(5, 100)
              ..varintField(31, 0))
        ..messageField(
            6,
            Pb()
              ..varintField(1, bellaId)
              ..varintField(4, gothId)
              ..stringField(5, 'Bella')
              ..stringField(6, 'Goth')
              ..varintField(7, 8192)
              ..varintField(8, 32))
        ..messageField(
            6,
            Pb()
              ..varintField(1, 0x4002)
              ..varintField(4, gothId)
              ..stringField(5, 'Alexander')
              ..stringField(6, 'Goth')
              ..varintField(7, 4096)
              ..varintField(8, 4))
        ..messageField(
            7,
            Pb()
              ..varintField(1, homeZone)
              ..stringField(2, 'Ophelia Villa')
              ..varintField(6, gothId)
              ..varintField(16, 3)
              ..varintField(17, 2));
      return world.bytes();
    }

    File writeSlot(Directory savesDir, String name) {
      final blob = worldBlob();
      final save = buildV2Package([
        Res(0x0000000D, refpackLiterals(blob), compression: 0xFFFF),
        Res(0x00000014, fakeJpeg(300, 200), instance: 0),
        Res(0x0000000F, fakeJpeg(256, 256), instance: 0x3001),
        Res(0x00000015, fakeJpeg(128, 128), instance: 0x4001),
      ]);
      return File(p.join(savesDir.path, name))..writeAsBytesSync(save);
    }

    test('reads the slot: names, funds, lots, sims and images', () {
      final savesDir = Directory(p.join(tempDir.path, 'saves'))..createSync();
      writeSlot(savesDir, 'Slot_00000001.save');
      // Rolling backups of the same slot, counted but not listed.
      writeSlot(savesDir, 'Slot_00000001.save.ver0');
      writeSlot(savesDir, 'Slot_00000001.save.day.ver0');

      final saves = scanSims4Saves(savesDir.path);
      expect(saves, hasLength(1));
      final save = saves.single;
      expect(save.name, 'Legacy run');
      expect(save.gameVersion, '1.125.59.1030');
      expect(save.backupCount, 2);
      expect(save.worldsVisited, ['Willow Creek', 'Oasis Springs']);
      expect(save.simCount, 2);
      expect(save.thumbnail, fakeJpeg(300, 200));

      // Played household first, townies after.
      expect(save.households, hasLength(2));
      final goth = save.households.first;
      expect(goth.name, 'Goth');
      expect(goth.isPlayed, isTrue);
      expect(goth.funds, 45500);
      expect(goth.lotName, 'Ophelia Villa');
      expect(goth.bedrooms, 3);
      expect(goth.bathrooms, 2);
      expect(goth.creatorName, 'MadameCreator');
      expect(goth.portrait, fakeJpeg(256, 256)); // the home lot's render
      expect(save.households[1].isPlayed, isFalse);

      final bella = goth.members.singleWhere((sim) => sim.firstName == 'Bella');
      expect(bella.fullName, 'Bella Goth');
      expect(bella.ageKey, 'adult');
      expect(bella.genderKey, 'female');
      expect(bella.portrait, fakeJpeg(128, 128));
      final alexander =
          goth.members.singleWhere((sim) => sim.firstName == 'Alexander');
      expect(alexander.ageKey, 'child');
      expect(alexander.genderKey, 'male');

      // The album carries the lot render and the sim portrait.
      expect(save.photos.map((photo) => photo.kindKey),
          containsAll(['lot', 'sim']));
    });

    test('an unreadable slot still appears, named by its file', () {
      final savesDir = Directory(p.join(tempDir.path, 'saves'))..createSync();
      File(p.join(savesDir.path, 'Slot_000000AB.save'))
          .writeAsStringSync('not a dbpf');

      final saves = scanSims4Saves(savesDir.path);
      expect(saves, hasLength(1));
      expect(saves.single.name, 'Slot_000000AB');
      expect(saves.single.households, isEmpty);
    });

    test('the adapter finds the saves through the Documents layout', () async {
      final docs = Directory(p.join(tempDir.path, 'Documents'))..createSync();
      final savesDir = Directory(
          p.joinAll([docs.path, 'Electronic Arts', 'The Sims 4', 'saves']))
        ..createSync(recursive: true);
      writeSlot(savesDir, 'Slot_00000002.save');

      final adapter = Sims4Adapter(documentsOverride: docs);
      final saves = await adapter.listSaveGames();
      expect(saves, hasLength(1));
      expect(saves.single.name, 'Legacy run');
    });
  });

  group('The Sims 3 and The Sims Medieval', () {
    void writeSave(Directory savesDir, String folderName) {
      final folder = Directory(p.join(savesDir.path, folderName))
        ..createSync(recursive: true);

      // Meta.data: magic, three UTF-16LE strings, the picture instance.
      final info = BytesBuilder();
      u32(info, 3);
      for (final value in ['Sunset Valley', 'Goth', 'Our legacy save']) {
        u32(info, value.length);
        for (final unit in value.codeUnits) {
          u16(info, unit);
        }
      }
      u32(info, 0x80); // image instance, low half
      u32(info, 0);
      u32(info, 0); // the id that follows it
      u32(info, 0);
      // The tail: the store, the installed content, and the build - the
      // digits-only one is the game version.
      for (final value in [
        '0.Steam-0.0.32',
        '1.ep1-0.rl.25',
        '21.0.175.024017'
      ]) {
        u32(info, value.length);
        for (final unit in value.codeUnits) {
          u16(info, unit);
        }
      }
      u32(info, 0); // terminator
      File(p.join(folder.path, 'Meta.data')).writeAsBytesSync(
          buildV2Package([Res(0x628A788F, info.toBytes(), instance: 1)]));

      // Which world is home: a UTF-8 stem plus two trailing bytes.
      File(p.join(folder.path, '1a5tf1l3.dat'))
          .writeAsBytesSync([...utf8.encode('Sunset Valley_0x01'), 0, 0]);

      File(p.join(folder.path, 'Sunset Valley_0x01.nhd')).writeAsBytesSync(
        buildV2Package([
          Res(0x6B6D837E, fakePng(200, 150), instance: 0x80),
          Res(0x6B6D837E, fakePng(180, 140), instance: 0x99),
          Res(0x0580A2CE, fakePng(128, 128), instance: 0x11),
          Res(0xD84E7FC6, fakePng(96, 96), instance: 0x12),
        ]),
      );
      // A vacation world the save has visited: its pictures join the
      // album too, captioned by the world they came from.
      File(p.join(folder.path, 'France_0x02.nhd')).writeAsBytesSync(
          buildV2Package([Res(0x0580A2CE, fakePng(64, 64), instance: 0x21)]));
    }

    test('reads metadata, the load-screen picture and the album', () {
      final savesDir = Directory(p.join(tempDir.path, 'Saves'))..createSync();
      writeSave(savesDir, 'My Town.sims3');
      Directory(p.join(savesDir.path, 'My Town.sims3.backup'))
          .createSync(); // previous version
      Directory(p.join(savesDir.path, 'Broken.sims3.bad'))
          .createSync(); // failed save: never shown

      final saves = scanSims3Saves(savesDir.path, extension: '.sims3');
      expect(saves, hasLength(1));
      final save = saves.single;
      expect(save.name, 'My Town');
      expect(save.worldName, 'Sunset Valley');
      expect(save.description, 'Our legacy save');
      expect(save.backupCount, 1);
      // The exact portrait the metadata names, not the first one found.
      expect(save.thumbnail, fakePng(200, 150));
      expect(save.households.single.name, 'Goth');
      expect(save.worldsVisited, containsAll(['Sunset Valley', 'France']));
      expect(save.photos.map((photo) => photo.kindKey),
          containsAll(['familyPortrait', 'sim', 'lot']));
      // The build the save was written by, picked out of the tail's
      // store/content strings.
      expect(save.gameVersion, '21.0.175.024017');
      // Pictures come from every world, each captioned by its own.
      expect(save.photos.map((photo) => photo.caption),
          containsAll(['Sunset Valley', 'France']));
    });

    test('a Medieval-shaped save parses the same way', () {
      final savesDir = Directory(p.join(tempDir.path, 'Saves'))..createSync();
      writeSave(savesDir, 'Kingdom1.tsm');

      final saves = scanSims3Saves(savesDir.path, extension: '.tsm');
      expect(saves, hasLength(1));
      expect(saves.single.households.single.name, 'Goth');
    });
  });

  group('The Sims 2', () {
    /// A Sims 2 string resource (STR#/CTSS): 64-byte name, format word,
    /// count, then per item a language byte and two NUL-terminated
    /// strings.
    Uint8List strResource(List<String> values,
        {int language = 1, List<int> Function(String)? encode}) {
      final encoder = encode ?? latin1.encode;
      final b = BytesBuilder();
      b.add(Uint8List(0x40));
      u16(b, 0xFFFD);
      u16(b, values.length);
      for (final value in values) {
        b.addByte(language);
        b.add(encoder(value));
        b.addByte(0);
        b.addByte(0); // empty description
      }
      return b.toBytes();
    }

    /// An SDSC record: 12-byte header, the base game's 170 stat words,
    /// then the sim's instance and character GUID.
    /// [version] picks how long the stat array is, the way the game's
    /// expansions grew it: 0x20 is the base game's 170 words, 0x36 the
    /// 231 that Apartment Life wrote (which is where the university and
    /// hobby fields live).
    Uint8List sdsc({
      required int instance,
      required int guid,
      required int family,
      required int age,
      required int gender,
      int version = 0x20,
      Map<int, int> stats = const {},
    }) {
      const wordsByVersion = {0x20: 170, 0x36: 231};
      final b = BytesBuilder();
      u32(b, 0);
      u32(b, version);
      u32(b, 0);
      final data = List<int>.filled(wordsByVersion[version]!, 0);
      data[58] = age;
      data[61] = family;
      data[65] = gender;
      for (final entry in stats.entries) {
        data[entry.key] = entry.value;
      }
      for (final value in data) {
        u16(b, value);
      }
      u16(b, instance);
      u32(b, guid);
      u32(b, 0);
      return b.toBytes();
    }

    /// [unknownWord] is the word between the lots and the funds - the one
    /// that reads like a name-string instance and isn't. Real saves put
    /// anything there, so the tests point it somewhere wrong on purpose.
    Uint8List fami({
      required int lot,
      required int money,
      int unknownWord = 0,
      int version = 0x4E,
    }) {
      final b = BytesBuilder();
      u32(b, 0x46414D49); // type echo
      u32(b, version); // 0x4E is what the base game wrote
      u32(b, 0); // reserved
      u32(b, lot);
      // The lots the expansions added, each gated on the version the way
      // a real save gates them.
      if (version >= 0x51) u32(b, lot); // business lot
      if (version >= 0x55) u32(b, 0); // vacation lot
      u32(b, unknownWord);
      u32(b, money);
      u32(b, 1); // family friends
      u32(b, 0); // flags
      u32(b, 0); // member count (membership joins over SDSC instead)
      u32(b, 0); // album guid
      return b.toBytes();
    }

    Uint8List ltxt(String name,
        {List<int> Function(String)? encode,
        String blurb = 'A quiet house on the corner.'}) {
      final encoder = encode ?? latin1.encode;
      final b = BytesBuilder();
      final head =
          Uint8List(19); // versions, size, type, roads, rotation, flags
      head[12] = 0x00; // residential
      b.add(head);
      final nameBytes = encoder(name);
      u32(b, nameBytes.length);
      b.add(nameBytes);
      final blurbBytes = encoder(blurb);
      u32(b, blurbBytes.length);
      b.add(blurbBytes);
      u32(b, 0);
      return b.toBytes();
    }

    /// FAMT: the hood's genealogy - a magic word, a sim count, then per
    /// sim its instance, a skipped word and its (kind, target) ties.
    Uint8List famt(Map<int, List<(int, int)>> ties) {
      final b = BytesBuilder();
      u32(b, 1); // magic
      u32(b, ties.length);
      for (final entry in ties.entries) {
        u16(b, entry.key);
        u32(b, 0); // the word nothing reads
        u32(b, entry.value.length);
        for (final (kind, target) in entry.value) {
          u32(b, kind);
          u16(b, target);
        }
      }
      return b.toBytes();
    }

    Uint8List srel(int daily, int flags) {
      final b = BytesBuilder();
      u32(b, 0);
      u32(b, 4);
      u32(b, daily);
      u32(b, flags);
      u32(b, daily * 2); // lifetime
      u32(b, 0);
      return b.toBytes();
    }

    Uint8List characterPackage({
      required int guid,
      required List<String> ctss,
      Map<int, Uint8List> portraits = const {},
      List<int> Function(String)? encode,
    }) {
      final objd = Uint8List(0x60);
      ByteData.sublistView(objd).setUint32(0x5C, guid, Endian.little);
      return buildV1Package([
        Res(0x4F424A44, objd),
        Res(0x43545353, strResource(ctss, encode: encode)),
        // One image per life stage the sim has lived through, keyed by
        // that stage's bitmask rather than by anything sim-specific.
        for (final entry in portraits.entries)
          Res(0x856DDBAC, entry.value, instance: entry.key),
      ]);
    }

    test('reads a neighborhood: families, sims, bonds and images', () {
      final hoods = Directory(p.join(tempDir.path, 'Neighborhoods'))
        ..createSync();
      final hood = Directory(p.join(hoods.path, 'N001'))..createSync();

      File(p.join(hood.path, 'N001_Neighborhood.package')).writeAsBytesSync(
        buildV1Package([
          Res(
              0xAACE2EFB,
              sdsc(
                  instance: 5,
                  guid: 0xA001,
                  family: 1,
                  age: 0x13,
                  gender: 1,
                  version: 0x36,
                  stats: {
                    10: 900, // cooking
                    18: 400, // logic
                    2: 750, // nice
                    57: 7, // job level
                    89: 0xBD0E, // career guid, low half
                    90: 0x6C9E, // career guid, high half -> Criminal
                    84: 0x0004, // life state: vampire
                    124: 800, // interest: politics
                    133: 300, // interest: sports
                    83: 850, // GPA, thousandths of the 4.0 scale
                    170: 0xF02B, // major guid, low half
                    171: 0x4E9C, // major guid, high half -> Biology
                    174: 5, // semester
                    204: 900, // hobby enthusiasm: cuisine
                    213: 400, // hobby enthusiasm: music
                    215: 0xD5, // the hobby she was born for: music
                  }),
              instance: 5),
          Res(
              0xAACE2EFB,
              sdsc(
                  instance: 6,
                  guid: 0xA002,
                  family: 1,
                  age: 0x03,
                  gender: 0,
                  stats: {68: 0x1}), // ghost flags: this one is a ghost
              instance: 6),
          // The family's name is the string sharing its instance; the
          // word inside the record points at another family's, which is
          // exactly what a played hood does.
          Res(0x46414D49, fami(lot: 9, money: 1234, unknownWord: 0x21),
              instance: 1),
          Res(0x0BF999E7, ltxt('42 Main Street'), instance: 9),
          Res(0x53545223, strResource(['Pleasant']), instance: 1),
          Res(0x53545223, strResource(['Somebody else']), instance: 0x21),
          // The hood's own catalog description: its name, then its blurb.
          Res(0x43545353, strResource(['Pleasantview', 'Where it all began.'])),
          Res(0xCC364C2A, srel(70, (1 << 4) | (1 << 3)), // friends + married
              instance: (5 << 16) | 6),
          Res(0xCC364C2A, srel(50, 1 << 4), instance: (6 << 16) | 5),
          // Genealogy: the child names his mother, and only that end of
          // the tie is stored - her "child" side has to be inferred.
          Res(
              0x8C870743,
              famt({
                6: [(0x00, 5)], // sim 6's mother is sim 5
              })),
        ]),
      );

      Directory(p.join(hood.path, 'Characters')).createSync();
      File(p.join(hood.path, 'Characters', 'char1.package'))
          .writeAsBytesSync(characterPackage(
        guid: 0xA001,
        ctss: ['Bella', 'Vanished one evening.', 'Goth'],
        // She is an adult (0x08); the child portrait must not win.
        portraits: {0x02: fakeJpeg(64, 64), 0x08: fakeJpeg(96, 96)},
      ));
      File(p.join(hood.path, 'Characters', 'char2.package')).writeAsBytesSync(
          characterPackage(guid: 0xA002, ctss: ['Alexander', '', 'Goth']));

      Directory(p.join(hood.path, 'Thumbnails')).createSync();
      File(p.join(hood.path, 'Thumbnails', 'N001_FamilyThumbnails.package'))
          .writeAsBytesSync(buildV1Package([
        // Keyed by the family's instance, and written as the jpg type -
        // which is the only one a real thumbnail package uses.
        Res(0x8C3CE95A, fakeJpeg(220, 160), instance: 1),
      ]));

      File(p.join(hood.path, 'N001_Neighborhood.png'))
          .writeAsBytesSync(fakePng(400, 300));
      Directory(p.join(hood.path, 'Storytelling')).createSync();
      File(p.join(hood.path, 'Storytelling', 'snapshot.jpg'))
          .writeAsBytesSync(fakeJpeg(800, 600));
      File(p.join(hood.path, 'Storytelling', 'snapshot_thumbnail.jpg'))
          .writeAsBytesSync(fakeJpeg(80, 60));

      final saves = scanSims2Saves(hoods.path);
      expect(saves, hasLength(1));
      final save = saves.single;
      // The name the game shows, not the folder code.
      expect(save.name, 'Pleasantview');
      expect(save.worldName, 'N001');
      expect(save.description, 'Where it all began.');
      expect(save.thumbnail, fakePng(400, 300));
      expect(save.simCount, 2);

      final family = save.households.single;
      expect(family.name, 'Pleasant');
      expect(family.funds, 1234);
      expect(family.lotName, '42 Main Street');
      expect(family.description, 'A quiet house on the corner.');
      expect(family.lotTypeKey, 'residential');
      expect(family.isPlayed, isTrue);
      expect(family.portrait, fakeJpeg(220, 160));

      final bella =
          family.members.singleWhere((sim) => sim.firstName == 'Bella');
      expect(bella.lastName, 'Goth');
      expect(bella.ageKey, 'adult');
      expect(bella.genderKey, 'female');
      expect(bella.bio, 'Vanished one evening.');
      expect(bella.skills['cooking'], 900);
      expect(bella.skills['logic'], 400);
      expect(bella.personality['nice'], 750);
      expect(bella.careerName, 'Criminal');
      expect(bella.careerLevel, 7);
      expect(bella.occultKey, 'vampire');
      expect(bella.interests['politics'], 800);
      expect(bella.interests['sports'], 300);
      // The portrait for the life stage she is in, not the first found.
      expect(bella.portrait, fakeJpeg(96, 96));

      final alexander =
          family.members.singleWhere((sim) => sim.firstName == 'Alexander');
      expect(alexander.ageKey, 'child');
      expect(alexander.genderKey, 'male');
      expect(alexander.isGhost, isTrue);
      expect(alexander.careerName, isNull);

      // University: subject, average on the four-point scale, semester.
      expect(bella.education?.major, 'Biology');
      expect(bella.education?.gpa, closeTo(3.4, 0.001));
      expect(bella.education?.semester, 5);
      expect(alexander.education, isNull);

      // Hobbies, and the one the game says she was born for.
      expect(bella.hobbies['cuisine'], 900);
      expect(bella.hobbies['music'], 400);
      expect(bella.predestinedHobbyKey, 'music');

      // The family tree reads from both ends of a one-sided tie: the
      // son names his mother, and she gets him back as her child.
      expect(alexander.familyTies.single.kindKey, 'mother');
      expect(alexander.familyTies.single.name, 'Bella Goth');
      expect(bella.familyTies.single.kindKey, 'child');
      expect(bella.familyTies.single.name, 'Alexander Goth');

      final bond = family.relationships.single;
      expect(bond.score, 60); // both directions averaged
      expect(bond.labelKeys, containsAll(['friends', 'married']));

      // The album: the family portrait plus the storytelling snapshot,
      // its generated thumbnail skipped.
      expect(save.photos.map((photo) => photo.kindKey),
          containsAll(['familyPortrait', 'snapshot']));
      expect(save.photos.where((photo) => photo.path != null), hasLength(1));
    });

    test('reads the funds of every FAMI version an install carries', () {
      final hoods = Directory(p.join(tempDir.path, 'Neighborhoods'))
        ..createSync();
      final hood = Directory(p.join(hoods.path, 'N001'))..createSync();

      // One family per layout: the version EA shipped, and the two the
      // game writes once the expansions' lot fields exist.
      const versions = {0x4E: 1200, 0x54: 2500, 0x55: 72085};
      var instance = 0;
      File(p.join(hood.path, 'N001_Neighborhood.package')).writeAsBytesSync(
        buildV1Package([
          for (final entry in versions.entries) ...[
            Res(0x46414D49,
                fami(lot: 9, money: entry.value, version: entry.key),
                instance: ++instance),
            Res(
                0x53545223,
                strResource(['Family${entry.key.toRadixString(16)}']),
                instance: instance),
            Res(
                0xAACE2EFB,
                sdsc(
                    instance: 0x50 + instance,
                    guid: 0xC000 + instance,
                    family: instance,
                    age: 0x13,
                    gender: 1),
                instance: 0x50 + instance),
          ],
          Res(0x43545353, strResource(['Pleasantview', 'Where it began.'])),
        ]),
      );

      final save = scanSims2Saves(hoods.path).single;
      final funds = {
        for (final household in save.households) household.name: household.funds
      };
      expect(funds, {
        'Family4e': 1200,
        'Family54': 2500,
        'Family55': 72085,
      });
    });

    // Issue #18: a played hood where the word inside each family record
    // lands on the family after it. Reading names off it handed every
    // household its neighbour's, which is what a real save reported -
    // a single sim's home labelled with the dorm next door.
    test('names a household from its own instance, never from that word',
        () {
      final hoods = Directory(p.join(tempDir.path, 'Neighborhoods'))
        ..createSync();
      final hood = Directory(p.join(hoods.path, 'N001'))..createSync();

      const names = {1: 'Gen 2', 2: 'Brivio', 3: 'Dude Bros'};
      File(p.join(hood.path, 'N001_Neighborhood.package')).writeAsBytesSync(
        buildV1Package([
          for (final entry in names.entries) ...[
            Res(
                0x46414D49,
                fami(lot: 0, money: 100 * entry.key, unknownWord: entry.key + 1),
                instance: entry.key),
            Res(0x53545223, strResource([entry.value]), instance: entry.key),
            Res(
                0xAACE2EFB,
                sdsc(
                    instance: 0x50 + entry.key,
                    guid: 0xD000 + entry.key,
                    family: entry.key,
                    age: 0x13,
                    gender: 1),
                instance: 0x50 + entry.key),
          ],
          Res(0x43545353, strResource(['Greystone Harbor', 'A harbor.'])),
        ]),
      );

      final save = scanSims2Saves(hoods.path).single;
      expect({
        for (final household in save.households) household.funds: household.name
      }, {
        100: 'Gen 2',
        200: 'Brivio',
        300: 'Dude Bros',
      });
    });

    test('leaves the hood\'s homeless out of the households', () {
      final hoods = Directory(p.join(tempDir.path, 'Neighborhoods'))
        ..createSync();
      final hood = Directory(p.join(hoods.path, 'N001'))..createSync();

      var instance = 100;
      Iterable<Res> simsIn(int family, int count) sync* {
        for (var i = 0; i < count; i++) {
          instance++;
          yield Res(
              0xAACE2EFB,
              sdsc(
                  instance: instance,
                  guid: 0xB000 + instance,
                  family: family,
                  age: 0x13,
                  gender: 1),
              instance: instance);
        }
      }

      File(p.join(hood.path, 'N001_Neighborhood.package')).writeAsBytesSync(
        buildV1Package([
          // A household: on a lot, and small enough to be one.
          Res(0x46414D49, fami(lot: 9, money: 1234), instance: 1),
          Res(0x53545223, strResource(['Pleasant']), instance: 1),
          Res(0x0BF999E7, ltxt('42 Main Street'), instance: 9),
          ...simsIn(1, 3),
          // The townie pool: a family record like any other, and every
          // sim without a home points at it.
          Res(0x46414D49, fami(lot: 0, money: 20000), instance: 0x7FFF),
          Res(0x53545223, strResource(['Townies']), instance: 0x7FFF),
          ...simsIn(0x7FFF, 12),
          // The dead, who carry no family at all.
          Res(0x46414D49, fami(lot: 0, money: 0), instance: 0),
          Res(0x53545223, strResource(['Ancestors']), instance: 0),
          ...simsIn(0, 9),
          // And a pool under a number this doesn't know, caught by the
          // eight-sim cap instead.
          Res(0x46414D49, fami(lot: 0, money: 20000), instance: 0x7F00),
          Res(0x53545223, strResource(['Unknown pool']), instance: 0x7F00),
          ...simsIn(0x7F00, 11),
          // A record with a name and nobody in it: an address the hood
          // keeps after a household has left.
          Res(0x46414D49, fami(lot: 0, money: 0), instance: 2),
          Res(0x53545223, strResource(['Moved out']), instance: 2),
          Res(0x43545353, strResource(['Pleasantview', 'Where it began.'])),
        ]),
      );

      final save = scanSims2Saves(hoods.path).single;
      expect(save.households.map((h) => h.name), ['Pleasant']);
      expect(save.households.single.members, hasLength(3));
      // And they are not sims the hood is credited with either: the count
      // under "Sims" is the one the households add up to.
      expect(save.simCount, 3);
    });

    /// Windows-1252, what a save written before the game moved to UTF-8
    /// carries: Latin-1 plus the curly punctuation in 0x80-0x9F.
    List<int> cp1252(String value) => [
          for (final rune in value.runes)
            switch (rune) {
              0x2019 => 0x92, // right single quote
              0x2026 => 0x85, // ellipsis
              _ => rune,
            }
        ];

    test('reads accented names, whichever encoding the save used', () {
      final hoods = Directory(p.join(tempDir.path, 'Neighborhoods'))
        ..createSync();
      final hood = Directory(p.join(hoods.path, 'N001'))..createSync();

      File(p.join(hood.path, 'N001_Neighborhood.package')).writeAsBytesSync(
        buildV1Package([
          Res(
              0xAACE2EFB,
              sdsc(instance: 5, guid: 0xA001, family: 1, age: 0x13, gender: 1),
              instance: 5),
          Res(0x46414D49, fami(lot: 9, money: 1234), instance: 1),
          // The lot predates UTF-8 and is in the code page Windows ran.
          Res(
              0x0BF999E7,
              ltxt('Rue de l’Étoile',
                  encode: cp1252, blurb: 'Un coin très calme…'),
              instance: 9),
          Res(0x53545223, strResource(['Gonçalves'], encode: utf8.encode),
              instance: 1),
          Res(
              0x43545353,
              strResource(
                  ['Baía da Belladonna', 'Os Sims sentem-se atraídos!'],
                  encode: utf8.encode)),
        ]),
      );

      Directory(p.join(hood.path, 'Characters')).createSync();
      File(p.join(hood.path, 'Characters', 'char1.package'))
          .writeAsBytesSync(characterPackage(
        guid: 0xA001,
        ctss: ['Anaïs', 'Mudou-se para a baía.', 'Gonçalves'],
        encode: utf8.encode,
      ));

      final save = scanSims2Saves(hoods.path).single;
      expect(save.name, 'Baía da Belladonna');
      expect(save.description, 'Os Sims sentem-se atraídos!');

      final family = save.households.single;
      expect(family.name, 'Gonçalves');
      // The code-page save reads too, curly apostrophe and all.
      expect(family.lotName, 'Rue de l’Étoile');
      expect(family.description, 'Un coin très calme…');

      final sim = family.members.single;
      expect(sim.firstName, 'Anaïs');
      expect(sim.lastName, 'Gonçalves');
      expect(sim.bio, 'Mudou-se para a baía.');
    });
  });

  group('The Sims 1', () {
    Uint8List iffFile(List<(String, int, Uint8List)> chunks) {
      final b = BytesBuilder();
      final signature = latin1.encode(
          'IFF FILE 2.5:TYPE FOLLOWED BY SIZE  JAMIE DOORNBOS & MAXIS 1');
      b.add(signature.sublist(0, 60));
      b.add([0, 0, 0, 0]); // rsmp offset (big-endian, unused)
      for (final (type, id, payload) in chunks) {
        b.add(latin1.encode(type));
        final size = payload.length + 76;
        b.add([
          size >> 24 & 0xFF,
          size >> 16 & 0xFF,
          size >> 8 & 0xFF,
          size & 0xFF
        ]);
        b.add([id >> 8 & 0xFF, id & 0xFF]);
        b.add([0, 0x10]); // flags
        b.add(Uint8List(64)); // label
        b.add(payload);
      }
      return b.toBytes();
    }

    void le32(BytesBuilder b, int v) => u32(b, v);

    Uint8List nbrs(
        List<
                ({
                  String name,
                  int id,
                  int guid,
                  Map<int, int> person,
                  Map<int, int> relations
                })>
            neighbors) {
      final b = BytesBuilder();
      le32(b, 0); // pad
      le32(b, 0x49); // version
      b.add(latin1.encode('SRBN'));
      le32(b, neighbors.length);
      for (final n in neighbors) {
        le32(b, 1); // present
        le32(b, 0xA); // entry version
        le32(b, 9); // unknown3, only in version 0xA
        b.add(latin1.encode(n.name));
        b.addByte(0);
        if (n.name.length.isEven) b.addByte(0); // pad name+NUL to even
        le32(b, 0); // mystery zero
        le32(b, 9); // person mode: data present
        final person = List<int>.filled(256, 0);
        for (final entry in n.person.entries) {
          person[entry.key] = entry.value;
        }
        for (final value in person) {
          u16(b, value);
        }
        u16(b, n.id);
        le32(b, n.guid);
        le32(b, 0xFFFFFFFF); // the usual -1
        le32(b, n.relations.length);
        for (final entry in n.relations.entries) {
          le32(b, 1); // key count
          le32(b, entry.key);
          le32(b, 1); // value count
          le32(b, entry.value);
        }
      }
      return b.toBytes();
    }

    Uint8List fami1(
        {required int house, required int budget, required List<int> guids}) {
      final b = BytesBuilder();
      le32(b, 0);
      le32(b, 0x9);
      b.add(latin1.encode('IMAF'));
      le32(b, house);
      le32(b, 1); // family number (user-created)
      le32(b, budget);
      le32(b, 500); // value in architecture
      le32(b, 2); // family friends
      le32(b, 24); // flags
      le32(b, guids.length);
      for (final guid in guids) {
        le32(b, guid);
      }
      le32(b, 0);
      le32(b, 0);
      le32(b, 0); // the base game writes only 3 trailer zeros
      return b.toBytes();
    }

    /// TS1's own string-table format (-3): total count, then per string a
    /// language byte and two NUL-terminated values.
    Uint8List str1(List<String> values) {
      final b = BytesBuilder();
      b.add([0xFD, 0xFF]); // format -3
      u16(b, values.length);
      for (final value in values) {
        b.addByte(1); // English US
        b.add(latin1.encode(value));
        b.addByte(0);
        b.addByte(0); // empty comment
      }
      return b.toBytes();
    }

    test('reads a UserData neighborhood: family, sims, house and bonds', () {
      final userData = Directory(p.join(tempDir.path, 'UserData2'))
        ..createSync();

      File(p.join(userData.path, 'Neighborhood.iff')).writeAsBytesSync(
        iffFile([
          (
            'NBRS',
            0,
            nbrs([
              (
                name: 'user00000',
                id: 1,
                guid: 0xB001,
                person: {
                  10: 800, // cooking
                  2: 900, // nice
                  61: 3, // family number
                  65: 0, // male
                },
                relations: {2: 55},
              ),
              (
                name: 'user00001',
                id: 2,
                guid: 0xB002,
                person: {61: 3, 65: 1},
                relations: {1: 45},
              ),
            ])
          ),
          ('FAMI', 3, fami1(house: 5, budget: 777, guids: [0xB001, 0xB002])),
          ('FAMs', 3, str1(['Newbie'])),
        ]),
      );

      Directory(p.join(userData.path, 'Characters')).createSync();
      // The sim's own catalog description wins: name, then biography.
      // The body strings carry a different name at index 11, which is
      // only the pool a townie's name is rolled from.
      final bodyStrings = [
        for (var i = 0; i < 11; i++) 'body $i',
        'Rolled Pool Name;Another',
      ];
      File(p.join(userData.path, 'Characters', 'User00000.iff'))
          .writeAsBytesSync(iffFile([
        ('STR#', 200, str1(bodyStrings)),
        ('CTSS', 2000, str1(['Bob Newbie', 'Likes the pool.'])),
      ]));
      // No catalog description: this one falls back to the pool.
      final bettyStrings = [...bodyStrings]..[11] = 'Betty Newbie;Extra Name';
      File(p.join(userData.path, 'Characters', 'User00001.iff'))
          .writeAsBytesSync(iffFile([('STR#', 200, str1(bettyStrings))]));

      Directory(p.join(userData.path, 'Houses')).createSync();
      File(p.join(userData.path, 'Houses', 'NeighborhoodDesc.iff'))
          .writeAsBytesSync(iffFile([
        ('STR#', 2005, str1(['Newbie House', 'desc']))
      ]));
      // The house's own rendered picture, the way the game stores it:
      // a plain Windows bitmap with magenta for transparency.
      File(p.join(userData.path, 'Houses', 'House05.iff'))
          .writeAsBytesSync(iffFile([
        (
          'BMP_',
          513,
          buildBmp(2, 1, [
            const [0xFF, 0x00, 0xFF],
            const [0x30, 0x60, 0x90],
          ])
        )
      ]));

      final saves = scanSims1Saves(tempDir.path);
      expect(saves, hasLength(1));
      final save = saves.single;
      expect(save.neighborhoodNumber, 2);
      expect(save.simCount, 2);

      final family = save.households.single;
      expect(family.name, 'Newbie');
      expect(family.funds, 777);
      expect(family.lotName, 'Newbie House');
      // They live in house 5, so this is a household the player has, not
      // one of the families the game left in the bin.
      expect(family.isPlayed, isTrue);

      final bob =
          family.members.singleWhere((sim) => sim.firstName == 'Bob Newbie');
      expect(bob.genderKey, 'male');
      expect(bob.skills['cooking'], 800);
      expect(bob.personality['nice'], 900);
      expect(bob.bio, 'Likes the pool.');
      // The sim with no catalog description falls back to the body
      // strings' name pool, taking the first name in it.
      expect(
          family.members.map((sim) => sim.firstName), contains('Betty Newbie'));
      // The house's own blurb, and what the game says it is worth.
      expect(family.description, 'desc');
      expect(family.propertyValue, 500);
      // The game's picture of the house, converted to something the app
      // can draw. It is also what stands in for the neighborhood.
      expect(family.portrait, isNotNull);
      expect(family.portrait!.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
      expect(save.thumbnail, family.portrait);
      expect(save.photos.single.kindKey, 'lot');
      expect(bob.ageKey, 'adult');

      final bond = family.relationships.single;
      expect(bond.score, 50); // (55 + 45) / 2
      expect(bond.nameA, isNot('user00000')); // display name, not file stem
    });

    test('a family still in the bin is not one the player has', () {
      final userData = Directory(p.join(tempDir.path, 'UserData'))
        ..createSync();
      File(p.join(userData.path, 'Neighborhood.iff')).writeAsBytesSync(
        iffFile([
          (
            'NBRS',
            0,
            nbrs([
              (
                name: 'user00000',
                id: 1,
                guid: 0xB001,
                person: {61: 3, 65: 0},
                relations: <int, int>{},
              ),
            ])
          ),
          // House 0: never moved in, and carrying the 20,000 simoleons
          // the game hands every family it ships.
          ('FAMI', 3, fami1(house: 0, budget: 20000, guids: [0xB001])),
          ('FAMs', 3, str1(['Roomies'])),
        ]),
      );

      final household = scanSims1Saves(tempDir.path).single.households.single;
      expect(household.name, 'Roomies');
      expect(household.isPlayed, isFalse);
      expect(household.lotName, isNull);
    });

    test('an install without UserData folders has no saves', () {
      expect(scanSims1Saves(tempDir.path), isEmpty);
    });
  });
}
