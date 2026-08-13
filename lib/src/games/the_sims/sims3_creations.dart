import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../../core/creation.dart';
import '../../core/dbpf.dart';

/// Reads The Sims 3's Library - the lots, households and sims the player
/// exported from the game or installed from the Launcher.
///
/// Every item is one `.package`, which is the whole difficulty: a mod is
/// a `.package` too, and the two sit in folders a few levels apart. What
/// tells them apart is the thumbnail: the game writes a lot's renders,
/// a household's portraits and a sim's headshots under three distinct
/// resource types, and nothing that is a mod carries any of them. So the
/// same index scan that decides a mod's kind decides this, and it decides
/// it from the file rather than from the folder it happens to be in -
/// which is what lets a lot dropped on the window be routed to the
/// Library instead of into Mods, where it would do nothing at all.
///
/// The display name is the **file name**. The item's own metadata
/// resource does carry a name, and for anything EA published it is a
/// localization key ("World/LotName:HiddenSpringsFestival") that only the
/// game can resolve; the Launcher meanwhile names the file after the
/// item, and that name is what the player sees in their Library. So the
/// file wins, and the metadata is read only for the description and for
/// a name that is plainly a name.
///
/// Synchronous on purpose - the adapter runs it in an isolate.

/// Lot renders, small to large.
const _lotThumbnailTypes = <int>[0xD84E7FC5, 0xD84E7FC6, 0xD84E7FC7];

/// Household portraits.
const _householdThumbnailTypes = <int>[0x6B6D837D, 0x6B6D837E, 0x6B6D837F];

/// Single-sim headshots (the game's SNAP resources).
const _simThumbnailTypes = <int>[0x0580A2CD, 0x0580A2CE, 0x0580A2CF];

/// The item's own description record: a run of int32-count UTF-16LE
/// strings after a fixed prefix that is not fixed enough to index into,
/// so the strings are found by scanning rather than by offset.
const _metadataType = 0xD063545B;

/// A household's own record, which is where an exported family keeps the
/// names of the sims in it. Households written by the game carry no
/// description record at all, so without this every one of them would be
/// a card reading out the hash in its file name.
const _householdRecordType = 0x062853A8;

/// A file the game named rather than a person: `ebf_0x8bc9006d100460d0`.
/// For these the name inside the package is the only real one there is,
/// so it wins over the file - the reverse of every other item here.
final _machineNamedFile =
    RegExp(r'^[A-Za-z]{0,6}[_-]?0x[0-9A-Fa-f]{8,16}$');

/// An internal template id rather than a title: `Ven_Park_Old_1_64x32`,
/// `emptyLot_08`, `86LGavSubKeaton`. One word carrying an underscore or a
/// digit is the shape of a name the game generated; a title someone typed
/// has a space in it, and a one-word lot really called "Lot42" reads the
/// same off its own file name anyway.
bool _isTemplateId(String value) =>
    !value.contains(' ') &&
    (value.contains('_') || RegExp(r'\d').hasMatch(value));

/// A Library thumbnail is a catalog picture; the cap only stops a
/// misread header asking for the moon.
const _maxThumbnailBytes = 8 << 20;

/// The longest run of UTF-16 a description can be before the scan stops
/// believing it found one.
const _maxStringChars = 4000;

List<Creation> scanSims3Creations(String libraryPath) {
  final dir = Directory(libraryPath);
  if (!dir.existsSync()) return const [];

  final creations = <Creation>[];
  try {
    for (final entity in dir.listSync()) {
      if (entity is! File) continue;
      if (p.extension(entity.path).toLowerCase() != '.package') continue;
      final creation = readSims3Creation(entity);
      if (creation != null) creations.add(creation);
    }
  } catch (_) {
    return const [];
  }
  creations.sort(compareCreations);
  return creations;
}

