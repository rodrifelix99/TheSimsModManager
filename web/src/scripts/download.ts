// Fills the download cards from the latest GitHub release: real file names,
// real sizes, and the visitor's own platform pushed to the front. If the API is
// unavailable the buttons keep linking to the releases page.
import { releasesApi } from '../data/links';

const SUFFIXES: Record<string, (name: string) => boolean> = {
  'windows-setup': (n) => n.endsWith('-windows-setup.exe'),
  'windows-portable': (n) => n.endsWith('-windows-portable.zip'),
  macos: (n) => n.endsWith('-macos.zip'),
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

  const platform = detectPlatform();
  const hero = document.getElementById('hero-download');
  const label = document.getElementById('hero-download-label');
  if (!(hero instanceof HTMLAnchorElement) || !label) return;
  if (platform && links[platform]) {
    hero.href = links[platform].browser_download_url;
    label.textContent = osLabels[platform] || strings.download;
    document.querySelector(`.dl-card[data-platform="${platform}"]`)?.classList.add('recommended');
  } else {
    label.textContent = strings.download;
  }
}
