// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class LDe extends L {
  LDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Sims Mod Manager';

  @override
  String get brandTitle => 'Mod Manager';

  @override
  String get brandSubtitle => 'für Die Sims';

  @override
  String get navLibrary => 'Bibliothek';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get sidebarGames => 'SPIELE';

  @override
  String sidebarNotInstalled(String detail) {
    return 'nicht installiert · $detail';
  }

  @override
  String sidebarModCount(int count, String detail) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mods',
      one: '1 Mod',
    );
    return '$_temp0 · $detail';
  }

  @override
  String get updateAvailable => 'Update verfügbar';

  @override
  String updateClickToDownload(String version) {
    return 'v$version: zum Herunterladen klicken';
  }

  @override
  String get storage => 'Speicher';

  @override
  String storageInMods(String size) {
    return '$size an Mods';
  }

  @override
  String storageFreeOf(String free, String total) {
    return '$free frei von $total';
  }

  @override
  String dropToInstall(String game) {
    return 'Hier ablegen, um in $game zu installieren';
  }

  @override
  String get dropFolders => 'Ordner';

  @override
  String scanningMods(int done, int total) {
    return 'Wir schauen in die Mods rein, nach Bildern und Konflikten… $done von $total';
  }

  @override
  String get skip => 'Überspringen';

  @override
  String libraryTitle(String game) {
    return '$game-Bibliothek';
  }

  @override
  String modsShown(int count, String era) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mods sichtbar',
      one: '1 Mod sichtbar',
    );
    return '$_temp0 · $era';
  }

  @override
  String get learnMore => 'Mehr erfahren';

  @override
  String get dismiss => 'Ausblenden';

  @override
  String get searchMods => 'Mods suchen…';

  @override
  String get install => 'Installieren';

  @override
  String filePickerModsLabel(String game) {
    return '$game-Mods';
  }

  @override
  String get statTotal => 'Gesamt';

  @override
  String get statEnabled => 'Aktiv';

  @override
  String get statDisabled => 'Inaktiv';

  @override
  String get statConflicts => 'Konflikte';

  @override
  String get conflictTooltipActive =>
      'Es werden nur Mods mit Konflikten gezeigt. Klick, um wieder alle zu sehen.';

  @override
  String get conflictTooltip =>
      'Aktive Mods, die sich einen Dateinamen mit einem anderen aktiven Mod teilen, die in mehreren Versionen installiert sind oder die dieselben Spielressourcen überschreiben. Das Spiel behält nur die zuletzt geladene Kopie — manchmal ist das Absicht (Patch-Mods), oft aber nicht.';

  @override
  String get conflictTooltipClickHint => 'Klick, um nur diese Mods zu sehen.';

  @override
  String get filterAll => 'Alle';

  @override
  String get emptyFiltered => 'Keine Mods passen zu den Filtern';

  @override
  String get emptyNoMods => 'Noch keine Mods';

  @override
  String get emptyFilteredHint =>
      'Lösch mal die Suche oder wähl einen anderen Filter.';

  @override
  String emptyNoModsHint(String path) {
    return 'Dieser Ordner wird beobachtet:\n$path';
  }

  @override
  String get openFolder => 'Ordner öffnen';

  @override
  String get conflictBadge => 'Konflikt';

  @override
  String modInFolder(String folder) {
    return 'in $folder';
  }

  @override
  String get modInModsFolder => 'im Mods-Ordner';

  @override
  String setupFoundNoModsFolder(String game) {
    return '$game ist da, aber noch ohne Mods-Ordner';
  }

  @override
  String setupNotFound(String game) {
    return 'Mods-Ordner von $game nicht gefunden';
  }

  @override
  String get setupFoundNoModsFolderBody =>
      'Der Ordner des Spiels liegt auf diesem Computer, er enthält bloß noch keinen Mods-Ordner. Leg ihn unten an oder wähl selbst einen aus.';

  @override
  String get setupNotFoundBody =>
      'Vielleicht ist das Spiel nicht installiert, liegt an einem ungewöhnlichen Ort, oder sein Mods-Ordner existiert noch nicht.';

  @override
  String get foundOnThisComputer => 'AUF DIESEM COMPUTER GEFUNDEN';

  @override
  String get chooseFolder => 'Ordner wählen…';

  @override
  String get createItForMe => 'Für mich anlegen';

  @override
  String willBeCreatedAt(String path) {
    return 'Wird hier angelegt:\n$path';
  }

  @override
  String get checkAgain => 'Nochmal prüfen';

  @override
  String get useThis => 'Diesen nehmen';

  @override
  String get enabled => 'Aktiv';

  @override
  String get disabled => 'Inaktiv';

  @override
  String get showInFileManager => 'Im Explorer zeigen';

  @override
  String get uninstallMod => 'Mod deinstallieren';

  @override
  String uninstallConfirmTitle(String title) {
    return '$title deinstallieren?';
  }

  @override
  String uninstallConfirmBody(String path) {
    return 'Die Datei wird von der Festplatte gelöscht:\n$path';
  }

  @override
  String get cancel => 'Abbrechen';

  @override
  String get uninstall => 'Deinstallieren';

  @override
  String conflictSameNameHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count andere aktive Mods haben denselben Dateinamen:',
      one: 'Ein anderer aktiver Mod hat denselben Dateinamen:',
    );
    return '$_temp0';
  }

  @override
  String conflictVersionHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count andere aktive Mods sehen aus wie andere Versionen dieses Mods:',
      one:
          'Ein anderer aktiver Mod sieht aus wie eine andere Version dieses Mods:',
    );
    return '$_temp0';
  }

  @override
  String conflictResourcesHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count andere aktive Mods überschreiben dieselben Spielressourcen:',
      one: 'Ein anderer aktiver Mod überschreibt dieselben Spielressourcen:',
    );
    return '$_temp0';
  }

  @override
  String sharedResources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gemeinsame Ressourcen',
      one: '1 gemeinsame Ressource',
    );
    return '$_temp0';
  }

  @override
  String get conflictSameNameBody =>
      'Gleiche Dateinamen heißen meistens, dass derselbe Mod zweimal installiert ist, oder dass die Pakete von zwei Creators kollidieren. Das Spiel lädt die überlappenden Ressourcen in unvorhersehbarer Reihenfolge: behalte einen und deaktiviere oder lösche den Rest.';

  @override
  String get conflictVersionBody =>
      'Wenn mehrere Versionen eines Mods installiert sind, lädt das Spiel die überlappenden Ressourcen in unvorhersehbarer Reihenfolge: behalte die neueste und deaktiviere oder lösche die anderen.';

  @override
  String get conflictResourcesBody =>
      'Diese Pakete enthalten Ressourcen mit denselben Kennungen, also behält das Spiel nur die zuletzt geladene Kopie. Das kann Absicht sein — Patch- und Override-Mods überdecken die Ressourcen anderer Mods bewusst —, aber bei Mods, die nichts miteinander zu tun haben, hört einer davon einfach still auf zu funktionieren: behalte den, den du willst, und deaktiviere die anderen.';

  @override
  String modInDirectory(String dir) {
    return 'in $dir';
  }

  @override
  String get factVersion => 'Version';

  @override
  String get factFormat => 'Format';

  @override
  String get factSize => 'Größe';

  @override
  String get factType => 'Typ';

  @override
  String get factModified => 'Geändert';

  @override
  String get statusHeading => 'Status';

  @override
  String get statusEnabledBody =>
      'Dieser Mod ist aktiv: Das Spiel lädt ihn beim nächsten Start.';

  @override
  String statusDisabledBody(String marker) {
    return 'Dieser Mod ist deaktiviert: Die Datei bleibt mit der Markierung „$marker“ auf der Festplatte, damit das Spiel sie überspringt. Du kannst ihn jederzeit wieder aktivieren, es wird nichts gelöscht.';
  }

  @override
  String get fileOnDisk => 'Datei auf der Festplatte';

  @override
  String get insideThePackage => 'Im Paket drin';

  @override
  String resourcesTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ressourcen insgesamt',
      one: '1 Ressource insgesamt',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get sectionModManagement => 'MOD-VERWALTUNG';

  @override
  String get sectionAppearance => 'DARSTELLUNG';

  @override
  String get sectionLanguage => 'SPRACHE';

  @override
  String get sectionPrivacy => 'DATENSCHUTZ';

  @override
  String sectionModsFolder(String game) {
    return 'MODS-ORDNER · $game';
  }

  @override
  String sectionGameCaches(String game) {
    return 'SPIEL-CACHES · $game';
  }

  @override
  String get sectionFeedback => 'FEEDBACK';

  @override
  String get sectionAbout => 'ÜBER';

  @override
  String get prefWarnConflictsTitle => 'Vor Konflikten warnen';

  @override
  String get prefWarnConflictsDesc =>
      'Markiert aktive Mods, die einen Dateinamen doppeln oder dieselben Spielressourcen überschreiben wie ein anderer Mod';

  @override
  String get prefConfirmDeleteTitle => 'Vor dem Deinstallieren nachfragen';

  @override
  String get prefConfirmDeleteDesc =>
      'Nachfragen, bevor eine Mod-Datei von der Festplatte gelöscht wird';

  @override
  String get prefShowDisabledTitle => 'Deaktivierte Mods zeigen';

  @override
  String get prefShowDisabledDesc =>
      'Lässt deaktivierte Mods in der Bibliothek sichtbar, statt sie auszublenden';

  @override
  String get prefScanArtworkTitle => 'In die Mods reinschauen';

  @override
  String get prefScanArtworkDesc =>
      'Schaut beim Laden der Bibliothek in die Mod-Dateien: nach eingebetteten Bildern, nach dem, was drinsteckt, und nach Mods, die dieselben Ressourcen überschreiben';

  @override
  String get prefSoundEffectsTitle => 'UI-Soundeffekte';

  @override
  String get prefSoundEffectsDesc =>
      'Spielt die klassischen Sims-Interface-Sounds bei Klicks, Schaltern und Hinweisen';

  @override
  String get prefAnalyticsTitle => 'Anonyme Nutzungsdaten teilen';

  @override
  String get prefAnalyticsDesc =>
      'Sendet anonyme Nutzungsstatistiken und Absturzberichte, um die App zu verbessern. Nie dabei: Mod-Namen, Dateipfade oder irgendwas Persönliches';

  @override
  String get themeTitle => 'Design';

  @override
  String get themeDesc =>
      'Hell oder dunkel. „System“ folgt der Einstellung deines Computers.';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get languageTitle => 'App-Sprache';

  @override
  String get languageDesc =>
      'Wähl, in welcher Sprache die App erscheint. „System“ folgt der Sprache deines Computers.';

  @override
  String get languageSystem => 'System';

  @override
  String get folderNotFound => 'Nicht gefunden. Wähl einen Ordner';

  @override
  String get folderNotLocated =>
      'Das Spiel (oder sein Mods-Ordner) wurde nicht automatisch gefunden';

  @override
  String folderSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mods',
      one: '1 Mod',
    );
    return '$_temp0 · $size auf der Festplatte';
  }

  @override
  String get customFolder => 'eigener Ordner';

  @override
  String get change => 'Ändern…';

  @override
  String get resetToAuto => 'Zurück auf automatisch';

  @override
  String createDefaultFolderAt(String path) {
    return 'Standardordner (mit den Dateien, die das Spiel braucht) anlegen unter:\n$path';
  }

  @override
  String get createFolder => 'Ordner anlegen';

  @override
  String get alsoFoundOnThisComputer =>
      'Ebenfalls auf diesem Computer gefunden:';

  @override
  String get clearCacheTitle => 'Cache-Dateien löschen';

  @override
  String clearCacheDesc(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Löscht $count Cache-Dateien ($size)',
      one: 'Löscht 1 Cache-Datei ($size)',
    );
    return '$_temp0, damit neu hinzugefügte oder entfernte Inhalte auftauchen; das Spiel baut sie beim nächsten Start neu auf';
  }

  @override
  String get clearCaches => 'Caches löschen';

  @override
  String get reportBugTitle => 'Fehler melden';

  @override
  String get reportBugDesc =>
      'Öffnet einen Fehlerbericht auf GitHub; App-Version, Betriebssystem und aktuelles Spiel sind schon ausgefüllt';

  @override
  String get reportBugButton => 'Melden…';

  @override
  String get suggestFeatureTitle => 'Funktion vorschlagen';

  @override
  String get suggestFeatureDesc =>
      'Fehlt dir was? Sag uns, was den Mod Manager besser machen würde';

  @override
  String get suggestFeatureButton => 'Vorschlagen…';

  @override
  String get wikiTitle => 'Anleitung & FAQ';

  @override
  String get wikiDesc =>
      'Wie man Mods installiert, die Ordnererkennung repariert und mehr, im Wiki des Projekts';

  @override
  String get wikiButton => 'Wiki öffnen';

  @override
  String aboutTagline(String version) {
    return 'Version $version · Die Sims 1-4 unterstützt · SimCity kommt bald';
  }

  @override
  String updateIsAvailable(String version) {
    return 'Version $version ist verfügbar';
  }

  @override
  String get noUpdateFound => 'Kein Update gefunden';

  @override
  String getVersion(String version) {
    return 'v$version holen';
  }

  @override
  String get checkingForUpdates => 'Wird geprüft…';

  @override
  String get checkForUpdates => 'Nach Updates suchen';

  @override
  String get categoryPackage => 'Paket';

  @override
  String get categoryScript => 'Skript';

  @override
  String get categoryObject => 'Objekt';

  @override
  String get categoryArchive => 'Archiv';

  @override
  String get categorySkin => 'Skin';

  @override
  String get categoryTexture => 'Textur';

  @override
  String get categoryWall => 'Wand';

  @override
  String get categoryFloor => 'Boden';

  @override
  String get contentCasParts => 'CAS-Teile';

  @override
  String get contentObjects => 'Objekte';

  @override
  String get contentTunings => 'Tunings';

  @override
  String get contentBehaviors => 'Verhalten';

  @override
  String get contentTextTables => 'Texttabellen';

  @override
  String get contentTextures => 'Texturen';

  @override
  String get contentMeshes => 'Meshes';

  @override
  String get eraClassic => 'Klassisch';

  @override
  String get eraNightlife => 'Nightlife';

  @override
  String get eraAmbitions => 'Traumkarrieren';

  @override
  String get eraModern => 'Modern';

  @override
  String get eraMedieval => 'Mittelalter';

  @override
  String get setupHelpSims1 =>
      'Das allererste Die Sims legt Custom Content in seinem Installationsordner ab, nicht in Dokumente: Objekte kommen in einen Downloads-Ordner neben die Spiel-EXE (z. B. C:\\Program Files (x86)\\Maxis\\The Sims\\Downloads), und diese App sortiert die übrigen Typen automatisch — Skins (.skn/.cmx/.bmp) nach GameData\\Skins, Wände und Böden nach GameData\\Walls und GameData\\Floors. Die Legacy Collection von 2025 funktioniert genauso aus ihrem eigenen Installationsordner (EA Games\\The Sims Legacy oder Steam\\steamapps\\common\\The Sims Legacy Collection). Wenn das Spiel woanders installiert ist (andere Festplatte, eigene Steam-Bibliothek), wähl seinen Downloads-Ordner von Hand aus.';

  @override
  String get setupHelpSims2 =>
      'Die Sims 2 lädt Custom Content aus Dokumente > EA Games > Die Sims 2 > Downloads (die Ultimate Collection nutzt „The Sims 2 Ultimate Collection“, die Legacy Collection von 2025 nutzt „The Sims 2 Legacy“). Den Ordner gibt es unter Umständen erst, wenn du ihn anlegst oder einmal Inhalte installierst. Beim Spielstart beantworte die Frage nach dem Custom Content mit „Ja“, damit Downloads aktiviert sind.';

  @override
  String get setupHelpSims3 =>
      'Die Sims 3 legt seinen Mods-Ordner nicht von selbst an: Es braucht das „Framework“ der Community, also einen Mods > Packages-Ordner in Dokumente > Electronic Arts > Die Sims 3, plus eine Resource.cfg, die dem Spiel sagt, dass es ihn lesen soll. Diese App legt beides für dich an. Bei Disc- oder Wine-Installationen kann der Ordner stattdessen im Spielpaket liegen; nutz „Ordner wählen“, um darauf zu zeigen.';

  @override
  String get setupHelpSims4 =>
      'Die Sims 4 lädt Mods aus Dokumente > Electronic Arts > Die Sims 4 > Mods. Das Spiel legt diesen Ordner beim ersten Start selbst an, starte es also einmal, falls er fehlt. Aktiviere danach im Spiel Optionen > Spieloptionen > Sonstiges > „Benutzerdefinierte Inhalte und Mods aktivieren“ (und „Skript-Mods zulassen“ für .ts4script-Dateien) und starte das Spiel neu.';

  @override
  String get setupHelpSimsMedieval =>
      'Die Sims Mittelalter lädt Mods aus seinem Installationsordner, nicht aus Dokumente: ein Mods > Packages-Ordner neben den Spieldateien (z. B. C:\\Program Files (x86)\\Origin Games\\The Sims Medieval), plus eine Resource.cfg im Installationsordner, die dem Spiel sagt, dass es ihn lesen soll. Diese App legt beides für dich an (unter Programme fragt Windows eventuell nach Administratorrechten). Der Ordner Dokumente > Electronic Arts > The Sims Medieval enthält nur Spielstände; Mods darin bewirken nichts. Bei Wine/CrossOver oder einer eigenen Steam-Bibliothek nutz „Ordner wählen“ und zeig auf den Mods > Packages-Ordner in der Installation.';
}
