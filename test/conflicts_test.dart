import 'package:flutter_test/flutter_test.dart';
import 'package:sims_mod_manager/src/core/conflicts.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';

Mod _mod(String name, String path, {bool enabled = true}) => Mod(
      name: name,
      path: path,
      status: enabled ? ModStatus.enabled : ModStatus.disabled,
    );

/// insightOf backed by a path → keys map; paths not listed act like
/// unscanned files (null insight).
PackageInsight? Function(Mod) _insights(Map<String, List<ResourceKey>> keys) =>
    (mod) {
      final k = keys[mod.path];
      return k == null ? null : PackageInsight(keys: k);
    };

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

  group('findResourceOverlaps', () {
    const casp = ResourceKey(0x034AEECB, 0, 0x100);
    const tuning = ResourceKey(0x0333406C, 0, 0x200);
    const texture = ResourceKey(0x00B2D882, 0, 0x300);

    test('mods sharing a resource key overlap each other, with counts', () {
      final a = _mod('a.package', r'C:\mods\a.package');
      final b = _mod('b.package', r'C:\mods\b.package');
      final c = _mod('c.package', r'C:\mods\c.package');

      final overlaps = findResourceOverlaps([a, b, c], _insights({
        a.path: [casp, tuning],
        b.path: [casp, tuning, texture],
        c.path: [texture],
      }));

      expect(overlaps, {
        a.path: {b.path: 2},
        b.path: {a.path: 2, c.path: 1},
        c.path: {b.path: 1},
      });
    });

    test('keys differing in any TGI component do not overlap', () {
      final a = _mod('a.package', r'C:\mods\a.package');
      final b = _mod('b.package', r'C:\mods\b.package');

      final overlaps = findResourceOverlaps([a, b], _insights({
        a.path: [const ResourceKey(0x034AEECB, 0, 0x100)],
        b.path: [
          const ResourceKey(0x034AEECB, 0, 0x101), // other instance
          const ResourceKey(0x034AEECB, 1, 0x100), // other group
          const ResourceKey(0x0333406C, 0, 0x100), // other type
        ],
      }));

      expect(overlaps, isEmpty);
    });

    test('disabled mods and unscanned mods do not participate', () {
      final a = _mod('a.package', r'C:\mods\a.package');
      final off = _mod('b.package', r'C:\mods\b.package.disabled',
          enabled: false);
      final unscanned = _mod('c.package', r'C:\mods\c.package');

      final overlaps = findResourceOverlaps([a, off, unscanned], _insights({
        a.path: [casp],
        off.path: [casp],
        // c.package never scanned: no entry.
      }));

      expect(overlaps, isEmpty);
    });

    test('the Sims 2 DIR resource never counts as an overlap', () {
      const dir = ResourceKey(0xE86B1EEF, 0x7FB59E88, 0x286B1F03);
      final a = _mod('a.package', r'C:\mods\a.package');
      final b = _mod('b.package', r'C:\mods\b.package');

      final overlaps = findResourceOverlaps([a, b], _insights({
        a.path: [dir, casp],
        b.path: [dir, tuning],
      }));

      expect(overlaps, isEmpty);
    });

    test('a key nearly every package carries is boilerplate, not a clash',
        () {
      // A creator tool stamping the same id into everything it exports
      // would otherwise flag its whole output - and cost a pair per
      // combination of owners, which is what makes a large library run
      // out of memory.
      final many = [
        for (var i = 0; i < 40; i++)
          _mod('m$i.package', 'C:\\mods\\m$i.package'),
      ];
      final overlaps = findResourceOverlaps(
          many, _insights({for (final m in many) m.path: [casp]}));

      expect(overlaps, isEmpty);
    });

    test('overlap rows stop growing at the partner cap', () {
      final many = [
        for (var i = 0; i < 40; i++)
          _mod('m$i.package', 'C:\\mods\\m$i.package'),
      ];
      // One distinct key per pair of mods, so every mod overlaps every
      // other while no single key looks like boilerplate. Uncapped, each
      // row would list all 39 partners.
      ResourceKey pairKey(int i, int j) => ResourceKey(
          0x034AEECB, 0, i < j ? i * 100 + j : j * 100 + i);
      final overlaps = findResourceOverlaps(many, _insights({
        for (var i = 0; i < many.length; i++)
          many[i].path: [
            for (var j = 0; j < many.length; j++)
              if (i != j) pairKey(i, j),
          ],
      }));

      // Every mod is still flagged; only how many partners are listed
      // for it is bounded.
      expect(overlaps, hasLength(40));
      for (final row in overlaps.values) {
        expect(row.length, lessThanOrEqualTo(32));
      }
      expect(overlaps.values.map((r) => r.length), contains(32));
    });

    test('a key repeated inside one package neither self-flags nor '
        'inflates counts', () {
      final a = _mod('a.package', r'C:\mods\a.package');
      final b = _mod('b.package', r'C:\mods\b.package');

      expect(
        findResourceOverlaps([a], _insights({
          a.path: [casp, casp],
        })),
        isEmpty,
      );
      expect(
        findResourceOverlaps([a, b], _insights({
          a.path: [casp, casp],
          b.path: [casp],
        })),
        {
          a.path: {b.path: 1},
          b.path: {a.path: 1},
        },
      );
    });
  });
}
