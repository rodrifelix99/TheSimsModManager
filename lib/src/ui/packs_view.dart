import 'package:flutter/material.dart';

import '../core/app_message.dart';
import '../core/game_pack.dart';
import 'app_controller.dart';
import 'game_skin.dart';
import 'game_theme.dart';
import 'l10n.dart';
import 'pack_icons.dart';
import 'widgets.dart';

/// The Packs screen: the publisher's own content installed beside the
/// game - expansions, game packs, stuff packs, kits - and, for the games
/// that allow it, a switch per pack.
///
/// Deliberately not the library. A mod is the user's file and the app
/// moves it around; a pack belongs to the game, so nothing here writes
/// into a pack's folder. Switching one off only changes the game's own
/// record of what to load, which is why the screen says to restart the
/// game rather than pretending anything happened right away.
class PacksView extends StatelessWidget {
  const PacksView({super.key, required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    final packs = c.gamePacks;

    if (c.packsLoading && packs == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(strokeWidth: 3, color: t.accent),
            ),
            const SizedBox(height: 16),
            Text(
              l.packsScanning,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: t.muted),
            ),
          ],
        ),
      );
    }
    if (packs == null || packs.isEmpty) {
      return _EmptyState(theme: t, controller: c);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(theme: t, controller: c),
        if (c.packsAreExperimental) _ExperimentalNotice(theme: t, controller: c),
        if (c.packsNeedAdmin) _AdminNotice(theme: t),
        if (c.hasPendingPackChanges) _RestartNotice(theme: t, controller: c),
        if (c.packCollectionNote case final note?)
          _CollectionNote(theme: t, note: note),
        Expanded(child: _PackList(theme: t, controller: c, packs: packs)),
      ],
    );
  }
}

/// The screen's rows, flattened: a section header per tier followed by
/// its packs. One lazy list rather than a column of lists, because an
/// install with every kit is a hundred and more rows and only the ones on
/// screen are worth building - the same bargain the library's Folders
/// layout makes.
sealed class _Row {
  const _Row();
}

class _SectionRow extends _Row {
  const _SectionRow(this.kind, this.count);
  final GamePackKind kind;
  final int count;
}

class _PackRow extends _Row {
  const _PackRow(this.pack);
  final GamePack pack;
}

List<_Row> _rowsFor(List<GamePack> packs) {
  final rows = <_Row>[];
  for (final kind in GamePackKind.values) {
    final ofKind = [for (final pack in packs) if (pack.kind == kind) pack];
    if (ofKind.isEmpty) continue;
    rows.add(_SectionRow(kind, ofKind.length));
    rows.addAll(ofKind.map(_PackRow.new));
  }
  return rows;
}

class _PackList extends StatelessWidget {
  const _PackList(
      {required this.theme, required this.controller, required this.packs});

  final GameTheme theme;
  final AppController controller;
  final List<GamePack> packs;

  @override
  Widget build(BuildContext context) {
    final rows = _rowsFor(packs);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(28, 4, 28, 28),
      itemCount: rows.length,
      itemBuilder: (context, index) => switch (rows[index]) {
        _SectionRow(:final kind, :final count) => Padding(
            padding: EdgeInsets.only(top: index == 0 ? 8 : 22, bottom: 10),
            child: Row(
              children: [
                Text(L.of(context).packKindPlural(kind), style: eyebrowStyle(theme)),
                const SizedBox(width: 8),
                Text('$count',
                    style: eyebrowStyle(theme).copyWith(color: theme.accent)),
              ],
            ),
          ),
        _PackRow(:final pack) =>
          _PackTile(theme: theme, controller: controller, pack: pack),
      },
    );
  }
}

class _PackTile extends StatelessWidget {
  const _PackTile(
      {required this.theme, required this.controller, required this.pack});

