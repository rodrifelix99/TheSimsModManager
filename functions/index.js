// The one thing on this site that cannot be a static file.
//
// A mod's page has to exist at /m/<id> for every listing on The Exchange,
// including the one a creator published a minute ago, and it has to carry that
// mod's own name and cover art in its meta tags - otherwise the link a creator
// pastes on Tumblr or Discord unfurls as a generic card for the site, which is
// most of the reason to share it at all. Astro cannot pre-render a page per
// Firestore document, so this fills one in at request time.
//
// It does as little as possible. Astro still draws the page: this fetches the
// shell Astro built (/m/index.html, which Hosting serves as a plain static file
// because static content wins over a rewrite), swaps five sentinels for this
// mod's title, description, cover and id, and drops the Firestore document into
// the block the page's script reads. Nothing about the layout, the styling or
// the wording lives here, and a site deploy changes the page without this ever
// being redeployed.
import { onRequest } from 'firebase-functions/v2/https';

const SITE = 'https://thesimsmodmanager.web.app';

// The same three constants web/src/data/exchange.ts holds. This is deployed as
// its own package and cannot import from the site's source. The web API key is
// public by design: firestore.rules decides what may be read, and it only
// hands an unauthenticated caller a listing whose `published` is true - so an
// unfinished draft answers 403 here and never reaches a page.
const PROJECT = 'thesimsmodmanager';
const BUCKET = 'thesimsmodmanager.firebasestorage.app';
const API_KEY = 'AIzaSyDsC3_mQFDUXj6pmKMw1_xf4_XigC82smE';

/// The site's languages. English is the root, the rest sit under their code.
const LOCALES = ['en', 'zh', 'es', 'pt', 'fr', 'de', 'it', 'ru', 'pl', 'ja'];

/// This arrives out of a URL a stranger wrote and is about to become a path.
const LISTING_ID = /^[A-Za-z0-9_-]{1,64}$/;

const listingUrl = (id) =>
  `https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents/mods/${encodeURIComponent(id)}?key=${API_KEY}`;

const fileUrl = (path) =>
  `https://firebasestorage.googleapis.com/v0/b/${BUCKET}/o/${encodeURIComponent(path)}?alt=media`;

/// Creator-written text on its way into an HTML attribute or a title.
const escapeHtml = (value) =>
  String(value)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');

/// Creator-written text on its way into a <script> block. Escaping `<` is what
/// stops a description containing `</script>` from ending the block early.
const escapeJson = (value) => JSON.stringify(value).replace(/</g, '\\u003c');

/// A meta description: one line, and short enough that nothing truncates it in
/// an unflattering place.
function summarize(text, limit = 200) {
  const line = String(text).replace(/\s+/g, ' ').trim();
  if (line.length <= limit) return line;
  const cut = line.slice(0, limit);
  const lastSpace = cut.lastIndexOf(' ');
  return (lastSpace > limit * 0.6 ? cut.slice(0, lastSpace) : cut) + '…';
}

const plain = (field) => {
  if (!field || typeof field !== 'object') return undefined;
  if ('stringValue' in field) return field.stringValue;
  if ('integerValue' in field) return Number(field.integerValue);
  if ('arrayValue' in field) return (field.arrayValue.values ?? []).map(plain);
  if ('mapValue' in field) {
    return Object.fromEntries(
      Object.entries(field.mapValue.fields ?? {}).map(([key, value]) => [key, plain(value)]),
    );
  }
  return undefined;
};

// ---------------------------------------------------------------- the shell

/// The built page per language, and the strings it carries, kept for as long as
/// a deploy is likely to take to matter. Re-fetched rather than bundled so a
/// wording fix on the site reaches these pages on the next site deploy, with
/// nothing to redeploy here.
const SHELL_TTL_MS = 5 * 60 * 1000;
const shells = new Map();

/// Which host to read the shell from. Normally the one that served this
/// request, so a preview channel and the emulator read their own build rather
/// than production's - but only from a host we recognise. The function's own
/// URL is public, so a caller can put anything in Host, and fetching that would
/// mean serving back whatever they pointed us at.
function originFor(request) {
  const host = request.headers['x-forwarded-host'] ?? request.headers.host ?? '';
  const known =
    /^([a-z0-9-]+\.)?thesimsmodmanager\.(web\.app|firebaseapp\.com)$/.test(host) ||
    /^(localhost|127\.0\.0\.1)(:\d+)?$/.test(host);
  if (!known) return SITE;
  return `${/^(localhost|127\.0\.0\.1)/.test(host) ? 'http' : 'https'}://${host}`;
}

