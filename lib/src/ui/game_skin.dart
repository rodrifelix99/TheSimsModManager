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

  /// SimCity 3000's: milled steel, squared off inside a charcoal keyline.
  static const simCity3000 = SimCity3000Skin();

  /// SimCity 4's: the same console cast in teal, rounded off and wet.
  static const simCity4 = SimCity4Skin();

  /// SimCity (2013)'s: pale silver pills on near-white panels, and the
  /// only skin here that writes in anything but white.
  static const simCity2013 = SimCity2013Skin();

  static GameSkin forGameId(String id) => switch (id) {
        'sims1' => sims1,
        'sims2' => sims2,
        'sims3' => sims3,
        'simsmedieval' => simsMedieval,
        'simcity3000' => simCity3000,
        'simcity4' => simCity4,
        'simcity2013' => simCity2013,
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
  ///
  /// [accent] and [fill] are the same ones handed to [decorate], and are
  /// needed for the same reason the decoration needs them: on a skin
  /// whose material decides the lettering, what a plate is made of has to
  /// be worked out before it can be written on. A call site that gives
  /// [decorate] neither may leave both off here too.
  Color ink(
    GameTheme t,
    SkinSurface surface, {
    SkinState state = SkinState.idle,
    bool secondary = false,
    Color? otherwise,
    Color? accent,
    Color? fill,
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
    Color? accent,
    Color? fill,
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

  /// The steel an *idle, uncoloured* panel is framed in, or null to
  /// frame it in [rim] like every other plate.
  ///
  /// The rim is the bright line inside a button's keyline, and on a skin
  /// whose rim is near-white a panel drawn in it has no frame at all by
  /// daylight - a pale card on a pale backdrop. Both SimCity consoles
  /// draw framed windows, so both answer this; everything else about the
  /// panel (the keyline, the seat, the lift on hover) is unchanged, and a
  /// call site that named an outline or lit the card still gets what it
  /// asked for.
  Color? panelFrame(GameTheme t) => null;

  /// What a label on [plate] is written in.
  ///
  /// White wherever the plates are dark, which is most of these skins.
  /// The Sims Medieval answers with its own brown ink by daylight,
  /// because its buttons are parchment - the plate is the skin's material
  /// and so is the writing on it, and that is a thing no call site and no
  /// palette can work out.
  ///
  /// It takes the plate because for one skin the answer is not a constant
  /// per theme at all. SimCity 2013 builds a resting control and a lit
  /// one out of *different materials* - a pale silver pill with dark grey
  /// lettering until it is the one you are on, when it fills with the
  /// game's blue and takes white - and no single ink serves both. Every
  /// other skin ignores the argument, which is why it is handed over
  /// rather than asked for.
  ///
  /// Whatever a skin answers has to be stable under [bearsLabel], which
  /// moves the plate *away* from the ink it was given: an answer that
  /// flipped as the plate moved would never settle. Reading the plate's
  /// own luminance is safe for exactly that reason - moving away from a
  /// colour cannot cross the threshold that picked it.
  Color label(GameTheme t, Color plate) => Colors.white;

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

  /// Is [surface] a raised plate - something built out of the skin's own
  /// material with a word across it - rather than a surface a call site
  /// coloured itself? A row only once it has materialised.
  bool raised(SkinSurface surface, SkinState state) => switch (surface) {
        SkinSurface.button || SkinSurface.chip || SkinSurface.primary => true,
        SkinSurface.row => state != SkinState.idle,
        _ => false,
      };

  /// What a raised [surface] is made of, before [bearsLabel] moves it.
  ///
  /// Split out of [decorate] so [ink] can ask the same question and get
  /// the same answer. The two could not disagree while [ink] was a
  /// constant; now that a skin may write differently on a pale plate and
  /// a dark one, a second copy of this reasoning would be a bug waiting
  /// to happen.
  Color raisedBase(
    GameTheme t,
    SkinSurface surface, {
    SkinState state = SkinState.idle,
    Color? accent,
    Color? fill,
  }) {
    final on = state == SkinState.active;
    if (surface == SkinSurface.primary) return accent ?? lit(t);
    // A chip's accent is the colour it lights up *in*, so an idle one
    // is the plain plate however loud a colour the call site named. That
    // asymmetry is the chip's own and predates this method; spelling it
    // out here rather than letting the general case below cover it is
    // what keeps splitting this out a refactor.
    if (surface == SkinSurface.chip) return on ? (accent ?? lit(t)) : plate(t);
    if (surface == SkinSurface.row) {
      final asked = solid(t, fill, on ? lit(t) : plate(t));
      return asked == t.surface ? lit(t) : asked;
    }
    return accent ?? (on ? lit(t) : plate(t));
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
    final ink = label(t, c);
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
                (state == SkinState.idle
                    ? (panelFrame(t) ?? rim(t).withValues(alpha: .75))
                    : a),
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
        final base = bearsLabel(
            t, surface, raisedBase(t, surface, state: state, accent: accent));
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
        final base = bearsLabel(t, surface,
            raisedBase(t, surface, state: state, accent: accent, fill: fill));
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
        final base = bearsLabel(
            t, surface, raisedBase(t, surface, state: state, accent: accent));
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
        final base = bearsLabel(
            t, surface, raisedBase(t, surface, state: state, accent: accent));
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
    Color? accent,
    Color? fill,
  }) {
    // Anything raised is a plate of the skin's own material, so what goes
    // on it is the skin's answer rather than the call site's - which is
    // the reason [ink] takes an [otherwise] rather than being one. The
    // plate has to be built before it can be written on, because for one
    // skin the lettering follows the material: an Ignore button made of
    // the warning orange takes a different word than the pale one beside
    // it.
    if (raised(surface, state)) {
      final base = bearsLabel(t, surface,
          raisedBase(t, surface, state: state, accent: accent, fill: fill));
      return label(t, base).withValues(alpha: secondary ? .72 : 1);
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
  Color label(GameTheme t, Color plate) =>
      isDark(t) ? _darkLabel : _lightLabel;

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

/// SimCity 3000's, and the first skin here drawn from outside The Sims:
/// a control console rather than a home. Steel plates squared off inside
/// a hard charcoal keyline, a bright machined line along the top edge and
/// a crease across the middle, seated flush on the panel rather than
/// floating over it.
///
/// The three Sims skins are all rounded, and rounding is the first thing
/// that has to go: SC3K's toolbars, dialogs and data windows are
/// rectangles with a chiselled edge, which is why [roundness] takes a
/// named radius down to a quarter of itself and every [radiusOf] here is
/// a few pixels rather than a dozen. The rest is the same vocabulary the
/// other plates are built from - it just happens to be milled steel.
///
/// The safety yellow, the vivid red and the saturated green the game
/// reads its data out in live in the palette rather than here: those are
/// what a number is drawn in, and nothing in this app is a demand meter.
/// A control that is *on* lights in the game's own selection blue.
class SimCity3000Skin extends PlateSkin {
  const SimCity3000Skin();

  // Daylight: the dialogs, which are pale steel with a mid-blue bar.
  static const _lightPlate = Color(0xFF5E7B9C);
  static const _lightRim = Color(0xFFD3E0EE);
  static const _lightOutline = Color(0xFF1B2833);
  static const _lightWell = Color(0xFFCBD5E4);

  // Night: the toolbar and the status strip, which are near-black steel.
  static const _darkPlate = Color(0xFF3C4E61);
  static const _darkRim = Color(0xFF8FA6BC);
  static const _darkOutline = Color(0xFF04080C);
  static const _darkWell = Color(0xFF0B1219);

  @override
  Color plate(GameTheme t) => isDark(t) ? _darkPlate : _lightPlate;
  @override
  Color rim(GameTheme t) => isDark(t) ? _darkRim : _lightRim;
  @override
  Color outline(GameTheme t) => isDark(t) ? _darkOutline : _lightOutline;
  @override
  Color well(GameTheme t) => isDark(t) ? _darkWell : _lightWell;

  /// The blue the game lights a chosen tool in - saturated, where the
  /// plates around it are deliberately not.
  @override
  Color lit(GameTheme t) => const Color(0xFF1C7FB0);

  /// A heavy keyline with a thin bright line inside it: the bevel here is
  /// cut rather than moulded, so the dark side of it carries the weight.
  @override
  double get keyline => 1.4;
  @override
  double get rimWidth => 1.2;

  /// Almost flush. A console's buttons sit in the panel; the seat is
  /// there to be seen at the bottom edge and nowhere else.
  @override
  double get drop => 1.2;

  /// Square, and that is the point - see the class comment.
  @override
  double get roundness => .25;

  @override
  double get faceHeadroom => .14;
  @override
  double get faceShadowroom => .2;

  /// Milled steel: a hard highlight along the top edge, a long even body,
  /// a crease at the midline and a darker skirt under it. The crease is
  /// what makes a row of these read as one bar of metal rather than as a
  /// row of pills, and it is the one thing the matte finish upstairs
  /// cannot say.
  ///
  /// Only the top highlight brightens under the pointer, because that is
  /// where a specular lives and because [faceHeadroom] has to hold for
  /// every state - the stop a label actually crosses may not move.
  @override
  LinearGradient face(Color base, {bool pressed = false, bool lit = false}) {
    final body = pressed ? _sink(base, .12) : base;
    return LinearGradient(
      begin: pressed ? Alignment.bottomCenter : Alignment.topCenter,
      end: pressed ? Alignment.topCenter : Alignment.bottomCenter,
      colors: [
        _lift(body, lit ? .42 : .3),
        _lift(body, .14),
        body,
        _sink(body, .09),
        _sink(body, .2),
      ],
      stops: const [0, .14, .5, .54, 1],
    );
  }

  /// The steel a window is framed in, which is [rim] everywhere else and
  /// cannot be here: this skin's rim is the near-white line inside a
  /// button's keyline, and a panel drawn in it has no frame at all by
  /// daylight - a pale card on a pale backdrop. The game's windows are
  /// framed, so they are framed. After dark the rim is already dim
  /// enough to frame one, so that case answers null and takes the plate
  /// skin's own.
  static const _lightFrame = Color(0xFF93A6BC);

  @override
  Color? panelFrame(GameTheme t) => isDark(t) ? null : _lightFrame;

  /// Flat steel rather than the Sims' outdoor falloff: light along the
  /// top, dark at the bottom. The other skins' radial gradient is a sky,
  /// and this game's backdrop is the console the sky is looked at from.
  @override
  Decoration backdrop(GameTheme t) => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _lift(t.bg, isDark(t) ? .07 : .3),
            t.bg,
            _sink(t.bg, isDark(t) ? .25 : .07),
          ],
          stops: const [0, .55, 1],
        ),
      );

  @override
  double radiusOf(SkinSurface surface) => switch (surface) {
        SkinSurface.panel => 4,
        SkinSurface.button => 3,
        SkinSurface.row => 3,
        SkinSurface.chip => 3,
        SkinSurface.notice => 4,
        SkinSurface.primary => 3,
        SkinSurface.well => 2,
      };
}

/// SimCity 4's, and the sibling that had to be told apart from the one
/// above rather than merely added beside it.
///
/// Four years separate the two consoles and every difference between
/// them runs the same way: 3000 is milled steel, squared off and matte,
/// read out in safety yellow; 4 is the same console cast in the teal its
/// HUD is made of, rounded off, and wet. So this skin keeps [PlateSkin]'s
/// whole vocabulary and moves the three things that carry a game -
/// [roundness] from a quarter back up to nearly whole, the material from
/// steel blue to teal, and [face] from a crease to a specular.
///
/// The amber lives in the palette rather than here, like 3000's yellow:
/// it is what a *number* is drawn in, and nothing in this app is a
/// budget line.
class SimCity4Skin extends PlateSkin {
  const SimCity4Skin();

  // Daylight: the budget and query windows, pale steel pulled toward the
  // teal, framed in a blue-gray the pale rim could never draw.
  static const _lightPlate = Color(0xFF4C7F84);
  static const _lightRim = Color(0xFFCFE4E4);
  static const _lightOutline = Color(0xFF16262A);
  static const _lightWell = Color(0xFFC7D6D8);
  static const _lightFrame = Color(0xFF89A3A6);

  // Night: the HUD along the bottom of the map, which is where this
  // game's chrome actually lives.
  static const _darkPlate = Color(0xFF2E4A4E);
  static const _darkRim = Color(0xFF86A8AC);
  static const _darkOutline = Color(0xFF03080A);
  static const _darkWell = Color(0xFF0A1416);

  /// The navy the backdrop runs into at the bottom. A hue rather than a
  /// shade, because "steel blue down to navy" is a turn the pure
  /// lightness ramp 3000's console uses cannot make.
  static const _navy = Color(0xFF0C1A2E);

  /// How far the specular lifts the half a label crosses. Named because
  /// [faceHeadroom] has to be the same number - see [Sims3Skin].
  static const _sheen = .22;

  @override
  Color plate(GameTheme t) => isDark(t) ? _darkPlate : _lightPlate;
  @override
  Color rim(GameTheme t) => isDark(t) ? _darkRim : _lightRim;
  @override
  Color outline(GameTheme t) => isDark(t) ? _darkOutline : _lightOutline;
  @override
  Color well(GameTheme t) => isDark(t) ? _darkWell : _lightWell;

  @override
  Color? panelFrame(GameTheme t) => isDark(t) ? null : _lightFrame;

  /// The muted teal an active tool is marked in - the game's own, and
  /// deliberately not the saturated blue 3000 picks one out with.
  @override
  Color lit(GameTheme t) => const Color(0xFF1B8C88);

  /// A moulded edge rather than 3000's cut one, so the bright side of it
  /// carries more of the weight and the dark keyline less.
  @override
  double get keyline => 1.2;
  @override
  double get rimWidth => 1.3;

  /// Proud of the panel rather than flush in it. 3000's controls sit in
  /// the console; these sit on it, and catch light on the way round.
  @override
  double get drop => 2.2;

  /// Rounded, which is the loudest single thing between the two consoles
  /// and the reason [roundness] exists at all: 3000 takes a named radius
  /// to a quarter, and this takes it very nearly whole.
  @override
  double get roundness => .85;

  @override
  double get faceHeadroom => _sheen;
  @override
  double get faceShadowroom => .17;

  /// Wet metal: a broad specular across the top third falling off
  /// smoothly into the body, a shaded skirt, and a lip of bounce light
  /// along the very bottom edge - which is what a rounded metal face
  /// does and what a flat milled one cannot. No crease: that is 3000's,
  /// and it is what makes a row of its controls read as one bar.
  ///
  /// The bounce is the last stop only, so it never reaches the darkest
  /// point a dark label has to survive - [faceShadowroom] tracks the
  /// skirt above it rather than the lip.
  @override
  LinearGradient face(Color base, {bool pressed = false, bool lit = false}) {
    final body = pressed ? _sink(base, .11) : base;
    return LinearGradient(
      begin: pressed ? Alignment.bottomCenter : Alignment.topCenter,
      end: pressed ? Alignment.topCenter : Alignment.bottomCenter,
      colors: [
        _lift(body, lit ? .46 : .38),
        _lift(body, lit ? _sheen : .12),
        body,
        _sink(body, .17),
        _sink(body, .09),
      ],
      stops: const [0, .3, .62, .9, 1],
    );
  }

  /// Lighter steel blue at the top edge, deepening into navy at the
  /// bottom. 3000's backdrop is the same shape and a pure lightness ramp;
  /// this one turns as it darkens, which is the difference between a
  /// sheet of steel and the sky the map sits under.
  @override
  Decoration backdrop(GameTheme t) => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _lift(t.bg, isDark(t) ? .09 : .34),
            t.bg,
            Color.lerp(_sink(t.bg, isDark(t) ? .22 : .06), _navy,
                isDark(t) ? .3 : .16)!,
          ],
          stops: const [0, .5, 1],
        ),
      );

  @override
  double radiusOf(SkinSurface surface) => switch (surface) {
        SkinSurface.panel => 12,
        SkinSurface.button => 9,
        SkinSurface.row => 9,
        // The HUD's own buttons are circles. A pill is as close as this
        // vocabulary gets, but a full one is the Sims 3's, so this stops
        // short of it - rounded hard, still legibly a rectangle.
        SkinSurface.chip => 20,
        SkinSurface.notice => 11,
        SkinSurface.primary => 10,
        SkinSurface.well => 8,
      };
}

