import 'dart:io';
import 'dart:typed_data';

/// Best-effort extraction of embedded artwork from a DBPF `.package` file.
///
/// Every Sims 2/3/4 mod is a DBPF archive: a header, a run of resource
/// blobs, and an index describing each blob (type/group/instance, offset,
/// size, compression). Custom content very often carries its own artwork
/// in there — Sims 4 CAS/Build-Buy thumbnails written by creator tools,
/// Sims 3 store-style PNG icons, Sims 2 Body Shop images — so the manager
/// can show the real thing instead of placeholder art.
///
/// The approach is deliberately forgiving: parse the index, walk resources
/// (known thumbnail types first, then everything else smallest-first),
/// undo the archive's compression, and return the first blob that starts
/// with a PNG or JPEG signature. Anything unreadable — not a DBPF file,
/// truncated, exotic compression — yields `null` and the UI falls back to
/// generated art. Never throws.
///
/// Synchronous on purpose: callers run it off the UI thread (the adapter
/// uses an isolate), and widget tests need file IO that can't leave a
/// handle dangling in their fake-async zone.
Uint8List? extractPackageThumbnail(File file) {
  RandomAccessFile? raf;
  try {
    raf = file.openSync();
    return _extract(raf);
  } catch (_) {
    return null;
  } finally {
    try {
      raf?.closeSync();
    } catch (_) {}
  }
}

/// DBPF resource types that hold thumbnails/icons in some Sims game.
/// Probed first; a wrong or missing type is harmless because every blob
/// is verified by its image signature before being returned.
const _thumbnailTypes = <int>{
  // The Sims 4 thumbnail resources (JPEG with alpha, per s4pi).
  0x3C1AF1F2, 0x5B282D45, 0xCD9DE247, 0xE254AE6E,
  0x0D338A3A, 0x16CCF748, 0x3BD45407, 0xE18CAEE2,
  // The Sims 3 PNG icons and thumbnails.
  0x2F7D0004, 0x2E75C764, 0x626F60CD, 0x626F60CE,
  // The Sims 2 jpg/tga/png image resource (Body Shop previews).
  0x856DDBAC,
};

/// The Sims 2 DIR resource listing compressed entries — never an image.
const _dirResourceType = 0xE86B1EEF;

/// Ignore blobs bigger than this even decompressed — thumbnails are small,
/// anything larger is a texture or mesh not worth reading into memory.
const _maxResourceBytes = 8 << 20;

/// How many non-thumbnail-typed resources to probe before giving up.
const _maxProbes = 512;

class _Entry {
  _Entry(this.type, this.offset, this.fileSize, this.memSize, this.compression);

  final int type;
  final int offset;
  final int fileSize;
  final int memSize;

  /// DBPF v2 compression id (0x0000 none, 0x5A42 zlib, 0xFFFF RefPack),
  /// or `null` for v1 archives where compression is sniffed per blob.
  final int? compression;

  int get probeSize => memSize > 0 ? memSize : fileSize;
}

