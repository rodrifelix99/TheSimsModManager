import 'package:flutter/material.dart';

import '../core/app_message.dart';
import '../core/mod.dart';
import '../services/sfx.dart';
import 'app_controller.dart';
import 'game_theme.dart';
import 'l10n.dart';
import 'mod_presentation.dart';
import 'widgets.dart';

/// Asks which folder [mods] should move into, and moves them.
///
/// The dialog is the keyboard-and-everything path to a move: dragging
/// mods onto a folder is faster once you know it works, but it only
/// exists where a folder is drawn, and in the grid there is nowhere to
/// drop the root.
Future<void> askWhereToMove(
  BuildContext context,
  AppController controller, {
  required GameTheme theme,
  required List<Mod> mods,
  required String method,
}) async {
  if (mods.isEmpty || !controller.canMoveMods) return;
  controller.playSound(UiSound.open);
  final folder = await showDialog<_Choice>(
    context: context,
    builder: (context) => _MoveDialog(
      theme: theme,
      controller: controller,
      count: mods.length,
    ),
  );
  if (folder == null) return;
  await controller.moveMods(mods, folder.folder, method: method);
}

/// A chosen destination. A class rather than the bare `String?` a folder
/// key is, because null is itself an answer here - the mods folder - and
/// `showDialog` returning null already means the user backed out.
class _Choice {
  const _Choice(this.folder);

  final String? folder;
}

class _MoveDialog extends StatefulWidget {
  const _MoveDialog(
      {required this.theme, required this.controller, required this.count});

  final GameTheme theme;
  final AppController controller;
  final int count;

  @override
  State<_MoveDialog> createState() => _MoveDialogState();
}

class _MoveDialogState extends State<_MoveDialog> {
  /// Null is the mods folder itself, which is a real answer and the one
  /// this opens on.
  String? _chosen;

  /// Set while the "New folder" row is a text field rather than a button.
  final _name = TextEditingController();
  bool _naming = false;

  /// Why the last name was turned down, drawn under the field. A slash in
  /// the name and a folder deeper than the game reads are both ordinary
  /// typos, so they are answered here rather than by closing.
  AppMessage? _refused;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// Makes the typed folder inside whichever one is currently chosen, and
  /// selects it - so the usual flow is type a name, hit Create, hit Move.
  Future<void> _create() async {
    final made = await widget.controller.createFolder(_chosen, _name.text);
    if (!mounted) return;
    if (made == null) {
      // Stay open. Closing would take the destination the user already
      // picked down with it, and abandon the move they came here for -
      // a mistyped folder name is not a reason to lose either.
      setState(() => _refused = widget.controller.lastError);
      return;
    }
    setState(() {
      _chosen = made;
      _naming = false;
      _refused = null;
      _name.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final c = widget.controller;
    final l = L.of(context);
    return AlertDialog(
      backgroundColor: t.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        l.moveTitle(widget.count),
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
              l.moveBody,
              style: TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w600, color: t.muted),
            ),
            const SizedBox(height: 14),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final folder in c.moveTargets)
                      _option(t, folder: folder, l: l),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_naming) _nameField(t, l) else _newFolderButton(t, l),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop<_Choice>(context),
          child: Text(l.cancel,
              style: TextStyle(color: t.muted, fontWeight: FontWeight.w800)),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _Choice(_chosen)),
          style: FilledButton.styleFrom(backgroundColor: t.accent),
          child: Text(l.move,
              style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  Widget _option(GameTheme t, {required String? folder, required L l}) {
    final selected = _chosen == folder;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => setState(() => _chosen = folder),
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 9, 12, 9),
          decoration: BoxDecoration(
            color: selected ? t.tint : t.surfaceAlt,
            border: Border.all(
              color: selected ? t.accent : t.border,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(11),
          ),
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
                folder == null
                    ? Icons.inventory_2_rounded
                    : Icons.folder_rounded,
                size: 15,
                color: selected ? t.accent : t.muted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  folder == null ? l.libraryRootFolder : folderChipLabel(folder),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: t.text),
                ),
              ),
              if (folder != null)
                Text(
                  '${widget.controller.folderCount(folder)}',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: t.muted),
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
              helperText: _chosen == null
                  ? l.newFolderIn(l.libraryRootFolder)
                  : l.newFolderIn(folderChipLabel(_chosen!)),
              helperStyle: TextStyle(fontSize: 11.5, color: t.muted),
              errorText:
                  _refused == null ? null : l.errorText(_refused!),
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

/// The standalone "New folder": the same question without a move behind
/// it, for setting a shelf up before there is anything to put on it. The
/// new folder lands inside whichever folder chip is selected, the way an
/// install does.
Future<void> askForNewFolder(
  BuildContext context,
  AppController controller, {
  required GameTheme theme,
}) async {
  if (!controller.canMoveMods) return;
  // The same rule an install follows: the one selected chip, and the
  // mods folder whenever the selection isn't a single ordinary folder.
  final parent = controller.installFolder;
  controller.playSound(UiSound.open);
  final name = await showDialog<String>(
    context: context,
    builder: (context) =>
        _NewFolderDialog(theme: theme, controller: controller, parent: parent),
  );
  if (name == null) return;
  await controller.createFolder(parent, name);
}

class _NewFolderDialog extends StatefulWidget {
  const _NewFolderDialog(
      {required this.theme, required this.controller, required this.parent});

  final GameTheme theme;
  final AppController controller;
  final String? parent;

  @override
  State<_NewFolderDialog> createState() => _NewFolderDialogState();
}

class _NewFolderDialogState extends State<_NewFolderDialog> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _name.text);

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final l = L.of(context);
    final parent = widget.parent;
    return AlertDialog(
      backgroundColor: t.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        l.newFolder,
        style:
            TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: t.text),
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.newFolderIn(
                  parent == null ? l.libraryRootFolder : folderChipLabel(parent)),
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: t.muted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              autofocus: true,
              onSubmitted: (_) => _submit(),
              style: TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w700, color: t.text),
              cursorColor: t.accent,
              decoration: InputDecoration(
                hintText: l.newFolderHint,
                hintStyle: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: t.muted),
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
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: t.accent),
          child: Text(l.create,
              style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}
