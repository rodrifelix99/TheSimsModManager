import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
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
