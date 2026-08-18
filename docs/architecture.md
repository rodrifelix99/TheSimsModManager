# Architecture

The entire app hangs off one abstraction: **`GameAdapter`**
([lib/src/core/game_adapter.dart](../lib/src/core/game_adapter.dart)).
The golden rule: **nothing outside `lib/src/games/` may reference a concrete
game.**

```
lib/src/
├── core/       game-agnostic layer (pure Dart, no Flutter imports)
├── games/      concrete game adapters, one folder per series
├── services/   settings, disk space, sound effects
└── ui/         Flutter UI, only sees core abstractions
```

## `core/`: the game-agnostic layer

| Piece | Role |
| --- | --- |
| `Game` | Pure metadata (id, name, series, year). Never gains game-specific behavior. |
| `Mod` | Immutable snapshot of a mod file on disk (incl. `category`, `modifiedAt`). Mutations go through the adapter and return new instances. |
| `GameAdapter` | The extension point: mod file extensions, the containers unpacked on install (`containerFileExtensions`), `setupHelp` text, folder resolution (`resolveModsDirectory`, `defaultModsPath`, `findModsDirectoryCandidates`), `createModsDirectory` (with game-specific scaffolding), categorization, list/install/remove/enable/disable. |
| `FolderBasedGameAdapter` | Shared base for games whose mods are plain files in a folder (all Sims games). Disable = rename with a marker appended to the file name; the game's loader then skips the file. The marker written is `.disabled` unless Settings says otherwise, and a file wearing any known marker (`.disabled`, CC Magic's `.off`, whatever is configured) is read as disabled either way. |
| `conflicts.dart` | `findConflictPairs`: who clashes with whom and why, from lexical heuristics over enabled mods (duplicate file names, two versions of the same mod) plus the overlaps below. `conflictReasonsOf` collapses that to one reason per mod. `findResourceOverlaps`: the real signal, packages sharing DBPF resource keys. |
| `ignored_conflicts.dart` | The clashes the player has settled, because a clash can be deliberate (patch mods, overrides, a load order someone arranged). The unit is the pair, not the mod, and a record is the two paths relative to the mods folder. |
| `stock_backup.dart` | The copy an install takes of a game file before writing over it. Most mods are files the game never shipped, but a Sims 3 routing fix replaces a `.world` and a graphics fix replaces a `.sgr`, and only a reinstall would bring those back. The original is renamed beside itself (`Sunset Valley.world.smmbak`) rather than copied anywhere: free at any size, still there if the app is uninstalled, and put back when the mod is. |
| `mod_name.dart` | `humanizeModName` for display titles, `parseModName` for a best-effort version token and a version-independent identity key. Package files carry no version metadata, so the file name is the only signal. |
| `mod_archive.dart` | Installing from `.zip`/`.rar`/`.7z`. Zip is decoded in an isolate; rar/7z shell out to the system `tar` (bsdtar). Only files matching the adapter's extensions are extracted, and zip-slip paths are refused. |
| `package_insight.dart` | `scanPackage`: best-effort DBPF (`.package`) parser for embedded artwork, resource counts, a content-type breakdown, and every index entry's resource key; zlib + RefPack decompression. Exposed as `GameAdapter.inspectMods`, a bulk scan across worker isolates. |
| `GameRegistry` | The list of adapters; the UI only sees adapters through it. |

## `games/`: concrete adapters

`lib/src/games/the_sims/sims_adapters.dart` holds the five Sims adapters
(Sims 1–4 plus The Sims Medieval). `DocumentsSimsAdapter` covers Sims 2/3/4:
it scans vendor folders under Documents for localized game-folder names
("Los Sims 3", "Die Sims 2") and ranks candidates. Sims 1 and The Sims
Medieval are install-folder games instead: they scan Program Files / Steam
locations (Medieval verifies disc installs by their `Game/Bin/TSM.exe`
signature, since disc folder names are localized). Adapters are registered
in `main.dart`.

