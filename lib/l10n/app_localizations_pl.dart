// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class LPl extends L {
  LPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'Sims Mod Manager';

  @override
  String get brandTitle => 'Mod Manager';

  @override
  String get brandSubtitle => 'do The Sims';

  @override
  String get navLibrary => 'Biblioteka';

  @override
  String get navShop => 'The Exchange';

  @override
  String get navSettings => 'Ustawienia';

  @override
  String get shopAlphaBadge => 'ALFA';

  @override
  String get shopTagline =>
      'Mody od społeczności, instalowane jednym kliknięciem.';

  @override
  String shopListingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count moda na półkach',
      many: '$count modów na półkach',
      few: '$count mody na półkach',
      one: '1 mod na półkach',
    );
    return '$_temp0';
  }

  @override
  String get shopRefresh => 'Odśwież';

  @override
  String get shopPublish => 'Opublikuj swoje mody';

  @override
  String get shopLoadFailedTitle => 'The Exchange nie odpowiada';

  @override
  String get shopLoadFailedBody =>
      'Nie udało się załadować półek. Sprawdź połączenie i spróbuj jeszcze raz.';

  @override
  String get shopRetry => 'Spróbuj jeszcze raz';

  @override
  String get shopEmptyTitle => 'Półki wciąż są puste';

  @override
  String get shopEmptyBody =>
      'The Exchange dopiero co otworzył podwoje i nikt jeszcze niczego nie opublikował. Aż tak tu świeżo. Robisz mody? Zajmij półkę jako pierwsza osoba!';

  @override
  String get shopAllGames => 'Wszystkie gry';

  @override
  String get shopShowAllGames => 'Pokaż wszystkie gry';

  @override
  String shopEmptyGameTitle(String game) {
    return 'Jeszcze nic do $game';
  }

  @override
  String shopEmptyGameBody(String game) {
    return 'Na półkach są już mody do innych gier, ale do $game nikt jeszcze niczego nie opublikował. Masz takiego moda? Zajmij tę półkę jako pierwsza osoba!';
  }

  @override
  String shopBy(String author) {
    return 'od $author';
  }

  @override
  String get shopInstalled => 'Zainstalowano';

  @override
  String get shopUpdate => 'Aktualizuj';

  @override
  String get shopUpdateBadge => 'aktualizacja';

  @override
  String shopUpdatesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count z twoich modów ma nowe wersje na The Exchange',
      many: '$count z twoich modów ma nowe wersje na The Exchange',
      few: '$count z twoich modów mają nowe wersje na The Exchange',
      one: '1 z twoich modów ma nową wersję na The Exchange',
    );
    return '$_temp0';
  }

  @override
  String get shopUpdateHeading => 'Jest nowa wersja tego moda';

  @override
  String shopUpdateBody(String version, String author) {
    return '$author opublikował(a) v$version na The Exchange. Aktualizacja zastąpi pliki, które masz teraz.';
  }

  @override
  String get shopUpdateSeeListing => 'Zobacz wpis';

  @override
  String get shopInstalling => 'Instalowanie…';

  @override
  String get shopInstallNotes => 'Wskazówki instalacji';

  @override
  String get shopCreatorNudge =>
      'Robisz mody? Publikowanie na The Exchange jest darmowe, a gracze instalują twoje prace jednym kliknięciem.';

  @override
  String shopNeedsFolder(String game) {
    return 'Najpierw ustaw folder modów dla $game. Zakładka Biblioteka przeprowadzi cię przez to.';
  }

  @override
  String shopVariations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wariantu',
      many: '$count wariantów',
      few: '$count warianty',
      one: '1 wariant',
    );
    return '$_temp0';
  }

  @override
  String get shopSaveFile => 'Pobierz';

  @override
  String get shopSaving => 'Pobieranie…';

  @override
  String get shopSaved => 'Zapisano';

  @override
  String get shopSaveHint =>
      'Instalacja wrzuca pliki prosto do twojego folderu z modami. Pobieranie po prostu zapisze plik tam, gdzie chcesz.';

  @override
  String get shopDestination => 'Instaluje do';

  @override
  String get shopVariationPick => 'Wybierz wariant';

  @override
  String get shopBack => 'Wróć do półek';

  @override
  String get shopCopyLink => 'Kopiuj link';

  @override
  String get shopLinkCopied => 'Skopiowano link';

  @override
  String get sidebarGames => 'GRY';

  @override
  String sidebarNotInstalled(String detail) {
    return 'nie zainstalowana · $detail';
  }

  @override
  String sidebarModCount(int count, String detail) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count moda',
      many: '$count modów',
      few: '$count mody',
      one: '$count mod',
    );
    return '$_temp0 · $detail';
  }

  @override
  String get updateAvailable => 'Jest aktualizacja';

  @override
  String updateClickToDownload(String version) {
    return 'v$version: kliknij, żeby pobrać';
  }

  @override
  String get storage => 'Miejsce na dysku';

  @override
  String storageInMods(String size) {
    return '$size w modach';
  }

  @override
  String storageFreeOf(String free, String total) {
    return '$free wolnego z $total';
  }

  @override
  String dropToInstall(String game) {
    return 'Upuść tutaj, żeby zainstalować w $game';
  }

  @override
  String get dropFolders => 'foldery';

  @override
  String scanningMods(int done, int total) {
    return 'Zaglądamy do modów w poszukiwaniu grafik i konfliktów… $done z $total';
  }

  @override
  String get skip => 'Pomiń';

  @override
  String libraryTitle(String game) {
    return 'Biblioteka $game';
  }

  @override
  String modsShown(int count, String era) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'widocznych $count moda',
      many: 'widocznych $count modów',
      few: 'widoczne $count mody',
      one: 'widoczny $count mod',
    );
    return '$_temp0 · $era';
  }

  @override
  String get learnMore => 'Dowiedz się więcej';

  @override
  String get dismiss => 'Ukryj';

  @override
  String get searchMods => 'Szukaj modów…';

  @override
  String get viewGrid => 'Siatka';

  @override
  String get viewList => 'Lista';

  @override
  String get viewFolders => 'Foldery';

  @override
  String get sortTooltip => 'Sortuj';

  @override
  String get sortByName => 'Nazwa (A–Z)';

  @override
  String get sortByRecent => 'Ostatnio zmienione';

  @override
  String get sortBySize => 'Najpierw największe';

  @override
  String get sortDisabledLast => 'Wyłączone na końcu';

  @override
  String get libraryRefresh => 'Odśwież';

  @override
  String get libraryRootFolder => 'Folder Mods';

  @override
  String get selectionTooltip => 'Zaznacz';

  @override
  String selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'zaznaczono $count',
      many: 'zaznaczono $count',
      few: 'zaznaczono $count',
      one: 'zaznaczono $count',
    );
    return '$_temp0';
  }

  @override
  String get selectionSelectAll => 'Zaznacz wszystko';

  @override
  String get selectionClear => 'Wyczyść zaznaczenie';

  @override
  String get selectionEnable => 'Włącz';

  @override
  String get selectionDisable => 'Wyłącz';

  @override
  String selectionProgress(int done, int total) {
    return '$done z $total';
  }

  @override
  String selectionDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Odinstalować $count moda?',
      many: 'Odinstalować $count modów?',
      few: 'Odinstalować $count mody?',
      one: 'Odinstalować $count mod?',
    );
    return '$_temp0';
  }

  @override
  String selectionDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Wszystkie $count pliku zostanie usuniętych z dysku. Nie da się tego cofnąć.',
      many:
          'Wszystkie $count plików zostanie usuniętych z dysku. Nie da się tego cofnąć.',
      few:
          'Wszystkie $count pliki zostaną usunięte z dysku. Nie da się tego cofnąć.',
      one: 'Plik zostanie usunięty z dysku. Nie da się tego cofnąć.',
    );
    return '$_temp0';
  }

  @override
  String get selectionMove => 'Przenieś do…';

  @override
  String get newFolder => 'Nowy folder';

  @override
  String newFolderIn(String folder) {
    return 'W folderze $folder';
  }

  @override
  String get newFolderHint => 'Nazwa folderu';

  @override
  String get create => 'Utwórz';

  @override
  String get move => 'Przenieś';

  @override
  String moveTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gdzie przenieść $count moda?',
      many: 'Gdzie przenieść $count modów?',
      few: 'Gdzie przenieść $count mody?',
      one: 'Gdzie przenieść $count mod?',
    );
    return '$_temp0';
  }

  @override
  String get moveBody =>
      'Pliki przeniosą się do innego folderu na dysku. Nic poza tym się nie zmienia - co wyłączone, zostaje wyłączone.';

  @override
  String get installFolderTitle => 'Który folder?';

  @override
  String installFolderBody(String game) {
    return 'Gdzie wylądują pliki w twoim folderze modów do $game.';
  }

  @override
  String get installFolderChoose => 'Wybierz';

  @override
  String get installFolderEmpty =>
      'Nie ma jeszcze podfolderów. Stwórz jakiś albo zostaw wszystko w folderze modów.';

  @override
  String get folderEmptySection => 'Nic tu jeszcze nie ma';

  @override
  String get install => 'Zainstaluj';

  @override
  String filePickerModsLabel(String game) {
    return 'Mody do $game';
  }

  @override
  String get installWhereTitle => 'Gdzie to ma trafić?';

  @override
  String installWhereBody(String game) {
    return '$game czyta mody z kilku folderów. Apka może to wywnioskować z samego pliku, albo ty powiesz gdzie.';
  }

  @override
  String get installWhereSorted => 'Zdecyduj za mnie';

  @override
  String get installWhereSortedDesc =>
      'Najpierw foldery, które są w pobranym pliku, resztę rozłóż po typie pliku.';

  @override
  String get installWhereRemember => 'Nie pytaj więcej';

  @override
  String get destinationSims1Downloads =>
      'Obiekty, hacki i większość pobranych rzeczy.';

  @override
  String get destinationSims1Global => 'Zmiany działające w całej podstawce.';

  @override
  String get destinationSims1Objects => 'Zmiany w plikach obiektów samej gry.';

  @override
  String get destinationSims1Skins =>
      'Codzienne skiny i głowy. Pokazują się w Tworzeniu Simów.';

  @override
  String get destinationSims1SkinsBuy =>
      'Ubrania sprzedawane w sklepach na działkach społecznych.';

  @override
  String get destinationSims1Walls => 'Tapety i okładziny ścian.';

  @override
  String get destinationSims1Floors => 'Podłogi.';

  @override
  String get destinationSims1Roofs => 'Tekstury dachów.';

  @override
  String get prefAskWhereTitle => 'Pytaj, gdzie instalować';

  @override
  String get prefAskWhereDesc =>
      'Ta gra czyta mody z więcej niż jednego folderu. Wybieraj folder za każdym razem, zamiast zdawać się na apkę';

  @override
  String get statTotal => 'Razem';

  @override
  String get statEnabled => 'Włączone';

  @override
  String get statDisabled => 'Wyłączone';

  @override
  String get statConflicts => 'Konflikty';

  @override
  String get statTotalTooltip =>
      'Wszystkie mody w tym folderze, włączone i wyłączone.';

  @override
  String get statTotalTooltipClear =>
      'Wszystkie mody w tym folderze. Kliknij, żeby zrzucić wyszukiwanie i filtry.';

  @override
  String get statEnabledTooltip => 'Mody, które gra wczytuje.';

  @override
  String get statEnabledTooltipActive =>
      'Widzisz tylko włączone mody. Kliknij, żeby znów pokazać wszystkie.';

  @override
  String get statDisabledTooltip =>
      'Mody, które leżą w folderze, ale są wyłączone.';

  @override
  String get statDisabledTooltipActive =>
      'Widzisz tylko wyłączone mody. Kliknij, żeby znów pokazać wszystkie.';

  @override
  String get conflictTooltipActive =>
      'Widzisz tylko mody z konfliktami. Kliknij, żeby znów pokazać wszystkie.';

  @override
  String get conflictTooltip =>
      'Włączone mody, które mają tę samą nazwę pliku co inny włączony mod, są zainstalowane w kilku wersjach albo nadpisują te same zasoby gry. Gra zostawia tylko tę kopię, którą wczyta na końcu, czasem to celowe (mody-łatki), ale często nie.';

  @override
  String get conflictTooltipClickHint =>
      'Kliknij, żeby zobaczyć tylko te mody.';

  @override
  String get filterAll => 'Wszystkie';

  @override
  String get emptyFiltered => 'Żaden mod nie pasuje do filtrów';

  @override
  String get emptyNoMods => 'Jeszcze nie ma modów';

  @override
  String get emptyFilteredHint =>
      'Spróbuj wyczyścić wyszukiwanie albo wybrać inny filtr.';

  @override
  String emptyNoModsHint(String path) {
    return 'Obserwujemy ten folder:\n$path';
  }

  @override
  String get openFolder => 'Otwórz folder';

  @override
  String get conflictBadge => 'konflikt';

  @override
  String modInFolder(String folder) {
    return 'w $folder';
  }

  @override
  String get modInModsFolder => 'w folderze Mods';

  @override
  String setupFoundNoModsFolder(String game) {
    return '$game jest, ale nie ma jeszcze folderu na mody';
  }

  @override
  String setupNotFound(String game) {
    return 'Nie znaleziono folderu modów gry $game';
  }

  @override
  String get setupFoundNoModsFolderBody =>
      'Folder gry jest na tym komputerze, tylko nie ma w nim jeszcze folderu na mody. Utwórz go poniżej albo wskaż jakiś ręcznie.';

  @override
  String get setupNotFoundBody =>
      'Gra może nie być zainstalowana, może leżeć w nietypowym miejscu albo jej folder na mody jeszcze nie istnieje.';

  @override
  String get foundOnThisComputer => 'ZNALEZIONE NA TYM KOMPUTERZE';

  @override
  String get chooseFolder => 'Wybierz folder…';

  @override
  String get createItForMe => 'Utwórz za mnie';

  @override
  String willBeCreatedAt(String path) {
    return 'Powstanie tutaj:\n$path';
  }

  @override
  String get checkAgain => 'Sprawdź jeszcze raz';

  @override
  String get useThis => 'Użyj tego';

  @override
  String get enabled => 'Włączony';

  @override
  String get disabled => 'Wyłączony';

  @override
  String get showInFileManager => 'Pokaż w eksploratorze';

  @override
  String get uninstallMod => 'Odinstaluj moda';

  @override
  String uninstallConfirmTitle(String title) {
    return 'Odinstalować $title?';
  }

  @override
  String uninstallConfirmBody(String path) {
    return 'Plik zostanie usunięty z dysku:\n$path';
  }

  @override
  String get cancel => 'Anuluj';

  @override
  String get uninstall => 'Odinstaluj';

  @override
  String conflictSameNameHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count innych włączonych modów ma tę samą nazwę pliku:',
      many: '$count innych włączonych modów ma tę samą nazwę pliku:',
      few: '$count inne włączone mody mają tę samą nazwę pliku:',
      one: 'Inny włączony mod ma tę samą nazwę pliku:',
    );
    return '$_temp0';
  }

  @override
  String conflictVersionHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count innych włączonych modów wygląda na inne wersje tego samego moda:',
      many:
          '$count innych włączonych modów wygląda na inne wersje tego samego moda:',
      few:
          '$count inne włączone mody wyglądają na inne wersje tego samego moda:',
      one: 'Inny włączony mod wygląda na inną wersję tego samego moda:',
    );
    return '$_temp0';
  }

  @override
  String conflictResourcesHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count innych włączonych modów nadpisuje te same zasoby gry:',
      many: '$count innych włączonych modów nadpisuje te same zasoby gry:',
      few: '$count inne włączone mody nadpisują te same zasoby gry:',
      one: 'Inny włączony mod nadpisuje te same zasoby gry:',
    );
    return '$_temp0';
  }

  @override
  String sharedResources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wspólnych zasobów',
      many: '$count wspólnych zasobów',
      few: '$count wspólne zasoby',
      one: '$count wspólny zasób',
    );
    return '$_temp0';
  }

  @override
  String get conflictSameNameBody =>
      'Identyczne nazwy zwykle znaczą, że ten sam mod jest zainstalowany dwa razy albo że gryzą się paczki dwóch twórców. Gra wczytuje ich nakładające się zasoby w nieprzewidywalnej kolejności: zostaw jednego, resztę wyłącz albo usuń.';

  @override
  String get conflictVersionBody =>
      'Kilka wersji tego samego moda naraz sprawia, że gra wczytuje ich nakładające się zasoby w nieprzewidywalnej kolejności: zostaw najnowszą, resztę wyłącz albo usuń.';

  @override
  String get conflictResourcesBody =>
      'Te paczki zawierają zasoby o tych samych identyfikatorach, więc gra zostawi tylko tę kopię, którą wczyta na końcu. Czasem tak ma być (mody-łatki i override celowo przykrywają zasoby innego moda), ale przy modach, które nie mają ze sobą nic wspólnego, oznacza to, że jeden po cichu przestaje działać: zostaw ten, na którym ci zależy, a resztę wyłącz.';

  @override
  String get conflictIgnore => 'Zignoruj';

  @override
  String get conflictIgnoreTooltip =>
      'Jeśli ten konflikt jest celowy, schowaj go. Przy modzie nic się nie zmienia, a ostrzeżenie przywrócisz na tej stronie albo w ustawieniach.';

  @override
  String get conflictRestore => 'Przywróć';

  @override
  String advisoryBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count twoich modów ma znane problemy',
      many: '$count twoich modów ma znane problemy',
      few: '$count twoje mody mają znane problemy',
      one: 'Jeden z twoich modów ma znany problem',
    );
    return '$_temp0';
  }

  @override
  String get advisoryShow => 'Zobacz';

  @override
  String get advisoryShowAll => 'Pokaż wszystkie mody';

  @override
  String get advisoryBadge => 'problem';

  @override
  String get advisoryBrokenHeading => 'Ten mod jest zgłaszany jako zepsuty';

  @override
  String get advisoryBrokenBody =>
      'Inni gracze zgłaszają, że przez ten mod gra przestaje działać. Wyłączenie go to najszybszy sposób, żeby sprawdzić, czy to on.';

  @override
  String get advisoryOutdatedHeading => 'Jest nowsza wersja tego moda';

  @override
  String get advisoryOutdatedBody =>
      'Masz dokładnie tę wersję, na którą ludzie narzekają. Pobranie najnowszej od twórcy powinno załatwić sprawę.';

  @override
  String get advisoryCautionHeading => 'Warto mieć go na oku';

  @override
  String get advisoryCautionBody =>
      'U większości działa, ale wiadomo, że potrafi narozrabiać. Warto go wyłączyć, jeśli szukasz źródła problemu.';

  @override
  String advisorySince(String since) {
    return 'Od $since';
  }

  @override
  String get advisoryOpenLink => 'Otwórz stronę twórcy';

  @override
  String get advisorySource => 'Zgłoszone przez innych graczy, nie przez grę.';

  @override
  String modInDirectory(String dir) {
    return 'w $dir';
  }

  @override
  String get factVersion => 'Wersja';

  @override
  String get factFormat => 'Format';

  @override
  String get factSize => 'Rozmiar';

  @override
  String get factType => 'Typ';

  @override
  String get factModified => 'Zmieniono';

  @override
  String get factDownloads => 'Pobrania';

  @override
  String get factIgnoredConflicts => 'Zignorowane';

  @override
  String ignoredConflictsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count konfliktu',
      many: '$count konfliktów',
      few: '$count konflikty',
      one: '$count konflikt',
    );
    return '$_temp0';
  }

  @override
  String get statusHeading => 'Status';

  @override
  String get statusEnabledBody =>
      'Ten mod jest włączony: gra wczyta go przy następnym uruchomieniu.';

  @override
  String statusDisabledBody(String marker) {
    return 'Ten mod jest wyłączony: plik zostaje na dysku z dopiskiem „$marker”, żeby gra go pominęła. Możesz włączyć go, kiedy chcesz. Nic nie znika.';
  }

  @override
  String get fileOnDisk => 'Plik na dysku';

  @override
  String get insideThePackage => 'W środku paczki';

  @override
  String resourcesTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zasobów łącznie',
      many: '$count zasobów łącznie',
      few: '$count zasoby łącznie',
      one: '$count zasób łącznie',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get sectionModManagement => 'ZARZĄDZANIE MODAMI';

  @override
  String get sectionAppearance => 'WYGLĄD';

  @override
  String get sectionLanguage => 'JĘZYK';

  @override
  String get sectionPrivacy => 'PRYWATNOŚĆ';

  @override
  String sectionModsFolder(String game) {
    return 'FOLDER MODÓW · $game';
  }

  @override
  String sectionGameCaches(String game) {
    return 'PAMIĘĆ PODRĘCZNA GRY · $game';
  }

  @override
  String sectionIgnoredConflicts(String game) {
    return 'ZIGNOROWANE KONFLIKTY · $game';
  }

  @override
  String sectionShopFolder(String game) {
    return 'THE EXCHANGE · $game';
  }

  @override
  String get prefShopFolderTitle => 'Gdzie trafiają mody z The Exchange';

  @override
  String prefShopFolderDesc(String folder) {
    return 'Instalacje trafiają do $folder';
  }

  @override
  String get sectionFeedback => 'OPINIE';

  @override
  String get sectionAbout => 'O APLIKACJI';

  @override
  String get prefWarnConflictsTitle => 'Ostrzegaj o konfliktach';

  @override
  String get prefWarnConflictsDesc =>
      'Oznacza włączone mody, które powielają nazwę pliku albo nadpisują te same zasoby gry co inny mod';

  @override
  String get prefConfirmDeleteTitle => 'Pytaj przed odinstalowaniem';

  @override
  String get prefConfirmDeleteDesc => 'Pytaj, zanim plik moda zniknie z dysku';

  @override
  String get prefShowDisabledTitle => 'Pokazuj wyłączone mody';

  @override
  String get prefShowDisabledDesc =>
      'Zostawia wyłączone mody widoczne w bibliotece, zamiast je chować';

  @override
  String get prefDisabledSuffixTitle => 'Znacznik wyłączonych modów';

  @override
  String get prefDisabledSuffixDesc =>
      'To, co dopisuje się do nazwy pliku, gdy wyłączasz moda. Zmień, żeby pasowało do innego menedżera (CC Magic używa .off); aplikacja i tak czyta oba, a już wyłączone mody zachowują swoje nazwy';

  @override
  String get prefDisabledSuffixInvalid =>
      'Musi być kropka i kilka liter albo cyfr, na przykład .off';

  @override
  String get prefExperimentalPacksTitle =>
      'Eksperymentalne przełączniki pakietów';

  @override
  String get prefExperimentalPacksDesc =>
      'Pozwala wyłączać pakiety tej gry. Niesprawdzone na tym wydaniu, a okolica ograna z pakietem może się bez niego zepsuć - najpierw zrób kopię zapisów';

  @override
  String get prefScanArtworkTitle => 'Zaglądaj do środka modów';

  @override
  String get prefScanArtworkDesc =>
      'Podczas wczytywania biblioteki zagląda do plików modów po grafiki, szczegóły zawartości i mody, które nadpisują te same zasoby';

  @override
  String get prefSoundEffectsTitle => 'Dźwięki interfejsu';

  @override
  String get prefSoundEffectsDesc =>
      'Odtwarza klasyczne dźwięki interfejsu The Sims przy kliknięciach, przełącznikach i powiadomieniach';

  @override
  String get prefAnalyticsTitle => 'Udostępniaj anonimowe dane o użyciu';

  @override
  String get prefAnalyticsDesc =>
      'Wysyła anonimowe statystyki użycia i raporty o awariach, żeby aplikacja była lepsza. Nigdy nie zawierają nazw modów, ścieżek do plików ani niczego osobistego';

  @override
  String get themeTitle => 'Motyw';

  @override
  String get themeDesc =>
      'Jasny albo ciemny. „Systemowy” idzie za ustawieniem komputera.';

  @override
  String get themeSystem => 'Systemowy';

  @override
  String get themeLight => 'Jasny';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get languageTitle => 'Język aplikacji';

  @override
  String get languageDesc =>
      'Wybierz, w jakim języku ma być aplikacja. „Systemowy” idzie za językiem komputera.';

  @override
  String get languageSystem => 'Systemowy';

  @override
  String get translatorsTitle => 'Tłumaczenie';

  @override
  String get translatorsDesc =>
      'Aplikacja mówi w jedenastu językach dzięki tym simmerom.';

  @override
  String get sectionStartup => 'URUCHAMIANIE';

  @override
  String get prefDefaultGameTitle => 'Gra przy starcie';

  @override
  String get prefDefaultGameDesc => 'Od której biblioteki zaczyna aplikacja';

  @override
  String get defaultGameAuto => 'Automatycznie';

  @override
  String get prefSetupGuideTitle => 'Przewodnik konfiguracji';

  @override
  String get prefSetupGuideDesc =>
      'Przejdź jeszcze raz pytania z pierwszego uruchomienia';

  @override
  String get onboardingReplay => 'Uruchom ponownie';

  @override
  String get onboardingSkip => 'Pomiń';

  @override
  String get onboardingSkipIntro => 'Pomiń intro';

  @override
  String get onboardingBack => 'Wstecz';

  @override
  String get onboardingNext => 'Dalej';

  @override
  String get onboardingFinish => 'Otwórz bibliotekę';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Krok $current z $total';
  }

  @override
  String get onboardingWelcomeTitle => 'Cześć! Skonfigurujmy to';

  @override
  String get onboardingWelcomeBody =>
      'Kilka szybkich pytań i twoje mody są gotowe. Zajmie mniej niż minutę, a wszystko da się potem zmienić w ustawieniach.';

  @override
  String get onboardingGamesTitle => 'Szukamy twoich gier';

  @override
  String get onboardingGamesBody =>
      'Sprawdzamy typowe miejsca: gdzie stoi każda gra i z jakiego folderu czyta mody.';

  @override
  String get onboardingScanning => 'Wciąż szukamy…';

  @override
  String onboardingGamesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Znalezione gry: $count',
      one: 'Znaleziono 1 grę',
      zero: 'Na razie nic',
    );
    return '$_temp0';
  }

  @override
  String onboardingGameMods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zainstalowane mody: $count',
      one: '1 mod już zainstalowany',
      zero: 'Folder modów gotowy',
    );
    return '$_temp0';
  }

  @override
  String get onboardingGameMissing => 'Nie ma jej na tym komputerze';

  @override
  String get onboardingNoGamesTitle => 'Nic nie znaleźliśmy';

  @override
  String get onboardingNoGamesBody =>
      'Nic straconego. Wskaż folder z modami samodzielnie w ustawieniach, a wszystko zadziała tak samo.';

  @override
  String get onboardingFavoriteTitle => 'W którą grasz najwięcej?';

  @override
  String get onboardingFavoriteBody =>
      'Aplikacja będzie zawsze otwierać się na tej grze. Między grami przełączysz się w każdej chwili z panelu bocznego.';

  @override
  String get onboardingLookTitle => 'Ustaw to po swojemu';

  @override
  String get onboardingLookBody =>
      'Cała aplikacja przebiera się w kolory gry, w której jesteś. Wybierz, jak ma wyglądać i brzmieć.';

  @override
  String get onboardingLibraryTitle => 'Jak czyta się twoja biblioteka';

  @override
  String get onboardingLibraryBody =>
      'Dwie rzeczy warte decyzji teraz, bo zmieniają to, co biblioteka ci pokazuje.';

  @override
  String get onboardingDoneTitle => 'Wszystko gotowe!';

  @override
  String get onboardingDoneBody =>
      'Twoja biblioteka jest wczytana i czeka. Przeciągnij plik moda na okno, żeby go zainstalować, a wszystko inne zmienisz w ustawieniach.';

  @override
  String get folderNotFound => 'Nie znaleziono. Wybierz folder';

  @override
  String get folderNotLocated =>
      'Nie udało się automatycznie znaleźć gry (ani jej folderu modów)';

  @override
  String folderSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count moda',
      many: '$count modów',
      few: '$count mody',
      one: '$count mod',
    );
    return '$_temp0 · $size na dysku';
  }

  @override
  String get customFolder => 'własny folder';

  @override
  String get change => 'Zmień…';

  @override
  String get resetToAuto => 'Wróć do automatu';

  @override
  String createDefaultFolderAt(String path) {
    return 'Utwórz domyślny folder (z plikami, których potrzebuje gra) w:\n$path';
  }

  @override
  String get createFolder => 'Utwórz folder';

  @override
  String get alsoFoundOnThisComputer => 'Znalezione też na tym komputerze:';

  @override
  String get clearCacheTitle => 'Wyczyść pliki pamięci podręcznej';

  @override
  String clearCacheDesc(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Usunie $count plików pamięci podręcznej ($size)',
      many: 'Usunie $count plików pamięci podręcznej ($size)',
      few: 'Usunie $count pliki pamięci podręcznej ($size)',
      one: 'Usunie $count plik pamięci podręcznej ($size)',
    );
    return '$_temp0, żeby świeżo dodana albo usunięta zawartość się pokazała; gra odbuduje je przy następnym starcie';
  }

  @override
  String get clearCaches => 'Wyczyść pamięć podręczną';

  @override
  String get ignoredConflictsTitle => 'Konflikty, które ignorujesz';

  @override
  String ignoredConflictsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count konfliktu, o których apka ma już nie przypominać. Przywróć je, a znowu pokażą się w bibliotece',
      many:
          '$count konfliktów, o których apka ma już nie przypominać. Przywróć je, a znowu pokażą się w bibliotece',
      few:
          '$count konflikty, o których apka ma już nie przypominać. Przywróć je, a znowu pokażą się w bibliotece',
      one:
          '$count konflikt, o którym apka ma już nie przypominać. Przywróć go, a znowu pokaże się w bibliotece',
    );
    return '$_temp0';
  }

  @override
  String get ignoredConflictsReset => 'Przywróć wszystkie';

  @override
  String get reportBugTitle => 'Zgłoś błąd';

  @override
  String get reportBugDesc =>
      'Otwiera zgłoszenie na GitHubie z wypełnioną wersją aplikacji, systemem i aktualną grą';

  @override
  String get reportBugButton => 'Zgłoś…';

  @override
  String get suggestFeatureTitle => 'Zaproponuj funkcję';

  @override
  String get suggestFeatureDesc =>
      'Czegoś brakuje? Napisz, co uczyniłoby menedżera modów lepszym';

  @override
  String get suggestFeatureButton => 'Zaproponuj…';

  @override
  String get wikiTitle => 'Poradnik i FAQ';

  @override
  String get wikiDesc =>
      'Jak instalować mody, naprawić wykrywanie folderów i więcej, na wiki projektu';

  @override
  String get wikiButton => 'Otwórz wiki';

  @override
  String aboutTagline(String version) {
    return 'Wersja $version · Obsługa The Sims 1-4 · SimCity już wkrótce';
  }

  @override
  String updateIsAvailable(String version) {
    return 'Wersja $version jest już dostępna';
  }

  @override
  String get noUpdateFound => 'Brak aktualizacji';

  @override
  String getVersion(String version) {
    return 'Pobierz v$version';
  }

  @override
  String get checkingForUpdates => 'Sprawdzam…';

  @override
  String get checkForUpdates => 'Sprawdź aktualizacje';

  @override
  String get categoryPackage => 'Paczka';

  @override
  String get categoryScript => 'Skrypt';

  @override
  String get categoryObject => 'Obiekt';

  @override
  String get categoryArchive => 'Archiwum';

  @override
  String get categorySkin => 'Skórka';

  @override
  String get categoryTexture => 'Tekstura';

  @override
  String get categoryWall => 'Ściana';

  @override
  String get categoryFloor => 'Podłoga';

  @override
  String get contentCasParts => 'elementy CAS';

  @override
  String get contentObjects => 'obiekty';

  @override
  String get contentTunings => 'tuningi';

  @override
  String get contentBehaviors => 'zachowania';

  @override
  String get contentTextTables => 'tabele tekstu';

  @override
  String get contentTextures => 'tekstury';

  @override
  String get contentMeshes => 'siatki';

  @override
  String get modKindCas => 'CAS';

  @override
  String get modKindBuildBuy => 'Budowanie';

  @override
  String get modKindGameplay => 'Rozgrywka';

  @override
  String get modKindScript => 'Skrypt';

  @override
  String errorNoModFiles(String extensions, String name) {
    return 'W $name nie ma żadnych plików modów ($extensions).';
  }

  @override
  String errorUnreadableArchive(String name) {
    return '$name to nie jest archiwum, które aplikacja potrafi odczytać.';
  }

  @override
  String errorNoUnpacker(String format, String name) {
    return 'Nic na tym komputerze nie potrafi rozpakować archiwów $format. Rozpakuj $name ręcznie i zainstaluj pliki ze środka.';
  }

  @override
  String errorNoUnpackerLinux(String format, String name) {
    return 'Nic na tym komputerze nie potrafi rozpakować archiwów $format. Zainstaluj p7zip i spróbuj ponownie albo rozpakuj $name ręcznie i zainstaluj pliki ze środka.';
  }

  @override
  String errorNoUnpackerLinuxRar(String format, String name) {
    return 'Nic na tym komputerze nie potrafi rozpakować archiwów $format. Zainstaluj p7zip lub unrar i spróbuj ponownie albo rozpakuj $name ręcznie i zainstaluj pliki ze środka.';
  }

  @override
  String errorUnpackFailed(String name) {
    return 'Nie udało się rozpakować $name. Archiwum może być zabezpieczone hasłem, być częścią archiwum wieloczęściowego albo uszkodzonym pobraniem. Rozpakuj je ręcznie i zainstaluj pliki ze środka.';
  }

  @override
  String errorSims3PackUnreadable(String name) {
    return '$name to nie jest paczka The Sims 3, którą ta aplikacja potrafi odczytać.';
  }

  @override
  String errorSims3PackWorld(String name) {
    return '$name to świat, a nie zawartość niestandardowa. Zainstaluj go Launcherem The Sims 3: gra trzyma światy poza folderem modów.';
  }

  @override
  String errorSims3PackLibrary(String name) {
    return '$name to działka albo rodzina, a nie zawartość niestandardowa. Zainstaluj to Launcherem The Sims 3: trafi do twojej Biblioteki w grze.';
  }

  @override
  String errorInstallFailed(String name, String reason) {
    return 'Nie udało się zainstalować „$name”: $reason. Jeśli będzie się powtarzać, rozpakuj ręcznie i zainstaluj pliki ze środka.';
  }

  @override
  String errorInstallFailedRaw(String name, String reason) {
    return 'Nie udało się zainstalować „$name”: $reason';
  }

  @override
  String errorFileInUseDelete(String name) {
    return 'Nie udało się usunąć „$name”: plik jest używany przez inny program (gra jest włączona?) albo chroniony przed zapisem. Zamknij wszystko, co go używa, i spróbuj ponownie.';
  }

  @override
  String errorFileInUseRename(String name) {
    return 'Nie udało się zmienić nazwy „$name”: plik jest używany przez inny program (gra jest włączona?) albo chroniony przed zapisem. Zamknij wszystko, co go używa, i spróbuj ponownie.';
  }

  @override
  String errorFileNameTaken(String name) {
    return 'W tym folderze już jest „$name”. Zmień nazwę jednego z nich i spróbuj jeszcze raz.';
  }

  @override
  String errorFolderNameBad(String name) {
    return '„$name” nie nadaje się na nazwę folderu. Spróbuj bez ukośników i znaków, które system rezerwuje dla siebie.';
  }

  @override
  String errorFolderTooDeep(int levels) {
    return 'Gra zagląda tylko $levels foldery w głąb folderu z modami - nic głębiej nigdy się nie wczyta.';
  }

  @override
  String errorBulkMoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count moda nie dało się przenieść',
      many: '$count modów nie dało się przenieść',
      few: '$count modów nie dało się przenieść',
      one: '$count moda nie dało się przenieść',
    );
    return '$_temp0 - może używa ich inny program (gra jest włączona?), są tylko do odczytu, albo w folderze jest już plik o tej nazwie.';
  }

  @override
  String errorBulkToggleFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count moda nie dało się przełączyć',
      many: '$count modów nie dało się przełączyć',
      few: '$count modów nie dało się przełączyć',
      one: '$count moda nie dało się przełączyć',
    );
    return '$_temp0 - może używa ich inny program (gra jest włączona?) albo są tylko do odczytu.';
  }

  @override
  String errorBulkRemoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count moda nie dało się usunąć',
      many: '$count modów nie dało się usunąć',
      few: '$count modów nie dało się usunąć',
      one: '$count moda nie dało się usunąć',
    );
    return '$_temp0 - może używa ich inny program (gra jest włączona?) albo są tylko do odczytu.';
  }

  @override
  String errorFileMissing(String name) {
    return '„$name” nie ma już w folderze modów: możliwe, że inny program go przeniósł albo usunął.';
  }

  @override
  String get requirementMedievalModLoader =>
      'The Sims Medieval nie uruchomi modów skryptowych ani core bez pliku ładującego od społeczności w folderze Game\\Bin gry. Zwykła zawartość działa, reszta nie.';

  @override
  String get requirementSims4ModsOff =>
      'Gra ma wyłączoną własną obsługę zawartości i modów w Opcjach gry, więc nic się z tego nie ładuje. Włącz to z powrotem w Opcje → Opcje gry → Inne i uruchom grę ponownie.';

  @override
  String get requirementSims4ScriptModsOff =>
      'Masz tu mody skryptowe, ale gra ma wyłączone „Zezwalaj na mody skryptowe” w Opcjach gry. Aktualizacje to resetują.';

  @override
  String get requirementGetFile => 'Skąd go wziąć';

  @override
  String tooDeepBanner(int count, int levels) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modów',
    );
    return '$_temp0 siedzi w podfolderze, którego gra nie czyta. Schodzi tylko $levels foldery w głąb. Przenieś je wyżej, to się wczytają.';
  }

  @override
  String get tooDeepShow => 'Pokaż je';

  @override
  String get duplicatesFind => 'Znajdź powtórzone mody';

  @override
  String duplicatesScanning(int done, int total) {
    return 'Czytam mody, które mogą być kopiami… $done z $total';
  }

  @override
  String get duplicatesStop => 'Zatrzymaj';

  @override
  String duplicatesBanner(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modów to dokładnie te same pliki co inne',
      many: '$count modów to dokładnie te same pliki co inne',
      few: '$count mody to dokładnie te same pliki co inne',
      one: 'Jeden mod to dokładnie ten sam plik co inny',
    );
    return '$_temp0 - odzyskasz $size.';
  }

  @override
  String get duplicatesShow => 'Pokaż je';

  @override
  String get duplicatesSelectExtras => 'Zaznacz zbędne kopie';

  @override
  String get duplicatesClean => 'Nic tu się nie powtarza.';

  @override
  String get duplicatesDismiss => 'Jasne';

  @override
  String tagTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tagi $count modów',
      many: 'Tagi $count modów',
      few: 'Tagi $count modów',
      one: 'Tagi tego moda',
    );
    return '$_temp0';
  }

  @override
  String get tagBody =>
      'Twoje własne tagi, żeby później wszystko odnaleźć. Kliknij tag, żeby go dodać albo zdjąć.';

  @override
  String get tagHint => 'Nowy tag';

  @override
  String get tagAdd => 'Dodaj';

  @override
  String get tagDone => 'Gotowe';

  @override
  String get tagHeading => 'Tagi';

  @override
  String get tagAddFirst => 'Dodaj tag';

  @override
  String tagRemove(String tag) {
    return 'Zdejmij „$tag”';
  }

  @override
  String get selectionTag => 'Otaguj…';

  @override
  String folderAlsoReading(String folders) {
    return 'Twoja gra czyta też $folders, więc mody z tego folderu też są w tej bibliotece.';
  }

  @override
  String errorNoWriteAccess(String folder) {
    return 'Apka nie ma uprawnień do zapisu w „$folder”. System chroni ten folder: nadaj swojemu kontu prawo zapisu albo wskaż inny folder w Ustawieniach.';
  }

  @override
  String get folderReadOnlyBanner =>
      'Ten folder modów jest tylko do odczytu, więc instalowanie i usuwanie modów nie zadziała, dopóki twoje konto nie będzie mogło w nim zapisywać.';

  @override
  String get elevatedNoDropBanner =>
      'Działasz jako administrator, więc Windows nie pozwala przeciągać plików na okno. Skorzystaj z przycisku Zainstaluj, ten dalej działa.';

  @override
  String errorShopDownload(String name) {
    return '„$name” nie dał się pobrać z The Exchange. Sprawdź połączenie i spróbuj jeszcze raz.';
  }

  @override
  String errorShopNoModFiles(String name) {
    return 'W „$name” nie ma nic, co ta gra mogłaby zainstalować. Może to wcale nie mod - użyj Pobierz i zapisz plik tam, gdzie chcesz.';
  }

  @override
  String get errorShopListingNotFound =>
      'Tego moda już nie ma na The Exchange. Mógł zostać zdjęty.';

  @override
  String get errorShopListingUnknownGame =>
      'Ten mod jest do gry, której ta wersja apki jeszcze nie zna. Spróbuj zaktualizować.';

  @override
  String errorPackToggleFailed(String pack) {
    return 'Nie udało się przełączyć $pack. Zamknij grę i spróbuj jeszcze raz.';
  }

  @override
  String get errorPackNoUserData =>
      'Nie znalazłem folderu z ustawieniami gry, więc nie ma gdzie zapisać, które pakiety pominąć. Odpal najpierw grę raz.';

  @override
  String get errorPackNeedsAdmin =>
      'Windows nie pozwolił apce tego zmienić. Uruchom ją jako administrator i spróbuj jeszcze raz.';

  @override
  String get errorPackNotSupported =>
      'W tym systemie nie da się włączać ani wyłączać pakietów.';

  @override
  String get errorPackIsTheGame =>
      'To pakiet, z którego uruchamia się gra, więc musi zostać włączony.';

  @override
  String get errorPackToggleRefused =>
      'Nie udało się zmienić tego pakietu. Zamknij grę i spróbuj jeszcze raz.';

  @override
  String get eraClassic => 'Klasyka';

  @override
  String get eraNightlife => 'Nocne życie';

  @override
  String get eraAmbitions => 'Kariera';

  @override
  String get eraModern => 'Nowoczesność';

  @override
  String get eraMedieval => 'Średniowiecze';

  @override
  String get navPacks => 'Pakiety';

  @override
  String get packsScanning => 'Szukam twoich pakietów…';

  @override
  String get packsEmptyTitle => 'Nie znaleziono pakietów';

  @override
  String packsEmptyBody(String game) {
    return 'Albo $game nie jest zainstalowana tam, gdzie apka może ją znaleźć, albo nie ma jeszcze przy niej żadnych pakietów.';
  }

  @override
  String get packsRescan => 'Sprawdź ponownie';

  @override
  String packsSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zainstalowanych $count pakietu',
      many: 'Zainstalowanych $count pakietów',
      few: 'Zainstalowane $count pakiety',
      one: 'Zainstalowany $count pakiet',
    );
    return '$_temp0';
  }

  @override
  String packsSummaryWithOff(int count, int off) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pakietu włączonych',
      many: '$count pakietów włączonych',
      few: '$count pakiety włączone',
      one: '$count pakiet włączony',
    );
    return '$_temp0, $off wyłączonych';
  }

  @override
  String get packsOff => 'Wyłączony';

  @override
  String get packsInstalled => 'Zainstalowany';

  @override
  String get packsNeedAdmin =>
      'Włączanie i wyłączanie tych pakietów wymaga uprawnień administratora, bo właśnie tam gra trzyma swoją listę. Uruchom apkę jako administrator, żeby je zmieniać - w międzyczasie przeciąganie i upuszczanie przestaje działać, więc warto potem wrócić.';

  @override
  String get packsExperimentalTitle => 'Wyłączanie ich jest eksperymentalne';

  @override
  String get packsExperimentalOff =>
      'Działa tak, jak zawsze działało w tej grze, ale nikt nie sprawdzał tego na tym wydaniu, a okolica, w którą grałeś z pakietem, może się zepsuć, gdy otworzysz ją bez niego. Samo oglądanie jest bezpieczne. Włącz eksperymentalne przełączniki w Ustawieniach, jeśli mimo to chcesz spróbować.';

  @override
  String get packsExperimentalOn =>
      'Najpierw zrób kopię swoich okolic. Okolica, w którą grałeś z pakietem, może się zepsuć, gdy otworzysz ją bez niego, a stąd się tego nie cofnie - ponowne włączenie pakietu nie zawsze przywraca zapis.';

  @override
  String packsRestartNotice(String game) {
    return 'Uruchom $game ponownie, żeby to zadziałało. Pakiety i tak zostają zainstalowane.';
  }

  @override
  String packsAllOwnedSims4(String expansions, String gamePacks) {
    return 'Dodatki: $expansions. Pakiety rozgrywki: $gamePacks. Wszystko kupione, jasne.';
  }

  @override
  String get packKindExpansions => 'Dodatki';

  @override
  String get packKindGamePacks => 'Pakiety rozgrywki';

  @override
  String get packKindStuffPacks => 'Akcesoria';

  @override
  String get packKindKits => 'Zestawy';

  @override
  String get packKindFreePacks => 'Darmowe pakiety';

  @override
  String get navSaves => 'Zapisy';

  @override
  String get savesScanning => 'Czytam twoje zapisy…';

  @override
  String get savesEmptyTitle => 'Nie znaleziono zapisów';

  @override
  String savesEmptyBody(String game) {
    return 'Zagraj w $game i zapisz grę, a twoje światy pojawią się tutaj: rodziny, zdjęcia i cała reszta.';
  }

  @override
  String get savesRescan => 'Skanuj ponownie';

  @override
  String savesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Znaleziono $count zapisu',
      many: 'Znaleziono $count zapisów',
      few: 'Znaleziono $count zapisy',
      one: 'Znaleziono $count zapis',
    );
    return '$_temp0';
  }

  @override
  String savesLastSaved(String date) {
    return 'Ostatni zapis: $date';
  }

  @override
  String get savesShowInFolder => 'Pokaż w folderze';

  @override
  String savesBackups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kopii zapasowej',
      many: '$count kopii zapasowych',
      few: '$count kopie zapasowe',
      one: '$count kopia zapasowa',
    );
    return '$_temp0';
  }

  @override
  String get savesTabHouseholds => 'Rodziny';

  @override
  String get savesTabAlbum => 'Album ze zdjęciami';

  @override
  String get savesTabStats => 'Statystyki świata';

  @override
  String savesNeighborhood(int number) {
    return 'Otoczenie $number';
  }

  @override
  String get savesOtherHouseholds => 'NPC i pozostałe rodziny';

  @override
  String savesSimCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sima',
      many: '$count Simów',
      few: '$count Simy',
      one: '$count Sim',
    );
    return '$_temp0';
  }

  @override
  String get savesFunds => 'Fundusze';

  @override
  String get savesRooms => 'Pokoje';

  @override
  String savesBedsBaths(int beds, int baths) {
    return '$beds syp. · $baths łaz.';
  }

  @override
  String savesByCreator(String name) {
    return 'od $name';
  }

  @override
  String get savesMembers => 'Członkowie';

  @override
  String get savesRelationships => 'Relacje';

  @override
  String get savesUnknownSim => 'Nieznany Sim';

  @override
  String get savesStatSims => 'Simowie';

  @override
  String get savesStatHouseholds => 'Rodziny';

  @override
  String get savesStatNetWorth => 'Majątek';

  @override
  String get savesStatWorlds => 'Światy';

  @override
  String get savesStatPhotos => 'Zdjęcia';

  @override
  String savesAcrossHouseholds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'w $count rodzinach',
      many: 'w $count rodzinach',
      few: 'w $count rodzinach',
      one: 'w $count rodzinie',
    );
    return '$_temp0';
  }

  @override
  String savesPlayedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grywalnej',
      many: '$count grywalnych',
      few: '$count grywalne',
      one: '$count grywalna',
    );
    return '$_temp0';
  }

  @override
  String get savesSizeOnDisk => 'Rozmiar na dysku';

  @override
  String get savesLifeStages => 'Etapy życia';

  @override
  String get savesTopSkills => 'Najwyższe umiejętności w tym zapisie';

  @override
  String get savesSaveInfo => 'Plik zapisu';

  @override
  String get savesLastSavedLabel => 'Ostatni zapis';

  @override
  String get savesGameVersion => 'Wersja gry';

  @override
  String get savesDescription => 'Opis';

  @override
  String get savesAgeInfant => 'Niemowlę';

  @override
  String get savesAgeBaby => 'Bobas';

  @override
  String get savesAgeToddler => 'Brzdąc';

  @override
  String get savesAgeChild => 'Dziecko';

  @override
  String get savesAgeTeen => 'Nastolatek';

  @override
  String get savesAgeYoungAdult => 'Młody dorosły';

  @override
  String get savesAgeAdult => 'Dorosły';

  @override
  String get savesAgeElder => 'Senior';

  @override
  String get savesGenderMale => 'Mężczyzna';

  @override
  String get savesGenderFemale => 'Kobieta';

  @override
  String get savesSkillCooking => 'Gotowanie';

  @override
  String get savesSkillMechanical => 'Mechanika';

  @override
  String get savesSkillCharisma => 'Charyzma';

  @override
  String get savesSkillBody => 'Ciało';

  @override
  String get savesSkillLogic => 'Logika';

  @override
  String get savesSkillCreativity => 'Kreatywność';

  @override
  String get savesSkillCleaning => 'Sprzątanie';

  @override
  String get savesPersonalityNeat => 'Schludny';

  @override
  String get savesPersonalityOutgoing => 'Towarzyski';

  @override
  String get savesPersonalityActive => 'Aktywny';

  @override
  String get savesPersonalityPlayful => 'Figlarny';

  @override
  String get savesPersonalityNice => 'Miły';

  @override
  String get savesZodiacAries => 'Baran';

  @override
  String get savesZodiacTaurus => 'Byk';

  @override
  String get savesZodiacGemini => 'Bliźnięta';

  @override
  String get savesZodiacCancer => 'Rak';

  @override
  String get savesZodiacLeo => 'Lew';

  @override
  String get savesZodiacVirgo => 'Panna';

  @override
  String get savesZodiacLibra => 'Waga';

  @override
  String get savesZodiacScorpio => 'Skorpion';

  @override
  String get savesZodiacSagittarius => 'Strzelec';

  @override
  String get savesZodiacCapricorn => 'Koziorożec';

  @override
  String get savesZodiacAquarius => 'Wodnik';

  @override
  String get savesZodiacPisces => 'Ryby';

  @override
  String get savesAspirationRomance => 'Romans';

  @override
  String get savesAspirationFamily => 'Rodzina';

  @override
  String get savesAspirationFortune => 'Fortuna';

  @override
  String get savesAspirationPopularity => 'Popularność';

  @override
  String get savesAspirationKnowledge => 'Wiedza';

  @override
  String get savesAspirationGrowUp => 'Dorastanie';

  @override
  String get savesAspirationPleasure => 'Przyjemność';

  @override
  String get savesAspirationGrilledCheese => 'Tost z serem';

  @override
  String get savesRelCrush => 'zauroczenie';

  @override
  String get savesRelLove => 'zakochani';

  @override
  String get savesRelEngaged => 'zaręczeni';

  @override
  String get savesRelMarried => 'małżeństwo';

  @override
  String get savesRelFriends => 'przyjaciele';

  @override
  String get savesRelBestFriends => 'najlepsi przyjaciele';

  @override
  String get savesRelSteady => 'chodzą ze sobą';

  @override
  String get savesRelEnemies => 'wrogowie';

  @override
  String get savesPhotoFamilyPortrait => 'Portret rodzinny';

  @override
  String get savesPhotoLot => 'Parcela';

  @override
  String get savesPhotoSim => 'Portret Sima';

  @override
  String get savesPhotoSnapshot => 'Zdjęcie';

  @override
  String get savesProperty => 'Majątek';

  @override
  String get savesGhost => 'duch';

  @override
  String savesCareerLevel(String career, int level) {
    return '$career · poziom $level';
  }

  @override
  String get savesSpeciesLargeDog => 'pies';

  @override
  String get savesSpeciesSmallDog => 'mały pies';

  @override
  String get savesSpeciesCat => 'kot';

  @override
  String get savesOccultVampire => 'wampir';

  @override
  String get savesOccultZombie => 'zombie';

  @override
  String get savesOccultWerewolf => 'wilkołak';

  @override
  String get savesOccultPlantSim => 'RoślinSim';

  @override
  String get savesOccultAlien => 'kosmita';

  @override
  String get savesOccultServo => 'servo';

  @override
  String get savesOccultWitch => 'czarownica';

  @override
  String get savesOccultBigfoot => 'wielka stopa';

  @override
  String get savesOccultFairy => 'wróżka';

  @override
  String get savesOccultGenie => 'dżin';

  @override
  String get savesOccultMermaid => 'syrena';

  @override
  String get savesLotResidential => 'Mieszkalna';

  @override
  String get savesLotCommunity => 'Parcela publiczna';

  @override
  String get savesLotDorm => 'Akademik';

  @override
  String get savesLotSecretSociety => 'Tajne stowarzyszenie';

  @override
  String get savesLotGreekHouse => 'Dom bractwa';

  @override
  String get savesLotHotel => 'Hotel';

  @override
  String get savesLotSecret => 'Ukryta parcela';

  @override
  String get savesLotBusiness => 'Firma';

  @override
  String get savesLotApartment => 'Mieszkanie';

  @override
  String savesGpa(String gpa) {
    return 'średnia $gpa';
  }

  @override
  String savesSemester(int number) {
    return 'semestr $number';
  }

  @override
  String savesPredestinedHobby(String hobby) {
    return 'Stworzony do hobby: $hobby';
  }

  @override
  String get savesHobbyCuisine => 'Kuchnia';

  @override
  String get savesHobbyArts => 'Sztuka i rękodzieło';

  @override
  String get savesHobbyFilm => 'Film i literatura';

  @override
  String get savesHobbySports => 'Sport';

  @override
  String get savesHobbyGames => 'Gry';

  @override
  String get savesHobbyNature => 'Natura';

  @override
  String get savesHobbyTinkering => 'Majsterkowanie';

  @override
  String get savesHobbyFitness => 'Fitness';

  @override
  String get savesHobbyScience => 'Nauka';

  @override
  String get savesHobbyMusic => 'Muzyka i taniec';

  @override
  String get savesTieMother => 'matka';

  @override
  String get savesTieFather => 'ojciec';

  @override
  String get savesTieSpouse => 'w związku z';

  @override
  String savesTieSibling(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'rodzeństwo',
      many: 'rodzeństwo',
      few: 'rodzeństwo',
      one: 'rodzeństwo',
    );
    return '$_temp0';
  }

  @override
  String savesTieChild(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dzieci',
      many: 'dzieci',
      few: 'dzieci',
      one: 'dziecko',
    );
    return '$_temp0';
  }

  @override
  String get savesInterestPolitics => 'Polityka';

  @override
  String get savesInterestMoney => 'Pieniądze';

  @override
  String get savesInterestEnvironment => 'Środowisko';

  @override
  String get savesInterestCrime => 'Przestępczość';

  @override
  String get savesInterestEntertainment => 'Rozrywka';

  @override
  String get savesInterestCulture => 'Kultura';

  @override
  String get savesInterestFood => 'Jedzenie';

  @override
  String get savesInterestHealth => 'Zdrowie';

  @override
  String get savesInterestFashion => 'Moda';

  @override
  String get savesInterestSports => 'Sport';

  @override
  String get savesInterestParanormal => 'Zjawiska paranormalne';

  @override
  String get savesInterestTravel => 'Podróże';

  @override
  String get savesInterestWork => 'Praca';

  @override
  String get savesInterestWeather => 'Pogoda';

  @override
  String get savesInterestAnimals => 'Zwierzęta';

  @override
  String get savesInterestSchool => 'Szkoła';

  @override
  String get savesInterestToys => 'Zabawki';

  @override
  String get savesInterestSciFi => 'Science fiction';

  @override
  String get savesInterestMusic => 'Muzyka';

  @override
  String get savesInterestOutdoors => 'Przyroda';

  @override
  String get setupHelpSims1 =>
      'Pierwsze The Sims trzyma własną zawartość w folderze instalacji, a nie w Dokumentach: obiekty trafiają do folderu Downloads obok pliku wykonywalnego gry (na przykład C:\\Program Files (x86)\\Maxis\\The Sims\\Downloads), a resztę aplikacja sortuje sama: skórki (.skn/.cmx/.bmp) do GameData\\Skins, ściany i podłogi do GameData\\Walls i GameData\\Floors. Legacy Collection z 2025 działa tak samo ze swojego folderu instalacji (EA Games\\The Sims Legacy albo Steam\\steamapps\\common\\The Sims Legacy Collection). Jeśli gra siedzi gdzie indziej (inny dysk, własna biblioteka Steam), wskaż jej folder Downloads ręcznie.';

  @override
  String get setupHelpSims2 =>
      'The Sims 2 wczytuje własną zawartość z Dokumenty > EA Games > The Sims 2 > Downloads (Ultimate Collection używa „The Sims 2 Ultimate Collection”, a Legacy Collection z 2025 używa „The Sims 2 Legacy”). Folder może nie istnieć, dopóki go nie utworzysz albo raz czegoś nie zainstalujesz. Przy starcie gry odpowiedz „Tak” na pytanie o własną zawartość, żeby pobrane rzeczy się włączyły.';

  @override
  String get setupHelpSims3 =>
      'The Sims 3 nie tworzy folderu na mody samo z siebie: potrzebuje społecznościowego „frameworku”, czyli folderu Mods > Packages w Dokumenty > Electronic Arts > The Sims 3 plus pliku Resource.cfg, który każe grze go czytać. Aplikacja utworzy oba za ciebie. Przy instalacji z płyty albo przez Wine folder może siedzieć w samej paczce gry; wtedy wskaż go przez „Wybierz folder”.';

  @override
  String get setupHelpSims4 =>
      'The Sims 4 wczytuje mody z Dokumenty > Electronic Arts > The Sims 4 > Mods. Gra tworzy ten folder przy pierwszym uruchomieniu, więc odpal ją raz, jeśli folderu nie ma. Potem w grze włącz Opcje > Opcje gry > Inne > „Włącz zawartość niestandardową i mody” (oraz „Zezwalaj na mody skryptowe” dla plików .ts4script) i uruchom grę ponownie.';

  @override
  String get setupHelpSimsMedieval =>
      'The Sims Medieval wczytuje mody z folderu instalacji, a nie z Dokumentów: folder Mods > Packages obok plików gry (na przykład C:\\Program Files (x86)\\Origin Games\\The Sims Medieval) plus plik Resource.cfg w folderze instalacji, który każe grze go czytać. Aplikacja utworzy oba za ciebie (w Program Files Windows może poprosić o uprawnienia administratora). Folder Dokumenty > Electronic Arts > The Sims Medieval trzyma tylko zapisy gry; mody wrzucone tam nic nie robią. Przy Wine/CrossOver albo własnej bibliotece Steam użyj „Wybierz folder” i wskaż folder Mods > Packages w instalacji.';

  @override
  String get prefSubfoldersTitle => 'Foldery zawierają swoje podfoldery';

  @override
  String get prefSubfoldersDesc =>
      'Folder pokazuje też wszystko, co jest w środku. Po wyłączeniu cc i cc/defaults to osobne półki.';

  @override
  String deleteFolderTitle(String folder) {
    return 'Usunąć $folder?';
  }

  @override
  String get deleteFolderBody =>
      'Folder i wszystko, co w nim jest, zniknie razem z podfolderami. Tego nie da się cofnąć.';

  @override
  String deleteFolderMods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zostaną usunięte mody: $count',
      one: 'Zostanie usunięty 1 mod',
    );
    return '$_temp0';
  }

  @override
  String get deleteFolderEmpty => 'Nie ma w nim żadnych modów.';

  @override
  String get deleteFolder => 'Usuń folder';

  @override
  String triviaTitle(String game) {
    return 'Plumbob wie · $game';
  }

  @override
  String get triviaContextLibrary => 'Wygląda na to, że przeglądasz swoje mody';

  @override
  String get triviaContextSaves => 'Wygląda na to, że siedzisz w zapisach';

  @override
  String get triviaContextPacks =>
      'Wygląda na to, że porządkujesz swoje pakiety';

  @override
  String triviaCounter(int index, int total) {
    return 'Ciekawostka $index z $total';
  }

  @override
  String get triviaOpen => 'Zapytaj plumbob';

  @override
  String get triviaClose => 'Nie teraz';

  @override
  String get triviaPrevious => 'Poprzednia ciekawostka';

  @override
  String get triviaNext => 'Następna ciekawostka';

  @override
  String get triviaAnother => 'Jeszcze jedna';

  @override
  String get triviaToSettings => 'Wystarczy? Wyłącz plumbob w Ustawieniach';

  @override
  String get prefTriviaTitle => 'Ciekawostki plumboba';

  @override
  String get prefTriviaDesc =>
      'Pozwól plumbobowi wyskakiwać co jakiś czas z ciekawostką o grze, w której akurat jesteś';

  @override
  String get triviaCategoryOrigins => 'Początki';

  @override
  String get triviaCategoryDesign => 'Projekt';

  @override
  String get triviaCategoryLore => 'Lore';

  @override
  String get triviaCategoryDeath => 'Śmierć';

  @override
  String get triviaCategoryMusic => 'Muzyka';

  @override
  String get triviaCategoryCheats => 'Kody';

  @override
  String get triviaCategoryRecords => 'Rekordy';

  @override
  String get triviaCategoryModding => 'Modding';

  @override
  String get triviaCategoryLanguage => 'Język';

  @override
  String get triviaCategoryCommunity => 'Społeczność';

  @override
  String get triviaSeriesLlama =>
      'Maxis zorganizowało kiedyś głosowanie całego studia nad nieoficjalną maskotką. Kandydowały paproć, tasiemiec nieuzbrojony i lama. Wygrała lama i od tamtej pory pojawia się w każdej odsłonie.';

  @override
  String get triviaSeriesSimlish =>
      'Simlish powstał przy mikrofonie. Stephen Kearin i Gerri Lawlor dostawali hasła w rodzaju „głodny” albo „samotny” i godzinami improwizowali, jak to powinno brzmieć.';

  @override
  String get triviaSeriesCheats =>
      'rosebud i klapaucius dają po §1000. Rosebud to Obywatel Kane, a Klapaucjusz to robot konstruktor z Cyberiady Stanisława Lema, książki, którą Will Wright wymienia jako inspirację od czasów SimCity.';

  @override
  String get triviaSeriesRecords =>
      'Guinness uznaje The Sims za najlepiej sprzedającą się serię pecetową w historii. Przekroczyła 125 milionów egzemplarzy ponad dekadę temu i została przetłumaczona na 60 języków.';

  @override
  String get triviaSeriesGoths =>
      'Gothowie to jedna z najdłużej obecnych rodzin w grach. Mortimer i Bella pojawiają się w każdej głównej odsłonie od 2000 roku.';

  @override
  String get triviaSeriesReaper =>
      'Ponury Żniwiarz ma biografię, której zwykła rozgrywka nigdy nie pokazuje. Między innymi wymienia jego ulubiony zespół: Styx.';

  @override
  String get triviaSeriesSimCity =>
      'The Sims wyrosło z SimCity. Willowi Wrightowi wciąż chodziło po głowie, żeby przybliżyć widok na tych ludzików, dla których buduje się miasto.';

  @override
  String get triviaSeriesLegacy =>
      'W styczniu 2025 EA wróciło do sprzedaży The Sims i The Sims 2 jako Legacy Collections, ze wszystkimi dodatkami. To poprawki zgodności, nie remastery, więc obie gry działają dokładnie tak jak kiedyś.';

  @override
  String get triviaSeriesPlumbob =>
      'Zielony diament zapisywano na trzy sposoby: PlumbBob w The Sims, Plum Bob w The Sims 2 i plumbob od The Sims 4. Maxis mówi, że w trakcie produkcji używano wszystkich trzech.';

  @override
  String get triviaSeriesModScene =>
      'Scena modderska jest niemal tak stara jak sama seria. Edytory skórek i obiektów krążyły już kilka miesięcy po premierze pierwszej części w 2000 roku, długo przed jakimikolwiek oficjalnymi narzędziami.';

  @override
  String get triviaSeriesConflicts =>
      'Konflikt jest prostszy, niż brzmi. Dwa mody zgłaszają się po ten sam zasób, oba się ładują, a wygrywa ten, którego gra przeczyta jako ostatni. Nic się nie zepsuło, coś zostało tylko przegłosowane.';

  @override
  String get triviaSeriesPackage =>
      'Plik .package to archiwum DBPF, czyli Database Packed File. Maxis używa tego samego kontenera od SimCity 4 i właśnie dlatego jedno narzędzie otwiera dwadzieścia lat custom contentu.';

  @override
  String get triviaSeriesRename =>
      'Wyłączanie moda przez zmianę nazwy to najstarszy trik sceny. Gra ładuje tylko to, co rozpoznaje, więc przemianowany package leży dokładnie tam, gdzie leżał, i milczy.';

  @override
  String get triviaSeriesSaves =>
      'Zapisy w The Sims to okolice, nie sloty. Rodziny, działki, wspomnienia i plotki mieszkają w jednym folderze, który rośnie tak długo, jak długo grasz.';

  @override
  String get triviaSeriesPacks =>
      'Wyłączenie pakietu nie przenosi ani jednego pliku. Każda gra z serii trzyma gdzie indziej własną listę tego, co ma wczytać, linijkę w ustawieniach albo klucz rejestru, a ukrycie pakietu to po prostu edycja tej listy.';

  @override
  String get triviaSims1Dollhouse =>
      'The Sims zaczynało jako symulator architektury o nazwie Project Dollhouse. Simów dodano tylko po to, żeby gracz miał jak ocenić, czy w tym domu da się dobrze mieszkać.';

  @override
  String get triviaSims1Oakland =>
      'Will Wright stracił dom w pożarze Oakland w 1991 roku. Odbudowa gospodarstwa domowego od zera, meble, sprzęty i codzienne rytuały, stała się zalążkiem gry.';

  @override
  String get triviaSims1Toilet =>
      'Zarząd nie dał się przekonać prezentacji i zbył pomysł jako „grę o kiblu”, bo simowie potrzebowali łazienki.';

  @override
  String get triviaSims1HomeTactics =>
      'Zanim projekt stał się The Sims, przedstawiano go jako Home Tactics: The Experimental Domestic Simulator. Tej wersji grupy testowe też nie polubiły.';

  @override
  String get triviaSims1Myst =>
      'W 2002 roku The Sims wyprzedziło Myst i zostało najlepiej sprzedającą się grą pecetową w historii.';

  @override
  String get triviaSims1Simlish =>
      'Simlish improwizowali aktorzy głosowi, bawiąc się strzępkami ukraińskiego, navajo, tagalskiego i estońskiego, i celowo pozbawiono go znaczenia, żeby język nigdy się nie zestarzał.';

  @override
  String get triviaSims1Architecture =>
      'Narzędzia budowlane były jak na rok 2000 tak nietypowe, że część osób nigdy nie postawiła ani jednego sima i traktowała grę jak darmowy program do architektury.';

  @override
  String get triviaSims1Audience =>
      'Nietypowo jak na tamte czasy, większość grających stanowiły kobiety, i po części dlatego marketing tej gry nie przypominał niczego innego na półce.';

  @override
  String get triviaSims1Cowplant =>
      'Krowoślin zadebiutował właśnie tu, pod nazwą Laganaphyllis Simnovorii, i od tamtej pory po cichu zjada simów w każdym pokoleniu.';

  @override
  String get triviaSims1Plumbob =>
      'Słowo plumbob pochodzi od pionu murarskiego, tego spiczastego ciężarka na sznurku, którym szuka się pionu. To była gra o architekturze, zanim stała się czymkolwiek innym.';

  @override
  String get triviaSims1Release =>
      'Gra ukazała się 4 lutego 2000 roku i sprzedała się lepiej, niż przewidywała którakolwiek z prognoz EA.';

  @override
  String get triviaSims1Edith =>
      'Każdy obiekt w grze zaprogramowano w języku SimAntics, przy użyciu wewnętrznego narzędzia nazwanego Edith na cześć Edith Bunker: pierwszej postaci, jaką kiedykolwiek zbudowano do The Sims.';

  @override
  String get triviaSims1Expansions =>
      'Siedem dodatków w trzy i pół roku, po jednym na wiosnę i na jesień, od Livin’ Large w sierpniu 2000 do Makin’ Magic w październiku 2003.';

  @override
  String get triviaSims1Unleashed =>
      'Unleashed przyniosło serii zwierzaki w 2002 roku i zgarnęło nagrodę dla symulacji roku na Interactive Achievement Awards.';

  @override
  String get triviaSims1Clown =>
      'Tragiczny Klaun zjawia się, żeby pocieszyć smutnego sima, który ma jego obraz. Jest w tym fatalny i na tym polega cały żart.';

  @override
  String get triviaSims1Llama =>
      'W oryginalnej drukowanej instrukcji znalazła się książka Making the Most of Your Llama. Nikt nigdy tego nie wyjaśnił.';

  @override
  String get triviaSims1Superstar =>
      'Superstar pozwalało simowi zostać aktorem, modelem albo piosenkarzem, ze wskaźnikiem sławy włącznie, jedenaście lat przed tym, jak The Sims 4 spróbowało sławy jeszcze raz.';

  @override
  String get triviaSims1Catalogue =>
      'Odbudowując dom po pożarze, Will Wright wciąż pytał sam siebie, które elementy domu są niezbędne, a które mogą poczekać. To pytanie to mniej więcej cały katalog trybu kupowania.';

  @override
  String get triviaSims2Aging =>
      'The Sims 2 było pierwszą częścią, w której simowie się starzeli, umierali ze starości i przekazywali genetykę. Oczy, nos i podbródek dziedziczy się po obojgu rodzicach.';

  @override
  String get triviaSims2Memories =>
      'Każdy sim nosi ukrytą listę wspomnień. Bycie świadkiem śmierci, pierwszego pocałunku albo awansu zostaje zapisane i wpływa później na nastrój.';

  @override
  String get triviaSims2Bella =>
      'Bella Goth znika z Pleasantview na samym początku gry, a przez dwadzieścia lat nikt oficjalnie nie wyjaśnił, co się stało.';

  @override
  String get triviaSims2Strangetown =>
      'Bella odnajduje się żywa w Strangetown, bez najmniejszego wspomnienia o Pleasantview. Maxis powiedziało, że obie Belle są prawdziwe, i na tym poprzestało.';

  @override
  String get triviaSims2FamilyTrees =>
      'Okolice w The Sims 2 stoją na prawdziwym drzewie genealogicznym: Pleasantview, Strangetown i Veronaville łączą małżeństwa i plotki.';

  @override
  String get triviaSims2Plead =>
      'Ponurego Żniwiarza można błagać. Zagadaj go w odpowiednim momencie, a może oddać ci sima, czasem w zamian za kogoś innego.';

  @override
  String get triviaSims2ReaperRomance =>
      'Ze Żniwiarzem można się związać. Rozegraj to dobrze, a z tego romansu wyjdzie duszek-niemowlę.';

  @override
  String get triviaSims2Satellite =>
      'Sim, który wpatruje się w gwiazdy, ma bardzo małą szansę oberwać spadającym satelitą. To jedna z najrzadszych śmierci w serii.';

  @override
  String get triviaSims2Therapist =>
      'Załamanie aspiracji wysyła sima do terapeuty, jeden z niewielu momentów, w których gra dla żartu łamie własną czwartą ścianę.';

  @override
  String get triviaSims2WantsFears =>
      'Pragnienia i lęki napędzają całą grę. Wskaźnik aspiracji reaguje na to, czego sim się bał, tak samo mocno jak na to, na co liczył.';

  @override
  String get triviaSims2FaceSculpt =>
      'Gra wyszła z pełnym systemem rzeźbienia twarzy i sylwetki i właśnie dlatego twarze z The Sims 2 do dziś wyglądają na bardziej zróżnicowane niż w późniejszych częściach.';

  @override
  String get triviaSims2Aliens =>
      'Porwanie przez kosmitów zdarza się tylko simom płci męskiej, którzy zbyt długo gapią się w gwiazdy, i tak, wracają w ciąży.';

  @override
  String get triviaSims2FreezerBunny =>
      'Freezer Bunny narysowała Emmy Toyonaga na potrzeby The Sims 2, a po raz pierwszy pojawił się schowany w zamrażarce na działce publicznej. Od tamtej pory jest przemycany do każdej odsłony.';

  @override
  String get triviaSims2SocialBunny =>
      'Towarzyski Królik zastąpił Tragicznego Klauna i, w przeciwieństwie do klauna, naprawdę działa. Sporo osób uznało tę sprawną wersję za jeszcze bardziej niepokojącą.';

  @override
  String get triviaSims2Giveaway =>
      'W lipcu 2014 EA rozdało Ultimate Collection za darmo przez Origin, do odebrania kodem I-LOVE-THE-SIMS. Przez kolejną dekadę, aż do Legacy Collection, ten prezent był jedyną legalną kopią w obiegu.';

  @override
  String get triviaSims3SunsetValley =>
      'Sunset Valley to Pleasantview z The Sims 2 jakieś 25 lat wcześniej, więc możesz poznać dziadków simów, którymi już grałeś.';

  @override
  String get triviaSims3Founders =>
      'Sunset Valley założyli Gothowie, a rozbudowali Landgraabowie. Możesz pokierować Mortimerem Gothem jako dzieckiem i zobaczyć, jak poznaje Bellę Bachelor.';

  @override
  String get triviaSims3OpenWorld =>
      'The Sims 3 zlikwidowało ekrany wczytywania w całości. Całe miasteczko symuluje się naraz, a każdy sim starzeje się i pracuje w tle.';

  @override
  String get triviaSims3Simulation =>
      'Wszyscy simowie w mieście są symulowani jednocześnie i dlatego długi zapis zaczyna zwalniać. Gra po cichu prowadzi życia, których nigdy nie spotkałeś.';

  @override
  String get triviaSims3CreateAStyle =>
      'Stwórz Styl pozwalał przemalować i przewzorzyć niemal dowolny obiekt. Funkcja była tak wymagająca, że nigdy nie wróciła.';

  @override
  String get triviaSims3Exchange =>
      'The Sims 3 miało prawdziwą wymianę online, w której gracze wymieniali się działkami, simami i wzorami prosto z launchera.';

  @override
  String get triviaSims3Downloads =>
      'Już w pierwszym tygodniu gracze pobrali z tego launchera ponad siedem milionów przedmiotów zrobionych przez społeczność.';

  @override
  String get triviaSims3Traits =>
      'Cechy zastąpiły stare suwaki osobowości, a niektóre z nich, jak Kleptoman i Szalony, po cichu łamią zasady zwyczajnego życia.';

  @override
  String get triviaSims3Kleptomaniac =>
      'Sim kleptoman wraca do domu z cudzymi meblami, nikt go o to nie prosi, i robi to dalej, dopóki tego nie zauważysz.';

  @override
  String get triviaSims3Simlish =>
      'Katy Perry, Lily Allen, Depeche Mode i dziesiątki innych artystów nagrali własne piosenki po simlijsku na potrzeby ścieżki dźwiękowej.';

  @override
  String get triviaSims3Townies =>
      'Ponieważ otwarty świat symulował też simów poza ekranem, regularnie okazywało się, że mieszkańcy pobrali się i doczekali dzieci zupełnie bez twojego udziału.';

  @override
  String get triviaSims3Store =>
      'Sims 3 Store sprzedał ostatecznie więcej obiektów, niż gra zawierała w dniu premiery.';

  @override
  String get triviaSims3Launch =>
      'The Sims 3 sprzedało 1,4 miliona egzemplarzy w pierwszym tygodniu, w czerwcu 2009, co było największą premierą pecetową w historii EA.';

  @override
  String get triviaSims4Flies =>
      'Śmierć od much jest prawdziwa. Zapuść działkę wystarczająco mocno, a rój wykończy twojego sima.';

  @override
  String get triviaSims4Emotions =>
      'Tutaj wszystkim rządzą emocje. Zainspirowany sim maluje lepiej, a wściekły potrafi umrzeć ze złości.';

  @override
  String get triviaSims4EmotionDeaths =>
      'Sim może umrzeć ze śmiechu, ze złości i ze wstydu. W tej części emocja nie jest ozdobą, tylko zagrożeniem.';

  @override
  String get triviaSims4CreateASim =>
      'Tworzenie sima zamieniło suwaki na ciągnięcie i pchanie twarzy bezpośrednio, i dlatego twarz w The Sims 4 robi się tak szybko.';

  @override
  String get triviaSims4Launch =>
      'The Sims 4 wyszło bez basenów i bez maluchów. Jedno i drugie wróciło za darmo, w łatce, po długim naciskaniu ze strony graczy.';

  @override
  String get triviaSims4Worlds =>
      'Willow Creek i Oasis Springs były w dniu premiery, we wrześniu 2014, jedynymi światami. Dziś są ich dziesiątki i prawie każdy przyszedł razem z pakietem.';

  @override
  String get triviaSims4Gender =>
      'Płeć odblokowano w pełni łatką z 2016 roku: każdy sim może nosić dowolne ubranie, mieć dowolny głos i zachodzić w ciążę albo nie.';

  @override
  String get triviaSims4Newcrest =>
      'Newcrest wyszło celowo zupełnie puste. Piętnaście działek, ani jednego budynku i otwarte zaproszenie dla społeczności, żeby to zapełniła.';

  @override
  String get triviaSims4Naming =>
      'Nazwy okolic w rodzaju Willow Creek czy Oasis Springs trzymają się zasady jeszcze ze starego Maxis: dwa proste angielskie słowa, żadnej wymyślonej pisowni.';

  @override
  String get triviaSims4Goths =>
      'Rodzina Goth jest i tutaj, co czyni ją jedną z najdłużej obecnych w grach, w każdej głównej odsłonie.';

  @override
  String get triviaSims4FreeToPlay =>
      'Podstawka stała się darmowa w październiku 2022, na PC, PlayStation i Xboksie naraz. Pakiety zostały płatne.';

  @override
  String get triviaSims4Mccc =>
      'MC Command Center, pierwszy mod, jaki prawie każdy instaluje w The Sims 4, przekroczył 14 milionów pobrań na samym CurseForge. Deaderpool aktualizuje go od 2015 roku.';

  @override
  String get triviaSims4Twallan =>
      'MCCC istnieje dzięki The Sims 3. Podnosi to, co zostawiły Master Controller i Story Progression Twallana, i przenosi ponad dziesięcioletni pomysł na nowy silnik.';

  @override
  String get triviaSims4Deaths =>
      'Sima może zabić krowoślin, automat z przekąskami, wieża stereo w kształcie lamy i śmiech. Nie wszystko naraz.';

  @override
  String get triviaMedievalWatcher =>
      'Tutaj nie jesteś gospodarstwem domowym, tylko Obserwatorem: życzliwym bóstwem, które popycha bohaterów po królestwie, zamiast prowadzić dzień jednej rodziny.';

  @override
  String get triviaMedievalHeroes =>
      'W królestwie mieści się do dziesięciu simów bohaterów w dziesięciu profesjach, a każdy pnie się od poziomu 1 do 10, zdobywając nowe zdolności i coraz bardziej dostojne tytuły.';

  @override
  String get triviaMedievalStocks =>
      'Każdy bohater budzi się z dwoma obowiązkami i terminem. Zbyt częste ich olewanie kończy się karą, a dotyczy to również monarchy, który może trafić pod pręgierz.';

  @override
  String get triviaMedievalAmbition =>
      'Przed startem wybierasz Ambicję dla całego królestwa, a przyjmowane zadania są punktowane właśnie względem niej. To najbliżej warunku zwycięstwa, jak The Sims kiedykolwiek było.';

  @override
  String get triviaMedievalQuests =>
      'To pełna konwersja, nie spin-off. Piaskownicę zastępuje ciąg zadań i właśnie dlatego jest to jedyna gra z The Sims, którą da się przejść do końca.';

  @override
  String get triviaMedievalPirates =>
      'Pirates and Nobles z sierpnia 2011 to jedyny dodatek, jaki kiedykolwiek dostała: sokoły i papugi, mapy skarbów i łopaty oraz wojna dwóch świeżo przybyłych frakcji.';

  @override
  String get triviaMedievalProxy =>
      'Gry nigdy nie budowano z myślą o modach. Mody skryptowe i rdzeniowe wymagają społecznościowego proxy d3dx9_31.dll wrzuconego do Game/Bin, zanim gra w ogóle je przeczyta, natomiast custom content działa i bez tego.';

  @override
  String get triviaMedievalEngine =>
      'Chodzi na silniku The Sims 3 i dlatego Resource.cfg oraz pliki .package wydają się tak znajome każdemu, kto modował tamtą grę.';
}
