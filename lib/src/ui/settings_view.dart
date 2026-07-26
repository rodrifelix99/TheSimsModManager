import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../app_version.dart';
import '../services/sfx.dart';
import 'app_controller.dart';
import 'game_theme.dart';
import 'l10n.dart';
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
                  title: l.prefScanArtworkTitle,
                  desc: l.prefScanArtworkDesc,
                  value: s.scanArtwork,
                  // Own action, not setPref: flipping it also rescans the
                  // library (on) or clears the cached artwork (off).
                  onToggle: () => c.setScanArtwork(!s.scanArtwork),
                ),
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
                BrandMark(theme: t, size: 26),
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
              child: _prefRow(
                t,
                title: 'Demo library',
                desc: 'Fill every game with invented mods, for screenshots. '
                    'Nothing is written to disk.',
                value: c.demoLibrary,
                onToggle: () => c.setDemoLibrary(!c.demoLibrary),
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
              decoration: BoxDecoration(
                color: t.tint,
                border: Border.all(color: t.accent, width: 1.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    current.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: t.accent,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.expand_more_rounded, size: 17, color: t.accent),
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
  Widget _rowLabel(GameTheme t, String title, String desc) => Column(
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

  BoxDecoration _cardDecoration(GameTheme t) => BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.border),
        borderRadius: BorderRadius.circular(14),
      );

  Widget _sectionLabel(GameTheme t, String label) => Padding(
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
