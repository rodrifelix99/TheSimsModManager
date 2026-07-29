import 'dart:io';
import 'dart:typed_data';

/// Reading DBPF archives, the container behind every Sims 2/3/4 file this
/// app opens: mod `.package`s, Sims 4 `.save`s, Sims 3 `Meta.data` and
/// world `.nhd`s. One reader for all of them - the index layouts (v1 for
/// Sims 2, v2 for Sims 3/4) and the compression schemes (RefPack, zlib,
/// per-blob sniffing) live here and nowhere else. `package_insight.dart`
/// scans mods with it; the save scanners in `src/games/` pull named
/// resources out with it.
///
/// Everything is best-effort and returns `null` rather than throwing:
/// these files come off the user's disk and can be truncated, half
/// written, or not DBPF at all.

/// One resource in a DBPF index: its type/group/instance identity plus
/// where its (possibly compressed) bytes sit in the file.
class DbpfEntry {
  const DbpfEntry(this.type, this.group, this.instance, this.offset,
      this.fileSize, this.memSize, this.compression);

  final int type;
  final int group;

  /// 64-bit instance (high and low halves combined).
  final int instance;

  final int offset;
  final int fileSize;
  final int memSize;

  /// DBPF v2 compression id (0x0000 none, 0x5A42 zlib, 0xFFFF RefPack),
  /// or `null` for v1 archives where compression is sniffed per blob.
  final int? compression;

  /// Best guess at the decompressed size, for smallest-first ordering.
  int get probeSize => memSize > 0 ? memSize : fileSize;
}

/// Ceiling on the output a compressed blob may declare before the
/// decompressor refuses it outright: the size is the blob's own claim.
/// Callers that legitimately expect more (a Sims 4 save's world blob)
/// pass their own limit.
const dbpfDefaultMaxResourceBytes = 8 << 20;

/// Biggest index a DBPF header may claim. A real one is a handful of
/// bytes per resource, so even a merged collection stays far below this;
/// the cap is there because the index is read in one allocation and the
/// size comes straight from the file's own header.
const _maxIndexBytes = 32 << 20;

/// Smallest DBPF index entry: a v2 record with type, group and the high
/// instance half all hoisted out as constants still carries four words.
const _minIndexEntryBytes = 16;

