// The live theme strip: clicking a game repaints the whole page in that game's
// palette and swaps the hero screenshot underneath it. The palettes mirror
// lib/src/ui/game_theme.dart, light and dark, so the page really is showing
// what the app shows; `dark` is the Sims 4 dark palette, the app's own default.
const THEMES: Record<string, Record<string, string>> = {
  sims1: { accent: '#1665B0', accent2: '#2FA8DC', bg: '#D8E4F7', surface: '#F2F7FF', surfaceAlt: '#E4EDFB', text: '#12294F', muted: '#4A6591', border: '#A9C4E8', tint: '#CFE0F8', danger: '#D6551F' },
  sims2: { accent: '#37801F', accent2: '#C08A15', bg: '#DDE0F5', surface: '#F4F5FF', surfaceAlt: '#E8EAFA', text: '#23265C', muted: '#5C639C', border: '#B7BDE6', tint: '#CDD3F2', danger: '#D6551F' },
  sims3: { accent: '#1A6F9E', accent2: '#5CA83C', bg: '#DCE9F2', surface: '#F2F8FD', surfaceAlt: '#E4EFF7', text: '#123048', muted: '#4E7590', border: '#A9CBE2', tint: '#CBE4F4', danger: '#D6551F' },
  sims4: { accent: '#189771', accent2: '#12B0D6', bg: '#EAF6F2', surface: '#FFFFFF', surfaceAlt: '#F2FAF7', text: '#0F2E28', muted: '#5F827A', border: '#D9ECE5', tint: '#DCF5EC', danger: '#D6551F' },
  simsmedieval: { accent: '#9C7B1E', accent2: '#5E9732', bg: '#F1EBDC', surface: '#FFFDF4', surfaceAlt: '#F5EFDF', text: '#33290F', muted: '#857A5C', border: '#E3DAC0', tint: '#F0E7CB', danger: '#D6551F' },
  simcity3000: { accent: '#2C6491', accent2: '#D18B12', bg: '#DCE3EF', surface: '#EEF2F9', surfaceAlt: '#E1E7F2', text: '#14202C', muted: '#4C5C70', border: '#AEBACD', tint: '#CBD6E8', danger: '#D6551F' },
  simcity4: { accent: '#1C7A75', accent2: '#C87F16', bg: '#DCE5E5', surface: '#EBF1F1', surfaceAlt: '#DFE8E8', text: '#12242A', muted: '#4A6167', border: '#A9BBBD', tint: '#C6D6D7', danger: '#D6551F' },
  simcity2013: { accent: '#1B7CB8', accent2: '#E8821A', bg: '#DEE6ED', surface: '#FBFCFD', surfaceAlt: '#EFF3F7', text: '#24323C', muted: '#537CA2', border: '#C3CFDA', tint: '#DBE5EE', danger: '#D6551F' },
  dark: { accent: '#2FD3A1', accent2: '#32C5E8', bg: '#0C1614', surface: '#13201D', surfaceAlt: '#182724', text: '#E4F2EE', muted: '#8AA6A0', border: '#223330', tint: '#12332B', danger: '#E8794A' },
};

interface ThemeStrings {
  src: string;
  alt: string;
  caption: string;
}

export function wireThemeSwitcher() {
  const chips = document.querySelectorAll<HTMLElement>('#theme-chips .chip');
  if (!chips.length) return;
  const block = document.getElementById('theme-strings');
  const strings: Record<string, ThemeStrings> = block?.textContent
    ? JSON.parse(block.textContent)
    : {};
  const shot = document.getElementById('hero-shot') as HTMLImageElement | null;
  const caption = document.getElementById('shot-caption');

  // Swapping src straight away would blank the hero for as long as the new
  // screenshot takes to arrive; wait for it off-screen instead.
  const swapShot = (next: ThemeStrings) => {
    if (!shot || shot.getAttribute('src') === next.src) return;
    const preload = new Image();
    preload.src = next.src;
    const apply = () => {
      shot.src = next.src;
      shot.alt = next.alt;
    };
    if (preload.complete) apply();
    else preload.addEventListener('load', apply, { once: true });
  };

  chips.forEach((chip) =>
    chip.addEventListener('click', () => {
      const name = chip.dataset.theme ?? '';
      const theme = THEMES[name];
      if (!theme) return;
      // A couple of fixed-color assets (Apple's black logo) need to know which
      // way the page went; the palette alone cannot tell them.
      document.documentElement.dataset.theme = name;
      const style = document.documentElement.style;
      style.setProperty('--accent', theme.accent);
      style.setProperty('--accent2', theme.accent2);
      style.setProperty('--bg', theme.bg);
      style.setProperty('--surface', theme.surface);
      style.setProperty('--surface-alt', theme.surfaceAlt);
      style.setProperty('--text', theme.text);
      style.setProperty('--muted', theme.muted);
      style.setProperty('--border', theme.border);
      style.setProperty('--tint', theme.tint);
      style.setProperty('--danger', theme.danger);
      chips.forEach((other) => other.classList.toggle('active', other === chip));

      const next = strings[name];
      if (!next) return;
      swapShot(next);
      if (caption) caption.innerHTML = next.caption;
    }),
  );
}
