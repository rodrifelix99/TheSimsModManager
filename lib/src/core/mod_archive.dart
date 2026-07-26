import 'dart:io';
import 'dart:isolate';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

import 'app_message.dart';
import 'install_path.dart';

/// Compressed archive formats mods are commonly distributed in and the
/// app can unpack on install. Zip is decoded natively (pure Dart);
/// rar and 7z have no pure-Dart decoder and go through whichever
/// external unpacker the machine has (see [archiveUnpackers]), as does
/// the odd zip the native decoder can't read.
const archiveFileExtensions = {'.zip', '.rar', '.7z'};

bool isArchivePath(String path) =>
    archiveFileExtensions.contains(p.extension(path).toLowerCase());

/// Why an archive stayed packed.
enum ArchiveExtractionFailure {
  /// Nothing installed on this machine reads the format.
  noUnpacker,

  /// An unpacker was there and refused the file: a password, one part of
  /// a split set, a damaged download, a format variant it can't read.
  refused,
}

/// An archive this machine couldn't unpack. Like [ModContentException]
/// here, it is a verdict on the file or the machine rather than a bug to
/// investigate, and [detail] is what to tell the user.
class ArchiveExtractionException implements Exception {
  const ArchiveExtractionException(this.detail,
      {this.cause = ArchiveExtractionFailure.refused});

  final AppMessage detail;
  final ArchiveExtractionFailure cause;

  @override
  String toString() => '$detail';
}

/// Extracts every file in [archive] whose extension (lowercase, with
/// dot) is in [fileExtensions] into [destination], preserving the
/// archive's internal folder structure, and returns the extracted files.
/// Anything else in the archive (readmes, screenshots) is skipped, as
/// are entries whose paths would escape [destination].
///
/// Throws an [AppMessage]-carrying exception when the archive can't be
/// read or contains no matching files.
Future<List<File>> extractModFiles(
  File archive,
  Directory destination,
  Set<String> fileExtensions,
) async {
  final extension = p.extension(archive.path).toLowerCase();
  final extracted = extension == '.zip'
      ? await _extractZip(archive, destination, fileExtensions)
      : await _extractWithUnpacker(archive, destination, fileExtensions);
  if (extracted.isEmpty) {
    throw ModContentException.noModFiles(
        fileExtensions, p.basename(archive.path));
  }
  return [for (final path in extracted) File(path)];
}

/// The pure-Dart decoder first, then an external unpacker for what it
/// couldn't make sense of: a compression method it doesn't know (WinZip's
/// deflate64 is all over old CC), or a rar wearing a .zip name. If they
/// can't read it either, the decoder's verdict was the right one and it
/// is what the user hears.
Future<List<String>> _extractZip(
  File archive,
  Directory destination,
  Set<String> extensions,
) async {
  final List<String> native;
  try {
    native = await _runZipExtract(archive.path, destination.path, extensions);
  } on FormatException catch (unreadable) {
    try {
      return await _extractWithUnpacker(archive, destination, extensions);
    } catch (_) {
      throw unreadable;
    }
  }
  // An empty result is the same question asked the other way round: the
  // decoder skips an entry it can't inflate as readily as it rejects the
  // whole file, so let an unpacker look before calling the zip empty.
  if (native.isNotEmpty) return native;
  try {
    return await _extractWithUnpacker(archive, destination, extensions);
  } catch (_) {
    return native;
  }
}

/// Top-level wrapper so the isolate closure can't capture caller state.
Future<List<String>> _runZipExtract(
        String archivePath, String destinationPath, Set<String> extensions) =>
    Isolate.run(() => _decodeZip(archivePath, destinationPath, extensions));

