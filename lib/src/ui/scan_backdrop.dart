import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'game_theme.dart';

/// Ambient backdrop for the artwork-scan loading screen: mod artwork and
/// cleaned-up titles drift up the screen with a depth illusion — far items
/// are smaller, fainter, blurrier, and slower than near ones.
///
/// [itemsSource] is pulled fresh every time a new floater spawns, so
/// artwork discovered mid-scan starts appearing without any rebuild
/// plumbing. Purely decorative: capped particle count, no input handling.
class ScanFloatBackdrop extends StatefulWidget {
  const ScanFloatBackdrop({
    super.key,
    required this.theme,
    required this.itemsSource,
  });

  final GameTheme theme;
  final List<(String, Uint8List?)> Function() itemsSource;

  @override
  State<ScanFloatBackdrop> createState() => _ScanFloatBackdropState();
}

class _Floater {
  _Floater({
    required this.title,
    required this.artwork,
    required this.x,
    required this.depth,
    required this.sway,
    required this.phase,
    required this.spawnedAt,
  });

  final String title;
  final Uint8List? artwork;

  /// Horizontal position as a fraction of the backdrop width.
  final double x;

  /// 0 = far away (small, faint, blurred, slow) … 1 = up close.
  final double depth;

  /// Horizontal sway amplitude, fraction of the backdrop width.
  final double sway;

  /// Sway phase offset so floaters don't move in lockstep.
  final double phase;

  /// Seconds on the ticker clock when this floater appeared.
  final double spawnedAt;

  /// Upward speed, fraction of the backdrop height per second.
  double get speed => lerpDouble(0.06, 0.16, depth)!;

  /// Top edge as a fraction of height: starts just below the screen and
  /// drifts past the top.
  double topAt(double now) => 1.05 - (now - spawnedAt) * speed;
}

class _ScanFloatBackdropState extends State<ScanFloatBackdrop>
    with SingleTickerProviderStateMixin {
  static const _maxFloaters = 14;
  static const _spawnEvery = 0.55; // seconds

  late final Ticker _ticker;
  final _random = Random();
  final _floaters = <_Floater>[];
  double _now = 0;
  double _lastSpawn = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    final now = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    _floaters.removeWhere((f) => f.topAt(now) < -0.3);
    if (now - _lastSpawn >= _spawnEvery && _floaters.length < _maxFloaters) {
      final pool = widget.itemsSource();
      if (pool.isNotEmpty) {
        var (title, artwork) = pool[_random.nextInt(pool.length)];
        // Keep a mix of artwork and titles even once most mods have art.
        if (artwork != null && _random.nextDouble() < 0.3) artwork = null;
        final depth = 0.15 + _random.nextDouble() * 0.85;
        _floaters
          ..add(_Floater(
            title: title,
            artwork: artwork,
            x: 0.05 + _random.nextDouble() * 0.8,
            depth: depth,
            sway: 0.01 + _random.nextDouble() * 0.03,
            phase: _random.nextDouble() * 2 * pi,
            spawnedAt: now,
          ))
          // Paint order: far floaters behind near ones.
          ..sort((a, b) => a.depth.compareTo(b.depth));
        _lastSpawn = now;
      }
    }
    setState(() => _now = now);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.theme;
    return RepaintBoundary(
      child: ClipRect(
        child: LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;
          return Stack(
            children: [
              for (final f in _floaters)
                Positioned(
                  left: (f.x + f.sway * sin(_now * 0.6 + f.phase)) * width,
                  top: f.topAt(_now) * height,
                  child: _floaterVisual(t, f),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _floaterVisual(GameTheme t, _Floater f) {
    final opacity = lerpDouble(0.10, 0.42, f.depth)!;
    final blur = lerpDouble(3.5, 0, f.depth)!;
    Widget child;
    final artwork = f.artwork;
    if (artwork != null && artwork.isNotEmpty) {
      final size = lerpDouble(52, 140, f.depth)!;
      child = ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.12),
        child: Image.memory(
          artwork,
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          // Bound the decode: backdrop tiles never exceed ~140 logical px.
          cacheWidth: 300,
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      );
    } else {
      child = Text(
        f.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: lerpDouble(12, 22, f.depth),
          fontWeight: FontWeight.w800,
          color: t.muted,
        ),
      );
    }
    if (blur > 0.1) {
      child = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: child,
      );
    }
    return IgnorePointer(child: Opacity(opacity: opacity, child: child));
  }
}
