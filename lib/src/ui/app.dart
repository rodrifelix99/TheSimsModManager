import 'dart:async' show StreamSubscription;
import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show Intl;

import '../core/deep_link.dart';
import '../core/game_registry.dart';
import '../core/whats_new.dart';
import '../services/analytics.dart';
import '../services/mod_shop.dart';
import '../services/reachability.dart';
import '../services/settings_store.dart';
import 'app_controller.dart';
import 'game_theme.dart';
import 'l10n.dart';
import 'shell.dart';

/// Smallest window (logical pixels) at which every screen lays out without
/// overflow: the library toolbar's fixed chrome (250 sidebar + 210 search +
/// view toggle + install button) and the detail view's fixed 300px left
/// column need ~900px of width.
///
/// The height is set by the sidebar, which is a column of fixed-height
/// things: five game rows, two nav buttons, The Exchange card and the
/// storage card need ~700px once the disk bar has filled in, and the
/// update banner wants ~70 more on top of that. 720 covers the everyday
/// case with room; the banner (and the sixth game, when SimCity lands)
/// is covered by the sidebar scrolling rather than by growing this
/// number, because a minimum much past 720 stops fitting a 768-tall
/// laptop screen at all. window_manager enforces it per-monitor-DPI;
/// min_window_size_test.dart pins it against regressions - including
/// against the full five-game sidebar, which is what the one-game tests
/// used to miss.
const Size kMinWindowSize = Size(940, 720);

