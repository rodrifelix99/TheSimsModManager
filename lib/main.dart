import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:window_manager/window_manager.dart';

import 'src/core/game_registry.dart';
import 'src/games/the_sims/sims_adapters.dart';
import 'src/services/settings_store.dart';
import 'src/ui/app.dart';

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
  // To support a new game, implement a GameAdapter and add it here.
  final registry = GameRegistry(const [
    Sims1Adapter(),
    Sims2Adapter(),
    Sims3Adapter(),
    Sims4Adapter(),
  ]);
  runApp(ModManagerApp(
    registry: registry,
    settings: settings,
    translucentSidebar: translucentSidebar,
  ));
}
