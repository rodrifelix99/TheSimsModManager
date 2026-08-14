import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../core/save_edit.dart';
import '../core/save_game.dart';
import '../services/sfx.dart';
import 'app_controller.dart';
import 'game_skin.dart';
import 'game_theme.dart';
import 'l10n.dart';

/// Changes what a save says about one household: its name, its funds.
///
/// The one dialog in the app that writes into a file the user cannot
/// download again, so it says so plainly before it does: the game has to
/// be closed (all three of these games write their save back on the way
/// out and would undo this), and a copy of the file is kept either way.
/// Nothing is optimistic here - the button spins until the save has been
/// rewritten, proved and read back, because a household drawn from bytes
/// that turned out to be wrong is the one outcome worth avoiding.
Future<void> askAboutHousehold(
  BuildContext context,
  AppController controller, {
  required GameTheme theme,
  required SaveHousehold household,
}) async {
  if (!controller.canEditHousehold(household)) return;
  controller.playSound(UiSound.open);
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _HouseholdDialog(
        theme: theme, controller: controller, household: household),
  );
}

class _HouseholdDialog extends StatefulWidget {
  const _HouseholdDialog(
      {required this.theme, required this.controller, required this.household});

  final GameTheme theme;
  final AppController controller;
  final SaveHousehold household;

  @override
  State<_HouseholdDialog> createState() => _HouseholdDialogState();
}

class _HouseholdDialogState extends State<_HouseholdDialog> {
  late final TextEditingController _name =
      TextEditingController(text: widget.household.name);
  late final TextEditingController _funds =
      TextEditingController(text: '${widget.household.funds ?? 0}');

  bool _saving = false;

  Set<SaveEditField> get _fields => widget.controller.editableSaveFields;

  int get _max => widget.controller.maxHouseholdFunds;

  @override
  void dispose() {
    _name.dispose();
    _funds.dispose();
    super.dispose();
  }

  /// What the boxes are asking for, with anything unchanged left out -
  /// an edit that names a field rewrites it, so a name nobody touched
  /// has no business being written back over itself.
  HouseholdEdit get _edit {
    final name = _name.text.trim();
    final funds = int.tryParse(_funds.text.trim());
    return HouseholdEdit(
      name: _fields.contains(SaveEditField.name) &&
              name.isNotEmpty &&
              name != widget.household.name
          ? name
          : null,
      funds: _fields.contains(SaveEditField.funds) &&
              funds != null &&
              funds != widget.household.funds
          ? funds.clamp(0, _max)
          : null,
    );
  }

  /// Whether the fields hold something that could be written. A funds box
  /// that has been emptied or filled past the game's ceiling is a no,
  /// said before the button is pressed rather than after.
  bool get _valid {
    if (_saving) return false;
    if (_fields.contains(SaveEditField.name) && _name.text.trim().isEmpty) {
      return false;
    }
    final funds = int.tryParse(_funds.text.trim());
    if (_fields.contains(SaveEditField.funds) &&
        (funds == null || funds < 0 || funds > _max)) {
      return false;
    }
    return !_edit.isEmpty;
  }

  Future<void> _save() async {
    if (!_valid) return;
    setState(() => _saving = true);
    final ok =
        await widget.controller.editSaveHousehold(widget.household, _edit);
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final l = L.of(context);
    return AlertDialog(
      backgroundColor: t.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        l.householdEditTitle,
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
              l.householdEditBody(widget.household.name),
              style: TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w600, color: t.muted),
            ),
            if (_fields.contains(SaveEditField.name)) ...[
              const SizedBox(height: 14),
              _label(t, l.householdEditName),
              const SizedBox(height: 6),
              _field(t, _name, hint: widget.household.name, autofocus: true),
            ],
            if (_fields.contains(SaveEditField.funds)) ...[
              const SizedBox(height: 14),
              _label(t, l.householdEditFunds),
              const SizedBox(height: 6),
              _field(
                t,
                _funds,
                hint: '${widget.household.funds ?? 0}',
                autofocus: !_fields.contains(SaveEditField.name),
                digitsOnly: true,
              ),
              const SizedBox(height: 5),
              Text(
                l.householdEditFundsMax(_simoleons(_max)),
                style: TextStyle(
                    fontSize: 11.5, fontWeight: FontWeight.w700, color: t.muted),
              ),
            ],
            const SizedBox(height: 14),
            _notice(t, l),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: Text(l.cancel,
              style: TextStyle(fontWeight: FontWeight.w800, color: t.muted)),
        ),
        FilledButton(
          onPressed: _valid ? _save : null,
          style: FilledButton.styleFrom(
            backgroundColor: t.accent,
            disabledBackgroundColor: t.surfaceAlt,
          ),
          child: _saving
              ? const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text(l.householdEditSave,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  Widget _label(GameTheme t, String text) => Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: .5,
          color: t.muted,
        ),
      );

  /// The warning that has to be read before the button below it means
  /// anything: the game rewrites its save when it closes, so an edit made
  /// while it is running is an edit that is about to be thrown away.
  Widget _notice(GameTheme t, L l) => Container(
        padding: const EdgeInsets.fromLTRB(11, 10, 12, 10),
        decoration:
            t.skin.decorate(t, SkinSurface.notice, radius: 11, accent: t.warning),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_rounded, size: 16, color: t.warning),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                l.householdEditNotice,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: t.onWarningTint,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _field(
    GameTheme t,
    TextEditingController controller, {
    required String hint,
    bool autofocus = false,
    bool digitsOnly = false,
  }) =>
      TextField(
        controller: controller,
        autofocus: autofocus,
        enabled: !_saving,
        keyboardType: digitsOnly ? TextInputType.number : null,
        inputFormatters:
            digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
        // A household name is a name, not a paragraph; the games all
        // truncate somewhere past this and none of them says where.
        maxLength: digitsOnly ? 12 : 64,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _save(),
        style:
            TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: t.text),
        cursorColor: t.accent,
        decoration: InputDecoration(
          hintText: hint,
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
      );
}

/// Grouped thousands, the way the games write a price, and the way the
/// saves screen behind this dialog already draws every other figure.
String _simoleons(int amount) {
  String number;
  try {
    number = NumberFormat.decimalPattern().format(amount);
  } catch (_) {
    // No symbols loaded for this locale, which is what a widget test
    // that never ran main() looks like.
    number = NumberFormat.decimalPattern('en').format(amount);
  }
  return '§$number';
}
