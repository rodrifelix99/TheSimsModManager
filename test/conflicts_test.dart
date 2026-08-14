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

/// What the lexical pass alone flags, which is what the library falls
/// back to with the package scan off.
Map<String, ConflictReason> _flagged(List<Mod> mods) =>
    conflictReasonsOf(findConflictPairs(mods, const {}));

void main() {
  test('flags enabled mods sharing a file name', () {
    final mods = [
      _mod('hair.package', r'C:\mods\hair.package'),
      _mod('hair.package', r'C:\mods\sub\hair.package'),
      _mod('sofa.package', r'C:\mods\sofa.package'),
    ];

    final conflicts = _flagged(mods);

    expect(conflicts, {
      r'C:\mods\hair.package': ConflictReason.duplicateName,
      r'C:\mods\sub\hair.package': ConflictReason.duplicateName,
    });
  });

  test('name comparison is case-insensitive', () {
    final mods = [
      _mod('Hair.package', r'C:\mods\Hair.package'),
      _mod('hair.package', r'C:\mods\sub\hair.package'),
    ];

    expect(_flagged(mods), hasLength(2));
  });

  test('disabled duplicates do not conflict', () {
    final mods = [
      _mod('hair.package', r'C:\mods\hair.package'),
      _mod('hair.package', r'C:\mods\sub\hair.package.disabled',
          enabled: false),
    ];

    expect(_flagged(mods), isEmpty);
  });

  test('flags two versions of the same mod', () {
    final mods = [
      _mod('CoolHair_v1.package', r'C:\mods\CoolHair_v1.package'),
      _mod('CoolHair_v2.package', r'C:\mods\sub\CoolHair_v2.package'),
      _mod('sofa.package', r'C:\mods\sofa.package'),
    ];

    expect(_flagged(mods), {
      r'C:\mods\CoolHair_v1.package': ConflictReason.versionPair,
      r'C:\mods\sub\CoolHair_v2.package': ConflictReason.versionPair,
    });
  });

  test('version matching ignores separators and casing', () {
    final mods = [
      _mod('cool_hair_v1.36.package', r'C:\mods\cool_hair_v1.36.package'),
      _mod('Cool Hair 1.37.package', r'C:\mods\Cool Hair 1.37.package'),
    ];

    expect(_flagged(mods), hasLength(2));
  });

  test('a versioned mod next to an unversioned one is not flagged', () {
    final mods = [
      _mod('CoolHair.package', r'C:\mods\CoolHair.package'),
      _mod('CoolHair_v2.package', r'C:\mods\CoolHair_v2.package'),
    ];

    expect(_flagged(mods), isEmpty);
  });

  test('a disabled old version does not conflict with the new one', () {
    final mods = [
      _mod('CoolHair_v2.package', r'C:\mods\CoolHair_v2.package'),
      _mod('CoolHair_v1.package', r'C:\mods\CoolHair_v1.package.disabled',
          enabled: false),
    ];

    expect(_flagged(mods), isEmpty);
  });

  test('same version twice falls under the duplicate-name rule only', () {
    final mods = [
      _mod('CoolHair_v2.package', r'C:\mods\CoolHair_v2.package'),
      _mod('CoolHair_v2.package', r'C:\mods\sub\CoolHair_v2.package'),
    ];

    final conflicts = _flagged(mods);
    expect(conflicts, hasLength(2));
    expect(conflicts.values,
        everyElement(ConflictReason.duplicateName));
  });

  test('different mods with versions do not cross-flag', () {
    final mods = [
      _mod('CoolHair_v1.package', r'C:\mods\CoolHair_v1.package'),
      _mod('WarmSofa_v2.package', r'C:\mods\WarmSofa_v2.package'),
    ];

    expect(_flagged(mods), isEmpty);
  });

  group('findConflictPairs', () {
    test('pairs every mod in a duplicate-name group with the others', () {
      final mods = [
        _mod('hair.package', r'C:\mods\hair.package'),
        _mod('hair.package', r'C:\mods\sub\hair.package'),
        _mod('hair.package', r'C:\mods\other\hair.package'),
        _mod('sofa.package', r'C:\mods\sofa.package'),
      ];

      final pairs = findConflictPairs(mods, const {});

      expect(pairs.keys, hasLength(3));
      expect(pairs[r'C:\mods\hair.package'], {
        r'C:\mods\sub\hair.package': ConflictReason.duplicateName,
        r'C:\mods\other\hair.package': ConflictReason.duplicateName,
      });
      expect(pairs, isNot(contains(r'C:\mods\sofa.package')));
    });

    test('a mod is never paired with itself', () {
      final mods = [_mod('hair.package', r'C:\mods\hair.package')];

      expect(findConflictPairs(mods, const {}), isEmpty);
    });

    test('overlaps join the pairs, and a lexical reason wins the pair', () {
      final a = _mod('hair.package', r'C:\mods\hair.package');
      final b = _mod('hair.package', r'C:\mods\sub\hair.package');
      final c = _mod('sofa.package', r'C:\mods\sofa.package');

      final pairs = findConflictPairs([a, b, c], {
        a.path: {b.path: 4, c.path: 2},
        b.path: {a.path: 4},
        c.path: {a.path: 2},
      });

      // The same name is the sharper thing to say about a and b, even
      // though their packages really do share resources too.
      expect(pairs[a.path], {
        b.path: ConflictReason.duplicateName,
        c.path: ConflictReason.resourceOverlap,
      });
      expect(pairs[c.path], {a.path: ConflictReason.resourceOverlap});
      expect(conflictReasonsOf(pairs), {
        a.path: ConflictReason.duplicateName,
        b.path: ConflictReason.duplicateName,
        c.path: ConflictReason.resourceOverlap,
      });
    });

    test('an overlap naming a disabled mod is dropped', () {
      final a = _mod('a.package', r'C:\mods\a.package');
      final off = _mod('b.package', r'C:\mods\b.package.disabled',
          enabled: false);

      final pairs = findConflictPairs([a, off], {
        a.path: {off.path: 3},
        off.path: {a.path: 3},
      });

      expect(pairs, isEmpty);
    });

    test('pair rows stop growing at the partner cap', () {
      final many = [
        for (var i = 0; i < 40; i++)
          _mod('same.package', 'C:\\mods\\m$i\\same.package'),
      ];

      final pairs = findConflictPairs(many, const {});

      expect(pairs, hasLength(40));
      for (final row in pairs.values) {
        expect(row.length, lessThanOrEqualTo(32));
      }
    });

    // A group of thousands - one basename across a whole CC dump - used
    // to be paired with itself squared, on the UI thread, on every
    // toggle. Only the first few members can ever be recorded, so the
    // walk is bounded by the cap.
    test('a huge duplicate-name group stays cheap', () {
      final many = [
        for (var i = 0; i < 3000; i++)
          _mod('merged.package', 'C:\\mods\\g$i\\merged.package'),
      ];

      final watch = Stopwatch()..start();
      final pairs = findConflictPairs(many, const {});
      watch.stop();

      expect(pairs, hasLength(3000));
      expect(watch.elapsedMilliseconds, lessThan(200));
    });

    // The overlaps are the signal the scan went to the trouble of
    // reading; 32 same-named siblings must not push them out.
    test('name twins do not crowd out a real overlap', () {
      final many = [
        for (var i = 0; i < 33; i++)
          _mod('mesh.package', 'C:\\mods\\m$i\\mesh.package'),
      ];
      final override = _mod('override.package', r'C:\mods\override.package');

      final pairs = findConflictPairs([...many, override], {
        many.first.path: {override.path: 40},
        override.path: {many.first.path: 40},
      });

      expect(pairs[many.first.path], contains(override.path));
      expect(pairs[many.first.path]![override.path],
          ConflictReason.resourceOverlap);
    });
  });

  group('exact duplicates', () {
    String? Function(Mod) digests(Map<String, String> byPath) =>
        (mod) => byPath[mod.path];

    test('same digest outranks every weaker reason for that pair', () {
      final a = _mod('hair.package', r'C:\mods\hair.package');
      final b = _mod('hair.package', r'C:\mods\sub\hair.package');

      final pairs = findConflictPairs([a, b], {
        a.path: {b.path: 9},
        b.path: {a.path: 9},
      }, digestOf: digests({a.path: 'abc', b.path: 'abc'}));

      // Same name and a real resource overlap are both true here, and
      // both are the long way round of saying it is the same file.
      expect(pairs[a.path], {b.path: ConflictReason.exactDuplicate});
      expect(conflictReasonsOf(pairs), {
        a.path: ConflictReason.exactDuplicate,
        b.path: ConflictReason.exactDuplicate,
      });
    });

    test('the same download under two names is caught with nothing else', () {
      final a = _mod('hair.package', r'C:\mods\hair.package');
      final b = _mod('hair-copy.package', r'C:\mods\hair-copy.package');

      // No shared name, no version token, no overlaps: the digest is the
      // only thing that knows.
      expect(_flagged([a, b]), isEmpty);
      expect(
        conflictReasonsOf(findConflictPairs([a, b], const {},
            digestOf: digests({a.path: 'abc', b.path: 'abc'}))),
        {
          a.path: ConflictReason.exactDuplicate,
          b.path: ConflictReason.exactDuplicate,
        },
      );
    });

    test('a disabled copy is not a conflict', () {
      final on = _mod('hair.package', r'C:\mods\hair.package');
      final off = _mod('hair.package', r'C:\mods\sub\hair.package.disabled',
          enabled: false);

      expect(
        findConflictPairs([on, off], const {},
            digestOf: digests({on.path: 'abc', off.path: 'abc'})),
        isEmpty,
      );
    });

    test('mods nothing has hashed are left to the weaker signals', () {
      final a = _mod('hair.package', r'C:\mods\hair.package');
      final b = _mod('hair.package', r'C:\mods\sub\hair.package');

      expect(
        conflictReasonsOf(
            findConflictPairs([a, b], const {}, digestOf: (_) => null)),
        {
          a.path: ConflictReason.duplicateName,
          b.path: ConflictReason.duplicateName,
        },
      );
    });

    test('different digests are not a duplicate', () {
      final a = _mod('hair.package', r'C:\mods\hair.package');
      final b = _mod('hair.package', r'C:\mods\sub\hair.package');

      expect(
        conflictReasonsOf(findConflictPairs([a, b], const {},
            digestOf: digests({a.path: 'abc', b.path: 'def'}))),
        {
          a.path: ConflictReason.duplicateName,
          b.path: ConflictReason.duplicateName,
        },
      );
    });

    // The budget is what a mod with 32 same-named siblings spends before
    // anything sharper is recorded, so the copies go in first.
    test('name twins do not crowd out an identical file', () {
      final many = [
        for (var i = 0; i < 40; i++)
          _mod('same.package', 'C:\\mods\\m$i\\same.package'),
      ];
      final copy = _mod('other.package', r'C:\mods\other.package');

      final pairs = findConflictPairs([...many, copy], const {},
          digestOf: digests({many.last.path: 'abc', copy.path: 'abc'}));

      expect(pairs[many.last.path], contains(copy.path));
      expect(
          pairs[many.last.path]![copy.path], ConflictReason.exactDuplicate);
    });
  });

  // Which of the four signals the user still wants to hear about. Asked
  // for by a player whose CC is deliberately kept in several versions:
  // every shelf of it was flagged, and settling those pairs one at a time
  // was the only way out (issue #20).
  group('the kinds Settings switches off', () {
    test('a muted signal is not reported', () {
      final mods = [
        _mod('CoolHair_v1.package', r'C:\mods\CoolHair_v1.package'),
        _mod('CoolHair_v2.package', r'C:\mods\CoolHair_v2.package'),
      ];

      expect(
        findConflictPairs(mods, const {},
            reasons: allConflictReasons.difference(
                {ConflictReason.versionPair})),
        isEmpty,
      );
    });

    test('the others keep working', () {
      final mods = [
        _mod('CoolHair_v1.package', r'C:\mods\CoolHair_v1.package'),
        _mod('CoolHair_v2.package', r'C:\mods\CoolHair_v2.package'),
        _mod('sofa.package', r'C:\mods\sofa.package'),
        _mod('sofa.package', r'C:\mods\sub\sofa.package'),
      ];

      expect(
        conflictReasonsOf(findConflictPairs(mods, const {},
            reasons: allConflictReasons
                .difference({ConflictReason.versionPair}))),
        {
          r'C:\mods\sofa.package': ConflictReason.duplicateName,
          r'C:\mods\sub\sofa.package': ConflictReason.duplicateName,
        },
      );
    });

    // Muting the sharpest reason a pair has must leave the pair standing
    // under the next one, not take the pair with it: these two files
    // really do share a name whether or not anyone wants to hear that
    // they are also byte-identical.
    test('a pair falls back to the sharpest reason it has left', () {
      final a = _mod('hair.package', r'C:\mods\hair.package');
      final b = _mod('hair.package', r'C:\mods\sub\hair.package');

      expect(
        conflictReasonsOf(findConflictPairs([a, b], const {},
            digestOf: (mod) => 'abc',
            reasons: allConflictReasons
                .difference({ConflictReason.exactDuplicate}))),
        {
          a.path: ConflictReason.duplicateName,
          b.path: ConflictReason.duplicateName,
        },
      );
    });

    test('muted overlaps are dropped even when they were scanned', () {
      final a = _mod('a.package', r'C:\mods\a.package');
      final b = _mod('b.package', r'C:\mods\b.package');

      expect(
        findConflictPairs([a, b], {
          a.path: {b.path: 12},
          b.path: {a.path: 12},
        }, reasons: allConflictReasons
            .difference({ConflictReason.resourceOverlap})),
        isEmpty,
      );
    });

    test('nothing wanted is nothing flagged', () {
      final mods = [
        _mod('hair.package', r'C:\mods\hair.package'),
        _mod('hair.package', r'C:\mods\sub\hair.package'),
      ];

      expect(findConflictPairs(mods, const {}, reasons: const {}), isEmpty);
    });
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

    test('the editor name map two script mods both carry is not a clash', () {
      // s3pe and NRaasPacker both add the _KEY resource at this exact
      // key the moment a resource in the package is given a name, which
      // the pure-scripting tutorial has every script mod do. Two NRaas
      // mods, or a font default next to a script mod, share it and
      // nothing else - the game never reads it.
      const nameMap = ResourceKey(0x0166038C, 0, 0);
      const manifest = ResourceKey(0x73E93EEB, 0, 0x8A7F1C);
      final a = _mod('NRaas_Overwatch.package', r'C:\mods\NRaas_Overwatch.package');
      final b = _mod('NRaas_ErrorTrap.package', r'C:\mods\NRaas_ErrorTrap.package');

      final overlaps = findResourceOverlaps([a, b], _insights({
        a.path: [nameMap, manifest, const ResourceKey(0x073FAA07, 0, 0x111)],
        b.path: [nameMap, manifest, const ResourceKey(0x073FAA07, 0, 0x222)],
      }));

      expect(overlaps, isEmpty);
    });

    test('an ignored type does not hide a real overlap in the same pair', () {
      const nameMap = ResourceKey(0x0166038C, 0, 0);
      final a = _mod('a.package', r'C:\mods\a.package');
      final b = _mod('b.package', r'C:\mods\b.package');

      final overlaps = findResourceOverlaps([a, b], _insights({
        a.path: [nameMap, tuning],
        b.path: [nameMap, tuning],
      }));

      expect(overlaps, {
        a.path: {b.path: 1},
        b.path: {a.path: 1},
      });
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
