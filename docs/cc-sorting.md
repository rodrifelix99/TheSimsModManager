# Sorting a large CC library

A user with 32,000 files in one Sims 2 Downloads folder asked for an
"I'm a CC addict, fix all my problems" button: sort the folder into
recolours, walls and floors, objects and so on, find the duplicates and
the older versions, and find the default replacements that overlap each
other.

Three of those four the app already answers. The fourth, and the one the
request is really about, is that it cannot say what a `.package` **is**.
This is what it would take, what the evidence for it is, the prior art
that already does most of it, and the constraint that stops it being a
button.

Evidence labels follow [simcity-support-validation.md](simcity-support-validation.md):
`VERIFIED_LOCAL` was read off a real install on the reference machine,
`VERIFIED_SOURCE` is stated by an established tool or the scene's own
documentation, `HYPOTHESIS` is plausible and uncorroborated,
`UNSUPPORTED` means no evidence was found and the code should do nothing.

---

## Prior art: this already exists

**Delphy's Download Organiser** does most of what was asked, and has since
2007. It detects "over 50 different package types", sorts into subfolders
by category, scans for orphans and duplicates (MD5), and its own
documentation claims it processes **32,000 files in under 10 minutes** -
which happens to be exactly the library that prompted this. `VERIFIED_SOURCE`

That is not a reason to drop the idea. It is a reason to be honest about
what the differentiator is, and to copy its taxonomy rather than invent
one:

- It is Windows .NET and last shipped **June 2017**. This app runs on
  macOS and Linux, where nothing equivalent exists.
- It is a separate tool the user has to find, trust and point at the
  right folder. The scan it needs is one this app already runs on launch.
- Whether it still works against the 2025 Legacy Collection is
  **unestablished** - the one Steam thread on the subject has zero
  replies. Worth checking before claiming it as a gap.

The honest framing for a release note is "the sorting Delphy's does, in
the app, on all three platforms", not "a new idea".

**SG Checker** (Pick'N'Mix Mods) is the reference for orphan detection and
carries the warning that matters: see below.

---

## The constraint: sorting changes load order

The Sims 2 loads Downloads **alphabetically, by ASCII, folders
included**. `VERIFIED_SOURCE` Where two packages carry the same resource,
the last one loaded wins, which is why the scene renames files with
leading `z`s to force a mod later.

Two details a folder-creating feature has to get right:

- **Folder names participate in the ordering.** The scene's own guidance
  is to put a mod that must load last in a folder that sorts behind the
  other, and to prefix folder names with `zzz` to push them later. So
  moving a file into a subfolder does change when it loads.
- **ASCII order is not alphabetical order.** Numbers sort before
  uppercase, uppercase before `_`, `_` before lowercase - so an uppercase
  `Z` sorts *before* a lowercase `a`. A folder named `ZZ_Overrides` loads
  **earlier** than one named `hair`, which is the opposite of what
  whoever named it intended. Any folder this app creates must use
  lowercase.

The user who asked for this wrote, in the same message, that their
conflicts are finally "in the correct load order". A button that
rearranged 32,000 files would break the one thing they had got right.

So this is not a button. It is a **proposal the user reads and accepts**,
it states the load-order consequence, the folder names it generates are
lowercase and numerically prefixed so the resulting order is deliberate,
and it is reversible. That matches the posture taken everywhere else
here: `keeperFirst` orders a duplicate set as a suggestion rather than a
verdict, and a conflict pair can be dismissed.

### Things that must not be moved - `VERIFIED_SOURCE`

- **Collections** (`Documents/EA Games/The Sims 2/Collections`) cannot be
  subfoldered at all.
- On base game and University only, sims, skintones and hair/clothing
  recolours cannot be subfoldered. Nightlife and later lifted this. The
  Legacy Collection is post-Nightlife, so this is a footnote, not a
  blocker.
- NTFS path length. The app already handles this in
  `claimInstallTarget`, and the sorter must route through it.

