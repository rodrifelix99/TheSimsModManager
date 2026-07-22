/// Whether a mod is currently active in the game.
enum ModStatus { enabled, disabled }

/// A single installed mod as seen on disk.
///
/// Immutable snapshot: operations that change a mod (enable/disable,
/// remove) go through the game's adapter, which returns fresh instances.
class Mod {
  const Mod({
    required this.name,
    required this.path,
    required this.status,
    this.sizeBytes,
    this.category = 'Package',
    this.modifiedAt,
  });

  /// Display name (file name without the `.disabled` marker).
  final String name;

  /// Absolute path of the mod file on disk.
  final String path;

  final ModStatus status;

  final int? sizeBytes;

  /// Coarse content type derived from the file extension by the adapter,
  /// e.g. `Script`, `Package`, `Object`.
  final String category;

  final DateTime? modifiedAt;

  bool get isEnabled => status == ModStatus.enabled;
}
