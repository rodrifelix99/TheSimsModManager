import 'dart:io';

import 'package:path/path.dart' as p;

/// Where the app keeps the things that are its own rather than a game's.
///
/// Save backups and the pictures the player picks for their mods both
/// land here, and both for the same reason: a game's folders are read by
/// the game, and a spare file in one of them is something it will try to
/// load (a `.package` beside a Sims 2 neighborhood is a second
/// neighborhood). It also outlives an uninstall, which is the point of a
/// backup, and it is a folder somebody would think to look in.

/// `<root>/TheSimsModManager/<parts>`, or null on a machine whose data
/// folder could not be worked out at all. The folder is not created.
Directory? appDataFolder(List<String> parts) {
  final root = appDataRoot();
  if (root == null) return null;
  return Directory(p.joinAll([root, 'TheSimsModManager', ...parts]));
}

/// The per-user data folder the platform keeps for applications.
String? appDataRoot() {
  final env = Platform.environment;
  if (Platform.isWindows) return env['APPDATA'];
  final home = env['HOME'];
  if (home == null || home.isEmpty) return null;
  if (Platform.isMacOS) return p.join(home, 'Library', 'Application Support');
  final xdg = env['XDG_DATA_HOME'];
  return xdg != null && xdg.isNotEmpty ? xdg : p.join(home, '.local', 'share');
}
