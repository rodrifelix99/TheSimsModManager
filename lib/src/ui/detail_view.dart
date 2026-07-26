import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../core/conflicts.dart' show ConflictReason;
import '../core/game_adapter.dart' show disabledSuffix;
import '../core/mod.dart';
import '../services/sfx.dart';
import 'app_controller.dart';
import 'game_theme.dart';
import 'l10n.dart';
import 'mod_presentation.dart' show modDate, modTitle, modVersion;
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
    final l = L.of(context);
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
          _backButton(t, c, l),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 300, child: _leftColumn(context, t, c, l, mod)),
              const SizedBox(width: 26),
              Expanded(child: _rightColumn(t, c, l, mod)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _backButton(GameTheme t, AppController c, L l) {
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
                l.navLibrary,
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
      BuildContext context, GameTheme t, AppController c, L l, Mod mod) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: t.shadow.withValues(alpha: .4),
                blurRadius: 32,
                offset: const Offset(0, 16),
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
                color: mod.isEnabled ? t.accent : t.switchOff,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    mod.isEnabled ? l.enabled : l.disabled,
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
                      activeColor: t.accent,
                      inactiveColor: t.switchOff,
                      shadow: t.shadow,
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
          label: l.showInFileManager,
          color: t.accent,
          background: t.tint,
          border: t.accent,
          onTap: () => c.revealInFileManager(mod.path),
        ),
        const SizedBox(height: 10),
        _outlineButton(
          t,
          label: l.uninstallMod,
          color: t.warning,
          background: Colors.transparent,
          border: t.warning.withValues(alpha: .4),
          hoverBackground: t.warning.withValues(alpha: .08),
          onTap: () => _confirmUninstall(context, t, c, l, mod),
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

  Future<void> _confirmUninstall(BuildContext context, GameTheme t,
      AppController c, L l, Mod mod) async {
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
                l.uninstallConfirmTitle(modTitle(mod)),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: t.text,
                ),
              ),
              content: Text(
                l.uninstallConfirmBody(mod.path),
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: t.muted,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l.cancel,
                      style: TextStyle(
                          color: t.muted, fontWeight: FontWeight.w800)),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  style:
                      FilledButton.styleFrom(backgroundColor: t.warning),
                  child: Text(l.uninstall,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
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
  Widget _conflictPanel(GameTheme t, AppController c, L l, Mod mod) {
    final others = c.conflictingWith(mod);
    final reason = c.conflictReasonOf(mod) ?? ConflictReason.resourceOverlap;
    final root = c.modsDir?.path;
    String relPath(Mod other) =>
        root == null ? other.path : p.relative(other.path, from: root);
    String rowLabel(Mod other) {
      final shared = c.sharedResourcesWith(mod, other);
      if (shared == 0) return relPath(other);
      return '${relPath(other)} — ${l.sharedResources(shared)}';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: t.warning.withValues(alpha: .1),
        border: Border.all(color: t.warning.withValues(alpha: .3)),
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
                decoration: BoxDecoration(
                  color: t.warning,
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
                  switch (reason) {
                    ConflictReason.duplicateName =>
                      l.conflictSameNameHeading(others.length),
                    ConflictReason.versionPair =>
                      l.conflictVersionHeading(others.length),
                    ConflictReason.resourceOverlap =>
                      l.conflictResourcesHeading(others.length),
                  },
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: t.onWarningTint,
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
                    rowLabel(other),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: t.onWarningTint,
                      decoration: hovered
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      decorationColor: t.onWarningTint,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            switch (reason) {
              ConflictReason.duplicateName => l.conflictSameNameBody,
              ConflictReason.versionPair => l.conflictVersionBody,
              ConflictReason.resourceOverlap => l.conflictResourcesBody,
            },
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: t.onWarningTint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _rightColumn(GameTheme t, AppController c, L l, Mod mod) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (c.isConflicted(mod)) ...[
          _conflictPanel(t, c, l, mod),
          const SizedBox(height: 16),
        ],
        TagChip(
            label: l.categoryName(mod.category),
            color: t.accent,
            background: t.tint),
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
          l.modInDirectory(p.dirname(mod.path)),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: t.muted,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            if (modVersion(mod) != null) ...[
              _fact(t, l.factVersion, modVersion(mod)!),
              const SizedBox(width: 12),
            ],
            _fact(t, l.factFormat, p.extension(mod.name)),
            const SizedBox(width: 12),
            _fact(t, l.factSize, formatBytes(mod.sizeBytes)),
            const SizedBox(width: 12),
            _fact(t, l.factType, l.categoryName(mod.category)),
            const SizedBox(width: 12),
            _fact(t, l.factModified, modDate(mod)),
          ],
        ),
        ..._contentsSection(t, c, l, mod),
        const SizedBox(height: 22),
        Text(
          l.statusHeading,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: t.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          mod.isEnabled
              ? l.statusEnabledBody
              : l.statusDisabledBody(disabledSuffix),
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            fontWeight: FontWeight.w600,
            color: t.muted,
          ),
        ),
        const SizedBox(height: 22),
        Text(
          l.fileOnDisk,
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
  List<Widget> _contentsSection(
      GameTheme t, AppController c, L l, Mod mod) {
    final insight = c.insightFor(mod);
    if (insight == null || insight.resourceCount == 0) return const [];
    return [
      const SizedBox(height: 22),
      Text(
        l.insideThePackage,
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
              label: '${entry.value} ${l.contentLabel(entry.key)}',
              color: t.accent,
              background: t.tint,
            ),
          TagChip(
            label: l.resourcesTotal(insight.resourceCount),
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
