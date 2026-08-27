import 'dart:io';

import 'package:path/path.dart' as p;

/// Something to tell the user, as the core layer is able to say it: a
/// stable key plus the values that belong in it, translated where it is
/// drawn (`AppText.errorText`). Same bargain as [Mod.category] and
/// [GameAdapter.setupHelpKey] - core has no localizations of its own, so
/// it carries the key and never the prose.
class AppMessage {
  const AppMessage(this.key, [this.args = const []]) : text = null;

  /// Wording that arrives already written and has no key of ours: the OS
  /// error behind a failed copy (in the user's own language), or the text
  /// of an exception we never anticipated. Shown as it stands.
  const AppMessage.verbatim(String this.text)
      : key = '',
        args = const [];

  final String key;

  /// The key's placeholder values, in the order the key expects them.
  final List<String> args;

  final String? text;

  /// Readable enough for a log or a test name; never for the user.
  @override
  String toString() => text ?? '$key(${args.join(', ')})';
}

/// The filesystem refusing an operation on a file, worded with the
/// system's own message: it is the only thing that knows whether the
/// volume is read-only, unplugged or full, and it says so in the user's
/// own language. [name] where the caller knows what the file is called;
/// otherwise the failing path's own base name, or nothing but the reason
/// when the exception names no path at all.
AppMessage refusedMessage(FileSystemException error, [String? name]) {
  final reason = error.osError?.message ?? error.message;
  final path = error.path;
  final about = name ?? (path == null ? '' : p.basename(path));
  if (about.isEmpty) return AppMessage.verbatim(reason);
  return AppMessage('fileWriteRefused', [about, reason]);
}

/// A file or folder that holds nothing this game can use, or an archive
/// whose bytes aren't the format they claim to be. A [FormatException]
/// because that is what it is - a verdict on the data, not a bug to
/// investigate - and callers already tell the two apart that way.
class ModContentException extends FormatException {
  ModContentException(this.detail) : super('$detail');

  /// The "nothing here this game can use" verdict, worded the same for
  /// an archive and a dropped folder: what was wanted ([extensions]) and
  /// where it wasn't found ([source], a base name). One constructor so
  /// the message's argument order can't drift between the three places
  /// that raise it.
  ModContentException.noModFiles(Iterable<String> extensions, String source)
      : this(AppMessage('noModFiles', [extensions.join(', '), source]));

  final AppMessage detail;
}
