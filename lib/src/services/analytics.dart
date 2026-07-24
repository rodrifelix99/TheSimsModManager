import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;

import '../app_version.dart';
import 'settings_store.dart';

/// PostHog analytics, feature flags and error tracking over the plain
/// HTTP API. The official posthog_flutter SDK has no Windows/Linux
/// support, so this is a small pure-Dart client instead: events batch to
/// `/batch/`, flags come from `/flags?v=2`, and crashes go up as
/// `$exception` events.
///
/// Everything is best-effort and anonymous: failures are swallowed (the
/// app must never notice analytics being down), the distinct id is a
/// random UUID, and no mod names, file paths or anything else personal
/// ever leaves the machine. The Settings "Share anonymous usage data"
/// toggle gates every send.

/// PostHog EU Cloud ingestion host (the project lives in the EU region).
const String postHogHost = 'https://eu.i.posthog.com';

/// The project's public client token (safe to ship; it can only write
/// events, never read anything back).
const String postHogProjectToken =
    'phc_zzqKjNq5hTkeHD8LmMSzdTvtoKzD29ojo7r9zeCuVznd';

/// True only in `--release` builds (`dart.vm.product`). Debug and
/// profile runs stamp `debug_build: true` on every event, and the
/// PostHog project's "filter out internal and test users" setting drops
/// them, so development never pollutes the real numbers.
const bool _releaseBuild = bool.fromEnvironment('dart.vm.product');

/// Posts [body] as JSON to [url]; returns the response body on HTTP 2xx
/// and null on any failure. Injectable so tests never touch the network.
typedef AnalyticsPost = Future<String?> Function(
    Uri url, Map<String, Object?> body);

Future<String?> _httpPost(Uri url, Map<String, Object?> body) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  try {
    final request = await client.postUrl(url);
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));
    final response = await request.close().timeout(const Duration(seconds: 15));
    final text = await response
        .transform(utf8.decoder)
        .join()
        .timeout(const Duration(seconds: 15));
    if (response.statusCode < 200 || response.statusCode >= 300) return null;
    return text;
  } catch (_) {
    return null;
  } finally {
    client.close(force: true);
  }
}

/// One evaluated feature flag from the `/flags?v=2` response.
class _Flag {
  const _Flag({required this.enabled, this.variant, this.payloadJson});

  final bool enabled;
  final String? variant;

  /// The flag's payload as a JSON-encoded string, exactly as PostHog
  /// returns it in `metadata.payload`.
  final String? payloadJson;
}

class Analytics {
  Analytics({required SettingsStore settings, AnalyticsPost? post})
      : _settings = settings,
        _post = post ?? _httpPost;

  /// A no-op instance: never persists, never sends. The default in
  /// widget tests so they stay off the network and off the preferences
  /// plugin's analytics keys.
  Analytics.disabled()
      : _settings = null,
        _post = ((url, body) async => null);

  final SettingsStore? _settings;
  final AnalyticsPost _post;

  String _distinctId = '';
  String _sessionId = '';
  DateTime? _sessionStart;
  final List<Map<String, Object?>> _queue = [];
  Timer? _flushTimer;
  Future<void>? _inflight;
  int _exceptionCount = 0;
  Map<String, _Flag> _flags = const {};

  /// Called after a fresh flag fetch lands, so the UI can react (e.g.
  /// show a remote announcement) without polling.
  void Function()? onFlagsChanged;

  bool get enabled => _settings?.analyticsEnabled ?? false;

  /// Random anonymous id for this install (empty until [init] runs).
  String get distinctId => _distinctId;

  // ---------------------------------------------------------------- setup

  /// Loads/creates the anonymous ids, restores cached feature flags,
  /// detects install vs update vs plain launch, and kicks off a fresh
  /// flag fetch in the background. Call once at startup, before runApp.
  Future<void> init() async {
    final settings = _settings;
    if (settings == null) return;
    _distinctId = settings.analyticsDistinctId ?? _uuid(version: 4);
    if (settings.analyticsDistinctId == null) {
      await settings.setAnalyticsDistinctId(_distinctId);
    }
    _sessionId = _uuid(version: 7);
    _sessionStart = DateTime.now();
    _loadCachedFlags();
    if (!enabled) return;

    final previous = settings.lastRunVersion;
    final launches = settings.launchCount + 1;
    await settings.setLaunchCount(launches);
    if (previous == null) {
      capture('app_installed');
    } else if (previous != appVersion) {
      capture('app_updated', {'previous_version': previous});
    }
    if (previous != appVersion) await settings.setLastRunVersion(appVersion);
    capture('app_opened', {
      'launch_count': launches,
      // Person-level too, so person lists can hide dev machines; the
      // per-event debug_build property is what the project's test-user
      // filter keys on (a machine can run both build kinds).
      r'$set': {
        'app_version': appVersion,
        'os': _osName,
        'debug_build': !_releaseBuild,
      },
    });
    unawaited(refreshFlags());
    unawaited(_writeUninstallMarker());
  }

