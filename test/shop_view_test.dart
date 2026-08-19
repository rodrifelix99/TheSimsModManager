import 'dart:async';
import 'dart:io';
import 'dart:ui' show Size;

import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart'
    show AlertDialog, AnimatedOpacity, IconData, Icons, ListView;
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sims_mod_manager/src/core/game.dart';
import 'package:sims_mod_manager/src/core/game_adapter.dart';
import 'package:sims_mod_manager/src/core/game_registry.dart';
import 'package:sims_mod_manager/src/core/install_destination.dart';
import 'package:sims_mod_manager/src/core/mod.dart';
import 'package:sims_mod_manager/src/core/package_insight.dart';
import 'package:sims_mod_manager/src/services/mod_shop.dart';
import 'package:sims_mod_manager/src/services/settings_store.dart';
import 'package:sims_mod_manager/src/ui/app.dart';
import 'package:sims_mod_manager/src/ui/app_controller.dart';
import 'package:sims_mod_manager/src/ui/shop_view.dart';
import 'package:sims_mod_manager/src/ui/widgets.dart' show SideStrip;

import 'until.dart';

class _FakeAdapter extends FolderBasedGameAdapter {
  _FakeAdapter(this.dir, {this.id = 'fake', this.title = 'Fake Game'});

  final Directory dir;
  final String id;
  final String title;

  /// The real implementation reads files in isolates the widget test's
  /// fake-async zone can't wait on.
  @override
  Future<Map<String, PackageInsight>> inspectMods(
    List<Mod> mods, {
    void Function(int done, int total)? onProgress,
    void Function(Map<String, PackageInsight> found)? onFound,
    bool Function()? isCancelled,
  }) async =>
      const {};

  @override
  Game get game => Game(id: id, name: title, series: 'Test', year: 2024);

  @override
  Set<String> get modFileExtensions => const {'.package'};

  @override
  String get setupHelpKey => 'test adapter';

  @override
  Future<String?> defaultModsPath() async => dir.path;
}

