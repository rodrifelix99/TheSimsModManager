import 'dart:typed_data';

/// Builders for hand-rolled DBPF archives and image blobs, shared by the
/// package-insight tests and the save-scanner tests: both need packages
/// with exact contents, and neither wants a second copy of the byte
/// plumbing.

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
  Res(this.type, this.data,
      {this.compression = 0, this.group = 0, this.instance});

  final int type;
  final Uint8List data; // already compressed when [compression] != 0
  final int compression; // DBPF v2 compression id
  final int group;
  final int? instance; // 64-bit; defaults to the entry's index
}

void u32(BytesBuilder b, int v) {
  b.add([v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, (v >> 24) & 0xFF]);
}

void u16(BytesBuilder b, int v) {
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
  u32(index, 0); // flags: nothing constant
  for (var i = 0; i < resources.length; i++) {
    final r = resources[i];
    final instance = r.instance ?? i;
    u32(index, r.type);
    u32(index, r.group);
    u32(index, instance >> 32); // instance hi
    u32(index, instance & 0xFFFFFFFF); // instance lo
    u32(index, offsets[i]);
    u32(index, r.data.length | 0x80000000); // extended: compression follows
    u32(index, r.data.length * 2); // memSize (any plausible value)
    u16(index, r.compression);
    u16(index, 1); // committed
  }
  final indexBytes = index.toBytes();

  final b = BytesBuilder();
  b.add('DBPF'.codeUnits);
  u32(b, 2); // major
  u32(b, 1); // minor
  b.add(Uint8List(36 - 12));
  u32(b, resources.length); // 36: entry count
  u32(b, 0); // 40: v1 index offset
  u32(b, indexBytes.length); // 44: index size
  b.add(Uint8List(64 - 48));
  u32(b, 96 + blobs.length); // 64: index offset
  b.add(Uint8List(96 - 68));
  assert(b.length == 96);
  b.add(blobs.toBytes());
  b.add(indexBytes);
  return b.toBytes();
}

/// Minimal DBPF v1 package (Sims 2 layout): 20-byte index entries, no
/// compression info in the index. [longIndex] switches to the 24-byte
/// index-7.2 entries carrying a second (high) instance half.
Uint8List buildV1Package(List<Res> resources, {bool longIndex = false}) {
  final blobs = BytesBuilder();
  final offsets = <int>[];
  for (final r in resources) {
    offsets.add(96 + blobs.length);
    blobs.add(r.data);
  }

  final index = BytesBuilder();
  for (var i = 0; i < resources.length; i++) {
    final r = resources[i];
    final instance = r.instance ?? i;
    u32(index, r.type);
    u32(index, r.group);
    u32(index, instance & 0xFFFFFFFF);
    if (longIndex) u32(index, instance >> 32);
    u32(index, offsets[i]);
    u32(index, r.data.length);
  }
  final indexBytes = index.toBytes();

  final b = BytesBuilder();
  b.add('DBPF'.codeUnits);
  u32(b, 1); // major
  u32(b, 1); // minor
  b.add(Uint8List(36 - 12));
  u32(b, resources.length); // 36: entry count
  u32(b, 96 + blobs.length); // 40: index offset (v1)
  u32(b, indexBytes.length); // 44: index size
  b.add(Uint8List(96 - 48));
  b.add(blobs.toBytes());
  b.add(indexBytes);
  return b.toBytes();
}

/// DBPF v2 package whose index hoists constant type/group/instance-high
/// fields out of the per-entry records (flags 0x7), the layout common in
/// real single-type Sims 4 CC. Entries hold [junk] and differ only in
/// their low instance half.
Uint8List buildV2ConstPackage({
  required int type,
  required int group,
  required int instanceHigh,
  required List<int> instanceLows,
}) {
  final blobs = BytesBuilder();
  final offsets = <int>[];
  for (var i = 0; i < instanceLows.length; i++) {
    offsets.add(96 + blobs.length);
    blobs.add(junk);
  }

  final index = BytesBuilder();
  u32(index, 7); // flags: type, group and instance-high are constant
  u32(index, type);
  u32(index, group);
  u32(index, instanceHigh);
  for (var i = 0; i < instanceLows.length; i++) {
    u32(index, instanceLows[i]);
    u32(index, offsets[i]);
    u32(index, junk.length); // no extended-size bit: uncompressed
    u32(index, junk.length);
  }
  final indexBytes = index.toBytes();

  final b = BytesBuilder();
  b.add('DBPF'.codeUnits);
  u32(b, 2); // major
  u32(b, 1); // minor
  b.add(Uint8List(36 - 12));
  u32(b, instanceLows.length); // 36: entry count
  u32(b, 0); // 40: v1 index offset
  u32(b, indexBytes.length); // 44: index size
  b.add(Uint8List(64 - 48));
  u32(b, 96 + blobs.length); // 64: index offset
  b.add(Uint8List(96 - 68));
  assert(b.length == 96);
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
  u32(prefixed, body.length + 4);
  prefixed.add(body);
  return prefixed.toBytes();
}
