// The creator portal, all three views of it.
//
// The document a listing writes here is a contract: lib/src/services/mod_shop.dart
// reads it back over plain REST and firestore.rules refuses anything shaped
// differently, so the keys below are not free to drift.
import {
  createUserWithEmailAndPassword,
  GoogleAuthProvider,
  onAuthStateChanged,
  sendPasswordResetEmail,
  signInWithEmailAndPassword,
  signInWithPopup,
  signOut,
} from 'firebase/auth';
import {
  collection,
  deleteDoc,
  deleteField,
  doc,
  getDoc,
  getDocs,
  orderBy,
  query,
  serverTimestamp,
  setDoc,
  updateDoc,
  where,
} from 'firebase/firestore';
import {
  deleteObject,
  getDownloadURL,
  listAll,
  ref,
  uploadBytesResumable,
} from 'firebase/storage';
import { auth, db, storage } from './firebase';
import { closeFormatPreviews, wireFormatting } from './format';
import { fmtSize, loadStrings, s } from '../strings';
import { gameNames } from '../../data/games';
import { normalizePackCodes, packCatalog } from '../../data/packs';
import { revealOnScroll } from '../reveal';

// Also written into firestore.rules, which is what actually refuses the
// eleventh; this copy is what the editor counts on to say so out loud.
// test/site_test.dart holds the two to each other.
const MAX_IMAGES = 10;
const MAX_IMAGE_BYTES = 10 * 1024 * 1024;
const MAX_FILE_BYTES = 500 * 1024 * 1024;

interface StoredFile {
  path: string;
  name: string;
  size: number;
}

interface Listing {
  name: string;
  /// The set this listing is one variation of, if the creator named one. The
  /// app draws every listing sharing it as a single card with a picker; each
  /// one keeps its own page, link and download count, which is what lets a
  /// creator publish colours one at a time and gather them afterwards.
  group?: string;
  gameId: string;
  version: string;
  description: string;
  instructions?: string;
  /// The packs this mod does nothing without, as the games' own codes. The
  /// app answers them against what the player actually has installed and
  /// warns; it never refuses an install over one, so this is a courtesy to
  /// whoever downloads rather than a lock.
  requiresPacks?: string[];
  authorUid: string;
  authorName: string;
  file: StoredFile;
  images: string[];
  published: boolean;
  createdAt: unknown;
  updatedAt: unknown;
  /// How many people have taken this mod. Counted by the recordDownload
  /// function and read-only here - firestore.rules refuses a save that moves
  /// it, which is why an edit below saves with update() rather than set().
  /// Absent on listings published before any of this existed.
  downloads?: number;
}

const $ = (id: string) => document.getElementById(id)!;
const input = (id: string) => $(id) as HTMLInputElement;
const area = (id: string) => $(id) as HTMLTextAreaElement;
const select = (id: string) => $(id) as HTMLSelectElement;

const reason = (error: unknown) =>
  error instanceof Error ? error.message : String(error);

/// The extension badge the cards and the preview wear, `.package` and friends.
const extensionOf = (name: string) => {
  const dot = name.lastIndexOf('.');
  return dot > 0 ? name.slice(dot).toLowerCase() : '';
};

function show(view: string) {
  for (const other of ['view-auth', 'view-mods', 'view-editor']) {
    $(other).classList.toggle('hidden', other !== view);
  }
  window.scrollTo(0, 0);
}

function setError(id: string, message: string) {
  const box = $(id);
  box.textContent = message;
  box.classList.toggle('show', !!message);
}

// ---------- auth ----------
let signupMode = false;

const authWords = (error: unknown) => {
  const code = (error as { code?: string }).code ?? '';
  const known: Record<string, string> = {
    'auth/invalid-credential': s('portal.auth.err.invalidCredential'),
    'auth/user-not-found': s('portal.auth.err.userNotFound'),
    'auth/wrong-password': s('portal.auth.err.wrongPassword'),
    'auth/email-already-in-use': s('portal.auth.err.emailInUse'),
    'auth/weak-password': s('portal.auth.err.weakPassword'),
    'auth/invalid-email': s('portal.auth.err.invalidEmail'),
    'auth/popup-closed-by-user': '',
  };
  return known[code] ?? s('portal.auth.err.generic', reason(error));
};

