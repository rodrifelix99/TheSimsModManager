import 'dart:io' show zlib;
import 'dart:typed_data';

import 'mod_shop.dart';

/// Invented listings for The Exchange, the shop's half of the demo
/// library: an alpha storefront with nothing on the shelves is the honest
/// state, and also the one screenshot nobody wants. Deterministic per
/// game, so a shot retaken tomorrow shows the same shelves, and every
/// creator handle is made up - never a real creator's name.
///
/// Nothing here reaches the network. The cover art is generated in
/// memory (see [demoListingArt]) rather than downloaded, so the shelves
/// look like a storefront instead of a wall of placeholder stripes.

/// One game's slot in the invented catalog: its id, and the extension its
/// mods actually use, so a Sims 1 listing doesn't offer a `.package`.
typedef DemoShopGame = ({String id, String fileExtension});

/// Builds the invented catalog. [today] is the anchor the "updated"
/// dates count back from, quantized to the day by the caller so a
/// listing doesn't change identity between refreshes.
List<ShopMod> buildDemoShop(List<DemoShopGame> games,
    {required DateTime today}) {
  final listings = <ShopMod>[];
  var index = 0;
  for (final game in games) {
    for (var n = 0; n < _perGame; n++) {
      final template = _templates[index % _templates.length];
      // The creator strides by a step coprime with the list length, so
      // the same creator and item never pair up twice.
      final creator = _creators[(index * 3 + 1) % _creators.length];
      final seed = index;
      // Bigger things ship as archives, the way they do on the real
      // sharing sites; single files keep the game's own extension.
      final archive = template.parts > 1;
      final slug = template.name.replaceAll(' ', '');
      listings.add(ShopMod(
        id: 'demo-${game.id}-$n',
        gameId: game.id,
        name: template.name,
        version: _versions[seed % _versions.length],
        description: template.blurb,
        instructions: template.notes,
        authorName: creator,
        fileName: '${creator}_$slug${archive ? '.zip' : game.fileExtension}',
        // A path that looks like the real thing, though nothing ever
        // fetches it: demo listings carry their bytes with them.
        filePath: 'mods/demo/${game.id}-$n/${creator}_$slug',
        fileSizeBytes: _size(seed, template.parts),
        updatedAt: today.subtract(Duration(days: seed * 3 % 41 + 1)),
        demoImages: [
          for (var i = 0; i < template.shots; i++) demoListingArt(seed, i),
        ],
      ));
      index++;
    }
  }
  return listings;
}

/// How many listings each game gets. Enough that the grid fills a window
/// and the per-game filter chips all have something behind them.
const int _perGame = 6;

const _versions = ['1.0', '1.2', '2.0', '1.4.1', '3.0', '2.1', '1.1', '4.2'];

int _size(int seed, int parts) {
  final spread = (seed * 37 % 100) + 1;
  return parts > 1
      ? 18 * 1024 * 1024 + spread * 900000
      : 320 * 1024 + spread * 64000;
}

/// Invented creator handles, in the spirit of the demo library's own -
/// deliberately not real creators' names.
const _creators = [
  'aurorasims',
  'pixelpeach',
  'moonlitcc',
  'noirbuilds',
  'simplyrae',
  'velvetsim',
  'urbanbloom',
  'lunara',
  'claybird',
  'peachyhaus',
];

class _Listing {
  const _Listing(this.name, this.blurb, {this.notes, this.parts = 1, this.shots = 3});

  final String name;
  final String blurb;
  final String? notes;

  /// More than one file inside, so the download is an archive.
  final int parts;

  /// How many screenshots the listing carries.
  final int shots;
}

