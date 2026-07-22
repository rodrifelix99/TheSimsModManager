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

  @override
  Future<Map<String, PackageInsight>> inspectMods(
    List<Mod> mods, {
    void Function(int done, int total)? onProgress,
    bool Function()? isCancelled,
  }) async {
    inspectCalls++;
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

  test('skipArtworkScan is a no-op when no scan is running', () async {
    final c = await makeController(const {});
    c.skipArtworkScan(); // must not throw or start anything
    expect(c.scanProgress, isNull);
  });
}
