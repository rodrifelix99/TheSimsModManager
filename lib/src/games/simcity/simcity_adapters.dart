/// Adapters for the four moddable SimCity games.
///
/// The franchise is not one game five times over: SimCity 4 loads a
/// deep, order-sensitive Plugins tree from two roots at once, SimCity
/// (2013) loads a flat folder of packages, SimCity 3000 keeps custom
/// buildings in a folder it also ships its own in, and SimCity
/// Societies has no packaged-mod format anyone has documented. So the
/// four are written apart and share only what they really share -
/// finding the install ([simcity_install.dart]) and the folder-based
/// list/install/enable/disable every game in this app has.
///
/// Everything here is evidence-backed; where the evidence stops, the
/// adapter stops too and `docs/simcity-support-validation.md` says so.
library;

import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/documents_dir.dart';
import '../../core/game.dart';
import '../../core/game_adapter.dart';
import '../../core/install_destination.dart';
import '../../core/mod.dart';
import '../../core/mod_catalog.dart';
import 'sc4pac.dart';
import 'sc4pac_channel.dart';
import 'simcity_install.dart';

/// Shared plumbing for the SimCity games whose mods folder is found by
/// locating the install first.
///
/// [modsSegments] is the folder below the install root, or empty when
/// the mods folder lives under Documents instead and the subclass says
/// where.
abstract class SimCityAdapter extends FolderBasedGameAdapter {
  const SimCityAdapter({this.searchOverride, this.documentsOverride});

  /// Test hook: pretend these are the installs on this machine, skipping
  /// the registry and the disk walk entirely.
  final List<Directory>? searchOverride;

  /// Test hook: pretend this is the user's Documents folder.
  final Directory? documentsOverride;

  /// Where the registry names this game.
  List<RegistryInstallHint> get registryHints;

  /// Folder names a launcher would have used, tried under the known
  /// launcher roots. Never a criterion on its own - a folder still has
  /// to pass [looksLikeInstall].
  List<String> get installFolderNames;

  /// Whether [dir] really is this game, told by files it cannot run
  /// without.
  Future<bool> looksLikeInstall(Directory dir);

  /// The mods folder inside an install, as path segments. Empty when
  /// the install root itself is it.
  List<String> get modsSegments => const [];

  Future<List<Directory>> installs() => findSimCityInstalls(
        cacheKey: game.id,
        hints: registryHints,
        signature: looksLikeInstall,
        folderNames: installFolderNames,
        searchOverride: searchOverride,
      );

  @override
  Future<Directory?> findGameFolder() async {
    final found = await installs();
    return found.isEmpty ? null : found.first;
  }

  @override
  Future<List<Directory>> findModsDirectoryCandidates() async {
    final found = <String, Directory>{};
    for (final install in await installs()) {
      final dir = Directory(p.joinAll([install.path, ...modsSegments]));
      try {
        if (!await dir.exists()) continue;
      } catch (_) {
        continue;
      }
      found[p.canonicalize(dir.path)] = dir;
    }
    return found.values.toList();
  }

  @override
  Future<String?> defaultModsPath() async {
    final install = await findGameFolder();
    if (install == null) return null;
    return p.joinAll([install.path, ...modsSegments]);
  }
}

// ---------------------------------------------------------------------
// SimCity 4
// ---------------------------------------------------------------------