/// SimCity (2013)'s, and the one skin here whose controls are *pale*.
///
/// The other five hand-painted skins are dark materials with white
/// lettering, and reaching for that here would have been wrong twice
/// over. This interface is white and silver: panels are near-white with
/// a thin grey border and a blue heading, the ordinary button is a pale
/// pill with dark grey lettering (the style guide names it: R74,G83,B90),
/// and the game's blue turns up only on the *selected* thing - a tab you
/// are on, a toggle that is pressed - where it fills the pill and takes
/// white.
///
/// The deep navy and the neon glow that the game is popularly pictured
/// in are its loading screens and its data-layer overlays, not its
/// chrome. A skin imitates the chrome.
///
/// So the three moves that carry it, beside two SimCity consoles that
/// are both dark metal:
///
///  - **Pale plates**, which needed [PlateSkin.label] to take the plate
///    it sits on. One ink per theme could not express a skin whose
///    resting control and lit control are different materials, and
///    picking blue-for-everything to get around that is exactly the
///    mistake this comment exists to stop being repeated.
///  - **A grey keyline instead of a dark one.** 3000 and 4 are carved -
///    a near-black line with a bright rim inside it. This is a drawn
///    interface: one hairline of grey, one of white inside it, nothing
///    chiselled anywhere.
///  - **Almost no relief.** A soft, small drop shadow and a gradient you
///    have to look for. The 2013 interface is flat where the 2003 one is
///    wet, which is ten years of interface fashion in one number.
///
/// The orange lives in the palette, like 3000's yellow and 4's amber. So
/// does the green: the style guide gives a positive and a warning colour
/// for *text*, and nothing in this app is a city alert.
class SimCity2013Skin extends PlateSkin {
  const SimCity2013Skin();

