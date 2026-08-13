import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../../core/creation.dart';
import '../../core/dbpf.dart';

/// Reads The Sims 2's bins - the lots in `LotCatalog` and the packaged
/// sims in `SavedSims`.
///
/// This is the one game in the series that files its two kinds of
/// player-built content in two different folders, which is why
/// [CreationFolder] carries the kinds it accepts at all: a household
/// dropped on the window has exactly one place it can go, and the app
/// knows which without asking.
///
/// Both folders hold DBPF v1 packages, the same container as a Sims 2
/// mod, so what a file *is* has to come from the resources inside it -
/// the lot description record for a lot, the sim description and its
/// character text for a sim.
///
/// Synchronous on purpose - the adapter runs it in an isolate.

/// The lot bin's own description record: a 64-byte name header, a fixed
/// prefix, then the lot's name and its blurb as one-byte-length strings.
const _lotDescriptionType = 0x6C589723;

/// Sim description, which is what makes a package in `SavedSims` a sim
/// rather than anything else that could be sitting there.
const _simDescriptionType = 0xAACE2EFB;

/// The catalog text a packaged sim carries: item 0 is the first name,
/// item 2 the last, item 1 the biography.
const _catalogTextType = 0x43545353;

/// Thumbnails. Real packages write both of these - `IMG` for the older
/// ones and `JPG` for anything the later patches touched - and reading
/// only one of them means half the bin has no picture.
const _imageTypes = <int>[0x856DDBAC, 0x8C3CE95A];

/// Every Sims 2 resource opens with a 64-byte slot for the name the
/// packer gave it; a thumbnail's bytes start after it.
const _resourceNameHeaderBytes = 0x40;

/// Where the lot's name starts: past the name header and the seventeen
/// bytes of version and counters after it.
const _lotNameOffset = _resourceNameHeaderBytes + 0x11;

/// A bin thumbnail is a catalog picture; the cap only stops a misread
/// header asking for the moon.
const _maxImageBytes = 8 << 20;

/// A lot that was packaged with its residents brings them along as
/// `cx_Character_cx_00000025_11f1177b.package` beside it. Those are not
/// entries of their own - the bin shows one card, the house - but they
/// are part of it, and a lot deleted without them leaves the folder
/// filling up with sims who live nowhere.
final _lotCompanion =
    RegExp(r'^cx_Character_(.+?)_[0-9a-f]+\.package$', caseSensitive: false);

/// Reads the lot bin. Every `.package` in it that is not a companion is a
/// lot, so nothing has to be opened to decide what one is - only to find
/// out what it is called.
List<Creation> scanSims2Lots(String lotCatalogPath) {
  final dir = Directory(lotCatalogPath);
  if (!dir.existsSync()) return const [];

  final lots = <File>[];
  final companions = <String, List<String>>{};
  try {
    for (final entity in dir.listSync()) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);
      if (p.extension(name).toLowerCase() != '.package') continue;
      final companion = _lotCompanion.firstMatch(name);
      if (companion != null) {
        (companions[companion.group(1)!.toLowerCase()] ??= [])
            .add(entity.path);
      } else {
        lots.add(entity);
      }
    }
  } catch (_) {
    return const [];
  }

  final creations = <Creation>[];
  for (final file in lots) {
    final creation = _readLot(
        file, companions[p.basenameWithoutExtension(file.path).toLowerCase()]);
    if (creation != null) creations.add(creation);
  }
  creations.sort(compareCreations);
  return creations;
}

/// Reads the packaged-sims bin.
List<Creation> scanSims2Sims(String savedSimsPath) {
  final dir = Directory(savedSimsPath);
  if (!dir.existsSync()) return const [];
  final creations = <Creation>[];
  try {
    for (final entity in dir.listSync()) {
      if (entity is! File) continue;
      if (p.extension(entity.path).toLowerCase() != '.package') continue;
      final creation = _readSim(entity);
      if (creation != null) creations.add(creation);
    }
  } catch (_) {
    return const [];
  }
  creations.sort(compareCreations);
  return creations;
}

