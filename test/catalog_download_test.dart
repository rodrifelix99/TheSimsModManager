import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sims_mod_manager/src/core/mod_catalog.dart';
import 'package:sims_mod_manager/src/services/catalog_download.dart';

CatalogAsset _asset(String id, String path, {String? sha256}) => CatalogAsset(
      id: id,
      url: Uri.parse('http://127.0.0.1/$path'),
      sha256: sha256,
    );

/// A real loopback server, because the thing under test is an
/// HttpClient talking to a host that decides the file name in a header
/// and the size in another. A fake would only pin our own assumptions
/// about both.
class _Host {
  _Host(this.server);

  final HttpServer server;
  final requested = <String>[];

  static Future<_Host> start(
    Map<String, List<int>> files, {
    Map<String, String?> dispositions = const {},
    Set<String> fail = const {},
    Duration? chunkDelay,
  }) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final host = _Host(server);
    server.listen((request) async {
      final path = request.uri.path.substring(1);
      host.requested.add(path);
      if (fail.contains(path) || !files.containsKey(path)) {
        request.response.statusCode = 404;
        await request.response.close();
        return;
      }
      final bytes = files[path]!;
      final disposition = dispositions.containsKey(path)
          ? dispositions[path]
          : 'attachment; filename="$path"';
      if (disposition != null) {
        request.response.headers.set('content-disposition', disposition);
      }
      request.response.headers.contentLength = bytes.length;
      // Written in pieces so a cancel has somewhere to land.
      for (var i = 0; i < bytes.length; i += 1024) {
        request.response
            .add(bytes.sublist(i, (i + 1024).clamp(0, bytes.length)));
        await request.response.flush();
        if (chunkDelay != null) await Future<void>.delayed(chunkDelay);
      }
      await request.response.close();
    });
    return host;
  }

  int get port => server.port;
  Future<void> stop() => server.close(force: true);
}

CatalogAsset _at(_Host host, String path, {String? sha256}) => CatalogAsset(
      id: path,
      url: Uri.parse('http://127.0.0.1:${host.port}/$path'),
      sha256: sha256,
    );

