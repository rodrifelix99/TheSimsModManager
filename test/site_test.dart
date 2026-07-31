// The website in web/ ships in the same eleven languages as the app, from flat
// dot-key dictionaries in web/src/i18n. Astro fails the build on a key that is
// missing outright, so what is left to pin here is what it cannot see: a
// translation file drifting from the English one, a key nobody draws any more,
// and the two files the retired GitHub Pages site still has to serve.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const languages = ['zh', 'es', 'pt', 'fr', 'de', 'it', 'ru', 'pl', 'ja', 'el'];

/// The languages the retired GitHub Pages site was translated into, which is
/// what its redirect stubs have to cover. Greek arrived after that site was
/// gone, so it never had an address there to point anywhere.
const pagesLanguages = ['zh', 'es', 'pt', 'fr', 'de', 'it', 'ru', 'pl', 'ja'];

const siteRoot = 'https://thesimsmodmanager.web.app/';

Map<String, Object?> _strings(String code) =>
    jsonDecode(File('web/src/i18n/$code.json').readAsStringSync())
        as Map<String, Object?>;

/// Every string literal under web/src that looks like a dictionary key, with
/// `${...}` left in place: `t(`faq.${key}.q`)` reaches several keys at once.
Iterable<String> _referenced(Set<String> prefixes) sync* {
  final literal = RegExp(r'''(['"`])([A-Za-z0-9._${}]*\.[A-Za-z0-9._${}]*)\1''');
  for (final entity in Directory('web/src').listSync(recursive: true)) {
    if (entity is! File) continue;
    if (!entity.path.endsWith('.astro') && !entity.path.endsWith('.ts')) {
      continue;
    }
    for (final match in literal.allMatches(entity.readAsStringSync())) {
      final value = match[2]!;
      final segments = value.split('.');
      // `startsWith('portal.')` is a prefix, not a key.
      if (segments.any((segment) => segment.isEmpty)) continue;
      if (prefixes.contains(segments.first)) yield value;
    }
  }
}

/// A reference with a `${...}` hole in it matches every key that fits it.
RegExp _asPattern(String reference) => RegExp(
      '^${RegExp.escape(reference).replaceAll(RegExp(r'\\\$\\\{[^}]*\\\}'), '[^.]+')}\$',
    );

void main() {
  test('every website string is translated everywhere', () {
    final english = _strings('en').keys.toSet();
    for (final code in languages) {
      final translated = _strings(code).keys.toSet();
      expect(english.difference(translated), isEmpty,
          reason: '$code.json is missing strings');
      expect(translated.difference(english), isEmpty,
          reason: '$code.json has strings English does not');
    }
  });

  test('the site draws every string it ships, and ships every one it draws',
      () {
    final english = _strings('en').keys.toSet();
    final prefixes = {for (final key in english) key.split('.').first};
    final references = _referenced(prefixes).toSet();

    final unknown = references
        .where((reference) => !reference.contains(r'${'))
        .where((reference) => !english.contains(reference));
    expect(unknown, isEmpty, reason: 'no such key in en.json');

    final patterns = references.map(_asPattern).toList();
    final unused = english.where(
        (key) => !patterns.any((pattern) => pattern.hasMatch(key)));
    expect(unused, isEmpty, reason: 'nothing in web/src draws these');
  });

  test('the retired Pages site still serves the advisory feed', () {
    // Apps up to v1.2.x read the list from the old address, and GitHub Pages
    // cannot redirect a JSON file. web/scripts/mirror-advisories.mjs copies it;
    // this catches the copy that was never re-run.
    final published = File('web/public/data/advisories.json');
    final mirror = File('docs/data/advisories.json');
    expect(mirror.existsSync(), isTrue, reason: 'docs/data/advisories.json');
    expect(mirror.readAsStringSync(), published.readAsStringSync(),
        reason: 'run `npm run build` in web/ and commit docs/data');
  });

  test('every old Pages address points at its new one', () {
    final pages = {
      'docs/index.html': siteRoot,
      'docs/thanks.html': '${siteRoot}thanks/',
      for (final code in pagesLanguages)
        'docs/$code/index.html': '$siteRoot$code/',
    };
    pages.forEach((path, target) {
      final file = File(path);
      expect(file.existsSync(), isTrue, reason: path);
      final html = file.readAsStringSync();
      expect(html, contains('<link rel="canonical" href="$target">'),
          reason: path);
      expect(html, contains('url=$target"'), reason: path);
    });
  });
}
