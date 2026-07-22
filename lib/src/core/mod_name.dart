import 'package:path/path.dart' as p;

/// Turns a mod file name into a human-friendly title using the naming
/// conventions Sims creators actually use — underscores/hyphens as word
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
