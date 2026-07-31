import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/app_version.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/services/analytics.dart';
import 'package:sims_mod_manager/src/services/github.dart';
import 'package:sims_mod_manager/src/services/reachability.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';

class _StubAdapter extends FolderBasedGameAdapter {
  const _StubAdapter();

  @override
  Game get game =>
      const Game(id: 'stub', name: 'The Sims 4', series: 'Test', year: 2014);

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  String get setupHelpKey => 'test adapter';

  @override
  Future<String?> defaultModsPath() async => null;
}

void main() {
  _mirrorTests();

  test('appVersion constant matches pubspec.yaml', () {
    // tool/release.dart rewrites both; this guards manual edits.
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(r'^version:\s*(\S+)\s*$', multiLine: true)
        .firstMatch(pubspec)!
        .group(1);
    expect(appVersion, version);
  });

  test('isNewerVersion compares x.y.z fields numerically', () {
    expect(isNewerVersion('1.0.2', '1.0.3'), isTrue);
    expect(isNewerVersion('1.0.2', '1.1.0'), isTrue);
    expect(isNewerVersion('1.9.9', '2.0.0'), isTrue);
    expect(isNewerVersion('1.0.2', '1.0.2'), isFalse);
    expect(isNewerVersion('1.0.2', '1.0.1'), isFalse);
    expect(isNewerVersion('2.0.0', '1.9.9'), isFalse);
    // Not lexicographic: 1.0.10 > 1.0.9.
    expect(isNewerVersion('1.0.9', '1.0.10'), isTrue);
    // Malformed tags never trigger an update prompt.
    expect(isNewerVersion('1.0.2', 'nightly'), isFalse);
    expect(isNewerVersion('garbage', '9.9.9'), isFalse);
  });

  test('bug report URL prefills the issue form fields', () {
    final url = bugReportUrl(gameName: 'The Sims 4');
    expect(url.host, 'github.com');
    expect(url.path, '/$githubRepo/issues/new');
    expect(url.queryParameters['template'], 'bug_report.yml');
    expect(url.queryParameters['version'], appVersion);
    expect(url.queryParameters['os'],
        anyOf('Windows', 'macOS', 'Linux'));
    expect(url.queryParameters['game'], 'The Sims 4');
  });

  test('feature request URL opens the feature form', () {
    final url = featureRequestUrl();
    expect(url.path, '/$githubRepo/issues/new');
    expect(url.queryParameters['template'], 'feature_request.yml');
    expect(url.queryParameters.containsKey('game'), isFalse);
  });

  test('controller surfaces a newer release and collapses re-checks', () async {
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    var calls = 0;
    final controller = AppController(
      registry: GameRegistry(const [_StubAdapter()]),
      settings: SettingsStore(await SharedPreferences.getInstance()),
      checkUpdates: () async {
        calls++;
        return const UpdateInfo(
            version: '9.9.9',
            url: 'https://github.com/$githubRepo/releases/tag/v9.9.9');
      },
    );
    expect(controller.availableUpdate, isNull);
    expect(controller.updateCheckDone, isFalse);

    await controller.checkForUpdates();
    expect(calls, 1);
    expect(controller.updateCheckDone, isTrue);
    expect(controller.checkingForUpdates, isFalse);
    expect(controller.availableUpdate?.version, '9.9.9');

    await controller.checkForUpdates();
    expect(calls, 2);
    expect(controller.availableUpdate?.version, '9.9.9');
  });

  test('controller reports up to date when the check finds nothing',
      () async {
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final controller = AppController(
      registry: GameRegistry(const [_StubAdapter()]),
      settings: SettingsStore(await SharedPreferences.getInstance()),
      checkUpdates: () async => null,
    );
    await controller.checkForUpdates();
    expect(controller.updateCheckDone, isTrue);
    expect(controller.availableUpdate, isNull);
  });

  const advisoryBody = '{"version": 1, "games": {"stub": [{"id": "a", '
      '"title": "A", "status": "broken", "identities": ["a.package"]}]}}';

  // init() fires the advisory download without awaiting it, the way it
  // does the update check, so the tests below let the event loop turn
  // before looking at what it left behind.
  Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

  test('the advisory list is downloaded once and then left alone', () async {
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    var calls = 0;
    final settings = SettingsStore(await SharedPreferences.getInstance());
    AppController build() => AppController(
          registry: GameRegistry(const [_StubAdapter()]),
          settings: settings,
          checkUpdates: () async => null,
          loadAdvisories: () async {
            calls++;
            return advisoryBody;
          },
        );

    await build().init();
    await settle();
    expect(calls, 1);
    expect(settings.advisoriesJson, advisoryBody);
    expect(settings.advisoriesFetchedAt, isNotNull);

    // A second launch inside the freshness window reads the cache instead.
    await build().init();
    await settle();
    expect(calls, 1);
  });

  test('a failed advisory download keeps the list already cached', () async {
    SharedPreferences.setMockInitialValues({
      'soundEffects': false,
      'advisories.cache': advisoryBody,
      // Old enough that a fresh download is due.
      'advisories.fetchedAt': DateTime.now()
          .subtract(const Duration(days: 3))
          .millisecondsSinceEpoch,
    });
    var calls = 0;
    final settings = SettingsStore(await SharedPreferences.getInstance());
    final controller = AppController(
      registry: GameRegistry(const [_StubAdapter()]),
      settings: settings,
      checkUpdates: () async => null,
      loadAdvisories: () async {
        calls++;
        return null;
      },
    );

    await controller.init();
    await settle();
    expect(calls, 1);
    expect(settings.advisoriesJson, advisoryBody);
  });
}