class ModManagerApp extends StatefulWidget {
  const ModManagerApp({
    super.key,
    required this.registry,
    required this.settings,
    this.translucentSidebar = false,
    this.analytics,
    this.fetchShop,
    this.fetchListing,
    this.downloadShop,
    this.reportDownload,
    this.pickSavePath,
    this.deepLinks,
    this.onBrightnessChanged,
    this.checkElevated,
    this.probeServices,
    this.whatsNewTable,
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

  /// The Exchange's listing fetch and file download; null means the real
  /// network. Injectable for the same reason as [analytics].
  final Future<List<ShopMod>?> Function()? fetchShop;
  final Future<ShopMod?> Function(String id)? fetchListing;
  final Future<void> Function(ShopMod mod, File destination,
      {void Function(int received, int total)? onProgress})? downloadShop;

  /// Reports a finished install so the listing's creator sees it in their
  /// download count; null means the real endpoint. Injectable so tests
  /// count nothing.
  final Future<void> Function(String id)? reportDownload;

  /// Where to put a listing's file when it is downloaded rather than
  /// installed; null means the system's Save-as dialog. Injectable so
  /// tests answer without one opening.
  final Future<String?> Function(String suggestedName)? pickSavePath;

  /// Addresses the OS handed the app, one per `simsmodmanager://` link
  /// opened. main() feeds this from the platform; tests feed it from a
  /// StreamController, which is the whole reason it is a plain Stream and
  /// not a plugin: nothing below here knows a plugin exists.
  final Stream<Uri>? deepLinks;

  /// Whether the OS is drawing a blurred backdrop behind the window
  /// (Windows acrylic / macOS vibrancy) that the sidebar should reveal.
  final bool translucentSidebar;

  /// Whether the app has administrator rights; null means ask the OS.
  /// Injectable so a test can have the elevated case without an elevated
  /// runner, which is the only way to cover it at all.
  final Future<bool> Function()? checkElevated;

  /// Whether our own services answer from this machine; null means
  /// really ask them. Injectable so a test can have the blocked case,
  /// which is otherwise only reachable from inside a country.
  final Future<Reachability> Function(String? mirrorBase)? probeServices;

  /// The what's-new table, for tests that need one independent of the
  /// release this build is.
  final List<WhatsNewEntry>? whatsNewTable;

  @override
  State<ModManagerApp> createState() => _ModManagerAppState();
}

class _ModManagerAppState extends State<ModManagerApp> {
  late final AppController _controller = AppController(
      registry: widget.registry,
      settings: widget.settings,
      analytics: widget.analytics,
      fetchShop: widget.fetchShop,
      fetchListing: widget.fetchListing,
      downloadShop: widget.downloadShop,
      reportDownload: widget.reportDownload,
      pickSavePath: widget.pickSavePath,
      checkElevated: widget.checkElevated,
      probeServices: widget.probeServices,
      whatsNewTable: widget.whatsNewTable);

  /// The language and theme currently rendered. Mirrored out of the
  /// controller rather than read from it during build: this widget sits
  /// above the whole app, and rebuilding it on every controller
  /// notification (there is one mid-first-build, from the initial library
  /// load) is both wasteful and illegal.
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;

  /// The theme name the Material seed below was built from. Kept beside
  /// the two above because it is the same kind of fact: a rebuild of
  /// MaterialApp itself rather than of anything under it.
  String? _appTheme;

  /// Last brightness handed to [ModManagerApp.onBrightnessChanged].
  Brightness? _reportedBrightness;

  StreamSubscription<Uri>? _links;

  /// The last address acted on, and when. The platform can hand the same
  /// link over twice (the one the app launched with can also arrive on
  /// the stream), and a double-clicked button on a web page is nobody's
  /// intent either.
  Uri? _lastLink;
  DateTime _lastLinkAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _locale = _controller.locale;
    _themeMode = _modeOf(widget.settings.themeModeName);
    _appTheme = _controller.appTheme;
    _controller.addListener(_syncAppearance);
    // Subscribed past the first frame, like _reportBrightness: a link that
    // launched the app is already waiting in the stream, and acting on it
    // during the first build would notify the controller mid-build. The
    // stream is not a broadcast one, so nothing is lost by waiting.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _links = widget.deepLinks?.listen(_openLink, onError: (_) {});
    });
  }

  /// One `simsmodmanager://` address, from a web page and therefore never
  /// trusted: anything that is not exactly a link we publish is dropped
  /// without a word. This only ever calls the controller, so nothing above
  /// MaterialApp rebuilds.
  void _openLink(Uri uri) {
    final now = DateTime.now();
    if (uri == _lastLink && now.difference(_lastLinkAt).inSeconds < 2) return;
    _lastLink = uri;
    _lastLinkAt = now;
    switch (parseDeepLink(uri)) {
      case ModListingLink(:final listingId):
        _controller.openShopListingById(listingId);
      case null:
        // No id in the report: it is not ours, so it is not ours to log.
        _controller.analytics.capture('deep_link_failed', {'reason': 'invalid'});
    }
  }

  static ThemeMode _modeOf(String? name) => switch (name) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  void _syncAppearance() {
    final mode = _modeOf(widget.settings.themeModeName);
    if (_controller.locale == _locale &&
        mode == _themeMode &&
        _controller.appTheme == _appTheme) {
      return;
    }
    setState(() {
      _locale = _controller.locale;
      _themeMode = mode;
      _appTheme = _controller.appTheme;
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
    _links?.cancel();
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
      // and, above all, `Theme.of(context).brightness` - which is half of
      // what picks the palette down in the shell - come out right.
      theme: _baseTheme(Brightness.light, _appTheme),
      darkTheme: _baseTheme(Brightness.dark, _appTheme),
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

  static ThemeData _baseTheme(Brightness brightness, String? appTheme) =>
      ThemeData(
        useMaterial3: true,
        brightness: brightness,
        fontFamily: 'Nunito',
        // Seeded from the chosen theme's own accent, so the Material bits
        // that keep their own colours - a dialog's buttons, a text field's
        // cursor - land in the same family as the chrome around them. The
        // default's is the Sims 4 accent, which is also the app's own mint.
        colorSchemeSeed: GameTheme.forTheme(appTheme, brightness).accent,
        splashFactory: NoSplash.splashFactory,
      );
}
