// The mod page's browser half. Almost everything on the page was already drawn
// by Astro; what is left is the listing itself, which arrives in the #mod-data
// block that the modPage function filled in. Nothing here signs in or writes,
// so it loads no Firebase SDK: the one fallback fetch goes straight to the REST
// endpoint that firestore.rules already opens to everybody.
import { fileUrl, listingIdPattern, listingUrl, toListing, type Listing } from '../data/exchange';
import { gameNames } from '../data/games';
import { fmtSize, loadStrings, s } from './strings';

const $ = (id: string) => document.getElementById(id)!;
const show = (id: string, visible = true) => $(id).toggleAttribute('hidden', !visible);

/// The listing id out of `/m/<id>` or `/<lang>/m/<id>`, or null when this is
/// not one of those addresses after all.
function idFromPath(): string | null {
  const segments = window.location.pathname.split('/').filter(Boolean);
  const at = segments.lastIndexOf('m');
  const id = at === -1 ? undefined : segments[at + 1];
  return id && listingIdPattern.test(id) ? id : null;
}

/// What the page was handed. `__MOD_DATA__` still sitting there means no
/// function stood in front of the page, which is what `astro dev` looks like.
function embedded(): { doc?: unknown; notFound?: boolean } | null {
  const raw = $('mod-data').textContent?.trim();
  if (!raw || raw.startsWith('__MOD_')) return null;
  try {
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

async function fetched(): Promise<unknown | null> {
  const id = idFromPath();
  if (!id) return null;
  try {
    const response = await fetch(listingUrl(id));
    return response.ok ? await response.json() : null;
  } catch {
    return null;
  }
}

/// The creator's own text, blank lines and all, as paragraphs. textContent
/// throughout: this is someone else's writing on our page.
function prose(into: HTMLElement, text: string) {
  into.textContent = '';
  for (const chunk of text.split(/\n\s*\n/)) {
    const paragraph = chunk.trim();
    if (!paragraph) continue;
    const element = document.createElement('p');
    element.textContent = paragraph;
    into.append(element);
  }
  return into.childElementCount > 0;
}

function gallery(mod: Listing) {
  const cover = $('mod-cover') as HTMLImageElement;
  const thumbs = $('mod-thumbs');
  if (mod.images.length === 0) {
    show('mod-cover-empty');
    return;
  }
  const showImage = (index: number) => {
    cover.src = fileUrl(mod.images[index]);
    cover.alt = s(index === 0 ? 'mod.coverAlt' : 'mod.shotAlt', mod.name);
    for (const [at, button] of [...thumbs.children].entries()) {
      button.setAttribute('aria-current', String(at === index));
    }
  };
  show('mod-cover');
  if (mod.images.length > 1) {
    mod.images.forEach((path, index) => {
      const button = document.createElement('button');
      button.type = 'button';
      const thumb = document.createElement('img');
      thumb.src = fileUrl(path);
      thumb.alt = s('mod.shotAlt', mod.name);
      thumb.loading = 'lazy';
      button.append(thumb);
      button.addEventListener('click', () => showImage(index));
      thumbs.append(button);
    });
  }
  showImage(0);
}

function paint(mod: Listing) {
  $('mod-name').textContent = mod.name;
  $('mod-by').textContent = s('mod.by', mod.authorName);
  $('mod-game').textContent = gameNames[mod.gameId] ?? mod.gameId;
  $('mod-version').textContent = mod.version;
  $('mod-size').textContent = fmtSize(mod.file.size);

  const updated = mod.updatedAt ? new Date(mod.updatedAt) : null;
  if (updated && !Number.isNaN(updated.valueOf())) {
    $('mod-updated').textContent = updated.toLocaleDateString(document.documentElement.lang, {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
    });
    show('mod-updated-fact');
  }

  // The one address the app answers to. It opens the listing; it never
  // installs on its own.
  ($('mod-install') as HTMLAnchorElement).href = `simsmodmanager://mod/${mod.id}`;
  const download = $('mod-download') as HTMLAnchorElement;
  download.href = fileUrl(mod.file.path);
  download.setAttribute('download', mod.file.name);
  download.textContent = s('mod.downloadFile', fmtSize(mod.file.size));

  gallery(mod);
  if (prose($('mod-description'), mod.description)) show('mod-about');
  if (prose($('mod-instructions'), mod.instructions)) show('mod-howto');

  show('mod-loading', false);
  show('mod-card');
}

function missing() {
  show('mod-loading', false);
  show('mod-missing');
  document.title = s('mod.notFoundTitle');
}

export async function startModPage() {
  loadStrings('mod-strings');
  const handed = embedded();
  if (handed?.notFound) {
    missing();
    return;
  }
  const doc = handed?.doc ?? (await fetched());
  const mod = toListing(doc);
  if (!mod) {
    missing();
    return;
  }
  // Only worth writing when nothing rendered the head for us; the function
  // already put a better title there, description included.
  if (!handed) document.title = `${mod.name} · The Exchange · The Sims Mod Manager`;
  paint(mod);
}
