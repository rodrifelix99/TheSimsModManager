/// Reading an sc4pac channel as a browsable catalog.
///
/// sc4pac (memo33/sc4pac-tools, GPL-3.0) is the package manager the
/// SimCity 4 scene actually uses, and its catalog is the closest thing
/// the game has to an index: three channels, together some five and a
/// half thousand packages, published as plain static JSON that anyone
/// may read. This app browses that work and credits it on every entry
/// drawn from it (see [CatalogSource]); it does not fork it, mirror it
/// or pretend to it. `sc4pac.dart` beside this file is the other half
/// of the same respect - what sc4pac has installed is held out of the
/// library so this app never deletes a file it does not own.
///
/// The channel layout, read off the live channels rather than from a
/// specification:
///
/// - `<base>sc4pac-channel-contents.json` is the whole index in one
///   document (645 KB for Main, 1.6 MB for Simtropolis), holding a
///   summary, categories and the available versions per package.
/// - `<base>metadata/<group>/<name>/<version>/pkg.json` is one
///   package's detail: description, author, images, websites, and
///   `variants`, each carrying its own dependencies and assets.
/// - `<base>metadata/sc4pacAsset/<assetId>/<version>/pkg.json` is a
///   file: a URL, a digest and a modification date.
///
/// Two things about that shape drive everything here.
///
/// **A package is a matrix, not a thing.** `variants` is a list of
/// branches and the first one is not a default - the Colossus Addon
/// Mod's first variant is `{CAM: no}`, which installs nothing at all.
/// Resolving a package means choosing, so [chooseSc4pacVariant] takes
/// the selection and falls back to the first branch that actually
/// carries files rather than to index zero.
///
/// **A package is its dependency closure.** A single lot routinely
/// needs a dozen prop packs, and fetching the lot alone puts brown
/// boxes in somebody's city. So [Sc4pacChannel.fetchListing] walks the
/// whole closure before it will say a word about installing, and the
/// reach verdict is over all of it.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../core/app_message.dart';
import '../../core/mod_catalog.dart';

/// The hosts that refuse this app outright.
///
/// Simtropolis sits behind a Cloudflare challenge that answers a plain
/// HTTP client with an interstitial page whatever user agent it sends,
/// on the download URL as well as the site. That is the host's
/// deliberate choice and not a bug to route around: sc4pac gets through
/// with an `Authorization: SC4PAC-TOKEN-ST` header, a scheme Simtropolis
/// built for sc4pac specifically and issues per user. It is not ours to
/// use, so entries whose files live there are shown honestly and their
/// page is opened in a browser instead.
///
/// Measured rather than assumed: everything else the channels point at
/// (SC4Evermore, GitHub releases, ModDB) answers an ordinary request.
const sc4pacBlockedHosts = {'simtropolis.com', 'community.simtropolis.com'};

/// The three channels sc4pac ships with, in its own order.
///
/// Kept as data rather than fetched, because a channel list is the one
/// thing that cannot be discovered from a channel. Taken from
/// `Constants.scala` in sc4pac-tools.
const sc4pacDefaultChannels = <Sc4pacChannelInfo>[
  Sc4pacChannelInfo(
    id: 'sc4pac-main',
    label: 'Main',
    base: 'https://memo33.github.io/sc4pac/channel/',
  ),
  Sc4pacChannelInfo(
    id: 'sc4pac-simtropolis',
    label: 'Simtropolis',
    base: 'https://sc4pac.simtropolis.com/',
  ),
  Sc4pacChannelInfo(
    id: 'sc4pac-sc4evermore',
    label: 'SC4Evermore',
    base: 'https://sc4evermore.github.io/sc4pac-channel/channel/',
  ),
];

/// Where one channel lives, before anything has been fetched from it.
class Sc4pacChannelInfo {
  const Sc4pacChannelInfo({
    required this.id,
    required this.label,
    required this.base,
  });