The Sims 3 also takes EA's own container, `.sims3pack`
(`the_sims/sims3pack.dart`): a length-prefixed `TS3Pack` magic, two version
bytes, an XML manifest, then every file it carries, each at an `<Offset>`
counted from the end of that manifest. The packages inside install into a
subfolder named after the pack, so they enable and remove like any other
mod and the library gets a chip for them. Worlds, lots and households ship
in the same container and belong to the game's Launcher rather than the
mods folder, so a pack carrying one is refused whole - decided per entry
on `<ContentType>`, never on the root `Type` attribute, which says
`"object"` on most of the store worlds. A set of recolours is shared as
one zip of these at least as often as a bare one, so an archive or a
dropped folder is unpacked for containers as well as mod files
(`FolderBasedGameAdapter.nestedContainerExtensions` and `unpackContainer`,
empty for every other game) and each is opened where it was found. One
that is refused costs itself rather than the download; its verdict is
only raised when nothing else in the archive survived.

Some of what people install does not belong in the mods folder at all.
The Sims 3 loads worlds from its own installation, ASI plugins from beside
the executable, and its graphics and sky settings from loose files the
game ships; The Sims 2 reads its graphics rules the same way. Those
extensions are `GameAdapter.rootFileExtensions`, deliberately kept apart
from the mod extensions, and `sims_root_folders.dart` finds the folders
through the same registry keys the pack manager reads (Windows only, and
for Sims 2 only the collection - and only the pack its load order ends on,
since every pack ships a `Graphics Rules.sgr` of its own and the game
reads exactly one of them).

Where such a file goes is answered by what it replaces: a routing fix
carries the world's own name because that is the only way the game loads
it instead, so the folder already holding that name is the folder it
belongs in. Failing a match, plugins and loaders go beside the executable
and a world nobody else is called goes to the base game; an `.ini` that
matches nothing the game ships is a mod's own config file and is left out
of the install, the way a readme is. Nothing is ever written over without
being parked first; uninstalling puts the original back, and switching a
mod off swaps the two rather than renaming one away, since a disabled
routing fix that left the game with no world at all would stop its town
loading. Because those folders hold the game's own content they are never
swept into the library - only what the app put there is listed
(`placed_mods.dart`).
Unlike The Sims 1, none of this asks the user anything: a `.package` has
one home and always did, so `sortsModsAcrossFolders` keeps the
destination dialog to the one game that really sorts a download.

Mods-folder resolution is a best-effort guess and returns `null` when the
game isn't found; the UI handles `null` with a setup screen (manual folder
pick, found candidates, one-click "create the default folder"). Never assume
the resolved path is the default one; the user can override it per game in
Settings.

## `services/`

- `SettingsStore` (shared_preferences): per-game mods-folder overrides + app
  prefs. Keyed by opaque game id only.
- `disk_space.dart`: best-effort free/total bytes of the volume holding the
  mods folder; returns null on failure and the UI omits the numbers.
- `sfx.dart`: `UiSound` semantic events (click, toggleOn/Off, install...)
  mapped onto the Sims 1 UI sound bank, played fire-and-forget.
- `github.dart`: update check against the releases API and the URL builders
  that prefill the issue forms. Best-effort; failures come back as null.
- `analytics.dart`: PostHog over the plain HTTP API in pure Dart (the
  official SDK has no Windows/Linux support). Anonymous id, counts and game
  ids only, never mod names or paths, and all of it gated on a Settings
  toggle. Also carries the feature flags and error reporting.

## `ui/`

- `app_controller.dart`: single `ChangeNotifier` holding all UI state and
  actions (folder override wins over auto-detection here).
- `game_theme.dart`: per-game-id color palettes; unknown ids get a neutral
  fallback, so new games need no UI work.
- `shell.dart` (title bar + sidebar), `library_view.dart`, `detail_view.dart`,
  `settings_view.dart`, `widgets.dart`.
- Artwork/metadata: `AppController.refresh` bulk-runs `inspectMods` under the
  loading screen and caches results keyed by path + size + mtime, so cards
  render synchronously and scrolling does no IO.

## Testing conventions

- Adapter tests run against **real temp directories**
  (`Directory.systemTemp`), not mocked filesystems; follow that pattern.
- In widget tests, keep file IO synchronous outside `tester.runAsync`
  (real async IO awaited in the fake-async zone deadlocks), and stub
  `inspectMods` in fake adapters, since real isolates can't finish inside
  the fake-async zone.
