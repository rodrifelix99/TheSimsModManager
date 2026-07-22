import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../core/game_adapter.dart';
import 'app_controller.dart';
import 'detail_view.dart';
import 'game_theme.dart';
import 'library_view.dart';
import 'settings_view.dart';
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
  @override
  void initState() {
    super.initState();
    widget.controller.init();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final t = GameTheme.forGame(c.adapter.game);
        // macOS keeps its native traffic lights overlaid; Windows/Linux lose
        // their caption buttons with the hidden title bar, so we draw our own.
        final ownButtons = Platform.isWindows || Platform.isLinux;
        final glass = widget.translucentSidebar;
        return Scaffold(
          // Transparent so the OS blur backdrop shows through the sidebar;
          // the content column below paints itself opaque.
          backgroundColor: glass ? Colors.transparent : t.bg,
          body: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Sidebar(theme: t, controller: c, glass: glass),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 450),
                      color: t.bg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Breathing room under the caption-button overlay.
                          const SizedBox(height: kWindowCaptionHeight),
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
            ],
          ),
        );
      },
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

class _SidebarState extends State<_Sidebar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final c = widget.controller;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      width: 250,
      // macOS overlays its native traffic lights in this corner, so start
      // the sidebar content below them; other platforms keep the tight top.
      padding: EdgeInsets.fromLTRB(
          16, Platform.isMacOS ? kWindowCaptionHeight + 6 : 20, 16, 20),
      decoration: BoxDecoration(
        color: widget.glass ? t.surface.withValues(alpha: .55) : t.surface,
        border: Border(right: BorderSide(color: t.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _logo(t),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 0, 6, 8),
            child: Text(
              'GAMES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.3,
                color: t.muted,
              ),
            ),
          ),
          for (final adapter in c.registry.adapters) ...[
            _gameRow(t, c, adapter),
            const SizedBox(height: 4),
          ],
          const SizedBox(height: 14),
          Container(height: 1, color: t.border),
          const SizedBox(height: 14),
          _navButton(
            t,
            label: 'Library',
            active: c.screen != AppScreen.settings,
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
            label: 'Settings',
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
            _updateCard(t, c),
            const SizedBox(height: 10),
          ],
          _storageCard(t, c),
        ],
      ),
    );
  }

  /// Accent-tinted banner shown once a newer GitHub release is known;
  /// clicking opens its download page.
  Widget _updateCard(GameTheme t, AppController c) {
    final update = c.availableUpdate!;
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: c.openReleasePage,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: hovered ? t.tint : t.surfaceAlt,
            border: Border.all(color: t.accent, width: 1.5),
            borderRadius: BorderRadius.circular(13),
          ),
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
                      'Update available',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: t.accent,
                      ),
                    ),
                    Text(
                      'v${update.version}: click to download',
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

  Widget _logo(GameTheme t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: AnimatedBuilder(
              animation: _bob,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, -2 + 4 * _bob.value),
                child: Transform.rotate(angle: 0.785398, child: child),
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: t.accentGradient,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: t.accent.withValues(alpha: .55),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mod Manager',
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
                  'for The Sims',
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

  Widget _gameRow(GameTheme t, AppController c, GameAdapter adapter) {
    final game = adapter.game;
    final active = game.id == c.adapter.game.id;
    final count = c.modCounts[game.id];
    final installed = count != null;
    final badgeColor =
        installed ? GameTheme.badgeColor(game) : t.muted.withValues(alpha: .5);
    final iconAsset = GameTheme.iconAsset(game);
    final trailing = game.name.replaceAll(RegExp(r'[^0-9]'), '');
    final badge = trailing.isEmpty ? game.name.substring(0, 1) : trailing;
    final opacity = installed ? 1.0 : 0.45;
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: () => c.selectGame(game.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: active || hovered ? t.tint : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Opacity(
            opacity: opacity,
            child: Row(
              children: [
                if (iconAsset != null)
                  SizedBox(
                    width: 27,
                    height: 27,
                    child: installed
                        ? Image.asset(iconAsset, fit: BoxFit.contain)
                        : ColorFiltered(
                            colorFilter: const ColorFilter.matrix(<double>[
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0.2126,
                              0.7152,
                              0.0722,
                              0,
                              0,
                              0,
                              0,
                              0,
                              1,
                              0,
                            ]),
                            child: Image.asset(iconAsset, fit: BoxFit.contain),
                          ),
                  )
                else
                  Container(
                    width: 27,
                    height: 27,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: installed
                          ? [
                              BoxShadow(
                                color: badgeColor.withValues(alpha: .45),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
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
                          color: t.text,
                        ),
                      ),
                      Text(
                        count == null
                            ? 'not installed · ${game.year ?? game.series}'
                            : '$count mods · ${game.year ?? game.series}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: t.muted,
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
                      color: t.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navButton(
    GameTheme t, {
    required String label,
    required bool active,
    required Widget Function(Color) iconBuilder,
    required VoidCallback onTap,
  }) {
    final color = active ? t.accent : t.text;
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: active || hovered ? t.tint : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            children: [
              iconBuilder(color),
              const SizedBox(width: 11),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _storageCard(GameTheme t, AppController c) {
    final used = c.allGamesSizeBytes;
    final disk = c.diskSpace;
    final pct = disk == null || disk.totalBytes <= 0
        ? 0.0
        : (disk.usedBytes / disk.totalBytes).clamp(0.0, 1.0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: widget.glass ? t.surfaceAlt.withValues(alpha: .5) : t.surfaceAlt,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Storage',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: t.text,
                ),
              ),
              Flexible(
                child: Text(
                  '${formatBytes(used)} in mods',
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
                '${formatBytes(disk.freeBytes)} free of '
                '${formatBytes(disk.totalBytes)}',
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
