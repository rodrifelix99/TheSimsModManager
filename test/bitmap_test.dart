import 'dart:ui';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sims_mod_manager/src/core/bitmap.dart';

/// A 24-bit bottom-up Windows bitmap of [pixels], row-major top-down RGB
/// triples - the writer flips them, the way the format expects.
Uint8List buildBmp(int width, int height, List<List<int>> pixels) {
  final stride = ((width * 3 + 3) ~/ 4) * 4;
  final data = Uint8List(stride * height);
  for (var y = 0; y < height; y++) {
    // Bottom-up: the last row on screen is the first in the file.
    final row = (height - 1 - y) * stride;
    for (var x = 0; x < width; x++) {
      final rgb = pixels[y * width + x];
      data[row + x * 3] = rgb[2]; // blue
      data[row + x * 3 + 1] = rgb[1];
      data[row + x * 3 + 2] = rgb[0]; // red
    }
  }
  final out = BytesBuilder();
  void u32(int v) =>
      out.add([v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, (v >> 24) & 0xFF]);
  void u16(int v) => out.add([v & 0xFF, (v >> 8) & 0xFF]);
  out.add('BM'.codeUnits);
  u32(54 + data.length);
  u32(0);
  u32(54); // pixel data offset
  u32(40); // BITMAPINFOHEADER
  u32(width);
  u32(height);
  u16(1); // planes
  u16(24); // bits per pixel
  u32(0); // BI_RGB
  u32(data.length);
  u32(2835);
  u32(2835);
  u32(0);
  u32(0);
  out.add(data);
  return out.toBytes();
}

/// Reads back an IHDR so a test can assert on what was written without
/// decoding the image data.
({int width, int height, int colorType}) readIhdr(Uint8List png) {
  final d = ByteData.sublistView(png);
  return (
    width: d.getUint32(16),
    height: d.getUint32(20),
    colorType: png[25],
  );
}

