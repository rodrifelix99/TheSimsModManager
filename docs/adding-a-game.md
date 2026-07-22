# Adding support for a new game

The app was designed so a new game (or an entire series — SimCity is the
obvious candidate) can be added **without touching the UI or core**.

## 1. Write the adapter

Create `lib/src/games/<series>/` and subclass
[`FolderBasedGameAdapter`](../lib/src/core/game_adapter.dart) if the game's
mods are plain files in a folder (this covers most games):

```dart
class MyGameAdapter extends FolderBasedGameAdapter {
  @override
  Game get game => const Game(
        id: 'my_game',          // opaque, stable — used for settings keys
        name: 'My Game',
        series: 'My Series',
        year: 2003,
      );

  @override
  List<String> get modFileExtensions => const ['.package'];

  @override
  String get setupHelp => 'Explain here where the game keeps its mods '
      'and anything the user must enable in-game.';

  @override
  String? defaultModsPath() { /* best-effort guess, null if not found */ }
}
```

Optional overrides:

- `findModsDirectoryCandidates()` — return *every* plausible location when
  the game can be installed in several places or uses localized folder
  names. The UI shows them as one-click choices.
- `scaffoldModsDirectory(dir)` — write framework files the game needs when
  the app creates the mods folder (see the Sims 3 `Resource.cfg` for an
  example).

If the game needs a fundamentally different install/disable mechanism
(archives, load-order files, a database…), implement `GameAdapter` directly
instead.

## 2. Register it

Add the adapter to the registry list in [main.dart](../lib/main.dart).
That's the only existing file that must change.

## 3. Optional polish

- Add a palette for the game id in
  [lib/src/ui/game_theme.dart](../lib/src/ui/game_theme.dart) — without one
  the game gets a neutral theme, which is fine.
- Icons/logos under `assets/games/` (mind copyright!).

## 4. Test it

Follow the existing adapter tests: create a real temp directory
(`Directory.systemTemp`), lay out fake game folders, and assert on
detection, listing, install, enable/disable behavior. See
[test/folder_based_game_adapter_test.dart](../test/folder_based_game_adapter_test.dart).

Rules of the road:

- Nothing outside `lib/src/games/` may reference your concrete game.
- `resolveModsDirectory` may return `null` — never invent a path that
  doesn't exist.
- Detection is best-effort; the user can always override the folder in
  Settings, and your adapter must respect that.
