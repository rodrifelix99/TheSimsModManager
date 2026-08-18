import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../core/game_adapter.dart';
import '../core/install_destination.dart';
import '../services/sfx.dart';
import 'app_controller.dart';
import 'game_skin.dart';
import 'game_theme.dart';
import 'l10n.dart';

/// Where an install should put its files, for a game that sorts one
/// download across more than one folder.
///
/// Only The Sims 1 does, and only when its install root was found, so for
/// everything else this returns straight away and nothing is ever shown.
/// The Sims 2 and 3 have folders of the game's own too, but nothing they
/// take could have gone in the mods folder anyway
/// ([GameAdapter.rootFileExtensions]), so there is no question to ask and
/// asking it on every `.package` install would be the wrong trade.
/// Null means the user backed out and nothing should be installed.
Future<InstallPlacement?> resolveInstallPlacement(
  BuildContext context,
  AppController controller, {
  required GameTheme theme,
  GameAdapter? into,
  Directory? target,
  List<String> subjects = const [],
}) async {
  final adapter = into ?? controller.adapter;
  if (!adapter.sortsModsAcrossFolders) return const SortedPlacement();
  final modsDir = target ?? await controller.modsDirFor(adapter);
  if (modsDir == null) return const SortedPlacement();
  final destinations = await adapter.installDestinations(modsDir);
  // One folder is not a choice, and neither is none.
  if (destinations.length < 2 || !controller.settings.askWhereToInstall) {
    return const SortedPlacement();
  }
  if (!context.mounted) return const SortedPlacement();
  controller.playSound(UiSound.open);
  return showDialog<InstallPlacement>(
    context: context,
    builder: (context) => InstallDestinationDialog(
      theme: theme,
      controller: controller,
      game: adapter.game.name,
      destinations: destinations,
      subjects: subjects,
    ),
  );
}

/// The question itself. Public and free of any file access so a test can
/// pump it with a made-up set of folders; [resolveInstallPlacement] is the
/// half that has to look at the disk first.
class InstallDestinationDialog extends StatefulWidget {
  const InstallDestinationDialog({
    super.key,
    required this.theme,
    required this.controller,
    required this.game,
    required this.destinations,
    required this.subjects,
  });

  final GameTheme theme;
  final AppController controller;
  final String game;
  final List<InstallDestination> destinations;
  final List<String> subjects;

  @override
  State<InstallDestinationDialog> createState() =>
      _InstallDestinationDialogState();
}

class _InstallDestinationDialogState
    extends State<InstallDestinationDialog> {
  /// Null is "sort it out for me", which is what the app does unasked and
  /// what this opens on.
  String? _chosen;
  bool _stopAsking = false;

  Future<void> _install() async {
    if (_stopAsking) {
      await widget.controller.settings.setAskWhereToInstall(false);
    }
    if (!mounted) return;
    Navigator.pop<InstallPlacement>(
        context,
        _chosen == null
            ? const SortedPlacement()
            : ChosenPlacement(_chosen!));
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final l = L.of(context);
    return AlertDialog(
      backgroundColor: t.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        l.installWhereTitle,
        style: TextStyle(
            fontWeight: FontWeight.w900, fontSize: 18, color: t.text),
      ),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.installWhereBody(widget.game),
              style: TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w600, color: t.muted),
            ),
            if (widget.subjects.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                _subjectLine(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: t.text),
              ),
            ],
            const SizedBox(height: 14),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _option(
                      t,
                      id: null,
                      label: l.installWhereSorted,
                      description: l.installWhereSortedDesc,
                    ),
                    for (final destination in widget.destinations)
                      _option(
                        t,
                        id: destination.id,
                        label: destination.label,
                        description: destination.descriptionKey == null
                            ? null
                            : l.destinationDescription(
                                destination.descriptionKey!),
                        mono: true,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () => setState(() => _stopAsking = !_stopAsking),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Checkbox(
                      value: _stopAsking,
                      visualDensity: VisualDensity.compact,
                      activeColor: t.accent,
                      onChanged: (value) =>
                          setState(() => _stopAsking = value ?? false),
                    ),
                    Expanded(
                      child: Text(
                        l.installWhereRemember,
                        style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: t.muted),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop<InstallPlacement>(context),
          child: Text(l.cancel,
              style: TextStyle(color: t.muted, fontWeight: FontWeight.w800)),
        ),
        FilledButton(
          onPressed: _install,
          style: FilledButton.styleFrom(backgroundColor: t.accent),
          child: Text(l.install,
              style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  /// What is about to be installed, by name. File names, so nothing here
  /// is translated; a long pick is cut off rather than filling the dialog.
  String _subjectLine() {
    final names = [for (final path in widget.subjects) p.basename(path)];
    if (names.length <= 3) return names.join(', ');
    return '${names.take(3).join(', ')} +${names.length - 3}';
  }

  Widget _option(
    GameTheme t, {
    required String? id,
    required String label,
    String? description,
    bool mono = false,
  }) {
    final selected = _chosen == id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => setState(() => _chosen = id),
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 9, 12, 9),
          decoration: t.skin.decorate(t, SkinSurface.panel,
              radius: 11,
              state: selected ? SkinState.active : SkinState.idle,
              fill: selected ? t.tint : t.surfaceAlt),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 18,
                color: selected ? t.accent : t.muted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: t.text,
                        fontFamily: mono ? 'monospace' : null,
                      ),
                    ),
                    if (description != null && description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: t.muted),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
