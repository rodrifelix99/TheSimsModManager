import 'dart:typed_data';

import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart' show NumberFormat;

import 'game_skin.dart';
import 'game_theme.dart';
import 'l10n.dart';
import 'plumbob_icons.dart';

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

/// The eyebrow style for the small all-caps-feeling section labels
/// (sidebar "Games", Settings section headers, the setup screen's
/// "Found on this computer"). One style, because each screen had begun
/// typing its own with a slightly different letter spacing.
TextStyle eyebrowStyle(GameTheme t) => TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.1,
      color: t.muted,
    );

/// The standard accent-outlined chrome button (Settings' folder actions,
/// the empty library's "open folder"). The setup screen's big paired CTAs
/// keep their own larger geometry to match their FilledButton sibling.
ButtonStyle accentButtonStyle(GameTheme t) => OutlinedButton.styleFrom(
      foregroundColor: t.accent,
      backgroundColor: t.tint,
      side: BorderSide(color: t.accent, width: 1.5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
    );

/// The selected game's own plumbob art, drawn at [size] tall. One widget
/// for the sidebar, the about card and the shop's empty state, whose
/// hand-built rotated squares this replaced had drifted a constant at a
/// time and could never carry a game's actual plumbob shape and color.
class BrandMark extends StatelessWidget {
  const BrandMark(
      {super.key, required this.gameId, this.size = 26, this.name, this.ink});

  final String gameId;
  final double size;

  /// The game's own name, for the neutral badge to take an initial off.
  /// The name rather than the id, because the id is a settings key that
  /// nobody reads and may be spelled nothing like the game.
  final String? name;

  /// The palette's accent, for the neutral badge. Passed in because
  /// nothing hands a [GameTheme] down the tree; without one the badge
  /// falls back to Material's primary, which is that accent's seed.
  final Color? ink;

  /// The first letter of the game's name, uppercased. Empty when there
  /// is no name to take one from, which draws a plain badge rather than
  /// a letter nobody chose.
  String get _initial {
    final source = name?.trim() ?? '';
    return source.isEmpty ? '' : source.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      // The same first-launch race the sidebar's game icons hit: an
      // install that has just finished hands the app files the antivirus
      // is still scanning, and a plumbob that failed to load reached
      // FlutterError.onError as a crash report for artwork that draws
      // fine on the next run. The space it would have taken is a better
      // answer than that - the mark is decoration, and everything it
      // sits beside says the same thing in words.
      child: switch (brandMarkAsset(gameId)) {
        final asset? => Image.asset(asset,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const SizedBox()),
        // A game this build ships no emblem for. Drawn rather than
        // borrowed: handing a SimCity row The Sims' plumbob would be a
        // stronger claim than a stand-in has any right to make, and a
        // blank would leave the sidebar's title with nothing beside it.
        _ => _NeutralMark(size: size, letter: _initial, ink: ink),
      },
    );
  }
}

/// The stand-in emblem: the accent-coloured plate every skin already
/// draws, with the game's own initial on it. No asset, so a game added
/// tomorrow has one on the day it is registered.
class _NeutralMark extends StatelessWidget {
  const _NeutralMark(
      {required this.size, required this.letter, required this.ink});

  final double size;
  final String letter;
  final Color? ink;

