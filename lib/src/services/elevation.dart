import 'dart:io';

/// Whether this process is running as administrator.
///
/// Worth knowing because of what it costs: Windows refuses a drag from
/// Explorer (medium integrity) to an elevated window (high), so running the
/// app as administrator - which the games keeping their mods under Program
/// Files push people into - silently kills drag and drop. Letting the OLE
/// messages through does not buy it back; the drop target is reached over
/// COM, and that call is refused on integrity grounds long before any
/// window message is involved. See issue #5.
///
/// Best-effort, like [diskSpaceFor]: any failure answers false, because a
/// banner that might be wrong is worse than no banner. Only Windows has
/// UIPI, so everything else answers false without asking. Shelled out
/// rather than done over FFI to keep the dependency list where it is (the
/// release pin makes adding one a bigger decision than it looks).
Future<bool> isRunningElevated() async {
  if (!Platform.isWindows) return false;
  // A widget test must never spawn a process; the controller injects its
  // own answer instead.
  if (Platform.environment.containsKey('FLUTTER_TEST')) return false;
  try {
    final result = await Process.run('powershell', [
      '-NoProfile',
      '-NonInteractive',
      '-Command',
      r'[Security.Principal.WindowsPrincipal]::new('
          r'[Security.Principal.WindowsIdentity]::GetCurrent()'
          r').IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)',
    ]);
    if (result.exitCode != 0) return false;
    return (result.stdout as String).trim().toLowerCase() == 'true';
  } catch (_) {
    return false;
  }
}
