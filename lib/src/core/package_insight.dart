import 'dart:io';
import 'dart:typed_data';

import 'dbpf.dart';

/// A DBPF resource identity: the Type/Group/Instance triple the game uses
/// to look resources up. When two enabled packages carry the same key the
/// game keeps whichever it loads last, so shared keys mean the mods
/// override each other.
class ResourceKey {
  const ResourceKey(this.type, this.group, this.instance);

  final int type;
  final int group;

  /// 64-bit instance (high and low halves combined).
  final int instance;

  @override
  bool operator ==(Object other) =>
      other is ResourceKey &&
      other.type == type &&
      other.group == group &&
      other.instance == instance;

  @override
  int get hashCode => Object.hash(type, group, instance);

  @override
  String toString() =>
      '${type.toRadixString(16).padLeft(8, '0')}'
      ':${group.toRadixString(16).padLeft(8, '0')}'
      ':${instance.toRadixString(16).padLeft(16, '0')}';
}

/// What a best-effort look inside a mod file turned up: embedded artwork
/// and a coarse summary of what the package contains. Plain data, safe
/// to send across isolates.
class PackageInsight {
  const PackageInsight({
    this.thumbnail,
    this.resourceCount = 0,
    this.contents = const {},
    this.keys = const [],
  });

  final Uint8List? thumbnail;

  final int resourceCount;

  /// Human label -> count for recognized resource kinds ("CAS parts",
  /// "Textures", ...), largest first. Unrecognized types are not listed.
  final Map<String, int> contents;

  /// Every resource key in the package index, for conflict detection
  /// (`findResourceOverlaps` in conflicts.dart). Read from the index
  /// headers only - no resource data is touched - so collecting them is
  /// essentially free. Empty for non-package files, and for packages with
  /// more resources than [maxRetainedKeys].
  final List<ResourceKey> keys;

  /// Above this many resources a package's keys are dropped instead of
  /// kept. The insight cache holds one entry per mod for as long as the
  /// app runs, and a library can hold tens of thousands of them, so an
  /// unbounded per-file list is a real memory risk: merged collections
  /// carry tens of thousands of resources each. Such a package would also
  /// overlap half the library, which is noise rather than a useful
  /// warning, so sitting out overlap detection costs little.
  static const maxRetainedKeys = 8192;
}

/// Best-effort scan of a DBPF `.package` file.
///
/// Every Sims 2/3/4 mod is a DBPF archive: a header, a run of resource
/// blobs, and an index describing each blob (type/group/instance, offset,
/// size, compression). Custom content very often carries its own artwork
/// in there (Sims 4 CAS/Build-Buy thumbnails written by creator tools,
/// Sims 3 store-style PNG icons, Sims 2 Body Shop images), usually in
/// several sizes, so the scan measures every candidate's pixel dimensions
/// and keeps the sharpest one instead of the first hit.
///
/// The approach is deliberately forgiving: parse the index (dbpf.dart),
/// probe resources (known thumbnail types first, then everything else
/// smallest-first within a byte budget), undo the archive's compression,
/// and sniff PNG/JPEG signatures. Anything unreadable (not a DBPF file,
/// truncated, exotic compression) yields `null` and the UI falls back to
/// generated art. Never throws.
///
/// Synchronous on purpose: callers run it off the UI thread (the adapter
/// batches files through isolates), and widget tests need file IO that
/// can't leave a handle dangling in their fake-async zone.
PackageInsight? scanPackage(File file) {
  RandomAccessFile? raf;
  try {
    raf = file.openSync();
    return _scan(raf);
  } catch (_) {
    return null;
  } finally {
    try {
      raf?.closeSync();
    } catch (_) {}
  }
}

/// DBPF resource types that hold thumbnails/icons in some Sims game.
/// Probed first; a wrong or missing type is harmless because every blob
/// is verified by its image signature before being considered.
const _thumbnailTypes = <int>{
  // The Sims 4 thumbnail resources (JPEG with alpha, per s4pi).
  0x3C1AF1F2, 0x5B282D45, 0xCD9DE247, 0xE254AE6E,
  0x0D338A3A, 0x16CCF748, 0x3BD45407, 0xE18CAEE2,
  // The Sims 3 PNG icons and thumbnails.
  0x2F7D0004, 0x2E75C764, 0x626F60CD, 0x626F60CE,
  // The Sims 2 jpg/tga/png image resource (Body Shop previews).
  0x856DDBAC,
};