/// SimCity 4 (Deluxe, and the base game with or without Rush Hour).
///
/// Three things separate it from every other game in this app, and all
/// three are load-bearing:
///
/// **Two Plugins roots, both live.** The reference install's
/// `Apps\SimCity 4.ini` says so itself - `[Directories] PlugIn=..\Plugins\` -
/// and the modern DLL plugins' own READMEs name the installation
/// directory's Plugins folder, while the community and sc4pac use
/// `Documents\SimCity 4\Plugins`. The user one is the mods folder,
/// because it is the writable one; the install one is an extra root
/// ([extraModsDirectories]) so what is in it is visible rather than
/// invisible.
///
/// **Path and file name are load order.** The game reads the tree
/// alphabetically, which is why sc4pac installs into numbered category
/// folders and why overrides are named `zzz...`. So an install here
/// must never flatten an archive, tidy a name or re-sort a folder: the
/// structure a download arrives with is a functional part of it. The
/// shared archive install already preserves it; nothing in this adapter
/// undoes that.
///
/// **A DLL only loads from the top of a root.** Every one of the
/// 0xC0000054 plugins says "the top-level of the Plugins folder", and
/// sc4pac proves it from the other end by symlinking its DLLs up there
/// out of the versioned folder it stores them in. A `.dll` this app
/// installs therefore goes to the top of the root, never into a
/// subfolder alongside the rest of a download.
class SimCity4Adapter extends SimCityAdapter {
  const SimCity4Adapter({
    super.searchOverride,
    super.documentsOverride,
    this.sc4pacProfilesOverride,
  });

  /// Test hook: pretend these are the sc4pac profiles on this machine.
  final List<Sc4pacProfile>? sc4pacProfilesOverride;

  @override
  Game get game => const Game(
        id: 'simcity4',
        name: 'SimCity 4',
        series: simCitySeries,
        year: 2003,
      );

  /// `.dat` is the workhorse - every DBPF plugin, from a single lot to
  /// the 366 MB Network Addon Mod controller. `.sc4lot`, `.sc4model`
  /// and `.sc4desc` are the same container under the names the Lot
  /// Editor and the BAT write. `.sc4` is the older spelling of the
  /// same. `.dll` is a GZCOM plugin.
  @override
  Set<String> get modFileExtensions =>
      const {'.dat', '.sc4lot', '.sc4model', '.sc4desc', '.sc4', '.dll'};

  /// A DLL plugin's settings file, which its README tells the user to
  /// copy in beside the DLL and which the plugin then reads by name.
  /// Not a mod: listing `SC4AutoSave.ini` as something to enable and
  /// disable on its own is how a plugin ends up half switched off.
  @override
  Set<String> get companionFileExtensions => const {'.ini'};

  /// Every one of these plugins writes a log beside itself the first
  /// time the game loads it - the README of each says so, and it is how
  /// they are meant to be troubleshot. Found by the end-to-end cycle:
  /// uninstalling the plugin used to leave the log behind, invisible to
  /// the library because `.log` is not a mod extension, and the folder
  /// slowly fills with records of plugins that are no longer there.
  @override
  Set<String> get generatedFileExtensions => const {'.log'};

  @override
  String get setupHelpKey => 'simcity4';

  @override
  Map<String, String> get categoryByExtension => const {
        '.dat': 'Package',
        '.sc4': 'Package',
        '.sc4lot': 'Lot',
        '.sc4model': 'Model',
        '.sc4desc': 'Description',
        '.dll': 'Script',
      };

  /// The sc4pac channels, which are this game's real index of mods.
  ///
  /// Browsed and credited, never mirrored - see `sc4pac_channel.dart`.
  /// The other three SimCity games get none, because nobody curates one
  /// for them and an empty shelf is a worse answer than no shelf.
  @override
  List<ModCatalog> catalogs() =>
      [
        for (final info in sc4pacDefaultChannels)
          Sc4pacChannel(info, gameId: game.id),
      ];

  @override
  List<RegistryInstallHint> get registryHints => simCity4Hints;

  @override
  List<String> get installFolderNames => const [
        'SimCity 4 Deluxe',
        'SimCity 4',
        'SimCity 4 Deluxe Edition',
      ];

  /// The executable and its own ini, both in `Apps`. The ini is what
  /// names the Plugins folder, so an install without it is one this
  /// adapter has nothing to say about anyway.
  @override
  Future<bool> looksLikeInstall(Directory dir) =>
      holdsAny(dir, const ['Apps/SimCity 4.exe', 'Apps/SimCity4.exe']);

