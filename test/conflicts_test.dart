import 'package:flutter_test/flutter_test.dart';
import 'package:sims_mod_manager/src/core/conflicts.dart';
import 'package:sims_mod_manager/src/core/mod.dart';

Mod _mod(String name, String path, {bool enabled = true}) => Mod(
      name: name,
      path: path,
      status: enabled ? ModStatus.enabled : ModStatus.disabled,
    );

void main() {
  test('flags enabled mods sharing a file name', () {
    final mods = [
      _mod('hair.package', r'C:\mods\hair.package'),
      _mod('hair.package', r'C:\mods\sub\hair.package'),
      _mod('sofa.package', r'C:\mods\sofa.package'),
    ];

    final conflicts = findConflicts(mods);

    expect(conflicts,
        {r'C:\mods\hair.package', r'C:\mods\sub\hair.package'});
  });

  test('name comparison is case-insensitive', () {
    final mods = [
      _mod('Hair.package', r'C:\mods\Hair.package'),
      _mod('hair.package', r'C:\mods\sub\hair.package'),
    ];

    expect(findConflicts(mods), hasLength(2));
  });

  test('disabled duplicates do not conflict', () {
    final mods = [
      _mod('hair.package', r'C:\mods\hair.package'),
      _mod('hair.package', r'C:\mods\sub\hair.package.disabled',
          enabled: false),
    ];

    expect(findConflicts(mods), isEmpty);
  });
}
