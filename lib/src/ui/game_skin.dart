import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'game_theme.dart';

/// Which piece of chrome a decoration is for. Six roles, one per shape
/// the app actually draws, so a skin never has to guess what it is
/// painting from the colours it was handed.
enum SkinSurface {
  /// A card standing on the background: the sidebar's cards, a mod card,
  /// a settings section, a dialog.
  panel,

  /// A bordered button with an icon in it: the library toolbar's refresh,
  /// sort and new-folder buttons.
  button,

  /// A row that is invisible until it is hovered or current: the
  /// sidebar's game rows and nav buttons, the header stats.
  row,

  /// A pill that is either off or the filter in force.
  chip,

  /// A strip saying something is up - the library's advisory and
  /// read-only banners, the conflict panel on a mod's page, the restart
  /// notice on the packs screen. Tinted in whatever colour it speaks in
  /// ([decorate]'s `accent`) rather than in the surface's own.
  notice,

  /// The one loud button on a screen - Install, Add to game.
  primary,

  /// Something you type or scroll inside: the search field, the view
  /// toggle's track.
  well,
}

/// What a surface is doing at the moment. [active] is the lasting state
/// (this chip is the filter, this row is the game you are on); the other
/// two are momentary.
enum SkinState { idle, hovered, active, pressed }

/// The state, from the booleans a call site already has on hand. Being
/// the filter in force outlasts the pointer sitting on it, so [active]
/// wins over [hovered]; a press is happening right now and wins over
/// both.
SkinState skinState({
  bool active = false,
  bool hovered = false,
  bool pressed = false,
}) =>
    pressed
        ? SkinState.pressed
        : active
            ? SkinState.active
            : hovered
                ? SkinState.hovered
                : SkinState.idle;

/// How a game's chrome is *built*, as opposed to what colour it is.
///
/// [GameTheme] answers which colours; a skin answers which shapes and
/// which materials. Every game has worn [GameSkin.flat] since the design
/// handoff - a rounded rectangle, a hairline border, a tint on hover -
/// and that is still the default, so adding a game needs no skin. The
/// Sims 1 is the first with one of its own: its chrome is the game's,
/// beveled and glossy and blue.
///
/// Call sites hand over the state and take back a decoration; they never
/// ask which skin they are wearing. That is the whole point - a widget
/// that branches on the game is a skin that hasn't been written yet.
abstract class GameSkin {
  const GameSkin();

  /// Today's look, and every game's until it says otherwise.
  static const flat = FlatSkin();

  /// The Sims 1's own UI: matte blue plates over a deep navy backdrop.
  static const sims1 = Sims1Skin();

  /// The Sims 2's: periwinkle lozenges, ringed twice.
  static const sims2 = Sims2Skin();

  /// The Sims 3's: glass, and the only one of the four that really is.
  static const sims3 = Sims3Skin();

  /// The Sims Medieval's: parchment by day, carved wood by night.
  static const simsMedieval = SimsMedievalSkin();

  static GameSkin forGameId(String id) => switch (id) {
        'sims1' => sims1,
        'sims2' => sims2,
        'sims3' => sims3,
        'simsmedieval' => simsMedieval,
        _ => flat,
      };

  /// Corner rounding this skin gives [surface] when the call site has no
  /// opinion. A call site that clips (a [ClipRRect] over artwork) has to
  /// pass the same number it drew the decoration with.
  double radiusOf(SkinSurface surface);

  /// The decoration for [surface] in [state].
  ///
  /// [accent] is the colour this particular one speaks in, for the places
  /// that carry their own (a conflict stat is orange, a shop badge is the
  /// accent); null means the theme's. [elevated] asks for the lift shadow
  /// a card grows on hover.
  ///
  /// [fill] and [outline] are for the places whose colouring is their own
  /// rather than the role's - the sidebar's update card is a panel that is
  /// always ringed, because it only exists when something happened.
  /// [FlatSkin] takes both literally everywhere, so every such place keeps
  /// the look it was drawn with.
  ///
  /// A skin with a material of its own honours [fill] on the surfaces that
  /// really are surfaces - [SkinSurface.panel], [SkinSurface.notice],
  /// [SkinSurface.well], [SkinSurface.row] - and **ignores it on the
  /// raised controls**, [SkinSurface.button], [SkinSurface.chip] and
  /// [SkinSurface.primary]. A fill on one of those is the flat skin's pale
  /// tint, written to be read with dark text on it, and a raised control
  /// is made of the skin's own material with a white label across it. A
  /// call site with something to say there says it with [accent], and the
  /// material is built out of that instead.
  BoxDecoration decorate(
    GameTheme t,
    SkinSurface surface, {
    SkinState state = SkinState.idle,
    double? radius,
    Color? accent,
    Color? fill,
    Color? outline,
    bool elevated = false,
  });

