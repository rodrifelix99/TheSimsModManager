import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/creation.dart';
import '../services/sfx.dart';
import 'app_controller.dart';
import 'game_skin.dart';
import 'game_theme.dart';
import 'l10n.dart';
import 'widgets.dart';

/// The Creations screen: the lots, rooms, households and sims the player
/// built or downloaded, as the game's own folders hold them.
///
/// Deliberately a shelf of pictures rather than a list of rows. Every
/// other screen in the app is about files whose names are the only thing
/// there is to go on; these carry the game's own catalog render, and a
/// house is a thing you recognise by looking at it. So the card is mostly
/// the picture, and everything else is underneath it.
///
/// Nothing here can be enabled or disabled, because the game has no such
/// idea for this content: a lot is in your library or it is not. The two
/// actions are the two that exist - put one in, take one out.
class CreationsView extends StatelessWidget {
  const CreationsView(
      {super.key, required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final open = controller.openCreation;
    if (open != null) {
      return _CreationDetail(
          theme: theme, controller: controller, creation: open);
    }

    final creations = controller.creations;
    if (controller.creationsLoading && creations == null) {
      return _Scanning(theme: theme);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(theme: theme, controller: controller),
        if (creations == null || creations.isEmpty)
          Expanded(child: _EmptyState(theme: theme, controller: controller))
        else
          Expanded(child: _Shelf(theme: theme, controller: controller)),
      ],
    );
  }
}

class _Scanning extends StatelessWidget {
  const _Scanning({required this.theme});

  final GameTheme theme;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                  strokeWidth: 3, color: theme.accent),
            ),
            const SizedBox(height: 16),
            Text(
              L.of(context).creationsScanning,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: theme.muted),
            ),
          ],
        ),
      );
}

class _Header extends StatelessWidget {
  const _Header({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    final counts = c.creationKindCounts;
    final total = c.creations?.length ?? 0;

    // The same header every sibling screen has: the screen's name, what
    // it holds underneath in muted text, and the actions pinned to the
    // right edge by an Expanded title. The packs shelf and the saves tab
    // are both built this way and it is what makes them read as one app.
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.navCreations,
                        style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            color: t.text)),
                    const SizedBox(height: 4),
                    Text(
                      l.creationsCount(total),
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: t.muted),
                    ),
                  ],
                ),
              ),
              _RefreshButton(theme: t, controller: c),
              const SizedBox(width: 12),
              _AddButton(theme: t, controller: c),
            ],
          ),
          if (counts.length > 1) ...[
            const SizedBox(height: 14),
            _KindChips(theme: t, controller: c, counts: counts),
          ],
        ],
      ),
    );
  }
}

