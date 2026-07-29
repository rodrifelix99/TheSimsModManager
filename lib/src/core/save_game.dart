import 'dart:typed_data';

/// What the app knows about one save file after a best-effort look inside.
///
/// Every field beyond [name] and [path] is optional, because every game
/// stores something different and a parser that hit trouble reports what
/// it got: a Sims 2 neighborhood carries funds and skills, a Sims 3 save
/// only names its household, a Sims 1 hood has no images at all. The UI
/// draws what is there and never invents the rest.
///
/// Like [Mod], these are immutable snapshots, plain data safe to send
/// across isolates (the scanners run off the UI thread). Strings that
/// need translating travel as stable English keys - ages, genders,
/// skills - resolved by `AppText` at the moment they are drawn, the same
/// bargain as `Mod.category`. Player-written text (save names, household
/// names, descriptions) is passed through verbatim: it is the user's own.
class SaveGame {
  const SaveGame({
    required this.name,
    required this.path,
    this.modifiedAt,
    this.sizeBytes = 0,
    this.backupCount = 0,
    this.worldName,
    this.description,
    this.gameVersion,
    this.thumbnail,
    this.households = const [],
    this.photos = const [],
    this.worldsVisited = const [],
    this.neighborhoodNumber,
  });

  /// The save's own name where the game stores one (Sims 4 slot name),
  /// the file or folder name otherwise.
  final String name;

  /// The save on disk - a file (Sims 4) or a folder (Sims 3, Medieval,
  /// Sims 2 neighborhoods, Sims 1 UserData) - for "show in folder".
  final String path;

  /// When the game last wrote it.
  final DateTime? modifiedAt;

  /// The save itself plus its backups, so the card can say what this
  /// slot really costs on disk.
  final int sizeBytes;

  /// Rolling backup copies found next to the save (`.ver0`..`.ver4` and
  /// the daily/weekly/monthly tiers for Sims 4, `.backup` for Sims 3).
  final int backupCount;

  /// The world or neighborhood the save plays in, when the save records
  /// one ("Willow Creek", "Sunset Valley").
  final String? worldName;

  /// The player's own description of the save (Sims 3 writes one).
  final String? description;

  /// The game version that wrote the save, when it says (Sims 4).
  final String? gameVersion;

  /// The image the game's own load screen shows for this save.
  final Uint8List? thumbnail;

  /// Every household the save knows, played ones first.
  final List<SaveHousehold> households;

  /// Images the save carries beyond the one thumbnail: family portraits,
  /// lot renders, sim snapshots, storytelling photos.
  final List<SavePhoto> photos;

  /// Worlds this save has visited, for the games whose save folder keeps
  /// one file per world (Sims 3 vacations and university).
  final List<String> worldsVisited;

  /// Which of the game's numbered neighborhoods this save is, for the one
  /// game whose saves have no name of their own (Sims 1 UserData folders);
  /// the UI words it. Null everywhere else.
  final int? neighborhoodNumber;

  /// How many sims the save is credited with: the ones who live in
  /// [households], not every sim record the file holds. Every game in the
  /// series keeps more than that - a Sims 2 neighborhood its dead and its
  /// townie pools, a Sims 1 folder the same 21 service NPCs in every
  /// copy - and counting those makes "N sims in M households" a sentence
  /// about people who live nowhere.
  int get simCount => sims.length;

  /// Every sim across [households], the tally the stats view starts from.
  Iterable<SaveSim> get sims sync* {
    for (final household in households) {
      yield* household.members;
    }
  }
}

class SaveHousehold {
  const SaveHousehold({
    required this.name,
    this.funds,
    this.lotName,
    this.isPlayed = true,
    this.description,
    this.creatorName,
    this.bedrooms,
    this.bathrooms,
    this.propertyValue,
    this.lotTypeKey,
    this.portrait,
    this.members = const [],
    this.relationships = const [],
  });

  final String name;

  /// Household funds in simoleons.
  final int? funds;

  /// The lot or address the household lives at.
  final String? lotName;

  /// Whether this is a household the player actually plays, as opposed
  /// to the townies and service sims the game populates a world with.
  final bool isPlayed;

  final String? description;
  final String? creatorName;

  /// Home lot rooms, for the games whose saves record them (Sims 4).
  final int? bedrooms;
  final int? bathrooms;

  /// Everything the household owns beyond its cash - the value the game
  /// puts on the house and what is in it. The Sims 1 records it, and
  /// "funds plus this" is the net worth the game itself quotes.
  final int? propertyValue;

  /// What kind of lot the household lives on, as a stable key
  /// (`residential`, `community`, `dorm`, ...), or null.
  final String? lotTypeKey;

  /// The household's portrait or its home lot's render, whichever the
  /// save carries.
  final Uint8List? portrait;

  final List<SaveSim> members;

  /// Relationships between this household's own members. Cross-household
  /// bonds exist in the files too, but a panel about one family draws
  /// this family's.
  final List<SaveRelationship> relationships;
}

