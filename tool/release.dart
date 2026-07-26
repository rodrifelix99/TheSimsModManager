// Release helper: bumps the version in pubspec.yaml, commits, tags, and
// pushes. The push of the `vX.Y.Z` tag triggers .github/workflows/release.yml,
// which builds Windows/macOS/Linux and publishes a GitHub Release.
//
// Day-to-day work happens on `dev`; main carries exactly one commit per
// release. A release does three things, in order:
//   1. Folds the previous release's commits out of dev (they are already
//      summarized by that release's commit on main, which dev is rebased
//      onto), so dev only ever shows the cycle in progress.
//   2. Bumps the version and commits it on dev.
//   3. Writes one "Release vX.Y.Z" commit on main with dev's exact tree,
//      tags it, and pushes. Main only ever fast-forwards; dev is
//      force-pushed after the fold. Other checkouts recover with
//      `git fetch && git checkout dev && git reset --hard origin/dev`.
//
// A release refuses to start unless dev's HEAD has a green "Analyze & test"
// run on GitHub, so a red or still-building push cannot ship; --skip-ci
// overrides that in an emergency.
//
// Usage:
//   dart tool/release.dart patch          # 1.0.0 -> 1.0.1
//   dart tool/release.dart minor          # 1.0.0 -> 1.1.0
//   dart tool/release.dart major          # 1.0.0 -> 2.0.0
//   dart tool/release.dart 1.2.3          # set an explicit version
//   dart tool/release.dart patch --dry-run
import 'dart:convert';
import 'dart:io';

const String _repo = 'rodrifelix99/TheSimsModManager';

Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final skipCi = args.contains('--skip-ci');
  final positional = args.where((a) => !a.startsWith('--')).toList();
  if (positional.length != 1) {
    stderr.writeln('Usage: dart tool/release.dart <patch|minor|major|x.y.z> '
        '[--dry-run] [--skip-ci]');
    exit(64);
  }

  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    stderr.writeln('Run this from the repository root (pubspec.yaml not found).');
    exit(66);
  }

  // Refuse to release with uncommitted changes, and insist on dev: the fold
  // below rewrites dev, and the release commit is cut from its tree.
  if (!dryRun) {
    final status = _git(['status', '--porcelain']);
    if (status.trim().isNotEmpty) {
      stderr.writeln(
          'Working tree is not clean. Commit or stash first:\n$status');
      exit(1);
    }
    final branch = _git(['rev-parse', '--abbrev-ref', 'HEAD']).trim();
    if (branch != 'dev') {
      stderr.writeln('Releases happen from dev (currently on $branch).');
      exit(1);
    }
    if (!skipCi) {
      await _requireGreenCi();
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
    final fold = _cycleToFold();
    if (fold != null) {
      stdout.writeln('Would fold the ${fold.count} commits of ${fold.tag} '
          'out of dev.');
    }
    stdout.writeln('Dry run: nothing written, committed, or pushed.');
    return;
  }

  // Release against the remote's view of main: a checkout may have no local
  // main at all (dev is where work happens), or a stale one.
  _git(['fetch', 'origin']);
  final folded = _foldReleasedCycle();

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
    stdout.writeln('Version unchanged; tagging the current commit.');
  }

  // One commit on main carrying dev's exact tree.
  final tree = _git(['rev-parse', 'dev^{tree}']).trim();
  final mainTip = _git(['rev-parse', 'refs/remotes/origin/main']).trim();
  final release = _git(
      ['commit-tree', tree, '-p', mainTip, '-m', 'Release $tag']).trim();
  _git(['update-ref', 'refs/heads/main', release]);
  _git(['tag', tag, release]);

  _git(['push', 'origin', 'main']);
  _git(['push', 'origin', tag]);
  if (folded) {
    _git(['push', '--force-with-lease', 'origin', 'dev']);
  } else {
    _git(['push', 'origin', 'dev']);
  }
  stdout.writeln(
      'Pushed $tag. GitHub Actions is now building the release:\n'
      'https://github.com/rodrifelix99/TheSimsModManager/actions');
}