/// Rescanning the folders. An icon on the skin's own button plate, the
/// way the library draws the same action: a secondary sitting beside a
/// primary is an icon here, because `accentButtonStyle` is a Material
/// style that cannot carry a gradient or a bevel, and an outlined text
/// button next to a skinned plate reads as a control from another app.
class _RefreshButton extends StatelessWidget {
  const _RefreshButton({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final busy = c.creationBusy || c.creationsLoading;
    return Tooltip(
      message: L.of(context).creationsRefresh,
      child: HoverBuilder(
        cursor: busy ? SystemMouseCursors.basic : SystemMouseCursors.click,
        builder: (context, hovered) => GestureDetector(
          onTap: busy ? null : c.refreshCreations,
          child: Opacity(
            opacity: busy ? .5 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 34,
              height: 40,
              decoration: t.skin.decorate(t, SkinSurface.button,
                  state: skinState(hovered: hovered && !busy)),
              child: Icon(
                Icons.refresh_rounded,
                size: 18,
                color: t.skin.ink(t, SkinSurface.button,
                    state: skinState(hovered: hovered && !busy),
                    secondary: !hovered,
                    otherwise: hovered && !busy ? t.accent : t.muted),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The screen's loud action, drawn the way the library's Install button
/// is: the skin's own `primary` material, its own label colour, and the
/// one-pixel lift on hover. A Material `FilledButton` cannot carry a
/// gradient or a bevel, so a skinned game would have got a flat slab of
/// accent where every other primary in the app is a plate.
class _AddButton extends StatelessWidget {
  const _AddButton({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    final busy = c.creationBusy;
    return HoverBuilder(
      cursor: busy ? SystemMouseCursors.basic : SystemMouseCursors.click,
      builder: (context, hovered) {
        final ink = t.skin.ink(t, SkinSurface.primary);
        return GestureDetector(
          onTap: busy ? null : () => _pickAndAdd(c, l),
          child: Opacity(
            opacity: busy ? .6 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              transform:
                  Matrix4.translationValues(0, hovered && !busy ? -1 : 0, 0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: t.skin.decorate(t, SkinSurface.primary,
                  state: skinState(hovered: hovered && !busy)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('＋',
                      style: TextStyle(
                          color: ink,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          height: 1)),
                  const SizedBox(width: 6),
                  Text(
                    busy ? l.creationsAdding : l.creationsAdd,
                    style: TextStyle(
                        color: ink,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Picks downloaded content and files it away.
///
/// The picker takes archives as well as loose files, because that is how
/// a household of five files is actually shared; which of the game's
/// folders each one belongs in is worked out from the files themselves,
/// so there is nothing to ask the user first.
Future<void> _pickAndAdd(AppController c, L l) async {
  c.playSound(UiSound.click);
  final files = await openFiles(acceptedTypeGroups: [
    XTypeGroup(
      label: l.creationsPickerLabel(c.adapter.game.name),
      extensions: [
        for (final e in c.creationPickerExtensions) e.replaceFirst('.', ''),
      ],
    ),
  ]);
  if (files.isEmpty) return;
  await c.addCreations([for (final file in files) file.path]);
}

/// One chip per kind the folder actually holds, plus the way back to all
/// of them. Multi-select with the same chord as the library's folder
/// chips: plain click means "just this one", ctrl or cmd adds.
class _KindChips extends StatelessWidget {
  const _KindChips(
      {required this.theme, required this.controller, required this.counts});

  final GameTheme theme;
  final AppController controller;
  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Chip(
          theme: t,
          label: L.of(context).creationsAll,
          selected: c.selectedCreationKinds.isEmpty,
          onTap: (_) => c.clearCreationKinds(),
        ),
        for (final entry in counts.entries)
          _Chip(
            theme: t,
            label: '${L.of(context).creationKind(entry.key)}  ${entry.value}',
            selected: c.selectedCreationKinds.contains(entry.key),
            onTap: (add) => c.toggleCreationKind(entry.key, add: add),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.theme,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final GameTheme theme;
  final String label;
  final bool selected;

  /// True when ctrl or cmd was down, which means "add to what is lit".
  final void Function(bool add) onTap;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return HoverBuilder(
      builder: (context, hovered) => GestureDetector(
        onTap: () {
          final keys = HardwareKeyboard.instance;
          onTap(keys.isControlPressed || keys.isMetaPressed);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: t.skin.decorate(t, SkinSurface.chip,
              radius: 999,
              state: skinState(hovered: hovered, active: selected),
              fill: selected ? t.surfaceAlt : t.surface,
              outline: selected ? t.accent : t.border),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: t.skin.ink(t, SkinSurface.chip,
                  state: skinState(hovered: hovered, active: selected),
                  otherwise: selected ? t.accent : t.muted),
            ),
          ),
        ),
      ),
    );
  }
}

/// The shelf. A wrap of fixed-width cards rather than a grid with a fixed
/// column count, so the window can be any width and the cards stay the
/// size the pictures are worth.
class _Shelf extends StatelessWidget {
  const _Shelf({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final visible = controller.visibleCreations;
    if (visible.isEmpty) {
      return Center(
        child: Text(
          L.of(context).creationsNoneOfKind,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700, color: theme.muted),
        ),
      );
    }
    // The library's own grid, down to the divisor: a shelf whose cards
    // are a different width from the ones a click away reads as another
    // app's screen. Taller than a mod card because a creation leads with
    // its picture and a mod leads with its name.
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / 320).floor().clamp(1, 4);
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(28, 4, 28, 28),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 230,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: visible.length,
          itemBuilder: (context, i) => _CreationCard(
              theme: theme, controller: controller, creation: visible[i]),
        );
      },
    );
  }
}

class _CreationCard extends StatelessWidget {
  const _CreationCard({
    required this.theme,
    required this.controller,
    required this.creation,
  });

  final GameTheme theme;
  final AppController controller;
  final Creation creation;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final l = L.of(context);
    return HoverBuilder(
      builder: (context, hovered) => GestureDetector(
          onTap: () => controller.selectCreation(creation),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            decoration: t.skin.decorate(t, SkinSurface.panel,
                radius: 14,
                state: skinState(hovered: hovered),
                fill: hovered ? t.surfaceAlt : t.surface,
                outline: hovered ? t.accent : t.border),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // The picture takes whatever the card has left after the
                // caption, so it grows with the column width instead of
                // leaving a band of panel under it.
                Expanded(child: _Thumbnail(theme: t, creation: creation)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(11, 9, 11, 11),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        creation.name,
                        style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: t.text),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        [
                          l.creationKind(creation.kindKey),
                          if (creation.sizeBytes > 0)
                            formatBytes(creation.sizeBytes),
                        ].join(' · '),
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: t.muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}

/// The game's own render, or the kind's initial where there is none.
///
/// A creation with no picture is normal rather than broken - the Sims 1
/// writes one only once the house has been visited, and a package that
/// half-decoded still deserves a card - so the fallback is a plain tile
/// in the game's colours rather than a broken-image mark.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.theme, required this.creation, this.height});

  final GameTheme theme;
  final Creation creation;

  /// Null lets the picture take whatever room its parent gives it, which
  /// is what a grid cell wants; the detail page names a height instead.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final bytes = creation.thumbnail;
    final blank = Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      color: theme.surfaceAlt,
      child: bytes != null
          ? null
          : Text(
              L.of(context).creationKind(creation.kindKey),
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: theme.muted),
            ),
    );
    if (bytes == null) return blank;
    return Image.memory(
      bytes,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (context, _, __) => blank,
    );
  }
}

/// One creation's own page: the picture at full size, what the format
/// gave up about it, and the two actions.
class _CreationDetail extends StatelessWidget {
  const _CreationDetail({
    required this.theme,
    required this.controller,
    required this.creation,
  });

  final GameTheme theme;
  final AppController controller;
  final Creation creation;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    // Held to a readable column rather than run to the window's edge: the
    // page is a picture and a few facts, and a 260px image floating in a
    // thousand points of panel is what it looked like without this.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          _BackButton(theme: t, onTap: c.closeCreation),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _Thumbnail(theme: t, creation: creation, height: 300),
          ),
          const SizedBox(height: 16),
          Text(
            creation.name,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w900, color: t.text),
          ),
          const SizedBox(height: 5),
          Text(
            [
              l.creationKind(creation.kindKey),
              if (creation.creatorName case final by?) l.creationsBy(by),
              if (creation.worldName case final world?) world,
              if (creation.sizeBytes > 0) formatBytes(creation.sizeBytes),
            ].join(' · '),
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: t.muted),
          ),
          if (creation.description case final blurb?) ...[
            const SizedBox(height: 16),
            Text(
              blurb,
              style: TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: t.text),
            ),
          ],
          if (creation.sims.isNotEmpty) ...[
            const SizedBox(height: 22),
            Text(l.creationsWhoLivesHere, style: eyebrowStyle(t)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final sim in creation.sims) _SimCard(theme: t, sim: sim),
              ],
            ),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  theme: t,
                  label: l.creationsShowInFolder,
                  color: t.accent,
                  onTap: () => c.revealCreation(creation),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  theme: t,
                  label: l.creationsDelete,
                  color: t.warning,
                  onTap: c.creationBusy
                      ? null
                      : () => _confirmRemove(context, t, c, creation),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l.creationsFileCount(creation.allFiles.length),
            style: TextStyle(
                fontSize: 11.5, fontWeight: FontWeight.w600, color: t.muted),
          ),
          ],
        ),
      ),
    );
  }
}

