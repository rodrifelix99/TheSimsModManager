import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../../core/dbpf.dart';
import '../../core/save_game.dart';

/// Reads The Sims 3 saves - and The Sims Medieval's, which kept the same
/// engine and save layout: a folder per save (`<name>.sims3` / `<name>.tsm`)
/// holding `Meta.data` (a tiny DBPF with the save's world name, household
/// name and description), `1a5tf1l3.dat` (which world file is home), and
/// one DBPF `.nhd` per world the save has visited.
///
/// The gameplay state inside the `.nhd` is an undocumented serialized blob
/// nobody has parsed outside the game, so funds and sim stats are out of
/// reach; what the world file does give up is images - the exact picture
/// the game's load screen shows, family portraits, sim snapshots and lot
/// renders, all plain PNGs at fixed resource types.
///
/// Synchronous on purpose - the adapter runs it inside an isolate.

/// The save-metadata resource in `Meta.data`.
const _saveInfoType = 0x628A788F;

/// Family portraits, three sizes. The medium one is the load screen's.
const _familyPortraitSmall = 0x6B6D837D;
const _familyPortrait = 0x6B6D837E;
const _familyPortraitLarge = 0x6B6D837F;

/// Sim snapshots (SNAP), medium size; small is 0x0580A2CD, large 0x0580A2CF.
const _simPortrait = 0x0580A2CE;

/// Lot thumbnails, medium size; small is 0xD84E7FC5.
const _lotThumbnail = 0xD84E7FC6;

/// A long-lived world keeps every portrait it ever rendered - tens of
/// thousands in the wild - and each one read here is held in memory, so
/// the album takes a slice, not the archive.
const _maxFamilyPhotos = 16;
const _maxSimPhotos = 24;
const _maxLotPhotos = 16;

List<SaveGame> scanSims3Saves(String savesPath, {required String extension}) {
  final dir = Directory(savesPath);
  if (!dir.existsSync()) return const [];

  final folders = <Directory>[];
  final backups = <String, Directory>{};
  try {
    for (final entity in dir.listSync()) {
      if (entity is! Directory) continue;
      final name = p.basename(entity.path).toLowerCase();
      if (name.endsWith('$extension.backup')) {
        backups[entity.path
            .substring(0, entity.path.length - '.backup'.length)] = entity;
      } else if (name.endsWith(extension)) {
        folders.add(entity);
      }
      // `.bad` folders are the corpse of a failed save; nothing to show.
    }
  } catch (_) {
    return const [];
  }

  final saves = <SaveGame>[
    for (final folder in folders) _parseSave(folder, backups[folder.path]),
  ];
  saves.sort((a, b) {
    final at = a.modifiedAt, bt = b.modifiedAt;
    if (at == null || bt == null) return at == bt ? 0 : (at == null ? 1 : -1);
    return bt.compareTo(at);
  });
  return saves;
}

SaveGame _parseSave(Directory folder, Directory? backup) {
  final name = p.basenameWithoutExtension(folder.path);
  var size = 0;
  DateTime? modified;
  final worldFiles = <File>[];
  try {
    for (final entity in folder.listSync()) {
      if (entity is! File) continue;
      try {
        final stat = entity.statSync();
        size += stat.size;
        if (modified == null || stat.modified.isAfter(modified)) {
          modified = stat.modified;
        }
      } catch (_) {}
      if (p.extension(entity.path).toLowerCase() == '.nhd') {
        worldFiles.add(entity);
      }
    }
    if (backup != null) {
      for (final entity in backup.listSync(recursive: true)) {
        if (entity is File) {
          try {
            size += entity.lengthSync();
          } catch (_) {}
        }
      }
    }
  } catch (_) {}

  final meta = _readMeta(File(p.join(folder.path, 'Meta.data')));
  final active = _activeWorldFile(folder, worldFiles);

  Uint8List? thumbnail;
  final photos = <SavePhoto>[];
  // The home world first, so the save's own picture is found there and
  // its portraits open the album; the places the save has travelled to
  // (vacation worlds, university) contribute the rest.
  final ordered = [
    if (active != null) active,
    for (final file in worldFiles)
      if (file.path != active?.path) file,
  ];
  for (final world in ordered) {
    final home = identical(world, active);
    _readWorldImages(
      world,
      home ? meta?.imageCandidates ?? const [] : const [],
      home ? (thumb) => thumbnail = thumb : (_) {},
      photos,
      worldName: _worldNameOf(world.path),
      // Only the home world is worth a full album; the others chip in
      // their best few so a well-travelled save doesn't blow the budget.
      generous: home,
    );
  }

  final household = meta?.householdName;
  return SaveGame(
    name: name,
    path: folder.path,
    modifiedAt: modified,
    sizeBytes: size,
    backupCount: backup == null ? 0 : 1,
    worldName: meta?.worldName,
    description: meta?.description,
    gameVersion: meta?.gameVersion,
    thumbnail: thumbnail,
    households: [
      if (household != null && household.isNotEmpty)
        SaveHousehold(name: household, portrait: thumbnail),
    ],
    photos: photos,
    worldsVisited: [
      for (final file in worldFiles) _worldNameOf(file.path),
    ],
  );
}

