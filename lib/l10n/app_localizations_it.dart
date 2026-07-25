// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class LIt extends L {
  LIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Sims Mod Manager';

  @override
  String get brandTitle => 'Mod Manager';

  @override
  String get brandSubtitle => 'per The Sims';

  @override
  String get navLibrary => 'Libreria';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get sidebarGames => 'GIOCHI';

  @override
  String sidebarNotInstalled(String detail) {
    return 'non installato · $detail';
  }

  @override
  String sidebarModCount(int count, String detail) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mod',
      one: '1 mod',
    );
    return '$_temp0 · $detail';
  }

  @override
  String get updateAvailable => 'Aggiornamento disponibile';

  @override
  String updateClickToDownload(String version) {
    return 'v$version: clicca per scaricare';
  }

  @override
  String get storage => 'Spazio';

  @override
  String storageInMods(String size) {
    return '$size di mod';
  }

  @override
  String storageFreeOf(String free, String total) {
    return '$free liberi su $total';
  }

  @override
  String dropToInstall(String game) {
    return 'Lascia qui per installare in $game';
  }

  @override
  String get dropFolders => 'cartelle';

  @override
  String scanningMods(int done, int total) {
    return 'Stiamo guardando dentro le mod, tra immagini e conflitti… $done di $total';
  }

  @override
  String get skip => 'Salta';

  @override
  String libraryTitle(String game) {
    return 'Libreria di $game';
  }

  @override
  String modsShown(int count, String era) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mod in vista',
      one: '1 mod in vista',
    );
    return '$_temp0 · $era';
  }

  @override
  String get learnMore => 'Scopri di più';

  @override
  String get dismiss => 'Chiudi';

  @override
  String get searchMods => 'Cerca mod…';

  @override
  String get install => 'Installa';

  @override
  String filePickerModsLabel(String game) {
    return 'Mod di $game';
  }

  @override
  String get statTotal => 'Totale';

  @override
  String get statEnabled => 'Attive';

  @override
  String get statDisabled => 'Disattive';

  @override
  String get statConflicts => 'Conflitti';

  @override
  String get conflictTooltipActive =>
      'Stai vedendo solo le mod in conflitto. Clicca per rivederle tutte.';

  @override
  String get conflictTooltip =>
      'Mod attive che hanno lo stesso nome file di un’altra mod attiva, che sono installate in più versioni, o che sovrascrivono le stesse risorse di gioco. Il gioco tiene solo la copia che carica per ultima — a volte è voluto (mod correttive), spesso no.';

  @override
  String get conflictTooltipClickHint => 'Clicca per vedere solo queste mod.';

  @override
  String get filterAll => 'Tutte';

  @override
  String get emptyFiltered => 'Nessuna mod corrisponde ai filtri';

  @override
  String get emptyNoMods => 'Ancora nessuna mod';

  @override
  String get emptyFilteredHint =>
      'Prova a cancellare la ricerca o a scegliere un altro filtro.';

  @override
  String emptyNoModsHint(String path) {
    return 'La cartella sotto osservazione è questa:\n$path';
  }

  @override
  String get openFolder => 'Apri cartella';

  @override
  String get conflictBadge => 'conflitto';

  @override
  String modInFolder(String folder) {
    return 'in $folder';
  }

  @override
  String get modInModsFolder => 'nella cartella Mods';

  @override
  String setupFoundNoModsFolder(String game) {
    return '$game c’è, ma non ha ancora una cartella mod';
  }

  @override
  String setupNotFound(String game) {
    return 'Cartella delle mod di $game non trovata';
  }

  @override
  String get setupFoundNoModsFolderBody =>
      'La cartella del gioco è su questo computer, solo che non contiene ancora una cartella per le mod. Creala qui sotto, oppure indicane una a mano.';

  @override
  String get setupNotFoundBody =>
      'Forse il gioco non è installato, forse si trova in un posto insolito, oppure la sua cartella delle mod non esiste ancora.';

  @override
  String get foundOnThisComputer => 'TROVATO SU QUESTO COMPUTER';

  @override
  String get chooseFolder => 'Scegli cartella…';

  @override
  String get createItForMe => 'Creala tu';

  @override
  String willBeCreatedAt(String path) {
    return 'Verrà creata in:\n$path';
  }

  @override
  String get checkAgain => 'Controlla di nuovo';

  @override
  String get useThis => 'Usa questa';

  @override
  String get enabled => 'Attiva';

  @override
  String get disabled => 'Disattiva';

  @override
  String get showInFileManager => 'Mostra nel gestore file';

  @override
  String get uninstallMod => 'Disinstalla la mod';

  @override
  String uninstallConfirmTitle(String title) {
    return 'Disinstallare $title?';
  }

  @override
  String uninstallConfirmBody(String path) {
    return 'Il file verrà eliminato dal disco:\n$path';
  }

  @override
  String get cancel => 'Annulla';

  @override
  String get uninstall => 'Disinstalla';

  @override
  String conflictSameNameHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Altre $count mod attive hanno lo stesso nome file:',
      one: 'Un’altra mod attiva ha lo stesso nome file:',
    );
    return '$_temp0';
  }

  @override
  String conflictVersionHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Altre $count mod attive sembrano versioni diverse di questa mod:',
      one: 'Un’altra mod attiva sembra una versione diversa di questa mod:',
    );
    return '$_temp0';
  }

  @override
  String conflictResourcesHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Altre $count mod attive sovrascrivono le stesse risorse di gioco:',
      one: 'Un’altra mod attiva sovrascrive le stesse risorse di gioco:',
    );
    return '$_temp0';
  }

  @override
  String sharedResources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risorse in comune',
      one: '1 risorsa in comune',
    );
    return '$_temp0';
  }

  @override
  String get conflictSameNameBody =>
      'Due nomi identici di solito vogliono dire che la stessa mod è installata due volte, o che i pacchetti di due creator si pestano i piedi. Il gioco carica le risorse che si sovrappongono in un ordine imprevedibile: tienine una e disattiva o elimina il resto.';

  @override
  String get conflictVersionBody =>
      'Avere più versioni della stessa mod installate fa sì che il gioco carichi le risorse che si sovrappongono in un ordine imprevedibile: tieni la più recente e disattiva o elimina le altre.';

  @override
  String get conflictResourcesBody =>
      'Questi pacchetti contengono risorse con gli stessi identificatori, quindi il gioco tiene solo la copia che carica per ultima. Può essere voluto — le mod correttive e gli override coprono di proposito le risorse di un’altra mod — ma tra mod che non c’entrano nulla significa che una delle due smette di funzionare senza dire niente: tieni quella che vuoi e disattiva le altre.';

  @override
  String modInDirectory(String dir) {
    return 'in $dir';
  }

  @override
  String get factVersion => 'Versione';

  @override
  String get factFormat => 'Formato';

  @override
  String get factSize => 'Dimensione';

  @override
  String get factType => 'Tipo';

  @override
  String get factModified => 'Modificata';

  @override
  String get statusHeading => 'Stato';

  @override
  String get statusEnabledBody =>
      'Questa mod è attiva: il gioco la caricherà al prossimo avvio.';

  @override
  String statusDisabledBody(String marker) {
    return 'Questa mod è disattivata: il file resta sul disco con il contrassegno «$marker» così il gioco lo salta. Puoi riattivarla quando vuoi, non viene eliminato niente.';
  }

  @override
  String get fileOnDisk => 'File sul disco';

  @override
  String get insideThePackage => 'Dentro il pacchetto';

  @override
  String resourcesTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risorse in tutto',
      one: '1 risorsa in tutto',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get sectionModManagement => 'GESTIONE DELLE MOD';

  @override
  String get sectionAppearance => 'ASPETTO';

  @override
  String get sectionLanguage => 'LINGUA';

  @override
  String get sectionPrivacy => 'PRIVACY';

  @override
  String sectionModsFolder(String game) {
    return 'CARTELLA MOD · $game';
  }

  @override
  String sectionGameCaches(String game) {
    return 'CACHE DEL GIOCO · $game';
  }

  @override
  String get sectionFeedback => 'FEEDBACK';

  @override
  String get sectionAbout => 'INFORMAZIONI';

  @override
  String get prefWarnConflictsTitle => 'Avvisa dei conflitti';

  @override
  String get prefWarnConflictsDesc =>
      'Segnala le mod attive che ripetono un nome file o che sovrascrivono le stesse risorse di gioco di un’altra mod';

  @override
  String get prefConfirmDeleteTitle => 'Chiedi conferma prima di disinstallare';

  @override
  String get prefConfirmDeleteDesc =>
      'Chiedi prima di eliminare dal disco il file di una mod';

  @override
  String get prefShowDisabledTitle => 'Mostra le mod disattivate';

  @override
  String get prefShowDisabledDesc =>
      'Tiene le mod disattivate visibili nella libreria invece di nasconderle';

  @override
  String get prefScanArtworkTitle => 'Analizza dentro le mod';

  @override
  String get prefScanArtworkDesc =>
      'Guarda dentro i file delle mod mentre la libreria carica, per tirarne fuori le immagini, capire cosa contengono e trovare le mod che sovrascrivono le stesse risorse';

  @override
  String get prefSoundEffectsTitle => 'Effetti sonori';

  @override
  String get prefSoundEffectsDesc =>
      'Riproduce i suoni classici dell’interfaccia di The Sims su clic, interruttori e avvisi';

  @override
  String get prefAnalyticsTitle => 'Condividi dati d’uso anonimi';

  @override
  String get prefAnalyticsDesc =>
      'Invia statistiche d’uso e segnalazioni di crash anonime per aiutare a migliorare l’app. Non include mai nomi di mod, percorsi di file o qualsiasi cosa personale';

  @override
  String get themeTitle => 'Tema';

  @override
  String get themeDesc =>
      'Chiaro o scuro. «Sistema» segue l’impostazione del tuo computer.';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get languageTitle => 'Lingua dell’app';

  @override
  String get languageDesc =>
      'Scegli in che lingua vedere l’app. «Sistema» segue la lingua del tuo computer.';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get folderNotFound => 'Non trovata. Scegli una cartella';

  @override
  String get folderNotLocated =>
      'Il gioco (o la sua cartella delle mod) non è stato trovato automaticamente';

  @override
  String folderSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mod',
      one: '1 mod',
    );
    return '$_temp0 · $size sul disco';
  }

  @override
  String get customFolder => 'cartella personalizzata';

  @override
  String get change => 'Cambia…';

  @override
  String get resetToAuto => 'Torna ad automatica';

  @override
  String createDefaultFolderAt(String path) {
    return 'Crea la cartella predefinita (con i file che servono al gioco) in:\n$path';
  }

  @override
  String get createFolder => 'Crea cartella';

  @override
  String get alsoFoundOnThisComputer => 'Trovate anche su questo computer:';

  @override
  String get clearCacheTitle => 'Svuota i file di cache';

  @override
  String clearCacheDesc(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Elimina $count file di cache ($size)',
      one: 'Elimina 1 file di cache ($size)',
    );
    return '$_temp0 così i contenuti appena aggiunti o rimossi si vedono; il gioco li ricostruisce al prossimo avvio';
  }

  @override
  String get clearCaches => 'Svuota la cache';

  @override
  String get reportBugTitle => 'Segnala un bug';

  @override
  String get reportBugDesc =>
      'Apre una segnalazione su GitHub con versione dell’app, sistema operativo e gioco attuale già compilati';

  @override
  String get reportBugButton => 'Segnala…';

  @override
  String get suggestFeatureTitle => 'Proponi una funzione';

  @override
  String get suggestFeatureDesc =>
      'Ti manca qualcosa? Dicci cosa renderebbe migliore il gestore di mod';

  @override
  String get suggestFeatureButton => 'Proponi…';

  @override
  String get wikiTitle => 'Guida e FAQ';

  @override
  String get wikiDesc =>
      'Come installare le mod, sistemare il rilevamento delle cartelle e altro ancora, sulla wiki del progetto';

  @override
  String get wikiButton => 'Apri la wiki';

  @override
  String aboutTagline(String version) {
    return 'Versione $version · The Sims 1-4 supportati · SimCity in arrivo';
  }

  @override
  String updateIsAvailable(String version) {
    return 'La versione $version è disponibile';
  }

  @override
  String get noUpdateFound => 'Nessun aggiornamento';

  @override
  String getVersion(String version) {
    return 'Scarica la v$version';
  }

  @override
  String get checkingForUpdates => 'Controllo…';

  @override
  String get checkForUpdates => 'Cerca aggiornamenti';

  @override
  String get categoryPackage => 'Pacchetto';

  @override
  String get categoryScript => 'Script';

  @override
  String get categoryObject => 'Oggetto';

  @override
  String get categoryArchive => 'Archivio';

  @override
  String get categorySkin => 'Skin';

  @override
  String get categoryTexture => 'Texture';

  @override
  String get categoryWall => 'Muro';

  @override
  String get categoryFloor => 'Pavimento';

  @override
  String get contentCasParts => 'elementi CAS';

  @override
  String get contentObjects => 'oggetti';

  @override
  String get contentTunings => 'tuning';

  @override
  String get contentBehaviors => 'comportamenti';

  @override
  String get contentTextTables => 'tabelle di testo';

  @override
  String get contentTextures => 'texture';

  @override
  String get contentMeshes => 'mesh';

  @override
  String get eraClassic => 'Classico';

  @override
  String get eraNightlife => 'Nightlife';

  @override
  String get eraAmbitions => 'Ambitions';

  @override
  String get eraModern => 'Moderno';

  @override
  String get eraMedieval => 'Medievale';

  @override
  String get setupHelpSims1 =>
      'Il primissimo The Sims tiene i contenuti personalizzati dentro la sua cartella di installazione, non in Documenti: gli oggetti vanno in una cartella Downloads accanto all’eseguibile del gioco (per esempio C:\\Program Files (x86)\\Maxis\\The Sims\\Downloads), e questa app smista gli altri tipi da sola — le skin (.skn/.cmx/.bmp) in GameData\\Skins, muri e pavimenti in GameData\\Walls e GameData\\Floors. La Legacy Collection del 2025 funziona allo stesso modo dalla sua cartella di installazione (EA Games\\The Sims Legacy, oppure Steam\\steamapps\\common\\The Sims Legacy Collection). Se il gioco è installato altrove (un altro disco, una libreria Steam personalizzata), scegli a mano la sua cartella Downloads.';

  @override
  String get setupHelpSims2 =>
      'The Sims 2 carica i contenuti personalizzati da Documenti > EA Games > The Sims 2 > Downloads (la Ultimate Collection usa «The Sims 2 Ultimate Collection», la Legacy Collection del 2025 usa «The Sims 2 Legacy»). La cartella potrebbe non esistere finché non la crei o non installi un contenuto la prima volta. All’avvio del gioco rispondi «Sì» alla richiesta sui contenuti personalizzati così i download sono abilitati.';

  @override
  String get setupHelpSims3 =>
      'The Sims 3 non crea la cartella delle mod da solo: gli serve il «framework» della community, cioè una cartella Mods > Packages dentro Documenti > Electronic Arts > The Sims 3, più un file Resource.cfg che dica al gioco di leggerla. Questa app può creare entrambi per te. Nelle installazioni da disco o con Wine la cartella può stare dentro il pacchetto del gioco; usa «Scegli cartella» per indicarla.';

  @override
  String get setupHelpSims4 =>
      'The Sims 4 carica le mod da Documenti > Electronic Arts > The Sims 4 > Mods. Il gioco crea questa cartella al primo avvio, quindi avvialo una volta se non c’è. Poi, dentro il gioco, attiva Opzioni > Opzioni di gioco > Altro > «Abilita contenuti personalizzati e mod» (e «Consenti mod script» per i file .ts4script) e riavvia il gioco.';

  @override
  String get setupHelpSimsMedieval =>
      'The Sims Medieval carica le mod dalla sua cartella di installazione, non da Documenti: una cartella Mods > Packages accanto ai file del gioco (per esempio C:\\Program Files (x86)\\Origin Games\\The Sims Medieval), più un file Resource.cfg nella cartella di installazione che dica al gioco di leggerla. Questa app può creare entrambi per te (sotto Programmi Windows potrebbe chiedere i permessi di amministratore). La cartella Documenti > Electronic Arts > The Sims Medieval contiene solo i salvataggi; le mod messe lì non fanno nulla. Per installazioni con Wine/CrossOver o una libreria Steam personalizzata, usa «Scegli cartella» e indica la cartella Mods > Packages dentro l’installazione.';
}
