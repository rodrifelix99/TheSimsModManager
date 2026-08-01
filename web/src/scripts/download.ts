// Fills the download cards from the latest GitHub release: real file names,
// real sizes, and the visitor's own platform pushed to the front. If the API is
// unavailable the buttons keep linking to the releases page.
import { releasesApi } from '../data/links';

const SUFFIXES: Record<string, (name: string) => boolean> = {
  'windows-setup': (n) => n.endsWith('-windows-setup.exe'),
  'windows-portable': (n) => n.endsWith('-windows-portable.zip'),
  // macOS ships a disk image now. The site deploys on every push and the
  // release it reads is whatever is out, so the zip older releases carry has
  // to keep resolving until one with a .dmg is published.
  macos: (n) => n.endsWith('-macos.dmg') || n.endsWith('-macos.zip'),
  linux: (n) => n.endsWith('-linux-x64.tar.gz'),
};

const fmtMB = (bytes: number) => (bytes / 1048576).toFixed(0) + ' MB';

function detectPlatform(): string | null {
  const ua = navigator.userAgent;
  if (/Windows/i.test(ua)) return 'windows-setup';
  if (/Macintosh|Mac OS X/i.test(ua)) return 'macos';
  if (/Linux/i.test(ua) && !/Android/i.test(ua)) return 'linux';
  return null;
}

interface Asset {
  name: string;
  size: number;
  browser_download_url: string;
}

// The Windows installer is unsigned, so SmartScreen hides Run anyway behind
// More info and a fair few people stop right there. Whatever starts that
// download opens the screenshot of it; the anchor keeps doing its own job.
function armSmartScreenNote(triggers: Element[]) {
  const note = document.getElementById('smartscreen-note');
  if (!(note instanceof HTMLDialogElement) || !note.showModal) return;
  for (const trigger of triggers) {
    trigger.addEventListener('click', () => note.showModal());
  }
  // A click on the backdrop is reported against the dialog itself.
  note.addEventListener('click', (event) => {
    if (event.target === note) note.close();
  });
}

export async function fillDownloads() {
  const block = document.getElementById('page-strings');
  if (!block?.textContent) return;
  const strings: Record<string, string> = JSON.parse(block.textContent);
  const osLabels: Record<string, string> = {
    'windows-setup': strings.osWindows,
    macos: strings.osMacos,
    linux: strings.osLinux,
  };

  let release: { tag_name?: string; assets?: Asset[] };
  try {
    const response = await fetch(releasesApi);
    if (!response.ok) return;
    release = await response.json();
  } catch {
    return;
  }

  const version = release.tag_name || '';
  const pill = document.getElementById('version-pill');
  if (version && pill) pill.textContent = strings.latest + version;

  const links: Record<string, Asset> = {};
  for (const asset of release.assets ?? []) {
    for (const [key, matches] of Object.entries(SUFFIXES)) {
      if (matches(asset.name)) links[key] = asset;
    }
  }

  document.querySelectorAll<HTMLElement>('.dl-card').forEach((card) => {
    const asset = links[card.dataset.platform ?? ''];
    const link = card.querySelector<HTMLAnchorElement>('a.get');
    if (!asset || !link) return;
    link.href = asset.browser_download_url;
    link.textContent += '  ·  ' + fmtMB(asset.size);
  });

  // The version sits under the button rather than on it, so the call to action
  // stays the shortest thing on the page.
  const badge = document.getElementById('hero-version');
  if (version && badge) badge.textContent = ' · ' + version;

  // Only what really points at the installer earns the note: with the API
  // unreachable the buttons still lead to the releases page, where nothing has
  // been downloaded yet.
  const installer = links['windows-setup']
    ? [...document.querySelectorAll('.dl-card[data-platform="windows-setup"] a.get')]
    : [];

  const platform = detectPlatform();
  const hero = document.getElementById('hero-download');
  const label = document.getElementById('hero-download-label');
  if (hero instanceof HTMLAnchorElement && label) {
    if (platform && links[platform]) {
      hero.href = links[platform].browser_download_url;
      label.textContent = osLabels[platform] || strings.download;
      document.querySelector(`.dl-card[data-platform="${platform}"]`)?.classList.add('recommended');
      if (platform === 'windows-setup') installer.push(hero);
    } else {
      label.textContent = strings.download;
    }
  }

  armSmartScreenNote(installer);
}
