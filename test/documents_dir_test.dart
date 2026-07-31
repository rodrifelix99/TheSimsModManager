import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sims_mod_manager/src/core/documents_dir.dart';

/// The candidate builders are pure, so the Windows and Linux layouts can
/// be pinned from any machine - which matters, because the layout that
/// broke detection (OneDrive's Known Folder Move) only exists on Windows
/// and CI runs the tests on Linux too.
void main() {
  group('Windows candidates', () {
    test('the registry answer comes first', () {
      final paths = windowsDocumentsCandidates(
        {'USERPROFILE': r'C:\Users\liz'},
        registryPath: r'C:\Users\liz\OneDrive\Documents',
      );

      expect(paths.first, r'C:\Users\liz\OneDrive\Documents');
      // The classic path stays in the list: Known Folder Move leaves it
      // behind, and a game installed before the move may still be in it.
      expect(paths, contains(r'C:\Users\liz\Documents'));
    });

    test('falls back to the profile folder with no registry answer', () {
      final paths =
          windowsDocumentsCandidates({'USERPROFILE': r'C:\Users\liz'});

      expect(paths, [r'C:\Users\liz\Documents']);
    });

    test('OneDrive roots are candidates when the registry is silent', () {
      final paths = windowsDocumentsCandidates(
        {
          'USERPROFILE': r'C:\Users\liz',
          'OneDrive': r'D:\OneDrive',
          'OneDriveCommercial': r'C:\Users\liz\OneDrive - Contoso',
        },
        oneDrives: [r'C:\Users\liz\OneDrive - Contoso'],
      );

      expect(paths, contains(r'D:\OneDrive\Documents'));
      expect(paths, contains(r'C:\Users\liz\OneDrive - Contoso\Documents'));
      // Guesses, so they sit behind the folder the machine has always had.
      expect(paths.indexOf(r'C:\Users\liz\Documents'),
          lessThan(paths.indexOf(r'D:\OneDrive\Documents')));
    });

    test('says nothing without a profile folder', () {
      expect(windowsDocumentsCandidates(const {}), isEmpty);
    });
  });

  group('Linux candidates', () {
    test('reads the localized folder name out of user-dirs.dirs', () {
      final paths = linuxDocumentsCandidates(
        {'HOME': '/home/liz'},
        userDirs: '# generated\n'
            'XDG_DESKTOP_DIR="\$HOME/Schreibtisch"\n'
            'XDG_DOCUMENTS_DIR="\$HOME/Dokumente"\n',
      );

      expect(paths.first, '/home/liz/Dokumente');
      expect(paths.last, '/home/liz/Documents');
    });

    test('the environment beats the config file', () {
      final paths = linuxDocumentsCandidates(
        {'HOME': '/home/liz', 'XDG_DOCUMENTS_DIR': '/data/docs'},
        userDirs: 'XDG_DOCUMENTS_DIR="\$HOME/Dokumente"\n',
      );

      expect(paths.first, '/data/docs');
    });

    test('ignores a relative path in the config', () {
      final paths = linuxDocumentsCandidates({'HOME': '/home/liz'},
          userDirs: 'XDG_DOCUMENTS_DIR="Dokumente"\n');

      expect(paths, ['/home/liz/Documents']);
    });
  });

  group('macOS candidates', () {
    test('offers the iCloud Drive copy as well', () {
      final paths = macDocumentsCandidates({'HOME': '/Users/liz'});

      expect(paths.first, '/Users/liz/Documents');
      expect(paths.last, contains('com~apple~CloudDocs'));
    });
  });

  group('documentsDirs', () {
    test('an override is the whole answer', () async {
      final docs = await Directory.systemTemp.createTemp('mod_manager_docs');
      addTearDown(() => docs.delete(recursive: true));

      expect(await documentsDirs(override: docs), [docs]);
    });

    test('an override that is not there answers nothing', () async {
      final docs = Directory(p.join(Directory.systemTemp.path, 'nope-$pid'));

      expect(await documentsDirs(override: docs), isEmpty);
    });

    test('keeps only the folders that are there', () async {
      final home = await Directory.systemTemp.createTemp('mod_manager_home');
      addTearDown(() => home.delete(recursive: true));
      final docs = Directory(p.join(home.path, 'Documents'))
        ..createSync(recursive: true);

      // The iCloud candidate does not exist here, so it drops out.
      final found = await documentsDirs(environment: {'HOME': home.path});

      expect(found.map((d) => d.path), [docs.path]);
    });

    test('the same folder reached twice is listed once', () async {
      final home = await Directory.systemTemp.createTemp('mod_manager_home');
      addTearDown(() => home.delete(recursive: true));
      final real = Directory(p.join(home.path, 'Documents'))
        ..createSync(recursive: true);
      // What iCloud's "Desktop & Documents Folders" leaves behind: the
      // second candidate is the first one under another name.
      final cloud = Directory(p.join(
          home.path, 'Library', 'Mobile Documents', 'com~apple~CloudDocs'))
        ..createSync(recursive: true);
      Link(p.join(cloud.path, 'Documents')).createSync(real.path);

      final found = await documentsDirs(environment: {'HOME': home.path});

      expect(found, hasLength(1));
    },
        skip:
            Platform.isWindows ? 'symlinks need a privilege on Windows' : null);
  });
}
