import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../app_version.dart';
import '../core/deep_link.dart';
import 'debug_log.dart';

/// The Exchange: the mod storefront creators publish to at
/// https://thesimsmodmanager.web.app/portal/ and the app browses in the shop
/// screen. Backed by Firebase (project `thesimsmodmanager`), spoken to
/// over plain HTTPS in pure Dart for the same reason analytics is: the
/// official SDKs don't support Linux. The app only ever reads - listings
/// are world-readable by security rule, and writing takes a creator
/// account through the portal - so all it needs is the public web API
/// key, the same one every portal visitor's browser holds.

const String shopPortalUrl = 'https://thesimsmodmanager.web.app/portal/';

/// A listing's page on the website: the address to hand out, and the one
/// that opens the app back here through `simsmodmanager://mod/<id>`.
/// Always the English root - it is one link for a whole audience, and the
/// page offers whoever opens it their own language.
String shopListingUrl(String id) =>
    'https://thesimsmodmanager.web.app/m/${Uri.encodeComponent(id)}';

const String _project = 'thesimsmodmanager';
const String _apiKey = 'AIzaSyDsC3_mQFDUXj6pmKMw1_xf4_XigC82smE';
const String _bucket = 'thesimsmodmanager.firebasestorage.app';

/// Ceiling on the listings response. A page of 300 listings is well
/// under a megabyte; anything bigger is a proxy or captive portal
/// answering in our place.
const int _maxListingBytes = 8 << 20;

/// Public download URL for a file in the shop's storage bucket. Built by
/// hand rather than with [Uri.https]: the object path travels as one
/// URL-encoded segment (`mods%2Fabc%2Ffile.zip`), which Uri.https would
/// re-encode.
Uri shopFileUri(String path) => Uri.parse(
    'https://firebasestorage.googleapis.com/v0/b/$_bucket/o/'
    '${Uri.encodeComponent(path)}?alt=media');

/// One listing on The Exchange, as published through the creator portal.
class ShopMod {
  const ShopMod({
    required this.id,
    required this.gameId,
    required this.name,
    required this.version,
    required this.description,
    required this.authorName,
    required this.fileName,
    required this.filePath,
    required this.fileSizeBytes,
    this.instructions,
    this.imagePaths = const [],
    this.updatedAt,
    this.downloads = 0,
    this.demoImages = const [],
  });

  /// Firestore document id: stable, opaque, safe for analytics (it names
  /// a public listing, never the user).
  final String id;

  final String gameId;

  /// Clean display name the creator chose - unlike the library, where a
  /// title has to be dug out of a file name.
  final String name;

  final String version;
  final String description;

  /// Anything the creator wants done besides installing.
  final String? instructions;

  final String authorName;

  /// The download: its file name (what lands in the mods folder, or an
  /// archive the adapter unpacks), storage path and size.
  final String fileName;
  final String filePath;
  final int fileSizeBytes;

  /// Screenshot storage paths, first one is the cover.
  final List<String> imagePaths;

  final DateTime? updatedAt;

  /// How many people have taken this mod. Counted server-side by the
  /// `recordDownload` function, which this app pings once an install has
  /// finished and the listing's web page pings on its download button -
  /// one machine counting once a day either way. Zero on a listing
  /// published before there was a counter, which is what we honestly
  /// know rather than a guess at what it missed.
  final int downloads;

  /// Screenshots carried as bytes rather than fetched, which only the
  /// invented listings of the demo library have (see `demo_shop.dart`).
  /// A real listing's images always live in [imagePaths].
  final List<Uint8List> demoImages;

  /// How many screenshots this listing has, wherever they come from.
  int get imageCount =>
      demoImages.isNotEmpty ? demoImages.length : imagePaths.length;

  Uri get downloadUri => shopFileUri(filePath);

  Uri? get coverUri =>
      imagePaths.isEmpty ? null : shopFileUri(imagePaths.first);

  Uri imageUri(int index) => shopFileUri(imagePaths[index]);
}