/// `Sunset Valley_0x0859db3c.nhd` -> `Sunset Valley`.
String _worldNameOf(String path) {
  final base = p.basenameWithoutExtension(path);
  final marker = base.lastIndexOf('_0x');
  return marker > 0 ? base.substring(0, marker) : base;
}

/// The world the save calls home: named by `1a5tf1l3.dat` (a UTF-8 string
/// with two trailing bytes, without the `.nhd` extension), or the only /
/// largest world file when the pointer is missing or stale.
File? _activeWorldFile(Directory folder, List<File> worldFiles) {
  try {
    final dat = File(p.join(folder.path, '1a5tf1l3.dat'));
    if (dat.existsSync()) {
      final bytes = dat.readAsBytesSync();
      if (bytes.length > 2) {
        final stem = utf8.decode(bytes.sublist(0, bytes.length - 2),
            allowMalformed: true);
        for (final candidate in [
          File(p.join(folder.path, '$stem.nhd')),
          File(p.join(folder.path, stem)),
        ]) {
          if (candidate.existsSync()) return candidate;
        }
      }
    }
  } catch (_) {}
  if (worldFiles.isEmpty) return null;
  File? largest;
  var largestSize = -1;
  for (final file in worldFiles) {
    try {
      final length = file.lengthSync();
      if (length > largestSize) {
        largest = file;
        largestSize = length;
      }
    } catch (_) {}
  }
  return largest;
}

class _SaveMeta {
  const _SaveMeta(this.worldName, this.householdName, this.description,
      this.gameVersion, this.imageCandidates);

  final String? worldName;
  final String? householdName;
  final String? description;

  /// The game build that wrote the save, e.g. `21.0.175.024017`.
  final String? gameVersion;

  /// Possible instance ids of the save's own load-screen picture, most
  /// plausible first (see [_readMeta]).
  final List<int> imageCandidates;
}

/// A version-number tail string: digits and dots only. The others name
/// the store and the installed content (`0.Steam-0.0.32`, `1.ep1-0.rl.25`),
/// which carry letters.
final _versionString = RegExp(r'^[0-9][0-9.]+$');

/// The `0x628A788F` resource: a magic word, then world name, household
/// name and description as int32-length-prefixed UTF-16LE strings, the
/// picture's instance as a uint64, another id, and finally a run of
/// strings naming the store, the installed content and the game build.
///
/// The picture instance is read positionally but not trusted: the tail's
/// layout has grown over patches, so every aligned uint64 from that point
/// on is collected as a candidate and the world file decides which one
/// names a portrait it actually has.
_SaveMeta? _readMeta(File file) {
  RandomAccessFile? raf;
  try {
    raf = file.openSync();
    final entries = readDbpfIndex(raf);
    if (entries == null) return null;
    Uint8List? blob;
    for (final e in entries) {
      if (e.type == _saveInfoType) {
        blob = readDbpfResource(raf, e);
        break;
      }
    }
    if (blob == null) return null;
    final d = ByteData.sublistView(blob);
    var pos = 4; // version/magic word

    String? readString() {
      if (pos + 4 > blob!.length) return null;
      final chars = d.getInt32(pos, Endian.little);
      pos += 4;
      if (chars < 0 || pos + chars * 2 > blob.length) return null;
      final s = String.fromCharCodes([
        for (var i = 0; i < chars; i++) d.getUint16(pos + i * 2, Endian.little),
      ]);
      pos += chars * 2;
      return s;
    }

    final world = readString();
    final household = readString();
    final description = readString();
    final candidates = <int>[];
    for (var at = pos; at + 8 <= blob.length; at += 4) {
      final value = d.getUint64(at, Endian.little);
      if (value != 0 && !candidates.contains(value)) candidates.add(value);
    }

    // The content/version strings after the two ids. Read positionally
    // (the picture instance and one more id, then strings until the
    // terminator); a tail that doesn't parse simply yields no version.
    String? version;
    pos += 16;
    while (pos + 4 <= blob.length) {
      final before = pos;
      final value = readString();
      if (value == null || value.isEmpty || pos == before) break;
      if (_versionString.hasMatch(value)) version = value;
    }
    return _SaveMeta(world, household, description, version, candidates);
  } catch (_) {
    return null;
  } finally {
    try {
      raf?.closeSync();
    } catch (_) {}
  }
}

