import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../../core/dbpf.dart';
import '../../core/protobuf_wire.dart';
import '../../core/save_game.dart';

/// Reads The Sims 4 save slots out of `saves/`.
///
/// A `.save` is a DBPF archive whose resource `0x0000000D` holds the whole
/// world state as one protobuf (the game's own shipped schema; field
/// numbers below match its `FileSerialization` messages and were verified
/// against a real 1.125 save). The archive also carries a handful of plain
/// JPEGs: the load screen's household picture, lot renders keyed by zone
/// id, and sim portraits keyed by sim id.
///
/// Best-effort throughout: a slot that won't parse still appears, named by
/// its file, so the user sees the save exists even when we can't read it.
/// Synchronous on purpose - the adapter runs it inside an isolate.

/// `Slot_XXXXXXXX.save`; everything after (`.ver0`, `.day.ver1`...) is a
/// rolling backup of the same slot.
final _slotName = RegExp(r'^Slot_[0-9A-Fa-f]{8}\.save$', caseSensitive: false);

const _saveGameDataType = 0x0000000D;
const _lotThumbnailType = 0x0000000F;
const _householdThumbnailType = 0x00000014;
const _simPortraitType = 0x00000015;

/// The world blob decompresses to tens of MB on a long-running save; the
/// cap only exists so a corrupt header can't ask for the moon.
const _maxWorldBlobBytes = 512 << 20;

/// Sim age flags, per the game's own serialization enum.
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

const _genderKeys = <int, String>{4096: 'male', 8192: 'female'};

List<SaveGame> scanSims4Saves(String savesPath) {
  final dir = Directory(savesPath);
  if (!dir.existsSync()) return const [];

  // One pass over the folder: slots, and every backup grouped under its
  // slot's file name.
  final slots = <File>[];
  final backupCounts = <String, int>{};
  final backupBytes = <String, int>{};
  try {
    for (final entity in dir.listSync()) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);
      if (_slotName.hasMatch(name)) {
        slots.add(entity);
        continue;
      }
      final dot = name.toLowerCase().indexOf('.save.');
      if (dot < 0) continue;
      final base = name.substring(0, dot + '.save'.length);
      if (!_slotName.hasMatch(base)) continue;
      backupCounts[base] = (backupCounts[base] ?? 0) + 1;
      try {
        backupBytes[base] = (backupBytes[base] ?? 0) + entity.lengthSync();
      } catch (_) {}
    }
  } catch (_) {
    return const [];
  }

  final saves = <SaveGame>[];
  for (final file in slots) {
    final name = p.basename(file.path);
    saves.add(_parseSlot(
      file,
      backupCount: backupCounts[name] ?? 0,
      backupBytes: backupBytes[name] ?? 0,
    ));
  }
  saves.sort((a, b) {
    final at = a.modifiedAt, bt = b.modifiedAt;
    if (at == null || bt == null) return at == bt ? 0 : (at == null ? 1 : -1);
    return bt.compareTo(at);
  });
  return saves;
}

SaveGame _parseSlot(File file,
    {required int backupCount, required int backupBytes}) {
  DateTime? modified;
  var size = backupBytes;
  try {
    final stat = file.statSync();
    modified = stat.modified;
    size += stat.size;
  } catch (_) {}
  final fallback = SaveGame(
    name: p.basenameWithoutExtension(file.path),
    path: file.path,
    modifiedAt: modified,
    sizeBytes: size,
    backupCount: backupCount,
  );

  RandomAccessFile? raf;
  try {
    raf = file.openSync();
    final entries = readDbpfIndex(raf);
    if (entries == null) return fallback;

    Uint8List? world;
    Uint8List? thumbnail;
    final lotImages = <int, Uint8List>{};
    final simImages = <int, Uint8List>{};
    for (final e in entries) {
      switch (e.type) {
        case _saveGameDataType:
          world = readDbpfResource(raf, e, maxBytes: _maxWorldBlobBytes);
        case _householdThumbnailType:
          thumbnail = readDbpfResource(raf, e);
        case _lotThumbnailType:
          final image = readDbpfResource(raf, e);
          if (image != null) lotImages[e.instance] = image;
        case _simPortraitType:
          final image = readDbpfResource(raf, e);
          if (image != null) simImages[e.instance] = image;
      }
    }
    if (world == null) return fallback;
    return _buildSave(fallback, readProtoFields(world),
        thumbnail: thumbnail, lotImages: lotImages, simImages: simImages);
  } catch (_) {
    return fallback;
  } finally {
    try {
      raf?.closeSync();
    } catch (_) {}
  }
}

