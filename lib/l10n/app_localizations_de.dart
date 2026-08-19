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
  String get brandSubtitle => 'für Die Sims und SimCity';

  @override
  String get navLibrary => 'Bibliothek';

  @override
  String get navShop => 'The Exchange';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get shopAlphaBadge => 'ALPHA';

  @override
  String get shopTagline =>
      'Mods aus der Community, mit einem Klick installiert.';

  @override
  String shopListingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mods im Regal',
      one: '1 Mod im Regal',
    );
    return '$_temp0';
  }

  @override
  String get shopRefresh => 'Aktualisieren';

  @override
  String get shopPublish => 'Deine Mods veröffentlichen';

  @override
  String get shopLoadFailedTitle => 'The Exchange meldet sich nicht';

  @override
  String get shopLoadFailedBody =>
      'Die Regale ließen sich nicht laden. Prüf deine Verbindung und versuch es nochmal.';

  @override
  String get shopRetry => 'Nochmal versuchen';

  @override
  String get shopEmptyTitle => 'Die Regale sind noch leer';

  @override
  String get shopEmptyBody =>
      'The Exchange hat gerade erst eröffnet und noch hat niemand etwas veröffentlicht. So neu ist das hier. Du baust selbst Mods? Deine könnte die erste im Regal sein!';

  @override
  String get shopAllGames => 'Alle Spiele';

  @override
  String get shopShowAllGames => 'Alle Spiele zeigen';

  @override
  String shopEmptyGameTitle(String game) {
    return 'Noch nichts für $game';
  }

  @override
  String shopEmptyGameBody(String game) {
    return 'Für andere Spiele liegt schon was im Regal, für $game hat aber noch niemand etwas veröffentlicht. Du hast eine Mod? Dann mach den Anfang!';
  }

  @override
  String shopBy(String author) {
    return 'von $author';
  }

  @override
  String get shopInstalled => 'Installiert';

  @override
  String get shopUpdate => 'Aktualisieren';

  @override
  String get shopUpdateBadge => 'Update';

  @override
  String shopUpdatesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Für $count deiner Mods gibt es neue Versionen auf The Exchange',
      one: 'Für 1 deiner Mods gibt es eine neue Version auf The Exchange',
    );
    return '$_temp0';
  }

  @override
  String get shopUpdateHeading => 'Von diesem Mod gibt es eine neue Version';

  @override
  String shopUpdateBody(String version, String author) {
    return '$author hat v$version auf The Exchange veröffentlicht. Beim Aktualisieren werden deine jetzigen Dateien ersetzt.';
  }

  @override
  String get shopUpdateSeeListing => 'Zum Eintrag';

  @override
  String get shopInstalling => 'Wird installiert…';

  @override
  String get shopInstallNotes => 'Installationshinweise';

  @override
  String get shopCreatorNudge =>
      'Du baust selbst Mods? Auf The Exchange zu veröffentlichen ist kostenlos, und Spieler installieren deine Sachen mit einem Klick.';

  @override
  String shopNeedsFolder(String game) {
    return 'Richte zuerst den Mods-Ordner für $game ein. Der Bibliothek-Tab führt dich durch.';
  }

  @override
  String shopVariations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Varianten',
      one: '1 Variante',
    );
    return '$_temp0';
  }

  @override
  String get shopSaveFile => 'Herunterladen';

  @override
  String get shopSaving => 'Wird geladen…';

  @override
  String get shopSaved => 'Gespeichert';

  @override
  String get shopSaveHint =>
      'Installieren legt die Dateien direkt in deinen Mods-Ordner. Herunterladen speichert nur die Datei, da wo du sie haben willst.';

  @override
  String get shopRequires => 'Braucht diese Packs';

  @override
  String get shopRequirementMet => 'Installiert';

  @override
  String get shopRequirementDisabled => 'Ausgeschaltet';

  @override
  String get shopRequirementMissing => 'Nicht installiert';

  @override
  String get shopRequirementUnknown => 'Nicht geprüft';

  @override
  String get shopRequirementsNote =>
      'Du kannst ihn trotzdem installieren — er macht nur wenig, solange die Packs fehlen.';

  @override
  String get shopRequirementsOffNote =>
      'Eines davon ist ausgeschaltet. Schalte es im Tab „Packs“ wieder ein.';

  @override
  String get shopRequirementsUnknownNote =>
      'Wir konnten die Packs dieses Spiels auf diesem Rechner nicht prüfen — das hier ist also die Angabe der Erstellerin oder des Erstellers.';

  @override
  String get shopDestination => 'Installiert nach';

  @override
  String get shopVariationPick => 'Wähl eine Variante';

  @override
  String get shopBack => 'Zurück zu den Regalen';

  @override
  String get shopCopyLink => 'Link kopieren';

  @override
  String get shopLinkCopied => 'Link kopiert';

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
  String get viewGrid => 'Raster';

  @override
  String get viewList => 'Liste';

  @override
  String get viewFolders => 'Ordner';

  @override
  String get sortTooltip => 'Sortieren';

  @override
  String get sortByName => 'Name (A–Z)';

  @override
  String get sortByRecent => 'Zuletzt geändert';

  @override
  String get sortBySize => 'Größte zuerst';

  @override
  String get sortDisabledLast => 'Deaktivierte ans Ende';

  @override
  String get libraryRefresh => 'Aktualisieren';

  @override
  String get libraryRootFolder => 'Mods-Ordner';

  @override
  String get selectionTooltip => 'Auswählen';

  @override
  String selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausgewählt',
      one: '1 ausgewählt',
    );
    return '$_temp0';
  }

  @override
  String get selectionSelectAll => 'Alle auswählen';

  @override
  String get selectionClear => 'Auswahl aufheben';

  @override
  String get selectionEnable => 'Aktivieren';

  @override
  String get selectionDisable => 'Deaktivieren';

  @override
  String selectionProgress(int done, int total) {
    return '$done von $total';
  }

  @override
  String selectionDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mods deinstallieren?',
      one: '1 Mod deinstallieren?',
    );
    return '$_temp0';
  }

  @override
  String selectionDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Alle $count Dateien werden von der Festplatte gelöscht. Das lässt sich nicht rückgängig machen.',
      one:
          'Die Datei wird von der Festplatte gelöscht. Das lässt sich nicht rückgängig machen.',
    );
    return '$_temp0';
  }

  @override
  String get selectionMove => 'Verschieben nach…';

  @override
  String get newFolder => 'Neuer Ordner';

  @override
  String newFolderIn(String folder) {
    return 'In $folder';
  }

  @override
  String get newFolderHint => 'Ordnername';

  @override
  String get create => 'Anlegen';

  @override
  String get move => 'Verschieben';

  @override
  String moveTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mods wohin verschieben?',
      one: '1 Mod wohin verschieben?',
    );
    return '$_temp0';
  }

  @override
  String get moveBody =>
      'Die Dateien wandern auf der Festplatte in einen anderen Ordner. Sonst ändert sich nichts - was aus ist, bleibt aus.';

  @override
  String get installFolderTitle => 'Welcher Ordner?';

  @override
  String installFolderBody(String game) {
    return 'Wo die Dateien in deinem Mods-Ordner für $game landen.';
  }

  @override
  String get installFolderChoose => 'Auswählen';

  @override
  String get installFolderEmpty =>
      'Noch keine Unterordner. Leg einen an, oder lass alles im Mods-Ordner.';

  @override
  String get folderEmptySection => 'Hier ist noch nichts drin';

  @override
  String get install => 'Installieren';

  @override
  String filePickerModsLabel(String game) {
    return '$game-Mods';
  }

  @override
  String get installWhereTitle => 'Wo soll das hin?';

  @override
  String installWhereBody(String game) {
    return '$game liest Mods aus mehreren Ordnern. Die App kann es an der Datei erkennen, oder du sagst, wo es hingehört.';
  }

  @override
  String get installWhereSorted => 'Entscheide du';

  @override
  String get installWhereSortedDesc =>
      'Nimmt die Ordner, die im Download stecken, und sortiert den Rest nach Dateityp.';

  @override
  String get installWhereRemember => 'Nicht mehr fragen';

  @override
  String get destinationSims1Downloads =>
      'Objekte, Hacks und die meisten Downloads.';

  @override
  String get destinationSims1Global =>
      'Änderungen, die im ganzen Grundspiel greifen.';

  @override
  String get destinationSims1Objects =>
      'Änderungen an den Objektdateien des Spiels selbst.';

  @override
  String get destinationSims1Skins =>
      'Alltagsskins und Köpfe. Die tauchen im Erstelle einen Sim auf.';

  @override
  String get destinationSims1SkinsBuy =>
      'Kleidung, die es in den Läden auf Gemeinschaftsgrundstücken gibt.';

  @override
  String get destinationSims1Walls => 'Wandbeläge.';

  @override
  String get destinationSims1Floors => 'Bodenbeläge.';

  @override
  String get destinationSims1Roofs => 'Dachtexturen.';

  @override
  String get prefAskWhereTitle => 'Vor dem Installieren fragen';

  @override
  String get prefAskWhereDesc =>
      'Dieses Spiel liest Mods aus mehreren Ordnern. Wähle jedes Mal selbst, statt es der App zu überlassen';

  @override
  String get statTotal => 'Gesamt';

  @override
  String get statEnabled => 'Aktiv';

  @override
  String get statDisabled => 'Inaktiv';

  @override
  String get statConflicts => 'Konflikte';

  @override
  String get statTotalTooltip =>
      'Alle Mods in diesem Ordner, aktiv oder nicht.';

  @override
  String get statTotalTooltipClear =>
      'Alle Mods in diesem Ordner. Klick, um Suche und Filter fallen zu lassen.';

  @override
  String get statEnabledTooltip => 'Mods, die das Spiel lädt.';

  @override
  String get statEnabledTooltipActive =>
      'Es werden nur aktive Mods gezeigt. Klick, um wieder alle zu sehen.';

  @override
  String get statDisabledTooltip =>
      'Mods, die im Ordner liegen, aber ausgeschaltet sind.';

  @override
  String get statDisabledTooltipActive =>
      'Es werden nur inaktive Mods gezeigt. Klick, um wieder alle zu sehen.';

  @override
  String get conflictTooltipActive =>
      'Es werden nur Mods mit Konflikten gezeigt. Klick, um wieder alle zu sehen.';

  @override
  String get conflictTooltip =>
      'Aktive Mods, die sich einen Dateinamen mit einem anderen aktiven Mod teilen, die in mehreren Versionen installiert sind oder die dieselben Spielressourcen überschreiben. Das Spiel behält nur die zuletzt geladene Kopie: manchmal ist das Absicht (Patch-Mods), oft aber nicht.';

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
  String get duplicateBadge => 'Kopie';

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
  String conflictSameFileHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count andere aktive Mods sind exakt dieselbe Datei:',
      one: 'Ein anderer aktiver Mod ist exakt dieselbe Datei:',
    );
    return '$_temp0';
  }

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
  String get conflictSameFileBody =>
      'Der Duplikat-Scan hat diese Dateien gelesen und sie stimmen Byte für Byte überein. Das sind also nicht zwei Mods, die sich streiten, sondern derselbe Download, der mehrfach in deinem Ordner liegt. Behalte einen und lösche den Rest: im Spiel ändert sich nichts und du bekommst den Speicher zurück.';

  @override
  String get conflictSameNameBody =>
      'Gleiche Dateinamen heißen meistens, dass derselbe Mod zweimal installiert ist, oder dass die Pakete von zwei Creators kollidieren. Das Spiel lädt die überlappenden Ressourcen in unvorhersehbarer Reihenfolge: behalte einen und deaktiviere oder lösche den Rest.';

  @override
  String get conflictVersionBody =>
      'Wenn mehrere Versionen eines Mods installiert sind, lädt das Spiel die überlappenden Ressourcen in unvorhersehbarer Reihenfolge: behalte die neueste und deaktiviere oder lösche die anderen.';

  @override
  String get conflictResourcesBody =>
      'Diese Pakete enthalten Ressourcen mit denselben Kennungen, also behält das Spiel nur die zuletzt geladene Kopie. Das kann Absicht sein (Patch- und Override-Mods überdecken die Ressourcen anderer Mods bewusst), aber bei Mods, die nichts miteinander zu tun haben, hört einer davon einfach still auf zu funktionieren: behalte den, den du willst, und deaktiviere die anderen.';

  @override
  String get conflictIgnore => 'Ignorieren';

  @override
  String get conflictIgnoreTooltip =>
      'Wenn dieser Konflikt Absicht ist, blende ihn aus. Am Mod ändert sich nichts, und du holst dir die Warnung auf dieser Seite oder in den Einstellungen zurück.';

  @override
  String get conflictRestore => 'Zurückholen';

  @override
  String advisoryBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count deiner Mods haben bekannte Probleme',
      one: 'Einer deiner Mods hat ein bekanntes Problem',
    );
    return '$_temp0';
  }

  @override
  String get advisoryShow => 'Mal ansehen';

  @override
  String get advisoryShowAll => 'Alle Mods anzeigen';

  @override
  String get advisoryBadge => 'Problem';

  @override
  String get advisoryBrokenHeading => 'Dieser Mod gilt als kaputt';

  @override
  String get advisoryBrokenBody =>
      'Andere Spieler melden, dass dieser hier das Spiel lahmlegt. Ihn zu deaktivieren ist der schnellste Weg herauszufinden, ob er schuld ist.';

  @override
  String get advisoryOutdatedHeading =>
      'Es gibt eine neuere Version von diesem Mod';

  @override
  String get advisoryOutdatedBody =>
      'Genau die Version, die du hast, macht Ärger. Die neueste vom Creator zu holen sollte reichen.';

  @override
  String get advisoryCautionHeading => 'Behalt den mal im Auge';

  @override
  String get advisoryCautionBody =>
      'Bei den meisten läuft er, aber er ist dafür bekannt, sich manchmal danebenzubenehmen. Zum Deaktivieren, wenn du einen Fehler suchst.';

  @override
  String advisorySince(String since) {
    return 'Seit $since';
  }

  @override
  String get advisoryOpenLink => 'Seite des Creators öffnen';

  @override
  String get advisorySource =>
      'Von anderen Spielern gemeldet, nicht vom Spiel.';

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
  String get factDownloads => 'Downloads';

  @override
  String get factIgnoredConflicts => 'Ignoriert';

  @override
  String ignoredConflictsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Konflikte',
      one: '1 Konflikt',
    );
    return '$_temp0';
  }

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
  String sectionIgnoredConflicts(String game) {
    return 'IGNORIERTE KONFLIKTE · $game';
  }

  @override
  String sectionShopFolder(String game) {
    return 'THE EXCHANGE · $game';
  }

  @override
  String get prefShopFolderTitle => 'Wohin Mods aus The Exchange kommen';

  @override
  String prefShopFolderDesc(String folder) {
    return 'Installationen landen in $folder';
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
  String get prefConflictKindsTitle => 'Vor welchen Konflikten warnen';

  @override
  String get prefConflictKindsDesc =>
      'Schalte die Arten ab, die du nicht markiert haben willst. Der Rest läuft weiter wie bisher';

  @override
  String get conflictKindSameFile => 'Identische Kopien';

  @override
  String get conflictKindSameName => 'Gleicher Dateiname';

  @override
  String get conflictKindVersions => 'Verschiedene Versionen';

  @override
  String get conflictKindResources => 'Geteilte Ressourcen';

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
  String get prefDisabledSuffixTitle => 'Markierung für deaktivierte Mods';

  @override
  String get prefDisabledSuffixDesc =>
      'Was an den Dateinamen gehängt wird, wenn du einen Mod ausschaltest. Stell es passend zu einem anderen Manager ein (CC Magic nutzt .off); die App liest sowieso beides, und schon deaktivierte Mods behalten ihren Namen';

  @override
  String get prefDisabledSuffixInvalid =>
      'Muss ein Punkt und ein paar Buchstaben oder Zahlen sein, etwa .off';

  @override
  String get prefExperimentalPacksTitle => 'Experimentelle Pack-Schalter';

  @override
  String get prefExperimentalPacksDesc =>
      'Lässt die Packs dieses Spiels ausschalten. Mit dieser Ausgabe ungetestet, und eine mit einem Pack gespielte Nachbarschaft kann ohne es kaputtgehen - sichere vorher deine Spielstände';

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
  String get appThemeTitle => 'App-Theme';

  @override
  String get appThemeDesc =>
      'Wie die ganze App aussieht. Bleibt gleich, egal welches Spiel du gerade verwaltest.';

  @override
  String get appThemeDefault => 'Standard';

  @override
  String get languageTitle => 'App-Sprache';

  @override
  String get languageDesc =>
      'Wähl, in welcher Sprache die App erscheint. „System“ folgt der Sprache deines Computers.';

  @override
  String get languageSystem => 'System';

  @override
  String get translatorsTitle => 'Übersetzt von';

  @override
  String get translatorsDesc =>
      'Die App spricht zwölf Sprachen dank dieser Simmer.';

  @override
  String get sectionStartup => 'START';

  @override
  String get prefDefaultGameTitle => 'Spiel beim Start';

  @override
  String get prefDefaultGameDesc => 'Mit welcher Bibliothek die App startet';

  @override
  String get defaultGameAuto => 'Automatisch';

  @override
  String get prefSetupGuideTitle => 'Einrichtungs-Tour';

  @override
  String get prefSetupGuideDesc =>
      'Geh die Fragen vom ersten Start noch mal durch';

  @override
  String get onboardingReplay => 'Nochmal starten';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingSkipIntro => 'Intro überspringen';

  @override
  String get onboardingBack => 'Zurück';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingFinish => 'Bibliothek öffnen';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Schritt $current von $total';
  }

  @override
  String get onboardingWelcomeTitle => 'Hi! Lass uns kurz einrichten';

  @override
  String get onboardingWelcomeBody =>
      'Ein paar schnelle Fragen und deine Mods sind startklar. Dauert keine Minute, und alles hier kannst du später in den Einstellungen ändern.';

  @override
  String get onboardingGamesTitle => 'Wir suchen deine Spiele';

  @override
  String get onboardingGamesBody =>
      'Wir schauen an den üblichen Stellen nach jedem Spiel und nach dem Ordner, aus dem es Mods lädt.';

  @override
  String get onboardingScanning => 'Wird noch gesucht …';

  @override
  String onboardingGamesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Spiele gefunden',
      one: '1 Spiel gefunden',
      zero: 'Noch nichts gefunden',
    );
    return '$_temp0';
  }

  @override
  String onboardingGameMods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mods schon installiert',
      one: '1 Mod schon installiert',
      zero: 'Mods-Ordner bereit',
    );
    return '$_temp0';
  }

  @override
  String get onboardingGameMissing => 'Nicht auf diesem Computer';

  @override
  String get onboardingNoGamesTitle => 'Wir haben nichts gefunden';

  @override
  String get onboardingNoGamesBody =>
      'Halb so wild. Zeig der App in den Einstellungen selbst einen Mods-Ordner, dann läuft alles genau gleich.';

  @override
  String get onboardingFavoriteTitle => 'Welches spielst du am meisten?';

  @override
  String get onboardingFavoriteBody =>
      'Die App startet immer mit diesem Spiel. Über die Seitenleiste wechselst du jederzeit zu einem anderen.';

  @override
  String get onboardingLookTitle => 'Mach es zu deinem';

  @override
  String get onboardingLookBody =>
      'Die ganze App trägt den Look, den du aussuchst, egal welches Spiel du gerade verwaltest. Such dir aus, wie sie aussehen und klingen soll.';

  @override
  String get onboardingLibraryTitle => 'Wie sich deine Bibliothek liest';

  @override
  String get onboardingLibraryBody =>
      'Zwei Sachen, die sich jetzt lohnen, weil sie ändern, was dir die Bibliothek zeigt.';

  @override
  String get onboardingDoneTitle => 'Alles bereit!';

  @override
  String get onboardingDoneBody =>
      'Deine Bibliothek ist geladen und wartet. Zieh eine Mod-Datei aufs Fenster, wenn du etwas installieren willst, und ändere all das jederzeit in den Einstellungen.';

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
  String get ignoredConflictsTitle => 'Konflikte, die du ignorierst';

  @override
  String ignoredConflictsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Konflikte, die die App nicht mehr melden soll. Hol sie zurück, dann tauchen sie wieder in der Bibliothek auf',
      one:
          'Ein Konflikt, den die App nicht mehr melden soll. Hol ihn zurück, dann taucht er wieder in der Bibliothek auf',
    );
    return '$_temp0';
  }

  @override
  String get ignoredConflictsReset => 'Alle zurückholen';

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
  String aboutTagline(String version, String series) {
    return 'Version $version · Mod-Manager für $series';
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
  String get categoryWorld => 'Welt';

  @override
  String get categorySettings => 'Einstellungen';

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
  String get modKindCas => 'CAS';

  @override
  String get modKindBuildBuy => 'Bauen & Kaufen';

  @override
  String get modKindGameplay => 'Gameplay';

  @override
  String get modKindScript => 'Skript';

  @override
  String errorNoModFiles(String extensions, String name) {
    return 'Keine Mod-Dateien ($extensions) in $name gefunden.';
  }

  @override
  String errorUnreadableArchive(String name) {
    return '$name ist kein Archiv, das diese App lesen kann.';
  }

  @override
  String errorNoUnpacker(String format, String name) {
    return 'Auf diesem Computer kann nichts $format-Archive entpacken. Entpack $name selbst und installier die Dateien daraus.';
  }

  @override
  String errorNoUnpackerLinux(String format, String name) {
    return 'Auf diesem Computer kann nichts $format-Archive entpacken. Installier p7zip und versuch es nochmal, oder entpack $name selbst und installier die Dateien daraus.';
  }

  @override
  String errorNoUnpackerLinuxRar(String format, String name) {
    return 'Auf diesem Computer kann nichts $format-Archive entpacken. Installier p7zip oder unrar und versuch es nochmal, oder entpack $name selbst und installier die Dateien daraus.';
  }

  @override
  String errorUnpackFailed(String name) {
    return '$name ließ sich nicht entpacken. Vielleicht ist es passwortgeschützt, Teil eines mehrteiligen Archivs oder ein beschädigter Download. Entpack es von Hand und installier die Dateien daraus.';
  }

  @override
  String errorSims3PackUnreadable(String name) {
    return '$name ist kein Die-Sims-3-Paket, das diese App lesen kann.';
  }

  @override
  String errorSims3PackWorld(String name) {
    return '$name ist eine Welt, kein Custom Content. Installier sie über den Die Sims 3 Launcher. Welten legt das Spiel außerhalb des Mods-Ordners ab.';
  }

  @override
  String errorSims3PackLibrary(String name) {
    return '$name ist ein Grundstück oder ein Haushalt, kein Custom Content. Installier es über den Die Sims 3 Launcher. Es landet in deiner Bibliothek im Spiel.';
  }

  @override
  String errorInstallFailed(String name, String reason) {
    return '„$name“ konnte nicht installiert werden: $reason. Wenn es weiter schiefgeht, entpack es von Hand und installier die Dateien daraus.';
  }

  @override
  String errorInstallFailedRaw(String name, String reason) {
    return '„$name“ konnte nicht installiert werden: $reason';
  }

  @override
  String errorFileInUseDelete(String name) {
    return '„$name“ konnte nicht gelöscht werden: die Datei wird von einem anderen Programm benutzt (läuft das Spiel?) oder ist schreibgeschützt. Schließ alles, was sie benutzt, und versuch es nochmal.';
  }

  @override
  String errorFileInUseRename(String name) {
    return '„$name“ konnte nicht umbenannt werden: die Datei wird von einem anderen Programm benutzt (läuft das Spiel?) oder ist schreibgeschützt. Schließ alles, was sie benutzt, und versuch es nochmal.';
  }

  @override
  String errorFileNameTaken(String name) {
    return 'In dem Ordner liegt schon ein „$name“. Benenn eins von beiden um und versuch es nochmal.';
  }

  @override
  String errorFolderNameBad(String name) {
    return '„$name“ geht als Ordnername nicht. Nimm einen ohne Schrägstriche und ohne Zeichen, die dein System für sich behält.';
  }

  @override
  String errorFolderTooDeep(int levels) {
    return 'Das Spiel schaut nur $levels Ordner tief in den Mods-Ordner hinein - alles darunter würde nie geladen.';
  }

  @override
  String errorBulkMoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mods konnten nicht verschoben werden',
      one: '1 Mod konnte nicht verschoben werden',
    );
    return '$_temp0 - vielleicht benutzt sie gerade ein anderes Programm (läuft das Spiel noch?), sie sind schreibgeschützt, oder im Zielordner liegt schon eine Datei mit dem Namen.';
  }

  @override
  String errorBulkToggleFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mods konnten nicht umgeschaltet werden',
      one: '1 Mod konnte nicht umgeschaltet werden',
    );
    return '$_temp0 - vielleicht benutzt sie gerade ein anderes Programm (läuft das Spiel noch?) oder sie sind schreibgeschützt.';
  }

  @override
  String errorBulkRemoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mods konnten nicht gelöscht werden',
      one: '1 Mod konnte nicht gelöscht werden',
    );
    return '$_temp0 - vielleicht benutzt sie gerade ein anderes Programm (läuft das Spiel noch?) oder sie sind schreibgeschützt.';
  }

  @override
  String errorFileMissing(String name) {
    return '„$name“ liegt nicht mehr im Mods-Ordner, vielleicht hat ein anderes Programm die Datei verschoben oder gelöscht.';
  }

  @override
  String get requirementMedievalModLoader =>
      'Die Sims Mittelalter kann ohne die Loader-Datei der Community im Ordner Game\\Bin des Spiels keine Script- oder Core-Mods ausführen. Custom Content läuft trotzdem, alles andere nicht.';

  @override
  String get requirementSims4ModsOff =>
      'Im Spiel selbst sind Custom Content und Mods in den Spieloptionen ausgeschaltet, deshalb lädt hiervon nichts. Schalt es unter Optionen → Spieloptionen → Sonstiges wieder ein und starte das Spiel neu.';

  @override
  String get requirementSims4ScriptModsOff =>
      'Du hast hier Script-Mods, aber im Spiel ist „Script-Mods zulassen“ in den Spieloptionen aus. Spiel-Updates setzen das zurück.';

  @override
  String get requirementGetFile => 'Wo es das gibt';

  @override
  String tooDeepBanner(int count, int levels) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mods liegen',
      one: 'Ein Mod liegt',
    );
    return '$_temp0 in einem Unterordner, den das Spiel nicht liest. Es schaut nur $levels Ordner tief: schieb sie weiter nach oben, dann laden sie.';
  }

  @override
  String get tooDeepShow => 'Zeig sie mir';

  @override
  String get duplicatesFind => 'Doppelte Mods finden';

  @override
  String duplicatesScanning(int done, int total) {
    return 'Lese die Mods, die Kopien sein könnten… $done von $total';
  }

  @override
  String get duplicatesStop => 'Stopp';

  @override
  String duplicatesBanner(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mods sind dieselbe Datei wie ein anderer',
      one: 'Ein Mod ist dieselbe Datei wie ein anderer',
    );
    return '$_temp0 - das sind $size, die du zurückbekommst.';
  }

  @override
  String get duplicatesShow => 'Zeig sie mir';

  @override
  String get duplicatesSelectExtras => 'Die überzähligen Kopien anhaken';

  @override
  String get duplicatesClean => 'Hier ist nichts doppelt.';

  @override
  String get duplicatesDismiss => 'Alles klar';

  @override
  String tagTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tags für $count Mods',
      one: 'Tags für diesen Mod',
    );
    return '$_temp0';
  }

  @override
  String get tagBody =>
      'Deine eigenen Tags, damit du später alles wiederfindest. Tipp einen an, um ihn zu setzen oder zu entfernen.';

  @override
  String get tagHint => 'Neuer Tag';

  @override
  String get tagAdd => 'Hinzufügen';

  @override
  String get tagDone => 'Fertig';

  @override
  String get tagHeading => 'Tags';

  @override
  String get tagAddFirst => 'Tag hinzufügen';

  @override
  String tagRemove(String tag) {
    return '„$tag“ entfernen';
  }

  @override
  String get selectionTag => 'Taggen…';

  @override
  String folderAlsoReading(String folders) {
    return 'Dein Spiel liest auch $folders, deshalb sind die Mods von dort ebenfalls in dieser Bibliothek.';
  }

  @override
  String errorFolderUnreadable(String folder) {
    return '„$folder“ ließ sich nicht öffnen. Wähl einen Ordner auf einem Laufwerk, das dieser Computer erreicht - ein Handy, eine Kamera oder ein getrenntes Netzlaufwerk kann deine Mods nicht halten.';
  }

  @override
  String errorNoWriteAccess(String folder) {
    return 'Die App darf nicht in „$folder“ schreiben. Dein System schützt diesen Ordner: gib deinem Konto Schreibrechte darauf, oder wähl in den Einstellungen einen anderen Ordner.';
  }

  @override
  String get folderReadOnlyBanner =>
      'Dieser Mods-Ordner ist schreibgeschützt: Installieren und Entfernen klappt erst, wenn dein Konto darin schreiben darf.';

  @override
  String get elevatedNoDropBanner =>
      'Du läufst als Administrator, deshalb lässt Windows keine Dateien aufs Fenster ziehen. Nimm stattdessen den Installieren-Button, der geht weiterhin.';

  @override
  String errorShopDownload(String name) {
    return '„$name“ ließ sich nicht von The Exchange herunterladen. Prüf deine Verbindung und versuch es nochmal.';
  }

  @override
  String errorShopNoModFiles(String name) {
    return 'In „$name“ ist nichts, was dieses Spiel installieren kann. Vielleicht ist es gar kein Mod - nimm Herunterladen und speicher die Datei da, wo du sie haben willst.';
  }

  @override
  String get errorShopListingNotFound =>
      'Diesen Mod gibt es auf The Exchange nicht mehr. Vielleicht wurde er zurückgezogen.';

  @override
  String get errorShopListingUnknownGame =>
      'Dieser Mod ist für ein Spiel, das diese Version der App noch nicht kennt. Probier mal ein Update.';

  @override
  String errorPackToggleFailed(String pack) {
    return '$pack ließ sich nicht umschalten. Schließ das Spiel und probier es nochmal.';
  }

  @override
  String get errorPackNoUserData =>
      'Der Einstellungsordner des Spiels ist nicht auffindbar, also gibt es nirgends zu vermerken, welche Packs übersprungen werden sollen. Starte das Spiel erst einmal.';

  @override
  String get errorPackNeedsAdmin =>
      'Windows hat die App das nicht ändern lassen. Starte sie als Administrator neu und probier es nochmal.';

  @override
  String get errorPackNotSupported =>
      'Auf diesem System lassen sich Packs nicht an- und ausschalten.';

  @override
  String get errorPackIsTheGame =>
      'Das ist das Pack, aus dem das Spiel startet, es muss also an bleiben.';

  @override
  String get errorPackToggleRefused =>
      'Dieses Pack ließ sich nicht ändern. Schließ das Spiel und probier es nochmal.';

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
  String get navPacks => 'Packs';

  @override
  String get packsScanning => 'Deine Packs werden gesucht…';

  @override
  String get packsEmptyTitle => 'Keine Packs gefunden';

  @override
  String packsEmptyBody(String game) {
    return 'Entweder ist $game nicht dort installiert, wo die App nachsehen kann, oder es liegen noch keine Packs daneben.';
  }

  @override
  String get packsRescan => 'Nochmal nachsehen';

  @override
  String packsSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Packs installiert',
      one: '1 Pack installiert',
    );
    return '$_temp0';
  }

  @override
  String packsSummaryWithOff(int count, int off) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Packs an',
      one: '1 Pack an',
    );
    return '$_temp0, $off ausgeschaltet';
  }

  @override
  String get packsOff => 'Aus';

  @override
  String get packsInstalled => 'Installiert';

  @override
  String get packsNeedAdmin =>
      'Diese Packs an- und auszuschalten braucht Administratorrechte, denn dort führt das Spiel seine Liste. Starte die App als Administrator neu, um sie zu ändern - Drag and Drop geht so lange nicht, es lohnt sich also, danach zurückzuwechseln.';

  @override
  String get packsExperimentalTitle => 'Die auszuschalten ist experimentell';

  @override
  String get packsExperimentalOff =>
      'Es funktioniert so, wie es bei diesem Spiel immer funktioniert hat, aber niemand hat es mit dieser Ausgabe getestet - und eine Nachbarschaft, die du mit einem Pack gespielt hast, kann kaputtgehen, wenn du sie ohne öffnest. Nur anzusehen ist gefahrlos. Schalte die experimentellen Pack-Schalter in den Einstellungen frei, wenn du es trotzdem versuchen willst.';

  @override
  String get packsExperimentalOn =>
      'Sichere vorher deine Nachbarschaften. Eine Nachbarschaft, die du mit einem Pack gespielt hast, kann kaputtgehen, wenn du sie ohne öffnest, und von hier aus lässt sich das nicht rückgängig machen: das Pack wieder anzuschalten holt den Spielstand nicht immer zurück.';

  @override
  String packsRestartNotice(String game) {
    return 'Starte $game neu, damit das wirkt. Deine Packs bleiben so oder so installiert.';
  }

  @override
  String packsAllOwnedSims4(String expansions, String gamePacks) {
    return '$expansions Erweiterungspacks. $gamePacks Gameplay-Packs. Alle gekauft, na klar.';
  }

  @override
  String get packKindExpansions => 'Erweiterungspacks';

  @override
  String get packKindGamePacks => 'Gameplay-Packs';

  @override
  String get packKindStuffPacks => 'Accessoires-Packs';

  @override
  String get packKindKits => 'Kits';

  @override
  String get packKindFreePacks => 'Gratis-Packs';

  @override
  String get navSaves => 'Spielstände';

  @override
  String get savesScanning => 'Deine Spielstände werden gelesen…';

  @override
  String get savesEmptyTitle => 'Keine Spielstände gefunden';

  @override
  String savesEmptyBody(String game) {
    return 'Sobald du $game spielst und speicherst, tauchen deine Welten hier auf, mit Familien, Fotos und allem Drum und Dran.';
  }

  @override
  String get savesRescan => 'Neu einlesen';

  @override
  String savesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Spielstände gefunden',
      one: '1 Spielstand gefunden',
    );
    return '$_temp0';
  }

  @override
  String savesLastSaved(String date) {
    return 'Zuletzt gespeichert: $date';
  }

  @override
  String get savesShowInFolder => 'Im Ordner anzeigen';

  @override
  String savesBackups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Backups',
      one: '1 Backup',
    );
    return '$_temp0';
  }

  @override
  String get savesTabHouseholds => 'Haushalte';

  @override
  String get savesTabAlbum => 'Fotoalbum';

  @override
  String get savesTabStats => 'Welt-Statistiken';

  @override
  String savesNeighborhood(int number) {
    return 'Nachbarschaft $number';
  }

  @override
  String get savesOtherHouseholds => 'NPCs und andere Haushalte';

  @override
  String savesSimCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sims',
      one: '1 Sim',
    );
    return '$_temp0';
  }

  @override
  String get savesFunds => 'Vermögen';

  @override
  String get savesRooms => 'Zimmer';

  @override
  String savesBedsBaths(int beds, int baths) {
    return '$beds Schlafz. · $baths Bäder';
  }

  @override
  String savesByCreator(String name) {
    return 'von $name';
  }

  @override
  String get savesMembers => 'Mitglieder';

  @override
  String get savesRelationships => 'Beziehungen';

  @override
  String get savesUnknownSim => 'Unbekannter Sim';

  @override
  String get savesStatSims => 'Sims';

  @override
  String get savesStatHouseholds => 'Haushalte';

  @override
  String get savesStatNetWorth => 'Gesamtvermögen';

  @override
  String get savesStatWorlds => 'Welten';

  @override
  String get savesStatPhotos => 'Fotos';

  @override
  String savesAcrossHouseholds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count Haushalten',
      one: 'in 1 Haushalt',
    );
    return '$_temp0';
  }

  @override
  String savesPlayedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gespielt',
      one: '1 gespielt',
    );
    return '$_temp0';
  }

  @override
  String get savesSizeOnDisk => 'Größe auf der Festplatte';

  @override
  String get savesLifeStages => 'Lebensabschnitte';

  @override
  String get savesTopSkills => 'Höchste Fähigkeiten in diesem Spielstand';

  @override
  String get savesSaveInfo => 'Spielstand-Datei';

  @override
  String get savesLastSavedLabel => 'Zuletzt gespeichert';

  @override
  String get savesGameVersion => 'Spielversion';

  @override
  String get savesDescription => 'Beschreibung';

  @override
  String get savesAgeInfant => 'Säugling';

  @override
  String get savesAgeBaby => 'Baby';

  @override
  String get savesAgeToddler => 'Kleinkind';

  @override
  String get savesAgeChild => 'Kind';

  @override
  String get savesAgeTeen => 'Teenager';

  @override
  String get savesAgeYoungAdult => 'Junger Erwachsener';

  @override
  String get savesAgeAdult => 'Erwachsener';

  @override
  String get savesAgeElder => 'Senior';

  @override
  String get savesGenderMale => 'Männlich';

  @override
  String get savesGenderFemale => 'Weiblich';

  @override
  String get savesSkillCooking => 'Kochen';

  @override
  String get savesSkillMechanical => 'Technik';

  @override
  String get savesSkillCharisma => 'Charisma';

  @override
  String get savesSkillBody => 'Körper';

  @override
  String get savesSkillLogic => 'Logik';

  @override
  String get savesSkillCreativity => 'Kreativität';

  @override
  String get savesSkillCleaning => 'Putzen';

  @override
  String get savesPersonalityNeat => 'Ordentlich';

  @override
  String get savesPersonalityOutgoing => 'Kontaktfreudig';

  @override
  String get savesPersonalityActive => 'Aktiv';

  @override
  String get savesPersonalityPlayful => 'Verspielt';

  @override
  String get savesPersonalityNice => 'Nett';

  @override
  String get savesZodiacAries => 'Widder';

  @override
  String get savesZodiacTaurus => 'Stier';

  @override
  String get savesZodiacGemini => 'Zwillinge';

  @override
  String get savesZodiacCancer => 'Krebs';

  @override
  String get savesZodiacLeo => 'Löwe';

  @override
  String get savesZodiacVirgo => 'Jungfrau';

  @override
  String get savesZodiacLibra => 'Waage';

  @override
  String get savesZodiacScorpio => 'Skorpion';

  @override
  String get savesZodiacSagittarius => 'Schütze';

  @override
  String get savesZodiacCapricorn => 'Steinbock';

  @override
  String get savesZodiacAquarius => 'Wassermann';

  @override
  String get savesZodiacPisces => 'Fische';

  @override
  String get savesAspirationRomance => 'Romantik';

  @override
  String get savesAspirationFamily => 'Familie';

  @override
  String get savesAspirationFortune => 'Reichtum';

  @override
  String get savesAspirationPopularity => 'Beliebtheit';

  @override
  String get savesAspirationKnowledge => 'Wissen';

  @override
  String get savesAspirationGrowUp => 'Erwachsenwerden';

  @override
  String get savesAspirationPleasure => 'Vergnügen';

  @override
  String get savesAspirationGrilledCheese => 'Käsetoast';

  @override
  String get savesRelCrush => 'verknallt';

  @override
  String get savesRelLove => 'verliebt';

  @override
  String get savesRelEngaged => 'verlobt';

  @override
  String get savesRelMarried => 'verheiratet';

  @override
  String get savesRelFriends => 'Freunde';

  @override
  String get savesRelBestFriends => 'beste Freunde';

  @override
  String get savesRelSteady => 'fest zusammen';

  @override
  String get savesRelEnemies => 'Feinde';

  @override
  String get savesPhotoFamilyPortrait => 'Familienporträt';

  @override
  String get savesPhotoLot => 'Grundstück';

  @override
  String get savesPhotoSim => 'Sim-Porträt';

  @override
  String get savesPhotoSnapshot => 'Schnappschuss';

  @override
  String get savesProperty => 'Besitz';

  @override
  String get savesGhost => 'Geist';

  @override
  String savesCareerLevel(String career, int level) {
    return '$career · Stufe $level';
  }

  @override
  String get savesSpeciesLargeDog => 'Hund';

  @override
  String get savesSpeciesSmallDog => 'kleiner Hund';

  @override
  String get savesSpeciesCat => 'Katze';

  @override
  String get savesOccultVampire => 'Vampir';

  @override
  String get savesOccultZombie => 'Zombie';

  @override
  String get savesOccultWerewolf => 'Werwolf';

  @override
  String get savesOccultPlantSim => 'PflanzenSim';

  @override
  String get savesOccultAlien => 'Alien';

  @override
  String get savesOccultServo => 'Servo';

  @override
  String get savesOccultWitch => 'Hexe';

  @override
  String get savesOccultBigfoot => 'Bigfoot';

  @override
  String get savesOccultFairy => 'Fee';

  @override
  String get savesOccultGenie => 'Dschinn';

  @override
  String get savesOccultMermaid => 'Meerjungfrau';

  @override
  String get savesLotResidential => 'Wohngrundstück';

  @override
  String get savesLotCommunity => 'Gemeinschaftsgrundstück';

  @override
  String get savesLotDorm => 'Wohnheim';

  @override
  String get savesLotSecretSociety => 'Geheimbund';

  @override
  String get savesLotGreekHouse => 'Verbindungshaus';

  @override
  String get savesLotHotel => 'Hotel';

  @override
  String get savesLotSecret => 'Geheimes Grundstück';

  @override
  String get savesLotBusiness => 'Geschäft';

  @override
  String get savesLotApartment => 'Wohnung';

  @override
  String savesGpa(String gpa) {
    return 'Schnitt $gpa';
  }

  @override
  String savesSemester(int number) {
    return 'Semester $number';
  }

  @override
  String savesPredestinedHobby(String hobby) {
    return 'Wie geschaffen für $hobby';
  }

  @override
  String get savesHobbyCuisine => 'Küche';

  @override
  String get savesHobbyArts => 'Kunst und Handwerk';

  @override
  String get savesHobbyFilm => 'Film und Literatur';

  @override
  String get savesHobbySports => 'Sport';

  @override
  String get savesHobbyGames => 'Spiele';

  @override
  String get savesHobbyNature => 'Natur';

  @override
  String get savesHobbyTinkering => 'Basteln';

  @override
  String get savesHobbyFitness => 'Fitness';

  @override
  String get savesHobbyScience => 'Wissenschaft';

  @override
  String get savesHobbyMusic => 'Musik und Tanz';

  @override
  String get savesTieMother => 'Mutter';

  @override
  String get savesTieFather => 'Vater';

  @override
  String get savesTieSpouse => 'verheiratet mit';

  @override
  String savesTieSibling(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Geschwister',
      one: 'Geschwisterkind',
    );
    return '$_temp0';
  }

  @override
  String savesTieChild(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kinder',
      one: 'Kind',
    );
    return '$_temp0';
  }

  @override
  String get savesInterestPolitics => 'Politik';

  @override
  String get savesInterestMoney => 'Geld';

  @override
  String get savesInterestEnvironment => 'Umwelt';

  @override
  String get savesInterestCrime => 'Verbrechen';

  @override
  String get savesInterestEntertainment => 'Unterhaltung';

  @override
  String get savesInterestCulture => 'Kultur';

  @override
  String get savesInterestFood => 'Essen';

  @override
  String get savesInterestHealth => 'Gesundheit';

  @override
  String get savesInterestFashion => 'Mode';

  @override
  String get savesInterestSports => 'Sport';

  @override
  String get savesInterestParanormal => 'Paranormales';

  @override
  String get savesInterestTravel => 'Reisen';

  @override
  String get savesInterestWork => 'Arbeit';

  @override
  String get savesInterestWeather => 'Wetter';

  @override
  String get savesInterestAnimals => 'Tiere';

  @override
  String get savesInterestSchool => 'Schule';

  @override
  String get savesInterestToys => 'Spielzeug';

  @override
  String get savesInterestSciFi => 'Science-Fiction';

  @override
  String get savesInterestMusic => 'Musik';

  @override
  String get savesInterestOutdoors => 'Natur';

  @override
  String get setupHelpSims1 =>
      'Das allererste Die Sims legt Custom Content in seinem Installationsordner ab, nicht in Dokumente: Objekte kommen in einen Downloads-Ordner neben die Spiel-EXE (z. B. C:\\Program Files (x86)\\Maxis\\The Sims\\Downloads), und diese App sortiert die übrigen Typen automatisch: Skins (.skn/.cmx/.bmp) nach GameData\\Skins, Wände und Böden nach GameData\\Walls und GameData\\Floors. Die Legacy Collection von 2025 funktioniert genauso aus ihrem eigenen Installationsordner (EA Games\\The Sims Legacy oder Steam\\steamapps\\common\\The Sims Legacy Collection). Wenn das Spiel woanders installiert ist (andere Festplatte, eigene Steam-Bibliothek), wähl seinen Downloads-Ordner von Hand aus.';

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

  @override
  String get prefSubfoldersTitle => 'Ordner schließen ihre Unterordner ein';

  @override
  String get prefSubfoldersDesc =>
      'Ein Ordner zeigt auch alles, was darunter liegt. Aus sind cc und cc/defaults getrennte Regale.';

  @override
  String deleteFolderTitle(String folder) {
    return '$folder löschen?';
  }

  @override
  String get deleteFolderBody =>
      'Der Ordner und alles darin ist weg, Unterordner eingeschlossen. Das lässt sich nicht rückgängig machen.';

  @override
  String deleteFolderMods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mods werden gelöscht',
      one: '1 Mod wird gelöscht',
    );
    return '$_temp0';
  }

  @override
  String get deleteFolderEmpty => 'Es sind keine Mods drin.';

  @override
  String get deleteFolder => 'Ordner löschen';

  @override
  String triviaTitle(String game) {
    return 'Der Plumbob weiß was · $game';
  }

  @override
  String get triviaContextLibrary =>
      'Sieht aus, als würdest du deine Mods durchgehen';

  @override
  String get triviaContextSaves =>
      'Sieht aus, als wärst du in deinen Spielständen';

  @override
  String get triviaContextPacks =>
      'Sieht aus, als würdest du deine Packs sortieren';

  @override
  String triviaCounter(int index, int total) {
    return 'Fakt $index von $total';
  }

  @override
  String get triviaOpen => 'Den Plumbob fragen';

  @override
  String get triviaClose => 'Jetzt nicht';

  @override
  String get triviaPrevious => 'Voriger Fakt';

  @override
  String get triviaNext => 'Nächster Fakt';

  @override
  String get triviaAnother => 'Noch einer';

  @override
  String get triviaToSettings =>
      'Genug? Schalt den Plumbob in den Einstellungen aus';

  @override
  String get prefTriviaTitle => 'Plumbob-Fakten';

  @override
  String get prefTriviaDesc =>
      'Lass den Plumbob ab und zu mit einem Fakt über das Spiel auftauchen, in dem du gerade bist';

  @override
  String get triviaCategoryOrigins => 'Ursprünge';

  @override
  String get triviaCategoryDesign => 'Design';

  @override
  String get triviaCategoryLore => 'Lore';

  @override
  String get triviaCategoryDeath => 'Tod';

  @override
  String get triviaCategoryMusic => 'Musik';

  @override
  String get triviaCategoryCheats => 'Cheats';

  @override
  String get triviaCategoryRecords => 'Rekorde';

  @override
  String get triviaCategoryModding => 'Modding';

  @override
  String get triviaCategoryLanguage => 'Sprache';

  @override
  String get triviaCategoryCommunity => 'Community';

  @override
  String get triviaSeriesLlama =>
      'Maxis hat einmal im ganzen Studio über ein inoffizielles Maskottchen abstimmen lassen. Zur Wahl standen ein Schwertfarn, ein Rinderbandwurm und ein Lama. Das Lama gewann, und seitdem taucht es in jedem Spiel wieder auf.';

  @override
  String get triviaSeriesSimlish =>
      'Simlish ist direkt am Mikrofon entstanden. Stephen Kearin und Gerri Lawlor bekamen Stichworte wie „hungrig“ oder „einsam“ und haben stundenlang improvisiert, wie das klingen müsste.';

  @override
  String get triviaSeriesCheats =>
      'rosebud und klapaucius bringen je §1.000. Rosebud kommt aus Citizen Kane; Klapaucius ist ein Roboterkonstrukteur aus Stanisław Lems Kyberiade, einem Buch, das Will Wright seit SimCity als Einfluss nennt.';

  @override
  String get triviaSeriesRecords =>
      'Guinness führt The Sims als meistverkaufte PC-Spielereihe aller Zeiten. Sie hat vor über zehn Jahren die 125 Millionen Exemplare geknackt und ist in 60 Sprachen übersetzt.';

  @override
  String get triviaSeriesGoths =>
      'Die Goths sind eine der langlebigsten Familien der Videospielgeschichte. Mortimer und Bella tauchen seit 2000 in jedem Hauptteil auf.';

  @override
  String get triviaSeriesReaper =>
      'Der Sensenmann hat eine Biografie, die dir das normale Spiel nie zeigt. Unter anderem steht dort seine Lieblingsband: Styx.';

  @override
  String get triviaSeriesSimCity =>
      'The Sims ist aus SimCity entstanden. Will Wright wollte immer wieder auf die kleinen Leute zoomen, für die die Stadt eigentlich gebaut wurde.';

  @override
  String get triviaSeriesLegacy =>
      'Im Januar 2025 hat EA The Sims und The Sims 2 als Legacy Collections wieder in den Verkauf gebracht, mit allen Erweiterungen. Das sind Kompatibilitätsfixes und keine Remaster, beide spielen sich also genau wie früher.';

  @override
  String get triviaSeriesPlumbob =>
      'Der grüne Diamant wurde schon dreifach geschrieben: PlumbBob in The Sims, Plum Bob in The Sims 2 und plumbob seit The Sims 4. Maxis sagt, alle drei waren während der Entwicklung im Umlauf.';

  @override
  String get triviaSeriesModScene =>
      'Die Mod-Szene ist fast so alt wie die Reihe. Skin- und Objekt-Editoren kursierten schon wenige Monate nach dem ersten Spiel im Jahr 2000, lange bevor es offizielle Werkzeuge gab.';

  @override
  String get triviaSeriesConflicts =>
      'Ein Konflikt ist einfacher, als er klingt. Zwei Mods beanspruchen dieselbe Ressource, beide werden geladen, und wer zuletzt gelesen wird, gewinnt. Kaputt ist nichts, es wurde nur etwas überstimmt.';

  @override
  String get triviaSeriesPackage =>
      'Eine .package-Datei ist ein DBPF-Archiv, kurz für Database Packed File. Maxis benutzt denselben Container seit SimCity 4, und genau deshalb öffnet ein einziges Werkzeug zwanzig Jahre Custom Content.';

  @override
  String get triviaSeriesRename =>
      'Einen Mod durch Umbenennen abzuschalten ist der älteste Trick der Szene. Das Spiel lädt nur, was es erkennt, also bleibt ein umbenanntes Package genau dort liegen, wo es ist, und hält still.';

  @override
  String get triviaSeriesSaves =>
      'Sims-Spielstände sind Nachbarschaften, keine Speicherplätze. Die Familien, die Grundstücke, die Erinnerungen und der Tratsch stecken alle in einem Ordner, der wächst, solange du weiterspielst.';

  @override
  String get triviaSeriesPacks =>
      'Ein Pack abzuschalten verschiebt keine einzige Datei. Jedes Spiel der Reihe führt seine Liste dessen, was geladen wird, woanders, in einer Einstellungszeile oder einem Registry-Schlüssel, und ein Pack zu verstecken heißt nur, diese Liste zu ändern.';

  @override
  String get triviaSims1Dollhouse =>
      'The Sims fing als Architektursimulation namens Project Dollhouse an. Die Sims kamen erst dazu, damit man beurteilen konnte, ob sich in dem Haus überhaupt gut leben lässt.';

  @override
  String get triviaSims1Oakland =>
      'Will Wright verlor 1991 sein Haus beim Feuersturm von Oakland. Einen Haushalt von null wieder aufzubauen, Möbel, Geräte, Abläufe, wurde zur Keimzelle des Spiels.';

  @override
  String get triviaSims1Toilet =>
      'Die Führungsetage war vom Pitch bekanntlich nicht überzeugt und tat ihn als „Klospiel“ ab, weil Sims ein Badezimmer brauchen.';

  @override
  String get triviaSims1HomeTactics =>
      'Bevor es The Sims hieß, wurde es als Home Tactics: The Experimental Domestic Simulator vorgestellt. Auch diese Fassung fiel bei den Testgruppen durch.';

  @override
  String get triviaSims1Myst =>
      '2002 zog The Sims an Myst vorbei und wurde zum meistverkauften PC-Spiel aller Zeiten.';

  @override
  String get triviaSims1Simlish =>
      'Simlish wurde von Sprechern improvisiert, die mit Fetzen aus Ukrainisch, Navajo, Tagalog und Estnisch spielten, und bewusst bedeutungslos gehalten, damit die Sprache nie veraltet.';

  @override
  String get triviaSims1Architecture =>
      'Die Bauwerkzeuge waren für das Jahr 2000 so ungewöhnlich, dass manche Leute nie einen einzigen Sim gesetzt und das Spiel als kostenlose Architektursoftware benutzt haben.';

  @override
  String get triviaSims1Audience =>
      'Für die damalige Zeit ungewöhnlich, war die Mehrheit der Spielenden weiblich, und das ist mit ein Grund, warum das Marketing im Regal wie nichts anderes aussah.';

  @override
  String get triviaSims1Cowplant =>
      'Die Kuhpflanze hatte hier ihren Auftritt, unter dem Namen Laganaphyllis Simnovorii, und frisst seitdem in jeder Generation klammheimlich Sims.';

  @override
  String get triviaSims1Plumbob =>
      'Das Wort plumbob kommt vom Senklot, dem spitzen Gewicht, das Bauleute an einer Schnur aufhängen, um die Senkrechte zu finden. Das hier war zuallererst ein Architekturspiel.';

  @override
  String get triviaSims1Release =>
      'Das Spiel erschien am 4. Februar 2000 und übertraf jede Verkaufsprognose, die EA dafür aufgestellt hatte.';

  @override
  String get triviaSims1Edith =>
      'Jedes Objekt im Spiel wurde in einer Sprache namens SimAntics programmiert, mit einem hauseigenen Werkzeug namens Edith, benannt nach Edith Bunker: der allerersten Figur, die je für The Sims gebaut wurde.';

  @override
  String get triviaSims1Expansions =>
      'Sieben Erweiterungen in dreieinhalb Jahren, je eine im Frühjahr und eine im Herbst, von Livin’ Large im August 2000 bis Makin’ Magic im Oktober 2003.';

  @override
  String get triviaSims1Unleashed =>
      'Unleashed brachte 2002 die Haustiere in die Reihe und holte bei den Interactive Achievement Awards den Preis für das Simulationsspiel des Jahres.';

  @override
  String get triviaSims1Clown =>
      'Der Tragische Clown taucht auf, um einen traurigen Sim aufzuheitern, der sein Gemälde besitzt. Er ist grandios schlecht darin, und genau das ist der Witz.';

  @override
  String get triviaSims1Llama =>
      'Im ursprünglichen gedruckten Handbuch steckte ein Buch namens Making the Most of Your Llama. Erklärt hat das nie jemand.';

  @override
  String get triviaSims1Superstar =>
      'Superstar ließ einen Sim Schauspieler, Model oder Sänger werden, samt funktionierender Ruhmesleiste, elf Jahre bevor The Sims 4 es noch einmal mit Berühmtheit versuchte.';

  @override
  String get triviaSims1Catalogue =>
      'Beim Wiederaufbau nach dem Feuer fragte sich Will Wright ständig, welche Teile eines Zuhauses unverzichtbar sind und welche warten können. Diese Frage ist im Grunde der Katalog des Kaufmodus.';

  @override
  String get triviaSims2Aging =>
      'The Sims 2 war der erste Teil, in dem Sims alterten, an Altersschwäche starben und Genetik weitergaben. Augen, Nasen und Kinn kommen von beiden Eltern.';

  @override
  String get triviaSims2Memories =>
      'Jeder Sim trägt eine versteckte Erinnerungsliste mit sich. Einen Tod, einen ersten Kuss oder eine Beförderung mitzuerleben wird gespeichert und färbt später auf die Stimmung ab.';

  @override
  String get triviaSims2Bella =>
      'Bella Goth verschwindet gleich zu Spielbeginn aus Pleasantview, und in zwanzig Jahren gab es nie eine offizielle Erklärung dafür.';

  @override
  String get triviaSims2Strangetown =>
      'Bella taucht in Strangetown quicklebendig wieder auf, ohne jede Erinnerung an Pleasantview. Maxis sagte, beide Bellas seien echt, und beließ es dabei.';

  @override
  String get triviaSims2FamilyTrees =>
      'Die Nachbarschaften von The Sims 2 laufen auf einem echten Stammbaum: Pleasantview, Strangetown und Veronaville hängen über Ehen und Gerüchte zusammen.';

  @override
  String get triviaSims2Plead =>
      'Man kann den Sensenmann anflehen. Sprich ihn im richtigen Moment an, und er gibt dir deinen Sim vielleicht zurück, gelegentlich im Tausch gegen jemand anderen.';

  @override
  String get triviaSims2ReaperRomance =>
      'Man kann mit dem Sensenmann anbandeln. Wer es gut anstellt, bekommt aus der Beziehung ein Geisterbaby.';

  @override
  String get triviaSims2Satellite =>
      'Ein Sim, der Sterne beobachtet, hat eine winzige Chance, von einem herabstürzenden Satelliten getroffen zu werden. Das ist einer der seltensten Tode der Reihe.';

  @override
  String get triviaSims2Therapist =>
      'Ein Bestrebungs-Zusammenbruch schickt den Sim zum Therapeuten, einer der wenigen Momente, in denen das Spiel seine eigene vierte Wand aus Spaß einreißt.';

  @override
  String get triviaSims2WantsFears =>
      'Wünsche und Ängste treiben das ganze Spiel an. Die Bestrebungsleiste reagiert auf das, wovor ein Sim sich gefürchtet hat, genauso stark wie auf das, was er sich erhofft hat.';

  @override
  String get triviaSims2FaceSculpt =>
      'Das Spiel kam mit einem vollständigen System zum Modellieren von Gesicht und Körper, und deshalb wirken die Gesichter in The Sims 2 bis heute vielfältiger als in späteren Teilen.';

  @override
  String get triviaSims2Aliens =>
      'Die Alien-Entführung trifft nur männliche Sims, die zu lange in den Himmel schauen, und ja, sie kommen schwanger zurück.';

  @override
  String get triviaSims2FreezerBunny =>
      'Der Freezer Bunny wurde von der Künstlerin Emmy Toyonaga für The Sims 2 gezeichnet und tauchte zuerst versteckt in einer Gefriertruhe auf einem Gemeinschaftsgrundstück auf. Seitdem wird er in jedes Spiel eingeschmuggelt.';

  @override
  String get triviaSims2SocialBunny =>
      'Der Sozialhase ersetzte den Tragischen Clown und funktioniert im Gegensatz zu ihm tatsächlich. Viele fanden die kompetente Variante noch beunruhigender.';

  @override
  String get triviaSims2Giveaway =>
      'EA verschenkte die Ultimate Collection im Juli 2014 über Origin, einzulösen mit dem Code I-LOVE-THE-SIMS. Das darauffolgende Jahrzehnt lang, bis zur Legacy Collection, war dieses Geschenk die einzige Kopie, die es gab.';

  @override
  String get triviaSims3SunsetValley =>
      'Sunset Valley ist Pleasantview aus The Sims 2, rund 25 Jahre früher, du kannst also die Großeltern von Sims treffen, die du schon gespielt hast.';

  @override
  String get triviaSims3Founders =>
      'Sunset Valley wurde von den Goths gegründet und von den Landgraabs großgezogen. Du kannst Mortimer Goth als Kind spielen und zusehen, wie er Bella Bachelor kennenlernt.';

  @override
  String get triviaSims3OpenWorld =>
      'The Sims 3 hat die Ladebildschirme komplett abgeschafft. Die ganze Stadt simuliert gleichzeitig, jeder Sim altert und arbeitet im Hintergrund.';

  @override
  String get triviaSims3Simulation =>
      'Jeder Sim in der Stadt wird gleichzeitig simuliert, und deshalb wird ein langer Spielstand langsam. Das Spiel führt still und leise Leben, die du nie getroffen hast.';

  @override
  String get triviaSims3CreateAStyle =>
      'Erstelle-einen-Stil erlaubte es, fast jedes Objekt neu einzufärben und zu bemustern, eine Funktion, die so viel Leistung fraß, dass sie nie zurückkam.';

  @override
  String get triviaSims3Exchange =>
      'The Sims 3 kam mit einem echten Online-Austausch, in dem direkt aus dem Launcher heraus Grundstücke, Sims und Muster getauscht wurden.';

  @override
  String get triviaSims3Downloads =>
      'Allein in der ersten Woche luden Spielende über sieben Millionen selbstgemachte Objekte direkt aus diesem Launcher herunter.';

  @override
  String get triviaSims3Traits =>
      'Eigenschaften ersetzten die alten Persönlichkeitsregler, und manche davon, etwa Kleptomanisch und Verrückt, brechen ganz nebenbei die Regeln des normalen Lebens.';

  @override
  String get triviaSims3Kleptomaniac =>
      'Ein kleptomanischer Sim kommt ungefragt mit fremden Möbeln nach Hause und hört damit erst auf, wenn du es merkst.';

  @override
  String get triviaSims3Simlish =>
      'Katy Perry, Lily Allen, Depeche Mode und Dutzende weitere Künstler haben ihre eigenen Songs für die Soundtracks auf Simlish neu eingesungen.';

  @override
  String get triviaSims3Townies =>
      'Weil die offene Welt auch Sims außerhalb des Bildes simulierte, stellte man regelmäßig fest, dass Stadtbewohner geheiratet und Kinder bekommen hatten, ganz ohne dein Zutun.';

  @override
  String get triviaSims3Store =>
      'Der Sims 3 Store verkaufte am Ende mehr Objekte, als das Spiel selbst zum Erscheinen enthielt.';

  @override
  String get triviaSims3Launch =>
      'The Sims 3 verkaufte sich im Juni 2009 in der ersten Woche 1,4 Millionen Mal, der größte PC-Start, den EA je hatte.';

  @override
  String get triviaSims4Flies =>
      'Tod durch Fliegen gibt es wirklich. Lass ein Grundstück dreckig genug werden, und ein Schwarm macht deinem Sim den Garaus.';

  @override
  String get triviaSims4Emotions =>
      'Hier treiben Emotionen alles an. Ein inspirierter Sim malt besser; ein wütender kann an seiner Wut sterben.';

  @override
  String get triviaSims4EmotionDeaths =>
      'Ein Sim kann sich totlachen, vor Wut sterben und vor Peinlichkeit vergehen. Gefühl ist in diesem Teil keine Deko, sondern eine Gefahr.';

  @override
  String get triviaSims4CreateASim =>
      'Erstelle-einen-Sim ersetzte die Regler dadurch, dass man direkt am Gesicht zieht und drückt, und deshalb ist ein Gesicht in The Sims 4 so schnell gemacht.';

  @override
  String get triviaSims4Launch =>
      'The Sims 4 erschien ohne Pools und ohne Kleinkinder. Beides kam kostenlos per Patch zurück, nach anhaltendem Druck der Spielerschaft.';

  @override
  String get triviaSims4Worlds =>
      'Willow Creek und Oasis Springs waren beim Start im September 2014 die einzigen zwei Welten. Heute sind es Dutzende, und fast alle kamen mit einem Pack.';

  @override
  String get triviaSims4Gender =>
      'Das Geschlecht wurde 2016 per Patch vollständig entkoppelt: Jeder Sim kann jede Kleidung tragen, jede Stimme haben und schwanger werden oder eben nicht.';

  @override
  String get triviaSims4Newcrest =>
      'Newcrest kam mit voller Absicht komplett leer heraus. Fünfzehn Grundstücke, kein einziges Gebäude, und eine offene Einladung an die Community, das zu ändern.';

  @override
  String get triviaSims4Naming =>
      'Nachbarschaftsnamen wie Willow Creek und Oasis Springs folgen einer Hausregel aus alten Maxis-Tagen: zwei schlichte englische Wörter, keine erfundenen Schreibweisen.';

  @override
  String get triviaSims4Goths =>
      'Die Familie Goth ist auch hier dabei, was sie zu einer der langlebigsten der Videospielgeschichte macht, präsent in jedem Hauptteil.';

  @override
  String get triviaSims4FreeToPlay =>
      'Das Hauptspiel wurde im Oktober 2022 kostenlos, auf PC, PlayStation und Xbox gleichzeitig. Die Packs blieben kostenpflichtig.';

  @override
  String get triviaSims4Mccc =>
      'MC Command Center, der erste Mod, den fast alle in The Sims 4 installieren, hat allein auf CurseForge über 14 Millionen Downloads. Deaderpool hält ihn seit 2015 aktuell.';

  @override
  String get triviaSims4Twallan =>
      'MCCC gibt es wegen The Sims 3. Es macht dort weiter, wo Twallans Master Controller und Story Progression aufgehört haben, und trägt eine über zehn Jahre alte Idee in eine neue Engine.';

  @override
  String get triviaSims4Deaths =>
      'Ein Sim kann von einer Kuhpflanze, einem Automaten, einer lamaförmigen Stereoanlage und von Lachen umgebracht werden. Nicht alles auf einmal.';

  @override
  String get triviaMedievalWatcher =>
      'Hier bist du kein Haushalt, du bist der Beobachter: eine wohlmeinende Gottheit, die Helden durch ein Königreich schubst, statt den Alltag einer Familie zu führen.';

  @override
  String get triviaMedievalHeroes =>
      'Ein Königreich fasst bis zu zehn Helden-Sims in zehn Berufen, und jeder steigt von Stufe 1 bis 10 auf, mit neuen Fähigkeiten und immer prächtigeren Titeln.';

  @override
  String get triviaMedievalStocks =>
      'Jeder Held wacht mit zwei Pflichten und einer Frist auf. Wer sie zu oft schleifen lässt, wird bestraft, und das gilt auch für den Monarchen, der im Pranger landen kann.';

  @override
  String get triviaMedievalAmbition =>
      'Du wählst vor dem Start eine Ambition für das ganze Königreich, und die Quests, die du annimmst, werden daran gemessen. Näher ist The Sims einer Siegbedingung nie gekommen.';

  @override
  String get triviaMedievalQuests =>
      'Das hier ist eine Totalkonversion, kein Ableger. Der Sandkasten weicht einer Kette von Quests, und deshalb ist es das einzige Sims-Spiel, das man wirklich durchspielen kann.';

  @override
  String get triviaMedievalPirates =>
      'Pirates and Nobles von August 2011 war die einzige Erweiterung, die es je bekam: Falken und Papageien, Schatzkarten und Schaufeln, und ein Krieg zwischen zwei neu angekommenen Parteien.';

  @override
  String get triviaMedievalProxy =>
      'Das Spiel war nie dafür gebaut, Mods zu laden. Script- und Core-Mods brauchen den d3dx9_31.dll-Proxy der Community in Game/Bin, bevor das Spiel sie überhaupt liest, Custom Content dagegen läuft auch ohne.';

  @override
  String get triviaMedievalEngine =>
      'Es läuft auf der Engine von The Sims 3, und deshalb kommen einem die Resource.cfg und die .package-Dateien so bekannt vor, wenn man dieses Spiel schon gemoddet hat.';

  @override
  String get navCreations => 'Kreationen';

  @override
  String creationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kreationen',
      one: '1 Kreation',
      zero: 'Noch nichts gespeichert',
    );
    return '$_temp0';
  }

  @override
  String get creationsScanning =>
      'Deine Grundstücke und Haushalte werden gelesen…';

  @override
  String get creationsRefresh => 'Aktualisieren';

  @override
  String get creationsAll => 'Alle';

  @override
  String get creationsBack => '← Zurück zu allem';

  @override
  String get creationsNoneOfKind => 'Von der Sorte ist hier nichts.';

  @override
  String get creationsEmptyTitle => 'Hier ist noch nichts';

  @override
  String get creationsEmptyBody =>
      'Grundstücke, Räume, Haushalte und Sims, die du im Spiel speicherst, landen hier — und alles, was du herunterlädst und auf das Fenster ziehst, auch.';

  @override
  String creationsBy(String creator) {
    return 'von $creator';
  }

  @override
  String get creationsWhoLivesHere => 'WER MITKOMMT';

  @override
  String get creationsShowInFolder => 'Im Ordner zeigen';

  @override
  String get creationsDelete => 'Löschen';

  @override
  String creationsDeleteTitle(String name) {
    return '„$name“ löschen?';
  }

  @override
  String get creationsDeleteBody =>
      'Es verschwindet endgültig aus dem Ordner des Spiels. Rückgängig geht nicht.';

  @override
  String creationsFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Dateien',
      one: '1 Datei',
    );
    return '$_temp0';
  }

  @override
  String get creationKindLot => 'Grundstück';

  @override
  String get creationKindRoom => 'Raum';

  @override
  String get creationKindHousehold => 'Haushalt';

  @override
  String get creationKindSim => 'Sim';

  @override
  String get creationFolderSims4Tray => 'Tray';

  @override
  String get creationFolderSims3Library => 'Library';

  @override
  String get creationFolderSims2LotCatalog => 'Grundstücks- und Häusersammlung';

  @override
  String get creationFolderSims2SavedSims => 'Verpackte Sims';

  @override
  String creationFolderSims1Houses(String number) {
    return 'Nachbarschaft $number';
  }

  @override
  String creationBadFileName(String name) {
    return '„$name“ hat Zeichen im Namen, die dieses System nicht erlaubt — das Spiel würde die Datei nie finden. Benenn sie um und versuch es nochmal.';
  }

  @override
  String creationFileInUse(String name) {
    return '„$name“ ist gerade in Benutzung. Schließ das Spiel und versuch es nochmal.';
  }

  @override
  String get creationSims1PickLot =>
      'Die Sims 1 nummeriert seine Grundstücke nach ihrer Position auf der Karte. Ein Haus muss also ein vorhandenes Grundstück ersetzen, und was darauf steht, ist weg. Such das Grundstück selbst aus: sicher es vorher, dann benenn den Download auf die House-Nummer dieses Grundstücks im Houses-Ordner um.';

  @override
  String creationInstallFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Diese $count Dateien konnten nicht hinzugefügt werden.',
      one: 'Die Datei konnte nicht hinzugefügt werden.',
    );
    return '$_temp0';
  }

  @override
  String creationRemoveFailed(String name) {
    return '„$name“ konnte nicht gelöscht werden.';
  }

  @override
  String get creationsAdd => 'Hinzufügen';

  @override
  String get creationsAdding => 'Wird hinzugefügt…';

  @override
  String creationsPickerLabel(String game) {
    return 'Grundstücke, Räume, Haushalte und Sims für $game';
  }

  @override
  String get creationsNothingToAdd =>
      'Da war nichts dabei, was dieses Spiel als Grundstück, Raum, Haushalt oder Sim lesen kann. Custom Content und Mods gehen über die Bibliothek rein.';

  @override
  String get householdEdit => 'Bearbeiten';

  @override
  String get householdEditTitle => 'Haushalt bearbeiten';

  @override
  String householdEditBody(String name) {
    return 'Ändere, was der Spielstand über „$name“ sagt.';
  }

  @override
  String get householdEditName => 'Name';

  @override
  String get householdEditFunds => 'Geld';

  @override
  String householdEditFundsMax(String max) {
    return 'Bis $max, mehr fasst dieses Spiel nicht.';
  }

  @override
  String get householdEditSave => 'Speichern';

  @override
  String get householdEditNotice =>
      'Schließ zuerst das Spiel: Es schreibt seinen Spielstand beim Beenden neu. Vorher wird eine Kopie der Datei angelegt.';

  @override
  String get errorSaveEditHouseholdGone =>
      'Dieser Haushalt ist nicht mehr im Spielstand. Aktualisier die Liste und versuch es nochmal.';

  @override
  String errorSaveEditUnreadable(String file) {
    return '„$file“ ist nicht so aufgebaut, wie die App es neu schreiben kann, also wurde nichts geändert.';
  }

  @override
  String errorSaveEditVerification(String file) {
    return 'Das neu geschriebene „$file“ ließ sich nicht richtig zurücklesen und wurde verworfen. Dein Spielstand ist unangetastet.';
  }

  @override
  String get errorSaveEditUnsupported =>
      'Die Spielstände dieses Spiels lassen sich lesen, aber nicht ändern.';

  @override
  String whatsNewEyebrow(String version) {
    return 'Neu in $version';
  }

  @override
  String get whatsNewAlsoSince => 'Ebenfalls in diesem Update';

  @override
  String get whatsNewDismiss => 'Los geht’s';

  @override
  String get whatsNew300RootTitle =>
      'Mods, die in die Ordner des Spiels gehören';

  @override
  String get whatsNew300RootBody =>
      'Welten, Grafik-Tweaks und Script-Loader haben im Mods-Ordner nie funktioniert. Jetzt landen sie direkt in den Ordnern, die das Spiel ausliest, und was sie ersetzen, wird aufgehoben. Beim Deinstallieren bekommst du das Original zurück.';

  @override
  String get whatsNew300PacksTitle =>
      'Angebote können sagen, welche Packs sie brauchen';

  @override
  String get whatsNew300PacksBody =>
      'Creator können einen Mod mit den Packs versehen, für die er gebaut wurde, und The Exchange gleicht sie vor der Installation mit deinen ab. Immer nur ein Hinweis, nie eine verschlossene Tür.';

  @override
  String get whatsNew300ContainersTitle =>
      'Ein Zip voller .sims3pack-Dateien funktioniert einfach';

  @override
  String get whatsNew300ContainersBody =>
      'Zieh das ganze Set aufs Fenster. Die Sims-3-Container in einem Archiv werden dort geöffnet, wo sie liegen, und alles wird auf einmal installiert.';

  @override
  String get whatsNew300SimCityTitle => 'SimCity 3000, 4, Societies und 2013';

  @override
  String get whatsNew300SimCityBody =>
      'Vier Spiele mehr in der Seitenleiste. SimCity 4 liest beide Plugins-Ordner, behält die Ladereihenfolge bei, die Ordner- und Dateinamen vorgeben, und lässt alles in Ruhe, was sc4pac installiert hat. In den Einstellungen kannst du Spiele ausblenden, die du nicht spielst.';

  @override
  String get whatsNew300CatalogTitle => 'Tausende SimCity-4-Mods zum Stöbern';

  @override
  String get whatsNew300CatalogBody =>
      'The Exchange zeigt jetzt auch die sc4pac-Kanäle neben unseren eigenen Angeboten, mit Credit für das Projekt, das sie pflegt. Ein Download kommt mit allem, was er braucht, oder gar nicht, und wo ein Host keine App für dich herunterladen lässt, sagt der Button das gleich.';

  @override
  String get whatsNew300ThemeTitle => 'Such dir den Look aus, der dir gefällt';

  @override
  String get whatsNew300ThemeBody =>
      'Früher hat die App die Farben des Spiels übernommen, das gerade offen war. Jetzt wählst du in den Einstellungen deinen Look, und der bleibt, egal welches Spiel du verwaltest.';

  @override
  String get categoryLot => 'Grundstück';

  @override
  String get categoryModel => 'Modell';

  @override
  String get categoryDescription => 'Beschreibung';

  @override
  String get categoryBuilding => 'Gebäude';

  @override
  String get setupHelpSimCity4 =>
      'SimCity 4 liest Plugins aus zwei Ordnern gleichzeitig: Dokumente > SimCity 4 > Plugins (deiner, und der, den diese App verwaltet) und ein Plugins-Ordner im Spielverzeichnis. Ordner- und Dateinamen sind die Ladereihenfolge, lass die Struktur aus dem Download also in Ruhe - deshalb nutzt sc4pac nummerierte Ordner und heißen Overrides „zzz...“. DLL-Plugins laden nur direkt aus einem Plugins-Ordner, nie aus einem Unterordner, also legt die App sie dorthin. Was sc4pac installiert hat, gehört sc4pac: das listet sc4pac, nicht diese App.';

  @override
  String get setupHelpSimCity2013 =>
      'SimCity lädt Mods als .package aus SimCityUserData > Packages im Spielverzeichnis (meist unter Programme, Windows fragt also eventuell nach Administratorrechten). Diese App verwaltet nur diesen Ordner. Das Spiel liest auch seinen SimCityData-Ordner, aber darin liegen die Inhalte von Maxis - ein Mod, der vor den Paketen des Spiels laden muss, gehört von Hand dorthin. Viele Mods sind nur für den Offline-Modus: probier sie an einer Stadt aus, die du verlieren kannst.';

  @override
  String get setupHelpSimCity3000 =>
      'SimCity 3000 lädt eigene Gebäude (.bld-Dateien aus dem Building Architect Tool) aus einem Buildings-Ordner im Spielverzeichnis. Der ist flach - ein Gebäude in einem Unterordner wird nie geladen. Die Gebäude, die mit dem Spiel kamen, sind hier ausgeblendet, damit du sie nicht versehentlich löschst. Auflösungs- und Kompatibilitäts-Patches, die SC3U.exe selbst verändern, installiert diese App nicht; halte dich an deren eigene Anleitung.';

  @override
  String get setupHelpSimCitySocieties =>
      'SimCity Societies legt eigene Inhalte in Dokumente > SimCity Societies > Import ab - dorthin schreibt auch der Package Installer des Spiels. Diese App kann den Ordner für dich anlegen. Inhalte kommen als .SCSPack-Dateien, und genau nach dieser Endung sucht das Spiel selbst. Zur Warnung: Societies war zum Bearbeiten gedacht, nicht zum Laden fertiger Mods - das meiste, was die Szene gemacht hat, war C# und XML im Data-Ordner des Spiels zu ändern, und den fasst diese App nie an.';

  @override
  String get sectionManagedGames => 'Spiele';

  @override
  String prefManageGameTitle(String game) {
    return '$game verwalten';
  }

  @override
  String get prefManageGameDesc =>
      'In der Seitenleiste anzeigen. Ein ausgeblendetes Spiel behält alle seine Einstellungen.';

  @override
  String get errorLastManagedGame =>
      'Das ist das letzte Spiel in deiner Seitenleiste, es muss also bleiben. Schalte zuerst ein anderes ein, wenn du es ausblenden willst.';

  @override
  String catalogCount(int count) {
    return '$count Mods';
  }

  @override
  String catalogCuratedBy(String project) {
    return 'Katalog von $project';
  }

  @override
  String get catalogOpenPage => 'Seite öffnen';

  @override
  String catalogBlocked(String host) {
    return '$host lässt Apps nicht für dich herunterladen. Hol es dir auf der Seite des Mods.';
  }

  @override
  String get catalogUnresolvedNote =>
      'Dieser hier ließ sich nicht aus dem Katalog lesen.';

  @override
  String get catalogDependencies => 'Kommt mit';

  @override
  String catalogFileCount(int count) {
    return '$count Dateien';
  }

  @override
  String catalogDownloading(int current, int total) {
    return 'Lädt $current von $total';
  }

  @override
  String get catalogWarningTitle => 'Achtung';

  @override
  String get catalogConflictsTitle => 'Verträgt sich nicht mit';

  @override
  String catalogSourceFailed(String source) {
    return '$source nicht erreichbar';
  }

  @override
  String get catalogEmpty => 'Dazu passt nichts.';

  @override
  String get catalogRefresh => 'Katalog neu laden';

  @override
  String get catalogOptions => 'Optionen';

  @override
  String catalogBy(String author) {
    return 'von $author';
  }

  @override
  String get errorCatalogUnreachable =>
      'Der Katalog war nicht erreichbar. Prüf deine Verbindung und versuch es nochmal.';

  @override
  String get errorCatalogUnreadable =>
      'Der Katalog hat etwas geantwortet, das diese Version nicht lesen kann.';

  @override
  String errorCatalogDownloadFailed(String host) {
    return '$host hat den Download abgelehnt.';
  }

  @override
  String get errorCatalogInstallFailed =>
      'Beim Installieren ist etwas schiefgegangen.';

  @override
  String get errorCatalogInstallCancelled => 'Installation abgebrochen.';

  @override
  String get catalogLoading => 'Katalog wird geladen…';

  @override
  String get catalogBack => '← Zurück zum Katalog';

  @override
  String get catalogPromoTitle => 'Selbst was gebaut?';

  @override
  String get catalogPromoBody =>
      'Stell ihn in The Exchange: Ein Klick installiert ihn, er bekommt eine eigene Seite samt Link, und wer ihn schon hat, erfährt von Updates.';
}
