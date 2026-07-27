// The landing page and the portal, in every language. The thank-you page is
// deliberately left out: it is noindex and nobody should arrive there from a
// search.
import type { APIRoute } from 'astro';
import { locales, localePath } from '../i18n';

export const GET: APIRoute = ({ site }) => {
  const paths = ['', 'portal/'].flatMap((base) =>
    locales.map((locale) => new URL(localePath(locale, base), site).href),
  );
  const body =
    '<?xml version="1.0" encoding="UTF-8"?>\n' +
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n' +
    paths.map((url) => `  <url>\n    <loc>${url}</loc>\n  </url>\n`).join('') +
    '</urlset>\n';
  return new Response(body, { headers: { 'Content-Type': 'application/xml; charset=utf-8' } });
};
