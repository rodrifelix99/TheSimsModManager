import 'dart:io';

/// Where a game reads mods from, when the answer is more than one folder.
///
/// Most games have a single mods folder and everything goes in it. The
/// Sims 1 does not: an object belongs in `Downloads`, a wall in
/// `GameData\Walls`, a behaviour override in `GameData\Global`, and a
/// hacked Superstar lot in `ExpansionPack6`. Which one a given file wants
/// is decided by what it overrides inside the game, which no file name or
/// extension reliably says - so the app guesses well and then lets the
/// user say otherwise.
class InstallDestination {
  const InstallDestination({
    required this.id,
    required this.directory,
    required this.label,
    this.descriptionKey,
    this.holdsStockFiles = false,
  });

  /// The folder's path below the game's own root, in POSIX form
  /// (`GameData/Skins`) whatever the platform writes. Stable, so it can
  /// key a stored choice and travel as an analytics property.
  ///
  /// Deliberately the real folder path rather than an opaque name: a
  /// download that carries its own folders is matched against these, and
  /// a readme telling someone to use `ExpansionPack6` is naming the same
  /// string the dialog shows them.
  final String id;

  final Directory directory;

  /// What the user sees. The folder path as this platform writes it,
  /// which is also what a mod's readme calls it.
  final String label;

  /// A stable English key saying what belongs here, resolved where it is
  /// drawn (the core layer has no localizations). Null for a folder the
  /// app can name but has nothing to add about.
  final String? descriptionKey;

  /// Whether the game's own files live here too. Those folders cannot be
  /// listed as a library wholesale - it would fill it with Maxis content
  /// the user could then disable - so what the app installs into them is
  /// remembered instead, and only that is shown.
  final bool holdsStockFiles;

  @override
  String toString() => 'InstallDestination($id)';
}

/// How one install decides where its files go.
sealed class InstallPlacement {
  const InstallPlacement();
}

/// Let the game's adapter decide, file by file. What the app does when
/// nobody says otherwise: for The Sims 1 that means honouring folders the
/// download names for itself, and sorting the rest by file type.
final class SortedPlacement extends InstallPlacement {
  const SortedPlacement();
}

/// Everything into one folder the user picked, whatever the adapter would
/// have done with it. This is what makes the sorting a suggestion: skins
/// that are meant to stay out of Create-a-Sim can be sent to `Downloads`
/// and left there.
final class ChosenPlacement extends InstallPlacement {
  const ChosenPlacement(this.destinationId);

  /// An [InstallDestination.id].
  final String destinationId;

  @override
  bool operator ==(Object other) =>
      other is ChosenPlacement && other.destinationId == destinationId;

  @override
  int get hashCode => destinationId.hashCode;

  @override
  String toString() => 'ChosenPlacement($destinationId)';
}
