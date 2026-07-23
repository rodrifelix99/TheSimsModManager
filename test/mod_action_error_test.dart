import 'dart:io';

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

class _FailingAdapter extends FolderBasedGameAdapter {
  _FailingAdapter(this.dir);

  final Directory dir;

  bool failToggle = false;
  bool failRemove = false;

  /// The real implementation reads files in isolates the test can't wait on.
  @override
  Future<Map<String, PackageInsight>> inspectMods(
    List<Mod> mods, {
    void Function(int done, int total)? onProgress,
    void Function(Map<String, PackageInsight> found)? onFound,
    bool Function()? isCancelled,
  }) async =>
      const {};

  @override
  Game get game =>
      const Game(id: 'fake', name: 'Fake Game', series: 'Test', year: 2024);

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  String get setupHelp => 'test adapter';

  @override
  Future<String?> defaultModsPath() async => dir.path;

  @override
  Future<Mod> setEnabled(Mod mod, {required bool enabled}) {
    if (failToggle) throw Exception('toggle went sideways');
    return super.setEnabled(mod, enabled: enabled);
  }

  @override
  Future<void> removeMod(Mod mod) {
    if (failRemove) throw Exception('removal went sideways');
    return super.removeMod(mod);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory modsDir;
  late _FailingAdapter adapter;

  setUp(() {
    modsDir = Directory.systemTemp.createTempSync('mod_manager_error_mods');
    adapter = _FailingAdapter(modsDir);
  });

  tearDown(() {
    modsDir.deleteSync(recursive: true);
  });

  Future<AppController> makeController() async {
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final controller = AppController(
      registry: GameRegistry([adapter]),
      settings: await SettingsStore.load(),
      checkUpdates: () async => null,
    );
    await controller.refresh();
    return controller;
  }

  File seedMod(String name) {
    final file = File(p.join(modsDir.path, name));
    file.writeAsStringSync('bytes of $name');
    return file;
  }

  test('a failed toggle keeps its error visible after the refresh', () async {
    seedMod('cozy_sofa.package');
    final c = await makeController();
    adapter.failToggle = true;

    await c.toggleMod(c.mods.single);

    // refresh() clears lastError at its start; the error must survive it.
    expect(c.lastError, contains('toggle went sideways'));
  });

  test('a failed removal keeps its error visible after the refresh', () async {
    seedMod('cozy_sofa.package');
    final c = await makeController();
    adapter.failRemove = true;

    await c.removeMod(c.mods.single);

    expect(c.lastError, contains('removal went sideways'));
    expect(c.mods, hasLength(1));
  });

  test('a successful toggle and removal leave no error', () async {
    seedMod('cozy_sofa.package');
    final c = await makeController();

    await c.toggleMod(c.mods.single);
    expect(c.lastError, isNull);

    await c.removeMod(c.mods.single);
    expect(c.lastError, isNull);
    expect(c.mods, isEmpty);
  });
}
