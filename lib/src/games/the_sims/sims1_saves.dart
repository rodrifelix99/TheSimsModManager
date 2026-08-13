import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../../core/bitmap.dart';
import '../../core/game_text.dart';
import '../../core/save_game.dart';

/// Reads The Sims 1 neighborhoods out of the install's `UserData` folders.
///
/// Everything lives in EA's IFF container: `UserData<n>/Neighborhood.iff`
/// holds every sim (NBRS chunk: names, the person-data array with skills
/// and personality, the relationship maps), every family (FAMI: funds,
/// house number, member GUIDs) and every family name (FAMs, a string
/// table sharing the family's chunk id). Display names come from each
/// sim's character file (`Characters/User00000.iff`, body-strings STR#
/// index 11) and house names from `Houses/NeighborhoodDesc.iff` (STR#
/// chunk `house + 2000`), the way the game itself resolves them.
///
/// Layouts follow FreeSO's parsers (the open-source reimplementation),
/// including its tolerance for real-world dirt: tombstoned NBRS entries,
/// truncated chunks, sizes past EOF. Sims themselves are sprite
/// composites the game assembles at runtime, so there is no such thing
/// as a portrait here; what it does keep is a rendered picture of every
/// house, which stands in for the family living there.
///
/// Synchronous on purpose - the adapter runs it inside an isolate.

/// Personality and skills live in the person-data array at these indices,
/// values 0-1000 (100 per displayed point). Generous (index 4) exists in
/// the data but the game never shows it, so neither do we.
const _personalityIndices = <String, int>{
  'nice': 2,
  'active': 3,
  'playful': 5,
  'outgoing': 6,
  'neat': 7,
};

const _skillIndices = <String, int>{
  'cooking': 10,
  'charisma': 11,
  'mechanical': 12,
  'creativity': 15,
  'body': 17,
  'logic': 18,
};

/// Person-data index of the sim's family number (the FAMI chunk id).
const _familyNumberIndex = 61;

/// Person-data index of gender: 0 human male, 1 human female; 8/9 and
/// 16/17 are Unleashed's dogs and cats.
const _genderIndex = 65;

/// Person-data index of the flag the game sets when a sim has died and
/// stayed on as a ghost.
const _ghostIndex = 68;

/// Person-data index saying what kind of resident this is: 0 a member of
/// the played family, 1 a townie or visitor, and 254 up the service NPCs
/// that are avatars only as far as the engine is concerned.
const _personTypeIndex = 32;

/// Person-data index of the sim's age, in years. The game has no life
/// stages beyond these two and never shows the number itself.
const _ageIndex = 58;

/// Below this a sim is a child; 0 counts as one too, since a record that
/// never had an age written is a child's.
const _adultAge = 18;

/// The chunk id of a house's thumbnail with its roof on, inside
/// `Houses/HouseNN.iff`. 512 is the same shot with the roof taken off,
/// which the game cross-fades to on hover and this has no use for.
const houseThumbnailChunk = 513;

/// Above this a neighbor is one of those props rather than somebody who
/// lives here, and counting them would inflate every total.
const _npcPersonType = 254;

List<SaveGame> scanSims1Saves(String installPath) {
  final root = Directory(installPath);
  if (!root.existsSync()) return const [];

  final saves = <SaveGame>[];
  try {
    for (final entity in root.listSync()) {
      if (entity is! Directory) continue;
      final name = p.basename(entity.path);
      final match =
          RegExp(r'^UserData(\d*)$', caseSensitive: false).firstMatch(name);
      if (match == null) continue;
      final number = match.group(1)!.isEmpty ? 1 : int.parse(match.group(1)!);
      final save = _parseNeighborhood(entity, number);
      if (save != null) saves.add(save);
    }
  } catch (_) {
    return const [];
  }
  saves.sort((a, b) =>
      (a.neighborhoodNumber ?? 0).compareTo(b.neighborhoodNumber ?? 0));
  return saves;
}