/// A release's `assets` array as the GitHub API returns it.
List<Object?> _assets(String version) => [
      for (final name in [
        'TheSimsModManager-$version-linux-x64.tar.gz',
        'TheSimsModManager-$version-macos.dmg',
        'TheSimsModManager-$version-windows-portable.zip',
        'TheSimsModManager-$version-windows-setup.exe',
      ])
        {
          'name': name,
          'browser_download_url': 'https://github.com/$githubRepo/releases/'
              'download/v$version/$name',
        },
    ];

const _update = UpdateInfo(
  version: '9.9.9',
  url: 'https://github.com/$githubRepo/releases/tag/v9.9.9',
  assetUrl: 'https://github.com/$githubRepo/releases/download/x.exe',
);

/// A controller whose flags carry [payload] for `download-mirror`, seeded
/// through the cache the real client reads on a cold launch.
Future<AppController> _withMirror(String? payload) async {
  SharedPreferences.setMockInitialValues({
    'soundEffects': false,
    if (payload != null)
      'analytics.flagsCache': '{"flags":{"download-mirror":'
          '{"enabled":true,"metadata":{"payload":${jsonEncode(payload)}}}}}',
  });
  final settings = SettingsStore(await SharedPreferences.getInstance());
  final analytics =
      Analytics(settings: settings, post: (url, body) async => null);
  // The cache is read in init(), not the constructor - which is how a
  // cold launch has its flags before anything reaches the network.
  await analytics.init();
  final controller = AppController(
    registry: GameRegistry(const [_StubAdapter()]),
    settings: settings,
    analytics: analytics,
    checkUpdates: () async => _update,
  );
  await controller.checkForUpdates();
  return controller;
}

const _blocked =
    Reachability(shop: false, site: false, downloads: false, mirror: true);

void _mirrorTests() {
  test('an installed build and a portable one are offered different files',
      () {
    // The shape only differs on Windows; elsewhere there is one file per
    // platform and this asserts nothing.
    expect(isPortableWindowsBuild(), Platform.isWindows ? anything : isFalse);
    if (!Platform.isWindows) return;
    expect(assetForThisPlatform(_assets('9.9.9'), windowsPortable: true),
        endsWith('windows-portable.zip'));
    expect(assetForThisPlatform(_assets('9.9.9'), windowsPortable: false),
        endsWith('windows-setup.exe'));
  });

  test('the platform installer is picked out of a release', () {
    // Told which shape rather than asked: under `flutter test` the
    // running executable is the Dart tester, which has no uninstaller
    // beside it and so reads as portable wherever the tests run.
    final url = assetForThisPlatform(_assets('9.9.9'), windowsPortable: false);
    expect(url, isNotNull);
    if (Platform.isWindows) {
      expect(url, endsWith('windows-setup.exe'));
    } else if (Platform.isMacOS) {
      expect(url, endsWith('macos.dmg'));
    } else {
      expect(url, endsWith('linux-x64.tar.gz'));
    }
  });

  test('a release carrying nothing for this platform picks nothing', () {
    expect(assetForThisPlatform(const [
      {'name': 'notes.txt'}
    ]), isNull);
    expect(assetForThisPlatform('not a list'), isNull);
  });

  test('the update button opens the release page when downloads work',
      () async {
    final c = await _withMirror('{"base":"https://mirror.example/"}');

    // Reachable is the default, so the mirror stays out of the way even
    // though one is configured.
    expect(c.updateDownload?.mirrored, isFalse);
    expect(c.updateDownload?.url, endsWith('/releases/tag/v9.9.9'));
  });

  test('blocked downloads go to the mirror, carrying the file itself',
      () async {
    final c = await _withMirror('{"base":"https://mirror.example/"}');
    c.reachability = _blocked;

    // The whole asset URL is appended, which is the form every GitHub
    // accelerator takes - and it is the file, not the page, because the
    // page's own links would still point at the blocked host.
    expect(c.updateDownload?.mirrored, isTrue);
    expect(
        c.updateDownload?.url,
        'https://mirror.example/https://github.com/$githubRepo/releases/'
        'download/x.exe');
  });

  test('with no mirror set, blocked downloads still get the release page',
      () async {
    final c = await _withMirror(null);
    c.reachability = _blocked;

    // Nothing is routed anywhere until someone sets a payload.
    expect(c.downloadMirror, isNull);
    expect(c.updateDownload?.mirrored, isFalse);
  });

  test('a mirror the probe could not reach either is not used', () async {
    final c = await _withMirror('{"base":"https://mirror.example/"}');
    c.reachability = const Reachability(
        shop: false, site: false, downloads: false, mirror: false);

    // Swapping one dead link for another helps nobody: the release page
    // is at least an address people can be told about.
    expect(c.updateDownload?.mirrored, isFalse);
    expect(c.updateDownload?.url, endsWith('/releases/tag/v9.9.9'));
  });

  test('a mirror that is not https is refused', () async {
    final c = await _withMirror('{"base":"http://mirror.example/"}');
    expect(c.downloadMirror, isNull);
  });
}
