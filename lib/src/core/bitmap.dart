import 'dart:io' show zlib;
import 'dart:typed_data';

/// Writing PNGs and reading the Windows bitmaps The Sims 1 stores its
/// artwork as.
///
/// The app draws images with Flutter's own decoders, which is why
/// everything here converts *to* PNG rather than to pixels: a house
/// thumbnail out of a `.iff` becomes bytes `Image.memory` understands,
/// and nothing downstream has to know where it came from. The PNG writer
/// is also what the demo shop paints its invented cover art with, which
/// is why it lives here rather than beside either caller.
///
/// Hand-rolled on purpose: an image package is a large dependency for
/// two small jobs, and one of them (the release pin, see the project
/// notes) has to resolve against an older SDK.

/// Above this a bitmap is refused rather than decoded. Every image this
/// reads is a thumbnail; the dimensions come out of the file's own
/// header, and the pixel buffer is allocated from them.
const _maxBitmapPixels = 4096 * 4096;

/// Writes an uncompressed PNG: 8 bits per channel, one IDAT, no
/// interlacing. [pixels] is row-major RGB or RGBA, per [hasAlpha].
Uint8List encodePng(int width, int height, Uint8List pixels,
    {bool hasAlpha = false}) {
  final stride = width * (hasAlpha ? 4 : 3);
  final raw = BytesBuilder();
  for (var y = 0; y < height; y++) {
    raw.addByte(0); // filter type: none
    raw.add(Uint8List.sublistView(pixels, y * stride, (y + 1) * stride));
  }
  final out = BytesBuilder();
  out.add(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
  out.add(_pngChunk(
      'IHDR',
      Uint8List.fromList(
          [..._be32(width), ..._be32(height), 8, hasAlpha ? 6 : 2, 0, 0, 0])));
  out.add(_pngChunk('IDAT', Uint8List.fromList(zlib.encode(raw.takeBytes()))));
  out.add(_pngChunk('IEND', Uint8List(0)));
  return out.takeBytes();
}

/// The Sims 1 keys its artwork's transparency on magenta rather than on
/// an alpha channel, with the same tolerance the game's own loader uses.
bool _isTransparent(int r, int g, int b) => r >= 248 && b >= 248 && g <= 4;

/// Converts a Windows bitmap to a PNG, turning the game's magenta into
/// real transparency. Returns `null` for anything that isn't a bitmap
/// this understands - the uncompressed 8/24/32-bit forms the games ship.
/// Never throws: these bytes come off a player's disk.
Uint8List? bmpToPng(Uint8List bmp) {
  try {
    // 'BM', then at least a file header and a BITMAPINFOHEADER.
    if (bmp.length < 54 || bmp[0] != 0x42 || bmp[1] != 0x4D) return null;
    final d = ByteData.sublistView(bmp);
    final dataOffset = d.getUint32(10, Endian.little);
    final headerSize = d.getUint32(14, Endian.little);
    if (headerSize < 40) return null; // the ancient BITMAPCOREHEADER
    final width = d.getInt32(18, Endian.little);
    final rawHeight = d.getInt32(22, Endian.little);
    // A negative height means the rows are stored top-down.
    final height = rawHeight.abs();
    final topDown = rawHeight < 0;
    final bitCount = d.getUint16(28, Endian.little);
    final compression = d.getUint32(30, Endian.little);
    if (width <= 0 || height <= 0 || width * height > _maxBitmapPixels) {
      return null;
    }
    // Only the uncompressed forms; 3 is BI_BITFIELDS, which for the
    // 32-bit case is still plain BGRA.
    if (compression != 0 && !(compression == 3 && bitCount == 32)) return null;
    if (bitCount != 8 && bitCount != 24 && bitCount != 32) return null;

    // 8-bit bitmaps index a palette of BGRA quads sitting between the
    // header and the pixels.
    List<int>? palette;
    if (bitCount == 8) {
      var colors = d.getUint32(46, Endian.little);
      if (colors == 0) colors = 256;
      if (colors > 256) return null;
      final start = 14 + headerSize;
      if (start + colors * 4 > bmp.length) return null;
      palette = [
        for (var i = 0; i < colors; i++) start + i * 4,
      ];
    }

    final bytesPerPixel = bitCount ~/ 8;
    // Rows are padded out to a four-byte boundary.
    final stride = ((width * bytesPerPixel + 3) ~/ 4) * 4;
    if (dataOffset + stride * height > bmp.length) return null;

    final out = Uint8List(width * height * 4);
    for (var y = 0; y < height; y++) {
      final row = dataOffset + (topDown ? y : height - 1 - y) * stride;
      var at = y * width * 4;
      for (var x = 0; x < width; x++) {
        final p = row + x * bytesPerPixel;
        int r, g, b;
        if (palette != null) {
          final entry = palette[bmp[p] < palette.length ? bmp[p] : 0];
          b = bmp[entry];
          g = bmp[entry + 1];
          r = bmp[entry + 2];
        } else {
          b = bmp[p];
          g = bmp[p + 1];
          r = bmp[p + 2];
        }
        out[at++] = r;
        out[at++] = g;
        out[at++] = b;
        out[at++] = _isTransparent(r, g, b) ? 0 : 255;
      }
    }
    return encodePng(width, height, out, hasAlpha: true);
  } catch (_) {
    return null;
  }
}

List<int> _be32(int value) =>
    [value >> 24 & 0xFF, value >> 16 & 0xFF, value >> 8 & 0xFF, value & 0xFF];

Uint8List _pngChunk(String type, Uint8List data) {
  final typeBytes = type.codeUnits;
  final out = BytesBuilder();
  out.add(_be32(data.length));
  out.add(typeBytes);
  out.add(data);
  out.add(_be32(_crc32([...typeBytes, ...data])));
  return out.takeBytes();
}

final _crcTable = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
  }
  return c;
});

int _crc32(List<int> bytes) {
  var c = 0xFFFFFFFF;
  for (final byte in bytes) {
    c = _crcTable[(c ^ byte) & 0xFF] ^ (c >> 8);
  }
  return (c ^ 0xFFFFFFFF) & 0xFFFFFFFF;
}
