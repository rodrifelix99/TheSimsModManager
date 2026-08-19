import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// An animated WebP played through once, by hand, and then left where
/// it stopped.
///
/// Films ship in that format rather than as the mp4 they were cut as:
/// Flutter plays no video on the desktop without a native player behind
/// it, and every one of those is a platform library per platform for a
/// few seconds of animation. [ui.Codec] already decodes this one, and
/// decoding it a frame at a time rather than handing the asset to an
/// [Image] is what lets a film *end* - an animated image drawn the
/// ordinary way loops forever and has nothing to say about when it
/// reached the last frame.
///
/// It draws nothing before the first frame and nothing after the last
/// one is let go, so whatever the caller stacks underneath is what
/// shows either side of it. That is the whole of the layout contract,
/// and it is what both callers are built on: the walkthrough's film
/// sits over black and swaps itself for a still of its own last frame,
/// and the what's-new hero sits over the picture it fades back to.
///
/// A film's sound belongs to it and is played here too, cued off the
/// picture and stopped with it. That is the whole reason it is not
/// left to [Sfx]: that fires clips nothing ever has to stop, and this
/// is the one sound in the app something can interrupt - closing the
/// card or skipping the film has to take the music along.
class FilmPlayer extends StatefulWidget {
  const FilmPlayer({
    super.key,
    required this.asset,
    required this.onSettled,
    this.onFrame,
    this.holdLast = false,
    this.audio,
    this.audioCue = Duration.zero,
    this.sound = false,
    this.fit = BoxFit.cover,
  });

  /// The animated WebP, as an asset path.
  final String asset;

  /// Called once, when the film is over however it got there - played
  /// out, or nothing here could be decoded at all. Never called for a
  /// player that is simply disposed: by then the caller is going away
  /// too and has not asked to hear about it.
  final VoidCallback onSettled;

  /// Called as each frame goes up, with the film's own clock rather
  /// than the wall's, so anything cued off the picture keeps its place
  /// where the two have drifted apart. Fires for a dropped frame too:
  /// what it reports is where the film has got to, not what is on
  /// screen.
  final void Function(Duration due)? onFrame;

  /// Whether the last frame stays on screen after the film is over.
  /// Off, it goes with the rest and what was underneath comes back at
  /// once; on, it is held so the caller can dissolve it into whatever
  /// comes next, and freed when the player leaves the tree.
  final bool holdLast;

  /// The film's sound, as an asset path - the ordinary kind, the same
  /// as [asset], rather than the `assets/`-relative one [AssetSource]
  /// wants. The stripping happens here, once, so a caller cannot get it
  /// wrong: a path spelled the other way is silence and nothing else,
  /// since every failure below is swallowed.
  final String? audio;

  /// Where in the film the sound starts, so its own opening lands on
  /// the picture's. Nothing computes it; it is read off the two by
  /// hand, and zero means the two begin together.
  final Duration audioCue;

  /// Whether the sound plays at all, which is the `soundEffects` pref.
  /// Read once by the caller and passed in: a film is short and the
  /// switch is nowhere near it, so it cannot move underneath.
  final bool sound;

  final BoxFit fit;

  @override
  State<FilmPlayer> createState() => _FilmPlayerState();
}

/// Whether a film really plays. Every widget test in the suite pumps a
/// screen one of these can sit on, and seconds of decoding in front of
/// each is the answer to all of them: under `flutter test` a film is
/// over before it starts and what a test measures is the picture
/// underneath, which is what the machine that cannot decode it sees.
bool get _plays => !Platform.environment.containsKey('FLUTTER_TEST');

class _FilmPlayerState extends State<FilmPlayer> {
  ui.Codec? _codec;
  ui.Image? _frame;

  /// Whether the film is over. From here nothing else decodes.
  bool _settled = false;

  /// Set the moment anything asks the film to end, so a decode already
  /// in flight lands on the floor rather than on screen.
  bool _stopping = false;

