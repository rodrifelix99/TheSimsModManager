import 'package:flutter/material.dart';

import '../core/game.dart';
import 'game_skin.dart';

/// The visual identity the app wears. One theme is on at a time,
/// whichever game the sidebar is on: the user picks it in Settings (and
/// during the walkthrough) and it stays put. Values mirror the design
/// prototype; each theme has a light and a dark palette, picked by
/// [forTheme].
///
/// The themes are named after the games whose chrome they were drawn
/// from, plus the flat default the design handoff itself drew - which is
/// why the palettes below are still keyed by game id.
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
  /// what the default theme wears. Stitched on by [forTheme] from the
  /// theme's id, so a palette entry never has to name one.
  final GameSkin skin;

  LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accent, accent2],
      );

  /// Colors only. The skin and the brightness-wide pair are stitched on
  /// by [_finish] rather than being repeated in both palette maps, and
  /// the era label is a fact about the game rather than about any of
  /// this - see [eraOf].
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
    // Cool slate under a steel blue, after the game's own dialogs: pale
    // steel fields, a mid-blue bar over them, charcoal around everything.
    // The second accent is the safety yellow the game reads its numbers
    // out in - it labels nothing on its own, so it is free to be the
    // colour it is in the game rather than one dark enough to sit under
    // text.
    'simcity3000': GameTheme(
      accent: Color(0xFF2C6491),
      accent2: Color(0xFFD18B12),
      bg: Color(0xFFDCE3EF),
      surface: Color(0xFFEEF2F9),
      surfaceAlt: Color(0xFFE1E7F2),
      text: Color(0xFF14202C),
      muted: Color(0xFF4C5C70),
      border: Color(0xFFAEBACD),
      tint: Color(0xFFCBD6E8),
      shadow: Color(0xFF0B131C),
      switchOff: Color(0x52798CA4),
    ),
    // The dialogs again, four years on and warmer for it: the same cool
    // steel, pulled toward the teal the HUD is cast in. The accent is
    // that teal rather than a blue, which is the whole of what separates
    // this palette from the one above; the second is the amber the game
    // reads a number out in and, like SimCity 3000's yellow, labels
    // nothing on its own.
    'simcity4': GameTheme(
      accent: Color(0xFF1C7A75),
      accent2: Color(0xFFC87F16),
      bg: Color(0xFFDCE5E5),
      surface: Color(0xFFEBF1F1),
      surfaceAlt: Color(0xFFDFE8E8),
      text: Color(0xFF12242A),
      muted: Color(0xFF4A6167),
      border: Color(0xFFA9BBBD),
      tint: Color(0xFFC6D6D7),
      shadow: Color(0xFF08161A),
      switchOff: Color(0x52789A9C),
    ),
    // The one game here whose own interface is *light*, so unlike every
    // other entry in this map it is the faithful half of its pair rather
    // than the daylight version of a dark one. Near-white panels, a pale
    // blue-grey behind them, the game's blue for headings and for
    // whatever is selected. `muted` is the style guide's own body colour
    // (R83,G124,B162); the second accent is the orange of the SimCity
    // World bar, which like both older consoles' second accent labels
    // nothing on its own and so keeps the colour it has in the game.
    'simcity2013': GameTheme(
      accent: Color(0xFF1B7CB8),
      accent2: Color(0xFFE8821A),
      // Light for a reason that is ours rather than the game's: the
      // shared warning orange has to clear 3 against it, and at the
      // steel this wanted to be it measured 2.83. The same constraint
      // set SimCity 4's background (3.16) and the Medieval parchment.
      bg: Color(0xFFDEE6ED),
      surface: Color(0xFFFBFCFD),
      surfaceAlt: Color(0xFFEFF3F7),
      text: Color(0xFF24323C),
      muted: Color(0xFF537CA2),
      border: Color(0xFFC3CFDA),
      tint: Color(0xFFDBE5EE),
      shadow: Color(0xFF0D1A24),
      switchOff: Color(0x528FA3B5),
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
    // The toolbar and the status strip, which is what the game itself is
    // built out of: near-black steel behind the map, lit in the blue it
    // picks a tool out with and read in safety yellow.
    'simcity3000': GameTheme(
      accent: Color(0xFF63A9D8),
      accent2: Color(0xFFF2C33F),
      bg: Color(0xFF101820),
      surface: Color(0xFF1C2733),
      surfaceAlt: Color(0xFF222E3B),
      text: Color(0xFFE4ECF3),
      muted: Color(0xFF93A6B6),
      border: Color(0xFF2F3E4C),
      tint: Color(0xFF16232F),
      shadow: Color(0xFF000000),
      switchOff: Color(0x66627B90),
    ),
    // The HUD the map is looked at over: dark slate with a green cast,
    // lit in the muted teal the game marks an active tool with and read
    // in amber. Where SimCity 3000's night is near-black steel, this one
    // keeps the teal in it, which is the difference the two skins are
    // built to carry.
    'simcity4': GameTheme(
      accent: Color(0xFF4FC4BE),
      accent2: Color(0xFFF0C244),
      bg: Color(0xFF0E1A1C),
      surface: Color(0xFF1A292C),
      surfaceAlt: Color(0xFF213235),
      text: Color(0xFFE1EFEF),
      muted: Color(0xFF90A9AB),
      border: Color(0xFF2D4144),
      tint: Color(0xFF142427),
      shadow: Color(0xFF000000),
      switchOff: Color(0x66628789),
    ),
    // This game shipped no dark interface at all - no night mode, no
    // dark panels, nothing the light one is a daylight version of. So
    // this is the invented half of the pair, which is the Sims bargain
    // exactly backwards: the same console with the lights off, keeping
    // the blue and the grey rather than reaching for the navy of the
    // loading screens, which is not chrome.
    'simcity2013': GameTheme(
      accent: Color(0xFF4FA8E0),
      accent2: Color(0xFFF0A03C),
      bg: Color(0xFF12171C),
      surface: Color(0xFF1E262D),
      surfaceAlt: Color(0xFF262F37),
      text: Color(0xFFE6EDF3),
      muted: Color(0xFF9DB1C2),
      border: Color(0xFF35414B),
      tint: Color(0xFF1A242C),
      shadow: Color(0xFF000000),
      switchOff: Color(0x66657C8E),
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

  /// The game's flavor label, e.g. "Modern · 2014", split so it can be
  /// translated: the first field names the mood (resolved by
  /// `AppText.eraName`) and the second is the year beside it. Null for a
  /// game nobody has written one for, which then falls back to its own
  /// series and year - see `eraLabel` in mod_presentation.dart.
  ///
  /// It describes the game on screen rather than the chrome around it,
  /// so it is a fact about the game rather than a field on the theme:
  /// the theme is the user's own choice and says nothing about which
  /// game is being managed.
  static (String, String)? eraOf(Game game) => _eraByGameId[game.id];

  /// The id of the flat chrome the design handoff drew, which is what
  /// the app wears until the user says otherwise.
  static const defaultThemeId = 'default';

  /// Every theme on offer, in the order Settings and the walkthrough
  /// list them: the flat default, then the games whose chrome the rest
  /// were drawn from, franchise by franchise the way the sidebar lists
  /// them rather than by year - a franchise arriving must not rearrange
  /// a list somebody already knows.
  static const themeIds = <String>[
    defaultThemeId,
    'sims1',
    'sims2',
    'sims3',
    'simsmedieval',
    'simcity3000',
    'simcity4',
    'simcity2013',
  ];

  /// The theme the whole app wears at [brightness]. An id we don't know -
  /// a preference written by a later build, or a game id left over from
  /// when the chrome followed the sidebar - falls back to the default.
  static GameTheme forTheme(String? id, Brightness brightness) {
    final key = id == null || id == defaultThemeId ? 'sims4' : id;
    final palettes =
        brightness == Brightness.dark ? _darkByGameId : _lightByGameId;
    // The skin follows the id rather than the palette, so an id that
    // borrows the default's colours still gets the flat chrome - the
    // borrowed one is a stand-in, and stand-in blue glass would be a
    // stronger claim than we have any right to make.
    return (palettes[key] ?? palettes['sims4']!)
        ._finish(brightness, GameSkin.forGameId(key));
  }

  /// The palette [game] would wear if it were the theme. Only the places
  /// that colour a game rather than the chrome ask for this - the sidebar
  /// badge and the walkthrough's list of games found - so it stays per
  /// game while everything else reads [forTheme].
  static GameTheme forGame(Game game, Brightness brightness) =>
      forTheme(game.id, brightness);

  /// Stitches on the skin and the brightness-wide colors the palettes
  /// don't repeat.
  GameTheme _finish(Brightness brightness, GameSkin skin) {
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
    'simcity3000': 'assets/games/icons/simcity_3000_icon.png',
    'simcity4': 'assets/games/icons/simcity_4_icon.webp',
    'simcity2013': 'assets/games/icons/simcity_2013_icon.png',
    'simcitysocieties': 'assets/games/icons/simcity_societies_icon.png',
  };

  static const _logoByGameId = <String, String>{
    'sims1': 'assets/games/logos/the_sims_1_logo.png',
    'sims2': 'assets/games/logos/the_sims_2_logo.png',
    'sims3': 'assets/games/logos/the_sims_3_logo.png',
    'sims4': 'assets/games/logos/the_sims_4_logo_dark.png',
    'simsmedieval': 'assets/games/logos/the_sims_medieval_logo.webp',
    'simcity3000': 'assets/games/logos/simcity_3000_logo.png',
    'simcity4': 'assets/games/logos/simcity_4_logo.png',
    'simcity2013': 'assets/games/logos/simcity_2013_logo.png',
    'simcitysocieties': 'assets/games/logos/simcity_societies_logo.webp',
  };

  static const _darkLogoByGameId = <String, String>{
    'sims4': 'assets/games/logos/the_sims_4_logo_white.png',
  };
}
