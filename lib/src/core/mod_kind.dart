/// What a mod turns out to *be*, read off the resources inside it.
///
/// The third thing the library can be narrowed by that nobody has to
/// type. The category chips answer from the file extension, which for
/// The Sims 2, 3 and 4 means almost every mod in the library reads
/// "Package" and says nothing; the folder chips answer from wherever the
/// user filed it. This answers from the contents: a package holding CAS
/// part resources is custom content for Create a Sim whatever it is
/// called and wherever it sits.
///
/// Deliberately coarse. It is worked out from the resource *index* the
/// artwork scan already reads - the type of each resource and nothing
/// else - so it costs no extra file IO at all, and it can only be as
/// specific as a resource type is. Which body part a CAS part dresses,
/// and which ages and genders it fits, live inside the CASP resource's
/// own body in a layout that changes between game versions; reading
/// those is a parser rather than a lookup table, and is not this.
///
/// Keys are stable English, resolved for drawing by `AppText.modKind`
/// the way `Mod.category` and `AppMessage` are: they key analytics and
/// they are compared, so they must not change when the language does. An
/// unknown key draws as itself rather than blanking.
library;

import 'package_insight.dart';

/// Custom content for Create a Sim: hair, clothing, skins, makeup,
/// accessories. Anything carrying CAS part resources.
const kindCasPart = 'CAS';

/// Objects and surfaces for Build/Buy - furniture, walls, floors.
const kindBuildBuy = 'Build Buy';

/// A mod that changes how the game behaves rather than what is in it:
/// tuning, and The Sims 2's own behaviour resources.
const kindGameplay = 'Gameplay';

/// Compiled script, which is a mod the game runs code from. Decided by
/// the file rather than by anything inside it.
const kindScript = 'Script';

/// The order the chips are offered in, coarsest question first. Not
/// alphabetical: this is a fixed vocabulary of four, and "is it CAS or
/// is it Build/Buy" is the question people actually sort by.
const modKindOrder = <String>[
  kindCasPart,
  kindBuildBuy,
  kindGameplay,
  kindScript,
];

/// Content labels from [PackageInsight.contents] that decide a kind.
/// The insight's own vocabulary, which several resource types across the
/// three games already fold into: `_typeLabels` in package_insight.dart
/// maps The Sims 2's OBJD and The Sims 4's catalog object onto the same
/// "objects", which is exactly the granularity wanted here.
const _casContents = 'CAS parts';
const _objectContents = 'objects';
const _tuningContents = <String>{'tunings', 'behaviors'};

/// Extensions that are a script whatever is inside them.
const _scriptExtensions = <String>{'.ts4script', '.py', '.pyc'};

/// What [insight] says the mod holding it is, or an empty set when the
/// contents do not answer - which is the honest result for a package of
/// nothing but textures, and for every mod at all when the scan that
/// reads inside files is switched off.
///
/// More than one kind is normal and not a failure: a build/buy set that
/// also dresses a Sim carries both, and a script mod shipping tuning
/// beside it carries both. Whichever chips it earns, it appears under.
///
/// [extension] is the mod file's own, lowercased with its dot, and is
/// what answers for the files that are not packages at all.
Set<String> modKindsOf(PackageInsight? insight, {required String extension}) {
  final kinds = <String>{};
  if (_scriptExtensions.contains(extension)) kinds.add(kindScript);
  final contents = insight?.contents;
  if (contents == null || contents.isEmpty) return kinds;
  final isContent = contents.containsKey(_casContents) ||
      contents.containsKey(_objectContents);
  if (contents.containsKey(_casContents)) kinds.add(kindCasPart);
  if (contents.containsKey(_objectContents)) kinds.add(kindBuildBuy);
  // Tuning beside CAS parts or objects is how that content is wired into
  // the game rather than a mod that changes the rules, so it only counts
  // where there is no such content to wire. Otherwise every piece of
  // custom content in the library would wear the Gameplay chip and the
  // chip would mean nothing. Measured against the content kinds and not
  // against "nothing found yet", so a script shipping tuning beside it
  // still reads as both.
  if (!isContent && _tuningContents.any(contents.containsKey)) {
    kinds.add(kindGameplay);
  }
  return kinds;
}

/// How many mods carry each kind, for the chips. Keyed the same way and
/// in [modKindOrder], so the row is drawn in a fixed order however the
/// library is made up.
Map<String, int> countKinds(Iterable<Set<String>> perMod) {
  final counts = <String, int>{};
  for (final kinds in perMod) {
    for (final kind in kinds) {
      counts[kind] = (counts[kind] ?? 0) + 1;
    }
  }
  return {
    for (final kind in modKindOrder)
      if (counts.containsKey(kind)) kind: counts[kind]!,
  };
}
