// The bit of formatting a creator may put in a listing's description.
//
// Square-bracket tags rather than Markdown, for two reasons: it is what the
// mod scene already writes (Nexus, MTS and every forum they came from), and
// two of the things creators ask for - underline and centring - Markdown has
// no spelling for at all. The set is deliberately small. Everything here is
// drawn twice, once by the app and once by web/src/data/markup.ts, and every
// tag is one more thing those two can come to disagree about.
//
//   [b]bold[/b]  [i]italic[/i]  [u]underline[/u]
//   [center]a whole paragraph[/center]
//   [url]https://example.com[/url]  [url=https://example.com]label[/url]
//
// Anything else is text. A description written before any of this existed is
// still a description: no tags means one paragraph per blank line, which is
// exactly what it used to be.

/// A run of text in one style. `link` is an http(s) address or null - no other
/// scheme ever reaches here, because the parser drops the link rather than pass
/// on something a creator wrote for whoever clicks it.
class ProseSpan {
  const ProseSpan(
    this.text, {
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.link,
  });

  final String text;
  final bool bold;
  final bool italic;
  final bool underline;
  final String? link;

  @override
  String toString() => 'ProseSpan($text, b:$bold, i:$italic, u:$underline, '
      'link:$link)';
}

/// One paragraph: the spans it is made of, and whether it sits centred.
/// Line breaks inside a paragraph stay in the span text.
class ProseParagraph {
  const ProseParagraph(this.spans, {this.centered = false});

  final List<ProseSpan> spans;
  final bool centered;

  String get text => spans.map((span) => span.text).join();
}

/// The tags above, opening or closing, with the optional `=target` of `[url]`.
final _tagPattern = RegExp(
  r'\[(/?)(b|i|u|center|url)(?:=([^\]\n]*))?\]',
  caseSensitive: false,
);

/// A bare address in the middle of ordinary prose. Creators paste those far
/// more often than they reach for a tag, so they become links too. The closing
/// bracket is excluded so an address inside `[url=...]` cannot be caught twice,
/// and the trailing punctuation of a sentence is trimmed off below.
final _bareUrlPattern = RegExp(r'https?://[^\s\[\]<>"' "'" r']+');

/// Where a paragraph ends: one blank line, however much space is on it.
final _paragraphBreak = RegExp(r'\n[ \t]*\n\s*');

/// An address as it may be handed to whatever opens links, or null when it may
/// not be. Only http and https: a `javascript:` or `file:` link in a listing
/// is either a mistake or an attack, and neither is worth rendering.
String? sanitizeProseLink(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  final url = Uri.tryParse(trimmed);
  if (url == null || !url.hasAuthority) return null;
  final scheme = url.scheme.toLowerCase();
  if (scheme != 'http' && scheme != 'https') return null;
  return trimmed;
}

/// A description or an install note as the paragraphs it draws as. Empty
/// paragraphs are dropped, so the result is empty for text that was only ever
/// whitespace.
List<ProseParagraph> parseProse(String source) {
  final spans = <_Draft>[];
  var bold = 0;
  var italic = 0;
  var underline = 0;
  var centered = 0;
  // The link being collected, if any: whether a `[url]` is open at all (one
  // whose address we refused still is, so its `[/url]` is not left on screen),
  // the address once it is known, where its spans start, and whether the
  // address is the label itself (`[url]…[/url]`).
  var linkOpen = false;
  String? linkHref;
  var linkStart = -1;
  var linkFromLabel = false;

  void emit(String text) {
    if (text.isEmpty) return;
    spans.add(_Draft(
      text,
      bold: bold > 0,
      italic: italic > 0,
      underline: underline > 0,
      centered: centered > 0,
      link: linkHref,
    ));
  }

  /// Plain text on its way in, with any bare addresses in it picked out. Only
  /// runs outside a `[url]`, where a link is already decided.
  void emitText(String text) {
    if (linkOpen) {
      emit(text);
      return;
    }
    var at = 0;
    for (final match in _bareUrlPattern.allMatches(text)) {
      // A sentence ending in an address should not swallow its full stop.
      var end = match.end;
      while (end > match.start && '.,;:!?)]}\'"'.contains(text[end - 1])) {
        end--;
      }
      final href = sanitizeProseLink(text.substring(match.start, end));
      if (href == null) continue;
      emit(text.substring(at, match.start));
      linkHref = href;
      emit(text.substring(match.start, end));
      linkHref = null;
      at = end;
    }
    emit(text.substring(at));
  }

  /// `[url]…[/url]`: the label was the address all along. Rewritten now that it
  /// has all been read, and left as plain text when it is not an address.
  void closeLabelLink() {
    final label = spans.skip(linkStart).map((span) => span.text).join();
    final href = sanitizeProseLink(label);
    if (href != null) {
      for (var i = linkStart; i < spans.length; i++) {
        spans[i] = spans[i].withLink(href);
      }
    }
    linkFromLabel = false;
    linkStart = -1;
  }

  var at = 0;
  for (final match in _tagPattern.allMatches(source)) {
    emitText(source.substring(at, match.start));
    at = match.end;
    final closing = match[1] == '/';
    final tag = match[2]!.toLowerCase();
    final target = match[3];

    switch (tag) {
      case 'b':
        closing ? (bold > 0 ? bold-- : emit(match[0]!)) : bold++;
      case 'i':
        closing ? (italic > 0 ? italic-- : emit(match[0]!)) : italic++;
      case 'u':
        closing ? (underline > 0 ? underline-- : emit(match[0]!)) : underline++;
      case 'center':
        closing ? (centered > 0 ? centered-- : emit(match[0]!)) : centered++;
      case 'url':
        if (closing) {
          if (!linkOpen) {
            emit(match[0]!);
          } else {
            if (linkFromLabel) closeLabelLink();
            linkOpen = false;
            linkHref = null;
          }
        } else if (linkOpen) {
          // A link inside a link is nothing anyone meant to write.
          emit(match[0]!);
        } else if (target == null) {
          linkOpen = true;
          linkFromLabel = true;
          linkStart = spans.length;
        } else {
          // A `[url=…]` we cannot follow still shows its label, unlinked.
          linkOpen = true;
          linkHref = sanitizeProseLink(target);
        }
    }
  }
  emitText(source.substring(at));
  // Tags nobody closed run to the end rather than turning back into text: a
  // creator who forgot a `[/b]` meant the bold, and half a tag on screen reads
  // like the site is broken.
  if (linkFromLabel) closeLabelLink();

  return _paragraphs(spans);
}