/// What one listing left on this machine: the version that was
/// installed and the files it produced, so a newer version on the shelves
/// can be recognized as an update rather than a stranger. [files] are
/// paths relative to that game's mods folder (Sims 1 routes some of them
/// into sibling folders, so a relative path can climb out with `..`).
class ShopInstall {
  const ShopInstall({
    required this.listingId,
    required this.gameId,
    required this.version,
    required this.name,
    required this.files,
  });

  final String listingId;
  final String gameId;
  final String version;

  /// The listing's name as it was when installed, so the record can
  /// caption itself even if the catalog can't be reached.
  final String name;

  final List<String> files;

  ShopInstall copyWith({String? version, String? name, List<String>? files}) =>
      ShopInstall(
        listingId: listingId,
        gameId: gameId,
        version: version ?? this.version,
        name: name ?? this.name,
        files: files ?? this.files,
      );

  Map<String, Object?> toJson() => {
        'game': gameId,
        'version': version,
        'name': name,
        'files': files,
      };
}

/// Parses the stored install records. Anything malformed is dropped: the
/// record is a convenience, and a corrupt entry must not cost the user
/// their shop screen.
Map<String, ShopInstall> parseShopInstalls(String? source) {
  if (source == null || source.isEmpty) return {};
  Object? json;
  try {
    json = jsonDecode(source);
  } catch (_) {
    return {};
  }
  if (json is! Map) return {};
  final result = <String, ShopInstall>{};
  for (final entry in json.entries) {
    final value = entry.value;
    if (value is! Map) continue;
    final gameId = value['game'];
    final version = value['version'];
    if (gameId is! String || version is! String) continue;
    final files = value['files'];
    result[entry.key.toString()] = ShopInstall(
      listingId: entry.key.toString(),
      gameId: gameId,
      version: version,
      name: value['name'] is String ? value['name'] as String : '',
      files: [
        if (files is List)
          for (final file in files)
            if (file is String) file,
      ],
    );
  }
  return result;
}

String encodeShopInstalls(Map<String, ShopInstall> installs) =>
    jsonEncode({for (final e in installs.entries) e.key: e.value.toJson()});

String? _str(Object? field) {
  if (field is! Map) return null;
  final value = field['stringValue'];
  return value is String ? value : null;
}

int? _int(Object? field) {
  if (field is! Map) return null;
  final value = field['integerValue'];
  // Firestore writes 64-bit integers as strings.
  return value is String ? int.tryParse(value) : (value is int ? value : null);
}

/// Turns one Firestore runQuery result row into a listing, or null when
/// the row isn't one (the trailing readTime row, a document missing
/// required fields - the portal can't write one, but the wire can carry
/// anything).
ShopMod? _parseDocument(Object? row) {
  if (row is! Map) return null;
  final doc = row['document'];
  if (doc is! Map) return null;
  final path = doc['name'];
  final fields = doc['fields'];
  if (path is! String || fields is! Map) return null;
  final id = path.split('/').last;
  final file = fields['file'];
  final fileFields = file is Map ? file['mapValue'] : null;
  final f = fileFields is Map ? fileFields['fields'] : null;
  if (f is! Map) return null;
  final gameId = _str(fields['gameId']);
  final name = _str(fields['name']);
  final fileName = _str(f['name']);
  final filePath = _str(f['path']);
  if (gameId == null || name == null || fileName == null || filePath == null) {
    return null;
  }
  final images = <String>[];
  final imagesField = fields['images'];
  final imagesValue = imagesField is Map ? imagesField['arrayValue'] : null;
  final values = imagesValue is Map ? imagesValue['values'] : null;
  if (values is List) {
    for (final value in values) {
      final image = _str(value);
      if (image != null) images.add(image);
    }
  }
  DateTime? updatedAt;
  final updatedField = fields['updatedAt'];
  if (updatedField is Map && updatedField['timestampValue'] is String) {
    updatedAt =
        DateTime.tryParse(updatedField['timestampValue'] as String)?.toLocal();
  }
  return ShopMod(
    id: id,
    gameId: gameId,
    name: name,
    version: _str(fields['version']) ?? '',
    description: _str(fields['description']) ?? '',
    instructions: _str(fields['instructions']),
    authorName: _str(fields['authorName']) ?? '',
    fileName: fileName,
    filePath: filePath,
    fileSizeBytes: _int(f['size']) ?? 0,
    imagePaths: images,
    updatedAt: updatedAt,
    // Absent on every listing published before the counter existed, and
    // never negative whatever the wire says.
    downloads: (_int(fields['downloads']) ?? 0).clamp(0, 1 << 40),
  );
}

