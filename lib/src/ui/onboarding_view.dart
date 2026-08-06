import 'dart:io' show Platform;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart' show kWindowCaptionHeight;

import '../core/game.dart';
import '../core/game_adapter.dart';
import '../services/sfx.dart';
import 'app_controller.dart';
import 'game_skin.dart';
import 'game_theme.dart';
import 'intro_video.dart';
import 'l10n.dart';
import 'widgets.dart';

/// The first-run walkthrough, covering the whole window.
///
/// It sits over the shell rather than replacing it: the library loads
/// behind it from the first frame, so the questions here (which game to
/// open on, how things should look) never stand between the user and the
/// app doing what it was started to do. Everything it asks is a setting
/// that already exists, worded the same way Settings words it - this is
/// where they are met, not a second place they live.
class OnboardingOverlay extends StatefulWidget {
  const OnboardingOverlay(
      {super.key, required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  State<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

bool get _underTest => Platform.environment.containsKey('FLUTTER_TEST');

/// Whether a repeating animation may actually repeat. A controller left
/// running forever is a frame scheduled forever, which is what makes
/// `pumpAndSettle` time out; the decorative ones here hold their first
/// frame under `flutter test` instead, so what a test measures is still
/// the real layout.
bool get _mayLoop => !_underTest;

/// Whether the film that opens the walkthrough plays. Ten seconds of it
/// stand in front of the first card, and every widget test in the suite
/// pumps the app and looks for that card: under `flutter test` the
/// walkthrough opens on it directly, and the backdrop is the flat one
/// the card was drawn against before any of this.
bool get _playsIntro => !_underTest;

/// How much of the skin's own backdrop is laid over the frame the film
/// stopped on. Enough that the card and the drifting plumbobs read as
/// themselves, little enough that the sky is still behind them.
const _filmScrim = .72;

class _OnboardingOverlayState extends State<OnboardingOverlay>
    with TickerProviderStateMixin {
  /// The card arriving: a fade and a small rise, once.
  late final AnimationController _intro = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 520));

  /// The walkthrough settling onto the film's last frame: the scrim and
  /// the plumbobs coming up over the picture it stopped on. Slower than
  /// the card, so the sky dims rather than snaps.
  late final AnimationController _settle = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));

  /// The plumbobs drifting up the backdrop.
  late final AnimationController _drift =
      AnimationController(vsync: this, duration: const Duration(seconds: 48));

  /// Whether the film is done with. Until it is there is no card, no
  /// scrim and no plumbob on screen - the window is the film, and a card
  /// held at zero opacity would still be catching the tap that skips it.
  bool _filmDone = !_playsIntro;

  /// The page the card was showing last build, so a step change knows
  /// which way it is travelling and slides that way.
  int _lastAt = 0;

  @override
  void initState() {
    super.initState();
    if (_mayLoop) _drift.repeat();
    if (_filmDone) {
      _intro.forward();
      _settle.value = 1;
    }
    _lastAt = widget.controller.onboardingAt;
  }

  @override
  void dispose() {
    _intro.dispose();
    _settle.dispose();
    _drift.dispose();
    super.dispose();
  }

  void _filmSettled() {
    if (_filmDone || !mounted) return;
    setState(() => _filmDone = true);
    _settle.forward();
    _intro.forward();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final c = widget.controller;
    final at = c.onboardingAt;
    final forward = at >= _lastAt;
    _lastAt = at;
    return Stack(
      children: [
        // The film, and then the frame it stopped on for the rest of the
        // walkthrough. Where there is none it is the flat backdrop below
        // that fills the window, at full strength.
        if (_playsIntro)
          Positioned.fill(
            child: IntroVideo(
              theme: t,
              sound: c.settings.soundEffects,
              onSettled: _filmSettled,
            ),
          ),
        // Opaque without a film behind it, so the library is out of sight
        // rather than half-visible under a scrim: this is a page of its
        // own. Over the film it is the scrim, laid on as the card lands.
        Positioned.fill(
          child: IgnorePointer(
            child: FadeTransition(
              opacity: _settle.drive(Tween(
                  begin: 0.0, end: _playsIntro ? _filmScrim : 1.0)),
              child: DecoratedBox(decoration: t.skin.backdrop(t)),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: FadeTransition(
              opacity: _settle,
              child: _DriftBackdrop(theme: t, animation: _drift),
            ),
          ),
        ),
        if (_filmDone)
          Positioned.fill(
            child: FadeTransition(
              opacity: CurvedAnimation(parent: _intro, curve: Curves.easeOut),
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, .035),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                    parent: _intro, curve: Curves.easeOutCubic)),
                child: _card(context, t, c, forward),
              ),
            ),
          ),
      ],
    );
  }

  Widget _card(
      BuildContext context, GameTheme t, AppController c, bool forward) {
    return LayoutBuilder(
      builder: (context, box) => Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, kWindowCaptionHeight, 24, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 640,
              // Whatever is left of the window once the caption strip and
              // the padding above are out of it: the card scrolls inside
              // rather than growing past the edges at kMinWindowSize.
              maxHeight:
                  math.max(320, box.maxHeight - kWindowCaptionHeight - 48),
            ),
            // The lift is drawn here rather than asked of the skin: a
            // panel's `elevated` shadow is written for a mod card that
            // rose under the pointer, and at the size of this card the
            // same numbers read as a grey slab sitting behind it. Its
            // own shadow also leaves the skins that build a bevel out of
            // `boxShadow` alone to keep theirs.
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
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
              child: Container(
                padding: const EdgeInsets.fromLTRB(32, 28, 32, 22),
                decoration: t.skin.decorate(t, SkinSurface.panel,
                    radius: 22, fill: t.surface),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 260),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween(
                                  begin: Offset(forward ? .06 : -.06, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            ),
                            child: KeyedSubtree(
                              key: ValueKey(c.onboardingStep),
                              child: _StepBody(theme: t, controller: c),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _Footer(theme: t, controller: c),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The dots and the buttons under the card. The dots sit on a row of
/// their own rather than beside the buttons: three translated labels and
/// a row of dots on one line is where the narrow window runs out.
class _Footer extends StatelessWidget {
  const _Footer({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    final steps = c.onboardingSteps;
    final at = c.onboardingAt;
    final last = at == steps.length - 1;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < steps.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == at ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: i == at
                      ? t.accent
                      : (i < at ? t.accent.withValues(alpha: .4) : t.border),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Skip flush left, the two actions flush right, in that order.
        // The left side is [Expanded] rather than a [Flexible] and a
        // [Spacer]: two flex children split the leftover space between
        // them, and the half the skip button didn't use was left sitting
        // to the right of the buttons - which is what stopped them
        // reaching the edge of the card.
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: last
                    ? const SizedBox.shrink()
                    : TextButton(
                        onPressed: () => c.finishOnboarding(skipped: true),
                        style: TextButton.styleFrom(
                          foregroundColor: t.muted,
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        child: Text(
                          l.onboardingSkip,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            if (at > 0) ...[
              _CardButton(
                theme: t,
                label: l.onboardingBack,
                onTap: c.backOnboardingStep,
              ),
              const SizedBox(width: 10),
            ],
            _CardButton(
              theme: t,
              label: last ? l.onboardingFinish : l.onboardingNext,
              primary: true,
              enabled: c.canAdvanceOnboarding,
              onTap: c.nextOnboardingStep,
            ),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

/// How tall a footer button is, both kinds.
const _buttonHeight = 44.0;

/// A button on the card's footer, loud or quiet.
///
/// Both are built here rather than the quiet one borrowing
/// [accentButtonStyle]: a Material button sizes itself from its own
/// padding and would sit a few pixels shorter than the one beside it,
/// which reads as two buttons that don't belong together rather than as
/// a pair. Same geometry, same label size, different material.
class _CardButton extends StatelessWidget {
  const _CardButton({
    required this.theme,
    required this.label,
    required this.onTap,
    this.primary = false,
    this.enabled = true,
  });

  final GameTheme theme;
  final String label;
  final VoidCallback onTap;
  final bool primary;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final surface = primary ? SkinSurface.primary : SkinSurface.button;
    return HoverBuilder(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      builder: (context, hovered) => Opacity(
        opacity: enabled ? 1 : .5,
        child: GestureDetector(
          onTap: enabled ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            // Spelled out rather than left to the padding: the quiet one
            // carries a border and the loud one doesn't, which is two
            // pixels of difference and enough to read as a mismatched
            // pair. A skin with a heavier keyline would widen the gap.
            height: _buttonHeight,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: t.skin.decorate(t, surface,
                radius: 12,
                state: skinState(hovered: hovered && enabled),
                // The quiet one is the app's accent outline: a tinted
                // fill inside a line of the accent, like every other
                // secondary button in the app.
                fill: primary ? null : t.tint,
                outline: primary ? null : t.accent),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: primary ? FontWeight.w900 : FontWeight.w800,
                color: t.skin.ink(t, surface,
                    otherwise: primary ? Colors.white : t.accent),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Whichever page is up, as a column the card scrolls.
class _StepBody extends StatelessWidget {
  const _StepBody({required this.theme, required this.controller});

  final GameTheme theme;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final c = controller;
    final l = L.of(context);
    return _Stagger(
      children: switch (c.onboardingStep) {
        OnboardingStep.welcome => _welcome(context, t, c, l),
        OnboardingStep.games => _games(context, t, c, l),
        OnboardingStep.favorite => _favorite(context, t, c, l),
        OnboardingStep.look => _look(context, t, c, l),
        OnboardingStep.library => _library(context, t, c, l),
        OnboardingStep.done => _done(context, t, c, l),
      },
    );
  }

  List<Widget> _welcome(BuildContext context, GameTheme t, AppController c, L l) {
    return [
      Center(child: _Bob(child: BrandMark(gameId: c.adapter.game.id, size: 64))),
      const SizedBox(height: 20),
      _title(t, l.onboardingWelcomeTitle, center: true),
      const SizedBox(height: 10),
      _body(t, l.onboardingWelcomeBody, center: true),
      const SizedBox(height: 24),
      Text(l.languageTitle, style: eyebrowStyle(t)),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _PickChip(
            theme: t,
            label: l.languageSystem,
            selected: c.settings.localeCode == null,
            onTap: () => c.setLocale(null),
          ),
          for (final language in appLanguages)
            _PickChip(
              theme: t,
              label: language.name,
              selected: c.settings.localeCode == language.code,
              onTap: () => c.setLocale(language.code),
            ),
        ],
      ),
    ];
  }

  List<Widget> _games(BuildContext context, GameTheme t, AppController c, L l) {
    final found = c.installedGames.length;
    final nothing = !c.scanningGames && found == 0;
    return [
      _title(t, l.onboardingGamesTitle),
      const SizedBox(height: 8),
      _body(t, l.onboardingGamesBody),
      const SizedBox(height: 16),
      Row(
        children: [
          if (c.scanningGames)
            SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(strokeWidth: 2, color: t.accent),
            )
          else
            Icon(Icons.check_circle_rounded, size: 17, color: t.accent),
          const SizedBox(width: 9),
          Flexible(
            child: Text(
              c.scanningGames ? l.onboardingScanning : l.onboardingGamesFound(found),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: t.accent,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      for (final adapter in c.registry.adapters) ...[
        _GameRow(theme: t, controller: c, adapter: adapter),
        const SizedBox(height: 7),
      ],
      if (nothing) ...[
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: t.skin.decorate(t, SkinSurface.notice,
              radius: 12, accent: t.warning),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.onboardingNoGamesTitle,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: t.onWarningTint,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                l.onboardingNoGamesBody,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: t.onWarningTint,
                ),
              ),
            ],
          ),
        ),
      ],
    ];
  }

  List<Widget> _favorite(
      BuildContext context, GameTheme t, AppController c, L l) {
    return [
      _title(t, l.onboardingFavoriteTitle),
      const SizedBox(height: 8),
      _body(t, l.onboardingFavoriteBody),
      const SizedBox(height: 18),
      LayoutBuilder(
        builder: (context, box) {
          // Two to a row where there is room for two, one where there
          // isn't - a game's name is the widest thing on the card.
          final columns = box.maxWidth >= 420 ? 2 : 1;
          final width = (box.maxWidth - (columns - 1) * 10) / columns;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final adapter in c.installedGames)
                SizedBox(
                  width: width,
                  child: _GameChoice(
                    theme: t,
                    controller: c,
                    adapter: adapter,
                    selected: c.defaultGameId == adapter.game.id,
                  ),
                ),
            ],
          );
        },
      ),
    ];
  }

  List<Widget> _look(BuildContext context, GameTheme t, AppController c, L l) {
    final s = c.settings;
    return [
      _title(t, l.onboardingLookTitle),
      const SizedBox(height: 8),
      _body(t, l.onboardingLookBody),
      const SizedBox(height: 18),
      Text(l.themeTitle, style: eyebrowStyle(t)),
      const SizedBox(height: 10),
      Builder(builder: (context) {
        const modes = [null, 'light', 'dark'];
        final labels = [l.themeSystem, l.themeLight, l.themeDark];
        return Row(
          children: [
            for (var i = 0; i < modes.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: _ThemeTile(
                  theme: t,
                  label: labels[i],
                  mode: modes[i],
                  selected: s.themeModeName == modes[i],
                  onTap: () => c.setThemeMode(modes[i]),
                ),
              ),
            ],
          ],
        );
      }),
      const SizedBox(height: 18),
      _ToggleRow(
        theme: t,
        title: l.prefSoundEffectsTitle,
        desc: l.prefSoundEffectsDesc,
        value: s.soundEffects,
        onToggle: () => c.setPref(
          () => s.setSoundEffects(!s.soundEffects),
          sound: s.soundEffects ? UiSound.toggleOff : UiSound.toggleOn,
          setting: 'soundEffects',
          value: !s.soundEffects,
        ),
      ),
      const SizedBox(height: 10),
      _ToggleRow(
        theme: t,
        title: l.prefTriviaTitle,
        desc: l.prefTriviaDesc,
        value: s.triviaBuddy,
        onToggle: () => c.setTriviaBuddy(!s.triviaBuddy),
      ),
    ];
  }

  List<Widget> _library(
      BuildContext context, GameTheme t, AppController c, L l) {
    final s = c.settings;
    return [
      _title(t, l.onboardingLibraryTitle),
      const SizedBox(height: 8),
      _body(t, l.onboardingLibraryBody),
      const SizedBox(height: 18),
      _ToggleRow(
        theme: t,
        title: l.prefScanArtworkTitle,
        desc: l.prefScanArtworkDesc,
        value: s.scanArtwork,
        onToggle: () => c.setScanArtwork(!s.scanArtwork),
      ),
      const SizedBox(height: 10),
      _ToggleRow(
        theme: t,
        title: l.prefWarnConflictsTitle,
        desc: l.prefWarnConflictsDesc,
        value: s.warnConflicts,
        onToggle: () => c.setPref(
          () => s.setWarnConflicts(!s.warnConflicts),
          sound: s.warnConflicts ? UiSound.toggleOff : UiSound.toggleOn,
          setting: 'warnConflicts',
          value: !s.warnConflicts,
        ),
      ),
    ];
  }

  List<Widget> _done(BuildContext context, GameTheme t, AppController c, L l) {
    return [
      Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 520),
          curve: Curves.elasticOut,
          builder: (context, value, child) =>
              Transform.scale(scale: value.clamp(0, 1.4), child: child),
          child: Container(
            width: 66,
            height: 66,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: t.accentGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: t.accent.withValues(alpha: .45),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.check_rounded, size: 36, color: Colors.white),
          ),
        ),
      ),
      const SizedBox(height: 20),
      _title(t, l.onboardingDoneTitle, center: true),
      const SizedBox(height: 10),
      _body(t, l.onboardingDoneBody, center: true),
    ];
  }

  static Widget _title(GameTheme t, String text, {bool center = false}) => Text(
        text,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          height: 1.15,
          color: t.text,
        ),
      );

  static Widget _body(GameTheme t, String text, {bool center = false}) => Text(
        text,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: TextStyle(
          fontSize: 13.5,
          height: 1.5,
          fontWeight: FontWeight.w600,
          color: t.muted,
        ),
      );
}

