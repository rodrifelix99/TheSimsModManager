import 'dart:io';
import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/conflicts.dart';
import 'package:sims_mod_manager/src/core/demo_library.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_pack.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/games/the_sims/demo_packs.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims1_packs.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims2_packs.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims3_packs.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims4_packs.dart';
import 'package:sims_mod_manager/src/ui/pack_icons.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';

class _FakeAdapter extends FolderBasedGameAdapter {
  _FakeAdapter(this.dir,
      {this.extensions = const {'.package'}, this.packs = const []});

  final Directory dir;
  final Set<String> extensions;

  /// The shelf this game would invent for demo mode. Empty by default:
  /// most of these tests are about the library, not the packs screen.
  final List<GamePack> packs;

  @override
  List<GamePack> demoPacks() => packs;

  @override
  bool get hasPacks => packs.isNotEmpty;

  @override
  bool get canTogglePacks => packs.isNotEmpty;

  /// Where a demo toggle that went looking for the disk would land.
  @override
  Future<void> setPackEnabled(GamePack pack, {required bool enabled}) async {
    throw StateError('the invented shelf must not write anything');
  }

  @override
  Game get game =>
      const Game(id: 'fake', name: 'Fake Game', series: 'Test', year: 2024);

  @override
  Set<String> get modFileExtensions => extensions;

  @override
  Map<String, String> get categoryByExtension =>
      const {'.ts4script': 'Script', '.far': 'Archive'};

  @override
  String get setupHelpKey => 'test adapter';

  @override
  Future<String?> defaultModsPath() async => dir.path;

  /// The real one scans in isolates; nothing here has a file to scan.
  @override
  Future<Map<String, PackageInsight>> inspectMods(
    List<Mod> mods, {
    void Function(int done, int total)? onProgress,
    void Function(Map<String, PackageInsight> found)? onFound,
    bool Function()? isCancelled,
  }) async =>
      const {};
}

const _root = r'/games/The Sims 4/Mods';
final _today = DateTime(2026, 7, 25);

/// Top-level folder each mod sits in, or null for the mods-folder root.
String? _folderOf(Mod mod) {
  final parts = p.split(p.relative(mod.path, from: _root));
  return parts.length > 1 ? parts.first : null;
}

