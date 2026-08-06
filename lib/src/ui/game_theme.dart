import 'package:flutter/material.dart';

import '../core/game.dart';
import 'game_skin.dart';

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
    this.skin = GameSkin.flat,
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

  /// How this game's chrome is built - the shapes and materials the
  /// colours above are painted with. [GameSkin.flat] for every game that
  /// hasn't asked for its own, which is what the design handoff drew and
  /// what a new game gets for free. Stitched on by [forGame] from the
  /// game's id, so a palette entry never has to name one.
  final GameSkin skin;

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
    // The game's own blues by daylight. Its interface is night-dark and
    // the dark palette below is the faithful one; this is the same
    // chrome with the lights on, because a Light setting that hands back
    // a dark window is a setting that stopped working. What carries the
    // game here is [Sims1Skin] - the panels stay pale so text reads on
    // them, and everything you press is still blue glass.
    'sims1': GameTheme(
      accent: Color(0xFF1665B0),
      accent2: Color(0xFF2FA8DC),
      bg: Color(0xFFD8E4F7),
      surface: Color(0xFFF2F7FF),
      surfaceAlt: Color(0xFFE4EDFB),
      text: Color(0xFF12294F),
      muted: Color(0xFF4A6591),
      border: Color(0xFFA9C4E8),
      tint: Color(0xFFCFE0F8),
      shadow: Color(0xFF0A1B3D),
      switchOff: Color(0x527D97BE),
    ),
    // The Sims 2's periwinkle by daylight, the same bargain the Sims 1
    // palette makes: pale surfaces so text reads on them, and [Sims2Skin]
    // carrying the game in the chrome. The accent is the plumbob green
    // the game fills a want, a motive and a needs meter with; the old
    // olive-and-parchment set predates anyone looking at the game.
    'sims2': GameTheme(
      accent: Color(0xFF37801F),
      accent2: Color(0xFFC08A15),
      bg: Color(0xFFDDE0F5),
      surface: Color(0xFFF4F5FF),
      surfaceAlt: Color(0xFFE8EAFA),
      text: Color(0xFF23265C),
      muted: Color(0xFF5C639C),
      border: Color(0xFFB7BDE6),
      tint: Color(0xFFCDD3F2),
      shadow: Color(0xFF1A1D45),
      switchOff: Color(0x528E96C9),
    ),
    // The accent and its second swapped round from the design's green
    // and blue: the game's interface is blue and cyan nearly everywhere,
    // and the green only ever turns up in the plumbob and the motive
    // bars. So the blue leads and the green is what it runs into.
    'sims3': GameTheme(
      accent: Color(0xFF1A6F9E),
      accent2: Color(0xFF5CA83C),
      bg: Color(0xFFDCE9F2),
      surface: Color(0xFFF2F8FD),
      surfaceAlt: Color(0xFFE4EFF7),
      text: Color(0xFF123048),
      muted: Color(0xFF4E7590),
      border: Color(0xFFA9CBE2),
      tint: Color(0xFFCBE4F4),
      shadow: Color(0xFF0E2636),
      switchOff: Color(0x52869FB4),
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
    // The neighbourhood screen: a deep royal backdrop, mid-blue panels,
    // and the cyan the game lights its edges with. Read off the shipped
    // UI rather than derived from the old teal one, which was a guess
    // made before anyone looked at the game.
    'sims1': GameTheme(
      accent: Color(0xFF4FD2F5),
      accent2: Color(0xFF2C7BE5),
      bg: Color(0xFF0A1B40),
      surface: Color(0xFF143A7A),
      surfaceAlt: Color(0xFF102E63),
      text: Color(0xFFE4EFFF),
      muted: Color(0xFF9DBBE6),
      border: Color(0xFF2A5296),
      tint: Color(0xFF17346B),
      shadow: Color(0xFF000000),
      switchOff: Color(0x66527AB4),
    ),
    // The live-mode HUD: a deep indigo behind periwinkle panels, with the
    // plumbob green on top. `surface` is held under a luminance of .069
    // by the warning pair, which has to clear 3 against it and is the
    // brightest thing the shared palette puts on a panel.
    'sims2': GameTheme(
      accent: Color(0xFF86D64F),
      accent2: Color(0xFFEAC24E),
      bg: Color(0xFF191B3D),
      surface: Color(0xFF333C78),
      surfaceAlt: Color(0xFF2B3369),
      text: Color(0xFFECEEFF),
      muted: Color(0xFFA9B0E0),
      border: Color(0xFF59639F),
      tint: Color(0xFF242B5C),
      shadow: Color(0xFF000000),
      switchOff: Color(0x66646FB0),
    ),
    'sims3': GameTheme(
      accent: Color(0xFF4EC0EE),
      accent2: Color(0xFF7FD455),
      bg: Color(0xFF0D1B26),
      surface: Color(0xFF17303F),
      surfaceAlt: Color(0xFF122835),
      text: Color(0xFFE3F0F8),
      muted: Color(0xFF96B6C8),
      border: Color(0xFF2A5064),
      tint: Color(0xFF123A4E),
      shadow: Color(0xFF000000),
      switchOff: Color(0x66627E90),
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
    // The skin follows the id rather than the palette, so a game that
    // borrows another's colours still gets the flat chrome - the
    // borrowed one is a stand-in, and stand-in blue glass would be a
    // stronger claim than we have any right to make.
    return palette._finish(_eraByGameId[game.id], brightness,
        GameSkin.forGameId(game.id));
  }

  /// Stitches on the era label, the skin, and the brightness-wide colors
  /// the per-game palettes don't repeat.
  GameTheme _finish(
      (String, String)? era, Brightness brightness, GameSkin skin) {
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
      skin: skin,
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
