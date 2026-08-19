import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../core/conflicts.dart' show ConflictReason;
import '../core/mod_advisories.dart' show AdvisoryStatus, ModAdvisory;
import '../core/game_adapter.dart' show disabledSuffix;
import '../core/mod.dart';
import '../services/mod_shop.dart' show ShopMod;
import '../services/sfx.dart';
import 'app_controller.dart';
import 'game_skin.dart';
import 'game_theme.dart';
import 'l10n.dart';
import 'mod_presentation.dart' show modDate, modTitle, modVersion;
import 'move_folder_dialog.dart';
import 'tag_dialog.dart';
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
      builder: (context, hovered) {
        final back = t.skin.ink(t, SkinSurface.button,
            state: skinState(hovered: hovered), otherwise: t.text);
        return GestureDetector(
        onTap: c.backToLibrary,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: t.skin.decorate(t, SkinSurface.button,
              radius: 10,
              state: skinState(hovered: hovered),
              fill: t.surface,
              outline: hovered ? t.accent : t.border),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('←',
                  style: TextStyle(fontSize: 15, color: back, height: 1)),
              const SizedBox(width: 7),
              Text(
                l.navLibrary,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: back,
                ),
              ),
            ],
          ),
        ),
        );
      },
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
          builder: (context, hovered) {
            final colour = mod.isEnabled ? t.accent : t.switchOff;
            // The skin says what the label is; a skin that answers white
            // needs the slab dark enough to carry it, and one that paints
            // its own lettering (the Medieval's brown on parchment) must
            // keep the colour it was given.
            //
            // The colour has to go along, even though the fill below is
            // built out of the answer: a skin whose lettering follows the
            // material cannot answer without it, and asked bare it would
            // answer for a plate this row is not made of. `switchOff` is
            // translucent and the skin composites it onto the surface,
            // which is exactly where the two used to part company - a
            // white word ordered for a slab that had come out pale.
            final ink = t.skin.ink(t, SkinSurface.row,
                state: SkinState.active, fill: colour, otherwise: Colors.white);
            final slab = ink == Colors.white ? bearsWhite(colour) : colour;
            return GestureDetector(
            onTap: () => c.toggleMod(mod),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              // A row rather than a primary: it carries no ring and no
              // glow, and switching a mod off has to look like the same
              // control gone quiet rather than a different one.
              decoration: t.skin.decorate(t, SkinSurface.row,
                  radius: 12,
                  state: SkinState.active,
                  fill: slab),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    mod.isEnabled ? l.enabled : l.disabled,
                    style: TextStyle(
                      color: ink,
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
            );
          },
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
        // Not for a mod the app has no business moving - The Sims 1 keeps
        // skins and walls in folders of the game's own, and which file
        // belongs in which of those is the adapter's answer.
        if (c.canMoveMods && c.canMove(mod)) ...[
          const SizedBox(height: 10),
          _outlineButton(
            t,
            label: l.selectionMove,
            color: t.text,
            background: Colors.transparent,
            border: t.border,
            hoverBackground: t.surfaceAlt,
            onTap: () => askWhereToMove(context, c,
                theme: t, mods: [mod], method: 'detail'),
          ),
        ],
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
          decoration: t.skin.decorate(t, SkinSurface.button,
              radius: 12,
              state: skinState(hovered: hovered),
              // The label's colour is what this button is *about* -
              // uninstall speaks in the warning orange - unless it is
              // just the text colour, which says nothing and leaves the
              // material to the skin.
              accent: color == t.text ? null : color,
              fill: hovered ? (hoverBackground ?? background) : background,
              outline: border),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: t.skin.ink(t, SkinSurface.button,
                  state: skinState(hovered: hovered),
                  accent: color == t.text ? null : color,
                  otherwise: color),
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

  /// What the published advisory list says about this mod: the wording
  /// for its status, whatever the entry itself carries (its title, when
  /// it started, a note, a link to the fix), and a reminder that this is
  /// other players talking rather than anything the app worked out.
  Widget _advisoryPanel(GameTheme t, AppController c, L l, ModAdvisory a) {
    final heading = switch (a.status) {
      AdvisoryStatus.broken => l.advisoryBrokenHeading,
      AdvisoryStatus.outdated => l.advisoryOutdatedHeading,
      AdvisoryStatus.caution => l.advisoryCautionHeading,
    };
    final body = switch (a.status) {
      AdvisoryStatus.broken => l.advisoryBrokenBody,
      AdvisoryStatus.outdated => l.advisoryOutdatedBody,
      AdvisoryStatus.caution => l.advisoryCautionBody,
    };
    final since = a.since;
    final note = a.note;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: t.skin
          .decorate(t, SkinSurface.notice, radius: 11, accent: t.warning),
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
                  heading,
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
          // The name the list knows it by, which is worth showing because
          // it needn't be the name of the file on this machine: a mod
          // matched on its contents may have been renamed by anyone.
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              since == null ? a.title : '${a.title} · ${l.advisorySince(since)}',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: t.onWarningTint,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            note == null ? body : '$body\n\n$note',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: t.onWarningTint,
            ),
          ),
          if (a.url != null) ...[
            const SizedBox(height: 8),
            HoverBuilder(
              cursor: SystemMouseCursors.click,
              builder: (context, hovered) => GestureDetector(
                onTap: () => c.openAdvisoryUrl(a),
                child: Text(
                  l.advisoryOpenLink,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: t.warning,
                    decoration: hovered
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationColor: t.warning,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            l.advisorySource,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: t.onWarningTint.withValues(alpha: .75),
            ),
          ),
        ],
      ),
    );
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
      return '${relPath(other)} - ${l.sharedResources(shared)}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: t.skin.decorate(t, SkinSurface.notice,
          radius: 11,
          accent: t.warning,
          outline: t.warning.withValues(alpha: .3)),
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
                    ConflictReason.exactDuplicate =>
                      l.conflictSameFileHeading(others.length),
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
              child: Row(
                children: [
                  Flexible(
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
                  const SizedBox(width: 10),
                  _ignoreConflictButton(
                      t, l, () => c.ignoreConflict(mod, other)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            switch (reason) {
              ConflictReason.exactDuplicate => l.conflictSameFileBody,
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

  /// "Ignore": settles one clash of the pair it sits on. Small and quiet
  /// next to the mod it belongs to, because it is an answer about that
  /// one row and not about the warning as a whole.
  Widget _ignoreConflictButton(GameTheme t, L l, VoidCallback onTap) {
    return Tooltip(
      message: l.conflictIgnoreTooltip,
      child: HoverBuilder(
        cursor: SystemMouseCursors.click,
        builder: (context, hovered) => GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: t.skin.decorate(t, SkinSurface.button,
                radius: 7,
                state: skinState(hovered: hovered),
                accent: t.warning,
                fill: hovered
                    ? t.warning.withValues(alpha: .18)
                    : Colors.transparent,
                outline: t.warning.withValues(alpha: .45)),
            child: Text(
              l.conflictIgnore,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: t.skin.ink(t, SkinSurface.button,
                    state: skinState(hovered: hovered),
                    accent: t.warning,
                    otherwise: t.onWarningTint),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// "You're ignoring N of this mod's clashes": the way back, on the mod
  /// it was settled from. Drawn only when the scan is still finding those
  /// clashes, so it says nothing about a mod whose partner has gone.
  Widget _ignoredConflictsFact(
      GameTheme t, AppController c, L l, Mod mod, int count) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: t.skin
          .decorate(t, SkinSurface.panel, radius: 12, fill: t.surfaceAlt),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.factIgnoredConflicts.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .5,
                    color: t.muted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  l.ignoredConflictsCount(count),
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: t.text,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          HoverBuilder(
            cursor: SystemMouseCursors.click,
            builder: (context, hovered) => GestureDetector(
              onTap: () => c.restoreConflicts(mod),
              child: Text(
                l.conflictRestore,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: t.accent,
                  decoration:
                      hovered ? TextDecoration.underline : TextDecoration.none,
                  decorationColor: t.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The mod's own labels, and the way onto it: a chip each, an x to take
  /// one off, and a button that opens the same dialog the selection bar
  /// does. Drawn even with nothing on it, because a mod's page is where
  /// someone goes looking for where tags are put on in the first place.
  Widget _tagsSection(GameTheme t, AppController c, L l, Mod mod) {
    final tags = c.tagsOf(mod);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Icon(Icons.sell_rounded, size: 15, color: t.muted),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final tag in tags) _tagChip(t, c, l, mod, tag),
                HoverBuilder(
                  cursor: SystemMouseCursors.click,
                  builder: (context, hovered) => GestureDetector(
                    onTap: () => askAboutTags(context, c,
                        theme: t, mods: [mod]),
                    child: Text(
                      tags.isEmpty ? l.tagAddFirst : '+',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: t.accent,
                        decoration: hovered
                            ? TextDecoration.underline
                            : TextDecoration.none,
                        decorationColor: t.accent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagChip(GameTheme t, AppController c, L l, Mod mod, String tag) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
      decoration: t.skin.decorate(t, SkinSurface.chip,
          radius: 20,
          fill: t.tint,
          outline: t.accent.withValues(alpha: .4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: t.skin.ink(t, SkinSurface.chip, otherwise: t.accent),
            ),
          ),
          const SizedBox(width: 4),
          Tooltip(
            message: l.tagRemove(tag),
            waitDuration: const Duration(milliseconds: 500),
            child: HoverBuilder(
              cursor: SystemMouseCursors.click,
              builder: (context, hovered) => GestureDetector(
                onTap: () => c.removeTag([mod], tag),
                child: Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: t.accent.withValues(alpha: hovered ? 1 : .55),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// "The creator published a new version": the accent-tinted twin of the
  /// advisory panel, for a mod that came from The Exchange and has a
  /// newer version waiting there. The button installs it on the spot,
  /// the same one click the shelves offer.
  Widget _shopUpdatePanel(
      GameTheme t, AppController c, L l, ShopMod listing) {
    final installing = c.shopProgress.containsKey(listing.id);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
      decoration: t.skin
          .decorate(t, SkinSurface.notice, radius: 14, fill: t.tint),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.arrow_circle_down_rounded, size: 19, color: t.accent),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  l.shopUpdateHeading,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: t.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            l.shopUpdateBody(listing.version, listing.authorName),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.5,
              color: t.text,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton(
                onPressed:
                    installing ? null : () => c.installShopMod(listing),
                style: FilledButton.styleFrom(
                  backgroundColor: t.accent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 13),
                ),
                child: Text(installing ? l.shopInstalling : l.shopUpdate),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () => c.openShop(gameId: listing.gameId),
                style: TextButton.styleFrom(
                  foregroundColor: t.muted,
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 13),
                ),
                child: Text(l.shopUpdateSeeListing),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rightColumn(GameTheme t, AppController c, L l, Mod mod) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (c.advisoryOf(mod) case final advisory?) ...[
          _advisoryPanel(t, c, l, advisory),
          const SizedBox(height: 16),
        ],
        if (c.isConflicted(mod)) ...[
          _conflictPanel(t, c, l, mod),
          const SizedBox(height: 16),
        ],
        if (c.shopUpdateForMod(mod) case final listing?) ...[
          _shopUpdatePanel(t, c, l, listing),
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
        if (c.ignoredConflictsOf(mod) case final ignored when ignored > 0) ...[
          const SizedBox(height: 12),
          _ignoredConflictsFact(t, c, l, mod, ignored),
        ],
        _tagsSection(t, c, l, mod),
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
          decoration: t.skin
              .decorate(t, SkinSurface.panel, radius: 9, fill: t.surfaceAlt),
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
        decoration: t.skin
            .decorate(t, SkinSurface.panel, radius: 12, fill: t.surfaceAlt),
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
