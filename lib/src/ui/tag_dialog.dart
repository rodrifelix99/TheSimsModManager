import 'package:flutter/material.dart';

import '../core/mod.dart';
import '../core/mod_tags.dart';
import '../services/sfx.dart';
import 'app_controller.dart';
import 'game_theme.dart';
import 'l10n.dart';

/// Puts labels on [mods] and takes them off again.
///
/// One dialog for both, and for one mod or a hundred: a tag is a thing
/// you toggle rather than a place you send something, so a row that is
/// already ticked is how a tag comes off. It stays open while that
/// happens - tagging is usually several at once, and a dialog that
/// closed on the first tick would have to be reopened for the second.
Future<void> askAboutTags(
  BuildContext context,
  AppController controller, {
  required GameTheme theme,
  required List<Mod> mods,
}) async {
  if (mods.isEmpty) return;
  controller.playSound(UiSound.open);
  await showDialog<void>(
    context: context,
    builder: (context) =>
        _TagDialog(theme: theme, controller: controller, mods: mods),
  );
}

class _TagDialog extends StatefulWidget {
  const _TagDialog(
      {required this.theme, required this.controller, required this.mods});

  final GameTheme theme;
  final AppController controller;
  final List<Mod> mods;

  @override
  State<_TagDialog> createState() => _TagDialogState();
}

class _TagDialogState extends State<_TagDialog> {
  final _name = TextEditingController();

  /// Lit while the field holds something that would be turned down, so
  /// the Add button says no before it is pressed rather than after.
  bool get _canAdd => sanitizeTag(_name.text) != null;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// The mods being tagged, freshly read: the controller rebuilds the
  /// library on every change, and the snapshots this dialog opened with
  /// are stale the moment the first tag lands.
  List<Mod> get _mods {
    final byPath = {for (final mod in widget.controller.mods) mod.path: mod};
    return [
      for (final mod in widget.mods)
        if (byPath[mod.path] case final fresh?) fresh,
    ];
  }

  /// How many of the mods on the table carry [tag].
  int _carrying(String tag) {
    final key = tagKey(tag);
    var count = 0;
    for (final mod in _mods) {
      if (widget.controller
          .tagsOf(mod)
          .any((held) => tagKey(held) == key)) {
        count++;
      }
    }
    return count;
  }

  Future<void> _add() async {
    final tag = _name.text;
    if (sanitizeTag(tag) == null) return;
    await widget.controller.addTag(_mods, tag);
    if (!mounted) return;
    setState(_name.clear);
  }

  Future<void> _toggle(String tag) async {
    // Everything already carrying it is the one state where a tap means
    // "off"; a partly-tagged selection fills in rather than empties.
    if (_carrying(tag) == _mods.length) {
      await widget.controller.removeTag(_mods, tag);
    } else {
      await widget.controller.addTag(_mods, tag);
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final c = widget.controller;
    final l = L.of(context);
    final tags = c.tagCounts.keys.toList();
    return AlertDialog(
      backgroundColor: t.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        l.tagTitle(widget.mods.length),
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
              l.tagBody,
              style: TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w600, color: t.muted),
            ),
            const SizedBox(height: 14),
            _field(t, l),
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [for (final tag in tags) _option(t, tag)],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          style: FilledButton.styleFrom(backgroundColor: t.accent),
          child:
              Text(l.tagDone, style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  Widget _field(GameTheme t, L l) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _name,
            autofocus: true,
            maxLength: maxTagLength,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _add(),
            style: TextStyle(
                fontSize: 13.5, fontWeight: FontWeight.w700, color: t.text),
            cursorColor: t.accent,
            decoration: InputDecoration(
              hintText: l.tagHint,
              counterText: '',
              hintStyle: TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w600, color: t.muted),
              isDense: true,
              filled: true,
              fillColor: t.surfaceAlt,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: t.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: t.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: t.accent, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _canAdd ? _add : null,
          style: FilledButton.styleFrom(
            backgroundColor: t.accent,
            disabledBackgroundColor: t.surfaceAlt,
          ),
          child: Text(l.tagAdd,
              style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  Widget _option(GameTheme t, String tag) {
    final carrying = _carrying(tag);
    final all = carrying == _mods.length && carrying > 0;
    final some = carrying > 0 && !all;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => _toggle(tag),
        borderRadius: BorderRadius.circular(11),
        child: Container(
          padding: const EdgeInsets.fromLTRB(10, 9, 12, 9),
          decoration: BoxDecoration(
            color: all || some ? t.tint : t.surfaceAlt,
            border: Border.all(
              color: all || some ? t.accent : t.border,
              width: all || some ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            children: [
              Icon(
                all
                    ? Icons.check_box_rounded
                    : some
                        // Some of them, which is a state a selection can
                        // be in and a single mod never is.
                        ? Icons.indeterminate_check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                size: 18,
                color: all || some ? t.accent : t.muted,
              ),
              const SizedBox(width: 10),
              Icon(Icons.sell_rounded,
                  size: 15, color: all || some ? t.accent : t.muted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tag,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: t.text),
                ),
              ),
              Text(
                '${widget.controller.tagCount(tag)}',
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
}
