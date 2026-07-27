// @ts-check
import { defineConfig } from 'astro/config';

// Firebase Hosting serves web/dist. Every absolute URL on the site (canonical,
// hreflang, og:image, JSON-LD) is built from `site`.
export default defineConfig({
  site: 'https://thesimsmodmanager.web.app',
  build: { format: 'directory' },
  devToolbar: { enabled: false },
});
