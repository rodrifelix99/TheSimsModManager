# Release process (maintainer)

Releases are fully automated from a git tag.

```sh
dart tool/release.dart patch          # or: minor | major | 1.2.3
dart tool/release.dart patch --dry-run
```

The script bumps `version:` in `pubspec.yaml`, commits, tags `vX.Y.Z`, and
pushes. The tag triggers
[.github/workflows/release.yml](../.github/workflows/release.yml), which
builds on GitHub runners:

| Platform | Artifact |
| --- | --- |
| Windows | portable zip + Inno Setup installer ([installer/windows/setup.iss](../installer/windows/setup.iss)) |
| macOS | `.app` zip |
| Linux | tar.gz |

…and publishes them to a GitHub Release with generated notes.

Notes:

- **Local machines never cross-compile** — CI is the only path that produces
  all three platforms.
- **Never change the `AppId`** in `setup.iss`; it's how Windows matches
  upgrades.
- macOS builds disable Swift Package Manager (flutter_acrylic is
  CocoaPods-only).