/// The invented catalog. Deliberately spread across the kinds of thing
/// people actually publish, with descriptions long enough to show what
/// the detail panel does with real copy.
const _templates = [
  _Listing(
    'Cottage Kitchen Set',
    'A 42-piece kitchen built for cosy country lots: an aga-style range, '
        'open shelving, a farmhouse sink and enough clutter to make the '
        'counters look lived in. Everything is base game compatible and '
        'comes in 18 swatches that match the palette of my earlier sets.',
    notes: 'Unzip into your mods folder. The counters need the recolours '
        'file to sit next to the meshes, so keep the folder together.',
    parts: 9,
  ),
  _Listing(
    'Wisteria Hair',
    'Long wavy hair with a soft braided crown, in 24 EA colours plus 6 '
        'pastels. Hat compatible, all LODs, and the mesh is under 8k '
        'polys so it will not tank your game in CAS.',
    shots: 4,
  ),
  _Listing(
    'Better Autonomy',
    'Stops your sims abandoning a meal to go wash a single plate. '
        'Rebalances the autonomy scores for cleaning, socialising and '
        'entertainment so households feel less frantic without going '
        'completely idle.',
    notes: 'Script mod: turn on "Script Mods Allowed" in game options '
        'and restart. Remove the old version before installing this one.',
  ),
  _Listing(
    'Terrazzo Bathroom',
    'Speckled terrazzo in eight colourways, with matching basins, a '
        'freestanding tub and the wall tiles to go with them. Made for '
        'small apartment bathrooms where nothing ever fits.',
    parts: 6,
  ),
  _Listing(
    'Florist Career',
    'A full custom career with ten levels, from bucket washer to '
        'wedding florist, with its own uniforms, chance cards and a work '
        'tone that actually changes your sim\'s mood.',
    notes: 'Back up your save first. Sims already at work when you '
        'install will need one in-game day to pick up the new track.',
    parts: 4,
  ),
  _Listing(
    'Arched Windows',
    'Tall arched windows in three heights and two frame weights, plus '
        'the matching door. Built to line up on the wall grid, so a row '
        'of them actually looks like a row.',
    shots: 2,
  ),
  _Listing(
    'Everyday Sneakers',
    'Scuffed canvas sneakers for everyone from teen up, 20 swatches. '
        'The kind of shoe your sims would actually own rather than the '
        'kind they wear to a gala.',
  ),
  _Listing(
    'Comfort Food Recipes',
    'Fourteen new cookable dishes: dumplings, shepherd\'s pie, congee, '
        'and a birthday cake that does not look like a beige brick. '
        'Each one has its own custom thumbnail and moodlet.',
    notes: 'Needs the latest patch. If your sims cannot see the new '
        'recipes, clear your localthumbcache and restart.',
    parts: 5,
  ),
  _Listing(
    'Paper Moon Lamps',
    'Six paper lanterns and two floor lamps that cast a warm low light. '
        'The glow colour is editable in build mode.',
    shots: 2,
  ),
  _Listing(
    'Night Owl Trait',
    'Your sim gets a mood boost after midnight and grumbles through the '
        'morning. Small, tidy, and it plays nicely with other custom '
        'traits.',
  ),
];

/// Generated art for a listing's [variant]th screenshot, as PNG bytes.
/// Deterministic and cached, because the shelves are rebuilt on every
/// refresh and the pixels never change. The palette follows [seed] alone
/// while the composition follows the variant, so one listing's shots
/// look like one mod photographed three times rather than three mods.
Uint8List demoListingArt(int seed, [int variant = 0]) =>
    _artCache[seed * 100 + variant] ??= _paint(seed, variant, 480, 300);

final _artCache = <int, Uint8List>{};

/// Palette pairs the art is built from - the same soft, slightly faded
/// range the placeholder stripes use, so a shelf of demo listings sits
/// next to the rest of the app rather than shouting over it.
const _palettes = <(int, int, int, int, int, int)>[
  (0x8F, 0xD3, 0xC7, 0x2E, 0x6F, 0x7E),
  (0xF2, 0xC7, 0x9A, 0xB5, 0x6B, 0x4E),
  (0xB9, 0xA7, 0xE0, 0x5B, 0x46, 0x8C),
  (0x9E, 0xCB, 0xE8, 0x2B, 0x55, 0x7A),
  (0xBC, 0xD3, 0x9A, 0x4F, 0x6B, 0x35),
  (0xE6, 0xA7, 0xB8, 0x8C, 0x3F, 0x59),
  (0xE3, 0xD3, 0xA2, 0x7A, 0x63, 0x2E),
  (0xA3, 0xDD, 0xC0, 0x2F, 0x6B, 0x55),
];

