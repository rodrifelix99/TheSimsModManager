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
  String get conflictTooltipActive =>
      'Widzisz tylko mody z konfliktami. Kliknij, żeby znów pokazać wszystkie.';

  @override
  String get conflictTooltip =>
      'Włączone mody, które mają tę samą nazwę pliku co inny włączony mod, są zainstalowane w kilku wersjach albo nadpisują te same zasoby gry. Gra zostawia tylko tę kopię, którą wczyta na końcu — czasem to celowe (mody-łatki), ale często nie.';

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
      'Te paczki zawierają zasoby o tych samych identyfikatorach, więc gra zostawi tylko tę kopię, którą wczyta na końcu. Czasem tak ma być — mody-łatki i override celowo przykrywają zasoby innego moda — ale przy modach, które nie mają ze sobą nic wspólnego, oznacza to, że jeden po cichu przestaje działać: zostaw ten, na którym ci zależy, a resztę wyłącz.';

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
  String get statusHeading => 'Status';

  @override
  String get statusEnabledBody =>
      'Ten mod jest włączony: gra wczyta go przy następnym uruchomieniu.';

  @override
  String statusDisabledBody(String marker) {
    return 'Ten mod jest wyłączony: plik zostaje na dysku z dopiskiem „$marker”, żeby gra go pominęła. Możesz włączyć go, kiedy chcesz — nic nie znika.';
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
      'Aplikacja mówi w dziesięciu językach dzięki tym simmerom.';

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
      'Jak instalować mody, naprawić wykrywanie folderów i więcej — na wiki projektu';

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
  String errorNoModFiles(String extensions, String name) {
    return 'W $name nie ma żadnych plików modów ($extensions).';
  }

  @override
  String errorUnreadableArchive(String name) {
    return '$name to nie jest archiwum zip, które aplikacja potrafi odczytać.';
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
    return '$name to świat, a nie zawartość niestandardowa. Zainstaluj go Launcherem The Sims 3 — gra trzyma światy poza folderem modów.';
  }

  @override
  String errorSims3PackLibrary(String name) {
    return '$name to działka albo rodzina, a nie zawartość niestandardowa. Zainstaluj to Launcherem The Sims 3 — trafi do twojej Biblioteki w grze.';
  }

  @override
  String errorInstallFailed(String name, String reason) {
    return 'Nie udało się zainstalować „$name” — $reason. Jeśli będzie się powtarzać, rozpakuj ręcznie i zainstaluj pliki ze środka.';
  }

  @override
  String errorInstallFailedRaw(String name, String reason) {
    return 'Nie udało się zainstalować „$name” — $reason';
  }

  @override
  String errorFileInUseDelete(String name) {
    return 'Nie udało się usunąć „$name” — plik jest używany przez inny program (gra jest włączona?) albo chroniony przed zapisem. Zamknij wszystko, co go używa, i spróbuj ponownie.';
  }

  @override
  String errorFileInUseRename(String name) {
    return 'Nie udało się zmienić nazwy „$name” — plik jest używany przez inny program (gra jest włączona?) albo chroniony przed zapisem. Zamknij wszystko, co go używa, i spróbuj ponownie.';
  }

  @override
  String errorFileMissing(String name) {
    return '„$name” nie ma już w folderze modów — możliwe, że inny program go przeniósł albo usunął.';
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
    return '$_temp0 siedzi w podfolderze, którego gra nie czyta. Schodzi tylko $levels foldery w głąb — przenieś je wyżej, to się wczytają.';
  }

  @override
  String get tooDeepShow => 'Pokaż je';

  @override
  String errorNoWriteAccess(String folder) {
    return 'Apka nie ma uprawnień do zapisu w „$folder”. System chroni ten folder — nadaj swojemu kontu prawo zapisu albo wskaż inny folder w Ustawieniach.';
  }

  @override
  String get folderReadOnlyBanner =>
      'Ten folder modów jest tylko do odczytu, więc instalowanie i usuwanie modów nie zadziała, dopóki twoje konto nie będzie mogło w nim zapisywać.';

  @override
  String get elevatedNoDropBanner =>
      'Działasz jako administrator, więc Windows nie pozwala przeciągać plików na okno. Skorzystaj z przycisku Zainstaluj — ten dalej działa.';

  @override
  String errorShopDownload(String name) {
    return '„$name” nie dał się pobrać z The Exchange. Sprawdź połączenie i spróbuj jeszcze raz.';
  }

  @override
  String get errorShopListingNotFound =>
      'Tego moda już nie ma na The Exchange. Mógł zostać zdjęty.';

  @override
  String get errorShopListingUnknownGame =>
      'Ten mod jest do gry, której ta wersja apki jeszcze nie zna. Spróbuj zaktualizować.';

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
  String get setupHelpSims1 =>
      'Pierwsze The Sims trzyma własną zawartość w folderze instalacji, a nie w Dokumentach: obiekty trafiają do folderu Downloads obok pliku wykonywalnego gry (na przykład C:\\Program Files (x86)\\Maxis\\The Sims\\Downloads), a resztę aplikacja sortuje sama — skórki (.skn/.cmx/.bmp) do GameData\\Skins, ściany i podłogi do GameData\\Walls i GameData\\Floors. Legacy Collection z 2025 działa tak samo ze swojego folderu instalacji (EA Games\\The Sims Legacy albo Steam\\steamapps\\common\\The Sims Legacy Collection). Jeśli gra siedzi gdzie indziej (inny dysk, własna biblioteka Steam), wskaż jej folder Downloads ręcznie.';

  @override
  String get setupHelpSims2 =>
      'The Sims 2 wczytuje własną zawartość z Dokumenty > EA Games > The Sims 2 > Downloads (Ultimate Collection używa „The Sims 2 Ultimate Collection”, a Legacy Collection z 2025 — „The Sims 2 Legacy”). Folder może nie istnieć, dopóki go nie utworzysz albo raz czegoś nie zainstalujesz. Przy starcie gry odpowiedz „Tak” na pytanie o własną zawartość, żeby pobrane rzeczy się włączyły.';

  @override
  String get setupHelpSims3 =>
      'The Sims 3 nie tworzy folderu na mody samo z siebie: potrzebuje społecznościowego „frameworku”, czyli folderu Mods > Packages w Dokumenty > Electronic Arts > The Sims 3 plus pliku Resource.cfg, który każe grze go czytać. Aplikacja utworzy oba za ciebie. Przy instalacji z płyty albo przez Wine folder może siedzieć w samej paczce gry; wtedy wskaż go przez „Wybierz folder”.';

  @override
  String get setupHelpSims4 =>
      'The Sims 4 wczytuje mody z Dokumenty > Electronic Arts > The Sims 4 > Mods. Gra tworzy ten folder przy pierwszym uruchomieniu, więc odpal ją raz, jeśli folderu nie ma. Potem w grze włącz Opcje > Opcje gry > Inne > „Włącz zawartość niestandardową i mody” (oraz „Zezwalaj na mody skryptowe” dla plików .ts4script) i uruchom grę ponownie.';

  @override
  String get setupHelpSimsMedieval =>
      'The Sims Medieval wczytuje mody z folderu instalacji, a nie z Dokumentów: folder Mods > Packages obok plików gry (na przykład C:\\Program Files (x86)\\Origin Games\\The Sims Medieval) plus plik Resource.cfg w folderze instalacji, który każe grze go czytać. Aplikacja utworzy oba za ciebie (w Program Files Windows może poprosić o uprawnienia administratora). Folder Dokumenty > Electronic Arts > The Sims Medieval trzyma tylko zapisy gry; mody wrzucone tam nic nie robią. Przy Wine/CrossOver albo własnej bibliotece Steam użyj „Wybierz folder” i wskaż folder Mods > Packages w instalacji.';
}
