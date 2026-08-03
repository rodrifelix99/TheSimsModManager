import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Waits for the interface to say something rather than for a round number
/// of milliseconds. Booting the shell reads a real folder off a real disk,
/// an install writes one, and a toggle renames one: a fixed wait that is
/// generous on an idle laptop is a coin toss on a CI runner, which is how
/// the Windows job came to fail on a different test every time.
///
/// Alternates real time (runAsync, where the IO actually progresses) with
/// frames (pump, where the result of it is drawn), so it returns as soon as
/// the machine is done and only gives up when the work really did fail -
/// leaving the test's own expectation to say what never arrived.
Future<void> until(WidgetTester tester, Finder finder) =>
    _untilTrue(tester, () => finder.evaluate().isNotEmpty);

/// The same wait for something leaving the screen - a warning an action was
/// meant to settle. The file is renamed before the app has been told, so
/// waiting on the disk alone would assert a frame too early.
Future<void> untilGone(WidgetTester tester, Finder finder) =>
    _untilTrue(tester, () => finder.evaluate().isEmpty);

/// The same wait, for something on disk rather than on screen: the rename
/// or the copy behind an action completes on the event loop, which only
/// runs outside the fake-async zone.
Future<void> untilExists(WidgetTester tester, FileSystemEntity entity) =>
    _untilTrue(tester, entity.existsSync);

Future<void> _untilTrue(WidgetTester tester, bool Function() done) async {
  final deadline = DateTime.now().add(const Duration(seconds: 20));
  while (DateTime.now().isBefore(deadline)) {
    if (done()) return;
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 25)));
    await tester.pump(const Duration(milliseconds: 25));
  }
}