SaveGame? _parseNeighborhood(Directory userData, int number) {
  final file = File(p.join(userData.path, 'Neighborhood.iff'));
  if (!file.existsSync()) return null;

  DateTime? modified;
  var size = 0;
  try {
    final stat = file.statSync();
    modified = stat.modified;
    size = stat.size;
  } catch (_) {}

  List<IffChunk> chunks;
  try {
    chunks = readIffChunks(file.readAsBytesSync());
  } catch (_) {
    chunks = const [];
  }
  if (chunks.isEmpty) {
    return SaveGame(
      name: p.basename(userData.path),
      path: userData.path,
      neighborhoodNumber: number,
      modifiedAt: modified,
      sizeBytes: size,
    );
  }

  final neighbors = <_Neighbor>[];
  for (final chunk in chunks.where((c) => c.type == 'NBRS')) {
    // The service NPCs the engine keeps as neighbors are props, not
    // residents; nothing on this screen should count them.
    neighbors.addAll(_parseNbrs(chunk.data).where((neighbor) =>
        (neighbor.personData(_personTypeIndex) ?? 0) < _npcPersonType));
  }
  final familyNames = <int, String>{
    for (final chunk in chunks.where((c) => c.type == 'FAMs'))
      chunk.id: _firstOrEmpty(parseIffStrings(chunk.data)),
  };

  final characterNames = _CharacterNames(userData);
  final houseNames = _HouseNames(userData);
  final byGuid = {for (final n in neighbors) n.guid: n};
  final byId = {for (final n in neighbors) n.neighborId: n};

  final households = <SaveHousehold>[];
  for (final chunk in chunks.where((c) => c.type == 'FAMI')) {
    if (chunk.id == 0) continue; // family number 0 means "no family"
    final family = _parseFami(chunk.data);
    if (family == null) continue;

    final members = <_Neighbor>[];
    for (final guid in family.memberGuids) {
      final neighbor = byGuid[guid];
      if (neighbor != null) members.add(neighbor);
    }
    // Membership is stored in both directions; pick up anyone the GUID
    // list lost but who still claims this family.
    for (final neighbor in neighbors) {
      if (neighbor.personData(_familyNumberIndex) == chunk.id &&
          !members.contains(neighbor)) {
        members.add(neighbor);
      }
    }

    final sims = [
      for (final neighbor in members)
        _toSim(neighbor, characterNames.of(neighbor.name),
            characterNames.bioOf(neighbor.name)),
    ];
    final name = familyNames[chunk.id];
    if ((name == null || name.isEmpty) && sims.isEmpty) continue;

    households.add(SaveHousehold(
      name: name != null && name.isNotEmpty ? name : sims.first.fullName,
      funds: family.budget,
      // Only a family that has moved in owns anything; an unhoused one
      // carrying a stale figure would read as a fortune it doesn't have.
      propertyValue: family.houseNumber > 0 && family.valueInArchitecture > 0
          ? family.valueInArchitecture
          : null,
      lotName:
          family.houseNumber > 0 ? houseNames.of(family.houseNumber) : null,
      description: family.houseNumber > 0
          ? houseNames.descriptionOf(family.houseNumber)
          : null,
      // The game's own picture of the house they live in - the closest
      // this game comes to a family portrait, since the sims themselves
      // are only ever drawn from sprites at runtime.
      portrait: family.houseNumber > 0
          ? _houseThumbnail(userData, family.houseNumber)
          : null,
      // A family the game marks as its own (-1) or that has never moved
      // in belongs under "other households": the shipped neighborhood
      // keeps the Pleasants, the Roomies and Bachelor in the bin at
      // 20,000 simoleons apiece, and they are nobody's save yet.
      isPlayed: family.familyNumber != -1 && family.houseNumber > 0,
      members: sims,
      relationships: _familyBonds(members, byId, characterNames),
    ));
  }
  households.sort((a, b) {
    if (a.isPlayed != b.isPlayed) return a.isPlayed ? -1 : 1;
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });

  return SaveGame(
    name: p.basename(userData.path),
    path: userData.path,
    neighborhoodNumber: number,
    modifiedAt: modified,
    sizeBytes: size,
    // The first house with a picture stands for the neighborhood, and
    // the rest make up its album.
    thumbnail: households
        .map((household) => household.portrait)
        .firstWhere((portrait) => portrait != null, orElse: () => null),
    households: households,
    photos: [
      for (final household in households)
        if (household.portrait != null)
          SavePhoto(
              bytes: household.portrait,
              kindKey: 'lot',
              caption: household.lotName ?? household.name),
    ],
  );
}

