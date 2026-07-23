import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

/// Compressed archive formats mods are commonly distributed in and the
/// app can unpack on install. Zip is decoded natively (pure Dart);
/// rar/7z are best-effort via the system's `tar` (bsdtar ships with
/// Windows 10+ and macOS, and reads both formats).
const archiveFileExtensions = {'.zip', '.rar', '.7z'};

/// Whether [path] points at an archive the app knows how to unpack.
bool isArchivePath(String path) =>
    archiveFileExtensions.contains(p.extension(path).toLowerCase());

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
  for (final entry in zip.files) {
    if (!entry.isFile) continue;
    final target = _safeTarget(destinationPath, entry.name, extensions);
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
  try {
    final ProcessResult result;
    try {
      result = await Process.run(
          'tar', ['-xf', archive.path, '-C', scratch.path]);
    } on ProcessException {
      throw FileSystemException(
          'Extracting $format archives needs the system tar tool, which was '
          'not found. Unpack ${p.basename(archive.path)} manually and '
          'install the files inside.');
    }
    if (result.exitCode != 0) {
      throw FileSystemException(
          'Could not extract ${p.basename(archive.path)}. Unpack it '
          'manually and install the files inside.');
    }
    final extracted = <String>[];
    await for (final entity in scratch.list(recursive: true)) {
      if (entity is! File) continue;
      final relative = p.relative(entity.path, from: scratch.path);
      final target = _safeTarget(destination.path, relative, extensions);
      if (target == null) continue;
      await File(target).parent.create(recursive: true);
      await entity.copy(target);
      extracted.add(target);
    }
    return extracted;
  } finally {
    try {
      await scratch.delete(recursive: true);
    } catch (_) {} // Best-effort cleanup of our own temp folder.
  }
}

/// Resolves an archive entry to its path under [destinationPath], or
/// `null` when the entry isn't a wanted mod file or tries to escape the
/// destination (zip-slip `../` entries, absolute paths).
String? _safeTarget(
    String destinationPath, String entryName, Set<String> extensions) {
  if (!extensions.contains(p.extension(entryName).toLowerCase())) return null;
  final relative = p.normalize(entryName);
  if (p.isAbsolute(relative)) return null;
  final target = p.normalize(p.join(destinationPath, relative));
  if (!p.isWithin(destinationPath, target)) return null;
  return target;
}