  /// The mods folder is the *user* one under Documents, not a folder
  /// inside the install: it is the writable one, it is where the
  /// community and sc4pac put things, and it survives the game being
  /// reinstalled.
  @override
  Future<List<Directory>> findModsDirectoryCandidates() async {
    final found = <String, Directory>{};
    void keep(Directory dir) {
      found.putIfAbsent(p.canonicalize(dir.path), () => dir);
    }

    // sc4pac's own record of where the user actually installs comes
    // first. It is the only reliable way to find a custom user
    // directory - the `-UserDir` launch parameter lives in a shortcut
    // the app cannot read, and a profile pointing somewhere else is the
    // user telling us so in writing.
    for (final profile in await _profiles()) {
      final dir = Directory(profile.pluginsRoot);
      if (await _exists(dir)) keep(dir);
    }
    for (final documents in await _documentsRoots()) {
      final dir = Directory(p.join(documents.path, 'SimCity 4', 'Plugins'));
      if (await _exists(dir)) keep(dir);
    }
    // Last, and only as a candidate the user can pick: the install's
    // own Plugins folder is a real root, but it is usually under
    // Program Files and proposing it as the default would make every
    // install an elevation problem.
    for (final install in await installs()) {
      final dir = Directory(p.join(install.path, 'Plugins'));
      if (await _exists(dir)) keep(dir);
    }
    return found.values.toList();
  }

  /// Documents/SimCity 4/Plugins, whether or not it exists yet - the
  /// game makes it on first run and the app can offer to make it early.
  @override
  Future<String?> defaultModsPath() async {
    for (final profile in await _profiles()) {
      return profile.pluginsRoot;
    }
    final documents = await _documentsRoots();
    if (documents.isEmpty) return null;
    return p.join(documents.first.path, 'SimCity 4', 'Plugins');
  }

  /// The install's own Plugins folder, when the mods folder is the user
  /// one. Both are read by the game at once, so a library that showed
  /// only one of them would be answering a different question than the
  /// one the player is asking.
  @override
  Future<List<Directory>> extraModsDirectories(Directory modsDir) async {
    final extras = <String, Directory>{};
    for (final install in await installs()) {
      final dir = Directory(p.join(install.path, 'Plugins'));
      if (p.equals(dir.path, modsDir.path)) continue;
      if (p.isWithin(modsDir.path, dir.path)) continue;
      if (p.isWithin(dir.path, modsDir.path)) continue;
      if (!await _exists(dir)) continue;
      extras.putIfAbsent(p.canonicalize(dir.path), () => dir);
    }
    return extras.values.toList();
  }

  /// The library minus everything sc4pac owns.
  ///
  /// Two separate wrongs this avoids, and the second is the one that
  /// would have cost a user real files. sc4pac unpacks each package
  /// into a versioned `*.sc4pac` folder, so left alone the library
  /// grows a folder chip per package and a Delete button that breaks
  /// sc4pac's lock file. And because SimCity 4 only loads a DLL from
  /// the top of a root, sc4pac symlinks its DLL plugins up there - so
  /// the sweep sees the link and the target, the duplicate scan hashes
  /// both, finds them byte-identical, and offers to delete "the spare
  /// copy". On the reference machine that is two plugins shown as four
  /// and two real files one click from deletion.
  ///
  /// So the manifest is read and the paths it names are held out. What
  /// cannot be read falls back to the folder suffix, which is sc4pac's
  /// own and which nothing else writes.
  @override
  Future<List<Mod>> listMods(Directory modsDir) async {
    final mods = await super.listMods(modsDir);
    final owners = await _ownersFor(modsDir);
    if (owners.isEmpty) return mods;
    return [
      for (final mod in mods)
        if (!_isExternallyManaged(mod.path, owners)) mod,
    ];
  }

