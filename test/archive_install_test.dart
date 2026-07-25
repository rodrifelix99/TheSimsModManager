import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/install_path.dart';
import 'package:sims_mod_manager/src/core/mod_archive.dart';

/// Minimal adapter pointing at a temp directory, to exercise the shared
/// archive-install behavior that all real adapters inherit.
class _FakeAdapter extends FolderBasedGameAdapter {
  _FakeAdapter(this.dir);

  final Directory dir;

  @override
  Game get game => const Game(id: 'fake', name: 'Fake Game', series: 'Test');

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  String get setupHelp => 'test adapter';

  @override
  Future<String?> defaultModsPath() async => dir.path;
}

void main() {
  late Directory modsDir;
  late Directory sourceDir;
  late _FakeAdapter adapter;

  setUp(() async {
    modsDir = await Directory.systemTemp.createTemp('mod_manager_mods');
    sourceDir = await Directory.systemTemp.createTemp('mod_manager_zips');
    adapter = _FakeAdapter(modsDir);
  });

  tearDown(() async {
    await modsDir.delete(recursive: true);
    await sourceDir.delete(recursive: true);
  });

  /// Writes a zip named [name] containing [entries] (path → content).
  File makeZip(String name, Map<String, String> entries) {
    final zip = Archive();
    entries.forEach((path, content) {
      zip.addFile(ArchiveFile.typedData(
          path, Uint8List.fromList(utf8.encode(content))));
    });
    final file = File(p.join(sourceDir.path, name));
    file.writeAsBytesSync(ZipEncoder().encode(zip));
    return file;
  }

  test('recognizes archive paths case-insensitively', () {
    expect(isArchivePath('mod.zip'), isTrue);
    expect(isArchivePath('Mod.RAR'), isTrue);
    expect(isArchivePath('mod.7z'), isTrue);
    expect(isArchivePath('mod.package'), isFalse);
  });

  test('installs mod files from a zip, skipping junk', () async {
    final zip = makeZip('bundle.zip', {
      'cool_sofa.package': 'sofa',
      'readme.txt': 'instructions',
      'screenshot.jpg': 'not a mod',
    });

    final mods = await adapter.installArchive(modsDir, zip);

    expect(mods.map((m) => m.name), ['cool_sofa.package']);
    expect(File(p.join(modsDir.path, 'cool_sofa.package')).readAsStringSync(),
        'sofa');
    expect(File(p.join(modsDir.path, 'readme.txt')).existsSync(), isFalse);
  });

  test('preserves the folder structure inside the archive', () async {
    final zip = makeZip('bundle.zip', {
      'MyMod v2/hair.package': 'hair',
      'MyMod v2/extras/lamp.package': 'lamp',
    });

    final mods = await adapter.installArchive(modsDir, zip);

    expect(mods, hasLength(2));
    expect(File(p.join(modsDir.path, 'MyMod v2', 'hair.package')).existsSync(),
        isTrue);
    expect(
        File(p.join(modsDir.path, 'MyMod v2', 'extras', 'lamp.package'))
            .existsSync(),
        isTrue);
  });

  test('refuses entries that escape the mods folder', () async {
    final zip = makeZip('bundle.zip', {
      '../escape.package': 'evil',
      'safe.package': 'good',
    });

    final mods = await adapter.installArchive(modsDir, zip);

    expect(mods.map((m) => m.name), ['safe.package']);
    expect(File(p.join(modsDir.parent.path, 'escape.package')).existsSync(),
        isFalse);
  });

  test('nesting too deep for the filesystem is flattened, not dropped',
      () async {
    // A real archive from the wild: folders nested until the path is
    // longer than the OS can open. bsdtar writes those happily on
    // Windows and nothing can read them back afterwards.
    final deep = [for (var i = 0; i < 20; i++) 'folder ${'x' * 60} $i']
        .join('/');
    final zip = makeZip('deep.zip', {
      '$deep/hair.package': 'hair',
      'shallow.package': 'lamp',
    });

    final mods = await adapter.installArchive(modsDir, zip);

    expect(mods.map((m) => m.name), containsAll(['hair.package',
        'shallow.package']));
    final limit = Platform.isWindows ? windowsPathLimit : posixPathLimit;
    for (final mod in mods) {
      expect(File(mod.path).existsSync(), isTrue);
      expect(mod.path.length, lessThanOrEqualTo(limit));
    }
    // Everything still landed inside the mods folder.
    expect(mods.every((m) => p.isWithin(modsDir.path, m.path)), isTrue);
    expect(await adapter.listMods(modsDir), hasLength(2));
  });

  test('two flattened files keep both, instead of overwriting', () async {
    final deep = [for (var i = 0; i < 20; i++) 'folder ${'x' * 60} $i']
        .join('/');
    final zip = makeZip('deep.zip', {
      '$deep/one/hair.package': 'first',
      '$deep/two/hair.package': 'second',
    });

    final mods = await adapter.installArchive(modsDir, zip);

    expect(mods, hasLength(2));
    expect(mods.map((m) => m.path).toSet(), hasLength(2));
    expect(
      mods.map((m) => File(m.path).readAsStringSync()).toSet(),
      {'first', 'second'},
    );
  });

  test('reinstalling the same archive overwrites rather than duplicating',
      () async {
    final zip = makeZip('bundle.zip', {'MyMod/hair.package': 'v1'});
    await adapter.installArchive(modsDir, zip);
    final again =
        await adapter.installArchive(modsDir, makeZip('bundle.zip', {
      'MyMod/hair.package': 'v2',
    }));

    expect(again, hasLength(1));
    expect(await adapter.listMods(modsDir), hasLength(1));
    expect(File(again.single.path).readAsStringSync(), 'v2');
  });

  test('an unreadable subfolder costs its own mods, not the library',
      () async {
    File(p.join(modsDir.path, 'visible.package')).writeAsStringSync('ok');
    final locked = Directory(p.join(modsDir.path, 'locked'))..createSync();
    File(p.join(locked.path, 'hidden.package')).writeAsStringSync('nope');
    Process.runSync('chmod', ['000', locked.path]);
    addTearDown(() => Process.runSync('chmod', ['755', locked.path]));

    expect((await adapter.listMods(modsDir)).map((m) => m.name),
        ['visible.package']);
  }, skip: Platform.isWindows ? 'chmod is a POSIX thing' : false);

  test('unpacks a 7z through the system tar, junk and all', () async {
    // The rar/7z branch: the one that walks what bsdtar left behind.
    final tree = Directory(p.join(sourceDir.path, 'CozyCC'))
      ..createSync(recursive: true);
    Directory(p.join(tree.path, 'chairs')).createSync();
    File(p.join(tree.path, 'sofa.package')).writeAsStringSync('sofa');
    File(p.join(tree.path, 'chairs', 'stool.package'))
        .writeAsStringSync('stool');
    File(p.join(tree.path, 'readme.txt')).writeAsStringSync('instructions');
    final archive = File(p.join(sourceDir.path, 'CozyCC.7z'));
    List<String> scratchFolders() => [
          for (final entry in Directory.systemTemp.listSync())
            if (p.basename(entry.path).startsWith('mod_unpack')) entry.path,
        ];
    final scratchBefore = scratchFolders();
    final packed = Process.runSync('tar', [
      '-c', '-f', archive.path, '--format=7zip', //
      '-C', sourceDir.path, 'CozyCC',
    ]);
    if (packed.exitCode != 0) {
      markTestSkipped('this tar cannot write 7z archives');
      return;
    }

    final mods = await adapter.installArchive(modsDir, archive);

    expect(mods.map((m) => m.name).toList()..sort(),
        ['sofa.package', 'stool.package']);
    expect(
        File(p.join(modsDir.path, 'CozyCC', 'chairs', 'stool.package'))
            .readAsStringSync(),
        'stool');
    expect(File(p.join(modsDir.path, 'CozyCC', 'readme.txt')).existsSync(),
        isFalse);
    // The scratch folder it unpacked into is gone again.
    expect(scratchFolders(), scratchBefore);
  });

  test('throws a readable error when the zip holds no mod files', () async {
    final zip = makeZip('junk.zip', {'readme.txt': 'nothing here'});

    expect(
      () => adapter.installArchive(modsDir, zip),
      throwsA(isA<FormatException>().having(
          (e) => e.message, 'message', contains('No mod files'))),
    );
  });

  test('throws a readable error on an unreadable archive', () async {
    final broken = File(p.join(sourceDir.path, 'broken.zip'))
      ..writeAsStringSync('this is not a zip');

    expect(
      () => adapter.installArchive(modsDir, broken),
      throwsA(isA<FormatException>()
          .having((e) => e.message, 'message', contains('broken.zip'))),
    );
  });
}
