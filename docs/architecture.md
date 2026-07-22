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
| `GameAdapter` | The extension point: mod file extensions, `setupHelp` text, folder resolution (`resolveModsDirectory`, `defaultModsPath`, `findModsDirectoryCandidates`), `createModsDirectory` (with game-specific scaffolding), categorization, list/install/remove/enable/disable. |
| `FolderBasedGameAdapter` | Shared base for games whose mods are plain files in a folder (all Sims games). Disable = rename with a `.disabled` suffix; the game's loader then skips the file. |
| `conflicts.dart` | `findConflicts`: duplicate-file-name heuristic over enabled mods. |
| `package_insight.dart` | `scanPackage`: best-effort DBPF (`.package`) parser for embedded artwork, resource counts, and a content-type breakdown; zlib + RefPack decompression. Exposed as `GameAdapter.inspectMods`, a bulk scan across worker isolates. |
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
- `sfx.dart`: `UiSound` semantic events (click, toggleOn/Off, install…)
  mapped onto the Sims 1 UI sound bank, played fire-and-forget.

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