  /// Whether [path] belongs to a manager that is not this one.
  bool _isExternallyManaged(String path, List<Sc4pacProfile> owners) {
    for (final profile in owners) {
      if (!p.isWithin(profile.pluginsRoot, path)) continue;
      final relative = p.relative(path, from: profile.pluginsRoot);
      if (profile.isEmpty) {
        // A profile whose lock file would not parse still tells us
        // which folder it manages, and the suffix does the rest.
        if (looksSc4pacManaged(relative)) return true;
        continue;
      }
      if (ownsPath(profile, relative)) return true;
      // Belt and braces: a package installed after the lock file was
      // last written is still not ours.
      if (looksSc4pacManaged(relative)) return true;
    }
    return false;
  }

  /// The profiles that manage [modsDir] or a folder holding it, plus
  /// the older layout that keeps its records in the Plugins folder.
  Future<List<Sc4pacProfile>> _ownersFor(Directory modsDir) async {
    final owners = <Sc4pacProfile>[];
    for (final profile in await _profiles()) {
      if (p.equals(profile.pluginsRoot, modsDir.path) ||
          p.isWithin(profile.pluginsRoot, modsDir.path) ||
          p.isWithin(modsDir.path, profile.pluginsRoot)) {
        owners.add(profile);
      }
    }
    final beside = await readSc4pacProfileBeside(modsDir);
    if (beside != null) owners.add(beside);
    return owners;
  }

  Future<List<Sc4pacProfile>> _profiles() async =>
      sc4pacProfilesOverride ?? await readSc4pacProfiles();

  /// A DLL plugin lifted to the top of the mods folder, because that is
  /// the only place SimCity 4 loads one from.
  ///
  /// Downloads ship them inside a folder of their own - the plugin's
  /// name, or `Windows/`, or the version - and unpacked as they arrive
  /// they are files the game never opens, with nothing on screen to say
  /// so. Its settings file goes with it: they find each other by name
  /// and in the same folder.
  ///
  /// Only `.dll` moves. Everything else stays exactly where the archive
  /// put it, because for this game the folder a `.dat` sits in is its
  /// load order and rearranging one is a change to the mod.
  Future<List<Mod>> _liftPlugins(Directory modsDir, List<Mod> mods) async {
    final lifted = <Mod>[];
    for (final mod in mods) {
      if (p.extension(enabledPathOf(mod.path)).toLowerCase() != '.dll' ||
          p.equals(p.dirname(mod.path), modsDir.path)) {
        lifted.add(mod);
        continue;
      }
      final companions = await companionsOf(mod.path);
      Mod moved;
      try {
        moved = await moveMod(mod, modsDir);
      } on ModActionException catch (e) {
        if (e.reason != ModActionFailure.nameTaken) {
          lifted.add(mod);
          continue;
        }
        // Something of that name is already up there - an older copy of
        // the same plugin, almost always, since this game tells its
        // plugins apart by file name alone. Reinstalling an archive
        // already overwrites elsewhere in this app rather than leaving a
        // second copy - see install_path.dart - and here the
        // alternative isn't a duplicate, it's the update sitting
        // somewhere SimCity 4 will never load a DLL from. So the stale
        // top-level copy is replaced too, and only a lock or a
        // permissions refusal leaves the reinstall stranded in its
        // subfolder the way every name collision used to.
        try {
          final stale = File(p.join(modsDir.path, p.basename(mod.path)));
          if (await stale.exists()) await stale.delete();
          moved = await moveMod(mod, modsDir);
        } catch (_) {
          lifted.add(mod);
          continue;
        }
      }
      for (final companion in companions) {
        final target = p.join(modsDir.path, p.basename(companion.path));
        if (await File(target).exists()) continue;
        try {
          await renameModFile(companion, target);
        } catch (_) {
          // The plugin is where the game reads it; a settings file
          // that would not follow is worth a default, not a failure.
        }
      }
      lifted.add(moved);
    }
    return lifted;
  }

