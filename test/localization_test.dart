import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale, Size;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Directionality, Localizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/app_message.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/games/the_sims/sims_adapters.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app.dart';
import 'package:sims_mod_manager/src/ui/l10n.dart';

class _FakeAdapter extends FolderBasedGameAdapter {
  _FakeAdapter(this.dir);

  final Directory dir;

  @override
  Future<Map<String, PackageInsight>> inspectMods(
    List<Mod> mods, {
    void Function(int done, int total)? onProgress,
    void Function(Map<String, PackageInsight> found)? onFound,
    bool Function()? isCancelled,
  }) async =>
      const {};

  @override
  Game get game =>
      const Game(id: 'fake', name: 'Fake Game', series: 'Test', year: 2024);

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  String get setupHelpKey => 'fake';

  @override
  Future<String?> defaultModsPath() async => dir.path;
}

Map<String, Object?> _arb(String locale) => (jsonDecode(
        File('lib/l10n/app_$locale.arb').readAsStringSync())
    as Map<String, Object?>);

void main() {
  test('every shipped language has a translation file', () {
    for (final language in appLanguages) {
      expect(File('lib/l10n/app_${language.code}.arb').existsSync(), isTrue,
          reason: 'missing ARB for ${language.name}');
    }
    // And nothing ships that the picker can't reach, in either direction.
    final codes = [for (final l in appLanguages) l.code];
    expect([for (final l in appSupportedLocales) l.languageCode], codes);
    expect({for (final l in L.supportedLocales) l.languageCode}, codes.toSet());
    // English has to come first: Flutter falls back to the first supported
    // locale, and the generated list is alphabetical (German).
    expect(appSupportedLocales.first.languageCode, 'en');
  });

  test('translations cover every message in the English template', () {
    final template = _arb('en').keys.where((k) => !k.startsWith('@')).toSet();
    for (final language in appLanguages.where((l) => l.code != 'en')) {
      final translated =
          _arb(language.code).keys.where((k) => !k.startsWith('@')).toSet();
      expect(template.difference(translated), isEmpty,
          reason: '${language.name} is missing messages');
      expect(translated.difference(template), isEmpty,
          reason: '${language.name} has messages English does not');
    }
  });

  test('every game adapter has setup help in every language', () async {
    // The adapters hand out keys and the UI resolves them; a key the
    // resolver never heard of renders an empty help card, which is the
    // one failure mode the type system can't catch here.
    final adapters = GameRegistry(const [
      Sims1Adapter(),
      Sims2Adapter(),
      Sims3Adapter(),
      SimsMedievalAdapter(),
      Sims4Adapter(),
    ]).adapters;
    for (final language in appLanguages) {
      final strings = await L.delegate.load(Locale(language.code));
      for (final adapter in adapters) {
        expect(strings.setupHelp(adapter.setupHelpKey), isNotEmpty,
            reason: '${language.name} has no setup help for '
                '${adapter.game.name}');
      }
    }
  });

  // Everything the core layer can raise, with stand-in values. It travels
  // as a key because core has no localizations of its own, and the
  // resolver is a switch over strings: a key it never heard of falls
  // through to the bare `key(args)` form, in every language at once.
  const errors = <AppMessage>[
    AppMessage('noModFiles', ['.package', 'peggy_hair.zip']),
    AppMessage('unreadableArchive', ['peggy_hair.zip']),
    AppMessage('noUnpacker', ['RAR', 'peggy_hair.rar']),
    AppMessage('noUnpackerLinux', ['7Z', 'peggy_hair.7z']),
    AppMessage('noUnpackerLinuxRar', ['RAR', 'peggy_hair.rar']),
    AppMessage('unpackFailed', ['peggy_hair.rar']),
    AppMessage('installFailed', ['peggy_hair.package', 'Access is denied']),
    AppMessage('installFailedRaw', ['peggy_hair.package', 'Bad state']),
    AppMessage('fileInUseDelete', ['peggy_hair.package']),
    AppMessage('fileInUseRename', ['peggy_hair.package']),
    AppMessage('fileMissing', ['peggy_hair.package']),
  ];

  test('every error message is written in every language', () async {
    for (final language in appLanguages) {
      final strings = await L.delegate.load(Locale(language.code));
      for (final error in errors) {
        final text = strings.errorText(error);
        expect(text, isNot(contains(error.key)),
            reason: '${language.name} has no wording for ${error.key}');
        // The file name is the whole point of the message; a translation
        // that drops the placeholder leaves the user guessing.
        for (final argument in error.args) {
          expect(text, contains(argument),
              reason: '${language.name} loses "$argument" '
                  'from ${error.key}');
        }
      }
    }
  });

  test('wording the OS already wrote is shown as it came', () async {
    final strings = await L.delegate.load(const Locale('fr'));
    expect(strings.errorText(const AppMessage.verbatim('Access is denied')),
        'Access is denied');
  });

  // No saved preference is the default, so this is what almost everyone
  // gets: the OS language, matched on the language subtag so regional
  // variants land somewhere sensible, and English when nothing matches.
  for (final probe in <({List<Locale> system, String want})>[
    (system: [Locale('de')], want: 'de'),
    (system: [Locale('es', 'MX')], want: 'es'),
    (system: [Locale('pt', 'PT')], want: 'pt'),
    (system: [Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')],
        want: 'zh'),
    // Nothing we ship: English, not whichever language sorts first.
    (system: [Locale('ko')], want: 'en'),
    // Second choice counts when the first is unsupported.
    (system: [Locale('ko'), Locale('fr')], want: 'fr'),
  ]) {
    testWidgets('system ${probe.system} runs the app in ${probe.want}',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 824);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      tester.platformDispatcher.localesTestValue = probe.system;
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      SharedPreferences.setMockInitialValues({'soundEffects': false});
      final tempDir = Directory.systemTemp.createTempSync('mod_manager_auto');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final settings = await SettingsStore.load();
      await tester.runAsync(() async {
        await tester.pumpWidget(ModManagerApp(
            registry: GameRegistry([_FakeAdapter(tempDir)]),
            settings: settings));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      final context = tester.element(find.byType(Directionality).first);
      expect(Localizations.localeOf(context).languageCode, probe.want);
    });
  }

  testWidgets('the saved language wins over the system one', (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(
        {'soundEffects': false, 'localeCode': 'de'});
    final tempDir = Directory.systemTemp.createTempSync('mod_manager_l10n');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    File('${tempDir.path}/cozy_sofa.package').writeAsStringSync('sofa bytes');

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(
          ModManagerApp(registry: registry, settings: settings));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Fake Game-Bibliothek'), findsOneWidget);
    expect(find.text('Einstellungen'), findsOneWidget);
    expect(find.text('Installieren'), findsOneWidget);
    expect(
      Localizations.localeOf(tester.element(find.text('Installieren')))
          .languageCode,
      'de',
    );
  });

  // Translations are longer than their English originals more often than
  // not, and the window can be squeezed to kMinWindowSize; a label that
  // only fits in English is a bug the English tests can never see.
  for (final language in appLanguages) {
    testWidgets('${language.name} fits the minimum window size',
        (tester) async {
      tester.view.physicalSize = kMinWindowSize;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      SharedPreferences.setMockInitialValues(
          {'soundEffects': false, 'localeCode': language.code});
      final tempDir = Directory.systemTemp.createTempSync('mod_manager_size');
      addTearDown(() => tempDir.deleteSync(recursive: true));
      File('${tempDir.path}/cozy_sofa.package').writeAsStringSync('x');

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

      final registry = GameRegistry([_FakeAdapter(tempDir)]);
      final settings = await SettingsStore.load();
      await tester.runAsync(() async {
        await tester.pumpWidget(
            ModManagerApp(registry: registry, settings: settings));
        await Future<void>.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(overflows, isEmpty, reason: 'library in ${language.name}');

      await tester.tap(find.text('cozy sofa'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(overflows, isEmpty, reason: 'mod details in ${language.name}');

      final strings = await L.delegate.load(Locale(language.code));
      await tester.tap(find.text(strings.navSettings).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(overflows, isEmpty, reason: 'settings in ${language.name}');
    });
  }
}
