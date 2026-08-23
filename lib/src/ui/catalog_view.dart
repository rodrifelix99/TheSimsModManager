import 'package:flutter/material.dart';

import '../core/mod_catalog.dart';
import 'app_controller.dart';
import 'game_skin.dart';
import 'game_theme.dart';
import 'l10n.dart';
import 'shot_viewer.dart';
import 'widgets.dart';

/// The catalog half of The Exchange: mods indexed by somebody else's
/// project, browsed on the same screen as our own listings and credited
/// on every shelf they appear on.
///
/// These are widgets rather than a screen. A person looking for a mod
/// does not care which index it sits in, so the shop screen hosts both
/// and a row of source chips swaps between them; a second sidebar tab
/// would have made the user learn our filing system to find a house.
///
/// Two things this has to be honest about, and they drive the whole
/// design:
///
/// - **Not every entry can be installed from in here.** A catalog points
///   at files on whichever host the creator used, and some of those
///   refuse a plain HTTP client by design. So the action is worded from
///   [CatalogListing.reach] rather than always saying Install and
///   failing at the last step.
/// - **A mod is its whole dependency closure.** A lot needs its prop
///   packs or the city fills with brown boxes, so the detail page counts
///   the files out before the button is pressed and the install is all
///   of them or none.
///
/// Pictures are a separate question from files: the index carries none
/// at all, and the host that gates the downloads serves its screenshots
/// perfectly well. So covers are fetched per card as it comes into view
/// (see [AppController.catalogCover]) and a blocked entry still gets
/// one.

/// The row that swaps The Exchange between its own listings and each
/// catalog, with the credit line under it.
class CatalogSourceRow extends StatelessWidget {
  const CatalogSourceRow({
    super.key,
    required this.theme,
    required this.controller,
  });

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    final grouped = c.catalogsBySeries;
    if (grouped.isEmpty) return const SizedBox.shrink();
    final active = c.shopCatalogSource;
    CatalogSource? credited;
    for (final catalogs in grouped.values) {
      for (final catalog in catalogs) {
        if (catalog.source.id == active) credited = catalog.source;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CatalogChip(
                theme: t,
                label: l.navShop,
                active: active == null,
                onTap: () => c.setShopCatalogSource(null),
              ),
              for (final series in grouped.entries) ...[
                // The series name, so a row of store names says what the
                // stores are for. Drawn as written: a series is a proper
                // noun the adapter supplies, not a key of ours.
                Padding(
                  padding: const EdgeInsets.only(left: 6, right: 2),
                  child: Text(series.key.toUpperCase(),
                      style: eyebrowStyle(t)),
                ),
                for (final catalog in series.value)
                  CatalogChip(
                    theme: t,
                    label: catalog.source.label,
                    active: active == catalog.source.id,
                    onTap: () => c.setShopCatalogSource(catalog.source.id),
                  ),
              ],
            ],
          ),
          if (credited != null) ...[
            const SizedBox(height: 8),
            CatalogCredit(theme: t, controller: c, source: credited),
          ],
        ],
      ),
    );
  }
}

/// A word for creators, shown only while somebody else's shelf is up.
///
/// Deliberately modest, and deliberately not a comparison. These
/// shelves are another project's curation and we are guests on them, so
/// this says what publishing here gets you and nothing at all about
/// what publishing elsewhere does not. It sits under the chips rather
/// than over the catalog, and it says nothing on our own shelf, where
/// the header already carries a Publish button.
class ExchangePromo extends StatelessWidget {
  const ExchangePromo({
    super.key,
    required this.theme,
    required this.controller,
  });

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: t.skin
            .decorate(t, SkinSurface.notice, radius: 10, accent: t.accent),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.catalogPromoTitle,
                      style: TextStyle(
                        color: t.text,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(height: 3),
                  Text(l.catalogPromoBody,
                      style: TextStyle(
                          color: t.muted, fontSize: 12, height: 1.45)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            CatalogButton(
              theme: t,
              label: l.shopPublish,
              onPressed: c.openShopPortal,
            ),
          ],
        ),
      ),
    );
  }
}

