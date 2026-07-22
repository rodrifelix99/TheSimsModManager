import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/game.dart';
import '../../core/game_adapter.dart';

/// Adapters for the four mainline Sims games. They differ only in where
/// the mods folder lives and which file types the game loads, so each one
/// is a thin subclass of [FolderBasedGameAdapter].
///
/// Folder resolution is a best-effort guess at the default install/user-data
/// locations; a per-game user override in settings is the planned escape
/// hatch when the guess is wrong (custom install drives, OneDrive-relocated
/// Documents, etc.).

const _series = 'The Sims';

/// The user's Documents folder, where Sims 2/3/4 keep their user data.
Future<Directory?> _documentsDir() async {
  final home = Platform.environment['USERPROFILE'] ?? // Windows
      Platform.environment['HOME']; // macOS / Linux
  if (home == null) return null;
  final docs = Directory(p.join(home, 'Documents'));
  return await docs.exists() ? docs : null;
}

Future<Directory?> _underDocuments(List<String> segments) async {
  final docs = await _documentsDir();
  if (docs == null) return null;
  final dir = Directory(p.joinAll([docs.path, ...segments]));
  return await dir.exists() ? dir : null;
}

class Sims4Adapter extends FolderBasedGameAdapter {
  const Sims4Adapter();

  @override
  Game get game => const Game(id: 'sims4', name: 'The Sims 4', series: _series);

  @override
  Set<String> get modFileExtensions => const {'.package', '.ts4script'};

  @override
  Future<Directory?> resolveModsDirectory() =>
      _underDocuments(['Electronic Arts', 'The Sims 4', 'Mods']);
}

class Sims3Adapter extends FolderBasedGameAdapter {
  const Sims3Adapter();

  @override
  Game get game => const Game(id: 'sims3', name: 'The Sims 3', series: _series);

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  Future<Directory?> resolveModsDirectory() =>
      _underDocuments(['Electronic Arts', 'The Sims 3', 'Mods', 'Packages']);
}

class Sims2Adapter extends FolderBasedGameAdapter {
  const Sims2Adapter();

  @override
  Game get game => const Game(id: 'sims2', name: 'The Sims 2', series: _series);

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  Future<Directory?> resolveModsDirectory() =>
      _underDocuments(['EA Games', 'The Sims 2', 'Downloads']);
}

class Sims1Adapter extends FolderBasedGameAdapter {
  const Sims1Adapter();

  @override
  Game get game => const Game(id: 'sims1', name: 'The Sims', series: _series);

  @override
  Set<String> get modFileExtensions => const {'.iff', '.far', '.skn', '.bmp'};

  /// The Sims 1 keeps mods inside the install directory, not Documents.
  @override
  Future<Directory?> resolveModsDirectory() async {
    final candidates = [
      r'C:\Program Files (x86)\Maxis\The Sims\Downloads',
      r'C:\Program Files\Maxis\The Sims\Downloads',
    ];
    for (final path in candidates) {
      final dir = Directory(path);
      if (await dir.exists()) return dir;
    }
    return null;
  }
}