  /// The sound, and the one player it runs on.
  AudioPlayer? _music;
  bool _cued = false;

  @override
  void initState() {
    super.initState();
    if (!_plays) {
      // Post-frame rather than here: [onSettled] is a caller's setState
      // more often than not, and this runs inside their build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _settle();
      });
      return;
    }
    _run();
  }

  @override
  void dispose() {
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
    ui.ImmutableBuffer? buffer;
    try {
      final data = await rootBundle.load(widget.asset);
      buffer = await ui.ImmutableBuffer.fromUint8List(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      codec = await descriptor.instantiateCodec();
    } catch (_) {
      // A film that will not decode is no reason to hold anything up:
      // what is underneath says the same thing more quietly.
      return _settle();
    } finally {
      // What the engine's own `instantiateImageCodecWithSize` does in
      // the same place, and for the same reason: the codec has taken
      // what it needs, and what this holds is the *encoded* film - the
      // longest of them is twenty-five megabytes - sitting on the
      // engine's heap until the collector happens to finalize a Dart
      // wrapper it has no reason to hurry over.
      buffer?.dispose();
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
      widget.onFrame?.call(due);
      // Started against the *film's* clock rather than the wall's, so
      // the sound keeps its place on the picture even where the two
      // have drifted apart. This frame is the one holding the cue and
      // it is about to go up: at worst the sound is a frame early,
      // which is the way to be wrong when a player takes a moment to
      // open the device anyway.
      if (!_cued && due > widget.audioCue) {
        _cued = true;
        _play();
      }
      // Every frame is decoded whatever happens - each one is drawn on
      // top of the one before it, so there is no skipping ahead - but a
      // frame whose moment has already gone is not put on screen, which
      // is the half of the cost that can be saved. Never twice running,
      // so a machine that cannot keep up still gets a film rather than
      // a slideshow, and never the first or the last: the first is what
      // clears whatever was there, and the last is the one a held film
      // stops on.
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

  /// Starts the sound. Every failure is swallowed, the bargain [Sfx]
  /// makes: a film with no sound is worth having, and a card that
  /// refused to open because a machine has no audio device is not.
  Future<void> _play() async {
    final audio = widget.audio;
    if (audio == null || !widget.sound || _settled) return;
    final player = AudioPlayer();
    _music = player;
    try {
      // [AssetSource] wants the path from inside `assets/`, which is
      // the one spelling in the app that is not an asset path.
      await player.play(AssetSource(
          audio.startsWith('assets/') ? audio.substring(7) : audio));
    } catch (_) {
      return _hush();
    }
    // Opening the device is an await, and a film can be skipped or a
    // card closed while the sound is still starting - which is the
    // likely case here rather than the exotic one. [_hush] going
    // through in that window let go of a player that had not begun yet
    // and found nothing to stop; this is the one that has to close it,
    // because by now nothing else is holding it and the sound would
    // play on over whatever came next.
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
  /// this one is being built, and a film's worth of them is far too
  /// much to leave to the collector.
  void _release(ui.Image? image) {
    if (image == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => image.dispose());
  }

  /// The end of it, however it was reached. The codec goes here rather
  /// than in [dispose]: a held film outlives its own playback, and the
  /// decoder behind it has nothing left to say.
  void _settle() {
    if (_settled) return;
    _settled = true;
    _codec?.dispose();
    _codec = null;
    if (!widget.holdLast) {
      final frame = _frame;
      if (mounted) {
        setState(() => _frame = null);
        _release(frame);
      } else {
        _frame = null;
        frame?.dispose();
      }
    }
    // Playing out finds a sound the same length long finished. Being
    // stopped early finds it mid-phrase, and that is what this is
    // really for.
    unawaited(_hush());
    widget.onSettled();
  }

  @override
  Widget build(BuildContext context) {
    final frame = _frame;
    if (frame == null) return const SizedBox.shrink();
    return RawImage(
        image: frame, fit: widget.fit, filterQuality: FilterQuality.medium);
  }
}
