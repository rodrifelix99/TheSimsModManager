import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show Intl;

import '../core/game_registry.dart';
import '../services/analytics.dart';
import '../services/settings_store.dart';
import 'app_controller.dart';
import 'l10n.dart';
import 'shell.dart';

/// Smallest window (logical pixels) at which every screen lays out without
/// overflow: the library toolbar's fixed chrome (250 sidebar + 210 search +
/// view toggle + install button) and the detail view's fixed 300px left
/// column need ~900px of width, and 560px keeps the sidebar column and the
/// settings rows clear. Still fits the tightest common laptop work area
/// (1366x768 at 125% scale ~ 1092x576 logical). window_manager enforces it
/// per-monitor-DPI; min_window_size_test.dart pins it against regressions.
const Size kMinWindowSize = Size(940, 560);

class ModManagerApp extends StatefulWidget {
  const ModManagerApp({
    super.key,
    required this.registry,
    required this.settings,
    this.translucentSidebar = false,
    this.analytics,
    this.onBrightnessChanged,
  });

  final GameRegistry registry;
  final SettingsStore settings;

  /// Told which way the app just went, light or dark, whenever that
  /// changes (including on the first build). main() re-tints the OS blur
  /// behind the window with it; tests pass nothing.
  final ValueChanged<Brightness>? onBrightnessChanged;

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

  /// The language and theme currently rendered. Mirrored out of the
  /// controller rather than read from it during build: this widget sits
  /// above the whole app, and rebuilding it on every controller
  /// notification (there is one mid-first-build, from the initial library
  /// load) is both wasteful and illegal.
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;

  /// Last brightness handed to [ModManagerApp.onBrightnessChanged].
  Brightness? _reportedBrightness;

  @override
  void initState() {
    super.initState();
    _locale = _controller.locale;
    _themeMode = _modeOf(widget.settings.themeModeName);
    _controller.addListener(_syncAppearance);
  }

  static ThemeMode _modeOf(String? name) => switch (name) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  void _syncAppearance() {
    final mode = _modeOf(widget.settings.themeModeName);
    if (_controller.locale == _locale && mode == _themeMode) return;
    setState(() {
      _locale = _controller.locale;
      _themeMode = mode;
    });
  }

  /// Reports the brightness the app actually resolved to. Deferred past
  /// the frame because the listener talks to the window plugin.
  void _reportBrightness(Brightness brightness) {
    if (brightness == _reportedBrightness) return;
    _reportedBrightness = brightness;
    final notify = widget.onBrightnessChanged;
    if (notify == null) return;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => notify(brightness));
  }

  @override
  void dispose() {
    _controller.removeListener(_syncAppearance);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => L.of(context).appName,
      debugShowCheckedModeBanner: false,
      // Null means "whatever the OS says", resolved against
      // supportedLocales with English as the last resort.
      locale: _locale,
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: appSupportedLocales,
      // The chrome paints itself from GameTheme; these two exist mostly so
      // Material's own bits (popup menus, dialog scrims, text selection)
      // and, above all, `Theme.of(context).brightness` - which is what
      // picks the game palette down in the shell - come out right.
      theme: _baseTheme(Brightness.light),
      darkTheme: _baseTheme(Brightness.dark),
      themeMode: _themeMode,
      // Dates and byte counts go through intl's own formatters, which read
      // an ambient locale rather than a BuildContext; this is the one spot
      // that knows which locale actually won.
      builder: (context, child) {
        Intl.defaultLocale = Localizations.localeOf(context).toLanguageTag();
        _reportBrightness(Theme.of(context).brightness);
        return child ?? const SizedBox.shrink();
      },
      home: AppShell(
        controller: _controller,
        translucentSidebar: widget.translucentSidebar,
      ),
    );
  }

  static ThemeData _baseTheme(Brightness brightness) => ThemeData(
        useMaterial3: true,
        brightness: brightness,
        fontFamily: 'Nunito',
        // The Sims 4 accent, which is also the app's own mint.
        colorSchemeSeed: const Color(0xFF189771),
        splashFactory: NoSplash.splashFactory,
      );
}
