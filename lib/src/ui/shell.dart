import 'dart:io';
import 'dart:math' as math;

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../core/game.dart';
import '../core/game_adapter.dart';
import 'app_controller.dart';
import 'creations_view.dart';
import 'detail_view.dart';
import 'game_skin.dart';
import 'game_theme.dart';
import 'install_destination_dialog.dart';
import 'l10n.dart';
import 'library_view.dart';
import 'onboarding_view.dart';
import 'packs_view.dart';
import 'saves_view.dart';
import 'settings_view.dart';
import 'shop_view.dart';
import 'trivia_buddy.dart';
import 'widgets.dart';

/// Window chrome: title bar, sidebar, and the active screen.
class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.controller,
    this.translucentSidebar = false,
  });

  final AppController controller;

  /// When true the window has an OS blur backdrop (acrylic/vibrancy), so the
  /// sidebar paints semi-transparent and the content area stays opaque.
  final bool translucentSidebar;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
    widget.controller.init();
  }

  Future<void> _handleDrop(
      AppController c, GameTheme t, DropDoneDetails details) async {
    setState(() => _dragging = false);
    // Nothing installs while the walkthrough is up: the window is a card
    // asking questions, and a file dropped on it was aimed at something
    // the user cannot see yet.
    if (c.modsDir == null || c.showOnboarding) return;
    final paths = [for (final f in details.files) f.path];
    // Filtered before asking: a drop of nothing but readmes has nothing
    // to ask about, and installDroppedPaths is still the one that says so.
    final usable = await c.acceptedDrops(paths);
    if (usable.isEmpty) return c.installDroppedPaths(paths);
    if (!mounted) return;
    final placement = await resolveInstallPlacement(context, c,
        theme: t, subjects: [for (final source in usable) source.path]);
    // Backed out of the dialog.
    if (placement == null) return;
    await c.installDroppedPaths(paths, placement: placement);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        // MaterialApp already resolved "system" against the OS, so this is
        // the single place the whole app learns whether it is dark.
        final t = GameTheme.forGame(c.adapter.game, Theme.of(context).brightness);
        // macOS keeps its native traffic lights overlaid; Windows/Linux lose
        // their caption buttons with the hidden title bar, so we draw our own.
        final ownButtons = Platform.isWindows || Platform.isLinux;
        final glass = widget.translucentSidebar;
        return Scaffold(
          // Transparent so the OS blur backdrop shows through the sidebar;
          // the content column below paints itself opaque.
          backgroundColor: glass ? Colors.transparent : t.bg,
          // Files dragged from anywhere (browser download bar, Explorer)
          // install on drop; only meaningful once a mods folder resolved.
          body: DropTarget(
            onDragEntered: (_) {
              if (c.modsDir != null && !c.showOnboarding) {
                setState(() => _dragging = true);
              }
            },
            onDragExited: (_) => setState(() => _dragging = false),
            onDragDone: (details) => _handleDrop(c, t, details),
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Sidebar(theme: t, controller: c, glass: glass),
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 450),
                        decoration: t.skin.backdrop(t),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Breathing room under the caption-button overlay.
                            const SizedBox(height: kWindowCaptionHeight),
                            // Above the screens rather than inside one: a
                            // toggle that fails from the detail view, or a
                            // cache clear that fails in Settings, has to be
                            // readable where it happened.
                            if (c.lastError != null)
                              _ErrorBanner(theme: t, controller: c),
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 320),
                                switchInCurve: Curves.easeOut,
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween(
                                      begin: const Offset(0, .015),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                ),
                                child: KeyedSubtree(
                                  key: ValueKey(
                                      '${c.adapter.game.id}.${c.screen}'),
                                  child: switch (c.screen) {
                                    AppScreen.library =>
                                      LibraryView(theme: t, controller: c),
                                    AppScreen.detail =>
                                      DetailView(theme: t, controller: c),
                                    AppScreen.settings =>
                                      SettingsView(theme: t, controller: c),
                                    AppScreen.shop =>
                                      ShopView(theme: t, controller: c),
                                    AppScreen.saves =>
                                      SavesView(theme: t, controller: c),
                                    AppScreen.packs =>
                                      PacksView(theme: t, controller: c),
                                    AppScreen.creations =>
                                      CreationsView(theme: t, controller: c),
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Over the whole window on the first run, but under the
                // caption buttons and the drag strip below: a walkthrough
                // nobody can move or close the window behind would be a
                // worse first impression than no walkthrough at all.
                if (c.showOnboarding)
                  Positioned.fill(
                    child: OnboardingOverlay(theme: t, controller: c),
                  ),
                // Invisible title-bar strip: drag to move, double-click to
                // maximize/restore, stopping short of the caption buttons.
                Positioned(
                  left: 0,
                  top: 0,
                  right: ownButtons ? _WindowButtons.width : 0,
                  height: kWindowCaptionHeight,
                  child: const DragToMoveArea(child: SizedBox.expand()),
                ),
                if (ownButtons)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: _WindowButtons(theme: t),
                  ),
                // Over every screen rather than on one: the facts written
                // about a screen have to be able to arrive while you are
                // standing on it. Under the drop overlay, which is the one
                // thing allowed to cover the window whole.
                TriviaBuddy(theme: t, controller: c),
                if (_dragging)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: _DropOverlay(theme: t, controller: c),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Why the last thing the user asked for didn't happen
/// ([AppController.lastError]): a strip they can read and wave away,
/// rather than a dialog standing between them and the next attempt. The
/// message travels as a key (`AppMessage`) and is translated here, at the
/// moment it is drawn.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final l = L.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        decoration: t.skin.decorate(t, SkinSurface.panel,
            radius: 12,
            state: SkinState.active,
            accent: t.warning,
            fill: t.warning.withValues(alpha: .1),
            outline: t.warning.withValues(alpha: .45)),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, size: 20, color: t.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l.errorText(controller.lastError!),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: t.text,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: controller.dismissError,
              tooltip: l.dismiss,
              iconSize: 17,
              color: t.muted,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-window highlight shown while files are dragged over the app.
class _DropOverlay extends StatelessWidget {
  const _DropOverlay({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final l = L.of(context);
    final accepted = [
      ...controller.adapter.modFileExtensions,
      ...controller.adapter.containerFileExtensions,
    ]..sort();
    return Container(
      color: t.bg.withValues(alpha: .8),
      alignment: Alignment.center,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
        decoration: t.skin.decorate(t, SkinSurface.panel,
            radius: 20, state: SkinState.active, fill: t.surface),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.file_download_outlined, size: 42, color: t.accent),
            const SizedBox(height: 10),
            Text(
              l.dropToInstall(controller.adapter.game.name),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: t.text,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              [...accepted, l.dropFolders].join('  ·  '),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: t.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Minimize / maximize / close buttons for platforms whose native caption
/// buttons disappear along with the hidden title bar.
class _WindowButtons extends StatefulWidget {
  const _WindowButtons({required this.theme});

  /// Three caption buttons at the platform-standard 46 px each.
  static const double width = 46 * 3;

  final GameTheme theme;

  @override
  State<_WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<_WindowButtons> with WindowListener {
  // The window starts unmaximized; afterwards we track it via events only,
  // so building this widget never touches the plugin (widget tests).
  bool _maximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() => setState(() => _maximized = true);

  @override
  void onWindowUnmaximize() => setState(() => _maximized = false);

  @override
  Widget build(BuildContext context) {
    final brightness = ThemeData.estimateBrightnessForColor(widget.theme.bg);
    return SizedBox(
      height: kWindowCaptionHeight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          WindowCaptionButton.minimize(
            brightness: brightness,
            onPressed: windowManager.minimize,
          ),
          if (_maximized)
            WindowCaptionButton.unmaximize(
              brightness: brightness,
              onPressed: windowManager.unmaximize,
            )
          else
            WindowCaptionButton.maximize(
              brightness: brightness,
              onPressed: windowManager.maximize,
            ),
          WindowCaptionButton.close(
            brightness: brightness,
            onPressed: windowManager.close,
          ),
        ],
      ),
    );
  }
}

/// Luminance matrix: a game's icon goes gray when that game has nothing
/// to offer (not installed, or no listings on The Exchange).
const _grayscale = ColorFilter.matrix(<double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0, //
  0, 0, 0, 1, 0, //
]);

class _Sidebar extends StatefulWidget {
  const _Sidebar({
    required this.theme,
    required this.controller,
    required this.glass,
  });

  final GameTheme theme;
  final AppController controller;

  /// Paint semi-transparent so the OS blur behind the window shows through.
  final bool glass;

  @override
  State<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<_Sidebar> {
  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final c = widget.controller;
    final l = L.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      width: 250,
      // macOS overlays its native traffic lights in this corner, so start
      // the sidebar content below them; other platforms keep the tight top.
      padding: EdgeInsets.fromLTRB(
          16, Platform.isMacOS ? kWindowCaptionHeight + 6 : 20, 16, 20),
      decoration: t.skin.sidebar(t, glass: widget.glass),
      // The column's height grows with the number of games and with what
      // the bottom cluster is carrying (the update banner, the disk bar),
      // and kMinWindowSize can't chase all of it - a short window scrolls
      // the sidebar instead of overflowing it. IntrinsicHeight + the
      // minHeight below is what keeps the Spacer working when there *is*
      // room: without them the scroll view's unbounded height would make
      // the flexible child meaningless.
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(child: _column(t, c, l)),
          ),
        ),
      ),
    );
  }

  Widget _column(GameTheme t, AppController c, L l) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _logo(t, c.adapter.game.id, l),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
            child: Text(l.sidebarGames, style: eyebrowStyle(t)),
          ),
          for (final adapter in c.registry.adapters) ...[
            _gameRow(t, c, l, adapter),
            const SizedBox(height: 4),
          ],
          const SizedBox(height: 14),
          Container(height: 1, color: t.border),
          const SizedBox(height: 14),
          _navButton(
            t,
            label: l.navLibrary,
            active: c.screen == AppScreen.library ||
                c.screen == AppScreen.detail,
            iconBuilder: (color) => Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 2.5),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            onTap: c.backToLibrary,
          ),
          const SizedBox(height: 4),
          _navButton(
            t,
            label: l.navSaves,
            active: c.screen == AppScreen.saves,
            // The design's saves glyph: the library square with one
            // corner rounded off, a page with a dog-ear.
            iconBuilder: (color) => Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 2.5),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                  bottomLeft: Radius.circular(9),
                ),
              ),
            ),
            onTap: c.openSaves,
          ),
          // Only for the games that have packs to show. A game whose
          // expansions merge into the install on setup has nothing to
          // list, and an empty screen would be a worse answer than no
          // screen at all.
          if (c.showPacks) ...[
            const SizedBox(height: 4),
            _navButton(
              t,
              label: l.navPacks,
              active: c.screen == AppScreen.packs,
              // Two stacked slabs: a box of content sitting on the game.
              iconBuilder: (color) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 18,
                    height: 7,
                    decoration: BoxDecoration(
                      border: Border.all(color: color, width: 2.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    width: 18,
                    height: 9,
                    decoration: BoxDecoration(
                      border: Border.all(color: color, width: 2.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
              onTap: c.openPacks,
            ),
          ],
          // Only for the games that keep player-built content somewhere
          // of their own. The Sims Medieval has no such folder, and an
          // empty shelf would be a worse answer than no shelf.
          if (c.showCreations) ...[
            const SizedBox(height: 4),
            _navButton(
              t,
              label: l.navCreations,
              active: c.screen == AppScreen.creations,
              // A house: a square with a roof over it.
              iconBuilder: (color) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.rotate(
                    angle: 0.785398, // 45 degrees: the roof
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: color, width: 2.5),
                          left: BorderSide(color: color, width: 2.5),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 15,
                    height: 9,
                    decoration: BoxDecoration(
                      border: Border.all(color: color, width: 2.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              onTap: c.openCreations,
            ),
          ],
          const SizedBox(height: 4),
          _navButton(
            t,
            label: l.navSettings,
            active: c.screen == AppScreen.settings,
            iconBuilder: (color) => Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 2.5),
                shape: BoxShape.circle,
              ),
            ),
            onTap: c.openSettings,
          ),
          const Spacer(),
          if (c.availableUpdate != null) ...[
            _updateCard(t, c, l),
            const SizedBox(height: 10),
          ],
          // Hidden outright where The Exchange cannot be reached: from
          // mainland China nothing Google-hosted answers, and a card
          // whose every press ends in the same failure is worse than no
          // card. The probe asks each launch, so a VPN brings it back.
          if (c.shopReachable) ...[
            _exchangeCard(t, c, l),
            const SizedBox(height: 10),
          ],
          _storageCard(t, c, l),
        ]);
  }

  /// Accent-tinted banner shown once a newer GitHub release is known;
  /// clicking opens its download page.
  Widget _updateCard(GameTheme t, AppController c, L l) {
    final update = c.availableUpdate!;
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: c.openReleasePage,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          // Ringed in the accent whether or not it is hovered: it is the
          // one card in the sidebar that only exists because something
          // happened.
          decoration: t.skin.decorate(t, SkinSurface.panel,
              state: SkinState.active,
              fill: hovered ? t.tint : t.surfaceAlt),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: t.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: t.accent.withValues(alpha: .5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.updateAvailable,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: t.accent,
                      ),
                    ),
                    Text(
                      l.updateClickToDownload(update.version),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: t.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The Exchange, sitting under the games rather than among them: its
  /// shelves carry every game at once. The row of game icons underneath
  /// is both the statement of that and a shortcut - tap one to open the
  /// shop already narrowed to it, tap it again to see everything.
  Widget _exchangeCard(GameTheme t, AppController c, L l) {
    final active = c.screen == AppScreen.shop;
    final counts = c.shopCountsByGame;
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: c.openShop,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
          decoration: t.skin.decorate(t, SkinSurface.panel,
              state: active ? SkinState.active : SkinState.idle,
              fill: active || hovered ? t.tint : t.surfaceAlt),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // The plumbob diamond: a rotated square, same outline
                  // weight as the nav icons above.
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: Center(
                      child: Transform.rotate(
                        angle: math.pi / 4,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: active ? t.accent : t.text, width: 2.5),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Flexible(
                    child: Text(
                      l.navShop,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: active ? t.accent : t.text,
                      ),
                    ),
                  ),
                  // Mods waiting for a new version, counted here so the
                  // answer is on screen from any tab rather than only for
                  // whoever thinks to go and look.
                  if (c.shopUpdateCount > 0) ...[
                    const SizedBox(width: 8),
                    Tooltip(
                      message: l.shopUpdatesWaiting(c.shopUpdateCount),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: t.accentGradient,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${c.shopUpdateCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 9),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final adapter in c.registry.adapters)
                    _exchangeGameShortcut(t, c, adapter.game,
                        // Before the first load nothing is known, and a
                        // row of gray icons would be a claim we can't
                        // make yet.
                        c.shopMods == null
                            ? null
                            : counts[adapter.game.id] ?? 0),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// One game's icon under The Exchange: lit when it has listings, dimmed
  /// when its shelf is empty, ringed while it's the filter in effect.
  /// [count] is null until the shelves have ever loaded.
  Widget _exchangeGameShortcut(
      GameTheme t, AppController c, Game game, int? count) {
    final selected = c.screen == AppScreen.shop && c.shopGameFilter == game.id;
    final empty = count == 0 && !selected;
    return Tooltip(
      message: count == null || count == 0
          ? game.name
          : '${game.name}  ·  $count',
      waitDuration: const Duration(milliseconds: 400),
      child: HoverBuilder(
        cursor: SystemMouseCursors.click,
        builder: (context, hovered) => GestureDetector(
          onTap: () => c.openShop(gameId: game.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(3),
            decoration: t.skin.decorate(t, SkinSurface.row,
                radius: 9,
                state: skinState(active: selected, hovered: hovered),
                fill: selected || hovered ? t.surface : null,
                outline: selected ? t.accent : null),
            child: Opacity(
              opacity: empty ? .5 : 1,
              child: _gameGlyph(t, game, size: 20, dim: empty),
            ),
          ),
        ),
      ),
    );
  }

  /// A game's icon at [size], falling back to the lettered badge for a
  /// game we ship no artwork for. [dim] drains the color out of it - the
  /// sidebar's way of saying "nothing here". Fading is the caller's job:
  /// the game rows already sit inside an [Opacity].
  Widget _gameGlyph(GameTheme t, Game game,
      {required double size, required bool dim}) {
    Widget badge() {
      final badgeColor = dim
          ? t.muted.withValues(alpha: .5)
          : GameTheme.badgeColor(game, Theme.of(context).brightness);
      final trailing = game.name.replaceAll(RegExp(r'[^0-9]'), '');
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: badgeColor,
          borderRadius: BorderRadius.circular(size * .3),
          boxShadow: dim
              ? null
              : [
                  BoxShadow(
                    color: badgeColor.withValues(alpha: .45),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Text(
          trailing.isEmpty ? game.name.substring(0, 1) : trailing,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: size * .48,
          ),
        ),
      );
    }

    final asset = GameTheme.iconAsset(game);
    if (asset == null) return badge();
    final image = Image.asset(
      asset,
      fit: BoxFit.contain,
      // The first launch after an install gets handed files the
      // antivirus is still scanning, and the sidebar draws every game at
      // once: five icons failed together seconds after setup finished,
      // and with nothing catching them the failures reached
      // FlutterError.onError as crash reports for artwork that loads
      // fine on the next run. The badge is what a game with no artwork
      // shows anyway.
      errorBuilder: (_, __, ___) => badge(),
    );
    return SizedBox(
      width: size,
      height: size,
      child: dim
          ? ColorFiltered(colorFilter: _grayscale, child: image)
          : image,
    );
  }

  Widget _logo(GameTheme t, String gameId, L l) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          BrandMark(gameId: gameId, size: 30),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.brandTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    height: 1,
                    color: t.text,
                  ),
                ),
                Text(
                  l.brandSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: t.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _gameRow(GameTheme t, AppController c, L l, GameAdapter adapter) {
    final game = adapter.game;
    final active = game.id == c.adapter.game.id;
    final count = c.modCounts[game.id];
    final installed = count != null;
    final opacity = installed ? 1.0 : 0.45;
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) {
        final state = skinState(active: active, hovered: hovered);
        return GestureDetector(
          onTap: () => c.selectGame(game.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: t.skin.decorate(t, SkinSurface.row, state: state),
            child: Opacity(
              opacity: opacity,
              child: Row(
                children: [
                  _gameGlyph(t, game, size: 27, dim: !installed),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                            color: t.skin.ink(t, SkinSurface.row,
                                state: state, otherwise: t.text),
                          ),
                        ),
                        Text(
                          count == null
                              ? l.sidebarNotInstalled(
                                  '${game.year ?? game.series}')
                              : l.sidebarModCount(
                                  count, '${game.year ?? game.series}'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: t.skin.ink(t, SkinSurface.row,
                                state: state,
                                secondary: true,
                                otherwise: t.muted),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (active)
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: t.skin.ink(t, SkinSurface.row,
                            state: state, otherwise: t.accent),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _navButton(
    GameTheme t, {
    required String label,
    required bool active,
    required Widget Function(Color) iconBuilder,
    required VoidCallback onTap,
  }) {
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) {
        final state = skinState(active: active, hovered: hovered);
        // The icon is drawn in the label's colour, so a skin that turns
        // the row into a pressed button takes the glyph with it.
        final color = t.skin.ink(t, SkinSurface.row,
            state: state, otherwise: active ? t.accent : t.text);
        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(10),
            decoration: t.skin.decorate(t, SkinSurface.row, state: state),
            child: Row(
              children: [
                iconBuilder(color),
                const SizedBox(width: 11),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _storageCard(GameTheme t, AppController c, L l) {
    final used = c.allGamesSizeBytes;
    final disk = c.diskSpace;
    final pct = disk == null || disk.totalBytes <= 0
        ? 0.0
        : (disk.usedBytes / disk.totalBytes).clamp(0.0, 1.0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: t.skin.decorate(t, SkinSurface.panel,
          fill: widget.glass
              ? t.surfaceAlt.withValues(alpha: .5)
              : t.surfaceAlt),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  l.storage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: t.text,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  l.storageInMods(formatBytes(used)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: t.muted,
                  ),
                ),
              ),
            ],
          ),
          // Drive fullness, only once the OS has answered.
          if (disk != null) ...[
            const SizedBox(height: 9),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 7,
                child: Stack(
                  children: [
                    Container(color: t.border),
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 500),
                      alignment: Alignment.centerLeft,
                      widthFactor: pct,
                      child: Container(
                        decoration: BoxDecoration(gradient: t.accentGradient),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 7),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l.storageFreeOf(formatBytes(disk.freeBytes),
                    formatBytes(disk.totalBytes)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: t.muted,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
