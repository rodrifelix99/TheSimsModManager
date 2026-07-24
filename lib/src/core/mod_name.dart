import 'package:path/path.dart' as p;

/// Turns a mod file name into a human-friendly title using the naming
/// conventions Sims creators actually use: underscores/hyphens as word
/// separators, CamelCase run-together words, url-encoded spaces:
///
/// - `cozy_living-overhaul.package` → `cozy living overhaul`
/// - `UICheatsExtension_v1.36.ts4script` → `UI Cheats Extension v1.36`
/// - `MCCommandCenter.package` → `MC Command Center`
///
/// Version markers like `v1.36` and acronyms like `MCCC` are preserved;
/// original casing is kept (no title-casing of the author's spelling).
String humanizeModName(String fileName) {
  var name = p.basenameWithoutExtension(fileName);
  name = name.replaceAll('%20', ' ');
  name = name.replaceAll(RegExp(r'[_+-]'), ' ');
  // CamelCase boundaries: lower/digit→Upper, and ACRONYMWord → ACRONYM Word.
  name = name.replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'), (m) => '${m[1]} ${m[2]}');
  name = name.replaceAllMapped(
      RegExp(r'([A-Z]+)([A-Z][a-z])'), (m) => '${m[1]} ${m[2]}');
  name = name.replaceAll(RegExp(r'\s+'), ' ').trim();
  return name.isEmpty ? fileName : name;
}

/// What a mod's file name reveals about its identity and version.
///
/// DBPF packages carry no version metadata (the header version is the
/// *format* version, identical for every mod), so the file name is the
/// only version signal there is. Creators overwhelmingly do encode one:
/// `Mod_v1.36.package`, `mod-1.2.3.package`, `Fix 2024-05-01.package`.
class ModNameInfo {
  const ModNameInfo({
    required this.identity,
    required this.strippedName,
    this.version,
  });

  /// Case- and separator-insensitive key identifying the mod regardless
  /// of its version marker, extension included: two files whose names
  /// differ only in version token, casing, or word separators share an
  /// identity. Opaque — only useful for equality.
  final String identity;

  /// The file name with the version token removed (extension kept), for
  /// building display titles that don't repeat the version.
  final String strippedName;

  /// Canonical version token — `1.36`, `2b`, `2024-05-01` — or `null`
  /// when the name carries no recognizable version.
  final String? version;

  /// Display text for [version]: numbers get a `v` prefix (`v1.36`),
  /// dates stay bare (`2024-05-01`). `null` when there's no version.
  String? get versionLabel {
    final v = version;
    if (v == null) return null;
    return RegExp(r'^\d{4}-').hasMatch(v) ? v : 'v$v';
  }
}

/// `v`-prefixed version: `v2`, `V1.2.3`, `v2.5b`. The prefix boundary
/// keeps words like `TV2` or `Luv2Build` from matching.
final _vVersion = RegExp(
    r'(^|[\s_\-.+(\[])[vV]\.?(\d+(?:\.\d+){0,3}[a-z]?)(?=$|[\s_\-.+)\]])');

/// ISO-ish date stamp: `2024-05-01`, `2024.5.1`, `2024_05_01`.
final _dateVersion = RegExp(
    r'(^|[\s_\-.+(\[])(20\d{2})[-._](\d{1,2})[-._](\d{1,2})(?=$|[\s_\-+)\]])');

/// Bare dotted number: `1.2.3` set off by separators. At least one dot is
/// required so `Part 3` or `Top5` never read as versions.
final _dottedVersion =
    RegExp(r'(^|[\s_+(\[-])(\d+(?:\.\d+){1,3})(?=$|[\s_\-.+)\]])');

/// Best-effort parse of a mod file name into a version-independent
/// identity and a version token. Purely lexical (no file IO); see
/// [ModNameInfo] for what each field means.
ModNameInfo parseModName(String fileName) {
  final base = p.basenameWithoutExtension(fileName).replaceAll('%20', ' ');
  final ext = p.extension(fileName).toLowerCase();

  String? version;
  Match? token;
  // Highest-confidence pattern wins; within a pattern, the last match
  // (versions almost always trail the name).
  Match? lastMatch(RegExp pattern) {
    Match? last;
    for (final match in pattern.allMatches(base)) {
      last = match;
    }
    return last;
  }

  final v = lastMatch(_vVersion);
  final d = lastMatch(_dateVersion);
  final n = lastMatch(_dottedVersion);
  if (v != null) {
    token = v;
    version = v.group(2)!.toLowerCase();
  } else if (d != null) {
    token = d;
    version = '${d.group(2)}-${d.group(3)!.padLeft(2, '0')}-'
        '${d.group(4)!.padLeft(2, '0')}';
  } else if (n != null) {
    token = n;
    version = n.group(2);
  }

  // Drop the token (and the separator that introduced it) from the name.
  var stripped = base;
  if (token != null) {
    stripped =
        (base.substring(0, token.start) + base.substring(token.end)).trim();
  }
  if (stripped.replaceAll(RegExp(r'[\s_\-+.]'), '').isEmpty) {
    // Version-only names like `v1.2.package`: keep the original title.
    stripped = base;
  }

  final key =
      stripped.toLowerCase().replaceAll(RegExp(r'[\s_\-+.]+'), ' ').trim();
  return ModNameInfo(
    identity: '$key$ext',
    strippedName: '$stripped${p.extension(fileName)}',
    version: version,
  );
}