function wireAuth() {
  $('btn-auth-mode').addEventListener('click', () => {
    signupMode = !signupMode;
    $('auth-title').textContent = s(signupMode ? 'portal.auth.signUp' : 'portal.auth.signIn');
    $('auth-sub').textContent = s(signupMode ? 'portal.auth.signUpSub' : 'portal.auth.signInSub');
    $('btn-auth-label').textContent = s(
      signupMode ? 'portal.auth.createButton' : 'portal.auth.signIn',
    );
    $('auth-switch-prompt').textContent = s(
      signupMode ? 'portal.auth.haveAccount' : 'portal.auth.newHere',
    );
    $('btn-auth-mode').textContent = s(
      signupMode ? 'portal.auth.signIn' : 'portal.auth.signUp',
    );
    input('auth-pass').autocomplete = signupMode ? 'new-password' : 'current-password';
    setError('auth-error', '');
  });

  $('btn-google').addEventListener('click', async () => {
    try {
      await signInWithPopup(auth, new GoogleAuthProvider());
    } catch (error) {
      setError('auth-error', authWords(error));
    }
  });

  $('form-auth').addEventListener('submit', async (event) => {
    event.preventDefault();
    setError('auth-error', '');
    const email = input('auth-email').value.trim();
    const password = input('auth-pass').value;
    try {
      if (signupMode) await createUserWithEmailAndPassword(auth, email, password);
      else await signInWithEmailAndPassword(auth, email, password);
    } catch (error) {
      setError('auth-error', authWords(error));
    }
  });

  $('btn-reset').addEventListener('click', async () => {
    const email = input('auth-email').value.trim();
    if (!email) {
      setError('auth-error', s('portal.auth.resetNeedsEmail'));
      return;
    }
    try {
      await sendPasswordResetEmail(auth, email);
      setError('auth-error', s('portal.auth.resetSent'));
    } catch (error) {
      setError('auth-error', authWords(error));
    }
  });

  $('btn-signout').addEventListener('click', () => signOut(auth));

  onAuthStateChanged(auth, (user) => {
    $('btn-signout').classList.toggle('hidden', !user);
    const who = $('who-name');
    const name = user ? (user.displayName ?? user.email ?? '') : '';
    who.textContent = name;
    who.dataset.initial = (name[0] ?? '?').toUpperCase();
    who.classList.toggle('hidden', !name);
    if (user) loadMods();
    else show('view-auth');
  });
}

// ---------- mod list ----------
type Filter = 'all' | 'live' | 'draft';
let filter: Filter = 'all';

/// The screenshot a card leads with, once Storage hands over its address.
function fillCover(cover: HTMLElement, path: string) {
  getDownloadURL(ref(storage, path))
    .then((url) => {
      const image = new Image();
      image.src = url;
      image.alt = '';
      cover.prepend(image);
    })
    .catch(() => {
      /* the placeholder stripes stay */
    });
}

/// The address a listing has out in the world. Always the English root: it is
/// one link for a whole audience, and the page offers whoever opens it their
/// own language anyway.
const shareLink = (id: string) => `${window.location.origin}/m/${id}`;

/// Copy that link. The button says so itself for a moment afterwards, which is
/// the only confirmation this needs.
function shareButton(id: string): HTMLButtonElement {
  const button = document.createElement('button');
  button.className = 'btn share';
  button.type = 'button';
  button.textContent = s('portal.mods.copyLink');
  button.addEventListener('click', async () => {
    try {
      await navigator.clipboard.writeText(shareLink(id));
      button.textContent = s('portal.mods.copied');
    } catch {
      // No clipboard permission, or an insecure origin. Showing the link beats
      // a button that silently does nothing.
      window.prompt(s('portal.mods.copyLink'), shareLink(id));
      return;
    }
    window.setTimeout(() => {
      button.textContent = s('portal.mods.copyLink');
    }, 1800);
  });
  return button;
}

/// How many people have taken this mod, on the card and again in the tally.
/// Real downloads only: the app pings once an install finishes and the mod
/// page when its download button is used, both through recordDownload, which
/// counts one machine once a day. Nothing seeds it and nothing estimates it,
/// so a new listing honestly reads 0.
function downloadStat(count: number): HTMLElement {
  const stat = document.createElement('span');
  stat.className = 'dlstat';
  const number = document.createElement('b');
  number.textContent = count.toLocaleString(document.documentElement.lang);
  stat.append(number, ' ' + s('portal.mods.downloads'));
  return stat;
}

