// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class LNl extends L {
  LNl([String locale = 'nl']) : super(locale);

  @override
  String get appName => 'Sims Mod Manager';

  @override
  String get brandTitle => 'Mod Manager';

  @override
  String get brandSubtitle => 'voor De Sims en SimCity';

  @override
  String get navLibrary => 'Bibliotheek';

  @override
  String get navShop => 'The Exchange';

  @override
  String get navSettings => 'Instellingen';

  @override
  String get shopAlphaBadge => 'ALFA';

  @override
  String get shopTagline => 'Mods van de community, geïnstalleerd in één klik.';

  @override
  String shopListingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods op de planken',
      one: '1 mod op de planken',
    );
    return '$_temp0';
  }

  @override
  String get shopRefresh => 'Ververs';

  @override
  String get shopPublish => 'Publiceer jouw mods';

  @override
  String get shopLoadFailedTitle => 'The Exchange antwoordt niet';

  @override
  String get shopLoadFailedBody =>
      'De planken konden niet geladen worden. Controleer je verbinding en probeer opnieuw.';

  @override
  String get shopRetry => 'Probeer opnieuw';

  @override
  String get shopEmptyTitle => 'De planken zijn nog leeg';

  @override
  String get shopEmptyBody =>
      'The Exchange opende zonet zijn deuren en niemand heeft al iets gepubliceerd. Zo nieuw is het. Zelf een mod gemaakt? Wees de eerste op de planken!';

  @override
  String get shopAllGames => 'Alle spellen';

  @override
  String get shopShowAllGames => 'Toon elk spel';

  @override
  String shopEmptyGameTitle(String game) {
    return 'Nog niets voor $game';
  }

  @override
  String shopEmptyGameBody(String game) {
    return 'Andere spellen hebben mods op de planken, maar er zijn er nog geen voor $game. Eén gemaakt? Wees de eerste!';
  }

  @override
  String shopBy(String author) {
    return 'door $author';
  }

  @override
  String get shopInstalled => 'Geïnstalleerd';

  @override
  String get shopUpdate => 'Update';

  @override
  String get shopUpdateBadge => 'update';

  @override
  String shopUpdatesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count van je mods hebben nieuwe versies op The Exchange',
      one: '1 van je mods heeft een nieuwe versie op The Exchange',
    );
    return '$_temp0';
  }

  @override
  String get shopUpdateHeading => 'Van deze is er een nieuwe versie';

  @override
  String shopUpdateBody(String version, String author) {
    return '$author heeft v$version gepubliceerd op The Exchange. Bijwerken vervangt de bestanden die je nu hebt.';
  }

  @override
  String get shopUpdateSeeListing => 'Bekijk de modpagina';

  @override
  String get shopInstalling => 'Installeren…';

  @override
  String get shopInstallNotes => 'Installatienotities';

  @override
  String get shopCreatorNudge =>
      'Zelf mods gemaakt? Publiceren op The Exchange is gratis en spelers installeren jouw werk in één klik.';

  @override
  String shopNeedsFolder(String game) {
    return 'Stel eerst de mods-map van $game in. Het tabblad Bibliotheek legt je uit hoe.';
  }

  @override
  String shopVariations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count varianten',
      one: '1 variant',
    );
    return '$_temp0';
  }

  @override
  String get shopSaveFile => 'Downloaden';

  @override
  String get shopSaving => 'Downloaden…';

  @override
  String get shopSaved => 'Opgeslagen';

  @override
  String get shopSaveHint =>
      'Installeren zet de bestanden meteen in je mods-map. Downloaden bewaart alleen het bestand, waar jij het wilt hebben.';

  @override
  String get shopRequires => 'Heeft deze packs nodig';

  @override
  String get shopRequirementMet => 'Geïnstalleerd';

  @override
  String get shopRequirementDisabled => 'Uitgezet';

  @override
  String get shopRequirementMissing => 'Niet geïnstalleerd';

  @override
  String get shopRequirementUnknown => 'Niet gecontroleerd';

  @override
  String get shopRequirementsNote =>
      'Je kunt hem sowieso installeren — hij doet alleen weinig zolang de packs er niet zijn.';

  @override
  String get shopRequirementsOffNote =>
      'Eén hiervan staat uit. Zet hem weer aan op het tabblad Packs.';

  @override
  String get shopRequirementsUnknownNote =>
      'We konden de packs van dit spel op deze computer niet controleren, dus dit is wat de maker zegt.';

  @override
  String get shopDestination => 'Installeert in';

  @override
  String get shopVariationPick => 'Selecteer een variant';

  @override
  String get shopBack => 'Terug naar de planken';

  @override
  String get shopCopyLink => 'Kopieer link';

  @override
  String get shopLinkCopied => 'Link gekopieerd';

  @override
  String get sidebarGames => 'SPELLEN';

  @override
  String sidebarNotInstalled(String detail) {
    return 'niet geïnstalleerd · $detail';
  }

  @override
  String sidebarModCount(int count, String detail) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods',
      one: '1 mod',
    );
    return '$_temp0 · $detail';
  }

  @override
  String get updateAvailable => 'Update beschikbaar';

  @override
  String updateClickToDownload(String version) {
    return 'v$version: klik om te downloaden';
  }

  @override
  String get storage => 'Opslag';

  @override
  String storageInMods(String size) {
    return '$size in mods';
  }

  @override
  String storageFreeOf(String free, String total) {
    return '$free vrij van $total';
  }

  @override
  String dropToInstall(String game) {
    return 'Sleep hierheen om te installeren in $game';
  }

  @override
  String get dropFolders => 'mappen';

  @override
  String scanningMods(int done, int total) {
    return 'Mods worden gecontroleerd op afbeeldingen en conflicten… $done van $total';
  }

  @override
  String get skip => 'Overslaan';

  @override
  String libraryTitle(String game) {
    return '$game Bibliotheek';
  }

  @override
  String modsShown(int count, String era) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods weergegeven',
      one: '1 mod weergegeven',
    );
    return '$_temp0 · $era';
  }

  @override
  String get learnMore => 'Meer info';

  @override
  String get dismiss => 'Sluiten';

  @override
  String get searchMods => 'Mods zoeken…';

  @override
  String get viewGrid => 'Raster';

  @override
  String get viewList => 'Lijst';

  @override
  String get viewFolders => 'Mappen';

  @override
  String get sortTooltip => 'Sorteer';

  @override
  String get sortByName => 'Naam (A–Z)';

  @override
  String get sortByRecent => 'Recent gewijzigd';

  @override
  String get sortBySize => 'Grootste eerst';

  @override
  String get sortDisabledLast => 'Uitgeschakelde als laatste';

  @override
  String get libraryRefresh => 'Ververs';

  @override
  String get libraryRootFolder => 'Mods-map';

  @override
  String get selectionTooltip => 'Selecteer';

  @override
  String selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count geselecteerd',
      one: '1 geselecteerd',
    );
    return '$_temp0';
  }

  @override
  String get selectionSelectAll => 'Alles selecteren';

  @override
  String get selectionClear => 'Wissen';

  @override
  String get selectionEnable => 'Inschakelen';

  @override
  String get selectionDisable => 'Uitschakelen';

  @override
  String selectionProgress(int done, int total) {
    return '$done van $total';
  }

  @override
  String selectionDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods deïnstalleren?',
      one: '1 mod deïnstalleren?',
    );
    return '$_temp0';
  }

  @override
  String selectionDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Alle $count bestanden worden van de schijf verwijderd. Dit kan niet ongedaan gemaakt worden.',
      one:
          'Het bestand wordt van de schijf verwijderd. Dit kan niet ongedaan gemaakt worden.',
    );
    return '$_temp0';
  }

  @override
  String get selectionMove => 'Verplaats naar…';

  @override
  String get newFolder => 'Nieuwe map';

  @override
  String newFolderIn(String folder) {
    return 'In $folder';
  }

  @override
  String get newFolderHint => 'Naam van de map';

  @override
  String get create => 'Maak aan';

  @override
  String get move => 'Verplaats';

  @override
  String moveTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods verplaatsen waarheen?',
      one: '1 mod verplaatsen waarheen?',
    );
    return '$_temp0';
  }

  @override
  String get moveBody =>
      'De bestanden verhuizen op de schijf. Verder verandert er niets aan - wat uitgeschakeld staat, blijft uitgeschakeld.';

  @override
  String get installFolderTitle => 'Welke map?';

  @override
  String installFolderBody(String game) {
    return 'Waar de bestanden terechtkomen in je mods-map voor $game.';
  }

  @override
  String get installFolderChoose => 'Kies';

  @override
  String get installFolderEmpty =>
      'Nog geen submappen. Maak er een aan, of laat alles in de mods-map staan.';

  @override
  String get folderEmptySection => 'Hier zit nog niets in';

  @override
  String get install => 'Installeer';

  @override
  String filePickerModsLabel(String game) {
    return '$game mods';
  }

  @override
  String get installWhereTitle => 'Waar moet dit?';

  @override
  String installWhereBody(String game) {
    return '$game leest mods uit verschillende mappen. De app kan zelf zien waar het moet komen of je kan zeggen waar het moet.';
  }

  @override
  String get installWhereSorted => 'Zoek het uit voor mij';

  @override
  String get installWhereSortedDesc =>
      'Volg de mappen die de download zelf noemt en plaats de rest op bestandstype.';

  @override
  String get installWhereRemember => 'Niet opnieuw vragen';

  @override
  String get destinationSims1Downloads =>
      'Objecten, hacks en meeste downloads.';

  @override
  String get destinationSims1Global =>
      'Mods die het basisspel globaal aanpassen.';

  @override
  String get destinationSims1Objects =>
      'Mods die de objectbestanden van het spel zelf aanpassen.';

  @override
  String get destinationSims1Skins =>
      'Gewone skins en hoofden. Deze worden getoond in Create a Sim.';

  @override
  String get destinationSims1SkinsBuy => 'Kledij verkocht in openbare winkels.';

  @override
  String get destinationSims1Walls => 'Wandbekleding.';

  @override
  String get destinationSims1Floors => 'Vloertegels.';

  @override
  String get destinationSims1Roofs => 'Daktexturen.';

  @override
  String get prefAskWhereTitle => 'Vraag waar te installeren';

  @override
  String get prefAskWhereDesc =>
      'Dit spel leest mods uit meer dan één map. Kies de map elke keer in plaats van de app te laten beslissen';

  @override
  String get statTotal => 'Totaal';

  @override
  String get statEnabled => 'Ingeschakeld';

  @override
  String get statDisabled => 'Uitgeschakeld';

  @override
  String get statConflicts => 'Conflicten';

  @override
  String get statTotalTooltip => 'Elke mod in deze map, in- of uitgeschakeld.';

  @override
  String get statTotalTooltipClear =>
      'Elke mod in deze map. Klik om de zoekopdracht en elke filter te wissen.';

  @override
  String get statEnabledTooltip => 'Mods die door het spel geladen worden.';

  @override
  String get statEnabledTooltipActive =>
      'Toont enkel ingeschakelde mods. Klik om alle mods opnieuw te tonen.';

  @override
  String get statDisabledTooltip => 'Mods die uitgeschakeld in de map zitten.';

  @override
  String get statDisabledTooltipActive =>
      'Toont enkel uitgeschakelde mods. Klik om alle mods opnieuw te tonen.';

  @override
  String get conflictTooltipActive =>
      'Toont enkel mods met conflicten. Klik om alle mods opnieuw te tonen.';

  @override
  String get conflictTooltip =>
      'Ingeschakelde mods die dezelfde bestandsnaam hebben als een andere ingeschakelde mod, die in meerdere versies geïnstalleerd zijn of die dezelfde onderdelen in het spel overschrijven. Het spel houdt enkel de kopie die het als laatste laadt, soms met opzet (patchmods), vaak niet.';

  @override
  String get conflictTooltipClickHint => 'Klik om enkel deze mods te tonen.';

  @override
  String get filterAll => 'Alle';

  @override
  String get emptyFiltered => 'Geen mods matchen met jouw filters';

  @override
  String get emptyNoMods => 'Nog geen mods';

  @override
  String get emptyFilteredHint =>
      'Probeer de zoekopdracht te wissen of kies een andere filter.';

  @override
  String emptyNoModsHint(String path) {
    return 'Deze map wordt in de gaten gehouden:\n$path';
  }

  @override
  String get openFolder => 'Open map';

  @override
  String get conflictBadge => 'conflict';

  @override
  String get duplicateBadge => 'kopie';

  @override
  String modInFolder(String folder) {
    return 'in $folder';
  }

  @override
  String get modInModsFolder => 'in de map Mods';

  @override
  String setupFoundNoModsFolder(String game) {
    return '$game gevonden, maar er is nog geen mods-map';
  }

  @override
  String setupNotFound(String game) {
    return 'Mods-map van $game niet gevonden';
  }

  @override
  String get setupFoundNoModsFolderBody =>
      'De map van het spel staat op deze computer; die bevat alleen nog geen mods-map. Maak deze hier aan, of verwijs zelf naar een map.';

  @override
  String get setupNotFoundBody =>
      'Het spel is misschien niet geïnstalleerd, staat op een ongewone plaats of de mods-map bestaat nog niet.';

  @override
  String get foundOnThisComputer => 'GEVONDEN OP DEZE COMPUTER';

  @override
  String get chooseFolder => 'Kies een map…';

  @override
  String get createItForMe => 'Maak het voor mij';

  @override
  String willBeCreatedAt(String path) {
    return 'Wordt aangemaakt op:\n$path';
  }

  @override
  String get checkAgain => 'Controleer opnieuw';

  @override
  String get useThis => 'Gebruik dit';

  @override
  String get enabled => 'Ingeschakeld';

  @override
  String get disabled => 'Uitgeschakeld';

  @override
  String get showInFileManager => 'Toon in bestandsbeheerder';

  @override
  String get uninstallMod => 'Deïnstalleer mod';

  @override
  String uninstallConfirmTitle(String title) {
    return '$title deïnstalleren?';
  }

  @override
  String uninstallConfirmBody(String path) {
    return 'Het bestand wordt van de schijf verwijderd:\n$path';
  }

  @override
  String get cancel => 'Annuleer';

  @override
  String get uninstall => 'Deïnstalleer';

  @override
  String conflictSameFileHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count andere ingeschakelde mods zijn exact hetzelfde bestand:',
      one: 'Een andere ingeschakelde mod is exact hetzelfde bestand:',
    );
    return '$_temp0';
  }

  @override
  String conflictSameNameHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count andere ingeschakelde mods hebben dezelfde bestandsnaam:',
      one: 'Een andere ingeschakelde mod heeft dezelfde bestandsnaam:',
    );
    return '$_temp0';
  }

  @override
  String conflictVersionHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count andere ingeschakelde mods lijken andere versies van deze mod te zijn:',
      one:
          'Een andere ingeschakelde mod lijkt een andere versie van deze mod te zijn:',
    );
    return '$_temp0';
  }

  @override
  String conflictResourcesHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count andere ingeschakelde mods overschrijven hetzelfde in het spel:',
      one: 'Een andere ingeschakelde mod overschrijft hetzelfde in het spel:',
    );
    return '$_temp0';
  }

  @override
  String sharedResources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gedeelde onderdelen',
      one: '1 gedeeld onderdeel',
    );
    return '$_temp0';
  }

  @override
  String get conflictSameFileBody =>
      'De duplicatenscan heeft deze bestanden gelezen en ze komen byte voor byte overeen, dus dit zijn geen twee mods die ruziemaken - het is dezelfde download die meer dan één keer in je map zit. Er een houden en de rest verwijderen verandert niets in het spel en geeft je de ruimte terug.';

  @override
  String get conflictSameNameBody =>
      'Identieke namen betekenen meestal dat dezelfde mod tweemaal is geïnstalleerd of dat de packages van twee creators botsen. Het spel laadt hun overlappende onderdelen in een onvoorspelbare volgorde: hou één mod en schakel de rest uit of verwijder ze.';

  @override
  String get conflictVersionBody =>
      'Meerdere versies van een mod geïnstalleerd hebben, betekent dat het spel overlappende onderdelen laadt in een onvoorspelbare volgorde: hou de nieuwste en schakel de rest uit of verwijder ze.';

  @override
  String get conflictResourcesBody =>
      'Deze packages bevatten onderdelen met dezelfde ID\'s dus het spel houdt enkel de package die het laatst wordt geladen. Dit kan zo bedoeld zijn (patch- en override-mods overschrijven bewust onderdelen van een andere mod), maar voor ongerelateerde mods betekent dit dat één van hen stilletjes stopt met werken: hou diegene die je wilt en schakel de rest uit.';

  @override
  String get conflictIgnore => 'Negeer';

  @override
  String get conflictIgnoreTooltip =>
      'Is dit conflict met opzet? Verberg het dan. Er verandert niets aan de mod, en je kan de waarschuwing terughalen vanaf deze pagina of vanuit Instellingen.';

  @override
  String get conflictRestore => 'Terughalen';

  @override
  String advisoryBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count van je mods hebben gekende problemen',
      one: 'Een van je mods heeft een gekend probleem',
    );
    return '$_temp0';
  }

  @override
  String get advisoryShow => 'Neem een kijkje';

  @override
  String get advisoryShowAll => 'Toon alle mods';

  @override
  String get advisoryBadge => 'probleem';

  @override
  String get advisoryBrokenHeading => 'Deze mod is als kapot gerapporteerd';

  @override
  String get advisoryBrokenBody =>
      'Andere spelers rapporteren dat deze het spel doet stoppen met werken. Deze uitschakelen is de snelste manier om te weten of het de oorzaak is van je probleem.';

  @override
  String get advisoryOutdatedHeading =>
      'Er is een nieuwere versie van deze mod';

  @override
  String get advisoryOutdatedBody =>
      'De versie die je hebt is diegene waar mensen problemen mee hebben. De laatste nieuwe van de creator gaan halen zou dit moeten oplossen.';

  @override
  String get advisoryCautionHeading =>
      'De moeite waard om in het oog te houden';

  @override
  String get advisoryCautionBody =>
      'Deze werkt voor de meeste mensen, maar het is geweten dat deze zich misdraagt. De moeite waard om deze uit te schakelen als je een probleem probeert te detecteren.';

  @override
  String advisorySince(String since) {
    return 'Sinds $since';
  }

  @override
  String get advisoryOpenLink => 'Open de pagina van de creator';

  @override
  String get advisorySource =>
      'Gerapporteerd door andere spelers, niet door het spel.';

  @override
  String modInDirectory(String dir) {
    return 'in $dir';
  }

  @override
  String get factVersion => 'Versie';

  @override
  String get factFormat => 'Formaat';

  @override
  String get factSize => 'Grootte';

  @override
  String get factType => 'Type';

  @override
  String get factModified => 'Aangepast';

  @override
  String get factDownloads => 'Downloads';

  @override
  String get factIgnoredConflicts => 'Genegeerd';

  @override
  String ignoredConflictsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conflicten',
      one: '1 conflict',
    );
    return '$_temp0';
  }

  @override
  String get statusHeading => 'Status';

  @override
  String get statusEnabledBody =>
      'Deze mod is actief: het spel zal deze laden bij de volgende opstart.';

  @override
  String statusDisabledBody(String marker) {
    return 'Deze mod is uitgeschakeld: het bestand blijft op de schijf staan met een \"$marker\" erachter, zodat het spel het overslaat. Je kan het op elk moment weer inschakelen; er wordt niets verwijderd.';
  }

  @override
  String get fileOnDisk => 'Bestand op de schijf';

  @override
  String get insideThePackage => 'Binnenin de package';

  @override
  String resourcesTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count onderdelen in totaal',
      one: '1 onderdeel in totaal',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get sectionModManagement => 'MODBEHEER';

  @override
  String get sectionAppearance => 'UITERLIJK';

  @override
  String get sectionLanguage => 'TAAL';

  @override
  String get sectionPrivacy => 'PRIVACY';

  @override
  String sectionModsFolder(String game) {
    return 'MODS-MAP · $game';
  }

  @override
  String sectionGameCaches(String game) {
    return 'SPELCACHES · $game';
  }

  @override
  String sectionIgnoredConflicts(String game) {
    return 'GENEGEERDE CONFLICTEN · $game';
  }

  @override
  String sectionShopFolder(String game) {
    return 'THE EXCHANGE · $game';
  }

  @override
  String get prefShopFolderTitle => 'Waar mods van The Exchange terechtkomen';

  @override
  String prefShopFolderDesc(String folder) {
    return 'Installaties komen in $folder';
  }

  @override
  String get sectionFeedback => 'FEEDBACK';

  @override
  String get sectionAbout => 'OVER';

  @override
  String get prefWarnConflictsTitle => 'Waarschuw voor conflicten';

  @override
  String get prefWarnConflictsDesc =>
      'Geef ingeschakelde mods een label als ze dezelfde bestandsnaam hebben of dezelfde onderdelen in het spel overschrijven als een andere mod';

  @override
  String get prefConflictKindsTitle => 'Voor welke conflicten waarschuwen';

  @override
  String get prefConflictKindsDesc =>
      'Zet de soorten uit die je niet gelabeld wilt zien. De rest blijft gewoon werken';

  @override
  String get conflictKindSameFile => 'Identieke kopieën';

  @override
  String get conflictKindSameName => 'Zelfde bestandsnaam';

  @override
  String get conflictKindVersions => 'Verschillende versies';

  @override
  String get conflictKindResources => 'Gedeelde onderdelen';

  @override
  String get prefConfirmDeleteTitle => 'Vraag bevestiging bij deïnstalleren';

  @override
  String get prefConfirmDeleteDesc =>
      'Vraag het eerst voor een modbestand van de schijf verwijderd wordt';

  @override
  String get prefShowDisabledTitle => 'Toon uitgeschakelde mods';

  @override
  String get prefShowDisabledDesc =>
      'Hou uitgeschakelde mods zichtbaar in de bibliotheek in plaats van ze te verbergen';

  @override
  String get prefDisabledSuffixTitle => 'Markering voor uitgeschakelde mods';

  @override
  String get prefDisabledSuffixDesc =>
      'Wat er achter een bestandsnaam komt wanneer je een mod uitschakelt. Pas het aan om bij een andere manager te passen (CC Magic gebruikt .off); de app leest ze allebei, en mods die je al had uitgeschakeld houden de naam die ze hebben';

  @override
  String get prefDisabledSuffixInvalid =>
      'Moet een punt en een paar letters of cijfers zijn, zoals .off';

  @override
  String get prefExperimentalPacksTitle => 'Experimentele packschakelaars';

  @override
  String get prefExperimentalPacksDesc =>
      'Laat de packs van dit spel uitschakelen. Niet getest op deze release, en een buurt waarin je met een pack hebt gespeeld kan er zonder stukgaan — maak eerst een back-up van je saves';

  @override
  String get prefScanArtworkTitle => 'Kijk in mods';

  @override
  String get prefScanArtworkDesc =>
      'Kijk tijdens het laden van de bibliotheek in de modbestanden naar afbeeldingen, inhoud en mods die dezelfde onderdelen overschrijven';

  @override
  String get prefSoundEffectsTitle => 'Geluidseffecten';

  @override
  String get prefSoundEffectsDesc =>
      'Speel de klassieke Sims-geluiden bij klikken, schakelaars en meldingen';

  @override
  String get prefAnalyticsTitle => 'Deel anonieme gebruiksgegevens';

  @override
  String get prefAnalyticsDesc =>
      'Stuur anonieme gebruiksstatistieken en crashrapporten om de app beter te maken. Nooit modnamen, bestandspaden of iets persoonlijks';

  @override
  String get themeTitle => 'Thema';

  @override
  String get themeDesc =>
      'Licht of donker. “Systeem” volgt de instelling van je computer.';

  @override
  String get themeSystem => 'Systeem';

  @override
  String get themeLight => 'Licht';

  @override
  String get themeDark => 'Donker';

  @override
  String get appThemeTitle => 'App-thema';

  @override
  String get appThemeDesc =>
      'Hoe de hele app eruitziet. Blijft hetzelfde, welk spel je ook beheert.';

  @override
  String get appThemeDefault => 'Standaard';

  @override
  String get languageTitle => 'Taal van de app';

  @override
  String get languageDesc =>
      'Kies de taal waarin de app getoond wordt. “Systeem” volgt de taal van je computer.';

  @override
  String get languageSystem => 'Systeem';

  @override
  String get translatorsTitle => 'Vertaald door';

  @override
  String get translatorsDesc =>
      'De app spreekt twaalf talen dankzij deze simmers.';

  @override
  String get sectionStartup => 'OPSTARTEN';

  @override
  String get prefDefaultGameTitle => 'Spel om mee te openen';

  @override
  String get prefDefaultGameDesc =>
      'Met welke bibliotheek de app opent wanneer je hem opstart';

  @override
  String get defaultGameAuto => 'Automatisch';

  @override
  String get prefSetupGuideTitle => 'Instelhulp';

  @override
  String get prefSetupGuideDesc =>
      'Loop de vragen van de eerste keer nog eens door';

  @override
  String get onboardingReplay => 'Nog eens doen';

  @override
  String get onboardingSkip => 'Sla het instellen over';

  @override
  String get onboardingSkipIntro => 'Sla de intro over';

  @override
  String get onboardingBack => 'Terug';

  @override
  String get onboardingNext => 'Volgende';

  @override
  String get onboardingFinish => 'Open mijn bibliotheek';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Stap $current van $total';
  }

  @override
  String get onboardingWelcomeTitle => 'Hey! Laten we je op weg helpen';

  @override
  String get onboardingWelcomeBody =>
      'Een paar korte vragen en je mods zijn klaar voor gebruik. Het duurt geen minuut, en alles hier kan je later nog aanpassen in Instellingen.';

  @override
  String get onboardingGamesTitle => 'Op zoek naar je spellen';

  @override
  String get onboardingGamesBody =>
      'We kijken op de gebruikelijke plaatsen naar elk spel en naar de map waaruit het mods leest.';

  @override
  String get onboardingScanning => 'Nog aan het zoeken…';

  @override
  String onboardingGamesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spellen gevonden',
      one: '1 spel gevonden',
      zero: 'Nog niets gevonden',
    );
    return '$_temp0';
  }

  @override
  String onboardingGameMods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods al geïnstalleerd',
      one: '1 mod al geïnstalleerd',
      zero: 'Mods-map klaar',
    );
    return '$_temp0';
  }

  @override
  String get onboardingGameMissing => 'Niet op deze computer';

  @override
  String get onboardingNoGamesTitle => 'Niets kunnen vinden';

  @override
  String get onboardingNoGamesBody =>
      'Geen probleem. Wijs de app zelf een mods-map aan in Instellingen en alles werkt precies hetzelfde.';

  @override
  String get onboardingFavoriteTitle => 'Welke speel je het meest?';

  @override
  String get onboardingFavoriteBody =>
      'De app opent elke keer met dit spel. Je kan altijd van spel wisselen via de zijbalk.';

  @override
  String get onboardingLookTitle => 'Maak het helemaal van jou';

  @override
  String get onboardingLookBody =>
      'De hele app draagt de look die jij kiest, welke game je ook beheert. Kies hoe het eruit moet zien en moet klinken.';

  @override
  String get onboardingLibraryTitle => 'Hoe je bibliotheek leest';

  @override
  String get onboardingLibraryBody =>
      'Twee dingen die je nu al kan beslissen, want ze veranderen wat de bibliotheek je laat zien.';

  @override
  String get onboardingDoneTitle => 'Helemaal klaar!';

  @override
  String get onboardingDoneBody =>
      'Je bibliotheek is geladen en staat klaar. Sleep een modbestand op het venster wanneer je er een wilt installeren, en verander dit allemaal in Instellingen.';

  @override
  String get folderNotFound => 'Niet gevonden. Kies een map';

  @override
  String get folderNotLocated =>
      'Het spel (of de mods-map) is niet automatisch gevonden';

  @override
  String folderSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods',
      one: '1 mod',
    );
    return '$_temp0 · $size op de schijf';
  }

  @override
  String get customFolder => 'eigen map';

  @override
  String get change => 'Wijzig…';

  @override
  String get resetToAuto => 'Terug naar automatisch';

  @override
  String createDefaultFolderAt(String path) {
    return 'Maak de standaardmap (met de bestanden die het spel nodig heeft) aan op:\n$path';
  }

  @override
  String get createFolder => 'Maak de map aan';

  @override
  String get alsoFoundOnThisComputer => 'Ook gevonden op deze computer:';

  @override
  String get clearCacheTitle => 'Wis cachebestanden';

  @override
  String clearCacheDesc(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Verwijder $count cachebestanden ($size)',
      one: 'Verwijder 1 cachebestand ($size)',
    );
    return '$_temp0 zodat nieuwe of verwijderde inhoud opduikt; het spel maakt ze bij de volgende opstart opnieuw aan';
  }

  @override
  String get clearCaches => 'Wis caches';

  @override
  String get ignoredConflictsTitle => 'Conflicten die je negeert';

  @override
  String ignoredConflictsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count conflicten die de app van jou niet meer moet melden. Haal ze terug om ze weer in de bibliotheek te zien',
      one:
          'Eén conflict dat de app van jou niet meer moet melden. Haal het terug om het weer in de bibliotheek te zien',
    );
    return '$_temp0';
  }

  @override
  String get ignoredConflictsReset => 'Haal ze terug';

  @override
  String get reportBugTitle => 'Meld een bug';

  @override
  String get reportBugDesc =>
      'Open een bugrapport op GitHub; je appversie, besturingssysteem en huidige spel staan al ingevuld';

  @override
  String get reportBugButton => 'Melden…';

  @override
  String get suggestFeatureTitle => 'Stel iets voor';

  @override
  String get suggestFeatureDesc =>
      'Mis je iets? Vertel ons wat de mod manager beter zou maken';

  @override
  String get suggestFeatureButton => 'Voorstellen…';

  @override
  String get wikiTitle => 'Handleiding & FAQ';

  @override
  String get wikiDesc =>
      'Hoe je mods installeert, mapdetectie repareert en meer, op de wiki van het project';

  @override
  String get wikiButton => 'Open de wiki';

  @override
  String aboutTagline(String version, String series) {
    return 'Versie $version · Modbeheer voor $series';
  }

  @override
  String updateIsAvailable(String version) {
    return 'Versie $version is beschikbaar';
  }

  @override
  String get noUpdateFound => 'Geen update gevonden';

  @override
  String getVersion(String version) {
    return 'Haal v$version';
  }

  @override
  String get checkingForUpdates => 'Controleren…';

  @override
  String get checkForUpdates => 'Controleer op updates';

  @override
  String get categoryPackage => 'Package';

  @override
  String get categoryScript => 'Script';

  @override
  String get categoryObject => 'Object';

  @override
  String get categoryArchive => 'Archief';

  @override
  String get categorySkin => 'Skin';

  @override
  String get categoryTexture => 'Textuur';

  @override
  String get categoryWall => 'Muur';

  @override
  String get categoryFloor => 'Vloer';

  @override
  String get categoryWorld => 'Wereld';

  @override
  String get categorySettings => 'Instellingen';

  @override
  String get contentCasParts => 'CAS-onderdelen';

  @override
  String get contentObjects => 'objecten';

  @override
  String get contentTunings => 'tunings';

  @override
  String get contentBehaviors => 'gedragingen';

  @override
  String get contentTextTables => 'teksttabellen';

  @override
  String get contentTextures => 'texturen';

  @override
  String get contentMeshes => 'meshes';

  @override
  String get modKindCas => 'CAS';

  @override
  String get modKindBuildBuy => 'Bouwen & kopen';

  @override
  String get modKindGameplay => 'Gameplay';

  @override
  String get modKindScript => 'Script';

  @override
  String errorNoModFiles(String extensions, String name) {
    return 'Geen modbestanden ($extensions) gevonden in $name.';
  }

  @override
  String errorUnreadableArchive(String name) {
    return '$name is geen archief dat deze app kan lezen.';
  }

  @override
  String errorNoUnpacker(String format, String name) {
    return 'Niets op deze computer kan $format-archieven uitpakken. Pak $name zelf uit en installeer de bestanden die erin zitten.';
  }

  @override
  String errorNoUnpackerLinux(String format, String name) {
    return 'Niets op deze computer kan $format-archieven uitpakken. Installeer p7zip en probeer opnieuw, of pak $name zelf uit en installeer de bestanden die erin zitten.';
  }

  @override
  String errorNoUnpackerLinuxRar(String format, String name) {
    return 'Niets op deze computer kan $format-archieven uitpakken. Installeer p7zip of unrar en probeer opnieuw, of pak $name zelf uit en installeer de bestanden die erin zitten.';
  }

  @override
  String errorUnpackFailed(String name) {
    return '$name kon niet uitgepakt worden. Misschien zit er een wachtwoord op, is het één deel van een gesplitst archief of is de download beschadigd. Pak het handmatig uit en installeer de bestanden die erin zitten.';
  }

  @override
  String errorSims3PackUnreadable(String name) {
    return '$name is geen Sims 3-package die deze app kan lezen.';
  }

  @override
  String errorSims3PackWorld(String name) {
    return '$name is een wereld, geen custom content. Installeer het met de The Sims 3 Launcher - het spel houdt werelden buiten de mods-map.';
  }

  @override
  String errorSims3PackLibrary(String name) {
    return '$name is een kavel of een huishouden, geen custom content. Installeer het met de The Sims 3 Launcher - het komt in je bibliotheek in het spel terecht.';
  }

  @override
  String errorInstallFailed(String name, String reason) {
    return '“$name” kon niet geïnstalleerd worden - $reason. Pak het handmatig uit en installeer de bestanden die erin zitten als het blijft mislukken.';
  }

  @override
  String errorInstallFailedRaw(String name, String reason) {
    return '“$name” kon niet geïnstalleerd worden - $reason';
  }

  @override
  String errorFileInUseDelete(String name) {
    return '“$name” kon niet verwijderd worden - een ander programma gebruikt het (staat het spel aan?) of het is schrijfbeveiligd. Sluit alles wat het gebruikt en probeer opnieuw.';
  }

  @override
  String errorFileInUseRename(String name) {
    return '“$name” kon niet hernoemd worden - een ander programma gebruikt het (staat het spel aan?) of het is schrijfbeveiligd. Sluit alles wat het gebruikt en probeer opnieuw.';
  }

  @override
  String errorFileNameTaken(String name) {
    return '“$name” zit al in die map. Hernoem er een van de twee en probeer opnieuw.';
  }

  @override
  String errorFolderNameBad(String name) {
    return '“$name” werkt niet als mapnaam. Probeer er een zonder schuine strepen of tekens die je systeem voor zichzelf houdt.';
  }

  @override
  String errorFolderTooDeep(int levels) {
    return 'Het spel kijkt maar $levels mappen diep in de mods-map, dus alles wat je daaronder zet zou nooit geladen worden.';
  }

  @override
  String errorBulkMoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods konden niet verplaatst worden',
      one: '1 mod kon niet verplaatst worden',
    );
    return '$_temp0 - een ander programma gebruikt ze misschien (staat het spel aan?), ze zijn schrijfbeveiligd, of ze zitten al in die map onder dezelfde naam.';
  }

  @override
  String errorBulkToggleFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods konden niet omgeschakeld worden',
      one: '1 mod kon niet omgeschakeld worden',
    );
    return '$_temp0 - een ander programma gebruikt ze misschien (staat het spel aan?) of ze zijn schrijfbeveiligd.';
  }

  @override
  String errorBulkRemoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods konden niet verwijderd worden',
      one: '1 mod kon niet verwijderd worden',
    );
    return '$_temp0 - een ander programma gebruikt ze misschien (staat het spel aan?) of ze zijn schrijfbeveiligd.';
  }

  @override
  String errorFileMissing(String name) {
    return '“$name” zit niet meer in de mods-map - een ander programma heeft het misschien verplaatst of verwijderd.';
  }

  @override
  String get requirementMedievalModLoader =>
      'The Sims Medieval kan geen script- of coremods draaien zonder het loaderbestand van de community in de map Game\\Bin van het spel. Custom content werkt wel zonder; al de rest niet.';

  @override
  String get requirementSims4ModsOff =>
      'Het spel heeft custom content en mods uitgeschakeld staan in zijn eigen Game Options, dus hier wordt niets van geladen. Zet het weer aan onder Options > Game Options > Other en start het spel opnieuw.';

  @override
  String get requirementSims4ScriptModsOff =>
      'Je hebt hier scriptmods staan, maar in de Game Options van het spel staat “Script Mods Allowed” uit. Updates van het spel zetten dat terug.';

  @override
  String get requirementGetFile => 'Waar je het vindt';

  @override
  String tooDeepBanner(int count, int levels) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods zitten',
      one: 'Eén mod zit',
    );
    return '$_temp0 in een submap die het spel niet leest. Het kijkt maar $levels mappen diep in de mods-map - zet ze hoger en ze worden geladen.';
  }

  @override
  String get tooDeepShow => 'Toon ze';

  @override
  String get duplicatesFind => 'Zoek dubbele mods';

  @override
  String duplicatesScanning(int done, int total) {
    return 'De mods die kopieën kunnen zijn worden gelezen… $done van $total';
  }

  @override
  String get duplicatesStop => 'Stop';

  @override
  String duplicatesBanner(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods zijn hetzelfde bestand als een andere',
      one: 'Eén mod is hetzelfde bestand als een andere',
    );
    return '$_temp0 - dat is $size die je terug kan krijgen.';
  }

  @override
  String get duplicatesShow => 'Toon ze';

  @override
  String get duplicatesSelectExtras => 'Vink de overtollige kopieën aan';

  @override
  String get duplicatesClean => 'Niets hierin is een kopie van iets anders.';

  @override
  String get duplicatesDismiss => 'Begrepen';

  @override
  String tagTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Labels voor $count mods',
      one: 'Labels voor deze mod',
    );
    return '$_temp0';
  }

  @override
  String get tagBody =>
      'Je eigen labels, om later dingen terug te vinden. Tik er een aan om hem op te zetten of eraf te halen.';

  @override
  String get tagHint => 'Nieuw label';

  @override
  String get tagAdd => 'Voeg toe';

  @override
  String get tagDone => 'Klaar';

  @override
  String get tagHeading => 'Labels';

  @override
  String get tagAddFirst => 'Voeg een label toe';

  @override
  String tagRemove(String tag) {
    return 'Verwijder “$tag”';
  }

  @override
  String get selectionTag => 'Label…';

  @override
  String folderAlsoReading(String folders) {
    return 'Je spel leest ook $folders, dus mods die daarin zitten staan ook in deze bibliotheek.';
  }

  @override
  String errorFolderUnreadable(String folder) {
    return '“$folder” kon niet geopend worden. Kies een map op een schijf die deze computer kan bereiken - een telefoon, een camera of een losgekoppelde netwerkschijf kan je mods niet bewaren.';
  }

  @override
  String errorNoWriteAccess(String folder) {
    return 'De app mag niet schrijven naar “$folder”. Je systeem beschermt die map - geef je account schrijfrechten, of wijs de app iets anders aan in Instellingen.';
  }

  @override
  String get folderReadOnlyBanner =>
      'Deze mods-map is alleen-lezen, dus mods installeren en verwijderen werkt pas als je account erin mag schrijven.';

  @override
  String get elevatedNoDropBanner =>
      'Je draait als administrator, dus Windows laat je geen bestanden op het venster slepen. Gebruik in de plaats de knop Installeer - die werkt nog wel.';

  @override
  String errorShopDownload(String name) {
    return '“$name” kon niet gedownload worden van The Exchange. Controleer je verbinding en probeer opnieuw.';
  }

  @override
  String errorShopNoModFiles(String name) {
    return 'Er zit niets in “$name” dat dit spel kan installeren. Misschien is het helemaal geen mod - gebruik Downloaden om het bestand te bewaren waar jij het wilt hebben.';
  }

  @override
  String get errorShopListingNotFound =>
      'Die mod staat niet meer op The Exchange. Misschien is hij offline gehaald.';

  @override
  String get errorShopListingUnknownGame =>
      'Die mod is voor een spel dat deze versie van de app nog niet kent. Probeer te updaten.';

  @override
  String errorPackToggleFailed(String pack) {
    return '$pack kon niet omgeschakeld worden. Sluit het spel en probeer opnieuw.';
  }

  @override
  String get errorPackNoUserData =>
      'De eigen instellingenmap van het spel is niet gevonden, dus er is nergens om te noteren welke packs overgeslagen moeten worden. Start het spel eerst één keer.';

  @override
  String get errorPackNeedsAdmin =>
      'Windows liet de app dat niet veranderen. Start hem opnieuw als administrator en probeer het nog eens.';

  @override
  String get errorPackNotSupported =>
      'Packs kunnen op dit systeem niet omgeschakeld worden.';

  @override
  String get errorPackIsTheGame =>
      'Dat is de pack waar het spel echt vanuit draait, dus die moet aan blijven.';

  @override
  String get errorPackToggleRefused =>
      'Die pack kon niet gewijzigd worden. Sluit het spel en probeer opnieuw.';

  @override
  String get eraClassic => 'Klassiek';

  @override
  String get eraNightlife => 'Nightlife';

  @override
  String get eraAmbitions => 'Ambitions';

  @override
  String get eraModern => 'Modern';

  @override
  String get eraMedieval => 'Middeleeuws';

  @override
  String get navPacks => 'Packs';

  @override
  String get packsScanning => 'Op zoek naar je packs…';

  @override
  String get packsEmptyTitle => 'Geen packs gevonden';

  @override
  String packsEmptyBody(String game) {
    return 'Of $game staat niet geïnstalleerd waar de app het kan zien, of er staan nog geen packs naast.';
  }

  @override
  String get packsRescan => 'Controleer opnieuw';

  @override
  String packsSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count packs geïnstalleerd',
      one: '1 pack geïnstalleerd',
    );
    return '$_temp0';
  }

  @override
  String packsSummaryWithOff(int count, int off) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count packs aan',
      one: '1 pack aan',
    );
    return '$_temp0, $off uitgeschakeld';
  }

  @override
  String get packsOff => 'Uit';

  @override
  String get packsInstalled => 'Geïnstalleerd';

  @override
  String get packsNeedAdmin =>
      'Deze packs aan- en uitzetten heeft administratorrechten nodig, want daar houdt het spel zijn lijst bij. Start de app opnieuw als administrator om ze te wijzigen — slepen en neerzetten werkt zolang niet, dus het is de moeite om daarna terug te schakelen.';

  @override
  String get packsExperimentalTitle => 'Deze uitschakelen is experimenteel';

  @override
  String get packsExperimentalOff =>
      'Het werkt zoals het altijd gewerkt heeft voor dit spel, maar niemand heeft het op deze release getest — en een buurt waarin je met een pack hebt gespeeld kan stukgaan als je hem zonder dat pack opent. Alleen tonen is veilig. Zet experimentele packschakelaars aan in Instellingen als je het toch wilt proberen.';

  @override
  String get packsExperimentalOn =>
      'Maak eerst een back-up van je buurten. Een buurt waarin je met een pack hebt gespeeld kan stukgaan als je hem zonder dat pack opent, en dat valt van hieruit niet ongedaan te maken — het pack weer aanzetten brengt de save niet altijd terug.';

  @override
  String packsRestartNotice(String game) {
    return 'Start $game opnieuw op om dit door te voeren. Je packs blijven hoe dan ook geïnstalleerd.';
  }

  @override
  String packsAllOwnedSims4(String expansions, String gamePacks) {
    return '$expansions uitbreidingen. $gamePacks gamepacks. Vast allemaal netjes gekocht.';
  }

  @override
  String get packKindExpansions => 'Uitbreidingspakketten';

  @override
  String get packKindGamePacks => 'Gamepacks';

  @override
  String get packKindStuffPacks => 'Accessoirepakketten';

  @override
  String get packKindKits => 'Kits';

  @override
  String get packKindFreePacks => 'Gratis packs';

  @override
  String get navSaves => 'Saves';

  @override
  String get savesScanning => 'Je saves worden gelezen…';

  @override
  String get savesEmptyTitle => 'Geen saves gevonden';

  @override
  String savesEmptyBody(String game) {
    return 'Zodra je $game speelt en opslaat, verschijnen je werelden hier - families, foto\'s en al.';
  }

  @override
  String get savesRescan => 'Saves opnieuw scannen';

  @override
  String savesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saves gevonden',
      one: '1 save gevonden',
    );
    return '$_temp0';
  }

  @override
  String savesLastSaved(String date) {
    return 'Laatst opgeslagen $date';
  }

  @override
  String get savesShowInFolder => 'Toon in map';

  @override
  String savesBackups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count back-ups',
      one: '1 back-up',
    );
    return '$_temp0';
  }

  @override
  String get savesTabHouseholds => 'Huishoudens';

  @override
  String get savesTabAlbum => 'Fotoalbum';

  @override
  String get savesTabStats => 'Wereldstatistieken';

  @override
  String savesNeighborhood(int number) {
    return 'Buurt $number';
  }

  @override
  String get savesOtherHouseholds => 'Townies & andere huishoudens';

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
  String get savesFunds => 'Geld';

  @override
  String get savesRooms => 'Kamers';

  @override
  String savesBedsBaths(int beds, int baths) {
    return '$beds slaapk. · $baths badk.';
  }

  @override
  String savesByCreator(String name) {
    return 'door $name';
  }

  @override
  String get savesMembers => 'Leden';

  @override
  String get savesRelationships => 'Relaties';

  @override
  String get savesUnknownSim => 'Onbekende Sim';

  @override
  String get savesStatSims => 'Sims';

  @override
  String get savesStatHouseholds => 'Huishoudens';

  @override
  String get savesStatNetWorth => 'Vermogen';

  @override
  String get savesStatWorlds => 'Werelden';

  @override
  String get savesStatPhotos => 'Foto\'s';

  @override
  String savesAcrossHouseholds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'verspreid over $count huishoudens',
      one: 'in 1 huishouden',
    );
    return '$_temp0';
  }

  @override
  String savesPlayedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gespeeld',
      one: '1 gespeeld',
    );
    return '$_temp0';
  }

  @override
  String get savesSizeOnDisk => 'Grootte op de schijf';

  @override
  String get savesLifeStages => 'Levensfasen';

  @override
  String get savesTopSkills => 'Hoogste vaardigheden in deze save';

  @override
  String get savesSaveInfo => 'Savebestand';

  @override
  String get savesLastSavedLabel => 'Laatst opgeslagen';

  @override
  String get savesGameVersion => 'Spelversie';

  @override
  String get savesDescription => 'Beschrijving';

  @override
  String get savesAgeInfant => 'Baby';

  @override
  String get savesAgeBaby => 'Pasgeborene';

  @override
  String get savesAgeToddler => 'Peuter';

  @override
  String get savesAgeChild => 'Kind';

  @override
  String get savesAgeTeen => 'Tiener';

  @override
  String get savesAgeYoungAdult => 'Jongvolwassene';

  @override
  String get savesAgeAdult => 'Volwassene';

  @override
  String get savesAgeElder => 'Senior';

  @override
  String get savesGenderMale => 'Man';

  @override
  String get savesGenderFemale => 'Vrouw';

  @override
  String get savesSkillCooking => 'Koken';

  @override
  String get savesSkillMechanical => 'Mechanisch';

  @override
  String get savesSkillCharisma => 'Charisma';

  @override
  String get savesSkillBody => 'Lichaam';

  @override
  String get savesSkillLogic => 'Logica';

  @override
  String get savesSkillCreativity => 'Creativiteit';

  @override
  String get savesSkillCleaning => 'Schoonmaken';

  @override
  String get savesPersonalityNeat => 'Netjes';

  @override
  String get savesPersonalityOutgoing => 'Sociaal';

  @override
  String get savesPersonalityActive => 'Actief';

  @override
  String get savesPersonalityPlayful => 'Speels';

  @override
  String get savesPersonalityNice => 'Aardig';

  @override
  String get savesZodiacAries => 'Ram';

  @override
  String get savesZodiacTaurus => 'Stier';

  @override
  String get savesZodiacGemini => 'Tweelingen';

  @override
  String get savesZodiacCancer => 'Kreeft';

  @override
  String get savesZodiacLeo => 'Leeuw';

  @override
  String get savesZodiacVirgo => 'Maagd';

  @override
  String get savesZodiacLibra => 'Weegschaal';

  @override
  String get savesZodiacScorpio => 'Schorpioen';

  @override
  String get savesZodiacSagittarius => 'Boogschutter';

  @override
  String get savesZodiacCapricorn => 'Steenbok';

  @override
  String get savesZodiacAquarius => 'Waterman';

  @override
  String get savesZodiacPisces => 'Vissen';

  @override
  String get savesAspirationRomance => 'Romantiek';

  @override
  String get savesAspirationFamily => 'Familie';

  @override
  String get savesAspirationFortune => 'Fortuin';

  @override
  String get savesAspirationPopularity => 'Populariteit';

  @override
  String get savesAspirationKnowledge => 'Kennis';

  @override
  String get savesAspirationGrowUp => 'Opgroeien';

  @override
  String get savesAspirationPleasure => 'Plezier';

  @override
  String get savesAspirationGrilledCheese => 'Tosti';

  @override
  String get savesRelCrush => 'oogje op elkaar';

  @override
  String get savesRelLove => 'verliefd';

  @override
  String get savesRelEngaged => 'verloofd';

  @override
  String get savesRelMarried => 'getrouwd';

  @override
  String get savesRelFriends => 'vrienden';

  @override
  String get savesRelBestFriends => 'beste vrienden';

  @override
  String get savesRelSteady => 'vaste relatie';

  @override
  String get savesRelEnemies => 'vijanden';

  @override
  String get savesPhotoFamilyPortrait => 'Familieportret';

  @override
  String get savesPhotoLot => 'Kavel';

  @override
  String get savesPhotoSim => 'Simportret';

  @override
  String get savesPhotoSnapshot => 'Momentopname';

  @override
  String get savesProperty => 'Eigendom';

  @override
  String get savesGhost => 'geest';

  @override
  String savesCareerLevel(String career, int level) {
    return '$career · niveau $level';
  }

  @override
  String get savesSpeciesLargeDog => 'hond';

  @override
  String get savesSpeciesSmallDog => 'kleine hond';

  @override
  String get savesSpeciesCat => 'kat';

  @override
  String get savesOccultVampire => 'vampier';

  @override
  String get savesOccultZombie => 'zombie';

  @override
  String get savesOccultWerewolf => 'weerwolf';

  @override
  String get savesOccultPlantSim => 'PlantSim';

  @override
  String get savesOccultAlien => 'alien';

  @override
  String get savesOccultServo => 'servo';

  @override
  String get savesOccultWitch => 'heks';

  @override
  String get savesOccultBigfoot => 'bigfoot';

  @override
  String get savesOccultFairy => 'fee';

  @override
  String get savesOccultGenie => 'geest uit de fles';

  @override
  String get savesOccultMermaid => 'zeemeermin';

  @override
  String get savesLotResidential => 'Woonkavel';

  @override
  String get savesLotCommunity => 'Openbaar terrein';

  @override
  String get savesLotDorm => 'Studentenhuis';

  @override
  String get savesLotSecretSociety => 'Geheim genootschap';

  @override
  String get savesLotGreekHouse => 'Studentensociëteit';

  @override
  String get savesLotHotel => 'Hotel';

  @override
  String get savesLotSecret => 'Geheim terrein';

  @override
  String get savesLotBusiness => 'Bedrijf';

  @override
  String get savesLotApartment => 'Appartement';

  @override
  String savesGpa(String gpa) {
    return '$gpa GPA';
  }

  @override
  String savesSemester(int number) {
    return 'semester $number';
  }

  @override
  String savesPredestinedHobby(String hobby) {
    return 'Geboren voor $hobby';
  }

  @override
  String get savesHobbyCuisine => 'Koken';

  @override
  String get savesHobbyArts => 'Kunst & knutselen';

  @override
  String get savesHobbyFilm => 'Film & literatuur';

  @override
  String get savesHobbySports => 'Sport';

  @override
  String get savesHobbyGames => 'Spelletjes';

  @override
  String get savesHobbyNature => 'Natuur';

  @override
  String get savesHobbyTinkering => 'Sleutelen';

  @override
  String get savesHobbyFitness => 'Fitness';

  @override
  String get savesHobbyScience => 'Wetenschap';

  @override
  String get savesHobbyMusic => 'Muziek & dans';

  @override
  String get savesTieMother => 'moeder';

  @override
  String get savesTieFather => 'vader';

  @override
  String get savesTieSpouse => 'getrouwd met';

  @override
  String savesTieSibling(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'broers en zussen',
      one: 'broer of zus',
    );
    return '$_temp0';
  }

  @override
  String savesTieChild(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'kinderen',
      one: 'kind',
    );
    return '$_temp0';
  }

  @override
  String get savesInterestPolitics => 'Politiek';

  @override
  String get savesInterestMoney => 'Geld';

  @override
  String get savesInterestEnvironment => 'Milieu';

  @override
  String get savesInterestCrime => 'Misdaad';

  @override
  String get savesInterestEntertainment => 'Amusement';

  @override
  String get savesInterestCulture => 'Cultuur';

  @override
  String get savesInterestFood => 'Eten';

  @override
  String get savesInterestHealth => 'Gezondheid';

  @override
  String get savesInterestFashion => 'Mode';

  @override
  String get savesInterestSports => 'Sport';

  @override
  String get savesInterestParanormal => 'Paranormaal';

  @override
  String get savesInterestTravel => 'Reizen';

  @override
  String get savesInterestWork => 'Werk';

  @override
  String get savesInterestWeather => 'Weer';

  @override
  String get savesInterestAnimals => 'Dieren';

  @override
  String get savesInterestSchool => 'School';

  @override
  String get savesInterestToys => 'Speelgoed';

  @override
  String get savesInterestSciFi => 'Sciencefiction';

  @override
  String get savesInterestMusic => 'Muziek';

  @override
  String get savesInterestOutdoors => 'Buitenleven';

  @override
  String get setupHelpSims1 =>
      'De originele The Sims houdt custom content in zijn installatiemap, niet in Documents: objecten gaan in een map Downloads naast het spelbestand (bv. C:\\Program Files (x86)\\Maxis\\The Sims\\Downloads), en deze app sorteert de andere types automatisch - skins (.skn/.cmx/.bmp) naar GameData\\Skins, muren en vloeren naar GameData\\Walls en GameData\\Floors. De Legacy Collection uit 2025 werkt op dezelfde manier vanuit zijn eigen installatiemap (EA Games\\The Sims Legacy, of Steam\\steamapps\\common\\The Sims Legacy Collection). Staat het spel ergens anders (een andere schijf, een eigen Steam-bibliotheek), kies dan zelf de map Downloads.';

  @override
  String get setupHelpSims2 =>
      'The Sims 2 laadt custom content uit Documents > EA Games > The Sims 2 > Downloads (de Ultimate Collection gebruikt “The Sims 2 Ultimate Collection”; de Legacy Collection uit 2025 gebruikt “The Sims 2 Legacy”). Die map bestaat pas als je hem aanmaakt of één keer content installeert. Antwoord bij het opstarten van het spel “Yes” op de vraag over custom content, zodat downloads ingeschakeld zijn.';

  @override
  String get setupHelpSims3 =>
      'The Sims 3 maakt zelf geen mods-map aan: het heeft het “framework” van de community nodig, een map Mods > Packages in Documents > Electronic Arts > The Sims 3, plus een bestand Resource.cfg dat het spel zegt daaruit te lezen. Deze app kan allebei voor je aanmaken. Bij installaties van schijf of via Wine kan de map in de app-bundel zelf zitten; gebruik dan “Kies een map” om ernaar te verwijzen.';

  @override
  String get setupHelpSims4 =>
      'The Sims 4 laadt mods uit Documents > Electronic Arts > The Sims 4 > Mods. Het spel maakt die map aan wanneer het voor het eerst draait, dus start het spel één keer op als hij ontbreekt. Zet daarna in het spel Options > Game Options > Other > “Enable Custom Content and Mods” aan (en “Script Mods Allowed” voor .ts4script-bestanden) en start het spel opnieuw op.';

  @override
  String get setupHelpSimsMedieval =>
      'The Sims Medieval laadt mods uit zijn installatiemap, niet uit Documents: een map Mods > Packages naast de spelbestanden (bv. C:\\Program Files (x86)\\Origin Games\\The Sims Medieval), plus een bestand Resource.cfg in de installatiemap dat het spel zegt daaruit te lezen. Deze app kan allebei voor je aanmaken (Windows vraagt onder Program Files misschien om administratorrechten). De map Documents > Electronic Arts > The Sims Medieval bevat alleen saves; mods die je daar zet doen niets. Bij installaties via Wine/CrossOver of een eigen Steam-bibliotheek gebruik je “Kies een map” om naar Mods > Packages in de installatiemap te verwijzen.';

  @override
  String get prefSubfoldersTitle => 'Mappen tellen hun submappen mee';

  @override
  String get prefSubfoldersDesc =>
      'Een map toont ook alles wat eronder zit. Uit zijn cc en cc/defaults twee aparte planken.';

  @override
  String deleteFolderTitle(String folder) {
    return '$folder verwijderen?';
  }

  @override
  String get deleteFolderBody =>
      'De map en alles wat erin zit gaat weg, submappen incluis. Dit kan niet ongedaan gemaakt worden.';

  @override
  String deleteFolderMods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods worden verwijderd',
      one: '1 mod wordt verwijderd',
    );
    return '$_temp0';
  }

  @override
  String get deleteFolderEmpty => 'Er zitten geen mods in.';

  @override
  String get deleteFolder => 'Verwijder de map';

  @override
  String triviaTitle(String game) {
    return 'Plumbob weet raad · $game';
  }

  @override
  String get triviaContextLibrary =>
      'Het lijkt erop dat je mods aan het bekijken bent';

  @override
  String get triviaContextSaves => 'Het lijkt erop dat je in je saves zit';

  @override
  String get triviaContextPacks =>
      'Het lijkt erop dat je je packs aan het regelen bent';

  @override
  String triviaCounter(int index, int total) {
    return 'Weetje $index van $total';
  }

  @override
  String get triviaOpen => 'Vraag het de plumbob';

  @override
  String get triviaClose => 'Nu even niet';

  @override
  String get triviaPrevious => 'Vorig weetje';

  @override
  String get triviaNext => 'Volgend weetje';

  @override
  String get triviaAnother => 'Nog eentje';

  @override
  String get triviaToSettings =>
      'Genoeg gehad? Zet de plumbob uit in Instellingen';

  @override
  String get prefTriviaTitle => 'Weetjes van de plumbob';

  @override
  String get prefTriviaDesc =>
      'Laat de plumbob af en toe opduiken met een weetje over het spel waar je in zit';

  @override
  String get triviaCategoryOrigins => 'Ontstaan';

  @override
  String get triviaCategoryDesign => 'Ontwerp';

  @override
  String get triviaCategoryLore => 'Lore';

  @override
  String get triviaCategoryDeath => 'Dood';

  @override
  String get triviaCategoryMusic => 'Muziek';

  @override
  String get triviaCategoryCheats => 'Cheats';

  @override
  String get triviaCategoryRecords => 'Records';

  @override
  String get triviaCategoryModding => 'Modding';

  @override
  String get triviaCategoryLanguage => 'Taal';

  @override
  String get triviaCategoryCommunity => 'Community';

  @override
  String get triviaSeriesLlama =>
      'Maxis hield ooit een stemming in de hele studio voor een onofficiële mascotte. De kandidaten waren een varen, een runderlintworm en een lama. De lama won, en die duikt sindsdien in alle spellen op.';

  @override
  String get triviaSeriesSimlish =>
      'Simlish is voor de microfoon bedacht. Stephen Kearin en Gerri Lawlor kregen woorden als “hongerig” of “eenzaam” voorgeschoteld en improviseerden urenlang hoe die zouden moeten klinken.';

  @override
  String get triviaSeriesCheats =>
      'rosebud en klapaucius leveren allebei §1.000 op. Rosebud komt uit Citizen Kane; Klapaucius is een robotbouwer uit De Cyberiade van Stanisław Lem, een boek dat Will Wright al sinds SimCity als invloed noemt.';

  @override
  String get triviaSeriesRecords =>
      'Guinness noemt The Sims de best verkochte pc-gameserie aller tijden. Ruim tien jaar geleden ging de teller al over de 125 miljoen exemplaren, en de serie is in 60 talen vertaald.';

  @override
  String get triviaSeriesGoths =>
      'De familie Goth hoort bij de langstlopende families in games. Mortimer en Bella duiken sinds 2000 in elk hoofddeel op.';

  @override
  String get triviaSeriesReaper =>
      'Magere Hein heeft een biografie die je bij gewoon spelen nooit te zien krijgt. Daarin staat onder meer zijn lievelingsband: Styx.';

  @override
  String get triviaSeriesSimCity =>
      'The Sims is uit SimCity gegroeid. Will Wright wilde steeds verder inzoomen op de mensjes voor wie die stad gebouwd werd.';

  @override
  String get triviaSeriesLegacy =>
      'In januari 2025 zette EA The Sims en The Sims 2 weer te koop als Legacy Collections, met alle uitbreidingen erbij. Het zijn compatibiliteitsfixes en geen remasters, dus allebei spelen ze precies zoals vroeger.';

  @override
  String get triviaSeriesPlumbob =>
      'De groene diamant is op drie manieren gespeld: PlumbBob in The Sims, Plum Bob in The Sims 2 en plumbob sinds The Sims 4. Maxis zegt dat alle drie tijdens de ontwikkeling gebruikt werden.';

  @override
  String get triviaSeriesModScene =>
      'De modscene is bijna even oud als de serie. Binnen enkele maanden na het verschijnen van het eerste spel in 2000 gingen er al skin- en objecteditors rond, lang voor er officiële tools waren.';

  @override
  String get triviaSeriesConflicts =>
      'Een conflict is simpeler dan het klinkt. Twee mods claimen hetzelfde onderdeel, allebei worden ze geladen, en degene die het spel als laatste leest wint. Er gaat niets stuk, er wordt alleen iets overruled.';

  @override
  String get triviaSeriesPackage =>
      'Een .package-bestand is een DBPF-archief, kort voor Database Packed File. Maxis gebruikt dezelfde container al sinds SimCity 4, en daarom kan één tool twintig jaar custom content openen.';

  @override
  String get triviaSeriesRename =>
      'Een mod uitschakelen door hem te hernoemen is de oudste truc uit de scene. Het spel laadt alleen bestanden die het herkent, dus een hernoemde package blijft precies waar hij is en houdt zich stil.';

  @override
  String get triviaSeriesSaves =>
      'Sims-saves zijn buurten, geen slots. De families, de kavels, de herinneringen en de roddels zitten allemaal in één map die blijft groeien zolang jij blijft spelen.';

  @override
  String get triviaSeriesPacks =>
      'Een pack uitschakelen verplaatst nooit een bestand. Elk spel in de serie houdt ergens anders zijn eigen lijstje bij van wat er geladen moet worden, een regel in een instellingenbestand of een registersleutel, en er een verbergen is niets meer dan dat lijstje aanpassen.';

  @override
  String get triviaSims1Dollhouse =>
      'The Sims begon als een architectuursimulator met de naam Project Dollhouse. De Sims zelf werden er pas bij gezet zodat spelers konden beoordelen of een huis wel prettig woonde.';

  @override
  String get triviaSims1Oakland =>
      'Will Wright verloor zijn huis bij de grote brand van Oakland in 1991. Een huishouden helemaal opnieuw opbouwen, meubels en apparaten en routines, werd de kiem van het spel.';

  @override
  String get triviaSims1Toilet =>
      'Directieleden waren berucht onovertuigd door de pitch en noemden het een “wc-spel”, omdat Sims een badkamer nodig hadden.';

  @override
  String get triviaSims1HomeTactics =>
      'Voor het The Sims werd, heette de pitch Home Tactics: The Experimental Domestic Simulator. De testgroepen vonden ook die versie maar niets.';

  @override
  String get triviaSims1Myst =>
      'In 2002 ging The Sims voorbij Myst en werd het de best verkochte pc-game aller tijden.';

  @override
  String get triviaSims1Simlish =>
      'Simlish werd geïmproviseerd door stemacteurs die voortborduurden op flarden Oekraïens, Navajo, Tagalog en Estisch, met opzet betekenisloos gehouden zodat de taal nooit veroudert.';

  @override
  String get triviaSims1Architecture =>
      'De bouwgereedschappen waren voor 2000 zo bijzonder dat sommige spelers nooit een Sim plaatsten en het spel als gratis architectuursoftware gebruikten.';

  @override
  String get triviaSims1Audience =>
      'Ongewoon voor die tijd was het merendeel van de spelers vrouw, en dat is mee waarom de marketing er anders uitzag dan al de rest in het schap.';

  @override
  String get triviaSims1Cowplant =>
      'De koeplant debuteerde hier onder de naam Laganaphyllis Simnovorii, en heeft sindsdien in elke generatie stilletjes Sims opgegeten.';

  @override
  String get triviaSims1Plumbob =>
      'Het woord plumbob komt van de plumb bob, het schietlood dat bouwvakkers aan een touwtje hangen om zuiver verticaal te vinden. Dit was eerst een architectuurspel.';

  @override
  String get triviaSims1Release =>
      'Het spel verscheen op 4 februari 2000 en overtrof elke verkoopvoorspelling die EA ervoor had gemaakt.';

  @override
  String get triviaSims1Edith =>
      'Elk object in het spel werd geschreven in een taal die SimAntics heet, via een eigen tool met de naam Edith, genoemd naar Edith Bunker: het allereerste personage dat voor The Sims gebouwd werd.';

  @override
  String get triviaSims1Expansions =>
      'Zeven uitbreidingen in drieënhalf jaar, elk voorjaar en elk najaar één, van Livin\' Large in augustus 2000 tot Makin\' Magic in oktober 2003.';

  @override
  String get triviaSims1Unleashed =>
      'Unleashed bracht in 2002 huisdieren naar de serie en won Computer Simulation Game of the Year bij de Interactive Achievement Awards.';

  @override
  String get triviaSims1Clown =>
      'De Tragic Clown komt een verdrietige Sim opvrolijken die zijn schilderij bezit. Hij is daar buitengewoon slecht in, en dat is de hele grap.';

  @override
  String get triviaSims1Llama =>
      'In de originele gedrukte handleiding stond een boekje met de titel Making the Most of Your Llama. Niemand heeft dat ooit uitgelegd.';

  @override
  String get triviaSims1Superstar =>
      'Met Superstar kon een Sim acteur, model of zanger worden met een echte roemmeter, elf jaar voor The Sims 4 het opnieuw met beroemdheid probeerde.';

  @override
  String get triviaSims1Catalogue =>
      'Terwijl hij na de brand opnieuw begon, bleef Will Wright zich afvragen welke delen van een huis onmisbaar waren en welke konden wachten. Die vraag is zo ongeveer de koopcatalogus.';

  @override
  String get triviaSims2Aging =>
      'The Sims 2 was het eerste spel in de serie waarin Sims ouder werden, van ouderdom stierven en genen doorgaven. Ogen, neuzen en kinnen komen van allebei de ouders.';

  @override
  String get triviaSims2Memories =>
      'Elke Sim draagt een verborgen lijst met herinneringen mee. Een sterfgeval zien, een eerste kus of een promotie wordt bijgehouden en kleurt latere stemmingen.';

  @override
  String get triviaSims2Bella =>
      'Bella Goth verdwijnt aan het begin van het spel uit Pleasantview, en die verdwijning is in twintig jaar nooit officieel verklaard.';

  @override
  String get triviaSims2Strangetown =>
      'Bella duikt springlevend op in Strangetown, zonder enige herinnering aan Pleasantview. Maxis heeft gezegd dat allebei de Bella\'s echt zijn en het daarbij gelaten.';

  @override
  String get triviaSims2FamilyTrees =>
      'De buurten van Sims 2 draaien op een echte stamboom: Pleasantview, Strangetown en Veronaville hangen aan elkaar van huwelijken en geruchten.';

  @override
  String get triviaSims2Plead =>
      'Je kan met Magere Hein onderhandelen. Spreek hem op het juiste moment aan en hij geeft je Sim misschien terug, af en toe in ruil voor iemand anders.';

  @override
  String get triviaSims2ReaperRomance =>
      'Je kan een relatie met Magere Hein krijgen. Speel het goed genoeg en er komt een spookbaby van.';

  @override
  String get triviaSims2Satellite =>
      'Een Sim die naar de sterren kijkt heeft een heel kleine kans om door een vallende satelliet geraakt te worden. Het is een van de zeldzaamste doden uit de serie.';

  @override
  String get triviaSims2Therapist =>
      'Wie zijn levenswens niet haalt, krijgt de therapeut over de vloer, een van de weinige momenten waarop het spel voor de grap door zijn eigen vierde wand breekt.';

  @override
  String get triviaSims2WantsFears =>
      'Wensen en angsten sturen het hele spel. De levenswensmeter reageert net zo hard op waar een Sim bang voor was als op waar hij op hoopte.';

  @override
  String get triviaSims2FaceSculpt =>
      'Het spel kwam met een volledig systeem om lichaamsvorm en gezicht te boetseren, en daarom zien Sims 2-gezichten er nog altijd gevarieerder uit dan die uit latere delen.';

  @override
  String get triviaSims2Aliens =>
      'Ontvoering door aliens overkomt alleen mannelijke Sims die te lang naar de sterren staren, en ja, ze komen zwanger terug.';

  @override
  String get triviaSims2FreezerBunny =>
      'Het Freezer Bunny werd getekend door kunstenaar Emmy Toyonaga voor The Sims 2 en zat de eerste keer verstopt in een diepvries op een openbaar terrein. Sindsdien is het in elk spel binnengesmokkeld.';

  @override
  String get triviaSims2SocialBunny =>
      'Het Social Bunny verving de Tragic Clown, en anders dan de clown werkt het echt. Genoeg spelers vonden die competente versie juist enger.';

  @override
  String get triviaSims2Giveaway =>
      'EA gaf de Ultimate Collection in juli 2014 gratis weg via Origin, in te wisselen met de code I-LOVE-THE-SIMS. Tot de Legacy Collection was die weggeefactie tien jaar lang de enige manier om eraan te komen.';

  @override
  String get triviaSims3SunsetValley =>
      'Sunset Valley is Pleasantview uit The Sims 2, ongeveer 25 jaar eerder, dus je ontmoet er de grootouders van Sims die je al gespeeld hebt.';

  @override
  String get triviaSims3Founders =>
      'Sunset Valley werd gesticht door de Goths en opgebouwd door de Landgraabs. Je kan Mortimer Goth als kind spelen en zien hoe hij Bella Bachelor ontmoet.';

  @override
  String get triviaSims3OpenWorld =>
      'The Sims 3 schrapte de laadschermen helemaal. De hele stad draait in één keer, met elke Sim die op de achtergrond ouder wordt en werkt.';

  @override
  String get triviaSims3Simulation =>
      'Elke Sim in de stad wordt tegelijk gesimuleerd, en daarom wordt een lange save trager. Het spel speelt stilletjes levens af die jij nooit ontmoet hebt.';

  @override
  String get triviaSims3CreateAStyle =>
      'Met Create-a-Style konden spelers bijna elk object hertinten en van een ander patroon voorzien, een functie die zo veeleisend was dat ze nooit is teruggekomen.';

  @override
  String get triviaSims3Exchange =>
      'The Sims 3 kwam met een echte online exchange waar spelers kavels, Sims en patronen rechtstreeks vanuit de launcher uitwisselden.';

  @override
  String get triviaSims3Downloads =>
      'Alleen al in de eerste week haalden spelers meer dan zeven miljoen zelfgemaakte items rechtstreeks uit die launcher.';

  @override
  String get triviaSims3Traits =>
      'Eigenschappen vervingen de oude persoonlijkheidsschuifjes, en een paar ervan, zoals Kleptomaan en Krankzinnig, breken stilletjes de regels van een gewoon leven.';

  @override
  String get triviaSims3Kleptomaniac =>
      'Een kleptomane Sim komt ongevraagd thuis met andermans meubels, en blijft dat doen tot jij het merkt.';

  @override
  String get triviaSims3Simlish =>
      'Katy Perry, Lily Allen, Depeche Mode en tientallen andere artiesten namen hun eigen nummers opnieuw op in het Simlish voor de soundtracks.';

  @override
  String get triviaSims3Townies =>
      'Omdat de open wereld ook Sims buiten beeld simuleerde, ontdekten spelers geregeld dat townies getrouwd waren en kinderen hadden gekregen zonder dat zij er iets aan gedaan hadden.';

  @override
  String get triviaSims3Store =>
      'De Sims 3 Store verkocht meer objecten dan er bij de release in het spel zelf zaten.';

  @override
  String get triviaSims3Launch =>
      'The Sims 3 verkocht in juni 2009 1,4 miljoen exemplaren in de eerste week, de grootste pc-lancering die EA ooit had gehad.';

  @override
  String get triviaSims4Flies =>
      'Doodgaan door vliegen bestaat echt. Laat een kavel smerig genoeg worden en een zwerm maakt een Sim af.';

  @override
  String get triviaSims4Emotions =>
      'Emoties sturen hier alles. Een geïnspireerde Sim schildert beter; een woedende kan doodgaan van kwaadheid.';

  @override
  String get triviaSims4EmotionDeaths =>
      'Een Sim kan doodgaan van het lachen, van woede en van schaamte. Emotie is hier geen versiering, het is een gevaar.';

  @override
  String get triviaSims4CreateASim =>
      'Create-a-Sim verving de schuifjes door rechtstreeks aan het gezicht te trekken en te duwen, en daarom zijn Sims 4-gezichten zo snel gemaakt.';

  @override
  String get triviaSims4Launch =>
      'The Sims 4 verscheen zonder zwembaden en zonder peuters. Allebei kwamen ze er na aanhoudende druk van spelers gratis bij in een patch.';

  @override
  String get triviaSims4Worlds =>
      'Willow Creek en Oasis Springs waren bij de release in september 2014 de enige twee werelden. Nu zijn er tientallen, en bijna allemaal kwamen ze met een pack mee.';

  @override
  String get triviaSims4Gender =>
      'Gender ging in een patch uit 2016 helemaal open: elke Sim kan alle kleding dragen, elke stem krijgen en wel of niet zwanger worden.';

  @override
  String get triviaSims4Newcrest =>
      'Newcrest kwam met opzet helemaal leeg. Vijftien kavels, geen gebouwen, en een open uitnodiging aan de community om het te vullen.';

  @override
  String get triviaSims4Naming =>
      'Buurtnamen als Willow Creek en Oasis Springs volgen een huisregel van vroeger bij Maxis: twee gewone Engelse woorden, geen verzonnen spelling.';

  @override
  String get triviaSims4Goths =>
      'De familie Goth komt ook hier voor, wat hen een van de langstlopende families in games maakt, aanwezig in elk hoofddeel.';

  @override
  String get triviaSims4FreeToPlay =>
      'Het basisspel werd in oktober 2022 gratis, op pc, PlayStation en Xbox tegelijk. De packs bleven betalend.';

  @override
  String get triviaSims4Mccc =>
      'MC Command Center, de eerste mod die de meeste Sims 4-spelers installeren, is alleen al op CurseForge meer dan 14 miljoen keer gedownload. Deaderpool werkt hem sinds 2015 bij.';

  @override
  String get triviaSims4Twallan =>
      'MCCC bestaat dankzij The Sims 3. Hij pikt op waar Twallans Master Controller en Story Progression ophielden, en draagt een tien jaar oud idee over naar een nieuwe engine.';

  @override
  String get triviaSims4Deaths =>
      'Sims kunnen omkomen door een koeplant, een snoepautomaat, een stereo in de vorm van een lama en door het lachen. Niet allemaal tegelijk.';

  @override
  String get triviaMedievalWatcher =>
      'Je bent hier geen huishouden, je bent de Watcher: een goedaardige godheid die helden door een koninkrijk stuurt in plaats van de dag van één familie te regelen.';

  @override
  String get triviaMedievalHeroes =>
      'Een koninkrijk telt tot tien heldensims verdeeld over tien beroepen, en elk van hen gaat van niveau 1 naar 10 met nieuwe vaardigheden en steeds grootsere titels onderweg.';

  @override
  String get triviaMedievalStocks =>
      'Elke held wordt wakker met twee verantwoordelijkheden en een deadline. Sla je die te vaak over, dan word je gestraft, en dat geldt ook voor de vorst, die in het schandblok kan belanden.';

  @override
  String get triviaMedievalAmbition =>
      'Je kiest voor het hele koninkrijk een Ambitie voor je begint, en de quests die je aanneemt worden daaraan afgemeten. Het is het dichtste dat The Sims ooit bij een winvoorwaarde is gekomen.';

  @override
  String get triviaMedievalQuests =>
      'Dit is een totale omvorming en geen spin-off. De zandbak is vervangen door een reeks quests, en daarom is het de enige Sims-game die je echt kan uitspelen.';

  @override
  String get triviaMedievalPirates =>
      'Pirates and Nobles, uit augustus 2011, was de enige add-on die het ooit kreeg: valken en papegaaien, schatkaarten en schoppen, en een oorlog tussen twee nieuwe facties.';

  @override
  String get triviaMedievalProxy =>
      'Het spel is nooit gebouwd om mods te laden. Script- en coremods hebben de d3dx9_31.dll-proxy van de community in Game/Bin nodig voor het spel ze überhaupt leest, al werkt custom content ook zonder.';

  @override
  String get triviaMedievalEngine =>
      'Het draait op de engine van The Sims 3, en daarom komen de Resource.cfg en de .package-bestanden zo bekend voor als je dat spel ooit gemod hebt.';

  @override
  String get navCreations => 'Creaties';

  @override
  String creationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count creaties',
      one: '1 creatie',
      zero: 'Nog niets opgeslagen',
    );
    return '$_temp0';
  }

  @override
  String get creationsScanning => 'Je kavels en huishoudens worden gelezen…';

  @override
  String get creationsRefresh => 'Vernieuwen';

  @override
  String get creationsAll => 'Alles';

  @override
  String get creationsBack => '← Terug naar alles';

  @override
  String get creationsNoneOfKind => 'Niets van dat soort hier.';

  @override
  String get creationsEmptyTitle => 'Hier staat nog niets';

  @override
  String get creationsEmptyBody =>
      'Kavels, kamers, huishoudens en sims die je in het spel opslaat komen hier terecht — net als alles wat je downloadt en op het venster sleept.';

  @override
  String creationsBy(String creator) {
    return 'van $creator';
  }

  @override
  String get creationsWhoLivesHere => 'WIE ER MEEKOMT';

  @override
  String get creationsShowInFolder => 'In map tonen';

  @override
  String get creationsDelete => 'Verwijderen';

  @override
  String creationsDeleteTitle(String name) {
    return '“$name” verwijderen?';
  }

  @override
  String get creationsDeleteBody =>
      'Het verdwijnt definitief uit de map van het spel. Ongedaan maken kan niet.';

  @override
  String creationsFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bestanden',
      one: '1 bestand',
    );
    return '$_temp0';
  }

  @override
  String get creationKindLot => 'Kavel';

  @override
  String get creationKindRoom => 'Kamer';

  @override
  String get creationKindHousehold => 'Huishouden';

  @override
  String get creationKindSim => 'Sim';

  @override
  String get creationFolderSims4Tray => 'Tray';

  @override
  String get creationFolderSims3Library => 'Library';

  @override
  String get creationFolderSims2LotCatalog => 'Kavel- en huizenverzameling';

  @override
  String get creationFolderSims2SavedSims => 'Ingepakte sims';

  @override
  String creationFolderSims1Houses(String number) {
    return 'Buurt $number';
  }

  @override
  String creationBadFileName(String name) {
    return '“$name” bevat tekens die dit systeem niet toestaat in een bestandsnaam, dus het spel zou het nooit vinden. Geef het een andere naam en probeer het opnieuw.';
  }

  @override
  String creationFileInUse(String name) {
    return '“$name” is in gebruik. Sluit het spel en probeer het opnieuw.';
  }

  @override
  String get creationSims1PickLot =>
      'De Sims 1 nummert kavels op hun plek op de kaart, dus een huis moet een kavel overnemen die er al is - en wat erop staat verdwijnt. Kies de kavel zelf: maak er een back-up van en hernoem de download daarna naar het House-nummer van die kavel in de map Houses.';

  @override
  String creationInstallFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Die $count bestanden konden niet worden toegevoegd.',
      one: 'Dat bestand kon niet worden toegevoegd.',
    );
    return '$_temp0';
  }

  @override
  String creationRemoveFailed(String name) {
    return '“$name” kon niet worden verwijderd.';
  }

  @override
  String get creationsAdd => 'Toevoegen';

  @override
  String get creationsAdding => 'Bezig met toevoegen…';

  @override
  String creationsPickerLabel(String game) {
    return 'Kavels, kamers, huishoudens en sims voor $game';
  }

  @override
  String get creationsNothingToAdd =>
      'Er zat niets tussen dat dit spel als kavel, kamer, huishouden of sim kan lezen. Custom content en mods gaan via de bibliotheek.';

  @override
  String get householdEdit => 'Bewerken';

  @override
  String get householdEditTitle => 'Huishouden bewerken';

  @override
  String householdEditBody(String name) {
    return 'Verander wat de save over “$name” zegt.';
  }

  @override
  String get householdEditName => 'Naam';

  @override
  String get householdEditFunds => 'Geld';

  @override
  String householdEditFundsMax(String max) {
    return 'Tot $max, meer kan dit spel niet aan.';
  }

  @override
  String get householdEditSave => 'Opslaan';

  @override
  String get householdEditNotice =>
      'Sluit eerst het spel: bij het afsluiten schrijft het zijn eigen save terug. Er wordt een kopie van het bestand bewaard voordat er iets verandert.';

  @override
  String get errorSaveEditHouseholdGone =>
      'Dat huishouden zit niet meer in de save. Ververs de lijst en probeer het opnieuw.';

  @override
  String errorSaveEditUnreadable(String file) {
    return '“$file” is niet opgebouwd zoals de app kan herschrijven, dus er is niets veranderd.';
  }

  @override
  String errorSaveEditVerification(String file) {
    return 'De herschreven “$file” las niet terug zoals het hoorde, dus is hij weggegooid. Je save is onaangeroerd.';
  }

  @override
  String get errorSaveEditUnsupported =>
      'De saves van dit spel kun je lezen, maar niet veranderen.';

  @override
  String whatsNewEyebrow(String version) {
    return 'Nieuw in $version';
  }

  @override
  String get whatsNewAlsoSince => 'Ook in deze update';

  @override
  String get whatsNewDismiss => 'Aan de slag';

  @override
  String get whatsNew300RootTitle => 'Mods die in de mappen van het spel horen';

  @override
  String get whatsNew300RootBody =>
      'Werelden, grafische tweaks en scriptloaders werkten nooit vanuit de Mods-map. Nu belanden ze meteen in de mappen die het spel uitleest, en wat ze vervangen wordt bewaard, dus bij verwijderen krijg je het origineel terug.';

  @override
  String get whatsNew300PacksTitle =>
      'Aanbiedingen kunnen zeggen welke packs ze nodig hebben';

  @override
  String get whatsNew300PacksBody =>
      'Makers kunnen een mod koppelen aan de packs waarvoor die gemaakt is, en The Exchange vergelijkt ze met die van jou voordat je installeert. Het is altijd een waarschuwing, nooit een dichte deur.';

  @override
  String get whatsNew300ContainersTitle =>
      'Een zip vol .sims3pack-bestanden werkt gewoon';

  @override
  String get whatsNew300ContainersBody =>
      'Sleep de hele set op het venster. De Sims 3-containers in een archief worden geopend waar ze staan, en alles wordt in één keer geïnstalleerd.';

  @override
  String get whatsNew300SimCityTitle => 'SimCity 3000, 4, Societies en 2013';

  @override
  String get whatsNew300SimCityBody =>
      'Vier games erbij in de zijbalk. SimCity 4 leest allebei zijn Plugins-mappen, houdt de laadvolgorde aan die map- en bestandsnamen aangeven en blijft af van alles wat sc4pac heeft geïnstalleerd. In de instellingen verberg je de games die je niet speelt.';

  @override
  String get whatsNew300CatalogTitle =>
      'Duizenden SimCity 4-mods om door te bladeren';

  @override
  String get whatsNew300CatalogBody =>
      'The Exchange laat nu ook de sc4pac-kanalen zien naast onze eigen listings, met credits voor het project dat ze bijhoudt. Een download komt met alles wat hij nodig heeft of helemaal niet, en waar een host geen app voor je laat downloaden, zegt de knop dat meteen.';

  @override
  String get whatsNew300ThemeTitle => 'Kies de look die je leuk vindt';

  @override
  String get whatsNew300ThemeBody =>
      'Vroeger nam de app de kleuren over van de game die openstond. Nu kies je in de instellingen de look die je wilt, en die blijft staan welke game je ook beheert.';

  @override
  String get categoryLot => 'Kavel';

  @override
  String get categoryModel => 'Model';

  @override
  String get categoryDescription => 'Beschrijving';

  @override
  String get categoryBuilding => 'Gebouw';

  @override
  String get setupHelpSimCity4 =>
      'SimCity 4 leest plugins uit twee mappen tegelijk: Documenten > SimCity 4 > Plugins (die van jou, en degene die deze app beheert) en een Plugins-map in de installatie van het spel. Map- en bestandsnamen zijn de laadvolgorde, dus laat de structuur waarmee een download binnenkomt met rust - daarom gebruikt sc4pac genummerde mappen en heten overrides „zzz...”. DLL-plugins laden alleen vanuit de bovenste laag van een Plugins-map, nooit uit een submap, dus de app zet ze daar voor je neer. Wat sc4pac heeft geïnstalleerd blijft van sc4pac: dat lijst sc4pac, niet deze app.';

  @override
  String get setupHelpSimCity2013 =>
      'SimCity laadt mods als .package uit SimCityUserData > Packages in de installatie van het spel (meestal onder Program Files, dus Windows kan om beheerdersrechten vragen). Deze app beheert alleen die map. Het spel leest ook zijn eigen SimCityData-map, maar daar staat de content van Maxis: een mod die vóór de pakketten van het spel moet laden, moet daar met de hand heen. Veel mods zijn alleen voor offline: probeer ze op een stad die je kwijt mag raken.';

  @override
  String get setupHelpSimCity3000 =>
      'SimCity 3000 laadt eigen gebouwen (.bld-bestanden uit de Building Architect Tool) uit een Buildings-map in de installatie van het spel. Die map is plat: een gebouw in een submap wordt nooit geladen. De gebouwen die met het spel meekwamen zijn hier verborgen, zodat je ze niet per ongeluk weggooit. Resolutie- en compatibiliteitsfixes die SC3U.exe zelf aanpassen installeert deze app niet; volg daarvoor hun eigen instructies.';

  @override
  String get setupHelpSimCitySocieties =>
      'SimCity Societies bewaart eigen content in Documenten > SimCity Societies > Import, waar de Package Installer van het spel het ook neerzet. Deze app kan de map voor je maken. Content komt als .SCSPack-bestanden - dat is de extensie waar het spel zelf naar zoekt. Let op: Societies is gemaakt om bewerkt te worden, niet om kant-en-klare mods te laden - het meeste wat de scene deed was de C# en XML in de Data-map van het spel aanpassen, en daar blijft deze app vanaf.';

  @override
  String get sectionManagedGames => 'Games';

  @override
  String prefManageGameTitle(String game) {
    return '$game beheren';
  }

  @override
  String get prefManageGameDesc =>
      'Toon het in de zijbalk. Een verborgen game houdt al zijn instellingen.';

  @override
  String get errorLastManagedGame =>
      'Dat is het laatste spel in je zijbalk, dus het moet blijven staan. Zet eerst een ander spel aan als je dit wilt verbergen.';

  @override
  String catalogCount(int count) {
    return '$count mods';
  }

  @override
  String catalogCuratedBy(String project) {
    return 'Catalogus van $project';
  }

  @override
  String get catalogOpenPage => 'Pagina openen';

  @override
  String catalogBlocked(String host) {
    return '$host laat apps niet voor je downloaden. Haal hem op via de pagina van de mod.';
  }

  @override
  String get catalogUnresolvedNote =>
      'Deze kon niet uit de catalogus gelezen worden.';

  @override
  String get catalogDependencies => 'Komt met';

  @override
  String catalogFileCount(int count) {
    return '$count bestanden';
  }

  @override
  String catalogDownloading(int current, int total) {
    return 'Downloadt $current van $total';
  }

  @override
  String get catalogWarningTitle => 'Let op';

  @override
  String get catalogConflictsTitle => 'Botst met';

  @override
  String catalogSourceFailed(String source) {
    return '$source niet bereikbaar';
  }

  @override
  String get catalogEmpty => 'Niets komt overeen.';

  @override
  String get catalogRefresh => 'Catalogus opnieuw laden';

  @override
  String get catalogOptions => 'Opties';

  @override
  String catalogBy(String author) {
    return 'van $author';
  }

  @override
  String get errorCatalogUnreachable =>
      'De catalogus was niet bereikbaar. Check je verbinding en probeer het nog eens.';

  @override
  String get errorCatalogUnreadable =>
      'De catalogus antwoordde met iets dat deze versie niet kan lezen.';

  @override
  String errorCatalogDownloadFailed(String host) {
    return '$host weigerde de download.';
  }

  @override
  String get errorCatalogInstallFailed =>
      'Er ging iets mis bij het installeren.';

  @override
  String get errorCatalogInstallCancelled => 'Installatie geannuleerd.';

  @override
  String get catalogLoading => 'Catalogus laden…';

  @override
  String get catalogBack => '← Terug naar de catalogus';

  @override
  String get catalogPromoTitle => 'Zelf een mod gemaakt?';

  @override
  String get catalogPromoBody =>
      'Zet hem op The Exchange: één klik installeert hem, hij krijgt een eigen pagina en link, en wie hem al heeft hoort het als er een update is.';
}
