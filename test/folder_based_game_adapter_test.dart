import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sims_mod_manager/src/core/app_message.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/mod.dart';

/// Minimal adapter pointing at a temp directory, to exercise the shared
/// folder-based behavior that all real adapters inherit.
class _FakeAdapter extends FolderBasedGameAdapter {
  _FakeAdapter(this.dir);

  final Directory dir;

  @override
  Game get game => const Game(id: 'fake', name: 'Fake Game', series: 'Test');

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  String get setupHelpKey => 'test adapter';

  @override
  Future<String?> defaultModsPath() async => dir.path;
}

/// Simulates Windows sharing violations: renames and deletes throw
/// [PathAccessException] until [failuresLeft] runs out.
class _LockedAdapter extends _FakeAdapter {
  _LockedAdapter(super.dir, {required this.failuresLeft});

  int failuresLeft;
  int attempts = 0;

  @override
  Duration get lockedFileRetryDelay => Duration.zero;

  /// Throws once per remaining failure, counting every attempt.
  void _attempt(File file, String message) {
    attempts++;
    if (failuresLeft > 0) {
      failuresLeft--;
      throw PathAccessException(
          file.path, const OSError('file in use', 32), message);
    }
  }

  @override
  Future<File> renameModFile(File file, String newPath) {
    _attempt(file, 'Cannot rename file');
    return super.renameModFile(file, newPath);
  }

  @override
  Future<void> deleteModFile(File file) {
    _attempt(file, 'Cannot delete file');
    return super.deleteModFile(file);
  }
}

