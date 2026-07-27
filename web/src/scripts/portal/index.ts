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
  doc,
  getDoc,
  getDocs,
  orderBy,
  query,
  serverTimestamp,
  setDoc,
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
import { fmtSize, loadStrings, s } from '../strings';
import { gameNames } from '../../data/games';
import { revealOnScroll } from '../reveal';

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
  gameId: string;
  version: string;
  description: string;
  instructions?: string;
  authorUid: string;
  authorName: string;
  file: StoredFile;
  images: string[];
  published: boolean;
  createdAt: unknown;
  updatedAt: unknown;
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
  meta.textContent = [gameNames[mod.gameId] ?? mod.gameId, fmtSize(mod.file?.size ?? 0)].join(' · ');

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

  body.append(line, meta, actions);
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
  for (const file of input('f-images').files ?? []) {
    if (keptImages.length + newImages.length >= MAX_IMAGES) break;
    if (file.size > MAX_IMAGE_BYTES) {
      setError('editor-error', s('portal.editor.imageTooBig', file.name));
      continue;
    }
    newImages.push(file);
  }
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

async function openEditor(id: string | null) {
  editingId = id;
  existing = null;
  keptImages = [];
  newImages = [];
  newFile = null;
  coverUrl = null;
  setError('editor-error', '');
  ($('form-editor') as HTMLFormElement).reset();
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
      select('f-game').value = existing.gameId;
      input('f-version').value = existing.version;
      input('f-author').value = existing.authorName;
      area('f-desc').value = existing.description;
      area('f-notes').value = existing.instructions ?? '';
      input('f-published').checked = existing.published;
      showPicked(existing.file.name, existing.file.size);
      keptImages = [...(existing.images ?? [])];
    }
  }
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
      if (notes) data.instructions = notes;
      await setDoc(doc(db, 'mods', id), data);
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
