/// Reading 7z archives without an external unpacker, the way zip is
/// already read.
///
/// The app used to hand every 7z to whatever tool the machine had, and on
/// Windows that is `tar.exe` - libarchive linked against zlib and nothing
/// else. It opens the container, meets LZMA (which is what 7-Zip
/// compresses with unless told otherwise) and gives up, and since no
/// 7-Zip, NanaZip or WinRAR installer puts itself on PATH there was
/// nothing behind it. Every ordinary .7z on The Exchange failed on
/// Windows and nowhere else.
///
/// The format is undocumented beyond the `DOC/7zFormat.txt` that ships
/// with the SDK, and this reads the part of it real archives use: the
/// header (itself usually LZMA-compressed), the folder/coder graph, and
/// the Copy, LZMA, LZMA2, Deflate, BZip2 and Delta coders. Anything else
/// - BCJ and its friends, PPMd, an encrypted archive - raises
/// [SevenZipUnsupportedError] so the caller can fall back to a real
/// unpacker rather than guess.
library;

import 'dart:typed_data';

import 'package:archive/archive.dart';

/// A coder this reader doesn't implement. Not a damaged archive: the
/// bytes are fine and something else may well read them.
class SevenZipUnsupportedError implements Exception {
  const SevenZipUnsupportedError(this.what);

  /// The coder, named for a log rather than for a user.
  final String what;

  @override
  String toString() => '7z uses $what, which this reader does not implement';
}

/// One file inside the archive.
class SevenZipEntry {
  const SevenZipEntry({
    required this.name,
    required this.size,
    required this.isDirectory,
  });

  /// The path the archive gives it, always '/'-joined: 7-Zip writes
  /// Windows separators and this is a key the caller compares, never a
  /// path it hands back to the filesystem.
  final String name;

  final int size;
  final bool isDirectory;
}

/// Hands every file in [bytes] to [onFile] with its contents.
///
/// [wanted] is asked before anything is decompressed; a folder none of
/// whose files are wanted is skipped whole, which matters because a
/// "solid" archive compresses many files into one stream and unpacking it
/// for a readme nobody asked for costs the whole set.
///
/// Throws a [FormatException] when the bytes aren't a 7z archive or are
/// damaged, and a [SevenZipUnsupportedError] when they are one this
/// reader can't decode.
void readSevenZip(
  Uint8List bytes,
  void Function(SevenZipEntry entry, Uint8List data) onFile, {
  bool Function(String name)? wanted,
}) =>
    _SevenZipArchive(bytes).read(onFile, wanted ?? (_) => true);

const _signature = [0x37, 0x7a, 0xbc, 0xaf, 0x27, 0x1c];

// Property ids, as DOC/7zFormat.txt names them.
const _kEnd = 0x00;
const _kHeader = 0x01;
const _kArchiveProperties = 0x02;
const _kAdditionalStreamsInfo = 0x03;
const _kMainStreamsInfo = 0x04;
const _kFilesInfo = 0x05;
const _kPackInfo = 0x06;
const _kUnpackInfo = 0x07;
const _kSubStreamsInfo = 0x08;
const _kSize = 0x09;
const _kCrc = 0x0a;
const _kFolder = 0x0b;
const _kCodersUnpackSize = 0x0c;
const _kNumUnpackStream = 0x0d;
const _kEmptyStream = 0x0e;
const _kEmptyFile = 0x0f;
const _kAnti = 0x10;
const _kName = 0x11;
const _kEncodedHeader = 0x17;

/// One step of a folder's decode chain.
class _Coder {
  _Coder(this.id, this.inStreams, this.outStreams, this.properties);

  final int id;
  final int inStreams;
  final int outStreams;
  final Uint8List? properties;
}

/// A "folder" in 7z's vocabulary is one decode chain producing one
/// output stream, which one or more files are then sliced out of.
class _Folder {
  final coders = <_Coder>[];