## What already exists in this app

| Need | Where it lives | State |
| --- | --- | --- |
| Exact duplicates | `core/duplicates.dart`, SHA-256 over the file | Shipped, behind `duplicate-scan` |
| Older vs newer versions | `ConflictReason.versionPair`, `parseModName` | Shipped |
| Packages overriding each other | `findResourceOverlaps` over DBPF keys | Shipped |
| Moving mods in bulk | `AppController.moveMods` + `_runBatch` | Shipped |
| Empty folders, chips, arrangement | `core/mod_folder.dart`, `madeFolders` | Shipped |
| **What a package contains** | nothing | **Missing** |

The gap is narrow and specific. Categorization today is
`GameAdapter.categoryForExtension`, keyed on the file extension alone,
and `Sims2Adapter` maps `.package` to `'Package'`
([sims_adapters.dart:1007](../lib/src/games/the_sims/sims_adapters.dart)).
Every one of those 32,000 mods is one category chip reading "Package".

Nothing new has to be read off the disk to fix that.
`PackageInsight.keys` already carries every resource's Type/Group/Instance
triple, taken from the index headers, which its own doc comment calls
"essentially free". Those keys exist to feed `findResourceOverlaps`, and
are thrown away otherwise.

---

## Evidence

Measured on the reference machine with this app's own `readDbpfIndex`,
against `Documents/EA Games/The Sims 2 Legacy/Downloads` (23 packages)
and `C:\Games\The Sims 2 Legacy Collection\Base` (761 packages, English
locale only).

The CC sample is small and mostly one creator. It is enough for the
content types it contains and not for the ones it does not.

### Sims 2 resource types are ASCII FourCCs - `VERIFIED_LOCAL`

`0x534C4F54` decodes as `SLOT`, `0x474C4F42` as `GLOB`, `0x4E524546` as
`NREF`, `0x42434F4E` as `BCON`, `0x54544142` as `TTAB`. Unknown types can
be labelled by decoding the four bytes rather than by extending a table,
which matters because the table cannot cover what the scene invents.

Not every type is ASCII. `TXMT` is `0x49596978`, `XOBJ` is `0xCCA8E925`.
Decode when it works, fall back to the table, then to the hex.

### The type histogram separates content cleanly - `VERIFIED_LOCAL`

| Package | Top types | Reading |
| --- | --- | --- |
| `DaniKH_DoctorDominionHair_MESH` | GMDC:2 GMND:2 SHPE:2 CRES:2 | mesh |
| `LiSR_Hair_KateMarshHair_DaniKH_MESH` | GMDC:3 GMND:3 SHPE:3 CRES:3 | mesh |
| `LiSR_Hair_KateMarshHair_DaniKH` | TXMT:18 BINX:7 3IDR:7 GZPS:6 TXTR:5 XHTN:1 | hair recolour |
| `danikh_deputyduncanhat` | TXMT:67 BINX:45 3IDR:45 TXTR:30 GZPS:26 XHTN:5 | hair recolour |
| `DaniKH_KH Eyes` | BINX:6 3IDR:6 STR#:6 IMG:6 TXMT:6 TXTR:6 | overlay, no GZPS |
| `KH_BuyMode_...Figurines` | BHAV:6 TXMT:6 SLOT:3 GLOB:3 CTSS:3 OBJD:3 | object |
| `gckp-clean-ui` | IMG:2815 `0x00000000`:192 | UI override |

Rules, in this order:

1. `GMDC` present and no `TXMT` -> **mesh**. Both `_MESH` files carried
   exactly `GMDC/GMND/SHPE/CRES` and nothing else.
2. `XOBJ` present and no `OBJD` -> **wall or floor** (below).
3. `GZPS` present -> **Body Shop content**; with `XHTN` -> **hair**,
   without -> **clothing or makeup**. `XHTN` appeared in every hair
   package and no other.