/// What [file] is, or null when it is not player-built content at all -
/// which for a `.package` is the usual answer, since that is also what
/// every mod in the game is.
Creation? readSims3Creation(File file) {
  RandomAccessFile? raf;
  try {
    raf = file.openSync();
    final index = readDbpfIndex(raf);
    if (index == null) return null;
    final kind = sims3CreationKind(index);
    if (kind == null) return null;

    final stat = file.statSync();
    final metadata = _readMetadata(raf, index);
    final stem = p.basenameWithoutExtension(file.path);
    // The file name is the display name everywhere except where the game
    // wrote the file name itself, and there its address is a better title
    // than the hash it would otherwise be.
    final name = _machineNamedFile.hasMatch(stem)
        ? (metadata?.name ?? metadata?.world ?? stem)
        : stem;
    final world = metadata?.world == name ? null : metadata?.world;
    return Creation(
      name: name,
      kindKey: kind,
      path: file.path,
      files: [file.path],
      sizeBytes: stat.size,
      modifiedAt: stat.modified,
      description: metadata?.description,
      worldName: world,
      thumbnail: _bestThumbnail(raf, index, kind),
    );
  } catch (_) {
    return null;
  } finally {
    try {
      raf?.closeSync();
    } catch (_) {}
  }
}

/// Which kind of creation a package's resource index says it is, or null
/// for one that carries none of the three thumbnail families - a mod.
String? sims3CreationKind(List<DbpfEntry> index) {
  final types = <int>{for (final entry in index) entry.type};
  if (types.any(_lotThumbnailTypes.contains)) return kindLot;
  if (types.any(_householdThumbnailTypes.contains)) return kindHousehold;
  if (types.any(_simThumbnailTypes.contains)) return kindSim;
  return null;
}

List<int> _thumbnailTypesFor(String kind) => switch (kind) {
      kindLot => _lotThumbnailTypes,
      kindHousehold => _householdThumbnailTypes,
      _ => _simThumbnailTypes,
    };

/// The largest picture of the right family. The three types are the same
/// shot at three sizes, and the card wants the one worth looking at.
Uint8List? _bestThumbnail(
    RandomAccessFile raf, List<DbpfEntry> index, String kind) {
  final wanted = _thumbnailTypesFor(kind);
  Uint8List? best;
  var bestArea = -1;
  for (final entry in index) {
    if (!wanted.contains(entry.type)) continue;
    final data = readDbpfResource(raf, entry, maxBytes: _maxThumbnailBytes);
    if (data == null) continue;
    if (!isPng(data) && !isJpeg(data)) continue;
    final area = imageArea(data);
    if (area > bestArea) {
      best = data;
      bestArea = area;
    }
  }
  return best;
}

typedef _Metadata = ({String? name, String? description, String? world});

/// What the package says about itself, out of whichever of the two
/// records it carries.
///
/// The description record holds, in some order and not all of them every
/// time: an internal template id, the item's name, its blurb, and its
/// address. Most of those are localization keys for anything EA
/// published, which only the game can resolve. So each string is judged
/// on what it looks like rather than on where it sat, and anything that
/// cannot be read as one of the three is left out.
_Metadata? _readMetadata(RandomAccessFile raf, List<DbpfEntry> index) {
  String? name;
  String? description;
  String? world;
  for (final value in _stringsOf(raf, index, _metadataType)) {
    if (_isLocalizationKey(value)) {
      world ??= _addressIn(value);
      continue;
    }
    if (_isTemplateId(value) || !_looksLikeText(value)) continue;
    // A blurb is a sentence. Anything shorter is the item's own name the
    // first time and its street address the second.
    if (value.length > _shortestBlurb && _readsAsProse(value)) {
      if (description == null || value.length > description.length) {
        description = value;
      }
      continue;
    }
    if (name == null) {
      name = value;
    } else {
      world ??= value;
    }
  }
  // An exported family has no description record at all, so without this
  // every one of them would be a card reading out a hash.
  name ??= _householdName(raf, index);
  if (world != null && world == name) world = null;
  if (name == null && description == null && world == null) return null;
  return (name: name, description: description, world: world);
}

