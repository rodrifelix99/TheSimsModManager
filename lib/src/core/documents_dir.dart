import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:win32_registry/win32_registry.dart';

/// Where the user's Documents folder actually is - the one thing Sims 2, 3
/// and 4 detection is built on, and the thing it kept getting wrong.
///
/// `%USERPROFILE%\Documents` is a guess, not an answer. OneDrive's Known
/// Folder Move repoints Documents at `%USERPROFILE%\OneDrive\Documents`, at
/// `OneDrive - <Company>` on a work account, or at whatever drive OneDrive
/// itself was installed on; Windows has let the folder be redirected by
/// hand since long before that. What Explorer reads instead is the
/// `Personal` shell folder in the registry, and that is what the games
/// follow too.
///
/// The old `%USERPROFILE%\Documents` usually survives a move - empty, or
/// holding whatever predated it - so this returns *every* folder that could
/// be Documents rather than the first one that exists, best answer first,
/// and callers scan them all. A machine with no redirection returns the one
/// folder it always did.

/// Test hook: what the registry says a shell folder is. `null` for a value
/// that isn't there.
typedef ShellFolderReader = String? Function(String name);

/// Registry paths holding the per-user shell folders, in the order to try.
/// `User Shell Folders` is the master copy and stores `%USERPROFILE%`
/// unexpanded; `Shell Folders` is the expanded cache Explorer keeps beside
/// it, worth reading only if the first is missing or unreadable.
const _shellFolderKeys = [
  r'Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders',
  r'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders',
];

/// The `Personal` value under those keys is Documents; it has been called
/// that since Windows 95 and the games have never cared what it is named.
const _documentsValue = 'Personal';

/// Reads the Documents path out of HKCU. Returns null off Windows, and on
/// any failure - a locked-down or roaming profile still gets the guesses
/// below, which is what the app had before this existed.
String? readWindowsDocumentsPath(String name) {
  if (!Platform.isWindows) return null;
  try {
    final hkcu = RegistryKey.openCurrentUser(RegistryAccess.read);
    try {
      for (final key in _shellFolderKeys) {
        try {
          final value = hkcu.getString(name, path: key, expandPaths: true);
          if (value != null && value.trim().isNotEmpty) return value.trim();
        } catch (_) {
          // Missing key or refused read: try the other one.
        }
      }
    } finally {
      hkcu.close();
    }
  } catch (_) {
    // No registry to read. Not fatal - the guesses cover the common cases.
  }
  return null;
}

/// The profile folder an environment names. `USERPROFILE` is what Windows
/// itself exports; `HOME` is what a POSIX-flavoured shell (Git Bash, MSYS)
/// exports, and a session started from one of those may carry only that.
String? _profileFolder(Map<String, String> env) {
  for (final key in ['USERPROFILE', 'HOME']) {
    if (env[key] case final value? when value.isNotEmpty) return value;
  }
  return null;
}

/// Candidate Documents paths on Windows, best answer first: what the
/// registry says, then the classic location, then the OneDrive layouts as
/// guesses for when the registry could not be read at all.
///
/// Pure so the ordering can be pinned by a test on any platform, which is
/// why the joins here are Windows joins rather than the host's: the paths
/// this builds are Windows paths whatever machine builds them. [oneDrives]
/// are the OneDrive roots found under the profile folder (`OneDrive`,
/// `OneDrive - Contoso`), which only a directory listing can know.
List<String> windowsDocumentsCandidates(
  Map<String, String> env, {
  String? registryPath,
  List<String> oneDrives = const [],
}) {
  final paths = <String>[];
  if (registryPath != null) paths.add(registryPath);
  if (_profileFolder(env) case final profile?) {
    paths.add(p.windows.join(profile, 'Documents'));
  }
  // OneDrive exports its own root, and names the business one separately.
  const oneDriveVars = ['OneDrive', 'OneDriveConsumer', 'OneDriveCommercial'];
  for (final key in oneDriveVars) {
    if (env[key] case final root? when root.isNotEmpty) {
      paths.add(p.windows.join(root, 'Documents'));
    }
  }
  for (final root in oneDrives) {
    paths.add(p.windows.join(root, 'Documents'));
  }
  return paths;
}