Uint8List? _extract(RandomAccessFile raf) {
  final header = _readAt(raf, 0, 96);
  if (header.length < 96) return null;
  if (header[0] != 0x44 || header[1] != 0x42 || // 'DBPF'
      header[2] != 0x50 ||
      header[3] != 0x46) {
    return null;
  }
  final d = ByteData.sublistView(header);
  final major = d.getUint32(4, Endian.little);
  final entryCount = d.getUint32(36, Endian.little);
  final indexOffsetV1 = d.getUint32(40, Endian.little);
  final indexSize = d.getUint32(44, Endian.little);
  final indexOffsetV2 = d.getUint32(64, Endian.little);
  if (entryCount == 0 || indexSize == 0) return null;

  final indexOffset =
      major >= 2 && indexOffsetV2 != 0 ? indexOffsetV2 : indexOffsetV1;
  final index = _readAt(raf, indexOffset, indexSize);
  if (index.length < indexSize) return null;
  final entries = major >= 2
      ? _parseIndexV2(index, entryCount)
      : _parseIndexV1(index, entryCount);

  // Known thumbnail types first (in file order), then the rest smallest
  // first — small blobs are far more likely to be icons than textures.
  final preferred = <_Entry>[];
  final rest = <_Entry>[];
  for (final e in entries) {
    if (e.type == _dirResourceType) continue;
    if (e.fileSize < 16 || e.fileSize > _maxResourceBytes) continue;
    if (e.memSize > _maxResourceBytes) continue;
    (_thumbnailTypes.contains(e.type) ? preferred : rest).add(e);
  }
  rest.sort((a, b) => a.probeSize.compareTo(b.probeSize));

  var probes = 0;
  for (final e in [...preferred, ...rest]) {
    if (probes++ >= _maxProbes) break;
    final raw = _readAt(raf, e.offset, e.fileSize);
    if (raw.length < e.fileSize) continue;
    final data = _decompress(raw, e.compression);
    if (data == null) continue;
    if (_isPng(data) || _isJpeg(data)) return data;
  }
  return null;
}

/// DBPF v2 index (Sims 3/4): a flags word marks TGI fields that are
/// constant across all entries and hoisted out of the per-entry records.
List<_Entry> _parseIndexV2(Uint8List index, int count) {
  final d = ByteData.sublistView(index);
  final entries = <_Entry>[];
  try {
    var pos = 0;
    final flags = d.getUint32(pos, Endian.little);
    pos += 4;
    int? constType;
    if (flags & 1 != 0) {
      constType = d.getUint32(pos, Endian.little);
      pos += 4;
    }
    if (flags & 2 != 0) pos += 4; // constant group
    if (flags & 4 != 0) pos += 4; // constant instance-high
    for (var i = 0; i < count; i++) {
      int type;
      if (constType != null) {
        type = constType;
      } else {
        type = d.getUint32(pos, Endian.little);
        pos += 4;
      }
      if (flags & 2 == 0) pos += 4; // group
      if (flags & 4 == 0) pos += 4; // instance-high
      pos += 4; // instance-low
      final offset = d.getUint32(pos, Endian.little);
      pos += 4;
      final fileSizeRaw = d.getUint32(pos, Endian.little);
      pos += 4;
      final memSize = d.getUint32(pos, Endian.little);
      pos += 4;
      var compression = 0;
      if (fileSizeRaw & 0x80000000 != 0) {
        compression = d.getUint16(pos, Endian.little);
        pos += 4; // compression id + "committed" flag
      }
      entries.add(_Entry(
          type, offset, fileSizeRaw & 0x7FFFFFFF, memSize, compression));
    }
  } catch (_) {
    // Truncated or malformed index: keep whatever parsed cleanly.
  }
  return entries;
}

/// DBPF v1 index (Sims 2): fixed-size records — 20 bytes, or 24 when the
/// index version adds a resource id. Compression isn't in the index (it
/// lives in the DIR resource), so entries sniff it per blob instead.
List<_Entry> _parseIndexV1(Uint8List index, int count) {
  final entrySize = index.length ~/ count;
  if (entrySize != 20 && entrySize != 24) return const [];
  final d = ByteData.sublistView(index);
  final entries = <_Entry>[];
  for (var i = 0; i < count; i++) {
    final base = i * entrySize;
    entries.add(_Entry(
      d.getUint32(base, Endian.little),
      d.getUint32(base + entrySize - 8, Endian.little),
      d.getUint32(base + entrySize - 4, Endian.little),
      0,
      null,
    ));
  }
  return entries;
}

