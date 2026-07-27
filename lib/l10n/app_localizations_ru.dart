// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class LRu extends L {
  LRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Sims Mod Manager';

  @override
  String get brandTitle => 'Мод-менеджер';

  @override
  String get brandSubtitle => 'для The Sims';

  @override
  String get navLibrary => 'Библиотека';

  @override
  String get navShop => 'The Exchange';

  @override
  String get navSettings => 'Настройки';

  @override
  String get shopAlphaBadge => 'АЛЬФА';

  @override
  String get shopTagline => 'Моды от сообщества: ставятся в один клик.';

  @override
  String shopListingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count мода на полках',
      many: '$count модов на полках',
      few: '$count мода на полках',
      one: '$count мод на полках',
    );
    return '$_temp0';
  }

  @override
  String get shopRefresh => 'Обновить';

  @override
  String get shopPublish => 'Опубликуй свои моды';

  @override
  String get shopLoadFailedTitle => 'The Exchange не отвечает';

  @override
  String get shopLoadFailedBody =>
      'Не получилось загрузить полки. Проверь соединение и попробуй ещё раз.';

  @override
  String get shopRetry => 'Попробовать ещё раз';

  @override
  String get shopEmptyTitle => 'Полки пока пустые';

  @override
  String get shopEmptyBody =>
      'The Exchange только-только открылся, и ещё никто ничего не опубликовал. Вот настолько тут всё свежее. Делаешь моды? Займи полку первым!';

  @override
  String get shopAllGames => 'Все игры';

  @override
  String get shopShowAllGames => 'Показать все игры';

  @override
  String shopEmptyGameTitle(String game) {
    return 'Для $game пока пусто';
  }

  @override
  String shopEmptyGameBody(String game) {
    return 'На полках уже есть моды для других игр, а для $game ещё никто ничего не выложил. Есть свой? Займи полку первым!';
  }

  @override
  String shopBy(String author) {
    return 'от $author';
  }

  @override
  String get shopInstalled => 'Установлен';

  @override
  String get shopUpdate => 'Обновить';

  @override
  String get shopUpdateBadge => 'обновление';

  @override
  String shopUpdatesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'У $count твоих модов вышли новые версии на The Exchange',
      many: 'У $count твоих модов вышли новые версии на The Exchange',
      few: 'У $count твоих модов вышли новые версии на The Exchange',
      one: 'У $count твоего мода вышла новая версия на The Exchange',
    );
    return '$_temp0';
  }

  @override
  String get shopUpdateHeading => 'У этого мода вышла новая версия';

  @override
  String shopUpdateBody(String version, String author) {
    return '$author опубликовал(а) v$version на The Exchange. Обновление заменит файлы, которые у тебя сейчас.';
  }

  @override
  String get shopUpdateSeeListing => 'Открыть карточку';

  @override
  String get shopInstalling => 'Устанавливаем…';

  @override
  String get shopInstallNotes => 'Заметки по установке';

  @override
  String get shopCreatorNudge =>
      'Делаешь моды? Публиковать на The Exchange бесплатно, а игроки ставят твои работы в один клик.';

  @override
  String shopNeedsFolder(String game) {
    return 'Сначала настрой папку модов для $game. Вкладка «Библиотека» всё подскажет.';
  }

  @override
  String get shopBack => 'Назад к полкам';

  @override
  String get shopCopyLink => 'Копировать ссылку';

  @override
  String get shopLinkCopied => 'Ссылка скопирована';

  @override
  String get sidebarGames => 'ИГРЫ';

  @override
  String sidebarNotInstalled(String detail) {
    return 'не установлена · $detail';
  }

  @override
  String sidebarModCount(int count, String detail) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count мода',
      many: '$count модов',
      few: '$count мода',
      one: '$count мод',
    );
    return '$_temp0 · $detail';
  }

  @override
  String get updateAvailable => 'Есть обновление';

  @override
  String updateClickToDownload(String version) {
    return 'v$version: нажми, чтобы скачать';
  }

  @override
  String get storage => 'Хранилище';

  @override
  String storageInMods(String size) {
    return '$size в модах';
  }

  @override
  String storageFreeOf(String free, String total) {
    return '$free свободно из $total';
  }

  @override
  String dropToInstall(String game) {
    return 'Отпусти, чтобы установить в $game';
  }

  @override
  String get dropFolders => 'папки';

  @override
  String scanningMods(int done, int total) {
    return 'Заглядываем внутрь модов: ищем картинки и конфликты… $done из $total';
  }

  @override
  String get skip => 'Пропустить';

  @override
  String libraryTitle(String game) {
    return 'Библиотека $game';
  }

  @override
  String modsShown(int count, String era) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'показано $count мода',
      many: 'показано $count модов',
      few: 'показано $count мода',
      one: 'показан $count мод',
    );
    return '$_temp0 · $era';
  }

  @override
  String get learnMore => 'Подробнее';

  @override
  String get dismiss => 'Скрыть';

  @override
  String get searchMods => 'Поиск модов…';

  @override
  String get install => 'Установить';

  @override
  String filePickerModsLabel(String game) {
    return 'Моды для $game';
  }

  @override
  String get statTotal => 'Всего';

  @override
  String get statEnabled => 'Включено';

  @override
  String get statDisabled => 'Выключено';

  @override
  String get statConflicts => 'Конфликты';

  @override
  String get conflictTooltipActive =>
      'Показаны только конфликтующие моды. Нажми, чтобы снова увидеть все.';

  @override
  String get conflictTooltip =>
      'Включённые моды, у которых совпадает имя файла с другим включённым модом, которые установлены сразу в нескольких версиях или которые переопределяют одни и те же игровые ресурсы. Игра оставит только ту копию, что загрузилась последней — иногда это задумано (моды-патчи), но чаще нет.';

  @override
  String get conflictTooltipClickHint =>
      'Нажми, чтобы показать только эти моды.';

  @override
  String get filterAll => 'Все';

  @override
  String get emptyFiltered => 'Под фильтры не подходит ни один мод';

  @override
  String get emptyNoMods => 'Модов пока нет';

  @override
  String get emptyFilteredHint =>
      'Попробуй очистить поиск или выбрать другой фильтр.';

  @override
  String emptyNoModsHint(String path) {
    return 'Вот папка, за которой мы следим:\n$path';
  }

  @override
  String get openFolder => 'Открыть папку';

  @override
  String get conflictBadge => 'конфликт';

  @override
  String modInFolder(String folder) {
    return 'в $folder';
  }

  @override
  String get modInModsFolder => 'в папке Mods';

  @override
  String setupFoundNoModsFolder(String game) {
    return '$game нашлась, но папки для модов пока нет';
  }

  @override
  String setupNotFound(String game) {
    return 'Папка модов $game не найдена';
  }

  @override
  String get setupFoundNoModsFolderBody =>
      'Папка игры на этом компьютере есть, просто внутри пока нет папки для модов. Создай её ниже или укажи вручную.';

  @override
  String get setupNotFoundBody =>
      'Возможно, игра не установлена, лежит в необычном месте, или её папка для модов ещё не создана.';

  @override
  String get foundOnThisComputer => 'НАЙДЕНО НА ЭТОМ КОМПЬЮТЕРЕ';

  @override
  String get chooseFolder => 'Выбрать папку…';

  @override
  String get createItForMe => 'Создай за меня';

  @override
  String willBeCreatedAt(String path) {
    return 'Будет создана здесь:\n$path';
  }

  @override
  String get checkAgain => 'Проверить снова';

  @override
  String get useThis => 'Взять эту';

  @override
  String get enabled => 'Включён';

  @override
  String get disabled => 'Выключен';

  @override
  String get showInFileManager => 'Показать в проводнике';

  @override
  String get uninstallMod => 'Удалить мод';

  @override
  String uninstallConfirmTitle(String title) {
    return 'Удалить $title?';
  }

  @override
  String uninstallConfirmBody(String path) {
    return 'Файл будет удалён с диска:\n$path';
  }

  @override
  String get cancel => 'Отмена';

  @override
  String get uninstall => 'Удалить';

  @override
  String conflictSameNameHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ещё у $count включённых модов такое же имя файла:',
      many: 'Ещё у $count включённых модов такое же имя файла:',
      few: 'Ещё у $count включённых модов такое же имя файла:',
      one: 'Ещё у одного включённого мода такое же имя файла:',
    );
    return '$_temp0';
  }

  @override
  String conflictVersionHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Ещё $count включённых мода похожи на другие версии этого же мода:',
      many:
          'Ещё $count включённых модов похожи на другие версии этого же мода:',
      few: 'Ещё $count включённых мода похожи на другие версии этого же мода:',
      one: 'Ещё один включённый мод похож на другую версию этого же мода:',
    );
    return '$_temp0';
  }

  @override
  String conflictResourcesHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ещё $count включённых мода переопределяют те же игровые ресурсы:',
      many: 'Ещё $count включённых модов переопределяют те же игровые ресурсы:',
      few: 'Ещё $count включённых мода переопределяют те же игровые ресурсы:',
      one: 'Ещё один включённый мод переопределяет те же игровые ресурсы:',
    );
    return '$_temp0';
  }

  @override
  String sharedResources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count общих ресурса',
      many: '$count общих ресурсов',
      few: '$count общих ресурса',
      one: '$count общий ресурс',
    );
    return '$_temp0';
  }

  @override
  String get conflictSameNameBody =>
      'Одинаковые имена обычно означают, что один и тот же мод установлен дважды или что столкнулись пакеты двух разных авторов. Игра загружает их пересекающиеся ресурсы в непредсказуемом порядке: оставь один, остальные выключи или удали.';

  @override
  String get conflictVersionBody =>
      'Если установлено несколько версий одного мода, игра загружает их пересекающиеся ресурсы в непредсказуемом порядке: оставь самую свежую, остальные выключи или удали.';

  @override
  String get conflictResourcesBody =>
      'В этих пакетах есть ресурсы с одинаковыми идентификаторами, поэтому игра оставит только ту копию, что загрузилась последней. Иногда так и задумано — моды-патчи и override-моды намеренно перекрывают ресурсы другого мода, — но для не связанных между собой модов это значит, что один из них молча перестаёт работать: оставь тот, который нужен, а остальные выключи.';

  @override
  String advisoryBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'У $count твоих модов есть известные проблемы',
      many: 'У $count твоих модов есть известные проблемы',
      few: 'У $count твоих модов есть известные проблемы',
      one: 'У одного из твоих модов есть известная проблема',
    );
    return '$_temp0';
  }

  @override
  String get advisoryShow => 'Посмотреть';

  @override
  String get advisoryShowAll => 'Показать все моды';

  @override
  String get advisoryBadge => 'проблема';

  @override
  String get advisoryBrokenHeading => 'Этот мод считают сломанным';

  @override
  String get advisoryBrokenBody =>
      'Другие игроки сообщают, что из-за него игра перестаёт работать. Отключить его — самый быстрый способ проверить, в нём ли дело.';

  @override
  String get advisoryOutdatedHeading => 'У этого мода есть версия поновее';

  @override
  String get advisoryOutdatedBody =>
      'У тебя стоит как раз та версия, на которую жалуются. Скачай свежую у автора — этого должно хватить.';

  @override
  String get advisoryCautionHeading => 'За ним стоит присмотреть';

  @override
  String get advisoryCautionBody =>
      'У большинства он работает, но иногда чудит. Если ищешь причину проблемы, попробуй его отключить.';

  @override
  String advisorySince(String since) {
    return 'С $since';
  }

  @override
  String get advisoryOpenLink => 'Открыть страницу автора';

  @override
  String get advisorySource => 'Об этом сообщили другие игроки, а не игра.';

  @override
  String modInDirectory(String dir) {
    return 'в $dir';
  }

  @override
  String get factVersion => 'Версия';

  @override
  String get factFormat => 'Формат';

  @override
  String get factSize => 'Размер';

  @override
  String get factType => 'Тип';

  @override
  String get factModified => 'Изменён';

  @override
  String get statusHeading => 'Состояние';

  @override
  String get statusEnabledBody =>
      'Мод активен: игра загрузит его при следующем запуске.';

  @override
  String statusDisabledBody(String marker) {
    return 'Мод выключен: файл остаётся на диске с меткой «$marker», чтобы игра его пропускала. Включить можно в любой момент, ничего не удаляется.';
  }

  @override
  String get fileOnDisk => 'Файл на диске';

  @override
  String get insideThePackage => 'Внутри пакета';

  @override
  String resourcesTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'всего $count ресурса',
      many: 'всего $count ресурсов',
      few: 'всего $count ресурса',
      one: 'всего $count ресурс',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get sectionModManagement => 'УПРАВЛЕНИЕ МОДАМИ';

  @override
  String get sectionAppearance => 'ОФОРМЛЕНИЕ';

  @override
  String get sectionLanguage => 'ЯЗЫК';

  @override
  String get sectionPrivacy => 'КОНФИДЕНЦИАЛЬНОСТЬ';

  @override
  String sectionModsFolder(String game) {
    return 'ПАПКА МОДОВ · $game';
  }

  @override
  String sectionGameCaches(String game) {
    return 'КЭШ ИГРЫ · $game';
  }

  @override
  String get sectionFeedback => 'ОБРАТНАЯ СВЯЗЬ';

  @override
  String get sectionAbout => 'О ПРИЛОЖЕНИИ';

  @override
  String get prefWarnConflictsTitle => 'Предупреждать о конфликтах';

  @override
  String get prefWarnConflictsDesc =>
      'Помечает включённые моды, у которых повторяется имя файла или которые переопределяют те же игровые ресурсы, что и другой мод';

  @override
  String get prefConfirmDeleteTitle => 'Спрашивать перед удалением';

  @override
  String get prefConfirmDeleteDesc =>
      'Переспрашивать, прежде чем удалить файл мода с диска';

  @override
  String get prefShowDisabledTitle => 'Показывать выключенные моды';

  @override
  String get prefShowDisabledDesc =>
      'Оставляет выключенные моды видимыми в библиотеке, а не прячет их';

  @override
  String get prefScanArtworkTitle => 'Заглядывать внутрь модов';

  @override
  String get prefScanArtworkDesc =>
      'Пока грузится библиотека, смотрит внутрь файлов модов: достаёт картинки, разбирается, что внутри, и находит моды, которые переопределяют одни и те же ресурсы';

  @override
  String get prefSoundEffectsTitle => 'Звуки интерфейса';

  @override
  String get prefSoundEffectsDesc =>
      'Играет классические звуки интерфейса The Sims при кликах, переключателях и уведомлениях';

  @override
  String get prefAnalyticsTitle => 'Делиться анонимной статистикой';

  @override
  String get prefAnalyticsDesc =>
      'Отправляет анонимную статистику использования и отчёты о сбоях, чтобы приложение становилось лучше. Никогда не включает названия модов, пути к файлам и что-либо личное';

  @override
  String get themeTitle => 'Тема';

  @override
  String get themeDesc =>
      'Светлая или тёмная. «Системная» следует настройке компьютера.';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get languageTitle => 'Язык приложения';

  @override
  String get languageDesc =>
      'Выбери, на каком языке показывать приложение. «Системный» следует языку компьютера.';

  @override
  String get languageSystem => 'Системный';

  @override
  String get translatorsTitle => 'Перевели';

  @override
  String get translatorsDesc =>
      'Приложение говорит на десяти языках благодаря этим симмерам.';

  @override
  String get folderNotFound => 'Не найдена. Выбери папку';

  @override
  String get folderNotLocated =>
      'Игру (или её папку модов) не удалось найти автоматически';

  @override
  String folderSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count мода',
      many: '$count модов',
      few: '$count мода',
      one: '$count мод',
    );
    return '$_temp0 · $size на диске';
  }

  @override
  String get customFolder => 'своя папка';

  @override
  String get change => 'Изменить…';

  @override
  String get resetToAuto => 'Вернуть автовыбор';

  @override
  String createDefaultFolderAt(String path) {
    return 'Создать стандартную папку (со всеми нужными игре файлами) здесь:\n$path';
  }

  @override
  String get createFolder => 'Создать папку';

  @override
  String get alsoFoundOnThisComputer => 'Ещё найдено на этом компьютере:';

  @override
  String get clearCacheTitle => 'Очистить файлы кэша';

  @override
  String clearCacheDesc(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалит $count файла кэша ($size)',
      many: 'Удалит $count файлов кэша ($size)',
      few: 'Удалит $count файла кэша ($size)',
      one: 'Удалит $count файл кэша ($size)',
    );
    return '$_temp0, чтобы новый или удалённый контент появился; игра пересоберёт их при следующем запуске';
  }

  @override
  String get clearCaches => 'Очистить кэш';

  @override
  String get reportBugTitle => 'Сообщить об ошибке';

  @override
  String get reportBugDesc =>
      'Откроет форму на GitHub: версия приложения, система и текущая игра уже заполнены';

  @override
  String get reportBugButton => 'Сообщить…';

  @override
  String get suggestFeatureTitle => 'Предложить идею';

  @override
  String get suggestFeatureDesc =>
      'Чего-то не хватает? Расскажи, что сделало бы мод-менеджер лучше';

  @override
  String get suggestFeatureButton => 'Предложить…';

  @override
  String get wikiTitle => 'Руководство и FAQ';

  @override
  String get wikiDesc =>
      'Как ставить моды, чинить поиск папок и многое другое — в вики проекта';

  @override
  String get wikiButton => 'Открыть вики';

  @override
  String aboutTagline(String version) {
    return 'Версия $version · Поддержка The Sims 1-4 · SimCity скоро';
  }

  @override
  String updateIsAvailable(String version) {
    return 'Доступна версия $version';
  }

  @override
  String get noUpdateFound => 'Обновлений нет';

  @override
  String getVersion(String version) {
    return 'Скачать v$version';
  }

  @override
  String get checkingForUpdates => 'Проверяем…';

  @override
  String get checkForUpdates => 'Проверить обновления';

  @override
  String get categoryPackage => 'Пакет';

  @override
  String get categoryScript => 'Скрипт';

  @override
  String get categoryObject => 'Объект';

  @override
  String get categoryArchive => 'Архив';

  @override
  String get categorySkin => 'Скин';

  @override
  String get categoryTexture => 'Текстура';

  @override
  String get categoryWall => 'Стена';

  @override
  String get categoryFloor => 'Пол';

  @override
  String get contentCasParts => 'элементы CAS';

  @override
  String get contentObjects => 'объекты';

  @override
  String get contentTunings => 'тюнинги';

  @override
  String get contentBehaviors => 'поведения';

  @override
  String get contentTextTables => 'таблицы текста';

  @override
  String get contentTextures => 'текстуры';

  @override
  String get contentMeshes => 'меши';

  @override
  String errorNoModFiles(String extensions, String name) {
    return 'Внутри $name нет файлов модов ($extensions).';
  }

  @override
  String errorUnreadableArchive(String name) {
    return '$name — это не zip-архив, который приложение может прочитать.';
  }

  @override
  String errorNoUnpacker(String format, String name) {
    return 'На этом компьютере нечем распаковать архивы $format. Распакуй $name вручную и установи файлы из него.';
  }

  @override
  String errorNoUnpackerLinux(String format, String name) {
    return 'На этом компьютере нечем распаковать архивы $format. Установи p7zip и попробуй снова или распакуй $name вручную и установи файлы из него.';
  }

  @override
  String errorNoUnpackerLinuxRar(String format, String name) {
    return 'На этом компьютере нечем распаковать архивы $format. Установи p7zip или unrar и попробуй снова или распакуй $name вручную и установи файлы из него.';
  }

  @override
  String errorUnpackFailed(String name) {
    return 'Не удалось распаковать $name. Возможно, архив под паролем, это часть многотомного архива или повреждённая загрузка. Распакуй его вручную и установи файлы из него.';
  }

  @override
  String errorSims3PackUnreadable(String name) {
    return '$name — это не пакет The Sims 3, который приложение может прочитать.';
  }

  @override
  String errorSims3PackWorld(String name) {
    return '$name — это мир, а не пользовательский контент. Установи его через лаунчер The Sims 3 — игра хранит миры вне папки модов.';
  }

  @override
  String errorSims3PackLibrary(String name) {
    return '$name — это участок или семья, а не пользовательский контент. Установи его через лаунчер The Sims 3 — он попадёт в твою Библиотеку в игре.';
  }

  @override
  String errorInstallFailed(String name, String reason) {
    return 'Не удалось установить «$name» — $reason. Если так и продолжится, распакуй вручную и установи файлы из него.';
  }

  @override
  String errorInstallFailedRaw(String name, String reason) {
    return 'Не удалось установить «$name» — $reason';
  }

  @override
  String errorFileInUseDelete(String name) {
    return 'Не удалось удалить «$name» — файл занят другой программой (игра запущена?) или защищён от записи. Закрой всё, что его использует, и попробуй снова.';
  }

  @override
  String errorFileInUseRename(String name) {
    return 'Не удалось переименовать «$name» — файл занят другой программой (игра запущена?) или защищён от записи. Закрой всё, что его использует, и попробуй снова.';
  }

  @override
  String errorFileMissing(String name) {
    return '«$name» больше нет в папке модов — возможно, другая программа переместила или удалила файл.';
  }

  @override
  String get requirementMedievalModLoader =>
      'The Sims Medieval не запускает скриптовые и core-моды без загрузчика от сообщества в папке Game\\Bin. Обычный контент работает и так, всё остальное — нет.';

  @override
  String get requirementSims4ModsOff =>
      'В самой игре в настройках выключены пользовательский контент и моды, поэтому ничего из этого не грузится. Включи обратно в Настройки → Настройки игры → Другое и перезапусти игру.';

  @override
  String get requirementSims4ScriptModsOff =>
      'У тебя тут есть скриптовые моды, но в настройках игры выключено «Разрешить скриптовые моды». Обновления игры сбрасывают этот пункт.';

  @override
  String get requirementGetFile => 'Где взять';

  @override
  String tooDeepBanner(int count, int levels) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count модов',
    );
    return '$_temp0 лежат в подпапке, которую игра не читает. Она заглядывает только на $levels папки вглубь — подними их повыше, и они загрузятся.';
  }

  @override
  String get tooDeepShow => 'Показать их';

  @override
  String errorNoWriteAccess(String folder) {
    return 'У приложения нет прав на запись в «$folder». Система защищает эту папку — выдай своей учётной записи доступ на запись или выбери другую папку в настройках.';
  }

  @override
  String get folderReadOnlyBanner =>
      'Эта папка модов только для чтения, так что установка и удаление модов не сработают, пока у твоей учётной записи не будет прав на запись.';

  @override
  String errorShopDownload(String name) {
    return '«$name» не скачался с The Exchange. Проверь соединение и попробуй ещё раз.';
  }

  @override
  String get errorShopListingNotFound =>
      'Этого мода больше нет на The Exchange. Возможно, его убрали.';

  @override
  String get errorShopListingUnknownGame =>
      'Этот мод для игры, которую эта версия приложения ещё не знает. Попробуй обновиться.';

  @override
  String get eraClassic => 'Классика';

  @override
  String get eraNightlife => 'Ночная жизнь';

  @override
  String get eraAmbitions => 'Карьера';

  @override
  String get eraModern => 'Современность';

  @override
  String get eraMedieval => 'Средневековье';

  @override
  String get setupHelpSims1 =>
      'Самая первая The Sims хранит пользовательский контент внутри своей папки установки, а не в «Документах»: объекты кладутся в папку Downloads рядом с исполняемым файлом игры (например C:\\Program Files (x86)\\Maxis\\The Sims\\Downloads), а остальные типы приложение раскладывает само — скины (.skn/.cmx/.bmp) в GameData\\Skins, стены и полы в GameData\\Walls и GameData\\Floors. Legacy Collection 2025 года работает так же из своей папки установки (EA Games\\The Sims Legacy или Steam\\steamapps\\common\\The Sims Legacy Collection). Если игра установлена в другом месте (другой диск, своя библиотека Steam), выбери её папку Downloads вручную.';

  @override
  String get setupHelpSims2 =>
      'The Sims 2 загружает пользовательский контент из «Документы» > EA Games > The Sims 2 > Downloads (у Ultimate Collection это «The Sims 2 Ultimate Collection», у Legacy Collection 2025 года — «The Sims 2 Legacy»). Папки может не быть, пока ты её не создашь или не поставишь контент в первый раз. При запуске игры ответь «Да» на вопрос о пользовательском контенте, чтобы загрузки включились.';

  @override
  String get setupHelpSims3 =>
      'The Sims 3 не создаёт папку для модов сама: ей нужен «фреймворк» от сообщества — папка Mods > Packages внутри «Документы» > Electronic Arts > The Sims 3 плюс файл Resource.cfg, который говорит игре её читать. Приложение может создать и то, и другое. На дисковых и Wine-установках папка может лежать внутри самого пакета игры; тогда укажи её через «Выбрать папку».';

  @override
  String get setupHelpSims4 =>
      'The Sims 4 загружает моды из «Документы» > Electronic Arts > The Sims 4 > Mods. Игра создаёт эту папку при первом запуске, так что запусти её разок, если папки нет. Затем в игре включи Настройки > Настройки игры > Другое > «Включить пользовательский контент и моды» (и «Разрешить скриптовые моды» для файлов .ts4script) и перезапусти игру.';

  @override
  String get setupHelpSimsMedieval =>
      'The Sims Medieval загружает моды из папки установки, а не из «Документов»: папка Mods > Packages рядом с файлами игры (например C:\\Program Files (x86)\\Origin Games\\The Sims Medieval) плюс файл Resource.cfg в папке установки, который говорит игре её читать. Приложение создаст и то, и другое (внутри Program Files Windows может запросить права администратора). Папка «Документы» > Electronic Arts > The Sims Medieval хранит только сохранения; моды там ничего не делают. Для Wine/CrossOver или своей библиотеки Steam укажи через «Выбрать папку» папку Mods > Packages внутри установки.';
}
