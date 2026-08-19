/// What a release brought that is worth stopping someone for.
///
/// Deliberately bundled rather than fetched: the build that introduces a
/// feature is the one that should carry the words about it, so the card
/// works offline, is translated with everything else, and can never
/// celebrate a feature the running copy does not have. The remote
/// `announcement` flag is the other half of that split - it is for the
/// things that happen between releases, and it is a banner because that
/// is what a message from elsewhere should be.
library;

/// One release worth celebrating. A release with nothing to say has no
/// entry at all, which is what keeps a patch that fixes a crash from
/// opening a dialog nobody asked for.
class WhatsNewEntry {
  const WhatsNewEntry({
    required this.version,
    required this.titleKey,
    required this.bodyKey,
    this.image,
    this.film,
    this.audio,
    this.url,
  });

  /// The version this shipped in, exactly as `appVersion` spells it.
  final String version;

  /// ARB keys rather than wording: core has no localizations, the same
  /// bargain `TriviaFact` and `Mod.category` make, resolved by
  /// `AppText.whatsNewTitle`/`whatsNewBody` at the moment it is drawn.
  final String titleKey;
  final String bodyKey;

  /// The hero, as an asset path. Optional, and an entry without one
  /// draws the card's own header instead - an older entry listed under
  /// the newest never shows its picture anyway.
  final String? image;

  /// A film to play across the hero once, as an asset path. Optional,
  /// and an animated WebP for the reason the walkthrough's own film is
  /// one - Flutter plays no video on the desktop without a native
  /// player per platform behind it.
  ///
  /// It is drawn *over* [image] rather than instead of it and dissolves
  /// into it when it reaches the end, so a release that ships no film,
  /// and a machine that cannot decode the one it has, are both left
  /// looking at the picture the card always showed.
  final String? film;

  /// The film's own sound, as an asset path. Optional, and only ever
  /// reached while [film] is playing: it starts with the picture and
  /// stops with it, whether that is the last frame or the moment the
  /// card is closed. Gated on the `soundEffects` pref, which is the
  /// app's standing answer to whether it may make a noise at all.
  final String? audio;

  /// Where to read more. Optional; no button when it is absent.
  final String? url;
}

/// The table, oldest first, which is the order releases happen in.
/// More than one entry may share a version: the first of them is the
/// one that gets the card's hero, and the rest are listed under it.
const List<WhatsNewEntry> whatsNewEntries = [
  WhatsNewEntry(
    version: '3.0.0',
    titleKey: 'whatsNew300SimCityTitle',
    bodyKey: 'whatsNew300SimCityBody',
    image: 'assets/whatsnew/3.0.0.webp',
    film: 'assets/whatsnew/3.0.0-film.webp',
    audio: 'assets/whatsnew/3.0.0.mp3',
  ),
  WhatsNewEntry(
    version: '3.0.0',
    titleKey: 'whatsNew300CatalogTitle',
    bodyKey: 'whatsNew300CatalogBody',
  ),
  WhatsNewEntry(
    version: '3.0.0',
    titleKey: 'whatsNew300ThemeTitle',
    bodyKey: 'whatsNew300ThemeBody',
  ),
  WhatsNewEntry(
    version: '3.0.0',
    titleKey: 'whatsNew300RootTitle',
    bodyKey: 'whatsNew300RootBody',
  ),
  WhatsNewEntry(
    version: '3.0.0',
    titleKey: 'whatsNew300PacksTitle',
    bodyKey: 'whatsNew300PacksBody',
  ),
  WhatsNewEntry(
    version: '3.0.0',
    titleKey: 'whatsNew300ContainersTitle',
    bodyKey: 'whatsNew300ContainersBody',
  ),
];

/// Orders two `x.y.z` strings, the way `compareTo` does.
///
/// Null when either is not a version we wrote: unlike a listing on The
/// Exchange - where creators spell versions freely and difference is all
/// that can be relied on - these are ours, so they really do order, and
/// a copy that has somehow gone backwards must show nothing rather than
/// everything.
int? compareVersions(String a, String b) {
  final left = _parse(a);
  final right = _parse(b);
  if (left == null || right == null) return null;
  for (var i = 0; i < 3; i++) {
    final d = left[i].compareTo(right[i]);
    if (d != 0) return d;
  }
  return 0;
}

List<int>? _parse(String version) {
  final parts = version.trim().split('.');
  if (parts.isEmpty || parts.length > 3) return null;
  final out = <int>[0, 0, 0];
  for (var i = 0; i < parts.length; i++) {
    final n = int.tryParse(parts[i]);
    if (n == null || n < 0) return null;
    out[i] = n;
  }
  return out;
}

/// What to celebrate on an update from [from] to [to], newest first.
///
/// Empty for a fresh install ([from] null), for a version that has
/// already been seen, and for anything unreadable. Entries newer than
/// [to] are left out as well, so a table written ahead of its release
/// cannot announce a feature that is not in this build.
List<WhatsNewEntry> entriesSince(
  String? from,
  String to, {
  List<WhatsNewEntry> entries = whatsNewEntries,
}) {
  if (from == null) return const [];
  final out = [
    for (var i = 0; i < entries.length; i++)
      if ((compareVersions(entries[i].version, from) ?? 0) > 0 &&
          (compareVersions(entries[i].version, to) ?? 1) <= 0)
        (i, entries[i]),
  ];
  // Newest release first, and within one release the order the table
  // was written in. That second half is not decoration: `List.sort` is
  // unstable, so two entries sharing a version could otherwise swap
  // between builds and the card would pick a different hero.
  out.sort((a, b) {
    final byVersion = compareVersions(b.$2.version, a.$2.version) ?? 0;
    return byVersion != 0 ? byVersion : a.$1.compareTo(b.$1);
  });
  return [for (final (_, entry) in out) entry];
}