  /// What colour the label on [surface] has to be.
  ///
  /// [otherwise] is the colour the call site would have used on its own,
  /// and is what comes back unless the skin's material overrules it -
  /// which is only ever where the material decided the background, as a
  /// blue glass button does in a light theme. So converting a call site
  /// changes nothing for a game wearing [FlatSkin], and the call site
  /// still reads as the sentence it was: this colour, unless the
  /// material says otherwise.
  Color ink(
    GameTheme t,
    SkinSurface surface, {
    SkinState state = SkinState.idle,
    bool secondary = false,
    Color? otherwise,
  });

  /// What the window's content area is painted with.
  Decoration backdrop(GameTheme t);

  /// What the sidebar is painted with. [glass] means the OS is blurring
  /// its own backdrop behind the window and the sidebar reveals it.
  Decoration sidebar(GameTheme t, {required bool glass});
}

/// [c] darkened, if it has to be, until a white label clears 3:1 on it.
///
/// A big bold button in this app is white lettering on the game's colour,
/// and that is the part worth keeping - so when the colour is too bright
/// to carry white, the colour moves rather than the lettering. The Sims
/// 4's mint measured 1.92 against white on the Install button, and this
/// is what brings it back without the label going dark.
///
/// The flat skin's version of what [PlateSkin.bearsWhite] does for the
/// hand-painted ones, and the same remedy already applied by hand to
/// three of the light accents. Bounded rather than `while` for the same
/// reason [PlateSkin.bearsLabel] is: a caller may hand over any colour,
/// and a loop that must reach black to stop is one argument away from
/// spinning.
Color bearsWhite(Color c) {
  var out = c;
  for (var i = 0; i < 16 && _ratio(Colors.white, out) < 3.2; i++) {
    out = _sink(out, .08);
  }
  return out;
}

/// A texture laid over the face of a plate: the asset, how strongly, and
/// the single colour it averages to.
///
/// The mean is carried rather than measured because nothing here can
/// decode an image and a skin is const. It is what makes the texture
/// visible to [PlateSkin.bearsLabel], which would otherwise be
/// guaranteeing the contrast of a face nobody sees - so a skin may lay
/// grain in any direction over any plate, and the label still reads.
/// theme_test.dart decodes the real asset and holds [mean] to it.
class GrainTexture {
  const GrainTexture({
    required this.asset,
    required this.mean,
    required this.opacity,
  });

  final String asset;
  final Color mean;
  final double opacity;

  DecorationImage get image => DecorationImage(
        image: AssetImage(asset),
        fit: BoxFit.cover,
        opacity: opacity,
        // A decoration has no errorBuilder to fall back to, and it needs
        // none: the plate underneath is already the right colour, and
        // [over] has costed the label's contrast against the wash either
        // way. Swallowed so a texture the antivirus is still scanning on
        // the first launch after an install is a plate without grain
        // rather than a crash report.
        onError: (_, __) {},
      );

  /// [c] with this texture over it, as far as one colour can say it.
  Color over(Color c) => Color.alphaBlend(mean.withValues(alpha: opacity), c);
}

/// WCAG contrast between two opaque colours.
double _ratio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + .05) / (math.min(la, lb) + .05);
}

/// Lighter by [amount] of the way to white.
Color _lift(Color c, double amount) => Color.lerp(c, Colors.white, amount)!;

/// Darker by [amount] of the way to black.
Color _sink(Color c, double amount) => Color.lerp(c, Colors.black, amount)!;

/// The design handoff's own chrome, unchanged: a flat fill, a hairline
/// border, a tint that comes up on hover.
class FlatSkin extends GameSkin {
  const FlatSkin();

  @override
  double radiusOf(SkinSurface surface) => switch (surface) {
        SkinSurface.panel => 13,
        SkinSurface.button => 11,
        SkinSurface.row => 11,
        SkinSurface.chip => 20,
        SkinSurface.notice => 12,
        SkinSurface.primary => 11,
        SkinSurface.well => 11,
      };

