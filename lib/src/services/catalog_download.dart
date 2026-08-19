/// Fetching the files a catalog listing needs, all of them.
///
/// The counterpart of `mod_shop.dart`'s single download, and different
/// in the one way that matters: a catalog entry is its whole dependency
/// closure, not one archive. A SimCity 4 lot routinely needs a dozen
/// prop packs and the Colossus Addon Mod needs eighteen files, so this
/// is a batch with two kinds of progress (which file, and how far into
/// it) and a cancel that has to be honoured in both.
///
/// **All or nothing.** Everything lands in a scratch folder and only
/// the complete set is handed back, because installing four of a lot's
/// twelve prop packs is the brown-box failure this whole feature exists
/// to avoid. A cancel or a failure part-way through leaves the mods
/// folder untouched.
library;

import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../app_version.dart';
import '../core/app_message.dart';
import '../core/install_path.dart';
import '../core/mod_catalog.dart';
import 'debug_log.dart';

/// A download that could not finish, worded for the banner.
///
/// Carries an [AppMessage] like [ModActionException] does rather than a
/// bare message: this reaches the user, and core has no localizations.
class CatalogDownloadException implements Exception {
  const CatalogDownloadException(this.detail, {this.cancelled = false});

  final AppMessage detail;

  /// Whether the user stopped it, which is not a failure to report and
  /// gets no error sound.
  final bool cancelled;

  @override
  String toString() => '$detail';
}

/// How far along a closure download is.
class CatalogDownloadProgress {
  const CatalogDownloadProgress({
    required this.index,
    required this.count,
    this.fraction,
    this.fileName = '',
  });

  /// Which file is in flight, zero-based.
  final int index;

  /// How many there are in total. Shown even when it is one, because
  /// "1 of 1" and "3 of 18" should read the same way.
  final int count;

  /// How far into the current file, or null when the host did not say
  /// how big it is. Not a fraction of the whole batch: file sizes here
  /// differ by three orders of magnitude and a bar built on file count
  /// would sit still through a 300 MB download and then jump.
  final double? fraction;

  final String fileName;

  /// The whole batch as one number, for a single bar. Weighted by file
  /// count rather than by bytes, which are not known until each request
  /// is made.
  double get overall =>
      count == 0 ? 0 : ((index + (fraction ?? 0)) / count).clamp(0.0, 1.0);
}

/// One downloaded file, and whether it is what the catalog expected.
class CatalogDownload {
  const CatalogDownload({
    required this.asset,
    required this.file,
    this.digestMatched,
  });

  final CatalogAsset asset;
  final File file;

  /// Null when the catalog recorded no digest, true or false when it
  /// did. **A false does not stop an install**: a catalog's metadata and
  /// the file its URL points at are maintained by different people, and
  /// a stale digest is far more likely than a tampered download. Seen on
  /// the live Main channel, where a recorded digest disagreed with the
  /// served file on a URL that was otherwise exactly right. It is worth
  /// recording and worth saying, and blocking on it would refuse working
  /// mods.
  final bool? digestMatched;
}

/// Download every file in [assets] into [scratch].
///
/// Reports progress per file and checks [isCancelled] both between
/// files and while bytes are moving, so a 300 MB download stops when
/// asked rather than at the end. Throws [CatalogDownloadException] on
/// the first failure, having deleted what it had written.
Future<List<CatalogDownload>> downloadCatalogAssets(
  List<CatalogAsset> assets,
  Directory scratch, {
  void Function(CatalogDownloadProgress progress)? onProgress,
  bool Function()? isCancelled,
}) async {
  final done = <CatalogDownload>[];
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  try {
    for (var i = 0; i < assets.length; i++) {
      if (isCancelled?.call() ?? false) {
        throw const CatalogDownloadException(
            AppMessage('catalogInstallCancelled'),
            cancelled: true);
      }
      final asset = assets[i];
      onProgress?.call(CatalogDownloadProgress(index: i, count: assets.length));
      done.add(await _downloadOne(
        client,
        asset,
        scratch,
        // Two files in one closure can arrive with the same declared
        // name from different hosts, so the asset id keeps them apart
        // without touching the name the archive is unpacked under.
        prefix: '$i',
        onProgress: (received, total) {
          onProgress?.call(CatalogDownloadProgress(
            index: i,
            count: assets.length,
            fraction: total > 0 ? (received / total).clamp(0.0, 1.0) : null,
          ));
        },
        isCancelled: isCancelled,
      ));
    }
    return done;
  } catch (_) {
    // The set is all or nothing, so a failure takes the part-downloads
    // with it rather than leaving a scratch folder somebody might
    // install half of.
    for (final entry in done) {
      try {
        if (await entry.file.exists()) await entry.file.delete();
      } catch (_) {}
    }
    rethrow;
  } finally {
    client.close(force: true);
  }
}