  @override
  Widget build(BuildContext context) {
    final ink = this.ink ?? Theme.of(context).colorScheme.primary;
    return SizedBox(
      width: size * 0.82,
      height: size,
      child: Center(
        child: Container(
          width: size * 0.78,
          height: size * 0.78,
          decoration: BoxDecoration(
            color: ink.withValues(alpha: 0.16),
            border: Border.all(color: ink, width: size * 0.07),
            borderRadius: BorderRadius.circular(size * 0.22),
          ),
          child: Center(
            child: Text(
              letter,
              maxLines: 1,
              style: TextStyle(
                color: ink,
                fontSize: size * 0.44,
                height: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The design's iOS-style toggle: colored track, springy white knob.
class PillSwitch extends StatelessWidget {
  const PillSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    required this.activeColor,
    required this.inactiveColor,
    required this.shadow,
    this.width = 40,
    this.height = 23,
    this.trackColor,
  });

  final bool value;
  final VoidCallback onChanged;
  final double width;
  final double height;
  final Color activeColor;

  /// Track color while off (the theme's [GameTheme.switchOff]).
  final Color inactiveColor;

  /// Base color of the knob's drop shadow (the theme's
  /// [GameTheme.shadow]).
  final Color shadow;

  /// Explicit track color override (used on the detail screen where the
  /// switch sits on a colored button).
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final knobSize = height - 5;
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
            color: trackColor ?? (value ? activeColor : inactiveColor),
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
                boxShadow: [
                  BoxShadow(
                    color: shadow.withValues(alpha: .3),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
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

/// A mod's thumbnail: artwork dug out of the mod file by the library's
/// bulk scan, [StripeThumb] placeholder art when there is none.
/// Undecodable bytes also fall back to the stripes, so a wrong guess from
/// the scanner can never break a card.
class ModThumb extends StatelessWidget {
  const ModThumb({
    super.key,
    required this.seed,
    this.bytes,
    this.borderRadius,
    this.decodeWidth,
    this.fit = BoxFit.cover,
  });

  final String seed;
  final Uint8List? bytes;
  final BorderRadius? borderRadius;

  /// Cropped to the slot by default, which is what a card wants. A frame
  /// showing the picture for its own sake asks for [BoxFit.contain].
  final BoxFit fit;

  /// Widest raster to decode the artwork into. Embedded previews are often
  /// far larger than the slot showing them, and a decoded image costs
  /// width × height × 4 bytes however small it's drawn - so callers pass
  /// the size they actually paint at. Null decodes at full size.
  final int? decodeWidth;

  @override
  Widget build(BuildContext context) {
    final fallback = StripeThumb(seed: seed, borderRadius: borderRadius);
    final data = bytes;
    if (data == null || data.isEmpty) return fallback;
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.memory(
        data,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        cacheWidth: decodeWidth,
        errorBuilder: (_, __, ___) => fallback,
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
  const ConflictBadge(
      {super.key, required this.theme, this.label, this.color, this.icon});

  final GameTheme theme;

  /// Wording for the badge; defaults to the conflict one. The advisory
  /// badge borrows the same marker with its own word, so a card carries
  /// one "something's up with this mod" flag rather than two identical
  /// ones stacked next to each other.
  final String? label;

  /// Fill color; the warning orange unless a caller says otherwise. The
  /// shop's update badge is the one piece of good news that wears this
  /// shape, so it comes through in the accent instead.
  final Color? color;

  /// Marker inside the white dot, "!" unless replaced.
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final fill = color ?? theme.warning;
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 3, 8, 3),
      decoration: BoxDecoration(
        color: fill,
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
            child: Text(
              icon ?? '!',
              style: TextStyle(
                color: fill,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label ?? L.of(context).conflictBadge,
            style: const TextStyle(
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

/// Single-line row that never wraps: children lay out left to right and
/// the ones that don't fit are hidden. The last child is the overflow
/// button (e.g. a "..." chip): it appears right after the last fitting
/// child whenever something is hidden, and disappears when everything
/// fits. [onVisibleCountChanged] reports how many leading children fit
/// (overflow button excluded) so the caller can list the hidden ones in
/// a menu; it fires during layout, so it must only record the value and
/// never call setState synchronously.
class OverflowRow extends MultiChildRenderObjectWidget {
  const OverflowRow({
    super.key,
    this.spacing = 9,
    required this.onVisibleCountChanged,
    required super.children,
  });

  final double spacing;
  final ValueChanged<int> onVisibleCountChanged;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderOverflowRow(spacing, onVisibleCountChanged);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderOverflowRow)
      ..spacing = spacing
      ..onVisibleCountChanged = onVisibleCountChanged;
  }
}

class _OverflowRowParentData extends ContainerBoxParentData<RenderBox> {
  bool visible = false;
}

class _RenderOverflowRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _OverflowRowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _OverflowRowParentData> {
  _RenderOverflowRow(this._spacing, this.onVisibleCountChanged);

  double _spacing;
  set spacing(double value) {
    if (value == _spacing) return;
    _spacing = value;
    markNeedsLayout();
  }

  ValueChanged<int> onVisibleCountChanged;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _OverflowRowParentData) {
      child.parentData = _OverflowRowParentData();
    }
  }

  @override
  void performLayout() {
    final children = getChildrenAsList();
    if (children.isEmpty) {
      size = constraints.smallest;
      onVisibleCountChanged(0);
      return;
    }
    final button = children.removeLast();
    const loose = BoxConstraints();
    for (final child in children) {
      child.layout(loose, parentUsesSize: true);
    }
    button.layout(loose, parentUsesSize: true);

    final maxWidth = constraints.maxWidth;
    var total = 0.0;
    for (var i = 0; i < children.length; i++) {
      total += children[i].size.width + (i > 0 ? _spacing : 0);
    }

    int visible;
    bool showButton;
    if (total <= maxWidth) {
      visible = children.length;
      showButton = false;
    } else {
      // Reserve room for the button, then take chips until one no
      // longer fits.
      showButton = true;
      visible = 0;
      var used = button.size.width;
      for (final child in children) {
        final w = child.size.width + _spacing;
        if (used + w > maxWidth) break;
        used += w;
        visible++;
      }
    }

    var rowHeight = button.size.height;
    for (final child in children) {
      rowHeight = math.max(rowHeight, child.size.height);
    }

    size = constraints
        .constrain(Size(maxWidth.isFinite ? maxWidth : total, rowHeight));

    var x = 0.0;
    for (var i = 0; i < children.length; i++) {
      final pd = children[i].parentData! as _OverflowRowParentData;
      pd.visible = i < visible;
      if (pd.visible) {
        pd.offset = Offset(x, (rowHeight - children[i].size.height) / 2);
        x += children[i].size.width + _spacing;
      } else {
        // Parked past the row's edge so stale offsets never report a
        // hidden chip as overlapping a visible one (they aren't painted
        // or hit-testable either way).
        pd.offset = Offset(size.width, 0);
      }
    }
    final buttonData = button.parentData! as _OverflowRowParentData;
    buttonData.visible = showButton;
    buttonData.offset = showButton
        ? Offset(x, (rowHeight - button.size.height) / 2)
        : Offset(size.width, 0);

    onVisibleCountChanged(visible);
  }

  /// Hidden chips must not be announced by screen readers.
  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    var child = firstChild;
    while (child != null) {
      final pd = child.parentData! as _OverflowRowParentData;
      if (pd.visible) visitor(child);
      child = pd.nextSibling;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var child = firstChild;
    while (child != null) {
      final pd = child.parentData! as _OverflowRowParentData;
      if (pd.visible) context.paintChild(child, pd.offset + offset);
      child = pd.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    var child = lastChild;
    while (child != null) {
      final pd = child.parentData! as _OverflowRowParentData;
      if (pd.visible) {
        final isHit = result.addWithPaintOffset(
          offset: pd.offset,
          position: position,
          hitTest: (result, transformed) =>
              child!.hitTest(result, position: transformed),
        );
        if (isHit) return true;
      }
      child = pd.previousSibling;
    }
    return false;
  }
}

/// Formats a byte count the way the design does: "480 MB", "2.2 GB".
/// The unit stays as-is everywhere (KB/MB/GB read fine in every language
/// we ship), but the number itself follows the locale, so German reads
/// "2,2 GB" rather than "2.2 GB".
String formatBytes(int? bytes) {
  if (bytes == null) return '-';
  const mb = 1024 * 1024;
  const gb = 1000 * mb;
  if (bytes >= 1000 * gb) return '${_oneDecimal(bytes / (1000 * gb))} TB';
  if (bytes >= gb) return '${_oneDecimal(bytes / gb)} GB';
  if (bytes >= mb) return '${_whole(bytes / mb)} MB';
  if (bytes >= 1024) return '${_whole(bytes / 1024)} KB';
  return '${_whole(bytes.toDouble())} B';
}

String _oneDecimal(double value) =>
    NumberFormat.decimalPatternDigits(decimalDigits: 1).format(value);

String _whole(double value) => NumberFormat.decimalPattern().format(
      value.round(),
    );

// ---------------------------------------------------------------------
// The card overlays' shared furniture. Both the first-run walkthrough
// and the what's-new card are one panel over the whole window, so the
// button under them and the backdrop behind them live here rather than
// in whichever of the two happened to be written first.
// ---------------------------------------------------------------------

/// How tall a footer button is, both kinds.
const cardButtonHeight = 44.0;

/// A button on the card's footer, loud or quiet.
///
/// Both are built here rather than the quiet one borrowing
/// [accentButtonStyle]: a Material button sizes itself from its own
/// padding and would sit a few pixels shorter than the one beside it,
/// which reads as two buttons that don't belong together rather than as
/// a pair. Same geometry, same label size, different material.
class CardButton extends StatelessWidget {
  const CardButton({
    super.key,
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
            height: cardButtonHeight,
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

/// A strip that scrolls sideways, reachable with an ordinary mouse.
///
/// A horizontal [ListView] answers a sideways wheel and a drag no desktop
/// mouse can make, so whatever sits past its edge is out of reach: the
/// shop's game filter is nine chips wide and a narrow window shows five
/// of them. Here the plain wheel scrolls it, and an arrow sits over each
/// end there is more to see past - the wheel for the hand already on it,
/// the arrows because nothing on screen says a wheel would do anything.
///
/// The arrows float over the strip rather than fading it out at the
/// edges: what a screen is painted on here is the skin's own backdrop,
/// which is a gradient in three of the four, so a flat wash over it is
/// the wrong colour at one end of the window.
class SideStrip extends StatefulWidget {
  const SideStrip({
    super.key,
    required this.theme,
    required this.builder,
    this.step = 180,
    this.inset = 6,
  });

  final GameTheme theme;

  /// Builds the strip itself. It has to take the controller handed to it
  /// and scroll horizontally, or nothing here reaches it.
  final Widget Function(BuildContext context, ScrollController controller)
      builder;

  /// How far one press of an arrow moves the strip.
  final double step;

  /// How far in from the strip's own edge the arrows sit.
  final double inset;

  @override
  State<SideStrip> createState() => _SideStripState();
}

class _SideStripState extends State<SideStrip> {
  final _controller = ScrollController();

  /// Both true until there is a strip to measure, so a row that fits
  /// never flashes an arrow on its first frame.
  bool _atStart = true;
  bool _atEnd = true;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_sync);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sync() {
    if (!mounted || !_controller.hasClients) return;
    final p = _controller.position;
    // A pixel of slack: a strip resting at its end can sit a fraction
    // short of the extent and would keep an arrow that does nothing.
    final atStart = p.pixels <= p.minScrollExtent + 1;
    final atEnd = p.pixels >= p.maxScrollExtent - 1;
    if (atStart == _atStart && atEnd == _atEnd) return;
    setState(() {
      _atStart = atStart;
      _atEnd = atEnd;
    });
  }

  /// What the wheel over the strip does. Only a wheel with nothing
  /// sideways about it: a trackpad's own horizontal swipe already
  /// reaches the strip, and answering that too would move it twice.
  void _wheel(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (event.scrollDelta.dx != 0 || !_controller.hasClients) return;
    final p = _controller.position;
    _controller.jumpTo((p.pixels + event.scrollDelta.dy)
        .clamp(p.minScrollExtent, p.maxScrollExtent));
  }

  void _nudge(double by) {
    if (!_controller.hasClients) return;
    final p = _controller.position;
    _controller.animateTo(
      (p.pixels + by).clamp(p.minScrollExtent, p.maxScrollExtent),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _wheel,
      // The metrics move when the strip's contents do - a game chip
      // arrives with the catalog, a label is longer in Polish - and that
      // is not a scroll, so nothing above would fire.
      child: NotificationListener<ScrollMetricsNotification>(
        onNotification: (_) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
          return false;
        },
        child: Stack(
          children: [
            widget.builder(context, _controller),
            Positioned(
              left: widget.inset,
              top: 0,
              bottom: 0,
              child: _arrow(back: true, shown: !_atStart),
            ),
            Positioned(
              right: widget.inset,
              top: 0,
              bottom: 0,
              child: _arrow(back: false, shown: !_atEnd),
            ),
          ],
        ),
      ),
    );
  }

  Widget _arrow({required bool back, required bool shown}) {
    final t = widget.theme;
    return Center(
      child: IgnorePointer(
        ignoring: !shown,
        child: AnimatedOpacity(
          opacity: shown ? 1 : 0,
          duration: const Duration(milliseconds: 150),
          child: HoverBuilder(
            cursor: SystemMouseCursors.click,
            builder: (context, hovered) => GestureDetector(
              onTap: () => _nudge(back ? -widget.step : widget.step),
              child: Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: t.skin.decorate(t, SkinSurface.button,
                    radius: 13,
                    state: skinState(hovered: hovered),
                    fill: t.surface,
                    outline: t.border),
                child: Icon(
                  back
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  size: 18,
                  color: t.skin.ink(t, SkinSurface.button, otherwise: t.text),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DriftBackdrop extends StatelessWidget {
  const DriftBackdrop(
      {super.key, required this.theme, required this.animation});

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
