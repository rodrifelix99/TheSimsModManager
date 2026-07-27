// Pages that build part of themselves at runtime hand their language over in a
// JSON block, and everything below reads it from here. The portal does it for
// nearly its whole interface; the mod page only for the parts that depend on
// which mod it is.
const ENTITIES: Record<string, string> = {
  '&amp;': '&',
  '&nbsp;': ' ',
  '&lt;': '<',
  '&gt;': '>',
  '&quot;': '"',
  '&#39;': "'",
};

let strings: Record<string, string> = {};

export function loadStrings(id = 'portal-strings') {
  const block = document.getElementById(id);
  if (block?.textContent) strings = JSON.parse(block.textContent);
}

/// One string, with %s replaced by [args] in order. What comes back is plain
/// text for textContent, so the markup a few of them carry is dropped.
export function s(key: string, ...args: string[]): string {
  let value = strings[key] ?? key;
  for (const arg of args) value = value.replace('%s', arg);
  return value
    .replace(/<[^>]+>/g, '')
    .replace(/&amp;|&nbsp;|&lt;|&gt;|&quot;|&#39;/g, (entity) => ENTITIES[entity]);
}

/// A file size the way both the portal and the mod page write it.
export const fmtSize = (bytes: number) =>
  bytes >= 1 << 30
    ? (bytes / (1 << 30)).toFixed(1) + ' ' + s('portal.size.gb')
    : bytes >= 1 << 20
      ? (bytes / (1 << 20)).toFixed(1) + ' ' + s('portal.size.mb')
      : Math.max(1, Math.round(bytes / 1024)) + ' ' + s('portal.size.kb');
