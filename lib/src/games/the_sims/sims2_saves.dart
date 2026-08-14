import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../../core/dbpf.dart';
import '../../core/dbpf_write.dart';
import '../../core/game_text.dart';
import '../../core/save_edit.dart';
import '../../core/save_game.dart';

/// Reads The Sims 2 neighborhoods - the game's unit of "a save" - out of
/// `Neighborhoods/N001...`, each a folder around one master DBPF
/// (`N001_Neighborhood.package`) holding every sim, family and
/// relationship in the hood.
///
/// Layouts follow the Sims2Tools library (the code behind Hood Exporter,
/// which reads exactly these resources) and SimsWiki's format pages:
/// SDSC carries each sim's stats in a ushort array whose indices Sims 2
/// inherited from The Sims 1's person data, FAMI each family's funds and
/// lot, SREL each relationship. Names are indirect: a family's name is
/// the string resource sharing its instance, a sim's name lives in its
/// character package's CTSS, joined over the OBJD GUID. Images are the
/// loose neighborhood PNG, the ready-rendered family JPEGs in
/// `Thumbnails/<hood>_FamilyThumbnails.package`, and the player's own
/// storytelling snapshots.
///
/// Synchronous on purpose - the adapter runs it inside an isolate.

const _sdscType = 0xAACE2EFB;
const _famiType = 0x46414D49;
const _srelType = 0xCC364C2A;
const _famtType = 0x8C870743;
const _ltxtType = 0x0BF999E7;
const _strType = 0x53545223;
const _ctssType = 0x43545353;
const _objdType = 0x4F424A44;

/// The jpg/tga/png image resource.
const _imgType = 0x856DDBAC;

/// The family numbers that mean "this sim has no household": the dead and
/// the unlinked ancestors a family tree points at (0), and the two
/// reserved pools every hood keeps its townies and service NPCs in. Each
/// of them has a FAMI record of its own, so without this every homeless
/// sim in the neighborhood joins one household - Pleasantview showed a
/// 68-member "Goth" (Gunther, Bella, the Brokes, the Newbies, all long
/// dead) next to the three Goths who actually live at 165 Sim Lane.
const _homelessFamilies = {0x0000, 0x7FFE, 0x7FFF};

/// The most sims the game will put under one roof. A lotless family
/// holding more than this is another of the pools above under a number
/// this doesn't know yet, rather than somebody's home.
const _maxHouseholdSims = 8;

/// SDSC version -> length of the ushort data array that follows the
/// 12-byte header (per Sims2Tools). The stat indices used here all sit
/// below the base game's 170, so an unknown newer version still yields
/// stats - just not the trailing GUID that names the sim.
const _sdscDataCounts = <int, int>{
  0x20: 170, // base game
  0x22: 179, // University
  0x29: 195, // Nightlife
  0x2A: 199, // Open for Business
  0x2C: 200, // Pets
  0x2D: 201, // Castaway
  0x2E: 204, // Bon Voyage
  0x2F: 204,
  0x33: 228, // FreeTime
  0x36: 231, // Apartment Life
};

// Indices into the SDSC data array (Sims2Tools' SdscIndex, whose members
// carry no explicit values - these are their declaration positions).
const _iPersonalityNice = 2;
const _iPersonalityActive = 3;
const _iPersonalityPlayful = 5;
const _iPersonalityOutgoing = 6;
const _iPersonalityNeat = 7;
const _iSkillCleaning = 9;
const _iSkillCooking = 10;
const _iSkillCharisma = 11;
const _iSkillMechanical = 12;
const _iSkillCreativity = 15;
const _iSkillBody = 17;
const _iSkillLogic = 18;
const _iAspiration = 46;
const _iJobLevel = 57;
const _iPersonAge = 58;
const _iFamilyNumber = 61;
const _iGender = 65;
const _iGhostFlags = 68;
const _iZodiac = 70;
const _iLifeState = 84;
const _iJobGuidLow = 89;
const _iJobGuidHigh = 90;
const _iSchoolGuidLow = 107;
const _iSchoolGuidHigh = 108;
const _iGpa = 83;
const _iMajorGuidLow = 170;
const _iMajorGuidHigh = 171;
const _iSemester = 174;
const _iOnCampus = 175;
const _iSpecies = 186;
const _iPredestinedHobby = 215;

/// The eighteen interests, in the order they sit in the array.
const _interestKeys = <String>[
  'politics',
  'money',
  'environment',
  'crime',
  'entertainment',
  'culture',
  'food',
  'health',
  'fashion',
  'sports',
  'paranormal',
  'travel',
  'work',
  'weather',
  'animals',
  'school',
  'toys',
  'sciFi',
];

/// Where that run starts (`iPolitics`).
const _iFirstInterest = 124;

/// The ten hobbies, in the order their enthusiasm values sit in the
/// array. A sim's enthusiasm is the same 0-1000 scale as everything
/// else here.
const _hobbyKeys = <String>[
  'cuisine',
  'arts',
  'film',
  'sports',
  'games',
  'nature',
  'tinkering',
  'fitness',
  'science',
  'music',
];

/// Where that run starts (`eCuisine`); the expansion that added hobbies
/// appended them, so older saves simply stop short of it.
const _iFirstHobby = 204;

/// The hobby the game decided a sim was born for, offset past the run of
/// stray values older tools wrote.
const _predestinedHobbyKeys = <int, String>{
  0xCC: 'cuisine',
  0xCD: 'arts',
  0xCE: 'film',
  0xCF: 'sports',
  0xD0: 'games',
  0xD1: 'nature',
  0xD2: 'tinkering',
  0xD3: 'fitness',
  0xD4: 'science',
  0xD5: 'music',
};

/// Major object GUID -> the subject, worded like the careers above.
const _majorNames = <int, String>{
  0x2E9CF007: 'Art',
  0x4E9CF02B: 'Biology',
  0x4E9CF04D: 'Drama',
  0xEE9CF044: 'Economics',
  0x2E9CF074: 'History',
  0xCE9CF085: 'Literature',
  0xEE9CF08D: 'Mathematics',
  0x2E9CF057: 'Philosophy',
  0xAE9CF063: 'Physics',
  0x4E9CF06D: 'Political Science',
  0xCE9CF07C: 'Psychology',
  0x8E97BF1D: 'Undeclared',
};

/// Family-tie kinds, as the genealogy resource numbers them. Stored one
/// way round only - a mother's own record carries the matching child
/// tie - so both directions are read rather than inferred.
const _familyTieKeys = <int, String>{
  0x00: 'mother',
  0x01: 'father',
  0x02: 'spouse',
  0x03: 'sibling',
  0x04: 'child',
};

