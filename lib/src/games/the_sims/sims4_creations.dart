import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../../core/creation.dart';
import '../../core/dbpf.dart';
import '../../core/protobuf_wire.dart';

/// Reads The Sims 4 Tray - the lots, rooms and households the player saved
/// to their library or downloaded from the Gallery.
///
/// Every item is a *set* of files sharing one id, named
/// `0x<group>!0x<instance>.<ext>`. The `.trayitem` is the metadata and the
/// anchor; beside it sit the payload (`.householdbinary`, `.blueprint` or
/// `.room`), one or two thumbnails (`.hhi`, `.bpi`, `.rmi`) and a portrait
/// per sim (`.sgi`). Which of the three payload extensions is present is
/// what says whether the item is a household, a lot or a room - read off
/// the file name rather than out of the metadata's own type word, because
/// the extension cannot be wrong and one sample of a type word is not a
/// mapping.
///
/// The `.trayitem` is an 8-byte header (a version word and the payload
/// length) followed by one protobuf. Field numbers below were read off a
/// real tray on a 1.11x install; unknown fields are skipped for free, so a
/// patch that adds one costs nothing.
///
/// The thumbnails are JPEGs the game obfuscates: a 24-byte header (the
/// image length, a constant, a version) and then the bytes XORed with a
/// repeating 8-byte key. Not encryption and never treated as such - it is
/// undone here so a card can show the picture the game shows.
///
/// Best-effort throughout: an item whose metadata will not parse still
/// appears, named after its file, because the player can see it in the
/// game and a manager that silently drops it is the more confusing of the
/// two answers. Synchronous on purpose - the adapter runs it in an isolate.

/// `0x00000001!0x00111663272a0031.trayitem` and its siblings.
final _trayName = RegExp(
    r'^0x([0-9a-f]{1,16})!0x([0-9a-f]{1,16})\.([a-z0-9]+)$',
    caseSensitive: false);

/// The payload extension that decides what an item is.
const _kindByExtension = <String, String>{
  'householdbinary': kindHousehold,
  'blueprint': kindLot,
  'room': kindRoom,
};

/// Thumbnail extensions, per kind. A household writes two `.hhi` (a small
/// one and a large one); the largest of whatever is there wins.
const _thumbnailExtensions = <String>{'hhi', 'bpi', 'rmi'};

/// Per-sim portraits. Their instance is the sim's own id rather than the
/// item's, which is what lets a face be matched to a name.
const _simPortraitExtension = 'sgi';

const _trayHeaderBytes = 8;

/// The obfuscated-image header: length, a constant the game writes on
/// every one of them, and a version word.
const _imageHeaderBytes = 24;

const _imageKey = <int>[0x41, 0x25, 0xE6, 0xCD, 0x47, 0xBA, 0xB2, 0x1A];

/// A tray thumbnail is a catalog picture, not a texture; anything claiming
/// more than this is a header we have misread.
const _maxImageBytes = 32 << 20;

const _genderKeys = <int, String>{4096: 'male', 8192: 'female'};

/// Age flags, the same enum the save files use. Only exact matches are
/// mapped: an unrecognised value means the card says nothing about age
/// rather than guessing at a life stage.
const _ageKeys = <int, String>{
  1: 'baby',
  2: 'toddler',
  4: 'child',
  8: 'teen',
  16: 'youngAdult',
  32: 'adult',
  64: 'elder',
  128: 'infant',
};

/// One file in the tray, with its name already taken apart.
class _TrayFile {
  _TrayFile(this.file, this.instance, this.extension);

  final File file;
  final int instance;
  final String extension;
}

List<Creation> scanSims4Creations(String trayPath) {
  final dir = Directory(trayPath);
  if (!dir.existsSync()) return const [];

  // One pass over the folder, grouped by the instance in each file name.
  // Portraits are kept apart because theirs is a sim id, not an item id.
  final sets = <int, List<_TrayFile>>{};
  final portraits = <int, File>{};
  try {
    for (final entity in dir.listSync()) {
      if (entity is! File) continue;
      final match = _trayName.firstMatch(p.basename(entity.path));
      if (match == null) continue;
      final instance = int.tryParse(match.group(2)!, radix: 16);
      if (instance == null) continue;
      final extension = match.group(3)!.toLowerCase();
      if (extension == _simPortraitExtension) {
        portraits[instance] = entity;
        continue;
      }
      (sets[instance] ??= []).add(_TrayFile(entity, instance, extension));
    }
  } catch (_) {
    return const [];
  }

  final creations = <Creation>[];
  for (final entry in sets.entries) {
    final creation = _readItem(entry.value, portraits);
    if (creation != null) creations.add(creation);
  }
  creations.sort(compareCreations);
  return creations;
}

