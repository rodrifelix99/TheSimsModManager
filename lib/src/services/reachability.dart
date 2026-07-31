import 'dart:io';

import '../app_version.dart';
import 'debug_log.dart';

/// Whether the services the app talks to can actually be reached from
/// this machine.
///
/// Asked rather than inferred from the country. Mainland China reaches
/// GitHub perfectly well and reaches nothing Google-hosted, so the two
/// do not stand or fall together; and a user on a VPN reaches
/// everything, from the same country. The only honest question is
/// whether the socket opens here, now.
///
/// Any HTTP answer counts as reached, whatever the status. The question
/// is whether the host is there, not whether it liked the request:
/// Firestore answers 404 to the HEAD below because it does not serve
/// HEAD on that path, and that refusal is itself proof it was reached.
/// What blocking looks like is no answer at all - a reset connection or
/// a timeout - which is what the probe is actually testing for.

/// The Exchange: the catalog and the file downloads. One address stands
/// for both, and for the storage bucket beside it - they are the same
/// Google front and have never been blocked apart.
const String shopProbeUrl = 'https://firestore.googleapis.com/v1/projects/'
    'thesimsmodmanager/databases/(default)/documents/mods?pageSize=1';

/// The website: the creator portal, every listing's shareable page, and
/// the advisory feed.
const String siteProbeUrl =
    'https://thesimsmodmanager.web.app/data/advisories.json';

/// Where a GitHub release's files actually come from, which is not
/// github.com and does not share its fate: from mainland China the API
/// answers fine and this host is the one that doesn't, which is why it
/// is asked separately rather than inferred from the rest.
const String downloadsProbeUrl = 'https://objects.githubusercontent.com/';

/// What answered, what didn't, and how long each took.
class Reachability {
  const Reachability({
    required this.shop,
    required this.site,
    required this.downloads,
    this.mirror,
    this.millis = const {},
  });

  /// The Exchange: its catalog, its downloads, and the update poll.
  final bool shop;

  /// The website the portal nudge and the shareable links open.
  final bool site;

  /// Release files, straight from GitHub. This is the one that decides
  /// whether a download needs rerouting at all: it stays the way every
  /// download goes unless it is known not to work.
  final bool downloads;

  /// The configured download mirror, or null when there is none to ask
  /// about. False means a machine that cannot reach GitHub's files
  /// cannot reach the way around them either, and sending it there
  /// would only swap one dead link for another.
  final bool? mirror;

  /// How long each host took to answer, keyed by the names below.
  /// Deliberately outside [==]: it differs on every launch, and a
  /// millisecond is not the answer changing.
  final Map<String, int> millis;

  /// What the app assumes before it has asked, and whenever the probe
  /// cannot run at all. Everything on: the same bargain the feature
  /// flags make, so a machine that never got an answer keeps its
  /// features rather than losing them to a question nobody answered.
  static const Reachability unknown =
      Reachability(shop: true, site: true, downloads: true);

  @override
  bool operator ==(Object other) =>
      other is Reachability &&
      other.shop == shop &&
      other.site == site &&
      other.downloads == downloads &&
      other.mirror == mirror;

  @override
  int get hashCode => Object.hash(shop, site, downloads, mirror);

  @override
  String toString() => 'Reachability(shop: $shop, site: $site, '
      'downloads: $downloads, mirror: $mirror)';
}

/// The blocked shapes worth developing against, for the debug picker in
/// Settings. Every branch the app takes on reachability is reachable
/// from one of these, which the machine writing the code cannot
/// otherwise get to: the answers here are all `true` outside the
/// countries this was written for, so the blocked half of it would only
/// ever be seen by the people it fails.
///
/// [id] is what the preference stores, [label] is what the picker draws.
const List<({String id, String label, Reachability state})>
    debugReachabilityScenarios = [
  (
    id: 'blocked',
    label: 'Everything blocked',
    state:
        Reachability(shop: false, site: false, downloads: false, mirror: false),
  ),
  // What mainland China actually looks like: api.github.com answers, so
  // the update check still finds a release, and nothing Google-hosted
  // does - which is The Exchange, the website and the release files.
  (
    id: 'china',
    label: 'Google-hosted blocked (China)',
    state:
        Reachability(shop: false, site: false, downloads: false, mirror: true),
  ),
  (
    id: 'downloads',
    label: 'Release files blocked, mirror answers',
    state: Reachability(shop: true, site: true, downloads: false, mirror: true),
  ),
  // The case the mirror cannot rescue, where the release page stays the
  // answer because a dead mirror is no better than a dead host.
  (
    id: 'nomirror',
    label: 'Release files and mirror blocked',
    state:
        Reachability(shop: true, site: true, downloads: false, mirror: false),
  ),
];

/// The scenario [id] names, or null for anything else - including null
/// itself, which is the picker being off and the network being asked.
Reachability? debugReachabilityFor(String? id) {
  for (final scenario in debugReachabilityScenarios) {
    if (scenario.id == id) return scenario.state;
  }
  return null;
}

/// Whether [url]'s host answers at all within [timeout], and how long it
/// took. The time is worth having even for a host that answered: a
/// mirror that takes eight seconds to say hello is one people give up on.
Future<(bool, int)> _answers(String url, Duration timeout) async {
  final client = HttpClient()..connectionTimeout = timeout;
  final started = DateTime.now();
  int elapsed() => DateTime.now().difference(started).inMilliseconds;
  try {
    final request = await client.headUrl(Uri.parse(url));
    request.headers
        .set(HttpHeaders.userAgentHeader, 'TheSimsModManager/$appVersion');
    final response = await request.close().timeout(timeout);
    await response.drain<void>();
    return (true, elapsed());
  } catch (e) {
    debugLog('reachability', '$url: ${e.runtimeType}: $e');
    return (false, elapsed());
  } finally {
    client.close(force: true);
  }
}

/// Asks every service whether it can be reached, [mirrorBase] included
/// when one is configured. Never throws, and never takes longer than
/// [timeout]: the probes run together, and the launch path that calls
/// this does not wait on it.
Future<Reachability> probeReachability(
  String? mirrorBase, {
  Duration timeout = const Duration(seconds: 6),
}) async {
  // A test would otherwise open real sockets, which the fake-async zone
  // widget tests run in never lets finish.
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    return Reachability.unknown;
  }
  final targets = <String, String>{
    'shop': shopProbeUrl,
    'site': siteProbeUrl,
    'downloads': downloadsProbeUrl,
    if (mirrorBase != null) 'mirror': mirrorBase,
  };
  final answers = await Future.wait(
      [for (final url in targets.values) _answers(url, timeout)]);
  final byName = Map.fromIterables(targets.keys, answers);
  final result = Reachability(
    shop: byName['shop']!.$1,
    site: byName['site']!.$1,
    downloads: byName['downloads']!.$1,
    mirror: byName['mirror']?.$1,
    millis: {for (final e in byName.entries) e.key: e.value.$2},
  );
  debugLog('reachability', '$result ${result.millis}');
  return result;
}
