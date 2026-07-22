# Contributing to The Sims Mod Manager

Thanks for wanting to help! Bug reports, feature ideas, docs fixes, and pull
requests are all welcome.

## Before you start

By contributing you agree to the contribution terms in
[LICENSE.md](../LICENSE.md) (§3): you keep the copyright to your work and
grant the maintainer a license to use and relicense it as part of the
project. Note that the project is **source-available, not open source**:
forks are for contributing back, not for redistribution.

## Reporting bugs / requesting features

Use the [issue templates](https://github.com/rodrifelix99/TheSimsModManager/issues/new/choose).
For bugs, always include: your OS, the game affected, and what the mods
folder looks like (path + a couple of file names); folder detection issues
are impossible to debug without this.

## Development setup

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install)
(stable channel) with desktop support enabled.

```sh
flutter pub get
flutter run -d windows      # or -d macos / -d linux
flutter analyze             # must be clean
flutter test                # must pass
```

## Architecture in one paragraph

The whole app hangs off one abstraction: `GameAdapter`
([lib/src/core/game_adapter.dart](../lib/src/core/game_adapter.dart)).
`lib/src/core/` is pure Dart and game-agnostic; concrete games live in
`lib/src/games/<series>/`; the UI in `lib/src/ui/` only ever sees adapters
through `GameRegistry`. **Nothing outside `lib/src/games/` may reference a
concrete game.** Read [docs/architecture.md](../docs/architecture.md) before
making non-trivial changes, and
[docs/adding-a-game.md](../docs/adding-a-game.md) if you're adding game
support.

## Pull request guidelines

- Keep PRs focused: one fix/feature per PR.
- `flutter analyze` clean and `flutter test` green.
- Add tests for adapter/core behavior. Follow the existing pattern: adapter
  tests run against real temp directories (`Directory.systemTemp`), not
  mocked filesystems.
- In widget tests, keep file IO synchronous outside `tester.runAsync`;
  real async IO awaited in the fake-async zone deadlocks.
- Match the surrounding code style; don't reformat unrelated code.
- Don't bump the version or touch `installer/windows/setup.iss`'s `AppId`;
  releases are handled by the maintainer.

## What makes a great contribution

- Folder-detection fixes for localized / non-standard installs (with the
  real-world path in the PR description).
- New `GameAdapter`s (SimCity!); see the guide.
- DBPF parsing improvements (`lib/src/core/package_insight.dart`).
- UI polish that respects the per-game theming system.
