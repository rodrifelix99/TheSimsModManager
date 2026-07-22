# Sims Mod Manager

A cross-platform desktop mod manager (Windows, macOS, Linux) built with Flutter.

Currently targets the mainline **The Sims** games (1–4): browse installed mods,
install, remove, and enable/disable them. The core is built around a
game-agnostic adapter layer, so support for the **SimCity** series — and any
other moddable game — can be wired in without touching the rest of the app.

## Features

- **Per-game themed UI** — the whole app re-tints as you switch between
  The Sims 1, 2, 3 and 4.
- **Library** with search, category filters (Package/Script/Object/…),
  grid and list layouts, and live Total/Enabled/Disabled/Conflicts stats.
- **One-click enable/disable** — disabling renames the file with a
  `.disabled` suffix so the game's loader skips it; nothing is deleted.
- **Conflict warnings** — enabled mods sharing a file name are badged
  (duplicate installs are the most common real-world conflict).
- **Robust folder detection** — finds localized user folders ("Los Sims 3",
  "Die Sims 2", the Ultimate Collection), lists every install when a game
  exists more than once, and lets you point at any folder manually
  (Settings → Mods folder → Change…).
- **Mods-folder scaffolding** — if a game has no mods folder yet, the app
  creates it *with the files the game needs*: the Sims 3 `Resource.cfg`
  framework, the standard Sims 4 `Resource.cfg`, etc.
- **Install** — pick mod files (filtered to the game's real extensions)
  and they're copied into the right place.

## Getting started

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install) with
desktop support enabled.

```sh
flutter pub get
flutter run -d windows   # or: -d macos / -d linux
```

If the platform runner directories (`windows/`, `macos/`, `linux/`) are ever
missing, regenerate them with:

```sh
flutter create --platforms=windows,macos,linux --project-name sims_mod_manager .
```

## Where each game keeps its mods

| Game | Default location | Notes |
| --- | --- | --- |
| The Sims | `<install>\The Sims\Downloads` | Lives in the install folder, not Documents |
| The Sims 2 | `Documents\EA Games\The Sims 2\Downloads` | Ultimate Collection uses its own folder name |
| The Sims 3 | `Documents\Electronic Arts\The Sims 3\Mods\Packages` | Needs the `Resource.cfg` framework — the app can create it |
| The Sims 4 | `Documents\Electronic Arts\The Sims 4\Mods` | Created by the game on first launch; enable CC/script mods in game options |

All of these are best-effort defaults — every game's folder can be overridden
in Settings, which covers custom drives, localized folder names,
OneDrive-relocated Documents, and Wine/CrossOver prefixes on macOS/Linux.

## Status

Working: everything above. Planned: drag-and-drop install, `.zip` extraction,
deep (resource-level) conflict detection, SimCity support.
