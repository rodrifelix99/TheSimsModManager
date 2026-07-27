import 'dart:ui' show Locale;

import '../../l10n/app_localizations.dart';
import '../core/app_message.dart';

export '../../l10n/app_localizations.dart' show L;

/// The languages the app ships, in the order the Settings picker lists
/// them: English first, then the rest by how many people the Sims
/// modding scene has in them. Each entry's [name] is written in that
/// language, because a picker that says "German" to someone who only
/// reads German is no help at all. [by] is the handle Settings credits
/// for the translation; the README table says the same thing and the two
/// are kept in step by hand.
const appLanguages = <({String code, String name, String by})>[
  (code: 'en', name: 'English', by: 'rodrifelix99'),
  (code: 'zh', name: '简体中文', by: 'xiaoyu_sims'),
  (code: 'es', name: 'Español', by: 'marisol_plumbob'),
  (code: 'pt', name: 'Português (Brasil)', by: 'rodrifelix99'),
  (code: 'fr', name: 'Français', by: 'clodesims'),
  (code: 'de', name: 'Deutsch', by: 'plumbobjonas'),
  (code: 'it', name: 'Italiano', by: 'giuliapixel89'),
  (code: 'ru', name: 'Русский', by: 'verasimka'),
  (code: 'pl', name: 'Polski', by: 'kasia_pxl'),
  (code: 'ja', name: '日本語', by: 'mochi_simjp'),
];

/// What [MaterialApp.supportedLocales] gets, in [appLanguages] order rather
/// than the generated `L.supportedLocales` order. The generator sorts
/// alphabetically, which puts German first, and Flutter falls back to the
/// *first* supported locale when a system language matches nothing at all -
/// so shipping the generated list hands a Korean or Turkish machine a German
/// app. English first makes the fallback English.
final List<Locale> appSupportedLocales = [
  for (final language in appLanguages) Locale(language.code),
];

/// Lookups for the strings that don't live in the widget that shows them:
/// adapters hand out stable English keys ([Mod.category], the content
/// labels from the package scan, [GameAdapter.setupHelpKey]), and what
/// went wrong with an install or a mod file arrives as an [AppMessage].
/// The UI translates them here. Keys the ARB files don't know are shown
/// as-is, so a new game or a newly recognized resource type degrades to
/// English instead of blanking out.
extension AppText on L {
  String categoryName(String key) => switch (key) {
        'Package' => categoryPackage,
        'Script' => categoryScript,
        'Object' => categoryObject,
        'Archive' => categoryArchive,
        'Skin' => categorySkin,
        'Texture' => categoryTexture,
        'Wall' => categoryWall,
        'Floor' => categoryFloor,
        _ => key,
      };

  String contentLabel(String key) => switch (key) {
        'CAS parts' => contentCasParts,
        'objects' => contentObjects,
        'tunings' => contentTunings,
        'behaviors' => contentBehaviors,
        'text tables' => contentTextTables,
        'textures' => contentTextures,
        'meshes' => contentMeshes,
        _ => key,
      };

  /// What the game still needs before it runs any of this. The adapter
  /// names the requirement, not the wording; a key with no translation
  /// yet is not worth a banner, so it draws nothing.
  String? requirement(String key) => switch (key) {
        'medievalModLoader' => requirementMedievalModLoader,
        'sims4ModsOff' => requirementSims4ModsOff,
        'sims4ScriptModsOff' => requirementSims4ScriptModsOff,
        _ => null,
      };

  String eraName(String key) => switch (key) {
        'classic' => eraClassic,
        'nightlife' => eraNightlife,
        'ambitions' => eraAmbitions,
        'modern' => eraModern,
        'medieval' => eraMedieval,
        _ => key,
      };

  /// What went wrong, in the user's language. The failing layer is core,
  /// which has no localizations, so it hands over a key and the values
  /// that go in it (see [AppMessage]); wording it had no key for - an OS
  /// error, an exception nobody foresaw - comes through untouched.
  String errorText(AppMessage message) {
    final text = message.text;
    if (text != null) return text;
    String arg(int i) => i < message.args.length ? message.args[i] : '';
    return switch (message.key) {
      'noModFiles' => errorNoModFiles(arg(0), arg(1)),
      'unreadableArchive' => errorUnreadableArchive(arg(0)),
      'noUnpacker' => errorNoUnpacker(arg(0), arg(1)),
      'noUnpackerLinux' => errorNoUnpackerLinux(arg(0), arg(1)),
      'noUnpackerLinuxRar' => errorNoUnpackerLinuxRar(arg(0), arg(1)),
      'unpackFailed' => errorUnpackFailed(arg(0)),
      'sims3PackUnreadable' => errorSims3PackUnreadable(arg(0)),
      'sims3PackWorld' => errorSims3PackWorld(arg(0)),
      'sims3PackLibrary' => errorSims3PackLibrary(arg(0)),
      'installFailed' => errorInstallFailed(arg(0), arg(1)),
      'installFailedRaw' => errorInstallFailedRaw(arg(0), arg(1)),
      'fileInUseDelete' => errorFileInUseDelete(arg(0)),
      'fileInUseRename' => errorFileInUseRename(arg(0)),
      'fileMissing' => errorFileMissing(arg(0)),
      'errorNoWriteAccess' => errorNoWriteAccess(arg(0)),
      'shopDownloadFailed' => errorShopDownload(arg(0)),
      'shopNeedsFolder' => shopNeedsFolder(arg(0)),
      'shopListingNotFound' => errorShopListingNotFound,
      'shopListingUnknownGame' => errorShopListingUnknownGame,
      _ => '$message',
    };
  }

  /// The game's "where do mods live" guidance. [key] comes from the
  /// adapter, so the UI still knows nothing about concrete games; an
  /// adapter without a translation yet falls back to the empty string
  /// and the surrounding cards simply have nothing to say.
  String setupHelp(String key) => switch (key) {
        'sims1' => setupHelpSims1,
        'sims2' => setupHelpSims2,
        'sims3' => setupHelpSims3,
        'sims4' => setupHelpSims4,
        'simsmedieval' => setupHelpSimsMedieval,
        _ => '',
      };
}
