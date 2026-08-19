# Adding support for a new game

The app was designed so a new game (or an entire series) can be added
**without touching the UI or core**. The SimCity franchise was added
that way and is the worked example: `lib/src/games/simcity/`, four
adapters, one line each in `main.dart`, and no UI branch on a game id
anywhere. The sidebar groups it by `Game.series` on its own.

## 1. Write the adapter

Create `lib/src/games/<series>/` and subclass
[`FolderBasedGameAdapter`](../lib/src/core/game_adapter.dart) if the game's
mods are plain files in a folder (this covers most games):

```dart
class MyGameAdapter extends FolderBasedGameAdapter {
  @override
  Game get game => const Game(
        id: 'my_game',          // opaque, stable, used for settings keys
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

- `companionFileExtensions`: files that ride along with a mod of the
  same base name rather than being mods themselves (a SimCity 4 DLL
  plugin's `.ini`). They install, disable and uninstall with it and are
  never listed on their own.
- `extraModsDirectories(modsDir)`: other folders this game reads that
  hold nothing but the player's own files (SimCity 4's second Plugins
  root).
- `findModsDirectoryCandidates()`: return *every* plausible location when
  the game can be installed in several places or uses localized folder
  names. The UI shows them as one-click choices.
- `scaffoldModsDirectory(dir)`: write framework files the game needs when
  the app creates the mods folder (see the Sims 3 `Resource.cfg` for an
  example).

If the game needs a fundamentally different install/disable mechanism
(archives, load-order files, a database...), implement `GameAdapter` directly
instead.

## 2. Register it

Add the adapter to the registry list in [main.dart](../lib/main.dart).
That's the only existing file that must change.

## 3. Optional polish

- Add a palette for the game id in
  [lib/src/ui/game_theme.dart](../lib/src/ui/game_theme.dart). Without one
  the game gets a neutral theme, which is fine.
- Icons/logos under `assets/games/` (mind copyright!). Without one the
  brand mark draws a neutral letter badge - never another franchise's
  emblem.
- `setupHelp<Game>` in all eleven ARB files is **not** optional:
  `localization_test.dart` fails without it.

## 4. Test it

Follow the existing adapter tests: create a real temp directory
(`Directory.systemTemp`), lay out fake game folders, and assert on
detection, listing, install, enable/disable behavior. See
[test/folder_based_game_adapter_test.dart](../test/folder_based_game_adapter_test.dart).

Rules of the road:

- Nothing outside `lib/src/games/` may reference your concrete game.
- `resolveModsDirectory` may return `null`; never invent a path that
  doesn't exist.
- Detection is best-effort; the user can always override the folder in
  Settings, and your adapter must respect that.
