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
  String get brandSubtitle => 'для The Sims и SimCity';

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
  String shopVariations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count варианта',
      many: '$count вариантов',
      few: '$count варианта',
      one: '$count вариант',
    );
    return '$_temp0';
  }

  @override
  String get shopSaveFile => 'Скачать';

  @override
  String get shopSaving => 'Скачиваем…';

  @override
  String get shopSaved => 'Сохранено';

  @override
  String get shopSaveHint =>
      'Установка кладёт файлы прямо в твою папку модов. Скачивание просто сохранит файл там, где захочешь.';

  @override
  String get shopRequires => 'Нужны эти наборы';

  @override
  String get shopRequirementMet => 'Установлен';

  @override
  String get shopRequirementDisabled => 'Выключен';

  @override
  String get shopRequirementMissing => 'Не установлен';

  @override
  String get shopRequirementUnknown => 'Не проверено';

  @override
  String get shopRequirementsNote =>
      'Установить всё равно можно — просто толку будет мало, пока нет наборов.';

  @override
  String get shopRequirementsOffNote =>
      'Один из них выключен. Включи его обратно на вкладке «Наборы».';

  @override
  String get shopRequirementsUnknownNote =>
      'Мы не смогли проверить наборы этой игры на этом компьютере, так что это слова автора.';

  @override
  String get shopDestination => 'Ставится в';

  @override
  String get shopVariationPick => 'Выбери вариант';

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
  String get viewGrid => 'Сетка';

  @override
  String get viewList => 'Список';

  @override
  String get viewFolders => 'Папки';

  @override
  String get sortTooltip => 'Сортировка';

  @override
  String get sortByName => 'По названию (А–Я)';

  @override
  String get sortByRecent => 'Недавно изменённые';

  @override
  String get sortBySize => 'Сначала большие';

  @override
  String get sortDisabledLast => 'Выключенные в конце';

  @override
  String get libraryRefresh => 'Обновить';

  @override
  String get libraryRootFolder => 'Папка Mods';

  @override
  String get selectionTooltip => 'Выбрать';

  @override
  String selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'выбрано $count',
      many: 'выбрано $count',
      few: 'выбрано $count',
      one: 'выбран $count',
    );
    return '$_temp0';
  }

  @override
  String get selectionSelectAll => 'Выбрать все';

  @override
  String get selectionClear => 'Снять выбор';

  @override
  String get selectionEnable => 'Включить';

  @override
  String get selectionDisable => 'Выключить';

  @override
  String selectionProgress(int done, int total) {
    return '$done из $total';
  }

  @override
  String selectionDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалить $count мода?',
      many: 'Удалить $count модов?',
      few: 'Удалить $count мода?',
      one: 'Удалить $count мод?',
    );
    return '$_temp0';
  }

  @override
  String selectionDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Все $count файла будут удалены с диска. Отменить это нельзя.',
      many: 'Все $count файлов будут удалены с диска. Отменить это нельзя.',
      few: 'Все $count файла будут удалены с диска. Отменить это нельзя.',
      one: 'Файл будет удалён с диска. Отменить это нельзя.',
    );
    return '$_temp0';
  }

  @override
  String get selectionMove => 'Переместить в…';

  @override
  String get newFolder => 'Новая папка';

  @override
  String newFolderIn(String folder) {
    return 'Внутри $folder';
  }

  @override
  String get newFolderHint => 'Название папки';

  @override
  String get create => 'Создать';

  @override
  String get move => 'Переместить';

  @override
  String moveTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Куда переместить $count мода?',
      many: 'Куда переместить $count модов?',
      few: 'Куда переместить $count мода?',
      one: 'Куда переместить $count мод?',
    );
    return '$_temp0';
  }

  @override
  String get moveBody =>
      'Файлы переедут в другую папку на диске. Больше ничего не меняется: что выключено, останется выключенным.';

  @override
  String get installFolderTitle => 'В какую папку?';

  @override
  String installFolderBody(String game) {
    return 'Куда попадут файлы внутри твоей папки модов для $game.';
  }

  @override
  String get installFolderChoose => 'Выбрать';

  @override
  String get installFolderEmpty =>
      'Подпапок пока нет. Создай одну или оставь всё в папке модов.';

  @override
  String get folderEmptySection => 'Тут пока пусто';

  @override
  String get install => 'Установить';

  @override
  String filePickerModsLabel(String game) {
    return 'Моды для $game';
  }

  @override
  String get installWhereTitle => 'Куда это положить?';

  @override
  String installWhereBody(String game) {
    return '$game читает моды из нескольких папок. Приложение может понять по самому файлу, а можешь указать ты.';
  }

  @override
  String get installWhereSorted => 'Разберись сам';

  @override
  String get installWhereSortedDesc =>
      'Сначала папки, которые уже есть в загрузке, остальное - по типу файла.';

  @override
  String get installWhereRemember => 'Больше не спрашивать';

  @override
  String get destinationSims1Downloads =>
      'Объекты, хаки и почти всё скачанное.';

  @override
  String get destinationSims1Global =>
      'Правки, которые меняют базовую игру целиком.';

  @override
  String get destinationSims1Objects =>
      'Правки к собственным файлам объектов игры.';

  @override
  String get destinationSims1Skins =>
      'Повседневные скины и головы. Появляются в редакторе персонажа.';

  @override
  String get destinationSims1SkinsBuy =>
      'Одежда, которую продают в магазинах на общественных участках.';

  @override
  String get destinationSims1Walls => 'Обои и покрытия для стен.';

  @override
  String get destinationSims1Floors => 'Напольные покрытия.';

  @override
  String get destinationSims1Roofs => 'Текстуры крыш.';

  @override
  String get prefAskWhereTitle => 'Спрашивать, куда устанавливать';

  @override
  String get prefAskWhereDesc =>
      'Эта игра читает моды больше чем из одной папки. Выбирай папку каждый раз, вместо того чтобы это решало приложение';

  @override
  String get statTotal => 'Всего';

  @override
  String get statEnabled => 'Включено';

  @override
  String get statDisabled => 'Выключено';

  @override
  String get statConflicts => 'Конфликты';

  @override
  String get statTotalTooltip =>
      'Все моды в этой папке, включённые и выключенные.';

  @override
  String get statTotalTooltipClear =>
      'Все моды в этой папке. Нажми, чтобы сбросить поиск и все фильтры.';

  @override
  String get statEnabledTooltip => 'Моды, которые игра загружает.';

  @override
  String get statEnabledTooltipActive =>
      'Показаны только включённые моды. Нажми, чтобы снова увидеть все.';

  @override
  String get statDisabledTooltip =>
      'Моды, которые лежат в папке, но выключены.';

  @override
  String get statDisabledTooltipActive =>
      'Показаны только выключенные моды. Нажми, чтобы снова увидеть все.';

  @override
  String get conflictTooltipActive =>
      'Показаны только конфликтующие моды. Нажми, чтобы снова увидеть все.';

  @override
  String get conflictTooltip =>
      'Включённые моды, у которых совпадает имя файла с другим включённым модом, которые установлены сразу в нескольких версиях или которые переопределяют одни и те же игровые ресурсы. Игра оставит только ту копию, что загрузилась последней, иногда это задумано (моды-патчи), но чаще нет.';

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
  String get duplicateBadge => 'копия';

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
  String conflictSameFileHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ещё у $count включённых модов точно такой же файл:',
      many: 'Ещё у $count включённых модов точно такой же файл:',
      few: 'Ещё у $count включённых модов точно такой же файл:',
      one: 'Ещё у одного включённого мода точно такой же файл:',
    );
    return '$_temp0';
  }

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
  String get conflictSameFileBody =>
      'Поиск дубликатов прочитал эти файлы, и они совпадают байт в байт. Это не два мода, которые конфликтуют, а одна и та же загрузка, лежащая в папке несколько раз. Оставь один, остальные удали: в игре ничего не изменится, а место вернётся.';

  @override
  String get conflictSameNameBody =>
      'Одинаковые имена обычно означают, что один и тот же мод установлен дважды или что столкнулись пакеты двух разных авторов. Игра загружает их пересекающиеся ресурсы в непредсказуемом порядке: оставь один, остальные выключи или удали.';

  @override
  String get conflictVersionBody =>
      'Если установлено несколько версий одного мода, игра загружает их пересекающиеся ресурсы в непредсказуемом порядке: оставь самую свежую, остальные выключи или удали.';

  @override
  String get conflictResourcesBody =>
      'В этих пакетах есть ресурсы с одинаковыми идентификаторами, поэтому игра оставит только ту копию, что загрузилась последней. Иногда так и задумано: моды-патчи и override-моды намеренно перекрывают ресурсы другого мода, но для не связанных между собой модов это значит, что один из них молча перестаёт работать: оставь тот, который нужен, а остальные выключи.';

  @override
  String get conflictIgnore => 'Игнорировать';

  @override
  String get conflictIgnoreTooltip =>
      'Если этот конфликт задуман, спрячь его. С модом ничего не случится: исчезнет только предупреждение, а вернуть его можно на этой странице или в настройках.';

  @override
  String get conflictRestore => 'Вернуть';

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
      'Другие игроки сообщают, что из-за него игра перестаёт работать. Отключить его - самый быстрый способ проверить, в нём ли дело.';

  @override
  String get advisoryOutdatedHeading => 'У этого мода есть версия поновее';

  @override
  String get advisoryOutdatedBody =>
      'У тебя стоит как раз та версия, на которую жалуются. Скачай свежую у автора. Этого должно хватить.';

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
  String get factDownloads => 'Скачиваний';

  @override
  String get factIgnoredConflicts => 'Скрыто';

  @override
  String ignoredConflictsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count конфликта',
      many: '$count конфликтов',
      few: '$count конфликта',
      one: '$count конфликт',
    );
    return '$_temp0';
  }

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
  String sectionIgnoredConflicts(String game) {
    return 'СКРЫТЫЕ КОНФЛИКТЫ · $game';
  }

  @override
  String sectionShopFolder(String game) {
    return 'THE EXCHANGE · $game';
  }

  @override
  String get prefShopFolderTitle => 'Куда попадают моды из The Exchange';

  @override
  String prefShopFolderDesc(String folder) {
    return 'Установки идут в $folder';
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
  String get prefConflictKindsTitle => 'О каких конфликтах предупреждать';

  @override
  String get prefConflictKindsDesc =>
      'Выключи те виды, которые не хочешь видеть помеченными. Остальные работают как раньше';

  @override
  String get conflictKindSameFile => 'Одинаковые копии';

  @override
  String get conflictKindSameName => 'Одинаковое имя файла';

  @override
  String get conflictKindVersions => 'Разные версии';

  @override
  String get conflictKindResources => 'Общие ресурсы';

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
  String get prefDisabledSuffixTitle => 'Метка выключенных модов';

  @override
  String get prefDisabledSuffixDesc =>
      'То, что дописывается к имени файла, когда ты выключаешь мод. Поменяй, чтобы совпадало с другим менеджером (CC Magic ставит .off); приложение всё равно читает оба варианта, а уже выключенные моды сохраняют свои имена';

  @override
  String get prefDisabledSuffixInvalid =>
      'Нужна точка и несколько букв или цифр, например .off';

  @override
  String get prefExperimentalPacksTitle =>
      'Экспериментальные переключатели наборов';

  @override
  String get prefExperimentalPacksDesc =>
      'Позволяет выключать наборы этой игры. На этом издании не проверялось, а район, в который играли с набором, без него может сломаться - сначала сделай копию сохранений';

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
  String get appThemeTitle => 'Тема приложения';

  @override
  String get appThemeDesc =>
      'Как выглядит всё приложение. Остаётся тем же, какую бы игру ты ни настраивал.';

  @override
  String get appThemeDefault => 'По умолчанию';

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
      'Приложение говорит на двенадцати языках благодаря этим симмерам.';

  @override
  String get sectionStartup => 'ЗАПУСК';

  @override
  String get prefDefaultGameTitle => 'Игра при запуске';

  @override
  String get prefDefaultGameDesc => 'С какой библиотеки открывается приложение';

  @override
  String get defaultGameAuto => 'Автоматически';

  @override
  String get prefSetupGuideTitle => 'Первая настройка';

  @override
  String get prefSetupGuideDesc => 'Пройти вопросы первого запуска ещё раз';

  @override
  String get onboardingReplay => 'Пройти снова';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingSkipIntro => 'Пропустить заставку';

  @override
  String get onboardingBack => 'Назад';

  @override
  String get onboardingNext => 'Дальше';

  @override
  String get onboardingFinish => 'Открыть библиотеку';

  @override
  String onboardingStepOf(int current, int total) {
    return 'Шаг $current из $total';
  }

  @override
  String get onboardingWelcomeTitle => 'Привет! Давай всё настроим';

  @override
  String get onboardingWelcomeBody =>
      'Пара быстрых вопросов, и моды готовы к работе. Займёт меньше минуты, а всё это потом можно поменять в настройках.';

  @override
  String get onboardingGamesTitle => 'Ищем твои игры';

  @override
  String get onboardingGamesBody =>
      'Смотрим в привычных местах: где стоит каждая игра и из какой папки она читает моды.';

  @override
  String get onboardingScanning => 'Ещё ищем…';

  @override
  String onboardingGamesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Найдено игр: $count',
      one: 'Найдена 1 игра',
      zero: 'Пока ничего',
    );
    return '$_temp0';
  }

  @override
  String onboardingGameMods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Уже установлено модов: $count',
      one: 'Уже установлен 1 мод',
      zero: 'Папка модов готова',
    );
    return '$_temp0';
  }

  @override
  String get onboardingGameMissing => 'Нет на этом компьютере';

  @override
  String get onboardingNoGamesTitle => 'Ничего не нашли';

  @override
  String get onboardingNoGamesBody =>
      'Не беда. Укажи папку с модами вручную в настройках, и всё будет работать точно так же.';

  @override
  String get onboardingFavoriteTitle => 'Во что играешь чаще всего?';

  @override
  String get onboardingFavoriteBody =>
      'Приложение будет открываться на этой игре. Переключаться между играми можно в любой момент через боковую панель.';

  @override
  String get onboardingLookTitle => 'Сделай по-своему';

  @override
  String get onboardingLookBody =>
      'Всё приложение носит тот вид, который ты выберешь, какой бы игрой ты ни занимался. Выбери, как оно должно выглядеть и звучать.';

  @override
  String get onboardingLibraryTitle => 'Как читается библиотека';

  @override
  String get onboardingLibraryBody =>
      'Две вещи, которые стоит решить сейчас: от них зависит, что библиотека тебе покажет.';

  @override
  String get onboardingDoneTitle => 'Готово!';

  @override
  String get onboardingDoneBody =>
      'Библиотека загружена и ждёт. Перетащи файл мода в окно, чтобы установить его, а всё это поменяешь в настройках.';

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
  String get ignoredConflictsTitle => 'Конфликты, о которых не напоминать';

  @override
  String ignoredConflictsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count конфликта, о которых приложение больше не напоминает. Верни их, и они снова появятся в библиотеке',
      many:
          '$count конфликтов, о которых приложение больше не напоминает. Верни их, и они снова появятся в библиотеке',
      few:
          '$count конфликта, о которых приложение больше не напоминает. Верни их, и они снова появятся в библиотеке',
      one:
          '$count конфликт, о котором приложение больше не напоминает. Верни его, и он снова появится в библиотеке',
    );
    return '$_temp0';
  }

  @override
  String get ignoredConflictsReset => 'Вернуть все';

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
      'Как ставить моды, чинить поиск папок и многое другое - в вики проекта';

  @override
  String get wikiButton => 'Открыть вики';

  @override
  String aboutTagline(String version, String series) {
    return 'Версия $version · Менеджер модов для $series';
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
  String get categoryWorld => 'Мир';

  @override
  String get categorySettings => 'Настройки';

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
  String get modKindCas => 'CAS';

  @override
  String get modKindBuildBuy => 'Строительство';

  @override
  String get modKindGameplay => 'Геймплей';

  @override
  String get modKindScript => 'Скрипт';

  @override
  String errorNoModFiles(String extensions, String name) {
    return 'Внутри $name нет файлов модов ($extensions).';
  }

  @override
  String errorUnreadableArchive(String name) {
    return '$name - это не архив, который приложение может прочитать.';
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
    return '$name - это не пакет The Sims 3, который приложение может прочитать.';
  }

  @override
  String errorSims3PackWorld(String name) {
    return '$name - это мир, а не пользовательский контент. Установи его через лаунчер The Sims 3: игра хранит миры вне папки модов.';
  }

  @override
  String errorSims3PackLibrary(String name) {
    return '$name - это участок или семья, а не пользовательский контент. Установи его через лаунчер The Sims 3: он попадёт в твою Библиотеку в игре.';
  }

  @override
  String errorInstallFailed(String name, String reason) {
    return 'Не удалось установить «$name»: $reason. Если так и продолжится, распакуй вручную и установи файлы из него.';
  }

  @override
  String errorInstallFailedRaw(String name, String reason) {
    return 'Не удалось установить «$name»: $reason';
  }

  @override
  String errorFileInUseDelete(String name) {
    return 'Не удалось удалить «$name»: файл занят другой программой (игра запущена?) или защищён от записи. Закрой всё, что его использует, и попробуй снова.';
  }

  @override
  String errorFileInUseRename(String name) {
    return 'Не удалось переименовать «$name»: файл занят другой программой (игра запущена?) или защищён от записи. Закрой всё, что его использует, и попробуй снова.';
  }

  @override
  String errorFileNameTaken(String name) {
    return 'В этой папке уже есть «$name». Переименуй один из файлов и попробуй снова.';
  }

  @override
  String errorFolderNameBad(String name) {
    return '«$name» не годится в качестве имени папки. Попробуй без слешей и символов, которые система оставляет себе.';
  }

  @override
  String errorFolderTooDeep(int levels) {
    return 'Игра заглядывает в папку модов только на $levels уровня вглубь - всё, что ниже, никогда не загрузится.';
  }

  @override
  String errorBulkMoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count мода не удалось переместить',
      many: '$count модов не удалось переместить',
      few: '$count мода не удалось переместить',
      one: '$count мод не удалось переместить',
    );
    return '$_temp0 - их может занимать другая программа (игра ещё запущена?), они защищены от записи, или в папке уже лежит файл с таким именем.';
  }

  @override
  String errorBulkToggleFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count мода не удалось переключить',
      many: '$count модов не удалось переключить',
      few: '$count мода не удалось переключить',
      one: '$count мод не удалось переключить',
    );
    return '$_temp0 - их может занимать другая программа (игра ещё запущена?) или они защищены от записи.';
  }

  @override
  String errorBulkRemoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count мода не удалось удалить',
      many: '$count модов не удалось удалить',
      few: '$count мода не удалось удалить',
      one: '$count мод не удалось удалить',
    );
    return '$_temp0 - их может занимать другая программа (игра ещё запущена?) или они защищены от записи.';
  }

  @override
  String errorFileMissing(String name) {
    return '«$name» больше нет в папке модов, возможно, другая программа переместила или удалила файл.';
  }

  @override
  String get requirementMedievalModLoader =>
      'The Sims Medieval не запускает скриптовые и core-моды без загрузчика от сообщества в папке Game\\Bin. Обычный контент работает и так, всё остальное - нет.';

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
    return '$_temp0 лежат в подпапке, которую игра не читает. Она заглядывает только на $levels папки вглубь. Подними их повыше, и они загрузятся.';
  }

  @override
  String get tooDeepShow => 'Показать их';

  @override
  String get duplicatesFind => 'Найти повторяющиеся моды';

  @override
  String duplicatesScanning(int done, int total) {
    return 'Читаю моды, которые могут повторяться… $done из $total';
  }

  @override
  String get duplicatesStop => 'Стоп';

  @override
  String duplicatesBanner(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count модов - это те же самые файлы, что и другие',
      many: '$count модов - это те же самые файлы, что и другие',
      few: '$count мода - это те же самые файлы, что и другие',
      one: 'Один мод - это тот же самый файл, что и другой',
    );
    return '$_temp0 - можно освободить $size.';
  }

  @override
  String get duplicatesShow => 'Показать их';

  @override
  String get duplicatesSelectExtras => 'Отметить лишние копии';

  @override
  String get duplicatesClean => 'Здесь ничего не повторяется.';

  @override
  String get duplicatesDismiss => 'Понятно';

  @override
  String tagTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Метки $count модов',
      many: 'Метки $count модов',
      few: 'Метки $count модов',
      one: 'Метки этого мода',
    );
    return '$_temp0';
  }

  @override
  String get tagBody =>
      'Твои собственные метки, чтобы потом всё находить. Нажми на метку, чтобы поставить её или снять.';

  @override
  String get tagHint => 'Новая метка';

  @override
  String get tagAdd => 'Добавить';

  @override
  String get tagDone => 'Готово';

  @override
  String get tagHeading => 'Метки';

  @override
  String get tagAddFirst => 'Добавить метку';

  @override
  String tagRemove(String tag) {
    return 'Снять «$tag»';
  }

  @override
  String get selectionTag => 'Пометить…';

  @override
  String folderAlsoReading(String folders) {
    return 'Твоя игра читает ещё и $folders, так что моды оттуда тоже есть в этой библиотеке.';
  }

  @override
  String errorFolderUnreadable(String folder) {
    return 'Не удалось открыть «$folder». Выбери папку на диске, до которого этот компьютер достаёт: телефон, камера или отключённый сетевой диск не смогут хранить твои моды.';
  }

  @override
  String errorNoWriteAccess(String folder) {
    return 'У приложения нет прав на запись в «$folder». Система защищает эту папку. Выдай своей учётной записи доступ на запись или выбери другую папку в настройках.';
  }

  @override
  String get folderReadOnlyBanner =>
      'Эта папка модов только для чтения, так что установка и удаление модов не сработают, пока у твоей учётной записи не будет прав на запись.';

  @override
  String get elevatedNoDropBanner =>
      'Ты запустил приложение от имени администратора, поэтому Windows не даёт перетаскивать файлы в окно. Используй кнопку «Установить». Она по-прежнему работает.';

  @override
  String errorShopDownload(String name) {
    return '«$name» не скачался с The Exchange. Проверь соединение и попробуй ещё раз.';
  }

  @override
  String errorShopNoModFiles(String name) {
    return 'Внутри «$name» нет ничего, что эта игра может установить. Может, это вообще не мод - нажми «Скачать» и сохрани файл там, где захочешь.';
  }

  @override
  String get errorShopListingNotFound =>
      'Этого мода больше нет на The Exchange. Возможно, его убрали.';

  @override
  String get errorShopListingUnknownGame =>
      'Этот мод для игры, которую эта версия приложения ещё не знает. Попробуй обновиться.';

  @override
  String errorPackToggleFailed(String pack) {
    return 'Не получилось переключить $pack. Закрой игру и попробуй ещё раз.';
  }

  @override
  String get errorPackNoUserData =>
      'Не нашли папку с настройками игры, так что негде отметить, какие наборы пропускать. Запусти игру разок сначала.';

  @override
  String get errorPackNeedsAdmin =>
      'Windows не дала приложению это изменить. Перезапусти его от имени администратора и попробуй ещё раз.';

  @override
  String get errorPackNotSupported =>
      'На этой системе наборы включать и выключать нельзя.';

  @override
  String get errorPackIsTheGame =>
      'Это тот набор, из которого запускается игра, так что он должен остаться включённым.';

  @override
  String get errorPackToggleRefused =>
      'Не получилось изменить этот набор. Закрой игру и попробуй ещё раз.';

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
  String get navPacks => 'Наборы';

  @override
  String get packsScanning => 'Ищем твои наборы…';

  @override
  String get packsEmptyTitle => 'Наборы не найдены';

  @override
  String packsEmptyBody(String game) {
    return 'Либо $game установлена не там, где приложение может её найти, либо рядом с ней пока нет наборов.';
  }

  @override
  String get packsRescan => 'Проверить заново';

  @override
  String packsSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Установлено $count набора',
      many: 'Установлено $count наборов',
      few: 'Установлено $count набора',
      one: 'Установлен $count набор',
    );
    return '$_temp0';
  }

  @override
  String packsSummaryWithOff(int count, int off) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count набора включено',
      many: '$count наборов включено',
      few: '$count набора включено',
      one: '$count набор включён',
    );
    return '$_temp0, $off выключено';
  }

  @override
  String get packsOff => 'Выключен';

  @override
  String get packsInstalled => 'Установлен';

  @override
  String get packsNeedAdmin =>
      'Чтобы включать и выключать эти наборы, нужны права администратора - именно там игра хранит свой список. Перезапусти приложение от имени администратора, чтобы их менять: пока так, перетаскивание не работает, так что потом лучше вернуться обратно.';

  @override
  String get packsExperimentalTitle => 'Выключать их - дело экспериментальное';

  @override
  String get packsExperimentalOff =>
      'Работает так же, как всегда работало в этой игре, но на этом издании никто не проверял, а район, в который ты играл с набором, может сломаться, если открыть его без него. Просто смотреть безопасно. Включи экспериментальные переключатели в Настройках, если всё равно хочешь попробовать.';

  @override
  String get packsExperimentalOn =>
      'Сначала сделай копию своих районов. Район, в который ты играл с набором, может сломаться, если открыть его без него, и отсюда это уже не отменить: обратно включённый набор не всегда возвращает сохранение.';

  @override
  String packsRestartNotice(String game) {
    return 'Перезапусти $game, чтобы это сработало. Наборы в любом случае остаются установленными.';
  }

  @override
  String packsAllOwnedSims4(String expansions, String gamePacks) {
    return 'Дополнений: $expansions. Игровых наборов: $gamePacks. Всё куплено, конечно.';
  }

  @override
  String get packKindExpansions => 'Дополнения';

  @override
  String get packKindGamePacks => 'Игровые наборы';

  @override
  String get packKindStuffPacks => 'Каталоги';

  @override
  String get packKindKits => 'Комплекты';

  @override
  String get packKindFreePacks => 'Бесплатные наборы';

  @override
  String get navSaves => 'Сохранения';

  @override
  String get savesScanning => 'Читаем твои сохранения…';

  @override
  String get savesEmptyTitle => 'Сохранений не найдено';

  @override
  String savesEmptyBody(String game) {
    return 'Поиграй в $game и сохранись. Твои миры появятся здесь: семьи, фото и всё остальное.';
  }

  @override
  String get savesRescan => 'Проверить заново';

  @override
  String savesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Найдено $count сохранения',
      many: 'Найдено $count сохранений',
      few: 'Найдено $count сохранения',
      one: 'Найдено $count сохранение',
    );
    return '$_temp0';
  }

  @override
  String savesLastSaved(String date) {
    return 'Последнее сохранение: $date';
  }

  @override
  String get savesShowInFolder => 'Показать в папке';

  @override
  String savesBackups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count резервной копии',
      many: '$count резервных копий',
      few: '$count резервные копии',
      one: '$count резервная копия',
    );
    return '$_temp0';
  }

  @override
  String get savesTabHouseholds => 'Семьи';

  @override
  String get savesTabAlbum => 'Фотоальбом';

  @override
  String get savesTabStats => 'Статистика мира';

  @override
  String savesNeighborhood(int number) {
    return 'Район $number';
  }

  @override
  String get savesOtherHouseholds => 'Горожане и другие семьи';

  @override
  String savesSimCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сима',
      many: '$count симов',
      few: '$count сима',
      one: '$count сим',
    );
    return '$_temp0';
  }

  @override
  String get savesFunds => 'Бюджет';

  @override
  String get savesRooms => 'Комнаты';

  @override
  String savesBedsBaths(int beds, int baths) {
    return 'Спален: $beds · Ванных: $baths';
  }

  @override
  String savesByCreator(String name) {
    return 'от $name';
  }

  @override
  String get savesMembers => 'Члены семьи';

  @override
  String get savesRelationships => 'Отношения';

  @override
  String get savesUnknownSim => 'Неизвестный сим';

  @override
  String get savesStatSims => 'Симы';

  @override
  String get savesStatHouseholds => 'Семьи';

  @override
  String get savesStatNetWorth => 'Состояние';

  @override
  String get savesStatWorlds => 'Миры';

  @override
  String get savesStatPhotos => 'Фото';

  @override
  String savesAcrossHouseholds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'в $count семьях',
      many: 'в $count семьях',
      few: 'в $count семьях',
      one: 'в $count семье',
    );
    return '$_temp0';
  }

  @override
  String savesPlayedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count игровой',
      many: '$count игровых',
      few: '$count игровые',
      one: '$count игровая',
    );
    return '$_temp0';
  }

  @override
  String get savesSizeOnDisk => 'Место на диске';

  @override
  String get savesLifeStages => 'Возрасты';

  @override
  String get savesTopSkills => 'Лучшие навыки в этом сохранении';

  @override
  String get savesSaveInfo => 'Файл сохранения';

  @override
  String get savesLastSavedLabel => 'Последнее сохранение';

  @override
  String get savesGameVersion => 'Версия игры';

  @override
  String get savesDescription => 'Описание';

  @override
  String get savesAgeInfant => 'Новорождённый';

  @override
  String get savesAgeBaby => 'Младенец';

  @override
  String get savesAgeToddler => 'Малыш';

  @override
  String get savesAgeChild => 'Ребёнок';

  @override
  String get savesAgeTeen => 'Подросток';

  @override
  String get savesAgeYoungAdult => 'Молодой взрослый';

  @override
  String get savesAgeAdult => 'Взрослый';

  @override
  String get savesAgeElder => 'Пожилой';

  @override
  String get savesGenderMale => 'Мужской';

  @override
  String get savesGenderFemale => 'Женский';

  @override
  String get savesSkillCooking => 'Кулинария';

  @override
  String get savesSkillMechanical => 'Механика';

  @override
  String get savesSkillCharisma => 'Харизма';

  @override
  String get savesSkillBody => 'Тело';

  @override
  String get savesSkillLogic => 'Логика';

  @override
  String get savesSkillCreativity => 'Творчество';

  @override
  String get savesSkillCleaning => 'Чистоплотность';

  @override
  String get savesPersonalityNeat => 'Аккуратный';

  @override
  String get savesPersonalityOutgoing => 'Общительный';

  @override
  String get savesPersonalityActive => 'Активный';

  @override
  String get savesPersonalityPlayful => 'Игривый';

  @override
  String get savesPersonalityNice => 'Добрый';

  @override
  String get savesZodiacAries => 'Овен';

  @override
  String get savesZodiacTaurus => 'Телец';

  @override
  String get savesZodiacGemini => 'Близнецы';

  @override
  String get savesZodiacCancer => 'Рак';

  @override
  String get savesZodiacLeo => 'Лев';

  @override
  String get savesZodiacVirgo => 'Дева';

  @override
  String get savesZodiacLibra => 'Весы';

  @override
  String get savesZodiacScorpio => 'Скорпион';

  @override
  String get savesZodiacSagittarius => 'Стрелец';

  @override
  String get savesZodiacCapricorn => 'Козерог';

  @override
  String get savesZodiacAquarius => 'Водолей';

  @override
  String get savesZodiacPisces => 'Рыбы';

  @override
  String get savesAspirationRomance => 'Романтика';

  @override
  String get savesAspirationFamily => 'Семья';

  @override
  String get savesAspirationFortune => 'Богатство';

  @override
  String get savesAspirationPopularity => 'Популярность';

  @override
  String get savesAspirationKnowledge => 'Знания';

  @override
  String get savesAspirationGrowUp => 'Взросление';

  @override
  String get savesAspirationPleasure => 'Удовольствие';

  @override
  String get savesAspirationGrilledCheese => 'Бутерброд с сыром';

  @override
  String get savesRelCrush => 'влюблённость';

  @override
  String get savesRelLove => 'любовь';

  @override
  String get savesRelEngaged => 'помолвлены';

  @override
  String get savesRelMarried => 'женаты';

  @override
  String get savesRelFriends => 'друзья';

  @override
  String get savesRelBestFriends => 'лучшие друзья';

  @override
  String get savesRelSteady => 'встречаются';

  @override
  String get savesRelEnemies => 'враги';

  @override
  String get savesPhotoFamilyPortrait => 'Семейный портрет';

  @override
  String get savesPhotoLot => 'Участок';

  @override
  String get savesPhotoSim => 'Портрет сима';

  @override
  String get savesPhotoSnapshot => 'Снимок';

  @override
  String get savesProperty => 'Имущество';

  @override
  String get savesGhost => 'призрак';

  @override
  String savesCareerLevel(String career, int level) {
    return '$career · уровень $level';
  }

  @override
  String get savesSpeciesLargeDog => 'собака';

  @override
  String get savesSpeciesSmallDog => 'маленькая собака';

  @override
  String get savesSpeciesCat => 'кошка';

  @override
  String get savesOccultVampire => 'вампир';

  @override
  String get savesOccultZombie => 'зомби';

  @override
  String get savesOccultWerewolf => 'оборотень';

  @override
  String get savesOccultPlantSim => 'растение';

  @override
  String get savesOccultAlien => 'пришелец';

  @override
  String get savesOccultServo => 'серво';

  @override
  String get savesOccultWitch => 'ведьма';

  @override
  String get savesOccultBigfoot => 'снежный человек';

  @override
  String get savesOccultFairy => 'фея';

  @override
  String get savesOccultGenie => 'джинн';

  @override
  String get savesOccultMermaid => 'русалка';

  @override
  String get savesLotResidential => 'Жилой участок';

  @override
  String get savesLotCommunity => 'Общественный участок';

  @override
  String get savesLotDorm => 'Общежитие';

  @override
  String get savesLotSecretSociety => 'Тайное общество';

  @override
  String get savesLotGreekHouse => 'Студенческий дом';

  @override
  String get savesLotHotel => 'Отель';

  @override
  String get savesLotSecret => 'Скрытый участок';

  @override
  String get savesLotBusiness => 'Бизнес';

  @override
  String get savesLotApartment => 'Квартира';

  @override
  String savesGpa(String gpa) {
    return 'средний балл $gpa';
  }

  @override
  String savesSemester(int number) {
    return 'семестр $number';
  }

  @override
  String savesPredestinedHobby(String hobby) {
    return 'Создан для увлечения «$hobby»';
  }

  @override
  String get savesHobbyCuisine => 'Кулинария';

  @override
  String get savesHobbyArts => 'Творчество';

  @override
  String get savesHobbyFilm => 'Кино и литература';

  @override
  String get savesHobbySports => 'Спорт';

  @override
  String get savesHobbyGames => 'Игры';

  @override
  String get savesHobbyNature => 'Природа';

  @override
  String get savesHobbyTinkering => 'Мастерство';

  @override
  String get savesHobbyFitness => 'Фитнес';

  @override
  String get savesHobbyScience => 'Наука';

  @override
  String get savesHobbyMusic => 'Музыка и танцы';

  @override
  String get savesTieMother => 'мать';

  @override
  String get savesTieFather => 'отец';

  @override
  String get savesTieSpouse => 'в браке с';

  @override
  String savesTieSibling(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'братья и сёстры',
      many: 'братья и сёстры',
      few: 'братья и сёстры',
      one: 'брат или сестра',
    );
    return '$_temp0';
  }

  @override
  String savesTieChild(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'детей',
      many: 'детей',
      few: 'детей',
      one: 'ребёнок',
    );
    return '$_temp0';
  }

  @override
  String get savesInterestPolitics => 'Политика';

  @override
  String get savesInterestMoney => 'Деньги';

  @override
  String get savesInterestEnvironment => 'Природа';

  @override
  String get savesInterestCrime => 'Преступность';

  @override
  String get savesInterestEntertainment => 'Развлечения';

  @override
  String get savesInterestCulture => 'Культура';

  @override
  String get savesInterestFood => 'Еда';

  @override
  String get savesInterestHealth => 'Здоровье';

  @override
  String get savesInterestFashion => 'Мода';

  @override
  String get savesInterestSports => 'Спорт';

  @override
  String get savesInterestParanormal => 'Паранормальное';

  @override
  String get savesInterestTravel => 'Путешествия';

  @override
  String get savesInterestWork => 'Работа';

  @override
  String get savesInterestWeather => 'Погода';

  @override
  String get savesInterestAnimals => 'Животные';

  @override
  String get savesInterestSchool => 'Школа';

  @override
  String get savesInterestToys => 'Игрушки';

  @override
  String get savesInterestSciFi => 'Фантастика';

  @override
  String get savesInterestMusic => 'Музыка';

  @override
  String get savesInterestOutdoors => 'Отдых на природе';

  @override
  String get setupHelpSims1 =>
      'Самая первая The Sims хранит пользовательский контент внутри своей папки установки, а не в «Документах»: объекты кладутся в папку Downloads рядом с исполняемым файлом игры (например C:\\Program Files (x86)\\Maxis\\The Sims\\Downloads), а остальные типы приложение раскладывает само: скины (.skn/.cmx/.bmp) в GameData\\Skins, стены и полы в GameData\\Walls и GameData\\Floors. Legacy Collection 2025 года работает так же из своей папки установки (EA Games\\The Sims Legacy или Steam\\steamapps\\common\\The Sims Legacy Collection). Если игра установлена в другом месте (другой диск, своя библиотека Steam), выбери её папку Downloads вручную.';

  @override
  String get setupHelpSims2 =>
      'The Sims 2 загружает пользовательский контент из «Документы» > EA Games > The Sims 2 > Downloads (у Ultimate Collection это «The Sims 2 Ultimate Collection», у Legacy Collection 2025 года - «The Sims 2 Legacy»). Папки может не быть, пока ты её не создашь или не поставишь контент в первый раз. При запуске игры ответь «Да» на вопрос о пользовательском контенте, чтобы загрузки включились.';

  @override
  String get setupHelpSims3 =>
      'The Sims 3 не создаёт папку для модов сама: ей нужен «фреймворк» от сообщества: папка Mods > Packages внутри «Документы» > Electronic Arts > The Sims 3 плюс файл Resource.cfg, который говорит игре её читать. Приложение может создать и то, и другое. На дисковых и Wine-установках папка может лежать внутри самого пакета игры; тогда укажи её через «Выбрать папку».';

  @override
  String get setupHelpSims4 =>
      'The Sims 4 загружает моды из «Документы» > Electronic Arts > The Sims 4 > Mods. Игра создаёт эту папку при первом запуске, так что запусти её разок, если папки нет. Затем в игре включи Настройки > Настройки игры > Другое > «Включить пользовательский контент и моды» (и «Разрешить скриптовые моды» для файлов .ts4script) и перезапусти игру.';

  @override
  String get setupHelpSimsMedieval =>
      'The Sims Medieval загружает моды из папки установки, а не из «Документов»: папка Mods > Packages рядом с файлами игры (например C:\\Program Files (x86)\\Origin Games\\The Sims Medieval) плюс файл Resource.cfg в папке установки, который говорит игре её читать. Приложение создаст и то, и другое (внутри Program Files Windows может запросить права администратора). Папка «Документы» > Electronic Arts > The Sims Medieval хранит только сохранения; моды там ничего не делают. Для Wine/CrossOver или своей библиотеки Steam укажи через «Выбрать папку» папку Mods > Packages внутри установки.';

  @override
  String get prefSubfoldersTitle => 'Папки включают вложенные папки';

  @override
  String get prefSubfoldersDesc =>
      'Папка показывает и всё, что лежит внутри неё. Если выключить, cc и cc/defaults будут отдельными полками.';

  @override
  String deleteFolderTitle(String folder) {
    return 'Удалить $folder?';
  }

  @override
  String get deleteFolderBody =>
      'Папка и всё, что в ней есть, исчезнет вместе с вложенными папками. Отменить это не получится.';

  @override
  String deleteFolderMods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Будет удалено модов: $count',
      one: 'Будет удалён 1 мод',
    );
    return '$_temp0';
  }

  @override
  String get deleteFolderEmpty => 'Модов внутри нет.';

  @override
  String get deleteFolder => 'Удалить папку';

  @override
  String triviaTitle(String game) {
    return 'Пламбоб знает · $game';
  }

  @override
  String get triviaContextLibrary => 'Похоже, ты разбираешь свои моды';

  @override
  String get triviaContextSaves => 'Похоже, ты в своих сохранениях';

  @override
  String get triviaContextPacks => 'Похоже, ты разбираешься со своими наборами';

  @override
  String triviaCounter(int index, int total) {
    return 'Факт $index из $total';
  }

  @override
  String get triviaOpen => 'Спросить пламбоб';

  @override
  String get triviaClose => 'Не сейчас';

  @override
  String get triviaPrevious => 'Предыдущий факт';

  @override
  String get triviaNext => 'Следующий факт';

  @override
  String get triviaAnother => 'Ещё один';

  @override
  String get triviaToSettings => 'Надоело? Выключи пламбоб в настройках';

  @override
  String get prefTriviaTitle => 'Факты от пламбоба';

  @override
  String get prefTriviaDesc =>
      'Пусть пламбоб иногда выскакивает с фактом об игре, в которой ты сейчас находишься';

  @override
  String get triviaCategoryOrigins => 'Истоки';

  @override
  String get triviaCategoryDesign => 'Дизайн';

  @override
  String get triviaCategoryLore => 'Лор';

  @override
  String get triviaCategoryDeath => 'Смерть';

  @override
  String get triviaCategoryMusic => 'Музыка';

  @override
  String get triviaCategoryCheats => 'Читы';

  @override
  String get triviaCategoryRecords => 'Рекорды';

  @override
  String get triviaCategoryModding => 'Моддинг';

  @override
  String get triviaCategoryLanguage => 'Язык';

  @override
  String get triviaCategoryCommunity => 'Сообщество';

  @override
  String get triviaSeriesLlama =>
      'Однажды в Maxis провели голосование всей студией за неофициальный талисман. Кандидатами были папоротник, бычий цепень и лама. Победила лама, и с тех пор она появляется в каждой игре серии.';

  @override
  String get triviaSeriesSimlish =>
      'Симлиш придумали прямо у микрофона. Стивену Кирину и Джерри Лоулор давали подсказки вроде «голодный» или «одинокий», и они часами импровизировали, как это должно звучать.';

  @override
  String get triviaSeriesCheats =>
      'rosebud и klapaucius дают по §1000 каждый. Rosebud — это «Гражданин Кейн», а Клапауций — робот-конструктор из «Кибериады» Станислава Лема, книги, которую Уилл Райт называет источником вдохновения ещё со времён SimCity.';

  @override
  String get triviaSeriesRecords =>
      'Guinness признаёт The Sims самой продаваемой серией игр для ПК в истории. Она перешагнула отметку в 125 миллионов копий больше десяти лет назад и переведена на 60 языков.';

  @override
  String get triviaSeriesGoths =>
      'Готы — одна из самых долгоживущих семей в играх вообще. Мортимер и Белла появляются в каждой основной части начиная с 2000 года.';

  @override
  String get triviaSeriesReaper =>
      'У Смерти есть биография, которую обычная игра тебе никогда не покажет. Помимо прочего, там указана его любимая группа: Styx.';

  @override
  String get triviaSeriesSimCity =>
      'The Sims выросла из SimCity. Уиллу Райту всё время хотелось приблизить камеру к тем человечкам, ради которых город и строится.';

  @override
  String get triviaSeriesLegacy =>
      'В январе 2025 года EA вернула в продажу The Sims и The Sims 2 в виде Legacy Collections, со всеми дополнениями. Это правки совместимости, а не ремастеры, так что обе играются ровно так же, как раньше.';

  @override
  String get triviaSeriesPlumbob =>
      'Зелёный кристалл писали тремя способами: PlumbBob в The Sims, Plum Bob в The Sims 2 и plumbob начиная с The Sims 4. В Maxis говорят, что во время разработки в ходу были все три.';

  @override
  String get triviaSeriesModScene =>
      'Сцена модов почти ровесница самой серии. Редакторы скинов и объектов ходили по рукам уже через считаные месяцы после выхода первой части в 2000 году, задолго до любых официальных инструментов.';

  @override
  String get triviaSeriesConflicts =>
      'Конфликт проще, чем звучит. Два мода претендуют на один ресурс, оба загружаются, и побеждает тот, который игра прочитает последним. Ничего не сломалось, просто одно перебило другое.';

  @override
  String get triviaSeriesPackage =>
      'Файл .package — это архив DBPF, то есть Database Packed File. Maxis использует один и тот же контейнер со времён SimCity 4, и потому одна программа открывает двадцать лет пользовательского контента.';

  @override
  String get triviaSeriesRename =>
      'Отключать мод переименованием — самый старый приём сцены. Игра грузит только то, что узнаёт, так что переименованный package остаётся ровно там, где лежал, и молчит.';

  @override
  String get triviaSeriesSaves =>
      'Сохранения в The Sims — это районы, а не слоты. Семьи, участки, воспоминания и сплетни живут в одной папке, которая растёт, пока ты продолжаешь играть.';

  @override
  String get triviaSeriesPacks =>
      'Отключение набора не двигает ни одного файла. Каждая игра серии держит свой список того, что нужно грузить, в другом месте: в строке настроек или в ключе реестра. Спрятать набор значит просто поправить этот список.';

  @override
  String get triviaSims1Dollhouse =>
      'The Sims начиналась как архитектурный симулятор под названием Project Dollhouse. Симов добавили только затем, чтобы игрок мог оценить, удобно ли в этом доме жить.';

  @override
  String get triviaSims1Oakland =>
      'Уилл Райт потерял дом в пожаре в Окленде в 1991 году. Восстановление быта с нуля — мебель, техника, привычки — и стало зерном, из которого выросла игра.';

  @override
  String get triviaSims1Toilet =>
      'Руководство не впечатлилось презентацией и отмахнулось от идеи как от «игры про туалет», потому что симам нужна ванная.';

  @override
  String get triviaSims1HomeTactics =>
      'До того как стать The Sims, проект презентовали как Home Tactics: The Experimental Domestic Simulator. Эта версия фокус-группам тоже не понравилась.';

  @override
  String get triviaSims1Myst =>
      'В 2002 году The Sims обошла Myst и стала самой продаваемой игрой для ПК за всю историю.';

  @override
  String get triviaSims1Simlish =>
      'Симлиш импровизировали актёры озвучки, играя с обрывками украинского, навахо, тагальского и эстонского, и намеренно оставили без смысла, чтобы язык никогда не устаревал.';

  @override
  String get triviaSims1Architecture =>
      'Инструменты строительства были настолько необычны для 2000 года, что некоторые вообще не ставили ни одного сима и пользовались игрой как бесплатной программой для архитектуры.';

  @override
  String get triviaSims1Audience =>
      'Что было редкостью для той эпохи, большинство игроков составляли женщины, и отчасти поэтому реклама этой игры не походила ни на что другое на полке.';

  @override
  String get triviaSims1Cowplant =>
      'Коровье растение дебютировало именно здесь, под названием Laganaphyllis Simnovorii, и с тех пор тихо поедает симов в каждом поколении серии.';

  @override
  String get triviaSims1Plumbob =>
      'Слово plumbob происходит от отвеса — того самого заострённого грузика на шнуре, которым строители ищут вертикаль. Это была игра про архитектуру раньше, чем про что-либо ещё.';

  @override
  String get triviaSims1Release =>
      'Игра вышла 4 февраля 2000 года и разошлась тиражом больше любого прогноза, который делала EA.';

  @override
  String get triviaSims1Edith =>
      'Каждый объект в игре запрограммирован на языке SimAntics через внутренний инструмент по имени Edith, названный в честь Эдит Банкер: самого первого персонажа, созданного для The Sims.';

  @override
  String get triviaSims1Expansions =>
      'Семь дополнений за три с половиной года, по одному весной и осенью, от Livin’ Large в августе 2000-го до Makin’ Magic в октябре 2003-го.';

  @override
  String get triviaSims1Unleashed =>
      'Unleashed принесло в серию питомцев в 2002 году и взяло награду за симулятор года на Interactive Achievement Awards.';

  @override
  String get triviaSims1Clown =>
      'Трагический клоун приходит развеселить грустного сима, у которого висит его картина. Получается у него из рук вон плохо, и в этом вся шутка.';

  @override
  String get triviaSims1Llama =>
      'В оригинальном печатном руководстве была книга под названием Making the Most of Your Llama. Объяснить это так никто и не потрудился.';

  @override
  String get triviaSims1Superstar =>
      'Superstar позволяло симу стать актёром, моделью или певцом, со шкалой славы и всем прочим, за одиннадцать лет до того, как The Sims 4 снова взялась за знаменитостей.';

  @override
  String get triviaSims1Catalogue =>
      'Отстраивая дом после пожара, Уилл Райт всё время спрашивал себя, какие части жилья необходимы, а какие могут подождать. Этот вопрос — по сути и есть каталог режима покупки.';

  @override
  String get triviaSims2Aging =>
      'The Sims 2 стала первой частью, где симы старели, умирали от старости и передавали генетику. Глаза, нос и подбородок достаются от обоих родителей.';

  @override
  String get triviaSims2Memories =>
      'У каждого сима есть скрытый список воспоминаний. Увиденная смерть, первый поцелуй или повышение записываются туда и позже влияют на настроение.';

  @override
  String get triviaSims2Bella =>
      'Белла Гот исчезает из Плезантвью в самом начале игры, и за двадцать лет это исчезновение так и не получило официального объяснения.';

  @override
  String get triviaSims2Strangetown =>
      'Белла обнаруживается живой в Стрейнджтауне и совершенно не помнит Плезантвью. В Maxis сказали, что обе Беллы настоящие, и на этом остановились.';

  @override
  String get triviaSims2FamilyTrees =>
      'Районы The Sims 2 держатся на настоящем генеалогическом древе: Плезантвью, Стрейнджтаун и Веронавиль связаны браками и слухами.';

  @override
  String get triviaSims2Plead =>
      'Смерть можно умолять. Заговори с ним в нужный момент, и он может вернуть тебе сима, иногда в обмен на кого-то другого.';

  @override
  String get triviaSims2ReaperRomance =>
      'Со Смертью можно закрутить роман. Разыграй всё правильно, и из этих отношений получится ребёнок-призрак.';

  @override
  String get triviaSims2Satellite =>
      'У сима, который засмотрелся на звёзды, есть крошечный шанс поймать головой падающий спутник. Это одна из самых редких смертей в серии.';

  @override
  String get triviaSims2Therapist =>
      'Провал жизненной цели отправляет сима к психотерапевту — один из немногих моментов, когда игра ломает собственную четвёртую стену просто ради смеха.';

  @override
  String get triviaSims2WantsFears =>
      'Желания и страхи двигают всю игру. Шкала стремлений реагирует на то, чего сим боялся, ровно так же сильно, как на то, чего он ждал.';

  @override
  String get triviaSims2FaceSculpt =>
      'Игра вышла с полноценной системой лепки лица и фигуры, и именно поэтому лица в The Sims 2 до сих пор выглядят разнообразнее, чем в поздних частях.';

  @override
  String get triviaSims2Aliens =>
      'Похищение пришельцами случается только с симами мужского пола, которые слишком долго глядят в телескоп, и да, возвращаются они беременными.';

  @override
  String get triviaSims2FreezerBunny =>
      'Freezer Bunny нарисовала художница Эмми Тоёнага для The Sims 2, и впервые он появился спрятанным внутри морозильника на общественном участке. С тех пор его протаскивают в каждую игру серии.';

  @override
  String get triviaSims2SocialBunny =>
      'Социальный кролик заменил Трагического клоуна и, в отличие от клоуна, действительно работает. Многим компетентная версия показалась даже более жуткой.';

  @override
  String get triviaSims2Giveaway =>
      'В июле 2014 года EA раздала Ultimate Collection бесплатно через Origin, по коду I-LOVE-THE-SIMS. Следующие десять лет, до самой Legacy Collection, этот подарок был единственной доступной копией.';

  @override
  String get triviaSims3SunsetValley =>
      'Сансет-Вэлли — это Плезантвью из The Sims 2 лет за 25 до событий, так что здесь можно встретить дедушек и бабушек симов, которыми ты уже играл.';

  @override
  String get triviaSims3Founders =>
      'Сансет-Вэлли основали Готы, а отстроили Ландграабы. Можно поиграть за Мортимера Гота в детстве и увидеть, как он знакомится с Беллой Бэчелор.';

  @override
  String get triviaSims3OpenWorld =>
      'The Sims 3 полностью избавилась от экранов загрузки. Весь городок симулируется разом, каждый сим стареет и ходит на работу в фоне.';

  @override
  String get triviaSims3Simulation =>
      'Все симы города просчитываются одновременно, и потому долгое сохранение начинает тормозить. Игра тихо ведёт жизни, с которыми ты никогда не пересекался.';

  @override
  String get triviaSims3CreateAStyle =>
      '«Создай стиль» позволял перекрашивать и перекраивать узор почти на любом объекте. Функция оказалась настолько тяжёлой, что больше не возвращалась.';

  @override
  String get triviaSims3Exchange =>
      'The Sims 3 вышла с настоящим онлайн-обменом, где игроки делились участками, симами и текстурами прямо из лаунчера.';

  @override
  String get triviaSims3Downloads =>
      'Только за первую неделю игроки скачали из этого лаунчера больше семи миллионов предметов, сделанных сообществом.';

  @override
  String get triviaSims3Traits =>
      'Черты характера заменили старые ползунки, и некоторые из них, вроде Клептомана и Безумца, тихо нарушают правила обычной жизни.';

  @override
  String get triviaSims3Kleptomaniac =>
      'Сим-клептоман приносит домой чужую мебель, никого не спросив, и продолжает это делать, пока ты не заметишь.';

  @override
  String get triviaSims3Simlish =>
      'Кэти Перри, Лили Аллен, Depeche Mode и десятки других артистов перезаписали собственные песни на симлише для саундтреков.';

  @override
  String get triviaSims3Townies =>
      'Поскольку открытый мир просчитывал и симов за кадром, регулярно обнаруживалось, что горожане переженились и завели детей вообще без твоего участия.';

  @override
  String get triviaSims3Store =>
      'Магазин The Sims 3 в итоге продал больше объектов, чем сама игра содержала на старте.';

  @override
  String get triviaSims3Launch =>
      'The Sims 3 разошлась тиражом 1,4 миллиона копий за первую неделю, в июне 2009 года, — крупнейший запуск на ПК за всю историю EA.';

  @override
  String get triviaSims4Flies =>
      'Смерть от мух — это по-настоящему. Запусти участок достаточно сильно, и рой доконает твоего сима.';

  @override
  String get triviaSims4Emotions =>
      'Здесь всем движут эмоции. Вдохновлённый сим лучше рисует, а разъярённый может умереть от злости.';

  @override
  String get triviaSims4EmotionDeaths =>
      'Сим может умереть от смеха, от злости и от стыда. В этой части эмоция — не украшение, а источник опасности.';

  @override
  String get triviaSims4CreateASim =>
      'В «Создании сима» ползунки заменили на прямое вытягивание и вдавливание лица, и потому лицо в The Sims 4 делается так быстро.';

  @override
  String get triviaSims4Launch =>
      'The Sims 4 вышла без бассейнов и без малышей. И то и другое вернули бесплатно, патчем, после долгого давления со стороны игроков.';

  @override
  String get triviaSims4Worlds =>
      'На старте в сентябре 2014 года мирами были только Уиллоу-Крик и Оазис-Спрингс. Сейчас их десятки, и почти каждый пришёл вместе с набором.';

  @override
  String get triviaSims4Gender =>
      'Пол полностью развязали патчем 2016 года: любой сим может носить любую одежду, иметь любой голос и беременеть или нет.';

  @override
  String get triviaSims4Newcrest =>
      'Ньюкрест намеренно выпустили совершенно пустым. Пятнадцать участков, ни одного здания и открытое приглашение сообществу всё это застроить.';

  @override
  String get triviaSims4Naming =>
      'Названия районов вроде Willow Creek и Oasis Springs следуют негласному правилу ещё старой Maxis: два простых английских слова, никаких выдуманных написаний.';

  @override
  String get triviaSims4Goths =>
      'Семья Гот есть и здесь, что делает её одной из самых долгоживущих в играх — она присутствует в каждой основной части.';

  @override
  String get triviaSims4FreeToPlay =>
      'Базовая игра стала бесплатной в октябре 2022 года, сразу на ПК, PlayStation и Xbox. Наборы остались платными.';

  @override
  String get triviaSims4Mccc =>
      'MC Command Center, первый мод, который ставит почти каждый игрок The Sims 4, перевалил за 14 миллионов загрузок на одном только CurseForge. Deaderpool обновляет его с 2015 года.';

  @override
  String get triviaSims4Twallan =>
      'MCCC существует благодаря The Sims 3. Он подхватывает то, на чём остановились Master Controller и Story Progression от Twallan, и переносит идею десятилетней давности на новый движок.';

  @override
  String get triviaSims4Deaths =>
      'Сима могут убить коровье растение, торговый автомат, стереосистема в форме ламы и смех. Не всё сразу.';

  @override
  String get triviaMedievalWatcher =>
      'Здесь ты не семья, ты Наблюдатель: доброжелательное божество, которое подталкивает героев по королевству, а не ведёт день одного дома.';

  @override
  String get triviaMedievalHeroes =>
      'В королевстве помещается до десяти симов-героев десяти профессий, и каждый растёт с 1-го уровня до 10-го, получая новые способности и всё более пышные титулы.';

  @override
  String get triviaMedievalStocks =>
      'Каждый герой просыпается с двумя обязанностями и сроком. Если слишком часто их забрасывать, последует наказание, и это касается даже монарха, который может угодить в колодки.';

  @override
  String get triviaMedievalAmbition =>
      'Перед началом ты выбираешь Амбицию для всего королевства, и принятые квесты оцениваются именно по ней. Ближе к условию победы The Sims не подбиралась никогда.';

  @override
  String get triviaMedievalQuests =>
      'Это полная конверсия, а не спин-офф. Песочницу здесь заменяет цепочка квестов, и потому это единственная игра The Sims, которую можно действительно пройти.';

  @override
  String get triviaMedievalPirates =>
      'Pirates and Nobles от августа 2011 года — единственное дополнение, которое она вообще получила: соколы и попугаи, карты сокровищ и лопаты, и война между двумя прибывшими фракциями.';

  @override
  String get triviaMedievalProxy =>
      'Игру никогда не задумывали под моды. Скриптовым и корневым модам нужен общественный прокси d3dx9_31.dll, положенный в Game/Bin, прежде чем игра вообще их прочитает, а вот пользовательский контент работает и без него.';

  @override
  String get triviaMedievalEngine =>
      'Она работает на движке The Sims 3, и потому Resource.cfg и файлы .package кажутся до боли знакомыми любому, кто модил ту игру.';

  @override
  String get navCreations => 'Творения';

  @override
  String creationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count творения',
      many: '$count творений',
      few: '$count творения',
      one: '$count творение',
      zero: 'Пока ничего не сохранено',
    );
    return '$_temp0';
  }

  @override
  String get creationsScanning => 'Читаю твои участки и семьи…';

  @override
  String get creationsRefresh => 'Обновить';

  @override
  String get creationsAll => 'Всё';

  @override
  String get creationsBack => '← Назад ко всему';

  @override
  String get creationsNoneOfKind => 'Ничего такого тут нет.';

  @override
  String get creationsEmptyTitle => 'Тут пока пусто';

  @override
  String get creationsEmptyBody =>
      'Участки, комнаты, семьи и симы, которых ты сохраняешь в игре, появляются здесь — и всё, что ты скачаешь и перетащишь в окно, тоже.';

  @override
  String creationsBy(String creator) {
    return 'автор: $creator';
  }

  @override
  String get creationsWhoLivesHere => 'КТО ИДЁТ В КОМПЛЕКТЕ';

  @override
  String get creationsShowInFolder => 'Показать в папке';

  @override
  String get creationsDelete => 'Удалить';

  @override
  String creationsDeleteTitle(String name) {
    return 'Удалить «$name»?';
  }

  @override
  String get creationsDeleteBody =>
      'Оно исчезнет из папки игры навсегда. Отменить не получится.';

  @override
  String creationsFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count файла',
      many: '$count файлов',
      few: '$count файла',
      one: '$count файл',
    );
    return '$_temp0';
  }

  @override
  String get creationKindLot => 'Участок';

  @override
  String get creationKindRoom => 'Комната';

  @override
  String get creationKindHousehold => 'Семья';

  @override
  String get creationKindSim => 'Сим';

  @override
  String get creationFolderSims4Tray => 'Tray';

  @override
  String get creationFolderSims3Library => 'Library';

  @override
  String get creationFolderSims2LotCatalog => 'Коллекция участков и домов';

  @override
  String get creationFolderSims2SavedSims => 'Упакованные симы';

  @override
  String creationFolderSims1Houses(String number) {
    return 'Район $number';
  }

  @override
  String creationBadFileName(String name) {
    return 'В имени «$name» есть символы, которые система не разрешает, — игра такой файл просто не найдёт. Переименуй его и попробуй ещё раз.';
  }

  @override
  String creationFileInUse(String name) {
    return '«$name» сейчас занят. Закрой игру и попробуй ещё раз.';
  }

  @override
  String get creationSims1PickLot =>
      'The Sims 1 нумерует участки по их месту на карте, поэтому дом должен занять уже существующий участок - и всё, что на нём стоит, пропадёт. Выбери участок сам: сделай резервную копию, а потом переименуй скачанный файл в номер House этого участка в папке Houses.';

  @override
  String creationInstallFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Эти $count файлов добавить не вышло.',
      one: 'Этот файл добавить не вышло.',
    );
    return '$_temp0';
  }

  @override
  String creationRemoveFailed(String name) {
    return '«$name» удалить не вышло.';
  }

  @override
  String get creationsAdd => 'Добавить';

  @override
  String get creationsAdding => 'Добавляю…';

  @override
  String creationsPickerLabel(String game) {
    return 'Участки, комнаты, семьи и симы для $game';
  }

  @override
  String get creationsNothingToAdd =>
      'Там не оказалось ни участка, ни комнаты, ни семьи, ни сима, которые эта игра умеет читать. Кастомный контент и моды добавляются через библиотеку.';

  @override
  String get householdEdit => 'Изменить';

  @override
  String get householdEditTitle => 'Изменить семью';

  @override
  String householdEditBody(String name) {
    return 'Меняем то, что сохранение говорит о «$name».';
  }

  @override
  String get householdEditName => 'Имя';

  @override
  String get householdEditFunds => 'Деньги';

  @override
  String householdEditFundsMax(String max) {
    return 'До $max, больше эта игра не удержит.';
  }

  @override
  String get householdEditSave => 'Сохранить';

  @override
  String get householdEditNotice =>
      'Сначала закрой игру: при выходе она перезаписывает своё сохранение. Копия файла откладывается до любых изменений.';

  @override
  String get errorSaveEditHouseholdGone =>
      'Этой семьи больше нет в сохранении. Обнови список и попробуй ещё раз.';

  @override
  String errorSaveEditUnreadable(String file) {
    return '«$file» устроен не так, как приложение умеет перезаписывать, поэтому ничего не изменилось.';
  }

  @override
  String errorSaveEditVerification(String file) {
    return 'Перезаписанный «$file» прочитался неправильно, поэтому его выбросили. Твоё сохранение не тронуто.';
  }

  @override
  String get errorSaveEditUnsupported =>
      'Сохранения этой игры можно читать, но не менять.';

  @override
  String whatsNewEyebrow(String version) {
    return 'Что нового в $version';
  }

  @override
  String get whatsNewAlsoSince => 'Ещё в этом обновлении';

  @override
  String get whatsNewDismiss => 'Поехали';

  @override
  String get whatsNew300RootTitle => 'Моды, которым место в папках самой игры';

  @override
  String get whatsNew300RootBody =>
      'Миры, графические правки и загрузчики скриптов никогда не работали из папки Mods. Теперь они ставятся прямо в те папки, которые читает игра, а то, что они заменяют, сохраняется, так что при удалении ты получаешь оригинал обратно.';

  @override
  String get whatsNew300PacksTitle =>
      'В объявлениях можно указать нужные дополнения';

  @override
  String get whatsNew300PacksBody =>
      'Авторы могут отметить, под какие дополнения сделан мод, и The Exchange сверит их с твоими до установки. Это всегда предупреждение, а не закрытая дверь.';

  @override
  String get whatsNew300ContainersTitle =>
      'Zip с кучей файлов .sims3pack просто работает';

  @override
  String get whatsNew300ContainersBody =>
      'Брось весь набор на окно. Контейнеры The Sims 3 внутри архива открываются там, где лежат, и всё ставится за один раз.';

  @override
  String get whatsNew300SimCityTitle => 'SimCity 3000, 4, Societies и 2013';

  @override
  String get whatsNew300SimCityBody =>
      'На боковой панели ещё четыре игры. SimCity 4 читает обе папки Plugins, сохраняет порядок загрузки, заданный именами папок и файлов, и не трогает то, что установил sc4pac. В настройках можно скрыть игры, в которые ты не играешь.';

  @override
  String get whatsNew300CatalogTitle => 'Тысячи модов для SimCity 4';

  @override
  String get whatsNew300CatalogBody =>
      'В The Exchange теперь есть каналы sc4pac рядом с нашими собственными объявлениями, с указанием проекта, который их ведёт. Загрузка приходит со всем, что ей нужно, или не приходит вовсе, а если хостинг не даёт приложению скачать файл, кнопка скажет об этом сразу.';

  @override
  String get whatsNew300ThemeTitle => 'Выбери вид, который тебе нравится';

  @override
  String get whatsNew300ThemeBody =>
      'Раньше приложение меняло цвета вместе с открытой игрой. Теперь ты выбираешь в настройках тот вид, который хочешь, и он остаётся, какой бы игрой ты ни занимался.';

  @override
  String get categoryLot => 'Участок';

  @override
  String get categoryModel => 'Модель';

  @override
  String get categoryDescription => 'Описание';

  @override
  String get categoryBuilding => 'Здание';

  @override
  String get setupHelpSimCity4 =>
      'SimCity 4 читает плагины сразу из двух папок: Документы > SimCity 4 > Plugins (твоей, той, которой управляет это приложение) и папки Plugins внутри установки игры. Имена папок и файлов - это порядок загрузки, так что не трогай структуру, с которой пришла сборка: именно поэтому sc4pac использует пронумерованные папки, а переопределения называются «zzz...». DLL-плагины загружаются только из корня папки Plugins, никогда из подпапки, поэтому приложение кладёт их туда за тебя. То, что установил sc4pac, остаётся за sc4pac: его показывает он, а не это приложение.';

  @override
  String get setupHelpSimCity2013 =>
      'SimCity загружает моды в .package из SimCityUserData > Packages внутри установки игры (обычно в Program Files, так что Windows может попросить права администратора). Это приложение управляет только этой папкой. Игра читает и свою папку SimCityData, но там лежит контент Maxis: мод, который должен загрузиться раньше пакетов игры, придётся положить туда вручную. Многие моды рассчитаны только на офлайн - проверяй их на городе, который не жалко.';

  @override
  String get setupHelpSimCity3000 =>
      'SimCity 3000 загружает свои здания (файлы .bld из Building Architect Tool) из папки Buildings внутри установки игры. Папка плоская - здание в подпапке не загрузится никогда. Здания, которые шли с игрой, здесь скрыты, чтобы ты их случайно не удалил. Патчи разрешения и совместимости, которые правят сам SC3U.exe, это приложение не ставит; действуй по их собственной инструкции.';

  @override
  String get setupHelpSimCitySocieties =>
      'SimCity Societies держит пользовательский контент в Документы > SimCity Societies > Import - туда же его кладёт и Package Installer самой игры. Приложение может создать эту папку за тебя. Контент приходит файлами .SCSPack - именно это расширение ищет сама игра. Учти: Societies делали под редактирование, а не под готовые моды - почти всё, чем занималась сцена, это правка C# и XML в папке Data самой игры, а её приложение не трогает никогда.';

  @override
  String get sectionManagedGames => 'Игры';

  @override
  String prefManageGameTitle(String game) {
    return 'Управлять $game';
  }

  @override
  String get prefManageGameDesc =>
      'Показывать в боковой панели. Скрытая игра сохраняет все свои настройки.';

  @override
  String get errorLastManagedGame =>
      'Это последняя игра в твоей боковой панели, так что она должна остаться. Сначала включи другую, если хочешь её скрыть.';

  @override
  String catalogCount(int count) {
    return '$count модов';
  }

  @override
  String catalogCuratedBy(String project) {
    return 'Каталог от $project';
  }

  @override
  String get catalogOpenPage => 'Открыть страницу';

  @override
  String catalogBlocked(String host) {
    return '$host не даёт приложениям скачивать за тебя. Забери мод на его странице.';
  }

  @override
  String get catalogUnresolvedNote => 'Этот не удалось прочитать из каталога.';

  @override
  String get catalogDependencies => 'В комплекте';

  @override
  String catalogFileCount(int count) {
    return '$count файлов';
  }

  @override
  String catalogDownloading(int current, int total) {
    return 'Скачиваю $current из $total';
  }

  @override
  String get catalogWarningTitle => 'Важно';

  @override
  String get catalogConflictsTitle => 'Конфликтует с';

  @override
  String catalogSourceFailed(String source) {
    return 'Не удалось связаться с $source';
  }

  @override
  String get catalogEmpty => 'Ничего не подходит.';

  @override
  String get catalogRefresh => 'Перезагрузить каталог';

  @override
  String get catalogOptions => 'Варианты';

  @override
  String catalogBy(String author) {
    return 'от $author';
  }

  @override
  String get errorCatalogUnreachable =>
      'Не удалось связаться с каталогом. Проверь соединение и попробуй ещё раз.';

  @override
  String get errorCatalogUnreadable =>
      'Каталог ответил чем-то, что эта версия не понимает.';

  @override
  String errorCatalogDownloadFailed(String host) {
    return '$host отклонил загрузку.';
  }

  @override
  String get errorCatalogInstallFailed => 'При установке что-то пошло не так.';

  @override
  String get errorCatalogInstallCancelled => 'Установка отменена.';

  @override
  String get catalogLoading => 'Загружаю каталог…';

  @override
  String get catalogBack => '← Назад к каталогу';

  @override
  String get catalogPromoTitle => 'Сам сделал мод?';

  @override
  String get catalogPromoBody =>
      'Выложи его в The Exchange: он ставится одним щелчком, получает свою страницу и ссылку, а те, у кого он уже есть, узнают об обновлениях.';
}
