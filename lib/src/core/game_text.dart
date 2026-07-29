import 'dart:convert';

/// Text the games wrote into their own files, none of which record an
/// encoding.
///
/// The Sims 2 stores what the player typed as UTF-8, so the "i" of a
/// Portuguese neighborhood called "Baia da Belladonna" is the two bytes
/// 0xC3 0xAD on disk; reading those one per character is what puts the
/// familiar garbage on screen. The Sims 1 predates that and leaves the
/// bytes in whatever code page Windows was running when the save was
/// written, which for every language the game shipped in is Windows-1252.
///
/// So: UTF-8 first, Windows-1252 when that fails. The guess is safe in both
/// directions because a lone high byte is not valid UTF-8 - a code-page save
/// almost never decodes as UTF-8 by accident, and a UTF-8 save always does.
String decodeGameText(List<int> bytes) {
  try {
    return utf8.decode(bytes);
  } on FormatException {
    return _decodeWindows1252(bytes);
  }
}

/// The 32 places Windows-1252 differs from Latin-1: printable punctuation
/// where Latin-1 has control codes, which is where the curly apostrophe in
/// a name like `Bella's place` lives. The five bytes Windows leaves
/// undefined (0x81, 0x8D, 0x8F, 0x90, 0x9D) pass through as themselves.
const _windows1252High = <int>[
  0x20AC, 0x0081, 0x201A, 0x0192, 0x201E, 0x2026, 0x2020, 0x2021, //
  0x02C6, 0x2030, 0x0160, 0x2039, 0x0152, 0x008D, 0x017D, 0x008F,
  0x0090, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014,
  0x02DC, 0x2122, 0x0161, 0x203A, 0x0153, 0x009D, 0x017E, 0x0178,
];

String _decodeWindows1252(List<int> bytes) {
  final out = StringBuffer();
  for (final byte in bytes) {
    out.writeCharCode(
        byte >= 0x80 && byte <= 0x9F ? _windows1252High[byte - 0x80] : byte);
  }
  return out.toString();
}
