// The live theme strip: clicking a game repaints the whole page in that game's
// palette and swaps the hero screenshot underneath it. The palettes mirror
// lib/src/ui/game_theme.dart, light and dark, so the page really is showing
// what the app shows; `dark` is the Sims 4 dark palette, the app's own default.
const THEMES: Record<string, Record<string, string>> = {
  sims1: { accent: '#12898A', accent2: '#E0A53A', bg: '#EEF2EC', surface: '#FFFFFF', surfaceAlt: '#F2F5EF', text: '#1E3A37', muted: '#6C827E', border: '#DBE4DE', tint: '#DCEFEE', danger: '#D6551F' },
  sims2: { accent: '#5BA12C', accent2: '#E07B2E', bg: '#F4EFE4', surface: '#FFFDF6', surfaceAlt: '#F6F1E6', text: '#31301D', muted: '#83806B', border: '#E6DDC9', tint: '#EAF3DD', danger: '#D6551F' },
  sims3: { accent: '#7CB518', accent2: '#2F7D9E', bg: '#ECEFF0', surface: '#FFFFFF', surfaceAlt: '#F1F4F5', text: '#22303A', muted: '#6C7F88', border: '#DDE4E7', tint: '#E9F2D8', danger: '#D6551F' },
  sims4: { accent: '#1FBF8F', accent2: '#12B0D6', bg: '#EAF6F2', surface: '#FFFFFF', surfaceAlt: '#F2FAF7', text: '#0F2E28', muted: '#5F827A', border: '#D9ECE5', tint: '#DCF5EC', danger: '#D6551F' },
  simsmedieval: { accent: '#9C7B1E', accent2: '#5E9732', bg: '#F1EBDC', surface: '#FFFDF4', surfaceAlt: '#F5EFDF', text: '#33290F', muted: '#857A5C', border: '#E3DAC0', tint: '#F0E7CB', danger: '#D6551F' },
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
