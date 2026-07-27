import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

/// Console notes for the services that answer `null` instead of throwing.
/// Being best-effort is right for the shipped app - the update check, the
/// advisory feed and The Exchange must never cost the user a screen - but
/// it leaves nothing to work from while developing: a sandboxed macOS
/// debug build with no route to the network looked exactly like an empty
/// catalog. Release builds stay silent.

/// Silent in release, and silent under `flutter test` as well: there the
/// fetches answer from the stub client rather than the network, so the
/// notes say nothing, and reading a body we are abandoning would add a
/// timer inside the fake-async zone that can outlive the test that
/// started it.
final bool _quiet =
    !kDebugMode || Platform.environment.containsKey('FLUTTER_TEST');

/// One line, tagged by the feature it came from (`[shop]`, `[update]`).
void debugLog(String tag, String reason) {
  if (!_quiet) debugPrint('[$tag] $reason');
}

/// As much of [body] as is worth reading in a console.
String debugHead(String body) =>
    body.length > 400 ? '${body.substring(0, 400)}...' : body;

/// The head of a response body. The interesting failures explain
/// themselves in there - Firestore names a missing index, GitHub names
/// the rate limit, PostHog names a rejected token - which is worth more
/// than the status code alone. Consumes the response, so only call it on
/// one being abandoned.
Future<String> debugBodyHead(HttpClientResponse response) async {
  if (_quiet) return '';
  try {
    return debugHead(await response
        .transform(utf8.decoder)
        .join()
        .timeout(const Duration(seconds: 5)));
  } catch (e) {
    return '<body unreadable: $e>';
  }
}