  final String id;
  final String label;
  final String base;

  CatalogSource sourceFor(String gameId) => CatalogSource(
        id: id,
        gameId: gameId,
        label: label,
        projectName: 'sc4pac',
        projectUrl: Uri.parse('https://memo33.github.io/sc4pac/'),
        sourceUrl: Uri.parse('https://github.com/memo33/sc4pac'),
      );
}

/// One package's detail, as the channel records it. Internal: the app
/// above sees [CatalogListing].
class Sc4pacPackage {
  const Sc4pacPackage({
    required this.group,
    required this.name,
    required this.version,
    required this.variants,
    this.summary = '',
    this.description = '',
    this.author = '',
    this.warning,
    this.conflicts,
    this.images = const [],
    this.websites = const [],
    this.choices = const [],
  });

  final String group;
  final String name;
  final String version;
  final List<Sc4pacVariant> variants;
  final String summary;
  final String description;
  final String author;
  final String? warning;
  final String? conflicts;
  final List<String> images;
  final List<String> websites;
  final List<CatalogChoice> choices;

  String get id => '$group:$name';
}

/// One branch of a package: the choices that select it, and what it
/// installs.
class Sc4pacVariant {
  const Sc4pacVariant({
    this.selection = const {},
    this.dependencies = const [],
    this.assets = const [],
  });

  /// The choice values this branch answers to, e.g. `{CAM: yes}`.
  final Map<String, String> selection;

  /// Package ids (`group:name`) this branch pulls in.
  final List<String> dependencies;

  final List<Sc4pacAssetRef> assets;

  /// Whether this branch actually installs anything. A branch with no
  /// files and no dependencies is an opt-out, which is a real answer
  /// and never a default.
  bool get isEmpty => dependencies.isEmpty && assets.isEmpty;
}

/// A package's reference to a file, before the file's own record is
/// fetched.
class Sc4pacAssetRef {
  const Sc4pacAssetRef({required this.assetId, this.include = const []});
  final String assetId;

  /// sc4pac treats these as regular expressions over the archive's
  /// paths, not as literal names. Carried through untouched because
  /// this app only ever shows them.
  final List<String> include;
}

/// The index, parsed. Pure, so the schema is pinned by a test rather
/// than by whichever channel happened to answer.
///
/// Returns the browse rows plus the version lookup the detail fetch
/// needs: a dependency names `latest.release` rather than a number, and
/// only the index knows what that resolves to.
class Sc4pacIndex {
  const Sc4pacIndex({required this.entries, required this.versions});

  final List<CatalogEntry> entries;

  /// `group:name` and `sc4pacAsset:<id>` to the newest version the
  /// channel lists.
  final Map<String, String> versions;
}

/// Parse `sc4pac-channel-contents.json`.
///
/// Never throws: a channel that answered with something unexpected
/// costs itself and not the screen, so a malformed record is skipped
/// and the rest of the index still loads.
Sc4pacIndex parseSc4pacIndex(String body, String sourceId) {
  final entries = <CatalogEntry>[];
  final versions = <String, String>{};
  Object? decoded;
  try {
    decoded = jsonDecode(body);
  } catch (_) {
    return const Sc4pacIndex(entries: [], versions: {});
  }
  if (decoded is! Map) return const Sc4pacIndex(entries: [], versions: {});

  String? newest(Object? raw) {
    if (raw is! List || raw.isEmpty) return null;
    final last = raw.last;
    return last is String && last.isNotEmpty ? last : null;
  }

  for (final raw in _listOf(decoded['packages'])) {
    if (raw is! Map) continue;
    final group = raw['group'];
    final name = raw['name'];
    final version = newest(raw['versions']);
    if (group is! String || name is! String || version == null) continue;
    versions['$group:$name'] = version;
    entries.add(CatalogEntry(
      sourceId: sourceId,
      id: '$group:$name',
      name: _titleOf(raw['summary'], name),
      version: version,
      summary: raw['summary'] is String ? raw['summary'] as String : '',
      categories: [
        for (final c in _listOf(raw['category']))
          if (c is String && c.isNotEmpty) c,
      ],
      externalIds: _externalIdsOf(raw['externalIds']),
    ));
  }

  for (final raw in _listOf(decoded['assets'])) {
    if (raw is! Map) continue;
    final name = raw['name'];
    final version = newest(raw['versions']);
    if (name is! String || version == null) continue;
    versions['sc4pacAsset:$name'] = version;
  }

  return Sc4pacIndex(entries: entries, versions: versions);
}

