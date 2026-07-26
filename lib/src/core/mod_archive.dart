import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import 'install_path.dart';

/// Compressed archive formats mods are commonly distributed in and the
/// app can unpack on install. Zip is decoded natively (pure Dart);
/// rar/7z are best-effort via the system's `tar` (bsdtar ships with
/// Windows 10+ and macOS, and reads both formats).
const archiveFileExtensions = {'.zip', '.rar', '.7z'};

bool isArchivePath(String path) =>
    archiveFileExtensions.contains(p.extension(path).toLowerCase());

/// An archive this machine can't unpack: no system `tar`, or bsdtar
/// refused the file (a password, one part of a split set, a format this
/// build of it can't read). Like [FormatException] here, it is a verdict
/// on the file rather than a bug to investigate, and [message] is
/// written for the user.
class ArchiveExtractionException implements Exception {
  const ArchiveExtractionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Extracts every file in [archive] whose extension (lowercase, with
/// dot) is in [fileExtensions] into [destination], preserving the
/// archive's internal folder structure, and returns the extracted files.
/// Anything else in the archive (readmes, screenshots) is skipped, as
/// are entries whose paths would escape [destination].
///
/// Throws with a user-readable message when the archive can't be read
/// or contains no matching files.
Future<List<File>> extractModFiles(
  File archive,
  Directory destination,
  Set<String> fileExtensions,
) async {
  final extension = p.extension(archive.path).toLowerCase();
  final extracted = extension == '.zip'
      // Decompression is CPU-bound; keep it off the UI thread. The
      // closure only captures sendable strings (see inspectMods' note
      // on isolate closures in game_adapter.dart).
      ? await _runZipExtract(archive.path, destination.path, fileExtensions)
      : await _extractWithSystemTar(archive, destination, fileExtensions);
  if (extracted.isEmpty) {
    final wanted = fileExtensions.join(', ');
    throw FormatException(
        'No mod files ($wanted) found inside ${p.basename(archive.path)}.');
  }
  return [for (final path in extracted) File(path)];
}

/// Top-level wrapper so the isolate closure can't capture caller state.
Future<List<String>> _runZipExtract(
        String archivePath, String destinationPath, Set<String> extensions) =>
    Isolate.run(() => _extractZip(archivePath, destinationPath, extensions));

List<String> _extractZip(
    String archivePath, String destinationPath, Set<String> extensions) {
  final Archive zip;
  try {
    zip = ZipDecoder().decodeBytes(File(archivePath).readAsBytesSync());
  } catch (_) {
    throw FormatException(
        '${p.basename(archivePath)} is not a readable zip archive.');
  }
  final extracted = <String>[];
  final taken = <String>{};
  for (final entry in zip.files) {
    if (!entry.isFile) continue;
    final target = _safeTarget(destinationPath, entry.name, extensions, taken);
    if (target == null) continue;
    File(target)
      ..parent.createSync(recursive: true)
      ..writeAsBytesSync(entry.content);
    extracted.add(target);
  }
  return extracted;
}

/// Rar and 7z have no pure-Dart decoders; bsdtar reads both and is
/// preinstalled on Windows 10+ and macOS (Linux: libarchive-tools).
/// Extracts to a temp folder, then moves just the mod files over.
Future<List<String>> _extractWithSystemTar(
  File archive,
  Directory destination,
  Set<String> extensions,
) async {
  final format = p.extension(archive.path).replaceFirst('.', '').toUpperCase();
  final scratch = await Directory.systemTemp.createTemp('mod_unpack');
  var root = scratch.path;
  try {
    final ProcessResult result;
    try {
      result = await Process.run(
          'tar', ['-xf', archive.path, '-C', scratch.path]);
    } on ProcessException {
      throw ArchiveExtractionException(
          'Extracting $format archives needs the system tar tool, which was '
          'not found. Unpack ${p.basename(archive.path)} manually and '
          'install the files inside.');
    }
    if (result.exitCode != 0) {
      throw ArchiveExtractionException(
          'Could not extract ${p.basename(archive.path)}. Unpack it '
          'manually and install the files inside.');
    }
    var walk = await _filesUnder(root);
    if (!walk.whole && Platform.isWindows) {
      // Something down there wouldn't open. bsdtar writes through
      // Windows' `\\?\` API, so an archive can leave behind paths longer
      // than the regular one takes, or names it normalises away
      // (trailing dots and spaces); that form is the only way to reach
      // them. It can only ever find more than the plain walk did - if it
      // finds less, this build doesn't take the prefix and the plain
      // walk stands.
      final extended = windowsExtendedPath(scratch.path);
      final retry = await _filesUnder(extended);
      if (retry.files.length >= walk.files.length) {
        root = extended;
        walk = retry;
      }
    }
    final unpacked = walk.files;
    final prefix = root.endsWith(Platform.pathSeparator)
        ? root
        : '$root${Platform.pathSeparator}';
    final extracted = <String>[];
    final taken = <String>{};
    for (final file in unpacked) {
      final relative = file.path.startsWith(prefix)
          ? file.path.substring(prefix.length)
          : p.basename(file.path);
      final target = _safeTarget(destination.path, relative, extensions, taken);
      if (target == null) continue;
      await File(target).parent.create(recursive: true);
      await file.copy(target);
      extracted.add(target);
    }
    return extracted;
  } finally {
    // Best-effort cleanup of our own temp folder. A name only the
    // extended form can address blocks the ordinary delete.
    try {
      await scratch.delete(recursive: true);
    } catch (_) {
      try {
        await Directory(windowsExtendedPath(scratch.path))
            .delete(recursive: true);
      } catch (_) {}
    }
  }
}

/// Every file anywhere under [root], and whether the walk reached all of
/// it: a folder the OS won't open (a name it can't address, a permission
/// wall) costs the files inside it, never the whole install.
Future<({List<File> files, bool whole})> _filesUnder(String root) async {
  final files = <File>[];
  var whole = true;
  await for (final entity in Directory(root)
      .list(recursive: true)
      .handleError((Object _) => whole = false)) {
    if (entity is File) files.add(entity);
  }
  return (files: files, whole: whole);
}

/// Resolves an archive entry to its path under [destinationPath], or
/// `null` when the entry isn't a wanted mod file or tries to escape the
/// destination (zip-slip `../` entries, absolute paths). [taken] carries
/// the paths already claimed by this extraction, so two entries the
/// platform's path rules push onto the same name don't overwrite each
/// other.
String? _safeTarget(String destinationPath, String entryName,
    Set<String> extensions, Set<String> taken) {
  if (!extensions.contains(p.extension(entryName).toLowerCase())) return null;
  final relative = p.normalize(entryName);
  if (p.isAbsolute(relative)) return null;
  final target = p.normalize(p.join(destinationPath, relative));
  if (!p.isWithin(destinationPath, target)) return null;
  return claimInstallTarget(destinationPath, relative, taken);
}