  /// Records the end of the session and pushes whatever is queued,
  /// bounded so window close never hangs on a dead network.
  Future<void> recordShutdown() async {
    final start = _sessionStart;
    if (start != null) {
      capture('app_closed', {
        'session_seconds': DateTime.now().difference(start).inSeconds,
      });
      _sessionStart = null;
    }
    try {
      await flush().timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  /// Flips the user's opt-in. Opting out announces itself first (so the
  /// opt-out rate is measurable) and then goes silent; opting back in
  /// announces after the pref flips so the event actually sends.
  Future<void> setEnabled(bool value) async {
    final settings = _settings;
    if (settings == null || value == settings.analyticsEnabled) return;
    if (!value) {
      capture('analytics_opt_out');
      try {
        await flush().timeout(const Duration(seconds: 3));
      } catch (_) {}
    }
    await settings.setAnalyticsEnabled(value);
    if (value) capture('analytics_opt_in');
    await _writeUninstallMarker();
  }

  // -------------------------------------------------------------- capture

  /// Queues [event] for delivery, stamped with the anonymous ids and app
  /// context. Fire-and-forget: batches leave on a short timer, or once
  /// enough pile up. No-op while the user has analytics switched off.
  void capture(String event, [Map<String, Object?> properties = const {}]) {
    if (!enabled || _distinctId.isEmpty) return;
    _queue.add({
      'event': event,
      'distinct_id': _distinctId,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'properties': {
        ..._superProperties,
        ..._flagProperties,
        ...properties,
      },
    });
    if (_queue.length >= 20) {
      unawaited(flush());
    } else {
      _flushTimer ??= Timer(const Duration(seconds: 2), () => flush());
    }
  }

  /// Sends everything queued to PostHog's batch endpoint. Failed batches
  /// go back in the queue (capped) for the next attempt.
  Future<void> flush() {
    // Serialize flushes so retries never reorder or duplicate events.
    final previous = _inflight ?? Future.value();
    return _inflight = previous.then((_) => _flushNow());
  }

  Future<void> _flushNow() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    if (_queue.isEmpty) return;
    final batch = List.of(_queue);
    _queue.clear();
    final response = await _post(
      Uri.parse('$postHogHost/batch/'),
      {'api_key': postHogProjectToken, 'batch': batch},
    );
    if (response == null) {
      _queue.insertAll(0, batch);
      if (_queue.length > 500) _queue.removeRange(500, _queue.length);
    }
  }

  Map<String, Object?> get _superProperties => {
        r'$app_version': appVersion,
        'app_version': appVersion,
        r'$app_name': 'TheSimsModManager',
        r'$os': _osName,
        r'$os_version': Platform.operatingSystemVersion,
        r'$locale': Platform.localeName,
        r'$session_id': _sessionId,
        'debug_build': !_releaseBuild,
      };

  /// Active flags attached to every event (PostHog's `$feature/…`
  /// convention), so any metric can be broken down by flag state.
  Map<String, Object?> get _flagProperties => {
        for (final entry in _flags.entries)
          if (entry.value.enabled)
            '\$feature/${entry.key}': entry.value.variant ?? true,
      };

  static String get _osName {
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'Mac OS X';
    return 'Linux';
  }

  // ------------------------------------------------------ error tracking

  /// Reports [error] to PostHog error tracking as an `$exception` event,
  /// with the Dart stack parsed into frames so issues group and render
  /// properly. Capped per session so a crash loop can't flood the
  /// project. [mechanism] names the hook that caught it.
  void captureException(
    Object error,
    StackTrace? stack, {
    bool handled = true,
    String mechanism = 'generic',
    Map<String, Object?> properties = const {},
  }) {
    if (!enabled || _exceptionCount >= 25) return;
    _exceptionCount++;
    var value = error.toString();
    if (value.length > 2000) value = value.substring(0, 2000);
    final frames = stack == null ? const <Map<String, Object?>>[] : _frames(stack);
    capture(r'$exception', {
      r'$exception_list': [
        {
          'type': error.runtimeType.toString(),
          'value': value,
          'mechanism': {
            'handled': handled,
            'synthetic': false,
            'type': mechanism,
          },
          if (frames.isNotEmpty)
            'stacktrace': {'type': 'raw', 'frames': frames},
        },
      ],
      r'$exception_level': handled ? 'error' : 'fatal',
      ...properties,
    });
  }

  static final _frameLine = RegExp(r'^#\d+\s+(.*?)\s+\((.*?)\)\s*$');

  /// Parses a Dart stack trace into PostHog "raw" frames, oldest first
  /// (the Sentry convention PostHog follows: the last frame is where the
  /// exception happened).
  static List<Map<String, Object?>> _frames(StackTrace stack) {
    final frames = <Map<String, Object?>>[];
    for (final line in stack.toString().split('\n')) {
      final match = _frameLine.firstMatch(line.trim());
      if (match == null) continue;
      final function = match.group(1)!;
      var location = match.group(2)!;
      int? lineno;
      int? colno;
      // Location is `uri:line:col`, but the uri itself contains colons
      // (`package:…`, `dart:async/…`), so peel numbers off the right.
      for (var i = 0; i < 2; i++) {
        final cut = location.lastIndexOf(':');
        if (cut < 0) break;
        final number = int.tryParse(location.substring(cut + 1));
        if (number == null) break;
        colno = lineno;
        lineno = number;
        location = location.substring(0, cut);
      }
      frames.add({
        'platform': 'custom',
        'lang': 'dart',
        'function': function,
        'filename': location,
        if (lineno != null) 'lineno': lineno,
        if (colno != null) 'colno': colno,
        'in_app': location.contains('sims_mod_manager') ||
            location.startsWith('file:'),
      });
      if (frames.length >= 50) break;
    }
    return frames.reversed.toList();
  }

  // -------------------------------------------------------- feature flags

  /// Fetches this install's flag values from PostHog and caches them for
  /// offline launches. Runs in the background at startup; the app uses
  /// the previous launch's values until it lands.
  Future<void> refreshFlags() async {
    final settings = _settings;
    if (settings == null || !enabled) return;
    final response = await _post(
      Uri.parse('$postHogHost/flags?v=2'),
      {'api_key': postHogProjectToken, 'distinct_id': _distinctId},
    );
    if (response == null) return;
    final parsed = _parseFlags(response);
    if (parsed == null) return;
    _flags = parsed;
    await settings.setCachedFlagsJson(response);
    onFlagsChanged?.call();
  }

  void _loadCachedFlags() {
    final cached = _settings?.cachedFlagsJson;
    if (cached == null) return;
    _flags = _parseFlags(cached) ?? const {};
  }

  static Map<String, _Flag>? _parseFlags(String body) {
    try {
      final json = jsonDecode(body);
      final flags = (json as Map<String, dynamic>)['flags'];
      if (flags is! Map<String, dynamic>) return null;
      return {
        for (final entry in flags.entries)
          if (entry.value is Map<String, dynamic>)
            entry.key: _Flag(
              enabled: entry.value['enabled'] == true,
              variant: entry.value['variant'] as String?,
              payloadJson:
                  (entry.value['metadata'] as Map<String, dynamic>?)?['payload']
                      as String?,
            ),
      };
    } catch (_) {
      return null;
    }
  }

  /// Whether flag [key] is on for this install; [fallback] applies when
  /// the flag has never been fetched (first offline launch, analytics
  /// off). Kill switches should default to true so features stay on
  /// without a network.
  bool isEnabled(String key, {bool fallback = false}) =>
      _flags[key]?.enabled ?? fallback;

  /// The multivariate variant this install got for [key], or null.
  String? variantOf(String key) => _flags[key]?.variant;

  /// The flag's JSON payload, decoded; null when off or payload-less.
  Object? payloadOf(String key) {
    final flag = _flags[key];
    if (flag == null || !flag.enabled || flag.payloadJson == null) return null;
    try {
      return jsonDecode(flag.payloadJson!);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------- uninstall marker

  /// Windows only: leaves the anonymous id where the Inno Setup
  /// uninstaller can find it, so uninstalls show up in analytics (see
  /// installer/windows/setup.iss). Removed when the user opts out, which
  /// also silences the uninstall ping.
  Future<void> _writeUninstallMarker() async {
    if (!Platform.isWindows) return;
    try {
      final appData = Platform.environment['APPDATA'];
      if (appData == null) return;
      final file = File(p.join(appData, 'TheSimsModManager', 'telemetry_id'));
      if (enabled) {
        await file.parent.create(recursive: true);
        await file.writeAsString(_distinctId);
      } else if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  // ----------------------------------------------------------------- ids

  static String _uuid({required int version}) {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    if (version == 7) {
      // UUIDv7: 48-bit unix millis prefix, so PostHog session analytics
      // can order sessions by id.
      final ms = DateTime.now().toUtc().millisecondsSinceEpoch;
      for (var i = 0; i < 6; i++) {
        bytes[i] = (ms >> (8 * (5 - i))) & 0xff;
      }
    }
    bytes[6] = (version << 4) | (bytes[6] & 0x0f);
    bytes[8] = 0x80 | (bytes[8] & 0x3f);
    final hex =
        bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }
}
