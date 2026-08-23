import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show KeyDownEvent, KeyRepeatEvent, LogicalKeyboardKey;
import 'package:window_manager/window_manager.dart' show kWindowCaptionHeight;

import 'l10n.dart';
import 'widgets.dart';

/// Opens a listing's screenshots over the whole window, starting on
/// [index].
///
/// The gallery frame on a listing's page is 380px wide and the catalog's
/// strip is 190px tall, because both sit beside the text that is the
/// reason someone opened the page. A screenshot is the one thing there
/// nobody can read at that size - it is a picture of an interface, with
/// whatever the creator is pointing at somewhere inside it - so this is
/// where it gets the window (issue #24).
///
/// [shots] are providers rather than URLs or bytes, so one viewer can
/// show both kinds of listing, and so the picture the frame already
/// fetched is the picture this opens: the same provider is the same
/// entry in Flutter's image cache.
Future<void> showShotViewer(
  BuildContext context, {
  required List<ImageProvider> shots,
  required String seed,
  int index = 0,
}) {
  if (shots.isEmpty) return Future<void>.value();
  return showGeneralDialog<void>(
    context: context,
    // Dismissible, which is what answers a click on the backdrop and the
    // Escape key without either being wired up below.
    barrierDismissible: true,
    barrierLabel: L.of(context).shotClose,
    barrierColor: Colors.black.withValues(alpha: .86),
    transitionDuration: const Duration(milliseconds: 160),
    transitionBuilder: (context, animation, secondary, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
    pageBuilder: (context, _, __) => _ShotViewer(
      shots: shots,
      seed: seed,
      index: index.clamp(0, shots.length - 1),
    ),
  );
}

/// The screenshot, the two arrows and the way out.
///
/// Everything here is drawn in plain black and white rather than in the
/// theme's colours, which is one of the few places a colour literal is
/// right: what these controls sit on is somebody's screenshot, not a
/// surface the palette knows anything about. Same bargain as the
/// file-name chip over a mod's artwork.
class _ShotViewer extends StatefulWidget {
  const _ShotViewer({
    required this.shots,
    required this.seed,
    required this.index,
  });

  final List<ImageProvider> shots;
  final String seed;
  final int index;

  @override
  State<_ShotViewer> createState() => _ShotViewerState();
}

class _ShotViewerState extends State<_ShotViewer> {
  late int _index = widget.index;

  /// Held rather than left to [InteractiveViewer]'s own, because
  /// stepping to the next screenshot has to put the magnifying glass
  /// down: a picture that arrives already zoomed into the corner the
  /// last one was being read in reads as a broken image.
  final _zoom = TransformationController();

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  void _step(int by) {
    final count = widget.shots.length;
    if (count < 2) return;
    setState(() {
      _index = (_index + by) % count;
      _zoom.value = Matrix4.identity();
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        _step(-1);
      case LogicalKeyboardKey.arrowRight:
        _step(1);
      default:
        return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    final many = widget.shots.length > 1;
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: Stack(
        children: [
          // Inset from the top by the caption strip, so the picture never
          // sits under the window's own buttons, and along the sides by
          // the room the arrows take.
          Padding(
            padding: EdgeInsets.fromLTRB(
                many ? 76 : 28, kWindowCaptionHeight + 20, many ? 76 : 28, 68),
            child: InteractiveViewer(
              transformationController: _zoom,
              maxScale: 6,
              child: Image(
                key: ValueKey(_index),
                image: widget.shots[_index],
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                // The frame that was clicked decoded its copy at the
                // width it was drawn at, so this is often a fresh fetch
                // of the full-size file - which is the point of opening
                // it, and worth saying is happening.
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.6,
                            color: Colors.white,
                          ),
                        ),
                      ),
                errorBuilder: (_, __, ___) => Center(
                  child: SizedBox(
                    width: 320,
                    height: 200,
                    child: StripeThumb(
                      seed: widget.seed,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: kWindowCaptionHeight + 12,
            left: 20,
            child: _RoundButton(
              key: const ValueKey('shot-viewer-close'),
              icon: Icons.close_rounded,
              label: l.shotClose,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          if (many) ...[
            Positioned(
              left: 14,
              top: 0,
              bottom: 0,
              child: Center(
                child: _RoundButton(
                  key: const ValueKey('shot-viewer-previous'),
                  icon: Icons.chevron_left_rounded,
                  label: l.shotPrevious,
                  onPressed: () => _step(-1),
                ),
              ),
            ),
            Positioned(
              right: 14,
              top: 0,
              bottom: 0,
              child: Center(
                child: _RoundButton(
                  key: const ValueKey('shot-viewer-next'),
                  icon: Icons.chevron_right_rounded,
                  label: l.shotNext,
                  onPressed: () => _step(1),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: .5),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  // Digits and a slash, which every language the app
                  // ships in reads the same way round.
                  child: Text(
                    '${_index + 1} / ${widget.shots.length}',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withValues(alpha: .92),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// One of the viewer's controls: a dark disc with a white glyph on it,
/// tooltipped because it carries no label of its own.
class _RoundButton extends StatelessWidget {
  const _RoundButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: HoverBuilder(
        cursor: SystemMouseCursors.click,
        builder: (context, hovered) => Semantics(
          button: true,
          label: label,
          child: GestureDetector(
            onTap: onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: hovered ? .74 : .48),
                border: Border.all(
                  color: Colors.white.withValues(alpha: hovered ? .55 : .22),
                ),
              ),
              child: Icon(icon, size: 22, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