  /// Which coder output feeds which coder input, as (inIndex, outIndex)
  /// over the folder's globally numbered streams.
  final bindPairs = <({int input, int output})>[];

  /// Folder input index -> the archive's packed stream that fills it.
  var packedIndices = <int>[];

  /// Unpacked size of every coder output, in order.
  var unpackSizes = <int>[];

  bool crcDefined = false;

  int get totalInStreams =>
      coders.fold(0, (sum, coder) => sum + coder.inStreams);

  int get totalOutStreams =>
      coders.fold(0, (sum, coder) => sum + coder.outStreams);

  /// The one output nothing else consumes: what the folder unpacks to.
  int get finalOutStream {
    for (var i = 0; i < totalOutStreams; i++) {
      if (!bindPairs.any((pair) => pair.output == i)) return i;
    }
    throw const FormatException('7z folder has no output');
  }

  int get unpackSize => unpackSizes[finalOutStream];
}

/// Everything the header says about where the compressed bytes are and
/// how they come apart.
class _StreamsInfo {
  int packPosition = 0;
  var packSizes = <int>[];
  var folders = <_Folder>[];

  /// How many files each folder holds. One unless kNumUnPackStream said
  /// otherwise.
  var substreamCounts = <int>[];

  /// Sizes of every substream, folder by folder.
  var substreamSizes = <int>[];
}

class _SevenZipArchive {
  _SevenZipArchive(this.bytes);

  final Uint8List bytes;

  void read(
    void Function(SevenZipEntry entry, Uint8List data) onFile,
    bool Function(String name) wanted,
  ) {
    final header = _readHeader();
    final streams = header.streams;
    final entries = header.entries;
    if (streams == null) {
      // An archive of nothing but empty files and folders. Nothing to
      // decode, and nothing a mod install would want either.
      return;
    }

    // Files with a stream take the substreams in order; the ones without
    // are folders and empty files, and are simply skipped here.
    final withStreams = [
      for (final e in entries)
        if (!e.isEmpty) e
    ];
    var packIndex = 0;
    var packOffset = 32 + streams.packPosition;
    var substream = 0;
    var sizeIndex = 0;

    for (var f = 0; f < streams.folders.length; f++) {
      final folder = streams.folders[f];
      final count = streams.substreamCounts[f];
      final sizes =
          streams.substreamSizes.sublist(sizeIndex, sizeIndex + count);
      sizeIndex += count;

      final folderEntries = [
        for (var i = 0; i < count; i++)
          if (substream + i < withStreams.length) withStreams[substream + i],
      ];
      substream += count;

      // Where this folder's packed bytes sit, whether or not we read them.
      final packCount = folder.packedIndices.length;
      final packStart = packOffset;
      for (var i = 0; i < packCount; i++) {
        packOffset += streams.packSizes[packIndex + i];
      }
      final firstPack = packIndex;
      packIndex += packCount;

      if (!folderEntries.any((e) => wanted(e.name))) continue;

      final packed = <Uint8List>[];
      var at = packStart;
      for (var i = 0; i < packCount; i++) {
        final size = streams.packSizes[firstPack + i];
        packed.add(_slice(at, size));
        at += size;
      }

      final data = _decodeFolder(folder, packed);
      var offset = 0;
      for (var i = 0; i < folderEntries.length; i++) {
        final entry = folderEntries[i];
        final size = sizes[i];
        if (offset + size > data.length) {
          throw const FormatException('7z substream runs past its folder');
        }
        if (wanted(entry.name)) {
          onFile(
            SevenZipEntry(name: entry.name, size: size, isDirectory: false),
            Uint8List.sublistView(data, offset, offset + size),
          );
        }
        offset += size;
      }
    }
  }

  Uint8List _slice(int start, int length) {
    if (start < 0 || start + length > bytes.length) {
      throw const FormatException('7z packed stream runs past the file');
    }
    return Uint8List.sublistView(bytes, start, start + length);
  }

