import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/app_message.dart';
import '../../core/game_pack.dart';

/// The Sims 4's packs: what is installed, and which ones the game has been
/// told not to load.
///
/// Both halves are the game's own. Packs are folders sitting beside `Game`
/// and `Data` in the install (`EP01`, `GP04`, `SP62`), and since patch
/// 1.117 the game itself can switch them off from Game Options - which it
/// records as `packstoskipmount` in `UserSetting.ini`, next to the Mods
/// folder. Writing that same line is how this app disables a pack: nothing
/// on disk moves, no launcher is involved, and the game's own Pack
/// Selection screen shows exactly what the app shows. Renaming pack
/// folders would do the job too and is what the community did before 2025,
/// but the EA App and Steam both treat a renamed folder as damage and
/// repair it.
///
/// Everything here is best-effort: these files come off a player's disk.

/// A pack's folder name: two letters for the tier, two digits for the
/// release. `FP01` is the one free pack.
final _packFolder = RegExp(r'^(EP|GP|SP|FP)(\d{2})$', caseSensitive: false);

/// `packstoskipmount`, wherever in the file it sits. Read wider than it is
/// written (see [applyPacksToSkip], which only ever inserts into
/// `[usersetting]`): another tool may have put it somewhere else, and the
/// value still says which packs are off.
final _skipLine = RegExp(
  r'^([ \t]*packstoskipmount[ \t]*=)[^\r\n]*',
  multiLine: true,
  caseSensitive: false,
);

/// The section the game keeps its own non-per-account settings in. Its
/// keys are plain `key = value`, unlike `[uiaccountsettings]`, whose every
/// key carries an account id and a type.
final _userSettingSection = RegExp(
  r'^[ \t]*\[usersetting\][ \t]*\r?\n',
  multiLine: true,
  caseSensitive: false,
);

/// The game's own title in front of a pack name, in any of the languages
/// the manifest ships: "The Sims™ 4 Get to Work", "Die Sims™ 4 An die
/// Arbeit", "The Sims 4™ Holiday Celebration Pack". Everything up to the
/// 4 goes, along with whatever separator follows it - including the
/// fullwidth colon the Chinese titles use.
final _gameTitlePrefix = RegExp(r'^.*?Sims\s*™?\s*4\s*™?\s*[:：\-–]?\s*');

final _gameTitleTag =
    RegExp(r'<gameTitle\s+locale="([A-Za-z_]+)"\s*>([^<]*)</gameTitle>');

/// Codes the game reads as stuff packs rather than kits. Both ship as
/// `SP`, and only the number tells them apart: the first eighteen were
/// stuff packs, then EA switched to kits and has released just two stuff
/// packs since. An unknown `SP` is therefore a kit - which is what every
/// new one has been since 2023, and a wrong label on a pack this app has
/// never heard of costs the user a word, not a feature.
bool _isStuffPack(int number) => number <= 18 || number == 46 || number == 49;

GamePackKind sims4PackKind(String code) {
  final match = _packFolder.firstMatch(code);
  if (match == null) return GamePackKind.stuff;
  final number = int.tryParse(match.group(2)!) ?? 0;
  return switch (match.group(1)!.toUpperCase()) {
    'EP' => GamePackKind.expansion,
    'GP' => GamePackKind.gamePack,
    'FP' => GamePackKind.free,
    _ => _isStuffPack(number) ? GamePackKind.stuff : GamePackKind.kit,
  };
}

/// Whether [name] looks like a folder holding one of this game's packs.
bool isSims4PackCode(String name) => _packFolder.hasMatch(name);

