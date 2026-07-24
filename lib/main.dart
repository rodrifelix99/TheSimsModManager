import 'dart:async';
import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
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
  unawaited(windowManager.waitUntilReadyToShow(windowOptions, () async {
    if (translucentSidebar) {
      await Window.setEffect(
        effect: Platform.isMacOS ? WindowEffect.sidebar : WindowEffect.acrylic,
        // Milky base tint so the blurred backdrop stays light-theme friendly.
        color: const Color(0x66FFFFFF),
        dark: false,
      );
    }
    await windowManager.show();
    await windowManager.focus();
  }));
  final settings = await SettingsStore.load();
  final analytics = Analytics(settings: settings);
  await analytics.init();
  // Crash reporting: framework build/layout errors and uncaught async
  // errors both go to PostHog error tracking, then behave as before
  // (except uncaught async errors no longer kill the app — they're
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
  ));
}
