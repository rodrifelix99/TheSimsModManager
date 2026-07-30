# Mod advisories

`web/public/data/advisories.json` is the list of mods currently reported broken.
The app downloads it, matches it against the library on the user's own
machine, and warns in the library banner and the mod detail panel. Nothing
about anyone's library is ever uploaded - the match happens locally.

The website deploys on every push to `dev`, so **an edit is live as soon as
it is pushed**. Advisories do not wait for a release.

Apps up to v1.2.x read the same list from the retired GitHub Pages address,
which cannot redirect a JSON file. `npm run build` in `web/` copies the file
to `docs/data/advisories.json` for them; commit both, and the test below
fails if you forget.

## Format

```json
{
  "version": 1,
  "updated": "2026-07-27",
  "games": {
    "sims4": [
      {
        "id": "example-2026-07",
        "title": "Example Mod",
        "status": "broken",
        "since": "the 24 July 2026 patch",
        "note": "Crashes on load. Remove it until an update lands.",
        "url": "https://example.com/downloads",
        "identities": ["example mod.package"],
        "fingerprints": ["6a9696f4052261f7"],
        "versions": ["1.2", "1.3"]
      }
    ]
  }
}
```

| Field | Required | Meaning |
|---|---|---|
| `id` | yes | Unique within the file. Never reported to analytics |
| `title` | yes | Shown verbatim, untranslated |
| `status` | yes | `broken`, `outdated` or `caution` |
| `since` | no | Display text only; the app never detects the game version |
| `note` | no | One or two sentences, shown verbatim |
| `url` | no | Where the fix is. Must be `https://` or it is dropped |
| `identities` | one of | Match by file name (see below) |
| `fingerprints` | one of | Match by package contents (see below) |
| `versions` | no | Version tokens affected. Omit to mean every version |

Game ids are the registry's (`sims1`, `sims2`, `sims3`, `sims4`,
`simsmedieval`). An entry needs at least one of `identities` or
`fingerprints`; anything the app cannot read - an unknown `status`, a
missing `title` - is skipped, and the rest of the file still loads.

## The two match keys

**`identities`** match a mod by name. The value is the file name
lowercased, with `_`, `-`, `+` and `.` collapsed to single spaces, the
version token removed, and the extension kept:

- `MC_Command_Center.package` -> `mc command center.package`
- `UICheatsExtension_v1.36.ts4script` -> `uicheatsextension.ts4script`

This is the only key that works for script mods, which are `.ts4script`
zips with no resource keys inside - and script mods are what a game patch
usually breaks. Use it as the default.

**`fingerprints`** match a mod by what is actually inside the package, so
they survive a user renaming the file. They only exist for DBPF
`.package` files, and only when the user has "Scan inside mods" on. Get
one by running the app in debug with the mod installed, or compute it
from `fingerprintOf` in
[lib/src/core/mod_advisories.dart](../lib/src/core/mod_advisories.dart).

Give an entry both keys when you can. A mod matches if **either** key
matches.

## Wording

Same tone as the app: friendly, casual, informal address. These strings
are shown untranslated in all eleven languages, so keep them short and plain
- no idioms, no jokes that only work in English.

Only publish what you can stand behind. An advisory says a named person's
work is broken, and it reaches every user of the app within minutes.
Link the creator's own post when there is one.

## Before pushing

```bash
cd web && npm run build && cd ..
flutter test test/mod_advisories_test.dart test/site_test.dart
```

The tests parse this exact file and fail on a duplicate `id`, on anything
that does not decode, and on a stale copy in `docs/data`.
