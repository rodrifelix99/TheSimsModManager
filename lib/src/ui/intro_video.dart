import 'dart:async';

import 'package:flutter/material.dart';

import 'film_player.dart';
import 'game_theme.dart';
import 'l10n.dart';
import 'widgets.dart';

/// The film the walkthrough opens on, and the frame it settles on.
///
/// It ships as an animated WebP and is played by [FilmPlayer], which is
/// where the reasons for both live.
const introAsset = 'assets/intro/intro.webp';

/// The last frame on its own. It is what the rest of the walkthrough
/// sits on, so the film's own frames and the codec behind them can go
/// the moment it is over, and it is what a machine that cannot decode
/// the film opens on instead.
const introStillAsset = 'assets/intro/last_frame.webp';

/// The music. An ordinary asset path like the film's own: [FilmPlayer]
/// is what turns it into the `assets/`-relative spelling the audio
/// package wants.
const introAudioAsset = 'assets/intro/intro.mp3';

/// Where in the film the music starts, so its own opening lands on the
/// picture's. Read off the two by hand; nothing computes it.
const introAudioCue = Duration(milliseconds: 1690);

/// Plays [introAsset] once, then holds [introStillAsset] behind whatever
/// comes next. Tapping it says the viewer has seen enough.
class IntroVideo extends StatefulWidget {
  const IntroVideo({
    super.key,
    required this.theme,
    required this.sound,
    required this.onSettled,
  });

  final GameTheme theme;

  /// Whether the music plays, which is the `soundEffects` pref. The film
  /// runs before the page that offers to change it, so this is read once
  /// and cannot move underneath it.
  final bool sound;

  /// Called once the last frame is up - by playing to it, by being asked
  /// to stop, or because nothing here could be decoded at all.
  final VoidCallback onSettled;

  @override
  State<IntroVideo> createState() => _IntroVideoState();
}

class _IntroVideoState extends State<IntroVideo> {
  /// Whether the film is over. From here the still is the picture, and
  /// the player is out of the tree so nothing else decodes.
  bool _settled = false;

  /// The skip hint waits a beat: offered in the first frame it reads as
  /// an apology for something that has not started yet.
  bool _offerSkip = false;
  Timer? _offer;

  /// Whether the still has been asked for yet. Warming it needs the
  /// screen's own configuration, which is not readable until the
  /// dependencies are.
  bool _warmed = false;

  @override
  void initState() {
    super.initState();
    _offer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _offerSkip = true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_warmed) return;
    _warmed = true;
    // The still is warmed while the film plays, so the swap at the end
    // is one picture replacing an identical one rather than a flash of
    // whatever is underneath. Its failure is swallowed the way the
    // film's is: the walkthrough is not worth a red screen over a
    // backdrop, and the [Image] that draws it has its own way out.
    precacheImage(const AssetImage(introStillAsset), context,
        onError: (_, __) {});
  }

  @override
  void dispose() {
    _offer?.cancel();
    super.dispose();
  }

  /// The end of it, however it was reached. Taking the player out of
  /// the tree is what frees the film and stops the music with it: this
  /// widget stays for the whole walkthrough, and eight megabytes of
  /// film has nothing left to say once the still is up.
  void _settle() {
    if (_settled) return;
    if (mounted) {
      setState(() => _settled = true);
    } else {
      _settled = true;
    }
    _offer?.cancel();
    widget.onSettled();
  }

  void _skip() => _settle();

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return GestureDetector(
      onTap: _settled ? null : _skip,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // What the film opens on, and what is behind it until the first
          // frame has decoded.
          const ColoredBox(color: Color(0xFF05070C)),
          if (_settled)
            Image.asset(introStillAsset,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          if (!_settled)
            FilmPlayer(
              asset: introAsset,
              audio: introAudioAsset,
              audioCue: introAudioCue,
              sound: widget.sound,
              onSettled: _settle,
            ),
          if (!_settled)
            Positioned(
              right: 26,
              bottom: 22,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 600),
                opacity: _offerSkip ? 1 : 0,
                child: _SkipHint(theme: t, onTap: _skip),
              ),
            ),
        ],
      ),
    );
  }
}

/// The way out of the film, drawn quietly over its own bottom corner.
/// Worded for the film rather than borrowing the footer's Skip, which
/// leaves the walkthrough entirely: offering that here would promise
/// something this button does not do.
class _SkipHint extends StatelessWidget {
  const _SkipHint({required this.theme, required this.onTap});

  final GameTheme theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = L.of(context);
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hovered) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.fromLTRB(14, 8, 12, 8),
          decoration: BoxDecoration(
            // Its own colours rather than the skin's: this sits on a
            // film nobody themed, where a pale plate would vanish into
            // the sky it ends on.
            color: Colors.black.withValues(alpha: hovered ? .55 : .34),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: .22)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.onboardingSkipIntro,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  size: 17, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