class SaveSim {
  const SaveSim({
    required this.firstName,
    this.lastName,
    this.ageKey,
    this.genderKey,
    this.zodiacKey,
    this.aspirationKey,
    this.careerName,
    this.careerLevel,
    this.occultKey,
    this.isGhost = false,
    this.bio,
    this.skills = const {},
    this.personality = const {},
    this.interests = const {},
    this.hobbies = const {},
    this.predestinedHobbyKey,
    this.education,
    this.familyTies = const [],
    this.portrait,
  });

  final String firstName;
  final String? lastName;

  /// Life stage as a stable key (`baby`..`elder`), translated when drawn;
  /// null when the save doesn't store one.
  final String? ageKey;

  /// `male` / `female`, or null.
  final String? genderKey;

  /// Star sign key (Sims 1/2 store one), or null.
  final String? zodiacKey;

  /// Aspiration key for the games that store an enum (Sims 2), or null.
  final String? aspirationKey;

  /// The career or school the sim is in, already worded - unlike the
  /// stable keys around it, this is looked up from the game's own tables
  /// by the scanner, because the set is open-ended and pack-dependent.
  final String? careerName;

  /// Level within [careerName], 1-based, when the save records one.
  final int? careerLevel;

  /// What the sim is other than human - `vampire`, `zombie`, `werewolf`,
  /// `plantSim`, `alien`, `servo`, `witch` - as a stable key. Null for a
  /// plain sim, which is nearly all of them.
  final String? occultKey;

  /// Whether the sim is dead and hanging around (The Sims 1 records it as
  /// a plain flag).
  final bool isGhost;

  /// The biography the game shows on the sim's own panel, when the save
  /// keeps one (The Sims 2 writes it next to the name).
  final String? bio;

  /// Skill key -> points on the game's own 0-1000 scale (100 = one skill
  /// point as the game shows it). Empty when the save doesn't store
  /// skills, which is not the same as storing zeros.
  final Map<String, int> skills;

  /// Personality axis key -> points, same 0-1000 scale.
  final Map<String, int> personality;

  /// Interest key -> points, same 0-1000 scale. What a sim likes talking
  /// about; Sims 1 and 2 both track these.
  final Map<String, int> interests;

  /// Hobby key -> enthusiasm, same 0-1000 scale: what the sim actually
  /// spends their free time on.
  final Map<String, int> hobbies;

  /// The one hobby the game decided this sim was born for, as a key.
  /// Null when the save predates hobbies or never rolled one.
  final String? predestinedHobbyKey;

  /// Their degree, for a sim who went to university.
  final SaveEducation? education;

  /// Parents, spouse, siblings and children, wherever they now live.
  final List<SaveFamilyTie> familyTies;

  final Uint8List? portrait;

  String get fullName => lastName == null || lastName!.isEmpty
      ? firstName
      : '$firstName $lastName';
}

/// One link in a sim's family tree: who [name] is to them. Ties reach
/// across households - a sim's mother may have moved out years ago - so
/// this carries the name rather than a reference into one household.
class SaveFamilyTie {
  const SaveFamilyTie({required this.kindKey, required this.name});

  /// `mother`, `father`, `spouse`, `sibling` or `child`, translated when
  /// drawn.
  final String kindKey;

  final String name;
}

/// What a sim is studying, for the one game that tracks a degree.
class SaveEducation {
  const SaveEducation({this.major, this.gpa, this.semester});

  /// The subject, already worded - like [SaveSim.careerName], it is
  /// looked up from the game's own table rather than kept as a key.
  final String? major;

  /// Grade point average on the usual 0-4 scale.
  final double? gpa;

  /// Which semester of the eight they are in.
  final int? semester;

  bool get isEmpty => major == null && gpa == null && semester == null;
}

class SaveRelationship {
  const SaveRelationship({
    required this.nameA,
    required this.nameB,
    required this.score,
    this.labelKeys = const [],
  });

  final String nameA;
  final String nameB;

  /// Daily relationship score on the games' own -100..100 scale.
  final int score;

  /// Stable keys for the flags the save sets on this pair (`married`,
  /// `friends`, `enemies`, ...), translated when drawn.
  final List<String> labelKeys;
}

/// One image from a save beyond its thumbnail. Carries either [bytes]
/// (extracted from inside a package) or [path] (a loose file on disk,
/// which stays there instead of being held in memory).
class SavePhoto {
  const SavePhoto({
    this.bytes,
    this.path,
    this.kindKey = 'snapshot',
    this.caption,
    this.modifiedAt,
  });

  /// Stable key for what the image is - `familyPortrait`, `lot`, `sim`,
  /// `snapshot` - so the album can caption it without guessing.
  final String kindKey;

  final Uint8List? bytes;
  final String? path;

  /// A name the save gives the image (the family it portrays, the lot it
  /// renders), when it gives one.
  final String? caption;

  final DateTime? modifiedAt;
}
