import 'package:flutter/material.dart';

import '../core/game.dart';

/// Warning color for mod conflicts (shared across all game themes).
const conflictOrange = Color(0xFFE0632E);
const conflictOrangeDark = Color(0xFFB34A1E);

/// The visual identity of one game: the whole chrome re-tints when the
/// user switches games. Values mirror the design prototype.
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
    required this.era,
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

  /// Flavor label shown next to the game name, e.g. "Modern · 2014".
  final String era;

  LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accent, accent2],
      );

  static const _byGameId = <String, GameTheme>{
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
      era: 'Classic · 2000',
    ),
    'sims2': GameTheme(
      accent: Color(0xFF5BA12C),
      accent2: Color(0xFFE07B2E),
      bg: Color(0xFFF4EFE4),
      surface: Color(0xFFFFFDF6),
      surfaceAlt: Color(0xFFF6F1E6),
      text: Color(0xFF31301D),
      muted: Color(0xFF83806B),
      border: Color(0xFFE6DDC9),
      tint: Color(0xFFEAF3DD),
      era: 'Nightlife · 2004',
    ),
    'sims3': GameTheme(
      accent: Color(0xFF7CB518),
      accent2: Color(0xFF2F7D9E),
      bg: Color(0xFFECEFF0),
      surface: Color(0xFFFFFFFF),
      surfaceAlt: Color(0xFFF1F4F5),
      text: Color(0xFF22303A),
      muted: Color(0xFF6C7F88),
      border: Color(0xFFDDE4E7),
      tint: Color(0xFFE9F2D8),
      era: 'Ambitions · 2009',
    ),
    'sims4': GameTheme(
      accent: Color(0xFF1FBF8F),
      accent2: Color(0xFF12B0D6),
      bg: Color(0xFFEAF6F2),
      surface: Color(0xFFFFFFFF),
      surfaceAlt: Color(0xFFF2FAF7),
      text: Color(0xFF0F2E28),
      muted: Color(0xFF5F827A),
      border: Color(0xFFD9ECE5),
      tint: Color(0xFFDCF5EC),
      era: 'Modern · 2014',
    ),
  };

  /// Theme for [game]; future games without a bespoke palette get a
  /// neutral teal one labeled with their year/series.
  static GameTheme forGame(Game game) {
    final known = _byGameId[game.id];
    if (known != null) return known;
    final fallback = _byGameId['sims4']!;
    return GameTheme(
      accent: fallback.accent,
      accent2: fallback.accent2,
      bg: fallback.bg,
      surface: fallback.surface,
      surfaceAlt: fallback.surfaceAlt,
      text: fallback.text,
      muted: fallback.muted,
      border: fallback.border,
      tint: fallback.tint,
      era: game.year != null ? '${game.series} · ${game.year}' : game.series,
    );
  }

  /// Sidebar badge color per game (the design gives each row its own dot).
  static Color badgeColor(Game game) =>
      _byGameId[game.id]?.accent ?? _byGameId['sims4']!.accent;

  /// Sidebar icon for [game], or null when we don't ship one — the row
  /// then falls back to the lettered badge, so new games need no UI work.
  static String? iconAsset(Game game) => _iconByGameId[game.id];

  /// Wordmark logo for [game] (variant readable on the light themes), or
  /// null when we don't ship one — the library header falls back to text.
  static String? logoAsset(Game game) => _logoByGameId[game.id];

  static const _iconByGameId = <String, String>{
    'sims1': 'assets/games/icons/the_sims_1_icon.png',
    'sims2': 'assets/games/icons/the_sims_2_icon.png',
    'sims3': 'assets/games/icons/the_sims_3_icon.png',
    'sims4': 'assets/games/icons/the_sims_4_icon.png',
  };

  static const _logoByGameId = <String, String>{
    'sims1': 'assets/games/logos/the_sims_1_logo.png',
    'sims2': 'assets/games/logos/the_sims_2_logo.png',
    'sims3': 'assets/games/logos/the_sims_3_logo.png',
    // All four themes are light, so use the dark-on-light variant.
    'sims4': 'assets/games/logos/the_sims_4_logo_dark.png',
  };
}
