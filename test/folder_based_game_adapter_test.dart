import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
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
  Future<Directory?> resolveModsDirectory() async => dir;
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
    addFile('readme.txt'); // not a mod — must be ignored

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

  test('remove deletes the file from disk', () async {
    addFile('old_mod.package');
    final mod = (await adapter.listMods(tempDir)).single;

    await adapter.removeMod(mod);

    expect(await adapter.listMods(tempDir), isEmpty);
  });
}
