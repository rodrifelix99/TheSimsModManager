import 'package:flutter/material.dart';

import '../core/trivia.dart';
import 'app_controller.dart';
import 'game_skin.dart';
import 'game_theme.dart';
import 'l10n.dart';
import 'widgets.dart';

/// How tall the bubble's footer controls are, arrows and labelled button
/// alike. One constant because they sit side by side: left to their own
/// intrinsic sizes the button came out two pixels short of the arrows,
/// which reads as a misalignment rather than as a style.
const _actionHeight = 27.0;

const _bubbleWidth = 348.0;
const _bubbleInset = 17.0;
const _bubbleBorderWidth = 1.5;
const _headingGap = 8.0;
const _closeSize = 20.0;

/// How much of the header row the heading may take before it ellipsizes:
/// everything except the ✕ and the gaps either side of the rule.
///
/// Spelled out rather than left to the flex system, because `Flexible`
/// heading + `Expanded` rule are two flex children of weight one and the
/// row hands each of them *half* the width - so the title was cut short
/// at "PLUMBOB KNOWS · T…" while a rule sat on 157 empty pixels it had
/// no use for. The rule keeps `Expanded` and takes whatever is left,
/// down to nothing, which is what it was always meant to do.
///
/// The border is a real 1.5px on each side eaten out of the row on top
/// of the padding - missing it the first time round was a real 3px
/// overflow, not just a rounding fudge.
const _headingMaxWidth = _bubbleWidth -
    _bubbleInset * 2 -
    _bubbleBorderWidth * 2 -
    _headingGap * 2 -
    _closeSize;

/// The plumbob in the bottom corner and the fact it has to offer.
///
/// It floats above whatever screen is up rather than living on one,
/// because the facts written about a screen ([TriviaContext]) have to be
/// able to arrive while you are on it. Nothing here reads a game: the
/// adapter hands up keys and [AppText.triviaFact] turns them into the
/// language the user is reading.
class TriviaBuddy extends StatelessWidget {
  const TriviaBuddy({super.key, required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    if (!c.showTrivia) return const SizedBox.shrink();
    return Positioned(
      right: 22,
      bottom: 20,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (c.triviaOpen)
            _Bubble(theme: theme, controller: c)
          else
            const SizedBox.shrink(),
          const SizedBox(width: 12),
          _PlumbobButton(theme: theme, controller: c),
        ],
      ),
    );
  }
}

