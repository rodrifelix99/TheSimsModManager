import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_thumbnail.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims_adapters.dart';

/// Bytes that pass the extractor's PNG signature check. Only the magic
/// matters — nothing here decodes them as an actual image.
final fakePng = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG magic
  ...List.generate(64, (i) => i),
]);

final fakeJpeg = Uint8List.fromList([
  0xFF, 0xD8, 0xFF, 0xE0, // JPEG/JFIF magic
  ...List.generate(64, (i) => 255 - i),
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
  final header = BytesBuilder();
  header.add('DBPF'.codeUnits);
  _u32(header, 2); // major
  _u32(header, 1); // minor

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
  final rest = BytesBuilder();
  // Header fields after major/minor: pad to offset 36.
  rest.add(Uint8List(36 - 12));
  final b = BytesBuilder();
  b.add(header.toBytes());
  b.add(rest.toBytes());
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

/// RefPack-compresses [data] using literal runs only — enough to exercise
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
    tempDir = Directory.systemTemp.createTempSync('pkg_thumb');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  File write(String name, List<int> bytes) =>
      File(p.join(tempDir.path, name))..writeAsBytesSync(bytes);

  test('finds an uncompressed PNG resource in a v2 package', () async {
    final file = write(
      'a.package',
      buildV2Package([
        Res(0x12345678, junk),
        Res(0x00000001, fakePng),
      ]),
    );
    expect(extractPackageThumbnail(file), fakePng);
  });

  test('inflates a zlib-compressed Sims 4 thumbnail resource', () async {
    final file = write(
      'b.package',
      buildV2Package([
        Res(0x12345678, junk),
        // 0x3C1AF1F2 is a known TS4 thumbnail type — probed first.
        Res(0x3C1AF1F2, Uint8List.fromList(zlib.encode(fakeJpeg)),
            compression: 0x5A42),
      ]),
    );
    expect(extractPackageThumbnail(file), fakeJpeg);
  });

  test('decodes a RefPack-compressed Sims 3 icon resource', () async {
    final file = write(
      'c.package',
      buildV2Package([
        Res(0x2F7D0004, refpackLiterals(fakePng), compression: 0xFFFF),
      ]),
    );
    expect(extractPackageThumbnail(file), fakePng);
  });

  test('sniffs RefPack with size prefix in a v1 (Sims 2) package',
      () async {
    final file = write(
      'd.package',
      buildV1Package([
        Res(0x12345678, junk),
        Res(0x856DDBAC, refpackLiterals(fakeJpeg, sizePrefix: true)),
      ]),
    );
    expect(extractPackageThumbnail(file), fakeJpeg);
  });

  test('reads uncompressed blobs in a v1 package as-is', () async {
    final file = write(
      'e.package',
      buildV1Package([Res(0x00000002, fakePng)]),
    );
    expect(extractPackageThumbnail(file), fakePng);
  });

  test('returns null when the package has no image resources', () async {
    final file = write(
      'f.package',
      buildV2Package([Res(0x12345678, junk)]),
    );
    expect(extractPackageThumbnail(file), isNull);
  });

  test('returns null for non-DBPF and truncated files', () async {
    expect(
        extractPackageThumbnail(write('g.package', 'not a dbpf'.codeUnits)),
        isNull);
    expect(extractPackageThumbnail(write('h.package', [0x44, 0x42])),
        isNull);
    expect(
        extractPackageThumbnail(
            File(p.join(tempDir.path, 'missing.package'))),
        isNull);
  });

  test('adapter serves a Sims 1 .bmp mod file as its own thumbnail',
      () async {
    const adapter = Sims1Adapter();
    final bmp = [0x42, 0x4D, 1, 2, 3, 4]; // 'BM' + junk
    final file = write('skin.bmp', bmp);
    final mod = Mod(
        name: 'skin.bmp', path: file.path, status: ModStatus.enabled);
    expect(await adapter.loadThumbnail(mod), bmp);
  });

  test('adapter returns null for non-image, non-package mod files',
      () async {
    const adapter = Sims1Adapter();
    final file = write('object.iff', 'IFF data'.codeUnits);
    final mod = Mod(
        name: 'object.iff', path: file.path, status: ModStatus.enabled);
    expect(await adapter.loadThumbnail(mod), isNull);
  });
}