/// A soft two-tone gradient with a circle and a couple of bands over it:
/// abstract enough to stand in for a screenshot, structured enough that
/// the shelves don't read as noise.
Uint8List _paint(int seed, int variant, int width, int height) {
  final palette = _palettes[seed % _palettes.length];
  final (r1, g1, b1, r2, g2, b2) = palette;
  final rgb = Uint8List(width * height * 3);
  // Composition moves with the variant, so a listing's shots differ
  // without changing colour.
  final v = seed * 7 + variant * 37;
  // Circle placed by the seed, never closer than its radius to an edge.
  final radius = height * (28 + v % 16) / 100;
  final cx = radius + (width - 2 * radius) * (v * 13 % 100) / 100;
  final cy = radius + (height - 2 * radius) * (v * 29 % 100) / 100;
  final bandTop = height * (55 + v * 11 % 25) / 100;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      // Diagonal gradient between the pair.
      final t = (x / width * .45 + y / height * .55).clamp(0.0, 1.0);
      var r = (r1 + (r2 - r1) * t).round();
      var g = (g1 + (g2 - g1) * t).round();
      var b = (b1 + (b2 - b1) * t).round();
      final dx = x - cx, dy = y - cy;
      if (dx * dx + dy * dy <= radius * radius) {
        // Lighten inside the circle rather than paint a flat disc, so
        // the gradient still reads through it.
        r = (r + (255 - r) * .30).round();
        g = (g + (255 - g) * .30).round();
        b = (b + (255 - b) * .30).round();
      }
      if (y > bandTop) {
        final shade = y > bandTop + height * .12 ? .18 : .09;
        r = (r * (1 - shade)).round();
        g = (g * (1 - shade)).round();
        b = (b * (1 - shade)).round();
      }
      final i = (y * width + x) * 3;
      rgb[i] = r;
      rgb[i + 1] = g;
      rgb[i + 2] = b;
    }
  }
  return _encodePng(width, height, rgb);
}

/// Minimal PNG writer: 8-bit RGB, one IDAT, no interlacing. Enough for
/// generated art, and it saves pulling an image package into the app for
/// something only a debug build ever draws.
Uint8List _encodePng(int width, int height, Uint8List rgb) {
  final raw = BytesBuilder();
  for (var y = 0; y < height; y++) {
    raw.addByte(0); // filter type: none
    raw.add(Uint8List.sublistView(rgb, y * width * 3, (y + 1) * width * 3));
  }
  final out = BytesBuilder();
  out.add(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  _chunk(out, 'IHDR',
      Uint8List.fromList([..._be32(width), ..._be32(height), 8, 2, 0, 0, 0]));
  _chunk(out, 'IDAT', Uint8List.fromList(zlib.encode(raw.takeBytes())));
  _chunk(out, 'IEND', Uint8List(0));
  return out.takeBytes();
}

List<int> _be32(int value) =>
    [value >> 24 & 0xFF, value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF];

void _chunk(BytesBuilder out, String type, Uint8List data) {
  final typeBytes = type.codeUnits;
  out.add(_be32(data.length));
  out.add(typeBytes);
  out.add(data);
  out.add(_be32(_crc32([...typeBytes, ...data])));
}

final _crcTable = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc32(List<int> bytes) {
  var c = 0xFFFFFFFF;
  for (final byte in bytes) {
    c = _crcTable[(c ^ byte) & 0xFF] ^ (c >> 8);
  }
  return (c ^ 0xFFFFFFFF) & 0xFFFFFFFF;
}
