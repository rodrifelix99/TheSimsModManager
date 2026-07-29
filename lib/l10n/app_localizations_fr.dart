// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class LFr extends L {
  LFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Sims Mod Manager';

  @override
  String get brandTitle => 'Mod Manager';

  @override
  String get brandSubtitle => 'pour Les Sims';

  @override
  String get navLibrary => 'Bibliothèque';

  @override
  String get navShop => 'The Exchange';

  @override
  String get navSettings => 'Réglages';

  @override
  String get shopAlphaBadge => 'ALPHA';

  @override
  String get shopTagline => 'Des mods de la communauté, installés en un clic.';

  @override
  String shopListingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods en rayon',
      one: '1 mod en rayon',
      zero: '0 mod en rayon',
    );
    return '$_temp0';
  }

  @override
  String get shopRefresh => 'Actualiser';

  @override
  String get shopPublish => 'Publie tes mods';

  @override
  String get shopLoadFailedTitle => 'The Exchange ne répond pas';

  @override
  String get shopLoadFailedBody =>
      'Impossible de charger les rayons. Vérifie ta connexion et réessaie.';

  @override
  String get shopRetry => 'Réessayer';

  @override
  String get shopEmptyTitle => 'Les rayons sont encore vides';

  @override
  String get shopEmptyBody =>
      'The Exchange vient tout juste d’ouvrir ses portes et personne n’a encore rien publié. C’est dire si c’est neuf. Tu crées des mods ? Inaugure les rayons !';

  @override
  String get shopAllGames => 'Tous les jeux';

  @override
  String get shopShowAllGames => 'Voir tous les jeux';

  @override
  String shopEmptyGameTitle(String game) {
    return 'Rien pour $game pour l’instant';
  }

  @override
  String shopEmptyGameBody(String game) {
    return 'D’autres jeux ont déjà des mods en rayon, mais personne n’a encore rien publié pour $game. Tu en as un ? À toi d’inaugurer le rayon !';
  }

  @override
  String shopBy(String author) {
    return 'par $author';
  }

  @override
  String get shopInstalled => 'Installé';

  @override
  String get shopUpdate => 'Mettre à jour';

  @override
  String get shopUpdateBadge => 'mise à jour';

  @override
  String shopUpdatesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de tes mods ont une nouvelle version sur The Exchange',
      one: '1 de tes mods a une nouvelle version sur The Exchange',
    );
    return '$_temp0';
  }

  @override
  String get shopUpdateHeading => 'Il existe une nouvelle version de ce mod';

  @override
  String shopUpdateBody(String version, String author) {
    return '$author a publié la v$version sur The Exchange. La mise à jour remplace les fichiers que tu as maintenant.';
  }

  @override
  String get shopUpdateSeeListing => 'Voir la fiche';

  @override
  String get shopInstalling => 'Installation…';

  @override
  String get shopInstallNotes => 'Notes d’installation';

  @override
  String get shopCreatorNudge =>
      'Tu crées des mods ? Publier sur The Exchange est gratuit, et les joueurs installent ton travail en un clic.';

  @override
  String shopNeedsFolder(String game) {
    return 'Configure d’abord le dossier de mods de $game. L’onglet Bibliothèque te guide.';
  }

  @override
  String shopVariations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count variantes',
      one: '1 variante',
    );
    return '$_temp0';
  }

  @override
  String get shopVariationPick => 'Choisis une variante';

  @override
  String get shopBack => 'Retour aux rayons';

  @override
  String get shopCopyLink => 'Copier le lien';

  @override
  String get shopLinkCopied => 'Lien copié';

  @override
  String get sidebarGames => 'JEUX';

  @override
  String sidebarNotInstalled(String detail) {
    return 'pas installé · $detail';
  }

  @override
  String sidebarModCount(int count, String detail) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods',
      one: '1 mod',
      zero: '0 mod',
    );
    return '$_temp0 · $detail';
  }

  @override
  String get updateAvailable => 'Mise à jour dispo';

  @override
  String updateClickToDownload(String version) {
    return 'v$version : clique pour télécharger';
  }

  @override
  String get storage => 'Stockage';

  @override
  String storageInMods(String size) {
    return '$size de mods';
  }

  @override
  String storageFreeOf(String free, String total) {
    return '$free libres sur $total';
  }

  @override
  String dropToInstall(String game) {
    return 'Dépose ici pour installer dans $game';
  }

  @override
  String get dropFolders => 'dossiers';

  @override
  String scanningMods(int done, int total) {
    return 'On regarde dans les mods pour trouver les images et les conflits… $done sur $total';
  }

  @override
  String get skip => 'Passer';

  @override
  String libraryTitle(String game) {
    return 'Bibliothèque $game';
  }

  @override
  String modsShown(int count, String era) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods affichés',
      one: '1 mod affiché',
      zero: '0 mod affiché',
    );
    return '$_temp0 · $era';
  }

  @override
  String get learnMore => 'En savoir plus';

  @override
  String get dismiss => 'Masquer';

  @override
  String get searchMods => 'Rechercher des mods…';

  @override
  String get viewGrid => 'Grille';

  @override
  String get viewList => 'Liste';

  @override
  String get viewFolders => 'Dossiers';

  @override
  String get libraryRefresh => 'Actualiser';

  @override
  String get libraryRootFolder => 'Dossier Mods';

  @override
  String get install => 'Installer';

  @override
  String filePickerModsLabel(String game) {
    return 'Mods $game';
  }

  @override
  String get installWhereTitle => 'Ça va où ?';

  @override
  String installWhereBody(String game) {
    return '$game lit les mods dans plusieurs dossiers. L’appli peut deviner d’après le fichier, ou tu lui dis où ça va.';
  }

  @override
  String get installWhereSorted => 'Décide pour moi';

  @override
  String get installWhereSortedDesc =>
      'Suit les dossiers fournis dans le téléchargement, puis range le reste par type de fichier.';

  @override
  String get installWhereRemember => 'Ne plus demander';

  @override
  String get destinationSims1Downloads =>
      'Objets, hacks et la plupart des téléchargements.';

  @override
  String get destinationSims1Global =>
      'Modifications qui changent tout le jeu de base.';

  @override
  String get destinationSims1Objects =>
      'Modifications des fichiers d’objets du jeu lui-même.';

  @override
  String get destinationSims1Skins =>
      'Peaux et têtes de tous les jours. Elles apparaissent dans Créer un Sim.';

  @override
  String get destinationSims1SkinsBuy =>
      'Vêtements vendus dans les boutiques des terrains communautaires.';

  @override
  String get destinationSims1Walls => 'Revêtements muraux.';

  @override
  String get destinationSims1Floors => 'Sols.';

  @override
  String get destinationSims1Roofs => 'Textures de toit.';

  @override
  String get prefAskWhereTitle => 'Demander où installer';

  @override
  String get prefAskWhereDesc =>
      'Ce jeu lit les mods dans plusieurs dossiers. Choisis le dossier à chaque fois au lieu de laisser l’appli décider';

  @override
  String get statTotal => 'Total';

  @override
  String get statEnabled => 'Actifs';

  @override
  String get statDisabled => 'Inactifs';

  @override
  String get statConflicts => 'Conflits';

  @override
  String get statTotalTooltip => 'Tous les mods de ce dossier, actifs ou non.';

  @override
  String get statTotalTooltipClear =>
      'Tous les mods de ce dossier. Clique pour effacer la recherche et les filtres.';

  @override
  String get statEnabledTooltip => 'Les mods que le jeu charge.';

  @override
  String get statEnabledTooltipActive =>
      'Seuls les mods actifs sont affichés. Clique pour revoir tous les mods.';

  @override
  String get statDisabledTooltip =>
      'Les mods posés dans le dossier mais désactivés.';

  @override
  String get statDisabledTooltipActive =>
      'Seuls les mods inactifs sont affichés. Clique pour revoir tous les mods.';

  @override
  String get conflictTooltipActive =>
      'Seuls les mods en conflit sont affichés. Clique pour revoir tous les mods.';

  @override
  String get conflictTooltip =>
      'Les mods actifs qui partagent un nom de fichier avec un autre mod actif, qui sont installés en plusieurs versions, ou qui écrasent les mêmes ressources du jeu. Le jeu ne garde que la copie chargée en dernier : parfois c’est voulu (mods correctifs), souvent non.';

  @override
  String get conflictTooltipClickHint => 'Clique pour n’afficher que ces mods.';

  @override
  String get filterAll => 'Tous';

  @override
  String get emptyFiltered => 'Aucun mod ne correspond aux filtres';

  @override
  String get emptyNoMods => 'Pas encore de mods';

  @override
  String get emptyFilteredHint =>
      'Essaie d’effacer la recherche ou de choisir un autre filtre.';

  @override
  String emptyNoModsHint(String path) {
    return 'Voici le dossier surveillé :\n$path';
  }

  @override
  String get openFolder => 'Ouvrir le dossier';

  @override
  String get conflictBadge => 'conflit';

  @override
  String modInFolder(String folder) {
    return 'dans $folder';
  }

  @override
  String get modInModsFolder => 'dans le dossier Mods';

  @override
  String setupFoundNoModsFolder(String game) {
    return '$game est là, mais pas encore de dossier de mods';
  }

  @override
  String setupNotFound(String game) {
    return 'Dossier de mods de $game introuvable';
  }

  @override
  String get setupFoundNoModsFolderBody =>
      'Le dossier du jeu est bien sur cet ordinateur, il ne contient simplement pas encore de dossier de mods. Crée-le ci-dessous, ou indique-en un à la main.';

  @override
  String get setupNotFoundBody =>
      'Le jeu n’est peut-être pas installé, peut-être rangé à un endroit inhabituel, ou son dossier de mods n’existe pas encore.';

  @override
  String get foundOnThisComputer => 'TROUVÉ SUR CET ORDINATEUR';

  @override
  String get chooseFolder => 'Choisir un dossier…';

  @override
  String get createItForMe => 'Crée-le pour moi';

  @override
  String willBeCreatedAt(String path) {
    return 'Sera créé ici :\n$path';
  }

  @override
  String get checkAgain => 'Revérifier';

  @override
  String get useThis => 'Utiliser celui-ci';

  @override
  String get enabled => 'Actif';

  @override
  String get disabled => 'Inactif';

  @override
  String get showInFileManager => 'Afficher dans l’explorateur';

  @override
  String get uninstallMod => 'Désinstaller le mod';

  @override
  String uninstallConfirmTitle(String title) {
    return 'Désinstaller $title ?';
  }

  @override
  String uninstallConfirmBody(String path) {
    return 'Le fichier sera supprimé du disque :\n$path';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get uninstall => 'Désinstaller';

  @override
  String conflictSameNameHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count autres mods actifs portent le même nom de fichier :',
      one: 'Un autre mod actif porte le même nom de fichier :',
    );
    return '$_temp0';
  }

  @override
  String conflictVersionHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count autres mods actifs ressemblent à d’autres versions de ce mod :',
      one: 'Un autre mod actif ressemble à une autre version de ce mod :',
    );
    return '$_temp0';
  }

  @override
  String conflictResourcesHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count autres mods actifs écrasent les mêmes ressources du jeu :',
      one: 'Un autre mod actif écrase les mêmes ressources du jeu :',
    );
    return '$_temp0';
  }

  @override
  String sharedResources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ressources en commun',
      one: '1 ressource en commun',
    );
    return '$_temp0';
  }

  @override
  String get conflictSameNameBody =>
      'Deux fichiers qui portent le même nom, c’est en général le même mod installé deux fois, ou les paquets de deux créateurs qui se marchent dessus. Le jeu charge leurs ressources communes dans un ordre imprévisible : garde-en un et désactive ou supprime le reste.';

  @override
  String get conflictVersionBody =>
      'Avoir plusieurs versions d’un même mod installées oblige le jeu à charger leurs ressources communes dans un ordre imprévisible : garde la plus récente et désactive ou supprime les autres.';

  @override
  String get conflictResourcesBody =>
      'Ces paquets contiennent des ressources aux mêmes identifiants, donc le jeu ne garde que la copie chargée en dernier. Ça peut être voulu (les mods correctifs et les overrides recouvrent les ressources d’un autre mod exprès), mais entre mods sans rapport, ça veut dire que l’un d’eux cesse de fonctionner sans rien dire : garde celui que tu veux et désactive les autres.';

  @override
  String advisoryBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de tes mods ont des problèmes connus',
      one: 'Un de tes mods a un problème connu',
    );
    return '$_temp0';
  }

  @override
  String get advisoryShow => 'Y jeter un œil';

  @override
  String get advisoryShowAll => 'Afficher tous les mods';

  @override
  String get advisoryBadge => 'problème';

  @override
  String get advisoryBrokenHeading => 'Ce mod est signalé comme cassé';

  @override
  String get advisoryBrokenBody =>
      'D\'autres joueurs signalent que celui-ci empêche le jeu de tourner. Le désactiver, c\'est le plus rapide pour savoir si c\'est lui le coupable.';

  @override
  String get advisoryOutdatedHeading =>
      'Il existe une version plus récente de ce mod';

  @override
  String get advisoryOutdatedBody =>
      'La version que tu as est justement celle qui pose problème. Récupérer la dernière du créateur devrait régler ça.';

  @override
  String get advisoryCautionHeading => 'À garder à l\'œil';

  @override
  String get advisoryCautionBody =>
      'Ça marche pour la plupart des gens, mais il est connu pour faire des siennes. À désactiver si tu cherches d\'où vient un souci.';

  @override
  String advisorySince(String since) {
    return 'Depuis $since';
  }

  @override
  String get advisoryOpenLink => 'Ouvrir la page du créateur';

  @override
  String get advisorySource => 'Signalé par d\'autres joueurs, pas par le jeu.';

  @override
  String modInDirectory(String dir) {
    return 'dans $dir';
  }

  @override
  String get factVersion => 'Version';

  @override
  String get factFormat => 'Format';

  @override
  String get factSize => 'Taille';

  @override
  String get factType => 'Type';

  @override
  String get factModified => 'Modifié';

  @override
  String get factDownloads => 'Téléchargements';

  @override
  String get statusHeading => 'État';

  @override
  String get statusEnabledBody =>
      'Ce mod est actif : le jeu le chargera au prochain lancement.';

  @override
  String statusDisabledBody(String marker) {
    return 'Ce mod est désactivé : le fichier reste sur le disque avec la marque « $marker » pour que le jeu l’ignore. Tu peux le réactiver quand tu veux, rien n’est supprimé.';
  }

  @override
  String get fileOnDisk => 'Fichier sur le disque';

  @override
  String get insideThePackage => 'Dans le paquet';

  @override
  String resourcesTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ressources au total',
      one: '1 ressource au total',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get sectionModManagement => 'GESTION DES MODS';

  @override
  String get sectionAppearance => 'APPARENCE';

  @override
  String get sectionLanguage => 'LANGUE';

  @override
  String get sectionPrivacy => 'CONFIDENTIALITÉ';

  @override
  String sectionModsFolder(String game) {
    return 'DOSSIER DE MODS · $game';
  }

  @override
  String sectionGameCaches(String game) {
    return 'CACHES DU JEU · $game';
  }

  @override
  String get sectionFeedback => 'VOS RETOURS';

  @override
  String get sectionAbout => 'À PROPOS';

  @override
  String get prefWarnConflictsTitle => 'Prévenir des conflits';

  @override
  String get prefWarnConflictsDesc =>
      'Signale les mods actifs qui reprennent un nom de fichier ou qui écrasent les mêmes ressources du jeu qu’un autre mod';

  @override
  String get prefConfirmDeleteTitle => 'Confirmer avant de désinstaller';

  @override
  String get prefConfirmDeleteDesc =>
      'Demander avant de supprimer un fichier de mod du disque';

  @override
  String get prefShowDisabledTitle => 'Afficher les mods désactivés';

  @override
  String get prefShowDisabledDesc =>
      'Garde les mods désactivés visibles dans la bibliothèque au lieu de les cacher';

  @override
  String get prefScanArtworkTitle => 'Analyser l’intérieur des mods';

  @override
  String get prefScanArtworkDesc =>
      'Regarde dans les fichiers de mod pendant le chargement de la bibliothèque pour en tirer les images, le détail du contenu et les mods qui écrasent les mêmes ressources';

  @override
  String get prefSoundEffectsTitle => 'Effets sonores';

  @override
  String get prefSoundEffectsDesc =>
      'Joue les sons d’interface cultes des Sims sur les clics, les interrupteurs et les alertes';

  @override
  String get prefAnalyticsTitle => 'Partager des données d’usage anonymes';

  @override
  String get prefAnalyticsDesc =>
      'Envoie des statistiques d’usage et des rapports de plantage anonymes pour aider à améliorer l’appli. N’inclut jamais de noms de mods, de chemins de fichiers ni quoi que ce soit de personnel';

  @override
  String get themeTitle => 'Thème';

  @override
  String get themeDesc =>
      'Clair ou sombre. « Système » suit le réglage de ton ordinateur.';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get languageTitle => 'Langue de l’appli';

  @override
  String get languageDesc =>
      'Choisis la langue dans laquelle l’appli s’affiche. « Système » suit la langue de ton ordinateur.';

  @override
  String get languageSystem => 'Système';

  @override
  String get translatorsTitle => 'Traduit par';

  @override
  String get translatorsDesc =>
      'L’appli parle dix langues grâce à ces simmers.';

  @override
  String get folderNotFound => 'Introuvable. Choisis un dossier';

  @override
  String get folderNotLocated =>
      'Le jeu (ou son dossier de mods) n’a pas été trouvé automatiquement';

  @override
  String folderSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods',
      one: '1 mod',
      zero: '0 mod',
    );
    return '$_temp0 · $size sur le disque';
  }

  @override
  String get customFolder => 'dossier personnalisé';

  @override
  String get change => 'Changer…';

  @override
  String get resetToAuto => 'Revenir à l’auto';

  @override
  String createDefaultFolderAt(String path) {
    return 'Créer le dossier par défaut (avec les fichiers dont le jeu a besoin) ici :\n$path';
  }

  @override
  String get createFolder => 'Créer le dossier';

  @override
  String get alsoFoundOnThisComputer => 'Aussi trouvés sur cet ordinateur :';

  @override
  String get clearCacheTitle => 'Vider les fichiers de cache';

  @override
  String clearCacheDesc(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Supprime $count fichiers de cache ($size)',
      one: 'Supprime 1 fichier de cache ($size)',
    );
    return '$_temp0 pour que le contenu ajouté ou retiré apparaisse ; le jeu les reconstruit au prochain lancement';
  }

  @override
  String get clearCaches => 'Vider les caches';

  @override
  String get reportBugTitle => 'Signaler un bug';

  @override
  String get reportBugDesc =>
      'Ouvre un rapport de bug sur GitHub, avec la version de l’appli, ton système et le jeu actuel déjà remplis';

  @override
  String get reportBugButton => 'Signaler…';

  @override
  String get suggestFeatureTitle => 'Proposer une idée';

  @override
  String get suggestFeatureDesc =>
      'Il te manque quelque chose ? Dis-nous ce qui rendrait le gestionnaire de mods meilleur';

  @override
  String get suggestFeatureButton => 'Proposer…';

  @override
  String get wikiTitle => 'Guide et FAQ';

  @override
  String get wikiDesc =>
      'Comment installer des mods, corriger la détection des dossiers, et plus encore, sur le wiki du projet';

  @override
  String get wikiButton => 'Ouvrir le wiki';

  @override
  String aboutTagline(String version) {
    return 'Version $version · Les Sims 1-4 pris en charge · SimCity bientôt';
  }

  @override
  String updateIsAvailable(String version) {
    return 'La version $version est disponible';
  }

  @override
  String get noUpdateFound => 'Aucune mise à jour';

  @override
  String getVersion(String version) {
    return 'Obtenir la v$version';
  }

  @override
  String get checkingForUpdates => 'Vérification…';

  @override
  String get checkForUpdates => 'Rechercher des mises à jour';

  @override
  String get categoryPackage => 'Paquet';

  @override
  String get categoryScript => 'Script';

  @override
  String get categoryObject => 'Objet';

  @override
  String get categoryArchive => 'Archive';

  @override
  String get categorySkin => 'Skin';

  @override
  String get categoryTexture => 'Texture';

  @override
  String get categoryWall => 'Mur';

  @override
  String get categoryFloor => 'Sol';

  @override
  String get contentCasParts => 'éléments CAS';

  @override
  String get contentObjects => 'objets';

  @override
  String get contentTunings => 'tunings';

  @override
  String get contentBehaviors => 'comportements';

  @override
  String get contentTextTables => 'tables de texte';

  @override
  String get contentTextures => 'textures';

  @override
  String get contentMeshes => 'maillages';

  @override
  String errorNoModFiles(String extensions, String name) {
    return 'Aucun fichier de mod ($extensions) dans $name.';
  }

  @override
  String errorUnreadableArchive(String name) {
    return '$name n’est pas une archive zip que l’app sait lire.';
  }

  @override
  String errorNoUnpacker(String format, String name) {
    return 'Rien sur cet ordinateur ne sait décompresser les archives $format. Décompresse $name toi-même et installe les fichiers qu’elle contient.';
  }

  @override
  String errorNoUnpackerLinux(String format, String name) {
    return 'Rien sur cet ordinateur ne sait décompresser les archives $format. Installe p7zip et réessaie, ou décompresse $name toi-même et installe les fichiers qu’elle contient.';
  }

  @override
  String errorNoUnpackerLinuxRar(String format, String name) {
    return 'Rien sur cet ordinateur ne sait décompresser les archives $format. Installe p7zip ou unrar et réessaie, ou décompresse $name toi-même et installe les fichiers qu’elle contient.';
  }

  @override
  String errorUnpackFailed(String name) {
    return 'Impossible de décompresser $name. Elle est peut-être protégée par un mot de passe, c’est peut-être une partie d’une archive découpée ou un téléchargement abîmé. Décompresse-la à la main et installe les fichiers qu’elle contient.';
  }

  @override
  String errorSims3PackUnreadable(String name) {
    return '$name n’est pas un paquet Les Sims 3 que cette appli sait lire.';
  }

  @override
  String errorSims3PackWorld(String name) {
    return '$name est un monde, pas du contenu personnalisé. Installe-le avec le Launcher des Sims 3 : le jeu range les mondes en dehors du dossier de mods.';
  }

  @override
  String errorSims3PackLibrary(String name) {
    return '$name est un terrain ou un ménage, pas du contenu personnalisé. Installe-le avec le Launcher des Sims 3 : il atterrit dans ta Bibliothèque en jeu.';
  }

  @override
  String errorInstallFailed(String name, String reason) {
    return '« $name » n’a pas pu être installé : $reason. Si ça continue, décompresse-le à la main et installe les fichiers qu’il contient.';
  }

  @override
  String errorInstallFailedRaw(String name, String reason) {
    return '« $name » n’a pas pu être installé : $reason';
  }

  @override
  String errorFileInUseDelete(String name) {
    return '« $name » n’a pas pu être supprimé : un autre programme l’utilise (le jeu est lancé ?) ou il est protégé en écriture. Ferme ce qui l’utilise et réessaie.';
  }

  @override
  String errorFileInUseRename(String name) {
    return '« $name » n’a pas pu être renommé : un autre programme l’utilise (le jeu est lancé ?) ou il est protégé en écriture. Ferme ce qui l’utilise et réessaie.';
  }

  @override
  String errorFileMissing(String name) {
    return '« $name » n’est plus dans le dossier de mods : un autre programme l’a peut-être déplacé ou supprimé.';
  }

  @override
  String get requirementMedievalModLoader =>
      'Les Sims Medieval ne peut pas faire tourner de mods de script ou de core sans le fichier chargeur de la communauté dans le dossier Game\\Bin du jeu. Le contenu personnalisé fonctionne quand même ; le reste, non.';

  @override
  String get requirementSims4ModsOff =>
      'Le jeu a désactivé le contenu personnalisé et les mods dans ses propres options, donc rien ne se charge. Réactive ça dans Options → Options de jeu → Autre, puis relance le jeu.';

  @override
  String get requirementSims4ScriptModsOff =>
      'Tu as des mods de script ici, mais le jeu a « Autoriser les mods de script » désactivé dans ses options. Les mises à jour remettent ça à zéro.';

  @override
  String get requirementGetFile => 'Où le trouver';

  @override
  String tooDeepBanner(int count, int levels) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods sont',
      one: 'Un mod est',
    );
    return '$_temp0 dans un sous-dossier que le jeu ne lit pas. Il ne descend que de $levels dossiers, alors remonte-les d’un cran et ils se chargeront.';
  }

  @override
  String get tooDeepShow => 'Montre-les-moi';

  @override
  String errorNoWriteAccess(String folder) {
    return 'L’appli n’a pas le droit d’écrire dans « $folder ». Ton système protège ce dossier : donne à ton compte l’accès en écriture, ou choisis un autre dossier dans les Réglages.';
  }

  @override
  String get folderReadOnlyBanner =>
      'Ce dossier de mods est en lecture seule : installer et retirer des mods ne marchera pas tant que ton compte ne peut pas y écrire.';

  @override
  String get elevatedNoDropBanner =>
      'Tu es en administrateur, du coup Windows empêche de glisser des fichiers sur la fenêtre. Passe par le bouton Installer, lui marche toujours.';

  @override
  String errorShopDownload(String name) {
    return '« $name » n’a pas pu être téléchargé depuis The Exchange. Vérifie ta connexion et réessaie.';
  }

  @override
  String get errorShopListingNotFound =>
      'Ce mod n’est plus sur The Exchange. Il a peut-être été retiré.';

  @override
  String get errorShopListingUnknownGame =>
      'Ce mod est pour un jeu que cette version de l’appli ne connaît pas encore. Essaie de la mettre à jour.';

  @override
  String get eraClassic => 'Classique';

  @override
  String get eraNightlife => 'Nuits de folie';

  @override
  String get eraAmbitions => 'Ambitions';

  @override
  String get eraModern => 'Moderne';

  @override
  String get eraMedieval => 'Médiéval';

  @override
  String get navSaves => 'Sauvegardes';

  @override
  String get savesScanning => 'Lecture de tes sauvegardes…';

  @override
  String get savesEmptyTitle => 'Aucune sauvegarde trouvée';

  @override
  String savesEmptyBody(String game) {
    return 'Dès que tu joues à $game et que tu sauvegardes, tes mondes s\'affichent ici : familles, photos et tout le reste.';
  }

  @override
  String get savesRescan => 'Relancer la recherche';

  @override
  String savesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sauvegardes trouvées',
      one: '1 sauvegarde trouvée',
    );
    return '$_temp0';
  }

  @override
  String savesLastSaved(String date) {
    return 'Dernière sauvegarde : $date';
  }

  @override
  String get savesShowInFolder => 'Afficher dans le dossier';

  @override
  String savesBackups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count copies de secours',
      one: '1 copie de secours',
    );
    return '$_temp0';
  }

  @override
  String get savesTabHouseholds => 'Foyers';

  @override
  String get savesTabAlbum => 'Album photo';

  @override
  String get savesTabStats => 'Statistiques';

  @override
  String savesNeighborhood(int number) {
    return 'Quartier $number';
  }

  @override
  String get savesOtherHouseholds => 'PNJ et autres foyers';

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
  String get savesFunds => 'Fonds';

  @override
  String get savesRooms => 'Pièces';

  @override
  String savesBedsBaths(int beds, int baths) {
    return '$beds ch. · $baths sdb';
  }

  @override
  String savesByCreator(String name) {
    return 'par $name';
  }

  @override
  String get savesMembers => 'Membres';

  @override
  String get savesRelationships => 'Relations';

  @override
  String get savesUnknownSim => 'Sim inconnu';

  @override
  String get savesStatSims => 'Sims';

  @override
  String get savesStatHouseholds => 'Foyers';

  @override
  String get savesStatNetWorth => 'Patrimoine';

  @override
  String get savesStatWorlds => 'Mondes';

  @override
  String get savesStatPhotos => 'Photos';

  @override
  String savesAcrossHouseholds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'dans $count foyers',
      one: 'dans 1 foyer',
    );
    return '$_temp0';
  }

  @override
  String savesPlayedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count joués',
      one: '1 joué',
    );
    return '$_temp0';
  }

  @override
  String get savesSizeOnDisk => 'Espace disque';

  @override
  String get savesLifeStages => 'Étapes de la vie';

  @override
  String get savesTopSkills => 'Meilleures compétences de cette partie';

  @override
  String get savesSaveInfo => 'Fichier de sauvegarde';

  @override
  String get savesLastSavedLabel => 'Dernière sauvegarde';

  @override
  String get savesGameVersion => 'Version du jeu';

  @override
  String get savesDescription => 'Description';

  @override
  String get savesAgeInfant => 'Nourrisson';

  @override
  String get savesAgeBaby => 'Bébé';

  @override
  String get savesAgeToddler => 'Bambin';

  @override
  String get savesAgeChild => 'Enfant';

  @override
  String get savesAgeTeen => 'Ado';

  @override
  String get savesAgeYoungAdult => 'Jeune adulte';

  @override
  String get savesAgeAdult => 'Adulte';

  @override
  String get savesAgeElder => 'Senior';

  @override
  String get savesGenderMale => 'Homme';

  @override
  String get savesGenderFemale => 'Femme';

  @override
  String get savesSkillCooking => 'Cuisine';

  @override
  String get savesSkillMechanical => 'Mécanique';

  @override
  String get savesSkillCharisma => 'Charisme';

  @override
  String get savesSkillBody => 'Physique';

  @override
  String get savesSkillLogic => 'Logique';

  @override
  String get savesSkillCreativity => 'Créativité';

  @override
  String get savesSkillCleaning => 'Ménage';

  @override
  String get savesPersonalityNeat => 'Ordonné';

  @override
  String get savesPersonalityOutgoing => 'Extraverti';

  @override
  String get savesPersonalityActive => 'Actif';

  @override
  String get savesPersonalityPlayful => 'Joueur';

  @override
  String get savesPersonalityNice => 'Gentil';

  @override
  String get savesZodiacAries => 'Bélier';

  @override
  String get savesZodiacTaurus => 'Taureau';

  @override
  String get savesZodiacGemini => 'Gémeaux';

  @override
  String get savesZodiacCancer => 'Cancer';

  @override
  String get savesZodiacLeo => 'Lion';

  @override
  String get savesZodiacVirgo => 'Vierge';

  @override
  String get savesZodiacLibra => 'Balance';

  @override
  String get savesZodiacScorpio => 'Scorpion';

  @override
  String get savesZodiacSagittarius => 'Sagittaire';

  @override
  String get savesZodiacCapricorn => 'Capricorne';

  @override
  String get savesZodiacAquarius => 'Verseau';

  @override
  String get savesZodiacPisces => 'Poissons';

  @override
  String get savesAspirationRomance => 'Romance';

  @override
  String get savesAspirationFamily => 'Famille';

  @override
  String get savesAspirationFortune => 'Fortune';

  @override
  String get savesAspirationPopularity => 'Popularité';

  @override
  String get savesAspirationKnowledge => 'Connaissance';

  @override
  String get savesAspirationGrowUp => 'Grandir';

  @override
  String get savesAspirationPleasure => 'Plaisir';

  @override
  String get savesAspirationGrilledCheese => 'Croque-monsieur';

  @override
  String get savesRelCrush => 'béguin';

  @override
  String get savesRelLove => 'amoureux';

  @override
  String get savesRelEngaged => 'fiancés';

  @override
  String get savesRelMarried => 'mariés';

  @override
  String get savesRelFriends => 'amis';

  @override
  String get savesRelBestFriends => 'meilleurs amis';

  @override
  String get savesRelSteady => 'en couple';

  @override
  String get savesRelEnemies => 'ennemis';

  @override
  String get savesPhotoFamilyPortrait => 'Portrait de famille';

  @override
  String get savesPhotoLot => 'Terrain';

  @override
  String get savesPhotoSim => 'Portrait de Sim';

  @override
  String get savesPhotoSnapshot => 'Photo';

  @override
  String get savesProperty => 'Patrimoine';

  @override
  String get savesGhost => 'fantôme';

  @override
  String savesCareerLevel(String career, int level) {
    return '$career · niveau $level';
  }

  @override
  String get savesSpeciesLargeDog => 'chien';

  @override
  String get savesSpeciesSmallDog => 'petit chien';

  @override
  String get savesSpeciesCat => 'chat';

  @override
  String get savesOccultVampire => 'vampire';

  @override
  String get savesOccultZombie => 'zombie';

  @override
  String get savesOccultWerewolf => 'loup-garou';

  @override
  String get savesOccultPlantSim => 'SimPlante';

  @override
  String get savesOccultAlien => 'extraterrestre';

  @override
  String get savesOccultServo => 'servo';

  @override
  String get savesOccultWitch => 'sorcière';

  @override
  String get savesOccultBigfoot => 'Bigfoot';

  @override
  String get savesOccultFairy => 'fée';

  @override
  String get savesOccultGenie => 'génie';

  @override
  String get savesOccultMermaid => 'sirène';

  @override
  String get savesLotResidential => 'Résidentiel';

  @override
  String get savesLotCommunity => 'Terrain communautaire';

  @override
  String get savesLotDorm => 'Résidence';

  @override
  String get savesLotSecretSociety => 'Société secrète';

  @override
  String get savesLotGreekHouse => 'Maison grecque';

  @override
  String get savesLotHotel => 'Hôtel';

  @override
  String get savesLotSecret => 'Terrain secret';

  @override
  String get savesLotBusiness => 'Commerce';

  @override
  String get savesLotApartment => 'Appartement';

  @override
  String savesGpa(String gpa) {
    return 'moyenne $gpa';
  }

  @override
  String savesSemester(int number) {
    return 'semestre $number';
  }

  @override
  String savesPredestinedHobby(String hobby) {
    return 'Né pour $hobby';
  }

  @override
  String get savesHobbyCuisine => 'Cuisine';

  @override
  String get savesHobbyArts => 'Arts et loisirs';

  @override
  String get savesHobbyFilm => 'Cinéma et littérature';

  @override
  String get savesHobbySports => 'Sport';

  @override
  String get savesHobbyGames => 'Jeux';

  @override
  String get savesHobbyNature => 'Nature';

  @override
  String get savesHobbyTinkering => 'Bricolage';

  @override
  String get savesHobbyFitness => 'Forme';

  @override
  String get savesHobbyScience => 'Science';

  @override
  String get savesHobbyMusic => 'Musique et danse';

  @override
  String get savesTieMother => 'mère';

  @override
  String get savesTieFather => 'père';

  @override
  String get savesTieSpouse => 'marié à';

  @override
  String savesTieSibling(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'frères et sœurs',
      one: 'frère ou sœur',
    );
    return '$_temp0';
  }

  @override
  String savesTieChild(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'enfants',
      one: 'enfant',
    );
    return '$_temp0';
  }

  @override
  String get savesInterestPolitics => 'Politique';

  @override
  String get savesInterestMoney => 'Argent';

  @override
  String get savesInterestEnvironment => 'Environnement';

  @override
  String get savesInterestCrime => 'Crime';

  @override
  String get savesInterestEntertainment => 'Divertissement';

  @override
  String get savesInterestCulture => 'Culture';

  @override
  String get savesInterestFood => 'Cuisine';

  @override
  String get savesInterestHealth => 'Santé';

  @override
  String get savesInterestFashion => 'Mode';

  @override
  String get savesInterestSports => 'Sport';

  @override
  String get savesInterestParanormal => 'Paranormal';

  @override
  String get savesInterestTravel => 'Voyages';

  @override
  String get savesInterestWork => 'Travail';

  @override
  String get savesInterestWeather => 'Météo';

  @override
  String get savesInterestAnimals => 'Animaux';

  @override
  String get savesInterestSchool => 'École';

  @override
  String get savesInterestToys => 'Jouets';

  @override
  String get savesInterestSciFi => 'Science-fiction';

  @override
  String get savesInterestMusic => 'Musique';

  @override
  String get savesInterestOutdoors => 'Plein air';

  @override
  String get setupHelpSims1 =>
      'Le tout premier Les Sims garde le contenu personnalisé dans son dossier d’installation, pas dans Documents : les objets vont dans un dossier Downloads à côté de l’exécutable du jeu (par exemple C:\\Program Files (x86)\\Maxis\\The Sims\\Downloads), et l’appli range les autres types toute seule : les skins (.skn/.cmx/.bmp) dans GameData\\Skins, les murs et les sols dans GameData\\Walls et GameData\\Floors. La Legacy Collection de 2025 fonctionne pareil depuis son propre dossier d’installation (EA Games\\The Sims Legacy, ou Steam\\steamapps\\common\\The Sims Legacy Collection). Si le jeu est installé ailleurs (autre disque, bibliothèque Steam personnalisée), choisis son dossier Downloads à la main.';

  @override
  String get setupHelpSims2 =>
      'Les Sims 2 charge le contenu personnalisé depuis Documents > EA Games > Les Sims 2 > Downloads (l’Ultimate Collection utilise « The Sims 2 Ultimate Collection », la Legacy Collection de 2025 utilise « The Sims 2 Legacy »). Le dossier peut ne pas exister tant que tu ne l’as pas créé ou que tu n’as pas installé de contenu une première fois. Au lancement du jeu, réponds « Oui » à la question sur le contenu personnalisé pour activer les téléchargements.';

  @override
  String get setupHelpSims3 =>
      'Les Sims 3 ne crée pas son dossier de mods tout seul : il lui faut le « framework » de la communauté, c’est-à-dire un dossier Mods > Packages dans Documents > Electronic Arts > Les Sims 3, plus un fichier Resource.cfg qui dit au jeu de le lire. L’appli peut créer les deux pour toi. Sur les installations disque ou Wine, le dossier peut se trouver dans le paquet du jeu ; utilise « Choisir un dossier » pour l’indiquer.';

  @override
  String get setupHelpSims4 =>
      'Les Sims 4 charge les mods depuis Documents > Electronic Arts > Les Sims 4 > Mods. Le jeu crée ce dossier à son premier lancement, alors lance-le une fois s’il n’est pas là. Ensuite, dans le jeu, active Options > Options de jeu > Autre > « Activer les contenus personnalisés et les mods » (et « Autoriser les mods de script » pour les fichiers .ts4script), puis redémarre le jeu.';

  @override
  String get setupHelpSimsMedieval =>
      'Les Sims Medieval charge les mods depuis son dossier d’installation, pas depuis Documents : un dossier Mods > Packages à côté des fichiers du jeu (par exemple C:\\Program Files (x86)\\Origin Games\\The Sims Medieval), plus un fichier Resource.cfg dans le dossier d’installation qui dit au jeu de le lire. L’appli peut créer les deux pour toi (Windows peut demander des droits administrateur dans Program Files). Le dossier Documents > Electronic Arts > The Sims Medieval ne contient que les sauvegardes ; les mods placés là ne font rien. Pour une installation Wine/CrossOver ou une bibliothèque Steam personnalisée, utilise « Choisir un dossier » et indique le dossier Mods > Packages à l’intérieur de l’installation.';
}