SaveGame _buildSave(SaveGame base, List<ProtoField> top,
    {Uint8List? thumbnail,
    required Map<int, Uint8List> lotImages,
    required Map<int, Uint8List> simImages}) {
  final slot = readProtoFields(top.firstBytes(2) ?? Uint8List(0));
  final account = readProtoFields(top.firstBytes(3) ?? Uint8List(0));
  final activeHouseholdId = slot.firstInt(11);

  final worlds = <String>[
    for (final neighborhood in top.allBytes(4))
      ...?_nonEmpty(readProtoFields(neighborhood).firstString(3)),
  ];

  // zone id -> what the save says about the lot.
  final zones = <int, ({String? name, int? bedrooms, int? bathrooms})>{};
  for (final zone in top.allBytes(7)) {
    final fields = readProtoFields(zone);
    final id = fields.firstInt(1);
    if (id == null) continue;
    zones[id] = (
      name: fields.firstString(2),
      bedrooms: fields.firstInt(16),
      bathrooms: fields.firstInt(17),
    );
  }

  // household id -> members. Sims carry their household's id themselves;
  // the handful that name none are sims the save is still carrying rather
  // than sims anyone lives with, and go uncounted.
  final membersByHousehold = <int, List<SaveSim>>{};
  for (final sim in top.allBytes(6)) {
    final fields = readProtoFields(sim);
    final firstName = fields.firstString(5);
    if (firstName == null || firstName.isEmpty) continue;
    final householdId = fields.firstInt(4);
    if (householdId == null) continue;
    membersByHousehold.putIfAbsent(householdId, () => []).add(SaveSim(
          firstName: firstName,
          lastName: fields.firstString(6),
          ageKey: _ageKeys[fields.firstInt(8)],
          genderKey: _genderKeys[fields.firstInt(7)],
          portrait: simImages[fields.firstInt(1)],
        ));
  }

  final households = <SaveHousehold>[];
  for (final household in top.allBytes(5)) {
    final fields = readProtoFields(household);
    final name = fields.firstString(3);
    if (name == null || name.isEmpty) continue;
    final id = fields.firstInt(2);
    final homeZone = fields.firstInt(4);
    final lot = homeZone == null ? null : zones[homeZone];
    households.add(SaveHousehold(
      name: name,
      funds: fields.firstInt(5),
      lotName: lot?.name,
      bedrooms: lot?.bedrooms,
      bathrooms: lot?.bathrooms,
      isPlayed: fields.firstInt(31) == 1 ||
          (activeHouseholdId != null && id == activeHouseholdId),
      description: _nonEmpty(fields.firstString(18))?.first,
      creatorName: _nonEmpty(fields.firstString(21))?.first,
      portrait: homeZone == null ? null : lotImages[homeZone],
      members: membersByHousehold[id] ?? const [],
    ));
  }
  // Played households are what the user came to see; the townie roster
  // follows, alphabetically, rather than being hidden.
  households.sort((a, b) {
    if (a.isPlayed != b.isPlayed) return a.isPlayed ? -1 : 1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });

  final photos = <SavePhoto>[
    for (final entry in lotImages.entries)
      SavePhoto(
          bytes: entry.value, kindKey: 'lot', caption: zones[entry.key]?.name),
    for (final household in households)
      for (final member in household.members)
        if (member.portrait != null)
          SavePhoto(
              bytes: member.portrait, kindKey: 'sim', caption: member.fullName),
  ];

  return SaveGame(
    name: _nonEmpty(slot.firstString(9))?.first ?? base.name,
    path: base.path,
    modifiedAt: base.modifiedAt,
    sizeBytes: base.sizeBytes,
    backupCount: base.backupCount,
    gameVersion: account.firstString(10),
    thumbnail: thumbnail,
    households: households,
    photos: photos,
    worldsVisited: worlds,
  );
}

/// Wraps a string as a single-element list so `...?` can splice it, and
/// treats empty as absent - the serializer writes `""` for unset fields.
List<String>? _nonEmpty(String? value) =>
    value == null || value.isEmpty ? null : [value];
