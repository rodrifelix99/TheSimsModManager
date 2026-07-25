import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/services/analytics.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';

/// Records what would be sent so tests can assert on tracking decisions.
class _SpyAnalytics extends Analytics {
  _SpyAnalytics() : super.disabled();

  final events = <String>[];
  final eventProperties = <Map<String, Object?>>[];
  final exceptions = <Object>[];

  @override
  void capture(String event, [Map<String, Object?> properties = const {}]) {
    events.add(event);
    eventProperties.add(properties);
  }

  @override
  void captureException(
    Object error,
    StackTrace? stack, {
    bool handled = true,
    String mechanism = 'generic',
    Map<String, Object?> properties = const {},
  }) {
    exceptions.add(error);
  }
}

class _FailingAdapter extends FolderBasedGameAdapter {
  _FailingAdapter(this.dir);

  final Directory dir;

  bool failToggle = false;
  bool failRemove = false;
  bool lockToggle = false;
  Object? installFailure;

  @override
  Duration get renameRetryDelay => Duration.zero;

  @override
  Future<File> renameModFile(File file, String newPath) {
    if (lockToggle) {
      throw PathAccessException(
          file.path, const OSError('file in use', 32), 'Cannot rename file');
    }
    return super.renameModFile(file, newPath);
  }

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

  @override
  Future<Mod> installMod(Directory modsDir, File source) {
    if (installFailure case final failure?) throw failure;
    return super.installMod(modsDir, source);
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

  Future<AppController> makeController({Analytics? analytics}) async {
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final controller = AppController(
      registry: GameRegistry([adapter]),
      settings: await SettingsStore.load(),
      checkUpdates: () async => null,
      analytics: analytics,
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

  test('a locked file shows a friendly message and stays out of tracking',
      () async {
    seedMod('cozy_sofa.package');
    final spy = _SpyAnalytics();
    final c = await makeController(analytics: spy);
    adapter.lockToggle = true;

    await c.toggleMod(c.mods.single);

    expect(c.lastError, contains('in use by another program'));
    expect(c.lastError, contains('cozy_sofa.package'));
    expect(spy.exceptions, isEmpty,
        reason: 'environmental failures are not app bugs');
    final failed = spy.eventProperties[spy.events.indexOf('mod_action_failed')];
    expect(failed['reason'], 'fileInUse');
  });

  test('an unexpected toggle failure is still reported to error tracking',
      () async {
    seedMod('cozy_sofa.package');
    final spy = _SpyAnalytics();
    final c = await makeController(analytics: spy);
    adapter.failToggle = true;

    await c.toggleMod(c.mods.single);

    expect(spy.exceptions, hasLength(1));
    final failed = spy.eventProperties[spy.events.indexOf('mod_action_failed')];
    expect(failed.containsKey('reason'), isFalse);
  });

  test('a failed removal keeps its error visible after the refresh', () async {
    seedMod('cozy_sofa.package');
    final c = await makeController();
    adapter.failRemove = true;

    await c.removeMod(c.mods.single);

    expect(c.lastError, contains('removal went sideways'));
    expect(c.mods, hasLength(1));
  });

  test('a failed install names the file and the reason the OS gave',
      () async {
    final source = File(p.join(modsDir.parent.path, 'grunge_sofa.package'))
      ..writeAsStringSync('sofa');
    addTearDown(source.deleteSync);
    final spy = _SpyAnalytics();
    final c = await makeController(analytics: spy);
    adapter.installFailure = PathNotFoundException(
        r'C:\Mods\deep\sofa.package',
        const OSError('The system cannot find the path specified', 3),
        'Directory listing failed');

    await c.installFiles([source]);

    expect(c.lastError, contains('grunge_sofa.package'));
    expect(c.lastError, contains('The system cannot find the path specified'));
    // Whatever the OS says stays out of the raw exception dump.
    expect(c.lastError, isNot(contains('PathNotFoundException')));
    final failed = spy.eventProperties[spy.events.indexOf('mod_install_failed')];
    expect(failed['reason'], 'not_found');
    expect(spy.exceptions, hasLength(1),
        reason: 'a filesystem failure on install is worth investigating');
  });

  test('an archive with nothing installable is a verdict, not a bug',
      () async {
    final source = File(p.join(modsDir.parent.path, 'empty_bundle.package'))
      ..writeAsStringSync('nothing');
    addTearDown(source.deleteSync);
    final spy = _SpyAnalytics();
    final c = await makeController(analytics: spy);
    adapter.installFailure =
        const FormatException('No mod files (.package) found inside x.zip.');

    await c.installFiles([source]);

    expect(c.lastError, 'No mod files (.package) found inside x.zip.');
    expect(spy.exceptions, isEmpty);
    final failed = spy.eventProperties[spy.events.indexOf('mod_install_failed')];
    expect(failed['reason'], 'no_mod_files');
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
