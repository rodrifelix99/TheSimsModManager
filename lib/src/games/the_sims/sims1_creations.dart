import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../../core/bitmap.dart';
import '../../core/creation.dart';
import 'sims1_saves.dart';

/// Reads The Sims 1's downloaded houses out of a neighborhood's `Houses`
/// folder.
///
/// The Sims 1 has no gallery and no household export: what the scene
/// shared, and still shares, is a house - one `HouseNN.iff` dropped into
/// `UserData/Houses` with a free number. So this game's creations are
/// lots and only lots, which is the honest answer rather than an empty
/// Households shelf.
///
/// The number is the identity: the game reads houses by slot, the
/// neighborhood's `NeighborhoodDesc.iff` names them by `house + 2000`,
/// and two files cannot share a slot. That is also what makes installing
/// one more than a copy - see [nextFreeHouseNumber].
///
/// The picture is the game's own render of the lot, a Windows bitmap in
/// the house file's `BMP_` chunk 513 (roof on). Names and descriptions
/// come from the neighborhood's description file, so a house whose slot
/// nothing has named yet reads as its file - which is exactly what the
/// game shows in that case too.
///
/// Synchronous on purpose - the adapter runs it in an isolate.

/// `House12.iff`. The game zero-pads to two digits and has never written
/// more, but a three-digit slot from a hand-built neighborhood is read
/// rather than ignored.
final _houseName =
    RegExp(r'^House(\d{1,3})\.iff$', caseSensitive: false);

/// Houses below 80 are named in `NeighborhoodDesc.iff`, 80-89 (Studio
/// Town) in `STDesc.iff`, 90 and up (Magic Town) in `MTDesc.iff`. The
/// same split [scanSims1Saves] reads, and for the same reason.
String _descriptionFileFor(int number) => number < 80
    ? 'NeighborhoodDesc.iff'
    : number < 90
        ? 'STDesc.iff'
        : 'MTDesc.iff';

/// The highest slot the game will look at. Beyond this a house is on disk
/// and invisible, which is the same trap the mods-too-deep banner warns
/// about, so an install refuses rather than writing one.
const maxHouseNumber = 99;

List<Creation> scanSims1Creations(String housesPath) {
  final dir = Directory(housesPath);
  if (!dir.existsSync()) return const [];

  final names = _HouseDescriptions(dir);
  final creations = <Creation>[];
  try {
    for (final entity in dir.listSync()) {
      if (entity is! File) continue;
      final match = _houseName.firstMatch(p.basename(entity.path));
      if (match == null) continue;
      final number = int.parse(match.group(1)!);
      creations.add(_readHouse(entity, number, names));
    }
  } catch (_) {
    return const [];
  }
  creations.sort(compareCreations);
  return creations;
}

Creation _readHouse(File file, int number, _HouseDescriptions names) {
  Uint8List? bytes;
  try {
    bytes = file.readAsBytesSync();
  } catch (_) {}

  Uint8List? thumbnail;
  if (bytes != null) {
    try {
      for (final chunk in readIffChunks(bytes)) {
        if (chunk.type == 'BMP_' && chunk.id == houseThumbnailChunk) {
          thumbnail = bmpToPng(chunk.data);
          break;
        }
      }
    } catch (_) {
      // A house whose picture will not decode is still a house.
    }
  }

  final described = names.of(number);
  var size = 0;
  DateTime? modified;
  try {
    final stat = file.statSync();
    size = stat.size;
    modified = stat.modified;
  } catch (_) {}

  return Creation(
    name: described?.name ?? p.basenameWithoutExtension(file.path),
    kindKey: kindLot,
    path: file.path,
    files: [file.path],
    sizeBytes: size,
    modifiedAt: modified,
    description: described?.description,
    thumbnail: thumbnail,
  );
}

/// The lowest slot in [housesPath] that no house occupies, or null when
/// the neighborhood is full.
///
/// This is what an install has to answer before it can copy anything: the
/// file name is not decoration, it is where the game will look for the
/// lot, and dropping in a `House03.iff` that already exists replaces
/// somebody's house. Slot 00 is skipped - the game keeps it for its own
/// bulldozed-lot template.
int? nextFreeHouseNumber(String housesPath) {
  final taken = <int>{};
  try {
    for (final entity in Directory(housesPath).listSync()) {
      if (entity is! File) continue;
      final match = _houseName.firstMatch(p.basename(entity.path));
      if (match != null) taken.add(int.parse(match.group(1)!));
    }
  } catch (_) {
    return null;
  }
  for (var number = 1; number <= maxHouseNumber; number++) {
    if (!taken.contains(number)) return number;
  }
  return null;
}

/// The file name a house takes in slot [number].
String houseFileName(int number) =>
    'House${number.toString().padLeft(2, '0')}.iff';

/// Whether [path] is a Sims 1 house file, told by its name. Nothing else
/// in the game's folders is called this, and the alternative - opening
/// every `.iff` in a download - would mean reading the game's own object
/// files to find out they are not houses.
bool isSims1HouseFile(String path) =>
    _houseName.hasMatch(path.split(RegExp(r'[\\/]')).last);

/// Names and blurbs for the houses of one neighborhood, read once.
class _HouseDescriptions {
  _HouseDescriptions(this._houses);

  final Directory _houses;
  final _cache = <String, Map<int, List<String>>>{};

  ({String name, String? description})? of(int number) {
    final strings = _load(_descriptionFileFor(number))[number + 2000];
    if (strings == null || strings.isEmpty) return null;
    final name = strings.first.trim();
    if (name.isEmpty) return null;
    final description =
        strings.length > 1 && strings[1].trim().isNotEmpty ? strings[1] : null;
    return (name: name, description: description);
  }

  Map<int, List<String>> _load(String fileName) =>
      _cache.putIfAbsent(fileName, () {
        final out = <int, List<String>>{};
        try {
          final file = File(p.join(_houses.path, fileName));
          if (!file.existsSync()) return out;
          for (final chunk in readIffChunks(file.readAsBytesSync())) {
            if (chunk.type != 'STR#') continue;
            final strings = parseIffStrings(chunk.data);
            if (strings.isNotEmpty) out[chunk.id] = strings;
          }
        } catch (_) {
          // No names is a worse library than named houses, not a failure.
        }
        return out;
      });
}
