// Release helper: bumps the version in pubspec.yaml, commits, tags, and
// pushes. The push of the `vX.Y.Z` tag triggers .github/workflows/release.yml,
// which builds Windows/macOS/Linux and publishes a GitHub Release.
//
// Usage:
//   dart tool/release.dart patch          # 1.0.0 -> 1.0.1
//   dart tool/release.dart minor          # 1.0.0 -> 1.1.0
//   dart tool/release.dart major          # 1.0.0 -> 2.0.0
//   dart tool/release.dart 1.2.3          # set an explicit version
//   dart tool/release.dart patch --dry-run
import 'dart:io';

void main(List<String> args) {
  final dryRun = args.contains('--dry-run');
  final positional = args.where((a) => !a.startsWith('--')).toList();
  if (positional.length != 1) {
    stderr.writeln(
        'Usage: dart tool/release.dart <patch|minor|major|x.y.z> [--dry-run]');
    exit(64);
  }

  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    stderr.writeln('Run this from the repository root (pubspec.yaml not found).');
    exit(66);
  }

  // Refuse to release with uncommitted changes.
  if (!dryRun) {
    final status = _git(['status', '--porcelain']);
    if (status.trim().isNotEmpty) {
      stderr.writeln(
          'Working tree is not clean — commit or stash first:\n$status');
      exit(1);
    }
  }

  final content = pubspec.readAsStringSync();
  final versionLine = RegExp(r'^version:\s*(\d+)\.(\d+)\.(\d+)(?:\+\S+)?\s*$',
      multiLine: true);
  final match = versionLine.firstMatch(content);
  if (match == null) {
    stderr.writeln('Could not find a "version: x.y.z" line in pubspec.yaml.');
    exit(65);
  }
  final current =
      '${match.group(1)}.${match.group(2)}.${match.group(3)}';

  final String next;
  switch (positional.single) {
    case 'major':
      next = '${int.parse(match.group(1)!) + 1}.0.0';
    case 'minor':
      next = '${match.group(1)}.${int.parse(match.group(2)!) + 1}.0';
    case 'patch':
      next =
          '${match.group(1)}.${match.group(2)}.${int.parse(match.group(3)!) + 1}';
    default:
      final explicit = RegExp(r'^\d+\.\d+\.\d+$');
      if (!explicit.hasMatch(positional.single)) {
        stderr.writeln('Not a bump keyword or x.y.z version: ${positional.single}');
        exit(64);
      }
      next = positional.single;
  }

  final tag = 'v$next';
  final existingTags = _git(['tag', '--list', tag]);
  if (existingTags.trim().isNotEmpty) {
    stderr.writeln('Tag $tag already exists.');
    exit(1);
  }

  stdout.writeln('Version: $current -> $next  (tag $tag)');
  if (dryRun) {
    stdout.writeln('Dry run — nothing written, committed, or pushed.');
    return;
  }

  final changed = next != current;
  if (changed) {
    pubspec.writeAsStringSync(
        content.replaceFirst(versionLine, 'version: $next'));
    // Keep the in-app version constant (Settings about card, update
    // check, bug-report prefill) in lockstep with pubspec.yaml.
    final versionDart = File('lib/src/app_version.dart');
    versionDart.writeAsStringSync(versionDart.readAsStringSync().replaceFirst(
        RegExp(r"const String appVersion = '[^']*';"),
        "const String appVersion = '$next';"));
    _git(['add', 'pubspec.yaml', 'lib/src/app_version.dart']);
    _git(['commit', '-m', 'Release $tag']);
  } else {
    stdout.writeln('Version unchanged — tagging the current commit.');
  }
  _git(['tag', tag]);
  _git(['push', 'origin', 'HEAD']);
  _git(['push', 'origin', tag]);
  stdout.writeln(
      'Pushed $tag. GitHub Actions is now building the release:\n'
      'https://github.com/rodrifelix99/TheSimsModManager/actions');
}

String _git(List<String> args) {
  final result = Process.runSync('git', args);
  if (result.exitCode != 0) {
    stderr.writeln('git ${args.join(' ')} failed:\n${result.stderr}');
    exit(result.exitCode);
  }
  return result.stdout as String;
}