/// The order a sim's relatives read best in.
const _familyTieOrder = ['mother', 'father', 'spouse', 'sibling', 'child'];

/// What a sim is, when it isn't an ordinary living one. A bit field, so
/// a sim can in principle be more than one; the first match wins, which
/// is what the game's own portrait does.
const _lifeStateBits = <int, String>{
  0x0400: 'witch',
  0x0200: 'bigfoot',
  0x0100: 'plantSim',
  0x0040: 'werewolf',
  0x0004: 'vampire',
  0x0001: 'zombie',
};

/// Non-human household members, from `Species`.
const _speciesKeys = <int, String>{
  1: 'largeDog',
  2: 'smallDog',
  3: 'cat',
};

const _ageKeys = <int, String>{
  0x01: 'baby',
  0x02: 'toddler',
  0x03: 'child',
  0x10: 'teen',
  0x13: 'adult',
  0x33: 'elder',
  0x40: 'youngAdult',
};

const _aspirationKeys = <int, String>{
  0x01: 'romance',
  0x02: 'family',
  0x04: 'fortune',
  0x10: 'popularity',
  0x20: 'knowledge',
  0x40: 'growUp',
  0x80: 'pleasure',
  0x100: 'grilledCheese',
};

const _zodiacKeys = <int, String>{
  1: 'aries',
  2: 'taurus',
  3: 'gemini',
  4: 'cancer',
  5: 'leo',
  6: 'virgo',
  7: 'libra',
  8: 'scorpio',
  9: 'sagittarius',
  10: 'capricorn',
  11: 'aquarius',
  12: 'pisces',
};

/// SREL flag bit -> label key (Sims2Tools' RelationshipStateBits).
/// Contact/pack/known and the family bit are bookkeeping, not something
/// worth a badge.
const _relationshipFlagKeys = <int, String>{
  0: 'crush',
  1: 'love',
  2: 'engaged',
  3: 'married',
  4: 'friends',
  5: 'bestFriends',
  6: 'steady',
  7: 'enemies',
};

/// The player's storytelling snapshots can number thousands; the album
/// keeps the newest.
const _maxStorytellingPhotos = 48;

/// Career object GUID -> what the game calls that track. Combined from
/// the low and high halves the SDSC stores separately. The names stay
/// English, like the game titles the app already shows that way; a GUID
/// that isn't here is a custom career and simply goes unnamed.
const _careerNames = <int, String>{
  0x3240CBA5: 'Adventurer', 0x2C89E95F: 'Athletic',
  0x4E6FFFBC: 'Artist', 0xF3E1C301: 'Construction',
  0x6C9EBD0E: 'Criminal', 0xEC9EBD5F: 'Culinary',
  0xD3E09422: 'Dance', 0x45196555: 'Business',
  0x72428B30: 'Education', 0xB3E09417: 'Entertainment',
  0xF240C306: 'Gamer', 0x33E0940E: 'Intelligence',
  0x7240D944: 'Journalism', 0x12428B19: 'Law',
  0xAC9EBCE3: 'Law Enforcement', 0x0C7761FD: 'Medical',
  0x6C9EBD32: 'Military', 0xB2428B0C: 'Music',
  0xEE70001C: 'Natural Science', 0x73E09404: 'Oceanography',
  0x2E6FFF87: 'Paranormal', 0x2C945B14: 'Politics',
  0x0C9EBD47: 'Science', 0xAE6FFFB0: 'Show Business',
  0xEC77620B: 'Slacker',
  // The teen/elder halves of the same tracks.
  0xF240D235: 'Adventurer', 0xAC89E947: 'Athletic',
  0x4C1E0577: 'Business', 0x53E1C30F: 'Construction',
  0xACA07ACD: 'Criminal', 0x4CA07B0C: 'Culinary',
  0xD3E094A5: 'Dance', 0xD243BBEC: 'Education',
  0x53E09494: 'Entertainment', 0x1240C962: 'Gamer',
  0x93E094C0: 'Intelligence', 0x5240E212: 'Journalism',
  0x1243BBDE: 'Law', 0x6CA07B39: 'Law Enforcement',
  0xAC89E918: 'Medical', 0xCCA07B66: 'Military',
  0xB243BBD2: 'Music', 0x13E09443: 'Oceanography',
  0xCCA07B8D: 'Politics', 0xECA07BB0: 'Science',
  0x6CA07BDC: 'Slacker',
  // Pets have careers of their own.
  0xD188A400: 'Security', 0xB188A4C1: 'Service',
  0xD175CC2D: 'Show Business',
};

/// School object GUID -> what it is, for the sims too young to work.
const _schoolNames = <int, String>{
  0xD06788B5: 'Public school',
  0xCC8F4C11: 'Private school',
};

List<SaveGame> scanSims2Saves(String neighborhoodsPath) {
  final hoodsDir = Directory(neighborhoodsPath);
  if (!hoodsDir.existsSync()) return const [];

  final saves = <SaveGame>[];
  try {
    for (final entity in hoodsDir.listSync()) {
      if (entity is! Directory) continue;
      final code = p.basename(entity.path);
      final package = File(p.join(entity.path, '${code}_Neighborhood.package'));
      if (!package.existsSync()) continue;
      final save = _parseHood(entity, code, package);
      if (save != null) saves.add(save);
    }
  } catch (_) {
    return const [];
  }
  saves.sort((a, b) {
    final at = a.modifiedAt, bt = b.modifiedAt;
    if (at == null || bt == null) return at == bt ? 0 : (at == null ? 1 : -1);
    return bt.compareTo(at);
  });
  return saves;
}

