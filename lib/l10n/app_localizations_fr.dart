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
  String get brandSubtitle => 'pour Les Sims et SimCity';

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
  String get shopSaveFile => 'Télécharger';

  @override
  String get shopSaving => 'Téléchargement…';

  @override
  String get shopSaved => 'Enregistré';

  @override
  String get shopSaveHint =>
      'Installer met les fichiers directement dans ton dossier de mods. Télécharger enregistre juste le fichier, là où tu veux.';

  @override
  String get shopRequires => 'Nécessite ces packs';

  @override
  String get shopRequirementMet => 'Installé';

  @override
  String get shopRequirementDisabled => 'Désactivé';

  @override
  String get shopRequirementMissing => 'Pas installé';

  @override
  String get shopRequirementUnknown => 'Non vérifié';

  @override
  String get shopRequirementsNote =>
      'Tu peux quand même l’installer — il ne fera simplement pas grand-chose tant que les packs ne sont pas là.';

  @override
  String get shopRequirementsOffNote =>
      'L’un d’eux est désactivé. Réactive-le dans l’onglet Packs.';

  @override
  String get shopRequirementsUnknownNote =>
      'On n’a pas pu vérifier les packs de ce jeu sur cet ordinateur, donc c’est la parole du créateur.';

  @override
  String get shopDestination => 'S’installe dans';

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
  String get sortTooltip => 'Trier';

  @override
  String get sortByName => 'Nom (A–Z)';

  @override
  String get sortByRecent => 'Modifiés récemment';

  @override
  String get sortBySize => 'Les plus gros d’abord';

  @override
  String get sortDisabledLast => 'Les désactivés à la fin';

  @override
  String get libraryRefresh => 'Actualiser';

  @override
  String get libraryRootFolder => 'Dossier Mods';

  @override
  String get selectionTooltip => 'Sélectionner';

  @override
  String selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sélectionnés',
      one: '1 sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get selectionSelectAll => 'Tout sélectionner';

  @override
  String get selectionClear => 'Tout désélectionner';

  @override
  String get selectionEnable => 'Activer';

  @override
  String get selectionDisable => 'Désactiver';

  @override
  String selectionProgress(int done, int total) {
    return '$done sur $total';
  }

  @override
  String selectionDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Désinstaller $count mods ?',
      one: 'Désinstaller 1 mod ?',
    );
    return '$_temp0';
  }

  @override
  String selectionDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Les $count fichiers seront supprimés du disque. Pas de retour en arrière.',
      one: 'Le fichier sera supprimé du disque. Pas de retour en arrière.',
    );
    return '$_temp0';
  }

  @override
  String get selectionMove => 'Déplacer vers…';

  @override
  String get newFolder => 'Nouveau dossier';

  @override
  String newFolderIn(String folder) {
    return 'Dans $folder';
  }

  @override
  String get newFolderHint => 'Nom du dossier';

  @override
  String get create => 'Créer';

  @override
  String get move => 'Déplacer';

  @override
  String moveTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Déplacer $count mods où ?',
      one: 'Déplacer 1 mod où ?',
    );
    return '$_temp0';
  }

  @override
  String get moveBody =>
      'Les fichiers changent de dossier sur le disque. Rien d’autre ne bouge : ce qui est désactivé le reste.';

  @override
  String get installFolderTitle => 'Quel dossier ?';

  @override
  String installFolderBody(String game) {
    return 'Où les fichiers atterrissent dans ton dossier de mods de $game.';
  }

  @override
  String get installFolderChoose => 'Choisir';

  @override
  String get installFolderEmpty =>
      'Pas encore de sous-dossier. Crées-en un, ou laisse tout dans le dossier de mods.';

  @override
  String get folderEmptySection => 'Rien ici pour l’instant';

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
  String get duplicateBadge => 'copie';

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
  String conflictSameFileHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count autres mods actifs sont exactement le même fichier :',
      one: 'Un autre mod actif est exactement le même fichier :',
    );
    return '$_temp0';
  }

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
  String get conflictSameFileBody =>
      'L’analyse des doublons a lu ces fichiers et ils sont identiques octet pour octet : ce ne sont pas deux mods qui se disputent, c’est le même téléchargement présent plusieurs fois dans ton dossier. Garde-en un et supprime le reste : rien ne change dans le jeu et tu récupères la place.';

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
  String get conflictIgnore => 'Ignorer';

  @override
  String get conflictIgnoreTooltip =>
      'Si ce conflit est voulu, masque-le. Le mod ne change en rien, et tu peux réafficher l\'avertissement depuis cette page ou depuis les réglages.';

  @override
  String get conflictRestore => 'Réafficher';

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
  String get factIgnoredConflicts => 'Ignorés';

  @override
  String ignoredConflictsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conflits',
      one: '1 conflit',
    );
    return '$_temp0';
  }

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
  String sectionIgnoredConflicts(String game) {
    return 'CONFLITS IGNORÉS · $game';
  }

  @override
  String sectionShopFolder(String game) {
    return 'THE EXCHANGE · $game';
  }

  @override
  String get prefShopFolderTitle => 'Où vont les mods de The Exchange';

  @override
  String prefShopFolderDesc(String folder) {
    return 'Les installations vont dans $folder';
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
  String get prefConflictKindsTitle => 'Quels conflits signaler';

  @override
  String get prefConflictKindsDesc =>
      'Désactive les types que tu ne veux pas voir signalés. Les autres continuent comme avant';

  @override
  String get conflictKindSameFile => 'Copies identiques';

  @override
  String get conflictKindSameName => 'Même nom de fichier';

  @override
  String get conflictKindVersions => 'Versions différentes';

  @override
  String get conflictKindResources => 'Ressources partagées';

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
  String get prefDisabledSuffixTitle => 'Marqueur des mods désactivés';

  @override
  String get prefDisabledSuffixDesc =>
      'Ce qui s’ajoute au nom du fichier quand tu désactives un mod. Change-le pour coller à un autre gestionnaire (CC Magic utilise .off) ; l’appli lit les deux de toute façon, et les mods déjà désactivés gardent le nom qu’ils ont';

  @override
  String get prefDisabledSuffixInvalid =>
      'Il faut un point et quelques lettres ou chiffres, comme .off';

  @override
  String get prefExperimentalPacksTitle =>
      'Interrupteurs de packs expérimentaux';

  @override
  String get prefExperimentalPacksDesc =>
      'Permet de désactiver les packs de ce jeu. Non testé sur cette édition, et un quartier joué avec un pack peut casser sans lui : sauvegarde tes parties d’abord';

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
  String get appThemeTitle => 'Thème de l’appli';

  @override
  String get appThemeDesc =>
      'L’allure de toute l’appli. Elle ne bouge pas, quel que soit le jeu que tu gères.';

  @override
  String get appThemeDefault => 'Par défaut';

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
      'L’appli parle douze langues grâce à ces simmers.';

  @override
  String get sectionStartup => 'DÉMARRAGE';

  @override
  String get prefDefaultGameTitle => 'Jeu à l’ouverture';

  @override
  String get prefDefaultGameDesc =>
      'La bibliothèque sur laquelle l’appli démarre';

  @override
  String get defaultGameAuto => 'Automatique';

  @override
  String get prefSetupGuideTitle => 'Guide de départ';

  @override
  String get prefSetupGuideDesc =>
      'Repasse par les questions du premier lancement';

  @override
  String get onboardingReplay => 'Le refaire';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingSkipIntro => 'Passer l’intro';

  @override
  String get onboardingBack => 'Retour';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingFinish => 'Ouvrir ma bibliothèque';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Étape $current sur $total';
  }

  @override
  String get onboardingWelcomeTitle => 'Salut ! On configure tout ça';

  @override
  String get onboardingWelcomeBody =>
      'Quelques questions rapides et tes mods sont prêts. Ça prend moins d’une minute, et tout se change plus tard dans les Réglages.';

  @override
  String get onboardingGamesTitle => 'On cherche tes jeux';

  @override
  String get onboardingGamesBody =>
      'On regarde aux endroits habituels pour chaque jeu et pour le dossier d’où il lit les mods.';

  @override
  String get onboardingScanning => 'Recherche en cours…';

  @override
  String onboardingGamesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jeux trouvés',
      one: '1 jeu trouvé',
      zero: 'Rien pour l’instant',
    );
    return '$_temp0';
  }

  @override
  String onboardingGameMods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods déjà installés',
      one: '1 mod déjà installé',
      zero: 'Dossier de mods prêt',
    );
    return '$_temp0';
  }

  @override
  String get onboardingGameMissing => 'Pas sur cet ordinateur';

  @override
  String get onboardingNoGamesTitle => 'On n’a rien trouvé';

  @override
  String get onboardingNoGamesBody =>
      'Pas grave. Indique toi-même un dossier de mods dans les Réglages et tout marche pareil.';

  @override
  String get onboardingFavoriteTitle => 'Auquel joues-tu le plus ?';

  @override
  String get onboardingFavoriteBody =>
      'L’appli s’ouvrira toujours sur ce jeu. Tu peux passer d’un jeu à l’autre quand tu veux depuis la barre latérale.';

  @override
  String get onboardingLookTitle => 'Fais-en le tien';

  @override
  String get onboardingLookBody =>
      'Toute l’appli porte le look que tu choisis, quel que soit le jeu que tu gères. Choisis à quoi elle doit ressembler et comment elle doit sonner.';

  @override
  String get onboardingLibraryTitle => 'Comment ta bibliothèque se lit';

  @override
  String get onboardingLibraryBody =>
      'Deux choses à décider maintenant, parce qu’elles changent ce que la bibliothèque te montre.';

  @override
  String get onboardingDoneTitle => 'C’est prêt !';

  @override
  String get onboardingDoneBody =>
      'Ta bibliothèque est chargée et t’attend. Dépose un fichier de mod sur la fenêtre pour l’installer, et change tout ça quand tu veux dans les Réglages.';

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
  String get ignoredConflictsTitle => 'Les conflits que tu ignores';

  @override
  String ignoredConflictsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count conflits que tu as demandé à l\'appli de ne plus signaler. Réaffiche-les pour les revoir dans la bibliothèque',
      one:
          'Un conflit que tu as demandé à l\'appli de ne plus signaler. Réaffiche-le pour le revoir dans la bibliothèque',
    );
    return '$_temp0';
  }

  @override
  String get ignoredConflictsReset => 'Tout réafficher';

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
  String aboutTagline(String version, String series) {
    return 'Version $version · Gestionnaire de mods pour $series';
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
  String get categoryWorld => 'Monde';

  @override
  String get categorySettings => 'Réglages';

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
  String get modKindCas => 'CAS';

  @override
  String get modKindBuildBuy => 'Construction';

  @override
  String get modKindGameplay => 'Gameplay';

  @override
  String get modKindScript => 'Script';

  @override
  String errorNoModFiles(String extensions, String name) {
    return 'Aucun fichier de mod ($extensions) dans $name.';
  }

  @override
  String errorUnreadableArchive(String name) {
    return '$name n’est pas une archive que l’app sait lire.';
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
  String errorFileNameTaken(String name) {
    return 'Il y a déjà un « $name » dans ce dossier. Renomme l’un des deux et réessaie.';
  }

  @override
  String errorFolderNameBad(String name) {
    return '« $name » ne passe pas comme nom de dossier. Essaie sans barre oblique ni caractères que ton système se réserve.';
  }

  @override
  String errorFolderTooDeep(int levels) {
    return 'Le jeu ne regarde que $levels dossiers de profondeur dans le dossier de mods : rien de ce que tu mets en dessous ne serait chargé.';
  }

  @override
  String errorBulkMoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods n’ont pas pu être déplacés',
      one: '1 mod n’a pas pu être déplacé',
    );
    return '$_temp0 - ils sont peut-être utilisés par un autre programme (le jeu est ouvert ?), protégés en écriture, ou un fichier du même nom est déjà dans le dossier.';
  }

  @override
  String errorBulkToggleFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods n’ont pas pu être modifiés',
      one: '1 mod n’a pas pu être modifié',
    );
    return '$_temp0 - ils sont peut-être utilisés par un autre programme (le jeu est ouvert ?) ou protégés en écriture.';
  }

  @override
  String errorBulkRemoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods n’ont pas pu être supprimés',
      one: '1 mod n’a pas pu être supprimé',
    );
    return '$_temp0 - ils sont peut-être utilisés par un autre programme (le jeu est ouvert ?) ou protégés en écriture.';
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
  String get duplicatesFind => 'Trouver les mods en double';

  @override
  String duplicatesScanning(int done, int total) {
    return 'Lecture des mods qui pourraient être des doublons… $done sur $total';
  }

  @override
  String get duplicatesStop => 'Arrêter';

  @override
  String duplicatesBanner(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods sont exactement le même fichier qu’un autre',
      one: 'Un mod est exactement le même fichier qu’un autre',
    );
    return '$_temp0 - ça fait $size à récupérer.';
  }

  @override
  String get duplicatesShow => 'Montre-les-moi';

  @override
  String get duplicatesSelectExtras => 'Cocher les copies en trop';

  @override
  String get duplicatesClean => 'Ici, rien n’est en double.';

  @override
  String get duplicatesDismiss => 'OK';

  @override
  String tagTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Étiquettes de $count mods',
      one: 'Étiquettes de ce mod',
    );
    return '$_temp0';
  }

  @override
  String get tagBody =>
      'Tes propres étiquettes, pour retrouver tes affaires plus tard. Touche-en une pour la mettre ou l’enlever.';

  @override
  String get tagHint => 'Nouvelle étiquette';

  @override
  String get tagAdd => 'Ajouter';

  @override
  String get tagDone => 'Terminé';

  @override
  String get tagHeading => 'Étiquettes';

  @override
  String get tagAddFirst => 'Ajouter une étiquette';

  @override
  String tagRemove(String tag) {
    return 'Enlever « $tag »';
  }

  @override
  String get selectionTag => 'Étiqueter…';

  @override
  String folderAlsoReading(String folders) {
    return 'Ton jeu lit aussi $folders, donc les mods qui s’y trouvent sont dans cette bibliothèque également.';
  }

  @override
  String errorFolderUnreadable(String folder) {
    return 'Impossible d’ouvrir « $folder ». Choisis un dossier sur un disque que cet ordinateur peut atteindre : un téléphone, un appareil photo ou un lecteur réseau déconnecté ne peuvent pas héberger tes mods.';
  }

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
  String errorShopNoModFiles(String name) {
    return 'Il n’y a rien que ce jeu puisse installer dans « $name ». Ce n’est peut-être pas un mod - utilise Télécharger pour enregistrer le fichier où tu veux.';
  }

  @override
  String get errorShopListingNotFound =>
      'Ce mod n’est plus sur The Exchange. Il a peut-être été retiré.';

  @override
  String get errorShopListingUnknownGame =>
      'Ce mod est pour un jeu que cette version de l’appli ne connaît pas encore. Essaie de la mettre à jour.';

  @override
  String errorPackToggleFailed(String pack) {
    return 'Impossible de changer $pack. Ferme le jeu et réessaie.';
  }

  @override
  String get errorPackNoUserData =>
      'Le dossier de réglages du jeu est introuvable, donc il n’y a nulle part où noter les packs à ignorer. Lance le jeu une fois d’abord.';

  @override
  String get errorPackNeedsAdmin =>
      'Windows n’a pas laissé l’appli changer ça. Relance-la en tant qu’administrateur et réessaie.';

  @override
  String get errorPackNotSupported =>
      'Sur ce système, les packs ne peuvent pas être activés ou désactivés.';

  @override
  String get errorPackIsTheGame =>
      'C’est le pack depuis lequel le jeu démarre, il doit rester actif.';

  @override
  String get errorPackToggleRefused =>
      'Impossible de changer ce pack. Ferme le jeu et réessaie.';

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
  String get navPacks => 'Packs';

  @override
  String get packsScanning => 'Recherche de tes packs…';

  @override
  String get packsEmptyTitle => 'Aucun pack trouvé';

  @override
  String packsEmptyBody(String game) {
    return 'Soit $game n’est pas installé là où l’appli peut le voir, soit il n’y a pas encore de packs à côté.';
  }

  @override
  String get packsRescan => 'Vérifier à nouveau';

  @override
  String packsSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count packs installés',
      one: '1 pack installé',
    );
    return '$_temp0';
  }

  @override
  String packsSummaryWithOff(int count, int off) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count packs actifs',
      one: '1 pack actif',
    );
    return '$_temp0, $off désactivés';
  }

  @override
  String get packsOff => 'Désactivé';

  @override
  String get packsInstalled => 'Installé';

  @override
  String get packsNeedAdmin =>
      'Activer et désactiver ces packs demande les droits administrateur, parce que c’est là que le jeu garde sa liste. Relance l’appli en tant qu’administrateur pour y toucher : le glisser-déposer ne marche plus pendant ce temps, donc autant revenir en arrière ensuite.';

  @override
  String get packsExperimentalTitle => 'Les désactiver est expérimental';

  @override
  String get packsExperimentalOff =>
      'Ça marche comme ça a toujours marché sur ce jeu, mais personne ne l’a testé sur cette édition, et un quartier auquel tu as joué avec un pack peut casser si tu l’ouvres sans. Les afficher ne risque rien. Active les interrupteurs expérimentaux dans les Réglages si tu veux quand même essayer.';

  @override
  String get packsExperimentalOn =>
      'Sauvegarde tes quartiers d’abord. Un quartier auquel tu as joué avec un pack peut casser si tu l’ouvres sans, et ça ne se défait pas d’ici : réactiver le pack ne ramène pas toujours la partie.';

  @override
  String packsRestartNotice(String game) {
    return 'Redémarre $game pour que ça prenne effet. Tes packs restent installés dans tous les cas.';
  }

  @override
  String packsAllOwnedSims4(String expansions, String gamePacks) {
    return '$expansions packs d’extension. $gamePacks packs de jeu. Tous achetés, évidemment.';
  }

  @override
  String get packKindExpansions => 'Packs d’extension';

  @override
  String get packKindGamePacks => 'Packs de jeu';

  @override
  String get packKindStuffPacks => 'Packs d’objets';

  @override
  String get packKindKits => 'Kits';

  @override
  String get packKindFreePacks => 'Packs gratuits';

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

  @override
  String get prefSubfoldersTitle => 'Les dossiers incluent leurs sous-dossiers';

  @override
  String get prefSubfoldersDesc =>
      'Un dossier montre aussi tout ce qui se trouve en dessous. Désactivé, cc et cc/defaults sont deux étagères distinctes.';

  @override
  String deleteFolderTitle(String folder) {
    return 'Supprimer $folder ?';
  }

  @override
  String get deleteFolderBody =>
      'Le dossier et tout ce qu’il contient disparaît, sous-dossiers compris. Impossible de revenir en arrière.';

  @override
  String deleteFolderMods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods seront supprimés',
      one: '1 mod sera supprimé',
    );
    return '$_temp0';
  }

  @override
  String get deleteFolderEmpty => 'Il ne contient aucun mod.';

  @override
  String get deleteFolder => 'Supprimer le dossier';

  @override
  String triviaTitle(String game) {
    return 'Le plumbob sait · $game';
  }

  @override
  String get triviaContextLibrary => 'On dirait que tu regardes tes mods';

  @override
  String get triviaContextSaves => 'On dirait que tu es dans tes sauvegardes';

  @override
  String get triviaContextPacks =>
      'On dirait que tu fais le tri dans tes packs';

  @override
  String triviaCounter(int index, int total) {
    return 'Anecdote $index sur $total';
  }

  @override
  String get triviaOpen => 'Demander au plumbob';

  @override
  String get triviaClose => 'Pas maintenant';

  @override
  String get triviaPrevious => 'Anecdote précédente';

  @override
  String get triviaNext => 'Anecdote suivante';

  @override
  String get triviaAnother => 'Encore une';

  @override
  String get triviaToSettings =>
      'Ça suffit ? Coupe le plumbob dans les Réglages';

  @override
  String get prefTriviaTitle => 'Anecdotes du plumbob';

  @override
  String get prefTriviaDesc =>
      'Laisse le plumbob surgir de temps en temps avec une anecdote sur le jeu où tu te trouves';

  @override
  String get triviaCategoryOrigins => 'Origines';

  @override
  String get triviaCategoryDesign => 'Design';

  @override
  String get triviaCategoryLore => 'Lore';

  @override
  String get triviaCategoryDeath => 'Mort';

  @override
  String get triviaCategoryMusic => 'Musique';

  @override
  String get triviaCategoryCheats => 'Codes';

  @override
  String get triviaCategoryRecords => 'Records';

  @override
  String get triviaCategoryModding => 'Modding';

  @override
  String get triviaCategoryLanguage => 'Langue';

  @override
  String get triviaCategoryCommunity => 'Communauté';

  @override
  String get triviaSeriesLlama =>
      'Maxis a un jour organisé un vote dans tout le studio pour choisir une mascotte officieuse. Les candidats étaient une fougère, un ténia bovin et un lama. Le lama a gagné, et depuis il n’a plus cessé d’apparaître dans les jeux.';

  @override
  String get triviaSeriesSimlish =>
      'Le simlish a été inventé au micro. On donnait à Stephen Kearin et Gerri Lawlor des consignes comme « faim » ou « solitude » et ils improvisaient ce que ça devait donner, pendant des heures.';

  @override
  String get triviaSeriesCheats =>
      'rosebud et klapaucius rapportent §1 000 chacun. Rosebud vient de Citizen Kane ; Klapaucius est un robot constructeur de la Cyberiade de Stanisław Lem, un livre que Will Wright cite comme influence depuis SimCity.';

  @override
  String get triviaSeriesRecords =>
      'Le Guinness reconnaît The Sims comme la série PC la plus vendue de tous les temps. Elle a dépassé les 125 millions d’exemplaires il y a plus de dix ans et a été traduite en 60 langues.';

  @override
  String get triviaSeriesGoths =>
      'Les Goth sont l’une des familles les plus anciennes du jeu vidéo. Mortimer et Bella apparaissent dans tous les épisodes principaux depuis 2000.';

  @override
  String get triviaSeriesReaper =>
      'La Faucheuse a une biographie que le jeu ne te montre jamais en temps normal. Entre autres choses, elle indique son groupe préféré : Styx.';

  @override
  String get triviaSeriesSimCity =>
      'The Sims est né de SimCity. Will Wright n’arrêtait pas de vouloir zoomer sur les petites personnes pour qui la ville était construite.';

  @override
  String get triviaSeriesLegacy =>
      'En janvier 2025, EA a remis The Sims et The Sims 2 en vente sous forme de Legacy Collections, toutes extensions comprises. Ce sont des correctifs de compatibilité, pas des remasters : les deux jeux se jouent exactement comme avant.';

  @override
  String get triviaSeriesPlumbob =>
      'Le diamant vert s’est écrit de trois façons : PlumbBob dans The Sims, Plum Bob dans The Sims 2, et plumbob depuis The Sims 4. Maxis dit que les trois ont servi pendant le développement.';

  @override
  String get triviaSeriesModScene =>
      'La scène des mods est presque aussi vieille que la série. Des éditeurs de skins et d’objets circulaient quelques mois seulement après la sortie du premier jeu en 2000, bien avant le moindre outil officiel.';

  @override
  String get triviaSeriesConflicts =>
      'Un conflit, c’est plus simple que ça en a l’air. Deux mods revendiquent la même ressource, les deux se chargent, et c’est celui que le jeu lit en dernier qui gagne. Rien n’est cassé, quelque chose est juste passé devant.';

  @override
  String get triviaSeriesPackage =>
      'Un fichier .package est une archive DBPF, pour Database Packed File. Maxis utilise le même conteneur depuis SimCity 4, et c’est pour ça qu’un seul outil ouvre vingt ans de contenu personnalisé.';

  @override
  String get triviaSeriesRename =>
      'Désactiver un mod en le renommant est la plus vieille astuce de la scène. Le jeu ne charge que ce qu’il reconnaît, donc un package renommé reste exactement là où il est, et se tait.';

  @override
  String get triviaSeriesSaves =>
      'Les sauvegardes de The Sims sont des quartiers, pas des emplacements. Les familles, les terrains, les souvenirs et les ragots vivent tous dans un même dossier, qui grossit tant que tu continues à jouer.';

  @override
  String get triviaSeriesPacks =>
      'Désactiver un pack ne déplace aucun fichier. Chaque jeu de la série garde ailleurs sa propre liste de ce qu’il doit charger, une ligne de réglages ou une clé de registre, et masquer un pack revient juste à modifier cette liste.';

  @override
  String get triviaSims1Dollhouse =>
      'The Sims a commencé comme un simulateur d’architecture appelé Project Dollhouse. Les sims n’ont été ajoutés que pour que le joueur puisse juger si la maison était agréable à vivre.';

  @override
  String get triviaSims1Oakland =>
      'Will Wright a perdu sa maison dans l’incendie d’Oakland en 1991. Reconstruire un foyer de zéro, les meubles, l’électroménager, les habitudes, a été la graine du jeu.';

  @override
  String get triviaSims1Toilet =>
      'Les dirigeants n’ont pas été convaincus par le pitch et l’ont balayé comme un « jeu de toilettes », parce que les sims avaient besoin d’une salle de bains.';

  @override
  String get triviaSims1HomeTactics =>
      'Avant de devenir The Sims, le projet s’appelait Home Tactics: The Experimental Domestic Simulator. Les groupes de test n’ont pas aimé cette version non plus.';

  @override
  String get triviaSims1Myst =>
      'En 2002, The Sims a dépassé Myst pour devenir le jeu PC le plus vendu de tous les temps.';

  @override
  String get triviaSims1Simlish =>
      'Le simlish a été improvisé par des comédiens jouant avec des bouts d’ukrainien, de navajo, de tagalog et d’estonien, et volontairement gardé dénué de sens pour que la langue ne vieillisse jamais.';

  @override
  String get triviaSims1Architecture =>
      'Les outils de construction étaient si inhabituels pour l’an 2000 que certains joueurs n’ont jamais posé le moindre sim et se servaient du jeu comme d’un logiciel d’architecture gratuit.';

  @override
  String get triviaSims1Audience =>
      'Fait rare pour l’époque, la majorité des joueurs étaient des joueuses, ce qui explique en partie pourquoi son marketing ne ressemblait à rien d’autre en rayon.';

  @override
  String get triviaSims1Cowplant =>
      'La vache-plante a débuté ici, sous le nom savant Laganaphyllis Simnovorii, et mange discrètement des sims à chaque génération depuis.';

  @override
  String get triviaSims1Plumbob =>
      'Le mot plumbob vient du fil à plomb, ce poids pointu que les maçons suspendent pour trouver la verticale. C’était un jeu d’architecture avant toute chose.';

  @override
  String get triviaSims1Release =>
      'Le jeu est sorti le 4 février 2000 et a dépassé toutes les prévisions de ventes qu’EA avait faites pour lui.';

  @override
  String get triviaSims1Edith =>
      'Chaque objet du jeu a été programmé dans un langage appelé SimAntics, via un outil maison baptisé Edith en hommage à Edith Bunker : le tout premier personnage créé pour The Sims.';

  @override
  String get triviaSims1Expansions =>
      'Sept extensions en trois ans et demi, une au printemps et une à l’automne, de Livin’ Large en août 2000 à Makin’ Magic en octobre 2003.';

  @override
  String get triviaSims1Unleashed =>
      'Unleashed a apporté les animaux à la série en 2002 et a remporté le prix du jeu de simulation de l’année aux Interactive Achievement Awards.';

  @override
  String get triviaSims1Clown =>
      'Le Clown Tragique débarque pour remonter le moral d’un sim triste qui possède son tableau. Il est absolument mauvais à ça, et c’est toute la blague.';

  @override
  String get triviaSims1Llama =>
      'Le manuel imprimé d’origine contenait un livre intitulé Making the Most of Your Llama. Personne n’a jamais expliqué pourquoi.';

  @override
  String get triviaSims1Superstar =>
      'Superstar permettait à un sim de devenir acteur, mannequin ou chanteur, jauge de célébrité comprise, onze ans avant que The Sims 4 ne retente la gloire.';

  @override
  String get triviaSims1Catalogue =>
      'En reconstruisant sa maison après l’incendie, Will Wright n’arrêtait pas de se demander quelles parties d’un foyer étaient indispensables et lesquelles pouvaient attendre. Cette question, c’est à peu près le catalogue du mode achat.';

  @override
  String get triviaSims2Aging =>
      'The Sims 2 est le premier de la série où les sims vieillissaient, mouraient de vieillesse et transmettaient leur génétique. Les yeux, le nez et le menton viennent des deux parents.';

  @override
  String get triviaSims2Memories =>
      'Chaque sim porte une liste de souvenirs cachée. Assister à une mort, à un premier baiser ou à une promotion est mémorisé et influence son humeur plus tard.';

  @override
  String get triviaSims2Bella =>
      'Bella Goth disparaît de Pleasantview dès le début du jeu, et en vingt ans cette disparition n’a jamais reçu d’explication officielle.';

  @override
  String get triviaSims2Strangetown =>
      'Bella réapparaît vivante à Strangetown, sans le moindre souvenir de Pleasantview. Maxis a dit que les deux Bella sont réelles et s’en est tenu là.';

  @override
  String get triviaSims2FamilyTrees =>
      'Les quartiers de The Sims 2 reposent sur un vrai arbre généalogique : Pleasantview, Strangetown et Veronaville sont reliés par les mariages et les rumeurs.';

  @override
  String get triviaSims2Plead =>
      'On peut supplier la Faucheuse. Parle-lui au bon moment et elle peut te rendre ton sim, parfois en échange de quelqu’un d’autre.';

  @override
  String get triviaSims2ReaperRomance =>
      'On peut séduire la Faucheuse. Joue bien tes cartes et il en sort un bébé fantôme.';

  @override
  String get triviaSims2Satellite =>
      'Un sim qui observe les étoiles a une toute petite chance de se prendre un satellite sur la tête. C’est l’une des morts les plus rares de la série.';

  @override
  String get triviaSims2Therapist =>
      'Un échec d’aspiration envoie le sim chez le thérapeute, l’une des rares fois où le jeu casse son propre quatrième mur pour rire.';

  @override
  String get triviaSims2WantsFears =>
      'Les envies et les peurs font tourner tout le jeu. La jauge d’aspiration réagit aussi fort à ce que le sim redoutait qu’à ce qu’il espérait.';

  @override
  String get triviaSims2FaceSculpt =>
      'Le jeu est sorti avec un système complet de sculpture du visage et du corps, et c’est pour ça que les visages de The Sims 2 paraissent encore plus variés que ceux des épisodes suivants.';

  @override
  String get triviaSims2Aliens =>
      'L’enlèvement extraterrestre n’arrive qu’aux sims masculins qui observent les étoiles trop longtemps, et oui, ils reviennent enceints.';

  @override
  String get triviaSims2FreezerBunny =>
      'Le Freezer Bunny a été dessiné par l’artiste Emmy Toyonaga pour The Sims 2 et est apparu pour la première fois caché dans un congélateur d’un terrain communautaire. Depuis, il est glissé en douce dans tous les jeux.';

  @override
  String get triviaSims2SocialBunny =>
      'Le Lapin Social a remplacé le Clown Tragique et, contrairement au clown, lui fonctionne vraiment. Beaucoup de joueurs ont trouvé la version efficace plus dérangeante.';

  @override
  String get triviaSims2Giveaway =>
      'EA a offert l’Ultimate Collection sur Origin en juillet 2014, à récupérer avec le code I-LOVE-THE-SIMS. Pendant les dix ans qui ont suivi, jusqu’à la Legacy Collection, ce cadeau était la seule copie disponible.';

  @override
  String get triviaSims3SunsetValley =>
      'Sunset Valley, c’est le Pleasantview de The Sims 2 environ 25 ans plus tôt, donc tu peux rencontrer les grands-parents de sims auxquels tu as déjà joué.';

  @override
  String get triviaSims3Founders =>
      'Sunset Valley a été fondée par les Goth et bâtie par les Landgraab. Tu peux jouer Mortimer Goth enfant et le voir rencontrer Bella Bachelor.';

  @override
  String get triviaSims3OpenWorld =>
      'The Sims 3 a supprimé les écrans de chargement pour de bon. La ville entière se simule d’un coup, chaque sim vieillissant et travaillant en arrière-plan.';

  @override
  String get triviaSims3Simulation =>
      'Tous les sims de la ville sont simulés en même temps, et c’est pour ça qu’une longue partie ralentit. Le jeu fait vivre, en silence, des gens que tu n’as jamais croisés.';

  @override
  String get triviaSims3CreateAStyle =>
      'Créer un Style permettait de recolorier et de re-motifier presque n’importe quel objet, une fonction si gourmande qu’elle n’est jamais revenue.';

  @override
  String get triviaSims3Exchange =>
      'The Sims 3 est sorti avec un véritable échange en ligne, où les joueurs partageaient terrains, sims et motifs directement depuis le launcher.';

  @override
  String get triviaSims3Downloads =>
      'Rien que la première semaine, les joueurs ont téléchargé plus de sept millions d’objets faits par la communauté depuis ce même launcher.';

  @override
  String get triviaSims3Traits =>
      'Les traits ont remplacé les anciens curseurs de personnalité, et certains, comme Cleptomane et Fou, enfreignent discrètement les règles de la vie normale.';

  @override
  String get triviaSims3Kleptomaniac =>
      'Un sim cleptomane rentre à la maison avec les meubles des autres, sans qu’on lui demande rien, et continue jusqu’à ce que tu t’en aperçoives.';

  @override
  String get triviaSims3Simlish =>
      'Katy Perry, Lily Allen, Depeche Mode et des dizaines d’autres artistes ont réenregistré leurs propres chansons en simlish pour les bandes-son.';

  @override
  String get triviaSims3Townies =>
      'Comme le monde ouvert simulait aussi les sims hors écran, il arrivait souvent de découvrir que les habitants s’étaient mariés et avaient eu des enfants sans la moindre intervention de ta part.';

  @override
  String get triviaSims3Store =>
      'Le Sims 3 Store a fini par vendre plus d’objets que le jeu lui-même n’en contenait à sa sortie.';

  @override
  String get triviaSims3Launch =>
      'The Sims 3 s’est vendu à 1,4 million d’exemplaires la première semaine, en juin 2009, le plus gros lancement PC qu’EA ait jamais connu.';

  @override
  String get triviaSims4Flies =>
      'Mourir de mouches, ça existe. Laisse un terrain assez sale et un essaim finit par avoir la peau de ton sim.';

  @override
  String get triviaSims4Emotions =>
      'Ici, tout part des émotions. Un sim Inspiré peint mieux ; un sim Enragé peut mourir de colère.';

  @override
  String get triviaSims4EmotionDeaths =>
      'Un sim peut mourir de rire, de colère et de gêne. Dans celui-ci, l’émotion n’est pas un décor, c’est un danger.';

  @override
  String get triviaSims4CreateASim =>
      'Créer un Sim a remplacé les curseurs par le fait de tirer et pousser directement sur le visage, et c’est pour ça qu’un visage se fait si vite dans The Sims 4.';

  @override
  String get triviaSims4Launch =>
      'The Sims 4 est sorti sans piscines et sans bambins. Les deux sont revenus gratuitement, par patch, après une longue pression des joueurs.';

  @override
  String get triviaSims4Worlds =>
      'Willow Creek et Oasis Springs étaient les deux seuls mondes au lancement, en septembre 2014. Il y en a des dizaines aujourd’hui, presque tous arrivés avec un pack.';

  @override
  String get triviaSims4Gender =>
      'Le genre a été entièrement débloqué par un patch en 2016 : n’importe quel sim peut porter n’importe quel vêtement, avoir n’importe quelle voix, et tomber enceint ou non.';

  @override
  String get triviaSims4Newcrest =>
      'Newcrest est sorti complètement vide, exprès. Quinze terrains, aucun bâtiment, et une invitation ouverte à la communauté pour le remplir.';

  @override
  String get triviaSims4Naming =>
      'Des noms de quartier comme Willow Creek et Oasis Springs suivent une règle maison héritée du vieux Maxis : deux mots anglais simples, aucune orthographe inventée.';

  @override
  String get triviaSims4Goths =>
      'La famille Goth est là aussi, ce qui en fait l’une des plus anciennes du jeu vidéo, présente dans chaque épisode principal.';

  @override
  String get triviaSims4FreeToPlay =>
      'Le jeu de base est devenu gratuit en octobre 2022, sur PC, PlayStation et Xbox en même temps. Les packs, eux, sont restés payants.';

  @override
  String get triviaSims4Mccc =>
      'MC Command Center, le premier mod que presque tout le monde installe dans The Sims 4, a dépassé les 14 millions de téléchargements rien que sur CurseForge. Deaderpool le met à jour depuis 2015.';

  @override
  String get triviaSims4Twallan =>
      'MCCC existe grâce à The Sims 3. Il reprend là où le Master Controller et le Story Progression de Twallan s’étaient arrêtés, et porte une idée vieille de plus de dix ans dans un nouveau moteur.';

  @override
  String get triviaSims4Deaths =>
      'Un sim peut être tué par une vache-plante, un distributeur automatique, une chaîne hi-fi en forme de lama et un fou rire. Pas tout en même temps.';

  @override
  String get triviaMedievalWatcher =>
      'Ici tu n’es pas un foyer, tu es l’Observateur : une divinité bienveillante qui pousse des héros à travers un royaume au lieu de gérer la journée d’une famille.';

  @override
  String get triviaMedievalHeroes =>
      'Un royaume accueille jusqu’à dix sims héros répartis en dix métiers, et chacun monte du niveau 1 au niveau 10 en gagnant de nouvelles aptitudes et des titres de plus en plus ronflants.';

  @override
  String get triviaMedievalStocks =>
      'Chaque héros se réveille avec deux responsabilités et une heure limite. Les négliger trop souvent est puni, et cela vaut aussi pour le monarque, qui peut finir au pilori.';

  @override
  String get triviaMedievalAmbition =>
      'Tu choisis une Ambition pour tout le royaume avant de commencer, et les quêtes que tu acceptes sont notées par rapport à elle. C’est ce que The Sims a fait de plus proche d’une condition de victoire.';

  @override
  String get triviaMedievalQuests =>
      'C’est une conversion totale, pas un spin-off. Le bac à sable cède la place à une suite de quêtes, et c’est pour ça que c’est le seul jeu The Sims qu’on peut vraiment terminer.';

  @override
  String get triviaMedievalPirates =>
      'Pirates and Nobles, d’août 2011, est le seul add-on qu’il ait jamais eu : faucons et perroquets, cartes au trésor et pelles, et une guerre entre deux factions fraîchement débarquées.';

  @override
  String get triviaMedievalProxy =>
      'Le jeu n’a jamais été conçu pour charger des mods. Les mods de script et de cœur ont besoin du proxy d3dx9_31.dll de la communauté déposé dans Game/Bin avant que le jeu daigne les lire, alors que le contenu personnalisé, lui, fonctionne sans.';

  @override
  String get triviaMedievalEngine =>
      'Il tourne sur le moteur de The Sims 3, et c’est pour ça que le Resource.cfg et les fichiers .package semblent si familiers à quiconque a moddé ce jeu-là.';

  @override
  String get navCreations => 'Créations';

  @override
  String creationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count créations',
      one: '1 création',
      zero: 'Rien d’enregistré pour l’instant',
    );
    return '$_temp0';
  }

  @override
  String get creationsScanning => 'Lecture de tes terrains et familles…';

  @override
  String get creationsRefresh => 'Actualiser';

  @override
  String get creationsAll => 'Tout';

  @override
  String get creationsBack => '← Retour à tout';

  @override
  String get creationsNoneOfKind => 'Rien de ce type ici.';

  @override
  String get creationsEmptyTitle => 'Encore rien ici';

  @override
  String get creationsEmptyBody =>
      'Les terrains, pièces, familles et sims que tu enregistres dans le jeu apparaissent ici — tout comme ce que tu télécharges et déposes sur la fenêtre.';

  @override
  String creationsBy(String creator) {
    return 'par $creator';
  }

  @override
  String get creationsWhoLivesHere => 'QUI VIENT AVEC';

  @override
  String get creationsShowInFolder => 'Afficher dans le dossier';

  @override
  String get creationsDelete => 'Supprimer';

  @override
  String creationsDeleteTitle(String name) {
    return 'Supprimer « $name » ?';
  }

  @override
  String get creationsDeleteBody =>
      'Ça disparaît définitivement du dossier du jeu. Pas de retour en arrière.';

  @override
  String creationsFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers',
      one: '1 fichier',
    );
    return '$_temp0';
  }

  @override
  String get creationKindLot => 'Terrain';

  @override
  String get creationKindRoom => 'Pièce';

  @override
  String get creationKindHousehold => 'Foyer';

  @override
  String get creationKindSim => 'Sim';

  @override
  String get creationFolderSims4Tray => 'Tray';

  @override
  String get creationFolderSims3Library => 'Library';

  @override
  String get creationFolderSims2LotCatalog =>
      'Collection de terrains et maisons';

  @override
  String get creationFolderSims2SavedSims => 'Sims empaquetés';

  @override
  String creationFolderSims1Houses(String number) {
    return 'Quartier $number';
  }

  @override
  String creationBadFileName(String name) {
    return '« $name » contient des caractères que ce système refuse dans un nom de fichier, donc le jeu ne le trouverait jamais. Renomme-le et réessaie.';
  }

  @override
  String creationFileInUse(String name) {
    return '« $name » est en cours d’utilisation. Ferme le jeu et réessaie.';
  }

  @override
  String get creationSims1PickLot =>
      'Les Sims 1 numérote ses terrains selon leur position sur la carte : une maison doit donc prendre la place d\'un terrain existant, et ce qui s\'y trouve est perdu. Choisis le terrain toi-même : fais une sauvegarde, puis renomme le téléchargement avec le numéro House de ce terrain dans le dossier Houses.';

  @override
  String creationInstallFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ces $count fichiers n’ont pas pu être ajoutés.',
      one: 'Ce fichier n’a pas pu être ajouté.',
    );
    return '$_temp0';
  }

  @override
  String creationRemoveFailed(String name) {
    return '« $name » n’a pas pu être supprimé.';
  }

  @override
  String get creationsAdd => 'Ajouter';

  @override
  String get creationsAdding => 'Ajout en cours…';

  @override
  String creationsPickerLabel(String game) {
    return 'Terrains, pièces, foyers et sims de $game';
  }

  @override
  String get creationsNothingToAdd =>
      'Rien là-dedans n’était un terrain, une pièce, un foyer ou un sim que ce jeu peut utiliser. Le contenu personnalisé et les mods passent par la bibliothèque.';

  @override
  String get householdEdit => 'Modifier';

  @override
  String get householdEditTitle => 'Modifier le foyer';

  @override
  String householdEditBody(String name) {
    return 'Change ce que la sauvegarde dit de « $name ».';
  }

  @override
  String get householdEditName => 'Nom';

  @override
  String get householdEditFunds => 'Argent';

  @override
  String householdEditFundsMax(String max) {
    return 'Jusqu’à $max, c’est tout ce que ce jeu peut contenir.';
  }

  @override
  String get householdEditSave => 'Enregistrer';

  @override
  String get householdEditNotice =>
      'Ferme le jeu d’abord : il réécrit sa propre sauvegarde en quittant. Une copie du fichier est gardée avant tout changement.';

  @override
  String get errorSaveEditHouseholdGone =>
      'Ce foyer n’est plus dans la sauvegarde. Actualise la liste et réessaie.';

  @override
  String errorSaveEditUnreadable(String file) {
    return '« $file » n’a pas la structure que l’appli sait réécrire, donc rien n’a été changé.';
  }

  @override
  String errorSaveEditVerification(String file) {
    return 'Le « $file » réécrit ne s’est pas relu comme il fallait, il a donc été jeté. Ta sauvegarde est intacte.';
  }

  @override
  String get errorSaveEditUnsupported =>
      'Les sauvegardes de ce jeu se lisent, mais ne se modifient pas.';

  @override
  String whatsNewEyebrow(String version) {
    return 'Nouveautés de la $version';
  }

  @override
  String get whatsNewAlsoSince => 'Aussi dans cette mise à jour';

  @override
  String get whatsNewDismiss => 'C’est parti';

  @override
  String get whatsNew300RootTitle =>
      'Les mods qui vont dans les dossiers du jeu';

  @override
  String get whatsNew300RootBody =>
      'Les mondes, les réglages graphiques et les chargeurs de scripts n’ont jamais fonctionné depuis le dossier Mods. Ils s’installent maintenant directement dans les dossiers que le jeu lit, et ce qu’ils remplacent est conservé : désinstaller te rend l’original.';

  @override
  String get whatsNew300PacksTitle =>
      'Les annonces peuvent indiquer les packs nécessaires';

  @override
  String get whatsNew300PacksBody =>
      'Les créateurs peuvent associer un mod aux packs pour lesquels il a été conçu, et The Exchange les compare aux tiens avant l’installation. C’est toujours un avertissement, jamais une porte fermée.';

  @override
  String get whatsNew300ContainersTitle =>
      'Un zip plein de fichiers .sims3pack fonctionne tout seul';

  @override
  String get whatsNew300ContainersBody =>
      'Dépose l’ensemble sur la fenêtre. Les conteneurs des Sims 3 nichés dans une archive sont ouverts là où ils se trouvent, et tout s’installe d’un coup.';

  @override
  String get whatsNew300SimCityTitle => 'SimCity 3000, 4, Societies et 2013';

  @override
  String get whatsNew300SimCityBody =>
      'Quatre jeux de plus dans la barre latérale. SimCity 4 lit ses deux dossiers Plugins, respecte l’ordre de chargement que dictent les noms de dossiers et de fichiers, et ne touche à rien de ce que sc4pac a installé. Les réglages permettent de masquer les jeux auxquels tu ne joues pas.';

  @override
  String get whatsNew300CatalogTitle =>
      'Des milliers de mods SimCity 4 à parcourir';

  @override
  String get whatsNew300CatalogBody =>
      'The Exchange affiche désormais les canaux sc4pac à côté de nos propres annonces, avec le crédit du projet qui les entretient. Un téléchargement arrive avec tout ce dont il dépend ou pas du tout, et quand un hébergeur refuse qu’une appli télécharge à ta place, le bouton te le dit d’emblée.';

  @override
  String get whatsNew300ThemeTitle => 'Choisis le look qui te plaît';

  @override
  String get whatsNew300ThemeBody =>
      'Avant, l’appli changeait de couleur selon le jeu ouvert. Maintenant tu choisis le look que tu veux dans les réglages, et il reste en place quel que soit le jeu que tu gères.';

  @override
  String get categoryLot => 'Terrain';

  @override
  String get categoryModel => 'Modèle';

  @override
  String get categoryDescription => 'Description';

  @override
  String get categoryBuilding => 'Bâtiment';

  @override
  String get setupHelpSimCity4 =>
      'SimCity 4 lit les plugins dans deux dossiers à la fois : Documents > SimCity 4 > Plugins (le tien, et celui que cette appli gère) et un dossier Plugins dans l\'installation du jeu. Les noms de dossiers et de fichiers font l\'ordre de chargement, alors ne touche pas à la structure livrée avec le téléchargement : c\'est pour ça que sc4pac utilise des dossiers numérotés et que les overrides s\'appellent « zzz... ». Les plugins DLL ne se chargent qu\'à la racine d\'un dossier Plugins, jamais dans un sous-dossier, donc l\'appli les y place pour toi. Ce que sc4pac a installé reste à sc4pac : c\'est lui qui le liste, pas cette appli.';

  @override
  String get setupHelpSimCity2013 =>
      'SimCity charge les mods en .package depuis SimCityUserData > Packages dans l\'installation du jeu (souvent sous Program Files, donc Windows peut demander les droits administrateur). Cette appli ne gère que ce dossier-là. Le jeu lit aussi son dossier SimCityData, mais celui-ci contient le contenu de Maxis : un mod qui doit se charger avant les paquets du jeu doit y aller à la main. Beaucoup de mods sont marqués hors-ligne uniquement : teste-les sur une ville que tu peux perdre.';

  @override
  String get setupHelpSimCity3000 =>
      'SimCity 3000 charge les bâtiments personnalisés (fichiers .bld, faits avec le Building Architect Tool) depuis un dossier Buildings dans l\'installation du jeu. Il est plat : un bâtiment dans un sous-dossier n\'est jamais chargé. Les bâtiments livrés avec le jeu sont masqués ici pour que tu ne les supprimes pas par erreur. Les correctifs de résolution et de compatibilité qui modifient SC3U.exe lui-même ne sont pas installés par cette appli ; suis leurs propres instructions.';

  @override
  String get setupHelpSimCitySocieties =>
      'SimCity Societies range le contenu personnalisé dans Documents > SimCity Societies > Import, là où le Package Installer du jeu le met. Cette appli peut créer le dossier pour toi. Le contenu arrive en fichiers .SCSPack - c\'est l\'extension que le jeu cherche lui-même. À savoir : Societies a été conçu pour être édité, pas pour charger des mods empaquetés - l\'essentiel de ce que faisait la communauté, c\'était modifier le C# et le XML dans le dossier Data du jeu, auquel cette appli ne touche jamais.';

  @override
  String get sectionManagedGames => 'Jeux';

  @override
  String prefManageGameTitle(String game) {
    return 'Gérer $game';
  }

  @override
  String get prefManageGameDesc =>
      'L\'afficher dans la barre latérale. Masquer un jeu conserve tous ses réglages.';

  @override
  String get errorLastManagedGame =>
      'C\'est le seul jeu qui reste dans ta barre latérale, donc il doit rester. Active-en un autre d\'abord si tu veux le masquer.';

  @override
  String catalogCount(int count) {
    return '$count mods';
  }

  @override
  String catalogCuratedBy(String project) {
    return 'Catalogue par $project';
  }

  @override
  String get catalogOpenPage => 'Ouvrir la page';

  @override
  String catalogBlocked(String host) {
    return '$host n\'autorise pas les applis à télécharger à ta place. Récupère-le sur la page du mod.';
  }

  @override
  String get catalogUnresolvedNote =>
      'Impossible de lire celui-ci dans le catalogue.';

  @override
  String get catalogDependencies => 'Vient avec';

  @override
  String catalogFileCount(int count) {
    return '$count fichiers';
  }

  @override
  String catalogDownloading(int current, int total) {
    return 'Téléchargement $current sur $total';
  }

  @override
  String get catalogWarningTitle => 'À savoir';

  @override
  String get catalogConflictsTitle => 'En conflit avec';

  @override
  String catalogSourceFailed(String source) {
    return 'Impossible de joindre $source';
  }

  @override
  String get catalogEmpty => 'Rien ne correspond.';

  @override
  String get catalogRefresh => 'Recharger le catalogue';

  @override
  String get catalogOptions => 'Options';

  @override
  String catalogBy(String author) {
    return 'de $author';
  }

  @override
  String get errorCatalogUnreachable =>
      'Impossible de joindre le catalogue. Vérifie ta connexion et réessaie.';

  @override
  String get errorCatalogUnreadable =>
      'Le catalogue a répondu quelque chose que cette version ne sait pas lire.';

  @override
  String errorCatalogDownloadFailed(String host) {
    return '$host a refusé le téléchargement.';
  }

  @override
  String get errorCatalogInstallFailed =>
      'Quelque chose s\'est mal passé à l\'installation.';

  @override
  String get errorCatalogInstallCancelled => 'Installation annulée.';

  @override
  String get catalogLoading => 'Chargement du catalogue…';

  @override
  String get catalogBack => '← Retour au catalogue';

  @override
  String get catalogPromoTitle => 'Tu as fait un mod ?';

  @override
  String get catalogPromoBody =>
      'Mets-le sur The Exchange : il s’installe en un clic, il a sa page et son lien, et ceux qui l’ont déjà sont prévenus des mises à jour.';
}