/// The bubble. Fixed width so a long fact wraps into a shape that reads
/// rather than stretching across the library behind it.
class _Bubble extends StatelessWidget {
  const _Bubble({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    final fact = c.triviaFact;
    if (fact == null) return const SizedBox.shrink();

    // A fact written about a screen says so instead of naming the game:
    // the point of those is that they arrived because of where you are.
    final heading = switch (fact.context) {
      TriviaContext.library => l.triviaContextLibrary,
      TriviaContext.saves => l.triviaContextSaves,
      TriviaContext.packs => l.triviaContextPacks,
      null => l.triviaTitle(c.adapter.game.name),
    };

    final bubble = t.skin.decorate(t, SkinSurface.panel, radius: 16);
    return TweenAnimationBuilder<double>(
      key: ValueKey(fact.key),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) => Opacity(
        opacity: value.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 10),
          child: child,
        ),
      ),
      child: Container(
        width: _bubbleWidth,
        padding: const EdgeInsets.fromLTRB(
            _bubbleInset, 15, _bubbleInset, 13),
        // The long soft shadow rides on top of whatever relief the skin
        // gives a panel: the bubble floats over the window rather than
        // sitting on it, and that is what this shadow says.
        decoration: bubble.copyWith(boxShadow: [
          ...?bubble.boxShadow,
          BoxShadow(
            color: t.shadow,
            blurRadius: 48,
            spreadRadius: -22,
            offset: const Offset(0, 24),
          ),
        ]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: _headingMaxWidth),
                  child: Text(
                    heading.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .9,
                      color: t.accent,
                    ),
                  ),
                ),
                const SizedBox(width: _headingGap),
                Expanded(child: Container(height: 1, color: t.border)),
                const SizedBox(width: _headingGap),
                _IconAction(
                  theme: t,
                  tooltip: l.triviaClose,
                  icon: Icons.close_rounded,
                  size: _closeSize,
                  onPressed: c.closeTrivia,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // The chip and the counter share a line: the counter is the
            // one part of the footer that grows with the language, and
            // down there it was crowding three controls off the edge.
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                    color: t.tint,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    l.triviaCategory(fact.category).toUpperCase(),
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .7,
                      color: t.accent,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Flexible(
                  child: Text(
                    l.triviaCounter(c.triviaNumber, c.triviaTotal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: t.muted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              l.triviaFact(fact.key),
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                fontWeight: FontWeight.w700,
                color: t.text,
              ),
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                _IconAction(
                  theme: t,
                  tooltip: l.triviaPrevious,
                  icon: Icons.chevron_left_rounded,
                  onPressed: () => c.stepTrivia(-1),
                ),
                const SizedBox(width: 5),
                _IconAction(
                  theme: t,
                  tooltip: l.triviaNext,
                  icon: Icons.chevron_right_rounded,
                  onPressed: () => c.stepTrivia(1),
                ),
                const SizedBox(width: 5),
                // Flexible so the one labelled button in here can give
                // ground: twelve languages write "Another one" at twelve
                // different widths, and the bubble is a fixed 348.
                Flexible(
                  child: SizedBox(
                    height: _actionHeight,
                    child: OutlinedButton(
                      // Horizontal padding only: the height is the
                      // SizedBox's, and vertical padding on top of it
                      // would only fight for room with the label.
                      style: accentButtonStyle(t).copyWith(
                        padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(horizontal: 13)),
                        minimumSize: const WidgetStatePropertyAll(Size.zero),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: c.shuffleTrivia,
                      child: Text(
                        l.triviaAnother,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            // The way out that isn't this bubble. The ✕ above only puts
            // one fact away; this is where "stop doing that" lives, and
            // it goes to the switch rather than being one, so turning the
            // buddy off is never a door that locks behind you.
            HoverBuilder(
              cursor: SystemMouseCursors.click,
              builder: (context, hovered) => GestureDetector(
                onTap: () {
                  c.closeTrivia();
                  c.openSettings();
                },
                child: Text(
                  l.triviaToSettings,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: hovered ? t.accent : t.muted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The plumbob itself: the game's own art, bobbing, with the badge that
/// says a fact is waiting.
class _PlumbobButton extends StatefulWidget {
  const _PlumbobButton({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  State<_PlumbobButton> createState() => _PlumbobButtonState();
}

class _PlumbobButtonState extends State<_PlumbobButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final c = widget.controller;
    return Tooltip(
      message: L.of(context).triviaOpen,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: c.toggleTrivia,
          child: SizedBox(
            width: 52,
            height: 58,
            child: AnimatedBuilder(
              animation: _float,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, -6 * Curves.easeInOut.transform(_float.value)),
                child: child,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Center(child: BrandMark(gameId: c.adapter.game.id, size: 46)),
                  if (c.triviaBadge)
                    Positioned(
                      right: 2,
                      top: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: t.warning,
                          shape: BoxShape.circle,
                          border: Border.all(color: t.surface, width: 2),
                        ),
                        child: const Text(
                          '!',
                          style: TextStyle(
                            fontSize: 9,
                            height: 1,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A small square button: the bubble's ✕ and its two arrows.
class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.theme,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.size = _actionHeight,
  });

  final GameTheme theme;
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Tooltip(
      message: tooltip,
      child: HoverBuilder(
        cursor: SystemMouseCursors.click,
        builder: (context, hovered) => GestureDetector(
          onTap: onPressed,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: t.skin.decorate(t, SkinSurface.button,
                radius: 9,
                state: skinState(hovered: hovered),
                fill: hovered ? t.tint : t.surface,
                outline: hovered ? t.accent : t.border),
            child: Icon(
              icon,
              size: size * .66,
              color: t.skin.ink(t, SkinSurface.button,
                  state: skinState(hovered: hovered),
                  secondary: !hovered,
                  otherwise: hovered ? t.accent : t.muted),
            ),
          ),
        ),
      ),
    );
  }
}