/// Parse one `pkg.json`. Null when it is not a package record.
Sc4pacPackage? parseSc4pacPackage(Object? decoded) {
  if (decoded is! Map) return null;
  final group = decoded['group'];
  final name = decoded['name'];
  final version = decoded['version'];
  if (group is! String || name is! String || version is! String) return null;

  final info = decoded['info'];
  final infoMap = info is Map ? info : const {};

  final variants = <Sc4pacVariant>[];
  for (final raw in _listOf(decoded['variants'])) {
    if (raw is! Map) continue;
    final selection = <String, String>{};
    final sel = raw['variant'];
    if (sel is Map) {
      sel.forEach((k, v) {
        if (k is String && v is String) selection[k] = v;
      });
    }
    final dependencies = <String>[];
    for (final dep in _listOf(raw['dependencies'])) {
      if (dep is! Map) continue;
      final dg = dep['group'];
      final dn = dep['name'];
      if (dg is String && dn is String) dependencies.add('$dg:$dn');
    }
    final assets = <Sc4pacAssetRef>[];
    for (final asset in _listOf(raw['assets'])) {
      if (asset is! Map) continue;
      final id = asset['assetId'];
      if (id is! String || id.isEmpty) continue;
      assets.add(Sc4pacAssetRef(
        assetId: id,
        include: [
          for (final i in _listOf(asset['include']))
            if (i is String) i,
        ],
      ));
    }
    variants.add(Sc4pacVariant(
      selection: selection,
      dependencies: dependencies,
      assets: assets,
    ));
  }

  return Sc4pacPackage(
    group: group,
    name: name,
    version: version,
    variants: variants,
    summary: _stringOf(infoMap['summary']),
    description: _stringOf(infoMap['description']),
    author: _authorOf(infoMap['author']),
    warning: _nullableStringOf(infoMap['warning']),
    conflicts: _nullableStringOf(infoMap['conflicts']),
    images: [
      for (final i in _listOf(infoMap['images']))
        if (i is String && i.isNotEmpty) i,
    ],
    websites: [
      for (final w in _listOf(infoMap['websites']))
        if (w is String && w.isNotEmpty) w,
    ],
    choices: _choicesOf(decoded['variantChoices'], decoded['variantInfo']),
  );
}

/// Which branch of a package a selection picks.
///
/// The fallback is the first branch that installs something, never
/// index zero: sc4pac writes opt-out branches (`{CAM: no}`) and those
/// come first often enough that taking index zero silently resolves a
/// package to nothing. A partial selection is honoured as far as it
/// goes, so answering one choice of two still narrows the result.
Sc4pacVariant? chooseSc4pacVariant(
  Sc4pacPackage pkg,
  Map<String, String> selection,
) {
  if (pkg.variants.isEmpty) return null;
  bool matches(Sc4pacVariant v) {
    for (final entry in v.selection.entries) {
      final chosen = selection[entry.key];
      if (chosen != null && chosen != entry.value) return false;
    }
    return true;
  }

  final candidates = pkg.variants.where(matches).toList();
  final pool = candidates.isEmpty ? pkg.variants : candidates;
  for (final v in pool) {
    if (!v.isEmpty) return v;
  }
  return pool.first;
}

