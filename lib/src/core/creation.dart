import 'dart:typed_data';

/// Content a *player* built and shared: a lot, a room, a household, a
/// single sim. The third thing this app manages, after [Mod] (what the
/// modding scene writes) and [GamePack] (what the publisher ships).
///
/// It needs a vocabulary of its own because none of the others fit. A
/// downloaded lot is not a mod - it is not loaded from the mods folder,
/// it cannot be enabled or disabled, and dropping one in Mods is the
/// single most common way a download does nothing at all. It is not a
/// save either: it is one item the player places into a save, and the
/// games keep them in a separate folder for exactly that reason (the
/// Sims 4 Tray, the Sims 3 Library, the Sims 2 lot and sim bins, the
/// Sims 1 Houses folder).
///
/// Like [Mod] and [SaveGame] these are immutable snapshots, plain data
/// safe to send across isolates - the readers run off the UI thread. The
/// same translation bargain applies: [kindKey] and [ageKey]/[genderKey]
/// travel as stable English keys resolved by `AppText` at the moment they
/// are drawn, while everything a player typed ([name], [description],
/// [creatorName], sim names) is passed through verbatim because it is
/// theirs.
class Creation {
  const Creation({
    required this.name,
    required this.kindKey,
    required this.path,
    this.files = const [],
    this.sizeBytes = 0,
    this.modifiedAt,
    this.creatorName,
    this.description,
    this.worldName,
    this.thumbnail,
    this.sims = const [],
  });

  /// What the game shows this as. The player's own title where one is
  /// stored, the file name where it is not.
  final String name;

  /// [kindLot], [kindRoom], [kindHousehold] or [kindSim].
  final String kindKey;

  /// The one file the app treats as the creation itself - what "show in
  /// folder" reveals, and what identifies it in the selection. For a game
  /// whose creation is a set of files this is the set's anchor (the Sims
  /// 4 `.trayitem`), not the whole of it.
  final String path;

  /// Every file the creation is made of, [path] included. A Sims 4 tray
  /// item is five to a dozen files sharing an id, and deleting the one
  /// the card was drawn from would leave the rest as litter the game
  /// half-reads. One file for every other game today, which is why this
  /// defaults to describing itself.
  final List<String> files;

  /// What the whole of [files] costs on disk.
  final int sizeBytes;

  /// When it was last written, for "newest first" and the date on a card.
  final DateTime? modifiedAt;

  /// Who built it, where the format records a creator (the Sims 4 tray
  /// keeps the gallery account name).
  final String? creatorName;

  /// The blurb the creator wrote.
  final String? description;

  /// The world or address the item names, for the formats that keep one.
  final String? worldName;

  /// The picture the game's own catalog shows for it.
  final Uint8List? thumbnail;

  /// The sims that come with it: a household's members, or the one sim a
  /// [kindSim] creation is. Empty for a lot or a room, and empty for a
  /// household whose file gave nothing up.
  final List<CreationSim> sims;

  /// A creation whose files are all named here, so a caller deleting one
  /// never has to work out the set for itself.
  List<String> get allFiles => files.isEmpty ? [path] : files;
}

/// One sim inside a [Creation].
///
/// Thinner than [SaveSim] on purpose: a tray item carries who a sim is
/// for the catalog to draw, not the several hundred stats a save keeps
/// about a life already lived. Traits and aspiration arrive *already
/// worded*, like [SaveSim.careerName] and for the same reason - the set
/// is open-ended and pack-dependent, and the game wrote the words itself.
class CreationSim {
  const CreationSim({
    required this.firstName,
    this.lastName,
    this.ageKey,
    this.genderKey,
    this.traits = const [],
    this.aspiration,
    this.portrait,
  });

  final String firstName;
  final String? lastName;

  /// Life stage as a stable key (`baby`..`elder`), or null.
  final String? ageKey;

  /// `male` / `female`, or null.
  final String? genderKey;

  /// The trait names as the game spelled them.
  final List<String> traits;

  /// The sim's aspiration, likewise already worded.
  final String? aspiration;