  // Daylight, which is the game: near-white panels, pale silver pills,
  // one thin grey line around everything.
  static const _lightPlate = Color(0xFFE9EEF4);
  static const _lightRim = Color(0xFFFFFFFF);
  static const _lightOutline = Color(0xFFA9B7C4);
  static const _lightWell = Color(0xFFFFFFFF);
  static const _lightFrame = Color(0xFFC6D0DA);

  /// The grey the style guide writes a button's label in, R74,G83,B90.
  static const _lightInk = Color(0xFF4A535A);

  // After dark. This game shipped no dark interface at all, so unlike
  // every other palette here the dark one is the invention and the light
  // one is the faithful half - the same console with the lights off,
  // which is the Sims bargain exactly backwards.
  static const _darkPlate = Color(0xFF333E48);
  static const _darkRim = Color(0xFF56636F);
  static const _darkOutline = Color(0xFF0A1015);
  static const _darkWell = Color(0xFF141B21);

  /// The blue a selected tab fills with, and the one place white
  /// lettering turns up in daylight.
  static const _lit = Color(0xFF2A93D4);

  /// How far [face] lifts the top of a lit plate. Named because
  /// [faceHeadroom] has to be the same number - see [Sims3Skin].
  static const _gloss = .18;

  @override
  Color plate(GameTheme t) => isDark(t) ? _darkPlate : _lightPlate;
  @override
  Color rim(GameTheme t) => isDark(t) ? _darkRim : _lightRim;
  @override
  Color outline(GameTheme t) => isDark(t) ? _darkOutline : _lightOutline;
  @override
  Color well(GameTheme t) => isDark(t) ? _darkWell : _lightWell;

