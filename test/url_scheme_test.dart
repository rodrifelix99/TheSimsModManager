// What the app writes to claim simsmodmanager://. The writes themselves are
// per-platform and thin; what is worth pinning is the content, because a
// desktop entry with an unquoted Exec or a registry command missing its "%1"
// fails silently - the link simply does nothing, on someone else's machine.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sims_mod_manager/src/services/url_scheme.dart';

void main() {
  group('Windows', () {
    test('the command carries the exe and the address after it', () {
      final values = windowsSchemeValues(r'C:\Games\SMM\sims_mod_manager.exe');
      expect(values[r'shell\open\command'],
          r'"C:\Games\SMM\sims_mod_manager.exe" "%1"');
      expect(values[''], startsWith('URL:'));
    });

    test('a path with spaces stays one argument', () {
      final values =
          windowsSchemeValues(r'C:\Program Files\The Sims Mod Manager\smm.exe');
      expect(values[r'shell\open\command'],
          startsWith(r'"C:\Program Files\'));
      expect(values[r'shell\open\command'], endsWith(r'smm.exe" "%1"'));
    });

    test('the icon comes out of the executable itself', () {
      expect(windowsSchemeValues(r'C:\a\b.exe')['DefaultIcon'], r'C:\a\b.exe,0');
    });
  });

  group('Linux', () {
    test('the entry claims the scheme and passes the address on', () {
      final entry = linuxDesktopEntry('/opt/smm/sims_mod_manager');
      expect(entry, contains('MimeType=x-scheme-handler/simsmodmanager;'));
      expect(entry, contains('Exec="/opt/smm/sims_mod_manager" %u'));
      expect(entry, contains('Type=Application'));
    });

    test('the exec line is quoted, because a tarball goes anywhere', () {
      final entry = linuxDesktopEntry('/home/me/My Games/smm/sims_mod_manager');
      expect(entry, contains('Exec="/home/me/My Games/smm/sims_mod_manager" %u'));
    });

    test('the icon is the one the runner ships beside the binary', () {
      expect(linuxDesktopEntry('/opt/smm/sims_mod_manager'),
          contains('Icon=/opt/smm/data/app_icon.png'));
    });

    test('the file is named after the GTK application id', () {
      // linux/CMakeLists.txt sets the same string as APPLICATION_ID; the
      // desktop environment ties a running window to this entry by it.
      expect(linuxDesktopFileName, 'com.felix.sims_mod_manager.desktop');
    });

    test('XDG_DATA_HOME wins over the default, when it is set', () {
      // Literal paths rather than a real temp directory: this describes a
      // Linux one, and the suite also runs on Windows and macOS.
      expect(
          linuxApplicationsDir(environment: {
            'XDG_DATA_HOME': '/home/me/.share',
            'HOME': '/home/me',
          }).path,
          '/home/me/.share/applications');
      expect(linuxApplicationsDir(environment: {'HOME': '/home/me'}).path,
          '/home/me/.local/share/applications');
      // An empty value is not a value.
      expect(
          linuxApplicationsDir(
              environment: {'XDG_DATA_HOME': '', 'HOME': '/home/me'}).path,
          '/home/me/.local/share/applications');
    });
  });

  test('registration stays out of the way under flutter test', () async {
    // FLUTTER_TEST is set for us here; the point is that this writes
    // nothing to the machine running the suite. Asserted against this
    // executable rather than the file's absence, because a developer on
    // Linux may well have a real entry there from a real install.
    await ensureUrlSchemeRegistered(executable: '/nowhere/smm');
    final entry =
        File(p.posix.join(
            linuxApplicationsDir().path, linuxDesktopFileName));
    if (entry.existsSync()) {
      expect(entry.readAsStringSync(), isNot(contains('/nowhere/smm')));
    }
  });
}