/// One game on the detection page: what it is, and whether it is here.
class _GameRow extends StatelessWidget {
  const _GameRow(
      {required this.theme, required this.controller, required this.adapter});

  final GameTheme theme;
  final AppController controller;
  final GameAdapter adapter;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final l = L.of(context);
    final game = adapter.game;
    final count = controller.modCounts[game.id];
    final installed = count != null;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: installed ? 1 : .5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: t.skin.decorate(t, SkinSurface.row,
            radius: 12,
            state: installed ? SkinState.active : SkinState.idle,
            fill: installed ? t.tint : t.surfaceAlt),
        child: Row(
          children: [
            _GameGlyph(game: game, size: 26),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: t.text,
                    ),
                  ),
                  Text(
                    installed
                        ? l.onboardingGameMods(count)
                        : (controller.scanningGames
                            ? l.onboardingScanning
                            : l.onboardingGameMissing),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: t.muted,
                    ),
                  ),
                ],
              ),
            ),
            if (installed)
              Icon(Icons.check_circle_rounded, size: 18, color: t.accent),
          ],
        ),
      ),
    );
  }
}

/// A game to start on, as a card that can be picked.
class _GameChoice extends StatelessWidget {
  const _GameChoice({
    required this.theme,
    required this.controller,
    required this.adapter,
    required this.selected,
  });

