import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../core/mod.dart';
import '../core/mod_name.dart';
import '../services/sfx.dart';
import 'app_controller.dart';
import 'game_theme.dart';
import 'widgets.dart';

/// The main screen: search, filters, stats, and the mod grid/list.
class LibraryView extends StatelessWidget {
  const LibraryView({super.key, required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    if (c.loading) {
      final progress = c.scanProgress;
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: t.accent,
              value: progress != null && progress.$2 > 0
                  ? progress.$1 / progress.$2
                  : null,
            ),
            if (progress != null) ...[
              const SizedBox(height: 14),
              Text(
                'Looking inside mods for artwork… '
                '${progress.$1} of ${progress.$2}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: t.muted,
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: c.skipArtworkScan,
                style: TextButton.styleFrom(
                  foregroundColor: t.muted,
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 13),
                ),
                child: const Text('Skip'),
              ),
            ],
          ],
        ),
      );
    }
    if (c.modsDir == null) {
      return _FolderSetupView(theme: t, controller: c);
    }
    final visible = c.filteredMods;
    final logoAsset = GameTheme.logoAsset(c.adapter.game);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 22, 28, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (logoAsset != null)
                      Image.asset(
                        logoAsset,
                        height: 42,
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.contain,
                        semanticLabel: '${c.adapter.game.name} Library',
                      )
                    else
                      Text(
                        '${c.adapter.game.name} Library',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          height: 1,
                          color: t.text,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      '${visible.length} mods shown · ${t.era}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: t.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              _searchField(t, c),
              const SizedBox(width: 14),
              _viewToggle(t, c),
              const SizedBox(width: 14),
              _installButton(t, c),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 14),
          child: Row(
            children: [
              Expanded(child: _FilterChips(theme: t, controller: c)),
              _stat(t, 'Total', '${c.mods.length}', t.text),
              _stat(t, 'Enabled', '${c.enabledCount}', t.accent),
              _stat(
                  t, 'Disabled', '${c.mods.length - c.enabledCount}', t.muted),
              _conflictStat(t, c),
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? _EmptyLibrary(theme: t, controller: c)
              : c.listView
                  ? _modList(t, c, visible)
                  : _modGrid(t, c, visible),
        ),
      ],
    );
  }

  Widget _searchField(GameTheme t, AppController c) {
    return SizedBox(
      width: 210,
      child: TextField(
        onChanged: c.setQuery,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: t.text,
        ),
        cursorColor: t.accent,
        decoration: InputDecoration(
          hintText: 'Search mods…',
          hintStyle: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: t.muted,
          ),
          prefixIcon: Icon(Icons.search, size: 17, color: t.muted),
          isDense: true,
          filled: true,
          fillColor: t.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: BorderSide(color: t.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: BorderSide(color: t.accent, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _viewToggle(GameTheme t, AppController c) {
    Widget button(bool list, IconData icon) {
      final active = c.listView == list;
      return GestureDetector(
        onTap: () => c.setListView(list),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 34,
            height: 32,
            decoration: BoxDecoration(
              color: active ? t.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: active ? t.accent : t.muted),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: t.surfaceAlt,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          button(false, Icons.grid_view_rounded),
          const SizedBox(width: 2),
          button(true, Icons.view_list_rounded),
        ],
      ),
    );
  }

  Widget _installButton(GameTheme t, AppController c) {
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: () => _pickAndInstall(c),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.translationValues(0, hovered ? -1 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: t.accentGradient,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: t.accent.withValues(alpha: .5),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('＋',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1)),
              SizedBox(width: 6),
              Text(
                'Install',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _pickAndInstall(AppController c) async {
    c.playSound(UiSound.click);
    final extensions = [
      for (final e in c.adapter.modFileExtensions) e.replaceFirst('.', ''),
    ];
    final files = await openFiles(acceptedTypeGroups: [
      XTypeGroup(label: '${c.adapter.game.name} mods', extensions: extensions),
    ]);
    if (files.isEmpty) return;
    await c.installFiles([for (final f in files) File(f.path)]);
  }

  Widget _stat(GameTheme t, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: t.border)),
      ),
      child: _statBody(t, label, value, color),
    );
  }

  Widget _statBody(GameTheme t, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            height: 1,
            color: color,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: .6,
            color: t.muted,
          ),
        ),
      ],
    );
  }

  /// The Conflicts stat doubles as a filter: tapping it narrows the
  /// library to the flagged mods, tapping again clears. A tooltip spells
  /// out what "conflict" means here (duplicate file names).
  Widget _conflictStat(GameTheme t, AppController c) {
    final active = c.conflictsOnly;
    final tappable = active || c.conflictCount > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: t.border)),
      ),
      child: Tooltip(
        message: active
            ? 'Showing conflicting mods only — click to show all mods again.'
            : 'Enabled mods sharing a file name with another enabled mod. '
                'The game loads duplicates in an unpredictable order.'
                '${tappable ? ' Click to show only these mods.' : ''}',
        waitDuration: const Duration(milliseconds: 400),
        child: HoverBuilder(
          cursor:
              tappable ? SystemMouseCursors.click : SystemMouseCursors.basic,
          builder: (context, hovered) => GestureDetector(
            onTap: tappable ? c.toggleConflictsOnly : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: active
                    ? conflictOrange.withValues(alpha: .14)
                    : hovered && tappable
                        ? conflictOrange.withValues(alpha: .07)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: _statBody(t, 'Conflicts', '${c.conflictCount}',
                  conflictOrange),
            ),
          ),
        ),
      ),
    );
  }

  Widget _modGrid(GameTheme t, AppController c, List<Mod> visible) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / 320).floor().clamp(1, 4);
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(28, 4, 28, 28),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 210,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: visible.length,
          itemBuilder: (context, i) =>
              _GridCard(theme: t, controller: c, mod: visible[i]),
        );
      },
    );
  }

  Widget _modList(GameTheme t, AppController c, List<Mod> visible) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(28, 4, 28, 28),
      itemCount: visible.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) =>
          _ListRow(theme: t, controller: c, mod: visible[i]),
    );
  }
}

