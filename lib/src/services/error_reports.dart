import 'package:flutter/foundation.dart';

/// Which failures are worth an entry in error tracking, and which are
/// facts about the machine the app is running on.
///
/// The bargain the rest of the app already strikes at every `catch` -
/// a locked file, a refused copy, an archive nothing can read are
/// reported to the *user* and counted, never filed as exceptions - has
/// to be struck here too, because these two hooks catch what no `catch`
/// can reach: errors raised inside the framework and inside plugins,
/// after the call that started them has returned.

/// The library [FlutterErrorDetails] carries for anything that failed to
/// decode into a picture: a missing asset, a 404, a socket that closed
/// mid-download. Set by `ImageStreamCompleter.reportError`.
const imageErrorLibrary = 'image resource service';

/// Whether [details] is a bug rather than a picture that didn't arrive.
///
/// An image reports here only when its widget has already gone - every
/// `Image` in the app carries an `errorBuilder`, and a listener that is
/// still attached handles the failure itself. So what lands here is a
/// thumbnail whose download finished after the user scrolled past it,
/// which is neither a crash nor anything the app could have done
/// differently. They were the single noisiest thing in error tracking.
bool isReportableFlutterError(FlutterErrorDetails details) =>
    details.library != imageErrorLibrary &&
    isReportableError(details.exception, details.stack);

/// Whether an uncaught async error is worth reporting.
///
/// Sound is decoration, and audioplayers raises out of its own timers
/// and stream callbacks - after the `play()` that started them has
/// returned, so no `try` around a call site can catch it. A stack with
/// audioplayers in it and nothing of ours is that: the app carried on,
/// and the worst that happened is a click nobody heard.
bool isReportableError(Object error, StackTrace? stack) {
  final frames = stack?.toString();
  if (frames == null) return true;
  return !frames.contains('package:audioplayers/') ||
      frames.contains('package:sims_mod_manager/');
}

/// How many failed pictures one run counts before it stops, the same
/// bargain the analytics service makes with exceptions: a shelf of
/// thumbnails behind a host that is down fails one card at a time, and
/// the fiftieth says nothing the first didn't.
const maxImageFailureReports = 25;

/// Where a failed picture was coming from, for the count that replaces
/// the report. Never the address itself: a catalog thumbnail's URL is
/// another project's, and a listing's is a creator's.
String imageErrorSource(Object error) =>
    '$error'.startsWith('Unable to load asset') ? 'asset' : 'network';
