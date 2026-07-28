// The formatting buttons over the two description boxes.
//
// They edit the text in the textarea, tags and all, because that is what a
// listing stores. Every insertion goes through execCommand('insertText') where
// it exists: it is the only way to put text in a field without throwing away
// the browser's own undo history, and losing a paragraph to a Ctrl+Z that no
// longer works is a worse bug than any of the ones this file could have.
import { renderProse } from '../../data/markup';

/// What each button writes around the selection. `caret` is where to leave the
/// cursor when there was nothing selected to wrap.
const wrappers: Record<string, { before: string; after: string }> = {
  b: { before: '[b]', after: '[/b]' },
  i: { before: '[i]', after: '[/i]' },
  u: { before: '[u]', after: '[/u]' },
  center: { before: '[center]', after: '[/center]' },
};

/// A selection that is already an address links to itself; anything else gets
/// an address to fill in, left selected so typing replaces it.
const linkFor = (selection: string) => {
  if (/^https?:\/\/\S+$/i.test(selection.trim())) {
    return { before: '[url]', after: '[/url]', select: null };
  }
  // The offsets of the `https://` inside `[url=https://]`.
  return { before: '[url=https://]', after: '[/url]', select: [5, 13] as const };
};

function replace(area: HTMLTextAreaElement, text: string, start: number, end: number) {
  area.focus();
  area.setSelectionRange(start, end);
  let inserted = false;
  try {
    inserted = document.execCommand('insertText', false, text);
  } catch {
    inserted = false;
  }
  if (inserted) return;
  // Firefox has dropped execCommand on form fields. Undo suffers; nothing else.
  area.setRangeText(text, start, end, 'end');
  area.dispatchEvent(new Event('input', { bubbles: true }));
}

function apply(area: HTMLTextAreaElement, fmt: string) {
  const start = area.selectionStart;
  const end = area.selectionEnd;
  const selection = area.value.slice(start, end);
  const wrapper = wrappers[fmt];
  if (fmt !== 'link' && !wrapper) return;
  const wrap =
    fmt === 'link' ? linkFor(selection) : { ...wrapper, select: null as readonly [number, number] | null };

  replace(area, `${wrap.before}${selection}${wrap.after}`, start, end);
  if (wrap.select) {
    // The `https://` of a fresh link, ready to be typed over.
    area.setSelectionRange(start + wrap.select[0], start + wrap.select[1]);
  } else if (selection) {
    area.setSelectionRange(start + wrap.before.length, start + wrap.before.length + selection.length);
  } else {
    const caret = start + wrap.before.length;
    area.setSelectionRange(caret, caret);
  }
}

/// The keys everyone already presses. Ctrl+U is "view source" on Windows, so it
/// is claimed here too - inside a textarea nobody means the other one.
const shortcuts: Record<string, string> = { b: 'b', i: 'i', u: 'u' };

/// Every wired box, so the editor can put them all back in writing mode.
const previews: Array<(on: boolean) => void> = [];

/// Back to the textareas. Saving while a preview is up would otherwise leave
/// the browser trying to focus a hidden required field, and the form would
/// refuse to submit with nothing on screen to say why.
export const closeFormatPreviews = () => previews.forEach((show) => show(false));

export function wireFormatting(fieldId: string) {
  const area = document.getElementById(fieldId) as HTMLTextAreaElement | null;
  const bar = document.querySelector<HTMLElement>(`.fmtbar[data-for="${fieldId}"]`);
  const preview = document.querySelector<HTMLElement>(`[data-preview="${fieldId}"]`);
  if (!area || !bar || !preview) return;

  const showPreview = (on: boolean) => {
    if (on) renderProse(preview, area.value);
    preview.classList.toggle('hidden', !on);
    area.classList.toggle('hidden', on);
    const button = bar.querySelector<HTMLButtonElement>('[data-fmt="preview"]')!;
    button.setAttribute('aria-pressed', String(on));
    for (const other of bar.querySelectorAll<HTMLButtonElement>('[data-fmt]:not([data-fmt="preview"])')) {
      other.disabled = on;
    }
  };

  previews.push(showPreview);

  bar.addEventListener('click', (event) => {
    const button = (event.target as HTMLElement).closest<HTMLElement>('[data-fmt]');
    if (!button) return;
    const fmt = button.dataset.fmt!;
    if (fmt === 'preview') {
      showPreview(preview.classList.contains('hidden'));
      return;
    }
    apply(area, fmt);
  });

  area.addEventListener('keydown', (event) => {
    if (!event.ctrlKey && !event.metaKey) return;
    if (event.altKey) return;
    const fmt = shortcuts[event.key.toLowerCase()];
    if (!fmt) return;
    event.preventDefault();
    apply(area, fmt);
  });

  // A box left showing its preview would open on the next listing still
  // showing the last one's.
  area.form?.addEventListener('reset', () => showPreview(false));
  showPreview(false);
}
