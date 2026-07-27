import 'dart:convert';
import 'dart:io';

import '../app_version.dart';
import 'debug_log.dart';

/// GitHub integration: release update checks and feedback links. Pure
/// Dart, no game or UI knowledge. Everything is best-effort: network
/// failures surface as `null`, never as exceptions - and say why in a
/// debug run, because nothing in the UI reports either of these failing.

/// The project's GitHub repository, `owner/name`.
const String githubRepo = 'rodrifelix99/TheSimsModManager';

/// The published mod-advisory list (see docs/advisories.md). It ships with
/// the website, which deploys on every push to `dev`, so an advisory goes
/// live on push rather than waiting for a release - which is the point,
/// given the mods it names break on the day a game patch lands.
///
/// Apps up to v1.2.x read the same file from the old GitHub Pages address,
/// which cannot redirect a JSON file; web/scripts/mirror-advisories.mjs
/// keeps that copy identical for as long as those installs are out there.
const String advisoriesUrl = 'https://thesimsmodmanager.web.app/data/advisories.json';

/// Ceiling on the advisory file. Ours is a few kilobytes; the cap is
/// there because what answers the request isn't always what we published
/// - a captive portal or a proxy will happily serve something else, and
/// the body is read into one string.
const int _maxAdvisoryBytes = 1 << 20;

class UpdateInfo {
  const UpdateInfo({required this.version, required this.url});

  /// The release's version, without the `v` tag prefix (e.g. `1.2.0`).
  final String version;

  final String url;
}

/// Whether [latest] is a strictly newer `x.y.z` version than [current].
/// Unparseable versions compare as not-newer, so a malformed tag can
/// never trigger a bogus update prompt.
bool isNewerVersion(String current, String latest) {
  List<int>? parse(String v) {
    final match = RegExp(r'^(\d+)\.(\d+)\.(\d+)').firstMatch(v.trim());
    if (match == null) return null;
    return [for (var i = 1; i <= 3; i++) int.parse(match.group(i)!)];
  }

  final a = parse(current);
  final b = parse(latest);
  if (a == null || b == null) return false;
  for (var i = 0; i < 3; i++) {
    if (b[i] != a[i]) return b[i] > a[i];
  }
  return false;
}

/// Asks the GitHub API for the latest release and returns it when it's
/// newer than the running [appVersion]; `null` when up to date or when
/// anything fails (offline, rate-limited, no releases yet).
Future<UpdateInfo?> fetchAvailableUpdate() async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final request = await client.getUrl(
        Uri.parse('https://api.github.com/repos/$githubRepo/releases/latest'));
    request.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
    request.headers
        .set(HttpHeaders.userAgentHeader, 'TheSimsModManager/$appVersion');
    final response = await request.close().timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      // The rate limit is the one that bites, and it answers 403 with a
      // remaining count of zero rather than anything that reads as an
      // outage.
      final remaining = response.headers.value('x-ratelimit-remaining');
      debugLog(
          'update',
          'HTTP ${response.statusCode}'
              '${remaining == null ? '' : ' (rate limit remaining $remaining)'}'
              ': ${await debugBodyHead(response)}');
      return null;
    }
    final body = await response
        .transform(utf8.decoder)
        .join()
        .timeout(const Duration(seconds: 15));
    final json = jsonDecode(body);
    if (json is! Map<String, dynamic>) return null;
    final tag = json['tag_name'];
    if (tag is! String) {
      debugLog('update', 'the latest release carries no tag_name');
      return null;
    }
    final version = tag.startsWith('v') ? tag.substring(1) : tag;
    if (!isNewerVersion(appVersion, version)) {
      debugLog('update', 'up to date: running $appVersion, latest is $version');
      return null;
    }
    final url = json['html_url'];
    return UpdateInfo(
      version: version,
      url: url is String && url.startsWith('https://')
          ? url
          : 'https://github.com/$githubRepo/releases/latest',
    );
  } catch (e) {
    debugLog('update', 'check failed: ${e.runtimeType}: $e');
    return null;
  } finally {
    client.close(force: true);
  }
}

/// Downloads the published advisory list, or `null` when anything at all
/// goes wrong (offline, Pages down, a body too big to be ours).
///
/// Returns the raw JSON rather than parsed advisories so the caller can
/// cache exactly what arrived and parse it again on the next launch,
/// the way the feature-flag cache does.
Future<String?> fetchAdvisories() async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final request = await client.getUrl(Uri.parse(advisoriesUrl));
    request.headers
        .set(HttpHeaders.userAgentHeader, 'TheSimsModManager/$appVersion');
    final response = await request.close().timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      debugLog('advisories',
          'HTTP ${response.statusCode}: ${await debugBodyHead(response)}');
      return null;
    }
    if (response.contentLength > _maxAdvisoryBytes) {
      debugLog('advisories',
          'refused an answer of ${response.contentLength} bytes');
      return null;
    }
    final body = await response
        .transform(utf8.decoder)
        .join()
        .timeout(const Duration(seconds: 15));
    // contentLength is -1 when the response is chunked, so the length is
    // only really known once it has all arrived.
    if (body.length > _maxAdvisoryBytes) {
      debugLog('advisories', 'refused an answer of ${body.length} bytes');
      return null;
    }
    debugLog('advisories', 'loaded ${body.length} bytes');
    return body;
  } catch (e) {
    debugLog('advisories', 'fetch failed: ${e.runtimeType}: $e');
    return null;
  } finally {
    client.close(force: true);
  }
}

/// The OS name matching the bug-report form's dropdown options.
String get _osName {
  if (Platform.isWindows) return 'Windows';
  if (Platform.isMacOS) return 'macOS';
  return 'Linux';
}

/// New-bug-report URL with the issue form's version/OS/game fields
/// prefilled (query params match the field ids in
/// .github/ISSUE_TEMPLATE/bug_report.yml). [gameName] must be one of the
/// form's dropdown options to take effect; GitHub ignores non-matches.
Uri bugReportUrl({String? gameName}) =>
    Uri.https('github.com', '/$githubRepo/issues/new', {
      'template': 'bug_report.yml',
      'version': appVersion,
      'os': _osName,
      if (gameName != null) 'game': gameName,
    });

Uri featureRequestUrl({String? gameName}) =>
    Uri.https('github.com', '/$githubRepo/issues/new', {
      'template': 'feature_request.yml',
      if (gameName != null) 'game': gameName,
    });

Uri get wikiUrl => Uri.https('github.com', '/$githubRepo/wiki');
