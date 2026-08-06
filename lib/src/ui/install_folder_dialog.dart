import 'package:flutter/material.dart';

import '../core/app_message.dart';
import '../core/game_adapter.dart';
import '../services/sfx.dart';
import 'app_controller.dart';
import 'game_skin.dart';
import 'game_theme.dart';
import 'l10n.dart';
import 'mod_presentation.dart';
import 'widgets.dart';

/// Asks which subfolder of [into]'s mods folder something installs into,
/// and answers with a folder key - the empty string being the mods
/// folder itself. Null is the user backing out.
///
/// The sibling of `askWhereToMove`, for the question asked before the
/// files exist rather than after: The Exchange has no folder chips to
/// read an answer off, and a listing names its own game, which need not
/// be the one the sidebar is on. Hence the adapter argument, and hence
/// the folder list arriving late enough to need a spinner - it is read
/// off that game's disk whenever it isn't the library already loaded.
Future<String?> askForInstallFolder(
  BuildContext context,
  AppController controller, {
  required GameTheme theme,
  required GameAdapter into,
  required String current,
}) {
  controller.playSound(UiSound.open);
  return showDialog<String>(
    context: context,
    builder: (context) => _InstallFolderDialog(
      theme: theme,
      controller: controller,
      into: into,
      current: current,
    ),
  );
}

class _InstallFolderDialog extends StatefulWidget {
  const _InstallFolderDialog({
    required this.theme,
    required this.controller,
    required this.into,
    required this.current,
  });

  final GameTheme theme;
  final AppController controller;
  final GameAdapter into;
  final String current;

  @override
  State<_InstallFolderDialog> createState() => _InstallFolderDialogState();
}

class _InstallFolderDialogState extends State<_InstallFolderDialog> {
  /// The empty string is the mods folder itself, which is a real answer
  /// and the one every game starts on.
  late String _chosen = widget.current;

  List<String>? _folders;

  final _name = TextEditingController();
  bool _naming = false;

  /// Why the last name was turned down, drawn under the field, the way
  /// the move dialog does it: a slash in the name or a folder deeper than
  /// the game reads are typos rather than reasons to close.
  AppMessage? _refused;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final found = await widget.controller.installFolderChoices(widget.into);
    if (!mounted) return;
    setState(() => _folders = found);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final made = await widget.controller.createFolder(
        _chosen.isEmpty ? null : _chosen, _name.text,
        into: widget.into);
    if (!mounted) return;
    if (made == null) {
      setState(() => _refused = widget.controller.lastError);
      return;
    }
    setState(() {
      // The list is a snapshot of the disk taken before this existed, and
      // nothing is going to hand it over again.
      _folders = [...?_folders, if (!(_folders ?? const []).contains(made)) made]
        ..sort();
      _chosen = made;
      _naming = false;
      _refused = null;
      _name.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final l = L.of(context);
    final folders = _folders;
    return AlertDialog(
      backgroundColor: t.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        l.installFolderTitle,
        style:
            TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: t.text),
      ),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.installFolderBody(widget.into.game.name),
              style: TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w600, color: t.muted),
            ),
            const SizedBox(height: 14),
            if (folders == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 22),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: t.accent),
                  ),
                ),
              )
            else ...[
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _option(t, folder: '', l: l),
                      for (final folder in folders)
                        _option(t, folder: folder, l: l),
                    ],
                  ),
                ),
              ),
              if (folders.isEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  l.installFolderEmpty,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: t.muted),
                ),
              ],
              const SizedBox(height: 8),
              if (_naming) _nameField(t, l) else _newFolderButton(t, l),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop<String>(context),
          child: Text(l.cancel,
              style: TextStyle(color: t.muted, fontWeight: FontWeight.w800)),
        ),
        FilledButton(
          onPressed:
              folders == null ? null : () => Navigator.pop(context, _chosen),
          style: FilledButton.styleFrom(backgroundColor: t.accent),
          child: Text(l.installFolderChoose,
              style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  Widget _option(GameTheme t, {required String folder, required L l}) {
    final selected = _chosen == folder;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => setState(() => _chosen = folder),
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 9, 12, 9),
          decoration: t.skin.decorate(t, SkinSurface.panel,
              radius: 11,
              state: selected ? SkinState.active : SkinState.idle,
              fill: selected ? t.tint : t.surfaceAlt),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 18,
                color: selected ? t.accent : t.muted,
              ),
              const SizedBox(width: 10),
              Icon(
                folder.isEmpty
                    ? Icons.inventory_2_rounded
                    : Icons.folder_rounded,
                size: 15,
                color: selected ? t.accent : t.muted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  folder.isEmpty
                      ? l.libraryRootFolder
                      : folderChipLabel(folder),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: t.text),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _newFolderButton(GameTheme t, L l) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => setState(() => _naming = true),
        style: TextButton.styleFrom(
          foregroundColor: t.accent,
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
        icon: const Icon(Icons.create_new_folder_outlined, size: 17),
        label: Text(l.newFolder),
      ),
    );
  }

  Widget _nameField(GameTheme t, L l) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _name,
            autofocus: true,
            onSubmitted: (_) => _create(),
            style: TextStyle(
                fontSize: 13.5, fontWeight: FontWeight.w700, color: t.text),
            cursorColor: t.accent,
            decoration: InputDecoration(
              hintText: l.newFolderHint,
              helperText: _chosen.isEmpty
                  ? l.newFolderIn(l.libraryRootFolder)
                  : l.newFolderIn(folderChipLabel(_chosen)),
              helperStyle: TextStyle(fontSize: 11.5, color: t.muted),
              errorText: _refused == null ? null : l.errorText(_refused!),
              errorMaxLines: 3,
              errorStyle: TextStyle(fontSize: 11.5, color: t.warning),
              hintStyle: TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w600, color: t.muted),
              isDense: true,
              filled: true,
              fillColor: t.surfaceAlt,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
        ),
        const SizedBox(width: 10),
        OutlinedButton(
          onPressed: _create,
          style: accentButtonStyle(t),
          child: Text(l.create),
        ),
      ],
    );
  }
}