/// Opens the shop, waiting for the library behind it rather than for a
/// round number of milliseconds: an install is a download to a scratch
/// file, a copy into the mods folder and a library refresh behind it, all
/// real IO on a real disk.
Future<void> _openShop(WidgetTester tester, {String game = 'Fake Game'}) async {
  await until(tester, find.text('$game Library'));
  await tester.tap(find.text('The Exchange'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Opens the listing's folder picker and takes [folder] out of it.
Future<void> _pickShopFolder(WidgetTester tester, String folder) async {
  await tester.tap(find.text('Change…'));
  await tester.pump();
  // The list arrives off the disk, so the dialog opens on a spinner.
  final option = find.descendant(
      of: find.byType(AlertDialog), matching: find.text(folder));
  await until(tester, option);
  await tester.tap(option);
  await tester.pump();
  await tester.tap(find.text('Choose'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

ShopMod _listing({
  String id = 'l1',
  String fileName = 'camera_fix.package',
  String gameId = 'fake',
  String name = 'Camera Fix',
  String version = '2.0',
  int downloads = 0,
  String authorUid = 'u1',
  String? group,
  List<String> imagePaths = const [],
}) =>
    ShopMod(
      id: id,
      gameId: gameId,
      name: name,
      version: version,
      description: 'Frees the camera.',
      instructions: 'Restart the game afterwards.',
      authorName: 'plumbob_pat',
      authorUid: authorUid,
      group: group,
      fileName: fileName,
      filePath: 'mods/u1/$id/$fileName',
      fileSizeBytes: 11,
      downloads: downloads,
      imagePaths: imagePaths,
    );

/// A game that routes installs into folders of its own, the way The Sims
/// 1 does. Two destinations is what makes the routing real: the folder
/// question is the adapter's to answer, and the shop must keep out of it.
class _RoutedAdapter extends _FakeAdapter {
  _RoutedAdapter(super.dir);

  /// What makes this one The Sims 1 rather than a game that merely has a
  /// folder of the game's own: one download's mod files are sorted
  /// across these folders, so a subfolder chosen for the install would
  /// take the routed ones with it.
  @override
  bool get sortsModsAcrossFolders => true;

  @override
  Future<List<InstallDestination>> installDestinations(
          Directory modsDir) async =>
      [
        InstallDestination(
            id: 'Downloads', directory: modsDir, label: 'Downloads'),
        InstallDestination(
            id: 'GameData/Skins',
            directory: Directory(p.join(modsDir.path, 'GameData', 'Skins')),
            label: r'GameData\Skins'),
      ];
}

void main() {
  testWidgets('an install from the shop lands in the folder set for the game',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // The folder is not made first: a default set months ago outlives the
    // folder it named, and an install is a worse moment than any to find
    // that out.
    SharedPreferences.setMockInitialValues(
        {'soundEffects': false, 'shopFolder.fake': 'cc/exchange'});
    final tempDir = Directory.systemTemp.createTempSync('shop_folder_pref');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(ModManagerApp(
        registry: registry,
        settings: settings,
        fetchShop: () async => [_listing()],
        downloadShop: (mod, destination, {onProgress}) async {
          destination.writeAsStringSync('shop bytes!');
          onProgress?.call(11, 11);
        },
      ));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await _openShop(tester);
    await tester.runAsync(() => tester.tap(find.text('Install')));
    await tester.pump();
    await until(tester, find.text('Installed'));

    expect(
        File(p.join(tempDir.path, 'cc', 'exchange', 'camera_fix.package'))
            .existsSync(),
        isTrue);
    expect(
        File(p.join(tempDir.path, 'camera_fix.package')).existsSync(), isFalse);
  });

  testWidgets(
      'a folder picked on a listing beats the default, and goes with '
      'the screen', (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('shop_folder_pick');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    // A folder the library knows about, which is where the picker's
    // choices come from for the game on screen.
    Directory(p.join(tempDir.path, 'cc')).createSync();
    File(p.join(tempDir.path, 'cc', 'old.package')).writeAsStringSync('x');

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(ModManagerApp(
        registry: registry,
        settings: settings,
        fetchShop: () async => [_listing()],
        downloadShop: (mod, destination, {onProgress}) async {
          destination.writeAsStringSync('shop bytes!');
          onProgress?.call(11, 11);
        },
      ));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await _openShop(tester);
    await tester.tap(find.text('Camera Fix').last);
    await until(tester, find.text('Installs into'.toUpperCase()));
    expect(find.text('Mods folder'), findsOneWidget);

    await _pickShopFolder(tester, 'cc');
    expect(find.text('cc'), findsOneWidget);
    expect(find.text('Mods folder'), findsNothing);

    // Back to the shelves and in again: the answer was about the install
    // in front of the user, not about the game.
    await tester.tap(find.text('Back to the shelves'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Camera Fix').last);
    await until(tester, find.text('Installs into'.toUpperCase()));
    expect(find.text('Mods folder'), findsOneWidget);

    await _pickShopFolder(tester, 'cc');
    await tester.runAsync(() => tester.tap(find.text('Install')));
    await tester.pump();
    await until(tester, find.text('Installed'));

    expect(File(p.join(tempDir.path, 'cc', 'camera_fix.package')).existsSync(),
        isTrue);
    expect(
        File(p.join(tempDir.path, 'camera_fix.package')).existsSync(), isFalse);
  });

  testWidgets(
      'a game that routes its own installs is never asked about '
      'subfolders', (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // The pref is set and has to be ignored: which folder a file belongs
    // in is this adapter's answer, worked out from the mods folder, and a
    // subfolder under it would take every routed file with it.
    SharedPreferences.setMockInitialValues({
      'soundEffects': false,
      'askWhereToInstall': false,
      'shopFolder.fake': 'cc',
    });
    final tempDir = Directory.systemTemp.createTempSync('shop_folder_routed');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final registry = GameRegistry([_RoutedAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(ModManagerApp(
        registry: registry,
        settings: settings,
        fetchShop: () async => [_listing()],
        downloadShop: (mod, destination, {onProgress}) async {
          destination.writeAsStringSync('shop bytes!');
          onProgress?.call(11, 11);
        },
      ));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await _openShop(tester);
    await tester.tap(find.text('Camera Fix').last);
    await until(tester, find.text('Install'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Installs into'.toUpperCase()), findsNothing);

    await tester.runAsync(() => tester.tap(find.text('Install')));
    await tester.pump();
    await until(tester, find.text('Installed'));

    expect(
        File(p.join(tempDir.path, 'camera_fix.package')).existsSync(), isTrue);
    expect(File(p.join(tempDir.path, 'cc', 'camera_fix.package')).existsSync(),
        isFalse);
  });

  testWidgets('the shop lists a mod and installs it in one click',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('shop_ui');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(ModManagerApp(
        registry: registry,
        settings: settings,
        fetchShop: () async => [_listing()],
        downloadShop: (mod, destination, {onProgress}) async {
          destination.writeAsStringSync('shop bytes!');
          onProgress?.call(11, 11);
        },
      ));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    // Into the shop via the sidebar; the listing renders from the
    // injected fetcher.
    await _openShop(tester);
    expect(find.text('Camera Fix'), findsOneWidget);
    expect(find.text('by plumbob_pat'), findsOneWidget);

    // One click: download lands in the temp scratch, installs into the
    // mods folder, and the button flips to Installed. The tap's
    // onPressed fires refresh()'s unawaited disk-space check, a real
    // Process.run - runAsync keeps its timer out of the fake-async zone.
    await tester.runAsync(() => tester.tap(find.text('Install')));
    await tester.pump();
    await until(tester, find.text('Installed'));

    expect(
        File(p.join(tempDir.path, 'camera_fix.package')).existsSync(), isTrue);
    expect(find.text('Installed'), findsOneWidget);
  });

  testWidgets('a listing downloads to where the user says, installing nothing',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('shop_save');
    final elsewhere = Directory.systemTemp.createTempSync('shop_save_dest');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    addTearDown(() => elsewhere.deleteSync(recursive: true));

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();
    final asked = <String>[];
    final counted = <String>[];
    final chosen = p.join(elsewhere.path, 'simtracker.mdb');

    await tester.runAsync(() async {
      await tester.pumpWidget(ModManagerApp(
        registry: registry,
        settings: settings,
        fetchShop: () async => [_listing(fileName: 'simtracker.mdb')],
        downloadShop: (mod, destination, {onProgress}) async {
          destination.writeAsStringSync('shop bytes!');
          onProgress?.call(11, 11);
        },
        pickSavePath: (suggested) async {
          asked.add(suggested);
          return chosen;
        },
        reportDownload: (id) async => counted.add(id),
      ));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await _openShop(tester);

    // Download lives on the listing's own page, next to Install.
    await tester.tap(find.text('Camera Fix'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Download'), findsOneWidget);

    await tester.runAsync(() => tester.tap(find.text('Download')));
    await tester.pump();
    await until(tester, find.text('Saved'));

    // The dialog was offered the file's own name, the bytes landed where
    // the user pointed, and the mods folder was never touched: the whole
    // point of the button (issue #16).
    expect(asked, ['simtracker.mdb']);
    expect(File(chosen).readAsStringSync(), 'shop bytes!');
    expect(tempDir.listSync(), isEmpty);
    expect(find.text('Install'), findsOneWidget);
    // A take is a take: the creator's count hears about it.
    expect(counted, ['l1']);
  });

  testWidgets('a second press while the save dialog is open does nothing',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('shop_twice');
    final elsewhere = Directory.systemTemp.createTempSync('shop_twice_dest');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    addTearDown(() => elsewhere.deleteSync(recursive: true));

    final settings = await SettingsStore.load();
    final downloads = <String>[];
    final chosen = p.join(elsewhere.path, 'camera_fix.package');
    // Held open the way a real Save-as dialog is: the button is live on
    // screen the whole time it is up.
    final dialog = Completer<String?>();

    await tester.runAsync(() async {
      await tester.pumpWidget(ModManagerApp(
        registry: GameRegistry([_FakeAdapter(tempDir)]),
        settings: settings,
        fetchShop: () async => [_listing()],
        downloadShop: (mod, destination, {onProgress}) async {
          downloads.add(mod.id);
          destination.writeAsStringSync('shop bytes!');
        },
        pickSavePath: (suggested) => dialog.future,
      ));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await _openShop(tester);
    await tester.tap(find.text('Camera Fix'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Two presses, the dialog still up for both.
    await tester.tap(find.text('Download'));
    await tester.pump();
    await tester.tap(find.text('Download'));
    await tester.pump();

    dialog.complete(chosen);
    await until(tester, find.text('Saved'));

    // One download, not two - the guard lands before the dialog rather
    // than after it.
    expect(downloads, ['l1']);
  });

  testWidgets('the shelves mix games, and a listing installs into its own',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final firstDir = Directory.systemTemp.createTempSync('shop_ui_first');
    final secondDir = Directory.systemTemp.createTempSync('shop_ui_second');
    addTearDown(() => firstDir.deleteSync(recursive: true));
    addTearDown(() => secondDir.deleteSync(recursive: true));

    final registry = GameRegistry([
      _FakeAdapter(firstDir),
      _FakeAdapter(secondDir, id: 'second', title: 'Second Game'),
    ]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(ModManagerApp(
        registry: registry,
        settings: settings,
        fetchShop: () async => [
          _listing(),
          _listing(
              id: 'l2',
              gameId: 'second',
              name: 'Kingdom Doors',
              fileName: 'doors.package'),
        ],
        downloadShop: (mod, destination, {onProgress}) async {
          destination.writeAsStringSync('shop bytes!');
          onProgress?.call(11, 11);
        },
      ));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    // The library is on the first game; the shop opens on all of them.
    await until(tester, find.text('Fake Game Library'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('The Exchange'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Camera Fix'), findsOneWidget);
    expect(find.text('Kingdom Doors'), findsOneWidget);

    // The filter chip leaves one game's shelf standing. The game's name
    // is also on its listing's cover badge, and the chips come first.
    await tester.tap(find
        .descendant(
            of: find.byType(ShopView), matching: find.text('Second Game'))
        .first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Camera Fix'), findsNothing);
    expect(find.text('Kingdom Doors'), findsOneWidget);

    // Installing it lands in the second game's folder, not the one the
    // sidebar is pointing at. The tap goes through runAsync like the
    // others: its onPressed fires refresh()'s unawaited disk-space check,
    // a real Process.run whose timer must stay out of the fake-async zone.
    await tester.runAsync(() => tester.tap(find.text('Install')));
    await tester.pump();
    await until(tester, find.text('Installed'));

    expect(File(p.join(secondDir.path, 'doors.package')).existsSync(), isTrue);
    expect(File(p.join(firstDir.path, 'doors.package')).existsSync(), isFalse);
    expect(find.text('Installed'), findsOneWidget);
  });

  testWidgets('empty shelves invite the first creator', (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('shop_ui_empty');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(ModManagerApp(
        registry: registry,
        settings: settings,
        fetchShop: () async => const [],
      ));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await _openShop(tester);
    expect(find.text('The shelves are still empty'), findsOneWidget);
    expect(find.text('Publish your mods'), findsWidgets);
  });

  testWidgets('a dead network shows the retry state, and retry recovers',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('shop_ui_dead');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    var calls = 0;
    await tester.runAsync(() async {
      await tester.pumpWidget(ModManagerApp(
        registry: registry,
        settings: settings,
        fetchShop: () async => ++calls == 1 ? null : [_listing()],
      ));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await _openShop(tester);
    expect(find.text('The Exchange isn’t answering'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Camera Fix'), findsOneWidget);
  });

  testWidgets('a newer version offers an update and badges the library',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // The record a previous session left behind: v1.0 of the listing,
    // and the file it installed sitting in the mods folder.
    SharedPreferences.setMockInitialValues({
      'soundEffects': false,
      'shop.installs': '{"l1": {"game": "fake", "version": "1.0", '
          '"name": "Camera Fix", "files": ["camera_fix.package"]}}',
    });
    final tempDir = Directory.systemTemp.createTempSync('shop_ui_update');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    File(p.join(tempDir.path, 'camera_fix.package'))
        .writeAsStringSync('old bytes');

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(ModManagerApp(
        registry: registry,
        settings: settings,
        // The shelves now carry v2.0 of the same listing.
        fetchShop: () async => [_listing()],
        downloadShop: (mod, destination, {onProgress}) async {
          destination.writeAsStringSync('new bytes');
          onProgress?.call(9, 9);
        },
      ));
      await Future<void>.delayed(const Duration(milliseconds: 400));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // The catalog is fetched on launch because something was installed
    // from it, so the library badges the mod without anyone opening the
    // shop, and the sidebar carries the count.
    expect(find.text('update'), findsOneWidget);
    expect(find.byTooltip('1 of your mods has a new version on The Exchange'),
        findsOneWidget);

    // The listing offers an update rather than reading as done.
    await tester.tap(find.text('The Exchange'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Update'), findsOneWidget);
    expect(find.text('Installed'), findsNothing);

    await tester.runAsync(() async {
      await tester.tap(find.text('Update'));
      await Future<void>.delayed(const Duration(milliseconds: 400));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // The file is replaced, the record moves to the new version, and
    // nothing is left claiming an update.
    expect(File(p.join(tempDir.path, 'camera_fix.package')).readAsStringSync(),
        'new bytes');
    expect(find.text('Installed'), findsOneWidget);
    expect(find.text('Update'), findsNothing);
    expect(settings.shopInstallsJson, contains('"version":"2.0"'));
    // The recorded file survives an update that overwrote it in place,
    // so the mod can still be matched to its listing next time.
    expect(settings.shopInstallsJson, contains('camera_fix.package'));
  });

  testWidgets('demo mode stocks the shelves for screenshots', (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(
        {'soundEffects': false, 'demoLibrary': true});
    final tempDir = Directory.systemTemp.createTempSync('shop_ui_demo');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(ModManagerApp(
        registry: registry,
        settings: settings,
        // Demo mode must not reach the catalog at all: a fetcher that
        // fails here would empty real shelves, and these are invented.
        fetchShop: () async => throw StateError('demo mode must not fetch'),
      ));
      await Future<void>.delayed(const Duration(milliseconds: 400));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('The Exchange'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Cottage Kitchen Set'), findsOneWidget);
    expect(find.text('by pixelpeach'), findsOneWidget);
    // Both of the states worth photographing are on the shelves, next to
    // the plain Install ones.
    expect(find.text('Installed'), findsOneWidget);
    expect(find.text('Install'), findsWidgets);
    // The invented set is one card of five colours, and its own Update
    // is the second of the two on screen: one on a plain listing's
    // button, one on the set card's badge.
    expect(find.text('Linen Curtains'), findsOneWidget);
    expect(find.text('Linen Curtains - Bone'), findsNothing);
    expect(find.text('5 variations'), findsOneWidget);
    expect(find.text('Update'), findsNWidgets(2));
    // And the invented listings carry their own pictures rather than
    // reaching for a URL that would 404 in a screenshot.
    expect(find.byType(widgets.Image), findsWidgets);

    // Nothing invented is ever written to the prefs the real records use.
    expect(settings.shopInstallsJson, isNull);
  });

  testWidgets('uninstalling forgets the shop record', (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'soundEffects': false,
      'confirmDelete': false,
      'shop.installs': '{"l1": {"game": "fake", "version": "2.0", '
          '"name": "Camera Fix", "files": ["camera_fix.package"]}}',
    });
    final tempDir = Directory.systemTemp.createTempSync('shop_ui_forget');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    File(p.join(tempDir.path, 'camera_fix.package')).writeAsStringSync('bytes');

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(ModManagerApp(
        registry: registry,
        settings: settings,
        fetchShop: () async => [_listing()],
      ));
      await Future<void>.delayed(const Duration(milliseconds: 400));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('camera fix'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.runAsync(() async {
      await tester.tap(find.text('Uninstall mod'));
      await Future<void>.delayed(const Duration(milliseconds: 400));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // With its only file gone the record goes too, so the shelves stop
    // claiming the user has it.
    expect(settings.shopInstallsJson, isNot(contains('l1')));
  });

  // --------------------------------------------------------- deep links
  //
  // A simsmodmanager://mod/<id> link from the website. The platform
  // plugin that carries one cannot run under flutter test, which is
  // exactly why ModManagerApp takes a plain Stream<Uri>: here the test is
  // the platform.

  /// The shell every deep-link test below starts from: an app on the
  /// library screen, with the shop fetchers the test wants and a stream
  /// to push addresses down.
  Future<StreamController<Uri>> launch(
    WidgetTester tester, {
    required Directory tempDir,
    required Future<List<ShopMod>?> Function() fetchShop,
    Future<ShopMod?> Function(String id)? fetchListing,
    Future<void> Function(ShopMod mod, File destination,
            {void Function(int received, int total)? onProgress})?
        downloadShop,
  }) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final settings = await SettingsStore.load();
    final links = StreamController<Uri>();
    addTearDown(links.close);

    await tester.runAsync(() async {
      await tester.pumpWidget(ModManagerApp(
        registry: GameRegistry([_FakeAdapter(tempDir)]),
        settings: settings,
        fetchShop: fetchShop,
        fetchListing: fetchListing,
        downloadShop: downloadShop,
        deepLinks: links.stream,
      ));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await until(tester, find.text('Fake Game Library'));
    await tester.pump(const Duration(milliseconds: 400));
    return links;
  }

  /// Waits for what the link was supposed to draw. [shows] is null only
  /// where the point is that nothing happened, and there is no arrival to
  /// wait for.
  Future<void> settle(WidgetTester tester, {Finder? shows}) async {
    if (shows != null) {
      await until(tester, shows);
    } else {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('a link opens the listing without installing it', (tester) async {
    final tempDir = Directory.systemTemp.createTempSync('shop_link');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    final fetched = <String>[];
    final downloaded = <String>[];

    final links = await launch(
      tester,
      tempDir: tempDir,
      fetchShop: () async => [_listing()],
      fetchListing: (id) async {
        fetched.add(id);
        return _listing(id: id);
      },
      downloadShop: (mod, destination, {onProgress}) async {
        downloaded.add(mod.id);
        destination.writeAsStringSync('shop bytes!');
      },
    );

    links.add(Uri.parse('simsmodmanager://mod/l1'));
    await settle(tester, shows: find.text('Back to the shelves'));

    // The listing's own page, reached without ever touching the shelves.
    expect(find.text('Back to the shelves'), findsOneWidget);
    expect(find.text('Camera Fix'), findsOneWidget);
    expect(find.text('Restart the game afterwards.'), findsOneWidget);
    // Already on the shelves we hold, so nothing was fetched for it.
    expect(fetched, isEmpty);
    // The whole point: a link opens a listing. It never installs one.
    expect(downloaded, isEmpty);
    expect(
        File(p.join(tempDir.path, 'camera_fix.package')).existsSync(), isFalse);
    expect(find.text('Install'), findsOneWidget);
  });

  testWidgets('a link to a listing the catalog page missed fetches it',
      (tester) async {
    final tempDir = Directory.systemTemp.createTempSync('shop_link_fetch');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    final fetched = <String>[];

    final links = await launch(
      tester,
      tempDir: tempDir,
      // The catalog is one page deep; a shared link can outlive a
      // listing's place on it.
      fetchShop: () async => const <ShopMod>[],
      fetchListing: (id) async {
        fetched.add(id);
        return _listing(id: id, name: 'Deep Cut');
      },
    );

    links.add(Uri.parse('simsmodmanager://mod/l9'));
    await settle(tester, shows: find.text('Deep Cut'));

    expect(fetched, ['l9']);
    expect(find.text('Deep Cut'), findsOneWidget);
    expect(find.text('Back to the shelves'), findsOneWidget);
  });

  testWidgets('a link to a mod that is gone says so and shows the shelves',
      (tester) async {
    final tempDir = Directory.systemTemp.createTempSync('shop_link_gone');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final links = await launch(
      tester,
      tempDir: tempDir,
      fetchShop: () async => [_listing()],
      fetchListing: (id) async => null,
    );

    links.add(Uri.parse('simsmodmanager://mod/deleted'));
    await settle(tester,
        shows: find.textContaining('isn’t on The Exchange any more'));

    expect(
        find.textContaining('isn’t on The Exchange any more'), findsOneWidget);
    // The shelves, not a dead screen: there is still a shop to browse.
    expect(find.text('Camera Fix'), findsOneWidget);
    expect(find.text('Back to the shelves'), findsNothing);
  });

  testWidgets('a link for a game this build does not know is refused',
      (tester) async {
    final tempDir = Directory.systemTemp.createTempSync('shop_link_game');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final links = await launch(
      tester,
      tempDir: tempDir,
      fetchShop: () async => [_listing()],
      fetchListing: (id) async =>
          _listing(id: id, gameId: 'simcity', name: 'From The Future'),
    );

    links.add(Uri.parse('simsmodmanager://mod/l9'));
    await settle(tester, shows: find.textContaining('doesn’t know yet'));

    expect(find.textContaining('doesn’t know yet'), findsOneWidget);
    expect(find.text('From The Future'), findsNothing);
  });

  testWidgets('an address that is not ours is dropped where it stands',
      (tester) async {
    final tempDir = Directory.systemTemp.createTempSync('shop_link_junk');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    final fetched = <String>[];

    final links = await launch(
      tester,
      tempDir: tempDir,
      fetchShop: () async => [_listing()],
      fetchListing: (id) async {
        fetched.add(id);
        return _listing(id: id);
      },
    );

    // No such verb, and installing is not one we will ever add.
    links.add(Uri.parse('simsmodmanager://install/l1'));
    await settle(tester);

    expect(fetched, isEmpty);
    // Still in the library, where the user was.
    expect(find.text('The Exchange'), findsOneWidget);
    expect(find.text('Back to the shelves'), findsNothing);
  });

  testWidgets('a link arriving from another screen still lands',
      (tester) async {
    final tempDir = Directory.systemTemp.createTempSync('shop_link_settings');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final links = await launch(
      tester,
      tempDir: tempDir,
      fetchShop: () async => [_listing()],
    );

    await tester.tap(find.text('Settings'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    links.add(Uri.parse('simsmodmanager://mod/l1'));
    await settle(tester, shows: find.text('Back to the shelves'));

    expect(find.text('Camera Fix'), findsOneWidget);
    expect(find.text('Back to the shelves'), findsOneWidget);
  });

  // The install itself is driven straight through the controller rather than
  // by tapping: an install draws "Installed" the moment the file lands, well
  // before the call returns, so nothing that happens at the end of one can be
  // waited for through the interface.
  test('installing a listing reports one download, and a demo one reports none',
      () async {
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('shop_counts_ctl');
    addTearDown(() => tempDir.deleteSync(recursive: true));
    final counted = <String>[];

    final controller = AppController(
      registry: GameRegistry([_FakeAdapter(tempDir)]),
      settings: await SettingsStore.load(),
      checkUpdates: () async => null,
      downloadShop: (mod, destination, {onProgress}) async {
        destination.writeAsStringSync('shop bytes!');
      },
      reportDownload: (id) async => counted.add(id),
    );
    await controller.refresh();

    await controller.installShopMod(_listing());
    expect(controller.lastError, isNull);
    expect(counted, ['l1']);

    // Reinstalling is a download the creator did have; the server is what
    // decides it is the same machine twice, not the app.
    await controller.installShopMod(_listing());
    expect(counted, ['l1', 'l1']);

    // The demo shelves are invented mods by invented creators. Nothing on
    // them may ever reach a real listing's count.
    await controller.settings.setDemoLibrary(true);
    await controller.installShopMod(
        _listing(id: 'l9', name: 'Pretend Mod', fileName: 'pretend.package'));
    expect(counted, ['l1', 'l1']);
  });

  testWidgets('a download count shows on the shelf once there is one',
      (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('shop_counts');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(ModManagerApp(
        registry: registry,
        settings: settings,
        fetchShop: () async => [
          _listing(downloads: 1284),
          // Nobody has taken this one, and a card that says so out loud
          // does the creator no favours: the number stays off entirely.
          _listing(id: 'l2', name: 'Quiet Doors', fileName: 'doors.package'),
        ],
      ));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await _openShop(tester);

    // Grouped the way the reader's own language groups numbers, and drawn
    // for the listing that has downloads and nowhere else.
    expect(find.text('1,284'), findsOneWidget);
    expect(find.text('0'), findsNothing);

    // The detail panel says it in words, next to the size and the date.
    await tester.tap(find.text('Camera Fix'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('DOWNLOADS'), findsOneWidget);
    expect(find.text('1,284'), findsOneWidget);
  });

  testWidgets(
      'a creator\'s set is one card, and the picker installs the '
      'colour that was chosen', (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('shop_set');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(ModManagerApp(
        registry: registry,
        settings: settings,
        fetchShop: () async => [
          for (final shade in ['Bone', 'Clay', 'Fern'])
            _listing(
              id: 'set-$shade',
              name: 'Linen Curtains - $shade',
              group: 'Linen Curtains',
              fileName: 'curtains_${shade.toLowerCase()}.package',
              downloads: 100,
            ),
          _listing(id: 'lone', name: 'Quiet Doors', fileName: 'doors.package'),
        ],
        downloadShop: (mod, destination, {onProgress}) async {
          destination.writeAsStringSync('shop bytes!');
          onProgress?.call(11, 11);
        },
      ));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await _openShop(tester);

    // Three listings, one card: the set's name, its count, and none of
    // the colours spelled out on the shelf. The lone listing is
    // untouched, and the header still counts what is on offer.
    expect(find.text('Linen Curtains'), findsOneWidget);
    expect(find.text('Linen Curtains - Bone'), findsNothing);
    expect(find.text('3 variations'), findsOneWidget);
    expect(find.text('Quiet Doors'), findsOneWidget);
    expect(find.text('4 mods on the shelves'), findsOneWidget);
    // A set card offers no Install - which colour would it be? - while
    // the lone listing still does. Its takes are the three added up.
    expect(find.text('Install'), findsOneWidget);
    expect(find.text('300'), findsOneWidget);

    // The page behind it is the set's, with the colours to choose from.
    await tester.tap(find.text('Linen Curtains'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('PICK A VARIATION'), findsOneWidget);
    expect(find.text('Bone'), findsOneWidget);
    expect(find.text('Clay'), findsOneWidget);
    expect(find.text('Fern'), findsOneWidget);

    // Picking one and installing it takes that colour and no other.
    await tester.tap(find.text('Fern'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.text('Install'));
    await until(tester, find.text('Installed'));

    expect(File(p.join(tempDir.path, 'curtains_fern.package')).existsSync(),
        isTrue);
    expect(File(p.join(tempDir.path, 'curtains_bone.package')).existsSync(),
        isFalse);

    // And the shelf card behind it says the set has been started.
    await tester.tap(find.text('Back to the shelves'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Installed'), findsOneWidget);
  });

  testWidgets('every screenshot of a listing can be reached', (tester) async {
    tester.view.physicalSize = const Size(1280, 824);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('shop_shots');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final registry = GameRegistry([_FakeAdapter(tempDir)]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(ModManagerApp(
        registry: registry,
        settings: settings,
        fetchShop: () async => [
          _listing(imagePaths: [
            for (var i = 1; i <= 10; i++) 'mods/u1/l1/images/$i.png',
          ]),
        ],
      ));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await _openShop(tester);
    await tester.tap(find.text('Camera Fix'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // The gallery column is 380px wide and a thumbnail is 86 of them, so
    // a strip that only scrolled sideways left the fifth onwards past the
    // edge with no mouse wheel that could reach along it.
    final panel = tester.getRect(find.byType(ShopView));
    for (var i = 0; i < 10; i++) {
      final thumb = find.byKey(widgets.ValueKey('shop-shot-$i'));
      expect(thumb, findsOneWidget, reason: 'screenshot ${i + 1}');
      // Compared edge by edge rather than with Rect.contains, which is
      // exclusive of right and bottom: a chip sitting flush against the
      // panel's edge is on screen, and would fail that test.
      final box = tester.getRect(thumb);
      expect(box.left >= panel.left, isTrue, reason: 'screenshot ${i + 1}');
      expect(box.top >= panel.top, isTrue, reason: 'screenshot ${i + 1}');
      expect(box.right <= panel.right, isTrue, reason: 'screenshot ${i + 1}');
      expect(box.bottom <= panel.bottom, isTrue, reason: 'screenshot ${i + 1}');
    }

    // And the last one takes the tap that puts it in the big frame.
    await tester.tap(find.byKey(const widgets.ValueKey('shop-shot-9')));
    await tester.pump();
  });

  testWidgets('the game filter answers a mouse wheel and its arrows',
      (tester) async {
    // Narrow on purpose: this is where the row runs off the edge, which
    // is the whole reason it can be scrolled at all.
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'soundEffects': false});
    final tempDir = Directory.systemTemp.createTempSync('shop_filter_strip');
    addTearDown(() => tempDir.deleteSync(recursive: true));

    // Nine games, as the registry carries today.
    final registry = GameRegistry([
      _FakeAdapter(tempDir),
      for (var i = 2; i <= 9; i++)
        _FakeAdapter(tempDir, id: 'g$i', title: 'Game Number $i'),
    ]);
    final settings = await SettingsStore.load();

    await tester.runAsync(() async {
      await tester.pumpWidget(ModManagerApp(
        registry: registry,
        settings: settings,
        fetchShop: () async => [_listing()],
      ));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await _openShop(tester);

    final strip = find.byType(SideStrip);
    final row = find.descendant(of: strip, matching: find.byType(ListView));
    double offset() => tester.widget<ListView>(row).controller!.offset;
    expect(offset(), 0);

    // The plain vertical wheel, which is all a desktop mouse has.
    final mouse = TestPointer(1, PointerDeviceKind.mouse);
    final over = tester.getCenter(strip);
    await tester.sendEventToBinding(mouse.hover(over));
    await tester.sendEventToBinding(mouse.scroll(const Offset(0, 120)));
    await tester.pump();
    expect(offset(), 120);

    // Which also brings the arrow back to where it started.
    double fade(IconData icon) => tester
        .widget<AnimatedOpacity>(find.ancestor(
            of: find.byIcon(icon), matching: find.byType(AnimatedOpacity)))
        .opacity;
    expect(fade(Icons.chevron_left_rounded), 1);

    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(offset(), greaterThan(120));

    // And pressing on until there is nothing left takes it away. The
    // loop stops on the arrow itself rather than after a set number of
    // presses: it goes when the strip does, and pressing where it was
    // is a tap on nothing.
    for (var i = 0; i < 20 && fade(Icons.chevron_right_rounded) == 1; i++) {
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(fade(Icons.chevron_right_rounded), 0);
    // The last chip is on screen: the game's name is also a shelf
    // heading below, so the finder stays inside the strip.
    expect(
        find.descendant(of: strip, matching: find.text('Game Number 9')),
        findsOneWidget);
  });
}