4. `OBJD` present -> **object**.
5. Dominated by `IMG` and type `0x00000000`, with no `OBJD`/`GZPS`/`GMDC`
   -> **UI**.

`0x2C1FD8A1` appears in the eyes and mask packages and is unidentified.
Probably an overlay XML (`XTOL` is a real type and fits), `HYPOTHESIS`,
and it should be drawn by its FourCC rather than guessed at.

### Walls and floors ride on XOBJ - `VERIFIED_LOCAL`

Previously marked `UNSUPPORTED`. Settled by scanning the game's own
pattern catalog, `TSData/Res/Catalog/Patterns/catpatterns.bundle.package`,
which is Maxis's walls and floors:

| Type | Count |
| --- | --- |
| `STR#` `0x53545223` | 530 |
| **`XOBJ` `0xCCA8E925`** | **476** |
| `0x2CB230B8` | 32 |
| `0x4DCADB7E` (`XFLR`) | 14 |
| `0xACA8EA06` | 8 |
| `PTBP` `0x50544250` | 1 |

`XWLL` does not appear in any source consulted and probably does not
exist. Walls and floors are both `XOBJ`, a CPF whose contents say which
it is.

**Consequence for the design**: the index-only scan can say "wall or
floor covering" for free, and **cannot tell a wall from a floor** without
reading the resource body. That is a deeper parse than
`scanPackage` does today. Ship the combined category first; splitting it
is a separate piece of work with its own cost.

### Default replacements collide with the game, custom content does not - `VERIFIED_LOCAL`

Building a key set from the 761 base-game packages (299,401 distinct
keys, DIR excluded) and intersecting each mod against it:

| Packages | Overlap with Maxis |
| --- | --- |
| 11 CC packages (all hair, meshes, eyes, hat, Body Shop) | **exactly 0** |
| 10 UI overrides | 7% to 100%, several at 100% |
| 2 object conversions | 48% and 55% |

The separation on "is it zero" is total: not low, zero. Every piece of
pure custom content touched nothing of the game's, and every override
touched something.

Two consequences:

- **Zero overlap is a safe test for "this is pure CC".**
- **A percentage threshold is not a safe test for "this is a default
  replacement".** The two object conversions land at ~50% because they
  carry Maxis behaviour resources at the same identity. Report the fact
  ("overrides 24 game resources"), not the inference.

The useful answer to the user's third ask follows and needs no new scan:
run `findResourceOverlaps` restricted to keys the game also owns, and you
have *which of my overrides fight each other over the same game
resource*, which is what they asked.

Cost: one pass over the game's packages per install, cacheable. Only Base
plus English locale was measured; EP1 to EP9 would add to it. Store the
keys packed rather than as strings.

### Orphan recolours: the link is 3IDR - `VERIFIED_SOURCE`

A recolour reaches its mesh through its **3IDR** (3D ID Referencing)
resource, which points at the `CRES`, `SHPE` and `TXMT` it needs. SG
Checker validates exactly that chain, per recolour type: `GZPS` and
`XMOL` against 3IDR plus the linked `CRES`/`SHPE`/`TXMT`, `XTOL` against
3IDR plus `TXMT`, `XFCH` against 3IDR plus `SHPE`. SimPE ships the same
idea as its "Recolor Basemesh Scanner", which reports found or not found
per file.

So the mechanism is established and this is implementable. **The warning
is more important than the mechanism**, and it downgrades my earlier
enthusiasm:

> "SG Checker tends to report 'false positives', ie things that work in
> game will be reported as having issues, mainly because there are
> 'broken' unused/redundant resources within the packages."

Its author also says it works better for objects and clothing than for
hairs and makeup - and hair is the bulk of what a large CC folder holds.
A tool by a respected modder, purpose-built for this, still gets it
wrong often enough to say so on the front page.

