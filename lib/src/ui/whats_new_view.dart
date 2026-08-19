import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart' show kWindowCaptionHeight;

import '../core/whats_new.dart';
import 'app_controller.dart';
import 'film_player.dart';
import 'game_skin.dart';
import 'game_theme.dart';
import 'l10n.dart';
import 'widgets.dart';

/// What the update brought, once, on the launch after it landed.
///
/// The walkthrough's sibling and deliberately its opposite in shape: it
/// asks nothing, has one way out, and is over in a glance. The newest
/// release gets the hero and the words; anything missed by someone who
/// skipped a release or two is listed under it, so updating late never
/// silently costs you the news.
class WhatsNewOverlay extends StatefulWidget {
  const WhatsNewOverlay(
      {super.key, required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  State<WhatsNewOverlay> createState() => _WhatsNewOverlayState();
}

/// Whether a repeating animation may actually repeat. Same bargain the
/// walkthrough makes: a controller left running forever is a frame
/// scheduled forever, which is what makes `pumpAndSettle` time out.
bool get _mayLoop => !Platform.environment.containsKey('FLUTTER_TEST');

class _WhatsNewOverlayState extends State<WhatsNewOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 520));

  late final AnimationController _drift =
      AnimationController(vsync: this, duration: const Duration(seconds: 48));

  @override
  void initState() {
    super.initState();
    if (_mayLoop) _drift.repeat();
    _intro.forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final c = widget.controller;
    return Stack(
      children: [
        // A scrim rather than the walkthrough's opaque page: this one is
        // news about the app, and the app it is about should still be
        // there behind it.
        Positioned.fill(
          child: FadeTransition(
            opacity: _intro,
            child: GestureDetector(
              onTap: c.dismissWhatsNew,
              child: ColoredBox(color: t.shadow.withValues(alpha: .58)),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: FadeTransition(
              opacity: _intro,
              child: DriftBackdrop(theme: t, animation: _drift),
            ),
          ),
        ),
        FadeTransition(
          opacity: CurvedAnimation(parent: _intro, curve: Curves.easeOut),
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, .04),
              end: Offset.zero,
            ).animate(
                CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic)),
            child: _card(t, c),
          ),
        ),
      ],
    );
  }

  Widget _card(GameTheme t, AppController c) {
    final entries = c.whatsNew;
    if (entries.isEmpty) return const SizedBox.shrink();
    final headline = entries.first;
    final panel =
        t.skin.decorate(t, SkinSurface.panel, radius: 22, fill: t.surface);
    // What the skin made of that 22: it is free to scale a named radius,
    // and SimCity 3000 takes it to a quarter. The clip below and the lift
    // under the card both have to follow it, or the rim is drawn round a
    // corner the card was cut somewhere else.
    final radius = panel.borderRadius?.resolve(null) ?? BorderRadius.circular(22);
    return LayoutBuilder(
      builder: (context, box) => Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, kWindowCaptionHeight, 24, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 560,
              maxHeight:
                  math.max(320, box.maxHeight - kWindowCaptionHeight - 48),
            ),
            // Drawn here rather than asked of the skin, for the reason
            // the walkthrough's card gives: a panel's `elevated` shadow
            // is written for a mod card rising under the pointer, and at
            // this size the same numbers read as a grey slab.
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: radius,
                boxShadow: [
                  BoxShadow(
                    color: t.shadow.withValues(alpha: .16),
                    blurRadius: 54,
                    spreadRadius: -10,
                    offset: const Offset(0, 22),
                  ),
                  BoxShadow(
                    color: t.shadow.withValues(alpha: .08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              // The panel's own outline, drawn over the content instead
              // of behind it. A [Container] paints its decoration behind
              // its child, and the hero is flush to the top of the card,
              // so the rim along that edge - and the two corners with it
              // - was being painted over: the border stopped following
              // the radius. Taken off the decoration the skin returned
              // rather than invented here, so a skin that draws no
              // border still draws none.
              child: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  border: panel.border,
                  borderRadius: panel.borderRadius,
                ),
                child: ClipRRect(
                  borderRadius: radius,
                  child: Container(
                    decoration: panel,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Hero(
                          theme: t,
                          entry: headline,
                          sound: c.settings.soundEffects,
                        ),
                        Flexible(
                          child: SingleChildScrollView(
                            // No gap of its own above the eyebrow: the
                            // hero's own dissolved tail is the gap, and
                            // padding on top of it would push the text
                            // clear of the picture the fade exists to
                            // join it to.
                            padding: const EdgeInsets.fromLTRB(30, 0, 30, 4),
                            child: _Body(theme: t, controller: c),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 18, 30, 22),
                          child: _Footer(theme: t, controller: c),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Taller than the picture needs to be seen, so the fade has somewhere
/// to happen. The body draws no gap of its own above the eyebrow, so
/// the extra height is spent on the dissolve rather than on empty card.
const _heroHeight = 232.0;

/// The picture across the top of the card, dissolved into it - and,
/// where a release brought one, the film that plays across it first.
///
/// Three layers, and each is the way out of the one above it. The
/// gradient is not a placeholder: a release can ship without artwork, and a hero
/// that fails to decode has to leave something behind rather than a
/// hole the height of a picture. The film sits over the picture rather
/// than in place of it and fades out on its last frame, so what is
/// underneath is what a release with no film shows, what a machine that
/// cannot decode one shows, and what the card settles on either way.
/// Nothing here is a cross-fade: the picture never moves, and only the
/// film's own opacity does.
///
/// Both are faded out at the foot and run to the card's edges on the
/// left and right, where the [ClipRRect] and the rim drawn over it are
/// what finish the picture. The sides used to dissolve as well, on the
/// theory that arbitrary artwork should not butt up against the skin's
/// rim; with a photograph in there it read as a vignette laid over the
/// picture rather than as the picture ending, so it went. The fade that
/// remains is a mask on the picture rather than a wash of
/// [GameTheme.surface] laid over it: three of the four skins fill a
/// panel with a gradient, so a flat wash would be the wrong colour at
/// one end of it. What shows through is the card's own fill, whatever
/// that is made of.
///
/// The height is what makes that fade work, and it is why the artwork is
/// wider than it looks. The picture is drawn to *cover* a box taller than
/// the fade needs, so the bottom half of it is being dissolved rather
/// than the last few pixels: a short box gives the gradient nowhere to
/// go and the picture stops somewhere visible whatever is laid over it.
/// A hero should therefore be drawn at 4:1.5 or wider and expect its
/// lower third to be given away.
class _Hero extends StatefulWidget {
  const _Hero({
    required this.theme,
    required this.entry,
    required this.sound,
  });

  final GameTheme theme;
  final WhatsNewEntry entry;

  /// Whether the film's sound plays, which is the `soundEffects` pref.
  /// Read once here rather than watched: the switch is in Settings, and
  /// Settings is behind the card.
  final bool sound;

  @override
  State<_Hero> createState() => _HeroState();
}

/// Long enough to read as the film giving way to the picture rather
/// than as a cut. The two are different shots - a film ends where its
/// own editor ended it, not on the frame somebody chose for the card -
/// so this is a dissolve between pictures and wants the time.
const _heroFade = Duration(milliseconds: 800);

class _HeroState extends State<_Hero> {
  /// Whether the film has reached its end and is on its way out.
  bool _settled = false;

  /// Whether it has finished going, which is when the last frame it was
  /// holding can be let go with it.
  bool _gone = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final image = widget.entry.image;
    final film = widget.entry.film;
    return SizedBox(
      height: _heroHeight,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          // Seven stops rather than three, easing off rather than
          // ramping: a straight ramp has a corner where it leaves full
          // opacity, and that corner is itself a visible line across
          // the picture - which reads as the edge the fade was there
          // to hide.
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
            Color(0xE0FFFFFF),
            Color(0x9EFFFFFF),
            Color(0x52FFFFFF),
            Color(0x1FFFFFFF),
            Color(0x00FFFFFF),
          ],
          stops: [0, .24, .44, .62, .78, .90, 1],
        ).createShader(bounds),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [t.accent.withValues(alpha: .22), t.tint],
                ),
              ),
            ),
            if (image != null)
              Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) =>
                    const SizedBox.shrink(),
              ),
            if (film != null && !_gone)
              AnimatedOpacity(
                opacity: _settled ? 0 : 1,
                duration: _heroFade,
                curve: Curves.easeInOut,
                // The last frame is held for the length of the fade and
                // dropped at the end of it, so the card is not left
                // sitting on a picture nobody can see any more.
                onEnd: () {
                  if (_settled && mounted) setState(() => _gone = true);
                },
                child: FilmPlayer(
                  asset: film,
                  audio: widget.entry.audio,
                  sound: widget.sound,
                  holdLast: true,
                  onSettled: () {
                    if (mounted) setState(() => _settled = true);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    final entries = c.whatsNew;
    final headline = entries.first;
    final older = entries.skip(1).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.whatsNewEyebrow(headline.version), style: eyebrowStyle(t)),
        const SizedBox(height: 8),
        Text(
          l.whatsNewTitle(headline.titleKey),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            height: 1.2,
            color: t.text,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l.whatsNewBody(headline.bodyKey),
          style: TextStyle(fontSize: 14, height: 1.5, color: t.muted),
        ),
        // Whatever was missed by updating late, a line each. No pictures:
        // a release nobody stopped on does not get a hero, and a stack of
        // them would make the card a slideshow.
        if (older.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(l.whatsNewAlsoSince, style: eyebrowStyle(t)),
          const SizedBox(height: 10),
          for (final entry in older)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Icon(Icons.auto_awesome_rounded,
                        size: 14, color: t.accent),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.whatsNewTitle(entry.titleKey),
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: t.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l.whatsNewBody(entry.bodyKey),
                          style: TextStyle(
                              fontSize: 12.5, height: 1.4, color: t.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    final headline = c.whatsNew.first;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (headline.url != null) ...[
          CardButton(
            theme: t,
            label: l.learnMore,
            onTap: () => c.openWhatsNewUrl(headline),
          ),
          const SizedBox(width: 10),
        ],
        CardButton(
          theme: t,
          label: l.whatsNewDismiss,
          primary: true,
          onTap: c.dismissWhatsNew,
        ),
      ],
    );
  }
}
