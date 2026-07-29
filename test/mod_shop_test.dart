import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sims_mod_manager/src/services/mod_shop.dart';

/// One Firestore runQuery row as the wire carries it.
Map<String, Object?> _row(String id, Map<String, Object?> fields) => {
      'document': {
        'name': 'projects/x/databases/(default)/documents/mods/$id',
        'fields': fields,
      },
      'readTime': '2026-07-27T10:00:00Z',
    };

Map<String, Object?> _listing({
  String id = 'abc123',
  String name = 'Better Build Camera',
  List<String> images = const ['mods/u1/abc123/images/1.png'],
}) =>
    _row(id, {
      'name': {'stringValue': name},
      'gameId': {'stringValue': 'sims4'},
      'version': {'stringValue': '1.2'},
      'description': {'stringValue': 'Frees the build mode camera.'},
      'instructions': {'stringValue': 'Enable script mods.'},
      'authorUid': {'stringValue': 'u1'},
      'authorName': {'stringValue': 'plumbob_pat'},
      'published': {'booleanValue': true},
      'file': {
        'mapValue': {
          'fields': {
            'path': {'stringValue': 'mods/u1/$id/camera.zip'},
            'name': {'stringValue': 'camera.zip'},
            'size': {'integerValue': '20480'},
          }
        }
      },
      'images': {
        'arrayValue': {
          'values': [
            for (final image in images) {'stringValue': image},
          ]
        }
      },
      'createdAt': {'timestampValue': '2026-07-01T09:30:00Z'},
      'updatedAt': {'timestampValue': '2026-07-20T18:00:00Z'},
      'downloads': {'integerValue': '1284'},
    });

/// A listing as the app holds it, for the grouping the shelves do.
ShopMod _mod({
  required String id,
  required String name,
  String? group,
  String authorUid = 'u1',
  String gameId = 'sims4',
}) =>
    ShopMod(
      id: id,
      gameId: gameId,
      name: name,
      version: '1.0',
      description: 'A recolour.',
      authorName: 'plumbob_pat',
      authorUid: authorUid,
      group: group,
      fileName: '$id.package',
      filePath: 'mods/$authorUid/$id/$id.package',
      fileSizeBytes: 2048,
      downloads: 1284,
    );