  @override
  Color? panelFrame(GameTheme t) => isDark(t) ? null : _lightFrame;

  @override
  Color lit(GameTheme t) => _lit;

  /// Dark grey on a pale plate, white on a dark one - which is the whole
  /// reason this hook takes the plate. In daylight that means the resting
  /// pill reads grey-on-silver and the selected one white-on-blue, both
  /// straight off the style guide; after dark every plate is dark enough
  /// that it comes out white, the way the other skins always are.
  ///
  /// The threshold is luminance rather than the theme, and it has to be,
  /// because a call site may hand over any colour at all: the warning
  /// orange behind an Ignore button is dark and takes white in both
  /// themes.
  @override
  Color label(GameTheme t, Color plate) =>
      plate.computeLuminance() > .4 ? _lightInk : Colors.white;

  /// One hairline of grey outside, one of white inside. Nothing here is
  /// carved, so the dark side of the edge - which is what both older
  /// consoles lean on - is the side this one does without.
  @override
  double get keyline => 1;
  @override
  double get rimWidth => 1;

  /// A soft, small shadow. These panels sit *over* the city rather than
  /// being cut into a console, but they are drawn flat, so what says so
  /// is a little separation and not a bevel.
  @override
  double get drop => 1.4;

  /// The style guide is unusually specific - "All Panel Rounded Corners
  /// 12 pixel radius" - and the app's own named panel radius is 15, so
  /// this is the number that turns one into the other rather than a
  /// judgement about how round the game looks.
  @override
  double get roundness => .8;

