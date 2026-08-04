import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import 'mod.dart';

/// Finding mods whose files are byte-for-byte the same, which is the one
/// clash `conflicts.dart` deliberately cannot answer: it reads names and
/// resource keys, so the same download saved twice under two names looks
/// to it like two mods that happen to override each other.
///
/// The identity is the file's SHA-256, never its name, its version token
/// or its resources. That matters because the answer is offered with a
/// delete button next to it: two files with the same digest are the same
/// file, and nothing weaker than a whole-file hash may be worded that
/// way to the user.
///
/// Cost is kept off the library by the size pass. Two files of different
/// lengths cannot be identical, so only the ones sharing a size with some
/// other mod are ever opened - in a real library a handful out of
/// thousands. [duplicateCandidates] is that pass and is pure; the reading
/// happens in [hashModFiles].

/// A set of mods that are the same file. Always two or more.
class DuplicateSet {
  const DuplicateSet(this.digest, this.sizeBytes, this.mods);

  /// Lowercase hex SHA-256 of the file every member carries.
  final String digest;

  final int sizeBytes;

  /// The members, [keeperFirst] order: the copy the UI suggests keeping
  /// leads, and the rest are what a "delete the extras" action ticks.
  final List<Mod> mods;

  /// What deleting all but one would give back.
  int get wastedBytes => sizeBytes * (mods.length - 1);
}

/// The mods worth opening: those sharing a byte size with another mod.
///
/// Empty files are left out. They are all identical to each other by
/// definition, they are never a mod anyone downloaded, and a set of
/// forty of them at the top of the list would bury the real answer.
List<Mod> duplicateCandidates(List<Mod> mods) {
  final bySize = <int, List<Mod>>{};
  for (final mod in mods) {
    final size = mod.sizeBytes;
    if (size == null || size <= 0) continue;
    bySize.putIfAbsent(size, () => []).add(mod);
  }
  return [
    for (final group in bySize.values)
      if (group.length > 1) ...group,
  ];
}

/// The duplicate sets in [mods], given whatever digests are known
/// ([digestOf] answers null for a mod that was never hashed, which is
/// every mod the size pass ruled out).
///
/// Pure, and cheap enough to re-run whenever the library changes: it is
/// what keeps the sets honest after a toggle, a move or a delete without
/// reading a single file again.
List<DuplicateSet> duplicateSetsOf(
  List<Mod> mods,
  String? Function(Mod mod) digestOf,
) {
  final byDigest = <String, List<Mod>>{};
  for (final mod in mods) {
    final digest = digestOf(mod);
    if (digest != null) byDigest.putIfAbsent(digest, () => []).add(mod);
  }
  final sets = <DuplicateSet>[];
  for (final entry in byDigest.entries) {
    if (entry.value.length < 2) continue;
    final members = entry.value..sort(keeperFirst);
    sets.add(DuplicateSet(
        entry.key, members.first.sizeBytes ?? 0, List.unmodifiable(members)));
  }
  // Biggest saving first: the point of the screen is the space back.
  sets.sort((a, b) {
    final byWaste = b.wastedBytes.compareTo(a.wastedBytes);
    return byWaste != 0 ? byWaste : a.digest.compareTo(b.digest);
  });
  return sets;
}

/// The order members of a set are offered in. First place is a
/// suggestion and not a verdict - which copy of an identical pair is
/// "the real one" is a question about the user's folders that the bytes
/// cannot answer - so it goes for the least surprising copy to keep:
/// the one that is switched on, nearest the top of the mods folder, and
/// oldest, in that order. The path breaks the last tie, because two mods
/// must never come out in an order that depends on the run.
int keeperFirst(Mod a, Mod b) {
  if (a.isEnabled != b.isEnabled) return a.isEnabled ? -1 : 1;
  // Depth off the path, not the name: [Mod.name] is a bare file name for
  // every game, so it says nothing about which subfolder a copy sits in.
  // Every member of a set is under the same mods folder, so counting
  // whole segments ranks them without needing to know where that is.
  final depth = _depthOf(a.path).compareTo(_depthOf(b.path));
  if (depth != 0) return depth;
  final aTime = a.modifiedAt;
  final bTime = b.modifiedAt;
  if (aTime != null && bTime != null) {
    final byAge = aTime.compareTo(bTime);
    if (byAge != 0) return byAge;
  } else if (aTime != bTime) {
    return aTime == null ? 1 : -1;
  }
  return a.path.toLowerCase().compareTo(b.path.toLowerCase());
}

