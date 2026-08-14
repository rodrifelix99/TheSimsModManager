import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sims_mod_manager/src/core/creation.dart';
import 'package:sims_mod_manager/src/core/creation_files.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims1_creations.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims_adapters.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims2_creations.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims3_creations.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims4_creations.dart';

import 'dbpf_fixtures.dart';

// ---------------------------------------------------------------------------
// The Sims 4 tray: a set of files sharing an id, a protobuf of metadata
// and thumbnails the game XORs.

const _imageKey = [0x41, 0x25, 0xE6, 0xCD, 0x47, 0xBA, 0xB2, 0x1A];

/// The tray's obfuscated-image wrapper: 24-byte header then the XORed
/// bytes. Built the way the game writes it so the reader is tested
/// against the real shape rather than against its own inverse.
Uint8List trayImage(Uint8List image) {
  final out = BytesBuilder();
  final header = Uint8List(24);
  final d = ByteData.sublistView(header);
  d.setUint64(0, image.length, Endian.little);
  d.setUint64(8, 0x3C0E789B4824FC8E, Endian.little); // the constant it writes
  d.setUint64(16, 2, Endian.little);
  out.add(header);
  for (var i = 0; i < image.length; i++) {
    out.addByte(image[i] ^ _imageKey[i & 7]);
  }
  return out.toBytes();
}

void varint(BytesBuilder b, int value) {
  var v = value;
  while (v >= 0x80) {
    b.addByte((v & 0x7F) | 0x80);
    v >>= 7;
  }
  b.addByte(v);
}

void protoVarint(BytesBuilder b, int field, int value) {
  varint(b, field << 3);
  varint(b, value);
}

void protoBytes(BytesBuilder b, int field, List<int> value) {
  varint(b, (field << 3) | 2);
  varint(b, value.length);
  b.add(value);
}

void protoString(BytesBuilder b, int field, String value) =>
    protoBytes(b, field, utf8.encode(value));

/// A `.trayitem` body: the 8-byte header the game writes, then the
/// message.
Uint8List trayItem({
  required int id,
  required String name,
  String? description,
  String? creator,
  List<({String first, String last, int simId, int gender, int age})> sims =
      const [],
}) {
  final body = BytesBuilder();
  protoVarint(body, 1, id);
  protoVarint(body, 2, 1);
  protoString(body, 4, name);
  if (description != null) protoString(body, 5, description);
  if (creator != null) protoString(body, 7, creator);

  if (sims.isNotEmpty) {
    final payload = BytesBuilder();
    for (final sim in sims) {
      final record = BytesBuilder();
      protoString(record, 3, sim.first);
      protoString(record, 4, sim.last);
      protoVarint(record, 5, sim.simId);
      protoVarint(record, 6, sim.gender);
      protoVarint(record, 9, sim.age);
      final trait = BytesBuilder();
      protoString(trait, 2, 'Cheerful');
      protoBytes(record, 10, trait.toBytes());
      final aspiration = BytesBuilder();
      protoString(aspiration, 2, 'Friend of the World');
      protoBytes(record, 11, aspiration.toBytes());

      final wrapper = BytesBuilder();
      protoVarint(wrapper, 1, 1);
      protoBytes(wrapper, 2, record.toBytes());
      protoBytes(payload, 2, wrapper.toBytes());
    }
    protoBytes(body, 10, payload.toBytes());
  }

  final bytes = body.toBytes();
  final out = BytesBuilder();
  final header = Uint8List(8);
  ByteData.sublistView(header).setUint32(4, bytes.length, Endian.little);
  out.add(header);
  out.add(bytes);
  return out.toBytes();
}

String trayName(int group, int instance, String extension) =>
    '0x${group.toRadixString(16).padLeft(8, '0')}'
    '!0x${instance.toRadixString(16).padLeft(16, '0')}.$extension';

// ---------------------------------------------------------------------------
// The Sims 2 bins.

