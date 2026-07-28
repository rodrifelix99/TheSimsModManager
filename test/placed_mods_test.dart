// A mod installed into a folder the game keeps its own files in has to
// stay visible: the library cannot sweep GameData\Global without offering
// the user a switch that turns off the base game, so what the app put
// there is remembered instead. These tests are about that record - that it
// is written, survives a restart, follows a mod through being switched
// off, and lets go when the file does.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/install_destination.dart';
import 'package:sims_mod_manager/src/core/placed_mods.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims_adapters.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;

  setUp(() {
    root = Directory.systemTemp.createTempSync('placed_mods');
  });

  tearDown(() => root.deleteSync(recursive: true));

  Directory make(List<String> segments) =>
      Directory(p.joinAll([root.path, ...segments]))
        ..createSync(recursive: true);

  File makeFile(List<String> segments) {
    final file = File(p.joinAll([root.path, ...segments]));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync('bytes');
    return file;
  }

  /// A stored record, written the way the app writes one on this platform:
  /// p.relative against the mods folder, so a sibling folder climbs out.
  String record(List<String> segments) =>
      jsonEncode(p.joinAll(['..', ...segments]));

  /// A Sims 1 install with the two folders that hold Maxis files.
  Directory makeInstall() {
    make(['Maxis', 'The Sims', 'GameData', 'Global']);
    make(['Maxis', 'The Sims', 'ExpansionPack6']);
    return make(['Maxis', 'The Sims', 'Downloads']);
  }

  Future<AppController> makeController(Directory downloads) async {
    final adapter = Sims1Adapter(programFilesOverride: [root.path]);
    final controller = AppController(
      registry: GameRegistry([adapter]),
      settings: await SettingsStore.load(),
      checkUpdates: () async => null,
      loadAdvisories: () async => null,
      fetchShop: () async => null,
    );
    await controller.init();
    expect(controller.modsDir?.path, downloads.path,
        reason: 'the temp install should be the one that resolved');
    return controller;
  }

  test('a mod installed into a Maxis folder still shows in the library',
      () async {
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final downloads = makeInstall();
    final source = makeFile(['src', 'GameData', 'Global', 'marriage.iff']);
    final c = await makeController(downloads);

    await c.installFiles([source],
        placement: const ChosenPlacement('GameData/Global'));

    expect(
        File(p.join(downloads.parent.path, 'GameData', 'Global',
                'marriage.iff'))
            .existsSync(),
        isTrue);
    expect(c.mods.map((m) => m.name), contains('marriage.iff'));
    // And it is on record, because nothing sweeps that folder.
    final placed = parsePlacedMods(c.settings.placedModsJson);
    expect(placed['sims1'], hasLength(1));
    expect(placed['sims1']!.single, contains('marriage.iff'));
  });

  test('the record survives a restart', () async {
    SharedPreferences.setMockInitialValues({
      'soundEffects': false,
      'placedMods':
          '{"sims1": [${record(['GameData', 'Global', 'marriage.iff'])}]}',
    });
    final downloads = makeInstall();
    makeFile(['Maxis', 'The Sims', 'GameData', 'Global', 'marriage.iff']);
    // Maxis's own file in the same folder, which must stay invisible.
    makeFile(['Maxis', 'The Sims', 'GameData', 'Global', 'Global.iff']);

    final c = await makeController(downloads);

    expect(c.mods.map((m) => m.name), ['marriage.iff']);
  });

  test('switching a placed mod off keeps it listed, and back on again',
      () async {
    SharedPreferences.setMockInitialValues({
      'soundEffects': false,
      'placedMods':
          '{"sims1": [${record(['GameData', 'Global', 'marriage.iff'])}]}',
    });
    final downloads = makeInstall();
    makeFile(['Maxis', 'The Sims', 'GameData', 'Global', 'marriage.iff']);
    final c = await makeController(downloads);

    await c.toggleMod(c.mods.single);
    expect(
        File(p.join(downloads.parent.path, 'GameData', 'Global',
                'marriage.iff.disabled'))
            .existsSync(),
        isTrue);
    // The record points at the name the mod has while it is on, so it has
    // to find the renamed file too or the mod would vanish when disabled.
    expect(c.mods.single.name, 'marriage.iff');
    expect(c.mods.single.status.name, 'disabled');

    await c.toggleMod(c.mods.single);
    expect(c.mods.single.status.name, 'enabled');
  });

  test('uninstalling a placed mod forgets it', () async {
    SharedPreferences.setMockInitialValues({
      'soundEffects': false,
      'confirmDelete': false,
      'placedMods':
          '{"sims1": [${record(['GameData', 'Global', 'marriage.iff'])}]}',
    });
    final downloads = makeInstall();
    makeFile(['Maxis', 'The Sims', 'GameData', 'Global', 'marriage.iff']);
    final c = await makeController(downloads);

    await c.removeMod(c.mods.single);

    expect(c.mods, isEmpty);
    expect(parsePlacedMods(c.settings.placedModsJson)['sims1'], isNull);
  });

  test('a record whose file was deleted by hand is dropped', () async {
    SharedPreferences.setMockInitialValues({
      'soundEffects': false,
      'placedMods': '{"sims1": ['
          '${record(['GameData', 'Global', 'gone.iff'])}, '
          '${record(['GameData', 'Global', 'here.iff'])}]}',
    });
    final downloads = makeInstall();
    makeFile(['Maxis', 'The Sims', 'GameData', 'Global', 'here.iff']);
    final c = await makeController(downloads);

    expect(c.mods.map((m) => m.name), ['here.iff']);
    expect(parsePlacedMods(c.settings.placedModsJson)['sims1'],
        {p.joinAll(['..', 'GameData', 'Global', 'here.iff'])});
  });

  test('the folders that are the player\'s own need no record', () async {
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final downloads = makeInstall();
    make(['Maxis', 'The Sims', 'GameData', 'Skins']);
    final source = makeFile(['src', 'head.cmx']);
    final c = await makeController(downloads);

    await c.installFiles([source]);

    // Sorted into GameData/Skins, which listMods sweeps, so remembering it
    // would only be a second way to find the same file.
    expect(c.mods.map((m) => m.name), ['head.cmx']);
    expect(c.settings.placedModsJson, anyOf(isNull, '{}'));
  });

  test('a selected folder chip does not swallow the chosen folder',
      () async {
    // The chip narrows an ordinary install to the folder being browsed.
    // A folder chosen in the dialog is an answer about the whole install
    // and has to win, or the file lands in the chip and does nothing.
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final downloads = makeInstall();
    make(['Maxis', 'The Sims', 'Downloads', 'cc']);
    makeFile(['Maxis', 'The Sims', 'Downloads', 'cc', 'existing.iff']);
    final source = makeFile(['src', 'marriage.iff']);
    final c = await makeController(downloads);
    c.setFolder('cc');

    await c.installFiles([source],
        placement: const ChosenPlacement('GameData/Global'));

    expect(
        File(p.join(downloads.parent.path, 'GameData', 'Global',
                'marriage.iff'))
            .existsSync(),
        isTrue);
    expect(File(p.join(downloads.path, 'cc', 'marriage.iff')).existsSync(),
        isFalse);
    expect(c.lastError, isNull);
  });

  test('records are kept when the mods folder points somewhere else',
      () async {
    // Two installs, or a re-pointed override: the record cannot resolve,
    // but the mod is still sitting where it was put and still loading.
    // Forgetting it here would lose it for good.
    SharedPreferences.setMockInitialValues({
      'soundEffects': false,
      'placedMods':
          '{"sims1": [${record(['GameData', 'Global', 'marriage.iff'])}]}',
    });
    makeInstall();
    makeFile(['Maxis', 'The Sims', 'GameData', 'Global', 'marriage.iff']);
    // A second install, which is the one the app is pointed at.
    make(['Elsewhere', 'The Sims', 'GameData']);
    final other = make(['Elsewhere', 'The Sims', 'Downloads']);

    final adapter = Sims1Adapter(programFilesOverride: [root.path]);
    final settings = await SettingsStore.load();
    await settings.setModsPathOverride('sims1', other.path);
    final c = AppController(
      registry: GameRegistry([adapter]),
      settings: settings,
      checkUpdates: () async => null,
      loadAdvisories: () async => null,
      fetchShop: () async => null,
    );
    await c.init();
    expect(c.modsDir?.path, other.path);

    expect(c.mods, isEmpty, reason: 'nothing of ours is in this install');
    expect(parsePlacedMods(c.settings.placedModsJson)['sims1'],
        {p.joinAll(['..', 'GameData', 'Global', 'marriage.iff'])},
        reason: 'the other install still has it');
  });

  test('the sidebar counts a placed mod in a game that is not on screen',
      () async {
    // The sidebar's count for the other games comes from its own pass,
    // which read the folder straight and so missed everything sitting in
    // one it cannot sweep - The Sims 1 read one short until it was
    // selected.
    SharedPreferences.setMockInitialValues({
      'soundEffects': false,
      'placedMods':
          '{"sims1": [${record(['GameData', 'Global', 'marriage.iff'])}]}',
    });
    makeInstall();
    makeFile(['Maxis', 'The Sims', 'Downloads', 'sofa.iff']);
    makeFile(['Maxis', 'The Sims', 'GameData', 'Global', 'marriage.iff']);
    // Maxis's own file next to it, which must not reach the count either.
    makeFile(['Maxis', 'The Sims', 'GameData', 'Global', 'Global.iff']);

    final sims1 = Sims1Adapter(programFilesOverride: [root.path]);
    final c = AppController(
      // Sims 4 comes first, so it is the one init() opens on and Sims 1
      // is counted by the sidebar pass rather than by refresh().
      registry:
          GameRegistry([Sims4Adapter(documentsOverride: root), sims1]),
      settings: await SettingsStore.load(),
      checkUpdates: () async => null,
      loadAdvisories: () async => null,
      fetchShop: () async => null,
    );
    await c.init();
    expect(c.adapter.game.id, 'sims4',
        reason: 'Sims 1 has to be the background one');

    expect(c.modCounts['sims1'], 2);
  });

  group('parsing', () {
    test('round trips', () {
      final placed = {
        'sims1': {'../GameData/Global/a.iff', '../ExpansionPack6/b.iff'},
      };  // Parsing keeps whatever string it was given, separators included.
      expect(parsePlacedMods(encodePlacedMods(placed)), placed);
    });

    test('anything that is not a record reads as none', () {
      expect(parsePlacedMods(null), isEmpty);
      expect(parsePlacedMods(''), isEmpty);
      expect(parsePlacedMods('not json'), isEmpty);
      expect(parsePlacedMods('[]'), isEmpty);
      expect(parsePlacedMods('{"sims1": "not a list"}'), isEmpty);
      expect(parsePlacedMods('{"sims1": []}'), isEmpty);
      expect(parsePlacedMods('{"sims1": [1, "", "ok.iff"]}'),
          {'sims1': {'ok.iff'}});
    });

    test('an empty game drops out rather than being stored empty', () {
      expect(encodePlacedMods({'sims1': <String>{}}), '{}');
    });
  });
}
