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
      return Center(child: CircularProgressIndicator(color: t.accent));
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
              Expanded(
                child: Wrap(
                  spacing: 9,
                  runSpacing: 9,
                  children: [
                    for (final cat in c.categories) _chip(t, c, cat),
                  ],
                ),
              ),
              _stat(t, 'Total', '${c.mods.length}', t.text),
              _stat(t, 'Enabled', '${c.enabledCount}', t.accent),
              _stat(
                  t, 'Disabled', '${c.mods.length - c.enabledCount}', t.muted),
              _stat(t, 'Conflicts', '${c.conflictCount}', conflictOrange),
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

  Widget _chip(GameTheme t, AppController c, String cat) {
    final active = cat == c.category;
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: () => c.setCategory(cat),
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
          child: Text.rich(
            TextSpan(
              text: cat,
              children: [
                TextSpan(
                  text: '  ${c.categoryCount(cat)}',
                  style: TextStyle(
                    color:
                        (active ? Colors.white : t.text).withValues(alpha: .55),
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
        ),
      ),
    );
  }

  Widget _stat(GameTheme t, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: t.border)),
      ),
      child: Column(
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
                    StripeThumb(
                      seed: mod.name,
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
                child: StripeThumb(
                  seed: mod.name,
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
    final filtering =
        c.query.isNotEmpty || c.category != 'All' || !c.settings.showDisabled;
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
                ? 'Try clearing the search or picking another category.'
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${c.adapter.game.name} mods folder not found',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: t.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'The game may not be installed, may live somewhere unusual, '
                'or its mods folder may not exist yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: t.muted,
                ),
              ),
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
