import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sims_mod_manager/src/core/sevenzip.dart';

import 'sevenzip_fixtures.dart';

Uint8List _bytes(String fixture) => base64.decode(fixture);

Map<String, String> _read(String fixture) {
  final out = <String, String>{};
  readSevenZip(
      _bytes(fixture), (entry, data) => out[entry.name] = utf8.decode(data));
  return out;
}

void main() {
  // Every fixture packs the same three files. The four written by
  // libarchive's own 7z writer (`tar --format=7zip --options
  // 7zip:compression=...`) cover the coders it can produce; the LZMA1 one
  // is assembled by hand around a raw stream, because libarchive writes
  // LZMA2 and never LZMA1 - and LZMA1 is what 7-Zip itself writes by
  // default, so it is the one that actually matters.
  //
  // The four with an encoded header (everything but copy) also decode a
  // compressed header on the way in, which is where a real archive
  // starts.
  group('reads a folder packed with', () {
    test('LZMA, which is what 7-Zip writes by default', () {
      expect(_read(sevenZipLzma1), sevenZipContents);
    });

    test('LZMA2', () => expect(_read(sevenZipLzma2), sevenZipContents));

    test('no compression at all',
        () => expect(_read(sevenZipCopy), sevenZipContents));

    test('deflate', () => expect(_read(sevenZipDeflate), sevenZipContents));

    test('bzip2', () => expect(_read(sevenZipBzip2), sevenZipContents));
  });

  test('keeps the archive folder structure', () {
    final names = <String>[];
    readSevenZip(_bytes(sevenZipLzma1), (entry, _) => names.add(entry.name));
    // Always forward slashes, whatever the machine that packed it wrote.
    expect(names, contains('inner/lamp.package'));
  });

  test('reports the size the header declared', () {
    final sizes = <String, int>{};
    readSevenZip(_bytes(sevenZipLzma1), (entry, data) {
      sizes[entry.name] = entry.size;
      expect(data.length, entry.size);
    });
    expect(sizes['hair.package'], 81);
    expect(sizes['readme.txt'], 7);
  });

  // A solid archive is one compressed stream holding every file, so
  // asking for one file unpacks the lot. Skipping a folder nothing wants
  // is the only saving available, and it has to still be exact about the
  // files it does hand over.
  test('a folder nothing wants is never unpacked', () {
    final seen = <String>[];
    readSevenZip(
      _bytes(sevenZipLzma1),
      (entry, data) {
        seen.add(entry.name);
        expect(utf8.decode(data), sevenZipContents[entry.name]);
      },
      wanted: (name) => name.endsWith('.package'),
    );
    expect(seen, ['hair.package', 'inner/lamp.package']);
  });

  group('refuses', () {
    test('bytes that are not a 7z at all', () {
      expect(
          () =>
              readSevenZip(Uint8List.fromList(utf8.encode('nope')), (_, __) {}),
          throwsA(isA<FormatException>()));
    });

    test('a download that stopped early', () {
      final cut = Uint8List.sublistView(_bytes(sevenZipLzma1), 0, 120);
      expect(
          () => readSevenZip(cut, (_, __) {}), throwsA(isA<FormatException>()));
    });

    // The point of the distinction: a coder we don't implement is not a
    // damaged file, and the caller has a real unpacker to fall back on.
    test('a coder it does not implement, as its own kind of failure', () {
      final patched = _bytes(sevenZipLzma1);
      // LZMA's id, turned into a neighbouring one nobody has assigned.
      patched[_indexOfLzmaCoderId(patched)] = 0x7f;
      expect(() => readSevenZip(patched, (_, __) {}),
          throwsA(isA<SevenZipUnsupportedError>()));
    });
  });
}

/// The last byte of the LZMA coder's id in the fixture's header, found by
/// walking from where the start header says the header begins - so a
/// matching run of bytes in the compressed payload can't be mistaken for
/// it.
int _indexOfLzmaCoderId(Uint8List bytes) {
  final start = ByteData.sublistView(bytes).getUint64(12, Endian.little);
  for (var i = 32 + start; i < bytes.length - 4; i++) {
    // The coder's flag byte (a three-byte id, with properties) and the id.
    if (bytes[i] == 0x23 &&
        bytes[i + 1] == 0x03 &&
        bytes[i + 2] == 0x01 &&
        bytes[i + 3] == 0x01) {
      return i + 3;
    }
  }
  throw StateError('the LZMA fixture no longer looks like one');
}