/// Parse an asset record into the file it names. Null when it is not
/// one, or names a URL this build will not follow.
CatalogAsset? parseSc4pacAsset(Object? decoded, {List<String> include = const []}) {
  if (decoded is! Map) return null;
  final id = decoded['assetId'];
  final url = decoded['url'];
  if (id is! String || url is! String) return null;
  final uri = Uri.tryParse(url);
  // Every one of these strings was written by somebody else and reaches
  // a network call, so the scheme is a whitelist rather than a check -
  // the same bargain `deep_link.dart` makes.
  if (uri == null || (uri.scheme != 'https' && uri.scheme != 'http')) {
    return null;
  }
  return CatalogAsset(
    id: id,
    url: uri,
    sha256: _digestOf(decoded['checksum']),
    lastModified: DateTime.tryParse(_stringOf(decoded['lastModified'])),
    include: include,
  );
}

/// Whether a host answers this app. Subdomains of a blocked host count,
/// so a channel pointing at a new Simtropolis subdomain is still read
/// correctly.
bool sc4pacHostIsReachable(String host) {
  final lower = host.toLowerCase();
  for (final blocked in sc4pacBlockedHosts) {
    if (lower == blocked || lower.endsWith('.$blocked')) return false;
  }
  return true;
}

/// The verdict over a resolved closure.
CatalogReach sc4pacReachOf(List<CatalogAsset> assets, {required bool resolved}) {
  if (!resolved) return CatalogReach.unresolved;
  for (final asset in assets) {
    if (!sc4pacHostIsReachable(asset.host)) return CatalogReach.browserOnly;
  }
  return CatalogReach.direct;
}

/// One sc4pac channel, read over HTTP.
class Sc4pacChannel extends ModCatalog {
  Sc4pacChannel(this.info, {
    this.gameId = 'simcity4',
    Future<String?> Function(Uri url)? fetch,
  }) : _fetch = fetch ?? _fetchText;

  final Sc4pacChannelInfo info;

  /// The game these packages are for, handed in by the adapter that
  /// built the channel rather than assumed here.
  final String gameId;
  final Future<String?> Function(Uri url) _fetch;

  Sc4pacIndex? _index;
  AppMessage? _failure;

  /// Package records already fetched this session. A detail page walks a
  /// dependency closure that overlaps heavily with the next one's - the
  /// same handful of prop packs sit under half the catalog - so this is
  /// what keeps opening a second lot from re-fetching sixteen files.
  final _packages = <String, Sc4pacPackage?>{};
  final _assets = <String, CatalogAsset?>{};

  @override
  CatalogSource get source => info.sourceFor(gameId);

  @override
  AppMessage? describeFailure() => _failure;

  Uri get _indexUrl => Uri.parse('${info.base}sc4pac-channel-contents.json');

  Uri _metadataUrl(String group, String name, String version) =>
      Uri.parse('${info.base}metadata/$group/$name/$version/pkg.json');

  @override
  Future<List<CatalogEntry>?> fetchEntries() async {
    final cached = _index;
    if (cached != null) return cached.entries;
    final body = await _fetch(_indexUrl);
    if (body == null) {
      _failure = const AppMessage('catalogUnreachable');
      return null;
    }
    final index = parseSc4pacIndex(body, info.id);
    if (index.entries.isEmpty) {
      _failure = const AppMessage('catalogUnreadable');
      return null;
    }
    _failure = null;
    _index = index;
    return index.entries;
  }