/// Parses [raf]'s DBPF header and index. Returns the entries, or `null`
/// when the file is not a DBPF archive or its header cannot be trusted
/// (truncated file, foreign format that happens to open with 'DBPF').
/// A malformed index tail costs the entries after it, not the whole read.
List<DbpfEntry>? readDbpfIndex(RandomAccessFile raf) {
  final header = readAt(raf, 0, 96);
  if (header.length < 96) return null;
  if (header[0] != 0x44 ||
      header[1] != 0x42 || // 'DBPF'
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
  // Nothing below reads the header's word for what it is without checking
  // it against the file first. A truncated download, a package another
  // tool half-wrote, or any format that happens to open with 'DBPF' can
  // claim a gigabyte-long index of four billion resources; the index is
  // read in a single allocation, and running out of memory takes the whole
  // process down - it is not an exception this function could catch.
  final fileLength = raf.lengthSync();
  if (indexOffset < 96 ||
      indexOffset >= fileLength ||
      indexSize > _maxIndexBytes ||
      indexSize > fileLength - indexOffset ||
      entryCount > indexSize ~/ _minIndexEntryBytes) {
    return null;
  }
  final index = readAt(raf, indexOffset, indexSize);
  if (index.length < indexSize) return null;
  final entries = major >= 2
      ? _parseIndexV2(index, entryCount)
      : _parseIndexV1(index, entryCount);
  return entries.isEmpty ? null : entries;
}

/// DBPF v2 index (Sims 3/4): a flags word marks TGI fields that are
/// constant across all entries and hoisted out of the per-entry records.
List<DbpfEntry> _parseIndexV2(Uint8List index, int count) {
  final d = ByteData.sublistView(index);
  final entries = <DbpfEntry>[];
  try {
    var pos = 0;
    final flags = d.getUint32(pos, Endian.little);
    pos += 4;
    int? constType;
    int? constGroup;
    int? constInstanceHigh;
    if (flags & 1 != 0) {
      constType = d.getUint32(pos, Endian.little);
      pos += 4;
    }
    if (flags & 2 != 0) {
      constGroup = d.getUint32(pos, Endian.little);
      pos += 4;
    }
    if (flags & 4 != 0) {
      constInstanceHigh = d.getUint32(pos, Endian.little);
      pos += 4;
    }
    for (var i = 0; i < count; i++) {
      int type;
      if (constType != null) {
        type = constType;
      } else {
        type = d.getUint32(pos, Endian.little);
        pos += 4;
      }
      int group;
      if (constGroup != null) {
        group = constGroup;
      } else {
        group = d.getUint32(pos, Endian.little);
        pos += 4;
      }
      int instanceHigh;
      if (constInstanceHigh != null) {
        instanceHigh = constInstanceHigh;
      } else {
        instanceHigh = d.getUint32(pos, Endian.little);
        pos += 4;
      }
      final instanceLow = d.getUint32(pos, Endian.little);
      pos += 4;
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
      entries.add(DbpfEntry(type, group, (instanceHigh << 32) | instanceLow,
          offset, fileSizeRaw & 0x7FFFFFFF, memSize, compression));
    }
  } catch (_) {
    // Truncated or malformed index: keep whatever parsed cleanly.
  }
  return entries;
}

/// DBPF v1 index (Sims 2): fixed-size records of 20 bytes - type, group,
/// instance, offset, size - or 24 when index version 7.2 inserts a second
/// (high) instance half before the offset. Compression isn't in the index
/// (it lives in the DIR resource), so entries sniff it per blob instead.
List<DbpfEntry> _parseIndexV1(Uint8List index, int count) {
  final entrySize = index.length ~/ count;
  if (entrySize != 20 && entrySize != 24) return const [];
  final d = ByteData.sublistView(index);
  final entries = <DbpfEntry>[];
  for (var i = 0; i < count; i++) {
    final base = i * entrySize;
    final instanceLow = d.getUint32(base + 8, Endian.little);
    final instanceHigh =
        entrySize == 24 ? d.getUint32(base + 12, Endian.little) : 0;
    entries.add(DbpfEntry(
      d.getUint32(base, Endian.little),
      d.getUint32(base + 4, Endian.little),
      (instanceHigh << 32) | instanceLow,
      d.getUint32(base + entrySize - 8, Endian.little),
      d.getUint32(base + entrySize - 4, Endian.little),
      0,
      null,
    ));
  }
  return entries;
}

/// Reads [entry]'s bytes out of [raf] and undoes the archive's
/// compression. `null` when the blob is truncated, doesn't decode
/// cleanly, or claims more than [maxBytes] of output - the size is the
/// blob's own word, and what comes back here is held in memory.
Uint8List? readDbpfResource(RandomAccessFile raf, DbpfEntry entry,
    {int maxBytes = dbpfDefaultMaxResourceBytes}) {
  if (entry.fileSize <= 0) return null;
  final raw = readAt(raf, entry.offset, entry.fileSize);
  if (raw.length < entry.fileSize) return null;
  final data = _decompress(raw, entry.compression, maxBytes);
  if (data == null || data.length > maxBytes) return null;
  return data;
}

Uint8List? _decompress(Uint8List raw, int? compression, int maxBytes) {
  try {
    switch (compression) {
      case 0x0000:
        return raw;
      case 0x5A42: // zlib (Sims 4)
        return Uint8List.fromList(zlib.decode(raw));
      case 0xFFFF: // RefPack (Sims 3)
      case 0xFFFE:
        return refpackDecode(raw, maxOutputBytes: maxBytes);
      case null: // Sims 2: sniff RefPack, else assume stored as-is.
        return refpackDecode(raw, maxOutputBytes: maxBytes) ?? raw;
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
/// data isn't RefPack, doesn't decode cleanly, or declares more output
/// than [maxOutputBytes].
Uint8List? refpackDecode(Uint8List src,
    {int maxOutputBytes = dbpfDefaultMaxResourceBytes}) {
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
  if (size <= 0 || size > maxOutputBytes) return null;

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

bool isPng(Uint8List b) =>
    b.length >= 8 &&
    b[0] == 0x89 &&
    b[1] == 0x50 &&
    b[2] == 0x4E &&
    b[3] == 0x47 &&
    b[4] == 0x0D &&
    b[5] == 0x0A &&
    b[6] == 0x1A &&
    b[7] == 0x0A;

bool isJpeg(Uint8List b) =>
    b.length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF;

/// Pixel area (width x height) of a PNG or JPEG, read from its headers
/// without decoding. 0 when the dimensions can't be determined; such an
/// image still counts, it just loses to anything measurable.
int imageArea(Uint8List b) {
  if (isPng(b)) {
    // IHDR is always the first chunk: width/height big-endian at 16/20.
    if (b.length < 24) return 0;
    if (b[12] != 0x49 || b[13] != 0x48 || b[14] != 0x44 || b[15] != 0x52) {
      return 0;
    }
    final d = ByteData.sublistView(b);
    return d.getUint32(16) * d.getUint32(20);
  }
  if (isJpeg(b)) {
    // Walk segments to a start-of-frame marker (0xC0-0xCF minus the
    // huffman/arithmetic ones), which holds height/width big-endian.
    var pos = 2;
    while (pos + 9 < b.length) {
      if (b[pos] != 0xFF) return 0;
      final marker = b[pos + 1];
      if (marker >= 0xC0 &&
          marker <= 0xCF &&
          marker != 0xC4 &&
          marker != 0xC8 &&
          marker != 0xCC) {
        final d = ByteData.sublistView(b);
        return d.getUint16(pos + 5) * d.getUint16(pos + 7);
      }
      pos += 2 + ((b[pos + 2] << 8) | b[pos + 3]);
    }
  }
  return 0;
}

Uint8List readAt(RandomAccessFile raf, int offset, int length) {
  raf.setPositionSync(offset);
  return raf.readSync(length);
}
