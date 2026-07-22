import 'dart:io';

import 'package:path/path.dart' as p;

import 'game.dart';
import 'mod.dart';

/// Suffix appended to a mod file to hide it from the game without deleting it.
const disabledSuffix = '.disabled';

/// Everything the manager needs to know to handle mods for one game.
///
/// This is the extension point of the whole app: to support a new game,
/// implement this interface (usually by extending [FolderBasedGameAdapter])
/// and register the adapter in [GameRegistry]. Nothing outside `src/games/`
/// should ever reference a concrete game.
abstract class GameAdapter {
  Game get game;

  /// File extensions this game accepts as mods (lowercase, with dot),
  /// e.g. `{'.package', '.ts4script'}`.
  Set<String> get modFileExtensions;

  /// Best-guess mods directory on this machine, or `null` if the game
  /// (or its mods folder) can't be located. The user can override this
  /// per game in settings later.
  Future<Directory?> resolveModsDirectory();

  Future<List<Mod>> listMods(Directory modsDir);

  /// Copies [source] into [modsDir].
  Future<Mod> installMod(Directory modsDir, File source);

  Future<void> removeMod(Mod mod);

  /// Enables or disables [mod] and returns its new state.
  Future<Mod> setEnabled(Mod mod, {required bool enabled});
}

/// Default implementation for games whose mods are plain files in a folder —
/// which is every Sims game. Disabling works by appending [disabledSuffix]
/// to the file name so the game's loader skips it.
///
/// Subclasses only supply [game], [modFileExtensions], and
/// [resolveModsDirectory].
abstract class FolderBasedGameAdapter implements GameAdapter {
  const FolderBasedGameAdapter();

  @override
  Future<List<Mod>> listMods(Directory modsDir) async {
    if (!await modsDir.exists()) return const [];
    final mods = <Mod>[];
    await for (final entity in modsDir.list(recursive: true)) {
      if (entity is! File) continue;
      final mod = _toMod(entity);
      if (mod != null) mods.add(mod);
    }
    mods.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return mods;
  }

  @override
  Future<Mod> installMod(Directory modsDir, File source) async {
    final target = p.join(modsDir.path, p.basename(source.path));
    final copied = await source.copy(target);
    return _toMod(copied)!;
  }

  @override
  Future<void> removeMod(Mod mod) => File(mod.path).delete();

  @override
  Future<Mod> setEnabled(Mod mod, {required bool enabled}) async {
    if (mod.isEnabled == enabled) return mod;
    final newPath = enabled
        ? mod.path.substring(0, mod.path.length - disabledSuffix.length)
        : '${mod.path}$disabledSuffix';
    final renamed = await File(mod.path).rename(newPath);
    return _toMod(renamed)!;
  }

  /// Maps a file to a [Mod], or `null` if it isn't a mod file for this game.
  Mod? _toMod(File file) {
    var name = p.basename(file.path);
    var status = ModStatus.enabled;
    if (name.toLowerCase().endsWith(disabledSuffix)) {
      name = name.substring(0, name.length - disabledSuffix.length);
      status = ModStatus.disabled;
    }
    if (!modFileExtensions.contains(p.extension(name).toLowerCase())) {
      return null;
    }
    return Mod(
      name: name,
      path: file.path,
      status: status,
      sizeBytes: file.existsSync() ? file.lengthSync() : null,
    );
  }
}