  @override
  Future<CatalogListing?> fetchListing(
    CatalogEntry entry, {
    Map<String, String> selection = const {},
  }) async {
    final index = _index;
    if (index == null) {
      // The closure walk resolves `latest.release` out of the index, so
      // there is nothing useful to answer without it.
      final entries = await fetchEntries();
      if (entries == null) return null;
      return fetchListing(entry, selection: selection);
    }

    final root = await _package(entry.id, index);
    if (root == null) {
      _failure = const AppMessage('catalogUnreadable');
      return null;
    }

    final assets = <CatalogAsset>[];
    final dependencies = <CatalogEntry>[];
    final seen = <String>{};
    // A closure is a graph the channel controls, so the walk is bounded
    // rather than trusted: a metadata cycle or a pathological package
    // must not turn opening a detail page into an unbounded fetch.
    var budget = 80;
    var resolved = true;

    Future<void> walk(String id, bool isRoot) async {
      if (!seen.add(id) || budget <= 0) {
        if (budget <= 0) resolved = false;
        return;
      }
      budget--;
      final pkg = isRoot ? root : await _package(id, index);
      if (pkg == null) {
        resolved = false;
        return;
      }
      if (!isRoot) {
        dependencies.add(CatalogEntry(
          sourceId: info.id,
          id: id,
          name: _titleOf(pkg.summary, pkg.name),
          version: pkg.version,
          summary: pkg.summary,
        ));
      }
      final variant = chooseSc4pacVariant(pkg, isRoot ? selection : const {});
      if (variant == null) return;
      for (final ref in variant.assets) {
        final asset = await _asset(ref, index);
        if (asset == null) {
          resolved = false;
          continue;
        }
        if (assets.every((a) => a.id != asset.id)) assets.add(asset);
      }
      for (final dep in variant.dependencies) {
        await walk(dep, false);
      }
    }

    await walk(entry.id, true);

    final reach = sc4pacReachOf(assets, resolved: resolved);
    return CatalogListing(
      entry: entry,
      reach: reach,
      description: root.description,
      author: root.author,
      warning: root.warning,
      conflicts: root.conflicts,
      imageUrls: [
        for (final i in root.images)
          if (Uri.tryParse(i) != null) Uri.parse(i),
      ],
      websiteUrls: [
        for (final w in root.websites)
          if (Uri.tryParse(w) != null) Uri.parse(w),
      ],
      dependencies: dependencies,
      assets: assets,
      choices: root.choices,
      unreachableHosts: {
        for (final a in assets)
          if (!sc4pacHostIsReachable(a.host)) a.host,
      }.toList()
        ..sort(),
    );
  }

  @override
  Future<List<Uri>> fetchImages(CatalogEntry entry) async {
    final index = _index ?? (await fetchEntries() == null ? null : _index);
    if (index == null) return const [];
    final pkg = await _package(entry.id, index);
    if (pkg == null) return const [];
    return [
      for (final raw in pkg.images)
        if (Uri.tryParse(raw) case final uri?)
          if (uri.scheme == 'https' || uri.scheme == 'http') uri,
    ];
  }

  Future<Sc4pacPackage?> _package(String id, Sc4pacIndex index) async {
    if (_packages.containsKey(id)) return _packages[id];
    final version = index.versions[id];
    final split = id.indexOf(':');
    if (version == null || split <= 0) return _packages[id] = null;
    final body = await _fetch(_metadataUrl(
      id.substring(0, split),
      id.substring(split + 1),
      version,
    ));
    if (body == null) return _packages[id] = null;
    Object? decoded;
    try {
      decoded = jsonDecode(body);
    } catch (_) {
      return _packages[id] = null;
    }
    return _packages[id] = parseSc4pacPackage(decoded);
  }

  Future<CatalogAsset?> _asset(Sc4pacAssetRef ref, Sc4pacIndex index) async {
    final cached = _assets[ref.assetId];
    if (cached != null) return cached;
    if (_assets.containsKey(ref.assetId)) return null;
    final version = index.versions['sc4pacAsset:${ref.assetId}'];
    if (version == null) return _assets[ref.assetId] = null;
    final body =
        await _fetch(_metadataUrl('sc4pacAsset', ref.assetId, version));
    if (body == null) return _assets[ref.assetId] = null;
    Object? decoded;
    try {
      decoded = jsonDecode(body);
    } catch (_) {
      return _assets[ref.assetId] = null;
    }
    return _assets[ref.assetId] =
        parseSc4pacAsset(decoded, include: ref.include);
  }
}