/// One entry of the filter row: a category or a mods subfolder.
typedef _FilterEntry = ({String label, bool isFolder});

/// The single-line filter row: category chips, then folder chips.
/// Chips that don't fit move into a "…" popup menu at the end
/// ([OverflowRow]). Folder chips — and only folder chips — can be
/// drag-and-dropped onto each other to rearrange them, both on the line
/// and inside the menu, including from the menu onto the line.
class _FilterChips extends StatefulWidget {
  const _FilterChips({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  State<_FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<_FilterChips> {
  /// How many leading chips fit on the line — recorded by [OverflowRow]
  /// during layout and read when the "…" menu opens (no rebuild needed).
  int _visibleCount = 0;

  final GlobalKey _dotsKey = GlobalKey();

  /// The "…" menu. A hand-rolled overlay instead of [showMenu]: a modal
  /// route's barrier would block drops onto the chips line below, and
  /// popping it mid-drag would kill the drag.
  OverlayEntry? _menuEntry;

  /// While a folder is dragged out of the menu, the dismiss barrier goes
  /// hit-test-transparent so the drop can reach the chips on the line.
  bool _menuDragging = false;

  @override
  void dispose() {
    _closeMenu();
    super.dispose();
  }

  List<_FilterEntry> _entries(AppController c) => [
        for (final cat in c.categories) (label: cat, isFolder: false),
        // Subfolders of the mods folder act as a second filter axis;
        // tapping the active one clears it again.
        for (final f in c.folders) (label: f, isFolder: true),
      ];

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final c = widget.controller;
    final entries = _entries(c);
    return OverflowRow(
      spacing: 9,
      onVisibleCountChanged: (n) {
        if (n == _visibleCount) return;
        _visibleCount = n;
        // The open menu lists the chips that no longer fit — refresh it
        // once this layout pass is over.
        if (_menuEntry != null) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _menuEntry?.markNeedsBuild());
        }
      },
      children: [
        for (final e in entries)
          e.isFolder ? _folderChip(t, c, e.label) : _categoryChip(t, c, e.label),
        _overflowButton(t, c),
      ],
    );
  }

  Widget _categoryChip(GameTheme t, AppController c, String cat) => _chip(
        t,
        cat,
        count: c.categoryCount(cat),
        active: cat == c.category,
        onTap: () => c.setCategory(cat),
      );

