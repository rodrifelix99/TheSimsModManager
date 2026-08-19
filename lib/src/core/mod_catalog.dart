/// A catalog somebody else curates, browsed inside this app.
///
/// The third source of mods, after the library (what is already on the
/// disk) and The Exchange (what creators publish to us). A catalog is
/// neither: it is a listing maintained by another project, which this
/// app reads and never writes. The Exchange's vocabulary does not fit
/// one - a catalog entry has no author account here, no download
/// counter of ours to move and no storage path - so it gets its own.
///
/// The whole point of the abstraction is that a catalog entry is
/// **not always installable by us**, and has to say so before the user
/// clicks. Files live wherever the curator's metadata points, and some
/// of those hosts refuse a plain HTTP client outright. Pretending
/// otherwise would mean an Install button that fails at the last step,
/// or worse, one that succeeds at fetching an archive and leaves the
/// game showing brown boxes because half the dependencies never came.
///
/// So [CatalogReach] travels with every entry, and the UI words the
/// action from it rather than from hope.
library;

import 'dart:convert';

import 'app_message.dart';

/// Who maintains a catalog, so the app can credit them wherever its
/// entries are drawn.
///
/// Attribution is not decoration here. The catalogs worth reading are
/// years of somebody's unpaid curation, and an app that browsed them
/// while looking like it had assembled the list itself would be taking
/// the credit for that work.
class CatalogSource {
  const CatalogSource({
    required this.id,
    required this.gameId,
    required this.label,
    required this.projectName,
    required this.projectUrl,
    this.sourceUrl,
  });

  /// The game this catalog indexes.
  ///
  /// A catalog is always about one game, which is what lets The Exchange
  /// show its chips only while that game is in view and, more
  /// importantly, install its entries into *that* game's mods folder
  /// rather than whichever game the sidebar happens to be on. Same rule
  /// The Exchange's own listings follow.
  final String gameId;

  /// Stable and opaque: it keys preferences and analytics, and is never
  /// drawn. Never a URL, which can move.
  final String id;

  /// What this particular listing is called, in the curator's own words
  /// ("Simtropolis", "SC4Evermore"). Proper nouns, so it arrives already
  /// worded rather than as a key - the same bargain `GamePack.name`
  /// makes.
  final String label;

  /// The project whose work this is, named on every entry drawn from it.
  final String projectName;

  /// Where to send someone who wants to know what [projectName] is, or
  /// to install it themselves.
  final Uri projectUrl;

  /// Where this listing's metadata is edited, when the curator publishes
  /// such a place. What a wrong description or a dead link should be
  /// reported to, which is the curator's business and not ours.
  final Uri? sourceUrl;
}

/// Whether this app can fetch an entry's files itself.
///
/// The distinction exists because it is real and permanent, not because
/// of a bug waiting to be fixed: some hosts sit behind a challenge that
/// no plain HTTP client passes, by the host's deliberate choice. An app
/// that treated that as a transient failure would retry forever and
/// blame the user's network.
enum CatalogReach {
  /// Every file this entry needs, dependencies included, comes from a
  /// host that answers an ordinary request. Install can do the whole
  /// job.
  direct,

  /// At least one file sits behind a host that refuses this app. The
  /// entry is still worth showing - it is a real mod, and its page is
  /// one click away - but the only honest primary action is to open
  /// that page in a browser.
  browserOnly,

  /// The entry's files could not be resolved at all: metadata that
  /// names a dependency the channel has since dropped, or a listing
  /// this build's parser did not understand. Distinct from
  /// [browserOnly] because the fix is different and neither the user
  /// nor a browser can help.
  unresolved,
}

/// One row of a catalog's browse list.
///
/// Deliberately thin: a catalog's index is one document holding
/// thousands of these, and everything expensive (description, images,
/// dependencies, the file list) is a second request made only for the
/// entry somebody opened. [CatalogListing] is that second answer.
class CatalogEntry {
  const CatalogEntry({
    required this.sourceId,
    required this.id,
    required this.name,
    required this.version,
    this.summary = '',
    this.categories = const [],
    this.externalIds = const {},
  });

  /// Which [CatalogSource] this came from. Entries from several catalogs
  /// share one shelf, and two of them may well describe the same mod.
  final String sourceId;

  /// Identifies the entry within its source, and is what a detail fetch
  /// is keyed by. Opaque to everything above this layer.
  final String id;

  final String name;

