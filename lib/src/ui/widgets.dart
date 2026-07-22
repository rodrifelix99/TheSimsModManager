import 'package:flutter/material.dart';

import 'game_theme.dart';

/// Rebuilds with `hovered: true` while the pointer is over the child.
class HoverBuilder extends StatefulWidget {
  const HoverBuilder({super.key, required this.builder, this.cursor});

  final Widget Function(BuildContext context, bool hovered) builder;
  final MouseCursor? cursor;

  @override
  State<HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<HoverBuilder> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.cursor ?? MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: widget.builder(context, _hovered),
    );
  }
}

/// The design's iOS-style toggle: colored track, springy white knob.
class PillSwitch extends StatelessWidget {
  const PillSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 40,
    this.height = 23,
    this.activeColor,
    this.trackColor,
  });

  final bool value;
  final VoidCallback onChanged;
  final double width;
  final double height;
  final Color? activeColor;

  /// Explicit track color override (used on the detail screen where the
  /// switch sits on a colored button).
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final knobSize = height - 5;
    final active = activeColor ?? const Color(0xFF1FBF8F);
    return GestureDetector(
      onTap: onChanged,
      behavior: HitTestBehavior.opaque,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: trackColor ??
                (value ? active : const Color(0x52788C87)), // 32% gray-green
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutBack,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: knobSize,
              height: knobSize,
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4D000000),
                    blurRadius: 3,
                    offset: Offset(0, 1),
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

/// Diagonal-stripe placeholder artwork, like the prototype's
/// repeating-linear-gradient thumbs. Colors are picked deterministically
/// from the mod name so every mod keeps its look between launches.
class StripeThumb extends StatelessWidget {
  const StripeThumb({super.key, required this.seed, this.borderRadius});

  final String seed;
  final BorderRadius? borderRadius;

  static const _pairs = <(Color, Color)>[
    (Color(0xFF8FD3C7), Color(0xFF5FB3A6)),
    (Color(0xFFF2C79A), Color(0xFFE6A878)),
    (Color(0xFFB9A7E0), Color(0xFF9A86CF)),
    (Color(0xFF9ECBE8), Color(0xFF6FA9D6)),
    (Color(0xFFBCD39A), Color(0xFF9BB878)),
    (Color(0xFFE6A7B8), Color(0xFFCF869A)),
    (Color(0xFFA7B4C2), Color(0xFF8695A6)),
    (Color(0xFFE3D3A2), Color(0xFFCDB97E)),
    (Color(0xFFF0A891), Color(0xFFDD8570)),
    (Color(0xFFA3DDC0), Color(0xFF7CC3A2)),
  ];

  @override
  Widget build(BuildContext context) {
    final (c1, c2) = _pairs[seed.hashCode.abs() % _pairs.length];
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CustomPaint(
        painter: _StripePainter(c1, c2),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  const _StripePainter(this.c1, this.c2);

  final Color c1;
  final Color c2;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = c1);
    final paint = Paint()
      ..color = c2
      ..strokeWidth = 14;
    // 45° stripes, 28px period, covering the whole rect.
    for (double x = -size.height; x < size.width + size.height; x += 28) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) => old.c1 != c1 || old.c2 != c2;
}

/// Small rounded label chip, e.g. the category tag on mod cards.
class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}

/// The little "conflict" badge with the white exclamation dot.
class ConflictBadge extends StatelessWidget {
  const ConflictBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
      decoration: BoxDecoration(
        color: conflictOrange,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 13,
            height: 13,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Text(
              '!',
              style: TextStyle(
                color: conflictOrange,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 5),
          const Text(
            'conflict',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Formats a byte count the way the design does: "480 MB", "2.2 GB".
String formatBytes(int? bytes) {
  if (bytes == null) return '—';
  const mb = 1024 * 1024;
  const gb = 1000 * mb;
  if (bytes >= 1000 * gb) {
    return '${(bytes / (1000 * gb)).toStringAsFixed(1)} TB';
  }
  if (bytes >= gb) {
    return '${(bytes / gb).toStringAsFixed(1)} GB';
  }
  if (bytes >= mb) return '${(bytes / mb).round()} MB';
  if (bytes >= 1024) return '${(bytes / 1024).round()} KB';
  return '$bytes B';
}