  @override
  Future<List<Mod>> installArchive(Directory modsDir, File archive,
          {InstallPlacement placement = const SortedPlacement(),
          Set<String> placed = const {}}) async =>
      _liftPlugins(
          modsDir,
          await super.installArchive(modsDir, archive,
              placement: placement, placed: placed));

  @override
  Future<List<Mod>> installFolder(Directory modsDir, Directory source,
          {InstallPlacement placement = const SortedPlacement(),
          Set<String> placed = const {}}) async =>
      _liftPlugins(
          modsDir,
          await super.installFolder(modsDir, source,
              placement: placement, placed: placed));

  /// SimCity 4 reads its Plugins tree however deep it goes: the Network
  /// Addon Mod ships four levels on the reference machine and loads.
  @override
  Future<int?> modDepthLimit(Directory modsDir) async => null;

  Future<List<Directory>> _documentsRoots() async =>
      documentsOverride != null ? [documentsOverride!] : await documentsDirs();
}

// ---------------------------------------------------------------------
// SimCity (2013)
// ---------------------------------------------------------------------

/// SimCity (2013), with or without Cities of Tomorrow.
///
/// Mods are DBPF `.package` files and there are two folders the game
/// reads them from: `SimCityData`, which is where its own eleven
/// packages live, and `SimCityUserData\Packages`, which is empty on a
/// fresh install and is the player's. Only the second is managed.
/// Sweeping `SimCityData` would put four hundred megabytes of Maxis's
/// own content in the library with a Delete button beside it, and there
/// is nothing on disk that says which of those files is the game's -
/// the same reason The Sims 1's `GameData\Global` is never swept.
///
/// That has a real cost and it is written down rather than hidden: a
/// mod whose readme says it must load before the game's own packages
/// has to go in `SimCityData` and be named to sort before `SimCity_`,
/// and this app will not put it there. See
/// `docs/simcity-support-validation.md`.
class SimCity2013Adapter extends SimCityAdapter {
  const SimCity2013Adapter({super.searchOverride});

  @override
  Game get game => const Game(
        id: 'simcity2013',
        name: 'SimCity',
        series: simCitySeries,
        year: 2013,
      );

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  String get setupHelpKey => 'simcity2013';

  @override
  List<RegistryInstallHint> get registryHints => simCity2013Hints;

  @override
  List<String> get installFolderNames => const ['SimCity', 'SimCity 2013'];

  /// The executable plus the data folder. Both, because a folder called
  /// `SimCity` under `EA Games` could as easily be SimCity 4's.
  @override
  Future<bool> looksLikeInstall(Directory dir) =>
      holdsAll(dir, const ['SimCity/SimCity.exe', 'SimCityData']);

  @override
  List<String> get modsSegments => const ['SimCityUserData', 'Packages'];

  /// Whether Cities of Tomorrow is installed, told by the expansion's
  /// own data package beside the base game's. Read rather than assumed:
  /// the expansion is a download rather than a folder of its own.
  Future<bool> hasCitiesOfTomorrow() async {
    final install = await findGameFolder();
    if (install == null) return false;
    return holdsAny(install, const [
      'SimCityData/SimCityDataEP1.package',
      'SimCityData/version_data_cot.txt',
    ]);
  }

  /// The player's own Packages folder is flat in practice, but the game
  /// is not documented to stop at a depth and nothing here needs to
  /// claim it does.
  @override
  Future<int?> modDepthLimit(Directory modsDir) async => null;
}

// ---------------------------------------------------------------------
// SimCity 3000
// ---------------------------------------------------------------------

