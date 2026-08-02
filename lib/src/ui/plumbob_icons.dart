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

/// The plumbob artwork for [gameId], falling back to the Sims 4 mark for
/// an id this hasn't shipped art for (a future game added before its own
/// plumbob exists).
String plumbobAsset(String gameId) =>
    'assets/plumbobs/${_plumbobFiles[gameId] ?? _plumbobFiles['sims4']!}';