function modCard(id: string, mod: Listing): HTMLElement {
  const card = document.createElement('article');
  card.className = 'modcard' + (mod.published ? '' : ' draft');
  card.dataset.state = mod.published ? 'live' : 'draft';

  const cover = document.createElement('div');
  cover.className = 'cover';
  const state = document.createElement('span');
  state.className = 'state';
  state.textContent = s(mod.published ? 'portal.mods.live' : 'portal.mods.draft');
  cover.append(state);
  const extension = extensionOf(mod.file?.name ?? '');
  if (extension) {
    const badge = document.createElement('span');
    badge.className = 'ext';
    badge.textContent = extension;
    cover.append(badge);
  }
  if (mod.images?.length) fillCover(cover, mod.images[0]);

  const body = document.createElement('div');
  body.className = 'body';
  const line = document.createElement('div');
  line.className = 'line';
  const title = document.createElement('h3');
  title.textContent = mod.name;
  const version = document.createElement('span');
  version.className = 'ver';
  version.textContent = 'v' + mod.version;
  line.append(title, version);

  const meta = document.createElement('p');
  meta.className = 'meta';
  meta.textContent = [
    gameNames[mod.gameId] ?? mod.gameId,
    fmtSize(mod.file?.size ?? 0),
    ...(mod.group ? [s('portal.mods.inSet', mod.group)] : []),
  ].join(' · ');

  const edit = document.createElement('button');
  edit.className = 'btn';
  edit.type = 'button';
  edit.textContent = s(mod.published ? 'portal.mods.edit' : 'portal.mods.finish');
  edit.addEventListener('click', () => openEditor(id));

  const actions = document.createElement('div');
  actions.className = 'actions';
  actions.append(edit);
  // A draft has no page to point at yet; only a published listing does.
  if (mod.published) actions.append(shareButton(id));

  body.append(line, meta);
  // Nobody can have taken a draft, so the number would only ever read 0 and
  // say nothing. It appears when the mod goes on the shelves.
  if (mod.published) body.append(downloadStat(mod.downloads ?? 0));
  body.append(actions);
  card.append(cover, body);
  return card;
}

function applyFilter() {
  for (const card of document.querySelectorAll<HTMLElement>('#mod-list .modcard')) {
    card.classList.toggle('hidden', filter !== 'all' && card.dataset.state !== filter);
  }
  for (const button of document.querySelectorAll<HTMLElement>('#mod-filters button')) {
    button.classList.toggle('on', button.dataset.filter === filter);
  }
}

function wireFilters() {
  for (const button of document.querySelectorAll<HTMLElement>('#mod-filters button')) {
    button.addEventListener('click', () => {
      filter = (button.dataset.filter as Filter) ?? 'all';
      applyFilter();
    });
  }
}

/// The set names already in use, offered as suggestions under the field. A
/// second colour has to land on the same spelling as the first or it stands
/// alone, and picking beats remembering.
function fillGroupNames(names: (string | undefined)[]) {
  const seen = new Map<string, string>();
  for (const name of names) {
    const trimmed = name?.trim();
    if (trimmed) seen.set(trimmed.toLowerCase(), trimmed);
  }
  const list = $('group-names');
  list.textContent = '';
  for (const name of [...seen.values()].sort((a, b) => a.localeCompare(b))) {
    const option = document.createElement('option');
    option.value = name;
    list.append(option);
  }
}