List<String> _decodeZip(
    String archivePath, String destinationPath, Set<String> extensions) {
  final Archive zip;
  try {
    zip = ZipDecoder().decodeBytes(File(archivePath).readAsBytesSync());
  } catch (_) {
    throw _unreadableZip(archivePath);
  }
  // Bytes that are no zip at all rarely make the decoder throw: a
  // truncated download, a renamed rar, plain garbage all come back as an
  // archive with nothing in it instead. Same verdict, so it travels the
  // same way - and an entry we merely didn't want is a different thing,
  // which is why this counts entries and not extracted files.
  if (zip.files.isEmpty) throw _unreadableZip(archivePath);
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

ModContentException _unreadableZip(String archivePath) => ModContentException(
    AppMessage('unreadableArchive', [p.basename(archivePath)]));

/// An external command that unpacks archives, and how to drive it. Rar
/// and 7z have no pure-Dart decoders, so this is the only way in.
class ArchiveUnpacker {
  const ArchiveUnpacker(
    this.executable, {
    required this.formats,
    required this.arguments,
    this.libarchiveOnly = false,
  });

  /// The command, as found on PATH.
  final String executable;

  /// Archive extensions it reads, lowercase and without the dot.
  final Set<String> formats;

  /// The arguments that extract [archive] into an existing [destination].
  final List<String> Function(String archive, String destination) arguments;

  /// `tar` is two different programs. Windows 10+ and macOS ship
  /// libarchive's, which reads rar and 7z; Linux distributions ship
  /// GNU's, which reads neither and is why a rar install there failed
  /// every time. Only `--version` tells them apart.
  final bool libarchiveOnly;
}

/// The unpackers we know how to drive, in the order they're tried: the
/// preinstalled `tar` of Windows 10+ and macOS first, then what a Linux
/// user installs for the job (libarchive-tools as `bsdtar`, p7zip as
/// `7z`/`7zz`/`7za`, unrar). Whichever fails on a given archive falls
/// through to the next, so a format one build can't read isn't the end
/// of the install.
const archiveUnpackers = <ArchiveUnpacker>[
  ArchiveUnpacker('tar',
      formats: _everyFormat, arguments: _tarArguments, libarchiveOnly: true),
  ArchiveUnpacker('bsdtar', formats: _everyFormat, arguments: _tarArguments),
  ArchiveUnpacker('7z', formats: _everyFormat, arguments: _sevenZipArguments),
  ArchiveUnpacker('7zz', formats: _everyFormat, arguments: _sevenZipArguments),
  ArchiveUnpacker('7za', formats: _everyFormat, arguments: _sevenZipArguments),
  ArchiveUnpacker('unrar', formats: {'rar'}, arguments: _unrarArguments),
];

/// Zip only reaches an unpacker when the Dart decoder gave up on it.
const _everyFormat = {'rar', '7z', 'zip'};

List<String> _tarArguments(String archive, String destination) =>
    ['-xf', archive, '-C', destination];

// -y answers the prompts, -p the password one: an encrypted archive has
// to fail rather than sit there waiting on a stdin nobody is watching.
List<String> _sevenZipArguments(String archive, String destination) =>
    ['x', '-y', '-p', '-o$destination', archive];

List<String> _unrarArguments(String archive, String destination) =>
    ['x', '-y', '-p-', archive, '$destination${Platform.pathSeparator}'];

/// How unpacker processes are launched. Tests replace it to fake which
/// unpackers a machine has; setting it forgets what was probed.
set archiveProcessRunner(
    Future<ProcessResult> Function(String, List<String>) runner) {
  _runProcess = runner;
  _probed.clear();
}

Future<ProcessResult> Function(String, List<String>) _runProcess = Process.run;

/// Which executables answered, remembered for the run: probing costs a
/// process launch each and the answer doesn't change while we're open.
final _probed = <String, bool>{};

Future<bool> _isInstalled(ArchiveUnpacker unpacker) async {
  final known = _probed[unpacker.executable];
  if (known != null) return known;
  bool present;
  try {
    final version = await _runProcess(unpacker.executable, const ['--version']);
    present = !unpacker.libarchiveOnly ||
        '${version.stdout}'.toLowerCase().contains('libarchive');
  } on ProcessException {
    present = false; // Not on PATH.
  }
  return _probed[unpacker.executable] = present;
}

/// Unpacks to a temp folder with the first unpacker that manages it,
/// then moves just the mod files over.
Future<List<String>> _extractWithUnpacker(
  File archive,
  Directory destination,
  Set<String> extensions,
) async {
  final format = p.extension(archive.path).replaceFirst('.', '').toLowerCase();
  final scratch = await Directory.systemTemp.createTemp('mod_unpack');
  try {
    var tried = 0;
    for (final unpacker in archiveUnpackers) {
      if (!unpacker.formats.contains(format)) continue;
      if (!await _isInstalled(unpacker)) continue;
      // A tool that gives up halfway still leaves its debris behind, so
      // every attempt gets a folder of its own.
      final attempt = await Directory(p.join(scratch.path, '${++tried}'))
          .create(recursive: true);
      final ProcessResult result;
      try {
        result = await _runProcess(unpacker.executable,
            unpacker.arguments(archive.path, attempt.path));
      } on ProcessException {
        continue; // Uninstalled since we probed it.
      }
      if (result.exitCode != 0) continue;
      return await _collectModFiles(attempt.path, destination, extensions);
    }
    final name = p.basename(archive.path);
    if (tried == 0) {
      throw ArchiveExtractionException(_noUnpackerMessage(format, name),
          cause: ArchiveExtractionFailure.noUnpacker);
    }
    throw ArchiveExtractionException(AppMessage('unpackFailed', [name]));
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

/// Only Linux is told what to install: the other two ship an unpacker, so
/// getting here means something unusual that a package name wouldn't
/// explain, and all we can offer is unpacking the thing by hand. Rar gets
/// its own key because it has an alternative tool to name, and how two
/// package names read as alternatives is the translation's business.
AppMessage _noUnpackerMessage(String format, String name) {
  final label = format.toUpperCase();
  if (!Platform.isLinux) return AppMessage('noUnpacker', [label, name]);
  return AppMessage(
      format == 'rar' ? 'noUnpackerLinuxRar' : 'noUnpackerLinux',
      [label, name]);
}

/// Moves the mod files an unpacker left under [root] into [destination],
/// keeping the archive's folder structure and skipping everything else.
Future<List<String>> _collectModFiles(
  String root,
  Directory destination,
  Set<String> extensions,
) async {
  var walk = await _filesUnder(root);
  if (!walk.whole && Platform.isWindows) {
    // Something down there wouldn't open. The unpackers write through
    // Windows' `\\?\` API, so an archive can leave behind paths longer
    // than the regular one takes, or names it normalises away
    // (trailing dots and spaces); that form is the only way to reach
    // them. It can only ever find more than the plain walk did - if it
    // finds less, this build doesn't take the prefix and the plain
    // walk stands.
    final extended = windowsExtendedPath(root);
    final retry = await _filesUnder(extended);
    if (retry.files.length >= walk.files.length) {
      root = extended;
      walk = retry;
    }
  }
  final prefix = root.endsWith(Platform.pathSeparator)
      ? root
      : '$root${Platform.pathSeparator}';
  final extracted = <String>[];
  final taken = <String>{};
  for (final file in walk.files) {
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
