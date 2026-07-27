import 'dart:io';

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:path/path.dart' as p;
import 'package:win32_registry/win32_registry.dart';

import '../core/deep_link.dart';
import 'debug_log.dart';

/// Claiming `simsmodmanager://` for this copy of the app.
///
/// The app does this itself rather than leaving it to an installer,
/// because two of the three downloads on the website have no installer to
/// do it: the Windows portable zip and the Linux tarball are both "unpack
/// it wherever you like and run it". Doing it here also means a portable
/// copy that gets moved re-points the handler at its new home the next
/// time it starts, which an install-time registration could never do.
///
/// macOS is the exception and does nothing here: LaunchServices reads
/// `CFBundleURLTypes` out of the bundle's own Info.plist the first time it
/// sees the app, and there is no user-writable store to poke at.
///
/// Best-effort throughout. A machine that refuses the write simply does
/// not get deep links, which costs the user nothing they had before.

/// Set to opt a debug build in. Off by default because a debug run would
/// otherwise point the scheme at `build/.../Debug`, which the next
/// `flutter clean` deletes - hijacking it on the developer's own machine.
const String _debugOptIn = 'SMM_REGISTER_SCHEME';

/// Points `simsmodmanager://` at [executable] (this app, by default), if
/// it does not already. Reads before writing, so a normal launch costs one
/// registry read or one small file read and nothing else.
Future<void> ensureUrlSchemeRegistered({String? executable}) async {
  if (Platform.environment.containsKey('FLUTTER_TEST')) return;
  if (!kReleaseMode && !Platform.environment.containsKey(_debugOptIn)) return;
  final exe = executable ?? Platform.resolvedExecutable;
  try {
    if (Platform.isWindows) {
      _registerWindows(exe);
    } else if (Platform.isLinux) {
      await _registerLinux(exe);
    }
  } catch (e) {
    debugLog('scheme', 'could not register: ${e.runtimeType}: $e');
  }
}

// ---------------------------------------------------------------- Windows

/// What `HKCU\Software\Classes\simsmodmanager` has to say. HKCU rather
/// than HKLM on purpose: no admin prompt, per-user like the installer's
/// own default, and a portable copy under the user's own folder can claim
/// the scheme without one either.
Map<String, String> windowsSchemeValues(String executable) => {
      '': 'URL:The Sims Mod Manager',
      r'shell\open\command': '"$executable" "%1"',
      'DefaultIcon': '$executable,0',
    };

void _registerWindows(String executable) {
  final wanted = windowsSchemeValues(executable);
  const root = r'Software\Classes\' + appUrlScheme;
  const commandPath = '$root\\shell\\open\\command';

  final hkcu = RegistryKey.openCurrentUser(RegistryAccess.readWrite);
  try {
    // The command is the value that actually matters, and the only one
    // that changes when a portable copy moves, so it decides whether
    // anything is written at all. Not being there yet is the usual answer
    // on a first run rather than a failure.
    String? current;
    try {
      current = hkcu.getString('', path: commandPath);
    } catch (_) {}
    if (current == wanted[r'shell\open\command']) return;

    final key = hkcu.create(root);
    try {
      key.setValue('', RegistryValue.string(wanted['']!));
      // Its presence is the flag; the value is meant to be empty.
      key.setValue('URL Protocol', const RegistryValue.string(''));
    } finally {
      key.close();
    }
    _writeDefault(hkcu, '$root\\DefaultIcon', wanted['DefaultIcon']!);
    _writeDefault(hkcu, commandPath, wanted[r'shell\open\command']!);
    debugLog('scheme', 'registered $appUrlScheme for $executable');
  } finally {
    hkcu.close();
  }
}

void _writeDefault(RegistryKey hkcu, String path, String value) {
  final key = hkcu.create(path);
  try {
    key.setValue('', RegistryValue.string(value));
  } finally {
    key.close();
  }
}

// ---------------------------------------------------------------- Linux

/// The desktop entry's file name. It matches APPLICATION_ID in
/// linux/CMakeLists.txt, which is what lets the desktop environment tie a
/// running window to this entry.
const String linuxDesktopFileName = 'com.felix.sims_mod_manager.desktop';

/// The entry itself. `%u` is what hands the address over, and the exec
/// line is quoted because the tarball is unpacked wherever the user likes,
/// spaces included.
///
/// Paths here are built with `p.posix` rather than `p`, which follows
/// whichever platform it is running on: this describes a Linux file
/// whatever machine works out what goes in it, and the tests run on all
/// three.
String linuxDesktopEntry(String executable) => '''
[Desktop Entry]
Type=Application
Name=Sims Mod Manager
Comment=Manage your Sims mods and custom content
Exec="$executable" %u
Icon=${p.posix.join(p.posix.dirname(executable), 'data', 'app_icon.png')}
Terminal=false
Categories=Utility;Game;
MimeType=x-scheme-handler/$appUrlScheme;
''';

/// Where desktop entries a single user installed belong.
Directory linuxApplicationsDir({Map<String, String>? environment}) {
  final env = environment ?? Platform.environment;
  final data = env['XDG_DATA_HOME'];
  final home = env['HOME'] ?? '';
  return Directory(p.posix.join(
      data != null && data.isNotEmpty
          ? data
          : p.posix.join(home, '.local', 'share'),
      'applications'));
}

Future<void> _registerLinux(String executable) async {
  final dir = linuxApplicationsDir();
  final file = File(p.join(dir.path, linuxDesktopFileName));
  final wanted = linuxDesktopEntry(executable);
  if (await file.exists() && await file.readAsString() == wanted) return;

  await dir.create(recursive: true);
  await file.writeAsString(wanted);
  debugLog('scheme', 'wrote ${file.path}');

  // Both best-effort, and both allowed to be missing: the entry alone is
  // enough on the desktops that read the directory directly. mimeapps.list
  // is deliberately left alone - it is the user's file, and xdg-mime is
  // the tool that is supposed to edit it.
  await _run('update-desktop-database', [dir.path]);
  await _run('xdg-mime', [
    'default',
    linuxDesktopFileName,
    'x-scheme-handler/$appUrlScheme',
  ]);
}

Future<void> _run(String executable, List<String> arguments) async {
  try {
    await Process.run(executable, arguments);
  } catch (e) {
    debugLog('scheme', '$executable: ${e.runtimeType}');
  }
}
