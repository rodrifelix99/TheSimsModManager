import 'dart:convert';
import 'dart:io';

import '../app_version.dart';

/// GitHub integration: release update checks and feedback links. Pure
/// Dart, no game or UI knowledge. Everything is best-effort — network
/// failures surface as `null`, never as exceptions.

/// The project's GitHub repository, `owner/name`.
const String githubRepo = 'rodrifelix99/TheSimsModManager';

/// A newer release published on GitHub.
class UpdateInfo {
  const UpdateInfo({required this.version, required this.url});

  /// The release's version, without the `v` tag prefix (e.g. `1.2.0`).
  final String version;

  /// The release's web page, holding the download assets.
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
    if (response.statusCode != 200) return null;
    final body = await response
        .transform(utf8.decoder)
        .join()
        .timeout(const Duration(seconds: 15));
    final json = jsonDecode(body);
    if (json is! Map<String, dynamic>) return null;
    final tag = json['tag_name'];
    if (tag is! String) return null;
    final version = tag.startsWith('v') ? tag.substring(1) : tag;
    if (!isNewerVersion(appVersion, version)) return null;
    final url = json['html_url'];
    return UpdateInfo(
      version: version,
      url: url is String && url.startsWith('https://')
          ? url
          : 'https://github.com/$githubRepo/releases/latest',
    );
  } catch (_) {
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

/// New-feature-request URL, opening the feature issue form.
Uri featureRequestUrl({String? gameName}) =>
    Uri.https('github.com', '/$githubRepo/issues/new', {
      'template': 'feature_request.yml',
      if (gameName != null) 'game': gameName,
    });

/// The project wiki (user guide & FAQ).
Uri get wikiUrl => Uri.https('github.com', '/$githubRepo/wiki');
