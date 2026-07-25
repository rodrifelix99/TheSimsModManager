// Builds the translated copies of the landing page.
//
// docs/index.html is both the English page GitHub Pages serves and the
// template for the rest: anything translatable carries a data-i18n key
// (element content) or data-i18n-attr (an attribute), and docs/i18n/<code>.json
// holds that language's strings. This writes docs/<code>/index.html for every
// language but English, wires up the hreflang alternates and the sitemap, and
// leaves index.html itself alone apart from its own alternates.
//
//   dart tool/build_site.dart [--check]
//
// --check writes nothing and exits non-zero if a page is out of date, which is
// what CI (and site_test.dart) use to catch an index.html edit that never got
// rebuilt.
import 'dart:convert';
import 'dart:io';

/// Language folder names, in the order the picker lists them. English is the
/// site root rather than /en/, so it isn't here.
const languages = ['zh', 'es', 'pt', 'fr', 'de', 'it', 'ru', 'pl', 'ja'];

const siteRoot = 'https://rodrifelix99.github.io/TheSimsModManager/';

/// The "this page is also in your language" banner speaks the *visitor's*
/// language, not the page's, so unlike everything else these strings ship in
/// every language on every page. Named here so site_test.dart can tell them
/// apart from the keys index.html marks up.
const bannerKeys = ['banner.msg', 'banner.cta', 'banner.close'];

void main(List<String> args) {
  final pages = buildSite();
  if (args.contains('--check')) {
    final stale = [
      for (final entry in pages.entries)
        if (!File(entry.key).existsSync() ||
            !matchesOnDisk(entry.key, entry.value))
          entry.key,
    ];
    if (stale.isEmpty) return;
    stderr.writeln('Out of date, re-run dart tool/build_site.dart:');
    for (final path in stale) {
      stderr.writeln('  $path');
    }
    exit(1);
  }
  for (final entry in pages.entries) {
    File(entry.key)
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(entry.value);
  }
  stdout.writeln('Built ${languages.length} translated pages.');
}

/// Every file the site build owns, as path -> contents. Pure apart from
/// reading the template and the string files, so site_test.dart can compare
/// it against what is on disk without running the generator as a process.
Map<String, String> buildSite() {
  final template = _withLanguageOffers(File('docs/index.html').readAsStringSync());
  return {
    // The English page only needs its alternates filled in; its own text is
    // already the source of truth.
    'docs/index.html': _withAlternates(template),
    for (final code in languages)
      'docs/$code/index.html': _translate(template, code, _strings(code)),
    'docs/sitemap.xml': _sitemap(),
  };
}

Map<String, String> _strings(String code) =>
    (jsonDecode(File('docs/i18n/$code.json').readAsStringSync())
            as Map<String, Object?>)
        .map((key, value) => MapEntry(key, value.toString()));

/// Fills the `#lang-offers` block with every language's banner strings. The
/// same block on every page, English included, because whose language the
/// visitor speaks is only known in the browser.
String _withLanguageOffers(String html) {
  final offers = {
    for (final code in ['en', ...languages])
      code: {
        for (final key in bannerKeys)
          key.split('.').last: _strings(code)[key] ??
              (throw StateError('$code.json is missing "\$key"')),
      },
  };
  return html.replaceFirst(
    RegExp(r'<script type="application/json" id="lang-offers">.*?</script>',
        dotAll: true),
    '<script type="application/json" id="lang-offers">'
    '${jsonEncode(offers)}</script>',
  );
}

String _translate(String html, String code, Map<String, String> strings) {
  var out = html;

  String lookup(String key) {
    final value = strings[key];
    if (value == null) throw StateError('$code.json is missing "$key"');
    return value;
  }

  // Element content: <p data-i18n="key">…</p>. Matching the opening tag's own
  // name means inner <b>/<a> are safe; no translatable element nests a second
  // element of its own kind.
  out = out.replaceAllMapped(
    RegExp(r'<(\w+)([^>]*\sdata-i18n="([^"]+)"[^>]*)>.*?</\1>', dotAll: true),
    (m) => '<${m[1]}${m[2]}>${lookup(m[3]!)}</${m[1]}>',
  );

  // Attributes: data-i18n-attr="alt:key" (or "content:key").
  out = out.replaceAllMapped(
    RegExp(r'data-i18n-attr="(\w+):([^"]+)"\s+(\w+)="[^"]*"'),
    (m) => 'data-i18n-attr="${m[1]}:${m[2]}" ${m[3]}="${_escape(lookup(m[2]!))}"',
  );

  // The JSON-LD description repeats the meta description word for word.
  out = out.replaceAll(
    '"description": "A free desktop app for Windows, macOS and Linux that '
        'manages your Sims mods and custom content: real thumbnails, '
        'one-click enable/disable, conflict warnings, and automatic folder '
        'detection for every mainline Sims game and The Sims Medieval."',
    '"description": ${jsonEncode(_stripTags(lookup('meta.description')))}',
  );

  // Strings the download script assembles at runtime.
  out = out.replaceAll(
    RegExp(
      r'<script type="application/json" id="page-strings">.*?</script>',
      dotAll: true,
    ),
    '<script type="application/json" id="page-strings">\n'
    '${const JsonEncoder.withIndent('  ').convert({
          for (final key in [
            'osWindows',
            'osMacos',
            'osLinux',
            'download',
            'latest',
          ])
            key: lookup('js.$key'),
        })}\n</script>',
  );

  out = out.replaceFirst('<html lang="en">', '<html lang="$code">');
  // One folder deeper than the assets and the sibling pages.
  out = out.replaceAllMapped(
      RegExp(r'(src|href)="images/'), (m) => '${m[1]}="../images/');
  out = out.replaceFirst('<option value="" selected>', '<option value="">');
  out = out.replaceFirst(
      '<option value="$code">', '<option value="$code" selected>');
  out = out.replaceFirst(
      '<link rel="canonical" href="$siteRoot">',
      '<link rel="canonical" href="$siteRoot$code/">');
  out = out.replaceAll('<meta property="og:url" content="$siteRoot">',
      '<meta property="og:url" content="$siteRoot$code/">');
  return _withAlternates(out);
}

/// The reciprocal hreflang set every page in the group has to carry, plus the
/// x-default pointing at English. Every page gets the same list, itself
/// included, which is what search engines expect.
String _withAlternates(String html) {
  final links = [
    '<link rel="alternate" hreflang="en" href="$siteRoot">',
    for (final code in languages)
      '<link rel="alternate" hreflang="$code" href="$siteRoot$code/">',
    '<link rel="alternate" hreflang="x-default" href="$siteRoot">',
  ];
  return html.replaceFirst('<!--hreflang-->', links.join('\n'));
}

String _sitemap() => '<?xml version="1.0" encoding="UTF-8"?>\n'
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
    '${[
      '',
      for (final code in languages) '$code/',
    ].map((path) => '  <url>\n    <loc>$siteRoot$path</loc>\n  </url>\n').join()}'
    '</urlset>\n';

/// Whether the file at [path] already holds [expected]. Line endings are
/// normalized first: a Windows checkout can hand back CRLF for content that
/// was written, and is regenerated, with LF.
bool matchesOnDisk(String path, String expected) =>
    _lf(File(path).readAsStringSync()) == _lf(expected);

String _lf(String value) => value.replaceAll('\r\n', '\n');

/// Markup is fine inside a paragraph, never inside an attribute or JSON-LD.
String _stripTags(String value) =>
    value.replaceAll(RegExp('<[^>]+>'), '').replaceAll('&amp;', '&');

String _escape(String value) => _stripTags(value).replaceAll('"', '&quot;');
