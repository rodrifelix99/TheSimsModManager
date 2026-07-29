import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims_adapters.dart';

import 'dbpf_fixtures.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('pkg_insight');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  File write(String name, List<int> bytes) =>
      File(p.join(tempDir.path, name))..writeAsBytesSync(bytes);

  test('finds an uncompressed PNG resource in a v2 package', () {
    final png = fakePng(64, 64);
    final file = write(
      'a.package',
      buildV2Package([Res(0x12345678, junk), Res(0x00000001, png)]),
    );
    expect(scanPackage(file)?.thumbnail, png);
  });

  test('picks the highest-resolution image, not the first found', () {
    final small = fakePng(32, 32);
    final large = fakePng(256, 256);
    final file = write(
      'b.package',
      buildV2Package([
        // Small thumb in a preferred thumbnail type, probed first…
        Res(0x3C1AF1F2, small),
        // …but a sharper image elsewhere must win.
        Res(0x12345678, large),
      ]),
    );
    expect(scanPackage(file)?.thumbnail, large);
  });

  test('measures JPEG dimensions too', () {
    final small = fakeJpeg(48, 48);
    final large = fakeJpeg(300, 200);
    final file = write(
      'c.package',
      buildV2Package([Res(0x00000001, small), Res(0x00000002, large)]),
    );
    expect(scanPackage(file)?.thumbnail, large);
  });

  test('inflates a zlib-compressed Sims 4 thumbnail resource', () {
    final jpeg = fakeJpeg(128, 128);
    final file = write(
      'd.package',
      buildV2Package([
        Res(0x12345678, junk),
        Res(0x3C1AF1F2, Uint8List.fromList(zlib.encode(jpeg)),
            compression: 0x5A42),
      ]),
    );
    expect(scanPackage(file)?.thumbnail, jpeg);
  });

  test('decodes a RefPack-compressed Sims 3 icon resource', () {
    final png = fakePng(96, 96);
    final file = write(
      'e.package',
      buildV2Package([
        Res(0x2F7D0004, refpackLiterals(png), compression: 0xFFFF),
      ]),
    );
    expect(scanPackage(file)?.thumbnail, png);
  });

  test('sniffs RefPack with size prefix in a v1 (Sims 2) package', () {
    final jpeg = fakeJpeg(80, 80);
    final file = write(
      'f.package',
      buildV1Package([
        Res(0x12345678, junk),
        Res(0x856DDBAC, refpackLiterals(jpeg, sizePrefix: true)),
      ]),
    );
    expect(scanPackage(file)?.thumbnail, jpeg);
  });

  test('summarizes recognized content types, largest first', () {
    final file = write(
      'g.package',
      buildV2Package([
        Res(0x034AEECB, junk), // CASP
        Res(0x034AEECB, junk), // CASP
        Res(0x3453CF95, junk), // RLE2 texture
        Res(0x0333406C, junk), // tuning
        Res(0x0333406C, junk), // tuning
        Res(0x0333406C, junk), // tuning
        Res(0xDEADBEEF, junk), // unknown: counted only in the total
      ]),
    );
    final insight = scanPackage(file)!;
    expect(insight.resourceCount, 7);
    expect(insight.contents,
        {'tunings': 3, 'CAS parts': 2, 'textures': 1});
    expect(insight.contents.keys.first, 'tunings');
    expect(insight.thumbnail, isNull);
  });

  test('collects resource keys (type/group/instance) from a v2 index', () {
    final file = write(
      'keys_v2.package',
      buildV2Package([
        Res(0x034AEECB, junk,
            group: 0x00000001, instance: 0x1234567890ABCDEF),
        Res(0x0333406C, junk, group: 0x80000000, instance: 42),
      ]),
    );
    expect(scanPackage(file)!.keys, [
      const ResourceKey(0x034AEECB, 0x00000001, 0x1234567890ABCDEF),
      const ResourceKey(0x0333406C, 0x80000000, 42),
    ]);
  });

  test('reads keys from a v2 index with constant hoisted fields', () {
    final file = write(
      'keys_const.package',
      buildV2ConstPackage(
        type: 0x034AEECB,
        group: 0x00000002,
        instanceHigh: 0x000000AB,
        instanceLows: [0x11, 0x22],
      ),
    );
    expect(scanPackage(file)!.keys, [
      const ResourceKey(0x034AEECB, 0x00000002, 0x000000AB00000011),
      const ResourceKey(0x034AEECB, 0x00000002, 0x000000AB00000022),
    ]);
  });

  test('collects keys from a v1 (Sims 2) index', () {
    final file = write(
      'keys_v1.package',
      buildV1Package([
        Res(0x42484156, junk, group: 0x7F01EC29, instance: 0x1000),
      ]),
    );
    expect(scanPackage(file)!.keys,
        [const ResourceKey(0x42484156, 0x7F01EC29, 0x1000)]);
  });

  test('v1 index-7.2 entries combine both instance halves', () {
    final file = write(
      'keys_v1_72.package',
      buildV1Package(
        [Res(0x42484156, junk, group: 0x7F01EC29, instance: 0xCAFE00001000)],
        longIndex: true,
      ),
    );
    expect(scanPackage(file)!.keys,
        [const ResourceKey(0x42484156, 0x7F01EC29, 0xCAFE00001000)]);
  });

  test('refuses a header claiming an index the file cannot hold', () {
    // Regression: the index size and entry count come straight out of the
    // file, and the index is read in one allocation. A truncated download
    // or a foreign format opening with 'DBPF' could ask for gigabytes -
    // and an out-of-memory kills the process outright, it is not an
    // exception scanPackage could swallow.
    final good = buildV2Package([Res(0x00000001, fakePng(64, 64))]);
    expect(scanPackage(write('sane.package', good))?.thumbnail, isNotNull);

    void patch(Uint8List bytes, int offset, int value) {
      ByteData.sublistView(bytes).setUint32(offset, value, Endian.little);
    }

    final hugeIndex = Uint8List.fromList(good);
    patch(hugeIndex, 44, 0xFFFFFFF0); // index size
    expect(scanPackage(write('huge_index.package', hugeIndex)), isNull);

    final hugeCount = Uint8List.fromList(good);
    patch(hugeCount, 36, 0xFFFFFFF0); // entry count
    expect(scanPackage(write('huge_count.package', hugeCount)), isNull);

    final wildOffset = Uint8List.fromList(good);
    patch(wildOffset, 64, 0xFFFFFFF0); // v2 index offset
    expect(scanPackage(write('wild_offset.package', wildOffset)), isNull);
  });

  test('drops the resource keys of a package with too many resources', () {
    // Merged collections carry tens of thousands of resources, and the
    // insight cache holds one entry per mod for the whole session.
    final many = [
      for (var i = 0; i < PackageInsight.maxRetainedKeys + 1; i++)
        Res(0x0333406C, junk, instance: i),
    ];
    final insight = scanPackage(write('merged.package', buildV2Package(many)))!;

    expect(insight.resourceCount, PackageInsight.maxRetainedKeys + 1);
    expect(insight.keys, isEmpty);
  });

  test('ignores an image too big to be a thumbnail', () {
    // A 300 KB blob is a texture sheet, not a preview; keeping one per mod
    // is what a 45,000-package library cannot afford.
    final huge = Uint8List.fromList([
      ...fakePng(2048, 2048),
      ...List.filled(300 << 10, 0x55),
    ]);
    final small = fakeJpeg(64, 64);
    final file = write(
      'oversized.package',
      buildV2Package([Res(0x00000001, huge), Res(0x00000002, small)]),
    );

    expect(scanPackage(file)?.thumbnail, small);
  });

  test('returns null for non-DBPF and truncated files', () {
    expect(scanPackage(write('h.package', 'not a dbpf'.codeUnits)), isNull);
    expect(scanPackage(write('i.package', [0x44, 0x42])), isNull);
    expect(scanPackage(File(p.join(tempDir.path, 'missing.package'))), isNull);
  });

  test('inspectMods scans in bulk, keyed by path, with progress', () async {
    const adapter = Sims1Adapter();
    final bmp = [0x42, 0x4D, 1, 2, 3, 4]; // 'BM' + junk
    final bmpFile = write('skin.bmp', bmp);
    final iffFile = write('object.iff', 'IFF data'.codeUnits);
    final mods = [
      Mod(name: 'skin.bmp', path: bmpFile.path, status: ModStatus.enabled),
      Mod(name: 'object.iff', path: iffFile.path, status: ModStatus.enabled),
    ];

    final progress = <(int, int)>[];
    final results = await adapter.inspectMods(mods,
        onProgress: (done, total) => progress.add((done, total)));

    expect(results[bmpFile.path]?.thumbnail, bmp);
    // The .iff yields nothing and is simply absent.
    expect(results.containsKey(iffFile.path), isFalse);
    expect(progress.last, (2, 2));
  });

  test('inspectMods streams discoveries through onFound as batches land',
      () async {
    const adapter = Sims1Adapter();
    final bmp = [0x42, 0x4D, 1, 2, 3, 4];
    final bmpFile = write('skin.bmp', bmp);
    final mods = [
      Mod(name: 'skin.bmp', path: bmpFile.path, status: ModStatus.enabled),
    ];

    final streamed = <String, PackageInsight>{};
    final results = await adapter.inspectMods(mods,
        onFound: (found) => streamed.addAll(found));

    expect(streamed[bmpFile.path]?.thumbnail, bmp);
    expect(streamed, results);
  });

  test('inspectMods stops early when isCancelled flips true', () async {
    const adapter = Sims1Adapter();
    // More files than one batch (8) so there is work left to cancel.
    final mods = [
      for (var i = 0; i < 40; i++)
        () {
          final file = write('skin$i.bmp', [0x42, 0x4D, i]);
          return Mod(
              name: 'skin$i.bmp', path: file.path, status: ModStatus.enabled);
        }(),
    ];

    var cancelled = false;
    final results = await adapter.inspectMods(mods,
        onProgress: (done, total) => cancelled = true,
        isCancelled: () => cancelled);

    // The first wave of batches lands, then the workers stop scheduling:
    // some files must remain unscanned.
    expect(results, isNotEmpty);
    expect(results.length, lessThan(mods.length));
  });

  test('inspectMods still works when onProgress captures unsendable state',
      () async {
    // Regression test: the scan isolate's closure must not drag the
    // caller's context along. In the app, onProgress closes over the
    // AppController (and through its listeners, the widget tree); if
    // that context leaks into the isolate message, every batch fails
    // and no artwork ever loads.
    const adapter = Sims1Adapter();
    final bmp = [0x42, 0x4D, 1, 2, 3, 4];
    final bmpFile = write('skin.bmp', bmp);
    final mods = [
      Mod(name: 'skin.bmp', path: bmpFile.path, status: ModStatus.enabled),
    ];

    final port = ReceivePort(); // unsendable across isolates
    addTearDown(port.close);
    final results = await adapter.inspectMods(mods, onProgress: (done, total) {
      // Reference the port so the callback's context holds it.
      expect(port.hashCode, isNotNull);
    });
    expect(results[bmpFile.path]?.thumbnail, bmp);
  });

  test('inspectMods survives unreadable files and empty input', () async {
    const adapter = Sims1Adapter();
    final mods = [
      Mod(
          name: 'gone.bmp',
          path: p.join(tempDir.path, 'gone.bmp'),
          status: ModStatus.enabled),
    ];
    expect(await adapter.inspectMods(mods), isEmpty);
    expect(await adapter.inspectMods(const []), isEmpty);
  });
}
