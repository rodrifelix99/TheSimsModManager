// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class LEl extends L {
  LEl([String locale = 'el']) : super(locale);

  @override
  String get appName => 'Sims Mod Manager';

  @override
  String get brandTitle => 'Διαχειριστής mod';

  @override
  String get brandSubtitle => 'για το Sims';

  @override
  String get navLibrary => 'Βιβλιοθήκη';

  @override
  String get navShop => 'The Exchange';

  @override
  String get navSettings => 'Ρυθμίσεις';

  @override
  String get shopAlphaBadge => 'ΑΛΦΑ';

  @override
  String get shopTagline => 'Mod από την κοινότητα, με ένα κλικ.';

  @override
  String shopListingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mod στα ράφια',
      one: '1 mod στα ράφια',
    );
    return '$_temp0';
  }

  @override
  String get shopRefresh => 'Ανανέωση';

  @override
  String get shopPublish => 'Δημοσιεύστε τα mod σας';

  @override
  String get shopLoadFailedTitle => 'Το The Exchange δεν απαντάει';

  @override
  String get shopLoadFailedBody =>
      'Δεν φόρτωσαν τα ράφια. Ελέγξτε τη σύνδεσή σας και δοκιμάστε ξανά.';

  @override
  String get shopRetry => 'Δοκιμάστε ξανά';

  @override
  String get shopEmptyTitle => 'Τα ράφια είναι ακόμα άδεια';

  @override
  String get shopEmptyBody =>
      'Το The Exchange μόλις άνοιξε τις πόρτες του και δεν έχει δημοσιεύσει κανείς τίποτα ακόμα. Τόσο καινούριο είναι. Φτιάχνετε mod; Γίνετε ο πρώτος στα ράφια!';

  @override
  String get shopAllGames => 'Όλα τα παιχνίδια';

  @override
  String get shopShowAllGames => 'Εμφάνιση κάθε παιχνιδιού';

  @override
  String shopEmptyGameTitle(String game) {
    return 'Τίποτα για το $game ακόμα';
  }

  @override
  String shopEmptyGameBody(String game) {
    return 'Άλλα παιχνίδια έχουν mod στα ράφια, αλλά για το $game δεν έχει δημοσιεύσει κανείς ακόμα. Φτιάξατε ένα; Γίνετε ο πρώτος!';
  }

  @override
  String shopBy(String author) {
    return 'από $author';
  }

  @override
  String get shopInstalled => 'Εγκατεστημένο';

  @override
  String get shopUpdate => 'Ενημέρωση';

  @override
  String get shopUpdateBadge => 'ενημέρωση';

  @override
  String shopUpdatesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count από τα mod σας έχουν νέες εκδόσεις στο The Exchange',
      one: '1 από τα mod σας έχει νέα έκδοση στο The Exchange',
    );
    return '$_temp0';
  }

  @override
  String get shopUpdateHeading => 'Υπάρχει νέα έκδοση αυτού του mod';

  @override
  String shopUpdateBody(String version, String author) {
    return 'Ο δημιουργός $author δημοσίευσε την v$version στο The Exchange. Η ενημέρωση αντικαθιστά τα αρχεία που έχετε τώρα.';
  }

  @override
  String get shopUpdateSeeListing => 'Δείτε την καταχώριση';

  @override
  String get shopInstalling => 'Γίνεται εγκατάσταση…';

  @override
  String get shopInstallNotes => 'Οδηγίες εγκατάστασης';

  @override
  String get shopCreatorNudge =>
      'Φτιάχνετε και εσείς mod; Η δημοσίευση στο The Exchange είναι δωρεάν και οι παίκτες εγκαθιστούν τη δουλειά σας με ένα κλικ.';

  @override
  String shopNeedsFolder(String game) {
    return 'Ρυθμίστε πρώτα τον φάκελο για mod του $game. Η καρτέλα Βιβλιοθήκη σάς καθοδηγεί.';
  }

  @override
  String shopVariations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count παραλλαγές',
      one: '1 παραλλαγή',
    );
    return '$_temp0';
  }

  @override
  String get shopSaveFile => 'Λήψη';

  @override
  String get shopSaving => 'Γίνεται λήψη…';

  @override
  String get shopSaved => 'Αποθηκεύτηκε';

  @override
  String get shopSaveHint =>
      'Η εγκατάσταση βάζει τα αρχεία κατευθείαν στον φάκελο mod σας. Η λήψη απλώς αποθηκεύει το αρχείο, όπου θέλετε.';

  @override
  String get shopDestination => 'Εγκατάσταση σε';

  @override
  String get shopVariationPick => 'Διαλέξτε παραλλαγή';

  @override
  String get shopBack => 'Πίσω στα ράφια';

  @override
  String get shopCopyLink => 'Αντιγραφή συνδέσμου';

  @override
  String get shopLinkCopied => 'Ο σύνδεσμος αντιγράφηκε';

  @override
  String get sidebarGames => 'ΠΑΙΧΝΙΔΙΑ';

  @override
  String sidebarNotInstalled(String detail) {
    return 'μη εγκατεστημένο · $detail';
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
  String get updateAvailable => 'Διαθέσιμη ενημέρωση';

  @override
  String updateClickToDownload(String version) {
    return 'v$version: κάντε κλικ για λήψη';
  }

  @override
  String get storage => 'Αποθηκευτικός χώρος';

  @override
  String storageInMods(String size) {
    return '$size σε mod';
  }

  @override
  String storageFreeOf(String free, String total) {
    return '$free ελεύθερα από $total';
  }

  @override
  String dropToInstall(String game) {
    return 'Αφήστε το για να εγκατασταθεί στο $game';
  }

  @override
  String get dropFolders => 'φάκελοι';

  @override
  String scanningMods(int done, int total) {
    return 'Διερεύνηση των mod για εικονίδια και ασυμβατότητες… $done από $total';
  }

  @override
  String get skip => 'Παράλειψη';

  @override
  String libraryTitle(String game) {
    return 'Βιβλιοθήκη του $game';
  }

  @override
  String modsShown(int count, String era) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count εμφανιζόμενα mod',
      one: '1 εμφανιζόμενο mod',
    );
    return '$_temp0 · $era';
  }

  @override
  String get learnMore => 'Μάθετε περισσότερα';

  @override
  String get dismiss => 'Παράλειψη';

  @override
  String get searchMods => 'Αναζήτηση mod…';

  @override
  String get viewGrid => 'Πλέγμα';

  @override
  String get viewList => 'Λίστα';

  @override
  String get viewFolders => 'Φάκελοι';

  @override
  String get sortTooltip => 'Ταξινόμηση';

  @override
  String get sortByName => 'Όνομα (A–Z)';

  @override
  String get sortByRecent => 'Άλλαξαν πρόσφατα';

  @override
  String get sortBySize => 'Πρώτα τα μεγαλύτερα';

  @override
  String get sortDisabledLast => 'Τα ανενεργά στο τέλος';

  @override
  String get libraryRefresh => 'Ανανέωση';

  @override
  String get libraryRootFolder => 'Φάκελος για mod';

  @override
  String get selectionTooltip => 'Επιλογή';

  @override
  String selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count επιλεγμένα',
      one: '1 επιλεγμένο',
    );
    return '$_temp0';
  }

  @override
  String get selectionSelectAll => 'Επιλογή όλων';

  @override
  String get selectionClear => 'Καθαρισμός';

  @override
  String get selectionEnable => 'Ενεργοποίηση';

  @override
  String get selectionDisable => 'Απενεργοποίηση';

  @override
  String selectionProgress(int done, int total) {
    return '$done από $total';
  }

  @override
  String selectionDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Απεγκατάσταση $count mods;',
      one: 'Απεγκατάσταση 1 mod;',
    );
    return '$_temp0';
  }

  @override
  String selectionDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Και τα $count αρχεία θα διαγραφούν από τον δίσκο. Δεν υπάρχει αναίρεση.',
      one: 'Το αρχείο θα διαγραφεί από τον δίσκο. Δεν υπάρχει αναίρεση.',
    );
    return '$_temp0';
  }

  @override
  String get selectionMove => 'Μετακίνηση σε…';

  @override
  String get newFolder => 'Νέος φάκελος';

  @override
  String newFolderIn(String folder) {
    return 'Μέσα στο $folder';
  }

  @override
  String get newFolderHint => 'Όνομα φακέλου';

  @override
  String get create => 'Δημιουργία';

  @override
  String get move => 'Μετακίνηση';

  @override
  String moveTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Πού να πάνε τα $count mods;',
      one: 'Πού να πάει το 1 mod;',
    );
    return '$_temp0';
  }

  @override
  String get moveBody =>
      'Τα αρχεία αλλάζουν φάκελο στον δίσκο. Τίποτα άλλο δεν αλλάζει - ό,τι είναι ανενεργό μένει ανενεργό.';

  @override
  String get installFolderTitle => 'Ποιος φάκελος;';

  @override
  String installFolderBody(String game) {
    return 'Πού καταλήγουν τα αρχεία μέσα στον φάκελο mods για $game.';
  }

  @override
  String get installFolderChoose => 'Επιλογή';

  @override
  String get installFolderEmpty =>
      'Δεν υπάρχουν υποφάκελοι ακόμη. Φτιάξε έναν, ή άσε τα πάντα στον φάκελο mods.';

  @override
  String get folderEmptySection => 'Δεν υπάρχει τίποτα εδώ ακόμα';

  @override
  String get install => 'Εγκατάσταση';

  @override
  String filePickerModsLabel(String game) {
    return 'Mods για το $game';
  }

  @override
  String get installWhereTitle => 'Πού να πάει αυτό;';

  @override
  String installWhereBody(String game) {
    return 'Το $game διαβάζει mod από αρκετούς φακέλους. Η εφαρμογή μπορεί να το βρει από το ίδιο το αρχείο ή μπορείτε να πείτε εσείς πού ανήκει.';
  }

  @override
  String get installWhereSorted => 'Ταξινόμησέ το για μένα';

  @override
  String get installWhereSortedDesc =>
      'Ακολουθεί τους φακέλους που ονομάζει η λήψη και τοποθετεί τα υπόλοιπα ανά τύπο αρχείου.';

  @override
  String get installWhereRemember => 'Να μην ερωτηθώ ξανά';

  @override
  String get destinationSims1Downloads =>
      'Αντικείμενα, hacks και οι περισσότερες λήψεις.';

  @override
  String get destinationSims1Global =>
      'Παρακάμψεις που αλλάζουν το βασικό παιχνίδι παντού.';

  @override
  String get destinationSims1Objects =>
      'Παρακάμψεις για τα αρχεία αντικειμένων του ίδιου του παιχνιδιού.';

  @override
  String get destinationSims1Skins =>
      'Καθημερινά δέρματα και κεφάλια. Αυτά εμφανίζονται στο Create a Sim.';

  @override
  String get destinationSims1SkinsBuy =>
      'Ρούχα που πωλούνται στα καταστήματα των κοινοτικών οικοπέδων.';

  @override
  String get destinationSims1Walls => 'Επενδύσεις τοίχων.';

  @override
  String get destinationSims1Floors => 'Πλακάκια δαπέδου.';

  @override
  String get destinationSims1Roofs => 'Υφές για στέγες.';

  @override
  String get prefAskWhereTitle => 'Ερώτηση για το πού θα γίνει η εγκατάσταση';

  @override
  String get prefAskWhereDesc =>
      'Αυτό το παιχνίδι διαβάζει mod από περισσότερους από έναν φακέλους. Επιλέξτε τον φάκελο κάθε φορά αντί να αποφασίζει η εφαρμογή';

  @override
  String get statTotal => 'ΣΥΝΟΛΙΚΑ';

  @override
  String get statEnabled => 'ΕΝΕΡΓΑ';

  @override
  String get statDisabled => 'ΑΝΕΝΕΡΓΑ';

  @override
  String get statConflicts => 'ΑΣΥΜΒΑΤΟΤΗΤΕΣ';

  @override
  String get statTotalTooltip =>
      'Κάθε mod σε αυτόν τον φάκελο, ενεργό ή ανενεργό.';

  @override
  String get statTotalTooltipClear =>
      'Κάθε mod σε αυτόν τον φάκελο. Κάντε κλικ για να καθαρίσετε την αναζήτηση και κάθε φίλτρο.';

  @override
  String get statEnabledTooltip => 'Τα mod που φορτώνει το παιχνίδι.';

  @override
  String get statEnabledTooltipActive =>
      'Εμφανίζονται μόνο τα ενεργά mod. Κάντε κλικ ξανά για να εμφανιστούν όλα.';

  @override
  String get statDisabledTooltip =>
      'Τα mod που κάθονται απενεργοποιημένα στον φάκελο.';

  @override
  String get statDisabledTooltipActive =>
      'Εμφανίζονται μόνο τα ανενεργά mod. Κάντε κλικ ξανά για να εμφανιστούν όλα.';

  @override
  String get conflictTooltipActive =>
      'Εμφανίζονται μόνο τα ασύμβατα mod. Κάντε κλικ ξανά για να εμφανιστούν όλα.';

  @override
  String get conflictTooltip =>
      'Ενεργά mod που μοιράζονται όνομα αρχείου με άλλο ενεργό mod, είναι εγκατεστημένα σε περισσότερες από μία εκδόσεις ή παρακάμπτουν τους ίδιους πόρους του παιχνιδιού. Το παιχνίδι κρατά μόνο το αντίγραφο που φορτώνει τελευταίο - κάποιες φορές αυτό είναι εσκεμμένο (patch mod), συνήθως όχι.';

  @override
  String get conflictTooltipClickHint =>
      'Κάντε κλικ για να δείτε μόνο αυτά τα mod.';

  @override
  String get filterAll => 'Όλα';

  @override
  String get emptyFiltered => 'Κανένα mod δεν ταιριάζει με τα φίλτρα σας';

  @override
  String get emptyNoMods => 'Κανένα mod ακόμα';

  @override
  String get emptyFilteredHint =>
      'Δοκιμάστε να καθαρίσετε την αναζήτηση ή να επιλέξετε άλλο φίλτρο.';

  @override
  String emptyNoModsHint(String path) {
    return 'Παρακολουθείται ο εξής φάκελος:\n$path';
  }

  @override
  String get openFolder => 'Άνοιγμα φακέλου';

  @override
  String get conflictBadge => 'ασυμβατότητα';

  @override
  String get duplicateBadge => 'αντίγραφο';

  @override
  String modInFolder(String folder) {
    return 'στο $folder';
  }

  @override
  String get modInModsFolder => 'στον φάκελο για mod';

  @override
  String setupFoundNoModsFolder(String game) {
    return 'Το $game βρέθηκε αλλά δεν έχει φάκελο για mod ακόμα';
  }

  @override
  String setupNotFound(String game) {
    return 'Δεν βρέθηκε φάκελος για mod στο $game';
  }

  @override
  String get setupFoundNoModsFolderBody =>
      'Ο φάκελος του παιχνιδιού βρίσκεται σε αυτόν τον υπολογιστή - απλώς δεν περιέχει ακόμη φάκελο για mod. Δημιουργήστε τον παρακάτω ή υποδείξτε τον χειροκίνητα.';

  @override
  String get setupNotFoundBody =>
      'Είτε το παιχνίδι δεν έχει εγκατασταθεί είτε βρίσκεται σε κάποιο ασυνήθιστο μέρος είτε ο φάκελος για mod δεν έχει δημιουργηθεί ακόμα.';

  @override
  String get foundOnThisComputer => 'ΒΡΕΘΗΚΕ ΣΕ ΑΥΤΟΝ ΤΟΝ ΥΠΟΛΟΓΙΣΤΗ';

  @override
  String get chooseFolder => 'Επιλέξτε φάκελο…';

  @override
  String get createItForMe => 'Δημιούργησέ τον για μένα';

  @override
  String willBeCreatedAt(String path) {
    return 'Θα δημιουργηθεί στο:\n$path';
  }

  @override
  String get checkAgain => 'Επανέλεγχος';

  @override
  String get useThis => 'Χρήση αυτού';

  @override
  String get enabled => 'Ενεργό';

  @override
  String get disabled => 'Ανενεργό';

  @override
  String get showInFileManager => 'Εμφάνιση στον διαχειριστή αρχείων';

  @override
  String get uninstallMod => 'Απεγκατάσταση mod';

  @override
  String uninstallConfirmTitle(String title) {
    return 'Απεγκατάσταση του $title;';
  }

  @override
  String uninstallConfirmBody(String path) {
    return 'Το αρχείο θα διαγραφεί από τον δίσκο:\n$path';
  }

  @override
  String get cancel => 'Ακύρωση';

  @override
  String get uninstall => 'Απεγκατάσταση';

  @override
  String conflictSameFileHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count άλλα ενεργά mod είναι ακριβώς το ίδιο αρχείο:',
      one: 'Κάποιο άλλο ενεργό mod είναι ακριβώς το ίδιο αρχείο:',
    );
    return '$_temp0';
  }

  @override
  String conflictSameNameHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count άλλα ενεργά mod έχουν το ίδιο όνομα αρχείου:',
      one: 'Κάποιο άλλο ενεργό mod έχει το ίδιο όνομα αρχείου:',
    );
    return '$_temp0';
  }

  @override
  String conflictVersionHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Φαίνεται πως $count άλλα ενεργά mod είναι διαφορετικές εκδόσεις αυτού του mod:',
      one:
          'Φαίνεται πως κάποιο άλλο ενεργό mod είναι διαφορετική έκδοση αυτού του mod:',
    );
    return '$_temp0';
  }

  @override
  String conflictResourcesHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count άλλα ενεργά mod παρακάμπτουν τους ίδιους πόρους του παιχνιδιού:',
      one:
          'Κάποιο άλλο ενεργό mod παρακάμπτει τους ίδιους πόρους του παιχνιδιού:',
    );
    return '$_temp0';
  }

  @override
  String sharedResources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count κοινοί πόροι',
      one: '1 κοινός πόρος',
    );
    return '$_temp0';
  }

  @override
  String get conflictSameFileBody =>
      'Η σάρωση διπλότυπων διάβασε αυτά τα αρχεία και ταιριάζουν byte προς byte. Δεν πρόκειται για δύο mod που συγκρούονται, αλλά για την ίδια λήψη που βρίσκεται στον φάκελο περισσότερες από μία φορές. Κρατήστε ένα και αφαιρέστε τα υπόλοιπα: τίποτα δεν αλλάζει στο παιχνίδι και κερδίζετε τον χώρο πίσω.';

  @override
  String get conflictSameNameBody =>
      'Τα πανομοιότυπα ονόματα συνήθως υποδεικνύουν ότι το ίδιο mod είναι εγκατεστημένο δύο φορές ή ότι τα πακέτα δύο δημιουργών είναι ασύμβατα. Το παιχνίδι φορτώνει τους αλληλοεπικαλυπτόμενους πόρους τους με απρόβλεπτη σειρά: κρατήστε το ένα και απενεργοποιήστε ή αφαιρέστε τα υπόλοιπα.';

  @override
  String get conflictVersionBody =>
      'Η διατήρηση πολλαπλών εκδόσεων ενός mod προκαλεί τη φόρτωση των αλληλοεπικαλυπτόμενων πόρων από το παιχνίδι με απρόβλεπτη σειρά: κρατήστε τη νεότερη και απενεργοποιήστε ή αφαιρέστε τις υπόλοιπες.';

  @override
  String get conflictResourcesBody =>
      'Αυτά τα πακέτα περιέχουν πόρους με τα ίδια αναγνωριστικά και ως εκ τούτου το παιχνίδι διατηρεί μόνο το αντίγραφο που φορτώνει τελευταίο. Αυτό μπορεί να είναι εσκεμμένο - τα patch mod και τα override mod επικαλύπτουν τους πόρους άλλων mod επίτηδες - ωστόσο σε περίπτωση που τα mod δεν σχετίζονται μεταξύ τους, σημαίνει ότι κάποιο από αυτά σταματάει να λειτουργεί χωρίς προειδοποίηση: κρατήστε αυτό που προτιμάτε και απενεργοποιήστε τα υπόλοιπα.';

  @override
  String get conflictIgnore => 'Αγνόηση';

  @override
  String get conflictIgnoreTooltip =>
      'Αν αυτή η ασυμβατότητα είναι σκόπιμη, κρύψτε την. Το mod δεν αλλάζει σε τίποτα, και μπορείτε να επαναφέρετε την προειδοποίηση από αυτή τη σελίδα ή από τις ρυθμίσεις.';

  @override
  String get conflictRestore => 'Επαναφορά';

  @override
  String advisoryBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count από τα mod σας έχουν γνωστά προβλήματα',
      one: 'Ένα από τα mod σας έχει γνωστό πρόβλημα',
    );
    return '$_temp0';
  }

  @override
  String get advisoryShow => 'Ρίξτε μια ματιά';

  @override
  String get advisoryShowAll => 'Εμφάνιση όλων των mod';

  @override
  String get advisoryBadge => 'πρόβλημα';

  @override
  String get advisoryBrokenHeading => 'Αυτό το mod αναφέρεται ως χαλασμένο';

  @override
  String get advisoryBrokenBody =>
      'Άλλοι παίκτες αναφέρουν ότι αυτό εδώ σταματάει το παιχνίδι από το να δουλεύει. Η απενεργοποίησή του είναι ο γρηγορότερος τρόπος να δείτε αν ευθύνεται για το πρόβλημά σας.';

  @override
  String get advisoryOutdatedHeading => 'Υπάρχει νεότερη έκδοση αυτού του mod';

  @override
  String get advisoryOutdatedBody =>
      'Η έκδοση που έχετε είναι αυτή με την οποία οι παίκτες αντιμετωπίζουν πρόβλημα. Η τελευταία έκδοση του δημιουργού μάλλον το λύνει.';

  @override
  String get advisoryCautionHeading => 'Αξίζει να το έχετε στο μάτι';

  @override
  String get advisoryCautionBody =>
      'Στους περισσότερους δουλεύει, αλλά είναι γνωστό ότι κάνει κόλπα. Αξίζει να το απενεργοποιήσετε αν ψάχνετε κάποιο πρόβλημα.';

  @override
  String advisorySince(String since) {
    return 'Από $since';
  }

  @override
  String get advisoryOpenLink => 'Άνοιγμα της σελίδας του δημιουργού';

  @override
  String get advisorySource =>
      'Αναφέρεται από άλλους παίκτες, όχι από το παιχνίδι.';

  @override
  String modInDirectory(String dir) {
    return 'στο $dir';
  }

  @override
  String get factVersion => 'Έκδοση';

  @override
  String get factFormat => 'Μορφή';

  @override
  String get factSize => 'Μέγεθος';

  @override
  String get factType => 'Τύπος';

  @override
  String get factModified => 'Τροποποιήθηκε';

  @override
  String get factDownloads => 'Λήψεις';

  @override
  String get factIgnoredConflicts => 'Αγνοημένες';

  @override
  String ignoredConflictsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ασυμβατότητες',
      one: '1 ασυμβατότητα',
    );
    return '$_temp0';
  }

  @override
  String get statusHeading => 'Κατάσταση';

  @override
  String get statusEnabledBody =>
      'Το mod είναι ενεργό: το παιχνίδι θα το φορτώσει κατά την επόμενη εκκίνηση.';

  @override
  String statusDisabledBody(String marker) {
    return 'Το mod είναι ανενεργό: το αρχείο διατηρείται στον δίσκο με μια επισήμανση «$marker» ώστε το παιχνίδι να το παραλείπει. Μπορείτε να το ενεργοποιήσετε οποτεδήποτε - τίποτα δεν διαγράφεται.';
  }

  @override
  String get fileOnDisk => 'Το αρχείο στον δίσκο';

  @override
  String get insideThePackage => 'Μέσα στο πακέτο';

  @override
  String resourcesTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count πόροι συνολικά',
      one: '1 πόρος συνολικά',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Ρυθμίσεις';

  @override
  String get sectionModManagement => 'ΔΙΑΧΕΙΡΙΣΗ MOD';

  @override
  String get sectionAppearance => 'ΕΜΦΑΝΙΣΗ';

  @override
  String get sectionLanguage => 'ΓΛΩΣΣΑ';

  @override
  String get sectionPrivacy => 'ΙΔΙΩΤΙΚΟΤΗΤΑ';

  @override
  String sectionModsFolder(String game) {
    return 'ΦΑΚΕΛΟΣ MOD · $game';
  }

  @override
  String sectionGameCaches(String game) {
    return 'CACHE ΤΟΥ ΠΑΙΧΝΙΔΙΟΥ · $game';
  }

  @override
  String sectionIgnoredConflicts(String game) {
    return 'ΑΓΝΟΗΜΕΝΕΣ ΑΣΥΜΒΑΤΟΤΗΤΕΣ · $game';
  }

  @override
  String sectionShopFolder(String game) {
    return 'THE EXCHANGE · $game';
  }

  @override
  String get prefShopFolderTitle => 'Πού πάνε τα mods από το The Exchange';

  @override
  String prefShopFolderDesc(String folder) {
    return 'Οι εγκαταστάσεις πάνε στο $folder';
  }

  @override
  String get sectionFeedback => 'ΣΧΟΛΙΑ';

  @override
  String get sectionAbout => 'ΣΧΕΤΙΚΑ';

  @override
  String get prefWarnConflictsTitle => 'Προειδοποίηση για ασυμβατότητες';

  @override
  String get prefWarnConflictsDesc =>
      'Να μαρκάρονται τα ενεργά mod που έχουν ίδιο όνομα αρχείου ή παρακάμπτουν τους ίδιους πόρους του παιχνιδιού με άλλο mod';

  @override
  String get prefConflictKindsTitle => 'Για ποιες ασυμβατότητες να ειδοποιεί';

  @override
  String get prefConflictKindsDesc =>
      'Απενεργοποιήστε τα είδη που δεν θέλετε να μαρκάρονται. Τα υπόλοιπα συνεχίζουν κανονικά';

  @override
  String get conflictKindSameFile => 'Πανομοιότυπα αντίγραφα';

  @override
  String get conflictKindSameName => 'Ίδιο όνομα αρχείου';

  @override
  String get conflictKindVersions => 'Διαφορετικές εκδόσεις';

  @override
  String get conflictKindResources => 'Κοινοί πόροι';

  @override
  String get prefConfirmDeleteTitle => 'Επιβεβαίωση πριν την απεγκατάσταση';

  @override
  String get prefConfirmDeleteDesc =>
      'Να ζητείται επιβεβαίωση πριν από τη διαγραφή ενός αρχείου mod από τον δίσκο';

  @override
  String get prefShowDisabledTitle => 'Εμφάνιση ανενεργών mod';

  @override
  String get prefShowDisabledDesc =>
      'Να διατηρούνται ορατά τα ανενεργά mod στη βιβλιοθήκη αντί να κρύβονται';

  @override
  String get prefDisabledSuffixTitle => 'Σήμανση ανενεργών mod';

  @override
  String get prefDisabledSuffixDesc =>
      'Αυτό που προστίθεται στο όνομα του αρχείου όταν απενεργοποιείς ένα mod. Άλλαξέ το για να ταιριάζει με άλλον διαχειριστή (το CC Magic βάζει .off)· η εφαρμογή διαβάζει ούτως ή άλλως και τα δύο, και όσα mod έχεις ήδη απενεργοποιήσει κρατούν το όνομά τους';

  @override
  String get prefDisabledSuffixInvalid =>
      'Χρειάζεται μια τελεία και λίγα γράμματα ή ψηφία, όπως .off';

  @override
  String get prefExperimentalPacksTitle => 'Πειραματικοί διακόπτες πακέτων';

  @override
  String get prefExperimentalPacksDesc =>
      'Επιτρέπει να σβήνεις τα πακέτα αυτού του παιχνιδιού. Αδοκίμαστο σε αυτή την έκδοση, και μια γειτονιά που παίχτηκε με κάποιο πακέτο μπορεί να χαλάσει χωρίς αυτό - κράτα πρώτα αντίγραφα';

  @override
  String get prefScanArtworkTitle => 'Σάρωση εντός των mod';

  @override
  String get prefScanArtworkDesc =>
      'Να γίνεται σάρωση μέσα στα αρχεία των mod όσο φορτώνει η βιβλιοθήκη για εικονίδια, λεπτομέρειες περιεχομένου και mod που παρακάμπτουν τους ίδιους πόρους';

  @override
  String get prefSoundEffectsTitle => 'Ηχητικά εφέ διεπαφής';

  @override
  String get prefSoundEffectsDesc =>
      'Να γίνεται αναπαραγωγή των ήχων του κλασικού Sims στα κλικ, στους διακόπτες και στις προειδοποιήσεις';

  @override
  String get prefAnalyticsTitle => 'Κοινοποίηση ανώνυμων δεδομένων χρήσης';

  @override
  String get prefAnalyticsDesc =>
      'Αποστολή ανώνυμων στατιστικών χρήσης και αναφορών κρασαρίσματος με σκοπό τη βελτίωση της εφαρμογής. Δεν περιλαμβάνει ποτέ ονόματα mod, διαδρομές αρχείων ή οτιδήποτε προσωπικό';

  @override
  String get themeTitle => 'Θέμα';

  @override
  String get themeDesc =>
      'Φωτεινό ή σκοτεινό. Η επιλογή «Σύστημα» ακολουθεί τη ρύθμιση του υπολογιστή σας.';

  @override
  String get themeSystem => 'Σύστημα';

  @override
  String get themeLight => 'Φωτεινό';

  @override
  String get themeDark => 'Σκοτεινό';

  @override
  String get languageTitle => 'Γλώσσα εφαρμογής';

  @override
  String get languageDesc =>
      'Επιλέξτε τη γλώσσα στην οποία θα εμφανίζεται η εφαρμογή. Η επιλογή «Σύστημα» ακολουθεί τη γλώσσα του υπολογιστή σας.';

  @override
  String get languageSystem => 'Σύστημα';

  @override
  String get translatorsTitle => 'Μεταφράστηκε από';

  @override
  String get translatorsDesc =>
      'Η εφαρμογή μιλάει δώδεκα γλώσσες χάρη σε αυτούς τους simmers.';

  @override
  String get sectionStartup => 'ΕΚΚΙΝΗΣΗ';

  @override
  String get prefDefaultGameTitle => 'Παιχνίδι στην εκκίνηση';

  @override
  String get prefDefaultGameDesc => 'Με ποια βιβλιοθήκη ανοίγει η εφαρμογή';

  @override
  String get defaultGameAuto => 'Αυτόματα';

  @override
  String get prefSetupGuideTitle => 'Οδηγός ρύθμισης';

  @override
  String get prefSetupGuideDesc =>
      'Δες ξανά τις ερωτήσεις της πρώτης εκκίνησης';

  @override
  String get onboardingReplay => 'Ξανά';

  @override
  String get onboardingSkip => 'Παράλειψη';

  @override
  String get onboardingSkipIntro => 'Παράλειψη εισαγωγής';

  @override
  String get onboardingBack => 'Πίσω';

  @override
  String get onboardingNext => 'Επόμενο';

  @override
  String get onboardingFinish => 'Άνοιγμα βιβλιοθήκης';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Βήμα $current από $total';
  }

  @override
  String get onboardingWelcomeTitle => 'Γεια! Ας τα ρυθμίσουμε';

  @override
  String get onboardingWelcomeBody =>
      'Λίγες γρήγορες ερωτήσεις και τα mods σου είναι έτοιμα. Θέλει λιγότερο από ένα λεπτό, και όλα αλλάζουν αργότερα από τις ρυθμίσεις.';

  @override
  String get onboardingGamesTitle => 'Ψάχνουμε τα παιχνίδια σου';

  @override
  String get onboardingGamesBody =>
      'Κοιτάμε στα συνηθισμένα σημεία για κάθε παιχνίδι και για τον φάκελο από όπου διαβάζει τα mods.';

  @override
  String get onboardingScanning => 'Ψάχνουμε ακόμη…';

  @override
  String onboardingGamesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Βρέθηκαν $count παιχνίδια',
      one: 'Βρέθηκε 1 παιχνίδι',
      zero: 'Τίποτα ακόμη',
    );
    return '$_temp0';
  }

  @override
  String onboardingGameMods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods ήδη εγκατεστημένα',
      one: '1 mod ήδη εγκατεστημένο',
      zero: 'Ο φάκελος mods είναι έτοιμος',
    );
    return '$_temp0';
  }

  @override
  String get onboardingGameMissing => 'Δεν υπάρχει σε αυτόν τον υπολογιστή';

  @override
  String get onboardingNoGamesTitle => 'Δεν βρήκαμε τίποτα';

  @override
  String get onboardingNoGamesBody =>
      'Κανένα πρόβλημα. Δείξε εσύ έναν φάκελο mods από τις ρυθμίσεις και όλα δουλεύουν το ίδιο.';

  @override
  String get onboardingFavoriteTitle => 'Ποιο παίζεις πιο πολύ;';

  @override
  String get onboardingFavoriteBody =>
      'Η εφαρμογή θα ανοίγει πάντα σε αυτό το παιχνίδι. Μπορείς να αλλάζεις παιχνίδι όποτε θες από την πλαϊνή μπάρα.';

  @override
  String get onboardingLookTitle => 'Κάν’ το δικό σου';

  @override
  String get onboardingLookBody =>
      'Όλη η εφαρμογή αλλάζει χρώματα ανάλογα με το παιχνίδι που έχεις ανοιχτό. Διάλεξε πώς θα δείχνει και πώς θα ακούγεται.';

  @override
  String get onboardingLibraryTitle => 'Πώς διαβάζεται η βιβλιοθήκη σου';

  @override
  String get onboardingLibraryBody =>
      'Δύο πράγματα που αξίζει να αποφασίσεις τώρα, γιατί αλλάζουν το τι σου δείχνει η βιβλιοθήκη.';

  @override
  String get onboardingDoneTitle => 'Όλα έτοιμα!';

  @override
  String get onboardingDoneBody =>
      'Η βιβλιοθήκη σου φορτώθηκε και σε περιμένει. Ρίξε ένα αρχείο mod πάνω στο παράθυρο για να το εγκαταστήσεις, και άλλαξε ό,τι θες από τις ρυθμίσεις.';

  @override
  String get folderNotFound => 'Δεν βρέθηκε. Επιλέξτε φάκελο';

  @override
  String get folderNotLocated =>
      'Το παιχνίδι (ή ο φάκελος για mod) δεν βρέθηκαν αυτόματα';

  @override
  String folderSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mod',
      one: '1 mod',
    );
    return '$_temp0 · $size στον δίσκο';
  }

  @override
  String get customFolder => 'προσαρμοσμένος φάκελος';

  @override
  String get change => 'Αλλαγή…';

  @override
  String get resetToAuto => 'Επαναφορά στο αυτόματο';

  @override
  String createDefaultFolderAt(String path) {
    return 'Δημιουργία του προεπιλεγμένου φακέλου (μαζί με τα αρχεία που χρειάζεται το παιχνίδι) στο:\n$path';
  }

  @override
  String get createFolder => 'Δημιουργία φακέλου';

  @override
  String get alsoFoundOnThisComputer =>
      'Βρέθηκε επίσης σε αυτόν τον υπολογιστή:';

  @override
  String get clearCacheTitle => 'Διαγραφή αρχείων cache';

  @override
  String clearCacheDesc(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Διαγραφή $count αρχείων cache ($size)',
      one: 'Διαγραφή 1 αρχείου cache ($size)',
    );
    return '$_temp0 ώστε να εμφανιστεί ό,τι περιεχόμενο προστέθηκε ή αφαιρέθηκε πρόσφατα - το παιχνίδι θα τα ξαναφτιάξει στην επόμενη εκκίνησή του';
  }

  @override
  String get clearCaches => 'Διαγραφή των cache';

  @override
  String get ignoredConflictsTitle => 'Ασυμβατότητες που αγνοείτε';

  @override
  String ignoredConflictsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count ασυμβατότητες που ζητήσατε να μην αναφέρονται. Επαναφέρετέ τες για να ξαναεμφανιστούν στη βιβλιοθήκη',
      one:
          'Μία ασυμβατότητα που ζητήσατε να μην αναφέρεται. Επαναφέρετέ την για να ξαναεμφανιστεί στη βιβλιοθήκη',
    );
    return '$_temp0';
  }

  @override
  String get ignoredConflictsReset => 'Επαναφορά όλων';

  @override
  String get reportBugTitle => 'Αναφορά bug';

  @override
  String get reportBugDesc =>
      'Δημιουργήστε μια αναφορά bug στο GitHub - η έκδοση της εφαρμογής, το λειτουργικό σας σύστημα και το τρέχον παιχνίδι συμπληρώνονται αυτόματα';

  @override
  String get reportBugButton => 'Αναφορά…';

  @override
  String get suggestFeatureTitle => 'Προτείνετε χαρακτηριστικό';

  @override
  String get suggestFeatureDesc =>
      'Λείπει κάτι; Πείτε μας πώς θα γινόταν καλύτερος ο διαχειριστής mod';

  @override
  String get suggestFeatureButton => 'Προτείνετε…';

  @override
  String get wikiTitle => 'Οδηγός χρήστη & συχνές ερωτήσεις';

  @override
  String get wikiDesc =>
      'Πώς να εγκαταστήσετε mod, να φτιάξετε την ανίχνευση φακέλων και άλλα πολλά, στο wiki του πρότζεκτ';

  @override
  String get wikiButton => 'Άνοιγμα wiki';

  @override
  String aboutTagline(String version) {
    return 'Έκδοση $version · Τα Sims 1-4 υποστηρίζονται · Το SimCity έρχεται σύντομα';
  }

  @override
  String updateIsAvailable(String version) {
    return 'Η έκδοση $version είναι διαθέσιμη';
  }

  @override
  String get noUpdateFound => 'Δεν βρέθηκε ενημέρωση';

  @override
  String getVersion(String version) {
    return 'Κατεβάστε τη v$version';
  }

  @override
  String get checkingForUpdates => 'Γίνεται έλεγχος…';

  @override
  String get checkForUpdates => 'Έλεγχος για ενημερώσεις';

  @override
  String get categoryPackage => 'Package';

  @override
  String get categoryScript => 'Script';

  @override
  String get categoryObject => 'Αντικείμενο';

  @override
  String get categoryArchive => 'Archive';

  @override
  String get categorySkin => 'Δέρμα';

  @override
  String get categoryTexture => 'Υφή';

  @override
  String get categoryWall => 'Τοίχος';

  @override
  String get categoryFloor => 'Πάτωμα';

  @override
  String get contentCasParts => 'στοιχεία CAS';

  @override
  String get contentObjects => 'αντικείμενα';

  @override
  String get contentTunings => 'tunings';

  @override
  String get contentBehaviors => 'συμπεριφορές';

  @override
  String get contentTextTables => 'πίνακες κειμένου';

  @override
  String get contentTextures => 'υφές';

  @override
  String get contentMeshes => 'πλέγματα';

  @override
  String get modKindCas => 'CAS';

  @override
  String get modKindBuildBuy => 'Κατασκευή';

  @override
  String get modKindGameplay => 'Gameplay';

  @override
  String get modKindScript => 'Script';

  @override
  String errorNoModFiles(String extensions, String name) {
    return 'Δεν βρέθηκαν αρχεία mod ($extensions) μέσα στο $name.';
  }

  @override
  String errorUnreadableArchive(String name) {
    return 'Το $name δεν είναι συμπιεσμένο αρχείο που μπορεί να διαβάσει αυτή η εφαρμογή.';
  }

  @override
  String errorNoUnpacker(String format, String name) {
    return 'Τίποτα σε αυτόν τον υπολογιστή δεν μπορεί να αποσυμπιέσει αρχεία $format. Αποσυμπιέστε το $name μόνοι σας και εγκαταστήστε τα αρχεία που έχει μέσα.';
  }

  @override
  String errorNoUnpackerLinux(String format, String name) {
    return 'Τίποτα σε αυτόν τον υπολογιστή δεν μπορεί να αποσυμπιέσει αρχεία $format. Εγκαταστήστε το p7zip και δοκιμάστε ξανά ή αποσυμπιέστε το $name μόνοι σας και εγκαταστήστε τα αρχεία που έχει μέσα.';
  }

  @override
  String errorNoUnpackerLinuxRar(String format, String name) {
    return 'Τίποτα σε αυτόν τον υπολογιστή δεν μπορεί να αποσυμπιέσει αρχεία $format. Εγκαταστήστε το p7zip ή το unrar και δοκιμάστε ξανά ή αποσυμπιέστε το $name μόνοι σας και εγκαταστήστε τα αρχεία που έχει μέσα.';
  }

  @override
  String errorUnpackFailed(String name) {
    return 'Δεν έγινε αποσυμπίεση του $name. Μπορεί να προστατεύεται με κωδικό, να είναι ένα κομμάτι χωρισμένου αρχείου ή μια χαλασμένη λήψη. Αποσυμπιέστε το χειροκίνητα και εγκαταστήστε τα αρχεία που έχει μέσα.';
  }

  @override
  String errorSims3PackUnreadable(String name) {
    return 'Το $name δεν είναι πακέτο του Sims 3 που μπορεί να διαβάσει αυτή η εφαρμογή.';
  }

  @override
  String errorSims3PackWorld(String name) {
    return 'Το $name είναι κόσμος, όχι προσαρμοσμένο περιεχόμενο. Εγκαταστήστε το με το The Sims 3 Launcher - το παιχνίδι κρατά τους κόσμους εκτός του φακέλου για mod.';
  }

  @override
  String errorSims3PackLibrary(String name) {
    return 'Το $name είναι οικόπεδο ή νοικοκυριό, όχι προσαρμοσμένο περιεχόμενο. Εγκαταστήστε το με το The Sims 3 Launcher - καταλήγει στη Βιβλιοθήκη μέσα στο παιχνίδι.';
  }

  @override
  String errorInstallFailed(String name, String reason) {
    return 'Το «$name» δεν εγκαταστάθηκε - $reason. Αν συνεχίσει να αποτυγχάνει, αποσυμπιέστε το χειροκίνητα και εγκαταστήστε τα αρχεία που έχει μέσα.';
  }

  @override
  String errorInstallFailedRaw(String name, String reason) {
    return 'Το «$name» δεν εγκαταστάθηκε - $reason';
  }

  @override
  String errorFileInUseDelete(String name) {
    return 'Το «$name» δεν διαγράφηκε - το χρησιμοποιεί άλλο πρόγραμμα (μήπως τρέχει το παιχνίδι;) ή είναι προστατευμένο από εγγραφή. Κλείστε ό,τι το χρησιμοποιεί και δοκιμάστε ξανά.';
  }

  @override
  String errorFileInUseRename(String name) {
    return 'Το «$name» δεν μετονομάστηκε - το χρησιμοποιεί άλλο πρόγραμμα (μήπως τρέχει το παιχνίδι;) ή είναι προστατευμένο από εγγραφή. Κλείστε ό,τι το χρησιμοποιεί και δοκιμάστε ξανά.';
  }

  @override
  String errorFileNameTaken(String name) {
    return 'Υπάρχει ήδη ένα «$name» σε εκείνον τον φάκελο. Μετονόμασε το ένα από τα δύο και ξαναδοκίμασε.';
  }

  @override
  String errorFolderNameBad(String name) {
    return 'Το «$name» δεν κάνει για όνομα φακέλου. Δοκίμασε ένα χωρίς καθέτους και χωρίς χαρακτήρες που κρατάει για τον εαυτό του το σύστημα.';
  }

  @override
  String errorFolderTooDeep(int levels) {
    return 'Το παιχνίδι κοιτάζει μόνο $levels φακέλους βαθιά μέσα στον φάκελο των mods, οπότε ό,τι βάλεις πιο κάτω δεν θα φορτώσει ποτέ.';
  }

  @override
  String errorBulkMoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods δεν μετακινήθηκαν',
      one: '1 mod δεν μετακινήθηκε',
    );
    return '$_temp0 - μπορεί να τα χρησιμοποιεί άλλο πρόγραμμα (τρέχει το παιχνίδι;), να είναι μόνο για ανάγνωση, ή να υπάρχει ήδη αρχείο με το ίδιο όνομα στον φάκελο.';
  }

  @override
  String errorBulkToggleFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods δεν άλλαξαν',
      one: '1 mod δεν άλλαξε',
    );
    return '$_temp0 - μπορεί να τα χρησιμοποιεί άλλο πρόγραμμα (τρέχει το παιχνίδι;) ή να είναι μόνο για ανάγνωση.';
  }

  @override
  String errorBulkRemoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods δεν διαγράφηκαν',
      one: '1 mod δεν διαγράφηκε',
    );
    return '$_temp0 - μπορεί να τα χρησιμοποιεί άλλο πρόγραμμα (τρέχει το παιχνίδι;) ή να είναι μόνο για ανάγνωση.';
  }

  @override
  String errorFileMissing(String name) {
    return 'Το «$name» δεν βρίσκεται πια στον φάκελο για mod - μπορεί να το μετακίνησε ή να το διέγραψε άλλο πρόγραμμα.';
  }

  @override
  String get requirementMedievalModLoader =>
      'Το The Sims Medieval δεν μπορεί να τρέξει script ή core mod χωρίς το αρχείο loader της κοινότητας μέσα στον φάκελο Game\\Bin του παιχνιδιού. Το προσαρμοσμένο περιεχόμενο δουλεύει και χωρίς αυτό, όλα τα άλλα όχι.';

  @override
  String get requirementSims4ModsOff =>
      'Το παιχνίδι έχει απενεργοποιημένα το προσαρμοσμένο περιεχόμενο και τα mod στις δικές του Game Options, οπότε τίποτα από αυτά δεν φορτώνει. Ενεργοποιήστε τα ξανά από Options → Game Options → Other και μετά επανεκκινήστε το παιχνίδι.';

  @override
  String get requirementSims4ScriptModsOff =>
      'Έχετε script mod εδώ, αλλά το παιχνίδι έχει απενεργοποιημένη την επιλογή «Script Mods Allowed» στις δικές του Game Options. Οι ενημερώσεις του παιχνιδιού την επαναφέρουν.';

  @override
  String get requirementGetFile => 'Από πού να το βρείτε';

  @override
  String tooDeepBanner(int count, int levels) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mod βρίσκονται',
      one: 'Ένα mod βρίσκεται',
    );
    return '$_temp0 σε υποφάκελο που δεν διαβάζει το παιχνίδι. Κοιτάζει μόνο $levels επίπεδα φακέλων μέσα στον φάκελο για mod - μετακινήστε τα ψηλότερα και θα φορτώσουν.';
  }

  @override
  String get tooDeepShow => 'Δείτε τα';

  @override
  String get duplicatesFind => 'Βρες διπλά mods';

  @override
  String duplicatesScanning(int done, int total) {
    return 'Διαβάζω τα mods που μπορεί να είναι διπλά… $done από $total';
  }

  @override
  String get duplicatesStop => 'Σταμάτα';

  @override
  String duplicatesBanner(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods είναι ακριβώς τα ίδια αρχεία με κάποια άλλα',
      one: 'Ένα mod είναι ακριβώς το ίδιο αρχείο με κάποιο άλλο',
    );
    return '$_temp0 - είναι $size που παίρνεις πίσω.';
  }

  @override
  String get duplicatesShow => 'Δείξε μου ποια';

  @override
  String get duplicatesSelectExtras => 'Τσέκαρε τα αντίγραφα που περισσεύουν';

  @override
  String get duplicatesClean => 'Εδώ δεν υπάρχει τίποτα διπλό.';

  @override
  String get duplicatesDismiss => 'Εντάξει';

  @override
  String tagTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ετικέτες $count mods',
      one: 'Ετικέτες αυτού του mod',
    );
    return '$_temp0';
  }

  @override
  String get tagBody =>
      'Οι δικές σου ετικέτες, για να τα βρίσκεις μετά. Πάτα μία για να μπει ή να βγει.';

  @override
  String get tagHint => 'Νέα ετικέτα';

  @override
  String get tagAdd => 'Πρόσθεσε';

  @override
  String get tagDone => 'Έτοιμο';

  @override
  String get tagHeading => 'Ετικέτες';

  @override
  String get tagAddFirst => 'Βάλε ετικέτα';

  @override
  String tagRemove(String tag) {
    return 'Βγάλε «$tag»';
  }

  @override
  String get selectionTag => 'Ετικέτα…';

  @override
  String folderAlsoReading(String folders) {
    return 'Το παιχνίδι σου διαβάζει και το $folders, οπότε τα mods που είναι εκεί μέσα είναι κι αυτά στη βιβλιοθήκη.';
  }

  @override
  String errorFolderUnreadable(String folder) {
    return 'Δεν ήταν δυνατό το άνοιγμα του «$folder». Διάλεξε φάκελο σε δίσκο που φτάνει αυτός ο υπολογιστής - ένα κινητό, μια κάμερα ή ένας αποσυνδεδεμένος δίσκος δικτύου δεν μπορούν να κρατήσουν τα mod σου.';
  }

  @override
  String errorNoWriteAccess(String folder) {
    return 'Η εφαρμογή δεν επιτρέπεται να γράψει στο «$folder». Το σύστημά σας προστατεύει αυτόν τον φάκελο - δώστε στον λογαριασμό σας δικαίωμα εγγραφής σε αυτόν ή δείξτε στην εφαρμογή άλλη τοποθεσία από τις Ρυθμίσεις.';
  }

  @override
  String get folderReadOnlyBanner =>
      'Αυτός ο φάκελος για mod είναι μόνο για ανάγνωση, οπότε η εγκατάσταση και η αφαίρεση mod δεν θα δουλέψουν μέχρι ο λογαριασμός σας να μπορεί να γράψει σε αυτόν.';

  @override
  String get elevatedNoDropBanner =>
      'Τρέχετε την εφαρμογή ως διαχειριστής, οπότε τα Windows δεν σας αφήνουν να σύρετε αρχεία στο παράθυρο. Χρησιμοποιήστε το κουμπί Εγκατάσταση - αυτό εξακολουθεί να δουλεύει.';

  @override
  String errorShopDownload(String name) {
    return 'Το «$name» δεν κατέβηκε από το The Exchange. Ελέγξτε τη σύνδεσή σας και δοκιμάστε ξανά.';
  }

  @override
  String errorShopNoModFiles(String name) {
    return 'Μέσα στο «$name» δεν υπάρχει κάτι που να μπορεί να εγκαταστήσει αυτό το παιχνίδι. Μπορεί να μην είναι καν mod - χρησιμοποιήστε τη Λήψη για να αποθηκεύσετε το αρχείο όπου θέλετε.';
  }

  @override
  String get errorShopListingNotFound =>
      'Αυτό το mod δεν είναι πια στο The Exchange. Μπορεί να αποσύρθηκε.';

  @override
  String get errorShopListingUnknownGame =>
      'Αυτό το mod είναι για παιχνίδι που δεν γνωρίζει ακόμα αυτή η έκδοση της εφαρμογής. Δοκιμάστε να την ενημερώσετε.';

  @override
  String errorPackToggleFailed(String pack) {
    return 'Δεν μπόρεσα να αλλάξω το $pack. Κλείσε το παιχνίδι και δοκίμασε ξανά.';
  }

  @override
  String get errorPackNoUserData =>
      'Δεν βρίσκω τον φάκελο ρυθμίσεων του παιχνιδιού, οπότε δεν υπάρχει πού να σημειωθεί ποια πακέτα να παραλειφθούν. Τρέξε πρώτα το παιχνίδι μία φορά.';

  @override
  String get errorPackNeedsAdmin =>
      'Τα Windows δεν άφησαν την εφαρμογή να το αλλάξει. Ξεκίνα την ξανά ως διαχειριστής και δοκίμασε πάλι.';

  @override
  String get errorPackNotSupported =>
      'Σε αυτό το σύστημα τα πακέτα δεν ανάβουν και δεν σβήνουν.';

  @override
  String get errorPackIsTheGame =>
      'Αυτό είναι το πακέτο από το οποίο τρέχει το παιχνίδι, οπότε πρέπει να μείνει αναμμένο.';

  @override
  String get errorPackToggleRefused =>
      'Δεν μπόρεσα να αλλάξω αυτό το πακέτο. Κλείσε το παιχνίδι και δοκίμασε ξανά.';

  @override
  String get eraClassic => 'Κλασικό';

  @override
  String get eraNightlife => 'Nightlife';

  @override
  String get eraAmbitions => 'Ambitions';

  @override
  String get eraModern => 'Μοντέρνο';

  @override
  String get eraMedieval => 'Μεσαιωνικό';

  @override
  String get navPacks => 'Πακέτα';

  @override
  String get packsScanning => 'Ψάχνω τα πακέτα σου…';

  @override
  String get packsEmptyTitle => 'Δεν βρέθηκαν πακέτα';

  @override
  String packsEmptyBody(String game) {
    return 'Είτε το $game δεν είναι εγκατεστημένο εκεί που μπορεί να το δει η εφαρμογή, είτε δεν υπάρχουν ακόμα πακέτα δίπλα του.';
  }

  @override
  String get packsRescan => 'Έλεγχος ξανά';

  @override
  String packsSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count πακέτα εγκατεστημένα',
      one: '1 πακέτο εγκατεστημένο',
    );
    return '$_temp0';
  }

  @override
  String packsSummaryWithOff(int count, int off) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count πακέτα ενεργά',
      one: '1 πακέτο ενεργό',
    );
    return '$_temp0, $off απενεργοποιημένα';
  }

  @override
  String get packsOff => 'Ανενεργό';

  @override
  String get packsInstalled => 'Εγκατεστημένο';

  @override
  String get packsNeedAdmin =>
      'Για να ανάβεις και να σβήνεις αυτά τα πακέτα χρειάζονται δικαιώματα διαχειριστή, γιατί εκεί κρατάει τη λίστα του το παιχνίδι. Ξεκίνα την εφαρμογή ξανά ως διαχειριστής για να τα αλλάξεις - στο μεταξύ το drag and drop σταματάει να δουλεύει, οπότε αξίζει να γυρίσεις πίσω μετά.';

  @override
  String get packsExperimentalTitle => 'Το να τα σβήνεις είναι πειραματικό';

  @override
  String get packsExperimentalOff =>
      'Δουλεύει όπως δούλευε πάντα σε αυτό το παιχνίδι, αλλά κανείς δεν το έχει δοκιμάσει σε αυτή την έκδοση, και μια γειτονιά που έπαιξες με κάποιο πακέτο μπορεί να χαλάσει αν την ανοίξεις χωρίς αυτό. Το να τα βλέπεις είναι ασφαλές. Άνοιξε τους πειραματικούς διακόπτες στις Ρυθμίσεις αν θέλεις να το δοκιμάσεις έτσι κι αλλιώς.';

  @override
  String get packsExperimentalOn =>
      'Κράτα πρώτα αντίγραφο των γειτονιών σου. Μια γειτονιά που έπαιξες με κάποιο πακέτο μπορεί να χαλάσει αν την ανοίξεις χωρίς αυτό, και από εδώ δεν αναιρείται - το να ξανανάψεις το πακέτο δεν φέρνει πάντα πίσω το αρχείο.';

  @override
  String packsRestartNotice(String game) {
    return 'Κάνε επανεκκίνηση το $game για να ισχύσει. Τα πακέτα σου μένουν εγκατεστημένα έτσι κι αλλιώς.';
  }

  @override
  String packsAllOwnedSims4(String expansions, String gamePacks) {
    return '$expansions πακέτα επέκτασης. $gamePacks πακέτα παιχνιδιού. Τα αγόρασες όλα, φυσικά.';
  }

  @override
  String get packKindExpansions => 'Πακέτα επέκτασης';

  @override
  String get packKindGamePacks => 'Πακέτα παιχνιδιού';

  @override
  String get packKindStuffPacks => 'Πακέτα αντικειμένων';

  @override
  String get packKindKits => 'Κιτ';

  @override
  String get packKindFreePacks => 'Δωρεάν πακέτα';

  @override
  String get navSaves => 'Αποθηκευμένα';

  @override
  String get savesScanning =>
      'Γίνεται ανάγνωση των αποθηκευμένων παιχνιδιών σας…';

  @override
  String get savesEmptyTitle => 'Δεν βρέθηκαν αποθηκευμένα παιχνίδια';

  @override
  String savesEmptyBody(String game) {
    return 'Μόλις παίξετε το $game και αποθηκεύσετε, οι κόσμοι σας εμφανίζονται εδώ - οικογένειες, φωτογραφίες και όλα τα υπόλοιπα.';
  }

  @override
  String get savesRescan => 'Νέα σάρωση';

  @override
  String savesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Βρέθηκαν $count αποθηκευμένα παιχνίδια',
      one: 'Βρέθηκε 1 αποθηκευμένο παιχνίδι',
    );
    return '$_temp0';
  }

  @override
  String savesLastSaved(String date) {
    return 'Τελευταία αποθήκευση $date';
  }

  @override
  String get savesShowInFolder => 'Εμφάνιση στον φάκελο';

  @override
  String savesBackups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count αντίγραφα ασφαλείας',
      one: '1 αντίγραφο ασφαλείας',
    );
    return '$_temp0';
  }

  @override
  String get savesTabHouseholds => 'Νοικοκυριά';

  @override
  String get savesTabAlbum => 'Άλμπουμ φωτογραφιών';

  @override
  String get savesTabStats => 'Στατιστικά κόσμου';

  @override
  String savesNeighborhood(int number) {
    return 'Γειτονιά $number';
  }

  @override
  String get savesOtherHouseholds => 'Townies και άλλα νοικοκυριά';

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
  String get savesFunds => 'Κεφάλαια';

  @override
  String get savesRooms => 'Δωμάτια';

  @override
  String savesBedsBaths(int beds, int baths) {
    return '$beds υπνοδ. · $baths μπάνια';
  }

  @override
  String savesByCreator(String name) {
    return 'από $name';
  }

  @override
  String get savesMembers => 'Μέλη';

  @override
  String get savesRelationships => 'Σχέσεις';

  @override
  String get savesUnknownSim => 'Άγνωστος Sim';

  @override
  String get savesStatSims => 'Sims';

  @override
  String get savesStatHouseholds => 'Νοικοκυριά';

  @override
  String get savesStatNetWorth => 'Περιουσία';

  @override
  String get savesStatWorlds => 'Κόσμοι';

  @override
  String get savesStatPhotos => 'Φωτογραφίες';

  @override
  String savesAcrossHouseholds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'σε $count νοικοκυριά',
      one: 'σε 1 νοικοκυριό',
    );
    return '$_temp0';
  }

  @override
  String savesPlayedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count παιγμένα',
      one: '1 παιγμένο',
    );
    return '$_temp0';
  }

  @override
  String get savesSizeOnDisk => 'Μέγεθος στον δίσκο';

  @override
  String get savesLifeStages => 'Στάδια ζωής';

  @override
  String get savesTopSkills => 'Υψηλότερες δεξιότητες σε αυτό το αρχείο';

  @override
  String get savesSaveInfo => 'Αρχείο αποθήκευσης';

  @override
  String get savesLastSavedLabel => 'Τελευταία αποθήκευση';

  @override
  String get savesGameVersion => 'Έκδοση παιχνιδιού';

  @override
  String get savesDescription => 'Περιγραφή';

  @override
  String get savesAgeInfant => 'Βρέφος';

  @override
  String get savesAgeBaby => 'Μωρό';

  @override
  String get savesAgeToddler => 'Νήπιο';

  @override
  String get savesAgeChild => 'Παιδί';

  @override
  String get savesAgeTeen => 'Έφηβος';

  @override
  String get savesAgeYoungAdult => 'Νεαρός ενήλικας';

  @override
  String get savesAgeAdult => 'Ενήλικας';

  @override
  String get savesAgeElder => 'Ηλικιωμένος';

  @override
  String get savesGenderMale => 'Άνδρας';

  @override
  String get savesGenderFemale => 'Γυναίκα';

  @override
  String get savesSkillCooking => 'Μαγειρική';

  @override
  String get savesSkillMechanical => 'Μηχανική';

  @override
  String get savesSkillCharisma => 'Χάρισμα';

  @override
  String get savesSkillBody => 'Σώμα';

  @override
  String get savesSkillLogic => 'Λογική';

  @override
  String get savesSkillCreativity => 'Δημιουργικότητα';

  @override
  String get savesSkillCleaning => 'Καθαριότητα';

  @override
  String get savesPersonalityNeat => 'Τακτικός';

  @override
  String get savesPersonalityOutgoing => 'Κοινωνικός';

  @override
  String get savesPersonalityActive => 'Δραστήριος';

  @override
  String get savesPersonalityPlayful => 'Παιχνιδιάρης';

  @override
  String get savesPersonalityNice => 'Ευγενικός';

  @override
  String get savesZodiacAries => 'Κριός';

  @override
  String get savesZodiacTaurus => 'Ταύρος';

  @override
  String get savesZodiacGemini => 'Δίδυμοι';

  @override
  String get savesZodiacCancer => 'Καρκίνος';

  @override
  String get savesZodiacLeo => 'Λέων';

  @override
  String get savesZodiacVirgo => 'Παρθένος';

  @override
  String get savesZodiacLibra => 'Ζυγός';

  @override
  String get savesZodiacScorpio => 'Σκορπιός';

  @override
  String get savesZodiacSagittarius => 'Τοξότης';

  @override
  String get savesZodiacCapricorn => 'Αιγόκερως';

  @override
  String get savesZodiacAquarius => 'Υδροχόος';

  @override
  String get savesZodiacPisces => 'Ιχθύες';

  @override
  String get savesAspirationRomance => 'Ρομάντζο';

  @override
  String get savesAspirationFamily => 'Οικογένεια';

  @override
  String get savesAspirationFortune => 'Πλούτος';

  @override
  String get savesAspirationPopularity => 'Δημοτικότητα';

  @override
  String get savesAspirationKnowledge => 'Γνώση';

  @override
  String get savesAspirationGrowUp => 'Ενηλικίωση';

  @override
  String get savesAspirationPleasure => 'Απόλαυση';

  @override
  String get savesAspirationGrilledCheese => 'Τοστ με τυρί';

  @override
  String get savesRelCrush => 'τσιμπημένος';

  @override
  String get savesRelLove => 'ερωτευμένοι';

  @override
  String get savesRelEngaged => 'αρραβωνιασμένοι';

  @override
  String get savesRelMarried => 'παντρεμένοι';

  @override
  String get savesRelFriends => 'φίλοι';

  @override
  String get savesRelBestFriends => 'κολλητοί';

  @override
  String get savesRelSteady => 'σε σχέση';

  @override
  String get savesRelEnemies => 'εχθροί';

  @override
  String get savesPhotoFamilyPortrait => 'Οικογενειακό πορτρέτο';

  @override
  String get savesPhotoLot => 'Οικόπεδο';

  @override
  String get savesPhotoSim => 'Πορτρέτο Sim';

  @override
  String get savesPhotoSnapshot => 'Στιγμιότυπο';

  @override
  String get savesProperty => 'Ακίνητο';

  @override
  String get savesGhost => 'φάντασμα';

  @override
  String savesCareerLevel(String career, int level) {
    return '$career · επίπεδο $level';
  }

  @override
  String get savesSpeciesLargeDog => 'σκύλος';

  @override
  String get savesSpeciesSmallDog => 'μικρός σκύλος';

  @override
  String get savesSpeciesCat => 'γάτα';

  @override
  String get savesOccultVampire => 'βαμπίρ';

  @override
  String get savesOccultZombie => 'ζόμπι';

  @override
  String get savesOccultWerewolf => 'λυκάνθρωπος';

  @override
  String get savesOccultPlantSim => 'PlantSim';

  @override
  String get savesOccultAlien => 'εξωγήινος';

  @override
  String get savesOccultServo => 'servo';

  @override
  String get savesOccultWitch => 'μάγος';

  @override
  String get savesOccultBigfoot => 'bigfoot';

  @override
  String get savesOccultFairy => 'νεράιδα';

  @override
  String get savesOccultGenie => 'τζίνι';

  @override
  String get savesOccultMermaid => 'γοργόνα';

  @override
  String get savesLotResidential => 'Κατοικία';

  @override
  String get savesLotCommunity => 'Κοινοτικό οικόπεδο';

  @override
  String get savesLotDorm => 'Εστία';

  @override
  String get savesLotSecretSociety => 'Μυστική εταιρεία';

  @override
  String get savesLotGreekHouse => 'Greek house';

  @override
  String get savesLotHotel => 'Ξενοδοχείο';

  @override
  String get savesLotSecret => 'Κρυφό οικόπεδο';

  @override
  String get savesLotBusiness => 'Επιχείρηση';

  @override
  String get savesLotApartment => 'Διαμέρισμα';

  @override
  String savesGpa(String gpa) {
    return '$gpa GPA';
  }

  @override
  String savesSemester(int number) {
    return 'εξάμηνο $number';
  }

  @override
  String savesPredestinedHobby(String hobby) {
    return 'Γεννημένος για $hobby';
  }

  @override
  String get savesHobbyCuisine => 'Κουζίνα';

  @override
  String get savesHobbyArts => 'Τέχνες & χειροτεχνία';

  @override
  String get savesHobbyFilm => 'Κινηματογράφος & λογοτεχνία';

  @override
  String get savesHobbySports => 'Αθλήματα';

  @override
  String get savesHobbyGames => 'Παιχνίδια';

  @override
  String get savesHobbyNature => 'Φύση';

  @override
  String get savesHobbyTinkering => 'Μαστορέματα';

  @override
  String get savesHobbyFitness => 'Γυμναστική';

  @override
  String get savesHobbyScience => 'Επιστήμη';

  @override
  String get savesHobbyMusic => 'Μουσική & χορός';

  @override
  String get savesTieMother => 'μητέρα';

  @override
  String get savesTieFather => 'πατέρας';

  @override
  String get savesTieSpouse => 'παντρεμένος με';

  @override
  String savesTieSibling(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'αδέρφια',
      one: 'αδέρφι',
    );
    return '$_temp0';
  }

  @override
  String savesTieChild(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'παιδιά',
      one: 'παιδί',
    );
    return '$_temp0';
  }

  @override
  String get savesInterestPolitics => 'Πολιτική';

  @override
  String get savesInterestMoney => 'Χρήμα';

  @override
  String get savesInterestEnvironment => 'Περιβάλλον';

  @override
  String get savesInterestCrime => 'Έγκλημα';

  @override
  String get savesInterestEntertainment => 'Ψυχαγωγία';

  @override
  String get savesInterestCulture => 'Κουλτούρα';

  @override
  String get savesInterestFood => 'Φαγητό';

  @override
  String get savesInterestHealth => 'Υγεία';

  @override
  String get savesInterestFashion => 'Μόδα';

  @override
  String get savesInterestSports => 'Αθλήματα';

  @override
  String get savesInterestParanormal => 'Παραφυσικά';

  @override
  String get savesInterestTravel => 'Ταξίδια';

  @override
  String get savesInterestWork => 'Δουλειά';

  @override
  String get savesInterestWeather => 'Καιρός';

  @override
  String get savesInterestAnimals => 'Ζώα';

  @override
  String get savesInterestSchool => 'Σχολείο';

  @override
  String get savesInterestToys => 'Παιχνίδια';

  @override
  String get savesInterestSciFi => 'Επιστημονική φαντασία';

  @override
  String get savesInterestMusic => 'Μουσική';

  @override
  String get savesInterestOutdoors => 'Ύπαιθρο';

  @override
  String get setupHelpSims1 =>
      'Το αρχικό The Sims διατηρεί το προσαρμοσμένο περιεχόμενο μέσα στον φάκελο εγκατάστασής του, όχι στα Έγγραφα: τα αντικείμενα πηγαίνουν σε έναν φάκελο Downloads δίπλα στο εκτελέσιμο του παιχνιδιού (π.χ. C:\\Program Files (x86)\\Maxis\\The Sims\\Downloads) και αυτή η εφαρμογή ταξινομεί αυτόματα τους άλλους τύπους - τα δέρματα (.skn/.cmx/.bmp) στον GameData\\Skins, τους τοίχους και τα πατώματα στους GameData\\Walls και GameData\\Floors. Η Legacy Collection του 2025 λειτουργεί με τον ίδιο τρόπο από τον δικό της φάκελο εγκατάστασης (EA Games\\The Sims Legacy ή Steam\\steamapps\\common\\The Sims Legacy Collection). Αν το παιχνίδι είναι εγκατεστημένο αλλού (άλλος δίσκος, προσαρμοσμένη βιβλιοθήκη Steam), επιλέξτε τον φάκελο Downloads του χειροκίνητα.';

  @override
  String get setupHelpSims2 =>
      'Το The Sims 2 φορτώνει προσαρμοσμένο περιεχόμενο από τα Έγγραφα > EA Games > The Sims 2 > Downloads (η Ultimate Collection χρησιμοποιεί τον «The Sims 2 Ultimate Collection», η Legacy Collection του 2025 τον «The Sims 2 Legacy»). Ο φάκελος μπορεί να μην υπάρχει πριν τον δημιουργήσετε ή εγκαταστήσετε προσαρμοσμένο περιεχόμενο τουλάχιστον μία φορά. Όταν ξεκινήσει το παιχνίδι, απαντήστε «Yes» στο παράθυρο για το προσαρμοσμένο περιεχόμενο, ώστε να ενεργοποιηθούν οι λήψεις.';

  @override
  String get setupHelpSims3 =>
      'Το The Sims 3 δεν δημιουργεί από μόνο του φάκελο για mod: χρειάζεται το framework της κοινότητας, δηλαδή έναν φάκελο Mods > Packages μέσα στα Έγγραφα > Electronic Arts > The Sims 3, συν ένα αρχείο Resource.cfg που λέει στο παιχνίδι να τον διαβάσει. Αυτή η εφαρμογή μπορεί να δημιουργήσει και τα δύο για εσάς. Αν έχετε εγκαταστήσει το παιχνίδι μέσω δίσκου ή Wine, ο φάκελος αυτός μπορεί να βρίσκεται μέσα στο app bundle - χρησιμοποιήστε το «Επιλέξτε φάκελο» για να τον υποδείξετε.';

  @override
  String get setupHelpSims4 =>
      'Το The Sims 4 φορτώνει τα mod από τα Έγγραφα > Electronic Arts > The Sims 4 > Mods. Το παιχνίδι δημιουργεί αυτόν τον φάκελο την πρώτη φορά που τρέχει, οπότε εκκινήστε το μία φορά αν λείπει. Έπειτα, μέσα από το παιχνίδι, ενεργοποιήστε το Options > Game Options > Other > «Enable Custom Content and Mods» (και το «Script Mods Allowed» για τα αρχεία .ts4script) και επανεκκινήστε το παιχνίδι.';

  @override
  String get setupHelpSimsMedieval =>
      'Το The Sims Medieval φορτώνει τα mod από τον φάκελο εγκατάστασής του, όχι από τα Έγγραφα: από έναν φάκελο Mods > Packages δίπλα στα αρχεία του παιχνιδιού (π.χ. C:\\Program Files (x86)\\Origin Games\\The Sims Medieval), συν ένα αρχείο Resource.cfg στον φάκελο εγκατάστασης που λέει στο παιχνίδι να τον διαβάσει. Αυτή η εφαρμογή μπορεί να δημιουργήσει και τα δύο για εσάς (τα Windows μπορεί να ζητήσουν δικαιώματα διαχειριστή για την τοποθεσία Program Files). Ο φάκελος Έγγραφα > Electronic Arts > The Sims Medieval περιέχει μόνο αποθηκευμένα παιχνίδια - ό,τι mod βάλετε εκεί δεν θα λειτουργήσει. Αν το έχετε εγκαταστήσει μέσω Wine/CrossOver ή έχετε προσαρμοσμένη βιβλιοθήκη Steam, χρησιμοποιήστε το «Επιλέξτε φάκελο» για να υποδείξετε τον φάκελο Mods > Packages μέσα στον φάκελο εγκατάστασης του παιχνιδιού.';

  @override
  String get prefSubfoldersTitle =>
      'Οι φάκελοι περιλαμβάνουν τους υποφακέλους τους';

  @override
  String get prefSubfoldersDesc =>
      'Ένας φάκελος δείχνει και όλα όσα βρίσκονται από κάτω. Κλειστό, το cc και το cc/defaults είναι ξεχωριστά ράφια.';

  @override
  String deleteFolderTitle(String folder) {
    return 'Διαγραφή του $folder;';
  }

  @override
  String get deleteFolderBody =>
      'Ο φάκελος και ό,τι έχει μέσα χάνεται, μαζί με τους υποφακέλους. Δεν αναιρείται.';

  @override
  String deleteFolderMods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Θα διαγραφούν $count mods',
      one: 'Θα διαγραφεί 1 mod',
    );
    return '$_temp0';
  }

  @override
  String get deleteFolderEmpty => 'Δεν έχει mods μέσα.';

  @override
  String get deleteFolder => 'Διαγραφή φακέλου';

  @override
  String triviaTitle(String game) {
    return 'Το plumbob ξέρει · $game';
  }

  @override
  String get triviaContextLibrary => 'Απ’ ό,τι φαίνεται κοιτάς τα mods σου';

  @override
  String get triviaContextSaves => 'Απ’ ό,τι φαίνεται είσαι στα save σου';

  @override
  String get triviaContextPacks => 'Απ’ ό,τι φαίνεται τακτοποιείς τα pack σου';

  @override
  String triviaCounter(int index, int total) {
    return 'Πληροφορία $index από $total';
  }

  @override
  String get triviaOpen => 'Ρώτα το plumbob';

  @override
  String get triviaClose => 'Όχι τώρα';

  @override
  String get triviaPrevious => 'Προηγούμενη πληροφορία';

  @override
  String get triviaNext => 'Επόμενη πληροφορία';

  @override
  String get triviaAnother => 'Άλλη μία';

  @override
  String get triviaToSettings => 'Έφτασε; Κλείσε το plumbob από τις Ρυθμίσεις';

  @override
  String get prefTriviaTitle => 'Πληροφορίες του plumbob';

  @override
  String get prefTriviaDesc =>
      'Άσε το plumbob να πετάγεται πού και πού με μια πληροφορία για το παιχνίδι στο οποίο βρίσκεσαι';

  @override
  String get triviaCategoryOrigins => 'Καταγωγή';

  @override
  String get triviaCategoryDesign => 'Σχεδίαση';

  @override
  String get triviaCategoryLore => 'Lore';

  @override
  String get triviaCategoryDeath => 'Θάνατος';

  @override
  String get triviaCategoryMusic => 'Μουσική';

  @override
  String get triviaCategoryCheats => 'Cheats';

  @override
  String get triviaCategoryRecords => 'Ρεκόρ';

  @override
  String get triviaCategoryModding => 'Modding';

  @override
  String get triviaCategoryLanguage => 'Γλώσσα';

  @override
  String get triviaCategoryCommunity => 'Κοινότητα';

  @override
  String get triviaSeriesLlama =>
      'Η Maxis είχε κάνει κάποτε ψηφοφορία σε όλο το στούντιο για ανεπίσημη μασκότ. Υποψήφια ήταν μια φτέρη, μια ταινία των βοοειδών και ένα λάμα. Κέρδισε το λάμα, και από τότε εμφανίζεται σε κάθε παιχνίδι.';

  @override
  String get triviaSeriesSimlish =>
      'Τα simlish γεννήθηκαν μπροστά στο μικρόφωνο. Στον Stephen Kearin και στη Gerri Lawlor έδιναν αφορμές του στιλ «πεινασμένος» ή «μόνος» κι εκείνοι αυτοσχεδίαζαν επί ώρες πώς θα έπρεπε να ακούγεται αυτό.';

  @override
  String get triviaSeriesCheats =>
      'Το rosebud και το klapaucius δίνουν από §1.000. Το rosebud είναι από τον Πολίτη Κέιν· ο Klapaucius είναι ρομπότ κατασκευαστής από την Κυβεριάδα του Stanisław Lem, βιβλίο που ο Will Wright αναφέρει ως επιρροή ήδη από το SimCity.';

  @override
  String get triviaSeriesRecords =>
      'Το Guinness αναγνωρίζει το The Sims ως τη σειρά παιχνιδιών για PC με τις μεγαλύτερες πωλήσεις όλων των εποχών. Ξεπέρασε τα 125 εκατομμύρια αντίτυπα πριν από πάνω από μια δεκαετία και έχει μεταφραστεί σε 60 γλώσσες.';

  @override
  String get triviaSeriesGoths =>
      'Οι Goth είναι από τις πιο μακροβιότερες οικογένειες στα βιντεοπαιχνίδια. Ο Mortimer και η Bella εμφανίζονται σε κάθε κύριο τίτλο από το 2000 και μετά.';

  @override
  String get triviaSeriesReaper =>
      'Ο Χάροντας έχει βιογραφικό που το κανονικό παιχνίδι δεν σου δείχνει ποτέ. Ανάμεσα στα άλλα, αναφέρει και το αγαπημένο του συγκρότημα: τους Styx.';

  @override
  String get triviaSeriesSimCity =>
      'Το The Sims βγήκε μέσα από το SimCity. Ο Will Wright όλο ήθελε να κάνει ζουμ στους ανθρωπάκους για τους οποίους χτιζόταν η πόλη.';

  @override
  String get triviaSeriesLegacy =>
      'Τον Ιανουάριο του 2025 η EA ξαναέβγαλε το The Sims και το The Sims 2 ως Legacy Collections, με όλα τα expansions μέσα. Είναι διορθώσεις συμβατότητας κι όχι remaster, οπότε και τα δύο παίζονται ακριβώς όπως τότε.';

  @override
  String get triviaSeriesPlumbob =>
      'Το πράσινο διαμάντι έχει γραφτεί με τρεις τρόπους: PlumbBob στο The Sims, Plum Bob στο The Sims 2 και plumbob από το The Sims 4 και μετά. Η Maxis λέει ότι στην ανάπτυξη χρησιμοποιήθηκαν και οι τρεις.';

  @override
  String get triviaSeriesModScene =>
      'Η σκηνή των mods είναι σχεδόν συνομήλικη της σειράς. Editors για skins και αντικείμενα κυκλοφορούσαν λίγους μόλις μήνες μετά το πρώτο παιχνίδι, το 2000, πολύ πριν υπάρξει οποιοδήποτε επίσημο εργαλείο.';

  @override
  String get triviaSeriesConflicts =>
      'Η σύγκρουση είναι πιο απλή απ’ ό,τι ακούγεται. Δύο mods διεκδικούν τον ίδιο πόρο, φορτώνονται και τα δύο, και κερδίζει όποιο διαβάσει τελευταίο το παιχνίδι. Δεν χάλασε τίποτα, απλώς κάτι πέρασε μπροστά.';

  @override
  String get triviaSeriesPackage =>
      'Ένα αρχείο .package είναι αρχειοθήκη DBPF, δηλαδή Database Packed File. Η Maxis χρησιμοποιεί τον ίδιο περιέκτη από το SimCity 4, και γι’ αυτό ένα μόνο εργαλείο ανοίγει είκοσι χρόνια custom content.';

  @override
  String get triviaSeriesRename =>
      'Το να κλείνεις ένα mod μετονομάζοντάς το είναι το παλιότερο κόλπο της σκηνής. Το παιχνίδι φορτώνει μόνο ό,τι αναγνωρίζει, οπότε ένα μετονομασμένο package μένει ακριβώς εκεί που ήταν και δεν βγάζει άχνα.';

  @override
  String get triviaSeriesSaves =>
      'Τα save του The Sims είναι γειτονιές, όχι θέσεις αποθήκευσης. Οι οικογένειες, τα οικόπεδα, οι αναμνήσεις και τα κουτσομπολιά ζουν όλα σε έναν φάκελο, που μεγαλώνει όσο συνεχίζεις να παίζεις.';

  @override
  String get triviaSeriesPacks =>
      'Το να κλείσεις ένα pack δεν μετακινεί ούτε ένα αρχείο. Κάθε παιχνίδι της σειράς κρατά αλλού τη δική του λίστα με το τι θα φορτώσει, μια γραμμή ρυθμίσεων ή ένα κλειδί μητρώου, και το να κρύψεις ένα pack σημαίνει απλώς να πειράξεις αυτή τη λίστα.';

  @override
  String get triviaSims1Dollhouse =>
      'Το The Sims ξεκίνησε ως προσομοιωτής αρχιτεκτονικής με το όνομα Project Dollhouse. Οι sims μπήκαν μόνο και μόνο για να μπορεί ο παίκτης να κρίνει αν αυτό το σπίτι ήταν καλό για να ζεις μέσα του.';

  @override
  String get triviaSims1Oakland =>
      'Ο Will Wright έχασε το σπίτι του στην πυρκαγιά του Όκλαντ το 1991. Το να ξαναστήσει ένα νοικοκυριό από το μηδέν, έπιπλα και συσκευές και ρουτίνες, έγινε ο σπόρος του παιχνιδιού.';

  @override
  String get triviaSims1Toilet =>
      'Τα στελέχη δεν πείστηκαν από την παρουσίαση και την ξαπόστειλαν ως «παιχνίδι με τις τουαλέτες», επειδή οι sims χρειάζονταν μπάνιο.';

  @override
  String get triviaSims1HomeTactics =>
      'Πριν γίνει The Sims, παρουσιαζόταν ως Home Tactics: The Experimental Domestic Simulator. Ούτε αυτή η εκδοχή άρεσε στα δοκιμαστικά γκρουπ.';

  @override
  String get triviaSims1Myst =>
      'Το 2002 το The Sims πέρασε το Myst και έγινε το παιχνίδι για PC με τις μεγαλύτερες πωλήσεις όλων των εποχών.';

  @override
  String get triviaSims1Simlish =>
      'Τα simlish αυτοσχεδιάστηκαν από ηθοποιούς που έπαιζαν με κομμάτια ουκρανικών, ναβάχο, ταγκαλόγκ και εσθονικών, και κρατήθηκαν επίτηδες χωρίς νόημα ώστε η γλώσσα να μην παλιώνει ποτέ.';

  @override
  String get triviaSims1Architecture =>
      'Τα εργαλεία δόμησης ήταν τόσο ασυνήθιστα για το 2000 που κάποιοι δεν έβαλαν ποτέ ούτε έναν sim και χρησιμοποιούσαν το παιχνίδι σαν δωρεάν πρόγραμμα αρχιτεκτονικής.';

  @override
  String get triviaSims1Audience =>
      'Πράγμα σπάνιο για την εποχή του, η πλειοψηφία του κοινού ήταν γυναίκες, και εν μέρει γι’ αυτό το μάρκετινγκ δεν έμοιαζε με τίποτε άλλο στο ράφι.';

  @override
  String get triviaSims1Cowplant =>
      'Το cowplant πρωτοεμφανίστηκε εδώ, με την ονομασία Laganaphyllis Simnovorii, και από τότε τρώει διακριτικά sims σε κάθε γενιά της σειράς.';

  @override
  String get triviaSims1Plumbob =>
      'Η λέξη plumbob βγαίνει από το νήμα της στάθμης, εκείνο το μυτερό βαρίδι που κρεμούν οι μάστορες για να βρουν την κατακόρυφο. Αυτό ήταν παιχνίδι αρχιτεκτονικής πριν από οτιδήποτε άλλο.';

  @override
  String get triviaSims1Release =>
      'Το παιχνίδι κυκλοφόρησε στις 4 Φεβρουαρίου 2000 και πούλησε περισσότερο από κάθε πρόβλεψη που είχε κάνει η EA γι’ αυτό.';

  @override
  String get triviaSims1Edith =>
      'Κάθε αντικείμενο στο παιχνίδι γράφτηκε σε μια γλώσσα που λέγεται SimAntics, μέσα από ένα εσωτερικό εργαλείο ονόματι Edith, βαφτισμένο έτσι από την Edith Bunker: τον πρώτο χαρακτήρα που φτιάχτηκε ποτέ για το The Sims.';

  @override
  String get triviaSims1Expansions =>
      'Επτά expansions σε τριάμισι χρόνια, ένα την άνοιξη κι ένα το φθινόπωρο, από το Livin’ Large τον Αύγουστο του 2000 μέχρι το Makin’ Magic τον Οκτώβριο του 2003.';

  @override
  String get triviaSims1Unleashed =>
      'Το Unleashed έφερε τα κατοικίδια στη σειρά το 2002 και πήρε το βραβείο παιχνιδιού προσομοίωσης της χρονιάς στα Interactive Achievement Awards.';

  @override
  String get triviaSims1Clown =>
      'Ο Τραγικός Κλόουν εμφανίζεται για να φτιάξει τη διάθεση ενός λυπημένου sim που έχει τον πίνακά του. Είναι πανάθλιος σ’ αυτό, και εκεί ακριβώς είναι όλο το αστείο.';

  @override
  String get triviaSims1Llama =>
      'Το αρχικό τυπωμένο εγχειρίδιο περιείχε ένα βιβλίο με τίτλο Making the Most of Your Llama. Κανείς δεν το εξήγησε ποτέ.';

  @override
  String get triviaSims1Superstar =>
      'Το Superstar άφηνε έναν sim να γίνει ηθοποιός, μοντέλο ή τραγουδιστής, με δείκτη φήμης και όλα, έντεκα χρόνια πριν το The Sims 4 ξαναδοκιμάσει τη διασημότητα.';

  @override
  String get triviaSims1Catalogue =>
      'Καθώς ξανάχτιζε το σπίτι του μετά τη φωτιά, ο Will Wright αναρωτιόταν συνέχεια ποια κομμάτια ενός σπιτιού είναι απαραίτητα και ποια μπορούν να περιμένουν. Αυτό το ερώτημα είναι λίγο πολύ ο κατάλογος του buy mode.';

  @override
  String get triviaSims2Aging =>
      'Το The Sims 2 ήταν το πρώτο της σειράς όπου οι sims γερνούσαν, πέθαιναν από γεράματα και κληροδοτούσαν γενετική. Τα μάτια, η μύτη και το πιγούνι έρχονται και από τους δύο γονείς.';

  @override
  String get triviaSims2Memories =>
      'Κάθε sim κουβαλά μια κρυφή λίστα αναμνήσεων. Το να δει έναν θάνατο, ένα πρώτο φιλί ή μια προαγωγή καταγράφεται και επηρεάζει τη διάθεσή του αργότερα.';

  @override
  String get triviaSims2Bella =>
      'Η Bella Goth εξαφανίζεται από το Pleasantview στην αρχή του παιχνιδιού, και μέσα σε είκοσι χρόνια δεν δόθηκε ποτέ επίσημη εξήγηση.';

  @override
  String get triviaSims2Strangetown =>
      'Η Bella βρίσκεται ζωντανή στο Strangetown, χωρίς την παραμικρή ανάμνηση από το Pleasantview. Η Maxis είπε ότι και οι δύο Bella είναι αληθινές, και το άφησε εκεί.';

  @override
  String get triviaSims2FamilyTrees =>
      'Οι γειτονιές του The Sims 2 πατούν σε ένα πραγματικό οικογενειακό δέντρο: το Pleasantview, το Strangetown και το Veronaville συνδέονται με γάμους και φήμες.';

  @override
  String get triviaSims2Plead =>
      'Τον Χάροντα μπορείς να τον παρακαλέσεις. Μίλα του τη σωστή στιγμή και μπορεί να σου δώσει πίσω τον sim σου, καμιά φορά με αντάλλαγμα κάποιον άλλο.';

  @override
  String get triviaSims2ReaperRomance =>
      'Μπορείς να τα φτιάξεις με τον Χάροντα. Αν το παίξεις σωστά, από αυτή τη σχέση βγαίνει ένα μωρό φάντασμα.';

  @override
  String get triviaSims2Satellite =>
      'Ένας sim που χαζεύει τα άστρα έχει μια πολύ μικρή πιθανότητα να τον πετύχει δορυφόρος που πέφτει. Είναι από τους πιο σπάνιους θανάτους της σειράς.';

  @override
  String get triviaSims2Therapist =>
      'Η κατάρρευση του aspiration στέλνει τον sim στον θεραπευτή, μία από τις λίγες φορές που το παιχνίδι σπάει τον δικό του τέταρτο τοίχο για την πλάκα.';

  @override
  String get triviaSims2WantsFears =>
      'Οι επιθυμίες και οι φόβοι κινούν ολόκληρο το παιχνίδι. Ο δείκτης aspiration αντιδρά εξίσου έντονα σε αυτό που φοβόταν ο sim όσο και σε αυτό που ήλπιζε.';

  @override
  String get triviaSims2FaceSculpt =>
      'Το παιχνίδι κυκλοφόρησε με ολοκληρωμένο σύστημα γλυπτικής προσώπου και σώματος, και γι’ αυτό τα πρόσωπα του The Sims 2 δείχνουν ακόμα πιο ποικίλα από των επόμενων τίτλων.';

  @override
  String get triviaSims2Aliens =>
      'Η απαγωγή από εξωγήινους συμβαίνει μόνο σε άντρες sims που χαζεύουν τα άστρα πολλή ώρα, και ναι, γυρίζουν έγκυοι.';

  @override
  String get triviaSims2FreezerBunny =>
      'Το Freezer Bunny το σχεδίασε η καλλιτέχνις Emmy Toyonaga για το The Sims 2 και πρωτοεμφανίστηκε κρυμμένο μέσα σε έναν καταψύκτη σε κοινοτικό οικόπεδο. Από τότε τρυπώνει κρυφά σε κάθε παιχνίδι.';

  @override
  String get triviaSims2SocialBunny =>
      'Το Social Bunny αντικατέστησε τον Τραγικό Κλόουν και, σε αντίθεση με τον κλόουν, αυτό όντως δουλεύει. Αρκετοί βρήκαν την ικανή εκδοχή ακόμα πιο ανησυχητική.';

  @override
  String get triviaSims2Giveaway =>
      'Τον Ιούλιο του 2014 η EA χάρισε το Ultimate Collection μέσω Origin, με τον κωδικό I-LOVE-THE-SIMS. Την επόμενη δεκαετία, μέχρι το Legacy Collection, αυτό το δώρο ήταν το μόνο αντίτυπο που κυκλοφορούσε.';

  @override
  String get triviaSims3SunsetValley =>
      'Το Sunset Valley είναι το Pleasantview του The Sims 2 περίπου 25 χρόνια νωρίτερα, οπότε μπορείς να γνωρίσεις τους παππούδες sims που έχεις ήδη παίξει.';

  @override
  String get triviaSims3Founders =>
      'Το Sunset Valley το ίδρυσαν οι Goth και το έχτισαν οι Landgraab. Μπορείς να παίξεις τον Mortimer Goth ως παιδί και να τον δεις να γνωρίζει τη Bella Bachelor.';

  @override
  String get triviaSims3OpenWorld =>
      'Το The Sims 3 κατάργησε τελείως τις οθόνες φόρτωσης. Ολόκληρη η πόλη προσομοιώνεται ταυτόχρονα, με κάθε sim να γερνά και να δουλεύει στο παρασκήνιο.';

  @override
  String get triviaSims3Simulation =>
      'Όλοι οι sims της πόλης προσομοιώνονται μαζί, και γι’ αυτό ένα παλιό save αρχίζει να κολλάει. Το παιχνίδι τρέχει σιωπηλά ζωές που δεν συνάντησες ποτέ.';

  @override
  String get triviaSims3CreateAStyle =>
      'Το Create-a-Style επέτρεπε να αλλάξεις χρώμα και μοτίβο σχεδόν σε κάθε αντικείμενο, μια λειτουργία τόσο απαιτητική που δεν ξαναγύρισε ποτέ.';

  @override
  String get triviaSims3Exchange =>
      'Το The Sims 3 κυκλοφόρησε με πραγματική διαδικτυακή ανταλλαγή, όπου οι παίκτες αντάλλασσαν οικόπεδα, sims και μοτίβα κατευθείαν από τον launcher.';

  @override
  String get triviaSims3Downloads =>
      'Μόνο την πρώτη εβδομάδα, οι παίκτες κατέβασαν πάνω από επτά εκατομμύρια αντικείμενα φτιαγμένα από την κοινότητα μέσα από αυτόν τον launcher.';

  @override
  String get triviaSims3Traits =>
      'Τα traits αντικατέστησαν τα παλιά ροοστάτη προσωπικότητας, και μερικά, όπως το Kleptomaniac και το Insane, σπάνε αθόρυβα τους κανόνες της κανονικής ζωής.';

  @override
  String get triviaSims3Kleptomaniac =>
      'Ένας κλεπτομανής sim γυρίζει σπίτι με τα έπιπλα των άλλων, χωρίς να του το ζητήσει κανείς, και συνεχίζει μέχρι να το πάρεις χαμπάρι.';

  @override
  String get triviaSims3Simlish =>
      'Η Katy Perry, η Lily Allen, οι Depeche Mode και δεκάδες άλλοι καλλιτέχνες ξαναηχογράφησαν τα δικά τους τραγούδια στα simlish για τα soundtrack.';

  @override
  String get triviaSims3Townies =>
      'Επειδή ο ανοιχτός κόσμος προσομοίωνε και τους sims εκτός οθόνης, συχνά ανακάλυπτες ότι οι κάτοικοι είχαν παντρευτεί και κάνει παιδιά χωρίς καμία δική σου ανάμειξη.';

  @override
  String get triviaSims3Store =>
      'Το The Sims 3 Store κατέληξε να πουλήσει περισσότερα αντικείμενα από όσα είχε το ίδιο το παιχνίδι όταν κυκλοφόρησε.';

  @override
  String get triviaSims3Launch =>
      'Το The Sims 3 πούλησε 1,4 εκατομμύριο αντίτυπα την πρώτη εβδομάδα, τον Ιούνιο του 2009, η μεγαλύτερη κυκλοφορία σε PC που είχε ποτέ η EA.';

  @override
  String get triviaSims4Flies =>
      'Ο θάνατος από μύγες είναι υπαρκτός. Άσε ένα οικόπεδο να βρομίσει αρκετά και ένα σμήνος αποτελειώνει τον sim σου.';

  @override
  String get triviaSims4Emotions =>
      'Εδώ τα πάντα τα κινούν τα συναισθήματα. Ένας Εμπνευσμένος sim ζωγραφίζει καλύτερα· ένας Εξοργισμένος μπορεί να πεθάνει από τον θυμό του.';

  @override
  String get triviaSims4EmotionDeaths =>
      'Ένας sim μπορεί να πεθάνει από τα γέλια, από θυμό και από ντροπή. Σε αυτό το παιχνίδι το συναίσθημα δεν είναι διακόσμηση, είναι κίνδυνος.';

  @override
  String get triviaSims4CreateASim =>
      'Το Create-a-Sim αντικατέστησε τους ροοστάτες με απευθείας τράβηγμα και σπρώξιμο στο πρόσωπο, και γι’ αυτό ένα πρόσωπο στο The Sims 4 φτιάχνεται τόσο γρήγορα.';

  @override
  String get triviaSims4Launch =>
      'Το The Sims 4 κυκλοφόρησε χωρίς πισίνες και χωρίς νήπια. Και τα δύο επέστρεψαν δωρεάν, με ενημέρωση, μετά από επίμονη πίεση των παικτών.';

  @override
  String get triviaSims4Worlds =>
      'Το Willow Creek και το Oasis Springs ήταν οι μόνοι δύο κόσμοι στην κυκλοφορία, τον Σεπτέμβριο του 2014. Τώρα είναι δεκάδες, και σχεδόν όλοι ήρθαν μαζί με κάποιο pack.';

  @override
  String get triviaSims4Gender =>
      'Το φύλο ξεκλειδώθηκε πλήρως με ενημέρωση του 2016: κάθε sim μπορεί να φοράει οτιδήποτε, να έχει οποιαδήποτε φωνή και να μένει έγκυος ή όχι.';

  @override
  String get triviaSims4Newcrest =>
      'Το Newcrest κυκλοφόρησε εντελώς άδειο, επίτηδες. Δεκαπέντε οικόπεδα, ούτε ένα κτίριο, και μια ανοιχτή πρόσκληση στην κοινότητα να το γεμίσει.';

  @override
  String get triviaSims4Naming =>
      'Ονόματα γειτονιών όπως Willow Creek και Oasis Springs ακολουθούν έναν άγραφο κανόνα από την παλιά Maxis: δύο απλές αγγλικές λέξεις, καμία επινοημένη ορθογραφία.';

  @override
  String get triviaSims4Goths =>
      'Η οικογένεια Goth εμφανίζεται και εδώ, κάτι που την κάνει μία από τις πιο μακροβιότερες στα βιντεοπαιχνίδια, παρούσα σε κάθε κύριο τίτλο.';

  @override
  String get triviaSims4FreeToPlay =>
      'Το βασικό παιχνίδι έγινε δωρεάν τον Οκτώβριο του 2022, σε PC, PlayStation και Xbox ταυτόχρονα. Τα packs παρέμειναν επί πληρωμή.';

  @override
  String get triviaSims4Mccc =>
      'Το MC Command Center, το πρώτο mod που βάζουν σχεδόν όλοι στο The Sims 4, έχει ξεπεράσει τα 14 εκατομμύρια κατεβάσματα μόνο στο CurseForge. Ο Deaderpool το ενημερώνει από το 2015.';

  @override
  String get triviaSims4Twallan =>
      'Το MCCC υπάρχει χάρη στο The Sims 3. Συνεχίζει από εκεί που σταμάτησαν το Master Controller και το Story Progression του Twallan, μεταφέροντας μια ιδέα πάνω από δέκα ετών σε νέα μηχανή.';

  @override
  String get triviaSims4Deaths =>
      'Έναν sim μπορεί να τον σκοτώσει ένα cowplant, ένα μηχάνημα αυτόματης πώλησης, ένα στερεοφωνικό σε σχήμα λάμα και τα γέλια. Όχι όλα μαζί.';

  @override
  String get triviaMedievalWatcher =>
      'Εδώ δεν είσαι νοικοκυριό, είσαι ο Παρατηρητής: μια καλοπροαίρετη θεότητα που σπρώχνει ήρωες μέσα σε ένα βασίλειο αντί να τρέχει τη μέρα μιας οικογένειας.';

  @override
  String get triviaMedievalHeroes =>
      'Ένα βασίλειο χωρά ως δέκα sims ήρωες σε δέκα επαγγέλματα, και ο καθένας ανεβαίνει από το επίπεδο 1 στο 10 κερδίζοντας νέες ικανότητες και όλο και πιο πομπώδεις τίτλους.';

  @override
  String get triviaMedievalStocks =>
      'Κάθε ήρωας ξυπνά με δύο υποχρεώσεις και μια προθεσμία. Αν τις αμελήσεις πολλές φορές, τιμωρείσαι, και αυτό ισχύει και για τον μονάρχη, που μπορεί να καταλήξει στο κιούφι.';

  @override
  String get triviaMedievalAmbition =>
      'Διαλέγεις μια Φιλοδοξία για ολόκληρο το βασίλειο πριν ξεκινήσεις, και οι αποστολές που αναλαμβάνεις βαθμολογούνται ως προς αυτήν. Είναι το πιο κοντά που έφτασε ποτέ το The Sims σε συνθήκη νίκης.';

  @override
  String get triviaMedievalQuests =>
      'Αυτό είναι ολική μετατροπή, όχι spin-off. Το sandbox αντικαθίσταται από μια αλυσίδα αποστολών, και γι’ αυτό είναι το μόνο παιχνίδι The Sims που μπορείς πραγματικά να τελειώσεις.';

  @override
  String get triviaMedievalPirates =>
      'Το Pirates and Nobles, τον Αύγουστο του 2011, ήταν το μοναδικό add-on που πήρε ποτέ: γεράκια και παπαγάλοι, χάρτες θησαυρού και φτυάρια, και ένας πόλεμος ανάμεσα σε δύο νεοφερμένες παρατάξεις.';

  @override
  String get triviaMedievalProxy =>
      'Το παιχνίδι δεν φτιάχτηκε ποτέ για να φορτώνει mods. Τα script και core mods χρειάζονται το proxy d3dx9_31.dll της κοινότητας μέσα στο Game/Bin για να καταδεχτεί καν να τα διαβάσει, ενώ το custom content δουλεύει και χωρίς αυτό.';

  @override
  String get triviaMedievalEngine =>
      'Τρέχει στη μηχανή του The Sims 3, και γι’ αυτό το Resource.cfg και τα αρχεία .package φαίνονται τόσο οικεία σε όποιον έχει κάνει modding σε εκείνο το παιχνίδι.';

  @override
  String get navCreations => 'Κατασκευές';

  @override
  String creationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count κατασκευές',
      one: '1 κατασκευή',
      zero: 'Δεν έχεις αποθηκεύσει τίποτα ακόμα',
    );
    return '$_temp0';
  }

  @override
  String get creationsScanning => 'Διαβάζω τα οικόπεδα και τα νοικοκυριά σου…';

  @override
  String get creationsRefresh => 'Ανανέωση';

  @override
  String get creationsAll => 'Όλα';

  @override
  String get creationsBack => '← Πίσω σε όλα';

  @override
  String get creationsNoneOfKind => 'Δεν υπάρχει τίποτα τέτοιο εδώ.';

  @override
  String get creationsEmptyTitle => 'Δεν υπάρχει τίποτα ακόμα';

  @override
  String get creationsEmptyBody =>
      'Τα οικόπεδα, τα δωμάτια, τα νοικοκυριά και τα sims που αποθηκεύεις μέσα στο παιχνίδι εμφανίζονται εδώ — όπως και ό,τι κατεβάζεις και ρίχνεις στο παράθυρο.';

  @override
  String creationsBy(String creator) {
    return 'από $creator';
  }

  @override
  String get creationsWhoLivesHere => 'ΠΟΙΟΙ ΕΡΧΟΝΤΑΙ ΜΑΖΙ';

  @override
  String get creationsShowInFolder => 'Εμφάνιση στον φάκελο';

  @override
  String get creationsDelete => 'Διαγραφή';

  @override
  String creationsDeleteTitle(String name) {
    return 'Διαγραφή «$name»;';
  }

  @override
  String get creationsDeleteBody =>
      'Φεύγει οριστικά από τον φάκελο του παιχνιδιού. Δεν αναιρείται.';

  @override
  String creationsFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count αρχεία',
      one: '1 αρχείο',
    );
    return '$_temp0';
  }

  @override
  String get creationKindLot => 'Οικόπεδο';

  @override
  String get creationKindRoom => 'Δωμάτιο';

  @override
  String get creationKindHousehold => 'Νοικοκυριό';

  @override
  String get creationKindSim => 'Sim';

  @override
  String get creationFolderSims4Tray => 'Tray';

  @override
  String get creationFolderSims3Library => 'Library';

  @override
  String get creationFolderSims2LotCatalog => 'Συλλογή οικοπέδων και σπιτιών';

  @override
  String get creationFolderSims2SavedSims => 'Πακεταρισμένα sims';

  @override
  String creationFolderSims1Houses(String number) {
    return 'Γειτονιά $number';
  }

  @override
  String creationBadFileName(String name) {
    return 'Το «$name» έχει χαρακτήρες που δεν επιτρέπει το σύστημα σε όνομα αρχείου, οπότε το παιχνίδι δεν θα το έβρισκε ποτέ. Μετονόμασέ το και δοκίμασε ξανά.';
  }

  @override
  String creationFileInUse(String name) {
    return 'Το «$name» χρησιμοποιείται. Κλείσε το παιχνίδι και δοκίμασε ξανά.';
  }

  @override
  String get creationNeighborhoodFull =>
      'Αυτή η γειτονιά έχει ήδη και τα 99 σπίτια που χωράει. Σβήσε κάποιο που δεν παίζεις πριν προσθέσεις άλλο.';

  @override
  String creationInstallFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Αυτά τα $count αρχεία δεν μπήκαν.',
      one: 'Αυτό το αρχείο δεν μπήκε.',
    );
    return '$_temp0';
  }

  @override
  String creationRemoveFailed(String name) {
    return 'Το «$name» δεν διαγράφηκε.';
  }

  @override
  String get creationsAdd => 'Προσθήκη';

  @override
  String get creationsAdding => 'Γίνεται προσθήκη…';

  @override
  String creationsPickerLabel(String game) {
    return 'Οικόπεδα, δωμάτια, νοικοκυριά και sims για $game';
  }

  @override
  String get creationsNothingToAdd =>
      'Τίποτα εκεί μέσα δεν ήταν οικόπεδο, δωμάτιο, νοικοκυριό ή sim που να διαβάζει αυτό το παιχνίδι. Το custom content και τα mods μπαίνουν από τη βιβλιοθήκη.';

  @override
  String get householdEdit => 'Επεξεργασία';

  @override
  String get householdEditTitle => 'Επεξεργασία νοικοκυριού';

  @override
  String householdEditBody(String name) {
    return 'Άλλαξε ό,τι λέει το αρχείο για το «$name».';
  }

  @override
  String get householdEditName => 'Όνομα';

  @override
  String get householdEditFunds => 'Χρήματα';

  @override
  String householdEditFundsMax(String max) {
    return 'Έως $max, όσο αντέχει αυτό το παιχνίδι.';
  }

  @override
  String get householdEditSave => 'Αποθήκευση';

  @override
  String get householdEditNotice =>
      'Κλείσε πρώτα το παιχνίδι: ξαναγράφει το αρχείο του όταν βγαίνει. Κρατάμε αντίγραφο πριν από κάθε αλλαγή.';

  @override
  String get errorSaveEditHouseholdGone =>
      'Αυτό το νοικοκυριό δεν υπάρχει πια στο αρχείο. Ανανέωσε τη λίστα και ξαναδοκίμασε.';

  @override
  String errorSaveEditUnreadable(String file) {
    return 'Το «$file» δεν έχει τη δομή που ξέρει να ξαναγράφει η εφαρμογή, οπότε δεν άλλαξε τίποτα.';
  }

  @override
  String errorSaveEditVerification(String file) {
    return 'Το «$file» που ξαναγράφτηκε δεν διαβάστηκε σωστά, οπότε πετάχτηκε. Το αρχείο σου είναι άθικτο.';
  }

  @override
  String get errorSaveEditUnsupported =>
      'Τα αρχεία αυτού του παιχνιδιού διαβάζονται, αλλά δεν αλλάζουν.';
}