/// Parses a Firestore runQuery response into listings. Rows that don't
/// parse are dropped rather than failing the lot: one malformed listing
/// must not empty the shop.
List<ShopMod> parseShopListings(String body) {
  final json = jsonDecode(body);
  if (json is! List) return const [];
  final mods = <ShopMod>[];
  var dropped = 0;
  for (final row in json) {
    if (_parseDocument(row) case final mod?) {
      mods.add(mod);
    } else if (row is Map && row['document'] != null) {
      // A row carrying a document that still didn't parse, rather than
      // the trailing readTime row - worth saying out loud in debug,
      // because from the shelves it is indistinguishable from a listing
      // the creator never published.
      dropped++;
    }
  }
  if (dropped > 0) _shopDebug('dropped $dropped listing(s) that did not parse');
  return mods;
}

void _shopDebug(String reason) => debugLog('shop', reason);

/// Every published listing, newest first, or null when anything at all
/// goes wrong (offline, the service down, an answer that isn't ours).
/// The whole catalog travels in one request rather than one per game:
/// The Exchange is a shelf for all of them, and which game a listing is
/// for is a filter the shop screen applies to what it already holds.
/// Best-effort like the update check: the shop screen offers a retry,
/// nothing else in the app waits on this.
Future<List<ShopMod>?> fetchShopListings() async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final request = await client.postUrl(Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$_project/'
        'databases/(default)/documents:runQuery?key=$_apiKey'));
    request.headers.contentType = ContentType.json;
    request.headers
        .set(HttpHeaders.userAgentHeader, 'TheSimsModManager/$appVersion');
    request.write(jsonEncode({
      'structuredQuery': {
        'from': [
          {'collectionId': 'mods'}
        ],
        'where': {
          'fieldFilter': {
            'field': {'fieldPath': 'published'},
            'op': 'EQUAL',
            'value': {'booleanValue': true},
          },
        },
        'orderBy': [
          {
            'field': {'fieldPath': 'updatedAt'},
            'direction': 'DESCENDING',
          }
        ],
        'limit': 300,
      },
    }));
    final response = await request.close().timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      _shopDebug('HTTP ${response.statusCode} from Firestore: '
          '${await debugBodyHead(response)}');
      return null;
    }
    if (response.contentLength > _maxListingBytes) {
      _shopDebug('refused an answer of ${response.contentLength} bytes');
      return null;
    }
    final body = await response
        .transform(utf8.decoder)
        .join()
        .timeout(const Duration(seconds: 20));
    if (body.length > _maxListingBytes) {
      _shopDebug('refused an answer of ${body.length} bytes');
      return null;
    }
    final listings = parseShopListings(body);
    _shopDebug('loaded ${listings.length} listings');
    return listings;
  } catch (e) {
    _shopDebug('fetch failed: ${e.runtimeType}: $e');
    return null;
  } finally {
    client.close(force: true);
  }
}

/// One published listing by document id, or null when there isn't one:
/// never published, taken down, a listing id that isn't one, or a network
/// that said no. Reads the document straight rather than re-running the
/// catalog query, because a deep link names exactly one listing and the
/// catalog is capped at 300 anyway - which is the whole reason this
/// exists. Unpublished drafts need no check here: the rules only hand an
/// anonymous reader a listing whose `published` is true, so a draft
/// answers 403 and lands in the same place as a missing one.
Future<ShopMod?> fetchShopListing(String id) async {
  // Guarded here rather than trusted from the caller: this is public, and
  // the id is one string away from being a path we build.
  if (!isShopListingId(id)) {
    _shopDebug('refused a listing id of ${id.length} characters');
    return null;
  }
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final request = await client.getUrl(Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$_project/'
        'databases/(default)/documents/mods/${Uri.encodeComponent(id)}'
        '?key=$_apiKey'));
    request.headers
        .set(HttpHeaders.userAgentHeader, 'TheSimsModManager/$appVersion');
    final response = await request.close().timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      _shopDebug('HTTP ${response.statusCode} for listing $id');
      return null;
    }
    if (response.contentLength > _maxListingBytes) {
      _shopDebug('refused an answer of ${response.contentLength} bytes');
      return null;
    }
    final body = await response
        .transform(utf8.decoder)
        .join()
        .timeout(const Duration(seconds: 20));
    if (body.length > _maxListingBytes) {
      _shopDebug('refused an answer of ${body.length} bytes');
      return null;
    }
    return parseShopListing(body);
  } catch (e) {
    _shopDebug('fetch of $id failed: ${e.runtimeType}: $e');
    return null;
  } finally {
    client.close(force: true);
  }
}

