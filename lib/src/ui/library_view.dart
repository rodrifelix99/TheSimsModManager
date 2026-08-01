import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import '../core/mod.dart';
import '../services/sfx.dart';
import 'app_controller.dart';
import 'game_theme.dart';
import 'install_destination_dialog.dart';
import 'l10n.dart';
import 'mod_presentation.dart';
import 'move_folder_dialog.dart';
import 'scan_backdrop.dart';
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
    final l = L.of(context);
    if (c.loading) {
      final progress = c.scanProgress;
      return Stack(
        fit: StackFit.expand,
        children: [
          if (progress != null)
            ScanFloatBackdrop(
              theme: t,
              itemCount: () => c.scanShowcaseCount,
              itemAt: c.scanShowcaseItem,
            ),
          Center(
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
                    l.scanningMods(progress.$1, progress.$2),
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
                    child: Text(l.skip),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }
    if (c.modsDir == null) {
      return _FolderSetupView(theme: t, controller: c);
    }
    final visible = c.filteredMods;
    final logoAsset =
        GameTheme.logoAsset(c.adapter.game, Theme.of(context).brightness);
    // Drawn for a game we ship no wordmark for, and again when the
    // bundle refuses to hand one over - see the sidebar's icons for when
    // that happens.
    final title = Text(
      l.libraryTitle(c.adapter.game.name),
      // Both lines stay one line each whatever the language: the header
      // sits above everything, so a title that wraps pushes the first
      // row of mods off a minimum-size window.
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 23,
        fontWeight: FontWeight.w900,
        height: 1,
        color: t.text,
      ),
    );
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
                        semanticLabel: l.libraryTitle(c.adapter.game.name),
                        errorBuilder: (_, __, ___) => title,
                      )
                    else
                      title,
                    const SizedBox(height: 4),
                    Text(
                      l.modsShown(
                          visible.length, eraLabel(l, t, c.adapter.game)),
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
              // Flexible rather than its natural 210: the search box is
              // the one thing up here that can give width back, and a
              // window narrower than kMinWindowSize (which macOS used to
              // hand us) overflowed this row rather than shrinking.
              Flexible(child: _searchField(t, c, l)),
              const SizedBox(width: 14),
              _sortButton(t, c, l),
              const SizedBox(width: 6),
              _viewToggle(t, c, l),
              const SizedBox(width: 6),
              if (c.canMoveMods) ...[
                _newFolderButton(t, c, l),
                const SizedBox(width: 6),
              ],
              _refreshButton(t, c, l),
              const SizedBox(width: 14),
              _installButton(t, c, l),
            ],
          ),
        ),
        if (c.announcement != null) _announcementBanner(t, c, l),
        if (!c.modsDirWritable) _readOnlyBanner(t, l),
        if (c.runningElevated) _elevatedBanner(t, l),
        for (final key in c.unmetRequirements)
          if (l.requirement(key) case final text?)
            _requirementBanner(t, c, l, key, text),
        if (c.tooDeepCount > 0) _tooDeepBanner(t, c, l),
        if (c.advisoryCount > 0) _advisoryBanner(t, c, l),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 14),
          // The selection bar is a row of its own under the filters rather
          // than a replacement for them. It cost a downward nudge of the
          // shelf while something is ticked, and bought back the two
          // things the swap had taken away: the folder chips, which are
          // where a dragged selection lands in the grid and list layouts,
          // and the filters themselves, which are how a selection gets
          // narrowed down in the first place.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: _FilterChips(theme: t, controller: c)),
                  _totalStat(t, c, l),
                  _stateStat(t, c, l, ModStateFilter.enabled),
                  _stateStat(t, c, l, ModStateFilter.disabled),
                  _conflictStat(t, c, l),
                ],
              ),
              if (c.hasSelection) ...[
                const SizedBox(height: 10),
                _SelectionBar(theme: t, controller: c),
              ],
            ],
          ),
        ),
        Expanded(
          child: visible.isEmpty
              ? _EmptyLibrary(theme: t, controller: c)
              : switch (c.layout) {
                  LibraryLayout.grid => _modGrid(t, c, visible),
                  LibraryLayout.list => _modList(t, c, visible),
                  LibraryLayout.folders => _modFolders(t, c),
                },
        ),
      ],
    );
  }

  /// Remote announcement from PostHog's `announcement` feature flag
  /// payload: a dismissible strip between the header and the filters.
  Widget _announcementBanner(GameTheme t, AppController c, L l) {
    final a = c.announcement!;
    final title = a['title'];
    final message = a['message'].toString();
    final hasUrl = a['url'] is String;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: t.tint,
          border: Border.all(color: t.accent, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.campaign_rounded, size: 20, color: t.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title is String && title.isNotEmpty
                    ? '$title: $message'
                    : message,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: t.text,
                ),
              ),
            ),
            if (hasUrl) ...[
              const SizedBox(width: 12),
              TextButton(
                onPressed: c.openAnnouncementUrl,
                style: TextButton.styleFrom(
                  foregroundColor: t.accent,
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 13),
                ),
                child: Text(l.learnMore),
              ),
            ],
            const SizedBox(width: 4),
            IconButton(
              onPressed: c.dismissAnnouncement,
              tooltip: l.dismiss,
              iconSize: 17,
              color: t.muted,
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      ),
    );
  }

  /// Running as administrator costs the window its drag and drop, and
  /// Windows refuses the drag without telling anyone - the file simply
  /// bounces off. Say it here, next to the Install button that still
  /// works, rather than let people conclude the app is broken.
  Widget _elevatedBanner(GameTheme t, L l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: t.warning.withValues(alpha: .1),
          border: Border.all(color: t.warning, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.admin_panel_settings_outlined, size: 20,
                color: t.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l.elevatedNoDropBanner,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: t.onWarningTint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The mods folder won't take a file. Said here, once, rather than
  /// leaving the user to discover it one refused install at a time -
  /// which is how it read before, since the OS wording behind the failure
  /// ("Access is denied") never mentions permissions at all.
  Widget _readOnlyBanner(GameTheme t, L l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: t.warning.withValues(alpha: .1),
          border: Border.all(color: t.warning, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.lock_outline_rounded, size: 20, color: t.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l.folderReadOnlyBanner,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: t.onWarningTint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Something outside the mods folder that stops the game running any
  /// of this: Medieval's loader file missing, or The Sims 4 set to
  /// ignore mods. The library looks perfectly healthy in both cases,
  /// which is exactly why it has to be said here.
  Widget _requirementBanner(
      GameTheme t, AppController c, L l, String key, String text) {
    final help = AppController.requirementHelpUrl(key);
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: t.warning.withValues(alpha: .1),
          border: Border.all(color: t.warning, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.extension_off_rounded, size: 20, color: t.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: t.onWarningTint,
                ),
              ),
            ),
            if (help != null) ...[
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => c.openRequirementHelp(key),
                style: TextButton.styleFrom(
                  foregroundColor: t.warning,
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 13),
                ),
                child: Text(l.requirementGetFile),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Mods nested deeper than the game's own Resource.cfg reaches. They
  /// are installed, enabled and completely inert, and nothing else in
  /// the app or the game would ever say so.
  Widget _tooDeepBanner(GameTheme t, AppController c, L l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: t.warning.withValues(alpha: .1),
          border: Border.all(color: t.warning, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.folder_off_rounded, size: 20, color: t.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l.tooDeepBanner(c.tooDeepCount, c.modDepthLimit ?? 0),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: t.onWarningTint,
                ),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: c.toggleTooDeepOnly,
              style: TextButton.styleFrom(
                foregroundColor: t.warning,
                textStyle:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              child:
                  Text(c.tooDeepOnly ? l.advisoryShowAll : l.tooDeepShow),
            ),
          ],
        ),
      ),
    );
  }

  /// Mods the published advisory list names (see mod_advisories.dart).
  /// Deliberately not dismissible, unlike the announcement above it: this
  /// one describes the library as it is right now and leaves on its own
  /// as soon as the mods behind it are disabled or updated.
  Widget _advisoryBanner(GameTheme t, AppController c, L l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 14, 28, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: t.warning.withValues(alpha: .1),
          border: Border.all(color: t.warning, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, size: 20, color: t.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l.advisoryBanner(c.advisoryCount),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: t.onWarningTint,
                ),
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: c.toggleAdvisoriesOnly,
              style: TextButton.styleFrom(
                foregroundColor: t.warning,
                textStyle:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              child:
                  Text(c.advisoriesOnly ? l.advisoryShowAll : l.advisoryShow),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchField(GameTheme t, AppController c, L l) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 210),
      child: TextField(
        onChanged: c.setQuery,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: t.text,
        ),
        cursorColor: t.accent,
        decoration: InputDecoration(
          hintText: l.searchMods,
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

  /// The order the library is drawn in, and whether the switched-off mods
  /// sink under the rest. One menu because they answer the same question:
  /// the grouping holds whichever order is picked, so a library sorted by
  /// date still reads by date within each half.
  Widget _sortButton(GameTheme t, AppController c, L l) {
    String label(LibrarySort sort) => switch (sort) {
          LibrarySort.name => l.sortByName,
          LibrarySort.recent => l.sortByRecent,
          LibrarySort.size => l.sortBySize,
        };
    PopupMenuItem<void> row(String text, bool checked, VoidCallback onTap) =>
        PopupMenuItem<void>(
          onTap: onTap,
          child: Row(
            children: [
              SizedBox(
                width: 24,
                child: checked
                    ? Icon(Icons.check_rounded, size: 16, color: t.accent)
                    : null,
              ),
              // Expanded, because the menu's own width is Material's and
              // a translated label has nowhere else to go: it wraps to a
              // second line rather than running off the end.
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: checked ? t.accent : t.text,
                  ),
                ),
              ),
            ],
          ),
        );

    return Tooltip(
      message: l.sortTooltip,
      child: PopupMenuButton<void>(
        tooltip: '',
        color: t.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: t.border)),
        itemBuilder: (context) => [
          for (final sort in LibrarySort.values)
            row(label(sort), c.sort == sort, () => c.setSort(sort)),
          const PopupMenuDivider(),
          row(l.sortDisabledLast, c.disabledLast,
              () => c.setDisabledLast(!c.disabledLast)),
        ],
        child: HoverBuilder(
          cursor: SystemMouseCursors.click,
          builder: (context, hovered) => AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 34,
            height: 40,
            decoration: BoxDecoration(
              color: hovered ? t.surface : t.surfaceAlt,
              border: Border.all(color: t.border),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              Icons.sort_rounded,
              size: 18,
              // Lit while the library isn't in the order it opens in, so
              // an unexpected order says where it came from.
              color: hovered || c.sort != LibrarySort.name || c.disabledLast
                  ? t.accent
                  : t.muted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _viewToggle(GameTheme t, AppController c, L l) {
    // Three unlabelled icons is one more than reads at a glance, so each
    // says what it is on hover.
    Widget button(LibraryLayout layout, IconData icon, String label) {
      final active = c.layout == layout;
      return Tooltip(
        message: label,
        child: GestureDetector(
          onTap: () => c.setLayout(layout),
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
          button(LibraryLayout.grid, Icons.grid_view_rounded, l.viewGrid),
          const SizedBox(width: 2),
          button(LibraryLayout.list, Icons.view_list_rounded, l.viewList),
          const SizedBox(width: 2),
          button(LibraryLayout.folders, Icons.folder_copy_rounded,
              l.viewFolders),
        ],
      ),
    );
  }

  /// The folder is only re-read when the app itself touches it, so a mod
  /// copied in from Explorer stays invisible until something forces a
  /// scan. Switching games in the sidebar already did that, but nothing
  /// on screen said so.
  Widget _refreshButton(GameTheme t, AppController c, L l) {
    return Tooltip(
      message: l.libraryRefresh,
      child: HoverBuilder(
        cursor: SystemMouseCursors.click,
        builder: (context, hovered) => GestureDetector(
          onTap: () {
            c.playSound(UiSound.click);
            c.refresh();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 34,
            height: 40,
            decoration: BoxDecoration(
              color: hovered ? t.surface : t.surfaceAlt,
              border: Border.all(color: t.border),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              Icons.refresh_rounded,
              size: 18,
              color: hovered ? t.accent : t.muted,
            ),
          ),
        ),
      ),
    );
  }

  /// Makes a subfolder inside whichever folder chip is selected, which is
  /// also where the next install would land - so what you are looking at
  /// is what you are filing into, here as there.
  Widget _newFolderButton(GameTheme t, AppController c, L l) {
    return Tooltip(
      message: l.newFolder,
      child: HoverBuilder(
        cursor: SystemMouseCursors.click,
        builder: (context, hovered) => GestureDetector(
          onTap: () => askForNewFolder(context, c, theme: t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 34,
            height: 40,
            decoration: BoxDecoration(
              color: hovered ? t.surface : t.surfaceAlt,
              border: Border.all(color: t.border),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              Icons.create_new_folder_outlined,
              size: 18,
              color: hovered ? t.accent : t.muted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _installButton(GameTheme t, AppController c, L l) {
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: () => _pickAndInstall(context, t, c, l),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('＋',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1)),
              const SizedBox(width: 6),
              Text(
                l.install,
                style: const TextStyle(
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

  static Future<void> _pickAndInstall(
      BuildContext context, GameTheme t, AppController c, L l) async {
    c.playSound(UiSound.click);
    // Archives are accepted alongside plain mod files: the adapter
    // unpacks them and installs the mod files they contain.
    final extensions = [
      for (final e in c.adapter.modFileExtensions) e.replaceFirst('.', ''),
      for (final e in c.adapter.containerFileExtensions)
        e.replaceFirst('.', ''),
    ];
    final files = await openFiles(acceptedTypeGroups: [
      XTypeGroup(
          label: l.filePickerModsLabel(c.adapter.game.name),
          extensions: extensions),
    ]);
    if (files.isEmpty) return;
    if (!context.mounted) return;
    final placement = await resolveInstallPlacement(context, c,
        theme: t, subjects: [for (final f in files) f.path]);
    // Backed out of the dialog: nothing was picked, so nothing installs.
    if (placement == null) return;
    await c.installFiles([for (final f in files) File(f.path)],
        placement: placement);
  }

  /// Every stat in the header is also a filter, so they all draw the same
  /// way: a hover tint in their own colour while there's something to
  /// click, and a stronger one while they're the filter in force.
  Widget _stat(
    GameTheme t,
    String label,
    String value,
    Color color, {
    required String tooltip,
    required bool active,
    required bool tappable,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: t.border)),
      ),
      child: Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 400),
        child: HoverBuilder(
          cursor:
              tappable ? SystemMouseCursors.click : SystemMouseCursors.basic,
          builder: (context, hovered) => GestureDetector(
            onTap: tappable ? onTap : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: active
                    ? color.withValues(alpha: .14)
                    : hovered && tappable
                        ? color.withValues(alpha: .07)
                        : Colors.transparent,
                borderRadius: BorderRadius.circular(9),
              ),
              child: _statBody(t, label, value, color),
            ),
          ),
        ),
      ),
    );
  }

  /// Total is the way back out: it clears every filter at once, so the
  /// number it shows is the number you end up looking at.
  Widget _totalStat(GameTheme t, AppController c, L l) {
    final tappable = c.isFiltering;
    return _stat(
      t,
      l.statTotal,
      '${c.mods.length}',
      t.text,
      tooltip: tappable ? l.statTotalTooltipClear : l.statTotalTooltip,
      active: false,
      tappable: tappable,
      onTap: c.clearFilters,
    );
  }

  /// The Enabled and Disabled stats narrow the library to their own half,
  /// and let go of it when clicked again.
  Widget _stateStat(GameTheme t, AppController c, L l, ModStateFilter state) {
    final enabled = state == ModStateFilter.enabled;
    final count = enabled ? c.enabledCount : c.disabledCount;
    final active = c.stateFilter == state;
    return _stat(
      t,
      enabled ? l.statEnabled : l.statDisabled,
      '$count',
      enabled ? t.accent : t.muted,
      tooltip: active
          ? (enabled ? l.statEnabledTooltipActive : l.statDisabledTooltipActive)
          : '${enabled ? l.statEnabledTooltip : l.statDisabledTooltip}'
              '${count > 0 ? ' ${l.conflictTooltipClickHint}' : ''}',
      active: active,
      tappable: active || count > 0,
      onTap: () => c.showOnly(state),
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

  /// A tooltip spells out what "conflict" means here (duplicate names,
  /// versions, or packages overriding the same resources).
  Widget _conflictStat(GameTheme t, AppController c, L l) {
    final active = c.conflictsOnly;
    final tappable = active || c.conflictCount > 0;
    return _stat(
      t,
      l.statConflicts,
      '${c.conflictCount}',
      t.warning,
      tooltip: active
          ? l.conflictTooltipActive
          : '${l.conflictTooltip}'
              '${tappable ? ' ${l.conflictTooltipClickHint}' : ''}',
      active: active,
      tappable: tappable,
      onTap: c.toggleConflictsOnly,
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

  /// The list, gathered under a header per subfolder. The sections are
  /// flattened into one lazy list rather than built as nested columns so
  /// a library of thousands still only builds the rows on screen.
  Widget _modFolders(GameTheme t, AppController c) {
    final rows = <_FolderRow>[];
    for (final group in c.folderGroups) {
      rows.add((group: group, mod: null));
      if (c.isFolderCollapsed(group.folder)) continue;
      for (final mod in group.mods) {
        rows.add((group: null, mod: mod));
      }
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(28, 4, 28, 28),
      itemCount: rows.length,
      // A header wants air above it; rows under one sit close together.
      separatorBuilder: (_, i) =>
          SizedBox(height: rows[i + 1].group != null ? 18 : 8),
      itemBuilder: (context, i) {
        final row = rows[i];
        final group = row.group;
        return group == null
            ? _ListRow(theme: t, controller: c, mod: row.mod!)
            : _FolderHeader(theme: t, controller: c, group: group);
      },
    );
  }
}

/// What clicking a mod does. Ctrl (Cmd on a Mac) ticks it, shift extends
/// the range from the last one ticked on its own, and a plain click opens
/// it - unless something is already ticked, in which case it ticks this
/// one too. Once the library is in selection mode a click that walked off
/// to a detail page instead would leave the selection behind it, which is
/// not what anyone means by it.
void _tapMod(AppController c, Mod mod) {
  final keys = HardwareKeyboard.instance;
  if (keys.isShiftPressed) return c.selectTo(mod);
  if (keys.isControlPressed || keys.isMetaPressed) return c.toggleSelected(mod);
  if (c.hasSelection) return c.toggleSelected(mod);
  c.openMod(mod);
}

/// What a drag of mods between folders carries: the mod it started on,
/// and nothing else.
///
/// The whole selection is worked out at the drop rather than packed in
/// here, because a `Draggable`'s data is an ordinary constructor argument
/// - built during every `build`, for every card on screen, whether or not
/// anything is ever dragged. Reading the selection there cost a walk of
/// the entire library per card per frame.
///
/// A type of its own so the folder chips' existing `DragTarget<String>`,
/// which rearranges the chips themselves, can never catch one.
class _ModDrag {
  const _ModDrag(this.mod);

  final Mod mod;

  /// What this drag is actually carrying, asked once, when it lands: the
  /// whole selection when the mod it started on is part of one.
  List<Mod> mods(AppController c) =>
      c.isSelected(mod) ? c.selectedMods : [mod];
}

/// Makes [child] a drag source for [mod] - for the whole selection when
/// [mod] is part of one, so dragging any of thirty ticked mods moves the
/// thirty.
///
/// `affinity: Axis.horizontal` is what keeps this out of the library's
/// way: a drag up or down scrolls the shelf exactly as it always did, and
/// only a sideways one picks a mod up.
Widget _draggableMod(
  AppController c,
  GameTheme t,
  L l,
  Mod mod, {
  required Widget child,
}) {
  // A mod the app has no business moving is not offered the gesture: the
  // games that keep files in folders of their own (The Sims 1's skins and
  // walls) would take the drag and then refuse it.
  if (!c.canMoveMods || !c.canMove(mod)) return child;
  return Draggable<_ModDrag>(
    data: _ModDrag(mod),
    affinity: Axis.horizontal,
    dragAnchorStrategy: pointerDragAnchorStrategy,
    feedback: _dragFeedback(c, t, l, mod),
    childWhenDragging: Opacity(opacity: .35, child: child),
    child: child,
  );
}

/// What travels under the pointer: the mod's own name for one, and the
/// count for a selection, so a drag says how much it is carrying.
Widget _dragFeedback(AppController c, GameTheme t, L l, Mod mod) {
  final count = c.isSelected(mod) ? c.selectedCount : 1;
  return Material(
    type: MaterialType.transparency,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      constraints: const BoxConstraints(maxWidth: 260),
      decoration: BoxDecoration(
        color: t.accent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: t.shadow.withValues(alpha: .4),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.drive_file_move_outlined,
              size: 15, color: Colors.white),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              count == 1 ? modTitle(mod) : l.selectionCount(count),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Wraps [child] as somewhere mods can be dropped: [folder] as a folder
/// key, or null for the mods folder itself. [highlight] draws the state
/// where a drop would land here.
Widget _folderDropTarget(
  AppController c,
  String? folder, {
  required Widget child,
  required Widget Function(Widget child) highlight,
}) {
  return DragTarget<_ModDrag>(
    onWillAcceptWithDetails: (details) =>
        c.canMoveMods && (folder == null || c.canMoveInto(folder)),
    onAcceptWithDetails: (details) =>
        c.moveMods(details.data.mods(c), folder, method: 'drag'),
    builder: (context, candidates, __) =>
        candidates.isEmpty ? child : highlight(child),
  );
}

/// The tick on a mod's card or row. Drawn under the pointer, and on
/// everything once anything is selected, so a library mid-selection reads
/// as a set of boxes rather than as mods that happen to be highlighted.
class _SelectTick extends StatelessWidget {
  const _SelectTick(
      {required this.theme, required this.controller, required this.mod});

  final GameTheme theme;
  final AppController controller;
  final Mod mod;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final selected = controller.isSelected(mod);
    return Tooltip(
      message: L.of(context).selectionTooltip,
      waitDuration: const Duration(milliseconds: 600),
      child: HoverBuilder(
        cursor: SystemMouseCursors.click,
        builder: (context, hovered) => GestureDetector(
          onTap: () => controller.toggleSelected(mod),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: selected
                  ? t.accent
                  : Colors.black.withValues(alpha: hovered ? .45 : .3),
              border: Border.all(
                  color: Colors.white.withValues(alpha: .85), width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: selected
                ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                : null,
          ),
        ),
      ),
    );
  }
}

/// What the header's stats give way to once anything is ticked: what the
/// selection holds, and everything that can be done to all of it at once.
///
/// The actions are icons with tooltips, like the sort and view buttons in
/// the header above, and for a harder reason than matching them: five
/// labelled verbs is more width than a minimum-size window has once they
/// are translated - "Απενεργοποίηση" alone is twice "Disable" - and a bar
/// whose labels come and go with the window is worse than one that never
/// had them.
class _SelectionBar extends StatelessWidget {
  const _SelectionBar({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    final progress = c.bulkProgress;
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: t.tint,
        border: Border.all(color: t.accent, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 18, color: t.accent),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              '${l.selectionCount(c.selectedCount)}'
              ' · ${formatBytes(c.selectedSizeBytes)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: t.text,
              ),
            ),
          ),
          if (progress != null)
            ..._working(t, c, l, progress)
          else
            ..._actions(context, t, c, l),
        ],
      ),
    );
  }

  /// Mid-batch: how far along it is, and the way out. Cancelling stops
  /// the next file rather than putting back the ones already done - these
  /// are renames and deletes on disk, and the bar doesn't pretend
  /// otherwise.
  List<Widget> _working(
      GameTheme t, AppController c, L l, (int, int) progress) {
    return [
      SizedBox(
        width: 96,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.$2 == 0 ? null : progress.$1 / progress.$2,
            color: t.accent,
            backgroundColor: t.surface,
            minHeight: 5,
          ),
        ),
      ),
      const SizedBox(width: 10),
      Text(
        l.selectionProgress(progress.$1, progress.$2),
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: t.muted,
        ),
      ),
      _action(t, l.cancel, Icons.stop_rounded, t.muted, c.cancelBulk),
    ];
  }

  List<Widget> _actions(
      BuildContext context, GameTheme t, AppController c, L l) {
    return [
      if (!c.allVisibleSelected)
        _action(t, l.selectionSelectAll, Icons.select_all_rounded, t.text,
            c.selectAllVisible),
      _action(t, l.selectionEnable, Icons.check_rounded, t.accent,
          () => c.setSelectedEnabled(true)),
      _action(t, l.selectionDisable, Icons.block_rounded, t.muted,
          () => c.setSelectedEnabled(false)),
      // Only when something in the selection can actually go somewhere:
      // a Move button that opens a dialog and then quietly does nothing
      // is worse than no Move button.
      if (c.canMoveMods && c.hasMovableSelection)
        _action(
            t,
            l.selectionMove,
            Icons.drive_file_move_outlined,
            t.text,
            () => askWhereToMove(context, c,
                theme: t,
                mods: [for (final mod in c.selectedMods) if (c.canMove(mod)) mod],
                method: 'selection')),
      _action(t, l.uninstall, Icons.delete_outline_rounded, t.warning,
          () => _confirmRemove(context, t, c, l)),
      _action(t, l.selectionClear, Icons.close_rounded, t.muted,
          c.clearSelection),
    ];
  }

  Widget _action(GameTheme t, String label, IconData icon, Color color,
      VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Tooltip(
        message: label,
        waitDuration: const Duration(milliseconds: 400),
        child: HoverBuilder(
          cursor: SystemMouseCursors.click,
          builder: (context, hovered) => GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 32,
              height: 30,
              decoration: BoxDecoration(
                color: hovered ? color.withValues(alpha: .13) : t.surface,
                border: Border.all(
                    color: hovered ? color.withValues(alpha: .55) : t.border),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRemove(
      BuildContext context, GameTheme t, AppController c, L l) async {
    final count = c.selectedCount;
    var confirmed = true;
    if (c.settings.confirmDelete) {
      c.playSound(UiSound.alert);
      confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: t.surface,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                l.selectionDeleteTitle(count),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: t.text,
                ),
              ),
              content: Text(
                l.selectionDeleteBody(count),
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
                  style: FilledButton.styleFrom(backgroundColor: t.warning),
                  child: Text(l.uninstall,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ) ??
          false;
    }
    if (confirmed) await c.removeSelected();
  }
}

/// One line of the folder view: a section header, or a mod belonging to
/// the header above it. Exactly one of the two is set.
typedef _FolderRow = ({ModFolderGroup? group, Mod? mod});

/// A folder view section header: what the folder is called, how much it
/// holds, and a chevron that rolls it up.
class _FolderHeader extends StatelessWidget {
  const _FolderHeader(
      {required this.theme, required this.controller, required this.group});

  final GameTheme theme;
  final AppController controller;
  final ModFolderGroup group;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    final folder = group.folder;
    return _folderDropTarget(
      c,
      folder,
      highlight: (child) => DecoratedBox(
        decoration: BoxDecoration(
          color: t.tint,
          border: Border.all(color: t.accent, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: child,
      ),
      child: _header(t, c, l, folder),
    );
  }

  Widget _header(GameTheme t, AppController c, L l, String? folder) {
    final collapsed = c.isFolderCollapsed(folder);
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: () => c.toggleFolderCollapsed(folder),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: hovered ? t.surfaceAlt : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              AnimatedRotation(
                duration: const Duration(milliseconds: 160),
                turns: collapsed ? -0.25 : 0,
                child: Icon(Icons.expand_more_rounded,
                    size: 19, color: t.muted),
              ),
              const SizedBox(width: 8),
              Icon(
                folder == null
                    ? Icons.inventory_2_rounded
                    : Icons.folder_rounded,
                size: 16,
                color: t.accent,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  folder == null ? l.libraryRootFolder : folderChipLabel(folder),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: t.text,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                // A folder the user just made says so rather than reading
                // "0 · 0 B", which looks like something went wrong.
                group.mods.isEmpty
                    ? l.folderEmptySection
                    : '${group.mods.length} · ${formatBytes(group.sizeBytes)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: t.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One entry of the filter row: a category or a mods subfolder.
typedef _FilterEntry = ({String label, bool isFolder});

/// The single-line filter row: category chips, then folder chips.
/// Chips that don't fit move into a "..." popup menu at the end
/// ([OverflowRow]). Folder chips, and only folder chips, can be
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
  /// How many leading chips fit on the line, recorded by [OverflowRow]
  /// during layout and read when the "..." menu opens (no rebuild needed).
  int _visibleCount = 0;

  final GlobalKey _dotsKey = GlobalKey();

  /// The "..." menu. A hand-rolled overlay instead of [showMenu]: a modal
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
    final l = L.of(context);
    final entries = _entries(c);
    return OverflowRow(
      spacing: 9,
      onVisibleCountChanged: (n) {
        if (n == _visibleCount) return;
        _visibleCount = n;
        // The open menu lists the chips that no longer fit; refresh it
        // once this layout pass is over.
        if (_menuEntry != null) {
          WidgetsBinding.instance
              .addPostFrameCallback((_) => _menuEntry?.markNeedsBuild());
        }
      },
      children: [
        for (final e in entries)
          e.isFolder
              ? _folderChip(t, c, e.label)
              : _categoryChip(t, c, l, e.label),
        _overflowButton(t, c),
      ],
    );
  }

  Widget _categoryChip(GameTheme t, AppController c, L l, String cat) => _chip(
        t,
        categoryChipLabel(l, cat),
        count: c.categoryCount(cat),
        active: cat == c.category,
        onTap: () => c.setCategory(cat),
        // 'All' is neither axis, so it stays bare; the rest say what
        // they filter on, since a file type and a folder of the user's
        // own sit side by side on this line.
        icon: cat == 'All' ? null : Icons.description_rounded,
      );

  /// A folder chip is also a drag source and two kinds of drop target:
  /// dropping folder A onto folder B moves A into B's position, and
  /// dropping *mods* onto it files them there. The two payloads are
  /// different types, so neither drag can ever be taken for the other.
  /// Categories are none of this, so the arrangement never touches the
  /// other filters.
  Widget _folderChip(GameTheme t, AppController c, String f) {
    return _folderDropTarget(
      c,
      f,
      highlight: (child) => Stack(
        children: [
          child,
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: t.accent.withValues(alpha: .2),
                  border: Border.all(color: t.accent, width: 2),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      child: _reorderableFolderChip(t, c, f),
    );
  }

  Widget _reorderableFolderChip(GameTheme t, AppController c, String f) {
    final chip = _chip(
      t,
      folderChipLabel(f),
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
        final l = L.of(context);
        final entries = _entries(c);
        final hidden = entries.sublist(_visibleCount.clamp(0, entries.length));
        if (hidden.isEmpty) {
          // Everything fits again (e.g. the last hidden folder was
          // dragged onto the line), so nothing is left to show.
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
                    boxShadow: [
                      BoxShadow(
                        color: t.shadow.withValues(alpha: .2),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
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
                          for (final e in hidden) _menuRow(t, c, l, e),
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
  Widget _menuRow(GameTheme t, AppController c, L l, _FilterEntry e) {
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
              if (e.isFolder || e.label != 'All') ...[
                Icon(
                  e.isFolder ? Icons.folder_rounded : Icons.description_rounded,
                  size: 14,
                  color: active ? t.accent : t.muted,
                ),
                const SizedBox(width: 7),
              ],
              Flexible(
                child: Text(
                  e.isFolder
                      ? folderChipLabel(e.label)
                      : categoryChipLabel(l, e.label),
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
          folderChipLabel(e.label),
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
    final l = L.of(context);
    final selected = c.isSelected(mod);
    // An advisory outranks a conflict: somebody has confirmed this one is
    // broken, where a conflict is only two files that look alike. A
    // waiting update is the mildest of the three and only speaks when the
    // others have nothing to say.
    final badge = switch ((
      c.advisoryOf(mod) != null,
      c.isConflicted(mod),
      c.shopUpdateForMod(mod) != null,
    )) {
      (true, _, _) => ConflictBadge(theme: t, label: l.advisoryBadge),
      (false, true, _) => ConflictBadge(theme: t),
      (false, false, true) => ConflictBadge(
          theme: t, label: l.shopUpdateBadge, color: t.accent, icon: '↓'),
      _ => null,
    };
    return _draggableMod(c, t, l, mod, child: _card(context, t, c, l, badge, selected));
  }

  Widget _card(BuildContext context, GameTheme t, AppController c, L l,
      Widget? badge, bool selected) {
    final mod = this.mod;
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: () => _tapMod(c, mod),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0, hovered ? -3 : 0, 0),
          decoration: BoxDecoration(
            color: selected ? t.tint : t.surface,
            border: Border.all(
              color: selected || hovered ? t.accent : t.border,
              width: selected ? 1.5 : 1,
            ),
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
                  fit: StackFit.expand,
                  children: [
                    ModThumb(
                      seed: mod.name,
                      bytes: c.thumbnailOf(mod),
                      // Cards are at most ~320 logical px wide.
                      decodeWidth: 640,
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
                    if (badge != null || hovered || c.hasSelection)
                      Positioned(
                        left: 10,
                        top: 10,
                        child: Row(
                          children: [
                            if (hovered || c.hasSelection) ...[
                              _SelectTick(theme: t, controller: c, mod: mod),
                              const SizedBox(width: 7),
                            ],
                            if (badge != null) badge,
                          ],
                        ),
                      ),
                    Positioned(
                      right: 9,
                      top: 9,
                      child: PillSwitch(
                        value: mod.isEnabled,
                        activeColor: t.accent,
                        inactiveColor: t.switchOff,
                        shadow: t.shadow,
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
                          if (modVersion(mod) != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              modVersion(mod)!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: t.muted.withValues(alpha: .75),
                              ),
                            ),
                          ],
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
                        modSubtitle(l, c, mod),
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
                            label: l.categoryName(mod.category),
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
    final l = L.of(context);
    final selected = c.isSelected(mod);
    return _draggableMod(c, t, l, mod, child: _row(t, c, l, selected));
  }

  Widget _row(GameTheme t, AppController c, L l, bool selected) {
    final mod = this.mod;
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: () => _tapMod(c, mod),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          transform: Matrix4.translationValues(hovered ? 3 : 0, 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? t.tint : t.surface,
            border: Border.all(
              color: selected || hovered ? t.accent : t.border,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                height: 52,
                // The tick sits on the thumbnail rather than beside it:
                // a box that appears on hover and takes width of its own
                // would shift every row under the pointer.
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ModThumb(
                        seed: mod.name,
                        bytes: c.thumbnailOf(mod),
                        decodeWidth: 128, // a 52px row thumbnail
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    if (hovered || c.hasSelection)
                      Positioned(
                        left: 3,
                        top: 3,
                        child: _SelectTick(theme: t, controller: c, mod: mod),
                      ),
                  ],
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
                          if (modVersion(mod) != null)
                            TextSpan(
                              text: '  ${modVersion(mod)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: t.muted.withValues(alpha: .75),
                              ),
                            ),
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
                      '${modSubtitle(l, c, mod)} · ${modDate(mod)}',
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
              if (c.advisoryOf(mod) != null) ...[
                TagChip(
                  label: l.advisoryBadge,
                  color: t.warning,
                  background: t.warning.withValues(alpha: .12),
                ),
                const SizedBox(width: 8),
              ],
              if (c.isConflicted(mod)) ...[
                TagChip(
                  label: l.conflictBadge,
                  color: t.warning,
                  background: t.warning.withValues(alpha: .12),
                ),
                const SizedBox(width: 8),
              ],
              if (c.shopUpdateForMod(mod) != null) ...[
                TagChip(
                  label: l.shopUpdateBadge,
                  color: t.accent,
                  background: t.tint,
                ),
                const SizedBox(width: 8),
              ],
              TagChip(
                label: l.categoryName(mod.category),
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
                inactiveColor: t.switchOff,
                shadow: t.shadow,
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
    final l = L.of(context);
    final filtering = c.isFiltering || !c.settings.showDisabled;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            filtering ? l.emptyFiltered : l.emptyNoMods,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: t.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            filtering
                ? l.emptyFilteredHint
                : l.emptyNoModsHint('${c.modsDir?.path}'),
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
              style: accentButtonStyle(t),
              child: Text(l.openFolder),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shown when no mods folder could be located: explains the game's setup,
/// offers manual selection, found candidates, and one-click creation of
/// the default folder: the "game not installed / no Mods folder yet /
/// multiple installs" caveats.
class _FolderSetupView extends StatelessWidget {
  const _FolderSetupView({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    // The game folder being present changes the story entirely: the game
    // is there, only its mods folder is missing; don't suggest the game
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
                    ? l.setupFoundNoModsFolder(c.adapter.game.name)
                    : l.setupNotFound(c.adapter.game.name),
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
                    ? l.setupFoundNoModsFolderBody
                    : l.setupNotFoundBody,
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
                  l.setupHelp(c.adapter.setupHelpKey),
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
                Text(l.foundOnThisComputer, style: eyebrowStyle(t)),
                const SizedBox(height: 8),
                for (final dir in c.candidateDirs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _candidateRow(t, c, l, dir.path),
                  ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: c.pickFolderOverride,
                      style: FilledButton.styleFrom(
                        backgroundColor: t.accent,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11)),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 13.5),
                      ),
                      child: Text(l.chooseFolder),
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
                        child: Text(l.createItForMe),
                      ),
                    ),
                  ],
                ],
              ),
              if (c.defaultPath != null) ...[
                const SizedBox(height: 12),
                Text(
                  l.willBeCreatedAt('${c.defaultPath}'),
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
                  label: Text(l.checkAgain),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _candidateRow(GameTheme t, AppController c, L l, String path) {
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
            child: Text(l.useThis),
          ),
        ],
      ),
    );
  }
}
