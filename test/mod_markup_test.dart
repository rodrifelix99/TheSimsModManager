// The listing markup, which is written by strangers and drawn twice. What is
// pinned here is the grammar itself: web/src/data/markup.ts has to answer the
// same way, and the two are only ever kept together by hand.
import 'package:flutter_test/flutter_test.dart';
import 'package:sims_mod_manager/src/core/mod_markup.dart';

/// A paragraph as `text|text` with each span's styles spelled out, so a case
/// reads as one line.
String describe(ProseParagraph paragraph) {
  final spans = paragraph.spans.map((span) {
    final marks = [
      if (span.bold) 'b',
      if (span.italic) 'i',
      if (span.underline) 'u',
      if (span.link != null) '->${span.link}',
    ].join(',');
    return marks.isEmpty ? span.text : '${span.text}{$marks}';
  });
  return '${paragraph.centered ? '=' : ''}${spans.join('|')}';
}

List<String> render(String source) =>
    parseProse(source).map(describe).toList();

void main() {
  group('plain text', () {
    test('splits on blank lines and keeps single breaks', () {
      expect(render('one\ntwo\n\nthree'), ['one\ntwo', 'three']);
    });

    test('drops whitespace between and around paragraphs', () {
      expect(render('\n  one  \n \n\n  two \n'), ['one', 'two']);
    });

    test('nothing at all is no paragraphs', () {
      expect(render('   \n\n  '), isEmpty);
    });
  });

  group('styles', () {
    test('bold, italic and underline nest', () {
      expect(render('[b]a[i]b[/i][/b]c'), ['a{b}|b{b,i}|c']);
      expect(render('[u]under[/u]'), ['under{u}']);
    });

    test('tags are case insensitive', () {
      expect(render('[B]a[/B]'), ['a{b}']);
    });

    test('an unclosed tag runs to the end', () {
      expect(render('[b]rest of it'), ['rest of it{b}']);
    });

    test('a closing tag on its own is text', () {
      expect(render('a[/b]b'), ['a[/b]b']);
    });

    test('a tag we do not know is text', () {
      expect(render('[size=20]big[/size]'), ['[size=20]big[/size]']);
    });

    test('centring is a property of the paragraph', () {
      expect(render('[center]one\n\ntwo[/center]\n\nthree'),
          ['=one', '=two', 'three']);
    });
  });

  group('links', () {
    test('a labelled link carries its address', () {
      expect(render('[url=https://example.com]click[/url]'),
          ['click{->https://example.com}']);
    });

    test('an unlabelled link is its own address', () {
      expect(render('[url]https://example.com[/url]'),
          ['https://example.com{->https://example.com}']);
    });

    test('styles survive inside a link', () {
      expect(render('[url=https://example.com][b]go[/b][/url]'),
          ['go{b,->https://example.com}']);
    });

    test('a bare address becomes a link', () {
      expect(render('see https://example.com/x for more'),
          ['see |https://example.com/x{->https://example.com/x}| for more']);
    });

    test('a bare address at the end of a sentence keeps the full stop out', () {
      expect(render('at https://example.com.'),
          ['at |https://example.com{->https://example.com}|.']);
    });

    test('an address inside a labelled link is not linked twice', () {
      expect(render('[url=https://a.example]https://b.example[/url]'),
          ['https://b.example{->https://a.example}']);
    });
  });

  group('what a link may be', () {
    test('anything but http and https is dropped, label kept', () {
      for (final bad in [
        'javascript:alert(1)',
        'JavaScript:alert(1)',
        'data:text/html,<script>',
        'file:///etc/passwd',
        'simsmodmanager://mod/abc',
        'not a url at all',
      ]) {
        expect(render('[url=$bad]label[/url]'), ['label'],
            reason: '$bad should not become a link');
        expect(sanitizeProseLink(bad), isNull);
      }
    });

    test('an unlabelled link that is not an address stays text', () {
      expect(render('[url]javascript:alert(1)[/url]'), ['javascript:alert(1)']);
    });

    test('http and https pass', () {
      expect(sanitizeProseLink('https://example.com/a?b=c#d'),
          'https://example.com/a?b=c#d');
      expect(sanitizeProseLink('  http://example.com  '), 'http://example.com');
    });
  });

  test('stripping leaves one plain string', () {
    expect(
      stripProse('[center][b]Hi[/b][/center]\n\n[url=https://x.example]there'
          '[/url]'),
      'Hi\n\nthere',
    );
  });

  test('a description written before any of this is unchanged', () {
    const old = 'Adds a camera hack.\n\nNeeds Get to Work.';
    expect(render(old), ['Adds a camera hack.', 'Needs Get to Work.']);
  });
}