  ({_StreamsInfo? streams, List<_FileRecord> entries}) _readHeader() {
    if (bytes.length < 32) {
      throw const FormatException('Not a 7z archive');
    }
    for (var i = 0; i < _signature.length; i++) {
      if (bytes[i] != _signature[i]) {
        throw const FormatException('Not a 7z archive');
      }
    }
    final start = _Reader(bytes, 12);
    final offset = start.readUint64();
    final size = start.readUint64();
    if (size == 0) return (streams: null, entries: const []);
    final at = 32 + offset;
    if (at < 32 || at + size > bytes.length) {
      throw const FormatException('7z header runs past the file');
    }

    var reader = _Reader(_slice(at, size));
    var id = reader.readByte();
    if (id == _kEncodedHeader) {
      // The header is itself a one-folder archive, compressed with the
      // same coders as the content.
      final info = _readStreamsInfo(reader);
      if (info.folders.length != 1) {
        throw const FormatException('7z encoded header is not one folder');
      }
      final folder = info.folders.single;
      var packAt = 32 + info.packPosition;
      final packed = <Uint8List>[];
      for (var i = 0; i < folder.packedIndices.length; i++) {
        packed.add(_slice(packAt, info.packSizes[i]));
        packAt += info.packSizes[i];
      }
      reader = _Reader(_decodeFolder(folder, packed));
      id = reader.readByte();
    }
    if (id != _kHeader) {
      throw const FormatException('7z header is not a header');
    }
    return _readPlainHeader(reader);
  }

  ({_StreamsInfo? streams, List<_FileRecord> entries}) _readPlainHeader(
      _Reader reader) {
    _StreamsInfo? streams;
    var entries = <_FileRecord>[];
    var id = reader.readByte();
    if (id == _kArchiveProperties) {
      while (true) {
        final type = reader.readNumber();
        if (type == _kEnd) break;
        reader.skip(reader.readNumber());
      }
      id = reader.readByte();
    }
    if (id == _kAdditionalStreamsInfo) {
      // Only ever written for names held outside the header, which
      // nothing in the wild does any more.
      throw const SevenZipUnsupportedError('external streams');
    }
    if (id == _kMainStreamsInfo) {
      streams = _readStreamsInfo(reader);
      id = reader.readByte();
    }
    if (id == _kFilesInfo) {
      entries = _readFilesInfo(reader);
      id = reader.readByte();
    }
    return (streams: streams, entries: entries);
  }

  _StreamsInfo _readStreamsInfo(_Reader reader) {
    final info = _StreamsInfo();
    var id = reader.readNumber();
    if (id == _kPackInfo) {
      info.packPosition = reader.readNumber();
      final count = reader.readNumber();
      var next = reader.readNumber();
      while (next != _kEnd) {
        if (next == _kSize) {
          info.packSizes = [
            for (var i = 0; i < count; i++) reader.readNumber()
          ];
        } else if (next == _kCrc) {
          reader.skipDigests(count);
        } else {
          throw const FormatException('7z pack info is not one we know');
        }
        next = reader.readNumber();
      }
      id = reader.readNumber();
    }
    if (id == _kUnpackInfo) {
      _readUnpackInfo(reader, info);
      id = reader.readNumber();
    }
    // Without a substreams record every folder holds exactly one file.
    info.substreamCounts = [for (final _ in info.folders) 1];
    info.substreamSizes = [
      for (final folder in info.folders) folder.unpackSize
    ];
    if (id == _kSubStreamsInfo) {
      _readSubStreamsInfo(reader, info);
      id = reader.readNumber();
    }
    if (id != _kEnd) {
      throw const FormatException('7z streams info does not end');
    }
    return info;
  }

