// The formatting a creator may put in a listing's description, as the website
// reads it.
//
// This is the twin of lib/src/core/mod_markup.dart, which the app draws from:
// same tags, same rules, same answers, kept together by hand and pinned on the
// Dart side by test/mod_markup_test.dart. Change one, change the other.
//
//   [b]bold[/b]  [i]italic[/i]  [u]underline[/u]
//   [center]a whole paragraph[/center]
//   [url]https://example.com[/url]  [url=https://example.com]label[/url]
//
// Nothing here ever builds HTML from creator text: render() makes elements and
// sets textContent, so a description is drawn, never run.

export interface ProseSpan {
  text: string;
  bold: boolean;
  italic: boolean;
  underline: boolean;
  /// An http(s) address, or undefined. No other scheme survives the parser.
  link?: string;
}

export interface ProseParagraph {
  spans: ProseSpan[];
  centered: boolean;
}

interface Draft extends ProseSpan {
  centered: boolean;
}

const tagPattern = /\[(\/?)(b|i|u|center|url)(?:=([^\]\n]*))?\]/gi;
const bareUrlPattern = /https?:\/\/[^\s[\]<>"']+/g;
const paragraphBreak = /\n[ \t]*\n\s*/;

/// An address as it may reach an href, or undefined when it may not. Only http
/// and https: a `javascript:` link in a listing is either a mistake or an
/// attack, and neither is worth rendering.
export function sanitizeLink(raw: string): string | undefined {
  const trimmed = raw.trim();
  if (!trimmed) return undefined;
  let url: URL;
  try {
    url = new URL(trimmed);
  } catch {
    return undefined;
  }
  if (url.protocol !== 'http:' && url.protocol !== 'https:') return undefined;
  return trimmed;
}

/// A description or an install note as the paragraphs it draws as.
export function parseProse(source: string): ProseParagraph[] {
  const spans: Draft[] = [];
  let bold = 0;
  let italic = 0;
  let underline = 0;
  let centered = 0;
  // The link being collected: whether a `[url]` is open at all (one whose
  // address we refused still is, so its `[/url]` is not left on screen), the
  // address once it is known, where its spans start, and whether the address is
  // the label itself (`[url]…[/url]`).
  let linkOpen = false;
  let linkHref: string | undefined;
  let linkStart = -1;
  let linkFromLabel = false;

  const emit = (text: string) => {
    if (!text) return;
    spans.push({
      text,
      bold: bold > 0,
      italic: italic > 0,
      underline: underline > 0,
      centered: centered > 0,
      link: linkHref,
    });
  };

  /// Plain text on its way in, with any bare addresses in it picked out.
  /// Creators paste those far more often than they reach for a tag.
  const emitText = (text: string) => {
    if (linkOpen) {
      emit(text);
      return;
    }
    let at = 0;
    bareUrlPattern.lastIndex = 0;
    for (const match of text.matchAll(bareUrlPattern)) {
      const start = match.index!;
      // A sentence ending in an address should not swallow its full stop.
      let end = start + match[0].length;
      while (end > start && '.,;:!?)]}\'"'.includes(text[end - 1])) end--;
      const href = sanitizeLink(text.slice(start, end));
      if (!href) continue;
      emit(text.slice(at, start));
      linkHref = href;
      emit(text.slice(start, end));
      linkHref = undefined;
      at = end;
    }
    emit(text.slice(at));
  };

  /// `[url]…[/url]`: the label was the address all along. Left as plain text
  /// when it turns out not to be one.
  const closeLabelLink = () => {
    const href = sanitizeLink(
      spans
        .slice(linkStart)
        .map((span) => span.text)
        .join(''),
    );
    if (href) for (let i = linkStart; i < spans.length; i++) spans[i].link = href;
    linkFromLabel = false;
    linkStart = -1;
  };

  let at = 0;
  tagPattern.lastIndex = 0;
  for (const match of source.matchAll(tagPattern)) {
    const start = match.index!;
    emitText(source.slice(at, start));
    at = start + match[0].length;
    const closing = match[1] === '/';
    const tag = match[2].toLowerCase();
    const target = match[3];

    switch (tag) {
      case 'b':
        if (!closing) bold++;
        else if (bold > 0) bold--;
        else emit(match[0]);
        break;
      case 'i':
        if (!closing) italic++;
        else if (italic > 0) italic--;
        else emit(match[0]);
        break;
      case 'u':
        if (!closing) underline++;
        else if (underline > 0) underline--;
        else emit(match[0]);
        break;
      case 'center':
        if (!closing) centered++;
        else if (centered > 0) centered--;
        else emit(match[0]);
        break;
      case 'url':
        if (closing) {
          if (!linkOpen) {
            emit(match[0]);
          } else {
            if (linkFromLabel) closeLabelLink();
            linkOpen = false;
            linkHref = undefined;
          }
        } else if (linkOpen) {
          // A link inside a link is nothing anyone meant to write.
          emit(match[0]);
        } else if (target === undefined) {
          linkOpen = true;
          linkFromLabel = true;
          linkStart = spans.length;
        } else {
          // A `[url=…]` we cannot follow still shows its label, unlinked.
          linkOpen = true;
          linkHref = sanitizeLink(target);
        }
        break;
    }
  }
  emitText(source.slice(at));
  // Tags nobody closed run to the end rather than turning back into text: a
  // creator who forgot a `[/b]` meant the bold, and half a tag on screen reads
  // like the site is broken.
  if (linkFromLabel) closeLabelLink();

  return paragraphs(spans);
}

const sameStyle = (a: Draft, b: Draft) =>
  a.bold === b.bold &&
  a.italic === b.italic &&
  a.underline === b.underline &&
  a.centered === b.centered &&
  a.link === b.link;

/// The drafted spans cut into paragraphs on blank lines, with neighbours in the
/// same style folded into one run.
function paragraphs(spans: Draft[]): ProseParagraph[] {
  const out: ProseParagraph[] = [];
  let current: Draft[] = [];

  const flush = () => {
    // Leading and trailing whitespace belongs to the gap between paragraphs.
    while (current.length) {
      current[0].text = current[0].text.replace(/^\s+/, '');
      if (current[0].text) break;
      current.shift();
    }
    while (current.length) {
      const last = current[current.length - 1];
      last.text = last.text.replace(/\s+$/, '');
      if (last.text) break;
      current.pop();
    }
    if (!current.length) return;
    const merged: Draft[] = [];
    for (const span of current) {
      const previous = merged[merged.length - 1];
      if (previous && sameStyle(previous, span)) previous.text += span.text;
      else merged.push({ ...span });
    }
    out.push({
      spans: merged.map(({ text, bold, italic, underline, link }) => ({
        text,
        bold,
        italic,
        underline,
        link,
      })),
      centered: merged.some((span) => span.centered),
    });
    current = [];
  };

  for (const span of spans) {
    const pieces = span.text.split(paragraphBreak);
    pieces.forEach((piece, index) => {
      if (index > 0) flush();
      if (piece) current.push({ ...span, text: piece });
    });
  }
  flush();
  return out;
}

/// The same text with every tag taken out, for the places that hold one line of
/// it - a card's blurb, a page's meta description.
export const stripProse = (source: string) =>
  parseProse(source)
    .map((paragraph) => paragraph.spans.map((span) => span.text).join(''))
    .join('\n\n')
    .replace(/[ \t]+/g, ' ');

/// Draws the text into `into`, replacing whatever was there. Returns whether
/// anything was written, which is what decides if the section shows at all.
export function renderProse(into: HTMLElement, text: string): boolean {
  into.textContent = '';
  for (const paragraph of parseProse(text)) {
    const element = document.createElement('p');
    if (paragraph.centered) element.style.textAlign = 'center';
    for (const span of paragraph.spans) {
      element.append(spanNode(span));
    }
    into.append(element);
  }
  return into.childElementCount > 0;
}

/// One span as nodes. Every line break inside it becomes a <br>, and the text
/// itself only ever arrives through textContent.
function spanNode(span: ProseSpan): Node {
  const lines = span.text.split('\n');
  const inner = document.createDocumentFragment();
  lines.forEach((line, index) => {
    if (index > 0) inner.append(document.createElement('br'));
    inner.append(document.createTextNode(line));
  });

  let node: HTMLElement | DocumentFragment = inner;
  const wrap = (tag: string) => {
    const element = document.createElement(tag);
    element.append(node);
    node = element;
  };
  if (span.underline) wrap('u');
  if (span.italic) wrap('em');
  if (span.bold) wrap('strong');
  if (span.link) {
    const anchor = document.createElement('a');
    anchor.href = span.link;
    anchor.rel = 'nofollow ugc noopener';
    anchor.target = '_blank';
    anchor.append(node);
    node = anchor;
  }
  return node;
}