  /// The curator's version string, compared for difference and never
  /// for order - the same rule The Exchange's listings follow, and for
  /// the same reason: these are written by hand and "1.2", "2026-05-01"
  /// and "final" are all real answers.
  final String version;

  final String summary;

  /// The curator's own categories, already worded. Drawn as filter
  /// chips, so a catalog that invents a new one costs nothing.
  final List<String> categories;

  /// Ids this entry carries on other sites, keyed by a short name for
  /// the site. What lets an entry link back to the page a human would
  /// recognise.
  final Map<String, List<String>> externalIds;
}

/// Everything the detail page needs, fetched for one entry at a time.
class CatalogListing {
  const CatalogListing({
    required this.entry,
    required this.reach,
    this.description = '',
    this.author = '',
    this.warning,
    this.conflicts,
    this.imageUrls = const [],
    this.websiteUrls = const [],
    this.dependencies = const [],
    this.assets = const [],
    this.choices = const [],
    this.unreachableHosts = const [],
  });

  final CatalogEntry entry;

  /// Whether Install can finish, worked out over the whole dependency
  /// closure rather than over this entry's own files. A mod whose own
  /// archive is reachable but whose prop pack is not installs to brown
  /// boxes, which is a worse outcome than not offering to install it.
  final CatalogReach reach;

  final String description;

  /// The mod's own maker, credited alongside the catalog that indexed
  /// it. Curators record this unevenly (some catalogs carry a numeric
  /// account id here), so it is drawn only when it reads as a name.
  final String author;

  /// The curator's warning about living with this mod, and what it is
  /// known to clash with. Shown as written: these are the notes that
  /// keep somebody's city from breaking, and paraphrasing them would be
  /// this app inventing advice about a mod it has never seen.
  final String? warning;
  final String? conflicts;

  final List<Uri> imageUrls;

  /// The pages a human would recognise this mod by, curator's order.
  /// The first is what "Open page" opens.
  final List<Uri> websiteUrls;

  /// Everything that has to be installed with it, already flattened and
  /// de-duplicated. Shown in full, because the count is the single most
  /// useful fact about installing a mod for this kind of game and the
  /// user is about to be told we can or cannot fetch all of it.
  final List<CatalogEntry> dependencies;

  /// The files themselves, this entry's and its closure's.
  final List<CatalogAsset> assets;

  /// Where the entry offers a choice that changes what gets installed.
  /// Empty on most, and the reason a catalog entry cannot simply be
  /// downloaded blind: picking wrong installs the wrong thing, or
  /// nothing at all.
  final List<CatalogChoice> choices;

  /// The hosts that refused us, named so the detail page can say which
  /// site the user is being sent to rather than an unexplained "open in
  /// browser". Empty unless [reach] is [CatalogReach.browserOnly].
  final List<String> unreachableHosts;

  bool get canInstall => reach == CatalogReach.direct && assets.isNotEmpty;
}

/// One downloadable file a listing needs.
class CatalogAsset {
  const CatalogAsset({
    required this.id,
    required this.url,
    this.sha256,
    this.lastModified,
    this.include = const [],
  });

  final String id;
  final Uri url;

  /// The curator's digest, when they record one.
  ///
  /// **Advisory, never a gate.** A catalog's metadata and the file its
  /// URL points at are updated by different people at different times,
  /// so a digest that no longer matches usually means the upload moved
  /// on rather than that the download was tampered with. Verified on a
  /// live entry: the recorded digest and the served file disagreed on a
  /// URL that was otherwise exactly right. Refusing the install there
  /// would refuse a perfectly good mod, so a mismatch is worth saying
  /// out loud and not worth blocking on.
  final String? sha256;

  final DateTime? lastModified;

  /// Which paths inside the archive this entry actually wants, when the
  /// curator narrows it. Empty means all of them.
  final List<String> include;

  /// The host, for the reach verdict and for telling the user where a
  /// file is coming from.
  String get host => url.host;
}

/// A choice the entry offers, where the answer changes what installs.
class CatalogChoice {
  const CatalogChoice({
    required this.id,
    required this.values,
    this.descriptions = const {},
  });

  /// Opaque, and what an answer is keyed by.
  final String id;

  /// The options, curator's order. Never empty.
  final List<String> values;

  /// The curator's gloss per value, where they wrote one.
  final Map<String, String> descriptions;
}

