import 'package:flutter/material.dart';

import '../core/game_registry.dart';
import '../services/settings_store.dart';
import 'app_controller.dart';
import 'shell.dart';

class ModManagerApp extends StatefulWidget {
  const ModManagerApp({
    super.key,
    required this.registry,
    required this.settings,
    this.translucentSidebar = false,
  });

  final GameRegistry registry;
  final SettingsStore settings;

  /// Whether the OS is drawing a blurred backdrop behind the window
  /// (Windows acrylic / macOS vibrancy) that the sidebar should reveal.
  final bool translucentSidebar;

  @override
  State<ModManagerApp> createState() => _ModManagerAppState();
}

class _ModManagerAppState extends State<ModManagerApp> {
  late final AppController _controller =
      AppController(registry: widget.registry, settings: widget.settings);

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
