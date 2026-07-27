import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/mod_advisories.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';

Mod _mod(String name, {bool enabled = true}) => Mod(
      name: name,
      path: '/mods/$name${enabled ? '' : '.disabled'}',
      status: enabled ? ModStatus.enabled : ModStatus.disabled,
    );

PackageInsight _insight(List<ResourceKey> keys) => PackageInsight(keys: keys);

/// insightOf backed by a name -> keys map; anything unlisted scans as null,
/// like a file the artwork scan never read.
PackageInsight? Function(Mod) _insights(Map<String, PackageInsight> byName) =>
    (mod) => byName[mod.name];

const _keysA = [
  ResourceKey(0x034AEECB, 0x00000000, 0x0123456789ABCDEF),
  ResourceKey(0x220557DA, 0x80000000, 0x7EDCBA9876543210),
];

String _file(List<Object?> advisories, {int version = 1}) =>
    '{"version": $version, "updated": "2026-07-27", "games": '
    '{"sims4": ${_json(advisories)}}}';

String _json(Object? value) {
  if (value is String) return '"$value"';
  if (value is List) return '[${value.map(_json).join(',')}]';
  if (value is Map) {
    return '{${value.entries.map((e) => '"${e.key}":${_json(e.value)}').join(',')}}';
  }
  return '$value';
}