async function loadMods() {
  show('view-mods');
  const user = auth.currentUser;
  if (!user) return;
  const list = $('mod-list');
  list.textContent = '';
  setError('mods-error', '');

  let docs;
  try {
    const snap = await getDocs(
      query(
        collection(db, 'mods'),
        where('authorUid', '==', user.uid),
        orderBy('updatedAt', 'desc'),
      ),
    );
    docs = snap.docs;
  } catch (error) {
    setError('mods-error', s('portal.mods.loadFailed', reason(error)));
    $('mod-filters').classList.add('hidden');
    return;
  }

  const listings = docs.map((entry) => [entry.id, entry.data() as Listing] as const);
  fillGroupNames(listings.map(([, mod]) => mod.group));
  $('mods-empty').classList.toggle('hidden', listings.length > 0);
  $('mod-filters').classList.toggle('hidden', listings.length === 0);

  const live = listings.filter(([, mod]) => mod.published).length;
  const counts: Record<Filter, number> = {
    all: listings.length,
    live,
    draft: listings.length - live,
  };
  const labels: Record<Filter, string> = {
    all: s('portal.mods.all'),
    live: s('portal.mods.live'),
    draft: s('portal.mods.draft'),
  };
  for (const button of document.querySelectorAll<HTMLElement>('#mod-filters button')) {
    const key = (button.dataset.filter as Filter) ?? 'all';
    button.textContent = `${labels[key]} ${counts[key]}`;
  }
  const tally = $('mod-tally');
  tally.textContent = '';
  const total = document.createElement('b');
  total.textContent = String(listings.length);
  tally.append(total, ' ' + s('portal.mods.listings'));
  // The number worth leading with, once there is one. Drafts contribute
  // nothing by definition, so this is the sum over what is on the shelves.
  const downloads = listings.reduce((sum, [, mod]) => sum + (mod.downloads ?? 0), 0);
  if (downloads > 0) tally.append(' · ', downloadStat(downloads));

  for (const [id, mod] of listings) list.append(modCard(id, mod));
  applyFilter();
  revealOnScroll();
}

// ---------- editor ----------
let editingId: string | null = null;
let existing: Listing | null = null;
let keptImages: string[] = []; // storage paths kept from the existing doc
let newImages: File[] = []; // files to upload
let newFile: File | null = null; // replaces the download, or null to keep

/// The card on the right, kept in step with the form as it is filled in. It is
/// the same shape the shop draws in the app, so what you type is what they see.
function renderPreview() {
  $('pv-name').textContent =
    input('f-name').value.trim() || s('portal.editor.namePlaceholder');
  $('pv-version').textContent = 'v' + (input('f-version').value.trim() || '1.0');
  const author = input('f-author').value.trim();
  const game = select('f-game').selectedOptions[0]?.textContent ?? '';
  $('pv-by').textContent = author ? `${s('portal.editor.by', author)} · ${game}` : game;

  const name = newFile?.name ?? existing?.file?.name ?? '';
  const extension = extensionOf(name);
  $('pv-ext').textContent = extension;
  $('pv-ext').classList.toggle('hidden', !extension);

  const image = $('pv-image') as HTMLImageElement;
  image.classList.toggle('hidden', !coverUrl);
  if (coverUrl && image.src !== coverUrl) image.src = coverUrl;
}

/// Whichever screenshot is first in the grid, which is the one players see.
let coverUrl: string | null = null;

function refreshCover() {
  const [kept] = keptImages;
  if (kept) {
    getDownloadURL(ref(storage, kept))
      .then((url) => {
        coverUrl = url;
        renderPreview();
      })
      .catch(() => {
        coverUrl = null;
        renderPreview();
      });
    return;
  }
  const [added] = newImages;
  coverUrl = added ? URL.createObjectURL(added) : null;
  renderPreview();
}

function renderImages() {
  const grid = $('images-grid');
  grid.textContent = '';
  const tile = (
    apply: (image: HTMLImageElement) => void,
    remove: () => void,
    first: boolean,
  ) => {
    const box = document.createElement('div');
    box.className = 'im';
    const image = new Image();
    image.alt = '';
    apply(image);
    const close = document.createElement('button');
    close.type = 'button';
    close.textContent = '✕';
    close.addEventListener('click', remove);
    box.append(image, close);
    if (first) {
      const tag = document.createElement('span');
      tag.className = 'cover-tag';
      tag.textContent = s('portal.editor.coverTag');
      box.append(tag);
    }
    grid.append(box);
  };

  let index = 0;
  for (const path of keptImages) {
    tile(
      (image) => {
        getDownloadURL(ref(storage, path))
          .then((url) => {
            image.src = url;
          })
          .catch(() => {});
      },
      () => {
        keptImages = keptImages.filter((kept) => kept !== path);
        renderImages();
      },
      index++ === 0,
    );
  }
  for (const file of newImages) {
    tile(
      (image) => {
        image.src = URL.createObjectURL(file);
      },
      () => {
        newImages = newImages.filter((other) => other !== file);
        renderImages();
      },
      index++ === 0,
    );
  }
  refreshCover();
}