/// The rendered picture of house [number], as a PNG. The game stores it
/// as a plain Windows bitmap inside the house's own file, with magenta
/// standing in for transparency.
Uint8List? _houseThumbnail(Directory userData, int number) {
  try {
    final file = File(p.join(userData.path, 'Houses',
        'House${number.toString().padLeft(2, '0')}.iff'));
    if (!file.existsSync()) return null;
    for (final chunk in readIffChunks(file.readAsBytesSync())) {
      if (chunk.type == 'BMP_' && chunk.id == houseThumbnailChunk) {
        return bmpToPng(chunk.data);
      }
    }
  } catch (_) {
    // A house file that won't open costs its picture, nothing else.
  }
  return null;
}

SaveSim _toSim(_Neighbor neighbor, String? displayName, String? bio) {
  Map<String, int> readValues(Map<String, int> indices) => {
        for (final entry in indices.entries)
          if (neighbor.personData(entry.value) case final value?
              when value >= 0)
            entry.key: value > 1000 ? 1000 : value,
      };

  // Unleashed's pets are sims with a flag in the gender field rather
  // than a species of their own: 8 marks a dog, 16 a cat, and the low
  // bit is still male/female.
  final gender = neighbor.personData(_genderIndex) ?? 0;
  final age = neighbor.personData(_ageIndex) ?? 0;
  return SaveSim(
    firstName: displayName ?? neighbor.name,
    bio: bio,
    // The game only ever knows a sim as grown up or not, and stores that
    // as a year count it never shows.
    ageKey: age > 0 && age < _adultAge ? 'child' : 'adult',
    genderKey: switch (gender & 0x1) {
      0 => 'male',
      _ => 'female',
    },
    occultKey: gender & 0x8 != 0
        ? 'largeDog'
        : gender & 0x10 != 0
            ? 'cat'
            : null,
    isGhost: (neighbor.personData(_ghostIndex) ?? 0) != 0,
    skills: readValues(_skillIndices),
    personality: readValues(_personalityIndices),
  );
}

/// Bonds between members of one family: relationship value 0 of each
/// sim's outgoing map, averaged with the reverse direction when both
/// exist (the game keeps the two sides separately).
List<SaveRelationship> _familyBonds(
    List<_Neighbor> members, Map<int, _Neighbor> byId, _CharacterNames names) {
  final bonds = <SaveRelationship>[];
  for (var i = 0; i < members.length; i++) {
    for (var j = i + 1; j < members.length; j++) {
      final a = members[i], b = members[j];
      final abValues = a.relationships[b.neighborId];
      final baValues = b.relationships[a.neighborId];
      final ab = abValues == null || abValues.isEmpty ? null : abValues.first;
      final ba = baValues == null || baValues.isEmpty ? null : baValues.first;
      if (ab == null && ba == null) continue;
      final score = ab == null
          ? ba!
          : ba == null
              ? ab
              : ((ab + ba) / 2).round();
      bonds.add(SaveRelationship(
        nameA: names.of(a.name) ?? a.name,
        nameB: names.of(b.name) ?? b.name,
        score: score.clamp(-100, 100).toInt(),
      ));
    }
  }
  bonds.sort((a, b) => b.score.compareTo(a.score));
  return bonds;
}

// ---------------------------------------------------------------------------
// The IFF container (EA's variant): a 64-byte file header, then chunks
// back to back. Chunk headers are big-endian, chunk payloads little-endian.
//
// Public because `sims1_creations.dart` reads the same containers: a
// downloaded house is one of these files, and a second copy of a parser
// this hard-won would only ever drift from the one that is tested.