  @override
  BoxDecoration decorate(
    GameTheme t,
    SkinSurface surface, {
    SkinState state = SkinState.idle,
    double? radius,
    Color? accent,
    Color? fill,
    Color? outline,
    bool elevated = false,
  }) {
    final a = accent ?? t.accent;
    final br = BorderRadius.circular(radius ?? radiusOf(surface));
    final lift = elevated
        ? [
            BoxShadow(
              color: t.shadow.withValues(alpha: .45),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
          ]
        : const <BoxShadow>[];
    return switch (surface) {
      SkinSurface.panel => BoxDecoration(
          color: fill ?? (state == SkinState.active ? t.tint : t.surface),
          border: Border.all(
            color: outline ?? (state == SkinState.idle ? t.border : a),
            width: state == SkinState.active ? 1.5 : 1,
          ),
          borderRadius: br,
          boxShadow: lift,
        ),
      SkinSurface.button => BoxDecoration(
          color: fill ?? (state == SkinState.idle ? t.surfaceAlt : t.surface),
          border: Border.all(color: outline ?? t.border),
          borderRadius: br,
        ),
      SkinSurface.row => BoxDecoration(
          color: fill ?? (state == SkinState.idle ? null : t.tint),
          border: outline == null ? null : Border.all(color: outline, width: 1.5),
          borderRadius: br,
        ),
      SkinSurface.chip => BoxDecoration(
          // A lit chip carries a white label, so it is held to the shade
          // that can read one - the same bargain the primary makes below.
          color: fill ?? (state == SkinState.active ? bearsWhite(a) : t.surface),
          border: Border.all(
            color: outline ??
                switch (state) {
                  SkinState.active => a,
                  SkinState.idle => t.border,
                  _ => a.withValues(alpha: .5),
                },
            width: 1.5,
          ),
          borderRadius: br,
        ),
      // A tenth of the colour behind it and the colour itself around it,
      // which is what every banner in the app was written as by hand.
      SkinSurface.notice => BoxDecoration(
          color: fill ?? a.withValues(alpha: .1),
          border: Border.all(color: outline ?? a, width: 1.5),
          borderRadius: br,
        ),
      // The loud button: the game's own colour with white lettering
      // across it, held to the shade that can carry the lettering. The
      // glow underneath keeps the undarkened accent, because nothing is
      // read against a glow.
      SkinSurface.primary => BoxDecoration(
          color: fill == null ? null : bearsWhite(fill),
          gradient: fill == null
              ? LinearGradient(
                  begin: t.accentGradient.begin,
                  end: t.accentGradient.end,
                  colors: [
                    for (final stop in t.accentGradient.colors)
                      bearsWhite(stop),
                  ],
                )
              : null,
          borderRadius: br,
          boxShadow: [
            BoxShadow(
              color: a.withValues(alpha: .5),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
      SkinSurface.well => BoxDecoration(
          color: fill ?? t.surface,
          border: Border.all(
            color: outline ?? (state == SkinState.idle ? t.border : a),
            width: 1.5,
          ),
          borderRadius: br,
        ),
    };
  }

  @override
  Color ink(
    GameTheme t,
    SkinSurface surface, {
    SkinState state = SkinState.idle,
    bool secondary = false,
    Color? otherwise,
  }) {
    if (otherwise != null) return otherwise;
    // White on the two surfaces this skin fills with the accent, which is
    // what makes them read as the loud control. [decorate] is what keeps
    // that legible, by darkening the material until white sits on it.
    final onFill = surface == SkinSurface.primary ||
        (surface == SkinSurface.chip && state == SkinState.active);
    if (onFill) return Colors.white.withValues(alpha: secondary ? .55 : 1);
    return secondary ? t.muted : t.text;
  }

  @override
  Decoration backdrop(GameTheme t) => BoxDecoration(color: t.bg);

  @override
  Decoration sidebar(GameTheme t, {required bool glass}) => BoxDecoration(
        color: glass ? t.surface.withValues(alpha: .55) : t.surface,
        border: Border(right: BorderSide(color: t.border)),
      );
}

/// The shared machinery behind the hand-painted skins.
///
/// Both games this covers are built the same way and out of the same
/// vocabulary - a plate of coloured plastic, a bright rim just inside a
/// dark keyline, a recess for anything you type into - and differ only in
/// which colours those are and in how round and how heavy. So the drawing
/// lives here once and a game supplies its materials.
///
/// Those materials are spelled out per skin rather than derived from
/// [GameTheme] because they *are* the theme at this layer: a bevel needs
/// several related shades and a rim, and lerping those out of one surface
/// colour gives a pale button in a light theme, which is the one thing
/// neither of these interfaces ever is. Each skin carries a daylight set
/// and a night one; which is in force follows the theme's own background,
/// so the Settings switch still decides.
abstract class PlateSkin extends GameSkin {
  const PlateSkin();

  /// What a control is made of at rest.
  Color plate(GameTheme t);

  /// The bright ring drawn just inside [outline].
  Color rim(GameTheme t);

  /// The dark keyline drawn around everything.
  Color outline(GameTheme t);

  /// What a recess - a text field, a track - is made of.
  Color well(GameTheme t);

  /// A texture laid over the face of [surface], or null - which is the
  /// answer for every skin whose chrome is painted rather than carved.
  ///
  /// It draws over the gradient and under the border, so the plate's own
  /// colour still shows through wherever the image is translucent, and
  /// [bearsLabel] folds it in before it decides where the plate has to
  /// sit. That is the whole reason [GrainTexture] carries a mean colour:
  /// without it a texture could only be laid in the one direction that
  /// could not cost contrast, which is a limit of the code rather than of
  /// the design.
  GrainTexture? grainOf(GameTheme t, SkinSurface surface) => null;

  /// What a control that is *on* is made of.
  ///
  /// Deliberately not the theme's accent, which is the wrong end of the
  /// scale in each theme: a light accent runs darker than the resting
  /// plate, so a lit chip reads as a recessed one, and a dark accent is
  /// often bright enough to swallow a white label. This is the colour the
  /// game's own lit controls are.
  Color lit(GameTheme t);

  /// What a label on a plate is written in.
  ///
  /// White wherever the plates are dark, which is three of the four
  /// skins. The Sims Medieval answers with its own brown ink by daylight,
  /// because its buttons are parchment - the plate is the skin's material
  /// and so is the writing on it, and that is a thing no call site and no
  /// palette can work out.
  Color label(GameTheme t) => Colors.white;

  /// How wide the dark keyline is, and the bright rim inside it. The
  /// Sims 2 draws both heavier than the Sims 1 does.
  double get keyline;
  double get rimWidth;

  /// How far a raised plate sits off what it stands on. Small on purpose:
  /// these plates sit on the panel rather than floating over it, and a
  /// wide soft shadow is the single thing that reads as glass.
  double get drop;

  /// What this skin does to a radius a call site named.
  ///
  /// Those numbers exist so [FlatSkin] stays pixel-identical wherever a
  /// screen had an opinion, but for a skin whose whole identity is how
  /// round things are, honouring them defeats the point - the Sims 2
  /// interface is lozenges, and a card that keeps the design's 15 is a
  /// box. So a named radius is read as a proportion and scaled, and the
  /// skin's own [radiusOf] is used untouched when nobody named one.
  double get roundness => 1;

  bool isDark(GameTheme t) =>
      ThemeData.estimateBrightnessForColor(t.bg) == Brightness.dark;

  /// The opaque colour to build a plate out of, from what the call site
  /// asked for.
  ///
  /// A bevel is three shades of one colour, and both of the ways a flat
  /// skin says "nothing here" break that. `Colors.transparent` means the
  /// control has no background of its own - true of a flat outline
  /// button, but a raised one is made of something, so it falls back to
  /// [fallback]. And a wash like `warning.withValues(alpha: .08)` is
  /// meant to be read against the surface behind it, so it is composited
  /// there rather than having its own alpha lightened and darkened three
  /// times over whatever happens to be underneath.
  Color solid(GameTheme t, Color? fill, Color fallback) {
    if (fill == null || fill.a == 0) return fallback;
    return fill.a < 1 ? Color.alphaBlend(fill, t.surface) : fill;
  }

  /// [c] moved until [label] on it clears 3:1, away from the label.
  ///
  /// This is why a game's own lit controls sit a shade off the colour
  /// they are lit in: a bright accent cannot hold a white word, and
  /// darkening it is the only move that keeps both the colour and the
  /// word. A skin whose plates are parchment has the same problem from
  /// the other side, and gets lightened instead.
  ///
  /// What it holds to the bar is the far edge of [face] rather than the
  /// body: on a glossy finish a white label crosses the lit half, and on
  /// a matte one a dark label crosses the shaded bottom. Any [grainOf]
  /// laid over that face is composited in first, since the label ends up
  /// on top of the texture rather than on top of the gradient.
  Color bearsLabel(GameTheme t, SkinSurface surface, Color c) {
    final ink = label(t);
    final pale = ink.computeLuminance() > .5;
    final wash = grainOf(t, surface);
    var out = c;
    // Bounded rather than `while`: a caller may hand over any colour at
    // all, and a loop that has to reach black or white to stop is one
    // bad argument away from spinning.
    for (var i = 0; i < 16; i++) {
      var worst = pale ? _lift(out, faceHeadroom) : _sink(out, faceShadowroom);
      if (wash != null) worst = wash.over(worst);
      if (_ratio(ink, worst) >= 3.2) break;
      out = pale ? _sink(out, .08) : _lift(out, .08);
    }
    return out;
  }

  /// How far [face] strays from the body *under the label*, up and down.
  ///
  /// A pale label has to survive the lightest of that, a dark one the
  /// darkest, and [bearsLabel] holds whichever applies to 3:1. Matte's
  /// headroom is zero because its highlight is a line along the top edge
  /// that no word ever crosses; its shadow is the bottom stop, which one
  /// does.
  double get faceHeadroom => 0;
  double get faceShadowroom => .13;

  /// What a plate is finished in.
  ///
  /// The default is matte plastic - a short highlight along the top edge,
  /// a flat body, a little shade at the bottom - which is what the 2000
  /// and 2004 interfaces were painted out of. The first pass at the
  /// Sims 1 gave it four stops and a hard step across the middle, and
  /// that step is exactly what made it read as Aero, a mirror finish
  /// nobody was drawing then. [Sims3Skin] overrides it, because by 2009
  /// everybody was.
  ///
  /// Reversed and darkened when [pressed], which is what all three games
  /// do when a button goes down.
  LinearGradient face(Color base, {bool pressed = false, bool lit = false}) {
    final body = pressed ? _sink(base, .10) : base;
    return LinearGradient(
      begin: pressed ? Alignment.bottomCenter : Alignment.topCenter,
      end: pressed ? Alignment.topCenter : Alignment.bottomCenter,
      colors: [_lift(body, lit ? .24 : .17), body, _sink(body, .13)],
      stops: const [0, .36, 1],
    );
  }

  /// The keyline every plate wears and the seat it casts. Two shadows
  /// rather than a border, because a [Border] cannot be both and the
  /// border itself is spent on the bright rim.
  List<BoxShadow> _relief(GameTheme t,
      {required bool pressed, double? depth}) {
    final key =
        BoxShadow(color: outline(t), blurRadius: 0, spreadRadius: keyline);
    if (pressed) return [key];
    final d = depth ?? drop;
    return [
      key,
      BoxShadow(
        color: t.shadow.withValues(alpha: isDark(t) ? .5 : .22),
        blurRadius: d * 1.4,
        offset: Offset(0, d),
      ),
    ];
  }

  @override
  BoxDecoration decorate(
    GameTheme t,
    SkinSurface surface, {
    SkinState state = SkinState.idle,
    double? radius,
    Color? accent,
    Color? fill,
    Color? outline,
    bool elevated = false,
  }) {
    final a = accent ?? t.accent;
    final br = BorderRadius.circular(
        radius == null ? radiusOf(surface) : radius * roundness);
    final pressed = state == SkinState.pressed;
    final hot = state == SkinState.hovered || state == SkinState.active;
    final key = this.outline(t);

    switch (surface) {
      // Panels are the only thing here that is not pressable, so they get
      // the keyline and the seat but no highlight worth the name: a card
      // lit like a button reads as one, and every mod in the grid would
      // look clickable.
      case SkinSurface.panel:
        final base =
            solid(t, fill, state == SkinState.active ? t.tint : t.surface);
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_lift(base, isDark(t) ? .06 : 0), base],
          ),
          border: Border.all(
            color: outline ??
                (state == SkinState.idle ? rim(t).withValues(alpha: .75) : a),
            width: rimWidth,
          ),
          borderRadius: br,
          boxShadow: [
            BoxShadow(
              color: key.withValues(alpha: isDark(t) ? 1 : .35),
              blurRadius: 0,
              spreadRadius: keyline,
            ),
            if (elevated)
              BoxShadow(
                color: t.shadow.withValues(alpha: .5),
                blurRadius: 26,
                offset: const Offset(0, 14),
              )
            else
              BoxShadow(
                color: t.shadow.withValues(alpha: isDark(t) ? .4 : .13),
                blurRadius: drop * 2,
                offset: Offset(0, drop),
              ),
          ],
        );

      case SkinSurface.button:
        final base = bearsLabel(t, surface,
            accent ?? (state == SkinState.active ? lit(t) : plate(t)));
        return BoxDecoration(
          gradient: face(base, pressed: pressed, lit: hot),
          image: grainOf(t, surface)?.image,
          border: Border.all(color: outline ?? rim(t), width: rimWidth),
          borderRadius: br,
          boxShadow: _relief(t, pressed: pressed),
        );

      // A row is a button that only materialises once you are on it -
      // off, it is a hairline of nothing, which is what keeps a sidebar
      // of five games from reading as five buttons in a stack. Unlike a
      // button it does take a fill, because the places that hand it one
      // are saying what the row *is* (a mod switched off, the folder view
      // in force) rather than which tint to wear.
      //
      // A row that is on takes [lit] outright rather than a blend toward
      // the theme's accent: mixing two hues muddies both, and periwinkle
      // stirred into plumbob green came out olive. And a fill lighter
      // than the plate is a surface colour rather than a material - the
      // view toggle hands over `t.surface` to mean "raised out of the
      // track" rather than to name a colour, and the panel's own colour
      // is the one thing a plate is never made of - so a fill that *is*
      // the surface is read as "on" too.
      case SkinSurface.row:
        if (state == SkinState.idle) return BoxDecoration(borderRadius: br);
        final asked = solid(
            t, fill, state == SkinState.active ? lit(t) : plate(t));
        final base = bearsLabel(t, surface, asked == t.surface ? lit(t) : asked);
        return BoxDecoration(
          gradient: face(base, pressed: pressed, lit: hot),
          image: grainOf(t, surface)?.image,
          border: Border.all(color: outline ?? rim(t), width: rimWidth),
          borderRadius: br,
          boxShadow: _relief(t, pressed: pressed),
        );

      // A caller that named its own colour keeps it - a warning chip is
      // orange in any theme - and everything else lights up in [lit].
      case SkinSurface.chip:
        final on = accent ?? lit(t);
        final base = bearsLabel(t, surface, state == SkinState.active ? on : plate(t));
        return BoxDecoration(
          gradient: face(base, pressed: pressed, lit: hot),
          image: grainOf(t, surface)?.image,
          border: Border.all(
            color: outline ??
                (state == SkinState.active ? _lift(on, .5) : rim(t)),
            width: rimWidth,
          ),
          borderRadius: br,
          boxShadow: _relief(t, pressed: pressed, depth: drop * .8),
        );

      // Opaque rather than a tenth of the colour laid over the window:
      // the backdrop here is a gradient, and a wash that thin over it came
      // out a different strength at the top of the screen than at the
      // bottom.
      case SkinSurface.notice:
        final base = solid(
            t,
            fill,
            Color.alphaBlend(
                a.withValues(alpha: isDark(t) ? .22 : .13), t.surface));
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_sink(base, .08), base],
          ),
          border: Border.all(color: outline ?? a, width: rimWidth),
          borderRadius: br,
          boxShadow: [
            BoxShadow(
              color: key.withValues(alpha: isDark(t) ? 1 : .3),
              blurRadius: 0,
              spreadRadius: keyline,
            ),
            BoxShadow(
              color: t.shadow.withValues(alpha: isDark(t) ? .35 : .12),
              blurRadius: drop * 2,
              offset: Offset(0, drop),
            ),
          ],
        );

