// Reading The Exchange without the Firebase SDK.
//
// The portal loads the modular SDK because it signs people in and uploads
// files. The mod page only ever reads one published document and shows its
// pictures, and firestore.rules already lets anyone do that, so it talks to the
// plain REST endpoints instead and ships no SDK at all. The app does the same
// thing in Dart, in lib/src/services/mod_shop.dart.
//
// functions/index.js keeps its own copy of these three constants: it is
// deployed as its own package and cannot import from here.

export const project = 'thesimsmodmanager';
export const bucket = 'thesimsmodmanager.firebasestorage.app';
/// Public by design: what may be read is decided by the rules, not by who
/// holds this string.
export const apiKey = 'AIzaSyDsC3_mQFDUXj6pmKMw1_xf4_XigC82smE';

/// Firestore document ids we will follow. The mod page is handed this straight
/// out of a URL a stranger wrote, and it is about to become a path.
export const listingIdPattern = /^[A-Za-z0-9_-]{1,64}$/;

export const listingUrl = (id: string) =>
  `https://firestore.googleapis.com/v1/projects/${project}/databases/(default)/documents/mods/${encodeURIComponent(id)}?key=${apiKey}`;

/// The public download for a file in the shop's bucket. The object path travels
/// as one encoded segment, slashes included.
export const fileUrl = (path: string) =>
  `https://firebasestorage.googleapis.com/v0/b/${bucket}/o/${encodeURIComponent(path)}?alt=media`;

/// One field of a Firestore REST document, as the plain value it stands for.
/// Only the shapes a listing actually uses are handled; anything else reads as
/// undefined, which every caller below already treats as "not set".
export function plainValue(field: unknown): unknown {
  if (!field || typeof field !== 'object') return undefined;
  const value = field as Record<string, unknown>;
  if ('stringValue' in value) return value.stringValue;
  if ('booleanValue' in value) return value.booleanValue;
  if ('integerValue' in value) return Number(value.integerValue);
  if ('doubleValue' in value) return value.doubleValue;
  if ('timestampValue' in value) return value.timestampValue;
  if ('nullValue' in value) return undefined;
  if ('arrayValue' in value) {
    const values = (value.arrayValue as { values?: unknown[] })?.values ?? [];
    return values.map(plainValue);
  }
  if ('mapValue' in value) {
    const fields = (value.mapValue as { fields?: Record<string, unknown> })?.fields ?? {};
    return Object.fromEntries(Object.entries(fields).map(([key, v]) => [key, plainValue(v)]));
  }
  return undefined;
}

export interface Listing {
  id: string;
  name: string;
  gameId: string;
  version: string;
  description: string;
  instructions: string;
  authorName: string;
  file: { path: string; name: string; size: number };
  images: string[];
  updatedAt: string;
  /// How many people have taken this mod, counted by the recordDownload
  /// function. Reads 0 on a listing published before there was a counter,
  /// which is the truth about what we know rather than a guess.
  downloads: number;
}

/// A Firestore REST document (`{name, fields}`) as a listing, or null when it
/// is not one. The document id comes from its own path, the way the app reads
/// it.
export function toListing(doc: unknown): Listing | null {
  if (!doc || typeof doc !== 'object') return null;
  const raw = doc as { name?: string; fields?: Record<string, unknown> };
  if (!raw.name || !raw.fields) return null;
  const field = (key: string) => plainValue(raw.fields![key]);
  const name = field('name');
  const file = (field('file') ?? {}) as Partial<Listing['file']>;
  if (typeof name !== 'string' || typeof file.path !== 'string') return null;
  return {
    id: raw.name.split('/').pop()!,
    name,
    gameId: String(field('gameId') ?? ''),
    version: String(field('version') ?? ''),
    description: String(field('description') ?? ''),
    instructions: String(field('instructions') ?? ''),
    authorName: String(field('authorName') ?? ''),
    file: {
      path: file.path,
      name: String(file.name ?? ''),
      size: Number(file.size ?? 0),
    },
    images: ((field('images') as unknown[]) ?? []).filter(
      (path): path is string => typeof path === 'string',
    ),
    updatedAt: String(field('updatedAt') ?? ''),
    downloads: Math.max(0, Math.trunc(Number(field('downloads') ?? 0)) || 0),
  };
}
