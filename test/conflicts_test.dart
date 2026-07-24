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

  test('flags two versions of the same mod', () {
    final mods = [
      _mod('CoolHair_v1.package', r'C:\mods\CoolHair_v1.package'),
      _mod('CoolHair_v2.package', r'C:\mods\sub\CoolHair_v2.package'),
      _mod('sofa.package', r'C:\mods\sofa.package'),
    ];

    expect(findConflicts(mods), {
      r'C:\mods\CoolHair_v1.package',
      r'C:\mods\sub\CoolHair_v2.package',
    });
  });

  test('version matching ignores separators and casing', () {
    final mods = [
      _mod('cool_hair_v1.36.package', r'C:\mods\cool_hair_v1.36.package'),
      _mod('Cool Hair 1.37.package', r'C:\mods\Cool Hair 1.37.package'),
    ];

    expect(findConflicts(mods), hasLength(2));
  });

  test('a versioned mod next to an unversioned one is not flagged', () {
    final mods = [
      _mod('CoolHair.package', r'C:\mods\CoolHair.package'),
      _mod('CoolHair_v2.package', r'C:\mods\CoolHair_v2.package'),
    ];

    expect(findConflicts(mods), isEmpty);
  });

  test('a disabled old version does not conflict with the new one', () {
    final mods = [
      _mod('CoolHair_v2.package', r'C:\mods\CoolHair_v2.package'),
      _mod('CoolHair_v1.package', r'C:\mods\CoolHair_v1.package.disabled',
          enabled: false),
    ];

    expect(findConflicts(mods), isEmpty);
  });

  test('same version twice falls under the duplicate-name rule only', () {
    final mods = [
      _mod('CoolHair_v2.package', r'C:\mods\CoolHair_v2.package'),
      _mod('CoolHair_v2.package', r'C:\mods\sub\CoolHair_v2.package'),
    ];

    expect(findConflicts(mods), hasLength(2));
  });

  test('different mods with versions do not cross-flag', () {
    final mods = [
      _mod('CoolHair_v1.package', r'C:\mods\CoolHair_v1.package'),
      _mod('WarmSofa_v2.package', r'C:\mods\WarmSofa_v2.package'),
    ];

    expect(findConflicts(mods), isEmpty);
  });
}
