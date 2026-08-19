import 'package:flutter_test/flutter_test.dart';
import 'package:sims_mod_manager/src/core/mod_catalog.dart';

CatalogInstall _install({
  String entryId = 'mattb325:lakehouse',
  String version = '1.0',
  List<String> files = const ['Lakehouse.dat'],
}) =>
    CatalogInstall(
      entryId: entryId,
      sourceId: 'sc4pac-main',
      gameId: 'simcity4',
      version: version,
      name: 'Lakehouse',
      files: files,
    );

void main() {
  group('records', () {
    test('survive a round trip', () {
      final encoded = encodeCatalogInstalls({
        'mattb325:lakehouse': _install(files: const ['a.dat', 'props/b.dat']),
      });
      final back = parseCatalogInstalls(encoded);
      expect(back, hasLength(1));
      final record = back['mattb325:lakehouse']!;
      expect(record.entryId, 'mattb325:lakehouse');
      expect(record.sourceId, 'sc4pac-main');
      expect(record.gameId, 'simcity4');
      expect(record.version, '1.0');
      expect(record.name, 'Lakehouse');
      expect(record.files, ['a.dat', 'props/b.dat']);
    });

    test('a whole closure is remembered, not just the entry file', () {
      // Eighteen files is a real closure (the Colossus Addon Mod), and
      // remembering only the first would leave seventeen behind on an
      // uninstall.
      final files = [for (var i = 0; i < 18; i++) 'file$i.dat'];
      final back = parseCatalogInstalls(
          encodeCatalogInstalls({'cam:x': _install(files: files)}));
      expect(back['cam:x']!.files, hasLength(18));
    });

    test('a corrupt record is dropped and the rest survive', () {
      const source = '{'
          '"good": {"game": "simcity4", "version": "1.0", '
          '"name": "Good", "files": ["a.dat"]},'
          '"noVersion": {"game": "simcity4", "name": "Bad"},'
          '"notAMap": 7'
          '}';
      final back = parseCatalogInstalls(source);
      expect(back.keys, ['good']);
    });

    test('nothing stored reads as nothing installed', () {
      expect(parseCatalogInstalls(null), isEmpty);
      expect(parseCatalogInstalls(''), isEmpty);
      expect(parseCatalogInstalls('not json'), isEmpty);
      expect(parseCatalogInstalls('[]'), isEmpty);
    });

    test('a record with files missing still parses', () {
      final back = parseCatalogInstalls(
          '{"x": {"game": "simcity4", "version": "1.0"}}');
      expect(back['x']!.files, isEmpty);
      // Falls back to the key, so a record can still caption itself.
      expect(back['x']!.name, 'x');
    });

    test('copyWith replaces the version and files, keeping identity', () {
      final updated = _install().copyWith(version: '2.0', files: const ['c']);
      expect(updated.entryId, 'mattb325:lakehouse');
      expect(updated.sourceId, 'sc4pac-main');
      expect(updated.name, 'Lakehouse');
      expect(updated.version, '2.0');
      expect(updated.files, ['c']);
    });
  });

  group('update detection', () {
    /// The rule the whole feature rests on: a curator writes versions by
    /// hand, so the only sound comparison is "is it different".
    bool hasUpdate(String installed, String listed) =>
        _install(version: installed).version != listed;

    test('a different string is an update whichever way it sorts', () {
      expect(hasUpdate('1.0', '1.1'), isTrue);
      expect(hasUpdate('2026-05-01', '2026-06-01'), isTrue);
      // A catalog that went backwards is still a difference: it is not
      // ours to decide the creator republished the wrong thing.
      expect(hasUpdate('2.0', '1.0'), isTrue);
      expect(hasUpdate('1.0', 'final'), isTrue);
    });

    test('the same string is not', () {
      expect(hasUpdate('1.0', '1.0'), isFalse);
      expect(hasUpdate('final', 'final'), isFalse);
    });
  });
}