Uint8List? _decompress(Uint8List raw, int? compression) {
  try {
    switch (compression) {
      case 0x0000:
        return raw;
      case 0x5A42: // zlib (Sims 4)
        return Uint8List.fromList(zlib.decode(raw));
      case 0xFFFF: // RefPack (Sims 3)
      case 0xFFFE:
        return _refpackDecode(raw);
      case null: // Sims 2: sniff RefPack, else assume stored as-is.
        return _refpackDecode(raw) ?? raw;
      default:
        return null;
    }
  } catch (_) {
    return null;
  }
}

bool _isRefpackHeader(Uint8List b, int pos) =>
    b.length > pos + 1 && (b[pos] & 0x3E) == 0x10 && b[pos + 1] == 0xFB;

/// EA RefPack (QFS) decompressor. Accepts the bare stream and the Sims 2
/// variant with a 4-byte compressed-size prefix. Returns `null` when the
/// data isn't RefPack or doesn't decode cleanly.
Uint8List? _refpackDecode(Uint8List src) {
  var pos = 0;
  if (!_isRefpackHeader(src, 0)) {
    if (_isRefpackHeader(src, 4)) {
      pos = 4; // compressed-size prefix
    } else {
      return null;
    }
  }
  final flags = src[pos];
  pos += 2; // flags byte + 0xFB magic
  final sizeBytes = (flags & 0x80) != 0 ? 4 : 3;
  if (flags & 0x01 != 0) pos += sizeBytes; // embedded compressed size
  var size = 0;
  for (var i = 0; i < sizeBytes; i++) {
    if (pos >= src.length) return null;
    size = (size << 8) | src[pos++];
  }
  if (size <= 0 || size > _maxResourceBytes) return null;

  final out = Uint8List(size);
  var op = 0;

  bool literal(int n) {
    if (pos + n > src.length || op + n > size) return false;
    out.setRange(op, op + n, src, pos);
    pos += n;
    op += n;
    return true;
  }

  bool backCopy(int n, int offset) {
    var from = op - offset;
    if (from < 0 || op + n > size) return false;
    for (var i = 0; i < n; i++) {
      out[op++] = out[from++];
    }
    return true;
  }

  while (pos < src.length) {
    final b0 = src[pos++];
    if (b0 < 0x80) {
      if (pos + 1 > src.length) return null;
      final b1 = src[pos++];
      if (!literal(b0 & 0x03)) return null;
      if (!backCopy(((b0 & 0x1C) >> 2) + 3, ((b0 & 0x60) << 3) + b1 + 1)) {
        return null;
      }
    } else if (b0 < 0xC0) {
      if (pos + 2 > src.length) return null;
      final b1 = src[pos++], b2 = src[pos++];
      if (!literal((b1 >> 6) & 0x03)) return null;
      if (!backCopy((b0 & 0x3F) + 4, ((b1 & 0x3F) << 8) + b2 + 1)) {
        return null;
      }
    } else if (b0 < 0xE0) {
      if (pos + 3 > src.length) return null;
      final b1 = src[pos++], b2 = src[pos++], b3 = src[pos++];
      if (!literal(b0 & 0x03)) return null;
      if (!backCopy(((b0 & 0x0C) << 6) + b3 + 5,
          ((b0 & 0x10) << 12) + (b1 << 8) + b2 + 1)) {
        return null;
      }
    } else if (b0 < 0xFC) {
      if (!literal(((b0 & 0x1F) + 1) << 2)) return null;
    } else {
      if (!literal(b0 & 0x03)) return null;
      break; // stop code
    }
  }
  return op == size ? out : null;
}

bool _isPng(Uint8List b) =>
    b.length >= 8 &&
    b[0] == 0x89 &&
    b[1] == 0x50 &&
    b[2] == 0x4E &&
    b[3] == 0x47 &&
    b[4] == 0x0D &&
    b[5] == 0x0A &&
    b[6] == 0x1A &&
    b[7] == 0x0A;

bool _isJpeg(Uint8List b) =>
    b.length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF;

Uint8List _readAt(RandomAccessFile raf, int offset, int length) {
  raf.setPositionSync(offset);
  return raf.readSync(length);
}
