import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import 'app_message.dart';

/// Changing what a save says about a household, which is the one thing
/// in this app that writes into a file the user cannot replace.
///
/// Everything else the app edits is a download: a mod put back wrong is
/// a mod downloaded again. A neighborhood is twenty years of somebody's
/// afternoons, so the rules here are stricter than anywhere else in the
/// codebase and none of them are negotiable:
///
///  * **The old file is kept before the new one is written.** Not beside
///    the save - the games read their own folders and a stray copy of a
///    neighborhood package is a second neighborhood - but in the app's
///    own data folder, the last few states per file ([keepBackups]).
///  * **The new file is proved before it replaces anything.** Every
///    editor hands its result to a verifier that re-reads it the way the
///    save scanner would and checks the change is there and the rest of
///    the households still are. A save that fails is never written.
///  * **The write itself is a rename.** The bytes land in a sibling
///    `.smmpart` and only become the save once they are all there, so a
///    machine that loses power mid-write loses the edit, not the save.
///
/// What a game can actually change is [GameAdapter.editableSaveFields],
/// and it is narrower than it looks: The Sims 3 keeps its households in
/// a serialized blob nobody outside the game has parsed, so a Sims 3
/// save can be read and never written.

/// What the user asked to change. A null field is one they left alone,
/// which is not the same as one they cleared - a household with no name
/// is not a thing any of these games has.
class HouseholdEdit {
  const HouseholdEdit({this.name, this.funds});

  /// The household's new name, already trimmed. Player-written text, so
  /// it travels verbatim like every other name in [SaveGame].
  final String? name;

  /// New household funds in simoleons, already clamped to the game's own
  /// ceiling by the caller ([GameAdapter.maxHouseholdFunds]).
  final int? funds;

  bool get isEmpty => name == null && funds == null;
}

/// The parts of a household a game lets the app rewrite. A game answers
/// with what its own format actually gives up, and the UI offers exactly
/// that: a field nobody can write is a field with no box on screen,
/// rather than a box that fails when pressed.
enum SaveEditField { name, funds }

/// An edit that could not be made, worded for the user. Carries an
/// [AppMessage] like [ModActionException] so core stays out of the
/// localizations.
class SaveEditException implements Exception {
  const SaveEditException(this.detail);

  /// The save named a household this file doesn't have - it was renamed
  /// or removed by the game since the screen was drawn.
  SaveEditException.householdGone() : detail = const AppMessage('saveEditHouseholdGone');

  /// The file is not the shape its reader expects, so nothing here knows
  /// how to put it back together.
  SaveEditException.unreadable(String file)
      : detail = AppMessage('saveEditUnreadable', [file]);

  /// The rewritten save did not read back as the one that was asked for.
  /// Nothing has been written when this is raised.
  SaveEditException.verificationFailed(String file)
      : detail = AppMessage('saveEditVerificationFailed', [file]);

  final AppMessage detail;

  @override
  String toString() => 'SaveEditException($detail)';
}

/// How many previous states of one save file are kept. Three is enough
/// to undo a run of edits made in one sitting without a Sims 4 slot's
/// eleven megabytes turning into a habit.
const keepBackups = 3;

/// Puts [bytes] where [target] is, keeping what was there first.
///
/// Returns the backup that was taken, for the message that says where it
/// went. Every step is ordered so that a failure leaves the save the way
/// it was: the backup is copied before anything is written, the bytes go
/// to a sibling part file, and only the rename at the end is destructive
/// - and a rename replaces the old file whole, on every platform.
Future<File?> replaceSaveFile(File target, Uint8List bytes,
    {required String gameId}) async {
  final backup = await _backUp(target, gameId: gameId);
  final part = File('${target.path}.smmpart');
  try {
    await part.writeAsBytes(bytes, flush: true);
    await part.rename(target.path);
  } catch (_) {
    try {
      if (await part.exists()) await part.delete();
    } catch (_) {}
    rethrow;
  }
  return backup;
}

/// Copies [target] into the app's own backup folder, then prunes that
/// file's older copies down to [keepBackups].
///
/// Best effort in one direction only: a backup that cannot be taken is
/// not a reason to refuse the edit on a machine whose data folder is
/// unwritable, but it is a reason to say so, which is what the null
/// return is for.
Future<File?> _backUp(File target, {required String gameId}) async {
  try {
    final root = saveBackupFolder(gameId);
    if (root == null) return null;
    await root.create(recursive: true);
    final stamp = DateTime.now()
        .toIso8601String()
        .replaceAll(RegExp(r'[:.]'), '-')
        .substring(0, 19);
    final name = p.basename(target.path);
    final backup = File(p.join(root.path, '$name.$stamp.bak'));
    await target.copy(backup.path);
    await _prune(root, name);
    return backup;
  } catch (_) {
    return null;
  }
}

/// Drops all but the newest [keepBackups] copies of one save file.
Future<void> _prune(Directory root, String name) async {
  try {
    final mine = <File>[
      for (final entity in root.listSync())
        if (entity is File &&
            p.basename(entity.path).startsWith('$name.') &&
            entity.path.endsWith('.bak'))
          entity,
    ];
    if (mine.length <= keepBackups) return;
    // The stamp is in the name and sorts as it reads, so the oldest are
    // simply the ones at the front.
    mine.sort((a, b) => a.path.compareTo(b.path));
    for (final file in mine.take(mine.length - keepBackups)) {
      try {
        await file.delete();
      } catch (_) {}
    }
  } catch (_) {}
}

/// Where the copies live: the app's own per-user data folder, never the
/// game's. A spare `.package` inside a Sims 2 neighborhood folder is a
/// neighborhood the game will try to read.
Directory? saveBackupFolder(String gameId) {
  final root = _appDataRoot();
  if (root == null) return null;
  return Directory(p.join(root, 'TheSimsModManager', 'save-backups', gameId));
}

String? _appDataRoot() {
  final env = Platform.environment;
  if (Platform.isWindows) return env['APPDATA'];
  final home = env['HOME'];
  if (home == null || home.isEmpty) return null;
  if (Platform.isMacOS) return p.join(home, 'Library', 'Application Support');
  final xdg = env['XDG_DATA_HOME'];
  return xdg != null && xdg.isNotEmpty ? xdg : p.join(home, '.local', 'share');
}
