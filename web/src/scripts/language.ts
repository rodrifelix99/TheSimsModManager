// Picking a language, and offering one.
//
// Every localized page carries its own place in the site on <html data-base>
// ('' for the landing page, 'portal/' for the portal), so both the picker and
// the banner can point at the same page in another language.

const base = () => document.documentElement.dataset.base ?? '';

const langHref = (code: string) => (code ? `/${code}/${base()}` : `/${base()}`);

export function wireLanguagePicker() {
  const picker = document.getElementById('lang-picker');
  if (!(picker instanceof HTMLSelectElement)) return;
  picker.addEventListener('change', () => {
    location.href = langHref(picker.value);
  });
}

/* Sending people somewhere based on Accept-Language would mean Googlebot,
   which crawls from the US, only ever sees the English page. So the other nine
   stay reachable by their own URL and this only suggests. */
export function offerLanguage() {
  document.querySelector('.lang-offer')?.remove();
  let dismissed = false;
  try {
    dismissed = localStorage.getItem('lang-offer') === 'off';
  } catch {
    /* private mode; offer it anyway */
  }
  if (dismissed) return;

  const block = document.getElementById('lang-offers');
  const header = document.querySelector('header');
  if (!block?.textContent || !header) return;
  const offers: Record<string, { msg: string; cta: string; close: string }> = JSON.parse(
    block.textContent,
  );

  const here = document.documentElement.lang;
  const wanted = (
    navigator.languages?.length ? [...navigator.languages] : [navigator.language || '']
  )
    .map((tag) => tag.toLowerCase().split('-')[0])
    .find((code) => offers[code]);
  if (!wanted || wanted === here) return;

  const offer = offers[wanted];
  const bar = document.createElement('div');
  bar.className = 'lang-offer';
  // The banner speaks the visitor's language, not the page's, so it needs to
  // say so for screen readers and for hyphenation.
  bar.lang = wanted;
  const wrap = document.createElement('div');
  wrap.className = 'wrap';
  const text = document.createElement('p');
  text.textContent = offer.msg;
  const link = document.createElement('a');
  link.href = langHref(wanted === 'en' ? '' : wanted);
  link.textContent = offer.cta;
  const close = document.createElement('button');
  close.type = 'button';
  close.textContent = '×';
  close.setAttribute('aria-label', offer.close);
  close.addEventListener('click', () => {
    try {
      localStorage.setItem('lang-offer', 'off');
    } catch {
      /* nothing to remember it with; the bar still closes */
    }
    bar.remove();
  });
  wrap.append(text, link, close);
  bar.append(wrap);
  header.insertAdjacentElement('afterend', bar);
}
