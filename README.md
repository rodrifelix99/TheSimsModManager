<div align="center">

# The Sims Mod Manager

**A free, cross-platform desktop mod manager for The Sims 1, 2, 3 & 4, The Sims Medieval and the SimCity series.**

[![Latest release](https://img.shields.io/github/v/release/rodrifelix99/TheSimsModManager?label=download&color=2ea44f)](https://github.com/rodrifelix99/TheSimsModManager/releases/latest)
[![Build](https://github.com/rodrifelix99/TheSimsModManager/actions/workflows/release.yml/badge.svg)](https://github.com/rodrifelix99/TheSimsModManager/actions/workflows/release.yml)
[![Downloads](https://img.shields.io/github/downloads/rodrifelix99/TheSimsModManager/total)](https://github.com/rodrifelix99/TheSimsModManager/releases)
[![Platforms](https://img.shields.io/badge/platforms-Windows%20%7C%20macOS%20%7C%20Linux-blue)](#download)
[![License](https://img.shields.io/badge/license-source--available-lightgrey)](LICENSE.md)
[![Donate](https://img.shields.io/badge/donate-PayPal-00457C?logo=paypal&logoColor=white)](https://www.paypal.com/donate/?hosted_button_id=UFSLDMGKB9R6A)

**[Visit the website →](https://thesimsmodmanager.web.app/)** · **[Follow on Tumblr](https://thesimsmodmanager.tumblr.com/)**

Browse, install, enable/disable, and clean up your mods and custom content
for nine games across two franchises, in one app, wearing whichever of the
eight interfaces you picked.

<img src="web/public/images/library-grid-ts4.png" alt="Library view (The Sims 4)" width="800">

</div>

## One app, eight interfaces

Each look is drawn after a game's own interface, down to what its buttons are
made of. The Sims 1's chiselled blue plates, the Sims 2's periwinkle lozenges
lit in plumbob green, the Sims 3's blue glass, the Medieval's parchment and
brass by day and carved wood after dark, the Sims 4's flat mint, SimCity
3000's milled steel console, that same console cast in SimCity 4's teal and
rounded off, and SimCity (2013)'s pale white-and-silver panels. Every one of
them comes in light and dark, following your system or your own pick.

The look is yours to choose and it stays put: pick one in Settings and it
holds whichever game you're managing.

| Light | Dark |
| --- | --- |
| <img src="web/public/images/library-grid-ts1.png" alt="Library view in The Sims 1's deep blues with chiselled buttons" width="420"> | <img src="web/public/images/library-grid-ts1-dark-mode.png" alt="The same Sims 1 look in dark mode" width="420"> |
| <img src="web/public/images/library-grid-ts2.png" alt="Library view in The Sims 2's periwinkle with plumbob-green toggles" width="420"> | <img src="web/public/images/library-grid-ts2-dark-mode.png" alt="The same Sims 2 look in dark mode" width="420"> |
| <img src="web/public/images/library-grid-ts3.png" alt="Library view in The Sims 3's blue glass over pale panels" width="420"> | <img src="web/public/images/library-grid-ts3-dark-mode.png" alt="The same Sims 3 look in dark mode" width="420"> |
| <img src="web/public/images/library-grid-tsm.png" alt="Library view in The Sims Medieval's parchment and brass" width="420"> | <img src="web/public/images/library-grid-tsm-dark-mode.png" alt="The same Medieval look in dark mode, carved dark wood" width="420"> |
| <img src="web/public/images/library-grid-ts4.png" alt="Library view in The Sims 4's flat mint, the app's default" width="420"> | <img src="web/public/images/library-grid-ts4-dark-mode.png" alt="The same Sims 4 look in dark mode" width="420"> |
| <img src="web/public/images/library-grid-sc3000.png" alt="Library view in SimCity 3000's milled steel, squared off" width="420"> | <img src="web/public/images/library-grid-sc3000-dark-mode.png" alt="The same SimCity 3000 look in dark mode" width="420"> |
| <img src="web/public/images/library-grid-sc4.png" alt="Library view in SimCity 4's teal, rounded and glossy" width="420"> | <img src="web/public/images/library-grid-sc4-dark-mode.png" alt="The same SimCity 4 look in dark mode" width="420"> |
| <img src="web/public/images/library-grid-sc2013.png" alt="Library view in SimCity (2013)'s pale white and silver panels" width="420"> | <img src="web/public/images/library-grid-sc2013-dark-mode.png" alt="The same SimCity (2013) look in dark mode" width="420"> |

The classic Sims 1 interface sounds come along for the ride, and so does a
plumbob that turns up every few minutes with something true about the game
you're in. It knows which screen you're on, it stays off the ones you came to
read, and one switch in Settings sends it away for good.

<div align="center">

<img src="web/public/images/trivia-buddy.png" alt="The plumbob buddy floating over the saves screen with a fact about The Sims 2" width="800">

<sub>Facts, not tips. Every one of them is about the game you're actually managing.</sub>

</div>

## Features

- **Eight interfaces to pick from**: colors, logos and the shape of every
  button, drawn after The Sims 1, 2, 3, 4, Medieval, SimCity 3000, SimCity 4
  or SimCity (2013) - complete with the classic Sims 1 UI sounds, in light
  or dark.
- **Real thumbnails & insights**: `.package` files are parsed (DBPF) to
  pull out embedded artwork and a content breakdown (CAS parts, textures,
  tuning...), so your library looks like a library, not a file list.
- **Library** with search, category filters (Package/Script/Object/...),
  grid, list and folder layouts, sorting by name, date or size (with the
  option to keep disabled mods at the bottom), and live
  Total/Enabled/Disabled/Conflicts stats.
- **Duplicate finder**: the one scan you start yourself, because it reads
  whole files rather than headers. Identity is the SHA-256 and nothing
  weaker, since the answer comes with a delete button next to it - it tells
  you how much space the spare copies are costing and offers to tick them.
- **One-click enable/disable**: disabling renames the file with a
  `.disabled` suffix so the game's loader skips it; nothing is ever deleted.
  You can pick the suffix yourself to match another manager, and mods
  something else disabled (CC Magic's `.off`) show up in the library too.
- **Conflict warnings**: enabled mods are badged when they share a file
  name, when two versions of the same mod are installed side by side, and
  when their packages actually share DBPF resource keys (the real thing:
  the game keeps whichever copy it loads last).
- **Finds your folders for you**: localized user folders
  ("Los Sims 3", "Die Sims 2", the Ultimate Collection), every install
  when a game exists more than once, and you can point at any folder
  manually.
- **Mods-folder scaffolding**: if a game has no mods folder yet, the app
  creates it *with the files the game needs* (e.g. the Sims 3
  `Resource.cfg` framework).
- **Install**: pick mod files (filtered to the game's real extensions)
  or drop files and folders straight onto the window; `.zip`, `.rar` and
  `.7z` archives are unpacked for you, keeping their folder structure and
  skipping readmes and screenshots.
- **The Exchange**: a mod shop inside the app. Browse the whole catalog,
  filter by game, install in one click, and get an Update button when a
  creator ships a new version of something you already have.
- **Saves**: read-only insight into your save files - households, funds,
  photo albums, and world stats like population, net worth, life stages
  and top skills, without opening the game.
- **Creations**: the lots, rooms, households and sims you downloaded, shown
  as the pictures the game made of them rather than as file names. Dropping
  one in Mods is the loudest silent failure there is - the file is there,
  the game never looks at it - so these get filed into the game's own Tray
  or Library folder instead.
- **Packs**: every expansion, game pack, stuff pack and kit installed
  next to the game, with its artwork and its size on disk. The Sims 4 and
  The Sims 3 can be switched off from here without moving a single file;
  nothing is ever uninstalled.

<div align="center">

<img src="web/public/images/mod-details-conflict.png" alt="Mod detail view with a duplicate file name warning" width="800">

<sub>A mod's detail view: what's inside the package, where the file lives, and why it got flagged.</sub>

</div>

## The Exchange

The app has its own mod shop, currently in alpha. Publishing is free at the
**[creator portal](https://thesimsmodmanager.web.app/portal/)**, and what you
publish shows up on everyone's shelves.

<div align="center">

<img src="web/public/images/mod-shop.png" alt="The Exchange inside the app: game filters and mod cards with cover art, creator, size and an Install button" width="800">

<sub>The shelves, filtered by game. Installing puts the file in the folder of the game the listing names, whichever game you're currently looking at.</sub>

<img src="web/public/images/mod-shop-mod-detail-and-update-page.png" alt="A listing inside the app with screenshots, version, size, install notes, and Install and Download buttons" width="800">

<sub>A listing brings its screenshots and install notes along. <b>Install</b> drops the files into your mods folder; <b>Download</b> just saves the file wherever you want it. Once the creator publishes a newer version, Install becomes Update.</sub>

<img src="web/public/images/mod-shop-variations.png" alt="A listing published in five colours, with a row of variation chips to pick from" width="800">

<sub>A mod published in eight shades is eight listings - each one is a different file - so they're gathered onto one card instead of merged. Every variation keeps its own link, its own version and its own download count.</sub>

</div>

### The SimCity catalog

Beside our own listings, The Exchange carries the
[sc4pac](https://github.com/memo33/sc4pac-tools) channels: thousands of
SimCity 4 packages from Simtropolis and SC4Evermore, credited to the project
that keeps them. A download brings everything it depends on or nothing at
all, and where a host won't let an app fetch a file, the button says so up
front and sends you to the page instead.

<div align="center">

<img src="web/public/images/mod-shop-catalog.png" alt="The Simtropolis catalog inside the app: 3,358 SimCity 4 packages with their preview renders" width="800">

<sub>Source chips switch between our shelves and each catalog channel. Nothing here is ours, and the credit line says whose it is.</sub>

</div>

## Saves

Read-only insight into your save files, no game launch required: every
household with its funds and members, a photo album, and world stats
(population, net worth, life stages, top skills). Support varies per game
by what each save format actually holds.

<div align="center">

<img src="web/public/images/save-households-ts4.png" alt="Saves screen for The Sims 4 listing a save's households, with the selected household's funds, room count and members" width="800">

<sub>Every save's households, backups included. Open one to see its funds, its house, and who's living there.</sub>

<img src="web/public/images/save-stats-ts2.png" alt="Saves screen for The Sims 2 showing world stats: total Sims, households, net worth, size on disk, photos and a life-stage breakdown" width="800">

<sub>World stats for the whole save: population, net worth, life stages, even the highest skill in the save.</sub>

</div>

## Creations

The third thing the app manages, after the mods the scene writes and the
packs EA ships: the lots, rooms, households and sims that other *players*
built. None of it belongs in the mods folder - a lot dropped in there sits
on disk forever and the game never looks at it - so downloads get routed
into the game's own Tray or Library folder instead.

They're shown as pictures because that's how you recognise a house. The
thumbnails are the game's own renders, read out of the files: The Sims 4
obfuscates its tray JPEGs, The Sims 3 hides its lot renders behind resource
types that tell a lot apart from a mod, and The Sims 2 keeps a packaged
lot's residents in files beside it, so deleting one takes them along instead
of leaving sims who live nowhere.

<div align="center">

<img src="web/public/images/creations-ts3.png" alt="Creations screen for The Sims 3: a shelf of downloaded lots and households shown as their in-game renders" width="800">

<sub>Downloaded lots and households, with the pictures the game made of them. Add a zip and it gets unpacked and filed where the game reads it.</sub>

</div>

## Keeping a big library tidy

<div align="center">

<img src="web/public/images/library-duplicates.png" alt="The library after a duplicate scan: a banner offering to reclaim space, with matching files badged as copies" width="800">

<sub>The same download saved twice reads to every heuristic as two mods that merely resemble each other, so this one hashes the files. It's the only scan you start yourself, and it tells you what the spare copies cost before offering to tick them.</sub>

<img src="web/public/images/library-folders.png" alt="The library's folder layout, with sections per subfolder that roll up and open" width="800">

<sub>The folder layout: your mods folder as you actually arranged it. Sections roll up, and mods can be dragged between folders without leaving the app.</sub>

</div>

## Packs

The publisher's own content, listed beside your mods: expansions, game packs,
stuff packs and kits, each with its artwork, its code and what it takes up on
disk. Where a game has a safe way to run without one, there's a switch. The
Sims 4 writes the same `packstoskipmount` line its own Pack Selection screen
uses; The Sims 3 takes the pack out of the registry the launcher reads
(Windows, administrator rights); the Sims 2 switches sit behind an
experimental opt-in in Settings, because a neighborhood played with a pack can
break when it's opened without one. The Sims 1 merged its expansions into the
base game, so there the screen is a list. Either way nothing is moved or
uninstalled, and the game picks the change up on its next start.

<div align="center">

<img src="web/public/images/packs-list.png" alt="Packs screen for The Sims 4 listing expansion packs with their icons, code and size, each with an on/off switch" width="800">

<sub>A pack you switch off stays installed; the game just stops loading it. Useful for a lighter game, or for finding out which pack a mod is really fighting with.</sub>

</div>

## First run

Nothing to configure before you start. The app goes looking for all nine
games, reports what it found and where each keeps its mods, and asks the
handful of questions that are worth asking - your language, which game to
open on, how it should look and sound. Every one of them is a setting you
can change later, and you can skip the lot.

<div align="center">

<img src="web/public/images/onboarding-games-found.png" alt="The setup walkthrough reporting nine games found, each with how many mods it already has" width="800">

<sub>What it found, before you've told it anything.</sub>

<img src="web/public/images/onboarding-look.png" alt="The setup walkthrough's look page: eight app themes, light/dark, UI sounds and plumbob trivia" width="800">

<sub>Pick the look here or in Settings; it stays put whichever game you're managing.</sub>

</div>

After an update there's one card, shown once, saying what the new version
brought. A release with nothing worth saying doesn't get one - which is the
default, because a dialog on every patch is a dialog people learn to dismiss
without reading.

<div align="center">

<img src="web/public/images/whats-new-card.png" alt="The what's-new card after an update, with artwork and a summary of what the release brought" width="800">

<sub>It ships with the release rather than arriving from a server, so it works offline and it can't announce a feature your copy doesn't have.</sub>

</div>

## Download

Grab the latest version from the
**[Releases page](https://github.com/rodrifelix99/TheSimsModManager/releases/latest)**. Free, no account needed.

| Platform | File | Notes |
| --- | --- | --- |
| **Windows** (installer) | `TheSimsModManager-x.y.z-windows-setup.exe` | Recommended. SmartScreen may warn (app isn't code-signed yet); choose *More info → Run anyway* |
| **Windows** (portable) | `TheSimsModManager-x.y.z-windows-portable.zip` | Extract anywhere, run `sims_mod_manager.exe` |
| **macOS** | `TheSimsModManager-x.y.z-macos.dmg` | Signed & notarized by Apple. Open it and drag the app into Applications |
| **Linux** | `TheSimsModManager-x.y.z-linux-x64.tar.gz` | Extract the folder, run `TheSimsModManager.sh` |

## Supported games

| Game | Default mods location | Notes |
| --- | --- | --- |
| The Sims | `<install>\The Sims\Downloads` | Lives in the install folder, not Documents |
| The Sims 2 | `Documents\EA Games\The Sims 2\Downloads` | Ultimate Collection uses its own folder name |
| The Sims 3 | `Documents\Electronic Arts\The Sims 3\Mods\Packages` | Needs the `Resource.cfg` framework; the app creates it for you |
| The Sims Medieval | `<install>\The Sims Medieval\Mods\Packages` | Lives in the install folder (Documents only holds saves); needs a `Resource.cfg` in the install root - the app creates it for you |
| The Sims 4 | `Documents\Electronic Arts\The Sims 4\Mods` | Created by the game on first launch; enable CC/script mods in game options |
| SimCity 3000 | `<install>\Buildings` | Flat - the game doesn't read subfolders, and the app says so when a file lands in one |
| SimCity 4 | `<install>\Plugins` and `Documents\SimCity 4\Plugins` | Load order is left exactly as a download arrives; sc4pac's own content is left to sc4pac |
| SimCity Societies | `<install>\Import` | `.SCSPack` content, in the folder its own package installer uses |
| SimCity (2013) | `<install>\SimCityUserData\Packages` | Under Program Files, so Windows may ask for administrator rights |

All of these are best-effort defaults: every game's folder can be overridden
in Settings, which covers custom drives, localized folder names,
OneDrive-relocated Documents, and Wine/CrossOver prefixes on macOS/Linux.

Pick which games you want on the sidebar in Settings; hiding one keeps every
setting it has. For the SimCity side, what was verified against real
installs and where support stops on purpose is written down in
[docs/simcity-support-validation.md](docs/simcity-support-validation.md).

The core is game-agnostic by design: any other moddable game can be added
without touching the rest of the app. See
[docs/adding-a-game.md](docs/adding-a-game.md).

## Building from source

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install) with
desktop support enabled.

```sh
flutter pub get
flutter run -d windows   # or: -d macos / -d linux
```

Run the tests and analyzer with `flutter test` and `flutter analyze`.
More detail in [docs/architecture.md](docs/architecture.md).

## Languages

The app speaks twelve languages and the website eleven of them (Dutch is
app-only for now). English and Portuguese are mine; the other ten were done
by simmers who actually play in them, which is why they use each scene's own
modding slang instead of a dictionary translation:

| Language | Translated by |
| --- | --- |
| English | rodrifelix99 |
| 简体中文 | xiaoyu_sims |
| Español | marisol_plumbob |
| Português (Brasil) | rodrifelix99 |
| Français | clodesims |
| Deutsch | plumbobjonas |
| Italiano | giuliapixel89 |
| Русский | verasimka |
| Polski | kasia_pxl |
| 日本語 | mochi_simjp |
| Ελληνικά | [friendofbellas](https://www.tumblr.com/friendofbellas) |
| Nederlands | [sims2idea](https://www.tumblr.com/sims2idea) |

Spotted something that reads wrong in your language, or want to add one that
isn't here? The strings live in [lib/l10n](lib/l10n) (app) and
[web/src/i18n](web/src/i18n) (website) - open an issue or a PR, credit included.

## Contributing

Bug reports, feature ideas, and pull requests are very welcome; see
[CONTRIBUTING.md](.github/CONTRIBUTING.md). Good first stops:

- The **[Wiki](https://github.com/rodrifelix99/TheSimsModManager/wiki)**: user guide & FAQ
- The **[Tumblr blog](https://thesimsmodmanager.tumblr.com/)**: news & release announcements
- [docs/architecture.md](docs/architecture.md): how the app is put together
- [docs/adding-a-game.md](docs/adding-a-game.md): add support for a new game

## Thanks

A good chunk of this app exists because someone with more patience than me answered a question at a bad hour:

- **bunsenpixel**, who figured out that a macOS window keeps the material it was born with, so the blur has to be set inside `waitUntilReadyToShow` and not a frame later. Two evenings of staring at a solid white window, fixed in one message.
- **wanderbyte**, for spotting that bsdtar unpacks `.rar`/`.7z` through `\\?\` paths and then leaves behind names the normal Windows API can't reach again, which is why a single deep archive was taking whole installs down with it.
- **mothcache**, for the RefPack notes that got the DBPF parser reading compressed resources instead of shrugging at half the packages in my Mods folder.
- **plumbtreemods**, who knows exactly where every kind of Sims 1 file is meant to land, mesh-name prefixes for buyable clothing included. The Sims 1 routing rules are theirs, I only wrote them down in Dart.
- **hexley_j**, for the Inno Setup warning that stopped me changing the `AppId` and shipping an "upgrade" that installs itself a second time next to the old one.

And to everyone who reported a bug with a screenshot and their real folder layout attached: that saves more time than it looks like it does.

## Where AI fits in

Claude turns up in this repo's contributor list now and then. It writes comments, docstrings, and paragraphs like this one - the spots where "correct and clear" is the whole job since English and clear documentation is not native to me. It has never touched the DBPF parser, the sims3pack offset math, or the conflict detector; those are mine, line by line, and I can walk you through any of them if you ask. I don't merge code I can't explain myself, full stop. Longer version, with the two bugs that taught me why that matters: [Say no to vibe coding](https://www.tumblr.com/thesimsmodmanager/823165940293369856/say-no-to-vibe-coding).

## Roadmap

More games via the adapter system. See the
[open issues](https://github.com/rodrifelix99/TheSimsModManager/issues) for
what's planned and to suggest more.

## License & disclaimer

The source is available for reading and contributing, but this is **not** an
open-source license: the code may not be reused or redistributed. The app
itself is free to download and use. See [LICENSE.md](LICENSE.md).

> **The Sims Mod Manager is an unofficial fan project.** It is not affiliated
> with, endorsed by, or sponsored by Electronic Arts Inc. or Maxis. *The
> Sims*, *SimCity*, and all related logos, artwork, and sounds are trademarks
> or copyrighted material of Electronic Arts Inc. and are used here for
> identification and interoperability only.
