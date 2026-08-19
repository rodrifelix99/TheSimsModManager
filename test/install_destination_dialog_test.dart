// The question the app asks before installing for a game that reads mods
// from more than one folder. Pumped directly with a made-up set of folders,
// so none of this touches a disk.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/install_destination.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims_adapters.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';
import 'package:sims_mod_manager/src/ui/game_theme.dart';
import 'package:sims_mod_manager/src/ui/install_destination_dialog.dart';
import 'package:sims_mod_manager/src/ui/l10n.dart';

import 'until.dart';

const _sims1 =
    Game(id: 'sims1', name: 'The Sims', series: 'The Sims', year: 2000);

InstallDestination _destination(String id, {String? descriptionKey}) =>
    InstallDestination(
      id: id,
      directory: Directory('/nowhere/$id'),
      label: id,
      descriptionKey: descriptionKey,
    );

final _defaultDestinations = [
  _destination('Downloads', descriptionKey: 'sims1Downloads'),
  _destination('GameData/Global', descriptionKey: 'sims1Global'),
  _destination('ExpansionPack6'),
];

/// What the dialog came back with, and whether it has come back at all -
/// which is the difference between cancelling and choosing the default.
class _Answer {
  bool closed = false;
  InstallPlacement? placement;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppController controller;
  late SettingsStore settings;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    settings = await SettingsStore.load();
    controller = AppController(
      registry: GameRegistry([const Sims1Adapter()]),
      settings: settings,
      checkUpdates: () async => null,
    );
  });

  Future<_Answer> show(
    WidgetTester tester, {
    List<InstallDestination>? destinations,
    List<String> subjects = const [],
  }) async {
    final answer = _Answer();
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: appSupportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => showDialog<InstallPlacement>(
                context: context,
                builder: (context) => InstallDestinationDialog(
                  theme: GameTheme.forGame(_sims1, Brightness.light),
                  controller: controller,
                  game: _sims1.name,
                  destinations: destinations ?? _defaultDestinations,
                  subjects: subjects,
                ),
              ).then((placement) {
                answer.closed = true;
                answer.placement = placement;
              }),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(answer.closed, isFalse, reason: 'the dialog should still be up');
    return answer;
  }

  Future<void> confirm(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Install'));
    await tester.pumpAndSettle();
  }

  testWidgets('lists every folder, and the app deciding is the default',
      (tester) async {
    final answer = await show(tester);

    expect(find.text('Where should this go?'), findsOneWidget);
    expect(find.text('Sort it out for me'), findsOneWidget);
    expect(find.text('Downloads'), findsOneWidget);
    expect(find.text('GameData/Global'), findsOneWidget);
    // A folder with nothing to say about itself is still offered by name.
    expect(find.text('ExpansionPack6'), findsOneWidget);
    // The ones the ARB files describe carry their description too.
    expect(find.text('Objects, hacks and most downloads.'), findsOneWidget);

    await confirm(tester);

    expect(answer.placement, isA<SortedPlacement>());
  });

  testWidgets('picking a folder comes back as that folder', (tester) async {
    final answer = await show(tester);

    await tester.tap(find.text('GameData/Global'));
    await tester.pumpAndSettle();
    await confirm(tester);

    expect(answer.placement, const ChosenPlacement('GameData/Global'));
  });

  testWidgets('backing out installs nothing at all', (tester) async {
    final answer = await show(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    // Null, not "sort it out": the caller has to be able to tell a cancel
    // apart from a default, or Cancel would install anyway.
    expect(answer.closed, isTrue);
    expect(answer.placement, isNull);
  });

  testWidgets('don\'t ask again turns the question off for good',
      (tester) async {
    await show(tester);
    expect(settings.askWhereToInstall, isTrue);

    await tester.tap(find.text('Don’t ask again'));
    await tester.pumpAndSettle();
    await confirm(tester);

    expect(settings.askWhereToInstall, isFalse);
  });

  testWidgets('what is about to be installed is named, and long picks cut off',
      (tester) async {
    await show(tester, subjects: const [
      '/tmp/a/chair.iff',
      '/tmp/a/head.cmx',
      '/tmp/a/brick.wll',
      '/tmp/a/tile.flr',
      '/tmp/a/roof.bmp',
    ]);

    expect(find.text('chair.iff, head.cmx, brick.wll +2'), findsOneWidget);
  });

  testWidgets('a short pick is named in full', (tester) async {
    await show(tester, subjects: const ['/tmp/a/chair.iff']);

    expect(find.text('chair.iff'), findsOneWidget);
  });

  // ------------------------------------------- when nothing is asked at all

  /// Runs the real resolver against [modsDir] and reports both what it
  /// decided and whether a dialog ever appeared.
  Future<(InstallPlacement?, bool)> resolve(
      WidgetTester tester, Directory modsDir) async {
    InstallPlacement? placement;
    var ran = false;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: L.localizationsDelegates,
      supportedLocales: appSupportedLocales,
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async {
                placement = await resolveInstallPlacement(context, controller,
                    theme: GameTheme.forGame(_sims1, Brightness.light),
                    target: modsDir);
                ran = true;
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    // Real directory reads, so the tap runs outside the fake-async zone.
    await tester.runAsync(() async {
      await tester.tap(find.text('open'));
    });
    // Then wait for the answer rather than for a round number of
    // milliseconds: those reads took under 100ms on an idle machine and
    // rather more with the rest of the suite running beside them, and
    // the dialog that had not arrived yet was read as one that was never
    // going to. Either outcome ends the wait, so the tests where nothing
    // is asked don't sit here.
    await untilTrue(
        tester,
        () =>
            ran || find.byType(InstallDestinationDialog).evaluate().isNotEmpty);
    await tester.pumpAndSettle();
    return (placement, ran);
  }

  testWidgets('a folder with no choice behind it is never asked about',
      (tester) async {
    // Not a Sims install, so the adapter offers nothing and the install
    // should go ahead without a dialog in the way.
    final plain = Directory.systemTemp.createTempSync('resolve_plain');
    addTearDown(() => plain.deleteSync(recursive: true));

    final (placement, ran) = await resolve(tester, plain);

    expect(ran, isTrue);
    expect(placement, isA<SortedPlacement>());
    expect(find.byType(InstallDestinationDialog), findsNothing);
  });

  testWidgets('turning the preference off stops the question', (tester) async {
    await settings.setAskWhereToInstall(false);
    final root = Directory.systemTemp.createTempSync('resolve_off');
    addTearDown(() => root.deleteSync(recursive: true));
    Directory(p.join(root.path, 'GameData', 'Skins'))
        .createSync(recursive: true);
    final downloads = Directory(p.join(root.path, 'Downloads'))..createSync();

    final (placement, ran) = await resolve(tester, downloads);

    expect(ran, isTrue);
    expect(placement, isA<SortedPlacement>());
    expect(find.byType(InstallDestinationDialog), findsNothing);
  });

  testWidgets('every language fits it in the smallest window', (tester) async {
    // Same guarantee localization_test gives the screens: German and
    // Russian run long, and a dialog is the tightest box in the app.
    tester.view.physicalSize = kMinWindowSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final overflows = <String>[];
    final priorOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final text = details.exceptionAsString();
      if (text.contains('overflowed')) {
        overflows.add(text.split('\n').first);
      } else {
        priorOnError?.call(details);
      }
    };
    addTearDown(() => FlutterError.onError = priorOnError);

    for (final language in appLanguages) {
      await tester.pumpWidget(MaterialApp(
        locale: Locale(language.code),
        localizationsDelegates: L.localizationsDelegates,
        supportedLocales: appSupportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () => showDialog<InstallPlacement>(
                  context: context,
                  builder: (context) => InstallDestinationDialog(
                    theme: GameTheme.forGame(_sims1, Brightness.light),
                    controller: controller,
                    game: _sims1.name,
                    // Every folder at once, which is the longest the list
                    // ever gets: all seven expansions installed.
                    destinations: [
                      ..._defaultDestinations,
                      _destination('GameData/Objects',
                          descriptionKey: 'sims1Objects'),
                      _destination('GameData/Skins',
                          descriptionKey: 'sims1Skins'),
                      _destination('ExpansionShared/SkinsBuy',
                          descriptionKey: 'sims1SkinsBuy'),
                      _destination('GameData/Walls',
                          descriptionKey: 'sims1Walls'),
                      _destination('GameData/Floors',
                          descriptionKey: 'sims1Floors'),
                      _destination('GameData/Roofs',
                          descriptionKey: 'sims1Roofs'),
                      for (var i = 1; i <= 7; i++) _destination('ExpansionPack$i'),
                    ],
                    subjects: const ['/tmp/a/marriage.iff'],
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(overflows, isEmpty, reason: 'install dialog in ${language.name}');
      await tester.tap(find.byType(TextButton).last);
      await tester.pumpAndSettle();
    }
  });

  testWidgets('an install with folders to choose between does ask',
      (tester) async {
    final root = Directory.systemTemp.createTempSync('resolve_on');
    addTearDown(() => root.deleteSync(recursive: true));
    Directory(p.join(root.path, 'GameData', 'Skins'))
        .createSync(recursive: true);
    Directory(p.join(root.path, 'GameData', 'Global'))
        .createSync(recursive: true);
    final downloads = Directory(p.join(root.path, 'Downloads'))..createSync();

    final (_, ran) = await resolve(tester, downloads);

    expect(ran, isFalse, reason: 'still waiting on the dialog');
    expect(find.byType(InstallDestinationDialog), findsOneWidget);
    // The real adapter's label, so it is written the way this platform
    // writes a path - which is also how a mod's readme names the folder.
    expect(find.text(p.join('GameData', 'Global')), findsOneWidget);
  });
}