/// The default fetcher. Best-effort like everything else here: any
/// failure is null and the caller words it.
Future<String?> _fetchText(Uri url) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final request = await client.getUrl(url);
    request.headers.set(HttpHeaders.userAgentHeader, sc4pacUserAgent);
    final response = await request.close().timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) return null;
    // The index is the biggest thing here and the largest channel's is
    // 1.6 MB, so the cap is generous enough to grow into and small
    // enough that a wrong URL cannot fill memory.
    if (response.contentLength > _maxCatalogBytes) return null;
    final body = await response
        .transform(utf8.decoder)
        .join()
        .timeout(const Duration(seconds: 30));
    return body.length > _maxCatalogBytes ? null : body;
  } catch (_) {
    return null;
  } finally {
    client.close(force: true);
  }
}

/// Identifies this app to the channels rather than hiding behind a
/// browser string. They are somebody's hosting bill and a reader that
/// says what it is can be asked to stop.
const sc4pacUserAgent = 'TheSimsModManager (+https://thesimsmodmanager.web.app)';

const _maxCatalogBytes = 16 << 20;

List<Object?> _listOf(Object? field) => field is List ? field : const [];

String _stringOf(Object? field) => field is String ? field : '';

String? _nullableStringOf(Object? field) {
  final value = _stringOf(field).trim();
  return value.isEmpty ? null : value;
}

/// A channel records the author unevenly: the Main channel often holds
/// a Simtropolis account number where a name belongs. A row of digits
/// credits nobody, so it is dropped rather than drawn.
String _authorOf(Object? field) {
  final value = _stringOf(field).trim();
  if (value.isEmpty) return '';
  return RegExp(r'^\d+$').hasMatch(value) ? '' : value;
}

/// The channel's digest, which it may record bare or under an
/// algorithm key.
String? _digestOf(Object? field) {
  if (field is String) return field.isEmpty ? null : field;
  if (field is Map) {
    final sha = field['sha256'];
    if (sha is String && sha.isNotEmpty) return sha;
  }
  return null;
}

/// The index carries a summary but no separate title, and the package
/// name is a slug. The summary is the closest thing to a title the
/// channel has; the slug is the fallback so a package without one is
/// still named something.
String _titleOf(Object? summary, String slug) {
  final value = _stringOf(summary).trim();
  if (value.isNotEmpty) return value;
  return slug.replaceAll('-', ' ');
}

Map<String, List<String>> _externalIdsOf(Object? field) {
  if (field is! Map) return const {};
  final ids = <String, List<String>>{};
  field.forEach((key, value) {
    if (key is! String) return;
    final values = [
      for (final v in _listOf(value))
        if (v is String && v.isNotEmpty) v,
    ];
    if (values.isNotEmpty) ids[key] = values;
  });
  return ids;
}

List<CatalogChoice> _choicesOf(Object? choices, Object? info) {
  final descriptions = <String, Map<String, String>>{};
  if (info is Map) {
    info.forEach((id, value) {
      if (id is! String || value is! Map) return;
      final glosses = value['valueDescriptions'];
      if (glosses is! Map) return;
      final out = <String, String>{};
      glosses.forEach((k, v) {
        if (k is String && v is String) out[k] = v;
      });
      if (out.isNotEmpty) descriptions[id] = out;
    });
  }

  final out = <CatalogChoice>[];
  for (final raw in _listOf(choices)) {
    if (raw is! Map) continue;
    final id = raw['variantId'];
    if (id is! String) continue;
    final values = [
      for (final v in _listOf(raw['choices']))
        if (v is String) v,
    ];
    if (values.isEmpty) continue;
    out.add(CatalogChoice(
      id: id,
      values: values,
      descriptions: descriptions[id] ?? const {},
    ));
  }
  return out;
}