/// Every pack code the app knows a name for, so a Steam install - which
/// ships no per-pack manifests, its packs arriving as depots unpacked
/// straight into the game folder - still reads as names rather than
/// codes. Kept in EA's own spelling, which is inconsistent about the
/// "Stuff"/"Kit" suffix on purpose: this is what the store calls them.
///
/// A code missing here is drawn as itself, so a kit released after this
/// build still lists, still toggles, and still says how big it is.
const sims4PackNames = <String, String>{
  'EP01': 'Get to Work',
  'EP02': 'Get Together',
  'EP03': 'City Living',
  'EP04': 'Cats & Dogs',
  'EP05': 'Seasons',
  'EP06': 'Get Famous',
  'EP07': 'Island Living',
  'EP08': 'Discover University',
  'EP09': 'Eco Lifestyle',
  'EP10': 'Snowy Escape',
  'EP11': 'Cottage Living',
  'EP12': 'High School Years',
  'EP13': 'Growing Together',
  'EP14': 'Horse Ranch',
  'EP15': 'For Rent',
  'EP16': 'Lovestruck',
  'EP17': 'Life & Death',
  'EP18': 'Businesses & Hobbies',
  'EP19': 'Enchanted by Nature',
  'EP20': 'Adventure Awaits',
  'EP21': 'Royalty & Legacy',
  'FP01': 'Holiday Celebration Pack',
  'GP01': 'Outdoor Retreat',
  'GP02': 'Spa Day',
  'GP03': 'Dine Out',
  'GP04': 'Vampires',
  'GP05': 'Parenthood',
  'GP06': 'Jungle Adventure',
  'GP07': 'StrangerVille',
  'GP08': 'Realm of Magic',
  'GP09': 'Star Wars: Journey to Batuu',
  'GP10': 'Dream Home Decorator',
  'GP11': 'My Wedding Stories',
  'GP12': 'Werewolves',
  'SP01': 'Luxury Party Stuff',
  'SP02': 'Perfect Patio Stuff',
  'SP03': 'Cool Kitchen Stuff',
  'SP04': 'Spooky Stuff',
  'SP05': 'Movie Hangout Stuff',
  'SP06': 'Romantic Garden Stuff',
  'SP07': 'Kids Room Stuff',
  'SP08': 'Backyard Stuff',
  'SP09': 'Vintage Glamour Stuff',
  'SP10': 'Bowling Night Stuff',
  'SP11': 'Fitness Stuff',
  'SP12': 'Toddler Stuff',
  'SP13': 'Laundry Day Stuff',
  'SP14': 'My First Pet Stuff',
  'SP15': 'Moschino Stuff',
  'SP16': 'Tiny Living',
  'SP17': 'Nifty Knitting',
  'SP18': 'Paranormal Stuff',
  'SP20': 'Throwback Fit Kit',
  'SP21': 'Country Kitchen Kit',
  'SP22': 'Bust the Dust Kit',
  'SP23': 'Courtyard Oasis Kit',
  'SP24': 'Fashion Street Kit',
  'SP25': 'Industrial Loft Kit',
  'SP26': 'Incheon Arrivals Kit',
  'SP28': 'Modern Menswear Kit',
  'SP29': 'Blooming Rooms Kit',
  'SP30': 'Carnaval Streetwear Kit',
  'SP31': 'Décor to the Max Kit',
  'SP32': 'Moonlight Chic Kit',
  'SP33': 'Little Campers Kit',
  'SP34': 'First Fits Kit',
  'SP35': 'Desert Luxe Kit',
  'SP36': 'Pastel Pop Kit',
  'SP37': 'Everyday Clutter Kit',
  'SP38': 'Simtimates Collection Kit',
  'SP39': 'Bathroom Clutter Kit',
  'SP40': 'Greenhouse Haven Kit',
  'SP41': 'Basement Treasures Kit',
  'SP42': 'Grunge Revival Kit',
  'SP43': 'Book Nook Kit',
  'SP44': 'Poolside Splash Kit',
  'SP45': 'Modern Luxe Kit',
  'SP46': 'Home Chef Hustle',
  'SP47': 'Castle Estate Kit',
  'SP48': 'Goth Galore Kit',
  'SP49': 'Crystal Creations',
  'SP50': 'Urban Homage Kit',
  'SP51': 'Party Essentials Kit',
  'SP52': 'Riviera Retreat Kit',
  'SP53': 'Cozy Bistro Kit',
  'SP54': 'Artist Studio Kit',
  'SP55': 'Storybook Nursery Kit',
  'SP56': 'Sweet Slumber Party Kit',
  'SP57': 'Cozy Kitsch Kit',
  'SP58': 'Comfy Gamer Kit',
  'SP59': 'Secret Sanctuary Kit',
  'SP60': 'Casanova Cave Kit',
  'SP61': 'Refined Livingroom Kit',
  'SP62': 'Business Chic Kit',
  'SP63': 'Sleek Bathroom Kit',
  'SP64': 'Sweet Allure Kit',
  'SP65': 'Restoration Workshop Kit',
  'SP66': 'Golden Years Kit',
  'SP67': 'Kitchen Clutter Kit',
  'SP68': "SpongeBob's House Kit",
  'SP69': 'Autumn Apparel Kit',
  'SP70': "SpongeBob Kid's Room Kit",
  'SP71': 'Grange Mudroom Kit',
  'SP72': 'Essential Glam Kit',
  'SP73': 'Modern Retreat Kit',
  'SP74': 'Garden to Table Kit',
  'SP75': 'Wonderland Playroom Kit',
  'SP76': 'Silver Screen Style Kit',
  'SP77': 'Tea Time Solarium Kit',
  'SP78': "Lady Bridgerton's Masquerade Ball Fashion Kit",
  'SP79': "Lady Bridgerton's Masquerade Ballroom Kit",
  'SP81': 'Prairie Dreams Kit',
  'SP82': 'Yard Charm Kit',
};

