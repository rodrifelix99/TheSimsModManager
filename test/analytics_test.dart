import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/app_version.dart';
import 'package:sims_mod_manager/src/services/analytics.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';

/// Records every outgoing request instead of touching the network.
class RecordingPost {
  /// (url, body, delivered): delivered is false for calls that "failed".
  final List<(Uri, Map<String, Object?>, bool)> calls = [];
  String? flagsResponse;
  bool fail = false;

  Future<String?> call(Uri url, Map<String, Object?> body) async {
    calls.add((url, body, !fail));
    if (fail) return null;
    if (url.path.contains('flags')) return flagsResponse;
    return '{"status": 1}';
  }

  /// Every event successfully delivered across batch requests, in order.
  List<Map<String, dynamic>> get events => [
        for (final call in calls)
          if (call.$3 && call.$1.path.contains('batch'))
            ...(call.$2['batch'] as List).cast<Map<String, dynamic>>(),
      ];

  List<String> get eventNames =>
      [for (final e in events) e['event'] as String];
}

Future<SettingsStore> freshStore(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return SettingsStore.load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('first launch records install, updates record the version jump',
      () async {
    final settings = await freshStore({});
    final post = RecordingPost();
    final analytics = Analytics(settings: settings, post: post.call);
    await analytics.init();
    await analytics.flush();
    expect(post.eventNames, containsAll(['app_installed', 'app_opened']));
    expect(post.eventNames, isNot(contains('app_updated')));
    expect(settings.lastRunVersion, appVersion);
    expect(settings.launchCount, 1);

    // Same version launching again: a plain open, no install/update.
    final post2 = RecordingPost();
    final again = Analytics(settings: settings, post: post2.call);
    await again.init();
    await again.flush();
    expect(post2.eventNames, ['app_opened']);
    expect(settings.launchCount, 2);

    // A version jump: app_updated names the version it came from.
    final upgraded = await freshStore({
      'analytics.lastRunVersion': '0.9.0',
      'analytics.launchCount': 5,
    });
    final post3 = RecordingPost();
    final updated = Analytics(settings: upgraded, post: post3.call);
    await updated.init();
    await updated.flush();
    expect(post3.eventNames, ['app_updated', 'app_opened']);
    final update = post3.events.first;
    expect((update['properties'] as Map)['previous_version'], '0.9.0');
    expect(upgraded.lastRunVersion, appVersion);
  });

  test('events carry the token, a stable anonymous id and app context',
      () async {
    final settings = await freshStore({});
    final post = RecordingPost();
    final analytics = Analytics(settings: settings, post: post.call);
    await analytics.init();
    analytics.capture('mod_installed', {'files': 2});
    await analytics.flush();

    final batchCall =
        post.calls.firstWhere((c) => c.$1.path.contains('batch'));
    expect(batchCall.$2['api_key'], postHogProjectToken);
    expect(batchCall.$1.toString(), startsWith(postHogHost));

    final event = post.events.firstWhere((e) => e['event'] == 'mod_installed');
    expect(event['distinct_id'], analytics.distinctId);
    expect(analytics.distinctId, hasLength(36)); // a UUID, not empty
    final props = event['properties'] as Map;
    expect(props['app_version'], appVersion);
    expect(props[r'$os'], isNotEmpty);
    expect(props[r'$session_id'], hasLength(36));
    expect(props['files'], 2);
    // flutter test is never a --release build, so this run must mark
    // itself as a test user for PostHog's internal-user filter.
    expect(props['debug_build'], isTrue);

    // The id persists: a new instance keeps reporting as the same install.
    final analytics2 = Analytics(settings: settings, post: post.call);
    await analytics2.init();
    expect(analytics2.distinctId, analytics.distinctId);
  });

  test('opting out silences everything', () async {
    final settings = await freshStore({'analyticsEnabled': false});
    final post = RecordingPost();
    final analytics = Analytics(settings: settings, post: post.call);
    await analytics.init();
    analytics.capture('mod_installed');
    analytics.captureException(StateError('boom'), StackTrace.current);
    await analytics.flush();
    expect(post.calls, isEmpty);
    expect(settings.launchCount, 0); // not even counted
  });

  test('feature flags parse, gate, expose payloads and survive offline',
      () async {
    final settings = await freshStore({});
    final post = RecordingPost()
      ..flagsResponse = '{"flags": {'
          '"update-check": {"enabled": true, "variant": null, '
          '"metadata": {"payload": null}},'
          '"artwork-scan": {"enabled": false},'
          '"announcement": {"enabled": true, "variant": null, "metadata": '
          '{"payload": "{\\"id\\": \\"a1\\", \\"message\\": \\"Hello\\"}"}}'
          '}}';
    final analytics = Analytics(settings: settings, post: post.call);
    await analytics.init();
    await analytics.refreshFlags();

    expect(analytics.isEnabled('update-check'), isTrue);
    expect(analytics.isEnabled('artwork-scan', fallback: true), isFalse);
    expect(analytics.isEnabled('never-fetched', fallback: true), isTrue);
    expect(analytics.isEnabled('never-fetched'), isFalse);
    final payload = analytics.payloadOf('announcement') as Map;
    expect(payload['id'], 'a1');
    expect(payload['message'], 'Hello');
    expect(analytics.payloadOf('artwork-scan'), isNull);

    // Enabled flags ride along on events as $feature/… properties.
    analytics.capture('ping');
    await analytics.flush();
    final event = post.events.firstWhere((e) => e['event'] == 'ping');
    expect((event['properties'] as Map)[r'$feature/update-check'], true);

    // A later launch with the network down uses the cached values.
    final offline = RecordingPost()..fail = true;
    final analytics2 = Analytics(settings: settings, post: offline.call);
    await analytics2.init();
    expect(analytics2.isEnabled('update-check'), isTrue);
    expect(analytics2.isEnabled('artwork-scan', fallback: true), isFalse);
  });

  test('captureException builds a PostHog error event with parsed frames',
      () async {
    final settings = await freshStore({});
    final post = RecordingPost();
    final analytics = Analytics(settings: settings, post: post.call);
    await analytics.init();

    analytics.captureException(
      const FormatException('bad bytes'),
      StackTrace.current,
      handled: false,
      mechanism: 'test',
    );
    await analytics.flush();

    final event = post.events.firstWhere((e) => e['event'] == r'$exception');
    final props = event['properties'] as Map;
    expect(props[r'$exception_level'], 'fatal');
    final exception = (props[r'$exception_list'] as List).single as Map;
    expect(exception['type'], 'FormatException');
    expect(exception['value'], contains('bad bytes'));
    expect((exception['mechanism'] as Map)['handled'], false);
    expect((exception['mechanism'] as Map)['type'], 'test');
    final frames =
        ((exception['stacktrace'] as Map)['frames'] as List).cast<Map>();
    expect(frames, isNotEmpty);
    // Every frame follows PostHog's custom-platform schema; this test
    // file must appear as an in-app frame.
    for (final frame in frames) {
      expect(frame['platform'], 'custom');
      expect(frame['lang'], 'dart');
      expect(frame['function'], isNotEmpty);
    }
    expect(
      frames.where((f) =>
          f['filename'].toString().contains('analytics_test.dart') &&
          f['lineno'] is int),
      isNotEmpty,
    );
  });

  test('failed batches are kept and retried, never duplicated', () async {
    final settings = await freshStore({});
    final post = RecordingPost();
    final analytics = Analytics(settings: settings, post: post.call);
    await analytics.init();
    await analytics.flush();
    final delivered = post.events.length;

    post.fail = true;
    analytics.capture('mod_installed');
    await analytics.flush();
    expect(post.events.length, delivered); // nothing landed

    post.fail = false;
    await analytics.flush();
    final names = post.eventNames.where((n) => n == 'mod_installed');
    expect(names.length, 1);
  });

  test('a disabled instance is inert', () async {
    final analytics = Analytics.disabled();
    await analytics.init();
    analytics.capture('anything');
    await analytics.flush();
    expect(analytics.enabled, isFalse);
    expect(analytics.isEnabled('update-check', fallback: true), isTrue);
  });
}
