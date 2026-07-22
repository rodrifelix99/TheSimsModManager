import 'dart:io';

import 'package:path/path.dart' as p;

/// Free/total bytes of the volume that holds a given path.
class DiskSpace {
  const DiskSpace({required this.totalBytes, required this.freeBytes});

  final int totalBytes;
  final int freeBytes;

  int get usedBytes => totalBytes - freeBytes;
}

/// Queries the OS for the space on the volume containing [path].
///
/// Best-effort: returns null for UNC paths, missing tools, or parse
/// failures — callers should render without disk numbers in that case.
/// Dart has no filesystem-stats API, so this shells out (PowerShell's
/// DriveInfo on Windows, POSIX `df` elsewhere).
Future<DiskSpace?> diskSpaceFor(String path) async {
  try {
    if (Platform.isWindows) {
      final root = p.rootPrefix(p.absolute(path));
      if (!RegExp(r'^[A-Za-z]:').hasMatch(root)) return null;
      final drive = root[0].toUpperCase();
      final result = await Process.run('powershell', [
        '-NoProfile',
        '-NonInteractive',
        '-Command',
        "\$d = [System.IO.DriveInfo]::new('$drive'); "
            '\$d.TotalFreeSpace; \$d.TotalSize',
      ]);
      if (result.exitCode != 0) return null;
      final lines = (result.stdout as String)
          .split(RegExp(r'\r?\n'))
          .where((l) => l.trim().isNotEmpty)
          .toList();
      if (lines.length < 2) return null;
      final free = int.tryParse(lines[0].trim());
      final total = int.tryParse(lines[1].trim());
      if (free == null || total == null) return null;
      return DiskSpace(totalBytes: total, freeBytes: free);
    }
    // macOS / Linux: portable df, 1K blocks.
    final result = await Process.run('df', ['-Pk', path]);
    if (result.exitCode != 0) return null;
    final lines = (result.stdout as String)
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();
    if (lines.length < 2) return null;
    final cols = lines[1].split(RegExp(r'\s+'));
    if (cols.length < 4) return null;
    final total = int.tryParse(cols[1]);
    final free = int.tryParse(cols[3]);
    if (total == null || free == null) return null;
    return DiskSpace(totalBytes: total * 1024, freeBytes: free * 1024);
  } catch (_) {
    return null;
  }
}