/// The buildings SimCity 3000 Unlimited ships in its own `Buildings`
/// folder, so a library of custom content does not open with a Delete
/// button next to Maxis's.
///
/// Read off a clean GOG install of SimCity 3000 Unlimited, where all
/// seventeen carry the installer's own timestamp. A file this table
/// does not know is listed, which is the right way round to be wrong:
/// a stock building of an edition nobody checked shows up as a mod,
/// rather than a player's own building quietly disappearing.
const simCity3000StockBuildings = <String>{
  'den burg bruges.bld',
  'dupont house.bld',
  'garvey plaza.bld',
  'guesthouse building.bld',
  'headquarters.bld',
  'hitech lab.bld',
  'hotel splash.bld',
  'kankakee jr. high school.bld',
  'longview park.bld',
  'maxis towers.bld',
  'north shore cannery.bld',
  'northeast nonwovens.bld',
  'proton building.bld',
  'the joneses.bld',
  'trash & burn.bld',
  'tutorial house.bld',
  'zweikky unpainted.bld',
};

/// SimCity 3000 and SimCity 3000 Unlimited.
///
/// The one thing this game really loads from a folder is custom
/// buildings: `.bld` files made with the Building Architect Tool, which
/// go in `Buildings` beside the game's own. That folder is the mods
/// folder, with the shipped buildings held out by name
/// ([simCity3000StockBuildings]).
///
/// What this adapter deliberately does **not** do is the other half of
/// the SimCity 3000 scene. Its resolution and compatibility fixes patch
/// `SC3U.exe` itself, and a binary patch is not a file to enable and
/// disable: doing it safely needs the exact edition and build
/// identified, the input bytes hashed, the patch verified, the original
/// kept and the whole thing refused on an executable nobody recognises.
/// None of that is in this app, so those mods are reported as manual
/// rather than pretended at. The `ddraw.dll` wrappers people put in
/// `Apps` are the same class of thing and are left alone for the same
/// reason.
class SimCity3000Adapter extends SimCityAdapter {
  const SimCity3000Adapter({super.searchOverride});

  @override
  Game get game => const Game(
        id: 'simcity3000',
        name: 'SimCity 3000',
        series: simCitySeries,
        year: 1999,
      );

  @override
  Set<String> get modFileExtensions => const {'.bld'};

  @override
  String get setupHelpKey => 'simcity3000';

  @override
  Map<String, String> get categoryByExtension => const {'.bld': 'Building'};

  @override
  List<RegistryInstallHint> get registryHints => simCity3000Hints;

  @override
  List<String> get installFolderNames => const [
        'SimCity 3000 Unlimited',
        'SimCity 3000',
        'SimCity3000Unlimited',
      ];

  /// Either edition's executable, in the `Apps` folder both keep it in.
  /// The folder name says nothing: the reference install is GOG's, at
  /// `C:\Games\SimCity 3000 Unlimited`, and a disc install is localized.
  @override
  Future<bool> looksLikeInstall(Directory dir) =>
      holdsAny(dir, const ['Apps/SC3U.exe', 'Apps/SC3.exe', 'Apps/Baapp.exe']);

  @override
  List<String> get modsSegments => const ['Buildings'];

  /// Whether this is the Unlimited edition, which shipped the Building
  /// Architect Plus and the extra scenarios. Told by its own
  /// executable, not by the folder name.
  Future<bool> isUnlimited() async {
    final install = await findGameFolder();
    if (install == null) return false;
    return holdsAny(install, const ['Apps/SC3U.exe']);
  }

  /// `Buildings` is flat - the game does not walk into subfolders of
  /// it - so a building filed into one is on disk and never loaded.
  @override
  Future<int?> modDepthLimit(Directory modsDir) async => 0;

  @override
  Future<List<Mod>> listMods(Directory modsDir) async {
    final mods = await super.listMods(modsDir);
    return [
      for (final mod in mods)
        if (!simCity3000StockBuildings.contains(mod.name.toLowerCase())) mod,
    ];
  }
}

// ---------------------------------------------------------------------
// SimCity Societies
// ---------------------------------------------------------------------