  /// A folder chip is also a drag source and a drop target: dropping
  /// folder A onto folder B moves A into B's position. Categories are
  /// neither, so the arrangement never touches the other filters.
  Widget _folderChip(GameTheme t, AppController c, String f) {
    final chip = _chip(
      t,
      f,
      count: c.folderCount(f),
      active: f == c.folder,
      onTap: () => c.setFolder(f == c.folder ? 'All' : f),
      icon: Icons.folder_rounded,
    );
    return Draggable<String>(
      data: f,
      feedback: Material(type: MaterialType.transparency, child: chip),
      childWhenDragging: Opacity(opacity: .35, child: chip),
      child: DragTarget<String>(
        onWillAcceptWithDetails: (details) => details.data != f,
        onAcceptWithDetails: (details) => c.reorderFolder(details.data, f),
        builder: (context, candidates, _) => candidates.isEmpty
            ? chip
            : Stack(
                children: [
                  chip,
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: t.accent, width: 2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _overflowButton(GameTheme t, AppController c) {
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: _toggleMenu,
        child: Container(
          key: _dotsKey,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(
              color: hovered ? t.accent.withValues(alpha: .5) : t.border,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '…',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: t.text,
            ),
          ),
        ),
      ),
    );
  }

  void _toggleMenu() {
    if (_menuEntry != null) {
      _closeMenu();
      return;
    }
    widget.controller.playSound(UiSound.click);
    final overlay = Overlay.of(context);
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    final dotsBox =
        _dotsKey.currentContext?.findRenderObject() as RenderBox?;
    if (overlayBox == null || dotsBox == null) return;
    final origin = dotsBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final anchor = Offset(origin.dx, origin.dy + dotsBox.size.height + 6);
    _menuEntry = OverlayEntry(
      builder: (_) => _buildMenu(anchor, overlayBox.size),
    );
    overlay.insert(_menuEntry!);
  }

  void _closeMenu() {
    _menuEntry?.remove();
    _menuEntry?.dispose();
    _menuEntry = null;
    _menuDragging = false;
  }

  Widget _buildMenu(Offset anchor, Size overlaySize) {
    final t = widget.theme;
    final c = widget.controller;
    const menuWidth = 250.0;
    final left =
        anchor.dx.clamp(8.0, (overlaySize.width - menuWidth - 8).clamp(8.0, double.infinity));
    // Rebuilds live with the controller, so a reorder made by dragging
    // inside the menu shows up immediately.
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) {
        final entries = _entries(c);
        final hidden = entries.sublist(_visibleCount.clamp(0, entries.length));
        if (hidden.isEmpty) {
          // Everything fits again (e.g. the last hidden folder was
          // dragged onto the line) — nothing left to show.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_menuEntry != null) _closeMenu();
          });
        }
        return Stack(
          children: [
            // Dismiss barrier. Hit-test-transparent while dragging so the
            // drop reaches the folder chips on the line underneath.
            Positioned.fill(
              child: Listener(
                behavior: _menuDragging
                    ? HitTestBehavior.translucent
                    : HitTestBehavior.opaque,
                onPointerDown: (_) => _closeMenu(),
              ),
            ),
            Positioned(
              left: left,
              top: anchor.dy,
              width: menuWidth,
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 320),
                  decoration: BoxDecoration(
                    color: t.surface,
                    border: Border.all(color: t.border),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33142823),
                        blurRadius: 24,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final e in hidden) _menuRow(t, c, e),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// A menu entry. Folder rows are drag sources and drop targets exactly
  /// like the line chips, so folders reorder within the menu and drag out
  /// of it onto the line; category rows only tap.
  Widget _menuRow(GameTheme t, AppController c, _FilterEntry e) {
    final active = e.isFolder ? e.label == c.folder : e.label == c.category;
    final count =
        e.isFolder ? c.folderCount(e.label) : c.categoryCount(e.label);
    final row = HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _closeMenu();
          if (e.isFolder) {
            c.setFolder(e.label == c.folder ? 'All' : e.label);
          } else {
            c.setCategory(e.label);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          color: hovered ? t.tint : Colors.transparent,
          child: Row(
            children: [
              if (e.isFolder) ...[
                Icon(
                  Icons.folder_rounded,
                  size: 14,
                  color: active ? t.accent : t.muted,
                ),
                const SizedBox(width: 7),
              ],
              Flexible(
                child: Text(
                  e.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: active ? t.accent : t.text,
                  ),
                ),
              ),
              Text(
                '  $count',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: t.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!e.isFolder) return row;
    return Draggable<String>(
      data: e.label,
      onDragStarted: () {
        _menuDragging = true;
        _menuEntry?.markNeedsBuild();
      },
      onDragEnd: (_) {
        _menuDragging = false;
        _menuEntry?.markNeedsBuild();
      },
      // The feedback is the chip the folder will become on the line.
      feedback: Material(
        type: MaterialType.transparency,
        child: _chip(
          t,
          e.label,
          count: count,
          active: active,
          onTap: () {},
          icon: Icons.folder_rounded,
        ),
      ),
      childWhenDragging: Opacity(opacity: .35, child: row),
      child: DragTarget<String>(
        onWillAcceptWithDetails: (details) => details.data != e.label,
        onAcceptWithDetails: (details) => c.reorderFolder(details.data, e.label),
        builder: (context, candidates, _) => candidates.isEmpty
            ? row
            : ColoredBox(color: t.tint, child: row),
      ),
    );
  }

  Widget _chip(
    GameTheme t,
    String label, {
    required int count,
    required bool active,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: active ? t.accent : t.surface,
            border: Border.all(
              color: active
                  ? t.accent
                  : hovered
                      ? t.accent.withValues(alpha: .5)
                      : t.border,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 13,
                  color: (active ? Colors.white : t.text)
                      .withValues(alpha: active ? .9 : .55),
                ),
                const SizedBox(width: 6),
              ],
              Text.rich(
                TextSpan(
                  text: label,
                  children: [
                    TextSpan(
                      text: '  $count',
                      style: TextStyle(
                        color: (active ? Colors.white : t.text)
                            .withValues(alpha: .55),
                      ),
                    ),
                  ],
                ),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: active ? Colors.white : t.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Human-friendly display title: extension stripped and creator naming
/// conventions cleaned up ("UICheatsExtension_v1.36.ts4script" →
/// "UI Cheats Extension v1.36").
String modTitle(Mod mod) => humanizeModName(mod.name);

/// The "by author" slot of the design — real files don't carry an author,
/// so show where the file lives instead.
String modSubtitle(AppController c, Mod mod) {
  final root = c.modsDir?.path;
  if (root != null) {
    final rel = p.relative(p.dirname(mod.path), from: root);
    if (rel != '.') return 'in $rel';
  }
  return 'in Mods folder';
}

String modDate(Mod mod) {
  final d = mod.modifiedAt;
  if (d == null) return '';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

class _GridCard extends StatelessWidget {
  const _GridCard(
      {required this.theme, required this.controller, required this.mod});

  final GameTheme theme;
  final AppController controller;
  final Mod mod;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: () => c.openMod(mod),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0, hovered ? -3 : 0, 0),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: hovered ? t.accent : t.border),
            borderRadius: BorderRadius.circular(15),
            boxShadow: hovered
                ? const [
                    BoxShadow(
                      color: Color(0x73142823),
                      blurRadius: 34,
                      offset: Offset(0, 18),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ModThumb(
                      seed: mod.name,
                      bytes: c.thumbnailOf(mod),
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(14)),
                    ),
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: .28),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          p.extension(mod.name),
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: Colors.white.withValues(alpha: .9),
                          ),
                        ),
                      ),
                    ),
                    if (c.isConflicted(mod))
                      const Positioned(
                          left: 10, top: 10, child: ConflictBadge()),
                    Positioned(
                      right: 9,
                      top: 9,
                      child: PillSwitch(
                        value: mod.isEnabled,
                        activeColor: t.accent,
                        onChanged: () => c.toggleMod(mod),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              modTitle(mod),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                                color: t.text,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            modDate(mod),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: t.muted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        modSubtitle(c, mod),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: t.muted,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TagChip(
                            label: mod.category,
                            color: t.accent,
                            background: t.tint,
                          ),
                          Text(
                            formatBytes(mod.sizeBytes),
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: t.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow(
      {required this.theme, required this.controller, required this.mod});

  final GameTheme theme;
  final AppController controller;
  final Mod mod;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: () => c.openMod(mod),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          transform: Matrix4.translationValues(hovered ? 3 : 0, 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: hovered ? t.accent : t.border),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: ModThumb(
                  seed: mod.name,
                  bytes: c.thumbnailOf(mod),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: modTitle(mod),
                        children: [
                          TextSpan(
                            text: '  ${p.extension(mod.name)}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: t.muted,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: t.text,
                      ),
                    ),
                    Text(
                      '${modSubtitle(c, mod)} · ${modDate(mod)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: t.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (c.isConflicted(mod)) ...[
                TagChip(
                  label: 'conflict',
                  color: conflictOrange,
                  background: conflictOrange.withValues(alpha: .12),
                ),
                const SizedBox(width: 8),
              ],
              TagChip(
                label: mod.category,
                color: t.accent,
                background: t.tint,
              ),
              SizedBox(
                width: 72,
                child: Text(
                  formatBytes(mod.sizeBytes),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: t.muted,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              PillSwitch(
                value: mod.isEnabled,
                activeColor: t.accent,
                onChanged: () => c.toggleMod(mod),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Folder exists but nothing (matching the filters) is in it.
class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final filtering = c.query.isNotEmpty ||
        c.category != 'All' ||
        c.folder != 'All' ||
        !c.settings.showDisabled;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            filtering ? 'No mods match your filters' : 'No mods yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: t.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            filtering
                ? 'Try clearing the search or picking another filter.'
                : 'This folder is being watched:\n${c.modsDir?.path}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: t.muted,
            ),
          ),
          if (!filtering) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => c.revealInFileManager(c.modsDir!.path),
              style: OutlinedButton.styleFrom(
                foregroundColor: t.accent,
                side: BorderSide(color: t.accent, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                textStyle:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              child: const Text('Open folder'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shown when no mods folder could be located: explains the game's setup,
/// offers manual selection, found candidates, and one-click creation of
/// the default folder — the "game not installed / no Mods folder yet /
/// multiple installs" caveats.
class _FolderSetupView extends StatelessWidget {
  const _FolderSetupView({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    // The game folder being present changes the story entirely: the game
    // is there, only its mods folder is missing — don't suggest the game
    // may not be installed.
    final gameFolder = c.gameFolder;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                gameFolder != null
                    ? '${c.adapter.game.name} found — no mods folder yet'
                    : '${c.adapter.game.name} mods folder not found',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: t.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                gameFolder != null
                    ? 'The game\'s folder is on this computer — it just '
                        'doesn\'t contain a mods folder yet. Create it below, '
                        'or point at one manually.'
                    : 'The game may not be installed, may live somewhere '
                        'unusual, or its mods folder may not exist yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: t.muted,
                ),
              ),
              if (gameFolder != null) ...[
                const SizedBox(height: 10),
                Text(
                  gameFolder.path,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11.5,
                    color: t.muted,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: t.surface,
                  border: Border.all(color: t.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  c.adapter.setupHelp,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.55,
                    fontWeight: FontWeight.w600,
                    color: t.text,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (c.candidateDirs.isNotEmpty) ...[
                Text(
                  'FOUND ON THIS COMPUTER',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: t.muted,
                  ),
                ),
                const SizedBox(height: 8),
                for (final dir in c.candidateDirs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _candidateRow(t, c, dir.path),
                  ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _chooseFolder(c),
                      style: FilledButton.styleFrom(
                        backgroundColor: t.accent,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11)),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 13.5),
                      ),
                      child: const Text('Choose folder…'),
                    ),
                  ),
                  if (c.defaultPath != null) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: c.createDefaultFolder,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: t.accent,
                          backgroundColor: t.tint,
                          side: BorderSide(color: t.accent, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11)),
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 13.5),
                        ),
                        child: const Text('Create it for me'),
                      ),
                    ),
                  ],
                ],
              ),
              if (c.defaultPath != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Will be created at:\n${c.defaultPath}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11.5,
                    color: t.muted,
                  ),
                ),
              ],
              // Installed the game / created the folder outside the app?
              // Re-run detection without restarting.
              const SizedBox(height: 14),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    c.playSound(UiSound.click);
                    c.refresh();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: t.muted,
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Check again'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _candidateRow(GameTheme t, AppController c, String path) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 9, 9, 9),
      decoration: BoxDecoration(
        color: t.surfaceAlt,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              path,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: t.text,
              ),
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: () => c.setFolderOverride(path),
            style: TextButton.styleFrom(
              foregroundColor: t.accent,
              textStyle:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            child: const Text('Use this'),
          ),
        ],
      ),
    );
  }

  static Future<void> _chooseFolder(AppController c) async {
    final path = await getDirectoryPath();
    if (path == null) return;
    await c.setFolderOverride(path);
  }
}
