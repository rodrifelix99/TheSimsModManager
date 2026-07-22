import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../services/sfx.dart';
import 'app_controller.dart';
import 'game_theme.dart';
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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              height: 1,
              color: t.text,
            ),
          ),
          const SizedBox(height: 22),
          _sectionLabel(t, 'MOD MANAGEMENT'),
          Container(
            decoration: _cardDecoration(t),
            child: Column(
              children: [
                _prefRow(
                  t,
                  title: 'Warn about conflicts',
                  desc:
                      'Scan enabled mods for duplicate file names and badge '
                      'them in the library',
                  value: s.warnConflicts,
                  onToggle: () => c.setPref(
                    () => s.setWarnConflicts(!s.warnConflicts),
                    sound: _toggleSound(s.warnConflicts),
                  ),
                ),
                _divider(t),
                _prefRow(
                  t,
                  title: 'Confirm before uninstalling',
                  desc: 'Ask before a mod file is deleted from disk',
                  value: s.confirmDelete,
                  onToggle: () => c.setPref(
                    () => s.setConfirmDelete(!s.confirmDelete),
                    sound: _toggleSound(s.confirmDelete),
                  ),
                ),
                _divider(t),
                _prefRow(
                  t,
                  title: 'Show disabled mods',
                  desc: 'Keep disabled mods visible in the library instead '
                      'of hiding them',
                  value: s.showDisabled,
                  onToggle: () => c.setPref(
                    () => s.setShowDisabled(!s.showDisabled),
                    sound: _toggleSound(s.showDisabled),
                  ),
                ),
                _divider(t),
                _prefRow(
                  t,
                  title: 'UI sound effects',
                  desc: 'Play the classic Sims interface sounds on clicks, '
                      'toggles and alerts',
                  value: s.soundEffects,
                  onToggle: () => c.setPref(
                    () => s.setSoundEffects(!s.soundEffects),
                    sound: _toggleSound(s.soundEffects),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel(t, 'MODS FOLDER — ${c.adapter.game.name}'),
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
                            c.modsDir?.path ?? 'Not found — choose a folder',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12.5,
                              color: t.text,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            c.modsDir == null
                                ? 'The game (or its mods folder) was not '
                                    'located automatically'
                                : '${c.mods.length} mods · '
                                    '${formatBytes(c.totalSizeBytes)} on disk'
                                    '${c.usingOverride ? ' · custom folder' : ''}',
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
                      onPressed: () => _chooseFolder(c),
                      style: _accentButtonStyle(t),
                      child: const Text('Change…'),
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
                        child: const Text('Reset to auto'),
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
                          'Create the default folder (with the files the '
                          'game needs) at:\n${c.defaultPath}',
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
                        style: _accentButtonStyle(t),
                        child: const Text('Create folder'),
                      ),
                    ],
                  ),
                ],
                // Multiple installs of the same game, each with its own
                // mods folder (localized names, Wine prefixes, …).
                if (c.candidateDirs.length > 1) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Also found on this computer:',
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
                              child: const Text('Use this'),
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
            c.adapter.setupHelp,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: t.muted,
            ),
          ),
          const SizedBox(height: 24),
          _sectionLabel(t, 'ABOUT'),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: _cardDecoration(t),
            child: Row(
              children: [
                Transform.rotate(
                  angle: 0.785398,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      gradient: t.accentGradient,
                      borderRadius: BorderRadius.circular(7),
                      boxShadow: [
                        BoxShadow(
                          color: t.accent.withValues(alpha: .5),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sims Mod Manager',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: t.text,
                        ),
                      ),
                      Text(
                        'Version 1.0 · The Sims 1–4 supported · '
                        'SimCity coming soon',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: t.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Sound for flipping a pref that currently reads [current].
  static UiSound _toggleSound(bool current) =>
      current ? UiSound.toggleOff : UiSound.toggleOn;

  static Future<void> _chooseFolder(AppController c) async {
    final path = await getDirectoryPath();
    if (path == null) return;
    if (!await Directory(path).exists()) return;
    await c.setFolderOverride(path);
  }

  ButtonStyle _accentButtonStyle(GameTheme t) => OutlinedButton.styleFrom(
        foregroundColor: t.accent,
        backgroundColor: t.tint,
        side: BorderSide(color: t.accent, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
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
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: t.muted,
          ),
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
          Expanded(
            child: Column(
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
            ),
          ),
          const SizedBox(width: 16),
          PillSwitch(
            value: value,
            width: 44,
            height: 25,
            activeColor: t.accent,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}