/// The lot bin's description record: a 64-byte name header, the 17-byte
/// prefix, then the name and blurb as one-byte-length strings.
Uint8List sims2LotDescription(String name, String blurb) {
  final b = BytesBuilder();
  b.add(Uint8List(0x40));
  b.add([6, 0]);
  b.add([3, 0, 0, 0]);
  b.add([3, 0, 0, 0]);
  b.add([0, 4, 2]);
  b.add([3, 0, 0, 0]);
  final nameBytes = utf8.encode(name);
  b.addByte(nameBytes.length);
  b.add(nameBytes);
  final blurbBytes = utf8.encode(blurb);
  b.addByte(blurbBytes.length);
  b.add(blurbBytes);
  b.add(Uint8List(16));
  return b.toBytes();
}

/// A packaged sim's catalog text: name, bio, surname.
Uint8List sims2CatalogText(String first, String bio, String last) {
  final b = BytesBuilder();
  b.add(Uint8List(0x40));
  b.add([0xFD, 0xFF]); // format -3
  b.add([3, 0]); // three entries
  for (final value in [first, bio, last]) {
    b.addByte(0); // language: English
    b.add(utf8.encode(value));
    b.addByte(0);
    b.addByte(0); // empty comment
  }
  return b.toBytes();
}

/// An image resource with the 64-byte name header in front of it, which
/// is how the bins really write them.
Uint8List headeredImage(Uint8List image) {
  final b = BytesBuilder();
  b.add(Uint8List(0x40));
  b.add(image);
  return b.toBytes();
}

// ---------------------------------------------------------------------------
// The Sims 1 IFF containers.

Uint8List iffChunk(String type, int id, List<int> payload) {
  final b = BytesBuilder();
  b.add(ascii.encode(type));
  final size = 76 + payload.length;
  b.add([
    (size >> 24) & 0xFF,
    (size >> 16) & 0xFF,
    (size >> 8) & 0xFF,
    size & 0xFF
  ]);
  b.add([(id >> 8) & 0xFF, id & 0xFF]);
  b.add(Uint8List(66)); // flags and the 64-byte label
  b.add(payload);
  return b.toBytes();
}

Uint8List iffFile(List<Uint8List> chunks) {
  final b = BytesBuilder();
  final signature = ascii.encode('IFF FILE 2.5:TYPE FOLLOWED BY SIZE');
  b.add(signature);
  b.add(Uint8List(60 - signature.length));
  b.add([0, 0, 0, 0]); // rsmp offset
  for (final chunk in chunks) {
    b.add(chunk);
  }
  return b.toBytes();
}

/// A STR# in format -3: a count, then {language, value, comment}.
Uint8List iffStrings(List<String> values) {
  final b = BytesBuilder();
  b.add([0xFD, 0xFF]); // -3
  b.add([values.length & 0xFF, (values.length >> 8) & 0xFF]);
  for (final value in values) {
    b.addByte(0);
    b.add(utf8.encode(value));
    b.addByte(0);
    b.addByte(0);
  }
  return b.toBytes();
}

