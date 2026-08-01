import 'dart:convert';

import 'mod.dart';
import 'mod_name.dart';
import 'package_insight.dart';

/// What a published advisory says about a mod. The detail panel words its
/// warning from this, the same way the conflict panel words its own from
/// [ConflictReason].
enum AdvisoryStatus {
  /// The mod stops the game working and should come out until it's fixed.
  broken,

  /// A fixed release exists; what's installed here isn't it.
  outdated,

  /// Known to misbehave in some situations, but not plainly broken.
  caution,
}

/// One entry from the published advisory list: a mod (or a set of
/// versions of one) that is currently reported broken, together with the
/// wording to show and the ways to recognize it on disk.
///
/// [title], [since] and [note] arrive already written and are shown to the
/// user verbatim, untranslated - the same bargain the `announcement`
/// feature flag's payload makes, and what `AppMessage.verbatim` exists
/// for. Only the framing around them comes from the ARB files.
class ModAdvisory {
  const ModAdvisory({
    required this.id,
    required this.title,
    required this.status,
    this.since,
    this.note,
    this.url,
    this.fingerprints = const {},
    this.identities = const {},
    this.versions = const {},
  });

  /// Stable id, unique within the file. Analytics never reports it: an
  /// advisory id next to a distinct id would say that a particular user
  /// has a particular mod, which is exactly what the privacy contract
  /// rules out.
  final String id;

  final String title;

  final AdvisoryStatus status;

  /// When it started, as display text ("the 24 July 2026 patch"). The app
  /// has no idea which game version is installed and doesn't try to guess.
  final String? since;

  final String? note;

  /// Where to get the fix, if there is one.
  final String? url;

  /// [fingerprintOf] values identifying this mod by its contents.
  final Set<String> fingerprints;

  /// [ModNameInfo.identity] values identifying it by name.
  final Set<String> identities;

  /// Versions affected, as [ModNameInfo.version] tokens. Empty means
  /// every version; when it isn't empty a mod whose name carries no
  /// version can't be told apart and so isn't flagged.
  final Set<String> versions;
}

/// Schema version this build understands. The file is served to installs
/// that will never update (the portable zip auto-updates nothing), so it
/// only ever grows new optional fields, which older builds ignore.
/// Bumping this number is the escape hatch for a change that would
/// genuinely mislead an old client - it makes them read nothing at all
/// rather than read it wrongly.
const int advisorySchemaVersion = 1;

/// Decodes the published advisory file into game id -> advisories.
///
/// Forgiving in the same way as [scanPackage] and `fetchAvailableUpdate`:
/// a malformed document yields an empty map and a single unreadable entry
/// is skipped, because a warning system that throws is worse than one
/// that stays quiet.
Map<String, List<ModAdvisory>> parseAdvisories(String source) {
  try {
    final root = jsonDecode(source);
    if (root is! Map<String, dynamic>) return const {};
    if (root['version'] != advisorySchemaVersion) return const {};
    final games = root['games'];
    if (games is! Map<String, dynamic>) return const {};

    final result = <String, List<ModAdvisory>>{};
    for (final entry in games.entries) {
      final list = entry.value;
      if (list is! List) continue;
      final parsed = <ModAdvisory>[];
      for (final item in list) {
        final advisory = _parseAdvisory(item);
        if (advisory != null) parsed.add(advisory);
      }
      if (parsed.isNotEmpty) result[entry.key] = parsed;
    }
    return result;
  } catch (_) {
    return const {};
  }
}

ModAdvisory? _parseAdvisory(Object? item) {
  if (item is! Map<String, dynamic>) return null;
  final id = item['id'];
  final title = item['title'];
  if (id is! String || id.isEmpty) return null;
  if (title is! String || title.isEmpty) return null;
  // An unrecognized status is a newer file talking about something this
  // build has no wording for; drop the entry rather than guess at it.
  final status = switch (item['status']) {
    'broken' => AdvisoryStatus.broken,
    'outdated' => AdvisoryStatus.outdated,
    'caution' => AdvisoryStatus.caution,
    _ => null,
  };
  if (status == null) return null;

  final fingerprints = _stringSet(item['fingerprints']);
  final identities = _stringSet(item['identities']);
  if (fingerprints.isEmpty && identities.isEmpty) return null;

  return ModAdvisory(
    id: id,
    title: title,
    status: status,
    since: _nonEmpty(item['since']),
    note: _nonEmpty(item['note']),
    url: _httpsUrl(item['url']),
    fingerprints: fingerprints,
    identities: identities,
    versions: _stringSet(item['versions']),
  );
}