function takeImages() {
  // Past the tenth, a picked file used to be dropped without a word, so a
  // creator who chose twelve at once had two of them simply never arrive.
  let overflow = false;
  let refused = '';
  for (const file of input('f-images').files ?? []) {
    if (keptImages.length + newImages.length >= MAX_IMAGES) {
      overflow = true;
      continue;
    }
    if (file.size > MAX_IMAGE_BYTES) {
      refused = s('portal.editor.imageTooBig', file.name);
      continue;
    }
    newImages.push(file);
  }
  // One pick can hit both, and they are different things to go and fix -
  // a file to resize, and a count to bring down - so saying only the
  // count would leave the oversized one looking like it went in.
  const full = overflow ? s('portal.editor.imagesFull', String(MAX_IMAGES)) : '';
  setError('images-error', [refused, full].filter(Boolean).join(' '));
  input('f-images').value = '';
  renderImages();
}

/// The row under the drop zone that names whichever file is going up.
function showPicked(name: string, size: number) {
  $('file-picked').classList.remove('hidden');
  $('file-name').textContent = name;
  $('file-hint').textContent = s('portal.editor.replaceHint', fmtSize(size));
}

function takeFile() {
  const file = input('f-file').files?.[0];
  if (!file) return;
  if (file.size > MAX_FILE_BYTES) {
    setError('editor-error', s('portal.editor.fileTooBig'));
    return;
  }
  newFile = file;
  showPicked(file.name, file.size);
  renderPreview();
}

function wireDropzones() {
  const zones: [string, string, () => void][] = [
    ['box-images', 'f-images', takeImages],
    ['box-file', 'f-file', takeFile],
  ];
  for (const [boxId, inputId, take] of zones) {
    const box = $(boxId);
    box.addEventListener('click', () => input(inputId).click());
    input(inputId).addEventListener('change', take);
    box.addEventListener('dragover', (event) => {
      event.preventDefault();
      box.classList.add('over');
    });
    box.addEventListener('dragleave', () => box.classList.remove('over'));
    box.addEventListener('drop', (event) => {
      event.preventDefault();
      box.classList.remove('over');
      const dropped = (event as DragEvent).dataTransfer?.files;
      if (!dropped?.length) return;
      input(inputId).files = dropped;
      take();
    });
  }
}

// ---------- the pack checklist ----------

/// Which packs the listing being edited says it needs. Held apart from the
/// form because the boxes themselves come and go: the list is rebuilt every
/// time the search narrows it, and a checkbox that is not on screen would
/// otherwise read as unticked.
let selectedPacks = new Set<string>();

/// Draws the checklist for whichever game is picked, narrowed by the search
/// box. Hidden whole for a game with no catalog - The Sims Medieval had one
/// add-on ever, and it shares the base game's patch level, so there is
/// nothing here to tick.
function renderPacks() {
  const packs = packCatalog[select('f-game').value] ?? [];
  $('packs-block').classList.toggle('hidden', packs.length === 0);
  if (packs.length === 0) return;
  const needle = input('f-packs-search').value.trim().toLowerCase();
  const list = $('pack-list');
  list.textContent = '';
  for (const pack of packs) {
    // A ticked pack stays on screen whatever the search says, so nothing
    // can be lost behind a filter somebody forgot they typed.
    const ticked = selectedPacks.has(pack.code);
    if (needle && !ticked && !pack.name.toLowerCase().includes(needle)
        && !pack.code.toLowerCase().includes(needle)) {
      continue;
    }
    const row = document.createElement('label');
    const box = document.createElement('input');
    box.type = 'checkbox';
    box.checked = ticked;
    box.addEventListener('change', () => {
      if (box.checked) selectedPacks.add(pack.code);
      else selectedPacks.delete(pack.code);
      packTally();
    });
    const name = document.createElement('span');
    name.textContent = pack.name;
    const code = document.createElement('span');
    code.className = 'code';
    code.textContent = pack.code;
    row.append(box, name, code);
    list.append(row);
  }
  packTally();
}