  void _readUnpackInfo(_Reader reader, _StreamsInfo info) {
    if (reader.readNumber() != _kFolder) {
      throw const FormatException('7z unpack info has no folders');
    }
    final count = reader.readNumber();
    if (reader.readByte() != 0) {
      throw const SevenZipUnsupportedError('folders held outside the header');
    }
    info.folders = [for (var i = 0; i < count; i++) _readFolder(reader)];
    if (reader.readNumber() != _kCodersUnpackSize) {
      throw const FormatException('7z folders have no sizes');
    }
    for (final folder in info.folders) {
      folder.unpackSizes = [
        for (var i = 0; i < folder.totalOutStreams; i++) reader.readNumber(),
      ];
    }
    var id = reader.readNumber();
    while (id != _kEnd) {
      if (id == _kCrc) {
        final defined = reader.readDefinedVector(count);
        for (var i = 0; i < count; i++) {
          info.folders[i].crcDefined = defined[i];
          if (defined[i]) reader.readUint32();
        }
      } else {
        reader.skip(reader.readNumber());
      }
      id = reader.readNumber();
    }
  }

  _Folder _readFolder(_Reader reader) {
    final folder = _Folder();
    final coders = reader.readNumber();
    for (var i = 0; i < coders; i++) {
      final flags = reader.readByte();
      final idSize = flags & 0x0f;
      var id = 0;
      for (var b = 0; b < idSize; b++) {
        id = (id << 8) | reader.readByte();
      }
      var inStreams = 1;
      var outStreams = 1;
      if (flags & 0x10 != 0) {
        inStreams = reader.readNumber();
        outStreams = reader.readNumber();
      }
      Uint8List? properties;
      if (flags & 0x20 != 0) {
        properties = reader.readBytes(reader.readNumber());
      }
      folder.coders.add(_Coder(id, inStreams, outStreams, properties));
    }
    final bindPairs = folder.totalOutStreams - 1;
    for (var i = 0; i < bindPairs; i++) {
      folder.bindPairs
          .add((input: reader.readNumber(), output: reader.readNumber()));
    }
    final packed = folder.totalInStreams - bindPairs;
    if (packed == 1) {
      // The only input nothing is bound to, left implicit.
      var found = -1;
      for (var i = 0; i < folder.totalInStreams; i++) {
        if (!folder.bindPairs.any((pair) => pair.input == i)) {
          found = i;
          break;
        }
      }
      if (found == -1) throw const FormatException('7z folder has no input');
      folder.packedIndices = [found];
    } else {
      folder.packedIndices = [
        for (var i = 0; i < packed; i++) reader.readNumber(),
      ];
    }
    return folder;
  }

  void _readSubStreamsInfo(_Reader reader, _StreamsInfo info) {
    var id = reader.readNumber();
    var counts = [for (final _ in info.folders) 1];
    if (id == _kNumUnpackStream) {
      counts = [for (final _ in info.folders) reader.readNumber()];
      id = reader.readNumber();
    }
    // Every substream but the last of each folder is listed; the last is
    // whatever is left of the folder.
    final sizes = <int>[];
    for (var f = 0; f < info.folders.length; f++) {
      if (counts[f] == 0) continue;
      var remaining = info.folders[f].unpackSize;
      if (id == _kSize) {
        for (var i = 0; i < counts[f] - 1; i++) {
          final size = reader.readNumber();
          sizes.add(size);
          remaining -= size;
        }
      } else if (counts[f] != 1) {
        throw const FormatException('7z substreams have no sizes');
      }
      if (remaining < 0) {
        throw const FormatException('7z substream sizes exceed their folder');
      }
      sizes.add(remaining);
    }
    if (id == _kSize) id = reader.readNumber();

    while (id != _kEnd) {
      if (id == _kCrc) {
        // Only the streams whose CRC isn't already known as their
        // folder's are listed here.
        var unknown = 0;
        for (var f = 0; f < info.folders.length; f++) {
          if (counts[f] == 1 && info.folders[f].crcDefined) continue;
          unknown += counts[f];
        }
        reader.skipDigests(unknown);
      } else {
        reader.skip(reader.readNumber());
      }
      id = reader.readNumber();
    }
    info.substreamCounts = counts;
    info.substreamSizes = sizes;
  }

