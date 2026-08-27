import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sims_mod_manager/src/services/error_reports.dart';

/// A stack as the two hooks in main.dart get one: text, with the package
/// each frame came from in it.
StackTrace _stack(List<String> frames) => StackTrace.fromString(
    [for (final frame in frames) '#0      $frame'].join('\n'));

void main() {
  group('framework errors', () {
    test('a picture that never arrived is not a bug', () {
      // Every Image in the app carries an errorBuilder, so one only
      // reports here after its widget has gone - a thumbnail whose
      // download finished behind a user who had already scrolled past.
      expect(
          isReportableFlutterError(FlutterErrorDetails(
            exception: Exception('HTTP request failed, statusCode: 404'),
            library: imageErrorLibrary,
          )),
          isFalse);
    });

    test('anything else still is', () {
      expect(
          isReportableFlutterError(FlutterErrorDetails(
            exception: Exception('A RenderFlex overflowed'),
            library: 'rendering library',
          )),
          isTrue);
    });

    test('an asset is told apart from an address', () {
      expect(imageErrorSource('Unable to load asset: "assets/x.png".'),
          'asset');
      expect(imageErrorSource('HTTP request failed, statusCode: 404, https://…'),
          'network');
    });
  });

  group('uncaught async errors', () {
    test('sound raising out of its own timers is not a bug', () {
      expect(
          isReportableError(
              Exception('AudioPlayer has been disposed'),
              _stack([
                'AudioPlayer.dispose (package:audioplayers/src/audioplayer.dart:499)',
                'AudioPlayer.state= (package:audioplayers/src/audioplayer.dart:76)',
              ])),
          isFalse);
    });

    test('but a fault of ours inside it is', () {
      expect(
          isReportableError(
              StateError('bad state'),
              _stack([
                'Sfx.play (package:sims_mod_manager/src/services/sfx.dart:72)',
                'AudioPlayer.play (package:audioplayers/src/audioplayer.dart:120)',
              ])),
          isTrue);
    });

    test('an error with no stack at all is reported', () {
      expect(isReportableError(StateError('bad state'), null), isTrue);
    });
  });
}