SaveGame? _parseHood(Directory folder, String code, File package) {
  DateTime? modified;
  try {
    modified = package.statSync().modified;
  } catch (_) {}
  var size = 0;
  try {
    for (final entity in folder.listSync(recursive: true, followLinks: false)) {
      if (entity is File) {
        try {
          size += entity.lengthSync();
        } catch (_) {}
      }
    }
  } catch (_) {}

  Uint8List? thumbnail;
  try {
    final png = File(p.join(folder.path, '${code}_Neighborhood.png'));
    if (png.existsSync()) thumbnail = png.readAsBytesSync();
  } catch (_) {}

  RandomAccessFile? raf;
  _Hood? hood;
  try {
    raf = package.openSync();
    final entries = readDbpfIndex(raf);
    if (entries != null) hood = _readHood(raf, entries);
  } catch (_) {
  } finally {
    try {
      raf?.closeSync();
    } catch (_) {}
  }

  final names = hood == null
      ? null
      : _characterNames(Directory(p.join(folder.path, 'Characters')));
  final familyThumbs = hood == null ? null : _familyThumbnails(folder, code);

  // Family ties point anywhere in the neighborhood, so the names they
  // resolve against are the whole hood's, not one household's.
  final nameByInstance = <int, String>{
    if (hood != null)
      for (final sim in hood.sims)
        if (names?[sim.guid] case final character?)
          sim.instance: _displayName(character),
  };

  final households = <SaveHousehold>[];
  if (hood != null) {
    for (final family in hood.families) {
      if (_homelessFamilies.contains(family.instance)) continue;
      final members = [
        for (final sim in hood.sims)
          if (sim.familyNumber == family.instance) sim,
      ];
      if (family.lotInstance == 0 && members.length > _maxHouseholdSims) {
        continue;
      }
      // Nobody lives here. Every hood keeps a handful of these - a record
      // left behind by a household that moved out, an address the game
      // reserved - and they were invisible only for as long as their
      // names were unreadable: Riverblossom Hills alone carries eleven.
      if (members.isEmpty) continue;
      final familyName = hood.familyNames[family.instance];
      final lot = hood.lots[family.lotInstance];
      households.add(SaveHousehold(
        id: family.instance,
        name: familyName != null && familyName.isNotEmpty
            ? familyName
            : _fallbackName(members, names),
        funds: family.money,
        lotName: lot?.name,
        description: lot?.description,
        lotTypeKey: lot?.typeKey,
        isPlayed: family.lotInstance != 0,
        portrait: familyThumbs?[family.instance],
        members: [
          for (final sim in members)
            _toSim(sim, names?[sim.guid], _portraitOf(sim, names?[sim.guid]),
                _tiesOf(sim, hood.familyTies, nameByInstance)),
        ],
        relationships: _familyBonds(hood, members, names),
      ));
    }
    households.sort((a, b) {
      if (a.isPlayed != b.isPlayed) return a.isPlayed ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

  final photos = <SavePhoto>[
    if (familyThumbs != null)
      for (final household in households)
        if (household.portrait != null)
          SavePhoto(
              bytes: household.portrait,
              kindKey: 'familyPortrait',
              caption: household.name),
    ..._storytellingPhotos(folder),
  ];

  return SaveGame(
    // The name the game shows, with the folder code standing in only
    // when the package would not give one up.
    name: hood?.name ?? code,
    worldName: hood?.name != null ? code : null,
    description: hood?.description,
    path: folder.path,
    modifiedAt: modified,
    sizeBytes: size,
    thumbnail: thumbnail,
    households: households,
    // Deliberately not hood.sims.length: that counts the pools above too,
    // and "510 sims in 34 households" would be a sentence about a
    // neighborhood where 380 of them are dead or passing through.
    photos: photos,
  );
}

// ---------------------------------------------------------------------------
// The neighborhood package.

class _Hood {
  _Hood(this.sims, this.families, this.familyNames, this.lots, this.relations,
      this.familyTies, this.name, this.description);

  /// Sim instance -> its family ties, as (kind, target instance) pairs.
  final Map<int, List<(int, int)>> familyTies;

  /// What the game calls this neighborhood, and the blurb its selection
  /// screen shows under it.
  final String? name;
  final String? description;

  final List<_SimRecord> sims;
  final List<_FamilyRecord> families;

  /// Family instance -> the family's display name.
  final Map<int, String> familyNames;

  /// Lot instance -> what its description resource says.
  final Map<int, _LotInfo> lots;

  /// SREL instance -> (daily score, flag bits), one per direction.
  final Map<int, (int, int)> relations;
}

class _SimRecord {
  _SimRecord(this.instance, this.guid, this.data);

  final int instance;

  /// The character package's OBJD GUID, or null when the SDSC version is
  /// too new to know where the trailing id block sits.
  final int? guid;
  final List<int> data;

  int? operator [](int index) => index < data.length ? data[index] : null;
  int get familyNumber => this[_iFamilyNumber] ?? 0;
}

class _FamilyRecord {
  _FamilyRecord(this.instance, this.lotInstance, this.money);

  final int instance;
  final int lotInstance;
  final int money;
}

_Hood _readHood(RandomAccessFile raf, List<DbpfEntry> entries) {
  final sims = <_SimRecord>[];
  final families = <_FamilyRecord>[];
  final strEntries = <int, DbpfEntry>{};
  final ltxtEntries = <int, DbpfEntry>{};
  final relations = <int, (int, int)>{};
  final familyTies = <int, List<(int, int)>>{};

  // The hood's own name and blurb: the one catalog description in the
  // package, string 0 and 1, exactly where SimPE's hood tool reads them.
  // Without it a neighborhood is only ever its folder code.
  String? hoodName;
  String? hoodDescription;
  for (final e in entries) {
    switch (e.type) {
      case _sdscType:
        final sim = _parseSdsc(raf, e);
        if (sim != null) sims.add(sim);
      case _famiType:
        final family = _parseFami(raf, e);
        if (family != null) families.add(family);
      case _strType:
        strEntries[e.instance & 0xFFFFFFFF] = e;
      case _ltxtType:
        ltxtEntries[e.instance & 0xFFFFFFFF] = e;
      case _srelType:
        final rel = _parseSrel(raf, e);
        if (rel != null) relations[e.instance & 0xFFFFFFFF] = rel;
      case _famtType:
        familyTies.addAll(_parseFamt(raf, e));
      case _ctssType:
        if (hoodName != null) break;
        final blob = readDbpfResource(raf, e);
        final strings =
            blob == null ? const <String>[] : _parseStrResource(blob);
        if (strings.isNotEmpty && strings.first.trim().isNotEmpty) {
          hoodName = strings.first.trim();
          final blurb = (strings.length > 1 ? strings[1] : '').trim();
          hoodDescription = blurb.isEmpty ? null : blurb;
        }
    }
  }

  // Only the string tables and lot descriptions the families need are
  // decompressed - a hood package carries hundreds of others.
  final familyNames = <int, String>{};
  final lots = <int, _LotInfo>{};
  for (final family in families) {
    if (!familyNames.containsKey(family.instance)) {
      final entry = strEntries[family.instance];
      final blob = entry == null ? null : readDbpfResource(raf, entry);
      final strings = blob == null ? const <String>[] : _parseStrResource(blob);
      if (strings.isNotEmpty && strings.first.trim().isNotEmpty) {
        familyNames[family.instance] = strings.first.trim();
      }
    }
    if (family.lotInstance != 0 && !lots.containsKey(family.lotInstance)) {
      final lot = _parseLtxt(raf, ltxtEntries[family.lotInstance]);
      if (lot != null) lots[family.lotInstance] = lot;
    }
  }
  return _Hood(sims, families, familyNames, lots, relations, familyTies,
      hoodName, hoodDescription);
}

/// What the lot description resource says about a household's home.
typedef _LotInfo = ({String? name, String? description, String? typeKey});

/// Lot types, per Sims2Tools' `Ltxt.LotType`. The hidden ones (vacation,
/// hobby, witches) are places the game sends sims rather than addresses,
/// and read as nothing rather than as a home.
const _lotTypeKeys = <int, String>{
  0x00: 'residential',
  0x01: 'community',
  0x02: 'dorm',
  0x03: 'greekHouse',
  0x04: 'secretSociety',
  0x05: 'hotel',
  0x08: 'apartment',
  0x09: 'apartment',
};

/// LTXT: two version words, lot width and height (u32 each), lot type,
/// roads and rotation (a byte each), flags (u32) - 19 bytes - then the
/// lot name and its description, each an int32-length-prefixed string.
_LotInfo? _parseLtxt(RandomAccessFile raf, DbpfEntry? entry) {
  if (entry == null) return null;
  final blob = readDbpfResource(raf, entry);
  if (blob == null || blob.length < 23) return null;
  final d = ByteData.sublistView(blob);
  var pos = 19;

  String? readString() {
    if (pos + 4 > blob.length) return null;
    final length = d.getInt32(pos, Endian.little);
    pos += 4;
    if (length < 0 || length > 4096 || pos + length > blob.length) return null;
    final value = decodeGameText(blob.sublist(pos, pos + length)).trim();
    pos += length;
    return value.isEmpty ? null : value;
  }

  final name = readString();
  final description = readString();
  return (
    name: name,
    description: description,
    typeKey: _lotTypeKeys[blob[12]],
  );
}

/// SDSC: 12-byte header (unknown, version, unknown), the ushort stat
/// array, then the sim's instance and character GUID.
_SimRecord? _parseSdsc(RandomAccessFile raf, DbpfEntry entry) {
  final blob = readDbpfResource(raf, entry);
  if (blob == null || blob.length < 12) return null;
  final d = ByteData.sublistView(blob);
  final version = d.getInt32(4, Endian.little);
  final dataCount = _sdscDataCounts[version];
  final available = (blob.length - 12) ~/ 2;
  final count = dataCount == null
      ? available
      : (dataCount > available ? available : dataCount);
  final data = <int>[
    for (var i = 0; i < count; i++) d.getUint16(12 + i * 2, Endian.little),
  ];
  int? guid;
  if (dataCount != null && 12 + dataCount * 2 + 6 <= blob.length) {
    // u16 sim instance (same as the resource's), then the GUID.
    guid = d.getUint32(12 + dataCount * 2 + 2, Endian.little);
  }
  return _SimRecord(entry.instance & 0xFFFF, guid, data);
}

/// FAMI: type echo, version, zero, lot instance, the expansions' extra
/// lots, a word this doesn't read, then the family funds. Only fields up
/// to the money are read, so unknown later versions still parse.
///
/// The version gates those extra lots, and the numbers are the file's
/// own: one install carries 0x4E in the hoods EA shipped, 0x54 and 0x55
/// in the ones the game has written since, each step inserting one more
/// lot ahead of the funds. They read 0x81 and 0x85 until this was checked
/// against real saves - 81 and 85 written as though they were already
/// hex - so a 0x55 hood took its funds from the word before, which is
/// zero on every family in it, and the whole neighborhood was worth
/// nothing.
///
/// The word before the money is not the family's name string, though it
/// reads like one and was taken for one until issue #18: in a hood the
/// game has only ever added to, it happens to equal the family's own
/// instance, so Pleasantview and every other freshly started save named
/// its households correctly. It drifts as soon as households are created
/// and deleted out of step - across the shipped hoods it points at some
/// other family's name (Riverblossom Hills' McGreggors read as
/// "Goldstein", Belladonna Cove's Cordials as "Ottomas") or at nothing at
/// all. The name is the STR# sharing the family's own instance, which is
/// what the family thumbnails are keyed by too.
_FamilyRecord? _parseFami(RandomAccessFile raf, DbpfEntry entry) {
  final blob = readDbpfResource(raf, entry);
  if (blob == null || blob.length < 24) return null;
  final d = ByteData.sublistView(blob);
  try {
    final money = famiMoneyOffset(blob);
    if (money == null) return null;
    return _FamilyRecord(entry.instance & 0xFFFFFFFF,
        d.getUint32(12, Endian.little), d.getInt32(money, Endian.little));
  } catch (_) {
    return null;
  }
}

/// Where the funds sit inside a FAMI blob, by the version the record
/// declares. Split out of [_parseFami] because the editor writes to the
/// same spot and the two must not be able to disagree about where it is.
/// Null when the record is too short to hold one.
int? famiMoneyOffset(Uint8List blob) {
  if (blob.length < 24) return null;
  final version = ByteData.sublistView(blob).getUint32(4, Endian.little);
  var pos = 16; // the 12-byte header, then the lot instance
  if (version >= 0x51) pos += 4; // Open for Business: business lot
  if (version >= 0x55) pos += 4; // Bon Voyage: vacation lot
  pos += 4; // the word that is not a name
  return pos + 4 <= blob.length ? pos : null;
}

/// FAMT: the hood's genealogy. A magic word, then per sim its instance,
/// a word nothing reads, and the ties it owns - each a kind and the
/// instance it points at. Returns sim instance -> its ties.
Map<int, List<(int, int)>> _parseFamt(RandomAccessFile raf, DbpfEntry entry) {
  final blob = readDbpfResource(raf, entry);
  if (blob == null || blob.length < 8) return const {};
  final d = ByteData.sublistView(blob);
  // Anything else is a resource this doesn't know how to walk.
  if (d.getUint32(0, Endian.little) != 1) return const {};
  final ties = <int, List<(int, int)>>{};
  var pos = 4;
  final sims = d.getInt32(pos, Endian.little);
  pos += 4;
  for (var i = 0; i < sims; i++) {
    if (pos + 10 > blob.length) break;
    final instance = d.getUint16(pos, Endian.little);
    pos += 2 + 4; // the instance, then the word Sims2Tools skips
    final count = d.getInt32(pos, Endian.little);
    pos += 4;
    if (count < 0) break;
    final mine = <(int, int)>[];
    for (var t = 0; t < count && pos + 6 <= blob.length; t++) {
      final kind = d.getUint32(pos, Endian.little);
      final target = d.getUint16(pos + 4, Endian.little);
      pos += 6;
      mine.add((kind, target));
    }
    if (mine.isNotEmpty) ties[instance] = mine;
  }
  return ties;
}

/// SREL: the instance packs the two sims' ids (high and low 16 bits);
/// the payload is a count-prefixed int32 array - [0] daily score,
/// [1] flag bits.
(int, int)? _parseSrel(RandomAccessFile raf, DbpfEntry entry) {
  final blob = readDbpfResource(raf, entry);
  if (blob == null || blob.length < 16) return null;
  final d = ByteData.sublistView(blob);
  final stored = d.getUint32(4, Endian.little);
  if (stored < 2 || 8 + stored * 4 > blob.length) return null;
  return (d.getInt32(8, Endian.little), d.getInt32(12, Endian.little));
}

SaveSim _toSim(_SimRecord sim, _Character? name, Uint8List? portrait,
    List<SaveFamilyTie> familyTies) {
  Map<String, int> values(Map<String, int> indices) => {
        for (final entry in indices.entries)
          if (sim[entry.value] case final value?)
            entry.key: value > 1000 ? 1000 : value,
      };

  /// The two halves the game keeps a job or school object's id in.
  int? guid(int low, int high) {
    final lo = sim[low], hi = sim[high];
    if (lo == null || hi == null) return null;
    final value = (hi << 16) | lo;
    return value == 0 ? null : value;
  }

  final career = _careerNames[guid(_iJobGuidLow, _iJobGuidHigh)] ??
      _schoolNames[guid(_iSchoolGuidLow, _iSchoolGuidHigh)];
  // A level only means something next to a career, and school has none.
  final level = _careerNames.containsKey(guid(_iJobGuidLow, _iJobGuidHigh))
      ? sim[_iJobLevel]
      : null;

  // A degree: the subject, the average on the usual four-point scale
  // (stored as thousandths), and how far through the eight semesters
  // they are. Only a sim who actually went has any of it.
  final gpa = sim[_iGpa];
  final semester = sim[_iSemester];
  final education = SaveEducation(
    major: _majorNames[guid(_iMajorGuidLow, _iMajorGuidHigh)],
    gpa: gpa != null && gpa > 0 ? gpa * 0.004 : null,
    semester:
        semester != null && semester > 0 && semester <= 8 ? semester : null,
  );

  final species = _speciesKeys[sim[_iSpecies]];
  final lifeState = sim[_iLifeState] ?? 0;
  String? occult = species;
  if (occult == null) {
    for (final entry in _lifeStateBits.entries) {
      if (lifeState & entry.key != 0) {
        occult = entry.value;
        break;
      }
    }
  }

  return SaveSim(
    firstName: name?.first ?? '',
    lastName: name?.last,
    bio: name?.bio,
    portrait: portrait,
    // A sim away at university is stored as an adult with a flag beside
    // it; without this every student reads as "Adult".
    ageKey:
        (sim[_iOnCampus] ?? 0) != 0 ? 'youngAdult' : _ageKeys[sim[_iPersonAge]],
    genderKey: switch (sim[_iGender]) {
      0 => 'male',
      1 => 'female',
      _ => null,
    },
    zodiacKey: _zodiacKeys[sim[_iZodiac]],
    aspirationKey: _aspirationKeys[sim[_iAspiration]],
    careerName: career,
    careerLevel: career != null && level != null && level > 0 ? level : null,
    occultKey: occult,
    isGhost: ((sim[_iGhostFlags] ?? 0) & 0x1) != 0,
    interests: {
      for (final (index, key) in _interestKeys.indexed)
        if (sim[_iFirstInterest + index] case final value? when value > 0)
          key: value > 1000 ? 1000 : value,
    },
    hobbies: {
      for (final (index, key) in _hobbyKeys.indexed)
        if (sim[_iFirstHobby + index] case final value? when value > 0)
          key: value > 1000 ? 1000 : value,
    },
    predestinedHobbyKey: _predestinedHobbyKeys[sim[_iPredestinedHobby]],
    education: education.isEmpty ? null : education,
    familyTies: familyTies,
    skills: values(const {
      'cooking': _iSkillCooking,
      'mechanical': _iSkillMechanical,
      'charisma': _iSkillCharisma,
      'body': _iSkillBody,
      'logic': _iSkillLogic,
      'creativity': _iSkillCreativity,
      'cleaning': _iSkillCleaning,
    }),
    personality: values(const {
      'neat': _iPersonalityNeat,
      'outgoing': _iPersonalityOutgoing,
      'active': _iPersonalityActive,
      'playful': _iPersonalityPlayful,
      'nice': _iPersonalityNice,
    }),
  );
}

String _fallbackName(List<_SimRecord> members, Map<int, _Character>? names) {
  for (final member in members) {
    final name = names?[member.guid];
    if (name != null && name.last.isNotEmpty) return name.last;
    if (name != null && name.first.isNotEmpty) return name.first;
  }
  return '';
}

/// Bonds between one family's members: both directions of an SREL pair
/// merged - scores averaged, flags unioned.
List<SaveRelationship> _familyBonds(
    _Hood hood, List<_SimRecord> members, Map<int, _Character>? names) {
  String nameOf(_SimRecord sim) {
    final name = names?[sim.guid];
    if (name == null) return '';
    return name.last.isEmpty ? name.first : '${name.first} ${name.last}';
  }

  final bonds = <SaveRelationship>[];
  for (var i = 0; i < members.length; i++) {
    for (var j = i + 1; j < members.length; j++) {
      final a = members[i], b = members[j];
      final ab = hood.relations[(a.instance << 16) | b.instance];
      final ba = hood.relations[(b.instance << 16) | a.instance];
      if (ab == null && ba == null) continue;
      final scores = [if (ab != null) ab.$1, if (ba != null) ba.$1];
      final flags = (ab?.$2 ?? 0) | (ba?.$2 ?? 0);
      final nameA = nameOf(a), nameB = nameOf(b);
      if (nameA.isEmpty || nameB.isEmpty) continue;
      bonds.add(SaveRelationship(
        nameA: nameA,
        nameB: nameB,
        score: (scores.reduce((x, y) => x + y) ~/ scores.length)
            .clamp(-100, 100)
            .toInt(),
        labelKeys: [
          for (final entry in _relationshipFlagKeys.entries)
            if (flags & (1 << entry.key) != 0) entry.value,
        ],
      ));
    }
  }
  bonds.sort((a, b) => b.score.compareTo(a.score));
  return bonds;
}

// ---------------------------------------------------------------------------
// Names and images living outside the neighborhood package.

/// The life-stage bitmask each portrait in a character package is keyed
/// by, per life stage as the SDSC records it. Two different encodings of
/// the same idea, which is why the translation has to be spelled out.
const _portraitInstanceByAge = <String, int>{
  'baby': 0x20,
  'toddler': 0x01,
  'child': 0x02,
  'teen': 0x04,
  'youngAdult': 0x40,
  'adult': 0x08,
  'elder': 0x10,
};

/// The other image type a character package may use for its portraits.
const _jpgType = 0x8C3CE95A;

/// What one character package says about its sim.
typedef _Character = ({
  String first,
  String last,
  String? bio,
  Map<int, Uint8List> portraits,
});

/// Character package GUID -> the sim, read the way Hood Exporter does:
/// each package in `Characters/` holds one OBJD (whose GUID at offset
/// 0x5C is the join key), one CTSS whose default-language strings are
/// first name, bio and last name, and one portrait per life stage the
/// sim has lived through, keyed by that stage's bitmask.
Map<int, _Character> _characterNames(Directory folder) {
  final names = <int, _Character>{};
  if (!folder.existsSync()) return names;
  List<FileSystemEntity> files;
  try {
    files = folder.listSync();
  } catch (_) {
    return names;
  }
  for (final entity in files) {
    if (entity is! File ||
        p.extension(entity.path).toLowerCase() != '.package') {
      continue;
    }
    RandomAccessFile? raf;
    try {
      raf = entity.openSync();
      final entries = readDbpfIndex(raf);
      if (entries == null) continue;
      int? guid;
      List<String>? strings;
      final portraits = <int, Uint8List>{};
      for (final e in entries) {
        if (e.type == _objdType && guid == null) {
          final blob = readDbpfResource(raf, e);
          if (blob != null && blob.length >= 0x60) {
            guid = ByteData.sublistView(blob).getUint32(0x5C, Endian.little);
          }
        } else if (e.type == _ctssType && strings == null) {
          final blob = readDbpfResource(raf, e);
          if (blob != null) strings = _parseStrResource(blob);
        } else if (e.type == _imgType || e.type == _jpgType) {
          // One image per life stage the sim has been through, keyed by
          // that stage rather than by anything sim-specific.
          final stage = e.instance & 0xFFFFFFFF;
          if (stage < 0x01 || stage > 0x40) continue;
          final image = _readImage(raf, e);
          if (image != null) portraits[stage] = image;
        }
      }
      if (guid != null && strings != null && strings.isNotEmpty) {
        // Hood Exporter reads the same three: given name, biography,
        // family name, in that stored order.
        final bio = (strings.length > 1 ? strings[1] : '').trim();
        names[guid] = (
          first: strings[0].trim(),
          last: (strings.length > 2 ? strings[2] : '').trim(),
          bio: bio.isEmpty ? null : bio,
          portraits: portraits,
        );
      }
    } catch (_) {
    } finally {
      try {
        raf?.closeSync();
      } catch (_) {}
    }
  }
  return names;
}

/// A sim's full name as the panels write it.
String _displayName(_Character character) => character.last.isEmpty
    ? character.first
    : '${character.first} ${character.last}';

/// One sim's family, resolved to names. Ties are stored from both ends
/// (a mother's record carries the child tie, the child's the mother
/// one), so both directions are read and the pairs deduplicated - a
/// relative whose name the hood cannot resolve is dropped rather than
/// listed as a number.
List<SaveFamilyTie> _tiesOf(_SimRecord sim,
    Map<int, List<(int, int)>> familyTies, Map<int, String> namesByInstance) {
  final found = <(String, String)>{};
  for (final (kind, target) in familyTies[sim.instance] ?? const []) {
    final key = _familyTieKeys[kind];
    final name = namesByInstance[target];
    if (key != null && name != null) found.add((key, name));
  }
  // The other end of every tie pointing at this sim, so a parent is
  // listed even when only the child's record kept the link.
  for (final entry in familyTies.entries) {
    if (entry.key == sim.instance) continue;
    final name = namesByInstance[entry.key];
    if (name == null) continue;
    for (final (kind, target) in entry.value) {
      if (target != sim.instance) continue;
      final key = switch (_familyTieKeys[kind]) {
        'mother' || 'father' => 'child',
        'child' => null, // whose parent they are is theirs to say
        final other => other, // spouse and sibling read the same way round
      };
      if (key != null) found.add((key, name));
    }
  }
  final ties = [
    for (final (key, name) in found) SaveFamilyTie(kindKey: key, name: name),
  ];
  ties.sort((a, b) {
    final order =
        _familyTieOrder.indexOf(a.kindKey) - _familyTieOrder.indexOf(b.kindKey);
    return order != 0 ? order : a.name.compareTo(b.name);
  });
  return ties;
}

/// The portrait for the life stage a sim is in now, falling back to the
/// most grown-up one the package has - a sim who aged up before the
/// game rendered the new stage still gets a face rather than a monogram.
Uint8List? _portraitOf(_SimRecord sim, _Character? character) {
  final portraits = character?.portraits;
  if (portraits == null || portraits.isEmpty) return null;
  final ageKey =
      (sim[_iOnCampus] ?? 0) != 0 ? 'youngAdult' : _ageKeys[sim[_iPersonAge]];
  final current = _portraitInstanceByAge[ageKey];
  if (current != null && portraits[current] != null) return portraits[current];
  for (final stage in const [0x10, 0x08, 0x40, 0x04, 0x02, 0x01, 0x20]) {
    final image = portraits[stage];
    if (image != null) return image;
  }
  return null;
}

/// An image resource's bytes, with the leading block some of them carry
/// skipped when the picture doesn't start where it should - the same
/// second attempt Sims2Tools makes before giving up.
Uint8List? _readImage(RandomAccessFile raf, DbpfEntry entry) {
  final data = readDbpfResource(raf, entry);
  if (data == null) return null;
  if (isJpeg(data) || isPng(data)) return data;
  if (data.length > 0x40) {
    final skipped = Uint8List.sublistView(data, 0x40);
    if (isJpeg(skipped) || isPng(skipped)) return skipped;
  }
  return null;
}

/// Family portraits: family instance -> JPEG bytes. The game renders one
/// per household it has to draw in the family bin, so a hood where
/// everyone is on a lot has none at all.
///
/// Both image types are accepted, and the jpg one is the point: every
/// thumbnail package on this install writes 0x8C3CE95A, so reading only
/// 0x856DDBAC - the type the character packages use for their sim
/// portraits - meant no household ever had a picture.
Map<int, Uint8List> _familyThumbnails(Directory folder, String code) {
  final thumbs = <int, Uint8List>{};
  final file = File(
      p.join(folder.path, 'Thumbnails', '${code}_FamilyThumbnails.package'));
  if (!file.existsSync()) return thumbs;
  RandomAccessFile? raf;
  try {
    raf = file.openSync();
    final entries = readDbpfIndex(raf);
    if (entries == null) return thumbs;
    for (final e in entries) {
      if (e.type != _imgType && e.type != _jpgType) continue;
      final data = _readImage(raf, e);
      if (data != null) thumbs[e.instance & 0xFFFFFFFF] = data;
    }
  } catch (_) {
  } finally {
    try {
      raf?.closeSync();
    } catch (_) {}
  }
  return thumbs;
}

/// The player's own camera snapshots, straight off the disk (paths, not
/// bytes - they can be full-size screenshots). Newest first, thumbnails
/// of the snapshots skipped.
List<SavePhoto> _storytellingPhotos(Directory folder) {
  final dir = Directory(p.join(folder.path, 'Storytelling'));
  if (!dir.existsSync()) return const [];
  final photos = <SavePhoto>[];
  try {
    for (final entity in dir.listSync()) {
      if (entity is! File) continue;
      final name = p.basename(entity.path).toLowerCase();
      if (name.contains('thumbnail')) continue;
      final extension = p.extension(name);
      if (extension != '.jpg' &&
          extension != '.jpeg' &&
          extension != '.png' &&
          extension != '.bmp') {
        continue;
      }
      DateTime? taken;
      try {
        taken = entity.statSync().modified;
      } catch (_) {}
      photos.add(
          SavePhoto(path: entity.path, kindKey: 'snapshot', modifiedAt: taken));
    }
  } catch (_) {}
  photos.sort((a, b) {
    final at = a.modifiedAt, bt = b.modifiedAt;
    if (at == null || bt == null) return at == bt ? 0 : (at == null ? 1 : -1);
    return bt.compareTo(at);
  });
  return photos.length > _maxStorytellingPhotos
      ? photos.sublist(0, _maxStorytellingPhotos)
      : photos;
}

// ---------------------------------------------------------------------------

/// A Sims 2 string resource (STR# and CTSS share the layout): a 64-byte
/// name, a format word, a count, then per string a language byte and two
/// NUL-terminated values. Returns the default-language (English) strings
/// in stored order.
List<String> _parseStrResource(Uint8List blob) {
  if (blob.length < 0x44) return const [];
  final d = ByteData.sublistView(blob);
  final count = d.getUint16(0x42, Endian.little);
  final strings = <String>[];
  var pos = 0x44;
  for (var i = 0; i < count && pos < blob.length; i++) {
    final language = blob[pos++];
    final title = _readCString(blob, pos);
    pos = title.$2;
    final description = _readCString(blob, pos);
    pos = description.$2;
    if (language <= 1) strings.add(title.$1);
  }
  return strings;
}

(String, int) _readCString(Uint8List blob, int pos) {
  final start = pos;
  while (pos < blob.length && blob[pos] != 0) {
    pos++;
  }
  final value = decodeGameText(blob.sublist(start, pos));
  return (value, pos < blob.length ? pos + 1 : pos);
}

// ---------------------------------------------------------------------------
// Writing one household back.

/// The DIR resource: the package's own record of which of its resources
/// are compressed, and what they come back as.
const _dirType = 0xE86B1EEF;

/// The whole neighborhood package with family [familyInstance] changed,
/// as bytes ready to go on disk (see `save_edit.dart` for the rules).
///
/// The package is rewritten rather than poked at. Funds alone would fit
/// in the four bytes they already occupy, but a name does not - a
/// family's name is a string resource of its own, and a longer name is a
/// longer resource, which moves every resource after it. One path that
/// always works beats a fast path that quietly handles half the edits,
/// and a hood is a couple of megabytes: the rewrite costs milliseconds.
///
/// Every resource nobody asked about is copied through with its bytes
/// exactly as they were found, compressed and all. The one or two that
/// are edited come back **stored plainly**, and their records are struck
/// from the DIR, which is precisely what that resource is for.
Uint8List editSims2Hood(File package, int familyInstance, HouseholdEdit edit) {
  RandomAccessFile? raf;
  try {
    raf = package.openSync();
    final header = readAt(raf, 0, 96);
    if (header.length < 96) throw SaveEditException.unreadable(package.path);
    final hd = ByteData.sublistView(header);
    final declared = hd.getUint32(36, Endian.little);
    final indexSize = hd.getUint32(44, Endian.little);
    final entries = readDbpfIndex(raf);
    if (entries == null || entries.length != declared || declared == 0) {
      throw SaveEditException.unreadable(package.path);
    }
    final entryBytes = indexSize ~/ declared;
    if (entryBytes != 20 && entryBytes != 24) {
      throw SaveEditException.unreadable(package.path);
    }

    // The two resources this family is spread across, picked exactly the
    // way the reader picks them: by instance, last one winning.
    DbpfEntry? fami;
    DbpfEntry? str;
    DbpfEntry? dir;
    for (final e in entries) {
      final instance = e.instance & 0xFFFFFFFF;
      if (e.type == _famiType && instance == familyInstance) fami = e;
      if (e.type == _strType && instance == familyInstance) str = e;
      if (e.type == _dirType) dir = e;
    }
    if (fami == null) throw SaveEditException.householdGone();

    // Resource -> the plainly stored bytes it should come back as.
    final rewritten = <DbpfEntry, Uint8List>{};

    final funds = edit.funds;
    if (funds != null) {
      final blob = readDbpfResource(raf, fami);
      final at = blob == null ? null : famiMoneyOffset(blob);
      if (blob == null || at == null) {
        throw SaveEditException.unreadable(package.path);
      }
      final edited = Uint8List.fromList(blob);
      ByteData.sublistView(edited).setInt32(at, funds, Endian.little);
      rewritten[fami] = edited;
    }

    final name = edit.name;
    if (name != null) {
      if (str == null) throw SaveEditException.householdGone();
      final blob = readDbpfResource(raf, str);
      final edited = blob == null ? null : _renameFamily(blob, name);
      if (edited == null) throw SaveEditException.unreadable(package.path);
      rewritten[str] = edited;
    }

    // Anything now stored plainly must stop claiming to be compressed.
    if (dir != null && rewritten.isNotEmpty) {
      final blob = readDbpfResource(raf, dir);
      if (blob != null) {
        rewritten[dir] = _pruneDir(
            blob, entryBytes == 24 ? 20 : 16, rewritten.keys.toList());
      }
    }

    final resources = <DbpfResource>[
      for (final entry in entries)
        if (rewritten[entry] case final bytes?)
          DbpfResource(
            type: entry.type,
            group: entry.group,
            instance: entry.instance,
            bytes: bytes,
          )
        else
          DbpfResource.copying(
              entry, readAt(raf, entry.offset, entry.fileSize)),
    ];
    final bytes = writeDbpfV1(header, entryBytes, resources);
    _verifyHood(bytes, familyInstance, edit, entries.length, package.path);
    return bytes;
  } on SaveEditException {
    rethrow;
  } catch (_) {
    throw SaveEditException.unreadable(package.path);
  } finally {
    try {
      raf?.closeSync();
    } catch (_) {}
  }
}

/// A family's string resource with the name replaced in every language
/// it carries.
///
/// These tables are pairs - the family's name, then the blurb the game
/// shows when the mouse rests on their house - repeated once per shipped
/// language, so the name is **the first entry of each language code**
/// and everything else is left alone. Rewriting only the English one
/// would rename the Goths for an English player and leave them Gothik in
/// German, which is exactly the seam the game's own translators avoided.
///
/// Strings that are not being replaced are copied as the bytes they
/// were, never re-encoded: the games wrote these in whatever the machine
/// was using at the time (see `game_text.dart`) and a round trip through
/// a decoder is how a hood full of accents turns to mojibake. The new
/// name goes in as UTF-8, which is what The Sims 2 writes.
///
/// Null when the resource is not the language-coded form this
/// understands, so a rename is refused rather than guessed at.
Uint8List? _renameFamily(Uint8List blob, String name) {
  if (blob.length < 0x44) return null;
  final d = ByteData.sublistView(blob);
  // 0xFFFD is the language-coded format, the only one a hood uses and
  // the only one the layout below describes.
  if (d.getUint16(0x40, Endian.little) != 0xFFFD) return null;
  final count = d.getUint16(0x42, Endian.little);
  final replacement = utf8.encode(name);

  final out = BytesBuilder()..add(Uint8List.sublistView(blob, 0, 0x44));
  final named = <int>{};
  var pos = 0x44;
  for (var i = 0; i < count; i++) {
    if (pos >= blob.length) return null;
    final language = blob[pos++];
    final title = _cStringRange(blob, pos);
    if (title == null) return null;
    pos = title.$2;
    final description = _cStringRange(blob, pos);
    if (description == null) return null;
    pos = description.$2;

    out.addByte(language);
    out.add(named.add(language)
        ? replacement
        : Uint8List.sublistView(blob, title.$1, title.$2 - 1));
    out.addByte(0);
    out.add(Uint8List.sublistView(blob, description.$1, description.$2 - 1));
    out.addByte(0);
  }
  return out.takeBytes();
}

/// The bounds of the NUL-terminated string at [pos]: where it starts,
/// and where the byte after its terminator is. Null when the terminator
/// is missing, which means the resource is truncated.
(int, int)? _cStringRange(Uint8List blob, int pos) {
  final start = pos;
  while (pos < blob.length && blob[pos] != 0) {
    pos++;
  }
  return pos < blob.length ? (start, pos + 1) : null;
}

/// The DIR resource without the records naming [plain]. Its records are
/// fixed-width - type, group, instance, (the instance's high half on a
/// 7.1 index,) then the size the resource decompresses to - so this is a
/// filter over a byte array and nothing more.
Uint8List _pruneDir(
    Uint8List blob, int recordBytes, List<DbpfEntry> plain) {
  final drop = <String>{
    for (final e in plain) '${e.type}/${e.group}/${e.instance}',
  };
  final d = ByteData.sublistView(blob);
  final out = BytesBuilder();
  for (var at = 0; at + recordBytes <= blob.length; at += recordBytes) {
    final high = recordBytes == 20 ? d.getUint32(at + 12, Endian.little) : 0;
    final key = '${d.getUint32(at, Endian.little)}/'
        '${d.getUint32(at + 4, Endian.little)}/'
        '${(high << 32) | d.getUint32(at + 8, Endian.little)}';
    if (drop.contains(key)) continue;
    out.add(Uint8List.sublistView(blob, at, at + recordBytes));
  }
  return out.takeBytes();
}

/// Refuses the rewritten package unless it reads back as the hood that
/// was asked for: the family there, saying what it was told to say, with
/// every resource still in the index.
void _verifyHood(Uint8List bytes, int familyInstance, HouseholdEdit edit,
    int expectedResources, String path) {
  try {
    final source = DbpfSource.bytes(bytes);
    final entries = readDbpfIndexFrom(source);
    if (entries == null || entries.length != expectedResources) {
      throw SaveEditException.verificationFailed(path);
    }
    DbpfEntry? fami;
    DbpfEntry? str;
    for (final e in entries) {
      final instance = e.instance & 0xFFFFFFFF;
      if (e.type == _famiType && instance == familyInstance) fami = e;
      if (e.type == _strType && instance == familyInstance) str = e;
    }
    final funds = edit.funds;
    if (funds != null) {
      final blob = fami == null ? null : readDbpfResourceFrom(source, fami);
      final at = blob == null ? null : famiMoneyOffset(blob);
      if (at == null ||
          ByteData.sublistView(blob!).getInt32(at, Endian.little) != funds) {
        throw SaveEditException.verificationFailed(path);
      }
    }
    final name = edit.name;
    if (name != null) {
      final blob = str == null ? null : readDbpfResourceFrom(source, str);
      final strings = blob == null ? const <String>[] : _parseStrResource(blob);
      if (strings.isEmpty || strings.first.trim() != name) {
        throw SaveEditException.verificationFailed(path);
      }
    }
  } on SaveEditException {
    rethrow;
  } catch (_) {
    throw SaveEditException.verificationFailed(path);
  }
}
