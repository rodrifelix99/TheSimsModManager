// The per-game plumbob art the brand mark draws instead of the old
// hand-built rotated square. Files are tall rectangles hugging the
// plumbob's real silhouette with no inner padding - draw them with
// BoxFit.contain, never force a square box around them.
const _plumbobFiles = <String, String>{
  'sims1': 'plumbob_ts1.webp',
  'sims2': 'plumbob_ts2.png',
  'sims3': 'plumbob_ts3.png',
  'sims4': 'plumbob_ts4.webp',
  'simsmedieval': 'plumbob_tsm.webp',
};

/// The plumbob artwork for [gameId], or null when this build ships none
/// for it.
///
/// Null rather than a fallback, and that is the whole point of the
/// change: it used to hand back the Sims 4 plumbob for any id it did
/// not know, which was harmless while every game was a Sims game and
/// became a lie the moment SimCity arrived. A plumbob is The Sims'
/// own emblem - it is not decoration that any game can borrow - so a
/// game without one gets [BrandMark]'s neutral badge instead.
String? plumbobAsset(String gameId) {
  final file = _plumbobFiles[gameId];
  return file == null ? null : 'assets/plumbobs/$file';
}

// What a series with no plumbob puts there instead. SimCity's own
// wordmark, the one the series has carried since 1989: with one of its
// games open the app is that series' mod manager, and the mark beside
// the title is what says so - the neutral badge's letter is what is
// left when a series has nothing of its own.
const _simCityMark = 'assets/games/logos/simcity_manager_logo.webp';

const _seriesMarks = <String, String>{
  'simcity3000': _simCityMark,
  'simcity4': _simCityMark,
  'simcitysocieties': _simCityMark,
  'simcity2013': _simCityMark,
};

/// The emblem [BrandMark] draws for [gameId]: the game's own plumbob
/// where The Sims is what is open, its series' mark where another
/// series is, and null when this build ships neither.
String? brandMarkAsset(String gameId) =>
    plumbobAsset(gameId) ?? _seriesMarks[gameId];