/// Lowercased so the file can be written in whatever casing reads best;
/// both match keys are case-insensitive by construction.
Set<String> _stringSet(Object? value) => {
      if (value is List)
        for (final item in value)
          if (item is String && item.trim().isNotEmpty) item.trim().toLowerCase(),
    };

String? _nonEmpty(Object? value) =>
    value is String && value.trim().isNotEmpty ? value.trim() : null;

String? _httpsUrl(Object? value) =>
    value is String && value.startsWith('https://') ? value : null;

/// A stable identifier for what's actually inside a package: the FNV-1a
/// hash of its deduplicated, sorted resource keys, as 16 hex characters.
/// `null` when there are no keys to hash - a non-DBPF file (script mods
/// are zips), or a package big enough that [PackageInsight.maxRetainedKeys]
/// dropped them.
///
/// This is why renaming a mod doesn't hide it from the advisory list, and
/// why the value must never be computed with `hashCode` or [Object.hash]:
/// it is published in a file that has to keep meaning the same thing long
/// after the Dart that wrote it is gone.
String? fingerprintOf(PackageInsight? insight) {
  final keys = insight?.keys;
  if (keys == null || keys.isEmpty) return null;
  // Deduplicated first: a package that repeats a key in its index must
  // fingerprint the same as the one that doesn't.
  final sorted = keys.toSet().toList()
    ..sort((a, b) {
      if (a.type != b.type) return a.type.compareTo(b.type);
      if (a.group != b.group) return a.group.compareTo(b.group);
      // Instances with the top bit set read as negative here. That orders
      // them before the rest instead of after, which is arbitrary but
      // fixed, and only the ordering being fixed matters.
      return a.instance.compareTo(b.instance);
    });

  var hash = 0xcbf29ce484222325; // FNV-1a 64-bit offset basis
  void feed(int value, int width) {
    for (var shift = width - 8; shift >= 0; shift -= 8) {
      hash = (hash ^ ((value >> shift) & 0xff)) * 0x100000001b3;
    }
  }

  for (final key in sorted) {
    feed(key.type, 32);
    feed(key.group, 32);
    feed(key.instance, 64);
  }
  // Halved rather than printed whole: the hash fills all 64 bits, and a
  // Dart int with the top bit set prints as a negative number.
  final high = (hash >> 32) & 0xffffffff;
  final low = hash & 0xffffffff;
  return high.toRadixString(16).padLeft(8, '0') +
      low.toRadixString(16).padLeft(8, '0');
}

/// Enabled mods that the published list has something to say about:
/// path -> the advisory covering it.
///
/// Only enabled mods are matched, like the conflict scan: the warning is
/// about what the game is loading right now, so disabling the culprit is
/// what makes it go away.
///
/// Two match keys, and neither is a fallback for the other. [fingerprintOf]
/// is the stronger one and survives renaming, but it needs the package
/// scan's resource keys, so it's unavailable when "Scan inside mods" is
/// off and for anything that isn't a DBPF package. Names carry the rest -
/// including script mods, which are `.ts4script` zips with no resource
/// keys at all and are precisely what a game patch tends to break.
///
/// [insightOf] supplies each mod's scan result, exactly as
/// [findResourceOverlaps] takes it.
Map<String, ModAdvisory> matchAdvisories(
  List<Mod> mods,
  List<ModAdvisory> advisories,
  PackageInsight? Function(Mod mod) insightOf,
) {
  if (advisories.isEmpty) return const {};
  final byFingerprint = <String, ModAdvisory>{};
  final byIdentity = <String, ModAdvisory>{};
  for (final advisory in advisories) {
    for (final print in advisory.fingerprints) {
      byFingerprint.putIfAbsent(print, () => advisory);
    }
    for (final identity in advisory.identities) {
      byIdentity.putIfAbsent(identity, () => advisory);
    }
  }

  final matched = <String, ModAdvisory>{};
  for (final mod in mods) {
    if (!mod.isEnabled) continue;
    final info = parseModName(mod.name);
    // Contents before name: the fingerprint knows what the file is, the
    // name only knows what it was called.
    final advisory =
        byFingerprint[fingerprintOf(insightOf(mod))] ?? byIdentity[info.identity];
    if (advisory == null) continue;
    if (advisory.versions.isNotEmpty &&
        !advisory.versions.contains(info.version?.toLowerCase())) {
      continue;
    }
    matched[mod.path] = advisory;
  }
  return matched;
}
