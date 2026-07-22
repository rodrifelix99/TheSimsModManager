import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../core/mod.dart';
import '../services/sfx.dart';
import 'app_controller.dart';
import 'game_theme.dart';
import 'library_view.dart' show modDate, modTitle;
import 'widgets.dart';

/// Full page for one mod: artwork, enable toggle, facts, file details.
class DetailView extends StatelessWidget {
  const DetailView({super.key, required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final mod = c.selectedMod;
    if (mod == null) {
      // Mod vanished (deleted externally); bounce back gracefully.
      WidgetsBinding.instance.addPostFrameCallback((_) => c.backToLibrary());
      return const SizedBox.shrink();
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _backButton(t, c),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 300, child: _leftColumn(context, t, c, mod)),
              const SizedBox(width: 26),
              Expanded(child: _rightColumn(t, c, mod)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _backButton(GameTheme t, AppController c) {
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: c.backToLibrary,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(
                color: hovered ? t.accent : t.border, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('←',
                  style: TextStyle(fontSize: 15, color: t.text, height: 1)),
              const SizedBox(width: 7),
              Text(
                'Library',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: t.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leftColumn(
      BuildContext context, GameTheme t, AppController c, Mod mod) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66142823),
                blurRadius: 32,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Stack(
            children: [
              ModThumb(
                seed: mod.name,
                bytes: c.thumbnailOf(mod),
                borderRadius: BorderRadius.circular(16),
              ),
              Positioned(
                left: 14,
                bottom: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .28),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    mod.name,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10.5,
                      color: Colors.white.withValues(alpha: .9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Enable/disable: colored slab with an embedded switch.
        HoverBuilder(
          cursor: SystemMouseCursors.click,
          builder: (context, hovered) => GestureDetector(
            onTap: () => c.toggleMod(mod),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: mod.isEnabled ? t.accent : const Color(0x52788C87),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    mod.isEnabled ? 'Enabled' : 'Disabled',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IgnorePointer(
                    child: PillSwitch(
                      value: mod.isEnabled,
                      width: 42,
                      height: 24,
                      trackColor: Colors.white.withValues(alpha: .35),
                      onChanged: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _outlineButton(
          t,
          label: 'Show in file manager',
          color: t.accent,
          background: t.tint,
          border: t.accent,
          onTap: () => c.revealInFileManager(mod.path),
        ),
        const SizedBox(height: 10),
        _outlineButton(
          t,
          label: 'Uninstall mod',
          color: conflictOrange,
          background: Colors.transparent,
          border: conflictOrange.withValues(alpha: .4),
          hoverBackground: conflictOrange.withValues(alpha: .08),
          onTap: () => _confirmUninstall(context, t, c, mod),
        ),
      ],
    );
  }

  Widget _outlineButton(
    GameTheme t, {
    required String label,
    required Color color,
    required Color background,
    required Color border,
    Color? hoverBackground,
    required VoidCallback onTap,
  }) {
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.translationValues(
              0, hovered && hoverBackground == null ? -1 : 0, 0),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: hovered ? (hoverBackground ?? background) : background,
            border: Border.all(color: border, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmUninstall(
      BuildContext context, GameTheme t, AppController c, Mod mod) async {
    var confirmed = true;
    if (c.settings.confirmDelete) {
      c.playSound(UiSound.alert);
      confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: t.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Uninstall ${modTitle(mod)}?',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: t.text,
                ),
              ),
              content: Text(
                'The file will be deleted from disk:\n${mod.path}',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: t.muted,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('Cancel',
                      style: TextStyle(
                          color: t.muted, fontWeight: FontWeight.w800)),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style:
                      FilledButton.styleFrom(backgroundColor: conflictOrange),
                  child: const Text('Uninstall',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ) ??
          false;
    }
    if (confirmed) await c.removeMod(mod);
  }

  /// The conflict warning: what we noticed, why it matters, and the
  /// actual mods this one clashes with; each row jumps to that mod.
  Widget _conflictPanel(GameTheme t, AppController c, Mod mod) {
    final others = c.conflictingWith(mod);
    final root = c.modsDir?.path;
    String relPath(Mod other) =>
        root == null ? other.path : p.relative(other.path, from: root);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: conflictOrange.withValues(alpha: .1),
        border: Border.all(color: conflictOrange.withValues(alpha: .3)),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: conflictOrange,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  others.length == 1
                      ? 'Another enabled mod has the same file name:'
                      : '${others.length} other enabled mods have the same '
                          'file name:',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: conflictOrangeDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final other in others)
            Padding(
              padding: const EdgeInsets.only(left: 26, top: 2),
              child: HoverBuilder(
                cursor: SystemMouseCursors.click,
                builder: (context, hovered) => GestureDetector(
                  onTap: () => c.openMod(other),
                  child: Text(
                    relPath(other),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: conflictOrangeDark,
                      decoration: hovered
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      decorationColor: conflictOrangeDark,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'Identical names usually mean the same mod is installed twice, '
            'or two creators\' packages clash. The game loads their '
            'overlapping resources in an unpredictable order: keep one '
            'and disable or remove the rest.',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: conflictOrangeDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rightColumn(GameTheme t, AppController c, Mod mod) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (c.isConflicted(mod)) ...[
          _conflictPanel(t, c, mod),
          const SizedBox(height: 16),
        ],
        TagChip(label: mod.category, color: t.accent, background: t.tint),
        const SizedBox(height: 12),
        Text(
          modTitle(mod),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.1,
            color: t.text,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'in ${p.dirname(mod.path)}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: t.muted,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _fact(t, 'Format', p.extension(mod.name)),
            const SizedBox(width: 12),
            _fact(t, 'Size', formatBytes(mod.sizeBytes)),
            const SizedBox(width: 12),
            _fact(t, 'Type', mod.category),
            const SizedBox(width: 12),
            _fact(t, 'Modified', modDate(mod)),
          ],
        ),
        ..._contentsSection(t, c, mod),
        const SizedBox(height: 22),
        Text(
          'Status',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: t.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          mod.isEnabled
              ? 'This mod is active: the game will load it on next launch.'
              : 'This mod is disabled: the file is kept on disk with a '
                  '"$disabledMarker" marker so the game skips it. Enable it '
                  'any time; nothing is deleted.',
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            fontWeight: FontWeight.w600,
            color: t.muted,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          'File on disk',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: t.text,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: t.surfaceAlt,
            border: Border.all(color: t.border),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  mod.path,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: t.text,
                  ),
                ),
              ),
              Text(
                formatBytes(mod.sizeBytes),
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: t.muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// "Inside the package": counts of recognized resource kinds found by
  /// the library scan. Empty for files that aren't readable packages.
  List<Widget> _contentsSection(GameTheme t, AppController c, Mod mod) {
    final insight = c.insightFor(mod);
    if (insight == null || insight.resourceCount == 0) return const [];
    return [
      const SizedBox(height: 22),
      Text(
        'Inside the package',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: t.text,
        ),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final entry in insight.contents.entries)
            TagChip(
              label: '${entry.value} ${entry.key}',
              color: t.accent,
              background: t.tint,
            ),
          TagChip(
            label: '${insight.resourceCount} resources total',
            color: t.muted,
            background: t.surfaceAlt,
          ),
        ],
      ),
    ];
  }

  Widget _fact(GameTheme t, String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: t.surfaceAlt,
          border: Border.all(color: t.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: .5,
                color: t.muted,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: t.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// User-facing name of the disable marker ('.disabled').
const disabledMarker = '.disabled';