      // The loud one, and loud from its colour rather than from a bloom:
      // the glow this used to cast was the other half of the Aero look.
      case SkinSurface.primary:
        final base = bearsLabel(t, surface, accent ?? lit(t));
        return BoxDecoration(
          gradient: face(base, pressed: pressed, lit: hot),
          image: grainOf(t, surface)?.image,
          border:
              Border.all(color: outline ?? _lift(base, .45), width: rimWidth),
          borderRadius: br,
          boxShadow: _relief(t, pressed: pressed, depth: drop * 1.4),
        );

      // Sunk rather than raised: the shade runs from the top down instead
      // of the highlight, and the light rim sits under the bottom edge,
      // where a recess catches it.
      case SkinSurface.well:
        final base = solid(t, fill, well(t));
        return BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_sink(base, .18), base, _lift(base, .05)],
            stops: const [0, .5, 1],
          ),
          border: Border.all(
            color: outline ?? (state == SkinState.idle ? key : a),
            width: rimWidth,
          ),
          borderRadius: br,
          boxShadow: [
            BoxShadow(
              color: rim(t).withValues(alpha: .32),
              blurRadius: 0,
              spreadRadius: keyline * .7,
              offset: const Offset(0, 1),
            ),
          ],
        );
    }
  }

  @override
  Color ink(
    GameTheme t,
    SkinSurface surface, {
    SkinState state = SkinState.idle,
    bool secondary = false,
    Color? otherwise,
  }) {
    // Anything raised is a coloured plate in both themes, so its label is
    // white in both - this is the answer a call site could not have worked
    // out from the palette, and the reason [ink] takes an [otherwise]
    // rather than being one.
    final onPlate = switch (surface) {
      SkinSurface.button || SkinSurface.chip || SkinSurface.primary => true,
      SkinSurface.row => state != SkinState.idle,
      _ => false,
    };
    if (onPlate) {
      return label(t).withValues(alpha: secondary ? .72 : 1);
    }
    return otherwise ?? (secondary ? t.muted : t.text);
  }

  @override
  Decoration backdrop(GameTheme t) => BoxDecoration(
        // The falloff both games' outdoor screens have: light near the top
        // of the window, deepening into the corners.
        gradient: RadialGradient(
          center: const Alignment(0, -.75),
          radius: 1.5,
          colors: [_lift(t.bg, isDark(t) ? .10 : .55), t.bg],
        ),
      );

  @override
  Decoration sidebar(GameTheme t, {required bool glass}) {
    final base = isDark(t) ? t.surfaceAlt : t.surface;
    // The blur behind the window shows through the gradient rather than
    // instead of it, so the panel keeps its shape either way.
    final alpha = glass ? .62 : 1.0;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _lift(base, isDark(t) ? .05 : 0).withValues(alpha: alpha),
          _sink(base, isDark(t) ? .12 : .04).withValues(alpha: alpha),
        ],
      ),
      border: Border(right: BorderSide(color: outline(t), width: 1.5)),
    );
  }
}

