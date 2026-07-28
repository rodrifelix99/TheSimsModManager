import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../core/mod_markup.dart';

/// A listing's description or install notes, with the little bit of formatting
/// creators may put in them (see core/mod_markup.dart). Stateful for one
/// reason: every link needs a recognizer, and a recognizer has to be disposed
/// of - a `Text.rich` built inline would leak one per rebuild.
class ProseText extends StatefulWidget {
  const ProseText(
    this.source, {
    super.key,
    required this.style,
    required this.linkColor,
    this.onLink,
  });

  final String source;
  final TextStyle style;
  final Color linkColor;

  /// Where a link goes. Null draws links as ordinary text, which is what a
  /// preview wants.
  final void Function(String url)? onLink;

  @override
  State<ProseText> createState() => _ProseTextState();
}

class _ProseTextState extends State<ProseText> {
  final _recognizers = <TapGestureRecognizer>[];
  var _paragraphs = const <ProseParagraph>[];

  @override
  void initState() {
    super.initState();
    _paragraphs = parseProse(widget.source);
  }

  @override
  void didUpdateWidget(ProseText old) {
    super.didUpdateWidget(old);
    if (old.source != widget.source) {
      _paragraphs = parseProse(widget.source);
    }
  }

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  TextSpan _span(ProseSpan span) {
    final link = span.link;
    final onLink = widget.onLink;
    TapGestureRecognizer? recognizer;
    if (link != null && onLink != null) {
      recognizer = TapGestureRecognizer()..onTap = () => onLink(link);
      _recognizers.add(recognizer);
    }
    return TextSpan(
      text: span.text,
      recognizer: recognizer,
      mouseCursor: link == null ? null : SystemMouseCursors.click,
      style: widget.style.copyWith(
        fontWeight: span.bold ? FontWeight.w900 : null,
        fontStyle: span.italic ? FontStyle.italic : null,
        color: link == null ? null : widget.linkColor,
        decoration: switch ((span.underline, link != null)) {
          (false, false) => null,
          _ => TextDecoration.underline,
        },
        decorationColor: link == null ? null : widget.linkColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilt from scratch, so the recognizers from the last build are gone
    // whichever way this was reached.
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, paragraph) in _paragraphs.indexed) ...[
          if (index > 0) SizedBox(height: widget.style.fontSize ?? 13.5),
          Text.rich(
            TextSpan(children: [for (final span in paragraph.spans) _span(span)]),
            textAlign: paragraph.centered ? TextAlign.center : TextAlign.start,
          ),
        ],
      ],
    );
  }
}