  List<_FileRecord> _readFilesInfo(_Reader reader) {
    final count = reader.readNumber();
    var emptyStreams = <bool>[];
    var emptyFiles = <bool>[];
    var names = <String>[];

    while (true) {
      final type = reader.readNumber();
      if (type == _kEnd) break;
      final size = reader.readNumber();
      final end = reader.position + size;
      switch (type) {
        case _kEmptyStream:
          emptyStreams = reader.readBitVector(count);
        case _kEmptyFile:
          emptyFiles =
              reader.readBitVector(emptyStreams.where((empty) => empty).length);
        case _kAnti:
          break; // A deletion marker in an incremental archive; not ours.
        case _kName:
          if (reader.readByte() != 0) {
            throw const SevenZipUnsupportedError(
                'names held outside the header');
          }
          names = reader.readNames(count, end);
        default:
          break; // Times, attributes, padding: nothing an install needs.
      }
      if (end > reader.length) {
        throw const FormatException('7z file property runs past the header');
      }
      reader.position = end;
    }

    if (names.length != count) {
      throw const FormatException('7z archive does not name every file');
    }
    var emptyIndex = 0;
    return [
      for (var i = 0; i < count; i++)
        () {
          final empty = i < emptyStreams.length && emptyStreams[i];
          // An entry with no stream is a folder, unless it was marked an
          // empty file - which is a file, just a zero-byte one.
          final isFile = !empty ||
              (emptyIndex < emptyFiles.length && emptyFiles[emptyIndex]);
          if (empty) emptyIndex++;
          return _FileRecord(names[i], empty, isFile);
        }(),
    ];
  }

  Uint8List _decodeFolder(_Folder folder, List<Uint8List> packed) {
    // Where each globally numbered stream begins, so a bind pair can be
    // matched to the coder that owns it.
    final firstIn = <int>[];
    final firstOut = <int>[];
    var ins = 0;
    var outs = 0;
    for (final coder in folder.coders) {
      firstIn.add(ins);
      firstOut.add(outs);
      ins += coder.inStreams;
      outs += coder.outStreams;
    }

    final decoded = <int, Uint8List>{};
    Uint8List outputOf(int stream, int depth) {
      final cached = decoded[stream];
      if (cached != null) return cached;
      if (depth > folder.coders.length) {
        throw const FormatException('7z coders feed each other in a circle');
      }
      var coder = -1;
      for (var i = 0; i < folder.coders.length; i++) {
        if (stream >= firstOut[i] &&
            stream < firstOut[i] + folder.coders[i].outStreams) {
          coder = i;
          break;
        }
      }
      if (coder == -1) throw const FormatException('7z names no such stream');

      final inputs = <Uint8List>[];
      for (var i = 0; i < folder.coders[coder].inStreams; i++) {
        final global = firstIn[coder] + i;
        final bound =
            folder.bindPairs.where((pair) => pair.input == global).firstOrNull;
        if (bound != null) {
          inputs.add(outputOf(bound.output, depth + 1));
          continue;
        }
        final packedAt = folder.packedIndices.indexOf(global);
        if (packedAt == -1 || packedAt >= packed.length) {
          throw const FormatException('7z folder input is fed by nothing');
        }
        inputs.add(packed[packedAt]);
      }
      final result =
          _runCoder(folder.coders[coder], inputs, folder.unpackSizes[stream]);
      decoded[stream] = result;
      return result;
    }

    return outputOf(folder.finalOutStream, 0);
  }
}

/// What the header says about one entry, before it is paired with the
/// bytes of a substream.
class _FileRecord {
  const _FileRecord(this.name, this.isEmpty, this.isFile);

  final String name;