/// The Sims 1's own interface: matte blue plates with a bright rim inside
/// a hard dark keyline, sunk recesses, and behind it all the deep blue the
/// neighbourhood screen fades out to.
///
/// Tighter and darker than [Sims2Skin] - a thin keyline, a shallow seat,
/// squarer corners - which is the difference between the two interfaces:
/// the Sims 1 is chiselled, the Sims 2 is moulded.
class Sims1Skin extends PlateSkin {
  const Sims1Skin();

  static const _lightPlate = Color(0xFF3F79CE);
  static const _lightRim = Color(0xFFAFD1F5);
  static const _lightOutline = Color(0xFF163E7C);
  static const _lightWell = Color(0xFFDCE7F8);

  static const _darkPlate = Color(0xFF2A5DA8);
  static const _darkRim = Color(0xFF7FB6EE);
  static const _darkOutline = Color(0xFF04102A);
  static const _darkWell = Color(0xFF0A1F47);

  @override
  Color plate(GameTheme t) => isDark(t) ? _darkPlate : _lightPlate;
  @override
  Color rim(GameTheme t) => isDark(t) ? _darkRim : _lightRim;
  @override
  Color outline(GameTheme t) => isDark(t) ? _darkOutline : _lightOutline;
  @override
  Color well(GameTheme t) => isDark(t) ? _darkWell : _lightWell;

