import 'dart:async';
import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/date_symbol_data_local.dart' show initializeDateFormatting;
import 'package:window_manager/window_manager.dart';

import 'src/core/game_registry.dart';
import 'src/games/the_sims/sims_adapters.dart';
import 'src/services/analytics.dart';
import 'src/services/settings_store.dart';
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
    await windowManager.show();
    await windowManager.focus();
  }));
  final analytics = Analytics(settings: settings);
  await analytics.init();
  // Crash reporting: framework build/layout errors and uncaught async
  // errors both go to PostHog error tracking, then behave as before
  // (except uncaught async errors no longer kill the app - they're
  // logged and swallowed, which is kinder to a desktop user mid-task).
  FlutterError.onError = (details) {
    analytics.captureException(details.exception, details.stack,
        handled: false, mechanism: 'FlutterError');
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    analytics.captureException(error, stack,
        handled: false, mechanism: 'PlatformDispatcher');
    debugPrint('Uncaught error: $error\n$stack');
    return true;
  };
  // Intercept close so the last events (app_closed) actually leave.
  await windowManager.setPreventClose(true);
  windowManager.addListener(_FlushOnClose(analytics));
  // To support a new game, implement a GameAdapter and add it here.
  final registry = GameRegistry(const [
    Sims1Adapter(),
    Sims2Adapter(),
    Sims3Adapter(),
    SimsMedievalAdapter(),
    Sims4Adapter(),
  ]);
  runApp(ModManagerApp(
    registry: registry,
    settings: settings,
    translucentSidebar: translucentSidebar,
    analytics: analytics,
    // Set from the app rather than up front, because the OS blur has to be
    // re-tinted whenever the theme flips: a milky white backdrop behind a
    // dark sidebar washes it straight back out.
    onBrightnessChanged: translucentSidebar ? _setWindowEffect : null,
  ));
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