async function loadShell(origin, locale) {
  const key = `${origin} ${locale}`;
  const cached = shells.get(key);
  if (cached && Date.now() - cached.at < SHELL_TTL_MS) return cached.shell;

  const prefix = locale === 'en' ? '' : `${locale}/`;
  const response = await fetch(`${origin}/${prefix}m/index.html`);
  if (!response.ok) throw new Error(`shell ${locale}: ${response.status}`);
  const html = await response.text();
  // Hosting serves this path statically; if a rewrite ever swallowed it we
  // would be reading our own output, so make sure the sentinels are still here.
  if (!html.includes('__MOD_DATA__')) throw new Error(`shell ${locale}: already filled`);

  const block = html.match(
    /<script type="application\/json" id="mod-strings">([\s\S]*?)<\/script>/,
  );
  const shell = { html, strings: block ? JSON.parse(block[1]) : {} };
  shells.set(key, { shell, at: Date.now() });
  return shell;
}

/// The shell with every sentinel replaced. Missing one would show a visitor
/// `__MOD_TITLE__`, so they are all filled on both paths through here.
function fill(shell, { id, title, ogTitle, description, image, data }) {
  return shell.html
    .replaceAll('__MOD_ID__', encodeURIComponent(id))
    .replaceAll('__MOD_TITLE__', escapeHtml(title))
    .replaceAll('__MOD_OGTITLE__', escapeHtml(ogTitle))
    .replaceAll('__MOD_DESC__', escapeHtml(description))
    .replaceAll('__MOD_IMAGE__', escapeHtml(image))
    .replace('__MOD_DATA__', escapeJson(data));
}

// ---------------------------------------------------------------- the page

export const modPage = onRequest(
  { region: 'us-central1', memory: '256MiB', maxInstances: 10, invoker: 'public' },
  async (request, response) => {
    const segments = request.path.split('/').filter(Boolean);
    const locale = LOCALES.includes(segments[0]) && segments[0] !== 'en' ? segments[0] : 'en';
    const at = segments.lastIndexOf('m');
    const id = at === -1 ? '' : (segments[at + 1] ?? '');

    let shell;
    try {
      shell = await loadShell(originFor(request), locale);
    } catch (error) {
      // Nothing to draw with. A redirect beats a blank page, and the visitor
      // lands where the mod would have pointed them anyway.
      console.error(error);
      response.redirect(302, `${SITE}/${locale === 'en' ? '' : locale + '/'}#exchange`);
      return;
    }

    const notFound = () => {
      response
        .status(404)
        .set('Cache-Control', 'public, max-age=60, s-maxage=60')
        .set('Content-Type', 'text/html; charset=utf-8')
        .send(
          fill(shell, {
            id,
            title: shell.strings['mod.notFoundTitle'] ?? 'Not found',
            ogTitle: shell.strings['mod.notFoundTitle'] ?? 'Not found',
            description: shell.strings['mod.notFoundBody'] ?? '',
            image: `${SITE}/images/library-grid.png`,
            data: { notFound: true },
          }),
        );
    };

    if (!LISTING_ID.test(id)) {
      notFound();
      return;
    }

    let doc;
    try {
      const listing = await fetch(listingUrl(id));
      // 403 is what an unpublished draft looks like to an anonymous reader, so
      // it is the same answer as 404 on purpose.
      if (!listing.ok) {
        notFound();
        return;
      }
      doc = await listing.json();
    } catch (error) {
      console.error(error);
      notFound();
      return;
    }

    const fields = doc?.fields ?? {};
    const name = plain(fields.name);
    if (typeof name !== 'string') {
      notFound();
      return;
    }
    const images = plain(fields.images) ?? [];
    const description = summarize(plain(fields.description) ?? '');

    response
      .status(200)
      // Long enough on the CDN that a link doing the rounds costs one call,
      // short enough that a creator's edit shows up while they are still
      // looking at it.
      .set('Cache-Control', 'public, max-age=300, s-maxage=600')
      .set('Content-Type', 'text/html; charset=utf-8')
      .send(
        fill(shell, {
          id,
          title: `${name} · The Exchange · The Sims Mod Manager`,
          ogTitle: name,
          description,
          image: images.length > 0 ? fileUrl(images[0]) : `${SITE}/images/library-grid.png`,
          data: { doc },
        }),
      );
  },
);