/// Candidate Documents paths on Linux. The folder is localized there
/// ("Dokumente", "Documentos") and named by the XDG user-dirs config, so
/// read that before falling back to the English name. [userDirs] is the
/// contents of `~/.config/user-dirs.dirs`, or null if there is none.
///
/// POSIX joins for the same reason the Windows builder uses Windows ones:
/// these are Linux paths whoever is asking.
List<String> linuxDocumentsCandidates(Map<String, String> env,
    {String? userDirs}) {
  final home = env['HOME'];
  final paths = <String>[];

  void addExpanded(String raw) {
    var value = raw.trim();
    if (value.startsWith('"') && value.endsWith('"') && value.length >= 2) {
      value = value.substring(1, value.length - 1);
    }
    if (value.isEmpty) return;
    if (home != null) {
      value = value.replaceAll(r'$HOME', home).replaceAll(r'${HOME}', home);
      if (value.startsWith('~/')) {
        value = p.posix.join(home, value.substring(2));
      }
    }
    if (p.posix.isAbsolute(value)) paths.add(value);
  }

  if (env['XDG_DOCUMENTS_DIR'] case final dir? when dir.isNotEmpty) {
    addExpanded(dir);
  }
  if (userDirs != null) {
    final match = RegExp(r'^\s*XDG_DOCUMENTS_DIR\s*=\s*(.+)$', multiLine: true)
        .firstMatch(userDirs);
    if (match != null) addExpanded(match.group(1)!);
  }
  if (home != null) paths.add(p.posix.join(home, 'Documents'));
  return paths;
}

/// Candidate Documents paths on macOS: the real one, plus the copy iCloud
/// Drive keeps when "Desktop & Documents Folders" is on and the local one
/// is a stub.
List<String> macDocumentsCandidates(Map<String, String> env) {
  final home = env['HOME'];
  if (home == null || home.isEmpty) return const [];
  return [
    p.posix.join(home, 'Documents'),
    p.posix.join(home, 'Library', 'Mobile Documents', 'com~apple~CloudDocs',
        'Documents'),
  ];
}

/// Memo of the plain lookup for the run. Several adapters ask several
/// times per refresh and the answer costs a registry read, a listing of
/// the profile folder and a stat per candidate - while Documents, like an
/// install, does not move with the app open. A folder that appears
/// mid-session shows up on restart.
Future<List<Directory>>? _cached;

/// Forgets the memo above. For tests; nothing in the app needs it.
void resetDocumentsDirsCache() => _cached = null;

/// Every folder that could be the user's Documents, best answer first,
/// existing only and deduped by real path (OneDrive redirection and iCloud
/// both hand out the same folder twice, once through a link).
///
/// [override] is the test hook the adapters pass through: given one, that
/// is the whole answer, and the memo is left alone.
///
/// [environment] describes a machine other than this one, so it answers for
/// the registry too: given one with no [readShellFolder] beside it, HKCU is
/// left unread rather than mixing this machine's Documents folder into an
/// answer about a made-up one.
Future<List<Directory>> documentsDirs({
  Directory? override,
  Map<String, String>? environment,
  ShellFolderReader? readShellFolder,
}) async {
  if (override != null) {
    return await override.exists() ? [override] : const [];
  }
  if (environment == null && readShellFolder == null) {
    return _cached ??=
        _documentsDirs(Platform.environment, readWindowsDocumentsPath);
  }
  return _documentsDirs(
    environment ?? Platform.environment,
    readShellFolder ??
        (environment == null ? readWindowsDocumentsPath : _noShellFolder),
  );
}

/// A registry that says nothing, for a described environment.
String? _noShellFolder(String name) => null;

Future<List<Directory>> _documentsDirs(
    Map<String, String> env, ShellFolderReader readShellFolder) async {
  final List<String> paths;
  if (Platform.isWindows) {
    paths = windowsDocumentsCandidates(
      env,
      registryPath: readShellFolder(_documentsValue),
      oneDrives: await _oneDriveRoots(env),
    );
  } else if (Platform.isLinux) {
    paths = linuxDocumentsCandidates(env, userDirs: await _userDirsFile(env));
  } else {
    paths = macDocumentsCandidates(env);
  }

  final found = <Directory>[];
  final seen = <String>{};
  for (final path in paths) {
    final dir = Directory(path);
    if (!await dir.exists()) continue;
    String key;
    try {
      key = await dir.resolveSymbolicLinks();
    } catch (_) {
      key = p.canonicalize(dir.path);
    }
    if (seen.add(key)) found.add(dir);
  }
  return found;
}

/// The OneDrive roots sitting in the profile folder. Enumerated rather than
/// guessed because a work account names its root after the tenant
/// ("OneDrive - Contoso"), which no fixed list can hold.
Future<List<String>> _oneDriveRoots(Map<String, String> env) async {
  final profile = _profileFolder(env);
  if (profile == null) return const [];
  final home = Directory(profile);
  if (!await home.exists()) return const [];
  final roots = <String>[];
  try {
    await for (final entity in home.list(followLinks: false)) {
      if (entity is! Directory) continue;
      if (p.basename(entity.path).toLowerCase().startsWith('onedrive')) {
        roots.add(entity.path);
      }
    }
  } on FileSystemException {
    // An unreadable profile folder is not something to fail detection over.
  }
  return roots;
}

Future<String?> _userDirsFile(Map<String, String> env) async {
  final home = env['HOME'];
  final config =
      env['XDG_CONFIG_HOME'] ?? (home == null ? null : p.join(home, '.config'));
  if (config == null) return null;
  final file = File(p.join(config, 'user-dirs.dirs'));
  try {
    return await file.exists() ? await file.readAsString() : null;
  } catch (_) {
    return null;
  }
}