  /// No stream of its own: a folder, or a file of zero bytes.
  final bool isEmpty;
  final bool isFile;
}

/// Runs one coder over its inputs. Everything here has a single input and
/// a single output; the ones that don't (BCJ2) are refused above.
Uint8List _runCoder(_Coder coder, List<Uint8List> inputs, int outSize) {
  final input = inputs.first;
  switch (coder.id) {
    case 0x00: // Copy
      return outSize <= input.length
          ? Uint8List.sublistView(input, 0, outSize)
          : input;
    case 0x21: // LZMA2
      return _decodeLzma2(input, outSize);
    case 0x030101: // LZMA
      return _decodeLzma(input, coder.properties, outSize);
    case 0x03: // Delta
      return _undoDelta(input, (coder.properties?.first ?? 0) + 1);
    case 0x040108: // Deflate
      return Inflate(input, uncompressedSize: outSize).getBytes();
    case 0x040202: // BZip2
      return BZip2Decoder().decodeBytes(input);
    case 0x06f10701:
      throw const SevenZipUnsupportedError('AES encryption');
    case 0x030401:
      throw const SevenZipUnsupportedError('PPMd');
    case 0x0303011b:
      throw const SevenZipUnsupportedError('the BCJ2 branch filter');
    default:
      throw SevenZipUnsupportedError('coder 0x${coder.id.toRadixString(16)}');
  }
}

/// LZMA as 7z stores it: the three parameters live in the coder's
/// properties rather than in the stream, and the length is known, so
/// there is no end marker to look for.
Uint8List _decodeLzma(Uint8List input, Uint8List? properties, int outSize) {
  if (properties == null || properties.isEmpty) {
    throw const FormatException('7z LZMA coder has no properties');
  }
  var packed = properties[0];
  if (packed >= 9 * 5 * 5) {
    throw const FormatException('7z LZMA properties are out of range');
  }
  final literalContextBits = packed % 9;
  packed ~/= 9;
  final literalPositionBits = packed % 5;
  final positionBits = packed ~/ 5;

  final decoder = LzmaDecoder()
    ..reset(
      literalContextBits: literalContextBits,
      literalPositionBits: literalPositionBits,
      positionBits: positionBits,
      resetDictionary: true,
    );
  return decoder.decode(InputMemoryStream(input), outSize);
}

/// LZMA2 is LZMA cut into chunks, each saying what to reset first and
/// whether it is even compressed. Same shape as the xz decoder's, which
/// is the only other place this format shows up.
Uint8List _decodeLzma2(Uint8List input, int outSize) {
  final decoder = LzmaDecoder();
  final output = Uint8List(outSize);
  final stream = InputMemoryStream(input);
  var written = 0;

  while (!stream.isEOS) {
    final control = stream.readByte();
    if (control == 0) break; // End of stream.
    if (control == 1 || control == 2) {
      // Stored, not compressed. 1 resets the dictionary first, 2 doesn't.
      final length = (stream.readByte() << 8 | stream.readByte()) + 1;
      if (control == 1) decoder.reset(resetDictionary: true);
      final chunk =
          decoder.decodeUncompressed(stream.readBytes(length), length);
      _append(output, written, chunk);
      written += length;
      continue;
    }
    if (control & 0x80 == 0) {
      throw FormatException(
          '7z LZMA2 control byte $control is not one we know');
    }
    final reset = (control >> 5) & 0x3;
    final uncompressed =
        ((control & 0x1f) << 16 | stream.readByte() << 8 | stream.readByte()) +
            1;
    final compressed = (stream.readByte() << 8 | stream.readByte()) + 1;
    int? literalContextBits;
    int? literalPositionBits;
    int? positionBits;
    if (reset >= 2) {
      var packed = stream.readByte();
      positionBits = packed ~/ 45;
      packed -= positionBits * 45;
      literalPositionBits = packed ~/ 9;
      literalContextBits = packed - literalPositionBits * 9;
    }
    if (reset > 0) {
      decoder.reset(
        literalContextBits: literalContextBits,
        literalPositionBits: literalPositionBits,
        positionBits: positionBits,
        resetDictionary: reset == 3,
      );
    }
    final chunk = decoder.decode(stream.readBytes(compressed), uncompressed);
    _append(output, written, chunk);
    written += uncompressed;
  }
  if (written < outSize) {
    throw const FormatException('7z LZMA2 stream ended early');
  }
  return output;
}