  final GameTheme theme;
  final AppController controller;
  final GameAdapter adapter;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final l = L.of(context);
    final game = adapter.game;
    final count = controller.modCounts[game.id] ?? 0;
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: () => controller.setDefaultGame(game.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
          decoration: t.skin.decorate(t, SkinSurface.panel,
              radius: 14,
              state: skinState(active: selected, hovered: hovered),
              fill: selected ? t.tint : t.surfaceAlt),
          child: Row(
            children: [
              _GameGlyph(game: game, size: 30),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: t.text,
                      ),
                    ),
                    Text(
                      l.onboardingGameMods(count),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: t.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              AnimatedScale(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                scale: selected ? 1 : 0,
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration:
                      BoxDecoration(gradient: t.accentGradient, shape: BoxShape.circle),
                  child: const Icon(Icons.check_rounded,
                      size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A game's icon, falling back to its plumbob for a game we ship no icon
/// for (and for one whose file the antivirus is still holding on the
/// first launch after an install).
class _GameGlyph extends StatelessWidget {
  const _GameGlyph({required this.game, required this.size});

  final Game game;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = GameTheme.iconAsset(game);
    final fallback = BrandMark(gameId: game.id, size: size);
    if (asset == null) return fallback;
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(asset,
          fit: BoxFit.contain, errorBuilder: (_, __, ___) => fallback),
    );
  }
}

/// Light / dark / system, drawn as the thing it does rather than named
/// and left at that: a scrap of window in that mode over its label.
class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.theme,
    required this.label,
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final GameTheme theme;
  final String label;

  /// 'light', 'dark', or null for whatever the desktop says.
  final String? mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final dark = mode == null
        ? Theme.of(context).brightness == Brightness.dark
        : mode == 'dark';
    final paper = dark ? const Color(0xFF1B1F1E) : const Color(0xFFF7F9F8);
    final ink = dark ? const Color(0xFF7E8C89) : const Color(0xFFC3CFCB);
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 9),
          decoration: t.skin.decorate(t, SkinSurface.panel,
              radius: 13,
              state: skinState(active: selected, hovered: hovered),
              fill: selected ? t.tint : t.surfaceAlt),
          child: Column(
            children: [
              Container(
                height: 42,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: paper,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: t.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Two bars and an accent one: the least a window can
                    // be and still read as one.
                    _bar(ink, 1),
                    const SizedBox(height: 4),
                    _bar(t.accent, .55),
                    const SizedBox(height: 4),
                    _bar(ink, .75),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: selected ? t.accent : t.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bar(Color color, double widthFactor) => FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: widthFactor,
        child: Container(
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}

/// A setting, worded exactly as Settings words it, with the same switch.
class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.theme,
    required this.title,
    required this.desc,
    required this.value,
    required this.onToggle,
  });

  final GameTheme theme;
  final String title;
  final String desc;
  final bool value;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: t.skin.decorate(t, SkinSurface.panel,
              radius: 13,
              state: skinState(hovered: hovered),
              fill: t.surfaceAlt),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: t.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: t.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
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
        ),
      ),
    );
  }
}

