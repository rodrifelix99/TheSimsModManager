import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sims_mod_manager/src/core/app_message.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/install_path.dart';
import 'package:sims_mod_manager/src/core/mod_archive.dart';

import 'sevenzip_fixtures.dart';

/// The last byte of the LZMA coder's id in the fixture's header, walked
/// from where the start header says the header begins so a matching run
/// inside the compressed payload can't be mistaken for it. `03 01 01` is
/// LZMA; `03 04 01` is PPMd.
int _lzmaCoderIdIn(Uint8List bytes) {
  final start = ByteData.sublistView(bytes).getUint64(12, Endian.little);
  for (var i = 32 + start; i < bytes.length - 4; i++) {
    if (bytes[i] == 0x23 &&
        bytes[i + 1] == 0x03 &&
        bytes[i + 2] == 0x01 &&
        bytes[i + 3] == 0x01) {
      return i + 2;
    }
  }
  throw StateError('the LZMA fixture no longer looks like one');
}

/// Where an unpacker was told to extract to: `-o` is 7-Zip's way of
/// saying it, `-C` tar's, and unrar takes it as the last argument.
String _destinationIn(List<String> arguments) {
  for (final argument in arguments) {
    if (argument.startsWith('-o')) return argument.substring(2);
  }
  final flagged = arguments.indexOf('-C');
  return flagged == -1 ? arguments.last : arguments[flagged + 1];
}

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
  String get setupHelpKey => 'test adapter';

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

  /// A rar the unpackers are faked around: nothing reads its bytes.
  File makeRar(String name) =>
      File(p.join(sourceDir.path, name))..writeAsStringSync('Rar!\x1a\x07');

  /// Answers `--version` probes from [installed] (executable → what it
  /// prints) and hands every extraction run to [extract], which returns
  /// the exit code after doing whatever the real tool would have done.
  void fakeUnpackers(
    Map<String, String> installed,
    int Function(String executable, String destination) extract, {
    List<String>? calls,
  }) {
    archiveProcessRunner = (executable, arguments) async {
      calls?.add(executable);
      if (arguments.length == 1 && arguments.first == '--version') {
        final version = installed[executable];
        if (version == null) {
          throw ProcessException(executable, arguments, 'not found', 2);
        }
        return ProcessResult(0, 0, version, '');
      }
      return ProcessResult(
          0, extract(executable, _destinationIn(arguments)), '', '');
    };
    addTearDown(() => archiveProcessRunner = Process.run);
  }

  test('skips GNU tar and unpacks with the next tool that is installed',
      () async {
    final calls = <String>[];
    fakeUnpackers(
      {'tar': 'tar (GNU tar) 1.35', '7z': '7-Zip 23.01'},
      (executable, destination) {
        File(p.join(destination, 'hair.package')).writeAsStringSync('hair');
        return 0;
      },
      calls: calls,
    );

    final mods = await adapter.installArchive(modsDir, makeRar('hair.rar'));

    expect(mods.map((m) => m.name), ['hair.package']);
    // tar was probed and turned down; nothing was handed to it.
    expect(calls, contains('tar'));
    expect(calls.last, '7z');
  });

  test('debris from a tool that gave up halfway is not installed', () async {
    fakeUnpackers(
      {'tar': 'bsdtar 3.7.4 - libarchive 3.7.4', '7z': '7-Zip 23.01'},
      (executable, destination) {
        if (executable == 'tar') {
          File(p.join(destination, 'hair.package')).writeAsStringSync('half');
          return 1;
        }
        File(p.join(destination, 'hair.package')).writeAsStringSync('whole');
        return 0;
      },
    );

    final mods = await adapter.installArchive(modsDir, makeRar('hair.rar'));

    expect(mods, hasLength(1));
    expect(File(mods.single.path).readAsStringSync(), 'whole');
  });

  test('names what to install when no unpacker is there at all', () async {
    fakeUnpackers(const {}, (_, __) => 0);

    await expectLater(
      adapter.installArchive(modsDir, makeRar('hair.rar')),
      // Which key it is depends on the platform (only Linux is told what
      // to install), the format named in it does not.
      throwsA(isA<ArchiveExtractionException>()
          .having((e) => e.cause, 'cause', ArchiveExtractionFailure.noUnpacker)
          .having((e) => e.detail.args.first, 'format', 'RAR')),
    );
  });

  test('an archive every unpacker refuses blames the file, not the machine',
      () async {
    final calls = <String>[];
    fakeUnpackers(
      {
        'tar': 'bsdtar 3.7.4 - libarchive 3.7.4',
        '7z': '7-Zip 23.01',
        'unrar': 'UNRAR 6.11',
      },
      (_, __) => 1,
      calls: calls,
    );

    await expectLater(
      adapter.installArchive(modsDir, makeRar('locked.rar')),
      throwsA(isA<ArchiveExtractionException>()
          .having((e) => e.cause, 'cause', ArchiveExtractionFailure.refused)
          .having((e) => e.detail.key, 'message key', 'unpackFailed')),
    );
    // It gave every one of them a go before giving up.
    expect(calls.where((c) => c == 'unrar'), hasLength(2));
  });

  test('a zip the Dart decoder refuses is handed to an unpacker', () async {
    fakeUnpackers({'tar': 'bsdtar 3.7.4 - libarchive 3.7.4'},
        (executable, destination) {
      File(p.join(destination, 'hair.package')).writeAsStringSync('hair');
      return 0;
    });
    // Deflate64 and friends: a real zip the pure-Dart decoder can't open.
    final zip = File(p.join(sourceDir.path, 'winzip.zip'))
      ..writeAsStringSync('PK\x03\x04 but not as we know it');

    final mods = await adapter.installArchive(modsDir, zip);

    expect(mods.map((m) => m.name), ['hair.package']);
  });

  test('a zip nothing can read still fails as a zip', () async {
    fakeUnpackers({'tar': 'bsdtar 3.7.4 - libarchive 3.7.4'}, (_, __) => 1);
    final zip = File(p.join(sourceDir.path, 'broken.zip'))
      ..writeAsStringSync('not a zip at all');

    // The unpackers are a second opinion, never the one the user hears:
    // a .zip that failed is reported as a zip, not as a missing tool.
    await expectLater(
      adapter.installArchive(modsDir, zip),
      throwsA(isA<ModContentException>()
          .having((e) => e.detail.args, 'args', contains('broken.zip'))),
    );
  });

  test('only unrar-style tools are offered a 7z they cannot read', () async {
    final calls = <String>[];
    fakeUnpackers({'unrar': 'UNRAR 6.11'}, (_, __) => 0, calls: calls);
    final archive = File(p.join(sourceDir.path, 'bundle.7z'))
      ..writeAsStringSync('7z\xbc\xaf');

    // Four bytes wearing a .7z name: the pure-Dart reader turns it down,
    // and since nothing installed here reads 7z either, its verdict
    // stands. Telling the user to install p7zip for a file that is no 7z
    // at all would send them off after the wrong thing.
    await expectLater(
        adapter.installArchive(modsDir, archive),
        throwsA(isA<ModContentException>()
            .having((e) => e.detail.key, 'message key', 'unreadableArchive')));
    expect(calls, isNot(contains('unrar')));
  });

  /// A machine whose only unpacker sits at [where] rather than on PATH,
  /// which is every Windows machine with 7-Zip on it.
  void fakeUnpackerAt(String where, int Function(String destination) extract,
      {List<String>? calls}) {
    archiveUnpackerLocations =
        (unpacker) => unpacker.executable == '7z' ? [where] : const [];
    addTearDown(
        () => archiveUnpackerLocations = defaultArchiveUnpackerLocations);
    fakeUnpackers(
      {where: '7-Zip 24.09'},
      (_, destination) => extract(destination),
      calls: calls,
    );
  }

  // 7-Zip, NanaZip and WinRAR all install into Program Files without
  // touching PATH, so probing PATH alone found nothing on a machine that
  // had the tool installed all along.
  test('finds an unpacker where it installs itself, not just on PATH',
      () async {
    fakeUnpackerAt(r'C:\Program Files\7-Zip\7z.exe', (destination) {
      File(p.join(destination, 'hair.package')).writeAsStringSync('hair');
      return 0;
    });

    final mods = await adapter.installArchive(modsDir, makeRar('hair.rar'));

    expect(mods.map((m) => m.name), ['hair.package']);
  });

  test('runs the tool it found by the path it found it at', () async {
    final calls = <String>[];
    fakeUnpackerAt(r'C:\Program Files\7-Zip\7z.exe', (destination) {
      File(p.join(destination, 'hair.package')).writeAsStringSync('hair');
      return 0;
    }, calls: calls);

    await adapter.installArchive(modsDir, makeRar('hair.rar'));

    // Probed and then driven under the full path. Handing the bare name
    // to Process.run would be the same failure the probe just ruled out.
    expect(calls.where((c) => c == r'C:\Program Files\7-Zip\7z.exe'),
        hasLength(2));
  });

  test('PATH wins over an install location', () async {
    final calls = <String>[];
    archiveUnpackerLocations = (unpacker) => unpacker.executable == '7z'
        ? const [r'C:\Program Files\7-Zip\7z.exe']
        : const [];
    addTearDown(
        () => archiveUnpackerLocations = defaultArchiveUnpackerLocations);
    fakeUnpackers({'7z': '7-Zip 23.01'}, (executable, destination) {
      File(p.join(destination, 'hair.package')).writeAsStringSync('hair');
      return 0;
    }, calls: calls);

    await adapter.installArchive(modsDir, makeRar('hair.rar'));

    // A build the user put on PATH themselves is the one they meant.
    expect(calls, isNot(contains(r'C:\Program Files\7-Zip\7z.exe')));
  });

  /// A real 7z, packed the way 7-Zip packs one by default.
  File makeSevenZip(String name) => File(p.join(sourceDir.path, name))
    ..writeAsBytesSync(base64.decode(sevenZipLzma1));

  // The bug this whole path exists for: Windows ships one unpacker, its
  // `tar` is libarchive without LZMA, and no 7-Zip installer puts itself
  // on PATH - so an ordinary .7z failed on Windows and nowhere else. It
  // has to install with nothing on the machine to help.
  test('installs a 7z with no unpacker on the machine at all', () async {
    final calls = <String>[];
    fakeUnpackers(const {}, (_, __) => 0, calls: calls);

    final mods = await adapter.installArchive(
        modsDir, makeSevenZip('Merlin-K_Fiat-Lux_Set.7z'));

    expect(
        mods.map((m) => m.name), containsAll(['hair.package', 'lamp.package']));
    expect(File(p.join(modsDir.path, 'hair.package')).readAsStringSync(),
        sevenZipContents['hair.package']);
    // The archive's own folder is kept, and the readme beside the mods
    // is left where every other install leaves one.
    expect(
        File(p.join(modsDir.path, 'inner', 'lamp.package')).readAsStringSync(),
        sevenZipContents['inner/lamp.package']);
    expect(File(p.join(modsDir.path, 'readme.txt')).existsSync(), isFalse);
    // Nothing was asked to help, because nothing needed to be.
    expect(calls, isEmpty);
  });

  test('falls back to an unpacker for a 7z coder it cannot read', () async {
    final calls = <String>[];
    fakeUnpackers(
      {'tar': 'bsdtar 3.7.4 - libarchive 3.7.4'},
      (executable, destination) {
        File(p.join(destination, 'hair.package')).writeAsStringSync('unpacked');
        return 0;
      },
      calls: calls,
    );
    // PPMd, which the reader turns down by name rather than by failing.
    final archive = makeSevenZip('ppmd.7z');
    final bytes = archive.readAsBytesSync();
    bytes[_lzmaCoderIdIn(bytes)] = 0x04;
    archive.writeAsBytesSync(bytes);

    final mods = await adapter.installArchive(modsDir, archive);

    expect(File(mods.single.path).readAsStringSync(), 'unpacked');
    expect(calls, contains('tar'));
  });

  test('throws a readable error when the zip holds no mod files', () async {
    final zip = makeZip('junk.zip', {'readme.txt': 'nothing here'});

    expect(
      () => adapter.installArchive(modsDir, zip),
      throwsA(isA<ModContentException>()
          .having((e) => e.detail.key, 'message key', 'noModFiles')
          .having((e) => e.detail.args, 'args', ['.package', 'junk.zip'])),
    );
  });

  // The key matters as much as the throw: the decoder hands back an empty
  // archive rather than raising on bytes that are no zip at all, and for a
  // while that reached the user as "no mod files inside" - which reads like
  // the download was fine and simply held nothing.
  test('throws a readable error on an unreadable archive', () async {
    final broken = File(p.join(sourceDir.path, 'broken.zip'))
      ..writeAsStringSync('this is not a zip');

    expect(
      () => adapter.installArchive(modsDir, broken),
      throwsA(isA<ModContentException>()
          .having((e) => e.detail.key, 'message key', 'unreadableArchive')
          .having((e) => e.detail.args, 'args', contains('broken.zip'))),
    );
  });

  test('a truncated zip is unreadable, not empty', () async {
    final whole = makeZip('whole.zip', {'a.package': 'DBPF payload here'});
    final cut = File(p.join(sourceDir.path, 'cut.zip'))
      ..writeAsBytesSync(whole.readAsBytesSync().sublist(0, 20));

    expect(
      () => adapter.installArchive(modsDir, cut),
      throwsA(isA<ModContentException>()
          .having((e) => e.detail.key, 'message key', 'unreadableArchive')),
    );
  });
}