  /// Both ends matter here, unlike on the skins that only ever write in
  /// white: a white label on a lit plate crosses the gloss at the top,
  /// and the grey one on a pale plate crosses the shade at the bottom.
  @override
  double get faceHeadroom => _gloss;
  @override
  double get faceShadowroom => .09;

  /// Barely a gradient, which is the point. A short lift along the top,
  /// a long flat body, a little shade at the bottom - a drawn button
  /// rather than a moulded or a milled one. The lit plate gets a
  /// stronger top, because the game's selected tab does.
  @override
  LinearGradient face(Color base, {bool pressed = false, bool lit = false}) {
    final body = pressed ? _sink(base, .09) : base;
    return LinearGradient(
      begin: pressed ? Alignment.bottomCenter : Alignment.topCenter,
      end: pressed ? Alignment.topCenter : Alignment.bottomCenter,
      colors: [
        _lift(body, lit ? _gloss : .09),
        _lift(body, .02),
        body,
        _sink(body, .09),
      ],
      stops: const [0, .42, .58, 1],
    );
  }

  /// A quiet wash, lighter at the top. The Sims skins put a sky here and
  /// both older consoles put a sheet of metal; this game puts a blurred
  /// photograph of a city behind its front end, which is not something a
  /// gradient can be, so the honest answer is to stay out of the way of
  /// the panels standing on it.
  @override
  Decoration backdrop(GameTheme t) => BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _lift(t.bg, isDark(t) ? .06 : .22),
            t.bg,
            _sink(t.bg, isDark(t) ? .18 : .05),
          ],
          stops: const [0, .5, 1],
        ),
      );

  @override
  double radiusOf(SkinSurface surface) => switch (surface) {
        // The style guide's own number - see [roundness].
        SkinSurface.panel => 12,
        SkinSurface.button => 6,
        SkinSurface.row => 6,
        // The vertical toggle strips are the roundest thing in the
        // interface, and still not pills.
        SkinSurface.chip => 11,
        SkinSurface.notice => 10,
        SkinSurface.primary => 6,
        // Fields are square-ish and white, with the grey line around
        // them doing all the work.
        SkinSurface.well => 4,
      };
}