void _append(Uint8List output, int at, Uint8List chunk) {
  if (at + chunk.length > output.length) {
    throw const FormatException('7z stream unpacks to more than it declared');
  }
  output.setRange(at, at + chunk.length, chunk);
}

/// The delta filter, undone: each byte was stored as its difference from
/// the one [distance] before it.
Uint8List _undoDelta(Uint8List input, int distance) {
  final output = Uint8List.fromList(input);
  for (var i = distance; i < output.length; i++) {
    output[i] = (output[i] + output[i - distance]) & 0xff;
  }
  return output;
}

/// Reads the header's own encoding: little-endian fixed integers, the
/// variable-length numbers the property records use, and bit vectors.
class _Reader {
  _Reader(this.bytes, [this.position = 0]);

  final Uint8List bytes;
  int position;

  int get length => bytes.length;

  int readByte() {
    if (position >= bytes.length) {
      throw const FormatException('7z header ends mid-value');
    }
    return bytes[position++];
  }

  Uint8List readBytes(int count) {
    if (count < 0 || position + count > bytes.length) {
      throw const FormatException('7z header ends mid-value');
    }
    final view = Uint8List.sublistView(bytes, position, position + count);
    position += count;
    return view;
  }

  void skip(int count) => position = position + count;

  int readUint32() {
    var value = 0;
    for (var i = 0; i < 4; i++) {
      value |= readByte() << (8 * i);
    }
    return value;
  }

  int readUint64() {
    var value = 0;
    for (var i = 0; i < 8; i++) {
      value |= readByte() << (8 * i);
    }
    return value;
  }

  /// The format's own variable-length number: the leading byte says how
  /// many more follow, and carries the top bits itself.
  int readNumber() {
    final first = readByte();
    var mask = 0x80;
    var value = 0;
    for (var i = 0; i < 8; i++) {
      if (first & mask == 0) {
        return value + ((first & (mask - 1)) << (8 * i));
      }
      value |= readByte() << (8 * i);
      mask >>= 1;
    }
    return value;
  }

  /// [count] bits, most significant first within each byte.
  List<bool> readBitVector(int count) {
    final bits = <bool>[];
    var current = 0;
    var mask = 0;
    for (var i = 0; i < count; i++) {
      if (mask == 0) {
        current = readByte();
        mask = 0x80;
      }
      bits.add(current & mask != 0);
      mask >>= 1;
    }
    return bits;
  }

  /// The same, behind the "all of them" byte that usually stands in for
  /// it.
  List<bool> readDefinedVector(int count) =>
      readByte() != 0 ? List.filled(count, true) : readBitVector(count);

  void skipDigests(int count) {
    final defined = readDefinedVector(count);
    for (final it in defined) {
      if (it) readUint32();
    }
  }

  /// File names: UTF-16, null-terminated, one after another. Dart strings
  /// are UTF-16 too, so surrogate pairs need no handling of their own.
  List<String> readNames(int count, int end) {
    final names = <String>[];
    final units = <int>[];
    while (position + 1 < end && names.length < count) {
      final unit = readByte() | (readByte() << 8);
      if (unit == 0) {
        names.add(_slashes(String.fromCharCodes(units)));
        units.clear();
      } else {
        units.add(unit);
      }
    }
    return names;
  }

  /// 7-Zip writes the separator of whatever machine packed the archive.
  static String _slashes(String name) => name.replaceAll(r'\', '/');
}
