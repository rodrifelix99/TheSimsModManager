import 'dart:io';

import 'package:path/path.dart' as p;

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
Future<bool> canWriteInto(Directory dir) async {
  var existing = dir;
  while (!await existing.exists()) {
    final parent = existing.parent;
    if (p.equals(parent.path, existing.path)) return false;
    existing = parent;
  }
  final probe = File(p.join(
      existing.path, '.smm-write-test-${DateTime.now().microsecondsSinceEpoch}'));
  try {
    await probe.writeAsString('');
  } catch (_) {
    return false;
  }
  try {
    await probe.delete();
  } catch (_) {} // The answer is already yes; the leftover is harmless.
  return true;
}
