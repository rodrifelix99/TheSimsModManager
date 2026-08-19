/// What a mod needs installed before it does anything, and whether this
/// machine has it.
///
/// The Exchange lets a creator name the packs their mod is built on, as
/// the codes the games use for themselves (`EP01`, `GP06`) - the same
/// vocabulary [GamePack.code] already speaks, which is why nothing here
/// has to parse anything. Everything in this file is pure: the reading of
/// the disk happens in the adapters, and what to do about the answer
/// happens in the UI.
///
/// The one rule worth stating out loud is that this **never blocks an
/// install**. It is a warning, and it is wrong often enough to have to
/// be: two of the five games can only be asked on Windows, a listing can
/// name a game the sidebar has never opened, and a creator can tick the
/// wrong box. So [PackRequirementState] has an answer for "we could not
/// find out", and the UI says that rather than accusing anyone of missing
/// a pack they are looking at.
library;

import 'game_pack.dart';

/// How a machine answers one declared requirement.
enum PackRequirementState {
  /// Installed and the game will load it.
  met,

  /// Installed, but switched off - which the app itself can undo, so this
  /// is the one state with a fix on the next screen over.
  disabled,

  /// The game knows its packs and this one is not among them.
  missing,

  /// Nobody could say. The game's packs are unreadable here (The Sims 2
  /// and 3 keep theirs in the Windows registry), the game is not
  /// installed, or the code is one this build has never heard of.
  unknown,
}

/// One pack a listing says it needs, answered for this machine.
class PackRequirement {
  const PackRequirement({
    required this.code,
    required this.name,
    required this.state,
  });

  /// The game's own code, always uppercase: `EP01`, `GP06`, `SP24`.
  final String code;

  /// What to call it on screen. The installed pack's own name when there
  /// is one, the shipped catalog's otherwise, and failing both the code -
  /// which is what every guide about an unreleased pack calls it anyway.
  final String name;

  final PackRequirementState state;

  /// Whether this one is in the way. Deliberately false for [unknown]:
  /// not knowing is not the same as knowing it is absent.
  bool get isBlocking =>
      state == PackRequirementState.missing ||
      state == PackRequirementState.disabled;
}

/// A pack code as we are willing to store and compare it, or null.
///
/// Every code that reaches this app was typed into a web page by a
/// stranger, so the grammar is a whitelist rather than a cleanup - the
/// same bargain `deep_link.dart` makes. Letters and digits only, because
/// that is all any of the five games has ever used, and short enough that
/// nothing long can hide in a listing.
String? normalizePackCode(Object? raw) {
  if (raw is! String) return null;
  final code = raw.trim().toUpperCase();
  if (code.length < 2 || code.length > 12) return null;
  for (final unit in code.codeUnits) {
    final isDigit = unit >= 0x30 && unit <= 0x39;
    final isLetter = unit >= 0x41 && unit <= 0x5A;
    if (!isDigit && !isLetter) return null;
  }
  return code;
}

/// The most codes a listing may carry. The rules cap the stored list at
/// the same number; this is the second half of that, for a document that
/// was written before the rule existed.
const int maxPackRequirements = 24;

/// Every code in [raw] we are willing to keep, in the order given, with
/// duplicates and anything unreadable dropped.
List<String> normalizePackCodes(Iterable<Object?> raw) {
  final codes = <String>[];
  for (final entry in raw) {
    final code = normalizePackCode(entry);
    if (code == null || codes.contains(code)) continue;
    codes.add(code);
    if (codes.length == maxPackRequirements) break;
  }
  return codes;
}

/// Answers [codes] against what the machine has.
///
/// [installed] is what the game said when asked, and **null means it was
/// never asked or could not answer** - a game whose packs this platform
/// cannot read, or one that is not installed. That distinction is the
/// whole point of the parameter: an empty list from a game that really
/// did answer means the player owns no packs, and a mod needing one is
/// genuinely out of reach; a null means we have nothing to say. Passing
/// an empty list for "could not look" would tell every Mac user that
/// their whole shelf is unusable.
///
/// [catalog] names a pack that is not installed, and is the shipped
/// table the adapter carries. A code missing from it still answers -
/// under its own name - because a pack that shipped after this build did
/// is exactly the case where the creator is right and we are behind.
List<PackRequirement> resolvePackRequirements({
  required List<String> codes,
  required List<GamePack>? installed,
  Map<String, String> catalog = const {},
}) {
  final byCode = <String, GamePack>{};
  for (final pack in installed ?? const <GamePack>[]) {
    final code = normalizePackCode(pack.code);
    if (code != null) byCode.putIfAbsent(code, () => pack);
  }
  return [
    for (final code in codes)
      if (installed == null)
        PackRequirement(
          code: code,
          name: catalog[code] ?? code,
          state: PackRequirementState.unknown,
        )
      else if (byCode[code] case final pack?)
        PackRequirement(
          code: code,
          name: pack.name.isEmpty ? (catalog[code] ?? code) : pack.name,
          state: pack.isEnabled
              ? PackRequirementState.met
              : PackRequirementState.disabled,
        )
      else
        PackRequirement(
          code: code,
          name: catalog[code] ?? code,
          state: PackRequirementState.missing,
        ),
  ];
}

/// The sharpest thing to say about a whole list, for a badge that has
/// room for one word. Ordered by how much the user can do about it:
/// something switched off is a click away, something missing is a
/// purchase, and not knowing is worth less than either.
PackRequirementState? worstPackRequirement(List<PackRequirement> of) {
  if (of.isEmpty) return null;
  for (final state in const [
    PackRequirementState.missing,
    PackRequirementState.disabled,
    PackRequirementState.unknown,
  ]) {
    if (of.any((one) => one.state == state)) return state;
  }
  return PackRequirementState.met;
}