That sets the bar. This finding is presented as **"these recolours may be
missing their mesh, here is what each one is looking for"**, never as a
tick-box that offers to delete them. It does not feed
`ConflictReason`, and it must not be wired to the bulk remover.

---

## Design

A **Sort** screen, reachable from the library, per game, off the scan
that already runs.

1. **Group.** The library, grouped by classification, with counts. This
   alone answers "what is in my Downloads folder" and is worth shipping
   on its own, before any file moves.
2. **Findings.** Orphan candidates, mods overriding the game, overrides
   fighting over the same game resource. Each is a list, not a number,
   and the orphan list is worded as a suspicion.
3. **Plan.** A proposed folder layout, shown in full before anything
   moves, stating how many files move and that load order changes.
   Accepting it routes through `moveMods`, so `_runBatch` gives the
   throttled repaint, the cancel and the progress strip for free, and the
   existing repathing keeps the shop, ignored-conflict, tag and insight
   records attached.

Nothing is applied without the plan being accepted, and the plan is
reversible.

### Code

- **core**: classification is a stable English key resolved by `AppText`
  at draw time, the bargain `Mod.category` and `TriviaFact` already make.
  A new `core/mod_class.dart` for the vocabulary, and the Maxis key set
  behind an adapter hook so core never knows what Maxis is.
- **games**: the type tables and the rules live in
  `lib/src/games/the_sims/`, reached through one new adapter method that
  takes the mod and its `PackageInsight` and defaults to today's
  `categoryForExtension`. Every other game inherits the default and
  nothing changes for them.
- **Integration decision, open**: `Mod.category` is set at `toMod` time
  from the extension, while the insight arrives later in `refresh`.
  Either the list is rebuilt after the scan, or the controller gains a
  `categoryOf(mod)` that prefers the scanned answer. The second is a
  smaller blast radius, but the chip counts are built in `_setMods` and
  that call path needs tracing before committing to it.
- **Scale**: `PackageInsight.keys` is dropped above `maxRetainedKeys`
  (8192), so a merged collection classifies from its content counts
  rather than its keys, or not at all. Delphy's does 32,000 files in ten
  minutes single-threaded; the existing scan is isolate-batched and
  already handles libraries this size.

### Rollout

Behind its own flag, defaulting on, alongside `duplicate-scan` and
`conflict-detection`. It moves files, so it needs a switch.

Events carry counts, the game id and the classification only. Never a
mod name, a folder name or a creator: what someone's CC folder holds is
as personal as which packs they own, which is why pack requirements send
no events at all.

## Out of scope

- Telling a wall from a floor. Needs the CPF body, not the index.
- Deciding which of two overlapping defaults should win. The app can say
  they fight; which one the player wants is not knowable from the bytes.
- Deleting orphan candidates. The false-positive rate above is the whole
  reason.
- Anything for another game. The rules are Sims 2 DBPF specifics. The
  screen is game-agnostic, the classifier is not.

## Sources

- [Game Help: Organizing Custom Content](http://simswiki.info/wiki.php?title=Game_Help%3AOrganizing_Custom_Content) - subfolder rules, Collections, per-EP restrictions
- [Forcing the load order of mods](https://sims2tutorials.tumblr.com/post/669944771461201920/forcing-the-load-order-of-mods) - ASCII ordering, the uppercase-Z trap
- [SG Checker](http://www.picknmixmods.com/Sims2/Notes/SgChecker/SgChecker.html) - 3IDR link validation and its false positives
- [DBPF Compare](http://www.picknmixmods.com/Sims2/Notes/DbpfCompare/DbpfCompare.html) - resource abbreviation list
- [List of Sims 2 Formats by Type](https://simswiki.info/wiki.php?title=List_of_Formats_by_Type) - hex type IDs
- [Delphy's Download Organiser](https://simswiki.info/wiki.php?title=Delphy's_Download_Organiser) and [General Usage](https://simswiki.info/wiki.php?title=Delphy's_Download_Organiser/General_Usage) - prior art
