import 'dart:async';
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'game_theme.dart';
import 'l10n.dart';
import 'widgets.dart';

/// The film the walkthrough opens on, and the frame it settles on.
///
/// It ships as an animated WebP rather than as the mp4 it was cut as:
/// Flutter plays no video on the desktop without a native player behind
/// it, and every one of those is a platform library per platform for ten
/// seconds of animation. [ui.Codec] already decodes this format frame by
/// frame, which is also what lets the last frame be *held* - an animated
/// image drawn the ordinary way loops forever and has nothing to say
/// about when it reached the end.
const introAsset = 'assets/intro/intro.webp';

/// The last frame on its own. It is what the rest of the walkthrough
/// sits on, so the film's own frames and the codec behind them can go
/// the moment it is over, and it is what a machine that cannot decode
/// the film opens on instead.
const introStillAsset = 'assets/intro/last_frame.webp';

/// The music, as [AssetSource] wants it - relative to `assets/`, the
/// same as the sound bank's own paths.
const introAudioAsset = 'intro/intro.mp3';

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
  ui.Codec? _codec;
  ui.Image? _frame;

  /// Whether the film is over. From here the still is the picture and
  /// nothing else decodes.
  bool _settled = false;

  /// Set the moment anything asks the film to end, so a decode already
  /// in flight lands on the floor rather than on screen.
  bool _stopping = false;

  /// The skip hint waits a beat: offered in the first frame it reads as
  /// an apology for something that has not started yet.
  bool _offerSkip = false;
  Timer? _offer;

  /// Whether the still has been asked for yet. Warming it needs the
  /// screen's own configuration, which is not readable until the
  /// dependencies are.
  bool _warmed = false;

  /// The music, and the one player it runs on. It is kept rather than
  /// fired and forgotten the way [Sfx] fires a click, because this is
  /// the one sound in the app that something can interrupt: skipping the
  /// film has to take the music with it.
  AudioPlayer? _music;
  bool _cued = false;

  @override
  void initState() {
    super.initState();
    _offer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _offerSkip = true);
    });
    _run();
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
    _stopping = true;
    // Settled as far as anything else is concerned: a decode still in
    // flight lands after this and must not free these a second time.
    _settled = true;
    _frame?.dispose();
    _frame = null;
    _codec?.dispose();
    _codec = null;
    // The window can close on a film that is still playing, and a
    // player nobody stopped goes on making noise after it.
    unawaited(_hush());
    super.dispose();
  }

  Future<void> _run() async {
    final ui.Codec codec;
    try {
      final data = await rootBundle.load(introAsset);
      final buffer = await ui.ImmutableBuffer.fromUint8List(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      codec = await descriptor.instantiateCodec();
    } catch (_) {
      // A film that will not decode is no reason to hold up the app: the
      // still says the same thing, and the walkthrough carries on.
      return _settle();
    }
    if (!mounted || _stopping) {
      codec.dispose();
      return _settle();
    }
    _codec = codec;
    final clock = Stopwatch()..start();
    var due = Duration.zero;
    var dropped = false;
    for (var i = 0; i < codec.frameCount; i++) {
      final ui.FrameInfo info;
      try {
        info = await codec.getNextFrame();
      } catch (_) {
        break;
      }
      if (!mounted || _stopping) {
        info.image.dispose();
        break;
      }
      due += info.duration;
      // Started against the *film's* clock rather than the wall's, so
      // the music keeps its place on the picture even where the two
      // have drifted apart. This frame is the one holding the cue, and
      // it is about to go up: at worst the sound is a frame early,
      // which is the way to be wrong when a player takes a moment to
      // open the device anyway.
      if (!_cued && due > introAudioCue) {
        _cued = true;
        _play();
      }
      // Every frame is decoded whatever happens - each one is drawn on
      // top of the one before it, so there is no skipping ahead - but a
      // frame whose moment has already gone is not put on screen, which
      // is the half of the cost that can be saved. Never twice running,
      // so a machine that cannot keep up still gets a film rather than a
      // still that jumps, and never the first or the last: opening the
      // film is what clears the black, and the last frame is the one the
      // whole walkthrough then sits on.
      final behind = clock.elapsed - due > info.duration;
      final edge = i == 0 || i == codec.frameCount - 1;
      if (behind && !dropped && !edge) {
        dropped = true;
        info.image.dispose();
        continue;
      }
      dropped = false;
      _draw(info.image);
      final wait = due - clock.elapsed;
      if (wait > Duration.zero) await Future<void>.delayed(wait);
    }
    _settle();
  }

  /// Starts the music. Every failure is swallowed, the bargain [Sfx]
  /// makes: a film with no sound is worth having, and a walkthrough that
  /// refused to open because a machine has no audio device is not.
  Future<void> _play() async {
    if (!widget.sound || _settled) return;
    final player = AudioPlayer();
    _music = player;
    try {
      await player.play(AssetSource(introAudioAsset));
    } catch (_) {
      return _hush();
    }
    // Opening the device is an await, and the skip hint appears ninety
    // milliseconds *before* this cue - so being skipped while the sound
    // is still starting is the likely case here rather than the exotic
    // one. [_hush] going through in that window let go of a player that
    // had not begun yet and found nothing to stop; this is the one that
    // has to close it, because by now nothing else is holding it and
    // the music would play on over the card.
    if (!identical(_music, player)) await _close(player);
  }

  /// Silence, and the player with it. Nulled before anything is awaited
  /// so a second caller finds nothing left to close - audioplayers
  /// throws out of a second `dispose()`, into whatever zone the event
  /// arrived on, which is exactly the unhandled noise [Sfx] documents.
  Future<void> _hush() async {
    final player = _music;
    _music = null;
    if (player != null) await _close(player);
  }

  Future<void> _close(AudioPlayer player) async {
    try {
      await player.stop();
    } catch (_) {
      // Nothing to do about a sound that will not stop.
    }
    try {
      await player.dispose();
    } catch (_) {
      // Nor about a player that will not close.
    }
  }

  void _draw(ui.Image image) {
    final previous = _frame;
    setState(() => _frame = image);
    _release(previous);
  }

  /// Lets a frame go one frame later than it stops being the current
  /// one: it was painted into the tree that is still on screen while
  /// this one is being built, and eight megabytes a frame is far too
  /// much to leave to the collector.
  void _release(ui.Image? image) {
    if (image == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => image.dispose());
  }

  /// The end of it, however it was reached. The frames and the codec go
  /// here rather than in [dispose]: this widget stays for the whole
  /// walkthrough, and eight megabytes of film has nothing left to say.
  void _settle() {
    if (_settled) return;
    _settled = true;
    final frame = _frame;
    if (mounted) {
      setState(() => _frame = null);
      _release(frame);
    } else {
      _frame = null;
      frame?.dispose();
    }
    _codec?.dispose();
    _codec = null;
    _offer?.cancel();
    // Playing to the end finds the music long finished - it is four
    // seconds inside a film of ten. Being skipped finds it mid-phrase,
    // and that is what this is really for.
    unawaited(_hush());
    widget.onSettled();
  }

  void _skip() {
    if (_settled) return;
    _stopping = true;
    _settle();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    final frame = _frame;
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
          if (frame != null)
            RawImage(
                image: frame,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium),
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
