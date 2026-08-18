import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sims_mod_manager/src/core/app_message.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims3pack.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims_adapters.dart';

/// One `<PackagedFile>` to write into a test container.
class _Entry {
  _Entry(this.name, this.contentType, this.content);

  final String name;
  final String contentType;
  final String content;
}

void main() {
  late Directory modsDir;
  late Directory sourceDir;
  late Sims3Adapter adapter;

  setUp(() async {
    modsDir = await Directory.systemTemp.createTemp('mod_manager_mods');
    sourceDir = await Directory.systemTemp.createTemp('mod_manager_packs');
    adapter = const Sims3Adapter();
  });

  tearDown(() async {
    await modsDir.delete(recursive: true);
    await sourceDir.delete(recursive: true);
  });

  /// Writes a `.sims3pack` in the real container layout: the
  /// length-prefixed magic, the version pair, the manifest's length, the
  /// manifest, then the payload the offsets point into.
  File makePack(
    String name,
    List<_Entry> entries, {
    String displayName = 'Test Pack',
    String rootType = 'object',
    String magic = 'TS3Pack',
  }) {
    final payload = BytesBuilder();
    final blocks = StringBuffer();
    for (final entry in entries) {
      final bytes = utf8.encode(entry.content);
      blocks.write('  <PackagedFile>\n'
          '    <Name>${entry.name}</Name>\n'
          '    <Length>${bytes.length}</Length>\n'
          '    <Offset>${payload.length}</Offset>\n'
          '    <ContentType>${entry.contentType}</ContentType>\n'
          '    <metatags>\n'
          '      <name>a metatag, not the entry name</name>\n'
          '    </metatags>\n'
          '  </PackagedFile>\n');
      payload.add(bytes);
    }
    final xml = utf8.encode('<?xml version="1.0" encoding="UTF-8"?>'
        '<Sims3Package Type="$rootType" SubType="0x00000000">\n'
        '  <DisplayName>$displayName</DisplayName>\n'
        '$blocks'
        '</Sims3Package>');

    final out = BytesBuilder();
    final head = ByteData(4)..setUint32(0, magic.length, Endian.little);
    out.add(head.buffer.asUint8List());
    out.add(ascii.encode(magic));
    out.add([1, 1]);
    final size = ByteData(4)..setUint32(0, xml.length, Endian.little);
    out.add(size.buffer.asUint8List());
    out.add(xml);
    out.add(payload.takeBytes());

    final file = File(p.join(sourceDir.path, name));
    file.writeAsBytesSync(out.takeBytes());
    return file;
  }

  /// Writes a zip named [name] holding [entries] (path -> bytes), which
  /// is how a set of recolours actually arrives: one archive of
  /// containers rather than a container of its own.
  File makeZip(String name, Map<String, List<int>> entries) {
    final zip = Archive();
    entries.forEach((path, bytes) {
      zip.addFile(ArchiveFile.typedData(path, Uint8List.fromList(bytes)));
    });
    final file = File(p.join(sourceDir.path, name));
    file.writeAsBytesSync(ZipEncoder().encode(zip));
    return file;
  }

  test('recognizes sims3pack paths case-insensitively', () {
    expect(isSims3PackPath('cute.sims3pack'), isTrue);
    expect(isSims3PackPath('Cute.Sims3Pack'), isTrue);
    expect(isSims3PackPath('cute.package'), isFalse);
  });

  test('only The Sims 3 accepts the container', () {
    expect(adapter.containerFileExtensions, contains('.sims3pack'));
    expect(const Sims4Adapter().containerFileExtensions,
        isNot(contains('.sims3pack')));
    expect(const Sims2Adapter().containerFileExtensions,
        isNot(contains('.sims3pack')));
    // The shared formats stay available to every game.
    expect(adapter.containerFileExtensions, contains('.zip'));
  });

  test('reads the manifest off a container', () async {
    final pack = makePack('cc.sims3pack', [
      _Entry('0xaaa.package', 'CASpart', 'hair'),
      _Entry('0xbbb.package', 'object', 'sofa'),
    ], displayName: 'Nice Hair');

    final manifest = await readSims3PackManifest(pack);

    expect(manifest.displayName, 'Nice Hair');
    expect(manifest.entries.map((e) => e.name),
        ['0xaaa.package', '0xbbb.package']);
    // Lowercased for comparison, and read from <ContentType> rather than
    // the <name> inside <metatags>.
    expect(manifest.entries.map((e) => e.contentType), ['caspart', 'object']);
    expect(manifest.libraryContent, isEmpty);
  });

  test('installs several packages into a folder named after the pack',
      () async {
    final pack = makePack('cc.sims3pack', [
      _Entry('0xaaa.package', 'CASpart', 'hair bytes'),
      _Entry('0xbbb.package', 'object', 'sofa bytes'),
      _Entry('thumb.png', 'unknown', 'a picture'),
    ], displayName: 'Nice Hair');

    final mods = await adapter.installArchive(modsDir, pack);

    // Entries are named by GUID in the container; what the library shows
    // is the one name a person wrote, numbered in manifest order.
    expect(mods.map((m) => m.name), ['Nice Hair.package', 'Nice Hair-2.package']);
    final folder = p.join(modsDir.path, 'Nice Hair');
    expect(File(p.join(folder, 'Nice Hair.package')).readAsStringSync(),
        'hair bytes');
    expect(File(p.join(folder, 'Nice Hair-2.package')).readAsStringSync(),
        'sofa bytes');
    // The thumbnail is not a mod file and stays out of the library.
    expect(File(p.join(folder, 'thumb.png')).existsSync(), isFalse);
  });

  test('a pack holding one mod file installs as that file', () async {
    // What almost every piece of custom content is: one package, whose
    // GUID name would be the whole of the library card without this.
    final pack = makePack('BS_Bikini_TS3.sims3pack',
        [_Entry('0xe4a3eb.package', 'CASpart', 'a bikini top')],
        displayName: 'BS_FrillEdgeBandeauBikiniTop_TS3');

    final mods = await adapter.installArchive(modsDir, pack);

    expect(mods.map((m) => m.name), ['BS_FrillEdgeBandeauBikiniTop_TS3.package']);
    // No folder of its own: one mod is not a set.
    expect(
        File(p.join(modsDir.path, 'BS_FrillEdgeBandeauBikiniTop_TS3.package'))
            .readAsStringSync(),
        'a bikini top');
  });

  test('installing the same pack twice leaves one copy', () async {
    final pack = makePack('cc.sims3pack', [
      _Entry('0xaaa.package', 'CASpart', 'hair bytes'),
      _Entry('0xbbb.package', 'object', 'sofa bytes'),
    ], displayName: 'Nice Hair');

    await adapter.installArchive(modsDir, pack);
    final again = await adapter.installArchive(modsDir, pack);

    expect(again.map((m) => m.name), ['Nice Hair.package', 'Nice Hair-2.package']);
    expect(Directory(p.join(modsDir.path, 'Nice Hair')).listSync().length, 2);
  });

  test('falls back to the file name when the pack has no title', () async {
    final pack = makePack('Some Creator CC.sims3pack',
        [_Entry('0xaaa.package', 'object', 'lamp')], displayName: '');

    await adapter.installArchive(modsDir, pack);

    expect(File(p.join(modsDir.path, 'Some Creator CC.package')).existsSync(),
        isTrue);
  });

  test('a title that names a folder installs no folder', () async {
    final pack = makePack('cc.sims3pack',
        [_Entry('0xaaa.package', 'object', 'lamp')], displayName: 'Lamps/Tall');

    await adapter.installArchive(modsDir, pack);

    expect(File(p.join(modsDir.path, 'Lamps_Tall.package')).existsSync(), isTrue);
    expect(Directory(p.join(modsDir.path, 'Lamps')).existsSync(), isFalse);
  });

  test('refuses a world, naming it as one', () async {
    // Shaped like the EA store worlds: the world itself plus the objects
    // and CAS parts it ships, which is exactly what must not be scattered
    // through the mods folder.
    final pack = makePack('Riverview.sims3pack', [
      _Entry('0xworld.package', 'world', 'the world'),
      _Entry('0xaaa.package', 'object', 'a bench'),
      _Entry('0xbbb.package', 'CASpart', 'a hat'),
    ], displayName: 'Riverview');

    await expectLater(
      adapter.installArchive(modsDir, pack),
      throwsA(isA<ModContentException>().having(
          (e) => e.detail.key, 'key', 'sims3PackWorld')),
    );
    // Nothing of it was installed, not even the parts that would have fit.
    expect(modsDir.listSync(), isEmpty);
  });

  test('refuses a world even when the root tag claims otherwise', () async {
    // Seven of the eleven real store worlds on hand say Type="object" at
    // the root, so the per-entry ContentType is the only honest signal.
    final pack = makePack('MidnightHollowGold.sims3pack', [
      _Entry('0xaaa.package', 'object', 'a lamp'),
      _Entry('0xworld.package', 'world', 'the world'),
    ], rootType: 'object');

    await expectLater(
      adapter.installArchive(modsDir, pack),
      throwsA(isA<ModContentException>().having(
          (e) => e.detail.key, 'key', 'sims3PackWorld')),
    );
  });

  test('refuses lots and households as library content', () async {
    for (final type in ['lot', 'household', 'blueprint', 'roomBlueprint']) {
      final pack = makePack('$type.sims3pack', [
        _Entry('0xaaa.package', type, 'library content'),
        _Entry('0xbbb.package', 'object', 'an object'),
      ]);

      await expectLater(
        adapter.installArchive(modsDir, pack),
        throwsA(isA<ModContentException>().having(
            (e) => e.detail.key, 'key', 'sims3PackLibrary')),
        reason: '$type belongs in the in-game Library',
      );
    }
  });

  test('reports a pack that holds no packages', () async {
    final pack = makePack(
        'art.sims3pack', [_Entry('thumb.png', 'unknown', 'a picture')]);

    await expectLater(
      adapter.installArchive(modsDir, pack),
      throwsA(isA<ModContentException>()
          .having((e) => e.detail.key, 'key', 'noModFiles')),
    );
  });

  test('rejects bytes that are not a container', () async {
    final notAPack = File(p.join(sourceDir.path, 'fake.sims3pack'))
      ..writeAsStringSync('this is not a sims3pack at all');

    await expectLater(
      adapter.installArchive(modsDir, notAPack),
      throwsA(isA<ModContentException>()
          .having((e) => e.detail.key, 'key', 'sims3PackUnreadable')),
    );
  });

  test('rejects a container whose magic is wrong', () async {
    final pack = makePack('odd.sims3pack',
        [_Entry('0xaaa.package', 'object', 'x')], magic: 'TS4Pack');

    await expectLater(
      adapter.installArchive(modsDir, pack),
      throwsA(isA<ModContentException>()
          .having((e) => e.detail.key, 'key', 'sims3PackUnreadable')),
    );
  });

  test('drops an entry whose bytes fall outside the file', () async {
    final pack = makePack('cut.sims3pack', [
      _Entry('0xaaa.package', 'object', 'lamp'),
      _Entry('0xbbb.package', 'object', 'sofa'),
    ]);
    // Lose the tail, so the last entry's offset+length runs past the end.
    final bytes = pack.readAsBytesSync();
    pack.writeAsBytesSync(bytes.sublist(0, bytes.length - 4));

    final mods = await adapter.installArchive(modsDir, pack);

    // One entry left, so it lands as the pack itself rather than in a
    // folder - what is inside is what decides that, not what was declared.
    expect(mods.map((m) => m.name), ['Test Pack.package']);
  });

  test('two packs with the same GUID names keep their own copies', () async {
    // Every real pack names its packages by GUID, so what stops one
    // creator's file from overwriting another's is the pack's own title.
    final first = makePack('one.sims3pack',
        [_Entry('0xaaa.package', 'object', 'first')], displayName: 'Pack One');
    final second = makePack('two.sims3pack',
        [_Entry('0xaaa.package', 'object', 'second')], displayName: 'Pack Two');

    await adapter.installArchive(modsDir, first);
    await adapter.installArchive(modsDir, second);

    expect(File(p.join(modsDir.path, 'Pack One.package')).readAsStringSync(),
        'first');
    expect(File(p.join(modsDir.path, 'Pack Two.package')).readAsStringSync(),
        'second');
  });

  test('unpacks the containers a zip carries', () async {
    // Issue #21: a set shared as one archive of sims3packs installed
    // nothing at all, because the extraction only ever looked for the
    // files the game loads.
    final zip = makeZip('recolours.zip', {
      'Sage.sims3pack': makePack('sage.sims3pack',
          [_Entry('0xaaa.package', 'object', 'a sage sofa')],
          displayName: 'Comfy Sofa - Sage').readAsBytesSync(),
      'Rust.sims3pack': makePack('rust.sims3pack',
          [_Entry('0xbbb.package', 'object', 'a rust sofa')],
          displayName: 'Comfy Sofa - Rust').readAsBytesSync(),
      'readme.txt': utf8.encode('put these in your Mods folder'),
    });

    final mods = await adapter.installArchive(modsDir, zip);

    expect(mods.map((m) => m.name).toList()..sort(),
        ['Comfy Sofa - Rust.package', 'Comfy Sofa - Sage.package']);
    expect(
        File(p.join(modsDir.path, 'Comfy Sofa - Sage.package'))
            .readAsStringSync(),
        'a sage sofa');
    // The container is not something the game reads out of Packages, and
    // the library would never list it: it goes with the unpacking.
    expect(File(p.join(modsDir.path, 'Sage.sims3pack')).existsSync(), isFalse);
  });

  test('a container is unpacked where the archive put it', () async {
    final zip = makeZip('bundle.zip', {
      'Comfy Sofa/Sage.sims3pack': makePack('sage.sims3pack', [
        _Entry('0xaaa.package', 'object', 'a sage sofa'),
        _Entry('0xbbb.package', 'object', 'a sage armchair'),
      ], displayName: 'Sage').readAsBytesSync(),
      'plain.package': utf8.encode('a loose mod'),
    });

    final mods = await adapter.installArchive(modsDir, zip);

    expect(mods, hasLength(3));
    // The archive's own folder still stands, and inside it the pack's,
    // because two files out of one container are a set.
    final folder = p.join(modsDir.path, 'Comfy Sofa', 'Sage');
    expect(File(p.join(folder, 'Sage.package')).readAsStringSync(),
        'a sage sofa');
    expect(File(p.join(folder, 'Sage-2.package')).readAsStringSync(),
        'a sage armchair');
    expect(File(p.join(modsDir.path, 'plain.package')).existsSync(), isTrue);
  });

  test('a world among them costs the world, not the download', () async {
    final zip = makeZip('bundle.zip', {
      'Riverview.sims3pack': makePack('riverview.sims3pack', [
        _Entry('0xworld.package', 'world', 'the world'),
        _Entry('0xaaa.package', 'object', 'a bench'),
      ], displayName: 'Riverview').readAsBytesSync(),
      'Hair.sims3pack': makePack('hair.sims3pack',
          [_Entry('0xbbb.package', 'CASpart', 'hair bytes')],
          displayName: 'Nice Hair').readAsBytesSync(),
    });

    final mods = await adapter.installArchive(modsDir, zip);

    expect(mods.map((m) => m.name), ['Nice Hair.package']);
    // Not a single piece of the world, and nothing left half-installed.
    expect(File(p.join(modsDir.path, 'Riverview.package')).existsSync(),
        isFalse);
    expect(File(p.join(modsDir.path, 'Riverview.sims3pack')).existsSync(),
        isFalse);
  });

  test('a zip of nothing but a world says so', () async {
    // Nothing survived, so the reason the one container was refused is
    // what the user hears - the generic "no mod files here" would send
    // them looking for a fault in a perfectly good download.
    final zip = makeZip('Riverview.zip', {
      'Riverview.sims3pack': makePack('riverview.sims3pack',
          [_Entry('0xworld.package', 'world', 'the world')],
          displayName: 'Riverview').readAsBytesSync(),
    });

    await expectLater(
      adapter.installArchive(modsDir, zip),
      throwsA(isA<ModContentException>()
          .having((e) => e.detail.key, 'key', 'sims3PackWorld')),
    );
  });

  test('unpacks the containers a dropped folder holds', () async {
    // The same download, unzipped by the user first - which is what half
    // of them do.
    final dropped = Directory(p.join(sourceDir.path, 'Comfy Sofa'))
      ..createSync();
    makePack('sage.sims3pack', [_Entry('0xaaa.package', 'object', 'a sofa')],
            displayName: 'Sage')
        .renameSync(p.join(dropped.path, 'Sage.sims3pack'));

    final mods = await adapter.installFolder(modsDir, dropped);

    expect(mods.map((m) => m.name), ['Sage.package']);
    expect(
        File(p.join(modsDir.path, 'Comfy Sofa', 'Sage.package'))
            .readAsStringSync(),
        'a sofa');
  });

  test('a game without a container of its own skips one', () async {
    // Nothing but The Sims 3 has anything to do with these, and a
    // sims3pack sitting in the Sims 4 Mods folder is a file the game
    // never reads and the library never lists.
    final zip = makeZip('bundle.zip', {
      'cc.sims3pack': makePack('cc.sims3pack',
          [_Entry('0xaaa.package', 'object', 'a sofa')]).readAsBytesSync(),
    });

    expect(const Sims4Adapter().nestedContainerExtensions, isEmpty);
    await expectLater(
      const Sims4Adapter().installArchive(modsDir, zip),
      throwsA(isA<ModContentException>()
          .having((e) => e.detail.key, 'key', 'noModFiles')),
    );
  });

  test('a zip still installs the ordinary way', () async {
    // The override must only take the sims3pack branch for sims3packs.
    final notAPack = File(p.join(sourceDir.path, 'bundle.zip'))
      ..writeAsStringSync('not really a zip');

    await expectLater(
      adapter.installArchive(modsDir, notAPack),
      throwsA(isA<ModContentException>()
          .having((e) => e.detail.key, 'key', 'unreadableArchive')),
    );
  });
}
