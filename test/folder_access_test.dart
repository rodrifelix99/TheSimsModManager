import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/app_message.dart';
import 'package:sims_mod_manager/src/core/folder_access.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';

class _FakeAdapter extends FolderBasedGameAdapter {
  _FakeAdapter(this.dir);

  /// Where this game's mods belong, whether or not the folder is there.
  final Directory dir;

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
}

/// chmod is the only way to build a folder the process may not write to
/// on the runners we have; Windows would need an ACL and its own tooling.
const _posixOnly = 'read-only folders are built with chmod here';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;

  setUp(() => root = Directory.systemTemp.createTempSync('mod_manager_access'));

  tearDown(() {
    // Put the permissions back or the delete fails too.
    if (!Platform.isWindows) {
      Process.runSync('chmod', ['-R', 'u+w', root.path]);
    }
    root.deleteSync(recursive: true);
  });

  Directory lockDir(String name) {
    final dir = Directory(p.join(root.path, name))..createSync();
    Process.runSync('chmod', ['500', dir.path]);
    return dir;
  }

  Future<AppController> makeController(Directory modsDir) async {
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final controller = AppController(
      registry: GameRegistry([_FakeAdapter(modsDir)]),
      settings: await SettingsStore.load(),
      checkUpdates: () async => null,
    );
    await controller.refresh();
    return controller;
  }

  group('canWriteInto', () {
    test('a folder that takes a file says yes', () async {
      expect(await canWriteInto(root), isTrue);
    });

    test('a folder that is not there yet is answered for its parent',
        () async {
      final missing = Directory(p.join(root.path, 'Mods', 'Packages'));
      expect(await canWriteInto(missing), isTrue);
    });

    test('the probe leaves nothing behind', () async {
      await canWriteInto(root);
      expect(root.listSync(), isEmpty);
    });

    test('a folder the system protects says no', () async {
      expect(await canWriteInto(lockDir('protected')), isFalse);
    }, skip: Platform.isWindows ? _posixOnly : false);

    test('a folder that would have to be created inside a protected one '
        'says no', () async {
      final missing = Directory(p.join(lockDir('protected').path, 'Mods'));
      expect(await canWriteInto(missing), isFalse);
    }, skip: Platform.isWindows ? _posixOnly : false);
  });

  group('the message', () {
    test('a refused write is worded as a permission problem, not an errno',
        () {
      final message = noWriteAccessMessage(PathAccessException(
          p.join('C:', 'Program Files', 'Mods', 'hair.package'),
          const OSError('Access is denied.', 5)));

      expect(message?.key, 'errorNoWriteAccess');
      // The folder, not the file: the folder is what needs the permission.
      expect(message?.args.single, p.join('C:', 'Program Files', 'Mods'));
    });

    test('anything else is left alone', () {
      expect(noWriteAccessMessage(const FormatException('nope')), isNull);
      expect(
          noWriteAccessMessage(
              PathAccessException('', const OSError('Access is denied.', 5))),
          isNull);
    });

    test('a file the game is holding open keeps its own wording', () {
      // Same exception type, already diagnosed by the adapter: the
      // permission wording must not overwrite it.
      const locked = ModActionException(
          ModActionFailure.fileInUse, AppMessage('fileInUseRename', ['x']));
      expect(errorMessage(locked).key, 'fileInUseRename');
    });
  });

  group('the library', () {
    test('a read-only mods folder is announced once, up front', () async {
      final modsDir = lockDir('protected');
      final c = await makeController(modsDir);

      expect(c.modsDirWritable, isFalse);
    }, skip: Platform.isWindows ? _posixOnly : false);

    test('an ordinary mods folder says nothing', () async {
      final c = await makeController(root);

      expect(c.modsDirWritable, isTrue);
    });

    test('creating the folder where it cannot be created explains why',
        () async {
      final modsDir =
          Directory(p.join(lockDir('protected').path, 'Mods', 'Packages'));
      final c = await makeController(modsDir);

      await c.createDefaultFolder();

      expect(c.lastError?.key, 'errorNoWriteAccess');
      expect(c.lastError?.args.single, modsDir.path);
      // Nothing half-made: createModsDirectory is recursive, and this is
      // why the check happens before it rather than after.
      expect(Directory(p.dirname(modsDir.path)).existsSync(), isFalse);
    }, skip: Platform.isWindows ? _posixOnly : false);

    test('an install the folder refuses explains why', () async {
      final modsDir = lockDir('protected');
      final source = File(p.join(root.path, 'hair.package'))
        ..writeAsStringSync('bytes');
      final c = await makeController(modsDir);

      await c.installDroppedPaths([source.path]);

      expect(c.lastError?.key, 'errorNoWriteAccess');
      expect(c.lastError?.args.single, modsDir.path);
    }, skip: Platform.isWindows ? _posixOnly : false);
  });
}