class IffChunk {
  const IffChunk(this.type, this.id, this.data);

  final String type;
  final int id;
  final Uint8List data;
}

List<IffChunk> readIffChunks(Uint8List bytes) {
  if (bytes.length < 64) return const [];
  final signature = latin1.decode(bytes.sublist(0, 60)).split('\x00').first;
  if (!signature.startsWith('IFF FILE')) return const [];

  final chunks = <IffChunk>[];
  final d = ByteData.sublistView(bytes);
  var pos = 64;
  while (pos + 76 <= bytes.length) {
    final type = latin1.decode(bytes.sublist(pos, pos + 4));
    final declared = d.getUint32(pos + 4); // big-endian, includes the header
    final id = d.getUint16(pos + 8);
    // Corrupt files declare sizes past EOF (FreeSO cites walls2.iff):
    // clamp to what is actually there.
    final dataSize = (declared - 76).clamp(0, bytes.length - pos - 76);
    chunks.add(IffChunk(
        type, id, Uint8List.sublistView(bytes, pos + 76, pos + 76 + dataSize)));
    if (declared <= 76) break; // malformed: no forward progress possible
    pos += declared;
  }
  return chunks;
}

// ---------------------------------------------------------------------------
// NBRS: every sim in the neighborhood.

class _Neighbor {
  _Neighbor(this.name, this.neighborId, this.guid, this._personData,
      this.relationships);

  /// The character file's stem (`User00000`), not the display name.
  final String name;
  final int neighborId;
  final int guid;
  final List<int> _personData;

  /// Target neighbor id -> relationship values (index 0 is the score).
  final Map<int, List<int>> relationships;

  int? personData(int index) =>
      index < _personData.length ? _personData[index] : null;
}

List<_Neighbor> _parseNbrs(Uint8List data) {
  final neighbors = <_Neighbor>[];
  final reader = _LeReader(data);
  try {
    reader.skip(12); // pad, version, 'SRBN'
    final count = reader.uint32();
    for (var i = 0; i < count && reader.hasBytes(4); i++) {
      final present = reader.int32();
      if (present != 1) continue; // tombstone: 4 bytes and nothing else
      final version = reader.int32();
      if (version == 0xA) reader.skip(4);
      final name = reader.cString();
      if (name.length.isEven) reader.skip(1); // pad to even name+NUL bytes
      reader.skip(4); // mystery zero
      final personMode = reader.int32();
      var personData = const <int>[];
      if (personMode > 0) {
        final blockBytes = version == 0x4 ? 0xA0 : 0x200;
        final shorts = blockBytes ~/ 2;
        personData = [
          for (var s = 0; s < shorts && s < 88; s++) reader.int16(),
        ];
        reader.skip(blockBytes - personData.length * 2);
      }
      final neighborId = reader.int16();
      final guid = reader.uint32();
      reader.skip(4); // usually -1
      final relationships = <int, List<int>>{};
      final entryCount = reader.int32();
      for (var e = 0; e < entryCount && reader.hasBytes(4); e++) {
        final keyCount = reader.int32();
        var target = 0;
        for (var k = 0; k < keyCount; k++) {
          target = reader.int32();
        }
        final valueCount = reader.int32();
        relationships[target] = [
          for (var v = 0; v < valueCount; v++) reader.int32().toSigned(16),
        ];
      }
      neighbors
          .add(_Neighbor(name, neighborId, guid, personData, relationships));
    }
  } catch (_) {
    // A truncated entry list keeps what parsed cleanly, like FreeSO.
  }
  return neighbors;
}

// ---------------------------------------------------------------------------
// FAMI: one family's funds, house and members.

class _Family {
  const _Family(this.houseNumber, this.familyNumber, this.budget,
      this.valueInArchitecture, this.memberGuids);

  final int houseNumber;

  /// -1 marks the game's own townie families.
  final int familyNumber;
  final int budget;

  /// What the game values the family's house and its contents at. The
  /// game itself adds this to the budget when it quotes what a family is
  /// worth, so it is the other half of "how well are they doing".
  final int valueInArchitecture;
  final List<int> memberGuids;
}