/// Parses the single-document endpoint's answer. It hands over the
/// document itself where runQuery wraps it in a row, so it is wrapped
/// here rather than teaching [_parseDocument] a second shape.
ShopMod? parseShopListing(String body) {
  try {
    return _parseDocument({'document': jsonDecode(body)});
  } catch (e) {
    _shopDebug('listing did not parse: ${e.runtimeType}');
    return null;
  }
}

/// Says that this machine took [id], so a creator's download count means
/// people who installed their mod rather than people who looked at it.
/// Called once an install has actually finished - a failed download is
/// not a download - and never for a demo listing, which is invented.
///
/// The server counts one machine once a day per listing, so pressing
/// Install again tomorrow is not a second download and reinstalling this
/// afternoon is not either. It sends the listing id and nothing else: no
/// account, no machine id, nothing about the library. The address the
/// request comes from is hashed on arrival purely to recognise a repeat,
/// which is the same thing the file download itself already reveals.
///
/// Fire and forget in every sense - failures are swallowed, the answer is
/// not read, and nothing in the app waits on it.
Future<void> reportShopDownload(String id) async {
  if (!isShopListingId(id)) return;
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);
  try {
    final request = await client.postUrl(Uri.parse(
        'https://thesimsmodmanager.web.app/api/downloads/'
        '${Uri.encodeComponent(id)}'));
    request.headers
        .set(HttpHeaders.userAgentHeader, 'TheSimsModManager/$appVersion');
    request.contentLength = 0;
    final response = await request.close().timeout(const Duration(seconds: 10));
    await response.drain<void>();
  } catch (e) {
    _shopDebug('download count for $id failed: ${e.runtimeType}');
  } finally {
    client.close(force: true);
  }
}

/// Downloads a listing's file into [destination], reporting progress as
/// (received, total) - total is 0 when the server didn't say. Unlike the
/// fetches above this throws on failure: the caller is an install the
/// user just asked for, and "nothing happened" is not an answer it can
/// show. A partial file is deleted before the error travels on.
Future<void> downloadShopFile(
  ShopMod mod,
  File destination, {
  void Function(int received, int total)? onProgress,
}) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  IOSink? sink;
  try {
    final request = await client.getUrl(mod.downloadUri);
    request.headers
        .set(HttpHeaders.userAgentHeader, 'TheSimsModManager/$appVersion');
    final response =
        await request.close().timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      throw HttpException('HTTP ${response.statusCode}', uri: mod.downloadUri);
    }
    final total = response.contentLength > 0
        ? response.contentLength
        : mod.fileSizeBytes;
    await destination.parent.create(recursive: true);
    sink = destination.openWrite();
    var received = 0;
    await for (final chunk in response.timeout(const Duration(minutes: 2))) {
      sink.add(chunk);
      received += chunk.length;
      onProgress?.call(received, total);
    }
    await sink.close();
    sink = null;
  } catch (e) {
    // This one travels on to the caller, but only as far as a worded
    // error banner - the exception itself stops here.
    _shopDebug('download of ${mod.id} failed: ${e.runtimeType}: $e');
    try {
      await sink?.close();
    } catch (_) {}
    try {
      if (await destination.exists()) await destination.delete();
    } catch (_) {}
    rethrow;
  } finally {
    client.close(force: true);
  }
}
