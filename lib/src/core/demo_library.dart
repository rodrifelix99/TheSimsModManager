import 'package:path/path.dart' as p;

import 'game_adapter.dart';
import 'mod.dart';
import 'package_insight.dart';

/// An invented mod library: files that never existed, built so the app can
/// be photographed on a machine where the games aren't installed (or where
/// the real library is three test files called `aaa.package`).
///
/// Nothing here touches the disk. The mods carry plausible paths under the
/// game's own mods folder, a spread of sizes, dates, categories and
/// subfolders, a few disabled ones, and two planted clashes so the
/// conflict badge has something to say. Generation is deterministic per
/// game, so a screenshot retaken tomorrow shows the same library.
class DemoLibrary {
  const DemoLibrary({required this.mods, required this.insights});

  final List<Mod> mods;

  /// Fake scan results keyed by `mod.path`, so the detail panel's contents
  /// breakdown fills in without anything to parse.
  final Map<String, PackageInsight> insights;
}

/// Builds the demo library for [adapter], with every file placed under
/// [root] (the game's resolved or default mods folder). [today] is the
/// anchor the modification dates count back from; it is quantized to the
/// day by callers so a mod's identity doesn't change between refreshes.
///
/// [depthLimit] is the game's own [GameAdapter.modDepthLimit]. A game whose
/// mods folder is flat (SimCity 3000's `Buildings`, limit 0) reads nothing
/// out of a subfolder, so filing the invented library into the usual
/// category folders would put every mod behind the too-deep banner - a
/// warning about a library nobody has, in the one shot meant to sell the
/// game's chrome. Those get a flat library instead.
DemoLibrary buildDemoLibrary(GameAdapter adapter, String root,
    {required DateTime today, int? depthLimit}) {
  final extensions = adapter.modFileExtensions.toList()..sort();
  if (extensions.isEmpty) {
    return const DemoLibrary(mods: [], insights: {});
  }
  final primary =
      extensions.contains('.package') ? '.package' : extensions.first;
  final script =
      extensions.contains('.ts4script') ? '.ts4script' : extensions.last;

  final mods = <Mod>[];
  final insights = <String, PackageInsight>{};
  var index = 0;

  // A flat mods folder takes no subfolders at all; anything else keeps the
  // sections, since a limit of 1 or more still reads the one level they use.
  final flat = depthLimit == 0;

  void add(String? folder, _Kind kind, String fileName, {bool? enabled}) {
    final i = index++;
    final extension = switch (kind) {
      _Kind.script => script,
      // Every fourth file takes another of the game's extensions, so games
      // with a rich file taxonomy (Sims 1) show more than one category chip
      // instead of a wall of the same one.
      _ when i % 4 == 3 => extensions[i % extensions.length],
      _ => primary,
    };
    final disabled = enabled == null ? i % 7 == 4 : !enabled;
    final path = folder == null || flat
        ? p.join(root, '$fileName$extension')
        : p.join(root, folder, '$fileName$extension');
    mods.add(Mod(
      name: '$fileName$extension',
      path: disabled ? '$path$disabledSuffix' : path,
      status: disabled ? ModStatus.disabled : ModStatus.enabled,
      sizeBytes: _size(kind, i),
      category: adapter.categoryForExtension(extension),
      // Spread over the last eight months or so, newest a few hours old.
      modifiedAt: today.subtract(Duration(hours: 7 * i * i % 6200 + i + 5)),
    ));
    final insight = _insight(kind, i);
    if (insight != null) insights[mods.last.path] = insight;
  }

  for (final section in _sections) {
    // One seed per section, fixed before the loop: a seed that moved with
    // every file would put the creator and the item on the same cycle, and
    // the same creator/item pair would come round twice.
    final seed = index;
    for (var n = 0; n < section.count; n++) {
      add(section.folder, section.kind, section.fileName(n, seed));
    }
  }

  // Two planted clashes: the same file installed in two folders, and a mod
  // sitting next to its own older version. Both are what the conflict scan
  // looks for, and both have to stay enabled to be seen, so the library
  // header never reads a lonely "0".
  add('CAS', _Kind.cas, 'velvetsim_Hair_Marigold', enabled: true);
  add('Overrides', _Kind.cas, 'velvetsim_Hair_Marigold', enabled: true);
  add('Gameplay', _Kind.gameplay, 'claybird_Career_Florist_v1.4',
      enabled: true);
  add('Gameplay', _Kind.gameplay, 'claybird_Career_Florist_v2.0',
      enabled: true);

  mods.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return DemoLibrary(mods: mods, insights: insights);
}

enum _Kind { cas, build, script, gameplay, merged }

