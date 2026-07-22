import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims_adapters.dart';

/// A PNG header with a valid IHDR declaring [w]×[h], followed by junk.
/// Only the signature and dimensions matter; nothing decodes the pixels.
Uint8List fakePng(int w, int h) => Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG magic
      0, 0, 0, 13, 0x49, 0x48, 0x44, 0x52, // IHDR chunk header
      (w >> 24) & 0xFF, (w >> 16) & 0xFF, (w >> 8) & 0xFF, w & 0xFF,
      (h >> 24) & 0xFF, (h >> 16) & 0xFF, (h >> 8) & 0xFF, h & 0xFF,
      8, 6, 0, 0, 0, // bit depth, color type, etc.
      ...List.generate(48, (i) => i),
    ]);

/// A JPEG with an SOF0 frame declaring [w]×[h], followed by junk.
Uint8List fakeJpeg(int w, int h) => Uint8List.fromList([
      0xFF, 0xD8, // SOI
      0xFF, 0xC0, 0x00, 0x11, 0x08, // SOF0, length, precision
      (h >> 8) & 0xFF, h & 0xFF,
      (w >> 8) & 0xFF, w & 0xFF,
      ...List.generate(48, (i) => 255 - i),
    ]);

/// Non-image resource payload (pretend tuning/mesh data).
final junk = Uint8List.fromList(List.generate(80, (i) => (i * 7) & 0xFF));

class Res {
  Res(this.type, this.data, {this.compression = 0});

  final int type;
  final Uint8List data; // already compressed when [compression] != 0
  final int compression; // DBPF v2 compression id
}

void _u32(BytesBuilder b, int v) {
  b.add([v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, (v >> 24) & 0xFF]);
}

void _u16(BytesBuilder b, int v) {
  b.add([v & 0xFF, (v >> 8) & 0xFF]);
}

/// Minimal DBPF v2 package (Sims 3/4 layout): 96-byte header, resource
/// blobs, then an index with no constant-field flags.
Uint8List buildV2Package(List<Res> resources) {
  final blobs = BytesBuilder();
  final offsets = <int>[];
  for (final r in resources) {
    offsets.add(96 + blobs.length);
    blobs.add(r.data);
  }

  final index = BytesBuilder();
  _u32(index, 0); // flags: nothing constant
  for (var i = 0; i < resources.length; i++) {
    final r = resources[i];
    _u32(index, r.type);
    _u32(index, 0); // group
    _u32(index, 0); // instance hi
    _u32(index, i); // instance lo
    _u32(index, offsets[i]);
    _u32(index, r.data.length | 0x80000000); // extended: compression follows
    _u32(index, r.data.length * 2); // memSize (any plausible value)
    _u16(index, r.compression);
    _u16(index, 1); // committed
  }
  final indexBytes = index.toBytes();

  final b = BytesBuilder();
  b.add('DBPF'.codeUnits);
  _u32(b, 2); // major
  _u32(b, 1); // minor
  b.add(Uint8List(36 - 12));
  _u32(b, resources.length); // 36: entry count
  _u32(b, 0); // 40: v1 index offset
  _u32(b, indexBytes.length); // 44: index size
  b.add(Uint8List(64 - 48));
  _u32(b, 96 + blobs.length); // 64: index offset
  b.add(Uint8List(96 - 68));
  assert(b.length == 96);
  b.add(blobs.toBytes());
  b.add(indexBytes);
  return b.toBytes();
}

/// Minimal DBPF v1 package (Sims 2 layout): 20-byte index entries, no
/// compression info in the index.
Uint8List buildV1Package(List<Res> resources) {
  final blobs = BytesBuilder();
  final offsets = <int>[];
  for (final r in resources) {
    offsets.add(96 + blobs.length);
    blobs.add(r.data);
  }

  final index = BytesBuilder();
  for (var i = 0; i < resources.length; i++) {
    final r = resources[i];
    _u32(index, r.type);
    _u32(index, 0); // group
    _u32(index, i); // instance
    _u32(index, offsets[i]);
    _u32(index, r.data.length);
  }
  final indexBytes = index.toBytes();

  final b = BytesBuilder();
  b.add('DBPF'.codeUnits);
  _u32(b, 1); // major
  _u32(b, 1); // minor
  b.add(Uint8List(36 - 12));
  _u32(b, resources.length); // 36: entry count
  _u32(b, 96 + blobs.length); // 40: index offset (v1)
  _u32(b, indexBytes.length); // 44: index size
  b.add(Uint8List(96 - 48));
  b.add(blobs.toBytes());
  b.add(indexBytes);
  return b.toBytes();
}

/// RefPack-compresses [data] using literal runs only, enough to exercise
/// the decoder's header parsing, literal codes, and stop code.
Uint8List refpackLiterals(List<int> data, {bool sizePrefix = false}) {
  final out = BytesBuilder();
  out.add([0x10, 0xFB]);
  out.add([
    (data.length >> 16) & 0xFF,
    (data.length >> 8) & 0xFF,
    data.length & 0xFF,
  ]);
  var i = 0;
  while (data.length - i >= 4) {
    var chunk = (data.length - i) & ~3;
    if (chunk > 112) chunk = 112;
    out.addByte(0xE0 + (chunk ~/ 4) - 1);
    out.add(data.sublist(i, i + chunk));
    i += chunk;
  }
  final rem = data.length - i;
  out.addByte(0xFC + rem);
  out.add(data.sublist(i));
  final body = out.toBytes();
  if (!sizePrefix) return body;
  final prefixed = BytesBuilder();
  _u32(prefixed, body.length + 4);
  prefixed.add(body);
  return prefixed.toBytes();
}

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
