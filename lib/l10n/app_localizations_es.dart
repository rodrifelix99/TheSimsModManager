// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class LEs extends L {
  LEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Sims Mod Manager';

  @override
  String get brandTitle => 'Mod Manager';

  @override
  String get brandSubtitle => 'para Los Sims';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navShop => 'The Exchange';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get shopAlphaBadge => 'ALFA';

  @override
  String get shopTagline => 'Mods de la comunidad, instalados con un clic.';

  @override
  String shopListingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods en las estanterías',
      one: '1 mod en las estanterías',
    );
    return '$_temp0';
  }

  @override
  String get shopRefresh => 'Actualizar';

  @override
  String get shopPublish => 'Publica tus mods';

  @override
  String get shopLoadFailedTitle => 'The Exchange no responde';

  @override
  String get shopLoadFailedBody =>
      'No se pudieron cargar las estanterías. Revisa tu conexión e inténtalo otra vez.';

  @override
  String get shopRetry => 'Reintentar';

  @override
  String get shopEmptyTitle => 'Las estanterías siguen vacías';

  @override
  String get shopEmptyBody =>
      'The Exchange acaba de abrir sus puertas y nadie ha publicado nada todavía. Así de nuevo es esto. ¿Haces mods? ¡Estrena tú las estanterías!';

  @override
  String get shopAllGames => 'Todos los juegos';

  @override
  String get shopShowAllGames => 'Ver todos los juegos';

  @override
  String shopEmptyGameTitle(String game) {
    return 'Aún no hay nada de $game';
  }

  @override
  String shopEmptyGameBody(String game) {
    return 'Otros juegos ya tienen mods en las estanterías, pero de $game todavía no hay ninguno. ¿Tienes uno? ¡Estrena tú esa estantería!';
  }

  @override
  String shopBy(String author) {
    return 'por $author';
  }

  @override
  String get shopInstalled => 'Instalado';

  @override
  String get shopUpdate => 'Actualizar';

  @override
  String get shopUpdateBadge => 'actualización';

  @override
  String shopUpdatesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de tus mods tienen versiones nuevas en The Exchange',
      one: '1 de tus mods tiene una versión nueva en The Exchange',
    );
    return '$_temp0';
  }

  @override
  String get shopUpdateHeading => 'Hay una versión nueva de este mod';

  @override
  String shopUpdateBody(String version, String author) {
    return '$author publicó la v$version en The Exchange. Al actualizar se reemplazan los archivos que tienes ahora.';
  }

  @override
  String get shopUpdateSeeListing => 'Ver la ficha';

  @override
  String get shopInstalling => 'Instalando…';

  @override
  String get shopInstallNotes => 'Notas de instalación';

  @override
  String get shopCreatorNudge =>
      '¿Haces mods? Publicar en The Exchange es gratis, y los jugadores instalan tu trabajo con un clic.';

  @override
  String shopNeedsFolder(String game) {
    return 'Configura primero la carpeta de mods de $game. La pestaña Biblioteca te guía paso a paso.';
  }

  @override
  String shopVariations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count variaciones',
      one: '1 variación',
    );
    return '$_temp0';
  }

  @override
  String get shopSaveFile => 'Descargar';

  @override
  String get shopSaving => 'Descargando…';

  @override
  String get shopSaved => 'Guardado';

  @override
  String get shopSaveHint =>
      'Instalar mete los archivos directamente en tu carpeta de mods. Descargar solo guarda el archivo, donde tú quieras.';

  @override
  String get shopVariationPick => 'Elige una variación';

  @override
  String get shopBack => 'Volver a las estanterías';

  @override
  String get shopCopyLink => 'Copiar enlace';

  @override
  String get shopLinkCopied => 'Enlace copiado';

  @override
  String get sidebarGames => 'JUEGOS';

  @override
  String sidebarNotInstalled(String detail) {
    return 'no instalado · $detail';
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
  String get updateAvailable => 'Actualización disponible';

  @override
  String updateClickToDownload(String version) {
    return 'v$version: haz clic para descargar';
  }

  @override
  String get storage => 'Almacenamiento';

  @override
  String storageInMods(String size) {
    return '$size en mods';
  }

  @override
  String storageFreeOf(String free, String total) {
    return '$free libres de $total';
  }

  @override
  String dropToInstall(String game) {
    return 'Suelta aquí para instalar en $game';
  }

  @override
  String get dropFolders => 'carpetas';

  @override
  String scanningMods(int done, int total) {
    return 'Mirando dentro de los mods para buscar imágenes y conflictos… $done de $total';
  }

  @override
  String get skip => 'Omitir';

  @override
  String libraryTitle(String game) {
    return 'Biblioteca de $game';
  }

  @override
  String modsShown(int count, String era) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods a la vista',
      one: '1 mod a la vista',
    );
    return '$_temp0 · $era';
  }

  @override
  String get learnMore => 'Saber más';

  @override
  String get dismiss => 'Descartar';

  @override
  String get searchMods => 'Buscar mods…';

  @override
  String get viewGrid => 'Cuadrícula';

  @override
  String get viewList => 'Lista';

  @override
  String get viewFolders => 'Carpetas';

  @override
  String get sortTooltip => 'Ordenar';

  @override
  String get sortByName => 'Nombre (A–Z)';

  @override
  String get sortByRecent => 'Modificados hace poco';

  @override
  String get sortBySize => 'Los más grandes primero';

  @override
  String get sortDisabledLast => 'Los desactivados al final';

  @override
  String get libraryRefresh => 'Actualizar';

  @override
  String get libraryRootFolder => 'Carpeta Mods';

  @override
  String get selectionTooltip => 'Seleccionar';

  @override
  String selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionados',
      one: '1 seleccionado',
    );
    return '$_temp0';
  }

  @override
  String get selectionSelectAll => 'Seleccionar todo';

  @override
  String get selectionClear => 'Deseleccionar';

  @override
  String get selectionEnable => 'Activar';

  @override
  String get selectionDisable => 'Desactivar';

  @override
  String selectionProgress(int done, int total) {
    return '$done de $total';
  }

  @override
  String selectionDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Desinstalar $count mods?',
      one: '¿Desinstalar 1 mod?',
    );
    return '$_temp0';
  }

  @override
  String selectionDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Los $count archivos se borrarán del disco. No hay vuelta atrás.',
      one: 'El archivo se borrará del disco. No hay vuelta atrás.',
    );
    return '$_temp0';
  }

  @override
  String get selectionMove => 'Mover a…';

  @override
  String get newFolder => 'Nueva carpeta';

  @override
  String newFolderIn(String folder) {
    return 'Dentro de $folder';
  }

  @override
  String get newFolderHint => 'Nombre de la carpeta';

  @override
  String get create => 'Crear';

  @override
  String get move => 'Mover';

  @override
  String moveTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Adónde movemos los $count mods?',
      one: '¿Adónde movemos el mod?',
    );
    return '$_temp0';
  }

  @override
  String get moveBody =>
      'Los archivos cambian de carpeta en el disco. Nada más cambia: lo que esté desactivado sigue desactivado.';

  @override
  String get folderEmptySection => 'Aquí todavía no hay nada';

  @override
  String get install => 'Instalar';

  @override
  String filePickerModsLabel(String game) {
    return 'Mods de $game';
  }

  @override
  String get installWhereTitle => '¿Dónde va esto?';

  @override
  String installWhereBody(String game) {
    return '$game lee mods desde varias carpetas. La app puede deducirlo del propio archivo, o puedes decirle tú dónde va.';
  }

  @override
  String get installWhereSorted => 'Decídelo por mí';

  @override
  String get installWhereSortedDesc =>
      'Respeta las carpetas que trae la descarga y coloca el resto según el tipo de archivo.';

  @override
  String get installWhereRemember => 'No volver a preguntar';

  @override
  String get destinationSims1Downloads =>
      'Objetos, hacks y la mayoría de descargas.';

  @override
  String get destinationSims1Global =>
      'Cambios que afectan al juego base entero.';

  @override
  String get destinationSims1Objects =>
      'Cambios sobre los archivos de objetos del propio juego.';

  @override
  String get destinationSims1Skins =>
      'Pieles y cabezas de diario. Salen en Crear un Sim.';

  @override
  String get destinationSims1SkinsBuy =>
      'Ropa que se vende en las tiendas de los solares comunitarios.';

  @override
  String get destinationSims1Walls => 'Papeles y revestimientos de pared.';

  @override
  String get destinationSims1Floors => 'Suelos.';

  @override
  String get destinationSims1Roofs => 'Texturas de tejado.';

  @override
  String get prefAskWhereTitle => 'Preguntar dónde instalar';

  @override
  String get prefAskWhereDesc =>
      'Este juego lee mods de más de una carpeta. Elige la carpeta cada vez en lugar de dejar que decida la app';

  @override
  String get statTotal => 'Total';

  @override
  String get statEnabled => 'Activos';

  @override
  String get statDisabled => 'Inactivos';

  @override
  String get statConflicts => 'Conflictos';

  @override
  String get statTotalTooltip =>
      'Todos los mods de esta carpeta, activos o no.';

  @override
  String get statTotalTooltipClear =>
      'Todos los mods de esta carpeta. Haz clic para quitar la búsqueda y los filtros.';

  @override
  String get statEnabledTooltip => 'Los mods que el juego carga.';

  @override
  String get statEnabledTooltipActive =>
      'Mostrando solo los mods activos. Haz clic para ver todos otra vez.';

  @override
  String get statDisabledTooltip =>
      'Mods que están en la carpeta pero apagados.';

  @override
  String get statDisabledTooltipActive =>
      'Mostrando solo los mods inactivos. Haz clic para ver todos otra vez.';

  @override
  String get conflictTooltipActive =>
      'Mostrando solo los mods en conflicto. Haz clic para ver todos otra vez.';

  @override
  String get conflictTooltip =>
      'Mods activos que comparten nombre de archivo con otro mod activo, que están instalados en más de una versión, o que sobrescriben los mismos recursos del juego. El juego solo se queda con la copia que carga en último lugar: a veces es a propósito (mods de parche), pero muchas veces no.';

  @override
  String get conflictTooltipClickHint => 'Haz clic para ver solo estos mods.';

  @override
  String get filterAll => 'Todos';

  @override
  String get emptyFiltered => 'Ningún mod coincide con los filtros';

  @override
  String get emptyNoMods => 'Todavía no hay mods';

  @override
  String get emptyFilteredHint =>
      'Prueba a borrar la búsqueda o a elegir otro filtro.';

  @override
  String emptyNoModsHint(String path) {
    return 'Esta es la carpeta que se está vigilando:\n$path';
  }

  @override
  String get openFolder => 'Abrir carpeta';

  @override
  String get conflictBadge => 'conflicto';

  @override
  String modInFolder(String folder) {
    return 'en $folder';
  }

  @override
  String get modInModsFolder => 'en la carpeta Mods';

  @override
  String setupFoundNoModsFolder(String game) {
    return '$game está aquí, pero aún no tiene carpeta de mods';
  }

  @override
  String setupNotFound(String game) {
    return 'No se encuentra la carpeta de mods de $game';
  }

  @override
  String get setupFoundNoModsFolderBody =>
      'La carpeta del juego está en este ordenador, solo que todavía no contiene una carpeta de mods. Créala aquí abajo o elige una a mano.';

  @override
  String get setupNotFoundBody =>
      'Puede que el juego no esté instalado, que esté en un sitio poco habitual o que su carpeta de mods aún no exista.';

  @override
  String get foundOnThisComputer => 'ENCONTRADO EN ESTE ORDENADOR';

  @override
  String get chooseFolder => 'Elegir carpeta…';

  @override
  String get createItForMe => 'Créala por mí';

  @override
  String willBeCreatedAt(String path) {
    return 'Se creará en:\n$path';
  }

  @override
  String get checkAgain => 'Volver a comprobar';

  @override
  String get useThis => 'Usar esta';

  @override
  String get enabled => 'Activo';

  @override
  String get disabled => 'Inactivo';

  @override
  String get showInFileManager => 'Mostrar en el explorador';

  @override
  String get uninstallMod => 'Desinstalar mod';

  @override
  String uninstallConfirmTitle(String title) {
    return '¿Desinstalar $title?';
  }

  @override
  String uninstallConfirmBody(String path) {
    return 'El archivo se borrará del disco:\n$path';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get uninstall => 'Desinstalar';

  @override
  String conflictSameNameHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Otros $count mods activos tienen el mismo nombre de archivo:',
      one: 'Otro mod activo tiene el mismo nombre de archivo:',
    );
    return '$_temp0';
  }

  @override
  String conflictVersionHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Otros $count mods activos parecen versiones distintas de este mismo mod:',
      one: 'Otro mod activo parece una versión distinta de este mismo mod:',
    );
    return '$_temp0';
  }

  @override
  String conflictResourcesHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Otros $count mods activos sobrescriben los mismos recursos del juego:',
      one: 'Otro mod activo sobrescribe los mismos recursos del juego:',
    );
    return '$_temp0';
  }

  @override
  String sharedResources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recursos compartidos',
      one: '1 recurso compartido',
    );
    return '$_temp0';
  }

  @override
  String get conflictSameNameBody =>
      'Que dos archivos se llamen igual suele significar que el mismo mod está instalado dos veces, o que chocan los paquetes de dos creadores distintos. El juego carga sus recursos solapados en un orden impredecible: quédate con uno y desactiva o elimina el resto.';

  @override
  String get conflictVersionBody =>
      'Tener varias versiones del mismo mod instaladas hace que el juego cargue sus recursos solapados en un orden impredecible: quédate con la más nueva y desactiva o elimina las demás.';

  @override
  String get conflictResourcesBody =>
      'Estos paquetes contienen recursos con los mismos identificadores, así que el juego solo conserva la copia que carga en último lugar. Puede ser a propósito (los mods de parche y de sobrescritura tapan los recursos de otro mod aposta), pero entre mods que no tienen nada que ver significa que uno de ellos deja de funcionar sin avisar: quédate con el que quieras y desactiva el resto.';

  @override
  String get conflictIgnore => 'Ignorar';

  @override
  String get conflictIgnoreTooltip =>
      'Si este conflicto es a propósito, escóndelo. El mod no cambia en nada, y puedes recuperar el aviso desde esta página o desde los ajustes.';

  @override
  String get conflictRestore => 'Recuperar';

  @override
  String advisoryBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de tus mods tienen problemas conocidos',
      one: 'Uno de tus mods tiene un problema conocido',
    );
    return '$_temp0';
  }

  @override
  String get advisoryShow => 'Echar un vistazo';

  @override
  String get advisoryShowAll => 'Mostrar todos los mods';

  @override
  String get advisoryBadge => 'problema';

  @override
  String get advisoryBrokenHeading => 'Este mod está roto';

  @override
  String get advisoryBrokenBody =>
      'Otros jugadores están reportando que este rompe el juego. Desactivarlo es la forma más rápida de saber si es el culpable.';

  @override
  String get advisoryOutdatedHeading => 'Hay una versión más nueva de este mod';

  @override
  String get advisoryOutdatedBody =>
      'La versión que tienes es justo la que está dando problemas. Bajarte la última del creador debería arreglarlo.';

  @override
  String get advisoryCautionHeading => 'Conviene no perderlo de vista';

  @override
  String get advisoryCautionBody =>
      'A la mayoría le funciona, pero se sabe que a veces falla. Merece la pena desactivarlo si andas buscando un problema.';

  @override
  String advisorySince(String since) {
    return 'Desde $since';
  }

  @override
  String get advisoryOpenLink => 'Abrir la página del creador';

  @override
  String get advisorySource =>
      'Reportado por otros jugadores, no por el juego.';

  @override
  String modInDirectory(String dir) {
    return 'en $dir';
  }

  @override
  String get factVersion => 'Versión';

  @override
  String get factFormat => 'Formato';

  @override
  String get factSize => 'Tamaño';

  @override
  String get factType => 'Tipo';

  @override
  String get factModified => 'Modificado';

  @override
  String get factDownloads => 'Descargas';

  @override
  String get factIgnoredConflicts => 'Ignorados';

  @override
  String ignoredConflictsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conflictos',
      one: '1 conflicto',
    );
    return '$_temp0';
  }

  @override
  String get statusHeading => 'Estado';

  @override
  String get statusEnabledBody =>
      'Este mod está activo: el juego lo cargará la próxima vez que lo abras.';

  @override
  String statusDisabledBody(String marker) {
    return 'Este mod está desactivado: el archivo sigue en el disco con la marca «$marker» para que el juego lo ignore. Puedes reactivarlo cuando quieras; no se borra nada.';
  }

  @override
  String get fileOnDisk => 'Archivo en el disco';

  @override
  String get insideThePackage => 'Dentro del paquete';

  @override
  String resourcesTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recursos en total',
      one: '1 recurso en total',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get sectionModManagement => 'GESTIÓN DE MODS';

  @override
  String get sectionAppearance => 'APARIENCIA';

  @override
  String get sectionLanguage => 'IDIOMA';

  @override
  String get sectionPrivacy => 'PRIVACIDAD';

  @override
  String sectionModsFolder(String game) {
    return 'CARPETA DE MODS · $game';
  }

  @override
  String sectionGameCaches(String game) {
    return 'CACHÉ DEL JUEGO · $game';
  }

  @override
  String sectionIgnoredConflicts(String game) {
    return 'CONFLICTOS IGNORADOS · $game';
  }

  @override
  String get sectionFeedback => 'SUGERENCIAS';

  @override
  String get sectionAbout => 'ACERCA DE';

  @override
  String get prefWarnConflictsTitle => 'Avisar de los conflictos';

  @override
  String get prefWarnConflictsDesc =>
      'Marca los mods activos que repiten un nombre de archivo o que sobrescriben los mismos recursos del juego que otro mod';

  @override
  String get prefConfirmDeleteTitle => 'Confirmar antes de desinstalar';

  @override
  String get prefConfirmDeleteDesc =>
      'Preguntar antes de borrar del disco el archivo de un mod';

  @override
  String get prefShowDisabledTitle => 'Mostrar los mods desactivados';

  @override
  String get prefShowDisabledDesc =>
      'Deja los mods desactivados a la vista en la biblioteca en lugar de esconderlos';

  @override
  String get prefDisabledSuffixTitle => 'Marca de mod desactivado';

  @override
  String get prefDisabledSuffixDesc =>
      'Lo que se añade al nombre del archivo cuando desactivas un mod. Cámbialo para que coincida con otro gestor (CC Magic usa .off); la app lee las dos formas igualmente, y los mods que ya desactivaste conservan el nombre que tienen';

  @override
  String get prefDisabledSuffixInvalid =>
      'Tiene que ser un punto y unas letras o números, como .off';

  @override
  String get prefExperimentalPacksTitle =>
      'Interruptores de packs experimentales';

  @override
  String get prefExperimentalPacksDesc =>
      'Permite desactivar los packs de este juego. Sin probar en esta edición, y un vecindario jugado con un pack puede romperse sin él: haz copia de tus partidas primero';

  @override
  String get prefScanArtworkTitle => 'Analizar el interior de los mods';

  @override
  String get prefScanArtworkDesc =>
      'Mira dentro de los archivos de mod mientras carga la biblioteca para sacar sus imágenes, saber qué contienen y detectar mods que sobrescriben los mismos recursos';

  @override
  String get prefSoundEffectsTitle => 'Efectos de sonido';

  @override
  String get prefSoundEffectsDesc =>
      'Reproduce los sonidos clásicos de la interfaz de Los Sims al hacer clic, cambiar ajustes y en los avisos';

  @override
  String get prefAnalyticsTitle => 'Compartir datos de uso anónimos';

  @override
  String get prefAnalyticsDesc =>
      'Envía estadísticas de uso e informes de fallos anónimos para ayudar a mejorar la app. Nunca incluye nombres de mods, rutas de archivos ni nada personal';

  @override
  String get themeTitle => 'Tema';

  @override
  String get themeDesc =>
      'Claro u oscuro. «Sistema» sigue la configuración de tu ordenador.';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get languageTitle => 'Idioma de la app';

  @override
  String get languageDesc =>
      'Elige en qué idioma se muestra la app. «Sistema» sigue el idioma de tu ordenador.';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get translatorsTitle => 'Traducido por';

  @override
  String get translatorsDesc =>
      'La app habla once idiomas gracias a estos simmers.';

  @override
  String get folderNotFound => 'No encontrada. Elige una carpeta';

  @override
  String get folderNotLocated =>
      'No se ha encontrado el juego (o su carpeta de mods) automáticamente';

  @override
  String folderSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods',
      one: '1 mod',
    );
    return '$_temp0 · $size en el disco';
  }

  @override
  String get customFolder => 'carpeta personalizada';

  @override
  String get change => 'Cambiar…';

  @override
  String get resetToAuto => 'Volver a automático';

  @override
  String createDefaultFolderAt(String path) {
    return 'Crear la carpeta por defecto (con los archivos que necesita el juego) en:\n$path';
  }

  @override
  String get createFolder => 'Crear carpeta';

  @override
  String get alsoFoundOnThisComputer =>
      'También encontradas en este ordenador:';

  @override
  String get clearCacheTitle => 'Borrar los archivos de caché';

  @override
  String clearCacheDesc(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Borra $count archivos de caché ($size)',
      one: 'Borra 1 archivo de caché ($size)',
    );
    return '$_temp0 para que aparezca el contenido que acabas de añadir o quitar; el juego los vuelve a crear la próxima vez que lo abras';
  }

  @override
  String get clearCaches => 'Borrar caché';

  @override
  String get ignoredConflictsTitle => 'Conflictos que estás ignorando';

  @override
  String ignoredConflictsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count conflictos que le dijiste a la app que dejara de avisarte. Recupéralos para volver a verlos en la biblioteca',
      one:
          'Un conflicto que le dijiste a la app que dejara de avisarte. Recupéralo para volver a verlo en la biblioteca',
    );
    return '$_temp0';
  }

  @override
  String get ignoredConflictsReset => 'Recuperarlos';

  @override
  String get reportBugTitle => 'Informar de un fallo';

  @override
  String get reportBugDesc =>
      'Abre un informe de fallo en GitHub con tu versión de la app, tu sistema operativo y el juego actual ya rellenados';

  @override
  String get reportBugButton => 'Informar…';

  @override
  String get suggestFeatureTitle => 'Sugerir una función';

  @override
  String get suggestFeatureDesc =>
      '¿Echas algo en falta? Cuéntanos qué haría mejor al gestor de mods';

  @override
  String get suggestFeatureButton => 'Sugerir…';

  @override
  String get wikiTitle => 'Guía y preguntas frecuentes';

  @override
  String get wikiDesc =>
      'Cómo instalar mods, arreglar la detección de carpetas y mucho más, en la wiki del proyecto';

  @override
  String get wikiButton => 'Abrir la wiki';

  @override
  String aboutTagline(String version) {
    return 'Versión $version · Compatible con Los Sims 1-4 · SimCity muy pronto';
  }

  @override
  String updateIsAvailable(String version) {
    return 'La versión $version ya está disponible';
  }

  @override
  String get noUpdateFound => 'No hay actualizaciones';

  @override
  String getVersion(String version) {
    return 'Descargar v$version';
  }

  @override
  String get checkingForUpdates => 'Comprobando…';

  @override
  String get checkForUpdates => 'Buscar actualizaciones';

  @override
  String get categoryPackage => 'Paquete';

  @override
  String get categoryScript => 'Script';

  @override
  String get categoryObject => 'Objeto';

  @override
  String get categoryArchive => 'Archivo';

  @override
  String get categorySkin => 'Skin';

  @override
  String get categoryTexture => 'Textura';

  @override
  String get categoryWall => 'Pared';

  @override
  String get categoryFloor => 'Suelo';

  @override
  String get contentCasParts => 'piezas de CAS';

  @override
  String get contentObjects => 'objetos';

  @override
  String get contentTunings => 'tunings';

  @override
  String get contentBehaviors => 'comportamientos';

  @override
  String get contentTextTables => 'tablas de texto';

  @override
  String get contentTextures => 'texturas';

  @override
  String get contentMeshes => 'mallas';

  @override
  String errorNoModFiles(String extensions, String name) {
    return 'No hay archivos de mods ($extensions) dentro de $name.';
  }

  @override
  String errorUnreadableArchive(String name) {
    return '$name no es un zip que esta app pueda leer.';
  }

  @override
  String errorNoUnpacker(String format, String name) {
    return 'Nada en este ordenador puede descomprimir archivos $format. Descomprime $name por tu cuenta e instala los archivos que haya dentro.';
  }

  @override
  String errorNoUnpackerLinux(String format, String name) {
    return 'Nada en este ordenador puede descomprimir archivos $format. Instala p7zip y vuelve a intentarlo, o descomprime $name por tu cuenta e instala los archivos que haya dentro.';
  }

  @override
  String errorNoUnpackerLinuxRar(String format, String name) {
    return 'Nada en este ordenador puede descomprimir archivos $format. Instala p7zip o unrar y vuelve a intentarlo, o descomprime $name por tu cuenta e instala los archivos que haya dentro.';
  }

  @override
  String errorUnpackFailed(String name) {
    return 'No se pudo descomprimir $name. Puede que tenga contraseña, que sea una parte de un archivo dividido o que la descarga esté dañada. Descomprímelo a mano e instala los archivos que haya dentro.';
  }

  @override
  String errorSims3PackUnreadable(String name) {
    return '$name no es un paquete de Los Sims 3 que esta app pueda leer.';
  }

  @override
  String errorSims3PackWorld(String name) {
    return '$name es un mundo, no contenido personalizado. Instálalo con el Launcher de Los Sims 3: el juego guarda los mundos fuera de la carpeta de mods.';
  }

  @override
  String errorSims3PackLibrary(String name) {
    return '$name es un solar o una familia, no contenido personalizado. Instálalo con el Launcher de Los Sims 3: acaba en tu Biblioteca dentro del juego.';
  }

  @override
  String errorInstallFailed(String name, String reason) {
    return 'No se pudo instalar «$name»: $reason. Si sigue fallando, descomprímelo a mano e instala los archivos que haya dentro.';
  }

  @override
  String errorInstallFailedRaw(String name, String reason) {
    return 'No se pudo instalar «$name»: $reason';
  }

  @override
  String errorFileInUseDelete(String name) {
    return 'No se pudo borrar «$name»: lo está usando otro programa (¿tienes el juego abierto?) o está protegido contra escritura. Cierra lo que lo esté usando y vuelve a intentarlo.';
  }

  @override
  String errorFileInUseRename(String name) {
    return 'No se pudo renombrar «$name»: lo está usando otro programa (¿tienes el juego abierto?) o está protegido contra escritura. Cierra lo que lo esté usando y vuelve a intentarlo.';
  }

  @override
  String errorFileNameTaken(String name) {
    return 'En esa carpeta ya hay un “$name”. Cambia el nombre de uno de los dos e inténtalo otra vez.';
  }

  @override
  String errorFolderNameBad(String name) {
    return '“$name” no vale como nombre de carpeta. Prueba con uno sin barras ni caracteres que reserve tu sistema.';
  }

  @override
  String errorFolderTooDeep(int levels) {
    return 'El juego solo mira $levels carpetas hacia dentro de la carpeta de mods, así que nada de lo que pongas más abajo se cargaría.';
  }

  @override
  String errorBulkMoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods no se pudieron mover',
      one: '1 mod no se pudo mover',
    );
    return '$_temp0: puede que otro programa los esté usando (¿tienes el juego abierto?), que estén protegidos contra escritura o que ya haya un archivo con ese nombre en la carpeta.';
  }

  @override
  String errorBulkToggleFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods no se pudieron cambiar',
      one: '1 mod no se pudo cambiar',
    );
    return '$_temp0: puede que otro programa los esté usando (¿tienes el juego abierto?) o que estén protegidos contra escritura.';
  }

  @override
  String errorBulkRemoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods no se pudieron borrar',
      one: '1 mod no se pudo borrar',
    );
    return '$_temp0: puede que otro programa los esté usando (¿tienes el juego abierto?) o que estén protegidos contra escritura.';
  }

  @override
  String errorFileMissing(String name) {
    return '«$name» ya no está en la carpeta de mods: puede que otro programa lo haya movido o borrado.';
  }

  @override
  String get requirementMedievalModLoader =>
      'Los Sims Medieval no puede ejecutar mods de script ni de núcleo sin el archivo cargador de la comunidad en la carpeta Game\\Bin del juego. El contenido personalizado sí funciona; lo demás no.';

  @override
  String get requirementSims4ModsOff =>
      'El juego tiene el contenido personalizado y los mods desactivados en sus propias Opciones de juego, así que no se está cargando nada. Vuelve a activarlo en Opciones → Opciones de juego → Otros y reinicia el juego.';

  @override
  String get requirementSims4ScriptModsOff =>
      'Tienes mods de script aquí, pero el juego tiene «Permitir mods de script» desactivado en sus Opciones de juego. Las actualizaciones lo reinician.';

  @override
  String get requirementGetFile => 'Dónde conseguirlo';

  @override
  String tooDeepBanner(int count, int levels) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hay $count mods',
      one: 'Hay un mod',
    );
    return '$_temp0 en una subcarpeta que el juego no lee. Solo mira $levels carpetas hacia dentro. Súbelos y funcionarán.';
  }

  @override
  String get tooDeepShow => 'Enséñamelos';

  @override
  String errorNoWriteAccess(String folder) {
    return 'La app no tiene permiso para escribir en «$folder». Tu sistema protege esa carpeta: dale permiso de escritura a tu cuenta, o elige otra carpeta en Ajustes.';
  }

  @override
  String get folderReadOnlyBanner =>
      'Esta carpeta de mods es de solo lectura, así que instalar y quitar mods no va a funcionar hasta que tu cuenta pueda escribir en ella.';

  @override
  String get elevatedNoDropBanner =>
      'Estás ejecutando como administrador, así que Windows no deja arrastrar archivos a la ventana. Usa el botón Instalar, que sigue funcionando.';

  @override
  String errorShopDownload(String name) {
    return '«$name» no se pudo descargar de The Exchange. Revisa tu conexión e inténtalo otra vez.';
  }

  @override
  String errorShopNoModFiles(String name) {
    return 'No hay nada que este juego pueda instalar dentro de “$name”. Igual ni siquiera es un mod - usa Descargar para guardar el archivo donde tú quieras.';
  }

  @override
  String get errorShopListingNotFound =>
      'Ese mod ya no está en The Exchange. Puede que lo hayan retirado.';

  @override
  String get errorShopListingUnknownGame =>
      'Ese mod es para un juego que esta versión de la app todavía no conoce. Prueba a actualizar.';

  @override
  String errorPackToggleFailed(String pack) {
    return 'No se ha podido cambiar $pack. Cierra el juego e inténtalo otra vez.';
  }

  @override
  String get errorPackNoUserData =>
      'No se encuentra la carpeta de ajustes del juego, así que no hay dónde apuntar qué packs saltarse. Abre el juego una vez primero.';

  @override
  String get errorPackNeedsAdmin =>
      'Windows no ha dejado que la app cambie eso. Reiníciala como administrador e inténtalo otra vez.';

  @override
  String get errorPackNotSupported =>
      'En este sistema no se pueden activar ni desactivar packs.';

  @override
  String get errorPackIsTheGame =>
      'Ese es el pack desde el que arranca el juego, así que tiene que quedarse activo.';

  @override
  String get errorPackToggleRefused =>
      'No se ha podido cambiar ese pack. Cierra el juego e inténtalo otra vez.';

  @override
  String get eraClassic => 'Clásico';

  @override
  String get eraNightlife => 'Noctámbulas';

  @override
  String get eraAmbitions => 'Triunfadores';

  @override
  String get eraModern => 'Moderno';

  @override
  String get eraMedieval => 'Medieval';

  @override
  String get navPacks => 'Packs';

  @override
  String get packsScanning => 'Buscando tus packs…';

  @override
  String get packsEmptyTitle => 'No se han encontrado packs';

  @override
  String packsEmptyBody(String game) {
    return 'O $game no está instalado donde la app pueda verlo, o todavía no hay packs junto a él.';
  }

  @override
  String get packsRescan => 'Volver a comprobar';

  @override
  String packsSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count packs instalados',
      one: '1 pack instalado',
    );
    return '$_temp0';
  }

  @override
  String packsSummaryWithOff(int count, int off) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count packs activos',
      one: '1 pack activo',
    );
    return '$_temp0, $off desactivados';
  }

  @override
  String get packsOff => 'Desactivado';

  @override
  String get packsInstalled => 'Instalado';

  @override
  String get packsNeedAdmin =>
      'Cambiar estos packs necesita permisos de administrador, porque ahí es donde el juego guarda su lista. Reinicia la app como administrador para tocarlos: mientras tanto arrastrar y soltar deja de funcionar, así que conviene volver atrás después.';

  @override
  String get packsExperimentalTitle => 'Desactivarlos es experimental';

  @override
  String get packsExperimentalOff =>
      'Funciona como siempre ha funcionado en este juego, pero nadie lo ha probado en esta edición, y un vecindario que has jugado con un pack puede romperse si lo abres sin él. Verlos es seguro. Activa los interruptores experimentales en Ajustes si aun así quieres probarlo.';

  @override
  String get packsExperimentalOn =>
      'Haz antes una copia de tus vecindarios. Un vecindario que has jugado con un pack puede romperse si lo abres sin él, y eso no se deshace desde aquí: volver a activar el pack no siempre recupera la partida.';

  @override
  String packsRestartNotice(String game) {
    return 'Reinicia $game para que surta efecto. Tus packs siguen instalados igualmente.';
  }

  @override
  String packsAllOwnedSims4(String expansions, String gamePacks) {
    return '$expansions packs de expansión. $gamePacks packs de juego. Los compraste todos, claro.';
  }

  @override
  String get packKindExpansions => 'Packs de expansión';

  @override
  String get packKindGamePacks => 'Packs de juego';

  @override
  String get packKindStuffPacks => 'Packs de accesorios';

  @override
  String get packKindKits => 'Kits';

  @override
  String get packKindFreePacks => 'Packs gratuitos';

  @override
  String get navSaves => 'Partidas';

  @override
  String get savesScanning => 'Leyendo tus partidas…';

  @override
  String get savesEmptyTitle => 'No hay partidas guardadas';

  @override
  String savesEmptyBody(String game) {
    return 'Cuando juegues a $game y guardes, tus mundos aparecerán aquí: familias, fotos y todo lo demás.';
  }

  @override
  String get savesRescan => 'Volver a buscar';

  @override
  String savesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partidas encontradas',
      one: '1 partida encontrada',
    );
    return '$_temp0';
  }

  @override
  String savesLastSaved(String date) {
    return 'Último guardado: $date';
  }

  @override
  String get savesShowInFolder => 'Mostrar en la carpeta';

  @override
  String savesBackups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count copias de seguridad',
      one: '1 copia de seguridad',
    );
    return '$_temp0';
  }

  @override
  String get savesTabHouseholds => 'Familias';

  @override
  String get savesTabAlbum => 'Álbum de fotos';

  @override
  String get savesTabStats => 'Estadísticas';

  @override
  String savesNeighborhood(int number) {
    return 'Barrio $number';
  }

  @override
  String get savesOtherHouseholds => 'Vecinos y otras familias';

  @override
  String savesSimCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sims',
      one: '1 sim',
    );
    return '$_temp0';
  }

  @override
  String get savesFunds => 'Fondos';

  @override
  String get savesRooms => 'Habitaciones';

  @override
  String savesBedsBaths(int beds, int baths) {
    return '$beds dorm. · $baths baños';
  }

  @override
  String savesByCreator(String name) {
    return 'de $name';
  }

  @override
  String get savesMembers => 'Miembros';

  @override
  String get savesRelationships => 'Relaciones';

  @override
  String get savesUnknownSim => 'Sim desconocido';

  @override
  String get savesStatSims => 'Sims';

  @override
  String get savesStatHouseholds => 'Familias';

  @override
  String get savesStatNetWorth => 'Patrimonio';

  @override
  String get savesStatWorlds => 'Mundos';

  @override
  String get savesStatPhotos => 'Fotos';

  @override
  String savesAcrossHouseholds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'en $count familias',
      one: 'en 1 familia',
    );
    return '$_temp0';
  }

  @override
  String savesPlayedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jugadas',
      one: '1 jugada',
    );
    return '$_temp0';
  }

  @override
  String get savesSizeOnDisk => 'Espacio en disco';

  @override
  String get savesLifeStages => 'Etapas de vida';

  @override
  String get savesTopSkills => 'Mejores habilidades de esta partida';

  @override
  String get savesSaveInfo => 'Archivo de guardado';

  @override
  String get savesLastSavedLabel => 'Último guardado';

  @override
  String get savesGameVersion => 'Versión del juego';

  @override
  String get savesDescription => 'Descripción';

  @override
  String get savesAgeInfant => 'Recién nacido';

  @override
  String get savesAgeBaby => 'Bebé';

  @override
  String get savesAgeToddler => 'Infante';

  @override
  String get savesAgeChild => 'Niño';

  @override
  String get savesAgeTeen => 'Adolescente';

  @override
  String get savesAgeYoungAdult => 'Joven adulto';

  @override
  String get savesAgeAdult => 'Adulto';

  @override
  String get savesAgeElder => 'Anciano';

  @override
  String get savesGenderMale => 'Hombre';

  @override
  String get savesGenderFemale => 'Mujer';

  @override
  String get savesSkillCooking => 'Cocina';

  @override
  String get savesSkillMechanical => 'Mecánica';

  @override
  String get savesSkillCharisma => 'Carisma';

  @override
  String get savesSkillBody => 'Cuerpo';

  @override
  String get savesSkillLogic => 'Lógica';

  @override
  String get savesSkillCreativity => 'Creatividad';

  @override
  String get savesSkillCleaning => 'Limpieza';

  @override
  String get savesPersonalityNeat => 'Ordenado';

  @override
  String get savesPersonalityOutgoing => 'Sociable';

  @override
  String get savesPersonalityActive => 'Activo';

  @override
  String get savesPersonalityPlayful => 'Juguetón';

  @override
  String get savesPersonalityNice => 'Simpático';

  @override
  String get savesZodiacAries => 'Aries';

  @override
  String get savesZodiacTaurus => 'Tauro';

  @override
  String get savesZodiacGemini => 'Géminis';

  @override
  String get savesZodiacCancer => 'Cáncer';

  @override
  String get savesZodiacLeo => 'Leo';

  @override
  String get savesZodiacVirgo => 'Virgo';

  @override
  String get savesZodiacLibra => 'Libra';

  @override
  String get savesZodiacScorpio => 'Escorpio';

  @override
  String get savesZodiacSagittarius => 'Sagitario';

  @override
  String get savesZodiacCapricorn => 'Capricornio';

  @override
  String get savesZodiacAquarius => 'Acuario';

  @override
  String get savesZodiacPisces => 'Piscis';

  @override
  String get savesAspirationRomance => 'Romance';

  @override
  String get savesAspirationFamily => 'Familia';

  @override
  String get savesAspirationFortune => 'Fortuna';

  @override
  String get savesAspirationPopularity => 'Popularidad';

  @override
  String get savesAspirationKnowledge => 'Conocimiento';

  @override
  String get savesAspirationGrowUp => 'Crecer';

  @override
  String get savesAspirationPleasure => 'Placer';

  @override
  String get savesAspirationGrilledCheese => 'Sándwich de queso';

  @override
  String get savesRelCrush => 'flechazo';

  @override
  String get savesRelLove => 'enamorados';

  @override
  String get savesRelEngaged => 'prometidos';

  @override
  String get savesRelMarried => 'casados';

  @override
  String get savesRelFriends => 'amigos';

  @override
  String get savesRelBestFriends => 'mejores amigos';

  @override
  String get savesRelSteady => 'en pareja';

  @override
  String get savesRelEnemies => 'enemigos';

  @override
  String get savesPhotoFamilyPortrait => 'Retrato familiar';

  @override
  String get savesPhotoLot => 'Solar';

  @override
  String get savesPhotoSim => 'Retrato de sim';

  @override
  String get savesPhotoSnapshot => 'Instantánea';

  @override
  String get savesProperty => 'Propiedad';

  @override
  String get savesGhost => 'fantasma';

  @override
  String savesCareerLevel(String career, int level) {
    return '$career · nivel $level';
  }

  @override
  String get savesSpeciesLargeDog => 'perro';

  @override
  String get savesSpeciesSmallDog => 'perro pequeño';

  @override
  String get savesSpeciesCat => 'gato';

  @override
  String get savesOccultVampire => 'vampiro';

  @override
  String get savesOccultZombie => 'zombi';

  @override
  String get savesOccultWerewolf => 'hombre lobo';

  @override
  String get savesOccultPlantSim => 'PlantSim';

  @override
  String get savesOccultAlien => 'alienígena';

  @override
  String get savesOccultServo => 'servo';

  @override
  String get savesOccultWitch => 'bruja';

  @override
  String get savesOccultBigfoot => 'Pie Grande';

  @override
  String get savesOccultFairy => 'hada';

  @override
  String get savesOccultGenie => 'genio';

  @override
  String get savesOccultMermaid => 'sirena';

  @override
  String get savesLotResidential => 'Residencial';

  @override
  String get savesLotCommunity => 'Solar comunitario';

  @override
  String get savesLotDorm => 'Residencia';

  @override
  String get savesLotSecretSociety => 'Sociedad secreta';

  @override
  String get savesLotGreekHouse => 'Casa griega';

  @override
  String get savesLotHotel => 'Hotel';

  @override
  String get savesLotSecret => 'Solar secreto';

  @override
  String get savesLotBusiness => 'Negocio';

  @override
  String get savesLotApartment => 'Apartamento';

  @override
  String savesGpa(String gpa) {
    return 'nota media $gpa';
  }

  @override
  String savesSemester(int number) {
    return 'semestre $number';
  }

  @override
  String savesPredestinedHobby(String hobby) {
    return 'Nacido para $hobby';
  }

  @override
  String get savesHobbyCuisine => 'Cocina';

  @override
  String get savesHobbyArts => 'Manualidades';

  @override
  String get savesHobbyFilm => 'Cine y literatura';

  @override
  String get savesHobbySports => 'Deportes';

  @override
  String get savesHobbyGames => 'Juegos';

  @override
  String get savesHobbyNature => 'Naturaleza';

  @override
  String get savesHobbyTinkering => 'Cacharreo';

  @override
  String get savesHobbyFitness => 'Fitness';

  @override
  String get savesHobbyScience => 'Ciencia';

  @override
  String get savesHobbyMusic => 'Música y baile';

  @override
  String get savesTieMother => 'madre';

  @override
  String get savesTieFather => 'padre';

  @override
  String get savesTieSpouse => 'casado con';

  @override
  String savesTieSibling(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hermanos',
      one: 'hermano',
    );
    return '$_temp0';
  }

  @override
  String savesTieChild(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hijos',
      one: 'hijo',
    );
    return '$_temp0';
  }

  @override
  String get savesInterestPolitics => 'Política';

  @override
  String get savesInterestMoney => 'Dinero';

  @override
  String get savesInterestEnvironment => 'Medio ambiente';

  @override
  String get savesInterestCrime => 'Crimen';

  @override
  String get savesInterestEntertainment => 'Ocio';

  @override
  String get savesInterestCulture => 'Cultura';

  @override
  String get savesInterestFood => 'Comida';

  @override
  String get savesInterestHealth => 'Salud';

  @override
  String get savesInterestFashion => 'Moda';

  @override
  String get savesInterestSports => 'Deportes';

  @override
  String get savesInterestParanormal => 'Paranormal';

  @override
  String get savesInterestTravel => 'Viajes';

  @override
  String get savesInterestWork => 'Trabajo';

  @override
  String get savesInterestWeather => 'Clima';

  @override
  String get savesInterestAnimals => 'Animales';

  @override
  String get savesInterestSchool => 'Escuela';

  @override
  String get savesInterestToys => 'Juguetes';

  @override
  String get savesInterestSciFi => 'Ciencia ficción';

  @override
  String get savesInterestMusic => 'Música';

  @override
  String get savesInterestOutdoors => 'Aire libre';

  @override
  String get setupHelpSims1 =>
      'El primer Los Sims guarda el contenido personalizado dentro de su carpeta de instalación, no en Documentos: los objetos van a una carpeta Downloads junto al ejecutable del juego (por ejemplo C:\\Program Files (x86)\\Maxis\\The Sims\\Downloads), y esta app ordena los demás tipos automáticamente: las skins (.skn/.cmx/.bmp) van a GameData\\Skins, y las paredes y suelos a GameData\\Walls y GameData\\Floors. La Legacy Collection de 2025 funciona igual desde su propia carpeta de instalación (EA Games\\The Sims Legacy, o Steam\\steamapps\\common\\The Sims Legacy Collection). Si tienes el juego instalado en otro sitio (otro disco, una biblioteca de Steam personalizada), elige su carpeta Downloads a mano.';

  @override
  String get setupHelpSims2 =>
      'Los Sims 2 carga el contenido personalizado desde Documentos > EA Games > Los Sims 2 > Downloads (la Ultimate Collection usa «The Sims 2 Ultimate Collection» y la Legacy Collection de 2025 usa «The Sims 2 Legacy»). Puede que la carpeta no exista hasta que la crees o instales contenido una primera vez. Cuando arranques el juego, responde «Sí» al aviso sobre el contenido personalizado para que se activen las descargas.';

  @override
  String get setupHelpSims3 =>
      'Los Sims 3 no crea la carpeta de mods por su cuenta: necesita el «framework» de la comunidad, es decir, una carpeta Mods > Packages dentro de Documentos > Electronic Arts > Los Sims 3, más un archivo Resource.cfg que le diga al juego que la lea. Esta app puede crear las dos cosas por ti. En instalaciones de disco o con Wine la carpeta puede estar dentro del propio paquete del juego; usa «Elegir carpeta» para señalarla.';

  @override
  String get setupHelpSims4 =>
      'Los Sims 4 carga los mods desde Documentos > Electronic Arts > Los Sims 4 > Mods. El juego crea esa carpeta la primera vez que se abre, así que ábrelo una vez si no la ves. Después, dentro del juego, activa Opciones > Opciones de juego > Otros > «Habilitar contenido personalizado y mods» (y «Mods de script permitidos» para los archivos .ts4script) y reinicia el juego.';

  @override
  String get setupHelpSimsMedieval =>
      'Los Sims Medieval carga los mods desde su carpeta de instalación, no desde Documentos: una carpeta Mods > Packages junto a los archivos del juego (por ejemplo C:\\Program Files (x86)\\Origin Games\\The Sims Medieval), más un archivo Resource.cfg en la carpeta de instalación que le diga al juego que la lea. Esta app puede crear las dos cosas por ti (Windows puede pedirte permisos de administrador dentro de Archivos de programa). La carpeta Documentos > Electronic Arts > The Sims Medieval solo guarda partidas; los mods que pongas ahí no hacen nada. Si lo tienes con Wine/CrossOver o en una biblioteca de Steam personalizada, usa «Elegir carpeta» para señalar la carpeta Mods > Packages de dentro de la instalación.';
}