void main() {
  late Directory temp;

  setUp(() => temp = Directory.systemTemp.createTempSync('creations_test'));
  tearDown(() {
    try {
      temp.deleteSync(recursive: true);
    } catch (_) {}
  });

  Directory dir(String name) =>
      Directory(p.join(temp.path, name))..createSync(recursive: true);

  group('The Sims 4 tray', () {
    test('reads a household out of the set its files make up', () {
      final tray = dir('Tray');
      const id = 0x00111663272A0031;
      const simId = 0x08111663272A0032;
      File(p.join(tray.path, trayName(1, id, 'trayitem'))).writeAsBytesSync(
          trayItem(
              id: id,
              name: 'Riley',
              description: 'Two of them and a cat.',
              creator: 'anadius',
              sims: [
            (first: 'Connor', last: 'Riley', simId: simId, gender: 4096, age: 16)
          ]));
      File(p.join(tray.path, trayName(0, id, 'householdbinary')))
          .writeAsBytesSync(junk);
      File(p.join(tray.path, trayName(0xB77C5602, id, 'hhi')))
          .writeAsBytesSync(trayImage(fakeJpeg(100, 100)));
      File(p.join(tray.path, trayName(0xB77C5603, id, 'hhi')))
          .writeAsBytesSync(trayImage(fakeJpeg(300, 300)));
      File(p.join(tray.path, trayName(0x13, simId, 'sgi')))
          .writeAsBytesSync(trayImage(fakeJpeg(64, 64)));

      final found = scanSims4Creations(tray.path);
      expect(found, hasLength(1));
      final household = found.single;
      expect(household.name, 'Riley');
      expect(household.kindKey, kindHousehold);
      expect(household.creatorName, 'anadius');
      expect(household.description, 'Two of them and a cat.');
      expect(household.sims.single.fullName, 'Connor Riley');
      expect(household.sims.single.genderKey, 'male');
      expect(household.sims.single.ageKey, 'youngAdult');
      expect(household.sims.single.traits, ['Cheerful']);
      expect(household.sims.single.aspiration, 'Friend of the World');
      expect(household.sims.single.portrait, isNotNull);
    });

    test('the biggest thumbnail wins, and it is a real image', () {
      final tray = dir('Tray');
      const id = 0x1234;
      File(p.join(tray.path, trayName(1, id, 'trayitem')))
          .writeAsBytesSync(trayItem(id: id, name: 'Big House'));
      File(p.join(tray.path, trayName(0, id, 'blueprint')))
          .writeAsBytesSync(junk);
      File(p.join(tray.path, trayName(0xB77C5602, id, 'bpi')))
          .writeAsBytesSync(trayImage(fakeJpeg(10, 10)));
      File(p.join(tray.path, trayName(0xB77C5603, id, 'bpi')))
          .writeAsBytesSync(trayImage(fakePng(400, 400)));

      final lot = scanSims4Creations(tray.path).single;
      expect(lot.kindKey, kindLot, reason: 'a .blueprint is a lot');
      // The PNG is the larger of the two, and it decoded.
      expect(lot.thumbnail!.sublist(0, 4), fakePng(1, 1).sublist(0, 4));
    });

    /// The one part of a set whose file name carries a sim id rather than
    /// the item's, so it can only be found through the metadata.
    test('a portrait travels with the household that owns it', () {
      final tray = dir('Tray');
      const id = 0xAAAA;
      const simId = 0xBBBB;
      final item = File(p.join(tray.path, trayName(1, id, 'trayitem')))
        ..writeAsBytesSync(trayItem(id: id, name: 'Solo', sims: [
          (first: 'Ida', last: 'Solo', simId: simId, gender: 8192, age: 32)
        ]));
      File(p.join(tray.path, trayName(0, id, 'householdbinary')))
          .writeAsBytesSync(junk);
      final portrait = File(p.join(tray.path, trayName(0x13, simId, 'sgi')))
        ..writeAsBytesSync(trayImage(fakeJpeg(64, 64)));
      // A portrait belonging to somebody else must not be swept in.
      File(p.join(tray.path, trayName(0x13, 0xCCCC, 'sgi')))
          .writeAsBytesSync(trayImage(fakeJpeg(64, 64)));

      final household = scanSims4Creations(tray.path).single;
      expect(household.allFiles, contains(portrait.path));
      expect(household.allFiles.where((f) => f.endsWith('.sgi')), hasLength(1));
      expect(sims4TraySiblings(item.path), contains(portrait.path));
      expect(sims4TraySiblings(item.path), hasLength(3));
    });

    test('a folder of anything else is not a tray', () {
      final tray = dir('Tray');
      File(p.join(tray.path, 'notes.txt')).writeAsStringSync('hello');
      expect(scanSims4Creations(tray.path), isEmpty);
      expect(sims4TrayFiles(['a.package', 'b.txt']), isEmpty);
    });
  });

  group('The Sims 3 library', () {
    /// The thumbnail family is the only thing that separates a lot from a
    /// mod, both of which are `.package` files.
    test('tells lots, households and sims apart, and leaves mods alone', () {
      final library = dir('Library');
      File(p.join(library.path, 'Gothique Library.package')).writeAsBytesSync(
          buildV2Package([Res(0xD84E7FC5, fakePng(128, 128))]));
      File(p.join(library.path, 'The Goths.package')).writeAsBytesSync(
          buildV2Package([Res(0x6B6D837D, fakePng(64, 64))]));
      File(p.join(library.path, 'Bella.package')).writeAsBytesSync(
          buildV2Package([Res(0x0580A2CD, fakePng(64, 64))]));
      File(p.join(library.path, 'nointeldefault.package'))
          .writeAsBytesSync(buildV2Package([Res(0x034AEECB, junk)]));

      final found = scanSims3Creations(library.path);
      expect(found.map((c) => '${c.name}:${c.kindKey}').toSet(), {
        'Gothique Library:$kindLot',
        'The Goths:$kindHousehold',
        'Bella:$kindSim',
      });
    });

    /// The metadata's name is a localization key for anything EA
    /// published, so the file name is what the player actually sees.
    test('the file name wins over a localization key inside', () {
      final library = dir('Library');
      final meta = BytesBuilder()
        ..add(Uint8List(0x50))
        ..add(_utf16('World/LotName:HiddenSpringsFestival'))
        ..add(_utf16('DOT03/World/Venue/LotAddress:Lot15'));
      File(p.join(library.path, 'Beryl Forest Campgrounds.package'))
          .writeAsBytesSync(buildV2Package([
        Res(0xD84E7FC5, fakePng(128, 128)),
        Res(0xD063545B, meta.toBytes()),
      ]));

      final lot = scanSims3Creations(library.path).single;
      expect(lot.name, 'Beryl Forest Campgrounds');
      expect(lot.worldName, 'Lot15');
      expect(lot.description, isNull);
    });

    /// A file the game named after a hash has nothing worth reading in
    /// its name, so there the record inside wins instead.
    test('a hash-named export takes its name from the record inside', () {
      final library = dir('Library');
      final household = BytesBuilder()
        ..add(Uint8List(0x10))
        ..add(_utf16('Bakerman'));
      File(p.join(library.path, 'ebf_0x471000eeb5f6bf30.package'))
          .writeAsBytesSync(buildV2Package([
        Res(0x6B6D837D, fakePng(64, 64)),
        Res(0x062853A8, household.toBytes()),
      ]));

      expect(scanSims3Creations(library.path).single.name, 'Bakerman');
    });

    /// The description record also holds .NET type names and runs of
    /// binary that happen to decode; neither is a blurb.
    test('keeps a real blurb and refuses what only looks like one', () {
      final library = dir('Library');
      final meta = BytesBuilder()
        ..add(Uint8List(0x50))
        ..add(_utf16('Gothique Library'))
        ..add(_utf16('Built by the very first Goths that ever settled here.'))
        ..add(_utf16('Sims3.Store.Objects.GlassWorkbench+ArtisanSkill, Store'));
      File(p.join(library.path, 'Gothique Library.package'))
          .writeAsBytesSync(buildV2Package([
        Res(0xD84E7FC5, fakePng(128, 128)),
        Res(0xD063545B, meta.toBytes()),
      ]));

      final lot = scanSims3Creations(library.path).single;
      expect(lot.description,
          'Built by the very first Goths that ever settled here.');
    });
  });

  group('The Sims 2 bins', () {
    test('reads a lot name and its picture out of the lot bin', () {
      final bin = dir('LotCatalog');
      File(p.join(bin.path, 'cx_00000003.package'))
          .writeAsBytesSync(buildV1Package([
        Res(0x6C589723, sims2LotDescription('Just Right - 2BR 1BA', '')),
        Res(0x856DDBAC, headeredImage(fakeJpeg(300, 300))),
      ]));

      final lot = scanSims2Lots(bin.path).single;
      expect(lot.name, 'Just Right - 2BR 1BA');
      expect(lot.kindKey, kindLot);
      expect(lot.thumbnail, isNotNull);
      // The record repeats the name where there is no blurb.
      expect(lot.description, isNull);
    });

    /// A lot packaged with its residents brings them along as separate
    /// files, and deleting the lot has to take them too.
    test('a packaged lot carries its residents in its file list', () {
      final bin = dir('LotCatalog');
      File(p.join(bin.path, 'cx_00000025.package'))
          .writeAsBytesSync(buildV1Package(
              [Res(0x6C589723, sims2LotDescription('Cozy Kitten Condo', ''))]));
      final resident =
          File(p.join(bin.path, 'cx_Character_cx_00000025_11f1177b.package'))
            ..writeAsBytesSync(buildV1Package([Res(0x4F424A44, junk)]));

      final found = scanSims2Lots(bin.path);
      expect(found, hasLength(1), reason: 'the resident is not a card of its own');
      expect(found.single.allFiles, contains(resident.path));
    });

    test('reads a packaged sim out of the sims bin', () {
      final bin = dir('SavedSims');
      File(p.join(bin.path, 'anysim.package')).writeAsBytesSync(
          buildV1Package([
        Res(0xAACE2EFB, junk),
        Res(0x43545353, sims2CatalogText('Bella', 'Loves a mystery.', 'Goth')),
        Res(0x8C3CE95A, headeredImage(fakeJpeg(128, 128))),
      ]));

      final sim = scanSims2Sims(bin.path).single;
      expect(sim.name, 'Bella Goth');
      expect(sim.kindKey, kindSim);
      expect(sim.description, 'Loves a mystery.');
      expect(sim.thumbnail, isNotNull);
      expect(sim.sims.single.lastName, 'Goth');
    });

    test('a mod in either bin is not a creation', () {
      final bin = dir('SavedSims');
      File(p.join(bin.path, 'somemod.package'))
          .writeAsBytesSync(buildV1Package([Res(0x4F424A44, junk)]));
      expect(scanSims2Sims(bin.path), isEmpty);
    });
  });

  group('The Sims 1 houses', () {
    Directory housesWith(List<int> numbers, {List<String>? names}) {
      final houses = dir(p.join('UserData', 'Houses'));
      for (final number in numbers) {
        File(p.join(houses.path, houseFileName(number))).writeAsBytesSync(
            iffFile([iffChunk('BMP_', 513, junk)]));
      }
      if (names != null) {
        File(p.join(houses.path, 'NeighborhoodDesc.iff')).writeAsBytesSync(
            iffFile([
          for (var i = 0; i < names.length; i++)
            iffChunk('STR#', numbers[i] + 2000,
                iffStrings([names[i], 'A place to live.'])),
        ]));
      }
      return houses;
    }

    test('names houses from the neighborhood description', () {
      final houses = housesWith([1, 2], names: ['Goth Manor', 'Pleasant Home']);
      final found = scanSims1Creations(houses.path);
      expect(found.map((c) => c.name).toSet(), {'Goth Manor', 'Pleasant Home'});
      expect(found.every((c) => c.kindKey == kindLot), isTrue);
      expect(found.first.description, 'A place to live.');
    });

    test('a house nothing has named reads as its file', () {
      final houses = housesWith([7]);
      expect(scanSims1Creations(houses.path).single.name, 'House07');
    });

    /// The lots the map really has are the ones with a file. A number
    /// nobody is using is not a free slot - it is a position the map has
    /// no lot for, and a house written there is invisible in game.
    test('the occupied slots are the map, in order', () {
      final houses = housesWith([4, 1, 2]);
      expect(occupiedHouseNumbers(houses.path), [1, 2, 4]);
      expect(houseFileName(3), 'House03.iff');
    });

    test('a folder with no houses offers no lots at all', () {
      final houses = housesWith([]);
      expect(occupiedHouseNumbers(houses.path), isEmpty);
    });

    /// Reported by a player: an earlier version claimed the lowest
    /// unused number, which on a neighborhood filled to 79 would have
    /// written into Studio Town's range and shown up nowhere.
    test('installing a house refuses to choose a lot', () async {
      final install = dir('sims1');
      Directory(p.join(install.path, 'UserData', 'Houses'))
          .createSync(recursive: true);
      final adapter = Sims1Adapter(installOverride: install);
      final folder = (await adapter.creationFolders()).single;
      await expectLater(
        adapter.installCreations([p.join(install.path, 'House.iff')], folder),
        throwsA(isA<ModActionException>()),
      );
    });

    test('recognises a house file by name and nothing else', () {
      expect(isSims1HouseFile('House07.iff'), isTrue);
      expect(isSims1HouseFile(r'C:\games\House7.iff'), isTrue);
      expect(isSims1HouseFile('Neighborhood.iff'), isFalse);
      expect(isSims1HouseFile('hair.package'), isFalse);
    });
  });

  group('installing and removing', () {
    test('a set of files lands whole, keeping every name', () async {
      final source = dir('download');
      final target = dir('Tray');
      final names = ['0x00000001!0x00aa.trayitem', '0x00000000!0x00aa.hhi'];
      for (final name in names) {
        File(p.join(source.path, name)).writeAsBytesSync(junk);
      }

      final written = await copyCreationFiles(
        [for (final name in names) p.join(source.path, name)],
        CreationFolder(labelKey: 'sims4Tray', path: target.path),
      );

      expect(written, hasLength(2));
      for (final name in names) {
        expect(File(p.join(target.path, name)).existsSync(), isTrue,
            reason: 'the game finds these by name, so they keep it');
      }
      // Nothing half-written is left behind.
      expect(
        target.listSync().where((e) => e.path.endsWith('.part')),
        isEmpty,
      );
    });

    test('reinstalling replaces rather than piling up copies', () async {
      final source = dir('download');
      final target = dir('Tray');
      final name = '0x00000001!0x00aa.trayitem';
      File(p.join(source.path, name)).writeAsBytesSync(junk);
      final folder = CreationFolder(labelKey: 'sims4Tray', path: target.path);

      await copyCreationFiles([p.join(source.path, name)], folder);
      await copyCreationFiles([p.join(source.path, name)], folder);

      expect(target.listSync(), hasLength(1));
    });

    test('a name this platform cannot write is refused, not rewritten',
        () async {
      final target = dir('Tray');
      // The reader looks these up by name, so a silently shortened one is
      // worse than a refusal.
      await expectLater(
        copyCreationFiles(
          [p.join(temp.path, 'bad:name?.trayitem')],
          CreationFolder(labelKey: 'sims4Tray', path: target.path),
        ),
        throwsA(isA<ModActionException>()),
      );
    }, skip: !Platform.isWindows);

    test('deleting takes every file the creation is made of', () async {
      final tray = dir('Tray');
      final files = [
        for (final name in ['a.trayitem', 'b.hhi', 'c.sgi'])
          (File(p.join(tray.path, name))..writeAsBytesSync(junk)).path,
      ];

      await deleteCreationFiles(Creation(
        name: 'Riley',
        kindKey: kindHousehold,
        path: files.first,
        files: files,
      ));

      expect(tray.listSync(), isEmpty);
    });

    test('a file already gone is not a failure', () async {
      final tray = dir('Tray');
      await deleteCreationFiles(Creation(
        name: 'Ghost',
        kindKey: kindLot,
        path: p.join(tray.path, 'never-existed.trayitem'),
      ));
    });
  });

  /// The Sims 4 adapter's own routing, which is what an Add or a drop
  /// runs through: a tray file announces itself, and the rest of its set
  /// is dragged along from beside it.
  group('routing a download', () {
    test('a tray file takes its whole set, and leaves other files alone',
        () async {
      final tray = dir('Tray');
      final download = dir('download');
      const id = 0xAAAA;
      final item = p.join(download.path, trayName(1, id, 'trayitem'));
      File(item).writeAsBytesSync(trayItem(id: id, name: 'Riley'));
      final payload = p.join(download.path, trayName(0, id, 'householdbinary'));
      File(payload).writeAsBytesSync(junk);
      final readme = p.join(download.path, 'readme.txt');
      File(readme).writeAsStringSync('install me');

      final adapter = Sims4Adapter(documentsOverride: Directory(temp.path));
      // The adapter looks for Documents/Electronic Arts/<game>/Tray.
      final docs = Directory(p.join(
          temp.path, 'Electronic Arts', 'The Sims 4', 'Tray'))
        ..createSync(recursive: true);
      File(p.join(docs.path, 'GameVersion.txt')).writeAsStringSync('1');

      final routing = await adapter.routeCreations([item, readme]);
      expect(routing, isNotNull);
      expect(routing!.folder.labelKey, 'sims4Tray');
      // The payload was never offered and is picked up anyway: half a
      // set is an item the game can draw and cannot load.
      expect(routing.files, containsAll([item, payload]));
      expect(routing.unrecognised, [readme]);
      expect(tray.existsSync(), isTrue);
    });

    test('a download with nothing in it for this game routes nowhere',
        () async {
      final download = dir('download');
      final mod = p.join(download.path, 'hair.package');
      File(mod).writeAsBytesSync(junk);
      final adapter = Sims4Adapter(documentsOverride: Directory(temp.path));
      expect(await adapter.routeCreations([mod]), isNull);
    });
  });

  group('the shelf itself', () {
    Creation at(String name, String kind, DateTime when) => Creation(
        name: name, kindKey: kind, path: '/$name', modifiedAt: when);

    test('counts every kind, in a fixed order', () {
      final counts = countCreationKinds([
        at('a', kindSim, DateTime(2026)),
        at('b', kindLot, DateTime(2026)),
        at('c', kindLot, DateTime(2026)),
      ]);
      expect(counts.keys.toList(), [kindLot, kindSim],
          reason: 'lots lead, whatever order they were found in');
      expect(counts[kindLot], 2);
    });

    /// A kind no reader has heard of still earns a chip rather than
    /// disappearing out of the totals.
    test('an unknown kind still counts', () {
      final counts = countCreationKinds([at('a', 'spaceship', DateTime(2026))]);
      expect(counts, {'spaceship': 1});
    });

    test('newest first, and the order is total', () {
      final same = DateTime(2026, 5, 1);
      final list = [
        at('zebra', kindLot, same),
        at('older', kindLot, DateTime(2025)),
        at('apple', kindLot, same),
      ]..sort(compareCreations);
      expect(list.map((c) => c.name).toList(), ['apple', 'zebra', 'older']);
    });

    test('a folder says what it will take', () {
      const lots = CreationFolder(
          labelKey: 'sims2LotCatalog', path: '/bin', kinds: [kindLot]);
      const anything = CreationFolder(labelKey: 'sims4Tray', path: '/tray');
      expect(lots.accepts(kindLot), isTrue);
      expect(lots.accepts(kindSim), isFalse);
      expect(anything.accepts(kindSim), isTrue);
    });

    test('a creation describes its own files when it is only one', () {
      final one = at('solo', kindLot, DateTime(2026));
      expect(one.allFiles, ['/solo']);
    });
  });
}

/// An int32-count UTF-16LE string, the way The Sims 3 writes text.
Uint8List _utf16(String value) {
  final b = BytesBuilder();
  final units = value.codeUnits;
  b.add([
    units.length & 0xFF,
    (units.length >> 8) & 0xFF,
    (units.length >> 16) & 0xFF,
    (units.length >> 24) & 0xFF,
  ]);
  for (final unit in units) {
    b.add([unit & 0xFF, (unit >> 8) & 0xFF]);
  }
  return b.toBytes();
}