/// The way back to the shelf. A row of its own rather than a Material
/// TextButton, so it carries the app's weight and colour like every other
/// quiet control.
class _BackButton extends StatelessWidget {
  const _BackButton({required this.theme, required this.onTap});

  final GameTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => HoverBuilder(
        cursor: SystemMouseCursors.click,
        builder: (context, hovered) => GestureDetector(
          onTap: onTap,
          child: Text(
            L.of(context).creationsBack,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: hovered ? theme.accent : theme.muted,
            ),
          ),
        ),
      );
}

/// The detail page's two actions, on the skin's own button plate - the
/// same control `detail_view` draws under a mod, so a creation's page and
/// a mod's page end the same way.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.theme,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final GameTheme theme;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final off = onTap == null;
    return HoverBuilder(
      cursor: off ? SystemMouseCursors.basic : SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: onTap,
        child: Opacity(
          opacity: off ? .5 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform:
                Matrix4.translationValues(0, hovered && !off ? -1 : 0, 0),
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: t.skin.decorate(t, SkinSurface.button,
                radius: 12,
                state: skinState(hovered: hovered && !off),
                accent: color,
                fill: color.withValues(alpha: hovered && !off ? .16 : .08),
                outline: color),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: t.skin.ink(t, SkinSurface.button,
                    state: skinState(hovered: hovered && !off),
                    accent: color,
                    otherwise: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SimCard extends StatelessWidget {
  const _SimCard({required this.theme, required this.sim});

  final GameTheme theme;
  final CreationSim sim;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final l = L.of(context);
    // The same life-stage and gender words the saves tab uses: these are
    // the games' own enums and a tray item spells them the same way.
    final facts = [
      if (sim.ageKey case final age?) l.savesAge(age),
      if (sim.genderKey case final gender?) l.savesGender(gender),
    ].join(' · ');
    return Container(
      // Wide enough for "Young adult · Masculine" on one line, which is
      // the longest the facts row gets and was being cut to "Masc...".
      width: 250,
      padding: const EdgeInsets.all(11),
      decoration: t.skin.decorate(t, SkinSurface.well,
          radius: 12, fill: t.surfaceAlt, outline: t.border),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sim.portrait case final portrait?)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(portrait,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder: (context, _, __) => const SizedBox(
                      width: 40, height: 40)),
            )
          else
            const SizedBox.shrink(),
          if (sim.portrait != null) const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sim.fullName,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: t.text),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (facts.isNotEmpty)
                  Text(
                    facts,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: t.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (sim.aspiration case final aspiration?)
                  Text(
                    aspiration,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: t.accent),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (sim.traits.isNotEmpty)
                  Text(
                    sim.traits.join(', '),
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: t.muted),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Nothing on the shelf. Two different nothings, and they need different
/// words: a game with no folder at all has not been set up, while an
/// empty folder is somebody who has not saved anything yet.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final l = L.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.creationsEmptyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w900, color: t.text),
            ),
            const SizedBox(height: 8),
            Text(
              l.creationsEmptyBody,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                  color: t.muted),
            ),
            const SizedBox(height: 18),
            // The same button as the header's. This is the screen a new
            // user lands on, and "drop it on the window" is a worse first
            // instruction than something to press.
            _AddButton(theme: t, controller: controller),
          ],
        ),
      ),
    );
  }
}

/// Deleting takes every file the creation is made of and there is no
/// undo, so the count is on the dialog: a household is five files and
/// somebody who expected one should see that before pressing it.
Future<void> _confirmRemove(
  BuildContext context,
  GameTheme t,
  AppController c,
  Creation creation,
) async {
  final l = L.of(context);
  c.playSound(UiSound.open);
  final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: t.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            l.creationsDeleteTitle(creation.name),
            style: TextStyle(
                fontWeight: FontWeight.w900, fontSize: 18, color: t.text),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.creationsDeleteBody,
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: t.muted),
              ),
              const SizedBox(height: 10),
              Text(
                l.creationsFileCount(creation.allFiles.length),
                style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: t.warning),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.cancel,
                  style:
                      TextStyle(color: t.muted, fontWeight: FontWeight.w800)),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(backgroundColor: t.warning),
              child: Text(l.creationsDelete,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ) ??
      false;
  if (confirmed) await c.removeCreation(creation);
}
