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
  String get navShop => 'The Exchange';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get shopAlphaBadge => 'ALPHA';

  @override
  String get shopTagline => 'Mod dalla community, installate con un clic.';

  @override
  String shopListingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mod sugli scaffali',
      one: '1 mod sugli scaffali',
    );
    return '$_temp0';
  }

  @override
  String get shopRefresh => 'Aggiorna';

  @override
  String get shopPublish => 'Pubblica le tue mod';

  @override
  String get shopLoadFailedTitle => 'The Exchange non risponde';

  @override
  String get shopLoadFailedBody =>
      'Non siamo riusciti a caricare gli scaffali. Controlla la connessione e riprova.';

  @override
  String get shopRetry => 'Riprova';

  @override
  String get shopEmptyTitle => 'Gli scaffali sono ancora vuoti';

  @override
  String get shopEmptyBody =>
      'The Exchange ha appena aperto i battenti e nessuno ha ancora pubblicato niente. È nuovo di zecca. Crei mod? Inaugura tu gli scaffali!';

  @override
  String get shopAllGames => 'Tutti i giochi';

  @override
  String get shopShowAllGames => 'Mostra tutti i giochi';

  @override
  String shopEmptyGameTitle(String game) {
    return 'Ancora niente per $game';
  }

  @override
  String shopEmptyGameBody(String game) {
    return 'Altri giochi hanno già mod sugli scaffali, ma per $game non ha ancora pubblicato nessuno. Ne hai una? Tocca a te inaugurare lo scaffale!';
  }

  @override
  String shopBy(String author) {
    return 'di $author';
  }

  @override
  String get shopInstalled => 'Installata';

  @override
  String get shopUpdate => 'Aggiorna';

  @override
  String get shopUpdateBadge => 'aggiornamento';

  @override
  String shopUpdatesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count delle tue mod hanno una nuova versione su The Exchange',
      one: '1 delle tue mod ha una nuova versione su The Exchange',
    );
    return '$_temp0';
  }

  @override
  String get shopUpdateHeading => 'C’è una nuova versione di questa mod';

  @override
  String shopUpdateBody(String version, String author) {
    return '$author ha pubblicato la v$version su The Exchange. Aggiornando sostituisci i file che hai adesso.';
  }

  @override
  String get shopUpdateSeeListing => 'Vedi la scheda';

  @override
  String get shopInstalling => 'Installazione…';

  @override
  String get shopInstallNotes => 'Note di installazione';

  @override
  String get shopCreatorNudge =>
      'Crei mod? Pubblicare su The Exchange è gratis, e i giocatori installano il tuo lavoro con un clic.';

  @override
  String shopNeedsFolder(String game) {
    return 'Prima configura la cartella dei mod di $game. La scheda Libreria ti guida passo passo.';
  }

  @override
  String shopVariations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count varianti',
      one: '1 variante',
    );
    return '$_temp0';
  }

  @override
  String get shopSaveFile => 'Scarica';

  @override
  String get shopSaving => 'Download in corso…';

  @override
  String get shopSaved => 'Salvato';

  @override
  String get shopSaveHint =>
      'Installa mette i file dritti nella tua cartella mod. Scarica salva solo il file, dove vuoi tu.';

  @override
  String get shopVariationPick => 'Scegli una variante';

  @override
  String get shopBack => 'Torna agli scaffali';

  @override
  String get shopCopyLink => 'Copia link';

  @override
  String get shopLinkCopied => 'Link copiato';

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
  String get viewGrid => 'Griglia';

  @override
  String get viewList => 'Elenco';

  @override
  String get viewFolders => 'Cartelle';

  @override
  String get sortTooltip => 'Ordina';

  @override
  String get sortByName => 'Nome (A–Z)';

  @override
  String get sortByRecent => 'Modificate di recente';

  @override
  String get sortBySize => 'Prima le più grandi';

  @override
  String get sortDisabledLast => 'Le disattivate in fondo';

  @override
  String get libraryRefresh => 'Aggiorna';

  @override
  String get libraryRootFolder => 'Cartella Mods';

  @override
  String get selectionTooltip => 'Seleziona';

  @override
  String selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selezionate',
      one: '1 selezionata',
    );
    return '$_temp0';
  }

  @override
  String get selectionSelectAll => 'Seleziona tutto';

  @override
  String get selectionClear => 'Deseleziona';

  @override
  String get selectionEnable => 'Attiva';

  @override
  String get selectionDisable => 'Disattiva';

  @override
  String selectionProgress(int done, int total) {
    return '$done di $total';
  }

  @override
  String selectionDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Disinstallare $count mod?',
      one: 'Disinstallare 1 mod?',
    );
    return '$_temp0';
  }

  @override
  String selectionDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tutti i $count file verranno eliminati dal disco. Non si torna indietro.',
      one: 'Il file verrà eliminato dal disco. Non si torna indietro.',
    );
    return '$_temp0';
  }

  @override
  String get selectionMove => 'Sposta in…';

  @override
  String get newFolder => 'Nuova cartella';

  @override
  String newFolderIn(String folder) {
    return 'Dentro $folder';
  }

  @override
  String get newFolderHint => 'Nome della cartella';

  @override
  String get create => 'Crea';

  @override
  String get move => 'Sposta';

  @override
  String moveTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dove sposto $count mod?',
      one: 'Dove sposto 1 mod?',
    );
    return '$_temp0';
  }

  @override
  String get moveBody =>
      'I file cambiano cartella sul disco. Non cambia nient’altro: quello che è disattivato resta disattivato.';

  @override
  String get folderEmptySection => 'Qui non c’è ancora niente';

  @override
  String get install => 'Installa';

  @override
  String filePickerModsLabel(String game) {
    return 'Mod di $game';
  }

  @override
  String get installWhereTitle => 'Dove deve andare?';

  @override
  String installWhereBody(String game) {
    return '$game legge le mod da più cartelle. L’app può capirlo dal file, oppure glielo dici tu.';
  }

  @override
  String get installWhereSorted => 'Decidi tu';

  @override
  String get installWhereSortedDesc =>
      'Segue le cartelle che arrivano nel download e sistema il resto per tipo di file.';

  @override
  String get installWhereRemember => 'Non chiedere più';

  @override
  String get destinationSims1Downloads =>
      'Oggetti, hack e quasi tutti i download.';

  @override
  String get destinationSims1Global =>
      'Modifiche che cambiano tutto il gioco base.';

  @override
  String get destinationSims1Objects =>
      'Modifiche ai file degli oggetti del gioco stesso.';

  @override
  String get destinationSims1Skins =>
      'Pelli e teste di tutti i giorni. Compaiono in Crea un Sim.';

  @override
  String get destinationSims1SkinsBuy =>
      'Vestiti in vendita nei negozi dei lotti comunitari.';

  @override
  String get destinationSims1Walls => 'Rivestimenti per pareti.';

  @override
  String get destinationSims1Floors => 'Pavimenti.';

  @override
  String get destinationSims1Roofs => 'Texture per i tetti.';

  @override
  String get prefAskWhereTitle => 'Chiedi dove installare';

  @override
  String get prefAskWhereDesc =>
      'Questo gioco legge le mod da più di una cartella. Scegli la cartella ogni volta invece di lasciar decidere all’app';

  @override
  String get statTotal => 'Totale';

  @override
  String get statEnabled => 'Attive';

  @override
  String get statDisabled => 'Disattive';

  @override
  String get statConflicts => 'Conflitti';

  @override
  String get statTotalTooltip =>
      'Tutte le mod in questa cartella, attive o no.';

  @override
  String get statTotalTooltipClear =>
      'Tutte le mod in questa cartella. Clicca per togliere ricerca e filtri.';

  @override
  String get statEnabledTooltip => 'Le mod che il gioco carica.';

  @override
  String get statEnabledTooltipActive =>
      'Stai vedendo solo le mod attive. Clicca per rivederle tutte.';

  @override
  String get statDisabledTooltip =>
      'Mod che stanno nella cartella ma sono spente.';

  @override
  String get statDisabledTooltipActive =>
      'Stai vedendo solo le mod disattive. Clicca per rivederle tutte.';

  @override
  String get conflictTooltipActive =>
      'Stai vedendo solo le mod in conflitto. Clicca per rivederle tutte.';

  @override
  String get conflictTooltip =>
      'Mod attive che hanno lo stesso nome file di un’altra mod attiva, che sono installate in più versioni, o che sovrascrivono le stesse risorse di gioco. Il gioco tiene solo la copia che carica per ultima: a volte è voluto (mod correttive), spesso no.';

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
      'Questi pacchetti contengono risorse con gli stessi identificatori, quindi il gioco tiene solo la copia che carica per ultima. Può essere voluto (le mod correttive e gli override coprono di proposito le risorse di un’altra mod), ma tra mod che non c’entrano nulla significa che una delle due smette di funzionare senza dire niente: tieni quella che vuoi e disattiva le altre.';

  @override
  String get conflictIgnore => 'Ignora';

  @override
  String get conflictIgnoreTooltip =>
      'Se questo conflitto è voluto, nascondilo. La mod non cambia in nulla, e puoi rimettere l\'avviso da questa pagina o dalle impostazioni.';

  @override
  String get conflictRestore => 'Rimetti';

  @override
  String advisoryBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dei tuoi mod hanno problemi noti',
      one: 'Uno dei tuoi mod ha un problema noto',
    );
    return '$_temp0';
  }

  @override
  String get advisoryShow => 'Dai un\'occhiata';

  @override
  String get advisoryShowAll => 'Mostra tutti i mod';

  @override
  String get advisoryBadge => 'problema';

  @override
  String get advisoryBrokenHeading => 'Questo mod è segnalato come rotto';

  @override
  String get advisoryBrokenBody =>
      'Altri giocatori segnalano che questo manda in crash il gioco. Disattivarlo è il modo più veloce per capire se è lui il colpevole.';

  @override
  String get advisoryOutdatedHeading =>
      'C\'è una versione più recente di questo mod';

  @override
  String get advisoryOutdatedBody =>
      'La versione che hai è proprio quella che dà problemi. Scaricare l\'ultima del creator dovrebbe sistemare tutto.';

  @override
  String get advisoryCautionHeading => 'Da tenere d\'occhio';

  @override
  String get advisoryCautionBody =>
      'Per la maggior parte funziona, ma ogni tanto fa i capricci. Vale la pena disattivarlo se stai cercando un problema.';

  @override
  String advisorySince(String since) {
    return 'Da $since';
  }

  @override
  String get advisoryOpenLink => 'Apri la pagina del creator';

  @override
  String get advisorySource => 'Segnalato da altri giocatori, non dal gioco.';

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
  String get factDownloads => 'Download';

  @override
  String get factIgnoredConflicts => 'Ignorati';

  @override
  String ignoredConflictsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conflitti',
      one: '1 conflitto',
    );
    return '$_temp0';
  }

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
  String sectionIgnoredConflicts(String game) {
    return 'CONFLITTI IGNORATI · $game';
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
  String get prefDisabledSuffixTitle => 'Marcatore delle mod disattivate';

  @override
  String get prefDisabledSuffixDesc =>
      'Quello che viene aggiunto al nome del file quando disattivi una mod. Cambialo per farlo combaciare con un altro gestore (CC Magic usa .off); l’app legge comunque entrambi, e le mod già disattivate tengono il nome che hanno';

  @override
  String get prefDisabledSuffixInvalid =>
      'Serve un punto e qualche lettera o numero, tipo .off';

  @override
  String get prefExperimentalPacksTitle =>
      'Interruttori pacchetti sperimentali';

  @override
  String get prefExperimentalPacksDesc =>
      'Permette di disattivare i pacchetti di questo gioco. Non provato su questa edizione, e un vicinato giocato con un pacchetto può rompersi senza: fai prima una copia dei salvataggi';

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
  String get translatorsTitle => 'Tradotto da';

  @override
  String get translatorsDesc =>
      'L’app parla undici lingue grazie a questi simmer.';

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
  String get ignoredConflictsTitle => 'Conflitti che stai ignorando';

  @override
  String ignoredConflictsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count conflitti che hai detto all\'app di non segnalare più. Rimettili per rivederli nella libreria',
      one:
          'Un conflitto che hai detto all\'app di non segnalare più. Rimettilo per rivederlo nella libreria',
    );
    return '$_temp0';
  }

  @override
  String get ignoredConflictsReset => 'Rimettili tutti';

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
  String errorNoModFiles(String extensions, String name) {
    return 'Nessun file di mod ($extensions) dentro $name.';
  }

  @override
  String errorUnreadableArchive(String name) {
    return '$name non è un archivio zip che l’app riesca a leggere.';
  }

  @override
  String errorNoUnpacker(String format, String name) {
    return 'Su questo computer non c’è niente che sappia aprire gli archivi $format. Estrai $name per conto tuo e installa i file che ci sono dentro.';
  }

  @override
  String errorNoUnpackerLinux(String format, String name) {
    return 'Su questo computer non c’è niente che sappia aprire gli archivi $format. Installa p7zip e riprova, oppure estrai $name per conto tuo e installa i file che ci sono dentro.';
  }

  @override
  String errorNoUnpackerLinuxRar(String format, String name) {
    return 'Su questo computer non c’è niente che sappia aprire gli archivi $format. Installa p7zip o unrar e riprova, oppure estrai $name per conto tuo e installa i file che ci sono dentro.';
  }

  @override
  String errorUnpackFailed(String name) {
    return 'Non è stato possibile estrarre $name. Potrebbe avere una password, essere una parte di un archivio diviso o un download danneggiato. Estrailo a mano e installa i file che ci sono dentro.';
  }

  @override
  String errorSims3PackUnreadable(String name) {
    return '$name non è un pacchetto di The Sims 3 che questa app riesca a leggere.';
  }

  @override
  String errorSims3PackWorld(String name) {
    return '$name è un mondo, non contenuto personalizzato. Installalo con il Launcher di The Sims 3: il gioco tiene i mondi fuori dalla cartella delle mod.';
  }

  @override
  String errorSims3PackLibrary(String name) {
    return '$name è un lotto o una famiglia, non contenuto personalizzato. Installalo con il Launcher di The Sims 3: finisce nella tua Libreria nel gioco.';
  }

  @override
  String errorInstallFailed(String name, String reason) {
    return 'Non è stato possibile installare «$name»: $reason. Se continua a non funzionare, estrailo a mano e installa i file che ci sono dentro.';
  }

  @override
  String errorInstallFailedRaw(String name, String reason) {
    return 'Non è stato possibile installare «$name»: $reason';
  }

  @override
  String errorFileInUseDelete(String name) {
    return 'Non è stato possibile eliminare «$name»: lo sta usando un altro programma (il gioco è aperto?) oppure è protetto da scrittura. Chiudi quello che lo sta usando e riprova.';
  }

  @override
  String errorFileInUseRename(String name) {
    return 'Non è stato possibile rinominare «$name»: lo sta usando un altro programma (il gioco è aperto?) oppure è protetto da scrittura. Chiudi quello che lo sta usando e riprova.';
  }

  @override
  String errorFileNameTaken(String name) {
    return 'In quella cartella c’è già un “$name”. Rinomina uno dei due e riprova.';
  }

  @override
  String errorFolderNameBad(String name) {
    return '“$name” non va bene come nome di cartella. Provane uno senza barre e senza caratteri che il sistema tiene per sé.';
  }

  @override
  String errorFolderTooDeep(int levels) {
    return 'Il gioco guarda solo $levels cartelle in profondità dentro la cartella delle mod, quindi nulla di più in basso verrebbe caricato.';
  }

  @override
  String errorBulkMoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mod non si sono potute spostare',
      one: '1 mod non si è potuta spostare',
    );
    return '$_temp0 - forse le sta usando un altro programma (il gioco è aperto?), sono protette da scrittura, o nella cartella c’è già un file con lo stesso nome.';
  }

  @override
  String errorBulkToggleFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mod non si sono potute cambiare',
      one: '1 mod non si è potuta cambiare',
    );
    return '$_temp0 - forse le sta usando un altro programma (il gioco è aperto?) o sono protette da scrittura.';
  }

  @override
  String errorBulkRemoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mod non si sono potute eliminare',
      one: '1 mod non si è potuta eliminare',
    );
    return '$_temp0 - forse le sta usando un altro programma (il gioco è aperto?) o sono protette da scrittura.';
  }

  @override
  String errorFileMissing(String name) {
    return '«$name» non è più nella cartella dei mod: forse un altro programma l’ha spostato o eliminato.';
  }

  @override
  String get requirementMedievalModLoader =>
      'The Sims Medieval non può eseguire mod di script o core senza il file loader della community nella cartella Game\\Bin del gioco. I contenuti personalizzati funzionano lo stesso, il resto no.';

  @override
  String get requirementSims4ModsOff =>
      'Il gioco ha contenuti personalizzati e mod disattivati nelle sue Opzioni di gioco, quindi non sta caricando niente. Riattivali da Opzioni → Opzioni di gioco → Altro e riavvia il gioco.';

  @override
  String get requirementSims4ScriptModsOff =>
      'Qui hai delle mod di script, ma il gioco ha «Consenti mod di script» disattivato nelle Opzioni di gioco. Gli aggiornamenti lo resettano.';

  @override
  String get requirementGetFile => 'Dove trovarlo';

  @override
  String tooDeepBanner(int count, int levels) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ci sono $count mod',
      one: 'C’è una mod',
    );
    return '$_temp0 in una sottocartella che il gioco non legge. Scende solo di $levels cartelle: spostale più in alto e funzioneranno.';
  }

  @override
  String get tooDeepShow => 'Fammi vedere';

  @override
  String get duplicatesFind => 'Trova i mod doppioni';

  @override
  String duplicatesScanning(int done, int total) {
    return 'Sto leggendo i mod che potrebbero essere doppioni… $done di $total';
  }

  @override
  String get duplicatesStop => 'Ferma';

  @override
  String duplicatesBanner(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mod sono lo stesso identico file di un altro',
      one: 'Un mod è lo stesso identico file di un altro',
    );
    return '$_temp0 - sono $size che ti riprendi.';
  }

  @override
  String get duplicatesShow => 'Mostrameli';

  @override
  String get duplicatesSelectExtras => 'Spunta le copie in più';

  @override
  String get duplicatesClean => 'Qui non c’è niente di doppio.';

  @override
  String get duplicatesDismiss => 'Ok';

  @override
  String tagTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tag di $count mod',
      one: 'Tag di questo mod',
    );
    return '$_temp0';
  }

  @override
  String get tagBody =>
      'I tuoi tag, per ritrovare le cose dopo. Toccane uno per metterlo o toglierlo.';

  @override
  String get tagHint => 'Nuovo tag';

  @override
  String get tagAdd => 'Aggiungi';

  @override
  String get tagDone => 'Fatto';

  @override
  String get tagHeading => 'Tag';

  @override
  String get tagAddFirst => 'Aggiungi un tag';

  @override
  String tagRemove(String tag) {
    return 'Togli «$tag»';
  }

  @override
  String get selectionTag => 'Tagga…';

  @override
  String folderAlsoReading(String folders) {
    return 'Il tuo gioco legge anche $folders, quindi i mod che stanno lì sono in questa libreria pure loro.';
  }

  @override
  String errorNoWriteAccess(String folder) {
    return 'L’app non ha il permesso di scrivere in «$folder». Il sistema protegge quella cartella: dai al tuo account l’accesso in scrittura, o scegli un’altra cartella nelle Impostazioni.';
  }

  @override
  String get folderReadOnlyBanner =>
      'Questa cartella dei mod è di sola lettura, quindi installare e rimuovere mod non funzionerà finché il tuo account non potrà scriverci.';

  @override
  String get elevatedNoDropBanner =>
      'Stai eseguendo come amministratore, quindi Windows non ti fa trascinare i file sulla finestra. Usa il pulsante Installa: quello funziona ancora.';

  @override
  String errorShopDownload(String name) {
    return '«$name» non si è scaricata da The Exchange. Controlla la connessione e riprova.';
  }

  @override
  String errorShopNoModFiles(String name) {
    return 'Dentro “$name” non c’è niente che questo gioco possa installare. Forse non è nemmeno una mod - usa Scarica per salvare il file dove vuoi tu.';
  }

  @override
  String get errorShopListingNotFound =>
      'Quella mod non è più su The Exchange. Forse è stata tolta.';

  @override
  String get errorShopListingUnknownGame =>
      'Quella mod è per un gioco che questa versione dell’app non conosce ancora. Prova ad aggiornare.';

  @override
  String errorPackToggleFailed(String pack) {
    return 'Non sono riuscito a cambiare $pack. Chiudi il gioco e riprova.';
  }

  @override
  String get errorPackNoUserData =>
      'Non trovo la cartella delle impostazioni del gioco, quindi non c’è dove segnare quali pacchetti saltare. Avvia il gioco una volta prima.';

  @override
  String get errorPackNeedsAdmin =>
      'Windows non ha lasciato che l’app lo cambiasse. Riavviala come amministratore e riprova.';

  @override
  String get errorPackNotSupported =>
      'Su questo sistema i pacchetti non si possono attivare o disattivare.';

  @override
  String get errorPackIsTheGame =>
      'Quello è il pacchetto da cui parte il gioco, quindi deve restare attivo.';

  @override
  String get errorPackToggleRefused =>
      'Non sono riuscito a cambiare quel pacchetto. Chiudi il gioco e riprova.';

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
  String get navPacks => 'Pacchetti';

  @override
  String get packsScanning => 'Sto cercando i tuoi pacchetti…';

  @override
  String get packsEmptyTitle => 'Nessun pacchetto trovato';

  @override
  String packsEmptyBody(String game) {
    return 'O $game non è installato dove l’app riesce a vederlo, oppure non ci sono ancora pacchetti accanto.';
  }

  @override
  String get packsRescan => 'Controlla di nuovo';

  @override
  String packsSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pacchetti installati',
      one: '1 pacchetto installato',
    );
    return '$_temp0';
  }

  @override
  String packsSummaryWithOff(int count, int off) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pacchetti attivi',
      one: '1 pacchetto attivo',
    );
    return '$_temp0, $off disattivati';
  }

  @override
  String get packsOff => 'Disattivato';

  @override
  String get packsInstalled => 'Installato';

  @override
  String get packsNeedAdmin =>
      'Attivare e disattivare questi pacchetti richiede i permessi di amministratore, perché è lì che il gioco tiene il suo elenco. Riavvia l’app come amministratore per cambiarli: intanto il trascinamento smette di funzionare, quindi conviene tornare indietro dopo.';

  @override
  String get packsExperimentalTitle => 'Disattivarli è sperimentale';

  @override
  String get packsExperimentalOff =>
      'Funziona come ha sempre funzionato su questo gioco, ma nessuno l’ha provato su questa edizione, e un vicinato con cui hai giocato con un pacchetto può rompersi se lo apri senza. Vederli non fa danni. Attiva gli interruttori sperimentali nelle Impostazioni se vuoi provarci lo stesso.';

  @override
  String get packsExperimentalOn =>
      'Fai prima una copia dei tuoi vicinati. Un vicinato con cui hai giocato con un pacchetto può rompersi se lo apri senza, e da qui non si torna indietro: riattivare il pacchetto non sempre recupera il salvataggio.';

  @override
  String packsRestartNotice(String game) {
    return 'Riavvia $game perché abbia effetto. I tuoi pacchetti restano installati comunque.';
  }

  @override
  String packsAllOwnedSims4(String expansions, String gamePacks) {
    return '$expansions espansioni. $gamePacks game pack. Comprati tutti, certo.';
  }

  @override
  String get packKindExpansions => 'Espansioni';

  @override
  String get packKindGamePacks => 'Game Pack';

  @override
  String get packKindStuffPacks => 'Stuff Pack';

  @override
  String get packKindKits => 'Kit';

  @override
  String get packKindFreePacks => 'Pacchetti gratuiti';

  @override
  String get navSaves => 'Salvataggi';

  @override
  String get savesScanning => 'Lettura dei tuoi salvataggi…';

  @override
  String get savesEmptyTitle => 'Nessun salvataggio trovato';

  @override
  String savesEmptyBody(String game) {
    return 'Quando giochi a $game e salvi, i tuoi mondi compaiono qui: famiglie, foto e tutto il resto.';
  }

  @override
  String get savesRescan => 'Cerca di nuovo';

  @override
  String savesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count salvataggi trovati',
      one: '1 salvataggio trovato',
    );
    return '$_temp0';
  }

  @override
  String savesLastSaved(String date) {
    return 'Ultimo salvataggio: $date';
  }

  @override
  String get savesShowInFolder => 'Mostra nella cartella';

  @override
  String savesBackups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count backup',
      one: '1 backup',
    );
    return '$_temp0';
  }

  @override
  String get savesTabHouseholds => 'Famiglie';

  @override
  String get savesTabAlbum => 'Album fotografico';

  @override
  String get savesTabStats => 'Statistiche';

  @override
  String savesNeighborhood(int number) {
    return 'Quartiere $number';
  }

  @override
  String get savesOtherHouseholds => 'PNG e altre famiglie';

  @override
  String savesSimCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sim',
      one: '1 Sim',
    );
    return '$_temp0';
  }

  @override
  String get savesFunds => 'Fondi';

  @override
  String get savesRooms => 'Stanze';

  @override
  String savesBedsBaths(int beds, int baths) {
    return '$beds camere · $baths bagni';
  }

  @override
  String savesByCreator(String name) {
    return 'di $name';
  }

  @override
  String get savesMembers => 'Membri';

  @override
  String get savesRelationships => 'Relazioni';

  @override
  String get savesUnknownSim => 'Sim sconosciuto';

  @override
  String get savesStatSims => 'Sim';

  @override
  String get savesStatHouseholds => 'Famiglie';

  @override
  String get savesStatNetWorth => 'Patrimonio';

  @override
  String get savesStatWorlds => 'Mondi';

  @override
  String get savesStatPhotos => 'Foto';

  @override
  String savesAcrossHouseholds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'in $count famiglie',
      one: 'in 1 famiglia',
    );
    return '$_temp0';
  }

  @override
  String savesPlayedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giocate',
      one: '1 giocata',
    );
    return '$_temp0';
  }

  @override
  String get savesSizeOnDisk => 'Spazio su disco';

  @override
  String get savesLifeStages => 'Fasi della vita';

  @override
  String get savesTopSkills => 'Abilità più alte in questo salvataggio';

  @override
  String get savesSaveInfo => 'File di salvataggio';

  @override
  String get savesLastSavedLabel => 'Ultimo salvataggio';

  @override
  String get savesGameVersion => 'Versione del gioco';

  @override
  String get savesDescription => 'Descrizione';

  @override
  String get savesAgeInfant => 'Neonato';

  @override
  String get savesAgeBaby => 'Bebè';

  @override
  String get savesAgeToddler => 'Bimbo';

  @override
  String get savesAgeChild => 'Bambino';

  @override
  String get savesAgeTeen => 'Adolescente';

  @override
  String get savesAgeYoungAdult => 'Giovane adulto';

  @override
  String get savesAgeAdult => 'Adulto';

  @override
  String get savesAgeElder => 'Anziano';

  @override
  String get savesGenderMale => 'Maschio';

  @override
  String get savesGenderFemale => 'Femmina';

  @override
  String get savesSkillCooking => 'Cucina';

  @override
  String get savesSkillMechanical => 'Meccanica';

  @override
  String get savesSkillCharisma => 'Carisma';

  @override
  String get savesSkillBody => 'Corpo';

  @override
  String get savesSkillLogic => 'Logica';

  @override
  String get savesSkillCreativity => 'Creatività';

  @override
  String get savesSkillCleaning => 'Pulizia';

  @override
  String get savesPersonalityNeat => 'Ordinato';

  @override
  String get savesPersonalityOutgoing => 'Estroverso';

  @override
  String get savesPersonalityActive => 'Attivo';

  @override
  String get savesPersonalityPlayful => 'Giocherellone';

  @override
  String get savesPersonalityNice => 'Gentile';

  @override
  String get savesZodiacAries => 'Ariete';

  @override
  String get savesZodiacTaurus => 'Toro';

  @override
  String get savesZodiacGemini => 'Gemelli';

  @override
  String get savesZodiacCancer => 'Cancro';

  @override
  String get savesZodiacLeo => 'Leone';

  @override
  String get savesZodiacVirgo => 'Vergine';

  @override
  String get savesZodiacLibra => 'Bilancia';

  @override
  String get savesZodiacScorpio => 'Scorpione';

  @override
  String get savesZodiacSagittarius => 'Sagittario';

  @override
  String get savesZodiacCapricorn => 'Capricorno';

  @override
  String get savesZodiacAquarius => 'Acquario';

  @override
  String get savesZodiacPisces => 'Pesci';

  @override
  String get savesAspirationRomance => 'Romanticismo';

  @override
  String get savesAspirationFamily => 'Famiglia';

  @override
  String get savesAspirationFortune => 'Fortuna';

  @override
  String get savesAspirationPopularity => 'Popolarità';

  @override
  String get savesAspirationKnowledge => 'Conoscenza';

  @override
  String get savesAspirationGrowUp => 'Crescita';

  @override
  String get savesAspirationPleasure => 'Piacere';

  @override
  String get savesAspirationGrilledCheese => 'Toast al formaggio';

  @override
  String get savesRelCrush => 'cotta';

  @override
  String get savesRelLove => 'innamorati';

  @override
  String get savesRelEngaged => 'fidanzati';

  @override
  String get savesRelMarried => 'sposati';

  @override
  String get savesRelFriends => 'amici';

  @override
  String get savesRelBestFriends => 'migliori amici';

  @override
  String get savesRelSteady => 'coppia fissa';

  @override
  String get savesRelEnemies => 'nemici';

  @override
  String get savesPhotoFamilyPortrait => 'Ritratto di famiglia';

  @override
  String get savesPhotoLot => 'Lotto';

  @override
  String get savesPhotoSim => 'Ritratto di Sim';

  @override
  String get savesPhotoSnapshot => 'Istantanea';

  @override
  String get savesProperty => 'Patrimonio';

  @override
  String get savesGhost => 'fantasma';

  @override
  String savesCareerLevel(String career, int level) {
    return '$career · livello $level';
  }

  @override
  String get savesSpeciesLargeDog => 'cane';

  @override
  String get savesSpeciesSmallDog => 'cane piccolo';

  @override
  String get savesSpeciesCat => 'gatto';

  @override
  String get savesOccultVampire => 'vampiro';

  @override
  String get savesOccultZombie => 'zombie';

  @override
  String get savesOccultWerewolf => 'licantropo';

  @override
  String get savesOccultPlantSim => 'PlantSim';

  @override
  String get savesOccultAlien => 'alieno';

  @override
  String get savesOccultServo => 'servo';

  @override
  String get savesOccultWitch => 'strega';

  @override
  String get savesOccultBigfoot => 'Bigfoot';

  @override
  String get savesOccultFairy => 'fata';

  @override
  String get savesOccultGenie => 'genio';

  @override
  String get savesOccultMermaid => 'sirena';

  @override
  String get savesLotResidential => 'Residenziale';

  @override
  String get savesLotCommunity => 'Lotto comunitario';

  @override
  String get savesLotDorm => 'Dormitorio';

  @override
  String get savesLotSecretSociety => 'Società segreta';

  @override
  String get savesLotGreekHouse => 'Casa greca';

  @override
  String get savesLotHotel => 'Hotel';

  @override
  String get savesLotSecret => 'Lotto segreto';

  @override
  String get savesLotBusiness => 'Attività';

  @override
  String get savesLotApartment => 'Appartamento';

  @override
  String savesGpa(String gpa) {
    return 'media $gpa';
  }

  @override
  String savesSemester(int number) {
    return 'semestre $number';
  }

  @override
  String savesPredestinedHobby(String hobby) {
    return 'Nato per $hobby';
  }

  @override
  String get savesHobbyCuisine => 'Cucina';

  @override
  String get savesHobbyArts => 'Arte e artigianato';

  @override
  String get savesHobbyFilm => 'Cinema e letteratura';

  @override
  String get savesHobbySports => 'Sport';

  @override
  String get savesHobbyGames => 'Giochi';

  @override
  String get savesHobbyNature => 'Natura';

  @override
  String get savesHobbyTinkering => 'Bricolage';

  @override
  String get savesHobbyFitness => 'Fitness';

  @override
  String get savesHobbyScience => 'Scienza';

  @override
  String get savesHobbyMusic => 'Musica e ballo';

  @override
  String get savesTieMother => 'madre';

  @override
  String get savesTieFather => 'padre';

  @override
  String get savesTieSpouse => 'sposato con';

  @override
  String savesTieSibling(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'fratelli',
      one: 'fratello',
    );
    return '$_temp0';
  }

  @override
  String savesTieChild(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'figli',
      one: 'figlio',
    );
    return '$_temp0';
  }

  @override
  String get savesInterestPolitics => 'Politica';

  @override
  String get savesInterestMoney => 'Denaro';

  @override
  String get savesInterestEnvironment => 'Ambiente';

  @override
  String get savesInterestCrime => 'Crimine';

  @override
  String get savesInterestEntertainment => 'Intrattenimento';

  @override
  String get savesInterestCulture => 'Cultura';

  @override
  String get savesInterestFood => 'Cibo';

  @override
  String get savesInterestHealth => 'Salute';

  @override
  String get savesInterestFashion => 'Moda';

  @override
  String get savesInterestSports => 'Sport';

  @override
  String get savesInterestParanormal => 'Paranormale';

  @override
  String get savesInterestTravel => 'Viaggi';

  @override
  String get savesInterestWork => 'Lavoro';

  @override
  String get savesInterestWeather => 'Meteo';

  @override
  String get savesInterestAnimals => 'Animali';

  @override
  String get savesInterestSchool => 'Scuola';

  @override
  String get savesInterestToys => 'Giocattoli';

  @override
  String get savesInterestSciFi => 'Fantascienza';

  @override
  String get savesInterestMusic => 'Musica';

  @override
  String get savesInterestOutdoors => 'Aria aperta';

  @override
  String get setupHelpSims1 =>
      'Il primissimo The Sims tiene i contenuti personalizzati dentro la sua cartella di installazione, non in Documenti: gli oggetti vanno in una cartella Downloads accanto all’eseguibile del gioco (per esempio C:\\Program Files (x86)\\Maxis\\The Sims\\Downloads), e questa app smista gli altri tipi da sola: le skin (.skn/.cmx/.bmp) vanno in GameData\\Skins, muri e pavimenti in GameData\\Walls e GameData\\Floors. La Legacy Collection del 2025 funziona allo stesso modo dalla sua cartella di installazione (EA Games\\The Sims Legacy, oppure Steam\\steamapps\\common\\The Sims Legacy Collection). Se il gioco è installato altrove (un altro disco, una libreria Steam personalizzata), scegli a mano la sua cartella Downloads.';

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