/// A pill that is either the choice in force or one of the others.
class _PickChip extends StatelessWidget {
  const _PickChip({
    required this.theme,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final GameTheme theme;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) {
        final state = skinState(active: selected, hovered: hovered);
        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: t.skin.decorate(t, SkinSurface.chip, state: state),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: t.skin.ink(t, SkinSurface.chip,
                    state: state,
                    otherwise: selected ? null : t.text),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The card's contents arriving one after another rather than all at
/// once. One controller for the whole page, each child on its own slice
/// of it: no timers, so a test that settles the tree still settles.
class _Stagger extends StatefulWidget {
  const _Stagger({required this.children});

  final List<Widget> children;

  @override
  State<_Stagger> createState() => _StaggerState();
}

class _StaggerState extends State<_Stagger>
    with SingleTickerProviderStateMixin {
  late final AnimationController _run = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 620))
    ..forward();

  @override
  void dispose() {
    _run.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.children.length;
    // The last child still has to finish inside the controller's run, so
    // the slices get shorter the more of them there are.
    final step = count < 2 ? 0.0 : math.min(.12, .5 / (count - 1));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          _slice(i * step, widget.children[i]),
      ],
    );
  }

  Widget _slice(double start, Widget child) {
    final animation = CurvedAnimation(
      parent: _run,
      curve: Interval(start, math.min(1, start + .5), curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, .12), end: Offset.zero)
            .animate(animation),
        child: child,
      ),
    );
  }
}