  /// The blue the game lights a control up in, a shade off its own cyan.
  @override
  Color lit(GameTheme t) => const Color(0xFF2E9BD8);

  @override
  double get keyline => .8;
  @override
  double get rimWidth => 1.3;
  @override
  double get drop => 1.5;

  @override
  double radiusOf(SkinSurface surface) => switch (surface) {
        SkinSurface.panel => 14,
        SkinSurface.button => 12,
        SkinSurface.row => 12,
        SkinSurface.chip => 999,
        SkinSurface.notice => 12,
        SkinSurface.primary => 14,
        SkinSurface.well => 12,
      };
}

/// The Sims 2's: periwinkle plates, every one of them ringed twice - a
/// heavy dark keyline with a pale rim just inside it - and rounded far
/// enough that most of the interface reads as lozenges rather than as
/// boxes. Its "on" colour is the plumbob green the game fills a want, a
/// motive bar and a needs meter with.
///
/// Read off the game rather than out of a spec: nothing authoritative is
/// published, and what the modding scene ships are recolours rather than
/// documented values.
class Sims2Skin extends PlateSkin {
  const Sims2Skin();

  static const _lightPlate = Color(0xFF7382D6);
  static const _lightRim = Color(0xFFC7CDF2);
  static const _lightOutline = Color(0xFF232A66);
  static const _lightWell = Color(0xFFD2D8F2);