Creation? _readLot(File file, List<String>? companions) =>
    _read(file, (raf, index, stat) {
      final entry =
          index.where((e) => e.type == _lotDescriptionType).firstOrNull;
      if (entry == null) return null;
      final data = readDbpfResource(raf, entry);
      final strings = data == null
          ? const <String>[]
          : _pascalStrings(data, _lotNameOffset, 2);
      final name = strings.isNotEmpty ? strings.first.trim() : '';
      final blurb = strings.length > 1 ? strings[1].trim() : '';
      return Creation(
        // A lot in the bin whose record would not read is still a lot the
        // game shows; the file name is `cx_00000003`, which says nothing,
        // but a missing card would say less.
        name: name.isEmpty ? p.basenameWithoutExtension(file.path) : name,
        kindKey: kindLot,
        path: file.path,
        files: [file.path, ...?companions],
        sizeBytes: stat.size + _sizeOf(companions),
        modifiedAt: stat.modified,
        // The record repeats the name in the description slot when the
        // builder wrote none, and a card that says the same thing twice
        // is worse than one that says it once.
        description: blurb.isEmpty || blurb == name ? null : blurb,
        thumbnail: _bestImage(raf, index),
      );
    });

Creation? _readSim(File file) => _read(file, (raf, index, stat) {
      if (!index.any((e) => e.type == _simDescriptionType)) return null;
      final text = _catalogText(raf, index);
      final first = text.isNotEmpty ? text[0].trim() : '';
      final last = text.length > 2 ? text[2].trim() : '';
      final bio = text.length > 1 ? text[1].trim() : '';
      final full = [first, last].where((s) => s.isNotEmpty).join(' ');
      return Creation(
        name: full.isEmpty ? p.basenameWithoutExtension(file.path) : full,
        kindKey: kindSim,
        path: file.path,
        files: [file.path],
        sizeBytes: stat.size,
        modifiedAt: stat.modified,
        description: bio.isEmpty ? null : bio,
        thumbnail: _bestImage(raf, index),
        sims: full.isEmpty
            ? const []
            : [
                CreationSim(
                  firstName: first.isEmpty ? full : first,
                  lastName: last.isEmpty ? null : last,
                )
              ],
      );
    });

int _sizeOf(List<String>? paths) {
  var total = 0;
  for (final path in paths ?? const <String>[]) {
    try {
      total += File(path).lengthSync();
    } catch (_) {}
  }
  return total;
}

Creation? _read(
  File file,
  Creation? Function(RandomAccessFile raf, List<DbpfEntry> index, FileStat stat)
      body,
) {
  RandomAccessFile? raf;
  try {
    raf = file.openSync();
    final index = readDbpfIndex(raf);
    if (index == null) return null;
    return body(raf, index, file.statSync());
  } catch (_) {
    return null;
  } finally {
    try {
      raf?.closeSync();
    } catch (_) {}
  }
}

/// The catalog strings of a packaged sim, default language only.
List<String> _catalogText(RandomAccessFile raf, List<DbpfEntry> index) {
  final entry = index.where((e) => e.type == _catalogTextType).firstOrNull;
  if (entry == null) return const [];
  final data = readDbpfResource(raf, entry);
  if (data == null || data.length < _resourceNameHeaderBytes + 4) {
    return const [];
  }
  // 64-byte name header, a format word, then a count and that many
  // {language byte, title, description} entries.
  var pos = _resourceNameHeaderBytes + 2;
  final d = ByteData.sublistView(data);
  if (pos + 2 > data.length) return const [];
  final count = d.getUint16(pos, Endian.little);
  pos += 2;
  final out = <String>[];
  for (var i = 0; i < count && pos < data.length; i++) {
    pos++; // language
    final title = _cString(data, pos);
    pos += title.length + 1;
    final description = _cString(data, pos);
    pos += description.length + 1;
    out.add(title);
    if (out.length == 1 && description.isNotEmpty) out.add(description);
  }
  return out;
}

