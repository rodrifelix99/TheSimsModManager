// The ten languages the site ships, and how a page reaches its strings.
//
// The dictionaries are flat dot-key JSON, one file per language, and English is
// the template: every other file has to carry exactly its keys (test/site_test.dart
// pins that). Values may contain markup, so most of them are drawn with set:html.
import de from './de.json';
import en from './en.json';
import es from './es.json';
import fr from './fr.json';
import it from './it.json';
import ja from './ja.json';
import pl from './pl.json';
import pt from './pt.json';
import ru from './ru.json';
import zh from './zh.json';

/// English is the site root rather than /en/, but it is still a locale here.
export const locales = ['en', 'zh', 'es', 'pt', 'fr', 'de', 'it', 'ru', 'pl', 'ja'] as const;

export type Locale = (typeof locales)[number];

export const defaultLocale: Locale = 'en';

/// The order the language picker lists, each written in its own language.
export const localeNames: Record<Locale, string> = {
  en: 'English',
  zh: '简体中文',
  es: 'Español',
  pt: 'Português',
  fr: 'Français',
  de: 'Deutsch',
  it: 'Italiano',
  ru: 'Русский',
  pl: 'Polski',
  ja: '日本語',
};

const dictionaries: Record<Locale, Record<string, string>> = {
  en,
  zh,
  es,
  pt,
  fr,
  de,
  it,
  ru,
  pl,
  ja,
};

export interface Translate {
  /// The string as written, markup included: draw it with set:html.
  (key: string): string;
  /// The same string with its markup and entities resolved, for a title, an
  /// attribute or anything else that cannot hold HTML.
  plain(key: string): string;
}

/// Every string of one language. Missing keys are a build failure rather than a
/// blank on the live page.
export function useTranslations(locale: Locale): Translate {
  const strings = dictionaries[locale];
  const t = (key: string): string => {
    const value = strings[key];
    if (value === undefined) {
      throw new Error(`${locale}.json is missing "${key}"`);
    }
    return value;
  };
  const translate = t as Translate;
  translate.plain = (key: string) => plain(t(key));
  return translate;
}

const ENTITIES: Record<string, string> = {
  '&amp;': '&',
  '&nbsp;': ' ',
  '&lt;': '<',
  '&gt;': '>',
  '&quot;': '"',
  '&#39;': "'",
};

/// Markup is fine inside a paragraph, never inside an attribute or JSON-LD.
export function plain(value: string): string {
  return value
    .replace(/<[^>]+>/g, '')
    .replace(/&amp;|&nbsp;|&lt;|&gt;|&quot;|&#39;/g, (entity) => ENTITIES[entity]);
}

/// Every portal string of one language, for the block its script reads. The
/// portal builds most of its interface at runtime, so it takes the lot rather
/// than a hand-kept subset that would rot the moment a message moves.
export function portalStrings(locale: Locale): Record<string, string> {
  return Object.fromEntries(
    Object.entries(dictionaries[locale]).filter(([key]) => key.startsWith('portal.')),
  );
}

/// What the mod page's script reads. It draws most of itself from the markup
/// Astro already rendered and only needs the strings that carry the mod's own
/// name, author or size, plus the size units it shares with the portal.
export function modStrings(locale: Locale): Record<string, string> {
  return Object.fromEntries(
    Object.entries(dictionaries[locale]).filter(
      ([key]) => key.startsWith('mod.') || key.startsWith('portal.size.'),
    ),
  );
}

/// What the language banner reads: every language's own offer, because whose
/// language the visitor speaks is only known in the browser.
export const languageOffers = Object.fromEntries(
  locales.map((code) => [
    code,
    {
      msg: dictionaries[code]['banner.msg'],
      cta: dictionaries[code]['banner.cta'],
      close: dictionaries[code]['banner.close'],
    },
  ]),
);

/// Where a page lives. `base` is the page within the site ('' for the landing
/// page, 'portal/' for the portal), always with its trailing slash.
export function localePath(locale: Locale, base = ''): string {
  return locale === defaultLocale ? `/${base}` : `/${locale}/${base}`;
}

/// The nine non-English routes a [lang] page builds.
export function translatedRoutes() {
  return locales
    .filter((code) => code !== defaultLocale)
    .map((lang) => ({ params: { lang }, props: { locale: lang } }));
}