  static const _darkPlate = Color(0xFF4E5AA8);
  static const _darkRim = Color(0xFF97A2E0);
  // Nearly black on purpose: the indigo this stands on is dark already,
  // and a keyline a shade off it is a keyline nobody can see.
  static const _darkOutline = Color(0xFF05061A);
  static const _darkWell = Color(0xFF1B2047);

  @override
  Color plate(GameTheme t) => isDark(t) ? _darkPlate : _lightPlate;
  @override
  Color rim(GameTheme t) => isDark(t) ? _darkRim : _lightRim;
  @override
  Color outline(GameTheme t) => isDark(t) ? _darkOutline : _lightOutline;
  @override
  Color well(GameTheme t) => isDark(t) ? _darkWell : _lightWell;

  @override
  Color lit(GameTheme t) => const Color(0xFF56A83A);

  @override
  double get keyline => 1.6;
  @override
  double get rimWidth => 1.6;
  @override
  double get drop => 2;
  @override
  double get roundness => 1.3;

  @override
  double radiusOf(SkinSurface surface) => switch (surface) {
        SkinSurface.panel => 18,
        SkinSurface.button => 14,
        SkinSurface.row => 14,
        SkinSurface.chip => 999,
        SkinSurface.notice => 16,
        SkinSurface.primary => 16,
        SkinSurface.well => 14,
      };
}

/// The Sims 3's, and the one that really is Aero: glass rather than
/// plastic, a bright sweep across the top half with a crisp step at the
/// midline, near-white rims, and a lighter, more cyan blue than either of
/// the two before it. Its plates sit on pale panels the way the game's
/// saturated round buttons sit on its pale dialogs.
///
/// This is the finish the Sims 1 skin wore by mistake on its first pass.
/// Here it is the point: by 2009 every interface on Windows had a mirror
/// on it, and the game's own is one of the glossiest of them.
class Sims3Skin extends PlateSkin {
  const Sims3Skin();

  static const _lightPlate = Color(0xFF3E88C0);
  static const _lightRim = Color(0xFFE8F4FD);
  static const _lightOutline = Color(0xFF1B4E76);
  static const _lightWell = Color(0xFFE0EEF8);

  static const _darkPlate = Color(0xFF2A6B99);
  static const _darkRim = Color(0xFFA8D8F2);
  static const _darkOutline = Color(0xFF04141F);
  static const _darkWell = Color(0xFF0B2331);

  /// How far the sweep lifts the lit half. Named because [faceHeadroom]
  /// has to be the same number: that half is what a label crosses, so it
  /// is what [PlateSkin.bearsWhite] has to hold to 3:1 rather than the
  /// body underneath it.
  static const _sweep = .26;

  @override
  Color plate(GameTheme t) => isDark(t) ? _darkPlate : _lightPlate;
  @override
  Color rim(GameTheme t) => isDark(t) ? _darkRim : _lightRim;
  @override
  Color outline(GameTheme t) => isDark(t) ? _darkOutline : _lightOutline;
  @override
  Color well(GameTheme t) => isDark(t) ? _darkWell : _lightWell;

  @override
  Color lit(GameTheme t) => const Color(0xFF29A9D8);

  @override
  double get keyline => 1;
  @override
  double get rimWidth => 1.5;
  @override
  double get drop => 2.5;
  @override
  double get roundness => 1.15;

  @override
  double get faceHeadroom => _sweep;
  @override
  double get faceShadowroom => .16;

