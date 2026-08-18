import 'dart:io';

import 'package:path/path.dart' as p;

/// The copy an install takes of a game file before writing over it.
///
/// Most of what this app installs is a file the game never shipped, so
/// there is nothing to keep. The folders the games load their own content
/// from are the exception: replacing `Sunset Valley.world` with a routing
/// fix, or `Graphics Rules.sgr` with one that knows about a newer card,
/// means writing over something only a reinstall would bring back. The
/// mod itself is a download away; the file it replaced is several
/// gigabytes of game.
///
/// So the original is renamed beside itself rather than copied anywhere.
/// It costs nothing at any size, it survives this app being uninstalled,
/// and it puts the backup in the one folder the user would think to look
/// in. Uninstalling the mod puts it back.
///
/// The marker is the file's whole name plus [stockBackupSuffix], so a
/// backup never reads as a mod: nothing here matches a mod extension, and
/// the games' loaders go by extension too, which is what keeps a parked
/// original out of the game as surely as out of the library.
const stockBackupSuffix = '.smmbak';

String stockBackupPathOf(String path) => '$path$stockBackupSuffix';

/// Parks whatever is at [target] so the caller may write there, and
/// answers whether it did.
///
/// A backup already on record is never overwritten. The first one is the
/// file the game shipped, and a second install writing over the first
/// mod's copy would turn the only way back into a copy of somebody's mod.
Future<bool> backUpStockFile(String target) async {
  final existing = File(target);
  if (!await existing.exists()) return false;
  final backup = File(stockBackupPathOf(target));
  if (await backup.exists()) return false;
  try {
    await existing.rename(backup.path);
    return true;
  } on FileSystemException {
    // A folder that refuses the rename (a read-only volume, a file the
    // game has open) is about to refuse the copy too, and that is the
    // failure worth reporting. Nothing has moved.
    return false;
  }
}

/// Puts the file [target] replaced back, and answers whether there was
/// one. [target] itself is expected to be gone already - this runs after
/// the uninstall, so that the moment the mod leaves, the game has its own
/// file again rather than neither.
Future<bool> restoreStockFile(String target) async {
  final backup = File(stockBackupPathOf(target));
  try {
    if (!await backup.exists()) return false;
    final current = File(target);
    if (await current.exists()) await current.delete();
    await backup.rename(target);
    return true;
  } on FileSystemException {
    // Best-effort: the mod is gone either way, and an original that
    // could not be moved back is still sitting there under its marker.
    return false;
  }
}

/// Whether [path] is one of these parked originals, so a folder sweep can
/// leave it alone.
bool isStockBackupPath(String path) =>
    p.basename(path).toLowerCase().endsWith(stockBackupSuffix);