class _Section {
  const _Section({
    required this.folder,
    required this.kind,
    required this.count,
    this.items = const [],
  });

  /// Subfolder of the mods directory, or null for files sitting loose in
  /// the root (every real library has a few).
  final String? folder;
  final _Kind kind;
  final int count;
  final List<String> items;

  /// `creator_Item` for the [n]th file of this section. The creator strides
  /// through its list by a step coprime with the list's length, so it stays
  /// out of step with the item and no section repeats a pair.
  String fileName(int n, int seed) {
    final creator = _creators[(n * 7 + seed) % _creators.length];
    final item = items[n % items.length];
    // Roughly every third file carries a version marker, the way creators'
    // own uploads do.
    final version = n % 3 == 1 ? '_v${1 + n % 3}.${n % 7}' : '';
    return '${creator}_$item$version';
  }
}

/// Invented creator handles - deliberately not real creators' names.
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

const _sections = [
  _Section(folder: 'CAS', kind: _Kind.cas, count: 34, items: [
    'Hair_Wisteria',
    'Eyes_Celeste',
    'SkinOverlay_Dewy',
    'Freckles_Sunkissed',
    'Brows_Feathered',
    'Lipgloss_Honey',
    'Nails_Almond',
    'Cardigan_Oversized',
    'Denim_HighWaist',
    'Sneakers_Everyday',
    'Earrings_Pearl',
    'Blush_Peachy',
  ]),
  _Section(folder: 'Build Buy', kind: _Kind.build, count: 22, items: [
    'KitchenSet_Nordic',
    'LivingRoom_Cozy',
    'Bathroom_Terrazzo',
    'GardenClutter',
    'CafeSigns',
    'Bookshelf_Stacked',
    'RugPack_Woven',
    'Windows_Arched',
    'Lamps_PaperMoon',
    'Plants_Trailing',
    'Curtains_Linen',
  ]),
  _Section(folder: 'Gameplay', kind: _Kind.gameplay, count: 12, items: [
    'Career_Florist',
    'Trait_NightOwl',
    'Aspiration_Homebody',
    'Recipes_ComfortFood',
    'Events_Housewarming',
    'Lot_Trait_Quiet',
  ]),
  _Section(folder: 'Script Mods', kind: _Kind.script, count: 7, items: [
    'BetterRelationships',
    'NoAutonomousDishes',
    'MoodletTweaks',
    'FasterHomework',
    'SmarterCarpools',
  ]),
  _Section(folder: 'Overrides', kind: _Kind.cas, count: 6, items: [
    'DefaultEyes_Replacement',
    'SkinOverlay_Dewy',
    'Hair_Wisteria',
    'Toddler_Teeth_Fix',
  ]),
  _Section(folder: null, kind: _Kind.merged, count: 4, items: [
    'MergedCC_Spring',
    'MergedCC_Clutter',
    'CC_Backup_Pack',
    'Everything_Merged',
  ]),
];

/// Plausible file size for a [kind] of mod: a script is kilobytes, a
/// merged CC pack is hundreds of megabytes, and the sizes have to vary or
/// the library reads as generated.
int _size(_Kind kind, int i) {
  final spread = (i * 37 % 100) + 1;
  return switch (kind) {
    _Kind.script => 12 * 1024 + spread * 3200,
    _Kind.gameplay => 40 * 1024 + spread * 21000,
    _Kind.cas => 180 * 1024 + spread * 78000,
    _Kind.build => 900 * 1024 + spread * 390000,
    _Kind.merged => 70 * 1024 * 1024 + spread * 3900000,
  };
}

/// The contents breakdown the detail panel shows, as the real scan would
/// report it: labels are the same stable English keys `AppText` translates.
/// Script mods get none, because a `.ts4script` is a zip the DBPF scan
/// can't read either.
PackageInsight? _insight(_Kind kind, int i) {
  final n = (i * 13 % 40) + 3;
  final contents = switch (kind) {
    _Kind.script => const <String, int>{},
    _Kind.cas => {'textures': n * 3, 'CAS parts': n, 'meshes': n ~/ 2 + 1},
    _Kind.build => {'textures': n * 4, 'objects': n * 2, 'meshes': n},
    _Kind.gameplay => {'tunings': n * 5, 'text tables': n},
    _Kind.merged => {
        'textures': n * 26,
        'CAS parts': n * 9,
        'objects': n * 4,
        'meshes': n * 3,
      },
  };
  if (contents.isEmpty) return null;
  final sorted = contents.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return PackageInsight(
    resourceCount: contents.values.fold(0, (sum, v) => sum + v),
    contents: {for (final entry in sorted) entry.key: entry.value},
  );
}