_Family? _parseFami(Uint8List data) {
  final reader = _LeReader(data);
  try {
    reader.skip(12); // pad, version, 'IMAF'
    final houseNumber = reader.int32();
    final familyNumber = reader.int32();
    final budget = reader.int32();
    final valueInArchitecture = reader.int32();
    reader.skip(8); // family friends, flags
    final count = reader.int32();
    final guids = <int>[];
    for (var i = 0; i < count && reader.hasBytes(4); i++) {
      guids.add(reader.uint32());
    }
    return _Family(
        houseNumber, familyNumber, budget, valueInArchitecture, guids);
  } catch (_) {
    return null;
  }
}

// ---------------------------------------------------------------------------
// STR# string tables (FAMs and CTSS are the same format under other
// names). Only the default-language strings are wanted. Public for the
// same reason as [readIffChunks].

List<String> parseIffStrings(Uint8List data) {
  final reader = _LeReader(data);
  try {
    if (!reader.hasBytes(2)) return const [];
    final format = reader.int16();
    switch (format) {
      case 0: // Pascal strings, English only
        final count = reader.uint16();
        return [
          for (var i = 0; i < count && reader.hasBytes(1); i++)
            reader.pascalString(),
        ];
      case -1: // NUL-terminated, English only
        final count = reader.uint16();
        return [
          for (var i = 0; i < count && reader.hasBytes(1); i++)
            reader.cString(),
        ];
      case -2: // value + comment pairs
        final count = reader.uint16();
        return [
          for (var i = 0; i < count && reader.hasBytes(1); i++)
            (() {
              final value = reader.cString();
              reader.cString(); // comment
              return value;
            })(),
        ];
      case -3: // language-coded entries; 0/1 are English US
        final count = reader.uint16();
        final english = <String>[];
        for (var i = 0; i < count && reader.hasBytes(2); i++) {
          final language = reader.uint8();
          final value = reader.cString();
          reader.cString(); // comment
          if (language <= 1) english.add(value);
        }
        return english;
      default: // -4 is TSO-only; anything else is not a string table
        return const [];
    }
  } catch (_) {
    return const [];
  }
}

// ---------------------------------------------------------------------------
// Display names, resolved the way the game does.

/// Sim display names out of `Characters/User00000.iff`: the body-strings
/// STR# chunk (id 200 by convention, the only STR# otherwise), string 11.
/// Townie templates keep several names there separated by `;`; the first
/// stands in, since the roll the game made is not recorded here.
class _CharacterNames {
  _CharacterNames(Directory userData)
      : _folder = Directory(p.join(userData.path, 'Characters'));

  final Directory _folder;
  Map<String, String>? _files;
  final Map<String, ({String? name, String? bio})> _cache = {};

  String? of(String stem) => _read(stem).name;

  String? bioOf(String stem) => _read(stem).bio;

  ({String? name, String? bio}) _read(String stem) =>
      _cache.putIfAbsent(stem, () {
        final files = _files ??= _list();
        final path = files[stem.toLowerCase()];
        if (path == null) return (name: null, bio: null);
        try {
          final chunks = readIffChunks(File(path).readAsBytesSync());
          // The sim's own catalog description: name first, then the
          // biography. The body strings also carry a name at index 11,
          // but that is the pool a townie's name is rolled from rather
          // than the name this sim ended up with.
          for (final chunk in chunks) {
            if (chunk.type != 'CTSS') continue;
            final strings = parseIffStrings(chunk.data);
            if (strings.isEmpty) continue;
            final name = strings.first.trim();
            if (name.isEmpty) continue;
            final bio = (strings.length > 1 ? strings[1] : '').trim();
            return (name: name, bio: bio.isEmpty ? null : bio);
          }
          // No catalog description: fall back to the body-string pool,
          // which is all a template-spawned sim ever had.
          final strChunks = chunks.where((c) => c.type == 'STR#').toList();
          if (strChunks.isEmpty) return (name: null, bio: null);
          final body = strChunks.firstWhere((c) => c.id == 200,
              orElse: () => strChunks.first);
          final strings = parseIffStrings(body.data);
          if (strings.length <= 11) return (name: null, bio: null);
          final name = strings[11]
              .split(';')
              .firstWhere((part) => part.trim().isNotEmpty, orElse: () => '')
              .trim();
          return (name: name.isEmpty ? null : name, bio: null);
        } catch (_) {
          return (name: null, bio: null);
        }
      });

