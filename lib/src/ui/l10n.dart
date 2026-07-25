import 'dart:ui' show Locale;

import '../../l10n/app_localizations.dart';

export '../../l10n/app_localizations.dart' show L;

/// The languages the app ships, in the order the Settings picker lists
/// them: English first, then the rest by how many people the Sims
/// modding scene has in them. Each entry's [name] is written in that
/// language, because a picker that says "German" to someone who only
/// reads German is no help at all.
const appLanguages = <({String code, String name})>[
  (code: 'en', name: 'English'),
  (code: 'zh', name: '简体中文'),
  (code: 'es', name: 'Español'),
  (code: 'pt', name: 'Português (Brasil)'),
  (code: 'fr', name: 'Français'),
  (code: 'de', name: 'Deutsch'),
  (code: 'it', name: 'Italiano'),
  (code: 'ru', name: 'Русский'),
  (code: 'pl', name: 'Polski'),
  (code: 'ja', name: '日本語'),
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

/// Native name of [code], or the code itself for anything unexpected.
String languageName(String code) => appLanguages
    .firstWhere((l) => l.code == code, orElse: () => (code: code, name: code))
    .name;

/// Lookups for the strings that don't live in the widget that shows them:
/// adapters hand out stable English keys ([Mod.category], the content
/// labels from the package scan, [GameAdapter.setupHelpKey]) and the UI
/// translates them here. Keys the ARB files don't know are shown as-is,
/// so a new game or a newly recognized resource type degrades to English
/// instead of blanking out.
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

  String eraName(String key) => switch (key) {
        'classic' => eraClassic,
        'nightlife' => eraNightlife,
        'ambitions' => eraAmbitions,
        'modern' => eraModern,
        'medieval' => eraMedieval,
        _ => key,
      };

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
