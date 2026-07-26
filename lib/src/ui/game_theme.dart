import 'package:flutter/material.dart';

import '../core/game.dart';

/// The visual identity of one game: the whole chrome re-tints when the
/// user switches games. Values mirror the design prototype; each game has
/// a light and a dark palette, picked by [forGame].
class GameTheme {
  const GameTheme({
    required this.accent,
    required this.accent2,
    required this.bg,
    required this.surface,
    required this.surfaceAlt,
    required this.text,
    required this.muted,
    required this.border,
    required this.tint,
    required this.shadow,
    required this.switchOff,
    this.warning = const Color(0xFFD6551F),
    this.onWarningTint = const Color(0xFFB34A1E),
    this.eraKey,
    this.eraDetail,
  });

  final Color accent;
  final Color accent2;
  final Color bg;
  final Color surface;
  final Color surfaceAlt;
  final Color text;
  final Color muted;
  final Color border;
  final Color tint;

  /// Base color for drop shadows, opaque - call sites pick the alpha they
  /// want. A shadow that reads on parchment disappears on a dark surface,
  /// so the dark palettes go to plain black.
  final Color shadow;

  /// The "off" gray: a switch's unlit track and the disabled-mod slab on
  /// the detail screen.
  final Color switchOff;

  /// Conflict/warning chrome, one hue for every game but split by
  /// brightness like everything else here: [warning] fills the badges,
  /// borders and tints, [onWarningTint] carries the warning panel's text.
  /// The defaults are the light pair; [forGame] swaps in the dark pair,
  /// because the light text variant disappears against a dark surface.
  final Color warning;
  final Color onWarningTint;

  /// Flavor label shown next to the game name, e.g. "Modern · 2014",
  /// split so it can be translated: [eraKey] names the mood (resolved by
  /// `AppText.eraName`) and [eraDetail] is the year beside it. Both null
  /// for a game we have no palette for, which then falls back to its own
  /// series and year - see `eraLabel` in library_view.dart.
  final String? eraKey;
  final String? eraDetail;

  LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accent, accent2],
      );

  /// Colors only. The era label is brightness-independent, so it lives in
  /// [_eraByGameId] and gets stitched on by [forGame] rather than being
  /// repeated in both palette maps.
  ///
  /// Three accents run a step or two darker than the design prototype
  /// (Sims 2 #5BA12C, Sims 3 #7CB518, Sims 4 #1FBF8F). At the mock's
  /// values the accent carries too little contrast against the white
  /// surfaces it labels - and, the same number seen from the other side,
  /// the white text on an accent-filled Install button. Same hue, same
  /// vividness, just less light; theme_test.dart holds the line at 3.
  static const _lightByGameId = <String, GameTheme>{
    'sims1': GameTheme(
      accent: Color(0xFF12898A),
      accent2: Color(0xFFE0A53A),
      bg: Color(0xFFEEF2EC),
      surface: Color(0xFFFFFFFF),
      surfaceAlt: Color(0xFFF2F5EF),
      text: Color(0xFF1E3A37),
      muted: Color(0xFF6C827E),
      border: Color(0xFFDBE4DE),
      tint: Color(0xFFDCEFEE),
      shadow: Color(0xFF142823),
      switchOff: Color(0x52788C87),
    ),
    'sims2': GameTheme(
      accent: Color(0xFF549428),
      accent2: Color(0xFFE07B2E),
      bg: Color(0xFFF4EFE4),
      surface: Color(0xFFFFFDF6),
      surfaceAlt: Color(0xFFF6F1E6),
      text: Color(0xFF31301D),
      muted: Color(0xFF83806B),
      border: Color(0xFFE6DDC9),
      tint: Color(0xFFEAF3DD),
      shadow: Color(0xFF2A2617),
      switchOff: Color(0x52938C74),
    ),
    'sims3': GameTheme(
      accent: Color(0xFF639113),
      accent2: Color(0xFF2F7D9E),
      bg: Color(0xFFECEFF0),
      surface: Color(0xFFFFFFFF),
      surfaceAlt: Color(0xFFF1F4F5),
      text: Color(0xFF22303A),
      muted: Color(0xFF6C7F88),
      border: Color(0xFFDDE4E7),
      tint: Color(0xFFE9F2D8),
      shadow: Color(0xFF16242C),
      switchOff: Color(0x52798C94),
    ),
    'sims4': GameTheme(
      accent: Color(0xFF189771),
      accent2: Color(0xFF12B0D6),
      bg: Color(0xFFEAF6F2),
      surface: Color(0xFFFFFFFF),
      surfaceAlt: Color(0xFFF2FAF7),
      text: Color(0xFF0F2E28),
      muted: Color(0xFF5F827A),
      border: Color(0xFFD9ECE5),
      tint: Color(0xFFDCF5EC),
      shadow: Color(0xFF142823),
      switchOff: Color(0x52788C87),
    ),
    // Parchment + antique gold + plumbob green, after the game's crest.
    'simsmedieval': GameTheme(
      accent: Color(0xFF9C7B1E),
      accent2: Color(0xFF5E9732),
      bg: Color(0xFFF1EBDC),
      surface: Color(0xFFFFFDF4),
      surfaceAlt: Color(0xFFF5EFDF),
      text: Color(0xFF33290F),
      muted: Color(0xFF857A5C),
      border: Color(0xFFE3DAC0),
      tint: Color(0xFFF0E7CB),
      shadow: Color(0xFF2B230D),
      switchOff: Color(0x52968B6C),
    ),
  };

  /// The same identities after dark: backgrounds keep each game's hue but
  /// drop to near-black, and the accents come up a few steps because the
  /// light-theme ones (especially the Sims 1 teal and the Medieval gold)
  /// go muddy against them.
  static const _darkByGameId = <String, GameTheme>{
    'sims1': GameTheme(
      accent: Color(0xFF2FB6B7),
      accent2: Color(0xFFE8B653),
      bg: Color(0xFF0E1615),
      surface: Color(0xFF16211F),
      surfaceAlt: Color(0xFF1B2725),
      text: Color(0xFFE7F0ED),
      muted: Color(0xFF93A8A4),
      border: Color(0xFF27332F),
      tint: Color(0xFF15302F),
      shadow: Color(0xFF000000),
      switchOff: Color(0x66627773),
    ),
    'sims2': GameTheme(
      accent: Color(0xFF7FC44A),
      accent2: Color(0xFFEE9145),
      bg: Color(0xFF15140E),
      surface: Color(0xFF1F1D15),
      surfaceAlt: Color(0xFF25231A),
      text: Color(0xFFF0EDE0),
      muted: Color(0xFFA9A48C),
      border: Color(0xFF332F22),
      tint: Color(0xFF232D18),
      shadow: Color(0xFF000000),
      switchOff: Color(0x6677715A),
    ),
    'sims3': GameTheme(
      accent: Color(0xFF9ED12F),
      accent2: Color(0xFF4FA5C9),
      bg: Color(0xFF0F1417),
      surface: Color(0xFF171E22),
      surfaceAlt: Color(0xFF1C2429),
      text: Color(0xFFE6EDF1),
      muted: Color(0xFF93A4AD),
      border: Color(0xFF283238),
      tint: Color(0xFF1E2A18),
      shadow: Color(0xFF000000),
      switchOff: Color(0x66647279),
    ),
    'sims4': GameTheme(
      accent: Color(0xFF2FD3A1),
      accent2: Color(0xFF32C5E8),
      bg: Color(0xFF0C1614),
      surface: Color(0xFF13201D),
      surfaceAlt: Color(0xFF182724),
      text: Color(0xFFE4F2EE),
      muted: Color(0xFF8AA6A0),
      border: Color(0xFF223330),
      tint: Color(0xFF12332B),
      shadow: Color(0xFF000000),
      switchOff: Color(0x665C7671),
    ),
    'simsmedieval': GameTheme(
      accent: Color(0xFFC9A03A),
      accent2: Color(0xFF7CBB48),
      bg: Color(0xFF161309),
      surface: Color(0xFF201C10),
      surfaceAlt: Color(0xFF262114),
      text: Color(0xFFF1EADA),
      muted: Color(0xFFAAA085),
      border: Color(0xFF353020),
      tint: Color(0xFF2C2512),
      shadow: Color(0xFF000000),
      switchOff: Color(0x66786F56),
    ),
  };

  static const _eraByGameId = <String, (String, String)>{
    'sims1': ('classic', '2000'),
    'sims2': ('nightlife', '2004'),
    'sims3': ('ambitions', '2009'),
    'sims4': ('modern', '2014'),
    'simsmedieval': ('medieval', '2011'),
  };

  /// Theme for [game] at [brightness]; future games without a bespoke
  /// palette get the neutral teal one, labeled with their year/series.
  static GameTheme forGame(Game game, Brightness brightness) {
    final palettes =
        brightness == Brightness.dark ? _darkByGameId : _lightByGameId;
    final palette = palettes[game.id] ?? palettes['sims4']!;
    return palette._finish(_eraByGameId[game.id], brightness);
  }

  /// Stitches on the era label and the brightness-wide colors the
  /// per-game palettes don't repeat.
  GameTheme _finish((String, String)? era, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return GameTheme(
      accent: accent,
      accent2: accent2,
      bg: bg,
      surface: surface,
      surfaceAlt: surfaceAlt,
      text: text,
      muted: muted,
      border: border,
      tint: tint,
      shadow: shadow,
      switchOff: switchOff,
      warning: dark ? const Color(0xFFE8794A) : warning,
      onWarningTint: dark ? const Color(0xFFF2A583) : onWarningTint,
      eraKey: era?.$1,
      eraDetail: era?.$2,
    );
  }

  /// Sidebar badge color per game (the design gives each row its own dot).
  static Color badgeColor(Game game, Brightness brightness) =>
      forGame(game, brightness).accent;

  /// Sidebar icon for [game], or null when we don't ship one; the row
  /// then falls back to the lettered badge, so new games need no UI work.
  static String? iconAsset(Game game) => _iconByGameId[game.id];

  /// Wordmark logo for [game] in the variant that reads at [brightness],
  /// or null when we don't ship one; the library header falls back to
  /// text. Only the Sims 4 wordmark comes in two versions - the older
  /// logos are white letters in a heavy outline, which carries either way.
  static String? logoAsset(Game game, Brightness brightness) =>
      brightness == Brightness.dark && _darkLogoByGameId.containsKey(game.id)
          ? _darkLogoByGameId[game.id]
          : _logoByGameId[game.id];

  static const _iconByGameId = <String, String>{
    'sims1': 'assets/games/icons/the_sims_1_icon.png',
    'sims2': 'assets/games/icons/the_sims_2_icon.png',
    'sims3': 'assets/games/icons/the_sims_3_icon.png',
    'sims4': 'assets/games/icons/the_sims_4_icon.png',
    'simsmedieval': 'assets/games/icons/the_sims_medieval_icon.webp',
  };

  static const _logoByGameId = <String, String>{
    'sims1': 'assets/games/logos/the_sims_1_logo.png',
    'sims2': 'assets/games/logos/the_sims_2_logo.png',
    'sims3': 'assets/games/logos/the_sims_3_logo.png',
    'sims4': 'assets/games/logos/the_sims_4_logo_dark.png',
    'simsmedieval': 'assets/games/logos/the_sims_medieval_logo.webp',
  };

  static const _darkLogoByGameId = <String, String>{
    'sims4': 'assets/games/logos/the_sims_4_logo_white.png',
  };
}
