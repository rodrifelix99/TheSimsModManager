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
//
// The second function here counts downloads; it is unrelated to the page and
// shares only the constants above it.
import { onRequest } from 'firebase-functions/v2/https';
import { getApps, initializeApp } from 'firebase-admin/app';
import { FieldValue, getFirestore } from 'firebase-admin/firestore';
import { createHash } from 'node:crypto';

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
const LOCALES = ['en', 'zh', 'es', 'pt', 'fr', 'de', 'it', 'ru', 'pl', 'ja', 'el'];

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

/// A description's formatting tags taken back out. The browser half renders
/// them (web/src/data/markup.ts); a meta description and an og:title are one
/// line of plain text, and `[b]` in a search result reads as a broken site.
/// Only the tags that file knows, so `[WIP]` in a title survives.
const stripTags = (text) =>
  String(text).replace(/\[\/?(?:b|i|u|center|url)(?:=[^\]\n]*)?\]/gi, '');

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
    const description = summarize(stripTags(plain(fields.description) ?? ''));

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

// ------------------------------------------------------------- the counter

// What a creator gets to see: how many people actually took their mod. Both
// halves of The Exchange ping this - the app once an install of a listing has
// finished (lib/src/ui/app_controller.dart), and the mod page when someone uses
// the plain download button (web/src/scripts/mod-page.ts). Nothing else may
// write the number: firestore.rules holds `downloads` still against every
// client, so the only path to it is through here, with the admin SDK.

/// One machine's download of one listing, for as long as this reads the same.
/// A creator's number should mean "people who took this" rather than "times a
/// button was pressed", so pressing it twice on the same evening counts once.
/// Whole days rather than a rolling window because it has to be computable
/// without reading anything back.
const dayBucket = () => Math.floor(Date.now() / 86_400_000);

/// The hit records exist only to answer "seen this one already", and the day
/// in the key means one older than yesterday can never be matched again.
/// Deleted by Firestore's TTL policy on the `hits` collection group (set it on
/// the `expiresAt` field); without the policy they pile up harmlessly, so
/// nothing here depends on them going away.
const HIT_TTL_MS = 3 * 86_400_000;

let firestore;
function db() {
  if (!firestore) {
    if (getApps().length === 0) initializeApp();
    firestore = getFirestore();
  }
  return firestore;
}

/// Who is asking, as something we can compare without keeping. The address and
/// the user agent go in, a hash comes out: enough to recognise the same
/// machine twice today, and not an IP address sitting in the database.
function hitKey(request, id) {
  const forwarded = String(request.headers['x-forwarded-for'] ?? '');
  const address = (forwarded.split(',')[0] || request.ip || '').trim();
  const agent = String(request.headers['user-agent'] ?? '');
  return createHash('sha256')
    .update(`${address}\n${agent}\n${id}\n${dayBucket()}`)
    .digest('base64url')
    .slice(0, 32);
}

export const recordDownload = onRequest(
  { region: 'us-central1', memory: '256MiB', maxInstances: 10, invoker: 'public' },
  async (request, response) => {
    response.set('Cache-Control', 'no-store');
    if (request.method !== 'POST') {
      response.status(405).json({ error: 'POST' });
      return;
    }

    const segments = request.path.split('/').filter(Boolean);
    const id = segments[segments.length - 1] ?? '';
    if (!LISTING_ID.test(id)) {
      response.status(400).json({ error: 'id' });
      return;
    }

    try {
      const listing = db().collection('mods').doc(id);
      const snap = await listing.get();
      // An unpublished draft is not on any shelf, so a ping naming one is
      // either stale or made up. Same answer as a listing that never existed.
      if (!snap.exists || snap.get('published') !== true) {
        response.status(404).json({ error: 'listing' });
        return;
      }

      // create() is the whole guard: it fails if this machine already counted
      // for this listing today, and it is one write either way.
      try {
        await listing.collection('hits').doc(hitKey(request, id)).create({
          at: FieldValue.serverTimestamp(),
          expiresAt: new Date(Date.now() + HIT_TTL_MS),
        });
      } catch (error) {
        if (error?.code === 6 /* ALREADY_EXISTS */) {
          response.status(200).json({ counted: false });
          return;
        }
        throw error;
      }

      await listing.update({ downloads: FieldValue.increment(1) });
      response.status(200).json({ counted: true });
    } catch (error) {
      // A count that did not happen is not worth telling the caller about -
      // neither the app nor the page has anything to do with the answer, and
      // the download itself already worked.
      console.error(error);
      response.status(200).json({ counted: false });
    }
  },
);