/// A catalog this app can read. Implemented under `lib/src/games/`, so
/// nothing above this layer names a particular project.
///
/// Every method is best-effort and must never throw: a catalog is
/// somebody else's website, and it being down is an ordinary Tuesday
/// rather than an error worth breaking a screen over. Failure is null
/// or an empty list, with [describeFailure] wording the last one for
/// the banner.
abstract class ModCatalog {
  const ModCatalog();

  CatalogSource get source;

  /// The browse list. Null when it could not be fetched at all, which
  /// the UI words differently from a catalog that really is empty.
  Future<List<CatalogEntry>?> fetchEntries();

  /// Everything about one entry, including whether we can install it.
  /// Null when the entry could not be resolved.
  ///
  /// [selection] answers the entry's own [CatalogChoice]s. It is on the
  /// interface rather than on the one catalog that has choices today,
  /// because the alternative is the layer above downcasting to a
  /// concrete catalog - which would put the name of a particular
  /// project into `lib/src/ui/`, the one thing this abstraction exists
  /// to prevent. A catalog with no choices ignores it.
  Future<CatalogListing?> fetchListing(
    CatalogEntry entry, {
    Map<String, String> selection = const {},
  });

  /// Just this entry's screenshots, without walking its dependency
  /// closure.
  ///
  /// Separate from [fetchListing] because the shelf wants a cover for
  /// every card on screen and the closure walk is a dozen requests an
  /// entry. This is one, and it shares the same cache, so opening the
  /// detail page afterwards costs nothing extra.
  ///
  /// Image hosts and file hosts are **different questions**: a catalog
  /// whose downloads are gated can still serve its pictures perfectly
  /// well (Simtropolis does exactly that), so nothing here consults
  /// [CatalogReach].
  Future<List<Uri>> fetchImages(CatalogEntry entry) async => const [];

  /// What went wrong last, if anything, in words the user reads.
  AppMessage? describeFailure() => null;
}

/// What a catalog install put on this machine.
///
/// The counterpart of `ShopInstall`, and it exists for the same two
/// reasons: without a record there is no way to answer "you have 1.0,
/// the catalog now lists 1.1", and no way to take a mod back off
/// without the user hunting down every file of a dependency closure by
/// hand. A catalog install can be eighteen files, so the second reason
/// matters more here than it does for The Exchange.
///
/// Versions are compared for **difference and never for order**, the
/// same rule The Exchange follows: curators write them freely and
/// "1.2", "2026-05-01" and "final" are all real answers.
class CatalogInstall {
  const CatalogInstall({
    required this.entryId,
    required this.sourceId,
    required this.gameId,
    required this.version,
    required this.name,
    required this.files,
  });

  final String entryId;
  final String sourceId;
  final String gameId;
  final String version;

  /// The name as it was when installed, so a record can caption itself
  /// with the catalog unreachable.
  final String name;

  /// Paths relative to the mods folder, which is what lets a whole
  /// install move with the folder and still be recognised.
  final List<String> files;

  CatalogInstall copyWith({String? version, List<String>? files}) =>
      CatalogInstall(
        entryId: entryId,
        sourceId: sourceId,
        gameId: gameId,
        version: version ?? this.version,
        name: name,
        files: files ?? this.files,
      );

  Map<String, Object?> toJson() => {
        'source': sourceId,
        'game': gameId,
        'version': version,
        'name': name,
        'files': files,
      };
}

/// Parses the stored records. Anything malformed is dropped rather than
/// thrown over: a record is a convenience, and one corrupt entry must
/// not cost the user the whole screen.
Map<String, CatalogInstall> parseCatalogInstalls(String? source) {
  if (source == null || source.isEmpty) return {};
  Object? decoded;
  try {
    decoded = jsonDecode(source);
  } catch (_) {
    return {};
  }
  if (decoded is! Map) return {};
  final out = <String, CatalogInstall>{};
  decoded.forEach((key, value) {
    if (key is! String || value is! Map) return;
    final game = value['game'];
    final version = value['version'];
    if (game is! String || version is! String) return;
    out[key] = CatalogInstall(
      entryId: key,
      sourceId: value['source'] is String ? value['source'] as String : '',
      gameId: game,
      version: version,
      name: value['name'] is String ? value['name'] as String : key,
      files: [
        for (final file in (value['files'] is List
            ? value['files'] as List
            : const []))
          if (file is String && file.isNotEmpty) file,
      ],
    );
  });
  return out;
}

String encodeCatalogInstalls(Map<String, CatalogInstall> installs) =>
    jsonEncode({
      for (final entry in installs.entries) entry.key: entry.value.toJson(),
    });