/// The plumbob on the welcome page, breathing.
class _Bob extends StatefulWidget {
  const _Bob({required this.child});

  final Widget child;

  @override
  State<_Bob> createState() => _BobState();
}

class _BobState extends State<_Bob> with SingleTickerProviderStateMixin {
  late final AnimationController _run = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2600));

  @override
  void initState() {
    super.initState();
    if (_mayLoop) _run.repeat(reverse: true);
  }

  @override
  void dispose() {
    _run.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _run,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -5 * Curves.easeInOut.transform(_run.value)),
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Plumbob silhouettes drifting up the backdrop. Purely decorative: a
/// fixed dozen, no input, no state beyond the clock.
class _DriftBackdrop extends StatelessWidget {
  const _DriftBackdrop({required this.theme, required this.animation});

  final GameTheme theme;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) => CustomPaint(
          painter: _DriftPainter(theme, animation.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _DriftPainter extends CustomPainter {
  const _DriftPainter(this.theme, this.t);

  final GameTheme theme;

  /// The clock, 0 to 1 and round again.
  final double t;

  /// Where each diamond sits across the window, how big it is, how far
  /// along its own climb it starts and how fast it climbs. Written down
  /// rather than randomised, so the backdrop looks the same every time
  /// the walkthrough is opened.
  static const _seeds = <(double, double, double, double)>[
    (.06, 26, .10, .55), (.17, 44, .62, .38), (.28, 18, .35, .72),
    (.39, 34, .88, .46), (.47, 22, .21, .63), (.58, 52, .49, .33),
    (.66, 16, .74, .80), (.75, 38, .05, .43), (.84, 24, .57, .58),
    (.92, 30, .31, .50), (.12, 20, .82, .68), (.53, 28, .95, .41),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final (x, extent, phase, speed) in _seeds) {
      final progress = (phase + t * speed) % 1.0;
      // Up the window, with a lazy sway either side of its own column.
      final cx = x * size.width +
          math.sin((progress + phase) * math.pi * 2) * size.width * .02;
      final cy = size.height * (1.15 - progress * 1.3);
      // Faded in at the bottom and out at the top, so nothing pops.
      final fade = math.sin(progress * math.pi).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = theme.accent.withValues(alpha: .07 * fade)
        ..style = PaintingStyle.fill;
      final path = Path()
        ..moveTo(cx, cy - extent * .62)
        ..lineTo(cx + extent * .38, cy)
        ..lineTo(cx, cy + extent * .62)
        ..lineTo(cx - extent * .38, cy)
        ..close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_DriftPainter old) =>
      old.t != t || old.theme.accent != theme.accent;
}
