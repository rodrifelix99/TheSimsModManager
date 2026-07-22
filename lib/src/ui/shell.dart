import 'package:flutter/material.dart';

import '../core/game_adapter.dart';
import 'app_controller.dart';
import 'detail_view.dart';
import 'game_theme.dart';
import 'library_view.dart';
import 'settings_view.dart';
import 'widgets.dart';

/// Window chrome: title bar, sidebar, and the active screen.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.controller});

  final AppController controller;

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
        return Scaffold(
          backgroundColor: t.bg,
          body: Column(
            children: [
              _TitleBar(theme: t, controller: c),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Sidebar(theme: t, controller: c),
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
                          key: ValueKey('${c.adapter.game.id}.${c.screen}'),
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
            ],
          ),
        );
      },
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 450),
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: t.surfaceAlt,
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 60),
          Expanded(
            child: Text(
              'Sims Mod Manager — ${controller.adapter.game.name}'
              '  ·  ${t.era}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: t.muted,
              ),
            ),
          ),
          const SizedBox(width: 60),
        ],
      ),
    );
  }
}

class _Sidebar extends StatefulWidget {
  const _Sidebar({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

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
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      decoration: BoxDecoration(
        color: t.surface,
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
          _storageCard(t, c),
        ],
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
    final badgeColor = GameTheme.badgeColor(game);
    final iconAsset = GameTheme.iconAsset(game);
    final count = c.modCounts[game.id];
    final trailing = game.name.replaceAll(RegExp(r'[^0-9]'), '');
    final badge = trailing.isEmpty ? game.name.substring(0, 1) : trailing;
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
          child: Row(
            children: [
              if (iconAsset != null)
                SizedBox(
                  width: 27,
                  height: 27,
                  child: Image.asset(iconAsset, fit: BoxFit.contain),
                )
              else
                Container(
                  width: 27,
                  height: 27,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withValues(alpha: .45),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
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
                          ? 'not found · ${game.year ?? game.series}'
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
        color: t.surfaceAlt,
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
          // Drive fullness — only once the OS has answered.
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
                        decoration:
                            BoxDecoration(gradient: t.accentGradient),
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