function packTally() {
  $('pack-tally').textContent = selectedPacks.size === 0
    ? s('portal.editor.requiresNone')
    : s('portal.editor.requiresCount', String(selectedPacks.size));
}

/// What to save, in the catalog's own order rather than the order they were
/// ticked, and never a code this game has no such pack for - the selection
/// is cleared when the game changes, and this is the second half of that.
function packsToSave(): string[] {
  const packs = packCatalog[select('f-game').value] ?? [];
  return normalizePackCodes(
    packs.filter((pack) => selectedPacks.has(pack.code)).map((pack) => pack.code),
  );
}

async function openEditor(id: string | null) {
  editingId = id;
  existing = null;
  keptImages = [];
  newImages = [];
  newFile = null;
  coverUrl = null;
  setError('editor-error', '');
  setError('images-error', '');
  ($('form-editor') as HTMLFormElement).reset();
  selectedPacks = new Set();
  $('file-picked').classList.add('hidden');
  $('editor-title').textContent = s(id ? 'portal.editor.editTitle' : 'portal.editor.newTitle');
  $('btn-save-label').textContent = s(id ? 'portal.editor.saveChanges' : 'portal.editor.save');
  $('btn-delete').classList.toggle('hidden', !id);
  input('f-author').value = auth.currentUser?.displayName ?? '';

  if (id) {
    const snap = await getDoc(doc(db, 'mods', id));
    if (snap.exists()) {
      existing = snap.data() as Listing;
      input('f-name').value = existing.name;
      input('f-group').value = existing.group ?? '';
      select('f-game').value = existing.gameId;
      input('f-version').value = existing.version;
      input('f-author').value = existing.authorName;
      area('f-desc').value = existing.description;
      area('f-notes').value = existing.instructions ?? '';
      selectedPacks = new Set(normalizePackCodes(existing.requiresPacks));
      input('f-published').checked = existing.published;
      showPicked(existing.file.name, existing.file.size);
      keptImages = [...(existing.images ?? [])];
    }
  }
  renderPacks();
  renderImages();
  renderPreview();
  show('view-editor');
}

function upload(path: string, file: File, contentType: string | null, onPct: (pct: number) => void) {
  return new Promise<string>((resolve, reject) => {
    const task = uploadBytesResumable(
      ref(storage, path),
      file,
      contentType ? { contentType } : undefined,
    );
    task.on(
      'state_changed',
      (snap) => onPct(snap.totalBytes ? snap.bytesTransferred / snap.totalBytes : 0),
      reject,
      () => resolve(path),
    );
  });
}