void main() {
  late Directory scratch;

  setUp(() async {
    scratch = await Directory.systemTemp.createTemp('catalog_dl_');
  });

  tearDown(() async {
    try {
      await scratch.delete(recursive: true);
    } catch (_) {}
  });

  group('file names', () {
    test('the host header wins, because the URL often carries no name', () {
      final asset = CatalogAsset(
        id: 'blam-fk',
        url: Uri.parse(
            'https://www.sc4evermore.com/index.php/downloads?task=download.send&id=390:blam'),
      );
      expect(
        catalogFileName(asset,
            contentDisposition:
                'attachment; filename="BLaM FK HIDP Mega Props.zip"'),
        'BLaM FK HIDP Mega Props.zip',
      );
    });

    test('a path in the header is discarded, never followed', () {
      final asset = _asset('x', 'a');
      expect(
        catalogFileName(asset,
            contentDisposition:
                r'attachment; filename="..\..\Windows\System32\evil.dll"'),
        'evil.dll',
      );
      expect(
        catalogFileName(asset,
            contentDisposition: 'attachment; filename="/etc/passwd"'),
        'passwd',
      );
    });

    test('the RFC 5987 form is preferred when both are present', () {
      expect(
        catalogFileName(
          _asset('x', 'a'),
          contentDisposition:
              "attachment; filename=\"plain.zip\"; filename*=UTF-8''caf%C3%A9.zip",
        ),
        'café.zip',
      );
    });

    test('falls back to the URL segment, then to the asset id', () {
      expect(catalogFileName(_asset('x', 'props/pack.zip')), 'pack.zip');
      // No extension on the segment, so it is not treated as a name.
      expect(catalogFileName(_asset('bsc-props', 'downloads')), 'bsc-props');
    });
  });

  group('downloading', () {
    test('fetches a closure in order and reports progress', () async {
      final host = await _Host.start({
        'a.zip': List.filled(4096, 1),
        'b.zip': List.filled(2048, 2),
      });
      addTearDown(host.stop);

      final seen = <String>[];
      final result = await downloadCatalogAssets(
        [_at(host, 'a.zip'), _at(host, 'b.zip')],
        scratch,
        onProgress: (p) => seen.add('${p.index + 1}/${p.count}'),
      );

      expect(host.requested, ['a.zip', 'b.zip']);
      expect(result, hasLength(2));
      expect(await result[0].file.readAsBytes(), hasLength(4096));
      expect(result[0].file.path, endsWith('a.zip'));
      expect(seen.first, '1/2');
      expect(seen.last, '2/2');
    });

    test('two files of the same name do not collide', () async {
      final host = await _Host.start({
        'one/pack.zip': List.filled(16, 1),
        'two/pack.zip': List.filled(32, 2),
      }, dispositions: {
        'one/pack.zip': 'attachment; filename="pack.zip"',
        'two/pack.zip': 'attachment; filename="pack.zip"',
      });
      addTearDown(host.stop);

      final result = await downloadCatalogAssets(
        [_at(host, 'one/pack.zip'), _at(host, 'two/pack.zip')],
        scratch,
      );
      expect(result[0].file.path, isNot(result[1].file.path));
      expect(await result[0].file.length(), 16);
      expect(await result[1].file.length(), 32);
    });

    test('a digest mismatch is recorded and does not stop the download',
        () async {
      final host = await _Host.start({'a.zip': List.filled(64, 7)});
      addTearDown(host.stop);

      final result = await downloadCatalogAssets(
        [_at(host, 'a.zip', sha256: 'not-the-right-digest')],
        scratch,
      );
      expect(result.single.digestMatched, isFalse);
      expect(await result.single.file.exists(), isTrue);
    });

    test('a matching digest is recognised', () async {
      final bytes = List.filled(64, 7);
      final host = await _Host.start({'a.zip': bytes});
      addTearDown(host.stop);

      // Hashed by the same library the downloader uses, so the test
      // pins the wiring rather than restating the algorithm.
      final expected = await downloadCatalogAssets(
        [_at(host, 'a.zip')],
        scratch,
      );
      final digest = await _sha256Of(expected.single.file);

      final again = await downloadCatalogAssets(
        [_at(host, 'a.zip', sha256: digest.toUpperCase())],
        scratch,
      );
      expect(again.single.digestMatched, isTrue,
          reason: 'a digest recorded in upper case still matches');
    });

    test('one failure takes the whole set with it', () async {
      final host = await _Host.start(
        {'a.zip': List.filled(1024, 1)},
        fail: {'b.zip'},
      );
      addTearDown(host.stop);

      await expectLater(
        downloadCatalogAssets(
          [_at(host, 'a.zip'), _at(host, 'b.zip')],
          scratch,
        ),
        throwsA(isA<CatalogDownloadException>()
            .having((e) => e.cancelled, 'cancelled', isFalse)),
      );

      // Nothing installable is left behind: a half-downloaded closure is
      // exactly the brown-box state this avoids.
      final left = await scratch
          .list(recursive: true)
          .where((e) => e is File)
          .toList();
      expect(left, isEmpty);
    });

    test('cancelling mid-file stops and leaves nothing behind', () async {
      final host = await _Host.start(
        {'big.zip': List.filled(64 * 1024, 3)},
        chunkDelay: const Duration(milliseconds: 5),
      );
      addTearDown(host.stop);

      var calls = 0;
      await expectLater(
        downloadCatalogAssets(
          [_at(host, 'big.zip')],
          scratch,
          isCancelled: () => ++calls > 3,
        ),
        throwsA(isA<CatalogDownloadException>()
            .having((e) => e.cancelled, 'cancelled', isTrue)),
      );

      final left = await scratch
          .list(recursive: true)
          .where((e) => e is File)
          .toList();
      expect(left, isEmpty);
    });

    test('cancelling before the second file never requests it', () async {
      final host = await _Host.start({
        'a.zip': List.filled(64, 1),
        'b.zip': List.filled(64, 2),
      });
      addTearDown(host.stop);

      var done = false;
      await expectLater(
        downloadCatalogAssets(
          [_at(host, 'a.zip'), _at(host, 'b.zip')],
          scratch,
          isCancelled: () => done,
          onProgress: (p) {
            if (p.index == 0 && p.fraction == 1.0) done = true;
          },
        ),
        throwsA(isA<CatalogDownloadException>()),
      );
      expect(host.requested, ['a.zip']);
    });
  });

  group('progress', () {
    test('overall spans the batch rather than the current file', () {
      const first = CatalogDownloadProgress(index: 0, count: 4, fraction: 0.5);
      const last = CatalogDownloadProgress(index: 3, count: 4, fraction: 1.0);
      expect(first.overall, closeTo(0.125, 0.001));
      expect(last.overall, 1.0);
    });

    test('a host that will not say how big a file is still moves', () {
      const p = CatalogDownloadProgress(index: 1, count: 2);
      expect(p.fraction, isNull);
      expect(p.overall, 0.5);
    });
  });
}

Future<String> _sha256Of(File file) async =>
    sha256.convert(await file.readAsBytes()).toString();