  @override
  LinearGradient face(Color base, {bool pressed = false, bool lit = false}) {
    final body = pressed ? _sink(base, .12) : base;
    return LinearGradient(
      begin: pressed ? Alignment.bottomCenter : Alignment.topCenter,
      end: pressed ? Alignment.topCenter : Alignment.bottomCenter,
      colors: [
        _lift(body, lit ? .48 : .40),
        _lift(body, lit ? _sweep : .20),
        body,
        _sink(body, .16),
      ],
      stops: const [0, .46, .54, 1],
    );
  }

  @override
  double radiusOf(SkinSurface surface) => switch (surface) {
        SkinSurface.panel => 16,
        SkinSurface.button => 13,
        SkinSurface.row => 13,
        SkinSurface.chip => 999,
        SkinSurface.notice => 14,
        SkinSurface.primary => 15,
        SkinSurface.well => 13,
      };
}

/// The Sims Medieval's, and the odd one out in every way that matters.
///
/// The other three interfaces are one material in a few shades. This one
/// is **two**, and which you get depends on the theme rather than on the
/// role: by daylight it is the ambition book and the build catalog -
/// parchment plates, brown ink, a thin brass line inside a dark brown
/// keyline - and at night it is the live HUD, the same chrome carved out
/// of dark wood with cream lettering and brass fittings. Both are in the
/// game, a screen apart, so neither is a compromise.
///
/// That is what forced [PlateSkin.label] and the two-directional
/// [PlateSkin.bearsLabel]: three skins could assume a raised control was
/// dark and took white, and a parchment button is the same problem read
/// from the other end. It is also the only skin that lays a [GrainTexture]
/// - real wood over both materials, harder over the carved one. Otherwise
/// nothing here needed a new idea: the rim just happens to be brass rather
/// than pale, and the lit colour is the amber the game highlights a row of
/// a menu in.
class SimsMedievalSkin extends PlateSkin {
  const SimsMedievalSkin();

  // Parchment, with the brass line and the brown keyline off the book's
  // own borders.
  static const _lightPlate = Color(0xFFE0CFA3);
  static const _lightRim = Color(0xFFB08A3E);
  static const _lightOutline = Color(0xFF5E4526);
  static const _lightWell = Color(0xFFCFBC8E);
  static const _lightLit = Color(0xFFD9AE52);
  static const _lightLabel = Color(0xFF3B2A17);

  // The same panel carved instead of printed.
  static const _darkPlate = Color(0xFF3E3320);
  static const _darkRim = Color(0xFF9A7C36);
  static const _darkOutline = Color(0xFF0C0904);
  static const _darkWell = Color(0xFF14100A);
  static const _darkLit = Color(0xFF6B5225);
  static const _darkLabel = Color(0xFFF3E9D2);

  @override
  Color plate(GameTheme t) => isDark(t) ? _darkPlate : _lightPlate;
  @override
  Color rim(GameTheme t) => isDark(t) ? _darkRim : _lightRim;
  @override
  Color outline(GameTheme t) => isDark(t) ? _darkOutline : _lightOutline;
  @override
  Color well(GameTheme t) => isDark(t) ? _darkWell : _lightWell;

  @override
  Color lit(GameTheme t) => isDark(t) ? _darkLit : _lightLit;

  @override
  Color label(GameTheme t) => isDark(t) ? _darkLabel : _lightLabel;

  /// What the wood photograph averages to. Hardcoded because a skin is
  /// const and nothing here decodes an image; theme_test.dart measures
  /// the real file and fails if the two drift apart.
  static const _grainMean = Color(0xFF3B2315);

  /// The one place in the app that draws a photograph: real grain over
  /// the plates, because the game's frames are wood and three shades of
  /// brown cannot say so on their own.
  ///
  /// **Both themes, at different strengths.** The carved plates take it
  /// full; the parchment ones take about two thirds, because at the
  /// strength that suits timber a page stops reading as a page. Contrast
  /// is not what decides that - [PlateSkin.bearsLabel] composites this in
  /// and moves the plate to suit, so brown ink on washed parchment is
  /// held to the same bar as cream on wood.
  ///
  /// Chips are left out because at the height of a pill the grain is
  /// mush, and panels because they are the field the frames go around.
  @override
  GrainTexture? grainOf(GameTheme t, SkinSurface surface) => switch (surface) {
        SkinSurface.button || SkinSurface.row || SkinSurface.primary =>
          GrainTexture(
            asset: 'assets/dark_wood_bg.jpg',
            mean: _grainMean,
            opacity: isDark(t) ? .3 : .2,
          ),
        _ => null,
      };

  /// Heavy on both counts: every frame in this game is a carved edge with
  /// a brass line inside it, and a hairline would read as neither.
  @override
  double get keyline => 1.6;
  @override
  double get rimWidth => 1.6;
  @override
  double get drop => 2;
  @override
  double get roundness => 1.1;

  @override
  double radiusOf(SkinSurface surface) => switch (surface) {
        SkinSurface.panel => 16,
        SkinSurface.button => 12,
        SkinSurface.row => 12,
        SkinSurface.chip => 999,
        SkinSurface.notice => 14,
        SkinSurface.primary => 14,
        SkinSurface.well => 12,
      };
}
