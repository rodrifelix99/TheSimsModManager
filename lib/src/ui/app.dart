import 'package:flutter/material.dart';

import '../core/game_registry.dart';
import '../services/analytics.dart';
import '../services/settings_store.dart';
import 'app_controller.dart';
import 'shell.dart';

/// Smallest window (logical pixels) at which every screen lays out without
/// overflow: the library toolbar's fixed chrome (250 sidebar + 210 search +
/// view toggle + install button) and the detail view's fixed 300px left
/// column need ~900px of width, and 560px keeps the sidebar column and the
/// settings rows clear. Still fits the tightest common laptop work area
/// (1366×768 at 125% scale ≈ 1092×576 logical). window_manager enforces it
/// per-monitor-DPI; min_window_size_test.dart pins it against regressions.
const Size kMinWindowSize = Size(940, 560);

class ModManagerApp extends StatefulWidget {
  const ModManagerApp({
    super.key,
    required this.registry,
    required this.settings,
    this.translucentSidebar = false,
    this.analytics,
  });

  final GameRegistry registry;
  final SettingsStore settings;

  /// PostHog client; null (tests) means a no-op instance, so widget
  /// tests never touch the network or the preferences plugin.
  final Analytics? analytics;

  /// Whether the OS is drawing a blurred backdrop behind the window
  /// (Windows acrylic / macOS vibrancy) that the sidebar should reveal.
  final bool translucentSidebar;

  @override
  State<ModManagerApp> createState() => _ModManagerAppState();
}

class _ModManagerAppState extends State<ModManagerApp> {
  late final AppController _controller = AppController(
      registry: widget.registry,
      settings: widget.settings,
      analytics: widget.analytics);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sims Mod Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Nunito',
        colorSchemeSeed: const Color(0xFF1FBF8F),
        splashFactory: NoSplash.splashFactory,
      ),
      home: AppShell(
        controller: _controller,
        translucentSidebar: widget.translucentSidebar,
      ),
    );
  }
}