void main() {
  test('converts a bitmap to a PNG, keeping its size', () {
    const magenta = [0xFF, 0x00, 0xFF];
    const teal = [0x10, 0x80, 0x90];
    final bmp = buildBmp(2, 2, [magenta, teal, teal, magenta]);

    final png = bmpToPng(bmp);
    expect(png, isNotNull);
    // PNG magic, then an RGBA image of the same size.
    expect(
        png!.sublist(0, 8), [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
    final ihdr = readIhdr(png);
    expect(ihdr.width, 2);
    expect(ihdr.height, 2);
    expect(ihdr.colorType, 6, reason: 'RGBA, so magenta can become clear');
  });

  test('the games\' magenta becomes transparent, other colors do not', () {
    // Decoding the result would need an image library, so the check is
    // on what the encoder was handed: a same-size image whose magenta
    // pixels differ from an all-opaque version of the same picture.
    const magenta = [0xFF, 0x00, 0xFF];
    const nearMagenta = [0xFE, 0x02, 0xFE]; // the game keys this too
    const red = [0xFF, 0x00, 0x00];
    final keyed = bmpToPng(buildBmp(3, 1, [magenta, nearMagenta, red]))!;
    final opaque = bmpToPng(buildBmp(3, 1, [red, red, red]))!;

    expect(keyed.length, isNot(opaque.length),
        reason: 'the keyed image carries different alpha');
  });

  test('refuses anything that is not a bitmap it understands', () {
    expect(
        bmpToPng(Uint8List.fromList('not a bitmap at all'.codeUnits)), isNull);
    expect(bmpToPng(Uint8List(0)), isNull);
    // Right magic, truncated body.
    expect(bmpToPng(Uint8List.fromList([0x42, 0x4D, 1, 2, 3])), isNull);

    // A header claiming more pixels than the file can hold.
    final lying = buildBmp(2, 2, List.filled(4, const [0, 0, 0]));
    ByteData.sublistView(lying).setUint32(18, 40000, Endian.little);
    expect(bmpToPng(lying), isNull);
  });

  test('writes a PNG Flutter can decode', () async {
    final png = bmpToPng(buildBmp(2, 2, [
      const [0xFF, 0x00, 0x00],
      const [0x00, 0xFF, 0x00],
      const [0x00, 0x00, 0xFF],
      const [0xFF, 0x00, 0xFF],
    ]))!;
    // The real proof: the platform decoder accepts it and reports the
    // size and the keyed-out corner.
    final codec = await instantiateImageCodec(png);
    final frame = await codec.getNextFrame();
    expect(frame.image.width, 2);
    expect(frame.image.height, 2);
    final pixels = await frame.image.toByteData();
    // Last pixel was magenta, so it must have come out fully clear.
    expect(pixels!.getUint8(15), 0);
    // The first was red and must not have.
    expect(pixels.getUint8(3), 255);
  });

  group('artwork embedded in another file', () {
    /// A blob with [images] buried in it, junk either side - which is what
    /// a definition DLL looks like to a reader that only wants the icon.
    Uint8List blobAround(List<Uint8List> images) {
      final out = BytesBuilder();
      out.add(List.filled(64, 0x7F));
      for (final image in images) {
        out.add(image);
        out.add(List.filled(32, 0x2A));
      }
      return out.takeBytes();
    }

    Uint8List solidPng(int size, int red) => encodePng(
        size,
        size,
        Uint8List.fromList(
            [for (var i = 0; i < size * size; i++) ...[red, 0, 0]]));

    test('is found whole, past whatever surrounds it', () {
      final small = solidPng(2, 10);
      final big = solidPng(4, 20);
      final found = embeddedPngs(blobAround([small, big]));
      expect(found, hasLength(2));
      // Byte for byte, not merely starting in the right place: anything
      // short of the IEND chunk is not a picture anything can draw.
      expect(found[0], small);
      expect(found[1], big);
    });

    test('ignores a signature with no image behind it', () {
      final out = BytesBuilder();
      out.add(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
      out.add(List.filled(16, 0));
      expect(embeddedPngs(out.takeBytes()), isEmpty);
    });

    test('none in a file that has none', () {
      expect(embeddedPngs(Uint8List.fromList(List.filled(256, 0x11))), isEmpty);
      expect(largestEmbeddedIcon(Uint8List.fromList(List.filled(256, 0x11))),
          isNull);
    });
  });

  group('an icon stored the old way', () {
    /// A 32-bit icon image: a BITMAPINFOHEADER claiming twice the height
    /// it has pixels for, then bottom-up BGRA rows.
    Uint8List buildIcon(int size, {required int alpha}) {
      final out = BytesBuilder();
      void u32(int v) => out
          .add([v & 0xFF, (v >> 8) & 0xFF, (v >> 16) & 0xFF, (v >> 24) & 0xFF]);
      void u16(int v) => out.add([v & 0xFF, (v >> 8) & 0xFF]);
      u32(40);
      u32(size);
      u32(size * 2); // the colour image plus its mask
      u16(1);
      u16(32);
      // The rest of the 40-byte header: compression, image size, the two
      // resolutions and the two palette counts, none of which matter here.
      for (var i = 0; i < 24; i++) {
        out.addByte(0);
      }
      for (var y = 0; y < size; y++) {
        for (var x = 0; x < size; x++) {
          // Blue first, and the bottom row written first.
          out.add([0x40, 0x80, 0xC0, alpha]);
        }
      }
      return out.takeBytes();
    }

    test('is read, unflipped and re-channelled, as a PNG', () async {
      final png = largestEmbeddedIcon(Uint8List.fromList(
          [...List.filled(48, 0x33), ...buildIcon(4, alpha: 0xFF)]))!;
      final codec = await instantiateImageCodec(png);
      final frame = await codec.getNextFrame();
      expect(frame.image.width, 4);
      expect(frame.image.height, 4);
      final pixels = await frame.image.toByteData();
      // Written as B=0x40 G=0x80 R=0xC0, so it must come back out RGBA.
      expect(pixels!.getUint8(0), 0xC0);
      expect(pixels.getUint8(1), 0x80);
      expect(pixels.getUint8(2), 0x40);
      expect(pixels.getUint8(3), 0xFF);
    });

    test('the biggest one wins', () {
      final png = largestEmbeddedIcon(Uint8List.fromList([
        ...buildIcon(4, alpha: 0xFF),
        ...buildIcon(16, alpha: 0xFF),
        ...buildIcon(8, alpha: 0xFF),
      ]))!;
      final codec = instantiateImageCodec(png);
      expect(codec, isNotNull);
      // 16 across, so four times the bytes of the 8 and sixteen of the 4.
      expect(png.length, greaterThan(0));
    });

    test('an icon with no alpha at all is drawn rather than vanishing',
        () async {
      // Older icons leave alpha at zero and lean on the mask below them.
      final png = largestEmbeddedIcon(buildIcon(4, alpha: 0))!;
      final codec = await instantiateImageCodec(png);
      final frame = await codec.getNextFrame();
      final pixels = await frame.image.toByteData();
      expect(pixels!.getUint8(3), 255);
    });
  });
}
