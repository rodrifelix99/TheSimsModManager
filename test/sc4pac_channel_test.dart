import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sims_mod_manager/src/core/mod_catalog.dart';
import 'package:sims_mod_manager/src/games/simcity/sc4pac_channel.dart';

/// The index as the live channels write it, trimmed to the fields this
/// app reads. Shapes taken from `sc4pac-channel-contents.json` on
/// memo33.github.io.
String _index({
  List<Map<String, Object?>> packages = const [],
  List<Map<String, Object?>> assets = const [],
}) =>
    jsonEncode({
      'scheme': 9,
      'info': {
        'channelLabel': ['Main'],
      },
      'stats': {'totalPackageCount': packages.length},
      'packages': packages,
      'assets': assets,
    });

Map<String, Object?> _pkgRow(
  String group,
  String name, {
  String version = '1.0',
  String summary = '',
  List<String> category = const [],
  Map<String, Object?> externalIds = const {},
}) =>
    {
      'group': group,
      'name': name,
      'versions': [version],
      'summary': summary,
      'category': category,
      'externalIds': externalIds,
    };

Map<String, Object?> _assetRow(String name, {String version = '1.0'}) =>
    {
      'name': name,
      'versions': [version],
    };

Map<String, Object?> _pkg(
  String group,
  String name, {
  String version = '1.0',
  List<Map<String, Object?>> variants = const [],
  Map<String, Object?> info = const {},
  Object? variantChoices,
  Object? variantInfo,
}) =>
    {
      r'$type': 'Package',
      'group': group,
      'name': name,
      'version': version,
      'info': info,
      'variants': variants,
      if (variantChoices != null) 'variantChoices': variantChoices,
      if (variantInfo != null) 'variantInfo': variantInfo,
    };

Map<String, Object?> _asset(String id, String url, {String? checksum}) => {
      r'$type': 'Asset',
      'assetId': id,
      'version': '1.0',
      'url': url,
      'lastModified': '2025-05-23T10:39:57Z',
      if (checksum != null) 'checksum': {'sha256': checksum},
    };

/// A fetcher answering from a map of URL to body, so a closure walk can
/// be pinned without a network.
Future<String?> Function(Uri) _server(
  Map<String, Object?> routes, {
  List<Uri>? log,
}) =>
    (Uri url) async {
      log?.add(url);
      final body = routes[url.toString()];
      if (body == null) return null;
      return body is String ? body : jsonEncode(body);
    };

const _base = 'https://example.test/channel/';
String _meta(String group, String name, [String version = '1.0']) =>
    '${_base}metadata/$group/$name/$version/pkg.json';