  final GameTheme theme;
  final AppController controller;
  final GamePack pack;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    final on = pack.isEnabled;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: HoverBuilder(
        builder: (context, hovered) => AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: t.skin.decorate(t, SkinSurface.panel,
              radius: 14,
              state: skinState(hovered: hovered),
              fill: hovered ? t.surfaceAlt : t.surface,
              outline: t.border),
          child: Row(
            children: [
              _PackIcon(
                  theme: t, pack: pack, gameId: c.adapter.game.id),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pack.nameFor(Localizations.localeOf(context).languageCode),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        // A pack that will not load reads as quiet rather
                        // than as missing: it is still installed.
                        color: on ? t.text : t.muted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      [
                        pack.code,
                        if (pack.sizeBytes != null && pack.sizeBytes! > 0)
                          formatBytes(pack.sizeBytes),
                        if (!on) l.packsOff,
                      ].join(' · '),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: on ? t.muted : t.warning,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (c.canTogglePacks && pack.canToggle)
                PillSwitch(
                  value: on,
                  onChanged: () => c.setPackEnabled(pack, enabled: !on),
                  activeColor: t.accent,
                  inactiveColor: t.switchOff,
                  shadow: t.shadow,
                )
              else
                Text(
                  l.packsInstalled,
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: t.muted),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The pack's artwork, from whichever of the two places it can be had.
///
/// The Sims 3 keeps an icon per pack beside its executable, so those come
/// off the player's own disk and are always exactly the pack they have.
/// The other games ship nothing a reader can reach - the artwork is
/// either in a format nothing here decodes, shared between packs, or gone
/// entirely because the expansion merged on install - so for those the
/// app ships its own, keyed by the code the game itself uses.
///
/// Neither is guaranteed, and a pack with no picture draws its code
/// instead. That is a real answer rather than a placeholder: `EP04` is
/// what the game calls the pack and what every guide about it says.
class _PackIcon extends StatelessWidget {
  const _PackIcon(
      {required this.theme, required this.pack, required this.gameId});

  final GameTheme theme;
  final GamePack pack;
  final String gameId;

  /// Twice the drawn size, so the artwork stays sharp on a scaled display
  /// without holding a 256-pixel bitmap per pack for a 42-pixel slot.
  static const _decodeWidth = 84;

  @override
  Widget build(BuildContext context) {
    final fallback = _CodeTile(theme: theme, pack: pack);
    final icon = pack.icon;
    final asset = icon == null ? packIconAsset(gameId, pack.code) : null;
    if ((icon == null || icon.isEmpty) && asset == null) return fallback;
    return SizedBox(
      width: 42,
      height: 42,
      child: Opacity(
        // A pack that will not load reads as quiet, not as missing.
        opacity: pack.isEnabled ? 1 : .45,
        // Contained rather than cropped: these arrive as square icons,
        // upright box art and wide wordmarks, and cropping to a square
        // would take the name off the ones that are mostly name.
        child: icon != null && icon.isNotEmpty
            ? Image.memory(
                icon,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                cacheWidth: _decodeWidth,
                errorBuilder: (_, __, ___) => fallback,
              )
            : Image.asset(
                asset!,
                fit: BoxFit.contain,
                cacheWidth: _decodeWidth,
                errorBuilder: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}

class _CodeTile extends StatelessWidget {
  const _CodeTile({required this.theme, required this.pack});

  final GameTheme theme;
  final GamePack pack;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final on = pack.isEnabled;
    final letters = pack.code.length >= 2 ? pack.code.substring(0, 2) : pack.code;
    final digits = pack.code.length > 2 ? pack.code.substring(2) : '';
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: t.skin.decorate(t, SkinSurface.panel,
          radius: 11,
          state: on ? SkinState.active : SkinState.idle,
          fill: on ? t.tint : t.surfaceAlt,
          outline: on ? t.accent : t.border),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            letters,
            style: TextStyle(
              fontSize: 13,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: .5,
              color: on ? t.accent : t.muted,
            ),
          ),
          if (digits.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              digits,
              style: TextStyle(
                fontSize: 11,
                height: 1,
                fontWeight: FontWeight.w700,
                color: on ? t.accent : t.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
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
    final off = c.disabledPackCount;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 22, 28, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.navPacks,
                    style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: t.text)),
                const SizedBox(height: 4),
                Text(
                  off == 0
                      ? l.packsSummary(c.enabledPackCount)
                      : l.packsSummaryWithOff(c.enabledPackCount, off),
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: t.muted),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: c.packsLoading ? null : c.refreshPacks,
            style: accentButtonStyle(t),
            child: Text(l.packsRescan),
          ),
        ],
      ),
    );
  }
}

/// The warning for a game whose pack switches work but have never been
/// shown to be safe. It stands whether or not the user has turned them
/// on: agreeing to a risk does not remove it, and the one being taken
/// here - a Sims 2 neighborhood opened without a pack it was played
/// with - is not one anybody gets a second go at.
class _ExperimentalNotice extends StatelessWidget {
  const _ExperimentalNotice({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final l = L.of(context);
    final on = !controller.packsNeedOptIn;
    return Container(
      margin: const EdgeInsets.fromLTRB(28, 8, 28, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: t.skin.decorate(t, SkinSurface.notice,
          accent: t.warning,
          fill: t.warning.withValues(alpha: .12),
          outline: t.warning.withValues(alpha: .5)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: t.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.packsExperimentalTitle,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: t.onWarningTint),
                ),
                const SizedBox(height: 3),
                Text(
                  // Once the switches are on, the wording stops telling
                  // the user where to find them and starts telling them
                  // what to do before using one.
                  on ? l.packsExperimentalOn : l.packsExperimentalOff,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: t.onWarningTint),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown for a game whose packs the app could switch, if only Windows
/// would let it. Says what is missing without telling anyone to just run
/// the app elevated from now on: doing that turns off drag and drop,
/// which is a worse trade for most people than opening the game's own
/// launcher when they want to change a pack.
class _AdminNotice extends StatelessWidget {
  const _AdminNotice({required this.theme});

  final GameTheme theme;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      margin: const EdgeInsets.fromLTRB(28, 8, 28, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: t.skin
          .decorate(t, SkinSurface.panel, radius: 12, fill: t.surfaceAlt),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, size: 18, color: t.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              L.of(context).packsNeedAdmin,
              style: TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w600, color: t.muted),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown once a pack has been switched this session. The game reads its
/// pack list when it starts, so until it is restarted what is on screen
/// and what is running disagree - and saying so is the whole job here.
class _RestartNotice extends StatelessWidget {
  const _RestartNotice({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final l = L.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(28, 8, 28, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: t.skin.decorate(t, SkinSurface.notice,
          accent: t.warning,
          fill: t.warning.withValues(alpha: .12),
          outline: t.warning.withValues(alpha: .5)),
      child: Row(
        children: [
          Icon(Icons.restart_alt_rounded, size: 18, color: t.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l.packsRestartNotice(controller.adapter.game.name),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: t.onWarningTint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The one joke the packs screen tells, on the one shelf that has earned
/// it. Sits below the notices rather than above them: a warning about a
/// save that could break outranks a wink.
///
/// The adapter decides whether there is anything to say and the wording
/// comes from the ARB files, so a game with no remark - which is every
/// game but The Sims 4 - draws nothing here, and a language that has not
/// been given the joke draws nothing either.
class _CollectionNote extends StatelessWidget {
  const _CollectionNote({required this.theme, required this.note});

  final GameTheme theme;
  final AppMessage note;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final text = L.of(context).packNote(note);
    if (text == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(28, 8, 28, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: t.skin.decorate(t, SkinSurface.notice,
          fill: t.tint, outline: t.accent.withValues(alpha: .45)),
      child: Row(
        children: [
          Image.asset(
            'assets/pirate-icon.webp',
            width: 22,
            height: 22,
            cacheWidth: 44,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.sailing_rounded, size: 18, color: t.accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w700, color: t.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l.packsEmptyTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w900, color: t.text),
            ),
            const SizedBox(height: 8),
            Text(
              l.packsEmptyBody(c.adapter.game.name),
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: t.muted),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: c.packsLoading ? null : c.refreshPacks,
              style: accentButtonStyle(t),
              child: Text(l.packsRescan),
            ),
          ],
        ),
      ),
    );
  }
}