void main() {
  late Directory tempDir;
  late _FakeAdapter adapter;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('mod_manager_test');
    adapter = _FakeAdapter(tempDir);
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  File addFile(String name) {
    final file = File(p.join(tempDir.path, name));
    file.writeAsStringSync('fake mod content');
    return file;
  }

  test('lists only mod files, sorted by name', () async {
    addFile('b_mod.package');
    addFile('a_mod.package');
    addFile('readme.txt'); // not a mod; must be ignored

    final mods = await adapter.listMods(tempDir);

    expect(mods.map((m) => m.name), ['a_mod.package', 'b_mod.package']);
    expect(mods.every((m) => m.isEnabled), isTrue);
  });

  test('recognizes disabled mods by suffix', () async {
    addFile('cool_hair.package$disabledSuffix');

    final mods = await adapter.listMods(tempDir);

    expect(mods, hasLength(1));
    expect(mods.single.name, 'cool_hair.package');
    expect(mods.single.status, ModStatus.disabled);
  });

  test('disable renames the file, enable renames it back', () async {
    addFile('lamp.package');
    var mod = (await adapter.listMods(tempDir)).single;

    mod = await adapter.setEnabled(mod, enabled: false);
    expect(mod.status, ModStatus.disabled);
    expect(File(p.join(tempDir.path, 'lamp.package$disabledSuffix')).existsSync(),
        isTrue);

    mod = await adapter.setEnabled(mod, enabled: true);
    expect(mod.status, ModStatus.enabled);
    expect(File(p.join(tempDir.path, 'lamp.package')).existsSync(), isTrue);
  });

  test('toggling a file already renamed on disk reports the new state',
      () async {
    final file = addFile('lamp.package');
    final mod = (await adapter.listMods(tempDir)).single;
    // Someone else (a second window, the user) already disabled it.
    file.renameSync('${file.path}$disabledSuffix');

    final updated = await adapter.setEnabled(mod, enabled: false);

    expect(updated.status, ModStatus.disabled);
  });

  test('a vanished file surfaces a friendly missing-file error', () async {
    final file = addFile('lamp.package');
    final mod = (await adapter.listMods(tempDir)).single;
    file.deleteSync();

    expect(
      () => adapter.setEnabled(mod, enabled: false),
      throwsA(isA<ModActionException>()
          .having((e) => e.reason, 'reason', ModActionFailure.fileMissing)
          .having((e) => e.toString(), 'message', contains('lamp.package'))),
    );
  });

  test('a transiently locked file is retried until the rename succeeds',
      () async {
    final locked = _LockedAdapter(tempDir, failuresLeft: 2);
    addFile('lamp.package');
    final mod = (await locked.listMods(tempDir)).single;

    final updated = await locked.setEnabled(mod, enabled: false);

    expect(updated.status, ModStatus.disabled);
    expect(locked.attempts, 3);
  });

  test('a file that stays locked gives a friendly in-use error on rename',
      () async {
    final locked = _LockedAdapter(tempDir, failuresLeft: 99);
    addFile('lamp.package');
    final mod = (await locked.listMods(tempDir)).single;

    await expectLater(
      locked.setEnabled(mod, enabled: false),
      throwsA(isA<ModActionException>()
          .having((e) => e.reason, 'reason', ModActionFailure.fileInUse)
          .having((e) => e.toString(), 'message', contains('lamp.package'))),
    );
    expect(locked.attempts, 4, reason: 'retries must be bounded');
    expect(File(p.join(tempDir.path, 'lamp.package')).existsSync(), isTrue,
        reason: 'the mod file itself is untouched');
  });

  test('install copies the file into the mods folder', () async {
    final outside = await Directory.systemTemp.createTemp('mod_source');
    addTearDown(() => outside.delete(recursive: true));
    final source = File(p.join(outside.path, 'new_sofa.package'))
      ..writeAsStringSync('sofa');

    final mod = await adapter.installMod(tempDir, source);

    expect(mod.name, 'new_sofa.package');
    expect(File(mod.path).existsSync(), isTrue);
    expect(source.existsSync(), isTrue, reason: 'install copies, not moves');
  });

  test('installing a file the game cannot read is refused, not copied',
      () async {
    // The picker's extension filter is advisory on Windows, so a stray
    // file can reach installMod; it used to be copied and then crash the
    // null-check on toMod (seen in error tracking on v2.1.3).
    final outside = await Directory.systemTemp.createTemp('mod_source');
    addTearDown(() => outside.delete(recursive: true));
    final source = File(p.join(outside.path, 'readme.txt'))
      ..writeAsStringSync('not a mod');

    await expectLater(adapter.installMod(tempDir, source),
        throwsA(isA<ModContentException>()));
    expect(File(p.join(tempDir.path, 'readme.txt')).existsSync(), isFalse,
        reason: 'a refused file must not land in the mods folder');
  });

  test('remove deletes the file from disk', () async {
    addFile('old_mod.package');
    final mod = (await adapter.listMods(tempDir)).single;

    await adapter.removeMod(mod);

    expect(await adapter.listMods(tempDir), isEmpty);
  });

  test('removing a file that is already gone counts as done', () async {
    final file = addFile('old_mod.package');
    final mod = (await adapter.listMods(tempDir)).single;
    file.deleteSync();

    await expectLater(adapter.removeMod(mod), completes);
  });

  test('a transiently locked file is retried until the delete succeeds',
      () async {
    final locked = _LockedAdapter(tempDir, failuresLeft: 2);
    addFile('old_mod.package');
    final mod = (await locked.listMods(tempDir)).single;

    await locked.removeMod(mod);

    expect(locked.attempts, 3);
    expect(await locked.listMods(tempDir), isEmpty);
  });

  test('a file that stays locked gives a friendly in-use error on delete',
      () async {
    final locked = _LockedAdapter(tempDir, failuresLeft: 99);
    addFile('old_mod.package');
    final mod = (await locked.listMods(tempDir)).single;

    await expectLater(
      locked.removeMod(mod),
      throwsA(isA<ModActionException>()
          .having((e) => e.reason, 'reason', ModActionFailure.fileInUse)
          .having((e) => e.toString(), 'message', contains('old_mod.package'))),
    );
    expect(locked.attempts, 4, reason: 'retries must be bounded');
    expect(File(p.join(tempDir.path, 'old_mod.package')).existsSync(), isTrue,
        reason: 'the mod file itself is untouched');
  });
}