/// The one remark this game's packs screen has to make about a
/// collection: every expansion and every game pack the app knows of,
/// sitting on one shelf.
///
/// Stuff packs and kits are deliberately not counted. Seventy-nine of the
/// codes in [sims4PackNames] are one or the other and nobody owns them
/// all, so asking for those would mean this never fires; the thirty-three
/// that do count are what people mean when they say they have every pack.
///
/// Judged against the table rather than against a total, so a pack that
/// ships after this build cannot make a complete collection read as an
/// incomplete one. The two numbers are counted off the shelf itself for
/// the same reason: an install ahead of the table should say what it has.
AppMessage? sims4CollectionNote(List<GamePack> packs) {
  const wanted = {GamePackKind.expansion, GamePackKind.gamePack};
  final installed = {for (final pack in packs) pack.code.toUpperCase()};
  for (final code in sims4PackNames.keys) {
    if (wanted.contains(sims4PackKind(code)) && !installed.contains(code)) {
      return null;
    }
  }
  var expansions = 0;
  var gamePacks = 0;
  for (final pack in packs) {
    if (pack.kind == GamePackKind.expansion) expansions++;
    if (pack.kind == GamePackKind.gamePack) gamePacks++;
  }
  return AppMessage('packsAllOwnedSims4', ['$expansions', '$gamePacks']);
}

/// The pack names an install spells out for itself, by language code.
///
/// The EA App writes a manifest per pack listing its title in every
/// language it ships, which is how a German player gets "An die Arbeit"
/// instead of the English name for a pack this build has never heard of.
/// Read with a regex rather than an XML parser on purpose: the four
/// fields wanted here are exporter-written and predictable, and a parser
/// is a dependency the release pin cannot always afford (same bargain as
/// `sims3pack.dart`).
///
/// Titles that are only the code again ("The Sims™ 4 GP06", which is what
/// six of the shipped manifests say) are dropped, so the caller falls
/// through to [sims4PackNames] rather than showing the code twice.
Map<String, String> parseInstallerTitles(String xml, {String? code}) {
  final titles = <String, String>{};
  for (final match in _gameTitleTag.allMatches(xml)) {
    final locale = match.group(1)!;
    final title = stripGameTitle(_unescapeXml(match.group(2)!));
    if (title.isEmpty) continue;
    if (code != null && title.toUpperCase() == code.toUpperCase()) continue;
    final language = locale.split('_').first.toLowerCase();
    titles.putIfAbsent(language, () => title);
  }
  return titles;
}

/// A pack's name without the game's own title in front of it.
String stripGameTitle(String title) {
  final stripped = title.replaceFirst(_gameTitlePrefix, '').trim();
  return stripped.isEmpty ? title.trim() : stripped;
}

final _xmlEntity = RegExp(r'&(#[xX]?[0-9a-fA-F]+|[a-zA-Z]+);');

const _namedEntities = {
  'lt': '<',
  'gt': '>',
  'quot': '"',
  'apos': "'",
  'amp': '&',
};

/// One pass rather than a chain of replaces: decoding `&amp;` first would
/// turn a literal `&amp;#39;` into an apostrophe the file never had.
/// Anything unrecognized is left standing as the text it is.
String _unescapeXml(String value) =>
    value.replaceAllMapped(_xmlEntity, (match) {
      final body = match.group(1)!;
      if (!body.startsWith('#')) {
        return _namedEntities[body.toLowerCase()] ?? match.group(0)!;
      }
      final hex = body.length > 1 && (body[1] == 'x' || body[1] == 'X');
      final digits = body.substring(hex ? 2 : 1);
      final code = int.tryParse(digits, radix: hex ? 16 : 10);
      // Anything outside what a name can hold is not worth guessing at.
      if (code == null || code < 0x20 || code > 0x10FFFF) return match.group(0)!;
      return String.fromCharCode(code);
    });

/// The pack codes [ini] says the game must not load, uppercased. An empty
/// value and a missing line both mean every pack is on, which is how the
/// game itself writes "nothing disabled".
Set<String> parsePacksToSkip(String ini) {
  final line = _skipLine.firstMatch(ini);
  if (line == null) return const {};
  final value = line.group(0)!.substring(line.group(1)!.length);
  return {
    for (final code in value.split(','))
      if (code.trim().isNotEmpty) code.trim().toUpperCase(),
  };
}

