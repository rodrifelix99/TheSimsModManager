# SimCity support: evidence and limitations

What was established before any of the four SimCity adapters was written,
how it was established, and - just as importantly - where the evidence
stopped and the adapter stopped with it.

Every claim carries one of four labels:

| Label | Meaning |
| --- | --- |
| `VERIFIED_LOCAL` | Read off an installed copy of the game on the reference machine, or produced by running this app's own code against one. |
| `VERIFIED_SOURCE` | Stated by the game's own files, by an established tool's source, or by a mod author's own README. |
| `HYPOTHESIS` | Plausible, corroborated by one source, not proven. Never used to justify writing to disk. |
| `UNSUPPORTED` | No evidence found. The adapter does nothing here. |

## The reference machine

Windows 11 Home 26200, all four games installed:

| Game | Edition | Install | Store | Version |
| --- | --- | --- | --- | --- |
| SimCity 3000 | Unlimited | `C:\Games\SimCity 3000 Unlimited` | GOG | `SC3U.exe`, DDrawCompat wrapper present |
| SimCity 4 | Deluxe + Rush Hour (`EP1`) | `...\Steam\steamapps\common\SimCity 4 Deluxe` | Steam | **1.1.641.0** (read from the game's own config log) |
| SimCity Societies | base + Destinations | `C:\Program Files\EA Games\SimCity Societies` | EA | `SimCitySocieties.exe` 6.9 MB, `SCSDestinations.exe` present |
| SimCity | with Cities of Tomorrow | `C:\Program Files\EA Games\SimCity` | EA | `version_app.txt` changelist 997255 |

The SimCity 4 install also carries a **real, third-party-managed mod
library**: sc4pac with two packages, the Network Addon Mod (366 MB in one
`.dat`, six folder levels deep), and 777 plugins in total. That is what
most of the SimCity 4 findings below were tested against, and it is why
several of them exist at all.

---

## Detection

### Registry (Windows) - `VERIFIED_LOCAL`

Read from the machine's own hive. All four are 32-bit applications, so
they land under `Wow6432Node`; both views are tried.

| Game | Key | Value | Note |
| --- | --- | --- | --- |
| SimCity 4 | `SOFTWARE\Maxis\SimCity 4` | `Install Dir` | also `IsDeluxe`, and an `EP1` subkey for Rush Hour |
| SimCity 3000 | `SOFTWARE\Electronic Arts\Maxis\SimCity 3000 Unlimited` | `InstalledPath` | **points at the `Apps` subfolder, not the game root** |
| SimCity Societies | `SOFTWARE\Electronic Arts\SimCity Societies` | `Install Dir` | expansion is a sibling key named `SimCity Societies (tm) Destinations` |
| SimCity (2013) | `SOFTWARE\Maxis\SimCity` | `Install Dir` | same vendor key as SimCity 4, one level up |

The SimCity 3000 `Apps` quirk is the one that would have silently broken
detection: read as the root, the mods folder resolves one level too deep
and the game looks uninstalled. `RegistryInstallHint.below` exists for it.

`SOFTWARE\WOW6432Node\Electronic Arts\Maxis\SimCity 4 Deluxe` also exists
on this machine and is **empty** - a decoy. Nothing reads it.

### Signature check - `VERIFIED_LOCAL`

A registry path, a launcher folder and the disk walk all end at the same
gate: a folder is only this game if it holds a file the game cannot run
without. Folder names are never a criterion (this machine's SimCity 3000
is at `C:\Games\...`, not under Program Files, and disc installs are
localized).

| Game | Signature |
| --- | --- |
| SimCity 4 | `Apps/SimCity 4.exe` (or `Apps/SimCity4.exe`) |
| SimCity 3000 | `Apps/SC3U.exe`, `Apps/SC3.exe` or `Apps/Baapp.exe` |
| SimCity Societies | `SimCitySocieties.exe` **and** `Data` |
| SimCity (2013) | `SimCity/SimCity.exe` **and** `SimCityData` |

SimCity (2013) needs both because "a folder called SimCity under EA
Games" is as likely to be SimCity 4's. A test pins that a SimCity 4
layout is not detected as SimCity 2013.

### Steam / GOG / EA / custom paths - `VERIFIED_LOCAL`

Handled by the same `core/install_scan.dart` the Sims install-folder
games use (moved there from the Sims adapters for this work): every Steam
library named in `libraryfolders.vdf`, every Windows drive root, three
levels deep, system folders skipped, bounded by a timeout. Plus the
launcher roots (`EA Games`, `Origin Games`, `GOG Galaxy\Games`, `Maxis`,
`Games`, `GOG Games`).

### Wine / Proton - `HYPOTHESIS`

The games register themselves in the **prefix's own hive**, not the
machine's, so `registryInstallDirs` returns nothing there. The folder
walk plus the signature check is what remains, and it is the same
mechanism the Sims install-folder games already rely on under Proton.
Not verified: no Linux machine was available. Documented as a limitation
rather than claimed.

### macOS - `UNSUPPORTED`

SimCity 4 had a native Mac port (Aspyr) with a different bundle layout,
and none of the four is currently sold for macOS. Nothing is claimed.

---

## SimCity 4

### Two plugin roots, both live - `VERIFIED_LOCAL` + `VERIFIED_SOURCE`

The install's own `Apps\SimCity 4.ini` reads:

```ini
[Directories]
Data=..\
PlugIn=..\Plugins\
```

so the install-directory `Plugins` folder is a real root and is
configurable. `Documents\SimCity 4\Plugins` is the other, and is what the
community and sc4pac use. The 0xC0000054 plugin READMEs name **either**
("the top-level of the Plugins folder in the SimCity 4 installation
directory or Documents/SimCity 4 directory").

**Decision:** the user folder is the mods folder (writable without
elevation, survives reinstalls); the install folder is an
`extraModsDirectories` root, so what is in it is visible rather than
invisible. Verified end to end - the probe lists mods from both.

### Custom user directory (`-UserDir`) - `VERIFIED_LOCAL`

The launch parameter lives in a shortcut the app cannot read. But sc4pac
records the folder it actually installs into, and this machine's
`sc4pac-plugins.json` names it:

```json
{"config": {"pluginsRoot": "C:\\Users\\rodri\\Documents\\SimCity 4\\Plugins", ...}}
```

**Decision:** an sc4pac profile's `pluginsRoot` is the first candidate,
ahead of the Documents guess. That is the only reliable way to find a
custom user directory, and a profile pointing elsewhere is the user
telling us so in writing.

### Load order is path and file name - `VERIFIED_SOURCE`

sc4pac's README: *"Packages are installed into subfolders prefixed by an
even number, as the order in which files are loaded by the game is
important"*, with `050-load-first` ... `900-overrides`, and odd-numbered
folders reserved for the user's own manual plugins. The scene's `zzz...`
override naming is the same rule from the other end.

**Consequence, and it is load-bearing:** an install here must never
flatten an archive, tidy a name, or re-sort a folder. The structure a
download arrives with is a functional part of it. The shared archive
install already preserves structure; a test pins that a `.dat` inside
`zzz_override/deep/` stays exactly there.

### A DLL only loads from the top of a root - `VERIFIED_SOURCE` + `VERIFIED_LOCAL`

Every 0xC0000054 README says "the top-level of the Plugins folder".
sc4pac proves it from the other end: on this machine it stores
`ExtraExtraCheats.dll` inside
`150-mods\simmaster07.extra-cheats-dll.1.1.1-3.sc4pac\` and **symlinks it
to the top of Plugins**, because that is the only place the game reads it.

**Decision:** `_liftPlugins` moves an installed `.dll` (and its settings
file) to the top of the mods root after an archive or folder install.
Only `.dll` moves - everything else keeps its folder, because that folder
is load order.

### Multi-file plugins - `VERIFIED_SOURCE`

READMEs read, and they agree:

| Plugin | Files to install | Files it generates |
| --- | --- | --- |
| `sc4-auto-save` | `SC4AutoSave.dll` + `SC4AutoSave.ini` | `SC4AutoSave.log` |
| `sc4-graphics-options` | `.dll` + `.ini` | `.log` |
| `sc4-more-building-styles` | `.dll` + `.ini` + `.dat` + `BuildingStyles.ini` | `.log` |
| `sc4-region-census` | `.dll` (install Plugins) + `RegionCensusUI.dat` (any Plugins) | `.log` |
| `sc4-dbpf-loading` | `.dll` alone | `.log` |
| SC4-ModernCamera (installed here) | `.dll` | `.json` (user-edited), `.last`, `.log` |

**Decision:** a new generic capability,
`GameAdapter.companionFileExtensions` (`.ini` for SimCity 4, empty for
every Sims game). A companion is installed with its mod, follows it
through a disable, and is deleted with it - but is **never listed as a
mod**, never counted, and never enabled on its own. Belonging is decided
by file name, which is the same rule the plugins themselves use to find
their own settings.

That leaves the state a plugin must never reach:

```
DLL enabled   INI disabled   DAT removed
```

Tests pin install, disable, re-enable and uninstall of a `.dll`+`.ini`
pair, including that an unrelated `Other.ini` is left alone.

Not covered: `sc4-more-building-styles`' second, differently-named ini
(`BuildingStyles.ini`) is treated as an ordinary file rather than a
companion, because nothing in the file name ties it to the plugin. It
installs (the extension is installable) but is listed as neither a mod
nor a companion. Known limitation.

### Coexistence with sc4pac - `VERIFIED_LOCAL`

Records read from this machine:

```
%APPDATA%\io.github.memo33\sc4pac\config\profiles\
  sc4pac-profiles.json          the profile list
  1\sc4pac-plugins.json         config.pluginsRoot, channels, explicit
  1\sc4pac-plugins-lock.json    installed[].files[] - paths relative to the root
```

The README documents both files in the Plugins folder itself; the current
build puts them under `%APPDATA%`. **Both are read.**

**This was the single most valuable finding of the work.** Run against
the real Plugins folder with the ownership check disabled, the library
shows **781** mods; with it, **777**. The four held back are:

```
<Plugins>\ExtraExtraCheats.dll                                        ← symlink
<Plugins>\150-mods\...extra-cheats-dll.1.1.1-3.sc4pac\ExtraExtraCheats.dll   ← its target
<Plugins>\SimCity 4 Extra Cheats Plugin.dll                           ← symlink
<Plugins>\150-mods\...extra-cheats-dll.1.1.1-3.sc4pac\SimCity 4 ...Plugin.dll ← its target
```

Two real plugins shown as four. Both halves of each pair are byte
identical, so the duplicate scan would have grouped them and offered
"tick the spare copies" - one click from deleting files sc4pac's lock
file still claims. That is exactly the confidently-incorrect behaviour
this work was told not to ship.

**Decision:** paths sc4pac's lock file claims are held out of the
library. A lock file that cannot be parsed falls back to the
`*.sc4pac` folder suffix, which is sc4pac's own and which nothing else
writes; a test pins that in that case the *stored* copy is still hidden
and only the top-level file the game actually loads remains, so the
dangerous pair is never formed. Nothing here writes to sc4pac's files.

### Depth and scale - `VERIFIED_LOCAL`

The Network Addon Mod reaches six levels under Plugins and loads.
`modDepthLimit` is null (no limit). 777 mods across that tree list in
**240 ms**.

### Game version - `VERIFIED_LOCAL`

`Apps\FELIX-PC-config-log.txt` reports `version = 1.1.641.0`, and
SC4-ModernCamera's own log reports `Detected SimCity 4 game version: 641`.
Modern DLL plugins do check this. **Not implemented:** the app does not
read the version or gate installs on it. Documented rather than guessed
at - a wrong version claim is worse than none.

---

## SimCity (2013)

### Mod roots - `VERIFIED_LOCAL` + `VERIFIED_SOURCE`

`SimCityUserData\Packages` exists on a clean install and is empty.
`SimCityData` holds the game's own eleven packages (400 MB `SimCity_App`,
`SimCity_Game`, ..., plus `SimCityDataEP1.package` for Cities of Tomorrow).
Community documentation says mods go in either, and that **`SimCityData`
loads alphabetically and a mod must sort before `SimCity_...`**.

**Decision:** only `SimCityUserData\Packages` is managed. Sweeping
`SimCityData` would put Maxis's own content in the library with a Delete
button beside it, and nothing on disk says which file is the game's -
the same reason The Sims 1's `GameData\Global` is never swept.

**Known limitation, stated in the app's own setup help:** a mod whose
readme requires it to load before the game's packages has to be placed in
`SimCityData` by hand. This app will not do it.

### Cities of Tomorrow - `VERIFIED_LOCAL`

`SimCityData\SimCityDataEP1.package` and `SimCityData\version_data_cot.txt`.
Read, never assumed.

### Permissions - `VERIFIED_LOCAL`

The whole install, user data included, is under `Program Files`. The
app's existing `folder_access.dart` write probe and read-only banner
cover it. Not solved by requiring elevation: that would break Explorer
drag-and-drop (issue #5).

### Online vs offline - `HYPOTHESIS`

Community sources consistently mark many mods offline-only. The setup
help says so. **The app does not detect it** - nothing in a `.package`
declares it. No mod was installed into this machine's SimCity 2013 and no
city was loaded: the game needs an EA account session and the risk to
server-side city state was not worth a validation datapoint.

---

## SimCity 3000

### Custom buildings - `VERIFIED_LOCAL` + `VERIFIED_SOURCE`

`.bld` files (Building Architect Tool output) in `<install>\Buildings`.
Confirmed by the install (17 `.bld` files present) and by community
installation instructions.

### The stock-content problem - `VERIFIED_LOCAL`

All seventeen `.bld` files in `Buildings` carry the **installer's own
timestamp** (18/08/2026 20:56:18, identical to the second) - they shipped
with the game. The folder therefore mixes Maxis's content with the
player's, exactly like The Sims 1's `GameData\Global`.

**Decision:** a shipped table (`simCity3000StockBuildings`) holds the
seventeen names out of the library. A building this table does not know
is listed, which is the right way round to be wrong: a stock building of
an edition nobody checked shows up as a mod, rather than a player's own
building quietly disappearing. Verified: the probe lists **0** mods on
this install, and a test pins that `My Tower.bld` survives while
`Maxis Towers.bld` does not.

### Depth - `HYPOTHESIS`

`Buildings` is flat on this install and no source describes subfolder
support. `modDepthLimit` returns 0, so a building filed into a subfolder
raises the app's existing "on disk, never loaded" banner. Conservative,
and reversible if evidence appears.

### Executable patches - `UNSUPPORTED`, deliberately

SimCity 3000 Unlimited's resolution and compatibility fixes patch
`SC3U.exe` itself; this machine also has a `ddraw.dll` wrapper
(DDrawCompat) in `Apps`. Neither is a file to enable and disable. Doing
it safely needs exact edition and build identification, an input hash, a
verified patch operation, a kept original, protection against applying
twice, and refusal on an unrecognised executable. None of that is in this
app, so these are reported as manual in the setup help and the app
touches neither the executable nor `Apps`.

### Other content types - `UNSUPPORTED`

`Cities\*.sc3` are saves, `Apps\BACustom\{Details,Paints,Props}` is
Building Architect working content, `Scripts\<LANGUAGE>` is localisation.
None is mod management and none is touched.

---

## SimCity Societies

**The weakest of the four, and the adapter says so.**

### The Import folder - `VERIFIED_LOCAL` (binary inspection)

The game ships `PackageInstaller.exe`. Its string table contains:

```
SimCity Societies\Import\
SOFTWARE\Electronic Arts\SimCity Societies
Install Dir
SHGetFolderPathW
Package Installer
Are you sure you want to install this package?
```

So the game's own installer resolves the Documents folder and writes into
`Documents\SimCity Societies\Import\`. Its sibling `Export` exists on
this machine, which is what the pair is for. `Import` does not exist yet,
so the app's setup screen offers to create it - verified by the probe
returning `modsDir: null` with a correct `defaultModsPath`.

### The file extension - `VERIFIED_LOCAL` (and the first answer was wrong)

The first pass shipped `.package`, reasoning that a tool called Package
Installer installs packages, and flagged it as the weakest claim in this
document. It was wrong, and the game says so itself. One run of UTF-16
strings in `SimCitySocieties.exe` carries the whole content
configuration:

```text
*.SCSPack   FileExtension/Package   dup   Directory/Export   Directory/Import   //Package   //FileAdd
```

with the rest of its directory keys beside it (`Directory/Data`,
`Directory/Scripts`, `Directory/CustomMaps`, `Directory/Localization`).
The literal `.package` appears **zero** times in the binary, in either
encoding.

So the extension is **`.SCSPack`**, and the adapter now accepts that and
nothing else. Had the guess shipped, a Societies player's real downloads
would have been invisible in the library - a folder full of content and
an empty screen, which is the exact silent failure this app exists to
prevent. The lesson is the cheap one: the binary that reads the format
was sitting on the same disk as the folder it reads from, and it was
worth ten minutes to ask it.

`PackageInstaller.exe` filtering on `All Files (*.*)` is not a
contradiction - it is a copy tool, and it lets you hand it anything.

Corroborated afterwards from outside the machine: surviving community
documentation describes `.SCSPack` as the format Societies content was
shared in, and says the normal way to install one was to **double-click
it**, which is the file association firing `PackageInstaller.exe`. That
matches the binary exactly.

It also leaves one thing open. This app writes the file into `Import`
directly, which is the same end state *if* `PackageInstaller.exe` only
copies. Its strings suggest nothing more (`Directory/Import`, a
confirmation prompt, an error string) and it is only 126 KB, but that it
does no registration step of its own is inference rather than proof. No
real `.SCSPack` could be obtained to settle it - the surviving hosts want
an account - so the test file used in the cycle carried the right name
and nothing else.

### Destinations - `VERIFIED_LOCAL`

Installed *inside* the base game's folder
(`SimCity Societies\SimCity Societies Destinations\`) with its own
`SCSDestinations.exe`, `SCSLibxp1.dll` and `DataXP1\`. Detected by those,
not by the registry key (whose name carries a `(tm)`).

### What the app deliberately does not do - `UNSUPPORTED`

Societies' gameplay is C# in `Data\Scripts` (`Ability_*.cs`) and XML in
`Data\XMLDb`, both inside the install and both entirely Maxis's. Most of
what the scene did was edit those in place. The app never lists, writes
to, or offers to delete anything under `Data`.

---

## DBPF: what was verified before anything was enabled

The repository's DBPF reader was written for Sims layouts. It was run
against **real** SimCity files before any conflict or artwork feature was
allowed near them (`lib/src/core/dbpf.dart`, unchanged by this work):

| File | Version | Header count | Parsed | Out of bounds |
| --- | --- | --- | --- | --- |
| `SimCity_DLC0.package` (2013) | **3.0** | 1806 | 1806 | 0 |
| `LocalSettings.package` (2013) | 3.0 | 1 | 1 | 0 |
| `NetworkAddonMod_BaseContent.dat` (SC4) | **1.0** | 3330 | 3330 | 0 |
| `NetworkAddonMod_UI.dat` (SC4) | 1.0 | 7 | 7 | 0 |
| `SimCityLocale.DAT` (SC4) | 1.0 | 5962 | 5962 | 0 |

Over 12,000 index entries, every count matching the header exactly, every
entry's offset and size inside the file. SimCity 2013's DBPF **3.0**
header uses the same field layout as Sims 3/4's 2.x (index offset at 0x40,
28-byte hoisted entries) and parses through the existing v2 path;
SimCity 4's 1.0 uses the 20-byte v1 records the Sims 2 path already reads.

Two consequences checked rather than assumed:

- `conflicts.dart` already ignores resource type `0xE86B1EEF`, the
  compression directory. SimCity 4 files carry it too (seen in
  `NetworkAddonMod_UI.dat` and `SimCityLocale.DAT`), so every compressed
  `.dat` would otherwise have flagged every other one. It carries over
  correctly with no change.
- `package_insight.dart`'s content taxonomy is Sims-specific. **None** of
  the SimCity resource types observed (`0x296678F7` exemplar,
  `0x5AD0E817`, `0x7AB50E44` FSH, `0x6534284A` S3D, `0x2026960B` LTEXT,
  `0x2F4E681B`, `0x00B1B104`) appears in it, so they produce **no label**
  rather than a wrong one - a SimCity plugin is never described as "CAS
  parts". `0x856DDBAC` is PNG in both franchises and is read as a
  thumbnail, correctly. No taxonomy change was needed and none was made.

---

## End-to-end cycle: SimCity 4 - `VERIFIED_LOCAL`

Run against the reference machine's **real** 777-plugin library, through
the adapter the app's own Install/Enable/Remove buttons go through.

Safety first: the game was confirmed not running, and every file under
`Documents\SimCity 4\Plugins` was SHA-256 hashed beforehand (786 files,
1.27 GB, plus a 957-line entry list covering folders, plus a copy of
sc4pac's lock file). No existing file was written to at any point, and no
city was ever loaded.

**Subject:** [sc4-auto-save](https://github.com/0xC0000054/sc4-auto-save)
v1.2.0, `SC4AutoSave.zip`, sha256
`2873ca87...1bfeb55` - a real, open-source, MIT-licensed DLL plugin
carrying `SC4AutoSave.dll` + `SC4AutoSave.ini` + three text files. The
archive was inspected before anything was extracted; auto-save only fires
with a city loaded, and none was.

| Step | Result |
| --- | --- |
| Install (`installArchive`) | **1** mod reported, not 2 - the `.ini` rode along as a companion. Both landed at the **top level** of Plugins. `README.txt`, `LICENSE.txt` and `Third Party Notices.txt` were not installed. Library 777 -> 778. |
| Hash diff after install | 2 added, **0 removed, 0 changed** across the 786 existing files. |
| Launch #1 | Game ran (its own config log rewritten). `SC4AutoSave.log` appeared containing `SC4AutoSave v1.2.0` - **written by the plugin itself, so it loaded**. |
| Disable | `.dll` **and** `.ini` renamed together to `.disabled`. |
| Launch #2 | Game ran; **no log** written. The plugin really is inert. |
| Re-enable | Both files back under their own names. |
| Launch #3 | Log written again. The plugin loads again. |
| Uninstall | `.dll`, `.ini` and the generated `.log` all gone. Library 778 -> 777. |
| Hash diff after uninstall | **0 added, 0 removed, 0 changed.** Entry-level diff including folders: **0 differences.** sc4pac's lock file byte-identical. The install-directory Plugins folder untouched (5 files, as at baseline). |

**One defect was found by the cycle and fixed.** On the first pass,
uninstalling left `SC4AutoSave.log` behind: the plugin writes it on
first load, `.log` is not a mod extension, so it was invisible to the
library and the folder would slowly fill with logs of plugins that are
no longer installed. Fixed with a new adapter capability,
`GameAdapter.generatedFileExtensions` (`.log` for SimCity 4, empty
everywhere else) - deliberately separate from
`companionFileExtensions`, because a companion is something the
download carried and the mod needs while this is output the mod
produced. Generated files are never installed, are **not** renamed when
a mod is switched off (a log records what happened; it is not part of
the mod's state), and are deleted with the mod. The cycle was then re-run
end to end and the table above is the second run.

That is exactly what an end-to-end pass is for: nine automated tests
covered install, disable, re-enable and uninstall of a `.dll`+`.ini`
pair and every one of them passed while the bug was still there, because
none of them had ever let a real game write a real log.

## End-to-end cycle: SimCity 3000 - `VERIFIED_LOCAL` (with one gap)

Against the real GOG install at `C:\Games\SimCity 3000 Unlimited`, whose
`Buildings` folder is writable (it is not under Program Files). All 17
shipped `.bld` files hashed first.

**Subject:** a genuine `.bld` in the real format - the game's own
`Tutorial House.bld`, copied out and renamed `SMM Test Tower.bld`,
zipped. It never left this machine.

| Step | Result |
| --- | --- |
| Install | Landed in `Buildings` as `[Building]`. **18 `.bld` on disk, 1 in the library** - the 17 shipped buildings held out by name, on real data. |
| Launch #1 | `SC3U.exe` ran and stayed up for 25 s with the custom building installed. No crash, no refusal. |
| Disable | `SMM Test Tower.bld.disabled` on disk, still one row in the library, marked disabled. |
| Re-enable | Back under its own name. |
| Uninstall | Gone; library 0. |
| Hash diff | **0 added, 0 removed, 0 changed** across the 17 shipped buildings. |

**The gap, stated plainly: whether the building reaches the in-game menu
was not verified.** SimCity 3000 writes *nothing* while it runs - an
instrumented launch watching all 3,496 files in the install recorded zero
writes and zero new files - and `SC3.cfg` is only persisted on a clean
exit, which needs someone to quit through the game's own UI. So there is
no deterministic load signal to capture, and "the game launched" is all
this cycle can honestly claim. A human with the build menu open is what
would close it.

## End-to-end cycle: SimCity Societies - `VERIFIED_LOCAL` (filesystem only)

| Step | Result |
| --- | --- |
| Create the mods folder | `Documents\SimCity Societies\Import` did not exist; `createModsDirectory` made it, and it is writable. |
| Install | A `.SCSPack` installed. A `decoy.package` and a `readme.txt` in the same archive were **not** installed - the corrected extension is enforced end to end, and the old `.package` behaviour is genuinely gone. |
| Disable / re-enable / uninstall | All correct, marker on and off. |
| Restore | The `Import` folder was removed again, since it was not there at baseline. Everything else in `Documents\SimCity Societies` untouched. |

**Not verified:** the game was not launched with content installed, and
no real `.SCSPack` was obtained - the test file carries the right name and
nothing else. Whether Societies picks up a file dropped into `Import` by
something other than its own Package Installer is open.

## End-to-end: SimCity (2013) - the refusal path, `VERIFIED_LOCAL`

`SimCityUserData\Packages` sits under `Program Files` and is **not
writable unelevated**, which is the state most of this game's players are
in. That, rather than a successful install, is the case worth proving.

| Check | Result |
| --- | --- |
| `canWriteInto` | **false** - so the library draws its read-only banner before the user tries anything. |
| Install attempt | Refused. Nothing was written; the folder is still empty. |
| What the adapter throws | `PathAccessException`, carrying the OS's own text (`Acesso negado` on this machine, because Windows answers in the user's language) **and the source path**. |
| What the user is shown | `installFailureMessage` turns it into `errorNoWriteAccess` naming **the folder that needs the permission** - not the file it was reading, not the OS text, and not the user's download path. Pinned by a test. |

No install into SimCity 2013 was attempted with elevation, and the game
was not launched: it needs an EA account session, and a mod's effect on
server-side city state is not worth a validation datapoint.

## Looking at the running app - `VERIFIED_LOCAL`

Everything above is the filesystem and the games. The app's own screens
were verified separately, by building it and looking, and that found two
things no test had.

What was confirmed on screen, against the real libraries: the sidebar
grouping (`THE SIMS` and `SIMCITY` headings, drawn only because there is
more than one franchise); all nine games listed with live counts, SimCity
4 at its real 777 and SimCity 3000 at 0 with its seventeen shipped
buildings held back; SimCity Societies dimmed as not installed, because
`Import` does not exist; the SimCity 3000 empty state naming the folder it
watches; the SimCity 4 library drawing artwork and resource counts pulled
out of real `.dat` files by the existing DBPF reader; a Network Addon Mod
path six folders deep preserved exactly; and the Sims games unchanged,
skin, trivia buddy and all.

**Two defects, both visible only by looking.**

- The sidebar's fallback badge draws the digits in a game's name. That
  was one character for every Sims game and is four for SimCity 3000, so
  it rendered clipped as `300`. The text now scales to fit.
- The brand line under the app name still read *for The Sims*. It now
  names both franchises, in all eleven languages.

Neither was reachable from a test: one is a pixel measurement inside a
27px circle, the other is a string that was true when it was written.

## Support matrix

| | SimCity 3000 | SimCity 4 | SimCity Societies | SimCity (2013) |
| --- | --- | --- | --- | --- |
| Auto detection | ✅ registry + signature | ✅ registry + signature + sc4pac | ✅ registry + signature | ✅ registry + signature |
| Manual path | ✅ | ✅ | ✅ | ✅ |
| Basic mod install | ✅ | ✅ | ✅ `.SCSPack`, read off the game binary | ⚠️ refused unelevated, safely |
| Archive install | ✅ zip/rar/7z | ✅ zip/rar/7z | ✅ zip/rar/7z | ✅ zip/rar/7z |
| Nested archive structure | n/a (flat folder) | ✅ preserved, never flattened | ✅ preserved | ✅ preserved |
| Multiple mod roots | ❌ one folder | ✅ user + install Plugins | ❌ one folder | ⚠️ user Packages only, by design |
| Enable / disable | ✅ | ✅ incl. companion `.ini` | ✅ | ✅ |
| Uninstall | ✅ | ✅ incl. companion `.ini` | ✅ | ✅ |
| Dependencies | ❌ none declared by the format | ❌ not modelled (sc4pac's job) | ❌ | ❌ |
| Multi-file mods | n/a | ✅ `.dll` + same-named `.ini` | ❌ | ❌ |
| Load-order preservation | n/a | ✅ structure and names untouched; DLLs lifted to root | n/a | ⚠️ user folder only |
| Conflict detection | ⚠️ name/duplicate only (`.bld` is not DBPF) | ✅ incl. DBPF resource overlap (parser verified) | ⚠️ name/duplicate only | ✅ incl. DBPF resource overlap (parser verified) |
| DBPF insight | ❌ not a DBPF format | ✅ verified on real files | ❌ unverified | ✅ verified on real files |
| Cache clearing | ❌ none known | ❌ none known | ❌ none known | ❌ none known |
| Stock content protected | ✅ shipped name table | ✅ install Plugins is read, not swept | ✅ `Data` never touched | ✅ `SimCityData` never swept |
| External manager coexistence | n/a | ✅ sc4pac ownership honoured | n/a | n/a |
| Real-game E2E | ✅ full cycle; game launched, but no load signal exists to read | ✅ **full cycle, game launched at each step** | ⚠️ full filesystem cycle; game not launched | ✅ refusal path verified; install needs elevation |
| Tested editions | Unlimited (GOG) | Deluxe + Rush Hour (Steam), 1.1.641.0 | base + Destinations (EA) | base + Cities of Tomorrow (EA) |
| Tested OS | Windows 11 26200 | Windows 11 26200 | Windows 11 26200 | Windows 11 26200 |

Legend: ✅ implemented and verified · ⚠️ implemented with a stated limit ·
❌ not implemented.

## Known limitations, in one place

1. **SimCity 3000's in-game result is unverified.** The full filesystem
   cycle ran against the real install and the game launches with a custom
   building present, but the game writes nothing at runtime, so whether
   the building reaches the build menu needs a human to look.
2. **SimCity Societies was never launched with content installed**, and
   no real `.SCSPack` was obtained. The extension is proven from the
   game's own binary, but that a file dropped into `Import` by something
   other than the game's Package Installer is picked up is not. This is
   now the thinnest claim in the document.
3. **SimCity 2013 was never successfully installed into**, because its
   folder needs elevation and the app deliberately does not ask for it.
   The refusal is verified; the success path is not. Separately, mods
   that must load before the game's own packages need `SimCityData` by
   hand, which is not automated, by design.
4. **SimCity 4 game-version requirements are not checked.** Modern DLL
   plugins declare them; the app neither reads the game version nor gates
   an install on one.
5. **SimCity 4 dependencies are not modelled.** sc4pac exists for that
   and does it properly; this app coexists rather than competes.
6. **A `.dll` sitting in a subfolder is listed as if it loaded.** The
   app puts installed DLLs at the top of a root, but a DLL already deep in
   the tree (put there by hand, or by an install this app did not do) has
   no "on disk, never loaded" marker of its own - `modDepthLimit` is one
   number and cannot say "unlimited for `.dat`, zero for `.dll`".
7. **Wine and Proton are untested** for all four.
8. **macOS is unsupported** for all four.
9. **Executable patches and DirectDraw wrappers are out of scope** for
   SimCity 3000, deliberately.
10. **SimCity 3000's stock-building table covers the Unlimited edition
    only.** Another edition's bonus buildings would list as mods.
