# Sims Mod Manager

A cross-platform desktop mod manager (Windows, macOS, Linux) built with Flutter.

Currently targets the mainline **The Sims** games (1–4): browse installed mods,
add, remove, and enable/disable them. The core is built around a game-agnostic
adapter layer, so support for the **SimCity** series — and any other moddable
game — can be wired in without touching the rest of the app.

## Getting started

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install) with
desktop support enabled.

```sh
# One-time: generate the native platform runners (they are not hand-written)
flutter create --platforms=windows,macos,linux --project-name sims_mod_manager .

flutter pub get
flutter run -d windows   # or: -d macos / -d linux
```

## Status

Early scaffold. Working: game detection at default install paths, mod listing,
enable/disable (rename-based), remove. Planned: custom folder overrides,
drag-and-drop install, conflict detection, SimCity support.