/// The first string in the household record, which is the family's own
/// name. Read at the offset it sits at rather than by scanning: this
/// record is mostly binary, and a scan over it finds runs of bytes that
/// decode into nonsense far more often than it finds the one name.
String? _householdName(RandomAccessFile raf, List<DbpfEntry> index) {
  final entry =
      index.where((e) => e.type == _householdRecordType).firstOrNull;
  if (entry == null) return null;
  final data = readDbpfResource(raf, entry);
  if (data == null || data.length < _householdNameOffset + 4) return null;
  final value = _utf16At(data, _householdNameOffset);
  return value != null && _looksLikeText(value) ? value : null;
}

/// Where the family name sits in the household record: four words of
/// bookkeeping and then the string.
const _householdNameOffset = 0x10;

/// A description is a sentence someone wrote; a lot's address ("Nouveau
/// Riche 3229") is not, and neither is its own name repeated.
const _shortestBlurb = 40;

List<String> _stringsOf(
    RandomAccessFile raf, List<DbpfEntry> index, int type) {
  final entry = index.where((e) => e.type == type).firstOrNull;
  if (entry == null) return const [];
  final data = readDbpfResource(raf, entry);
  return data == null ? const [] : _utf16Strings(data);
}

/// A key rather than a name: the game's own tables are addressed like
/// paths, and no player types "World/LotName:" into a title.
bool _isLocalizationKey(String value) =>
    value.contains(':') || value.contains('/');

/// The world out of an address key like
/// `DOT03/World/Venue/LotAddress:Lot15`, when one is spelled out.
String? _addressIn(String value) {
  final marker = value.indexOf('LotAddress:');
  if (marker < 0) return null;
  final address = value.substring(marker + 'LotAddress:'.length).trim();
  return address.isEmpty ? null : address;
}

/// Every int32-count UTF-16LE string in [data]. The layout the game uses
/// everywhere it writes text, and the only way through a record whose
/// prefix changes length between items.
List<String> _utf16Strings(Uint8List data) {
  final out = <String>[];
  for (var i = 0; i + 4 < data.length; i++) {
    final value = _utf16At(data, i);
    if (value == null) continue;
    out.add(value);
    i += 4 + value.length * 2 - 1;
  }
  return out;
}

/// The int32-count UTF-16LE string at [offset], or null when the bytes
/// there are not one.
String? _utf16At(Uint8List data, int offset) {
  final d = ByteData.sublistView(data);
  if (offset + 4 > data.length) return null;
  final count = d.getInt32(offset, Endian.little);
  if (count <= 2 ||
      count > _maxStringChars ||
      offset + 4 + count * 2 > data.length) {
    return null;
  }
  final units = <int>[];
  for (var j = 0; j < count; j++) {
    final unit = d.getUint16(offset + 4 + j * 2, Endian.little);
    // Control characters other than the line breaks a blurb really
    // carries mean this run of bytes was never text.
    if (unit < 0x20 && unit != 0x0A && unit != 0x0D) return null;
    units.add(unit);
  }
  return String.fromCharCodes(units);
}

/// Whether a run of bytes that decoded is actually text.
///
/// Any four bytes can be read as a length and any two after them as a
/// character, so a scan over a record that is mostly binary turns up
/// short strings of unrelated scripts. Demanding a Latin letter is what
/// separates a name from three CJK code points that were a float; a long
/// string is believed without one, so a description written in Japanese
/// or Russian still comes through. A short name in one of those scripts
/// does not, and falls back to the file name - which for a hand-exported
/// item is what the player typed anyway.
bool _looksLikeText(String value) {
  final trimmed = value.trim();
  if (trimmed.length < 3) return false;
  if (trimmed.length >= _believedWithoutLatin) return true;
  return RegExp('[A-Za-z]').hasMatch(trimmed);
}

/// Length past which a string is text whatever alphabet it is in.
const _believedWithoutLatin = 12;

/// Whether a long string is prose rather than something the engine wrote
/// about itself: a blurb has a space in its first few words, while
/// `Sims3.Store.Objects.GlassAndJewelryWorkbench+ArtisanSkillStore,
/// StoreObjects, Version=...` - a .NET type name, which these records do
/// carry - runs sixty characters before its first one.
bool _readsAsProse(String value) {
  final head = value.length <= _prosePrefix ? value : value.substring(0, _prosePrefix);
  return head.contains(' ');
}

const _prosePrefix = 30;