/// "Catalog by sc4pac", linking to the project.
///
/// Every entry on these shelves is somebody else's unpaid curation, so
/// the credit sits on the screen itself rather than in an about box.
class CatalogCredit extends StatelessWidget {
  const CatalogCredit({
    super.key,
    required this.theme,
    required this.controller,
    required this.source,
  });

  final GameTheme theme;
  final AppController controller;
  final CatalogSource source;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final l = L.of(context);
    return HoverBuilder(
      builder: (context, hovered) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => controller.openCatalogProject(source),
          child: Text(
            l.catalogCuratedBy(source.projectName),
            style: TextStyle(
              color: hovered ? t.accent : t.muted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              decoration: hovered ? TextDecoration.underline : null,
              decorationColor: t.accent,
            ),
          ),
        ),
      ),
    );
  }
}

/// The shelf of catalog entries, drawn as the library's own grid so a
/// card here is the width of a mod card a click away.
class CatalogShelf extends StatelessWidget {
  const CatalogShelf({
    super.key,
    required this.theme,
    required this.controller,
  });

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);

    if (c.catalogLoading && c.catalogEntries == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final entries = c.filteredCatalogEntries;
    if (entries.isEmpty) {
      return Center(
        child: Text(l.catalogEmpty,
            style: TextStyle(color: t.muted, fontSize: 13)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / 320).floor().clamp(1, 4);
        return CustomScrollView(
          slivers: [
            for (final failure in c.catalogFailures)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 10),
                  child: CatalogNotice(
                    theme: t,
                    text: l.catalogSourceFailed(failure),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.42,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _EntryCard(
                    theme: t,
                    controller: c,
                    entry: entries[i],
                  ),
                  childCount: entries.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.theme,
    required this.controller,
    required this.entry,
  });

  final GameTheme theme;
  final AppController controller;
  final CatalogEntry entry;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    final cover = c.catalogCover(entry);
    final installed = c.catalogInstalled(entry);
    final update = c.catalogHasUpdate(entry);

    return HoverBuilder(
      builder: (context, hovered) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => c.openCatalogEntry(entry),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: t.skin.decorate(t, SkinSurface.panel,
                state: skinState(hovered: hovered),
                radius: 12,
                elevated: hovered),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _Cover(theme: t, url: cover, seed: entry.id),
                      if (update || installed)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: TagChip(
                            label: update ? l.shopUpdate : l.shopInstalled,
                            color: update ? t.accent : t.muted,
                            background: t.surface,
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(11, 9, 11, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: t.text,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.categories.isEmpty
                            ? entry.version
                            : entry.categories.first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: t.muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A card's picture, or a coloured stand-in while there is none.
///
/// The stand-in is deliberate rather than a spinner: most cards get
/// their cover within a moment, and a shelf of spinners reads as broken
/// where a shelf of colour reads as loading.
class _Cover extends StatelessWidget {
  const _Cover({required this.theme, required this.url, required this.seed});

  final GameTheme theme;
  final Uri? url;
  final String seed;

  @override
  Widget build(BuildContext context) {
    if (url == null) return StripeThumb(seed: seed);
    return Image.network(
      url.toString(),
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => StripeThumb(seed: seed),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : StripeThumb(seed: seed),
    );
  }
}

/// One entry's page.
class CatalogDetailPanel extends StatelessWidget {
  const CatalogDetailPanel({
    super.key,
    required this.theme,
    required this.controller,
  });

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    final entry = c.selectedCatalogEntry!;
    final listing = c.catalogListing;
    final source = c.catalogSourceOf(entry);

    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
      children: [
        HoverBuilder(
          builder: (context, hovered) => MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: c.catalogInstalling ? null : c.closeCatalogEntry,
              child: Text(
                l.catalogBack,
                style: TextStyle(
                  color: hovered ? t.accent : t.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(entry.name,
            style: TextStyle(
              color: t.text,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            )),
        const SizedBox(height: 5),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (listing != null && listing.author.isNotEmpty)
              Text(l.catalogBy(listing.author),
                  style: TextStyle(color: t.muted, fontSize: 12)),
            if (source != null)
              CatalogCredit(theme: t, controller: c, source: source),
          ],
        ),
        const SizedBox(height: 18),
        if (c.catalogListingLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 44),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (listing == null)
          CatalogNotice(theme: t, text: l.catalogUnresolvedNote)
        else
          ..._body(context, listing),
      ],
    );
  }

  List<Widget> _body(BuildContext context, CatalogListing listing) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    return [
      if (listing.imageUrls.isNotEmpty) ...[
        _Gallery(theme: t, urls: listing.imageUrls),
        const SizedBox(height: 18),
      ],
      _Actions(theme: t, controller: c, listing: listing),
      const SizedBox(height: 18),
      if (listing.description.isNotEmpty) ...[
        Text(listing.description,
            style: TextStyle(color: t.text, fontSize: 13, height: 1.5)),
        const SizedBox(height: 16),
      ],
      if (listing.warning != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CatalogNotice(
            theme: t,
            title: l.catalogWarningTitle,
            text: listing.warning!,
          ),
        ),
      if (listing.conflicts != null)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: CatalogNotice(
            theme: t,
            title: l.catalogConflictsTitle,
            text: listing.conflicts!,
          ),
        ),
      if (listing.choices.isNotEmpty) ...[
        const SizedBox(height: 6),
        _Section(theme: t, title: l.catalogOptions),
        for (final choice in listing.choices)
          _ChoiceRow(theme: t, controller: c, choice: choice),
        const SizedBox(height: 10),
      ],
      if (listing.dependencies.isNotEmpty) ...[
        _Section(
          theme: t,
          title: l.catalogDependencies,
          trailing: l.catalogFileCount(listing.assets.length),
        ),
        for (final dependency in listing.dependencies)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text('· ${dependency.name}',
                style: TextStyle(color: t.muted, fontSize: 12)),
          ),
      ],
    ];
  }
}

/// The screenshots, scrolled sideways: a strip is the glance at what the
/// mod looks like, and a click on any of them is the look at it.
///
/// The strip crops each picture to 190px so the row reads as a row, and
/// what a crop takes off is often the half the screenshot was taken for
/// (issue #24) - so the viewer gets the whole set rather than the one
/// that was clicked, opened on that one.
class _Gallery extends StatelessWidget {
  const _Gallery({required this.theme, required this.urls});

  final GameTheme theme;
  final List<Uri> urls;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (context, i) => const SizedBox(width: 10),
        itemBuilder: (context, i) => HoverBuilder(
          cursor: SystemMouseCursors.click,
          builder: (context, hovered) => GestureDetector(
            onTap: () => showShotViewer(
              context,
              shots: [for (final url in urls) NetworkImage(url.toString())],
              seed: urls[i].toString(),
              index: i,
            ),
            // The ring is drawn in front rather than as a border: this
            // strip is exactly as tall as the pictures in it, and a
            // border would take its two pixels out of them.
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    width: 2,
                    color: hovered ? theme.accent : Colors.transparent),
              ),
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                urls[i].toString(),
                height: 190,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) =>
                    const SizedBox.shrink(),
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : SizedBox(
                        width: 280,
                        child: StripeThumb(seed: urls[i].toString()),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The one place the reach verdict turns into a button.
class _Actions extends StatelessWidget {
  const _Actions({
    required this.theme,
    required this.controller,
    required this.listing,
  });

  final GameTheme theme;
  final AppController controller;
  final CatalogListing listing;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    final progress = c.catalogProgress;

    if (progress != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.overall,
                    minHeight: 6,
                    backgroundColor: t.switchOff,
                    valueColor: AlwaysStoppedAnimation(t.accent),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CatalogButton(
                theme: t,
                label: l.cancel,
                onPressed: c.cancelCatalogInstall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.catalogDownloading(progress.index + 1, progress.count),
            style: TextStyle(color: t.muted, fontSize: 11),
          ),
        ],
      );
    }

    final update = c.catalogHasUpdate(listing.entry);
    final installed = c.catalogInstalled(listing.entry);
    return switch (listing.reach) {
      CatalogReach.direct => Row(
          children: [
            CatalogButton(
              theme: t,
              primary: true,
              label: update
                  ? l.shopUpdate
                  : installed
                      ? l.shopInstalled
                      : l.install,
              onPressed: c.installCatalogListing,
            ),
            const SizedBox(width: 10),
            Text(l.catalogFileCount(listing.assets.length),
                style: TextStyle(color: t.muted, fontSize: 11)),
          ],
        ),
      CatalogReach.browserOnly => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (listing.websiteUrls.isNotEmpty)
              CatalogButton(
                theme: t,
                primary: true,
                label: l.catalogOpenPage,
                onPressed: () => c.openCatalogPage(listing),
              ),
            const SizedBox(height: 10),
            CatalogNotice(
              theme: t,
              text: l.catalogBlocked(listing.unreachableHosts.isEmpty
                  ? ''
                  : listing.unreachableHosts.first),
            ),
          ],
        ),
      CatalogReach.unresolved =>
        CatalogNotice(theme: t, text: l.catalogUnresolvedNote),
    };
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.theme,
    required this.controller,
    required this.choice,
  });

  final GameTheme theme;
  final AppController controller;
  final CatalogChoice choice;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final chosen = c.catalogChoices[choice.id];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          for (final value in choice.values)
            CatalogChip(
              theme: t,
              label: value,
              active: chosen == value,
              onTap: () => c.setCatalogChoice(choice.id, value),
            ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.theme, required this.title, this.trailing});

  final GameTheme theme;
  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Text(title.toUpperCase(), style: eyebrowStyle(theme)),
            const Spacer(),
            if (trailing != null)
              Text(trailing!,
                  style: TextStyle(color: theme.muted, fontSize: 11)),
          ],
        ),
      );
}

