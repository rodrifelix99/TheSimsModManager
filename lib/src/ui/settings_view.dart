import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../app_version.dart';
import '../core/game_adapter.dart' show defaultDisabledSuffix;
import '../services/reachability.dart' show debugReachabilityScenarios;
import '../services/sfx.dart';
import 'app_controller.dart';
import 'game_skin.dart';
import 'game_theme.dart';
import 'install_folder_dialog.dart';
import 'l10n.dart';
import 'mod_presentation.dart';
import 'widgets.dart';

/// Settings: mod-management toggles, per-game mods folder, about card.
class SettingsView extends StatelessWidget {
  const SettingsView(
      {super.key, required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final s = c.settings;
    final l = L.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.settingsTitle,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              height: 1,
              color: t.text,
            ),
          ),
          const SizedBox(height: 22),
          _sectionLabel(t, l.sectionModManagement),
          Container(
            decoration: _cardDecoration(t),
            child: Column(
              children: [
                _prefRow(
                  t,
                  title: l.prefWarnConflictsTitle,
                  desc: l.prefWarnConflictsDesc,
                  value: s.warnConflicts,
                  onToggle: () => c.setPref(
                    () => s.setWarnConflicts(!s.warnConflicts),
                    sound: _toggleSound(s.warnConflicts),
                    setting: 'warnConflicts',
                    value: !s.warnConflicts,
                  ),
                ),
                _divider(t),
                _prefRow(
                  t,
                  title: l.prefConfirmDeleteTitle,
                  desc: l.prefConfirmDeleteDesc,
                  value: s.confirmDelete,
                  onToggle: () => c.setPref(
                    () => s.setConfirmDelete(!s.confirmDelete),
                    sound: _toggleSound(s.confirmDelete),
                    setting: 'confirmDelete',
                    value: !s.confirmDelete,
                  ),
                ),
                // Only games that read mods from several folders have
                // anywhere else to put one, so for the rest this would be
                // a switch with nothing behind it. Shown anyway once it is
                // off, because The Exchange can raise the question for a
                // game the sidebar isn't pointing at and the way back has
                // to be somewhere.
                if (c.hasInstallChoice || !s.askWhereToInstall) ...[
                  _divider(t),
                  _prefRow(
                    t,
                    title: l.prefAskWhereTitle,
                    desc: l.prefAskWhereDesc,
                    value: s.askWhereToInstall,
                    onToggle: () => c.setPref(
                      () => s.setAskWhereToInstall(!s.askWhereToInstall),
                      sound: _toggleSound(s.askWhereToInstall),
                      setting: 'askWhereToInstall',
                      value: !s.askWhereToInstall,
                    ),
                  ),
                ],
                _divider(t),
                _prefRow(
                  t,
                  title: l.prefShowDisabledTitle,
                  desc: l.prefShowDisabledDesc,
                  value: s.showDisabled,
                  onToggle: () => c.setPref(
                    () => s.setShowDisabled(!s.showDisabled),
                    sound: _toggleSound(s.showDisabled),
                    setting: 'showDisabled',
                    value: !s.showDisabled,
                  ),
                ),
                _divider(t),
                _prefRow(
                  t,
                  title: l.prefSubfoldersTitle,
                  desc: l.prefSubfoldersDesc,
                  value: s.folderIncludesSubfolders,
                  // Own action, not setPref: the counts on the chips are
                  // worked out as the library is read, so flipping this
                  // has to rebuild it rather than just redraw it.
                  onToggle: () =>
                      c.setFolderIncludesSubfolders(!s.folderIncludesSubfolders),
                ),
                _divider(t),
                _SuffixRow(theme: t, controller: c),
                _divider(t),
                _prefRow(
                  t,
                  title: l.prefScanArtworkTitle,
                  desc: l.prefScanArtworkDesc,
                  value: s.scanArtwork,
                  // Own action, not setPref: flipping it also rescans the
                  // library (on) or clears the cached artwork (off).
                  onToggle: () => c.setScanArtwork(!s.scanArtwork),
                ),
                // Only where it could do anything: the games whose packs
                // switch safely never look at this, and offering it on
                // them would read as a warning about them too.
                if (c.packsAreExperimental) ...[
                  _divider(t),
                  _prefRow(
                    t,
                    title: l.prefExperimentalPacksTitle,
                    desc: l.prefExperimentalPacksDesc,
                    value: s.experimentalPackToggles,
                    onToggle: () => c.setPref(
                      () => s.setExperimentalPackToggles(
                          !s.experimentalPackToggles),
                      sound: _toggleSound(s.experimentalPackToggles),
                      setting: 'experimentalPackToggles',
                      value: !s.experimentalPackToggles,
                    ),
                  ),
                ],
                _divider(t),
                _prefRow(
                  t,
                  title: l.prefSoundEffectsTitle,
                  desc: l.prefSoundEffectsDesc,
                  value: s.soundEffects,
                  onToggle: () => c.setPref(
                    () => s.setSoundEffects(!s.soundEffects),
                    sound: _toggleSound(s.soundEffects),
                    setting: 'soundEffects',
                    value: !s.soundEffects,
                  ),
                ),
                _divider(t),
                // Its own action rather than setPref: switching it back on
                // has to restart the timer, or the buddy would return
                // silent until the next launch.
                _prefRow(
                  t,
                  title: l.prefTriviaTitle,
                  desc: l.prefTriviaDesc,
                  value: s.triviaBuddy,
                  onToggle: () => c.setTriviaBuddy(!s.triviaBuddy),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel(t, l.sectionStartup),
          Container(
            decoration: _cardDecoration(t),
            child: Column(
              children: [
                _pickerRow(
                  t,
                  title: l.prefDefaultGameTitle,
                  desc: l.prefDefaultGameDesc,
                  selected: s.defaultGameId ?? '',
                  options: [
                    (value: '', label: l.defaultGameAuto),
                    for (final adapter in c.registry.adapters)
                      (value: adapter.game.id, label: adapter.game.name),
                  ],
                  onSelected: (value) =>
                      c.setDefaultGame(value.isEmpty ? null : value),
                ),
                _divider(t),
                _linkRow(
                  t,
                  title: l.prefSetupGuideTitle,
                  desc: l.prefSetupGuideDesc,
                  buttonLabel: l.onboardingReplay,
                  onTap: c.restartOnboarding,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel(t, l.sectionAppearance),
          Container(
            decoration: _cardDecoration(t),
            child: _themeRow(t, c, l),
          ),
          const SizedBox(height: 24),
          _sectionLabel(t, l.sectionLanguage),
          Container(
            decoration: _cardDecoration(t),
            child: Column(
              // The credits are the one row with no trailing control to
              // stretch them, so without this they sit centered while
              // every other row in the card runs flush left.
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _languageRow(t, c, l),
                _divider(t),
                _translatorsBlock(context, t, l),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel(t, l.sectionPrivacy),
          Container(
            decoration: _cardDecoration(t),
            child: _prefRow(
              t,
              title: l.prefAnalyticsTitle,
              desc: l.prefAnalyticsDesc,
              value: s.analyticsEnabled,
              // Own action, not setPref: the analytics service handles
              // its own opt-in/out bookkeeping around the flip.
              onToggle: () => c.setAnalyticsEnabled(!s.analyticsEnabled),
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel(t, l.sectionModsFolder(c.adapter.game.name)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: _cardDecoration(t),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.modsDir?.path ?? l.folderNotFound,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12.5,
                              color: t.text,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            c.modsDir == null
                                ? l.folderNotLocated
                                : l.folderSummary(c.mods.length,
                                        formatBytes(c.totalSizeBytes)) +
                                    (c.usingOverride
                                        ? ' · ${l.customFolder}'
                                        : ''),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: t.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: c.pickFolderOverride,
                      style: accentButtonStyle(t),
                      child: Text(l.change),
                    ),
                    if (c.usingOverride) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: c.clearFolderOverride,
                        style: TextButton.styleFrom(
                          foregroundColor: t.muted,
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        child: Text(l.resetToAuto),
                      ),
                    ],
                  ],
                ),
                // Why the library holds more than this folder does. Only
                // the game's own manifest puts anything here, so a user
                // who never heard of it still gets told.
                if (c.extraModsDirs.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.subdirectory_arrow_right_rounded,
                          size: 15, color: t.muted),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          l.folderAlsoReading([
                            for (final dir in c.extraModsDirs)
                              p.basename(dir.path),
                          ].join(', ')),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: t.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (c.modsDir == null && c.defaultPath != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.createDefaultFolderAt('${c.defaultPath}'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: t.muted,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: c.createDefaultFolder,
                        style: accentButtonStyle(t),
                        child: Text(l.createFolder),
                      ),
                    ],
                  ),
                ],
                // Multiple installs of the same game, each with its own
                // mods folder (localized names, Wine prefixes, ...).
                if (c.candidateDirs.length > 1) ...[
                  const SizedBox(height: 14),
                  Text(
                    l.alsoFoundOnThisComputer,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: t.muted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (final dir in c.candidateDirs)
                    if (dir.path != c.modsDir?.path)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                dir.path,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: t.text,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => c.setFolderOverride(dir.path),
                              style: TextButton.styleFrom(
                                foregroundColor: t.accent,
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12.5),
                              ),
                              child: Text(l.useThis),
                            ),
                          ],
                        ),
                      ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l.setupHelp(c.adapter.setupHelpKey),
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: t.muted,
            ),
          ),
          // Where the shop files things for this game. Per game because
          // the folders are, and on the game's own section rather than
          // among the app-wide toggles above for the same reason - a
          // listing for another game keeps that game's answer, and its
          // own page is where it can be overruled.
          _ShopFolderRow(
              key: ValueKey(c.adapter.game.id), theme: t, controller: c),
          // The way back for a clash the user settled on a mod whose page
          // now shows nothing about it - which is most of them, since the
          // last ignored pair takes the whole warning panel with it.
          if (c.ignoredConflictCount > 0) ...[
            const SizedBox(height: 24),
            _sectionLabel(t, l.sectionIgnoredConflicts(c.adapter.game.name)),
            Container(
              decoration: _cardDecoration(t),
              child: _linkRow(
                t,
                title: l.ignoredConflictsTitle,
                desc: l.ignoredConflictsDesc(c.ignoredConflictCount),
                buttonLabel: l.ignoredConflictsReset,
                onTap: c.restoreAllConflicts,
              ),
            ),
          ],
          // Only games with a stale-cache problem (Sims 3, Medieval)
          // report cache files; for everyone else the card is absent.
          if (c.cacheFiles.isNotEmpty) ...[
            const SizedBox(height: 24),
            _sectionLabel(t, l.sectionGameCaches(c.adapter.game.name)),
            Container(
              decoration: _cardDecoration(t),
              child: _linkRow(
                t,
                title: l.clearCacheTitle,
                desc: l.clearCacheDesc(
                    c.cacheFiles.length, formatBytes(c.cacheSizeBytes)),
                buttonLabel: l.clearCaches,
                onTap: c.clearCaches,
              ),
            ),
          ],
          const SizedBox(height: 24),
          _sectionLabel(t, l.sectionFeedback),
          Container(
            decoration: _cardDecoration(t),
            child: Column(
              children: [
                _linkRow(
                  t,
                  title: l.reportBugTitle,
                  desc: l.reportBugDesc,
                  buttonLabel: l.reportBugButton,
                  onTap: c.reportBug,
                ),
                _divider(t),
                _linkRow(
                  t,
                  title: l.suggestFeatureTitle,
                  desc: l.suggestFeatureDesc,
                  buttonLabel: l.suggestFeatureButton,
                  onTap: c.suggestFeature,
                ),
                _divider(t),
                _linkRow(
                  t,
                  title: l.wikiTitle,
                  desc: l.wikiDesc,
                  buttonLabel: l.wikiButton,
                  onTap: c.openWiki,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel(t, l.sectionAbout),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration(t),
            child: Row(
              children: [
                BrandMark(gameId: c.adapter.game.id, size: 26),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.appName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: t.text,
                        ),
                      ),
                      Text(
                        l.aboutTagline(appVersion),
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: t.muted,
                        ),
                      ),
                      if (c.availableUpdate != null || c.updateCheckDone) ...[
                        const SizedBox(height: 3),
                        Text(
                          c.availableUpdate != null
                              ? l.updateIsAvailable(c.availableUpdate!.version)
                              : l.noUpdateFound,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: c.availableUpdate != null
                                ? t.accent
                                : t.muted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                if (c.availableUpdate != null)
                  OutlinedButton(
                    onPressed: c.openReleasePage,
                    style: accentButtonStyle(t),
                    child: Text(l.getVersion(c.availableUpdate!.version)),
                  )
                else
                  OutlinedButton(
                    onPressed:
                        c.checkingForUpdates ? null : c.checkForUpdates,
                    style: accentButtonStyle(t),
                    child: Text(c.checkingForUpdates
                        ? l.checkingForUpdates
                        : l.checkForUpdates),
                  ),
              ],
            ),
          ),
          // Debug builds only, and deliberately not translated: nobody
          // running the shipped app can reach this row, so putting its
          // wording through ten ARB files would only give translators
          // something meaningless to translate.
          if (kDebugMode) ...[
            const SizedBox(height: 24),
            _sectionLabel(t, 'DEVELOPER'),
            Container(
              decoration: _cardDecoration(t),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _prefRow(
                    t,
                    title: 'Demo library',
                    desc: 'Fill every game with invented mods, for '
                        'screenshots. Nothing is written to disk.',
                    value: c.demoLibrary,
                    onToggle: () => c.setDemoLibrary(!c.demoLibrary),
                  ),
                  _divider(t),
                  _pickerRow(
                    t,
                    title: 'Reachability',
                    desc: 'Pretend our services answer, or do not, whatever '
                        'this machine can actually reach. The answer is '
                        'never reported or stored; the choice below stays '
                        'picked until you change it, restart or not.',
                    selected: c.settings.debugReachability ?? '',
                    options: [
                      (value: '', label: 'Ask the network'),
                      for (final scenario in debugReachabilityScenarios)
                        (value: scenario.id, label: scenario.label),
                    ],
                    onSelected: (value) =>
                        c.setDebugReachability(value.isEmpty ? null : value),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// The language picker. "System" is the default, so most people never
  /// touch this row; the menu is there for the ones whose system language
  /// isn't the one they want to read.
  Widget _languageRow(GameTheme t, AppController c, L l) => _pickerRow(
        t,
        title: l.languageTitle,
        desc: l.languageDesc,
        selected: c.settings.localeCode ?? '',
        options: [
          (value: '', label: l.languageSystem),
          for (final language in appLanguages)
            (value: language.code, label: language.name),
        ],
        onSelected: (value) => c.setLocale(value.isEmpty ? null : value),
      );

  /// Who wrote each translation, sitting right under the picker that
  /// switches between them. Only the two labels go through the ARB files -
  /// the handles and the native language names read the same everywhere.
  /// The language currently on screen is drawn in the accent color, since
  /// that is the one credit the reader is actually looking at.
  Widget _translatorsBlock(BuildContext context, GameTheme t, L l) {
    final current = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _rowLabel(t, l.translatorsTitle, l.translatorsDesc),
          const SizedBox(height: 12),
          Wrap(
            spacing: 22,
            runSpacing: 7,
            children: [
              for (final language in appLanguages)
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: language.name,
                        style: TextStyle(
                          color: language.code == current ? t.accent : t.text,
                        ),
                      ),
                      TextSpan(
                        text: ' · ${language.by}',
                        style: TextStyle(color: t.muted),
                      ),
                    ],
                  ),
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Light, dark, or whatever the desktop is set to.
  Widget _themeRow(GameTheme t, AppController c, L l) => _pickerRow(
        t,
        title: l.themeTitle,
        desc: l.themeDesc,
        selected: c.settings.themeModeName ?? '',
        options: [
          (value: '', label: l.themeSystem),
          (value: 'light', label: l.themeLight),
          (value: 'dark', label: l.themeDark),
        ],
        onSelected: (value) => c.setThemeMode(value.isEmpty ? null : value),
      );

  /// A row whose trailing control is a dropdown of [options]. The empty
  /// string is the "follow the system" option: PopupMenuItem can't carry
  /// null and still tell "chose nothing" from "chose the default".
  Widget _pickerRow(
    GameTheme t, {
    required String title,
    required String desc,
    required String selected,
    required List<({String value, String label})> options,
    required ValueChanged<String> onSelected,
  }) {
    final current = options.firstWhere((o) => o.value == selected,
        orElse: () => options.first);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        children: [
          Expanded(child: _rowLabel(t, title, desc)),
          const SizedBox(width: 16),
          PopupMenuButton<String>(
            initialValue: current.value,
            tooltip: '',
            color: t.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: t.border)),
            onSelected: onSelected,
            itemBuilder: (context) => [
              for (final option in options)
                PopupMenuItem(
                  value: option.value,
                  child: Text(
                    option.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: t.text,
                    ),
                  ),
                ),
            ],
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: t.skin.decorate(t, SkinSurface.button,
                  radius: 10, fill: t.tint, outline: t.accent),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    current.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: t.skin
                          .ink(t, SkinSurface.button, otherwise: t.accent),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.expand_more_rounded,
                      size: 17,
                      color: t.skin
                          .ink(t, SkinSurface.button, otherwise: t.accent)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A card row with a title/description and a trailing action button
  /// that opens something outside the app.
  Widget _linkRow(
    GameTheme t, {
    required String title,
    required String desc,
    required String buttonLabel,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        children: [
          Expanded(child: _rowLabel(t, title, desc)),
          const SizedBox(width: 16),
          OutlinedButton(
            onPressed: onTap,
            style: accentButtonStyle(t),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }

  /// Sound for flipping a pref that currently reads [current].
  static UiSound _toggleSound(bool current) =>
      current ? UiSound.toggleOff : UiSound.toggleOn;

  /// The title-over-description column every card row leads with.
  static Widget _rowLabel(GameTheme t, String title, String desc) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: t.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: t.muted,
            ),
          ),
        ],
      );

  static BoxDecoration _cardDecoration(GameTheme t) =>
      t.skin.decorate(t, SkinSurface.panel, radius: 14);

  static Widget _sectionLabel(GameTheme t, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          label,
          style: eyebrowStyle(t),
        ),
      );

  Widget _divider(GameTheme t) => Container(height: 1, color: t.border);

  Widget _prefRow(
    GameTheme t, {
    required String title,
    required String desc,
    required bool value,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        children: [
          Expanded(child: _rowLabel(t, title, desc)),
          const SizedBox(width: 16),
          PillSwitch(
            value: value,
            width: 44,
            height: 25,
            activeColor: t.accent,
            inactiveColor: t.switchOff,
            shadow: t.shadow,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}

/// The marker disabling a mod appends to its file name. A field rather
/// than a list of choices because the value belongs to whatever other
/// tool the user runs alongside this one, and we don't get to know them
/// all: CC Magic writes `.off`, and the next one will write something
/// else. Empty goes back to the app's own.
/// Which subfolder installs from The Exchange land in for the game on
/// screen. Its own card rather than a row among the toggles above,
/// because the answer is per game like the folders themselves, and the
/// section label has to be able to say which game it is about.
///
/// Absent for a game with no mods folder set up and for The Sims 1,
/// which routes installs into folders of its own. Keyed on the game at
/// the call site, so switching games asks the disk again instead of
/// carrying the last game's answer over.
class _ShopFolderRow extends StatefulWidget {
  const _ShopFolderRow(
      {super.key, required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  State<_ShopFolderRow> createState() => _ShopFolderRowState();
}

class _ShopFolderRowState extends State<_ShopFolderRow> {
  bool? _choosable;

  @override
  void initState() {
    super.initState();
    _ask();
  }

  Future<void> _ask() async {
    final can =
        await widget.controller.canChooseShopFolder(widget.controller.adapter);
    if (!mounted) return;
    setState(() => _choosable = can);
  }

  Future<void> _pick() async {
    final c = widget.controller;
    final game = c.adapter.game.id;
    final chosen = await askForInstallFolder(context, c,
        theme: widget.theme,
        into: c.adapter,
        current: c.shopDestinationFolder(game));
    if (chosen == null) return;
    await c.setShopFolder(game, chosen);
  }

  @override
  Widget build(BuildContext context) {
    if (_choosable != true) return const SizedBox.shrink();
    final t = widget.theme;
    final c = widget.controller;
    final l = L.of(context);
    final folder = c.shopDestinationFolder(c.adapter.game.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        SettingsView._sectionLabel(t, l.sectionShopFolder(c.adapter.game.name)),
        Container(
          decoration: SettingsView._cardDecoration(t),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: SettingsView._rowLabel(
                    t,
                    l.prefShopFolderTitle,
                    l.prefShopFolderDesc(folder.isEmpty
                        ? l.libraryRootFolder
                        : folderChipLabel(folder)),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: _pick,
                  style: accentButtonStyle(t),
                  child: Text(l.change),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SuffixRow extends StatefulWidget {
  const _SuffixRow({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  State<_SuffixRow> createState() => _SuffixRowState();
}

class _SuffixRowState extends State<_SuffixRow> {
  late final TextEditingController _text =
      TextEditingController(text: widget.controller.settings.disabledSuffix);
  final FocusNode _focus = FocusNode();

  /// Whether what's in the box right now would break the library. Shown
  /// under the field instead of swallowing the change silently, which
  /// would read as the setting not working.
  bool _refused = false;

  @override
  void initState() {
    super.initState();
    // Committing on the way out as well as on Enter: a field that quietly
    // forgets what was typed into it is worse than one that asks twice.
    _focus.addListener(() {
      if (!_focus.hasFocus) _commit();
    });
  }

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _commit() {
    final typed = _text.text.trim();
    final ok = typed.isEmpty || widget.controller.canUseDisabledSuffix(typed);
    if (ok) {
      _text.text = typed;
      widget.controller.setDisabledSuffix(typed);
    }
    if (_refused != !ok) setState(() => _refused = !ok);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final l = L.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsView._rowLabel(
                    t, l.prefDisabledSuffixTitle, l.prefDisabledSuffixDesc),
                if (_refused) ...[
                  const SizedBox(height: 6),
                  Text(
                    l.prefDisabledSuffixInvalid,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: t.warning,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 132,
            // Drawn by the skin for the same reason the library's search
            // field is: a sunken well needs a gradient, and a border side
            // cannot carry one. The resting outline comes with it; the
            // focus ring below paints over the top.
            child: DecoratedBox(
              decoration: t.skin.decorate(t, SkinSurface.well,
                  radius: 10,
                  accent: _refused ? t.warning : t.accent,
                  fill: t.surfaceAlt,
                  outline: _refused ? t.warning : null),
              child: TextField(
              controller: _text,
              focusNode: _focus,
              onSubmitted: (_) => _commit(),
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: t.text,
              ),
              cursorColor: t.accent,
              decoration: InputDecoration(
                hintText: defaultDisabledSuffix,
                hintStyle: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: t.muted,
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: Colors.transparent, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: _refused ? t.warning : t.accent, width: 1.5),
                ),
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}