/// The drafted spans cut into paragraphs on blank lines.
List<ProseParagraph> _paragraphs(List<_Draft> spans) {
  final paragraphs = <ProseParagraph>[];
  var current = <_Draft>[];

  void flush() {
    // Leading and trailing whitespace belongs to the gap between paragraphs.
    while (current.isNotEmpty) {
      current.first = current.first.withText(_trimLeft(current.first.text));
      if (current.first.text.isNotEmpty) break;
      current.removeAt(0);
    }
    while (current.isNotEmpty) {
      current.last = current.last.withText(_trimRight(current.last.text));
      if (current.last.text.isNotEmpty) break;
      current.removeLast();
    }
    if (current.isEmpty) return;
    // Neighbours in the same style are one run: tags that turned back into
    // text would otherwise leave the renderers a seam to draw.
    final merged = <_Draft>[];
    for (final span in current) {
      if (merged.isNotEmpty && merged.last.matches(span)) {
        merged.last.text += span.text;
      } else {
        merged.add(span.withText(span.text));
      }
    }
    paragraphs.add(ProseParagraph(
      [for (final span in merged) span.span],
      centered: merged.any((span) => span.centered),
    ));
    current = <_Draft>[];
  }

  for (final span in spans) {
    final pieces = span.text.split(_paragraphBreak);
    for (var i = 0; i < pieces.length; i++) {
      if (i > 0) flush();
      if (pieces[i].isEmpty) continue;
      current.add(span.withText(pieces[i]));
    }
  }
  flush();
  return paragraphs;
}

String _trimLeft(String value) => value.replaceFirst(RegExp(r'^\s+'), '');
String _trimRight(String value) => value.replaceFirst(RegExp(r'\s+$'), '');

/// The same text with every tag taken out, for the places that can only hold
/// one line of it - a page's meta description, a card's blurb.
String stripProse(String source) => parseProse(source)
    .map((paragraph) => paragraph.text)
    .join('\n\n')
    .replaceAll(RegExp(r'[ \t]+'), ' ');

/// A span while it is still being built: the styles are settled but the
/// paragraph it lands in is not.
class _Draft {
  _Draft(
    this.text, {
    required this.bold,
    required this.italic,
    required this.underline,
    required this.centered,
    this.link,
  });

  String text;
  final bool bold;
  final bool italic;
  final bool underline;
  final bool centered;
  final String? link;

  /// Same styles, so the two can be drawn as one run.
  bool matches(_Draft other) =>
      bold == other.bold &&
      italic == other.italic &&
      underline == other.underline &&
      centered == other.centered &&
      link == other.link;

  _Draft withText(String value) => _Draft(
        value,
        bold: bold,
        italic: italic,
        underline: underline,
        centered: centered,
        link: link,
      );

  _Draft withLink(String value) => _Draft(
        text,
        bold: bold,
        italic: italic,
        underline: underline,
        centered: centered,
        link: value,
      );

  ProseSpan get span => ProseSpan(
        text,
        bold: bold,
        italic: italic,
        underline: underline,
        link: link,
      );
}
