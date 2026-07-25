// The landing page ships in ten languages, generated from docs/index.html by
// tool/build_site.dart. These pin the two ways that goes wrong: a translation
// file drifting from the English one, and an edit to index.html that never got
// rebuilt into docs/<lang>/.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/build_site.dart';

Map<String, Object?> _strings(String code) =>
    jsonDecode(File('docs/i18n/$code.json').readAsStringSync())
        as Map<String, Object?>;

void main() {
  test('every landing page string is translated everywhere', () {
    final english = _strings('en').keys.toSet();
    for (final code in languages) {
      final translated = _strings(code).keys.toSet();
      expect(english.difference(translated), isEmpty,
          reason: '$code.json is missing strings');
      expect(translated.difference(english), isEmpty,
          reason: '$code.json has strings English does not');
    }
  });

  test('index.html marks every string it expects to be translated', () {
    final html = File('docs/index.html').readAsStringSync();
    final marked = {
      for (final m in RegExp(r'data-i18n(?:-attr)?="(?:\w+:)?([^"]+)"')
          .allMatches(html))
        m[1]!,
      // The download script's own strings live in a JSON block instead.
      ...(jsonDecode(RegExp(r'id="page-strings">(.*?)</script>', dotAll: true)
                  .firstMatch(html)![1]!) as Map<String, Object?>)
          .keys
          .map((key) => 'js.$key'),
      // As do the language banner's, which the build injects for every
      // language rather than just the page's own.
      ...bannerKeys,
    };
    expect(marked, _strings('en').keys.toSet());
  });

  test('the generated pages are up to date', () {
    // Same code path as the generator, so an index.html or translation edit
    // that was never rebuilt shows up here instead of on the live site.
    buildSite().forEach((path, expected) {
      final file = File(path);
      expect(file.existsSync(), isTrue,
          reason: '$path is missing. Run `dart tool/build_site.dart`.');
      expect(matchesOnDisk(path, expected), isTrue,
          reason: '$path is stale. Run `dart tool/build_site.dart`.');
    });
  });
}
