import 'dart:io';

import 'package:path/path.dart' as p;

/// What the app may do with a folder, once it has tried.
///
/// Three answers rather than two, because "no" and "the system would not
/// even say" want different wording: a Program Files folder needs a
/// permission the user can grant, while a path behind a mount point that
/// resolves to nothing needs a different folder entirely.
enum FolderAccess {
  /// A file was written there and taken away again.
  writable,

  /// The folder is there and the write was refused.
  denied,

  /// The system could not answer for it at all: a junction pointing at a
  /// volume that isn't mounted (Windows raises ERROR_UNTRUSTED_MOUNT_POINT
  /// and ERROR_MOUNT_POINT_NOT_RESOLVED out of a plain `exists`), a drive
  /// letter nothing is plugged into, a share that stopped answering.
  unreachable,
}

/// Whether the app can actually put files in [dir].
///
/// Answered by trying rather than by reading permission bits: Windows
/// protecting Program Files, a POSIX mode, an ACL and a read-only volume
/// all look different from the outside, and the only thing the app needs
/// to know is the same in every case. The Sims 1 and The Sims Medieval
/// keep their mods inside the game's install folder, which on a stock
/// Windows setup is exactly the folder a standard process may not write
/// to, so this is a normal answer rather than an exceptional one.
///
/// A folder that isn't there yet is answered for the nearest one above it
/// that is, which is what the setup screen wants to know: whether the
/// mods folder can be created here at all.
Future<bool> canWriteInto(Directory dir) async =>
    await folderAccess(dir) == FolderAccess.writable;

/// [canWriteInto] with its reason kept, for the callers that have
/// somewhere to word it.
///
/// This one never throws. It is asked *about* a folder the user chose or
/// the app guessed, so the folder being unusable is the answer rather
/// than an exception: `Directory.exists` itself raises on a path whose
/// mount point resolves nowhere, and that reached the setup screen as a
/// crash report for a machine doing nothing wrong.
Future<FolderAccess> folderAccess(Directory dir) async {
  var existing = dir;
  while (true) {
    final bool there;
    try {
      there = await existing.exists();
    } on FileSystemException {
      return FolderAccess.unreachable;
    }
    if (there) break;
    final parent = existing.parent;
    // Walked past the drive letter without finding anything: whatever
    // this path names, it is not on a volume this computer has.
    if (p.equals(parent.path, existing.path)) return FolderAccess.unreachable;
    existing = parent;
  }
  final probe = File(p.join(
      existing.path, '.smm-write-test-${DateTime.now().microsecondsSinceEpoch}'));
  try {
    await probe.writeAsString('');
  } catch (_) {
    return FolderAccess.denied;
  }
  try {
    await probe.delete();
  } catch (_) {} // The answer is already yes; the leftover is harmless.
  return FolderAccess.writable;
}
