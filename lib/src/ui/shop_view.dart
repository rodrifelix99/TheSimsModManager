import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:intl/intl.dart' show DateFormat, NumberFormat;

import '../core/game.dart';
import '../services/mod_shop.dart';
import '../services/sfx.dart';
import 'app_controller.dart';
import 'game_theme.dart';
import 'install_destination_dialog.dart';
import 'l10n.dart';
import 'prose_text.dart';
import 'widgets.dart';

/// The Exchange: the in-app storefront for listings creators publish
/// through the web portal. It stands apart from the library's game -
/// every game's mods share the shelves, narrowed by the filter row -
/// so a listing installs into the folder of the game *it* names.
/// Browsing and the per-listing detail live in one screen; which of the
/// two is showing is the controller's [AppController.selectedShopListing],
/// not this widget's, because a `simsmodmanager://mod/<id>` link can name
/// a listing while the user is on another screen entirely and this widget
/// does not exist yet.
class ShopView extends StatelessWidget {
  const ShopView({super.key, required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  void _open(ShopMod mod) => controller.openShopListing(mod);

  /// Asks where the listing goes before spending anything on downloading
  /// it - the file name is all the question needs, and a dialog that
  /// appeared after a progress bar finished would read as an afterthought.
  static Future<void> _installFromShop(
      BuildContext context, GameTheme t, AppController c, ShopMod mod) async {
    final into = c.registry.byGameId(mod.gameId);
    if (into == null) return;
    final placement = await resolveInstallPlacement(context, c,
        theme: t, into: into, subjects: [mod.fileName]);
    if (placement == null) return;
    await c.installShopMod(mod, placement: placement);
  }

  void _back() => controller.closeShopListing();

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    final selected = c.selectedShopListing;
    if (selected != null) return _detail(t, c, l, selected);
    return _shelves(t, c, l);
  }

  /// The game a listing is for, or null when the registry has never heard
  /// of it (the controller keeps those off the shelves, so this only
  /// happens to a detail view left open across a refresh).
  Game? _gameOf(AppController c, ShopMod mod) =>
      c.registry.byGameId(mod.gameId)?.game;

  // ---------------------------------------------------------------- shelves

  Widget _shelves(GameTheme t, AppController c, L l) {
    // Null still means "nothing loaded yet"; once loaded, the shelves
    // show what the filter allows.
    final mods = c.shopMods == null ? null : c.visibleShopMods;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 22, 28, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            l.navShop,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              height: 1,
                              color: t.text,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        TagChip(
                          label: l.shopAlphaBadge,
                          color: t.accent,
                          background: t.tint,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mods == null || mods.isEmpty
                          ? l.shopTagline
                          : l.shopListingCount(mods.length),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
              IconButton(
                onPressed: c.shopLoading ? null : c.refreshShop,
                tooltip: l.shopRefresh,
                color: t.muted,
                icon: const Icon(Icons.refresh_rounded, size: 20),
              ),
              const SizedBox(width: 6),
              OutlinedButton(
                onPressed: c.openShopPortal,
                style: accentButtonStyle(t),
                child: Text(l.shopPublish),
              ),
            ],
          ),
        ),
        // Only once there is something to sort through: an empty catalog
        // has nothing to filter, and a failed load nothing to say.
        if (c.shopKnownMods.isNotEmpty) _filterRow(t, c, l),
        Expanded(child: _shelvesBody(t, c, l, mods)),
      ],
    );
  }

  /// The game filter: every game the app supports, each with its icon and
  /// how many listings it has, plus the "all games" chip the shop opens
  /// on. A game with an empty shelf still gets a chip - that it is empty
  /// is worth seeing.
  Widget _filterRow(GameTheme t, AppController c, L l) {
    final counts = c.shopCountsByGame;
    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
        children: [
          _filterChip(t, c,
              label: l.shopAllGames,
              count: c.shopKnownMods.length,
              selected: c.shopGameFilter == null,
              onTap: () => c.setShopGameFilter(null)),
          for (final adapter in c.registry.adapters)
            _filterChip(t, c,
                label: adapter.game.name,
                game: adapter.game,
                count: counts[adapter.game.id] ?? 0,
                selected: c.shopGameFilter == adapter.game.id,
                onTap: () => c.setShopGameFilter(adapter.game.id)),
        ],
      ),
    );
  }

  Widget _filterChip(
    GameTheme t,
    AppController c, {
    required String label,
    required int count,
    required bool selected,
    required VoidCallback onTap,
    Game? game,
  }) {
    final asset = game == null ? null : GameTheme.iconAsset(game);
    final empty = count == 0 && !selected;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: HoverBuilder(
        cursor: SystemMouseCursors.click,
        builder: (context, hovered) => GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.fromLTRB(asset == null ? 14 : 8, 7, 12, 7),
            decoration: BoxDecoration(
              color: selected ? t.tint : (hovered ? t.surfaceAlt : t.surface),
              border: Border.all(
                color: selected ? t.accent : t.border,
                width: selected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (asset != null) ...[
                  Opacity(
                    opacity: empty ? .45 : 1,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      // The chip is named as well as pictured, so an
                      // icon the bundle won't load leaves a gap rather
                      // than a crash report (see the sidebar's icons).
                      child: Image.asset(
                        asset,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: selected
                        ? t.accent
                        : (empty ? t.muted : t.text),
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? t.accent : t.muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _shelvesBody(GameTheme t, AppController c, L l, List<ShopMod>? mods) {
    // A link named a listing and we are still finding out which. The
    // shelves underneath may already be loaded, but they are not what the
    // user asked for.
    if (c.shopOpeningListing) {
      return Center(child: CircularProgressIndicator(color: t.accent));
    }
    if (mods == null) {
      if (c.shopLoadFailed) return _loadFailed(t, c, l);
      return Center(child: CircularProgressIndicator(color: t.accent));
    }
    if (mods.isEmpty) {
      // Nothing anywhere is the alpha's story; nothing for the game
      // being filtered is just that shelf.
      final filtered = c.registry.byGameId(c.shopGameFilter ?? '')?.game;
      return c.shopKnownMods.isEmpty || filtered == null
          ? _emptyShelves(t, c, l)
          : _emptyShelf(t, c, l, filtered);
    }
    // One card per shelf entry rather than per listing: a creator's set
    // of eight colours is one thing to consider, and the choice between
    // them belongs on the page that describes it.
    final groups = c.visibleShopGroups;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns =
                  (constraints.maxWidth / 320).floor().clamp(1, 4);
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(28, 4, 28, 20),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisExtent: 232,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: groups.length,
                itemBuilder: (context, i) => groups[i].isSet
                    ? _setCard(t, c, l, groups[i])
                    : _card(t, c, l, groups[i].lead),
              );
            },
          ),
        ),
        _creatorNudge(t, c, l),
      ],
    );
  }

  /// The standing "this could be you" strip under the shelves.
  Widget _creatorNudge(GameTheme t, AppController c, L l) {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 11, 28, 11),
      decoration: BoxDecoration(
        color: t.surfaceAlt,
        border: Border(top: BorderSide(color: t.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l.shopCreatorNudge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: t.muted,
              ),
            ),
          ),
          const SizedBox(width: 14),
          TextButton(
            onPressed: c.openShopPortal,
            style: TextButton.styleFrom(
              foregroundColor: t.accent,
              textStyle:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            child: Text(l.shopPublish),
          ),
        ],
      ),
    );
  }

  Widget _loadFailed(GameTheme t, AppController c, L l) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: 42, color: t.muted),
          const SizedBox(height: 12),
          Text(
            l.shopLoadFailedTitle,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: t.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.shopLoadFailedBody,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: t.muted,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: c.refreshShop,
            style: accentButtonStyle(t),
            child: Text(l.shopRetry),
          ),
        ],
      ),
    );
  }

  /// The alpha's honest empty state: nothing published for this game
  /// yet, and an invitation to be the first.
  Widget _emptyShelves(GameTheme t, AppController c, L l) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BrandMark(theme: t, size: 34),
              const SizedBox(height: 22),
              Text(
                l.shopEmptyTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: t.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.shopEmptyBody,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.55,
                  color: t.muted,
                ),
              ),
              const SizedBox(height: 20),
              _publishButton(t, c, l),
            ],
          ),
        ),
      ),
    );
  }

  /// One game's shelf is empty while others aren't: say so, and offer the
  /// way back to everything rather than leaving the user staring at a
  /// filter they may have forgotten setting.
  Widget _emptyShelf(GameTheme t, AppController c, L l, Game game) {
    final asset = GameTheme.iconAsset(game);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (asset != null)
                Opacity(
                  opacity: .45,
                  child: SizedBox(
                    width: 46,
                    height: 46,
                    child: Image.asset(
                      asset,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                          Icons.inventory_2_outlined,
                          size: 40,
                          color: t.muted),
                    ),
                  ),
                )
              else
                Icon(Icons.inventory_2_outlined, size: 40, color: t.muted),
              const SizedBox(height: 18),
              Text(
                l.shopEmptyGameTitle(game.name),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: t.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l.shopEmptyGameBody(game.name),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.55,
                  color: t.muted,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => c.setShopGameFilter(null),
                    style: accentButtonStyle(t),
                    child: Text(l.shopShowAllGames),
                  ),
                  const SizedBox(width: 10),
                  _publishButton(t, c, l),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _publishButton(GameTheme t, AppController c, L l) {
    return FilledButton(
      onPressed: c.openShopPortal,
      style: FilledButton.styleFrom(
        backgroundColor: t.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
      ),
      child: Text(l.shopPublish),
    );
  }

  // ------------------------------------------------------------------ cards

  Widget _card(GameTheme t, AppController c, L l, ShopMod mod) {
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: () => _open(mod),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0, hovered ? -3 : 0, 0),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: hovered ? t.accent : t.border),
            borderRadius: BorderRadius.circular(15),
            boxShadow: hovered
                ? [
                    BoxShadow(
                      color: t.shadow.withValues(alpha: .45),
                      blurRadius: 34,
                      offset: const Offset(0, 18),
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
                  children: [
                    Positioned.fill(
                      child: _cover(mod,
                          const BorderRadius.vertical(top: Radius.circular(14))),
                    ),
                    // Which game this is for, since the shelves mix them.
                    // Redundant while one game is filtered, so it goes.
                    if (c.shopGameFilter == null)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: _gameBadge(t, c, mod),
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
                              mod.name,
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
                          if (mod.version.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              mod.version,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: t.muted.withValues(alpha: .75),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l.shopBy(mod.authorName),
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
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    formatBytes(mod.fileSizeBytes),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: t.muted,
                                    ),
                                  ),
                                ),
                                if (mod.downloads > 0)
                                  _downloadCount(t, mod.downloads,
                                      leading: ' · '),
                              ],
                            ),
                          ),
                          _installButton(t, c, l, mod, compact: true),
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

  /// A creator's set, as one card. It wears the most recently updated
  /// variation's cover and says how many there are; what it does not
  /// carry is an Install button, because there is no answer to which
  /// colour that would be - the page behind it asks.
  Widget _setCard(GameTheme t, AppController c, L l, ShopGroup group) {
    final lead = group.lead;
    final updatable =
        group.variants.any((mod) => c.shopUpdateFor(mod) != null);
    final installed =
        !updatable && group.variants.any(c.isShopModInstalled);
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: () => _open(lead),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0, hovered ? -3 : 0, 0),
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: hovered ? t.accent : t.border),
            borderRadius: BorderRadius.circular(15),
            boxShadow: hovered
                ? [
                    BoxShadow(
                      color: t.shadow.withValues(alpha: .45),
                      blurRadius: 34,
                      offset: const Offset(0, 18),
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
                  children: [
                    Positioned.fill(
                      child: _cover(lead,
                          const BorderRadius.vertical(top: Radius.circular(14))),
                    ),
                    if (c.shopGameFilter == null)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: _gameBadge(t, c, lead),
                      ),
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: _plate(
                        t,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.palette_outlined,
                                size: 12.5, color: t.accent),
                            const SizedBox(width: 4),
                            Text(
                              l.shopVariations(group.variants.length),
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: t.text,
                              ),
                            ),
                          ],
                        ),
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
                      Text(
                        group.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                          color: t.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l.shopBy(lead.authorName),
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
                          // The set's takes, which is the sum of numbers
                          // that were each counted; silent at zero, the
                          // same as a lone listing's. Flexible because a
                          // big number and a translated badge share one
                          // narrow row.
                          if (group.downloads > 0)
                            Flexible(child: _downloadCount(t, group.downloads))
                          else
                            const SizedBox.shrink(),
                          if (updatable)
                            TagChip(
                              label: l.shopUpdate,
                              color: t.accent,
                              background: t.tint,
                            )
                          else if (installed)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_rounded,
                                    size: 13, color: t.muted),
                                const SizedBox(width: 4),
                                Text(
                                  l.shopInstalled,
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

  /// The solid backing a label needs to read over a screenshot.
  Widget _plate(GameTheme t, {required Widget child}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: t.surface.withValues(alpha: .88),
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: t.shadow.withValues(alpha: .3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: child,
      );

  /// How many people have taken this mod, on the card next to its size.
  /// Only ever drawn above zero: a listing nobody has downloaded yet says
  /// more by saying nothing, and every listing published before there was
  /// a counter reads zero for reasons that are ours rather than the
  /// creator's.
  Widget _downloadCount(GameTheme t, int downloads, {String leading = ''}) {
    final style = TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w700,
      color: t.muted,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading.isNotEmpty) Text(leading, style: style),
        Icon(Icons.file_download_outlined, size: 12.5, color: t.muted),
        const SizedBox(width: 2),
        Flexible(
          child: Text(_count(downloads),
              maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
        ),
      ],
    );
  }

  /// The game a listing belongs to, worn on its cover: the icon where we
  /// have one, the name where we don't. Sits on a solid plate so it reads
  /// over any screenshot.
  Widget _gameBadge(GameTheme t, AppController c, ShopMod mod) {
    final game = _gameOf(c, mod);
    if (game == null) return const SizedBox.shrink();
    final asset = GameTheme.iconAsset(game);
    final label = Text(
      game.name,
      style: TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        color: t.text,
      ),
    );
    return Tooltip(
      message: game.name,
      waitDuration: const Duration(milliseconds: 400),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: asset == null ? 8 : 4, vertical: 4),
        decoration: BoxDecoration(
          color: t.surface.withValues(alpha: .88),
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: t.shadow.withValues(alpha: .3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: asset == null
            ? label
            : SizedBox(
                width: 20,
                height: 20,
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => label,
                ),
              ),
      ),
    );
  }

  /// Cover screenshot, stripe art when the listing has none (or the
  /// image fails to arrive).

  Widget _installButton(GameTheme t, AppController c, L l, ShopMod mod,
      {bool compact = false}) {
    final progress = c.shopProgress.containsKey(mod.id)
        ? (c.shopProgress[mod.id],)
        : null;
    // A listing already installed at another version reads as an update
    // rather than as done: same one click, but it says what it will do.
    final updatable = progress == null && c.shopUpdateFor(mod) != null;
    final installed =
        progress == null && !updatable && c.isShopModInstalled(mod);
    // The listing names its own game, and that game's folder is the one
    // that has to exist - not the folder of whatever the sidebar points at.
    final game = _gameOf(c, mod);
    final needsFolder = game == null || !c.hasModsFolder(game.id);
    final label = installed
        ? l.shopInstalled
        : progress != null
            ? l.shopInstalling
            : updatable
                ? l.shopUpdate
                : l.install;
    final button = HoverBuilder(
      cursor: installed || progress != null || needsFolder
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: installed || progress != null || needsFolder
            ? null
            : () => _installFromShop(context, t, c, mod),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 18, vertical: compact ? 6 : 10),
          decoration: BoxDecoration(
            gradient: installed || needsFolder ? null : t.accentGradient,
            color: installed || needsFolder ? t.surfaceAlt : null,
            border: installed || needsFolder
                ? Border.all(color: t.border)
                : null,
            borderRadius: BorderRadius.circular(compact ? 9 : 11),
            boxShadow: !installed && !needsFolder && hovered
                ? [
                    BoxShadow(
                      color: t.accent.withValues(alpha: .5),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : const [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (installed) ...[
                Icon(Icons.check_rounded, size: compact ? 13 : 15,
                    color: t.muted),
                const SizedBox(width: 5),
              ],
              if (updatable && !needsFolder) ...[
                Icon(Icons.arrow_circle_down_rounded,
                    size: compact ? 13 : 15, color: Colors.white),
                const SizedBox(width: 5),
              ],
              if (progress != null) ...[
                SizedBox(
                  width: compact ? 11 : 13,
                  height: compact ? 11 : 13,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: progress.$1,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 7),
              ],
              Text(
                label,
                style: TextStyle(
                  color: installed || needsFolder ? t.muted : Colors.white,
                  fontSize: compact ? 12 : 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!needsFolder || installed || game == null) return button;
    return Tooltip(
      message: l.shopNeedsFolder(game.name),
      waitDuration: const Duration(milliseconds: 300),
      child: button,
    );
  }

  // ----------------------------------------------------------------- detail

  /// A count with the reader's own thousands separator. Same fallback as
  /// [_updatedDate]: widget tests never run main(), so the symbols for
  /// the active locale may not have been loaded.
  String _count(int value) {
    try {
      return NumberFormat.decimalPattern().format(value);
    } catch (_) {
      return NumberFormat.decimalPattern('en').format(value);
    }
  }

  String _updatedDate(ShopMod mod) {
    final d = mod.updatedAt;
    if (d == null) return '';
    try {
      return DateFormat.yMMMd().format(d);
    } catch (_) {
      return DateFormat.yMMMd('en').format(d);
    }
  }

  Widget _detail(GameTheme t, AppController c, L l, ShopMod mod) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 28, 0),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: _back,
                style: TextButton.styleFrom(
                  foregroundColor: t.muted,
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 13),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 17),
                label: Text(l.shopBack),
              ),
              const Spacer(),
              _CopyLinkButton(theme: t, controller: c, mod: mod),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 10, 28, 28),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 720;
                // Keyed on the listing: which screenshot is showing is
                // this one mod's business, and opening another has to
                // start it back at the cover.
                final gallery =
                    _Gallery(key: ValueKey(mod.id), theme: t, mod: mod);
                final info = _info(t, c, l, mod);
                if (!wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [gallery, const SizedBox(height: 22), info],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 380, child: gallery),
                    const SizedBox(width: 26),
                    Expanded(child: info),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Which game the open listing is for, and a way to see the rest of
  /// that game's shelf: the detail is where someone decides whether this
  /// mod is even for them.
  Widget _detailGamePill(GameTheme t, AppController c, Game game) {
    final asset = GameTheme.iconAsset(game);
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: () {
          c.setShopGameFilter(game.id);
          _back();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.fromLTRB(asset == null ? 10 : 5, 4, 10, 4),
          decoration: BoxDecoration(
            color: hovered ? t.tint : t.surfaceAlt,
            border: Border.all(color: hovered ? t.accent : t.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (asset != null) ...[
                SizedBox(
                  width: 18,
                  height: 18,
                  child: Image.asset(
                    asset,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 7),
              ],
              Text(
                game.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: hovered ? t.accent : t.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The row that swaps which variation of a set the page is about. Each
  /// chip carries what the user already has of it - a tick for installed,
  /// an arrow where the creator has published something newer - so the
  /// answer to "which of these did I take?" is on screen rather than one
  /// click away per colour.
  Widget _variantPicker(
      GameTheme t, AppController c, L l, ShopGroup group, ShopMod selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.shopVariationPick.toUpperCase(), style: eyebrowStyle(t)),
        const SizedBox(height: 7),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final variant in group.variants)
              _variantChip(t, c, group, variant, variant.id == selected.id),
          ],
        ),
      ],
    );
  }

  Widget _variantChip(GameTheme t, AppController c, ShopGroup group,
      ShopMod variant, bool selected) {
    final updatable = c.shopUpdateFor(variant) != null;
    final installed = !updatable && c.isShopModInstalled(variant);
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: () => c.openShopVariant(variant),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.fromLTRB(12, 7, 12, 7),
          decoration: BoxDecoration(
            color: selected ? t.tint : (hovered ? t.surfaceAlt : t.surface),
            border: Border.all(
              color: selected ? t.accent : t.border,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (installed) ...[
                Icon(Icons.check_rounded, size: 13, color: t.muted),
                const SizedBox(width: 5),
              ],
              if (updatable) ...[
                Icon(Icons.arrow_circle_down_rounded,
                    size: 13, color: t.accent),
                const SizedBox(width: 5),
              ],
              Text(
                shopVariantLabel(group.name, variant.name),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: selected ? t.accent : t.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(GameTheme t, AppController c, L l, ShopMod mod) {
    final facts = <(String, String)>[
      if (mod.version.isNotEmpty) (l.factVersion, mod.version),
      (l.factSize, formatBytes(mod.fileSizeBytes)),
      if (mod.updatedAt != null) (l.factModified, _updatedDate(mod)),
      if (mod.downloads > 0) (l.factDownloads, _count(mod.downloads)),
    ];
    // Inside a set, the page is the set's: its name at the top, and the
    // picker below choosing which variation everything under it - the
    // facts, the button, the description - is about.
    final group = c.selectedShopGroup;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group?.name ?? mod.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            height: 1.15,
            color: t.text,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Flexible(
              child: Text(
                l.shopBy(mod.authorName),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: t.muted,
                ),
              ),
            ),
            if (_gameOf(c, mod) case final game?) ...[
              const SizedBox(width: 10),
              _detailGamePill(t, c, game),
            ],
          ],
        ),
        if (group != null) ...[
          const SizedBox(height: 16),
          _variantPicker(t, c, l, group, mod),
        ],
        const SizedBox(height: 14),
        Wrap(
          spacing: 18,
          runSpacing: 8,
          children: [
            for (final (label, value) in facts)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.toUpperCase(), style: eyebrowStyle(t)),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: t.text,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 18),
        _installButton(t, c, l, mod),
        if (mod.description.isNotEmpty) ...[
          const SizedBox(height: 22),
          ProseText(
            mod.description,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              height: 1.6,
              color: t.text,
            ),
            linkColor: t.accent,
            onLink: (url) => c.openUrl(Uri.parse(url)),
          ),
        ],
        if (mod.instructions case final notes?) ...[
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
            decoration: BoxDecoration(
              color: t.surfaceAlt,
              border: Border.all(color: t.border),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.shopInstallNotes.toUpperCase(),
                    style: eyebrowStyle(t)),
                const SizedBox(height: 6),
                ProseText(
                  notes,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.55,
                    color: t.text,
                  ),
                  linkColor: t.accent,
                  onLink: (url) => c.openUrl(Uri.parse(url)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Copies a listing's public address, so someone who found a mod here can
/// pass it on without going looking for the website first. Says so for a
/// moment afterwards, which is all the confirmation it needs.
class _CopyLinkButton extends StatefulWidget {
  const _CopyLinkButton({
    required this.theme,
    required this.controller,
    required this.mod,
  });

  final GameTheme theme;
  final AppController controller;
  final ShopMod mod;

  @override
  State<_CopyLinkButton> createState() => _CopyLinkButtonState();
}

class _CopyLinkButtonState extends State<_CopyLinkButton> {
  bool _copied = false;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    final c = widget.controller;
    c.playSound(UiSound.click);
    await Clipboard.setData(
        ClipboardData(text: shopListingUrl(widget.mod.id)));
    c.analytics.capture(
        'shop_link_copied', {'game': widget.mod.gameId, 'listing': widget.mod.id});
    if (!mounted) return;
    setState(() => _copied = true);
    _reset?.cancel();
    _reset = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final l = L.of(context);
    return TextButton.icon(
      // The demo shelves are invented; their ids point at nothing.
      onPressed: widget.mod.demoImages.isNotEmpty ? null : _copy,
      style: TextButton.styleFrom(
        foregroundColor: _copied ? t.accent : t.muted,
        textStyle:
            const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
      ),
      icon: Icon(
          _copied ? Icons.check_rounded : Icons.link_rounded, size: 17),
      label: Text(_copied ? l.shopLinkCopied : l.shopCopyLink),
    );
  }
}

/// One listing's screenshots: the big one, and the strip that swaps it.
/// The only state the shop screen has left, and it belongs to the listing
/// rather than the screen - hence the key on it at the call site.
class _Gallery extends StatefulWidget {
  const _Gallery({super.key, required this.theme, required this.mod});

  final GameTheme theme;
  final ShopMod mod;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final mod = widget.mod;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: t.border),
              borderRadius: BorderRadius.circular(15),
            ),
            child: _cover(mod, BorderRadius.circular(14),
                index: mod.imageCount == 0 ? null : _index),
          ),
        ),
        if (mod.imageCount > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 56,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: mod.imageCount,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) => HoverBuilder(
                cursor: SystemMouseCursors.click,
                builder: (context, hovered) => GestureDetector(
                  onTap: () => setState(() => _index = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 86,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: i == _index || hovered ? t.accent : t.border,
                        width: i == _index ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _cover(mod, BorderRadius.circular(9), index: i),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

Widget _cover(ShopMod mod, BorderRadius radius, {int? index}) {
  final fallback = StripeThumb(seed: mod.name, borderRadius: radius);
  // The invented listings carry their pictures with them; only real
  // ones have anything to fetch.
  if (mod.demoImages.isNotEmpty) {
    final at = (index ?? 0).clamp(0, mod.demoImages.length - 1);
    return ClipRRect(
      borderRadius: radius,
      child: Image.memory(
        mod.demoImages[at],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
  final uri = index == null
      ? mod.coverUri
      : (index < mod.imagePaths.length ? mod.imageUri(index) : null);
  if (uri == null) return fallback;
  return ClipRRect(
    borderRadius: radius,
    child: Image.network(
      uri.toString(),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => fallback,
    ),
  );
}