Creation? _readItem(List<_TrayFile> files, Map<int, File> portraits) {
  final anchor =
      files.where((f) => f.extension == 'trayitem').firstOrNull ?? files.first;
  final kind = files
          .map((f) => _kindByExtension[f.extension])
          .whereType<String>()
          .firstOrNull ??
      // A set whose payload is missing is still an item the game lists,
      // and a household is what nearly all of them are.
      kindHousehold;

  var size = 0;
  DateTime? modified;
  for (final f in files) {
    try {
      final stat = f.file.statSync();
      size += stat.size;
      if (modified == null || stat.modified.isAfter(modified)) {
        modified = stat.modified;
      }
    } catch (_) {}
  }

  final meta = _readTrayItem(anchor.file);
  // The portraits belong to the set even though their file names carry a
  // sim id rather than the item's: they are copied with it and deleted
  // with it, so they have to be in [Creation.files].
  final used = <String>[];
  final sims = meta == null
      ? const <CreationSim>[]
      : _readSims(meta, portraits, used: used);
  for (final path in used) {
    try {
      size += File(path).lengthSync();
    } catch (_) {}
  }

  return Creation(
    name: meta?.name ?? p.basenameWithoutExtension(anchor.file.path),
    kindKey: kind,
    path: anchor.file.path,
    files: [for (final f in files) f.file.path, ...used],
    sizeBytes: size,
    modifiedAt: modified,
    creatorName: meta?.creator,
    description: meta?.description,
    thumbnail: _bestThumbnail(files),
    sims: sims,
  );
}

/// What the `.trayitem` gave up. Every field is optional: the point of the
/// walker is that a message it half-understands still yields the parts it
/// does.
class _TrayMeta {
  const _TrayMeta(this.name, this.description, this.creator, this.payload);

  final String? name;
  final String? description;
  final String? creator;

  /// The item's own body, which for a household holds its sims.
  final List<ProtoField>? payload;
}

_TrayMeta? _readTrayItem(File file) {
  try {
    final raw = file.readAsBytesSync();
    if (raw.length <= _trayHeaderBytes) return null;
    final fields =
        readProtoFields(Uint8List.sublistView(raw, _trayHeaderBytes));
    if (fields.isEmpty) return null;
    final payload = fields.firstBytes(10);
    return _TrayMeta(
      _clean(fields.firstString(4)),
      _clean(fields.firstString(5)),
      _clean(fields.firstString(7)),
      payload == null ? null : readProtoFields(payload),
    );
  } catch (_) {
    return null;
  }
}

/// The sims in a household payload. Each sits under its own wrapper
/// (`f2 { f1: index, f2: sim }`), which is also what keeps the walk honest
/// when a household has eight of them.
List<CreationSim> _readSims(
  _TrayMeta meta,
  Map<int, File> portraits, {
  required List<String> used,
}) {
  final payload = meta.payload;
  if (payload == null) return const [];
  final sims = <CreationSim>[];
  for (final wrapper in payload.allBytes(2)) {
    final record = readProtoFields(wrapper).firstBytes(2);
    if (record == null) continue;
    final sim = readProtoFields(record);
    final first = _clean(sim.firstString(3));
    if (first == null) continue;
    final id = sim.firstInt(5);
    Uint8List? portrait;
    if (id != null) {
      final file = portraits[id];
      if (file != null) {
        used.add(file.path);
        portrait = _readObfuscatedImage(file);
      }
    }
    sims.add(CreationSim(
      firstName: first,
      lastName: _clean(sim.firstString(4)),
      ageKey: _ageKeys[sim.firstInt(9) ?? -1],
      genderKey: _genderKeys[sim.firstInt(6) ?? -1],
      traits: [
        for (final trait in sim.allBytes(10))
          if (_clean(readProtoFields(trait).firstString(2)) case final name?)
            name,
      ],
      aspiration: _clean(
          readProtoFields(sim.firstBytes(11) ?? Uint8List(0)).firstString(2)),
      portrait: portrait,
    ));
  }
  return sims;
}