/// Refuses to release unless every "Analyze & test" check run for HEAD
/// finished green. No runs at all means the commit was never pushed (or CI
/// has not started): push dev and let it finish first.
Future<void> _requireGreenCi() async {
  final sha = _git(['rev-parse', 'HEAD']).trim();
  final short = sha.substring(0, 7);
  List<dynamic> runs;
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(
        'https://api.github.com/repos/$_repo/commits/$sha/check-runs?per_page=100'));
    request.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
    request.headers.set(HttpHeaders.userAgentHeader, 'sims-mod-manager-release');
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode != 200) {
      stderr.writeln('Could not read CI status for $short '
          '(HTTP ${response.statusCode}); is the commit pushed? '
          'Use --skip-ci to release anyway.');
      exit(1);
    }
    runs = (jsonDecode(body) as Map<String, dynamic>)['check_runs'] as List;
  } on IOException catch (e) {
    stderr.writeln(
        'Could not read CI status for $short: $e\nUse --skip-ci to release anyway.');
    exit(1);
  } finally {
    client.close();
  }
  final ci = runs
      .where((r) => (r['name'] as String).startsWith('Analyze & test'))
      .toList();
  if (ci.isEmpty) {
    stderr.writeln('No "Analyze & test" runs for $short. Push dev, let CI '
        'finish, then release (or use --skip-ci).');
    exit(1);
  }
  final notGreen =
      ci.where((r) => r['conclusion'] != 'success').toList();
  if (notGreen.isNotEmpty) {
    stderr.writeln('CI is not green for $short:');
    for (final r in notGreen) {
      stderr.writeln('  ${r['name']}: ${r['conclusion'] ?? r['status']}');
    }
    stderr.writeln('Fix it (or use --skip-ci) and try again.');
    exit(1);
  }
  stdout.writeln('CI is green for $short (${ci.length} checks).');
}

class _Fold {
  _Fold(this.tag, this.boundary, this.count);
  final String tag;
  final String boundary;
  final int count;
}

/// The previous release's commits still sitting at the bottom of dev:
/// everything up to and including that release's version-bump commit (found
/// by its tree, which matches the release tag's exactly). Null when there is
/// nothing to fold.
_Fold? _cycleToFold() {
  final tags = _git(['tag', '--list', 'v*', '--sort=v:refname'])
      .trim()
      .split('\n')
      .where((t) => t.isNotEmpty)
      .toList();
  if (tags.isEmpty) return null;
  final latest = tags.last;
  // Already folded (or a fresh checkout of a just-released state): the
  // release commit is part of dev's own history.
  if (_isAncestor('$latest^{commit}', 'dev')) return null;
  final base = _git(['merge-base', 'dev', 'refs/remotes/origin/main']).trim();
  final targetTree = _git(['rev-parse', '$latest^{tree}']).trim();
  final commits = _git(['rev-list', '--reverse', '$base..dev'])
      .trim()
      .split('\n')
      .where((c) => c.isNotEmpty)
      .toList();
  for (var i = 0; i < commits.length; i++) {
    final tree = _git(['rev-parse', '${commits[i]}^{tree}']).trim();
    if (tree == targetTree) return _Fold(latest, commits[i], i + 1);
  }
  stderr.writeln('Could not find the $latest bump commit on dev; '
      'refusing to guess what to fold.');
  exit(1);
}

/// Rebases dev onto the latest release's commit on main, dropping the
/// commits that release already summarizes. Returns whether dev was
/// rewritten.
bool _foldReleasedCycle() {
  final fold = _cycleToFold();
  if (fold == null) return false;
  stdout.writeln('Folding the ${fold.count} commits of ${fold.tag} out of dev.');
  // The release commit's tree equals the bump commit's, so this replay
  // cannot conflict.
  _git([
    'rebase',
    '--committer-date-is-author-date',
    '--onto',
    '${fold.tag}^{commit}',
    fold.boundary,
    'dev',
  ]);
  return true;
}

bool _isAncestor(String maybeAncestor, String ref) {
  final result =
      Process.runSync('git', ['merge-base', '--is-ancestor', maybeAncestor, ref]);
  if (result.exitCode != 0 && result.exitCode != 1) {
    stderr.writeln('git merge-base --is-ancestor failed:\n${result.stderr}');
    exit(result.exitCode);
  }
  return result.exitCode == 0;
}

String _git(List<String> args, {Map<String, String>? environment}) {
  final result = Process.runSync('git', args, environment: environment);
  if (result.exitCode != 0) {
    stderr.writeln('git ${args.join(' ')} failed:\n${result.stderr}');
    exit(result.exitCode);
  }
  return result.stdout as String;
}