int _depthOf(String path) => p.split(path.replaceAll('\\', '/')).length;

/// SHA-256 of every file in [mods], as path -> lowercase hex. A file
/// that cannot be read is left out rather than reported as anything.
///
/// Batched across isolates like `GameAdapter.inspectMods`, for the same
/// reason: hashing is the one thing in the app that reads whole files,
/// and a library with a gigabyte of same-sized packages would otherwise
/// hold the window still for the duration. [onProgress] counts files,
/// and [isCancelled] is checked between batches, so a scan the user
/// walked away from stops at the next boundary rather than at the end.
Future<Map<String, String>> hashModFiles(
  List<Mod> mods, {
  void Function(int done, int total)? onProgress,
  bool Function()? isCancelled,
}) async {
  final digests = <String, String>{};
  if (mods.isEmpty) return digests;
  final paths = [for (final mod in mods) mod.path];
  final batchSize = (paths.length ~/ 64).clamp(1, 16);
  final batches = [
    for (var i = 0; i < paths.length; i += batchSize)
      paths.sublist(
          i, i + batchSize > paths.length ? paths.length : i + batchSize),
  ];
  var done = 0;
  var next = 0;
  Future<void> worker() async {
    while (next < batches.length && !(isCancelled?.call() ?? false)) {
      final batch = batches[next++];
      Map<String, String?> hashed;
      try {
        hashed = await _hashBatch(batch);
      } catch (_) {
        hashed = const {};
      }
      for (final entry in hashed.entries) {
        final digest = entry.value;
        if (digest != null) digests[entry.key] = digest;
      }
      done += batch.length;
      onProgress?.call(done, paths.length);
    }
  }

  await Future.wait([
    for (var i = 0; i < _workers && i < batches.length; i++) worker(),
  ]);
  return digests;
}

/// Concurrent hashing isolates. Fewer than the artwork scan's: this pass
/// is bound by the disk rather than by the parsing, and four readers on
/// one spinning drive is slower than two.
const _workers = 2;

/// Read size per file. Whole-file reads are not an option here - the
/// files this opens run to hundreds of megabytes.
const _chunkBytes = 1 << 20;

/// Spawned from a static scope whose only local is [batch]: a closure
/// built inside [hashModFiles] would capture the caller's `onProgress`,
/// and through it the whole controller, which is expensive to copy into
/// the isolate and fails outright on anything unsendable.
Future<Map<String, String?>> _hashBatch(List<String> batch) =>
    Isolate.run(() => {for (final path in batch) path: _hashFile(path)});

String? _hashFile(String path) {
  RandomAccessFile? file;
  try {
    file = File(path).openSync();
    final sink = _DigestSink();
    final input = sha256.startChunkedConversion(sink);
    final buffer = Uint8List(_chunkBytes);
    while (true) {
      final read = file.readIntoSync(buffer);
      if (read <= 0) break;
      input.add(read == buffer.length
          ? buffer
          : Uint8List.sublistView(buffer, 0, read));
    }
    input.close();
    return sink.value?.toString();
  } catch (_) {
    // Locked by the game, deleted mid-scan, unreadable: a file we cannot
    // hash is one we must not claim anything about.
    return null;
  } finally {
    try {
      file?.closeSync();
    } catch (_) {}
  }
}

/// Catches the one digest a chunked SHA-256 conversion emits.
/// `package:convert`'s AccumulatorSink would do, for a dependency.
class _DigestSink implements Sink<Digest> {
  Digest? value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}
