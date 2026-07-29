import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sims_mod_manager/src/core/game_text.dart';

void main() {
  test('reads a save written in UTF-8', () {
    expect(decodeGameText(utf8.encode('Baía da Belladonna')),
        'Baía da Belladonna');
    expect(decodeGameText(utf8.encode('Gonçalves')), 'Gonçalves');
    // Not double-decoded: bytes that already say "mojibake" stay as typed.
    expect(decodeGameText(utf8.encode('BaÃ­a')), 'BaÃ­a');
  });

  test('falls back to Windows-1252 for a save written before that', () {
    // Latin-1's own range, which the two encodings share.
    expect(decodeGameText([0x42, 0x61, 0xED, 0x61]), 'Baía');
    // And the punctuation Windows put where Latin-1 has control codes:
    // a curly apostrophe, an ellipsis and the euro sign.
    expect(decodeGameText([0x92, 0x85, 0x80]), '’…€');
  });

  test('reads empty and plain ASCII either way', () {
    expect(decodeGameText(const []), '');
    expect(decodeGameText(utf8.encode('Pleasantview')), 'Pleasantview');
  });
}
