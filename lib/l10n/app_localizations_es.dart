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
  String get navSettings => 'Ajustes';

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
  String get install => 'Instalar';

  @override
  String filePickerModsLabel(String game) {
    return 'Mods de $game';
  }

  @override
  String get statTotal => 'Total';

  @override
  String get statEnabled => 'Activos';

  @override
  String get statDisabled => 'Inactivos';

  @override
  String get statConflicts => 'Conflictos';

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