class CatalogNotice extends StatelessWidget {
  const CatalogNotice({
    super.key,
    required this.theme,
    required this.text,
    this.title,
  });

  final GameTheme theme;
  final String text;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: t.skin
          .decorate(t, SkinSurface.notice, radius: 10, accent: t.warning),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!,
                style: TextStyle(
                  color: t.onWarningTint,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                )),
            const SizedBox(height: 3),
          ],
          Text(text,
              style: TextStyle(
                  color: t.onWarningTint, fontSize: 12, height: 1.45)),
        ],
      ),
    );
  }
}

class CatalogChip extends StatelessWidget {
  const CatalogChip({
    super.key,
    required this.theme,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final GameTheme theme;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return HoverBuilder(
      builder: (context, hovered) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: t.skin.decorate(t, SkinSurface.chip,
                state: skinState(active: active, hovered: hovered), radius: 20),
            child: Text(
              label,
              style: TextStyle(
                color: t.skin.ink(t, SkinSurface.chip,
                    state: skinState(active: active, hovered: hovered),
                    otherwise: active ? Colors.white : t.text),
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CatalogButton extends StatelessWidget {
  const CatalogButton({
    super.key,
    required this.theme,
    required this.label,
    required this.onPressed,
    this.primary = false,
  });

  final GameTheme theme;
  final String label;
  final VoidCallback? onPressed;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final surface = primary ? SkinSurface.primary : SkinSurface.button;
    return HoverBuilder(
      builder: (context, hovered) => MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: primary ? 18 : 14, vertical: primary ? 10 : 8),
            decoration: t.skin.decorate(t, surface,
                state: skinState(hovered: hovered), radius: primary ? 10 : 9),
            child: Text(
              label,
              style: TextStyle(
                color: t.skin.ink(t, surface,
                    state: skinState(hovered: hovered),
                    otherwise: primary ? Colors.white : t.text),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
