import 'dart:io';

import 'package:path/path.dart' as p;

import 'app_message.dart';
import 'creation.dart';
import 'folder_access.dart';
import 'game_adapter.dart';
import 'install_path.dart';

/// Putting player-built content into a game's own folder, and taking it
/// out again.
///
/// Deliberately not built on the mod install path. That machinery exists
/// to file a mod into the right subfolder, mark it enabled or disabled,
/// and rebuild the conflict scan; none of it means anything here. What
/// this needs instead is the one rule mods never have: **a set of files
/// lands whole or not at all**. A Sims 4 tray item is a `.trayitem`, a
/// payload and several thumbnails sharing an id, and a copy that stopped
/// halfway leaves the game an item it can draw but not load.

/// Copies [paths] into [folder].
///
/// Every file keeps its own name, because for a set of files that name
/// *is* the join: the game finds a tray item's picture by matching the
/// id in the file name, so the sanitising and shortening
/// [claimInstallTarget] does to a mod would quietly break the set. Names
/// that a platform cannot write are refused rather than rewritten, which
/// on Windows is the only honest answer for a file the game will look up
/// by name.
///
/// Existing files are overwritten - reinstalling a lot you already have
/// is a replacement, and the alternative (a numbered copy) shows up in
/// the game as two identical entries nobody asked for. The write goes to
/// a `.part` beside the destination first and is renamed onto it, so a
/// failure halfway leaves whatever was already there intact; the same
/// bargain `downloadShopFile` makes, and for the same reason.
Future<List<String>> copyCreationFiles(
  List<String> paths,
  CreationFolder folder,
) async {
  final destination = Directory(folder.path);
  await destination.create(recursive: true);
  if (!await canWriteInto(destination)) {
    throw ModActionException(
      ModActionFailure.fileInUse,
      AppMessage('errorNoWriteAccess', [folder.path]),
    );
  }
  final written = <String>[];
  for (final path in paths) {
    final name = p.basename(path);
    if (sanitizeComponent(name, windows: Platform.isWindows) != name) {
      throw ModActionException(
        ModActionFailure.nameTaken,
        AppMessage('creationBadFileName', [name]),
      );
    }
    final target = p.join(destination.path, name);
    if (p.equals(target, path)) {
      // Already where it belongs: installing a file out of the folder it
      // is already in is a no-op, not a copy onto itself.
      written.add(target);
      continue;
    }
    final part = File('$target.part');
    await retryWhileLocked(
      () async {
        await File(path).copy(part.path);
        await part.rename(target);
      },
      name: name,
      inUse: () => AppMessage('creationFileInUse', [name]),
    );
    written.add(target);
  }
  return written;
}

/// Deletes every file [creation] is made of.
///
/// Keeps going after a file that is already gone (a second window, the
/// user's own file manager) because the point is that the set ends up
/// off the disk, and stops at one that refuses - a locked file means the
/// game has the item open, and taking the rest would leave it broken
/// rather than deleted.
Future<void> deleteCreationFiles(Creation creation) async {
  for (final path in creation.allFiles) {
    final file = File(path);
    final name = p.basename(path);
    try {
      await retryWhileLocked(
        () => file.delete(),
        name: name,
        inUse: () => AppMessage('fileInUseDelete', [name]),
      );
    } on PathNotFoundException {
      // Already off the disk. That is what the caller asked for.
    }
  }
}

/// The size of a set of files, skipping any that have gone. Best-effort:
/// a size nobody could read is 0 rather than a failed listing.
Future<int> creationSizeOf(Iterable<String> paths) async {
  var total = 0;
  for (final path in paths) {
    try {
      total += await File(path).length();
    } catch (_) {}
  }
  return total;
}
