import 'dart:io';
import 'dart:typed_data';

import 'dbpf.dart';

/// Writing DBPF archives back out, which the app does for exactly one
/// reason: [save_edit.dart] changing a household inside a save.
///
/// The counterpart of [readDbpfIndex], and deliberately a much smaller
/// thing. It never builds an archive from nothing - it is handed the
/// archive that is already on disk and rewrites it with one resource
/// swapped, so all it has to get right is the header, the resource
/// blobs and the index. Everything else about the file, including the
/// bytes of every resource nobody asked about, is copied through.
///
/// Two index layouts, the same two the reader knows: v1 (Sims 2, fixed
/// records and compression recorded in a DIR resource of its own) and
/// v2 (Sims 4, per-entry compression and constant TGI fields hoisted out
/// of the records).

/// One resource on its way into an archive: where it belongs in the
/// index, and the exact bytes to store.
///
/// [bytes] is what lands on disk, compressed or not - the writer never
/// compresses anything itself. [memSize] is what those bytes come back
/// as, which is [bytes].length for a resource stored plainly and the
/// decompressed length for one carried through untouched.
class DbpfResource {
  const DbpfResource({
    required this.type,
    required this.group,
    required this.instance,
    required this.bytes,
    this.compression = 0,
    int? memSize,
    this.committed = 1,
  }) : _memSize = memSize;

  /// Everything about [entry] except its bytes, for a resource being
  /// carried through an edit unchanged.
  factory DbpfResource.copying(DbpfEntry entry, Uint8List raw) => DbpfResource(
        type: entry.type,
        group: entry.group,
        instance: entry.instance,
        bytes: raw,
        compression: entry.compression ?? 0,
        memSize: entry.memSize,
      );

  final int type;
  final int group;
  final int instance;
  final Uint8List bytes;

  /// The id the index records: 0 stored plainly, 0x5A42 zlib, 0xFFFF
  /// RefPack. For a v1 archive it is not written at all - see the DIR
  /// resource - and only says whether [bytes] are already compressed.
  final int compression;

  final int committed;
  final int? _memSize;

  int get memSize => _memSize ?? bytes.length;
}

/// Reads every resource of [raf] out verbatim, ready to be handed back
/// to a writer with one of them replaced. The bytes are the stored ones,
/// compression and all, so a resource nobody is editing costs nothing to
/// keep and cannot be damaged by a decompressor this app wrote.
List<DbpfResource> readDbpfVerbatim(
    RandomAccessFile raf, List<DbpfEntry> entries) {
  return [
    for (final entry in entries)
      DbpfResource.copying(entry, readAt(raf, entry.offset, entry.fileSize)),
  ];
}

/// Rewrites a DBPF v1 archive (Sims 2). [header] is the original file's
/// first 96 bytes, carried through so every field this doesn't
/// understand keeps its value; [entryBytes] is the index record size the
/// file was already using, 20 or 24.
///
/// The hole table is dropped (its three header fields are zeroed): holes
/// are free space left by an in-place edit, and a file written from
/// scratch has none.
Uint8List writeDbpfV1(
    Uint8List header, int entryBytes, List<DbpfResource> resources) {
  if (entryBytes != 20 && entryBytes != 24) {
    throw ArgumentError('unsupported DBPF v1 index record size: $entryBytes');
  }
  final out = _Sink(header);
  final offsets = out.writeResources(resources);

  final indexOffset = out.length;
  final index = BytesBuilder();
  final record = ByteData(entryBytes);
  for (var i = 0; i < resources.length; i++) {
    final r = resources[i];
    record.setUint32(0, r.type, Endian.little);
    record.setUint32(4, r.group, Endian.little);
    record.setUint32(8, r.instance & 0xFFFFFFFF, Endian.little);
    if (entryBytes == 24) {
      record.setUint32(12, (r.instance >> 32) & 0xFFFFFFFF, Endian.little);
    }
    record.setUint32(entryBytes - 8, offsets[i], Endian.little);
    record.setUint32(entryBytes - 4, r.bytes.length, Endian.little);
    index.add(record.buffer.asUint8List());
  }
  out.add(index.takeBytes());

  out.patchHeader(
    entryCount: resources.length,
    indexOffset: indexOffset,
    indexSize: resources.length * entryBytes,
    indexOffsetField: 40,
  );
  // Hole count, offset and size.
  out.setHeaderUint32(48, 0);
  out.setHeaderUint32(52, 0);
  out.setHeaderUint32(56, 0);
  return out.takeBytes();
}