/// Waits for the interface to say something rather than for a round number
/// of milliseconds, the same way the folder-chip test does. Booting the
/// shell reads a real folder off a real disk and then invents ninety mods
/// on top of it: a fixed wait that is generous on an idle machine is a coin
/// toss when the rest of the suite runs beside it, and the library arrives
/// a frame after the assertion.
///
/// Alternates real time (runAsync, where the work actually progresses) with
/// frames (pump, where the result of it is drawn), so it returns as soon as
/// the machine is done and only gives up when the load really did fail.
Future<void> _until(WidgetTester tester, Finder finder) async {
  final deadline = DateTime.now().add(const Duration(seconds: 20));
  while (DateTime.now().isBefore(deadline)) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 25)));
    await tester.pump(const Duration(milliseconds: 25));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('demo library', () {
    final adapter = _FakeAdapter(Directory(_root));
    final demo = buildDemoLibrary(adapter, _root, today: _today);

    test('is a library worth photographing', () {
      expect(demo.mods.length, greaterThan(60));
      expect(demo.mods.where((m) => !m.isEnabled), isNotEmpty);
      expect(demo.mods.map(_folderOf).toSet().length, greaterThan(4));
      // Loose files in the root as well as tidy subfolders.
      expect(demo.mods.where((m) => _folderOf(m) == null), isNotEmpty);
      // Sizes have to vary or every card reads the same.
      expect(demo.mods.map((m) => m.sizeBytes).toSet().length,
          greaterThan(demo.mods.length ~/ 2));
      expect(demo.mods.every((m) => (m.sizeBytes ?? 0) > 0), isTrue);
      expect(demo.mods.every((m) => m.modifiedAt!.isBefore(_today)), isTrue);
    });

    test('never invents the same file twice', () {
      final paths = demo.mods.map((m) => m.path).toList();
      expect(paths.toSet().length, paths.length);
      // Names may repeat only where a clash was planted on purpose.
      final names = demo.mods.map((m) => m.name).toList();
      final repeated = [
        for (final name in names.toSet())
          if (names.where((n) => n == name).length > 1) name,
      ];
      expect(repeated.length, 1);
      expect(repeated.single, contains('Hair_Marigold'));
    });

    test('names its mods after nobody real', () {
      // Invented creator handles only - a demo library must not put a real
      // creator's name on files they never made.
      final names = demo.mods.map((m) => m.name.toLowerCase()).join(' ');
      for (final handle in ['heyharrie', 'okruee', 'deaderpool', 'twisted']) {
        expect(names.contains(handle), isFalse, reason: handle);
      }
    });

    test('reports contents the detail panel can show', () {
      expect(demo.insights, isNotEmpty);
      for (final insight in demo.insights.values) {
        expect(insight.resourceCount, greaterThan(0));
        expect(insight.contents, isNotEmpty);
        // Sorted largest first, like the real scan reports it.
        final counts = insight.contents.values.toList();
        expect(counts, orderedEquals(counts.toList()..sort((a, b) => b - a)));
      }
      // Every insight belongs to a mod that's actually in the library.
      final paths = demo.mods.map((m) => m.path).toSet();
      expect(demo.insights.keys.every(paths.contains), isTrue);
    });

    test('plants clashes the conflict scan finds', () {
      final conflicts = findConflicts(demo.mods);
      expect(conflicts, isNotEmpty);
      // Both kinds: a duplicate file name and two versions side by side.
      final names = [
        for (final mod in demo.mods)
          if (conflicts.containsKey(mod.path)) mod.name,
      ];
      expect(names.where((n) => n.contains('Hair_Marigold')).length, 2);
      expect(names.where((n) => n.contains('Career_Florist_v')).length, 2);
    });

    test('is the same library on every build', () {
      final again = buildDemoLibrary(adapter, _root, today: _today);
      expect(again.mods.map((m) => m.path), demo.mods.map((m) => m.path));
      expect(again.mods.map((m) => m.status), demo.mods.map((m) => m.status));
    });

    test('speaks the game\'s own file types', () {
      final sims1 = _FakeAdapter(Directory(_root),
          extensions: const {'.far', '.iff', '.package'});
      final library = buildDemoLibrary(sims1, _root, today: _today);
      final extensions =
          library.mods.map((m) => p.extension(m.name)).toSet();
      expect(extensions, containsAll(['.far', '.iff', '.package']));
      // Categories come from the adapter, so the filter chips vary too.
      expect(library.mods.map((m) => m.category).toSet().length,
          greaterThan(1));
    });
  });

  group('demo mode', () {
    late Directory tempDir;
    late AppController controller;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('demo_library');
      File(p.join(tempDir.path, 'real_sofa.package'))
          .writeAsStringSync('sofa bytes');
      SharedPreferences.setMockInitialValues(
          {'soundEffects': false, 'demoLibrary': true});
      controller = AppController(
        registry: GameRegistry([_FakeAdapter(tempDir)]),
        settings: await SettingsStore.load(),
        checkUpdates: () async => null,
      );
    });

    tearDown(() => tempDir.deleteSync(recursive: true));

    test('adds invented mods to the real ones', () async {
      await controller.refresh();
      final real = controller.mods.firstWhere((m) => m.name == 'real_sofa.package');
      expect(controller.isDemoMod(real), isFalse);
      expect(controller.mods.where(controller.isDemoMod), isNotEmpty);
      expect(controller.conflictCount, greaterThan(0));
      // The demo library invents files; it never writes any.
      expect(tempDir.listSync().length, 1);
    });

    test('toggling an invented mod stays in memory', () async {
      await controller.refresh();
      final mod = controller.mods.firstWhere(
          (m) => controller.isDemoMod(m) && m.isEnabled);
      await controller.toggleMod(mod);

      final updated =
          controller.mods.firstWhere((m) => m.name == mod.name);
      expect(updated.isEnabled, isFalse);
      expect(updated.path.endsWith(disabledSuffix), isTrue);
      expect(controller.isDemoMod(updated), isTrue);
      expect(controller.lastError, isNull);
      expect(tempDir.listSync().length, 1);
    });

    test('removing an invented mod drops it from the library', () async {
      await controller.refresh();
      final mod = controller.mods.firstWhere(controller.isDemoMod);
      final before = controller.mods.length;
      await controller.removeMod(mod);

      expect(controller.mods.length, before - 1);
      expect(controller.mods.any((m) => m.path == mod.path), isFalse);
      expect(controller.lastError, isNull);
      expect(tempDir.listSync().length, 1);
    });

    // The screenshot machine's actual situation: no game installed, so
    // without demo mode the shell would be showing the setup screen.
    testWidgets('fills the shell even with the game missing',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 824);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues(
          {'soundEffects': false, 'demoLibrary': true});
      final missing = Directory(p.join(tempDir.path, 'not-installed'));
      final registry = GameRegistry([_FakeAdapter(missing)]);
      final settings = await SettingsStore.load();

      await tester.runAsync(() async {
        await tester.pumpWidget(
            ModManagerApp(registry: registry, settings: settings));
      });
      // The title only exists once the folder has been read and the demo
      // library built on top of it, so wait for the title itself rather
      // than for a duration.
      await _until(tester, find.text('Fake Game Library'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Fake Game Library'), findsOneWidget);
      // Folder chips built from the invented subfolders (each carries its
      // count in the same span, hence textContaining).
      expect(find.textContaining('CAS'), findsWidgets);
      expect(find.textContaining('Build Buy'), findsWidgets);
      expect(find.textContaining('Script Mods'), findsWidgets);
      expect(missing.existsSync(), isFalse);
    });

    test('off by default, and the real library is untouched', () async {
      SharedPreferences.setMockInitialValues({'soundEffects': false});
      final plain = AppController(
        registry: GameRegistry([_FakeAdapter(tempDir)]),
        settings: await SettingsStore.load(),
        checkUpdates: () async => null,
      );
      await plain.refresh();
      expect(plain.demoLibrary, isFalse);
      expect(plain.mods.map((m) => m.name), ['real_sofa.package']);
    });
  });

  group('demo packs', () {
    test('are the games\' own packs, in a collection somebody could own', () {
      final shelves = {
        'sims1': demoSims1Packs,
        'sims2': demoSims2Packs,
        'sims3': demoSims3Packs,
        'sims4': demoSims4Packs,
      };
      for (final entry in shelves.entries) {
        final packs = entry.value;
        expect(packs, isNotEmpty, reason: entry.key);
        expect(packs.map((p) => p.code).toSet().length, packs.length,
            reason: '${entry.key} repeats a code');
        // A pack drawn as its own code is what a missing name looks like.
        expect(packs.every((p) => p.name.isNotEmpty && p.name != p.code), isTrue,
            reason: entry.key);
      }

      // Names come from the shipped tables rather than being invented:
      // a pack is the publisher's product, not a creator's.
      expect(demoSims4Packs.every((p) => sims4PackNames[p.code] == p.name),
          isTrue);
      expect(demoSims3Packs.map((p) => p.code), sims3PackNames.keys);
      expect(demoSims2Packs.map((p) => p.code), sims2PackNames.keys);
      expect(demoSims1Packs.map((p) => p.name), sims1PackNames.values);
    });

    test('read as a shelf rather than a checklist', () {
      // Every expansion and game pack, and only some of the kits: nobody
      // owns all hundred-odd of those.
      final kinds = demoSims4Packs.map((p) => p.kind).toSet();
      expect(kinds, containsAll(GamePackKind.values));
      expect(demoSims4Packs.length, lessThan(sims4PackNames.length));
      expect(
          demoSims4Packs
              .where((p) => p.kind == GamePackKind.expansion)
              .length,
          sims4PackNames.keys.where((c) => c.startsWith('EP')).length);

      // Something is switched off on the shelves whose game can switch
      // one off, so the header's counts aren't "all of them, none".
      for (final packs in [demoSims4Packs, demoSims3Packs, demoSims2Packs]) {
        expect(packs.where((p) => !p.isEnabled), isNotEmpty);
        expect(packs.where((p) => p.isEnabled), isNotEmpty);
        expect(packs.every((p) => (p.sizeBytes ?? 0) > 0), isTrue);
      }
      // Sizes vary, or the shelf reads as generated.
      expect(demoSims4Packs.map((p) => p.sizeBytes).toSet().length,
          greaterThan(demoSims4Packs.length ~/ 2));
      // A Sims 2 expansion is not the size of a Sims 4 one.
      int biggest(List<GamePack> packs) => packs
          .map((p) => p.sizeBytes ?? 0)
          .reduce((a, b) => a > b ? a : b);
      expect(biggest(demoSims2Packs), lessThan(biggest(demoSims4Packs)));
    });

    test('keep each game\'s own truths', () {
      // Mansion & Garden runs the collection: a fact, not a switch.
      final locked =
          demoSims2Packs.firstWhere((p) => p.code == 'EP09');
      expect(locked.canToggle, isFalse);
      expect(locked.isEnabled, isTrue);
      expect(demoSims2Packs.where((p) => !p.canToggle).length, 1);

      // The Sims 1's expansions merged into the base game, so being
      // listed is all the app can say about one - as the real list does.
      expect(demoSims1Packs.every((p) => p.isEnabled), isTrue);
      expect(demoSims1Packs.every((p) => p.sizeBytes == null), isTrue);
    });

    test('draw the artwork the app ships', () {
      for (final pack in demoSims1Packs) {
        expect(packIconAsset('sims1', pack.code), isNotNull, reason: pack.code);
      }
      for (final pack in demoSims2Packs) {
        expect(packIconAsset('sims2', pack.code), isNotNull, reason: pack.code);
      }
      // The Sims 4 ships artwork for most of its packs and codes the
      // rest; every expansion has one, which is what a shot shows first.
      for (final pack in demoSims4Packs) {
        if (pack.kind != GamePackKind.expansion) continue;
        expect(packIconAsset('sims4', pack.code), isNotNull, reason: pack.code);
      }
      // The Sims 3's icons sit beside the player's own copy, so an
      // invented shelf has none and falls back to the code tiles.
      expect(
          demoSims3Packs.every((p) => packIconAsset('sims3', p.code) == null),
          isTrue);
    });
  });

  group('demo mode packs', () {
    late Directory tempDir;
    late AppController controller;

    final shelf = [
      const GamePack(
          code: 'EP01', name: 'Get to Work', kind: GamePackKind.expansion),
      const GamePack(
          code: 'EP02',
          name: 'Get Together',
          kind: GamePackKind.expansion,
          isEnabled: false),
      const GamePack(
          code: 'SP01', name: 'Luxury Party Stuff', kind: GamePackKind.stuff),
    ];

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('demo_packs');
      SharedPreferences.setMockInitialValues(
          {'soundEffects': false, 'demoLibrary': true});
      controller = AppController(
        registry: GameRegistry([_FakeAdapter(tempDir, packs: shelf)]),
        settings: await SettingsStore.load(),
        checkUpdates: () async => null,
      );
      await controller.refresh();
    });

    tearDown(() => tempDir.deleteSync(recursive: true));

    test('fills the shelf without going to the disk', () async {
      controller.openPacks();
      await Future<void>.delayed(Duration.zero);

      expect(controller.showPacks, isTrue);
      expect(controller.packsLoading, isFalse);
      expect(controller.gamePacks?.map((p) => p.code), ['EP01', 'EP02', 'SP01']);
      expect(controller.enabledPackCount, 2);
      expect(controller.disabledPackCount, 1);
      expect(tempDir.listSync(), isEmpty);
    });

    test('switching an invented pack stays in memory', () async {
      controller.openPacks();
      await Future<void>.delayed(Duration.zero);
      // The fake adapter throws if the write is attempted at all.
      await controller.setPackEnabled(shelf.first, enabled: false);

      final pack =
          controller.gamePacks!.firstWhere((p) => p.code == 'EP01');
      expect(pack.isEnabled, isFalse);
      expect(controller.lastError, isNull);
      // The game still reads its pack list at startup, invented or not.
      expect(controller.hasPendingPackChanges, isTrue);
    });

    test('the shelf is dropped when demo mode goes off', () async {
      controller.openPacks();
      await Future<void>.delayed(Duration.zero);
      expect(controller.gamePacks, isNotNull);

      await controller.setDemoLibrary(false);
      expect(controller.gamePacks, isNull);
      expect(controller.hasPendingPackChanges, isFalse);

      // Read for real this time: the fake adapter has no packs on disk.
      controller.openPacks();
      await Future<void>.delayed(Duration.zero);
      expect(controller.gamePacks, isEmpty);
    });
  });
}
