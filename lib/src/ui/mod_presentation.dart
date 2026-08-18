import 'package:intl/intl.dart' show DateFormat;
import 'package:path/path.dart' as p;

import '../core/game.dart';
import '../core/mod.dart';
import '../core/mod_folder.dart';
import '../core/mod_name.dart';
import 'app_controller.dart';
import 'game_theme.dart';
import 'l10n.dart';

/// How a mod (and its game) is written out wherever one is shown: titles,
/// versions, dates, chip labels. Shared by the library and the detail
/// screen rather than homed in either one's file, so neither has to
/// import the other to caption a mod.

/// The theme's flavor label next to the game name ("Modern · 2014"),
/// translated. Themes without one (a game with no bespoke palette yet)
/// fall back to the game's own series and year.
String eraLabel(L l, GameTheme t, Game game) {
  final key = t.eraKey;
  final name = key == null ? game.series : l.eraName(key);
  final detail = t.eraDetail ?? game.year?.toString();
  return detail == null ? name : '$name · $detail';
}

/// Label for a category filter chip. Categories travel through the app as
/// stable English keys (they key analytics and the adapters' taxonomy),
/// so they are only translated at the moment they are drawn.
String categoryChipLabel(L l, String category) =>
    category == 'All' ? l.filterAll : l.categoryName(category);

/// Label for a folder filter chip. Folders travel as '/'-joined keys
/// ('cc/defaults'); spaced out, a nested one reads as the one place it
/// is rather than as a path the user has to parse.
String folderChipLabel(String folder) => folderSegments(folder).join(' / ');

/// Human-friendly display title: extension and version token stripped,
/// creator naming conventions cleaned up
/// ("UICheatsExtension_v1.36.ts4script" -> "UI Cheats Extension").
String modTitle(Mod mod) => humanizeModName(parseModName(mod.name).strippedName);

/// The version guessed from the file name (`v1.36`, `2024-05-01`), shown
/// as its own quieter text next to the title; `null` when the name
/// carries none. The title above has the token stripped so the version
/// never shows twice.
String? modVersion(Mod mod) => parseModName(mod.name).versionLabel;

/// The "by author" slot of the design: real files don't carry an author,
/// so show where the file lives instead.
String modSubtitle(L l, AppController c, Mod mod) {
  final root = c.modsDir?.path;
  if (root != null) {
    final folder = p.dirname(mod.path);
    final rel = p.relative(folder, from: root);
    // One step out is a sibling of the mods folder and reads perfectly -
    // the Sims 3 framework's own `..\Overrides` is where a lot of
    // libraries keep half their mods. Further out is one of the game's
    // own folders, six levels up and across, and the route to it reads
    // as a row of dots where a folder name should be; there, say where
    // the file actually is instead.
    if (p.split(rel).where((s) => s == '..').length > 1) {
      return l.modInFolder(folder);
    }
    if (rel != '.') return l.modInFolder(rel);
  }
  return l.modInModsFolder;
}

/// The file's modification date, written the way the current language
/// writes dates. Falls back to English if intl was never handed the
/// locale's date symbols (widget tests, which don't run main()).
String modDate(Mod mod) {
  final d = mod.modifiedAt;
  if (d == null) return '';
  try {
    return DateFormat.yMMMd().format(d);
  } catch (_) {
    return DateFormat.yMMMd('en').format(d);
  }
}
