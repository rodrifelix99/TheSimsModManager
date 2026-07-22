import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/app_version.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/services/github.dart';
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
  String get setupHelp => 'test adapter';

  @override
  Future<String?> defaultModsPath() async => null;
}

void main() {
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
}