/// Pulls the load-screen picture and an album's worth of portraits out of
/// [world]. The index of a late-game world lists tens of thousands of
/// resources; only the images taken are read. [generous] is the home
/// world's larger share of the album; the places the save has visited
/// contribute a few each, captioned by [worldName].
void _readWorldImages(File world, List<int> thumbnailCandidates,
    void Function(Uint8List) onThumbnail, List<SavePhoto> photos,
    {required String worldName, required bool generous}) {
  RandomAccessFile? raf;
  try {
    raf = world.openSync();
    final entries = readDbpfIndex(raf);
    if (entries == null) return;

    final familyPortraits = <DbpfEntry>[];
    final simPortraits = <DbpfEntry>[];
    final lotThumbnails = <DbpfEntry>[];
    for (final e in entries) {
      switch (e.type) {
        case _familyPortrait:
          familyPortraits.add(e);
        case _simPortrait:
          simPortraits.add(e);
        case _lotThumbnail:
          lotThumbnails.add(e);
      }
    }

    // The save's own picture: the family portrait whose instance the
    // metadata names. Tried at every size, sharpest first; when nothing
    // matches (Medieval, or a stale pointer) the biggest portrait stands
    // in - a family picture either way.
    Uint8List? thumbnail;
    for (final candidate in thumbnailCandidates) {
      for (final type in const [
        _familyPortraitLarge,
        _familyPortrait,
        _familyPortraitSmall,
      ]) {
        for (final e in entries) {
          if (e.type != type || e.instance != candidate) continue;
          thumbnail = readDbpfResource(raf, e);
          if (thumbnail != null && isPng(thumbnail)) break;
          thumbnail = null;
        }
        if (thumbnail != null) break;
      }
      if (thumbnail != null) break;
    }
    if (thumbnail == null && familyPortraits.isNotEmpty) {
      final biggest =
          familyPortraits.reduce((a, b) => a.probeSize >= b.probeSize ? a : b);
      final data = readDbpfResource(raf, biggest);
      if (data != null && isPng(data)) thumbnail = data;
    }
    if (thumbnail != null) onThumbnail(thumbnail);

    void take(List<DbpfEntry> pool, int cap, String kindKey) {
      // Biggest first: with no names to go by, the sharpest renders are
      // the ones worth an album slot.
      pool.sort((a, b) => b.probeSize.compareTo(a.probeSize));
      var taken = 0;
      for (final e in pool) {
        if (taken >= cap) break;
        final data = readDbpfResource(raf!, e);
        if (data == null || !isPng(data)) continue;
        photos
            .add(SavePhoto(bytes: data, kindKey: kindKey, caption: worldName));
        taken++;
      }
    }

    final share = generous ? 1 : 4; // visited worlds get a quarter each
    take(familyPortraits, _maxFamilyPhotos ~/ share, 'familyPortrait');
    take(simPortraits, _maxSimPhotos ~/ share, 'sim');
    take(lotThumbnails, _maxLotPhotos ~/ share, 'lot');
  } catch (_) {
    // A world that can't be read costs its pictures, not the save row.
  } finally {
    try {
      raf?.closeSync();
    } catch (_) {}
  }
}