/// [ini] with the game told to skip exactly [codes].
///
/// Rewrites the existing line wherever it sits and leaves the rest of the
/// file alone - this is the game's own settings file, holding a lot more
/// than packs, and a reflowed copy of it is a worse thing to hand back
/// than the bytes that were there. When the line is absent it is added to
/// `[usersetting]` and nowhere else: appended to the end of the file it
/// would land under whichever section happens to be last, where the game
/// will never read it.
String applyPacksToSkip(String ini, Iterable<String> codes) {
  final value = (codes.toList()..sort()).join(',');
  if (_skipLine.hasMatch(ini)) {
    return ini.replaceFirstMapped(_skipLine, (m) => '${m.group(1)} $value');
  }
  // Nothing disabled and nothing recorded: leave the file untouched
  // rather than write a line saying so.
  if (value.isEmpty) return ini;
  final newline = ini.contains('\r\n') ? '\r\n' : '\n';
  final section = _userSettingSection.firstMatch(ini);
  if (section != null) {
    // The game leaves a blank line between entries; match it.
    return ini.replaceRange(
        section.end, section.end, 'packstoskipmount = $value$newline$newline');
  }
  final tail = ini.isEmpty || ini.endsWith('\n') ? '' : newline;
  return '$ini$tail[usersetting]$newline'
      'packstoskipmount = $value$newline';
}

/// Every pack installed in [installDir], expansions first and each tier in
/// release order - the order the game's own pack list uses, and the one a
/// player thinks in.
///
/// [userSettings] is the game's `UserSetting.ini`; when it is missing or
/// unreadable every pack simply reads as enabled, which is what a game
/// that has never had a pack switched off looks like anyway.
Future<List<GamePack>> listSims4Packs({
  required Directory installDir,
  File? userSettings,
}) async {
  if (!await installDir.exists()) return const [];

  final skipped = await _readSkipped(userSettings);
  final packs = <GamePack>[];
  await for (final entity in installDir.list().handleError((Object _) {})) {
    if (entity is! Directory) continue;
    final code = p.basename(entity.path).toUpperCase();
    if (!isSims4PackCode(code)) continue;
    final titles = await _readTitles(installDir, code);
    packs.add(GamePack(
      code: code,
      name: titles['en'] ?? sims4PackNames[code] ?? code,
      kind: sims4PackKind(code),
      isEnabled: !skipped.contains(code),
      path: entity.path,
      sizeBytes: await _folderSize(entity),
      localizedNames: titles,
    ));
  }
  packs.sort(_byTierThenCode);
  return packs;
}

int _byTierThenCode(GamePack a, GamePack b) {
  final tier = a.kind.index.compareTo(b.kind.index);
  return tier != 0 ? tier : a.code.compareTo(b.code);
}

Future<Set<String>> _readSkipped(File? userSettings) async {
  if (userSettings == null) return const {};
  try {
    if (!await userSettings.exists()) return const {};
    return parsePacksToSkip(await userSettings.readAsString());
  } catch (_) {
    // An unreadable settings file means the app cannot say which packs
    // are off; saying "all on" is the honest reading of nothing.
    return const {};
  }
}

Future<Map<String, String>> _readTitles(Directory installDir, String code) async {
  final manifest = File(p.join(
      installDir.path, '__Installer', 'DLC', code, '__Installer', 'installerdata.xml'));
  try {
    if (!await manifest.exists()) return const {};
    return parseInstallerTitles(await manifest.readAsString(), code: code);
  } catch (_) {
    return const {};
  }
}

/// What the pack's folder holds, or null when it could not be walked.
/// Best-effort by design: a folder the OS refuses costs that folder's
/// bytes, not the pack's whole entry in the list.
Future<int?> _folderSize(Directory dir) async {
  var total = 0;
  try {
    await for (final entity
        in dir.list(recursive: true, followLinks: false).handleError((Object _) {})) {
      if (entity is File) {
        final stat = await entity.stat();
        if (stat.type != FileSystemEntityType.notFound) total += stat.size;
      }
    }
  } catch (_) {
    return null;
  }
  return total;
}

/// Tells the game to load or skip [code], by rewriting the one line in
/// [userSettings] that says so.
///
/// The game rewrites this file itself when it closes, so a change made
/// while it is running is lost - which is why the UI says to close the
/// game first and why nothing here tries to be clever about it.
Future<void> setSims4PackEnabled(
  File userSettings,
  String code, {
  required bool enabled,
}) async {
  final existing =
      await userSettings.exists() ? await userSettings.readAsString() : '';
  final skipped = parsePacksToSkip(existing).toSet();
  final wanted = code.toUpperCase();
  if (enabled ? !skipped.remove(wanted) : !skipped.add(wanted)) return;
  final updated = applyPacksToSkip(existing, skipped);
  if (updated == existing) return;
  await userSettings.parent.create(recursive: true);
  await userSettings.writeAsString(updated, flush: true);
}