/// SimCity Societies, with or without Destinations.
///
/// The least-verified of the four, and it says so. Societies was built
/// to be edited rather than to load packaged mods: its gameplay is C#
/// in `Data\Scripts` and XML in `Data\XMLDb`, both inside the install
/// and both entirely the game's own, and the "online exchange" its
/// press material promised never outlived the game.
///
/// The one piece of hard evidence for a user content folder is the
/// game's own `PackageInstaller.exe`, which carries the literal string
/// `SimCity Societies\Import\`, reads its install path out of the same
/// registry key this adapter does, and asks Windows for the Documents
/// folder. That folder is the mods folder here. Its sibling `Export`
/// exists on the reference machine, which is what the pair is for.
///
/// The extension is `.SCSPack`, and that is the game's own word for it
/// rather than a guess. `SimCitySocieties.exe` carries, in one run of
/// UTF-16 strings, its whole content configuration:
///
/// ```text
/// \*.SCSPack   FileExtension/Package   Directory/Export   Directory/Import
/// ```
///
/// `.package` appears nowhere in the binary. An earlier version of this
/// adapter accepted `.package` on the reasoning that a tool called
/// Package Installer probably installs packages; it would have left a
/// real player's downloads invisible in the library, which is the one
/// failure this whole screen exists to prevent. The lesson is the
/// obvious one: the file that reads the format is the source worth
/// asking.
///
/// Nothing in `Data` is ever touched, listed or offered for deletion.
class SimCitySocietiesAdapter extends SimCityAdapter {
  const SimCitySocietiesAdapter({super.searchOverride, super.documentsOverride});

  @override
  Game get game => const Game(
        id: 'simcitysocieties',
        name: 'SimCity Societies',
        series: simCitySeries,
        year: 2007,
      );

  @override
  Set<String> get modFileExtensions => const {'.scspack'};

  @override
  Map<String, String> get categoryByExtension =>
      const {'.scspack': 'Package'};

  @override
  String get setupHelpKey => 'simcitysocieties';

  @override
  List<RegistryInstallHint> get registryHints => simCitySocietiesHints;

  @override
  List<String> get installFolderNames => const [
        'SimCity Societies',
        'SimCity Societies Deluxe',
      ];

  @override
  Future<bool> looksLikeInstall(Directory dir) => holdsAll(
      dir, const ['SimCitySocieties.exe', 'Data']);

  /// Whether Destinations is installed. It goes *inside* the base
  /// game's folder rather than beside it, with an executable and a
  /// script library of its own.
  Future<bool> hasDestinations() async {
    final install = await findGameFolder();
    if (install == null) return false;
    return holdsAny(install, const [
      'SimCity Societies Destinations/SCSDestinations.exe',
      'SimCity Societies Destinations/SCSLibxp1.dll',
    ]);
  }

  /// The Import folder under Documents, whatever the install is - it is
  /// the user's, and it is what the game's own package installer writes
  /// to.
  @override
  Future<List<Directory>> findModsDirectoryCandidates() async {
    final found = <String, Directory>{};
    for (final documents in await _documentsRoots()) {
      final dir =
          Directory(p.join(documents.path, 'SimCity Societies', 'Import'));
      try {
        if (!await dir.exists()) continue;
      } catch (_) {
        continue;
      }
      found.putIfAbsent(p.canonicalize(dir.path), () => dir);
    }
    return found.values.toList();
  }

  @override
  Future<String?> defaultModsPath() async {
    final documents = await _documentsRoots();
    if (documents.isEmpty) return null;
    return p.join(documents.first.path, 'SimCity Societies', 'Import');
  }

  Future<List<Directory>> _documentsRoots() async =>
      documentsOverride != null ? [documentsOverride!] : await documentsDirs();
}

Future<bool> _exists(Directory dir) async {
  try {
    return await dir.exists();
  } catch (_) {
    return false;
  }
}
