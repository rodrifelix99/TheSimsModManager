// The app's half of the listing markup: what parseProse decided, actually
// drawn. The grammar itself is pinned in mod_markup_test.dart.
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sims_mod_manager/src/ui/prose_text.dart';

Future<void> pumpProse(
  WidgetTester tester,
  String source, {
  void Function(String url)? onLink,
}) =>
    tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ProseText(
          source,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          linkColor: const Color(0xFF00A67E),
          onLink: onLink,
        ),
      ),
    ));

/// Every drawn span that carries text, paragraph by paragraph. Text.rich wraps
/// what it is given in one more span of its own, so this walks down.
List<TextSpan> spansOf(WidgetTester tester) {
  final found = <TextSpan>[];
  void walk(InlineSpan span) {
    if (span is! TextSpan) return;
    if (span.text != null) found.add(span);
    for (final child in span.children ?? const <InlineSpan>[]) {
      walk(child);
    }
  }

  for (final text in tester.widgetList<RichText>(find.byType(RichText))) {
    walk(text.text);
  }
  return found;
}

void main() {
  testWidgets('a paragraph per blank line', (tester) async {
    await pumpProse(tester, 'one\n\ntwo');
    expect(find.byType(RichText), findsNWidgets(2));
  });

  testWidgets('bold, italic and underline reach the style', (tester) async {
    await pumpProse(tester, '[b]a[/b][i]b[/i][u]c[/u]');
    final spans = spansOf(tester);
    expect(spans[0].style!.fontWeight, FontWeight.w900);
    expect(spans[1].style!.fontStyle, FontStyle.italic);
    expect(spans[2].style!.decoration, TextDecoration.underline);
  });

  testWidgets('a centered paragraph is centered', (tester) async {
    await pumpProse(tester, '[center]middle[/center]\n\nleft');
    final drawn = tester.widgetList<RichText>(find.byType(RichText)).toList();
    expect(drawn[0].textAlign, TextAlign.center);
    expect(drawn[1].textAlign, TextAlign.start);
  });

  testWidgets('tapping a link hands over its address', (tester) async {
    final opened = <String>[];
    await pumpProse(
      tester,
      'read [url=https://example.com/docs]the docs[/url]',
      onLink: opened.add,
    );
    final link = spansOf(tester).firstWhere((span) => span.recognizer != null);
    expect(link.text, 'the docs');
    (link.recognizer! as TapGestureRecognizer).onTap!();
    expect(opened, ['https://example.com/docs']);
  });

  testWidgets('with nowhere for links to go, nothing is tappable',
      (tester) async {
    await pumpProse(tester, '[url=https://example.com]here[/url]');
    expect(spansOf(tester).every((span) => span.recognizer == null), isTrue);
  });

  testWidgets('a rebuild does not pile up recognizers', (tester) async {
    await pumpProse(tester, '[url=https://a.example]one[/url]', onLink: (_) {});
    await pumpProse(tester, '[url=https://b.example]two[/url]', onLink: (_) {});
    final links =
        spansOf(tester).where((span) => span.recognizer != null).toList();
    expect(links, hasLength(1));
    expect(links.single.text, 'two');
    // The teardown below disposes the state; a recognizer disposed twice
    // throws, which is what this is really checking.
    await tester.pumpWidget(const SizedBox());
  });
}