void main() {
  group('fingerprintOf', () {
    test('is stable across builds', () {
      // Pinned on purpose. Every fingerprint published in
      // docs/data/advisories.json was produced by this function, so a
      // change here silently stops the whole list matching anything - the
      // one failure mode of this feature that nobody would notice.
      expect(fingerprintOf(_insight(_keysA)), '6a9696f4052261f7');
    });

    test('ignores key order and repeats', () {
      final shuffled = _insight([_keysA[1], _keysA[0], _keysA[0]]);
      expect(fingerprintOf(shuffled), fingerprintOf(_insight(_keysA)));
    });

    test('separates different contents', () {
      final other = _insight(
          [_keysA[0], const ResourceKey(0x220557DA, 0x80000000, 0x1)]);
      expect(fingerprintOf(other), isNot(fingerprintOf(_insight(_keysA))));
    });

    test('handles instances with the top bit set', () {
      final high = _insight(
          [const ResourceKey(0x1, 0x2, -1)]); // 0xFFFFFFFFFFFFFFFF
      expect(fingerprintOf(high), hasLength(16));
    });

    test('is null without keys', () {
      expect(fingerprintOf(null), isNull);
      expect(fingerprintOf(const PackageInsight()), isNull);
      // A package over maxRetainedKeys reports no keys at all.
      expect(fingerprintOf(const PackageInsight(resourceCount: 90000)), isNull);
    });
  });

  group('parseAdvisories', () {
    Map<String, Object?> entry({
      String id = 'a',
      String title = 'A mod',
      String status = 'broken',
      Object? identities = const ['a mod.package'],
    }) =>
        {'id': id, 'title': title, 'status': status, 'identities': identities};

    test('reads a well-formed file', () {
      final games = parseAdvisories(_file([
        {
          ...entry(),
          'since': 'the July patch',
          'note': 'Remove it.',
          'url': 'https://example.com/fix',
          'versions': ['1.2'],
        }
      ]));
      final advisory = games['sims4']!.single;
      expect(advisory.id, 'a');
      expect(advisory.title, 'A mod');
      expect(advisory.status, AdvisoryStatus.broken);
      expect(advisory.since, 'the July patch');
      expect(advisory.note, 'Remove it.');
      expect(advisory.url, 'https://example.com/fix');
      expect(advisory.versions, {'1.2'});
      expect(advisory.identities, {'a mod.package'});
    });

    test('lowercases match keys', () {
      final games = parseAdvisories(_file([
        {
          ...entry(identities: const ['A Mod.Package']),
          'fingerprints': ['ABCDEF0123456789'],
        }
      ]));
      final advisory = games['sims4']!.single;
      expect(advisory.identities, {'a mod.package'});
      expect(advisory.fingerprints, {'abcdef0123456789'});
    });

    test('drops entries it cannot trust, keeping the rest', () {
      final games = parseAdvisories(_file([
        entry(id: 'good'),
        entry(id: '', title: 'no id'),
        {'id': 'no-title', 'status': 'broken'},
        entry(id: 'unknown-status', status: 'exploded'),
        {'id': 'no-keys', 'title': 'x', 'status': 'broken'},
        'not an object',
      ]));
      expect(games['sims4']!.map((a) => a.id), ['good']);
    });

    test('refuses a schema version it does not know', () {
      expect(parseAdvisories(_file([entry()], version: 2)), isEmpty);
    });

    test('survives anything malformed', () {
      expect(parseAdvisories('not json'), isEmpty);
      expect(parseAdvisories('[]'), isEmpty);
      expect(parseAdvisories('{"version": 1}'), isEmpty);
      expect(parseAdvisories('{"version": 1, "games": []}'), isEmpty);
      expect(parseAdvisories(''), isEmpty);
    });

    test('rejects a non-https fix link rather than opening it', () {
      final games = parseAdvisories(_file([
        {...entry(), 'url': 'http://example.com'}
      ]));
      expect(games['sims4']!.single.url, isNull);
    });
  });

  group('matchAdvisories', () {
    const byName = ModAdvisory(
      id: 'by-name',
      title: 'Named',
      status: AdvisoryStatus.broken,
      identities: {'mc command center.package'},
    );
    const byPrint = ModAdvisory(
      id: 'by-print',
      title: 'Fingerprinted',
      status: AdvisoryStatus.outdated,
      fingerprints: {'6a9696f4052261f7'},
    );

    test('matches on the file name', () {
      final mods = [_mod('MC_Command_Center.package'), _mod('other.package')];
      final found = matchAdvisories(mods, [byName], (_) => null);
      expect(found.keys, ['/mods/MC_Command_Center.package']);
      expect(found.values.single.id, 'by-name');
    });

    test('matches renamed files on their contents', () {
      final mods = [_mod('renamed by the user.package')];
      final found = matchAdvisories(
          mods, [byPrint], _insights({mods.first.name: _insight(_keysA)}));
      expect(found.values.single.id, 'by-print');
    });

    test('prefers contents over the name', () {
      final mods = [_mod('MC_Command_Center.package')];
      final found = matchAdvisories(mods, [byName, byPrint],
          _insights({mods.first.name: _insight(_keysA)}));
      expect(found.values.single.id, 'by-print');
    });

    test('leaves disabled mods alone', () {
      final mods = [_mod('MC_Command_Center.package', enabled: false)];
      expect(matchAdvisories(mods, [byName], (_) => null), isEmpty);
    });

    test('honours a version constraint', () {
      const versioned = ModAdvisory(
        id: 'versioned',
        title: 'Old versions only',
        status: AdvisoryStatus.outdated,
        identities: {'hair.package'},
        versions: {'1.2'},
      );
      matcher(String name) =>
          matchAdvisories([_mod(name)], [versioned], (_) => null);
      expect(matcher('hair_v1.2.package'), isNotEmpty);
      expect(matcher('hair_v1.3.package'), isEmpty);
      // No version in the name: nothing to compare, so nothing is claimed.
      expect(matcher('hair.package'), isEmpty);
    });

    test('matches every version when unconstrained', () {
      final found = matchAdvisories(
          [_mod('MC_Command_Center_v2.0.package')], [byName], (_) => null);
      expect(found, isNotEmpty);
    });

    test('is empty with nothing published', () {
      expect(matchAdvisories([_mod('a.package')], const [], (_) => null),
          isEmpty);
    });
  });

  test('the published advisory file parses', () {
    // A file edited by hand and served straight to users should not be able
    // to ship broken.
    final file = File('web/public/data/advisories.json');
    expect(file.existsSync(), isTrue,
        reason: 'web/public/data/advisories.json');
    final games = parseAdvisories(file.readAsStringSync());
    final ids = [
      for (final list in games.values)
        for (final advisory in list) advisory.id,
    ];
    expect(ids.toSet(), hasLength(ids.length), reason: 'duplicate advisory id');
  });
}