/// Rewrites a DBPF v2 archive (Sims 4). The index's constant-field
/// hoisting is recomputed rather than remembered: whichever of type,
/// group and the instance's high half turn out to be the same across
/// every resource are written once at the top, which is what the game's
/// own writer does and what keeps the file the size it was.
Uint8List writeDbpfV2(Uint8List header, List<DbpfResource> resources) {
  if (resources.isEmpty) throw ArgumentError('a DBPF needs at least one entry');
  final out = _Sink(header);
  final offsets = out.writeResources(resources);

  final first = resources.first;
  final constType =
      resources.every((r) => r.type == first.type) ? first.type : null;
  final constGroup =
      resources.every((r) => r.group == first.group) ? first.group : null;
  final firstHigh = (first.instance >> 32) & 0xFFFFFFFF;
  final constHigh = resources.every((r) => (r.instance >> 32) & 0xFFFFFFFF == firstHigh)
      ? firstHigh
      : null;

  final index = BytesBuilder();
  void word(int value) {
    final b = ByteData(4)..setUint32(0, value, Endian.little);
    index.add(b.buffer.asUint8List());
  }

  word((constType != null ? 1 : 0) |
      (constGroup != null ? 2 : 0) |
      (constHigh != null ? 4 : 0));
  if (constType != null) word(constType);
  if (constGroup != null) word(constGroup);
  if (constHigh != null) word(constHigh);

  for (var i = 0; i < resources.length; i++) {
    final r = resources[i];
    if (constType == null) word(r.type);
    if (constGroup == null) word(r.group);
    if (constHigh == null) word((r.instance >> 32) & 0xFFFFFFFF);
    word(r.instance & 0xFFFFFFFF);
    word(offsets[i]);
    // The high bit says a compression word follows. The game writes one
    // on every entry, plainly stored resources included (they carry
    // 0x0000), so this does too: an index of uniform records is what a
    // save's own reader has always been handed.
    word(r.bytes.length | 0x80000000);
    word(r.memSize);
    final tail = ByteData(4)
      ..setUint16(0, r.compression, Endian.little)
      ..setUint16(2, r.committed, Endian.little);
    index.add(tail.buffer.asUint8List());
  }

  final indexOffset = out.length;
  final indexBytes = index.takeBytes();
  out.add(indexBytes);
  out.patchHeader(
    entryCount: resources.length,
    indexOffset: indexOffset,
    indexSize: indexBytes.length,
    indexOffsetField: 64,
  );
  out.setHeaderUint32(40, 0); // the v1 index offset, unused here
  return out.takeBytes();
}

/// The file being built: the original header, then whatever is added
/// after it, with the header patched once the offsets are known.
class _Sink {
  _Sink(Uint8List header) : _header = Uint8List.fromList(header) {
    if (_header.length < 96) {
      throw ArgumentError('a DBPF header is 96 bytes, got ${_header.length}');
    }
    _body = BytesBuilder();
  }

  final Uint8List _header;
  late final BytesBuilder _body;

  int get length => _header.length + _body.length;

  void add(Uint8List bytes) => _body.add(bytes);

  /// Writes every resource back to back and returns where each landed.
  List<int> writeResources(List<DbpfResource> resources) {
    final offsets = <int>[];
    for (final r in resources) {
      offsets.add(length);
      _body.add(r.bytes);
    }
    return offsets;
  }

  void setHeaderUint32(int at, int value) =>
      ByteData.sublistView(_header).setUint32(at, value, Endian.little);

  void patchHeader({
    required int entryCount,
    required int indexOffset,
    required int indexSize,
    required int indexOffsetField,
  }) {
    setHeaderUint32(36, entryCount);
    setHeaderUint32(44, indexSize);
    setHeaderUint32(indexOffsetField, indexOffset);
  }

  Uint8List takeBytes() {
    final out = BytesBuilder()
      ..add(_header)
      ..add(_body.takeBytes());
    return out.takeBytes();
  }
}
