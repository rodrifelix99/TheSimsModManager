import 'dart:typed_data';

import 'app_message.dart';

/// A pack that could not be switched on or off, for a reason the user can
/// do something about. [detail] is what to tell them, worded when it is
/// drawn - the same bargain [ModActionException] makes.
class PackActionException implements Exception {
  const PackActionException(this.detail);

  final AppMessage detail;

  @override
  String toString() => '$detail';
}

/// What kind of content a pack is, in the vocabulary the publisher itself
/// uses on the box. The UI words these ([AppText.packKind]); core keeps an
/// enum because the set is small and shared across the whole series -
/// unlike [Mod.category], which every adapter is free to extend.
enum GamePackKind {
  /// The big ones: a new world, a new life stage, new careers.
  expansion,

  /// The Sims 4's middle tier, between an expansion and a stuff pack.
  gamePack,

  /// Objects and clothes around a theme, no new systems.
  stuff,

  /// Smaller than a stuff pack: one room's worth of objects, or one
  /// wardrobe's.
  kit,

  /// Content the publisher gave away.
  free,
}

/// One piece of the publisher's own content installed beside the base
/// game: an expansion, a game pack, a stuff pack, a kit.
///
/// This is the counterpart to [Mod] for content the user did not install
/// themselves, and it is deliberately thinner. A mod is a file the app
/// owns and may rename; a pack belongs to the game and its installer, so
/// the app reads it and - for the games that support it - asks the game to
/// stop loading it. Nothing here is ever written into the pack's folder.
///
/// Immutable plain data, safe to send across isolates like [Mod] and
/// [SaveGame]. [name] arrives already worded rather than as a translation
/// key: pack names are proper nouns the install itself spells out (the
/// Sims 4 ships a manifest per pack naming it in seventeen languages),
/// which is the same bargain [SaveSim.careerName] makes.
class GamePack {
  const GamePack({
    required this.code,
    required this.name,
    required this.kind,
    this.isEnabled = true,
    this.canToggle = true,
    this.path,
    this.sizeBytes,
    this.icon,
    this.localizedNames = const {},
  });

  /// What the game itself calls this pack - `EP01`, `sims3_ep07`. Stable
  /// across languages, storefronts and reinstalls, so it is what the app
  /// stores and what a toggle is written against; never shown as-is when
  /// there is a [name].
  final String code;

  /// The pack's name in English (or whatever single name the install
  /// gave up), with the game's own title stripped off the front: "Get to
  /// Work", not "The Sims™ 4 Get to Work". Falls back to [code] for a
  /// pack nothing on this machine could name.
  final String name;

  final GamePackKind kind;

  /// Whether the game will load this pack the next time it starts. Always
  /// true for the games that have no way to turn one off.
  final bool isEnabled;

  /// Whether this particular pack may be switched off, for a game that
  /// can switch the rest. False for the one The Sims 2 pack whose
  /// executable runs the whole collection: asking for it is refused, so
  /// the UI draws a fact rather than a switch that snaps back. Only read
  /// where [GameAdapter.canTogglePacks] is already true.
  final bool canToggle;

  /// The pack's folder on disk, for "show in folder". Null for a game
  /// that records a pack somewhere other than a folder of its own.
  final String? path;

  /// What the pack costs on disk, when that was worth counting.
  final int? sizeBytes;

  /// The pack's own artwork, for the games that ship it somewhere a
  /// reader can reach. Null is the common case and the UI draws its own
  /// tile instead, the same way [ModThumb] falls back to stripes.
  final Uint8List? icon;

  /// [name] per language code (`de`, `pt`), for installs that ship the
  /// pack's name translated. Empty when the install named it once or not
  /// at all - most games say nothing, and a shipped fallback table can
  /// only ever be English.
  final Map<String, String> localizedNames;

  /// What to call this pack for a user reading [languageCode]: the
  /// install's own translation when it has one, [name] otherwise. Pack
  /// names are marketing, so a missing translation means English rather
  /// than a gap - which is also what the game's own launcher does.
  String nameFor(String? languageCode) {
    if (languageCode == null) return name;
    return localizedNames[languageCode.toLowerCase()] ?? name;
  }

  GamePack copyWith({bool? isEnabled}) => GamePack(
        code: code,
        name: name,
        kind: kind,
        isEnabled: isEnabled ?? this.isEnabled,
        canToggle: canToggle,
        path: path,
        sizeBytes: sizeBytes,
        icon: icon,
        localizedNames: localizedNames,
      );

  @override
  String toString() => '$code ($name)';
}