void main() {
  test('parses a runQuery response into listings', () {
    final body = jsonEncode([
      _listing(),
      // The response's trailing row carries only a readTime.
      {'readTime': '2026-07-27T10:00:00Z'},
    ]);
    final mods = parseShopListings(body);
    expect(mods, hasLength(1));
    final mod = mods.single;
    expect(mod.id, 'abc123');
    expect(mod.gameId, 'sims4');
    expect(mod.name, 'Better Build Camera');
    expect(mod.version, '1.2');
    expect(mod.authorName, 'plumbob_pat');
    expect(mod.instructions, 'Enable script mods.');
    expect(mod.fileName, 'camera.zip');
    expect(mod.filePath, 'mods/u1/abc123/camera.zip');
    expect(mod.fileSizeBytes, 20480);
    expect(mod.imagePaths, ['mods/u1/abc123/images/1.png']);
    expect(mod.updatedAt, DateTime.utc(2026, 7, 20, 18).toLocal());
    expect(mod.downloads, 1284);
  });

  test('a listing from before the counter reads zero downloads, not junk', () {
    final row = _listing();
    final fields =
        ((row['document']! as Map)['fields']! as Map).cast<String, Object?>();
    fields.remove('downloads');
    expect(parseShopListings(jsonEncode([row])).single.downloads, 0);

    // Nothing here is written by the app, so the wire is allowed to be
    // wrong; it must not come back as a negative count on a card.
    fields['downloads'] = {'integerValue': '-5'};
    expect(parseShopListings(jsonEncode([row])).single.downloads, 0);
  });

  test('drops rows missing required fields instead of failing the lot', () {
    final body = jsonEncode([
      _row('broken', {
        // No name, no file map: not installable, not showable.
        'gameId': {'stringValue': 'sims4'},
      }),
      _listing(id: 'ok'),
    ]);
    final mods = parseShopListings(body);
    expect(mods, hasLength(1));
    expect(mods.single.id, 'ok');
  });

  test('listing tolerates absent optional fields', () {
    final row = _listing(images: const []);
    final fields =
        ((row['document']! as Map)['fields']! as Map).cast<String, Object?>();
    fields.remove('instructions');
    fields.remove('updatedAt');
    final mods = parseShopListings(jsonEncode([row]));
    expect(mods.single.instructions, isNull);
    expect(mods.single.updatedAt, isNull);
    expect(mods.single.coverUri, isNull);
  });

  test('a set name is read, and a blank one is no set at all', () {
    final named = _listing();
    ((named['document']! as Map)['fields']! as Map)['group'] = {
      'stringValue': ' Comfy Sofa '
    };
    final blank = _listing(id: 'def456');
    ((blank['document']! as Map)['fields']! as Map)['group'] = {
      'stringValue': '   '
    };
    final mods = parseShopListings(jsonEncode([named, blank]));
    expect(mods.first.group, 'Comfy Sofa');
    expect(mods.last.group, isNull);
    expect(shopGroupKey(mods.last), isNull);
  });

  test('same creator, same set name, same game is one shelf entry', () {
    final groups = groupShopListings([
      _mod(id: 'a', name: 'Comfy Sofa - Sage', group: 'Comfy Sofa'),
      _mod(id: 'b', name: 'Lace Curtains'),
      _mod(id: 'c', name: 'Comfy Sofa - Rust', group: 'comfy  sofa'),
    ]);
    // The set keeps the place its most recent variation had, and the
    // creator's own spelling of the name.
    expect(groups.map((g) => g.name), ['Comfy Sofa', 'Lace Curtains']);
    expect(groups.first.isSet, isTrue);
    expect(groups.first.lead.id, 'a');
    // Reading order is the label's, not the catalog's: Rust before Sage.
    expect(groups.first.variants.map((m) => m.id), ['c', 'a']);
    expect(groups.last.isSet, isFalse);
    // Counted numbers add up; nothing is estimated for the set.
    expect(groups.first.downloads, 2568);
  });

  test('a set is one creator, one game - never two who chose the same name',
      () {
    final groups = groupShopListings([
      _mod(id: 'a', name: 'Sage', group: 'Comfy Sofa'),
      _mod(id: 'b', name: 'Rust', group: 'Comfy Sofa', authorUid: 'u2'),
      _mod(id: 'c', name: 'Bone', group: 'Comfy Sofa', gameId: 'sims3'),
      // A listing with no creator behind it is nobody's word to trust.
      _mod(id: 'd', name: 'Ink', group: 'Comfy Sofa', authorUid: ''),
    ]);
    expect(groups, hasLength(4));
    expect(groups.every((group) => !group.isSet), isTrue);
  });

  test('a variation is captioned by what its name adds to the set', () {
    expect(shopVariantLabel('Comfy Sofa', 'Comfy Sofa - Sage'), 'Sage');
    expect(shopVariantLabel('Comfy Sofa', 'Comfy Sofa (Sage)'), 'Sage');
    expect(shopVariantLabel('Comfy Sofa', 'comfy sofa: Sage'), 'Sage');
    // Nothing to strip, or nothing left after stripping: the creator's
    // own name for the listing stands.
    expect(shopVariantLabel('Comfy Sofa', 'Sage Sofa'), 'Sage Sofa');
    expect(shopVariantLabel('Comfy Sofa', 'Comfy Sofa'), 'Comfy Sofa');
    expect(shopVariantLabel('Comfy Sofa', 'Comfy Sofa -'), 'Comfy Sofa -');
  });

  test('non-JSON and non-list bodies parse to nothing', () {
    expect(parseShopListings('{}'), isEmpty);
    expect(() => parseShopListings('<html>captive portal</html>'),
        throwsFormatException);
  });

  test('install records survive a round trip through storage', () {
    final installs = {
      'l1': const ShopInstall(
        listingId: 'l1',
        gameId: 'sims4',
        version: '1.2',
        name: 'Camera Fix',
        files: ['camera.package', '../GameData/Skins/hair.skn'],
      ),
    };
    final parsed = parseShopInstalls(encodeShopInstalls(installs));
    expect(parsed, hasLength(1));
    expect(parsed['l1']!.gameId, 'sims4');
    expect(parsed['l1']!.version, '1.2');
    expect(parsed['l1']!.name, 'Camera Fix');
    expect(parsed['l1']!.files,
        ['camera.package', '../GameData/Skins/hair.skn']);
  });

  test('a corrupt install record costs only itself', () {
    final parsed = parseShopInstalls('{'
        '"good": {"game": "sims2", "version": "3", "files": ["a.package"]},'
        '"noVersion": {"game": "sims2"},'
        '"notAMap": 7'
        '}');
    expect(parsed.keys, ['good']);
    // A record written before the name was stored still loads.
    expect(parsed['good']!.name, '');
  });

  test('unreadable install storage parses to nothing', () {
    expect(parseShopInstalls(null), isEmpty);
    expect(parseShopInstalls(''), isEmpty);
    expect(parseShopInstalls('not json'), isEmpty);
    expect(parseShopInstalls('[]'), isEmpty);
  });

  test('parses the single-document endpoint, which carries no row', () {
    // The document itself, not a runQuery row around it.
    final body = jsonEncode(_listing()['document']);
    final mod = parseShopListing(body);
    expect(mod?.id, 'abc123');
    expect(mod?.name, 'Better Build Camera');
    expect(mod?.filePath, 'mods/u1/abc123/camera.zip');
  });

  test('a listing that is not one parses to null rather than throwing', () {
    expect(parseShopListing('{}'), isNull);
    expect(parseShopListing('not json at all'), isNull);
    expect(
        parseShopListing(jsonEncode({
          'error': {'code': 403, 'status': 'PERMISSION_DENIED'}
        })),
        isNull);
  });

  test('fetchShopListing reads one document by id', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final paths = <String>[];
    server.listen((request) async {
      paths.add(request.uri.path);
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode(_listing()['document']));
      await request.response.close();
    });
    final inner = HttpClient();
    addTearDown(() => inner.close(force: true));
    final mod = await HttpOverrides.runZoned(
      () => fetchShopListing('abc123'),
      createHttpClient: (_) => _RedirectingClient(server.port, inner),
    );
    expect(mod?.id, 'abc123');
    expect(paths.single, endsWith('/documents/mods/abc123'));
  });

  test('a taken-down or unpublished listing comes back as null', () async {
    // 404 and the 403 the rules answer an anonymous reader with for a
    // draft are the same answer here on purpose.
    for (final status in [HttpStatus.notFound, HttpStatus.forbidden]) {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      server.listen((request) async {
        request.response.statusCode = status;
        await request.response.close();
      });
      final inner = HttpClient();
      addTearDown(() => inner.close(force: true));
      final mod = await HttpOverrides.runZoned(
        () => fetchShopListing('abc123'),
        createHttpClient: (_) => _RedirectingClient(server.port, inner),
      );
      expect(mod, isNull, reason: 'HTTP $status');
    }
  });

  test('an id that is not one never reaches the wire', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    var requests = 0;
    server.listen((request) async {
      requests++;
      await request.response.close();
    });
    final inner = HttpClient();
    addTearDown(() => inner.close(force: true));
    for (final id in ['../../users/x', 'a/b', '', 'a' * 65, 'a b']) {
      final mod = await HttpOverrides.runZoned(
        () => fetchShopListing(id),
        createHttpClient: (_) => _RedirectingClient(server.port, inner),
      );
      expect(mod, isNull, reason: id);
    }
    expect(requests, 0);
  });

  test('a listing page address is the one the website serves', () {
    expect(shopListingUrl('abc123'),
        'https://thesimsmodmanager.web.app/m/abc123');
  });

  test('download URL keeps the object path as one encoded segment', () {
    final uri = shopFileUri('mods/u1/abc/My Mod v1.zip');
    expect(uri.toString(),
        contains('/o/mods%2Fu1%2Fabc%2FMy%20Mod%20v1.zip'));
    expect(uri.queryParameters['alt'], 'media');
  });

  test('downloadShopFile writes the body and reports progress', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    final payload = List<int>.generate(64 * 1024, (i) => i % 251);
    server.listen((request) async {
      request.response.headers.contentType = ContentType.binary;
      request.response.contentLength = payload.length;
      request.response.add(payload);
      await request.response.close();
    });
    final dir = Directory.systemTemp.createTempSync('shop_dl');
    addTearDown(() => dir.deleteSync(recursive: true));
    final mod = ShopMod(
      id: 'x',
      gameId: 'sims4',
      name: 'X',
      version: '1',
      description: '',
      authorName: 'a',
      fileName: 'x.package',
      filePath: 'mods/u/x/x.package',
      fileSizeBytes: payload.length,
    );
    final dest = File(p.join(dir.path, 'x.package'));
    final progress = <(int, int)>[];
    // The service derives its URL from the real bucket; an HttpOverrides
    // zone reroutes the request to the local server. The inner client is
    // created outside the zone so the override can't recurse into itself.
    final inner = HttpClient();
    addTearDown(() => inner.close(force: true));
    await HttpOverrides.runZoned(
      () => downloadShopFile(mod, dest,
          onProgress: (received, total) => progress.add((received, total))),
      createHttpClient: (_) => _RedirectingClient(server.port, inner),
    );
    expect(dest.readAsBytesSync(), payload);
    expect(progress, isNotEmpty);
    expect(progress.last.$1, payload.length);
    expect(progress.last.$2, payload.length);
  });

  test('a failed download throws and leaves no partial file', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(() => server.close(force: true));
    server.listen((request) async {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
    });
    final dir = Directory.systemTemp.createTempSync('shop_dl404');
    addTearDown(() => dir.deleteSync(recursive: true));
    final mod = ShopMod(
      id: 'x',
      gameId: 'sims4',
      name: 'X',
      version: '1',
      description: '',
      authorName: 'a',
      fileName: 'x.package',
      filePath: 'mods/u/x/x.package',
      fileSizeBytes: 10,
    );
    final dest = File(p.join(dir.path, 'x.package'));
    final inner = HttpClient();
    addTearDown(() => inner.close(force: true));
    await expectLater(
      HttpOverrides.runZoned(
        () => downloadShopFile(mod, dest),
        createHttpClient: (_) => _RedirectingClient(server.port, inner),
      ),
      throwsA(isA<HttpException>()),
    );
    expect(dest.existsSync(), isFalse);
  });
}

/// Sends every request to the local test server, whatever host the
/// service asked for. Only the members the download path touches are
/// implemented; anything else failing loudly is the point.
class _RedirectingClient implements HttpClient {
  _RedirectingClient(this.port, this.inner);

  final int port;
  final HttpClient inner;

  @override
  Duration? get connectionTimeout => inner.connectionTimeout;

  @override
  set connectionTimeout(Duration? value) => inner.connectionTimeout = value;

  @override
  Future<HttpClientRequest> getUrl(Uri url) =>
      inner.getUrl(url.replace(scheme: 'http', host: '127.0.0.1', port: port));

  @override
  void close({bool force = false}) {
    // The test owns the inner client's lifetime; the service closing its
    // wrapper must not tear down a client another test still holds.
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('unused in tests: ${invocation.memberName}');
}