/// The biggest picture in the set. A household writes a small thumbnail
/// and a full-size portrait; the card wants the one worth looking at.
Uint8List? _bestThumbnail(List<_TrayFile> files) {
  Uint8List? best;
  var bestArea = -1;
  for (final f in files) {
    if (!_thumbnailExtensions.contains(f.extension)) continue;
    final image = _readObfuscatedImage(f.file);
    if (image == null) continue;
    final area = imageArea(image);
    if (area > bestArea) {
      best = image;
      bestArea = area;
    }
  }
  return best;
}

/// Undoes the tray's obfuscation and hands back the image, or null when
/// the file is not one after all.
Uint8List? _readObfuscatedImage(File file) {
  try {
    final raw = file.readAsBytesSync();
    if (raw.length <= _imageHeaderBytes) return null;
    final declared =
        ByteData.sublistView(raw).getUint64(0, Endian.little);
    // The header's own word for how long the image is, checked against the
    // file before a byte of it is trusted.
    if (declared <= 0 ||
        declared > _maxImageBytes ||
        _imageHeaderBytes + declared > raw.length) {
      return null;
    }
    final out = Uint8List(declared);
    for (var i = 0; i < declared; i++) {
      out[i] = raw[_imageHeaderBytes + i] ^ _imageKey[i & 7];
    }
    return isJpeg(out) || isPng(out) ? out : null;
  } catch (_) {
    return null;
  }
}

/// Text the game wrote, with the empty string read as "nothing here" - a
/// tray item with no description carries a zero-length one rather than
/// leaving the field out.
String? _clean(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

/// Whether [paths] are Sims 4 tray files, and the whole of each set they
/// belong to. A tray file announces itself by extension, so nothing has to
/// be opened to decide.
Set<String> sims4TrayFiles(Iterable<String> paths) => {
      for (final path in paths)
        if (_trayName.hasMatch(p.basename(path))) path,
    };

/// The other files of the tray set [path] belongs to, found beside it.
///
/// A user dragging a household in usually drags the `.trayitem` and its
/// payload but forgets a thumbnail, or drops one file of five; the set is
/// what the game needs, so the install goes looking for the rest rather
/// than copying what it was handed and leaving the item half there.
List<String> sims4TraySiblings(String path) {
  final match = _trayName.firstMatch(p.basename(path));
  if (match == null) return [path];
  final instance = int.tryParse(match.group(2)!, radix: 16);
  if (instance == null) return [path];

  final found = <String>{path};
  final beside = <int, String>{};
  try {
    for (final entity in File(path).parent.listSync()) {
      if (entity is! File) continue;
      final sibling = _trayName.firstMatch(p.basename(entity.path));
      if (sibling == null) continue;
      final id = int.tryParse(sibling.group(2)!, radix: 16);
      if (id == null) continue;
      if (id == instance) {
        found.add(entity.path);
      } else if (sibling.group(3)!.toLowerCase() == _simPortraitExtension) {
        beside[id] = entity.path;
      }
    }
  } catch (_) {}

  // The portraits are the one part of a set whose file name does not carry
  // the item's id, so they can only be found by asking the metadata who
  // lives here.
  if (beside.isNotEmpty) {
    for (final candidate in found.toList()) {
      if (p.extension(candidate).toLowerCase() != '.trayitem') continue;
      for (final id in _simIdsOf(File(candidate))) {
        final portrait = beside[id];
        if (portrait != null) found.add(portrait);
      }
    }
  }
  return found.toList();
}

/// The ids of the sims a tray item names, so their portraits can be found
/// beside it. Empty for a lot, a room, and anything that would not parse.
Iterable<int> _simIdsOf(File trayItem) sync* {
  final payload = _readTrayItem(trayItem)?.payload;
  if (payload == null) return;
  for (final wrapper in payload.allBytes(2)) {
    final record = readProtoFields(wrapper).firstBytes(2);
    if (record == null) continue;
    final id = readProtoFields(record).firstInt(5);
    if (id != null) yield id;
  }
}