  Map<String, String> _list() {
    final files = <String, String>{};
    try {
      for (final entity in _folder.listSync()) {
        if (entity is File &&
            p.extension(entity.path).toLowerCase() == '.iff') {
          files[p.basenameWithoutExtension(entity.path).toLowerCase()] =
              entity.path;
        }
      }
    } catch (_) {}
    return files;
  }
}

/// House names out of the description IFFs, keyed `house + 2000`: houses
/// below 80 in `NeighborhoodDesc.iff`, 80-89 (Studio Town) in
/// `STDesc.iff`, 90 up (Magic Town) in `MTDesc.iff`.
class _HouseNames {
  _HouseNames(Directory userData)
      : _houses = Directory(p.join(userData.path, 'Houses'));

  final Directory _houses;
  final Map<String, List<IffChunk>?> _descs = {};

  /// House number -> the strings of its entry: name first, then the
  /// description the player typed for it.
  final Map<int, List<String>> _cache = {};

  String? of(int house) => _stringAt(house, 0);

  String? descriptionOf(int house) => _stringAt(house, 1);

  String? _stringAt(int house, int index) {
    final strings = _cache.putIfAbsent(house, () {
      final file = house < 80
          ? 'NeighborhoodDesc.iff'
          : house < 90
              ? 'STDesc.iff'
              : 'MTDesc.iff';
      final chunks = _descs.putIfAbsent(file, () {
        try {
          return readIffChunks(
              File(p.join(_houses.path, file)).readAsBytesSync());
        } catch (_) {
          return null;
        }
      });
      if (chunks == null) return const [];
      for (final chunk in chunks) {
        if (chunk.type == 'STR#' && chunk.id == house + 2000) {
          return parseIffStrings(chunk.data);
        }
      }
      return const [];
    });
    if (index >= strings.length) return null;
    final value = strings[index].trim();
    return value.isEmpty ? null : value;
  }
}

String _firstOrEmpty(List<String> strings) =>
    strings.isEmpty ? '' : strings.first;

// ---------------------------------------------------------------------------

/// Little-endian reader over a chunk payload. Throws [RangeError] past the
/// end; chunk parsers catch it and keep what they have, which is the
/// FreeSO approach to these files.
class _LeReader {
  _LeReader(this._bytes) : _data = ByteData.sublistView(_bytes);

  final Uint8List _bytes;
  final ByteData _data;
  int _pos = 0;

  bool hasBytes(int count) => _pos + count <= _bytes.length;

  void skip(int count) {
    _pos = (_pos + count).clamp(0, _bytes.length);
  }

  int uint8() => _bytes[_pos++];

  int int16() {
    final value = _data.getInt16(_pos, Endian.little);
    _pos += 2;
    return value;
  }

  int uint16() {
    final value = _data.getUint16(_pos, Endian.little);
    _pos += 2;
    return value;
  }

  int int32() {
    final value = _data.getInt32(_pos, Endian.little);
    _pos += 4;
    return value;
  }

  int uint32() {
    final value = _data.getUint32(_pos, Endian.little);
    _pos += 4;
    return value;
  }

  String cString() {
    final start = _pos;
    while (_pos < _bytes.length && _bytes[_pos] != 0) {
      _pos++;
    }
    final value = decodeGameText(_bytes.sublist(start, _pos));
    if (_pos < _bytes.length) _pos++; // the terminator
    return value;
  }

  String pascalString() {
    final length = uint8();
    final end = (_pos + length).clamp(0, _bytes.length);
    final value = decodeGameText(_bytes.sublist(_pos, end));
    _pos = end;
    return value;
  }
}