  final Uint8List? portrait;

  String get fullName => lastName == null || lastName!.isEmpty
      ? firstName
      : '$firstName $lastName';
}

/// One of the folders a game reads player-built content from.
///
/// [labelKey] rather than a name, because these are the game's own
/// folders and the app words them: "Tray", "Library", "Lots & Houses",
/// "Sims", "Houses". [path] is what the files are copied into and what
/// "open folder" opens.
class CreationFolder {
  const CreationFolder({
    required this.labelKey,
    required this.path,
    this.labelArgs = const [],
    this.kinds = const [],
  });

  /// Stable key resolved by `AppText.creationFolderLabel` when drawn.
  final String labelKey;

  /// What goes in the label, for a game with more than one folder of the
  /// same sort - The Sims 1 has a Houses folder per neighborhood, and
  /// which neighborhood is the only thing that tells them apart.
  final List<String> labelArgs;

  final String path;

  /// The kinds this folder holds, when the game files them apart - the
  /// Sims 2 keeps lots in one bin and sims in another, so a household
  /// dropped on the app has exactly one place it can go. Empty means the
  /// folder takes whatever this game has, which is the Sims 3 and 4.
  final List<String> kinds;

  bool accepts(String kindKey) => kinds.isEmpty || kinds.contains(kindKey);
}

/// The verdict [GameAdapter.routeCreations] returns: these files are
/// player-built content, and here is where they go.
///
/// [files] is what was recognised, which need not be everything offered -
/// a download can be a lot beside a readme, and the readme is nobody's
/// business. [unrecognised] is the rest, so an install can still put
/// genuine mods where mods go instead of making the user choose between
/// the two halves of one download.
class CreationRouting {
  const CreationRouting({
    required this.folder,
    required this.files,
    this.kindKey,
    this.unrecognised = const [],
  });

  final CreationFolder folder;
  final List<String> files;

  /// What the recognised files turned out to be, when the routing could
  /// tell. Null when the folder takes everything anyway and nothing had
  /// to be opened to decide.
  final String? kindKey;

  final List<String> unrecognised;
}

/// A house or venue: a whole plot of land with what is built on it.
const kindLot = 'lot';

/// A single room, which the Sims 4 lets a player share on its own.
const kindRoom = 'room';

/// A family, saved with their clothes, traits and relationships.
const kindHousehold = 'household';

/// One sim on their own.
const kindSim = 'sim';

/// The order the filter chips are offered in: the two things a player
/// downloads most, then the two that are people. Not alphabetical, for
/// the same reason `modKindOrder` is not.
const creationKindOrder = <String>[
  kindLot,
  kindRoom,
  kindHousehold,
  kindSim,
];

/// How many creations carry each kind, for the chips - keyed and ordered
/// like [creationKindOrder] however the folder is made up.
Map<String, int> countCreationKinds(Iterable<Creation> creations) {
  final counts = <String, int>{};
  for (final creation in creations) {
    counts[creation.kindKey] = (counts[creation.kindKey] ?? 0) + 1;
  }
  return {
    for (final kind in creationKindOrder)
      if (counts.containsKey(kind)) kind: counts[kind]!,
    // A kind no one has heard of still gets a chip rather than vanishing
    // from the counts, the same way an unknown key draws as itself.
    for (final entry in counts.entries)
      if (!creationKindOrder.contains(entry.key)) entry.key: entry.value,
  };
}

/// Newest first, then by name so the order is total - `List.sort` is
/// unstable in Dart and two creations written in the same second would
/// otherwise swap places between builds. The same rule
/// `AppController._compareForLibrary` follows, and for the same reason.
int compareCreations(Creation a, Creation b) {
  final at = a.modifiedAt, bt = b.modifiedAt;
  if (at != null && bt != null && at != bt) return bt.compareTo(at);
  if (at == null && bt != null) return 1;
  if (at != null && bt == null) return -1;
  final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
  return byName != 0 ? byName : a.path.compareTo(b.path);
}
