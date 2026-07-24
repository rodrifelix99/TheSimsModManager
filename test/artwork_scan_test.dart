import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';

/// Records whether the bulk artwork scan was asked for, without touching
/// real isolates.
class _RecordingAdapter extends FolderBasedGameAdapter {
  _RecordingAdapter(this.dir);

  final Directory dir;

  int inspectCalls = 0;
  int inspectedMods = 0;

  /// When true the scan "finds" nothing, like a script mod or .far file.
  bool yieldNothing = false;

  @override
  Future<Map<String, PackageInsight>> inspectMods(
    List<Mod> mods, {
    void Function(int done, int total)? onProgress,
    void Function(Map<String, PackageInsight> found)? onFound,
    bool Function()? isCancelled,
  }) async {
    inspectCalls++;
    inspectedMods += mods.length;
    if (yieldNothing) return const {};
    return {
      for (final mod in mods)
        mod.path: PackageInsight(thumbnail: Uint8List.fromList(const [1])),
    };
  }

  @override
  Game get game =>
      const Game(id: 'fake', name: 'Fake Game', series: 'Test', year: 2024);

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  String get setupHelp => 'test adapter';

  @override
  Future<String?> defaultModsPath() async => dir.path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late _RecordingAdapter adapter;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('mod_manager_scanpref');
    File(p.join(tempDir.path, 'a.package')).writeAsStringSync('bytes');
    adapter = _RecordingAdapter(tempDir);
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  Future<AppController> makeController(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(
        {'soundEffects': false, ...prefs});
    final controller = AppController(
      registry: GameRegistry([adapter]),
      settings: await SettingsStore.load(),
      checkUpdates: () async => null,
    );
    await controller.refresh();
    return controller;
  }

  test('artwork scan runs by default and fills the insight cache',
      () async {
    final c = await makeController(const {});
    expect(adapter.inspectCalls, 1);
    expect(c.thumbnailOf(c.mods.single), isNotNull);
  });

  test('scanArtwork=false skips the scan entirely', () async {
    final c = await makeController(const {'scanArtwork': false});
    expect(adapter.inspectCalls, 0);
    expect(c.thumbnailOf(c.mods.single), isNull);
    expect(c.scanProgress, isNull);
  });

  test('setScanArtwork(false) clears cached artwork; (true) rescans',
      () async {
    final c = await makeController(const {});
    expect(c.thumbnailOf(c.mods.single), isNotNull);

    await c.setScanArtwork(false);
    expect(c.settings.scanArtwork, isFalse);
    expect(c.thumbnailOf(c.mods.single), isNull);

    await c.setScanArtwork(true);
    expect(c.settings.scanArtwork, isTrue);
    expect(adapter.inspectCalls, 2);
    expect(c.thumbnailOf(c.mods.single), isNotNull);
  });

  test('a later refresh re-scans nothing when the library is unchanged',
      () async {
    final c = await makeController(const {});
    expect(adapter.inspectedMods, 1);

    await c.refresh();
    expect(adapter.inspectedMods, 1);
  });

  test('files that scan to nothing are not re-scanned on refresh', () async {
    adapter.yieldNothing = true;
    final c = await makeController(const {});
    expect(adapter.inspectedMods, 1);
    expect(c.thumbnailOf(c.mods.single), isNull);

    await c.refresh();
    expect(adapter.inspectedMods, 1);
  });

  test('skipArtworkScan is a no-op when no scan is running', () async {
    final c = await makeController(const {});
    c.skipArtworkScan(); // must not throw or start anything
    expect(c.scanProgress, isNull);
  });
}