Future<CatalogDownload> _downloadOne(
  HttpClient client,
  CatalogAsset asset,
  Directory scratch, {
  required String prefix,
  void Function(int received, int total)? onProgress,
  bool Function()? isCancelled,
}) async {
  File? destination;
  File? partial;
  IOSink? sink;
  try {
    final request = await client.getUrl(asset.url);
    request.headers
        .set(HttpHeaders.userAgentHeader, 'TheSimsModManager/$appVersion');
    final response = await request.close().timeout(const Duration(seconds: 30));
    if (response.statusCode != 200) {
      catalogDebug('HTTP ${response.statusCode} for ${asset.url.host}');
      throw CatalogDownloadException(
          AppMessage('catalogDownloadFailed', [asset.url.host]));
    }

    final name = catalogFileName(
      asset,
      contentDisposition: response.headers.value('content-disposition'),
    );
    final dir = Directory(p.join(scratch.path, prefix));
    await dir.create(recursive: true);
    destination = File(p.join(dir.path, name));
    partial = File('${destination.path}.part');

    final total = response.contentLength;
    // A percent at a time: every call repaints the window (the shell
    // hangs off one notifier) and these archives arrive in tens of
    // thousands of chunks. Same bargain `downloadShopFile` makes.
    final step = total > 0 ? (total ~/ 100).clamp(1, 1 << 30) : 256 * 1024;
    var received = 0;
    var reported = 0;
    final digest = _DigestSink();
    final hasher = sha256.startChunkedConversion(digest);

    sink = partial.openWrite();
    await for (final chunk in response.timeout(const Duration(minutes: 5))) {
      if (isCancelled?.call() ?? false) {
        throw const CatalogDownloadException(
            AppMessage('catalogInstallCancelled'),
            cancelled: true);
      }
      sink.add(chunk);
      hasher.add(chunk);
      received += chunk.length;
      if (received - reported >= step) {
        reported = received;
        onProgress?.call(received, total);
      }
    }
    await sink.close();
    sink = null;
    hasher.close();
    if (reported != received) onProgress?.call(received, total);

    await partial.rename(destination.path);
    final actual = digest.value?.toString();
    final expected = asset.sha256;
    final matched = (expected == null || actual == null)
        ? null
        : actual == expected.toLowerCase();
    if (matched == false) {
      catalogDebug('digest drift on ${asset.id}: '
          'catalog $expected, served $actual');
    }
    return CatalogDownload(
      asset: asset,
      file: destination,
      digestMatched: matched,
    );
  } on CatalogDownloadException {
    rethrow;
  } catch (e) {
    catalogDebug('download of ${asset.id} failed: ${e.runtimeType}: $e');
    throw CatalogDownloadException(
        AppMessage('catalogDownloadFailed', [asset.url.host]));
  } finally {
    try {
      await sink?.close();
    } catch (_) {}
    try {
      if (partial != null && await partial.exists()) await partial.delete();
    } catch (_) {}
  }
}

/// What to call the file on disk.
///
/// The extension is the part that matters: the install routes on it, so
/// a name without one reaches an unpacker that cannot tell what it is
/// holding. Best answer first - the host's own `Content-Disposition`,
/// which is the only place a real name appears for a URL like
/// `?task=download.send&id=390:blam-fk-hidp-mega-props` - then the URL's
/// last segment, and failing both the asset's id.
///
/// Everything here was written by somebody else and becomes a path, so
/// the result goes through [sanitizeComponent] whichever way it came.
String catalogFileName(CatalogAsset asset, {String? contentDisposition}) {
  final declared = _dispositionFileName(contentDisposition);
  var name = declared ?? '';
  if (name.isEmpty) {
    final segments = asset.url.pathSegments.where((s) => s.isNotEmpty);
    if (segments.isNotEmpty && p.extension(segments.last).isNotEmpty) {
      name = segments.last;
    }
  }
  if (name.isEmpty) name = asset.id;
  name = sanitizeComponent(name, windows: Platform.isWindows);
  return name.isEmpty ? 'download' : name;
}

/// The `filename` out of a `Content-Disposition` header.
///
/// Handles the quoted form every host here uses and the RFC 5987
/// `filename*=UTF-8''...` form, preferring the latter when both are
/// present because that is the one that can carry a non-ASCII name.
/// Any path in the value is discarded rather than trusted: this string
/// comes off the network and is about to become a file name.
String? _dispositionFileName(String? header) {
  if (header == null || header.isEmpty) return null;
  final extended =
      RegExp(r"filename\*\s*=\s*([^']*)'[^']*'([^;]+)", caseSensitive: false)
          .firstMatch(header);
  if (extended != null) {
    try {
      final value = Uri.decodeComponent(extended.group(2)!.trim());
      final name = p.basename(value.replaceAll('\\', '/'));
      if (name.isNotEmpty) return name;
    } catch (_) {
      // A malformed encoding falls through to the plain form below.
    }
  }
  final plain =
      RegExp(r'filename\s*=\s*"([^"]+)"|filename\s*=\s*([^;]+)',
              caseSensitive: false)
          .firstMatch(header);
  if (plain == null) return null;
  final value = (plain.group(1) ?? plain.group(2) ?? '').trim();
  if (value.isEmpty) return null;
  return p.basename(value.replaceAll('\\', '/'));
}

void catalogDebug(String reason) => debugLog('catalog', reason);

/// Catches the one digest a chunked SHA-256 conversion emits, the same
/// three lines `duplicates.dart` keeps for the same reason: it saves a
/// dependency on `package:convert` for one class.
class _DigestSink implements Sink<Digest> {
  Digest? value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}
