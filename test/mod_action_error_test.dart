import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/app_message.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/install_destination.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/mod_archive.dart';
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
  bool lockRemove = false;

  /// The other way the filesystem says no: not a sharing violation the
  /// app should wait out, but a volume that will not take the write at
  /// all. Read-only media, a share that stopped answering, a full disk.
  bool refuseToggle = false;
  bool refuseRemove = false;
  Object? installFailure;

  @override
  Duration get lockedFileRetryDelay => Duration.zero;

  @override
  Future<File> renameModFile(File file, String newPath) {
    if (lockToggle) {
      throw PathAccessException(
          file.path, const OSError('file in use', 32), 'Cannot rename file');
    }
    if (refuseToggle) {
      throw FileSystemException('Cannot rename file to "$newPath"',
          file.path, const OSError('Read-only file system', 30));
    }
    return super.renameModFile(file, newPath);
  }

  @override
  Future<void> deleteModFile(File file) {
    if (lockRemove) {
      throw PathAccessException(
          file.path, const OSError('file in use', 32), 'Cannot delete file');
    }
    if (refuseRemove) {
      throw FileSystemException('Cannot delete file', file.path,
          const OSError('Read-only file system', 30));
    }
    return super.deleteModFile(file);
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
  String get setupHelpKey => 'test adapter';

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
  Future<Mod> installMod(Directory modsDir, File source,
      {InstallPlacement placement = const SortedPlacement(),
      Set<String> placed = const {}}) {
    if (installFailure case final failure?) throw failure;
    return super.installMod(modsDir, source,
        placement: placement, placed: placed);
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
    expect('${c.lastError}', contains('toggle went sideways'));
  });

  test('a locked file shows a friendly message and stays out of tracking',
      () async {
    seedMod('cozy_sofa.package');
    final spy = _SpyAnalytics();
    final c = await makeController(analytics: spy);
    adapter.lockToggle = true;

    await c.toggleMod(c.mods.single);

    // A key and the file name, not a finished English sentence: the UI
    // translates it where it draws it.
    expect(c.lastError?.key, 'fileInUseRename');
    expect(c.lastError?.args, ['cozy_sofa.package']);
    expect(spy.exceptions, isEmpty,
        reason: 'environmental failures are not app bugs');
    final failed = spy.eventProperties[spy.events.indexOf('mod_action_failed')];
    expect(failed['reason'], 'fileInUse');
  });

  test('a volume that refuses the rename is worded, not reported', () async {
    seedMod('cozy_sofa.package');
    final spy = _SpyAnalytics();
    final c = await makeController(analytics: spy);
    adapter.refuseToggle = true;

    await c.toggleMod(c.mods.single);

    // The system's own message travels with it: it is the only thing
    // that knows whether the volume is read-only, unplugged or full.
    expect(c.lastError?.key, 'fileWriteRefused');
    expect(c.lastError?.args, ['cozy_sofa.package', 'Read-only file system']);
    expect(spy.exceptions, isEmpty,
        reason: 'a volume that will not be written to is not an app bug');
    final failed = spy.eventProperties[spy.events.indexOf('mod_action_failed')];
    expect(failed['reason'], 'writeRefused');
  });

  test('a volume that refuses the delete is worded, not reported', () async {
    seedMod('cozy_sofa.package');
    final spy = _SpyAnalytics();
    final c = await makeController(analytics: spy);
    adapter.refuseRemove = true;

    await c.removeMod(c.mods.single);

    expect(c.lastError?.key, 'fileWriteRefused');
    expect(c.lastError?.args, ['cozy_sofa.package', 'Read-only file system']);
    expect(spy.exceptions, isEmpty);
    expect(c.mods, hasLength(1), reason: 'nothing was deleted');
  });

  test('a disk with no room left is a verdict on the machine', () async {
    final source = File(p.join(modsDir.parent.path, 'peggy_hair.package'))
      ..writeAsStringSync('bytes');
    addTearDown(source.deleteSync);
    final spy = _SpyAnalytics();
    final c = await makeController(analytics: spy);
    adapter.installFailure = FileSystemException(
        'Cannot copy file to "hair.package"',
        source.path,
        const OSError('There is not enough space on the disk.', 112));

    await c.installFiles([source]);

    expect(spy.exceptions, isEmpty,
        reason: 'a full disk is not a bug to investigate');
    final failed = spy.eventProperties[spy.events.indexOf('mod_install_failed')];
    expect(failed['reason'], 'file_system');
    // The OS wrote that sentence, in the user's own language - minus
    // the full stop, because the key it lands in has its own.
    expect(c.lastError?.args.last, 'There is not enough space on the disk');
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

    expect('${c.lastError}', contains('removal went sideways'));
    expect(c.mods, hasLength(1));
  });

  test('a mod the game is holding open stays out of tracking', () async {
    seedMod('cozy_sofa.package');
    final spy = _SpyAnalytics();
    final c = await makeController(analytics: spy);
    adapter.lockRemove = true;

    await c.removeMod(c.mods.single);

    expect(c.lastError?.key, 'fileInUseDelete');
    expect(c.lastError?.args, ['cozy_sofa.package']);
    expect(spy.exceptions, isEmpty,
        reason: 'environmental failures are not app bugs');
    final failed = spy.eventProperties[spy.events.indexOf('mod_action_failed')];
    expect(failed['reason'], 'fileInUse');
  });

  test('an archive that will not unpack is a verdict, not a bug', () async {
    final source = File(p.join(modsDir.parent.path, 'peggy_hair.package'))
      ..writeAsStringSync('bytes');
    addTearDown(source.deleteSync);
    final spy = _SpyAnalytics();
    final c = await makeController(analytics: spy);
    adapter.installFailure =
        const ArchiveExtractionException(AppMessage('unpackFailed', [
      'peggy_hair.rar',
    ]));

    await c.installFiles([source]);

    expect(c.lastError?.key, 'unpackFailed');
    expect(c.lastError?.args, ['peggy_hair.rar']);
    expect(spy.exceptions, isEmpty);
    final failed = spy.eventProperties[spy.events.indexOf('mod_install_failed')];
    expect(failed['reason'], 'unpack_failed');
  });

  test('a machine with no unpacker is told apart from a bad archive',
      () async {
    final source = File(p.join(modsDir.parent.path, 'peggy_hair.package'))
      ..writeAsStringSync('bytes');
    addTearDown(source.deleteSync);
    final spy = _SpyAnalytics();
    final c = await makeController(analytics: spy);
    adapter.installFailure = const ArchiveExtractionException(
        AppMessage('noUnpacker', ['RAR', 'peggy_hair.rar']),
        cause: ArchiveExtractionFailure.noUnpacker);

    await c.installFiles([source]);

    expect(spy.exceptions, isEmpty);
    final failed = spy.eventProperties[spy.events.indexOf('mod_install_failed')];
    expect(failed['reason'], 'no_unpacker');
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

    expect(c.lastError?.key, 'installFailed');
    // What the OS said, in the user's own language, and nothing of the
    // raw exception dump around it.
    expect(c.lastError?.args,
        ['grunge_sofa.package', 'The system cannot find the path specified']);
    final failed = spy.eventProperties[spy.events.indexOf('mod_install_failed')];
    expect(failed['reason'], 'not_found');
    expect(spy.exceptions, isEmpty,
        reason: 'a vanished path is a verdict on the machine, and the '
            'failure tally already counts it under its own reason');
  });

  test('a refused write on install stays out of error tracking', () async {
    final source = File(p.join(modsDir.parent.path, 'grunge_sofa.package'))
      ..writeAsStringSync('sofa');
    addTearDown(source.deleteSync);
    final spy = _SpyAnalytics();
    final c = await makeController(analytics: spy);
    adapter.installFailure = PathAccessException(
        r'C:\Program Files\Mods\sofa.package',
        const OSError('Access is denied', 5),
        'Cannot copy file');

    await c.installFiles([source]);

    expect(c.lastError?.key, 'errorNoWriteAccess');
    expect(spy.exceptions, isEmpty,
        reason: 'environmental failures are not app bugs');
    final failed = spy.eventProperties[spy.events.indexOf('mod_install_failed')];
    expect(failed['reason'], 'access_denied');
  });

  test('an unexpected install failure is still reported to error tracking',
      () async {
    final source = File(p.join(modsDir.parent.path, 'grunge_sofa.package'))
      ..writeAsStringSync('sofa');
    addTearDown(source.deleteSync);
    final spy = _SpyAnalytics();
    final c = await makeController(analytics: spy);
    adapter.installFailure = StateError('install went sideways');

    await c.installFiles([source]);

    expect(spy.exceptions, hasLength(1));
    final failed = spy.eventProperties[spy.events.indexOf('mod_install_failed')];
    expect(failed['reason'], 'unknown');
  });

  test('an archive with nothing installable is a verdict, not a bug',
      () async {
    final source = File(p.join(modsDir.parent.path, 'empty_bundle.package'))
      ..writeAsStringSync('nothing');
    addTearDown(source.deleteSync);
    final spy = _SpyAnalytics();
    final c = await makeController(analytics: spy);
    adapter.installFailure =
        ModContentException(const AppMessage('noModFiles', [
      '.package',
      'x.zip',
    ]));

    await c.installFiles([source]);

    expect(c.lastError?.key, 'noModFiles');
    expect(c.lastError?.args, ['.package', 'x.zip']);
    expect(spy.exceptions, isEmpty);
    final failed = spy.eventProperties[spy.events.indexOf('mod_install_failed')];
    expect(failed['reason'], 'no_mod_files');
  });

  test('a zip nothing could read is tallied as a failed unpack', () async {
    final source = File(p.join(modsDir.parent.path, 'broken.package'))
      ..writeAsStringSync('bytes');
    addTearDown(source.deleteSync);
    final spy = _SpyAnalytics();
    final c = await makeController(analytics: spy);
    // The user still hears the zip verdict; only the failure tally files
    // a broken download with the unpacks, not the empty archives.
    adapter.installFailure =
        ModContentException(const AppMessage('unreadableArchive', [
      'broken.zip',
    ]));

    await c.installFiles([source]);

    expect(c.lastError?.key, 'unreadableArchive');
    expect(spy.exceptions, isEmpty);
    final failed = spy.eventProperties[spy.events.indexOf('mod_install_failed')];
    expect(failed['reason'], 'unpack_failed');
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