/// Resource type -> content label for the "what's inside" summary.
/// Best-effort and intentionally coarse; unknown types simply aren't
/// counted. IDs cover Sims 2 (ASCII-style ids), Sims 3, and Sims 4.
const _typeLabels = <int, String>{
  0x034AEECB: 'CAS parts', // CASP (Sims 3/4)
  0xC0DB5AE7: 'objects', // Sims 4 object definition
  0x319E4F1D: 'objects', // Sims 3 OBJD / Sims 4 catalog object
  0x4F424A44: 'objects', // Sims 2 OBJD
  0x0333406C: 'tunings', // XML tuning (Sims 3/4)
  0x545AC67A: 'tunings', // Sims 4 SimData
  0x42484156: 'behaviors', // Sims 2 BHAV
  0x220557DA: 'text tables', // Sims 4 STBL
  0x53545223: 'text tables', // Sims 2 STR#
  0x43545353: 'text tables', // Sims 2 CTSS catalog description
  0x1C4A276C: 'textures', // Sims 2 TXTR
  0x00B2D882: 'textures', // Sims 3 DDS image
  0x3453CF95: 'textures', // Sims 4 RLE2
  0xAC4F8687: 'meshes', // Sims 2 GMDC
  0x015A1849: 'meshes', // Sims 4 GEOM
  0x01661233: 'meshes', // MODL
  0x01D10F34: 'meshes', // MLOD
};

/// The Sims 2 DIR resource listing compressed entries, never an image.
const _dirResourceType = 0xE86B1EEF;

/// Biggest blob still considered a candidate thumbnail. Every embedded
/// preview any Sims game writes fits well inside this; the cap matters
/// because the image it finds is then held in the insight cache for the
/// rest of the session, once per mod, and because it keeps the probe from
/// reading megabytes out of every package in the library.
const _maxThumbnailBytes = 256 << 10;

/// How many resources to probe for artwork before giving up.
const _maxProbes = 512;

/// Total compressed bytes the artwork probe may read per package.
const _probeByteBudget = 8 << 20;

/// Once a found image reaches this many pixels (512x512), stop probing
/// the generic pool; it's sharp enough for any thumbnail slot.
const _goodEnoughArea = 512 * 512;

PackageInsight? _scan(RandomAccessFile raf) {
  final entries = readDbpfIndex(raf);
  if (entries == null) return null;

  final counts = <String, int>{};
  for (final e in entries) {
    final label = _typeLabels[e.type] ??
        (_thumbnailTypes.contains(e.type) ? 'thumbnails' : null);
    if (label != null) counts[label] = (counts[label] ?? 0) + 1;
  }
  final ordered = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  return PackageInsight(
    thumbnail: _bestThumbnail(raf, entries),
    resourceCount: entries.length,
    contents: {for (final e in ordered) e.key: e.value},
    keys: entries.length > PackageInsight.maxRetainedKeys
        ? const []
        : [for (final e in entries) ResourceKey(e.type, e.group, e.instance)],
  );
}

/// Probes resources for embedded artwork and returns the sharpest image
/// found (by pixel area), or `null`. Known thumbnail types are all
/// probed; the generic pool is walked smallest-first within [_maxProbes]
/// and [_probeByteBudget], stopping early once something crosses
/// [_goodEnoughArea]. Blobs over [_maxThumbnailBytes] are not candidates:
/// at library scale they are what a thumbnail cache cannot afford to hold,
/// and a preview image that big isn't one.
Uint8List? _bestThumbnail(RandomAccessFile raf, List<DbpfEntry> entries) {
  final preferred = <DbpfEntry>[];
  final rest = <DbpfEntry>[];
  for (final e in entries) {
    if (e.type == _dirResourceType) continue;
    if (e.fileSize < 16 || e.fileSize > _maxThumbnailBytes) continue;
    if (e.memSize > _maxThumbnailBytes) continue;
    (_thumbnailTypes.contains(e.type) ? preferred : rest).add(e);
  }
  rest.sort((a, b) => a.probeSize.compareTo(b.probeSize));

  Uint8List? best;
  var bestArea = -1;
  var probes = 0;
  var bytesRead = 0;

  void probe(DbpfEntry e) {
    probes++;
    bytesRead += e.fileSize;
    // The size the index promised is checked again inside: it is only a
    // claim, and this image is what gets held in memory.
    final data = readDbpfResource(raf, e, maxBytes: _maxThumbnailBytes);
    if (data == null) return;
    if (!(isPng(data) || isJpeg(data))) return;
    final area = imageArea(data);
    if (area > bestArea) {
      best = data;
      bestArea = area;
    }
  }

  for (final e in preferred) {
    if (probes >= _maxProbes || bytesRead >= _probeByteBudget) break;
    probe(e);
  }
  for (final e in rest) {
    if (probes >= _maxProbes || bytesRead >= _probeByteBudget) break;
    if (bestArea >= _goodEnoughArea) break;
    probe(e);
  }
  return best;
}
