import 'dart:async';
import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/date_symbol_data_local.dart' show initializeDateFormatting;
import 'package:window_manager/window_manager.dart';

import 'src/core/game_registry.dart';
import 'src/games/simcity/simcity_adapters.dart';
import 'src/games/the_sims/sims_adapters.dart';
import 'src/services/analytics.dart';
import 'src/services/error_reports.dart';
import 'src/services/settings_store.dart';
import 'src/services/url_scheme.dart';
import 'src/ui/app.dart';

/// Flushes queued analytics before the window actually closes. Requires
/// windowManager.setPreventClose(true); destroy() always runs, so a dead
/// network can never keep the window open.
class _FlushOnClose with WindowListener {
  _FlushOnClose(this.analytics);

  final Analytics analytics;
  bool _closing = false;

  @override
  Future<void> onWindowClose() async {
    if (_closing) return;
    _closing = true;
    // Hide before flushing, not after: the shutdown event costs a cold TLS
    // handshake to PostHog, and preventClose keeps the window on screen for
    // as long as that takes. Hidden, the app reads as closed immediately and
    // the process goes away a moment later.
    try {
      await windowManager.hide();
    } catch (_) {}
    try {
      await analytics.recordShutdown();
    } catch (_) {}
    await windowManager.destroy();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Month names for every shipped language; without this intl only knows
  // how to write a date in English.
  await initializeDateFormatting();
  // Hide the native title bar so the app's themed chrome extends all the way
  // to the top edge; AppShell overlays its own drag strip + caption buttons.
  await windowManager.ensureInitialized();
  // OS-level blur behind the window (Windows acrylic / macOS vibrancy); the
  // shell keeps the content area opaque so only the sidebar reads as glass.
  final translucentSidebar = Platform.isWindows || Platform.isMacOS;
  if (translucentSidebar) {
    await Window.initialize();
  }
  // Minimum size is in logical pixels; window_manager rescales it for the
  // monitor's DPI, so the floor holds on any display scale.
  const windowOptions = WindowOptions(
    titleBarStyle: TitleBarStyle.hidden,
    minimumSize: kMinWindowSize,
  );
  final settings = await SettingsStore.load();
  unawaited(windowManager.waitUntilReadyToShow(windowOptions, () async {
    // Before show(), not after the first frame: the window opens with its
    // backdrop already in place, and on macOS the vibrancy view keeps the
    // opaque material it was born with until something sets one.
    if (translucentSidebar) {
      await _setWindowEffect(_startingBrightness(settings));
    }
    // minimumSize only constrains resizing: on macOS it becomes
    // setContentMinSize, which leaves a window that already opened
    // smaller exactly where it is. The macOS runner takes its frame from
    // the nib - 800x600, Flutter's stock size - so the app opened 140px
    // under its own floor and the library header overflowed there, on a
    // width no test covers because nothing was supposed to reach it.
    // Grow-only: a window the user pulled wider stays wider.
    final size = await windowManager.getSize();
    if (size.width < kMinWindowSize.width ||
        size.height < kMinWindowSize.height) {
      await windowManager.setSize(Size(
        size.width < kMinWindowSize.width ? kMinWindowSize.width : size.width,
        size.height < kMinWindowSize.height
            ? kMinWindowSize.height
            : size.height,
      ));
      await windowManager.center();
    }
    await windowManager.show();
    await windowManager.focus();
  }));
  final analytics = Analytics(settings: settings);
  await analytics.init();
  // Crash reporting: framework build/layout errors and uncaught async
  // errors both go to PostHog error tracking, then behave as before
  // (except uncaught async errors no longer kill the app - they're
  // logged and swallowed, which is kinder to a desktop user mid-task).
  // Pictures fail in crowds - a shelf of thumbnails whose host is down
  // is one failure per card, and the machine that reported this loudest
  // sent twenty-five in half an hour - so they are counted like
  // exceptions are: up to a point, and then not at all.
  var imageFailures = 0;
  FlutterError.onError = (details) {
    if (details.library == imageErrorLibrary) {
      // A picture that never arrived is counted rather than reported:
      // see [isReportableFlutterError] for why none of these is a bug.
      if (imageFailures++ < maxImageFailureReports) {
        analytics.capture('image_load_failed',
            {'source': imageErrorSource(details.exception)});
      }
    } else if (isReportableFlutterError(details)) {
      analytics.captureException(details.exception, details.stack,
          handled: false, mechanism: 'FlutterError');
    }
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    if (isReportableError(error, stack)) {
      analytics.captureException(error, stack,
          handled: false, mechanism: 'PlatformDispatcher');
    }
    debugPrint('Uncaught error: $error\n$stack');
    return true;
  };
  // Intercept close so the last events (app_closed) actually leave.
  await windowManager.setPreventClose(true);
  windowManager.addListener(_FlushOnClose(analytics));
  // To support a new game, implement a GameAdapter and add it here.
  // Franchise by franchise, each in release order; the sidebar groups on
  // Game.series and keeps this order inside a group. The Sims leads
  // because that is the order its users have always seen, and a new
  // franchise arriving must not rearrange somebody's sidebar.
  final registry = GameRegistry(const [
    Sims1Adapter(),
    Sims2Adapter(),
    Sims3Adapter(),
    SimsMedievalAdapter(),
    Sims4Adapter(),
    SimCity3000Adapter(),
    SimCity4Adapter(),
    SimCitySocietiesAdapter(),
    SimCity2013Adapter(),
  ]);
  runApp(ModManagerApp(
    registry: registry,
    settings: settings,
    translucentSidebar: translucentSidebar,
    analytics: analytics,
    deepLinks: _deepLinks(),
    // Set from the app rather than up front, because the OS blur has to be
    // re-tinted whenever the theme flips: a milky white backdrop behind a
    // dark sidebar washes it straight back out.
    onBrightnessChanged: translucentSidebar ? _setWindowEffect : null,
  ));
  // After runApp, never in front of it: claiming a URL scheme is worth a
  // registry read, not a slower first frame.
  unawaited(ensureUrlSchemeRegistered());
}

/// Every `simsmodmanager://` address the OS hands over, cold start
/// included. The app widget takes a plain stream rather than the plugin,
/// so nothing below main() knows a plugin exists and widget tests can be
/// the platform themselves.
Stream<Uri> _deepLinks() {
  // Not a broadcast controller on purpose: it buffers whatever arrives
  // before the app subscribes, which is exactly the link that launched it.
  final links = StreamController<Uri>();
  final appLinks = AppLinks();
  // Not awaited - a platform round trip must not sit in front of the first
  // frame, and a link is worth nothing until there is a window to show it.
  unawaited(appLinks.getInitialLink().then((uri) {
    if (uri != null) links.add(uri);
  }).catchError((_) {}));
  appLinks.uriLinkStream.listen((uri) {
    // The app is already running and something else has the foreground.
    unawaited(_raiseWindow());
    links.add(uri);
  }, onError: (_) {});
  return links.stream;
}

/// Brings the window back from wherever the user left it. Best-effort:
/// Windows may refuse the foreground to a process that does not have it,
/// in which case the taskbar button flashes instead, which is the OS's
/// answer and not ours to argue with.
Future<void> _raiseWindow() async {
  try {
    if (await windowManager.isMinimized()) await windowManager.restore();
    await windowManager.show();
    await windowManager.focus();
  } catch (_) {}
}

/// Which way the app will resolve before it has drawn anything, so the
/// backdrop is right on the very first frame.
Brightness _startingBrightness(SettingsStore settings) =>
    switch (settings.themeModeName) {
      'light' => Brightness.light,
      'dark' => Brightness.dark,
      _ => PlatformDispatcher.instance.platformBrightness,
    };

Future<void> _setWindowEffect(Brightness brightness) async {
  final dark = brightness == Brightness.dark;
  try {
    // macOS ignores `color` and `dark` here - it only swaps the material,
    // and how that material frosts is decided by the window's own
    // appearance. Without this the sidebar reads as a light pane of glass
    // under a dark theme, or the reverse.
    if (Platform.isMacOS) await Window.overrideMacOSBrightness(dark: dark);
    await Window.setEffect(
      effect: Platform.isMacOS ? WindowEffect.sidebar : WindowEffect.acrylic,
      color: dark ? const Color(0x33000000) : const Color(0x66FFFFFF),
      dark: dark,
    );
  } catch (_) {
    // Purely decorative; a platform that refuses just keeps the plain
    // window it already has.
  }
}