/// The largest picture in the package. A bin entry carries the catalog
/// shot at more than one size.
Uint8List? _bestImage(RandomAccessFile raf, List<DbpfEntry> index) {
  Uint8List? best;
  var bestArea = -1;
  for (final entry in index) {
    if (!_imageTypes.contains(entry.type)) continue;
    var data = readDbpfResource(raf, entry, maxBytes: _maxImageBytes);
    if (data == null) continue;
    if (!isJpeg(data) && !isPng(data)) {
      // Some of these carry the 64-byte name header in front of the
      // image and some do not, so the signature decides rather than the
      // type.
      if (data.length <= _resourceNameHeaderBytes) continue;
      data = Uint8List.sublistView(data, _resourceNameHeaderBytes);
      if (!isJpeg(data) && !isPng(data)) continue;
    }
    final area = imageArea(data);
    if (area > bestArea) {
      best = data;
      bestArea = area;
    }
  }
  return best;
}

/// [count] one-byte-length strings starting at [offset].
///
/// The offset is where the record has put them on every version seen, but
/// not on every version there is: the prefix between the name header and
/// the strings grew over the game's patches. So a name that does not read
/// as one sends the reader looking for the first that does, which is
/// cheaper than a table of layouts per version and does not go stale.
List<String> _pascalStrings(Uint8List data, int offset, int count) {
  final atOffset = _pascalStringsAt(data, offset, count);
  if (atOffset.isNotEmpty && _readsAsName(atOffset.first)) return atOffset;
  for (var pos = _resourceNameHeaderBytes; pos < data.length; pos++) {
    final found = _pascalStringsAt(data, pos, count);
    if (found.isNotEmpty && _readsAsName(found.first)) return found;
  }
  return atOffset;
}

List<String> _pascalStringsAt(Uint8List data, int offset, int count) {
  final out = <String>[];
  var pos = offset;
  for (var i = 0; i < count; i++) {
    if (pos >= data.length) break;
    final length = data[pos++];
    if (pos + length > data.length) break;
    out.add(_decode(Uint8List.sublistView(data, pos, pos + length)));
    pos += length;
  }
  return out;
}

/// A lot name is text somebody typed: printable, and with a letter in it.
bool _readsAsName(String value) {
  final trimmed = value.trim();
  if (trimmed.length < 3) return false;
  if (trimmed.codeUnits.any((u) => u < 0x20)) return false;
  return RegExp('[A-Za-z]').hasMatch(trimmed);
}

String _cString(Uint8List data, int offset) {
  var end = offset;
  while (end < data.length && data[end] != 0) {
    end++;
  }
  if (end <= offset) return '';
  return _decode(Uint8List.sublistView(data, offset, end));
}

/// The game writes these strings as UTF-8 and has since the expansions,
/// but the older records are plain bytes; decoding one as the other turns
/// a dash into "â". So UTF-8 is tried first and anything it refuses is
/// read as Latin-1, which cannot fail.
String _decode(Uint8List bytes) {
  try {
    return utf8.decode(bytes);
  } catch (_) {
    return latin1.decode(bytes);
  }
}

/// Whether [file] is a Sims 2 lot-bin package, which is what tells a
/// downloaded lot from a downloaded mod: both are `.package` files and
/// only one of them belongs in Downloads.
bool isSims2Lot(File file) => _hasType(file, _lotDescriptionType);

/// Whether [file] is a packaged sim.
bool isSims2Sim(File file) => _hasType(file, _simDescriptionType);

bool _hasType(File file, int type) {
  RandomAccessFile? raf;
  try {
    raf = file.openSync();
    final index = readDbpfIndex(raf);
    return index != null && index.any((e) => e.type == type);
  } catch (_) {
    return false;
  } finally {
    try {
      raf?.closeSync();
    } catch (_) {}
  }
}