const cleanName = (name: string) => name.replace(/[\\/:*?"<>|]/g, '_');

function wireEditor() {
  $('btn-new').addEventListener('click', () => openEditor(null));
  $('btn-first').addEventListener('click', () => openEditor(null));
  $('btn-back').addEventListener('click', () => loadMods());
  wireDropzones();

  for (const id of ['f-name', 'f-version', 'f-author', 'f-game']) {
    $(id).addEventListener('input', renderPreview);
  }
  // A pack code means nothing outside the game that shipped it, so changing
  // the game empties the selection rather than carrying EP01 across.
  $('f-game').addEventListener('change', () => {
    selectedPacks = new Set();
    input('f-packs-search').value = '';
    renderPacks();
  });
  $('f-packs-search').addEventListener('input', renderPacks);
  wireFormatting('f-desc');
  wireFormatting('f-notes');
  // Before the click that submits, and again if anything did get as far as
  // failing validation: a required box the browser cannot focus is refused
  // with nothing on screen to explain itself.
  $('btn-save').addEventListener('mousedown', closeFormatPreviews);
  $('form-editor').addEventListener('invalid', closeFormatPreviews, true);

  $('form-editor').addEventListener('submit', async (event) => {
    event.preventDefault();
    setError('editor-error', '');
    const user = auth.currentUser;
    if (!user) return;
    if (!newFile && !existing) {
      setError('editor-error', s('portal.editor.needFile'));
      return;
    }
    const save = $('btn-save') as HTMLButtonElement;
    save.disabled = true;
    const bar = $('upload-bar');
    bar.classList.add('show');
    const pct = (value: number) => {
      (bar.firstElementChild as HTMLElement).style.width = Math.round(value * 100) + '%';
    };

    try {
      const id = editingId ?? doc(collection(db, 'mods')).id;
      const base = `mods/${user.uid}/${id}`;

      // The download itself; replacing it removes the one it replaces.
      let file = existing?.file ?? null;
      if (newFile) {
        const name = cleanName(newFile.name);
        const path = `${base}/${name}`;
        await upload(path, newFile, null, (value) => pct(value * 0.8));
        if (file && file.path !== path) {
          try {
            await deleteObject(ref(storage, file.path));
          } catch {
            /* the old object is already gone or unreachable */
          }
        }
        file = { path, name, size: newFile.size };
      }

      // Screenshots: upload the new, drop the removed.
      const images = [...keptImages];
      let done = 0;
      for (const image of newImages) {
        const path = `${base}/images/${Date.now()}-${cleanName(image.name)}`;
        await upload(path, image, image.type || 'image/png', (value) =>
          pct(0.8 + ((done + value) / Math.max(1, newImages.length)) * 0.2),
        );
        images.push(path);
        done++;
      }
      for (const gone of (existing?.images ?? []).filter((path) => !keptImages.includes(path))) {
        try {
          await deleteObject(ref(storage, gone));
        } catch {
          /* same: nothing to remove */
        }
      }

      const data: Listing = {
        name: input('f-name').value.trim(),
        gameId: select('f-game').value,
        version: input('f-version').value.trim(),
        description: area('f-desc').value.trim(),
        authorUid: user.uid,
        authorName: input('f-author').value.trim(),
        file: file!,
        images,
        published: input('f-published').checked,
        createdAt: existing?.createdAt ?? serverTimestamp(),
        updatedAt: serverTimestamp(),
      };
      const notes = area('f-notes').value.trim();
      const set = input('f-group').value.trim();
      const needs = packsToSave();
      const listing = doc(db, 'mods', id);
      if (existing) {
        // An edit saves with update(), not set(): `downloads` belongs to the
        // recordDownload function, and merging it through untouched is the
        // only way a save can be legal however long the editing took. The
        // price is that cleared instructions need saying out loud - set()
        // dropped a missing key for free.
        await updateDoc(listing, {
          ...data,
          instructions: notes || deleteField(),
          // Same as the notes: a field cleared to nothing has to be said
          // out loud, or the listing stays in a set it was taken out of.
          group: set || deleteField(),
          // And again: a requirement the creator has since unticked has to
          // be removed rather than left behind warning people about a pack
          // the mod no longer needs.
          requiresPacks: needs.length ? needs : deleteField(),
        });
      } else {
        if (notes) data.instructions = notes;
        if (set) data.group = set;
        if (needs.length) data.requiresPacks = needs;
        data.downloads = 0;
        await setDoc(listing, data);
      }
      await loadMods();
    } catch (error) {
      setError('editor-error', s('portal.editor.saveFailed', reason(error)));
    } finally {
      save.disabled = false;
      bar.classList.remove('show');
      pct(0);
    }
  });

  $('btn-delete').addEventListener('click', async () => {
    if (!editingId) return;
    if (!confirm(s('portal.editor.deleteConfirm'))) return;
    const user = auth.currentUser;
    if (!user) return;
    const button = $('btn-delete') as HTMLButtonElement;
    button.disabled = true;
    try {
      await deleteDoc(doc(db, 'mods', editingId));
      // Best-effort cleanup; an orphaned file is invisible without a listing.
      const base = `mods/${user.uid}/${editingId}`;
      for (const folder of [`${base}/images`, base]) {
        try {
          const all = await listAll(ref(storage, folder));
          for (const item of all.items) {
            try {
              await deleteObject(item);
            } catch {
              /* keep going through the rest */
            }
          }
        } catch {
          /* nothing under that prefix */
        }
      }
      await loadMods();
    } catch (error) {
      setError('editor-error', s('portal.editor.deleteFailed', reason(error)));
    } finally {
      button.disabled = false;
    }
  });
}

export function startPortal() {
  loadStrings();
  revealOnScroll();
  wireAuth();
  wireFilters();
  wireEditor();
}