void main() {
  group('index', () {
    test('reads packages, versions and the asset version table', () {
      final index = parseSc4pacIndex(
        _index(
          packages: [
            _pkgRow('bsc', 'mega-props-vol03',
                version: '2.1',
                summary: 'BSC Mega Props Vol03',
                category: ['100-props-textures'],
                externalIds: {
                  'stex': ['31419']
                }),
          ],
          assets: [_assetRow('bsc-mega-props-vol03', version: '2.1')],
        ),
        'sc4pac-main',
      );

      expect(index.entries, hasLength(1));
      final entry = index.entries.single;
      expect(entry.id, 'bsc:mega-props-vol03');
      expect(entry.name, 'BSC Mega Props Vol03');
      expect(entry.version, '2.1');
      expect(entry.categories, ['100-props-textures']);
      expect(entry.externalIds['stex'], ['31419']);
      expect(index.versions['bsc:mega-props-vol03'], '2.1');
      expect(index.versions['sc4pacAsset:bsc-mega-props-vol03'], '2.1');
    });

    test('a malformed row costs itself and not the rest of the index', () {
      final index = parseSc4pacIndex(
        _index(packages: [
          {'group': 'bsc'}, // no name, no versions
          _pkgRow('cam', 'colossus-addon-mod'),
        ]),
        'sc4pac-main',
      );
      expect(index.entries.map((e) => e.id), ['cam:colossus-addon-mod']);
    });

    test('a body that is not the index at all parses to nothing', () {
      expect(parseSc4pacIndex('<html>nope</html>', 'x').entries, isEmpty);
      expect(parseSc4pacIndex('[]', 'x').entries, isEmpty);
    });

    test('the package slug names an entry that carries no summary', () {
      final index = parseSc4pacIndex(
        _index(packages: [_pkgRow('bsc', 'mega-props-vol03')]),
        'x',
      );
      expect(index.entries.single.name, 'mega props vol03');
    });
  });

  group('variants', () {
    /// The Colossus Addon Mod really is written this way, and taking
    /// index zero resolves it to nothing at all. Found by sampling the
    /// live channel, where it made the catalog look far more installable
    /// than it is.
    final cam = parseSc4pacPackage(_pkg('cam', 'colossus-addon-mod', variants: [
      {
        'variant': {'CAM': 'no'},
      },
      {
        'variant': {'CAM': 'yes', 'cam:colossus-addon-mod:version': 'current'},
        'assets': [
          {'assetId': 'cam-colossus-addon-mod'}
        ],
        'dependencies': [
          {'group': 'bsc', 'name': 'common-dependencies'}
        ],
      },
    ]))!;

    test('an opt-out branch is never the default', () {
      final chosen = chooseSc4pacVariant(cam, const {});
      expect(chosen, isNotNull);
      expect(chosen!.assets.single.assetId, 'cam-colossus-addon-mod');
      expect(chosen.selection['CAM'], 'yes');
    });

    test('a selection is honoured even when it picks the empty branch', () {
      final chosen = chooseSc4pacVariant(cam, const {'CAM': 'no'});
      expect(chosen!.isEmpty, isTrue);
    });

    test('a partial selection still narrows', () {
      final pkg = parseSc4pacPackage(_pkg('a', 'b', variants: [
        {
          'variant': {'mode': 'seasonal'},
          'assets': [
            {'assetId': 'seasonal'}
          ],
        },
        {
          'variant': {'mode': 'winter'},
          'assets': [
            {'assetId': 'winter'}
          ],
        },
      ]))!;
      expect(
        chooseSc4pacVariant(pkg, const {'mode': 'winter'})!.assets.single.assetId,
        'winter',
      );
    });

    test('choices carry the curator gloss', () {
      final pkg = parseSc4pacPackage(_pkg(
        'a',
        'b',
        variants: [
          {
            'variant': {'a:b:mode': 'seasonal'},
          }
        ],
        variantChoices: [
          {
            'variantId': 'a:b:mode',
            'choices': ['seasonal', 'winter'],
          }
        ],
        variantInfo: {
          'a:b:mode': {
            'valueDescriptions': {
              'seasonal': 'trees changing appearance throughout the year',
            },
          },
        },
      ))!;
      expect(pkg.choices.single.values, ['seasonal', 'winter']);
      expect(
        pkg.choices.single.descriptions['seasonal'],
        startsWith('trees changing'),
      );
    });
  });

  group('assets', () {
    test('reads url, digest and date', () {
      final asset = parseSc4pacAsset(
        _asset('x', 'https://www.sc4evermore.com/x.zip', checksum: 'abc'),
      )!;
      expect(asset.url.host, 'www.sc4evermore.com');
      expect(asset.sha256, 'abc');
      expect(asset.lastModified?.year, 2025);
    });

    test('a non-http url is refused rather than followed', () {
      expect(parseSc4pacAsset(_asset('x', 'file:///etc/passwd')), isNull);
      expect(parseSc4pacAsset(_asset('x', 'javascript:alert(1)')), isNull);
    });
  });

  group('reach', () {
    test('Simtropolis and its subdomains are out of our reach', () {
      expect(sc4pacHostIsReachable('community.simtropolis.com'), isFalse);
      expect(sc4pacHostIsReachable('simtropolis.com'), isFalse);
      expect(sc4pacHostIsReachable('cdn.community.simtropolis.com'), isFalse);
    });

    test('the hosts that answer us are reachable', () {
      expect(sc4pacHostIsReachable('www.sc4evermore.com'), isTrue);
      expect(sc4pacHostIsReachable('github.com'), isTrue);
    });

    test('one blocked file in the closure blocks the whole entry', () {
      final assets = [
        CatalogAsset(id: 'a', url: Uri.parse('https://www.sc4evermore.com/a')),
        CatalogAsset(
            id: 'b', url: Uri.parse('https://community.simtropolis.com/b')),
      ];
      expect(sc4pacReachOf(assets, resolved: true), CatalogReach.browserOnly);
    });

    test('a closure that could not be walked is unresolved, not blocked', () {
      expect(sc4pacReachOf(const [], resolved: false), CatalogReach.unresolved);
    });
  });

  group('closure', () {
    /// A lot on SC4Evermore needing one prop pack, also on SC4Evermore:
    /// the shape that really is installable end to end.
    Map<String, Object?> reachableRoutes() => {
          '${_base}sc4pac-channel-contents.json': _index(
            packages: [
              _pkgRow('mattb325', 'lakehouse', summary: 'Lakehouse'),
              _pkgRow('bsc', 'props', summary: 'BSC Props'),
            ],
            assets: [_assetRow('mattb325-lakehouse'), _assetRow('bsc-props')],
          ),
          _meta('mattb325', 'lakehouse'): _pkg(
            'mattb325',
            'lakehouse',
            info: {
              'summary': 'Lakehouse',
              'description': 'A house by a lake.',
              'author': 'mattb325',
              'websites': ['https://www.sc4evermore.com/lakehouse'],
            },
            variants: [
              {
                'assets': [
                  {'assetId': 'mattb325-lakehouse'}
                ],
                'dependencies': [
                  {'group': 'bsc', 'name': 'props'}
                ],
              }
            ],
          ),
          _meta('bsc', 'props'): _pkg('bsc', 'props', variants: [
            {
              'assets': [
                {'assetId': 'bsc-props'}
              ],
            }
          ]),
          _meta('sc4pacAsset', 'mattb325-lakehouse'):
              _asset('mattb325-lakehouse', 'https://www.sc4evermore.com/a.zip'),
          _meta('sc4pacAsset', 'bsc-props'):
              _asset('bsc-props', 'https://www.sc4evermore.com/b.zip'),
        };

    test('walks dependencies and reports the whole closure', () async {
      final channel = Sc4pacChannel(
        const Sc4pacChannelInfo(id: 'x', label: 'Main', base: _base),
        fetch: _server(reachableRoutes()),
      );
      final entries = await channel.fetchEntries();
      final listing = await channel.fetchListing(
        entries!.firstWhere((e) => e.id == 'mattb325:lakehouse'),
      );

      expect(listing!.reach, CatalogReach.direct);
      expect(listing.canInstall, isTrue);
      expect(listing.assets.map((a) => a.id),
          containsAll(['mattb325-lakehouse', 'bsc-props']));
      expect(listing.dependencies.single.id, 'bsc:props');
      expect(listing.author, 'mattb325');
      expect(listing.description, 'A house by a lake.');
    });

    test('a dependency on a blocked host blocks the entry that needs it',
        () async {
      final routes = reachableRoutes();
      routes[_meta('sc4pacAsset', 'bsc-props')] = _asset(
        'bsc-props',
        'https://community.simtropolis.com/files/file/1-props/?do=download',
      );
      final channel = Sc4pacChannel(
        const Sc4pacChannelInfo(id: 'x', label: 'Main', base: _base),
        fetch: _server(routes),
      );
      final entries = await channel.fetchEntries();
      final listing = await channel.fetchListing(
        entries!.firstWhere((e) => e.id == 'mattb325:lakehouse'),
      );

      expect(listing!.reach, CatalogReach.browserOnly);
      expect(listing.canInstall, isFalse);
      expect(listing.unreachableHosts, ['community.simtropolis.com']);
    });

    test('a cycle in the metadata terminates', () async {
      final channel = Sc4pacChannel(
        const Sc4pacChannelInfo(id: 'x', label: 'Main', base: _base),
        fetch: _server({
          '${_base}sc4pac-channel-contents.json': _index(packages: [
            _pkgRow('a', 'one'),
            _pkgRow('b', 'two'),
          ]),
          _meta('a', 'one'): _pkg('a', 'one', variants: [
            {
              'dependencies': [
                {'group': 'b', 'name': 'two'}
              ],
            }
          ]),
          _meta('b', 'two'): _pkg('b', 'two', variants: [
            {
              'dependencies': [
                {'group': 'a', 'name': 'one'}
              ],
            }
          ]),
        }),
      );
      final entries = await channel.fetchEntries();
      final listing = await channel
          .fetchListing(entries!.firstWhere((e) => e.id == 'a:one'));
      expect(listing, isNotNull);
      expect(listing!.dependencies.map((d) => d.id), ['b:two']);
    });

    test('a package fetched twice is only fetched once', () async {
      final log = <Uri>[];
      final channel = Sc4pacChannel(
        const Sc4pacChannelInfo(id: 'x', label: 'Main', base: _base),
        fetch: _server(reachableRoutes(), log: log),
      );
      final entries = await channel.fetchEntries();
      final entry = entries!.firstWhere((e) => e.id == 'mattb325:lakehouse');
      await channel.fetchListing(entry);
      final first = log.length;
      await channel.fetchListing(entry);
      expect(log.length, first, reason: 'the second open re-fetched metadata');
    });

    test('an index that never answers is a failure with words for it',
        () async {
      final channel = Sc4pacChannel(
        const Sc4pacChannelInfo(id: 'x', label: 'Main', base: _base),
        fetch: (_) async => null,
      );
      expect(await channel.fetchEntries(), isNull);
      expect(channel.describeFailure(), isNotNull);
    });
  });

  test('the shipped channel list is the three sc4pac ships with', () {
    expect(sc4pacDefaultChannels.map((c) => c.label),
        ['Main', 'Simtropolis', 'SC4Evermore']);
    for (final channel in sc4pacDefaultChannels) {
      expect(channel.base, endsWith('/'), reason: 'urls are joined bare');
      expect(Uri.parse(channel.base).scheme, 'https');
      final source = channel.sourceFor('simcity4');
      expect(source.projectName, 'sc4pac');
      // The game travels with the catalog: it is what decides which
      // mods folder an install lands in, and when the chips show.
      expect(source.gameId, 'simcity4');
    }
  });
}
