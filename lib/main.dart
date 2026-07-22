import 'dart:async';

import 'package:flutter/material.dart';
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
  const windowOptions = WindowOptions(titleBarStyle: TitleBarStyle.hidden);
  unawaited(windowManager.waitUntilReadyToShow(windowOptions, () async {
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
  runApp(ModManagerApp(registry: registry, settings: settings));
}
