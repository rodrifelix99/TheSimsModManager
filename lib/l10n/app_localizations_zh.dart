// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class LZh extends L {
  LZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Sims Mod Manager';

  @override
  String get brandTitle => 'MOD 管理器';

  @override
  String get brandSubtitle => '为模拟人生打造';

  @override
  String get navLibrary => '库';

  @override
  String get navShop => 'The Exchange';

  @override
  String get navSettings => '设置';

  @override
  String get shopAlphaBadge => '内测版';

  @override
  String get shopTagline => '来自社区的 MOD，一键安装。';

  @override
  String shopListingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '货架上有 $count 个 MOD',
    );
    return '$_temp0';
  }

  @override
  String get shopRefresh => '刷新';

  @override
  String get shopPublish => '发布你的 MOD';

  @override
  String get shopLoadFailedTitle => 'The Exchange 没有回应';

  @override
  String get shopLoadFailedBody => '货架加载失败。检查一下网络连接，再试一次吧。';

  @override
  String get shopRetry => '再试一次';

  @override
  String get shopEmptyTitle => '货架还空着';

  @override
  String get shopEmptyBody =>
      'The Exchange 刚刚开张，还没有人发布过任何 MOD，就是这么新。你也做 MOD？来当第一个上架的人吧！';

  @override
  String get shopAllGames => '全部游戏';

  @override
  String get shopShowAllGames => '显示全部游戏';

  @override
  String shopEmptyGameTitle(String game) {
    return '还没有$game的 MOD';
  }

  @override
  String shopEmptyGameBody(String game) {
    return '其他游戏的货架上已经有 MOD 了，但$game的还没有人发布过。你做了一个？来当第一个上架的人吧！';
  }

  @override
  String shopBy(String author) {
    return '作者：$author';
  }

  @override
  String get shopInstalled => '已安装';

  @override
  String get shopUpdate => '更新';

  @override
  String get shopUpdateBadge => '有更新';

  @override
  String shopUpdatesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '你有 $count 个 MOD 在 The Exchange 上出了新版本',
    );
    return '$_temp0';
  }

  @override
  String get shopUpdateHeading => '这个 MOD 有新版本了';

  @override
  String shopUpdateBody(String version, String author) {
    return '$author 在 The Exchange 上发布了 v$version。更新会替换你现在的文件。';
  }

  @override
  String get shopUpdateSeeListing => '查看详情';

  @override
  String get shopInstalling => '安装中…';

  @override
  String get shopInstallNotes => '安装说明';

  @override
  String get shopCreatorNudge => '你也做 MOD？在 The Exchange 发布完全免费，玩家一键就能安装你的作品。';

  @override
  String shopNeedsFolder(String game) {
    return '先设置好$game的模组文件夹，库标签页会一步步教你。';
  }

  @override
  String shopVariations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个款式',
    );
    return '$_temp0';
  }

  @override
  String get shopSaveFile => '下载';

  @override
  String get shopSaving => '下载中…';

  @override
  String get shopSaved => '已保存';

  @override
  String get shopSaveHint => '安装会把文件直接放进你的模组文件夹；下载只是把文件存到你想放的地方。';

  @override
  String get shopDestination => '安装到';

  @override
  String get shopVariationPick => '选一个款式';

  @override
  String get shopBack => '返回货架';

  @override
  String get shopCopyLink => '复制链接';

  @override
  String get shopLinkCopied => '链接已复制';

  @override
  String get sidebarGames => '游戏';

  @override
  String sidebarNotInstalled(String detail) {
    return '未安装 · $detail';
  }

  @override
  String sidebarModCount(int count, String detail) {
    return '$count 个 MOD · $detail';
  }

  @override
  String get updateAvailable => '有新版本';

  @override
  String updateClickToDownload(String version) {
    return 'v$version：点击下载';
  }

  @override
  String get storage => '存储空间';

  @override
  String storageInMods(String size) {
    return 'MOD 占用 $size';
  }

  @override
  String storageFreeOf(String free, String total) {
    return '剩余 $free，共 $total';
  }

  @override
  String dropToInstall(String game) {
    return '松开即可安装到《$game》';
  }

  @override
  String get dropFolders => '文件夹';

  @override
  String scanningMods(int done, int total) {
    return '正在翻看 MOD 里的图片和冲突… $done/$total';
  }

  @override
  String get skip => '跳过';

  @override
  String libraryTitle(String game) {
    return '《$game》MOD 库';
  }

  @override
  String modsShown(int count, String era) {
    return '显示 $count 个 MOD · $era';
  }

  @override
  String get learnMore => '了解更多';

  @override
  String get dismiss => '关闭';

  @override
  String get searchMods => '搜索 MOD…';

  @override
  String get viewGrid => '网格';

  @override
  String get viewList => '列表';

  @override
  String get viewFolders => '文件夹';

  @override
  String get sortTooltip => '排序';

  @override
  String get sortByName => '名称（A–Z）';

  @override
  String get sortByRecent => '最近修改';

  @override
  String get sortBySize => '从大到小';

  @override
  String get sortDisabledLast => '已停用的排在最后';

  @override
  String get libraryRefresh => '刷新';

  @override
  String get libraryRootFolder => 'Mods 文件夹';

  @override
  String get selectionTooltip => '选择';

  @override
  String selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已选 $count 个',
    );
    return '$_temp0';
  }

  @override
  String get selectionSelectAll => '全选';

  @override
  String get selectionClear => '取消选择';

  @override
  String get selectionEnable => '启用';

  @override
  String get selectionDisable => '停用';

  @override
  String selectionProgress(int done, int total) {
    return '$done/$total';
  }

  @override
  String selectionDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '卸载这 $count 个 MOD？',
    );
    return '$_temp0';
  }

  @override
  String selectionDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '这 $count 个文件将从磁盘上删除，无法撤销。',
    );
    return '$_temp0';
  }

  @override
  String get selectionMove => '移动到…';

  @override
  String get newFolder => '新建文件夹';

  @override
  String newFolderIn(String folder) {
    return '建在 $folder 里';
  }

  @override
  String get newFolderHint => '文件夹名称';

  @override
  String get create => '创建';

  @override
  String get move => '移动';

  @override
  String moveTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '把这 $count 个 MOD 移到哪里？',
    );
    return '$_temp0';
  }

  @override
  String get moveBody => '文件会在磁盘上移动位置，其他什么都不变 —— 已经停用的还是停用状态。';

  @override
  String get installFolderTitle => '装到哪个文件夹？';

  @override
  String installFolderBody(String game) {
    return '文件会放进你 $game 的 Mods 文件夹里的哪个位置。';
  }

  @override
  String get installFolderChoose => '就它了';

  @override
  String get installFolderEmpty => '还没有子文件夹。新建一个，或者全都放在 Mods 文件夹里。';

  @override
  String get folderEmptySection => '这里还什么都没有';

  @override
  String get install => '安装';

  @override
  String filePickerModsLabel(String game) {
    return '《$game》MOD';
  }

  @override
  String get installWhereTitle => '要装到哪里？';

  @override
  String installWhereBody(String game) {
    return '$game会从好几个文件夹里读取 MOD。可以让应用根据文件自己判断，也可以由你来指定。';
  }

  @override
  String get installWhereSorted => '让应用自己判断';

  @override
  String get installWhereSortedDesc => '优先按下载包里写好的文件夹放，剩下的按文件类型分。';

  @override
  String get installWhereRemember => '不用再问了';

  @override
  String get destinationSims1Downloads => '物件、Hack，以及大部分下载内容。';

  @override
  String get destinationSims1Global => '会影响整个基础游戏的覆盖文件。';

  @override
  String get destinationSims1Objects => '覆盖游戏自带物件文件的内容。';

  @override
  String get destinationSims1Skins => '日常皮肤和头部。会出现在创建模拟市民里。';

  @override
  String get destinationSims1SkinsBuy => '在社区地块商店里出售的服装。';

  @override
  String get destinationSims1Walls => '墙纸。';

  @override
  String get destinationSims1Floors => '地板。';

  @override
  String get destinationSims1Roofs => '屋顶贴图。';

  @override
  String get prefAskWhereTitle => '安装前先问我放哪';

  @override
  String get prefAskWhereDesc => '这个游戏会从多个文件夹读取 MOD。每次都自己选文件夹，而不是让应用决定';

  @override
  String get statTotal => '总计';

  @override
  String get statEnabled => '已启用';

  @override
  String get statDisabled => '已停用';

  @override
  String get statConflicts => '冲突';

  @override
  String get statTotalTooltip => '这个文件夹里的所有 MOD，启用的和停用的都算。';

  @override
  String get statTotalTooltipClear => '这个文件夹里的所有 MOD。点击可清掉搜索和所有筛选。';

  @override
  String get statEnabledTooltip => '游戏会加载的 MOD。';

  @override
  String get statEnabledTooltipActive => '当前只显示已启用的 MOD。点击可重新显示全部。';

  @override
  String get statDisabledTooltip => '放在文件夹里但关掉了的 MOD。';

  @override
  String get statDisabledTooltipActive => '当前只显示已停用的 MOD。点击可重新显示全部。';

  @override
  String get conflictTooltipActive => '当前只显示有冲突的 MOD。点击可重新显示全部。';

  @override
  String get conflictTooltip =>
      '这些已启用的 MOD 与另一个已启用的 MOD 文件名相同、装了不止一个版本，或者覆盖了同样的游戏资源。游戏只会保留最后加载的那一份，有时是故意的（补丁类 MOD），但更多时候不是。';

  @override
  String get conflictTooltipClickHint => '点击可只看这些 MOD。';

  @override
  String get filterAll => '全部';

  @override
  String get emptyFiltered => '没有 MOD 符合当前筛选';

  @override
  String get emptyNoMods => '还没有 MOD';

  @override
  String get emptyFilteredHint => '试试清空搜索，或者换一个筛选条件。';

  @override
  String emptyNoModsHint(String path) {
    return '正在监视这个文件夹：\n$path';
  }

  @override
  String get openFolder => '打开文件夹';

  @override
  String get conflictBadge => '冲突';

  @override
  String get duplicateBadge => '重复';

  @override
  String modInFolder(String folder) {
    return '位于 $folder';
  }

  @override
  String get modInModsFolder => '位于 Mods 文件夹';

  @override
  String setupFoundNoModsFolder(String game) {
    return '找到了《$game》，但还没有 MOD 文件夹';
  }

  @override
  String setupNotFound(String game) {
    return '找不到《$game》的 MOD 文件夹';
  }

  @override
  String get setupFoundNoModsFolderBody =>
      '游戏文件夹就在这台电脑上，只是里面还没有 MOD 文件夹。可以在下面创建一个，或者手动指定。';

  @override
  String get setupNotFoundBody => '可能游戏没有安装、装在了不太常见的位置，或者它的 MOD 文件夹还不存在。';

  @override
  String get foundOnThisComputer => '在这台电脑上找到';

  @override
  String get chooseFolder => '选择文件夹…';

  @override
  String get createItForMe => '帮我创建';

  @override
  String willBeCreatedAt(String path) {
    return '将创建在：\n$path';
  }

  @override
  String get checkAgain => '重新检测';

  @override
  String get useThis => '用这个';

  @override
  String get enabled => '已启用';

  @override
  String get disabled => '已停用';

  @override
  String get showInFileManager => '在文件管理器中显示';

  @override
  String get uninstallMod => '卸载 MOD';

  @override
  String uninstallConfirmTitle(String title) {
    return '要卸载 $title 吗？';
  }

  @override
  String uninstallConfirmBody(String path) {
    return '这个文件将从磁盘上删除：\n$path';
  }

  @override
  String get cancel => '取消';

  @override
  String get uninstall => '卸载';

  @override
  String conflictSameFileHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '另外 $count 个已启用的 MOD 和它是完全相同的文件：',
    );
    return '$_temp0';
  }

  @override
  String conflictSameNameHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '另外 $count 个已启用的 MOD 文件名相同：',
    );
    return '$_temp0';
  }

  @override
  String conflictVersionHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '另外 $count 个已启用的 MOD 看起来是这个 MOD 的其他版本：',
    );
    return '$_temp0';
  }

  @override
  String conflictResourcesHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '另外 $count 个已启用的 MOD 覆盖了同样的游戏资源：',
    );
    return '$_temp0';
  }

  @override
  String sharedResources(int count) {
    return '$count 个共同资源';
  }

  @override
  String get conflictSameFileBody =>
      '重复扫描读过这些文件，它们逐字节完全一致。这不是两个 MOD 在打架，而是同一个下载在文件夹里存了好几份。留一个、把其余删掉，游戏里不会有任何变化，空间却能拿回来。';

  @override
  String get conflictSameNameBody =>
      '文件名完全一样，通常意味着同一个 MOD 装了两遍，或者两位作者的包撞车了。游戏加载重叠资源的顺序无法预料：留一个，其余的停用或删掉。';

  @override
  String get conflictVersionBody =>
      '同一个 MOD 装了好几个版本，游戏加载重叠资源的顺序就无法预料：留最新的那个，其余的停用或删掉。';

  @override
  String get conflictResourcesBody =>
      '这些包里有标识符相同的资源，所以游戏只会保留最后加载的那一份。这有时是故意的（补丁类和覆盖类 MOD 本来就是要盖住别的 MOD 的资源），但如果两个 MOD 毫不相干，那就意味着其中一个悄悄失效了：留下你想要的那个，把其余的停用。';

  @override
  String get conflictIgnore => '忽略';

  @override
  String get conflictIgnoreTooltip =>
      '如果这个冲突是你故意留的，就把它藏起来。模组本身完全不动，消失的只是提示，随时能在这个页面或者设置里恢复。';

  @override
  String get conflictRestore => '恢复';

  @override
  String advisoryBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '你有 $count 个 MOD 存在已知问题',
    );
    return '$_temp0';
  }

  @override
  String get advisoryShow => '去看看';

  @override
  String get advisoryShowAll => '显示全部 MOD';

  @override
  String get advisoryBadge => '问题';

  @override
  String get advisoryBrokenHeading => '这个 MOD 被反馈已损坏';

  @override
  String get advisoryBrokenBody =>
      '其他玩家反馈这个 MOD 会让游戏无法正常运行。想确认是不是它捣的鬼，最快的办法就是先停用它。';

  @override
  String get advisoryOutdatedHeading => '这个 MOD 有更新的版本了';

  @override
  String get advisoryOutdatedBody => '你装的正好是出问题的那个版本。去作者那里下最新版应该就好了。';

  @override
  String get advisoryCautionHeading => '建议多留意一下';

  @override
  String get advisoryCautionBody => '大多数人用着没事，但它偶尔会闹脾气。如果你正在排查问题，可以先停用试试。';

  @override
  String advisorySince(String since) {
    return '自 $since 起';
  }

  @override
  String get advisoryOpenLink => '打开作者页面';

  @override
  String get advisorySource => '来自其他玩家的反馈，不是游戏的检测结果。';

  @override
  String modInDirectory(String dir) {
    return '位于 $dir';
  }

  @override
  String get factVersion => '版本';

  @override
  String get factFormat => '格式';

  @override
  String get factSize => '大小';

  @override
  String get factType => '类型';

  @override
  String get factModified => '修改时间';

  @override
  String get factDownloads => '下载量';

  @override
  String get factIgnoredConflicts => '已忽略';

  @override
  String ignoredConflictsCount(int count) {
    return '$count 个冲突';
  }

  @override
  String get statusHeading => '状态';

  @override
  String get statusEnabledBody => '这个 MOD 已启用：游戏下次启动时会加载它。';

  @override
  String statusDisabledBody(String marker) {
    return '这个 MOD 已停用：文件还在磁盘上，只是带了「$marker」标记，游戏会跳过它。随时可以重新启用，什么都不会被删除。';
  }

  @override
  String get fileOnDisk => '磁盘上的文件';

  @override
  String get insideThePackage => '包里有什么';

  @override
  String resourcesTotal(int count) {
    return '共 $count 个资源';
  }

  @override
  String get settingsTitle => '设置';

  @override
  String get sectionModManagement => 'MOD 管理';

  @override
  String get sectionAppearance => '外观';

  @override
  String get sectionLanguage => '语言';

  @override
  String get sectionPrivacy => '隐私';

  @override
  String sectionModsFolder(String game) {
    return 'MOD 文件夹 · $game';
  }

  @override
  String sectionGameCaches(String game) {
    return '游戏缓存 · $game';
  }

  @override
  String sectionIgnoredConflicts(String game) {
    return '已忽略的冲突 · $game';
  }

  @override
  String sectionShopFolder(String game) {
    return 'THE EXCHANGE · $game';
  }

  @override
  String get prefShopFolderTitle => 'The Exchange 的 Mod 装到哪';

  @override
  String prefShopFolderDesc(String folder) {
    return '安装会放进 $folder';
  }

  @override
  String get sectionFeedback => '反馈';

  @override
  String get sectionAbout => '关于';

  @override
  String get prefWarnConflictsTitle => '提醒我注意冲突';

  @override
  String get prefWarnConflictsDesc => '为文件名重复、或与其他 MOD 覆盖同样游戏资源的已启用 MOD 打上标记';

  @override
  String get prefConfirmDeleteTitle => '卸载前先确认';

  @override
  String get prefConfirmDeleteDesc => '从磁盘删除 MOD 文件之前先问一下';

  @override
  String get prefShowDisabledTitle => '显示已停用的 MOD';

  @override
  String get prefShowDisabledDesc => '让已停用的 MOD 继续留在库里，而不是把它们藏起来';

  @override
  String get prefDisabledSuffixTitle => '停用标记';

  @override
  String get prefDisabledSuffixDesc =>
      '停用某个 MOD 时，会加在文件名末尾的后缀。可以改成别的管理器用的写法（CC Magic 用 .off）；两种写法应用都认得，已经停用的 MOD 也会保留现在的文件名';

  @override
  String get prefDisabledSuffixInvalid => '要以点开头，后面跟几个字母或数字，比如 .off';

  @override
  String get prefExperimentalPacksTitle => '实验性内容包开关';

  @override
  String get prefExperimentalPacksDesc =>
      '允许关闭这款游戏的内容包。在这个版本上未经验证，用某个包玩过的街区缺少它可能会坏掉 - 请先备份存档';

  @override
  String get prefScanArtworkTitle => '扫描 MOD 内部';

  @override
  String get prefScanArtworkDesc =>
      '在库加载时翻看 MOD 文件，找出内嵌的预览图、内容详情，以及覆盖同样资源的 MOD';

  @override
  String get prefSoundEffectsTitle => '界面音效';

  @override
  String get prefSoundEffectsDesc => '在点击、切换和提示时播放模拟人生的经典界面音效';

  @override
  String get prefAnalyticsTitle => '共享匿名使用数据';

  @override
  String get prefAnalyticsDesc =>
      '发送匿名的使用统计和崩溃报告，帮助改进这个应用。绝不包含 MOD 名称、文件路径或任何个人信息';

  @override
  String get themeTitle => '主题';

  @override
  String get themeDesc => '浅色或深色。「跟随系统」会跟着你电脑的设置走。';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get languageTitle => '应用语言';

  @override
  String get languageDesc => '选择应用界面使用的语言。「跟随系统」会使用你电脑的语言。';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get translatorsTitle => '翻译者';

  @override
  String get translatorsDesc => '这个应用能有十二种语言，全靠这些模拟人生玩家。';

  @override
  String get sectionStartup => '启动';

  @override
  String get prefDefaultGameTitle => '启动时打开的游戏';

  @override
  String get prefDefaultGameDesc => '打开应用时先显示哪个游戏的模组库';

  @override
  String get defaultGameAuto => '自动';

  @override
  String get prefSetupGuideTitle => '设置向导';

  @override
  String get prefSetupGuideDesc => '再走一遍首次启动时的问题';

  @override
  String get onboardingReplay => '再看一次';

  @override
  String get onboardingSkip => '跳过';

  @override
  String get onboardingSkipIntro => '跳过片头';

  @override
  String get onboardingBack => '上一步';

  @override
  String get onboardingNext => '下一步';

  @override
  String get onboardingFinish => '打开我的模组库';

  @override
  String onboardingStepOf(int current, int total) {
    return '第 $current 步，共 $total 步';
  }

  @override
  String get onboardingWelcomeTitle => '嗨！先花一分钟设置一下';

  @override
  String get onboardingWelcomeBody =>
      '回答几个小问题，你的模组就能用了。用不了一分钟，而且这里的每一项之后都能在设置里改。';

  @override
  String get onboardingGamesTitle => '正在找你的游戏';

  @override
  String get onboardingGamesBody => '我们会在常见的位置查找每个游戏，以及它读取模组的文件夹。';

  @override
  String get onboardingScanning => '还在找…';

  @override
  String onboardingGamesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '找到 $count 个游戏',
      zero: '暂时什么都没找到',
    );
    return '$_temp0';
  }

  @override
  String onboardingGameMods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已装有 $count 个模组',
      zero: '模组文件夹已就绪',
    );
    return '$_temp0';
  }

  @override
  String get onboardingGameMissing => '这台电脑上没有';

  @override
  String get onboardingNoGamesTitle => '一个都没找到';

  @override
  String get onboardingNoGamesBody => '没关系。你可以在设置里自己指定模组文件夹，其他一切照常。';

  @override
  String get onboardingFavoriteTitle => '你玩得最多的是哪一部？';

  @override
  String get onboardingFavoriteBody => '应用每次都会从这个游戏打开。你随时可以在侧边栏切换到别的游戏。';

  @override
  String get onboardingLookTitle => '调成你喜欢的样子';

  @override
  String get onboardingLookBody => '整个界面都会跟着当前游戏换配色。挑一挑它该是什么样子、什么声音。';

  @override
  String get onboardingLibraryTitle => '模组库怎么显示';

  @override
  String get onboardingLibraryBody => '有两件事值得现在决定，它们会改变模组库给你看到的内容。';

  @override
  String get onboardingDoneTitle => '全都好了！';

  @override
  String get onboardingDoneBody =>
      '模组库已经加载好了。想装模组时，把文件拖到窗口里就行；这里选的每一项随时能在设置里改。';

  @override
  String get folderNotFound => '没找到。请选择一个文件夹';

  @override
  String get folderNotLocated => '没能自动找到游戏（或它的 MOD 文件夹）';

  @override
  String folderSummary(int count, String size) {
    return '$count 个 MOD · 占用 $size';
  }

  @override
  String get customFolder => '自定义文件夹';

  @override
  String get change => '更改…';

  @override
  String get resetToAuto => '恢复自动';

  @override
  String createDefaultFolderAt(String path) {
    return '在这里创建默认文件夹（含游戏需要的文件）：\n$path';
  }

  @override
  String get createFolder => '创建文件夹';

  @override
  String get alsoFoundOnThisComputer => '这台电脑上还找到：';

  @override
  String get clearCacheTitle => '清理缓存文件';

  @override
  String clearCacheDesc(int count, String size) {
    return '删除 $count 个缓存文件（$size），让新增或删掉的内容能显示出来；游戏下次启动时会重新生成它们';
  }

  @override
  String get clearCaches => '清理缓存';

  @override
  String get ignoredConflictsTitle => '你忽略掉的冲突';

  @override
  String ignoredConflictsDesc(int count) {
    return '你让应用别再提示的 $count 个冲突。恢复之后它们会重新出现在库里';
  }

  @override
  String get ignoredConflictsReset => '全部恢复';

  @override
  String get reportBugTitle => '反馈问题';

  @override
  String get reportBugDesc => '在 GitHub 上开一个问题反馈，应用版本、系统和当前游戏都已经填好了';

  @override
  String get reportBugButton => '反馈…';

  @override
  String get suggestFeatureTitle => '提个建议';

  @override
  String get suggestFeatureDesc => '缺了点什么？告诉我们怎样能让这个 MOD 管理器更好用';

  @override
  String get suggestFeatureButton => '建议…';

  @override
  String get wikiTitle => '使用指南与常见问题';

  @override
  String get wikiDesc => '怎么安装 MOD、怎么修好文件夹检测，还有更多内容，都在项目 wiki 上';

  @override
  String get wikiButton => '打开 wiki';

  @override
  String aboutTagline(String version) {
    return '版本 $version · 支持模拟人生 1-4 · 模拟城市即将支持';
  }

  @override
  String updateIsAvailable(String version) {
    return '$version 版本已经可以下载了';
  }

  @override
  String get noUpdateFound => '没有可用更新';

  @override
  String getVersion(String version) {
    return '获取 v$version';
  }

  @override
  String get checkingForUpdates => '检查中…';

  @override
  String get checkForUpdates => '检查更新';

  @override
  String get categoryPackage => '资源包';

  @override
  String get categoryScript => '脚本';

  @override
  String get categoryObject => '物件';

  @override
  String get categoryArchive => '存档包';

  @override
  String get categorySkin => '皮肤';

  @override
  String get categoryTexture => '贴图';

  @override
  String get categoryWall => '墙面';

  @override
  String get categoryFloor => '地板';

  @override
  String get contentCasParts => 'CAS 部件';

  @override
  String get contentObjects => '物件';

  @override
  String get contentTunings => '调参文件';

  @override
  String get contentBehaviors => '行为脚本';

  @override
  String get contentTextTables => '文本表';

  @override
  String get contentTextures => '贴图';

  @override
  String get contentMeshes => '模型';

  @override
  String get modKindCas => 'CAS';

  @override
  String get modKindBuildBuy => '建造购买';

  @override
  String get modKindGameplay => '玩法';

  @override
  String get modKindScript => '脚本';

  @override
  String errorNoModFiles(String extensions, String name) {
    return '$name 里没有找到模组文件（$extensions）。';
  }

  @override
  String errorUnreadableArchive(String name) {
    return '$name 不是这个应用能读取的压缩包。';
  }

  @override
  String errorNoUnpacker(String format, String name) {
    return '这台电脑上没有能解压 $format 压缩包的工具。自己把 $name 解压出来，再安装里面的文件吧。';
  }

  @override
  String errorNoUnpackerLinux(String format, String name) {
    return '这台电脑上没有能解压 $format 压缩包的工具。装上 p7zip 再试一次，或者自己把 $name 解压出来，再安装里面的文件。';
  }

  @override
  String errorNoUnpackerLinuxRar(String format, String name) {
    return '这台电脑上没有能解压 $format 压缩包的工具。装上 p7zip 或 unrar 再试一次，或者自己把 $name 解压出来，再安装里面的文件。';
  }

  @override
  String errorUnpackFailed(String name) {
    return '$name 解压失败。可能有密码、是分卷压缩包的一部分，或者下载损坏了。手动解压后再安装里面的文件吧。';
  }

  @override
  String errorSims3PackUnreadable(String name) {
    return '$name 不是这个应用能读取的《模拟人生3》包。';
  }

  @override
  String errorSims3PackWorld(String name) {
    return '$name 是一个世界，不是自定义内容。用《模拟人生3》启动器安装吧，游戏把世界放在 Mods 文件夹之外。';
  }

  @override
  String errorSims3PackLibrary(String name) {
    return '$name 是一块地块或一户家庭，不是自定义内容。用《模拟人生3》启动器安装吧，它会进到游戏里的收藏库。';
  }

  @override
  String errorInstallFailed(String name, String reason) {
    return '「$name」安装失败：$reason。要是一直不行，就手动解压后安装里面的文件。';
  }

  @override
  String errorInstallFailedRaw(String name, String reason) {
    return '「$name」安装失败：$reason';
  }

  @override
  String errorFileInUseDelete(String name) {
    return '「$name」删除失败：文件被别的程序占用了（游戏还开着？），或者是只读的。先关掉占用它的程序，再试一次。';
  }

  @override
  String errorFileInUseRename(String name) {
    return '「$name」重命名失败：文件被别的程序占用了（游戏还开着？），或者是只读的。先关掉占用它的程序，再试一次。';
  }

  @override
  String errorFileNameTaken(String name) {
    return '那个文件夹里已经有“$name”了。改个名字再试一次吧。';
  }

  @override
  String errorFolderNameBad(String name) {
    return '“$name”不能用作文件夹名。换一个不带斜杠和系统保留字符的名字试试。';
  }

  @override
  String errorFolderTooDeep(int levels) {
    return '游戏只会读取 MOD 文件夹往下 $levels 层，再深的东西永远不会加载。';
  }

  @override
  String errorBulkMoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 个 MOD 没能移动，可能被别的程序占用（游戏还开着吗？）、是只读的，或者目标文件夹里已经有同名文件了。',
    );
    return '$_temp0';
  }

  @override
  String errorBulkToggleFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 个 MOD 没能切换状态，可能被别的程序占用（游戏还开着吗？）或者是只读的。',
    );
    return '$_temp0';
  }

  @override
  String errorBulkRemoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 个 MOD 没能删除，可能被别的程序占用（游戏还开着吗？）或者是只读的。',
    );
    return '$_temp0';
  }

  @override
  String errorFileMissing(String name) {
    return '「$name」已经不在模组文件夹里了，可能被别的程序移动或删除了。';
  }

  @override
  String get requirementMedievalModLoader =>
      '《模拟人生中世纪》没有社区的加载器文件（放在游戏的 Game\\Bin 文件夹里）就跑不了脚本模组和核心模组。自定义内容不受影响，其他的都不行。';

  @override
  String get requirementSims4ModsOff =>
      '游戏自己的「游戏选项」里把自定义内容和模组关掉了，所以这些统统没加载。到 选项 → 游戏选项 → 其他 里重新打开，然后重启游戏。';

  @override
  String get requirementSims4ScriptModsOff =>
      '你这里有脚本模组，但游戏的「游戏选项」里关掉了「允许脚本模组」。每次游戏更新都会把它重置。';

  @override
  String get requirementGetFile => '去哪儿下载';

  @override
  String tooDeepBanner(int count, int levels) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 个模组',
    );
    return '$_temp0放在游戏读不到的子文件夹里。游戏只会往模组文件夹里找 $levels 层，把它们往上挪一挪就能加载了。';
  }

  @override
  String get tooDeepShow => '看看是哪些';

  @override
  String get duplicatesFind => '查找重复的模组';

  @override
  String duplicatesScanning(int done, int total) {
    return '正在读取可能重复的模组… $done / $total';
  }

  @override
  String get duplicatesStop => '停止';

  @override
  String duplicatesBanner(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '有 $count 个模组和别的模组是同一个文件',
    );
    return '$_temp0，清掉能省下 $size。';
  }

  @override
  String get duplicatesShow => '看看是哪些';

  @override
  String get duplicatesSelectExtras => '勾选多余的副本';

  @override
  String get duplicatesClean => '这里没有重复的模组。';

  @override
  String get duplicatesDismiss => '知道了';

  @override
  String tagTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个模组的标签',
    );
    return '$_temp0';
  }

  @override
  String get tagBody => '你自己的标签，方便以后找东西。点一下加上或去掉。';

  @override
  String get tagHint => '新标签';

  @override
  String get tagAdd => '添加';

  @override
  String get tagDone => '完成';

  @override
  String get tagHeading => '标签';

  @override
  String get tagAddFirst => '加个标签';

  @override
  String tagRemove(String tag) {
    return '去掉“$tag”';
  }

  @override
  String get selectionTag => '打标签…';

  @override
  String folderAlsoReading(String folders) {
    return '你的游戏也会读取 $folders，所以那里的模组也在这个库里。';
  }

  @override
  String errorFolderUnreadable(String folder) {
    return '打不开「$folder」。请选一个这台电脑能访问的驱动器上的文件夹，手机、相机或者已断开的网络驱动器放不了你的模组。';
  }

  @override
  String errorNoWriteAccess(String folder) {
    return '应用没有权限写入「$folder」。这个文件夹被系统保护着，给你的账户加上写入权限，或者在设置里换一个文件夹。';
  }

  @override
  String get folderReadOnlyBanner => '这个模组文件夹是只读的，在账户拿到写入权限之前，安装和删除模组都做不了。';

  @override
  String get elevatedNoDropBanner =>
      '你是以管理员身份运行的，所以 Windows 不让你把文件拖到窗口里。用「安装」按钮吧，那个还能正常用。';

  @override
  String errorShopDownload(String name) {
    return '「$name」无法从 The Exchange 下载。检查一下网络连接，再试一次吧。';
  }

  @override
  String errorShopNoModFiles(String name) {
    return '“$name”里没有这个游戏能安装的东西，可能根本不是模组。用「下载」把文件存到你想放的地方吧。';
  }

  @override
  String get errorShopListingNotFound => 'The Exchange 上已经没有这个模组了，可能是被下架了。';

  @override
  String get errorShopListingUnknownGame => '这个模组对应的游戏，当前版本的应用还不认识。更新一下试试。';

  @override
  String errorPackToggleFailed(String pack) {
    return '没能切换 $pack。关掉游戏再试一次。';
  }

  @override
  String get errorPackNoUserData => '找不到游戏自己的设置文件夹，也就没地方记下要跳过哪些内容包。先把游戏运行一次吧。';

  @override
  String get errorPackNeedsAdmin => 'Windows 不允许应用做这个改动。以管理员身份重启后再试一次。';

  @override
  String get errorPackNotSupported => '这个系统上无法开关内容包。';

  @override
  String get errorPackIsTheGame => '游戏就是从这个包启动的，所以它必须保持开启。';

  @override
  String get errorPackToggleRefused => '没能改动这个包。关掉游戏再试一次。';

  @override
  String get eraClassic => '经典';

  @override
  String get eraNightlife => '夜生活';

  @override
  String get eraAmbitions => '事业';

  @override
  String get eraModern => '现代';

  @override
  String get eraMedieval => '中世纪';

  @override
  String get navPacks => '内容包';

  @override
  String get packsScanning => '正在查找你的内容包…';

  @override
  String get packsEmptyTitle => '没有找到内容包';

  @override
  String packsEmptyBody(String game) {
    return '可能是《$game》没装在应用能看到的位置，也可能是旁边还没有任何内容包。';
  }

  @override
  String get packsRescan => '重新检查';

  @override
  String packsSummary(int count) {
    return '已安装 $count 个内容包';
  }

  @override
  String packsSummaryWithOff(int count, int off) {
    return '$count 个已开启，$off 个已关闭';
  }

  @override
  String get packsOff => '已关闭';

  @override
  String get packsInstalled => '已安装';

  @override
  String get packsNeedAdmin =>
      '开关这些内容包需要管理员权限，因为游戏的清单就存在那里。以管理员身份重启应用才能改动 - 这期间拖放会失效，改完之后建议再切回来。';

  @override
  String get packsExperimentalTitle => '关闭它们还是实验性功能';

  @override
  String get packsExperimentalOff =>
      '它的原理和这款游戏一直以来的做法一样，但没人在这个版本上验证过，而且用某个包玩过的街区，在缺少它的时候打开可能会坏掉。只是查看不会有事。如果还是想试，就在设置里打开实验性内容包开关。';

  @override
  String get packsExperimentalOn =>
      '先备份你的街区。用某个包玩过的街区，缺少它时打开可能会坏掉，而且这在这里撤不回来 - 把包重新打开也不一定能把存档救回来。';

  @override
  String packsRestartNotice(String game) {
    return '重启《$game》后才会生效。你的内容包不管怎样都还在。';
  }

  @override
  String packsAllOwnedSims4(String expansions, String gamePacks) {
    return '$expansions个资料片，$gamePacks个游戏包。当然都是买的。';
  }

  @override
  String get packKindExpansions => '资料片';

  @override
  String get packKindGamePacks => '游戏包';

  @override
  String get packKindStuffPacks => '物品组合包';

  @override
  String get packKindKits => '套件';

  @override
  String get packKindFreePacks => '免费内容包';

  @override
  String get navSaves => '存档';

  @override
  String get savesScanning => '正在读取你的存档…';

  @override
  String get savesEmptyTitle => '没有找到存档';

  @override
  String savesEmptyBody(String game) {
    return '玩过$game并保存后，你的世界就会出现在这里：家庭、照片，一个都不少。';
  }

  @override
  String get savesRescan => '重新扫描存档';

  @override
  String savesCount(int count) {
    return '找到 $count 个存档';
  }

  @override
  String savesLastSaved(String date) {
    return '上次保存于 $date';
  }

  @override
  String get savesShowInFolder => '在文件夹中显示';

  @override
  String savesBackups(int count) {
    return '$count 个备份';
  }

  @override
  String get savesTabHouseholds => '家庭';

  @override
  String get savesTabAlbum => '相册';

  @override
  String get savesTabStats => '世界统计';

  @override
  String savesNeighborhood(int number) {
    return '社区 $number';
  }

  @override
  String get savesOtherHouseholds => '市民与其他家庭';

  @override
  String savesSimCount(int count) {
    return '$count 个市民';
  }

  @override
  String get savesFunds => '资金';

  @override
  String get savesRooms => '房间';

  @override
  String savesBedsBaths(int beds, int baths) {
    return '$beds 卧 · $baths 卫';
  }

  @override
  String savesByCreator(String name) {
    return '由 $name 创建';
  }

  @override
  String get savesMembers => '成员';

  @override
  String get savesRelationships => '关系';

  @override
  String get savesUnknownSim => '未知市民';

  @override
  String get savesStatSims => '市民';

  @override
  String get savesStatHouseholds => '家庭';

  @override
  String get savesStatNetWorth => '总资产';

  @override
  String get savesStatWorlds => '世界';

  @override
  String get savesStatPhotos => '照片';

  @override
  String savesAcrossHouseholds(int count) {
    return '来自 $count 个家庭';
  }

  @override
  String savesPlayedCount(int count) {
    return '$count 个在玩';
  }

  @override
  String get savesSizeOnDisk => '占用空间';

  @override
  String get savesLifeStages => '人生阶段';

  @override
  String get savesTopSkills => '本存档的最高技能';

  @override
  String get savesSaveInfo => '存档文件';

  @override
  String get savesLastSavedLabel => '上次保存';

  @override
  String get savesGameVersion => '游戏版本';

  @override
  String get savesDescription => '描述';

  @override
  String get savesAgeInfant => '新生儿';

  @override
  String get savesAgeBaby => '婴儿';

  @override
  String get savesAgeToddler => '幼儿';

  @override
  String get savesAgeChild => '儿童';

  @override
  String get savesAgeTeen => '青少年';

  @override
  String get savesAgeYoungAdult => '青年';

  @override
  String get savesAgeAdult => '成年';

  @override
  String get savesAgeElder => '老年';

  @override
  String get savesGenderMale => '男';

  @override
  String get savesGenderFemale => '女';

  @override
  String get savesSkillCooking => '烹饪';

  @override
  String get savesSkillMechanical => '机械';

  @override
  String get savesSkillCharisma => '魅力';

  @override
  String get savesSkillBody => '体魄';

  @override
  String get savesSkillLogic => '逻辑';

  @override
  String get savesSkillCreativity => '创造力';

  @override
  String get savesSkillCleaning => '清洁';

  @override
  String get savesPersonalityNeat => '爱干净';

  @override
  String get savesPersonalityOutgoing => '外向';

  @override
  String get savesPersonalityActive => '活跃';

  @override
  String get savesPersonalityPlayful => '爱玩';

  @override
  String get savesPersonalityNice => '友善';

  @override
  String get savesZodiacAries => '白羊座';

  @override
  String get savesZodiacTaurus => '金牛座';

  @override
  String get savesZodiacGemini => '双子座';

  @override
  String get savesZodiacCancer => '巨蟹座';

  @override
  String get savesZodiacLeo => '狮子座';

  @override
  String get savesZodiacVirgo => '处女座';

  @override
  String get savesZodiacLibra => '天秤座';

  @override
  String get savesZodiacScorpio => '天蝎座';

  @override
  String get savesZodiacSagittarius => '射手座';

  @override
  String get savesZodiacCapricorn => '摩羯座';

  @override
  String get savesZodiacAquarius => '水瓶座';

  @override
  String get savesZodiacPisces => '双鱼座';

  @override
  String get savesAspirationRomance => '浪漫';

  @override
  String get savesAspirationFamily => '家庭';

  @override
  String get savesAspirationFortune => '财富';

  @override
  String get savesAspirationPopularity => '人气';

  @override
  String get savesAspirationKnowledge => '知识';

  @override
  String get savesAspirationGrowUp => '成长';

  @override
  String get savesAspirationPleasure => '享乐';

  @override
  String get savesAspirationGrilledCheese => '烤奶酪';

  @override
  String get savesRelCrush => '心动';

  @override
  String get savesRelLove => '热恋';

  @override
  String get savesRelEngaged => '订婚';

  @override
  String get savesRelMarried => '已婚';

  @override
  String get savesRelFriends => '朋友';

  @override
  String get savesRelBestFriends => '挚友';

  @override
  String get savesRelSteady => '稳定交往';

  @override
  String get savesRelEnemies => '敌人';

  @override
  String get savesPhotoFamilyPortrait => '全家福';

  @override
  String get savesPhotoLot => '地块';

  @override
  String get savesPhotoSim => '市民照';

  @override
  String get savesPhotoSnapshot => '快照';

  @override
  String get savesProperty => '房产';

  @override
  String get savesGhost => '幽灵';

  @override
  String savesCareerLevel(String career, int level) {
    return '$career · 第 $level 级';
  }

  @override
  String get savesSpeciesLargeDog => '狗';

  @override
  String get savesSpeciesSmallDog => '小型犬';

  @override
  String get savesSpeciesCat => '猫';

  @override
  String get savesOccultVampire => '吸血鬼';

  @override
  String get savesOccultZombie => '僵尸';

  @override
  String get savesOccultWerewolf => '狼人';

  @override
  String get savesOccultPlantSim => '植物人';

  @override
  String get savesOccultAlien => '外星人';

  @override
  String get savesOccultServo => '机器人';

  @override
  String get savesOccultWitch => '女巫';

  @override
  String get savesOccultBigfoot => '大脚怪';

  @override
  String get savesOccultFairy => '妖精';

  @override
  String get savesOccultGenie => '精灵';

  @override
  String get savesOccultMermaid => '人鱼';

  @override
  String get savesLotResidential => '住宅';

  @override
  String get savesLotCommunity => '社区场地';

  @override
  String get savesLotDorm => '宿舍';

  @override
  String get savesLotSecretSociety => '秘密社团';

  @override
  String get savesLotGreekHouse => '兄弟会';

  @override
  String get savesLotHotel => '酒店';

  @override
  String get savesLotSecret => '隐藏场地';

  @override
  String get savesLotBusiness => '商铺';

  @override
  String get savesLotApartment => '公寓';

  @override
  String savesGpa(String gpa) {
    return '绩点 $gpa';
  }

  @override
  String savesSemester(int number) {
    return '第 $number 学期';
  }

  @override
  String savesPredestinedHobby(String hobby) {
    return '天生适合$hobby';
  }

  @override
  String get savesHobbyCuisine => '烹饪';

  @override
  String get savesHobbyArts => '手工艺';

  @override
  String get savesHobbyFilm => '影视文学';

  @override
  String get savesHobbySports => '运动';

  @override
  String get savesHobbyGames => '游戏';

  @override
  String get savesHobbyNature => '自然';

  @override
  String get savesHobbyTinkering => '修补';

  @override
  String get savesHobbyFitness => '健身';

  @override
  String get savesHobbyScience => '科学';

  @override
  String get savesHobbyMusic => '音乐舞蹈';

  @override
  String get savesTieMother => '母亲';

  @override
  String get savesTieFather => '父亲';

  @override
  String get savesTieSpouse => '配偶';

  @override
  String savesTieSibling(int count) {
    return '兄弟姐妹';
  }

  @override
  String savesTieChild(int count) {
    return '子女';
  }

  @override
  String get savesInterestPolitics => '政治';

  @override
  String get savesInterestMoney => '金钱';

  @override
  String get savesInterestEnvironment => '环境';

  @override
  String get savesInterestCrime => '犯罪';

  @override
  String get savesInterestEntertainment => '娱乐';

  @override
  String get savesInterestCulture => '文化';

  @override
  String get savesInterestFood => '美食';

  @override
  String get savesInterestHealth => '健康';

  @override
  String get savesInterestFashion => '时尚';

  @override
  String get savesInterestSports => '运动';

  @override
  String get savesInterestParanormal => '灵异';

  @override
  String get savesInterestTravel => '旅行';

  @override
  String get savesInterestWork => '工作';

  @override
  String get savesInterestWeather => '天气';

  @override
  String get savesInterestAnimals => '动物';

  @override
  String get savesInterestSchool => '学校';

  @override
  String get savesInterestToys => '玩具';

  @override
  String get savesInterestSciFi => '科幻';

  @override
  String get savesInterestMusic => '音乐';

  @override
  String get savesInterestOutdoors => '户外';

  @override
  String get setupHelpSims1 =>
      '初代模拟人生把自定义内容放在自己的安装目录里，而不是「文档」：物件放在游戏可执行文件旁边的 Downloads 文件夹（例如 C:\\Program Files (x86)\\Maxis\\The Sims\\Downloads），其他类型这个应用会自动归类：皮肤（.skn/.cmx/.bmp）放进 GameData\\Skins，墙面和地板放进 GameData\\Walls 和 GameData\\Floors。2025 年的 Legacy Collection 也一样，用它自己的安装目录（EA Games\\The Sims Legacy，或 Steam\\steamapps\\common\\The Sims Legacy Collection）。如果游戏装在别的地方（另一个磁盘、自定义的 Steam 库），请手动选它的 Downloads 文件夹。';

  @override
  String get setupHelpSims2 =>
      '模拟人生 2 从「文档 > EA Games > The Sims 2 > Downloads」加载自定义内容（Ultimate Collection 用的是「The Sims 2 Ultimate Collection」，2025 年的 Legacy Collection 用的是「The Sims 2 Legacy」）。在你亲手创建它、或者第一次装内容之前，这个文件夹可能并不存在。游戏启动时，对自定义内容的提示选「是」，下载的内容才会生效。';

  @override
  String get setupHelpSims3 =>
      '模拟人生 3 不会自己创建 MOD 文件夹：它需要社区的「框架」，也就是「文档 > Electronic Arts > The Sims 3」里的 Mods > Packages 文件夹，再加上一个告诉游戏去读它的 Resource.cfg 文件。这两样这个应用都能帮你建好。光盘版或 Wine 安装时，这个文件夹也可能在游戏包内部；那就用「选择文件夹」手动指过去。';

  @override
  String get setupHelpSims4 =>
      '模拟人生 4 从「文档 > Electronic Arts > The Sims 4 > Mods」加载 MOD。游戏第一次运行时会自己建好这个文件夹，所以如果没有，先把游戏启动一次。然后在游戏里打开 选项 > 游戏选项 > 其他 >「启用自定义内容和MOD」（.ts4script 文件还需要「允许脚本MOD」），再重启游戏。';

  @override
  String get setupHelpSimsMedieval =>
      '模拟人生中世纪从安装目录加载 MOD，而不是「文档」：在游戏文件旁边放一个 Mods > Packages 文件夹（例如 C:\\Program Files (x86)\\Origin Games\\The Sims Medieval），再在安装目录里放一个告诉游戏去读它的 Resource.cfg。这两样这个应用都能帮你建好（在 Program Files 下 Windows 可能会要管理员权限）。「文档 > Electronic Arts > The Sims Medieval」只存档案，放在那儿的 MOD 不起作用。如果用 Wine/CrossOver，或者 Steam 库位置是自定义的，就用「选择文件夹」指向安装目录里的 Mods > Packages。';

  @override
  String get prefSubfoldersTitle => '文件夹包含子文件夹';

  @override
  String get prefSubfoldersDesc =>
      '文件夹会一并显示下面的所有内容。关掉后，cc 和 cc/defaults 就是两个独立的架子。';

  @override
  String deleteFolderTitle(String folder) {
    return '删除 $folder？';
  }

  @override
  String get deleteFolderBody => '这个文件夹和里面的所有东西都会消失，子文件夹也一样。这个操作无法撤销。';

  @override
  String deleteFolderMods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '将删除 $count 个模组',
    );
    return '$_temp0';
  }

  @override
  String get deleteFolderEmpty => '里面没有模组。';

  @override
  String get deleteFolder => '删除文件夹';

  @override
  String triviaTitle(String game) {
    return '绿钻小知识 · $game';
  }

  @override
  String get triviaContextLibrary => '看起来你在翻自己的模组';

  @override
  String get triviaContextSaves => '看起来你在存档里';

  @override
  String get triviaContextPacks => '看起来你在整理资料包';

  @override
  String triviaCounter(int index, int total) {
    return '第 $index 条，共 $total 条';
  }

  @override
  String get triviaOpen => '问问绿钻';

  @override
  String get triviaClose => '暂时不用';

  @override
  String get triviaPrevious => '上一条';

  @override
  String get triviaNext => '下一条';

  @override
  String get triviaAnother => '再来一条';

  @override
  String get triviaToSettings => '看够了？到设置里把绿钻关掉';

  @override
  String get prefTriviaTitle => '绿钻小知识';

  @override
  String get prefTriviaDesc => '让绿钻时不时冒出来，讲一条你当前这部游戏的冷知识';

  @override
  String get triviaCategoryOrigins => '起源';

  @override
  String get triviaCategoryDesign => '设计';

  @override
  String get triviaCategoryLore => '设定';

  @override
  String get triviaCategoryDeath => '死法';

  @override
  String get triviaCategoryMusic => '音乐';

  @override
  String get triviaCategoryCheats => '秘籍';

  @override
  String get triviaCategoryRecords => '纪录';

  @override
  String get triviaCategoryModding => '模组';

  @override
  String get triviaCategoryLanguage => '语言';

  @override
  String get triviaCategoryCommunity => '社区';

  @override
  String get triviaSeriesLlama =>
      'Maxis 曾经全工作室投票选一个非官方吉祥物，候选是波士顿蕨、牛带绦虫和羊驼。羊驼赢了，从此它就一直出现在每一代游戏里。';

  @override
  String get triviaSeriesSimlish =>
      '模拟语是在录音棚里现场造出来的。制作组给 Stephen Kearin 和 Gerri Lawlor 一些提示，比如「饿了」「孤单」，两人就即兴发挥出那应该是什么声音，一录就是好几个小时。';

  @override
  String get triviaSeriesCheats =>
      'rosebud 和 klapaucius 各给 §1,000。rosebud 出自《公民凯恩》；Klapaucius 则是斯坦尼斯瓦夫·莱姆《机器人大师》里的机器人工匠，这本书从 SimCity 时代起就被 Will Wright 列为灵感来源。';

  @override
  String get triviaSeriesRecords =>
      '吉尼斯认定《模拟人生》是史上最畅销的 PC 游戏系列。十多年前它就突破了一亿两千五百万份，并被翻译成 60 种语言。';

  @override
  String get triviaSeriesGoths =>
      '哥特一家是电子游戏里延续最久的家庭之一。莫蒂默和贝拉从 2000 年起出现在每一部正传里。';

  @override
  String get triviaSeriesReaper =>
      '死神有一份正常游玩永远看不到的人物简介。里面除了别的，还写了他最喜欢的乐队：Styx。';

  @override
  String get triviaSeriesSimCity =>
      '《模拟人生》是从 SimCity 里长出来的。Will Wright 一直想把镜头推近，看看这座城市究竟是为哪些小人建的。';

  @override
  String get triviaSeriesLegacy =>
      '2025 年 1 月，EA 把《模拟人生》和《模拟人生 2》以 Legacy Collection 的形式重新上架，资料片全都包含在内。它们是兼容性修补而不是重制版，所以玩起来和当年一模一样。';

  @override
  String get triviaSeriesPlumbob =>
      '那颗绿色的钻石有过三种拼法：《模拟人生》里是 PlumbBob，《模拟人生 2》里是 Plum Bob，从《模拟人生 4》起是 plumbob。Maxis 说开发期间这三种都在用。';

  @override
  String get triviaSeriesModScene =>
      '模组圈几乎和这个系列一样老。2000 年第一代发售后没几个月，皮肤和物件编辑器就已经在流传了，那时候还根本没有官方工具。';

  @override
  String get triviaSeriesConflicts =>
      '所谓冲突，比听上去简单得多。两个模组都要占同一份资源，两个都会加载，游戏最后读到哪个就以哪个为准。没有东西坏掉，只是有一个被盖过去了。';

  @override
  String get triviaSeriesPackage =>
      '.package 文件其实是 DBPF 压缩包，全称 Database Packed File。Maxis 从 SimCity 4 起就一直用同一种容器，所以一个工具能打开二十年份的自定义内容。';

  @override
  String get triviaSeriesRename =>
      '靠改文件名来关掉一个模组，是这个圈子里最老的招数。游戏只加载它认得的文件，所以改过名的 package 就原地待着，安安静静。';

  @override
  String get triviaSeriesSaves =>
      '《模拟人生》的存档是「街区」，不是「档位」。家庭、地块、记忆和八卦全都住在同一个文件夹里，你玩得越久它就越大。';

  @override
  String get triviaSeriesPacks =>
      '关掉一个资料包不会移动任何文件。系列里的每一部游戏都把「要加载什么」的清单放在别处，可能是一行设置，也可能是一个注册表键，隐藏一个包不过是改那份清单而已。';

  @override
  String get triviaSims1Dollhouse =>
      '《模拟人生》最初是个叫 Project Dollhouse 的建筑模拟器。加入模拟市民，只是为了让玩家能判断这房子到底住得舒不舒服。';

  @override
  String get triviaSims1Oakland =>
      'Will Wright 在 1991 年奥克兰大火里失去了自己的房子。从零重建一个家，家具、电器、日常作息，成了这款游戏的种子。';

  @override
  String get triviaSims1Toilet => '高层当年并没有被这个提案说服，还把它贬为「马桶游戏」，因为模拟市民得上厕所。';

  @override
  String get triviaSims1HomeTactics =>
      '在定名《模拟人生》之前，它的提案名字是 Home Tactics: The Experimental Domestic Simulator。焦点小组同样不买账。';

  @override
  String get triviaSims1Myst => '2002 年，《模拟人生》超过《神秘岛》，成为史上最畅销的 PC 游戏。';

  @override
  String get triviaSims1Simlish =>
      '模拟语是配音演员即兴发挥出来的，素材是乌克兰语、纳瓦霍语、他加禄语和爱沙尼亚语的碎片，并刻意保持没有含义，这样这门语言就永远不会过时。';

  @override
  String get triviaSims1Architecture =>
      '对 2000 年来说，它的建造工具实在太特别了，有些人干脆一个模拟市民都没放，就把游戏当成免费的建筑设计软件用。';

  @override
  String get triviaSims1Audience =>
      '在那个年代很少见，这款游戏的玩家以女性居多，这也是它的宣传在货架上跟谁都不像的原因之一。';

  @override
  String get triviaSims1Cowplant =>
      '奶牛植物就是在这一代首次登场的，学名 Laganaphyllis Simnovorii，从那以后每一代它都在悄悄吃掉模拟市民。';

  @override
  String get triviaSims1Plumbob =>
      'plumbob 这个词来自铅垂线，就是工匠挂在绳子上用来找垂直的那个尖头坠子。这款游戏首先是一款建筑游戏。';

  @override
  String get triviaSims1Release => '游戏于 2000 年 2 月 4 日发售，销量超过了 EA 为它做过的每一份预测。';

  @override
  String get triviaSims1Edith =>
      '游戏里每一个物件都是用一种叫 SimAntics 的语言写的，用的是内部工具 Edith，这个名字取自 Edith Bunker：《模拟人生》有史以来做出的第一个角色。';

  @override
  String get triviaSims1Expansions =>
      '三年半里出了七部资料片，春一部秋一部，从 2000 年 8 月的 Livin’ Large 到 2003 年 10 月的 Makin’ Magic。';

  @override
  String get triviaSims1Unleashed =>
      'Unleashed 在 2002 年把宠物带进了这个系列，并在 Interactive Achievement Awards 拿下年度模拟游戏。';

  @override
  String get triviaSims1Clown => '悲剧小丑会跑来安慰一个挂着他画像的伤心市民。他干得糟透了，而这正是笑点所在。';

  @override
  String get triviaSims1Llama =>
      '最初的纸质说明书里夹着一本叫《Making the Most of Your Llama》的书。从来没有人解释过为什么。';

  @override
  String get triviaSims1Superstar =>
      'Superstar 让模拟市民能当演员、模特或歌手，还配了一条名气条，比《模拟人生 4》再度尝试明星玩法早了十一年。';

  @override
  String get triviaSims1Catalogue =>
      '大火之后重建房子时，Will Wright 一直在问自己：一个家里哪些东西是必需的，哪些可以以后再说。这个问题大致就是购买模式的目录。';

  @override
  String get triviaSims2Aging =>
      '《模拟人生 2》是系列里第一部让市民会变老、会寿终正寝、会把基因传下去的作品。眼睛、鼻子和下巴都来自父母双方。';

  @override
  String get triviaSims2Memories =>
      '每个市民都带着一份隐藏的记忆清单。目睹死亡、初吻或者升职都会被记下来，并影响之后的心情。';

  @override
  String get triviaSims2Bella =>
      '游戏一开始，贝拉·哥特就从 Pleasantview 消失了，二十年过去，官方从未解释过她去了哪里。';

  @override
  String get triviaSims2Strangetown =>
      '贝拉活生生地出现在 Strangetown，却完全不记得 Pleasantview。Maxis 说两个贝拉都是真的，然后就没有下文了。';

  @override
  String get triviaSims2FamilyTrees =>
      '《模拟人生 2》的街区建立在一棵真正的家谱上：Pleasantview、Strangetown 和 Veronaville 靠婚姻和流言彼此相连。';

  @override
  String get triviaSims2Plead => '死神是可以求情的。在恰当的时机跟他搭话，他也许会把你的市民还回来，偶尔要拿另一个人来换。';

  @override
  String get triviaSims2ReaperRomance => '你可以跟死神谈恋爱。要是这一手打得漂亮，这段关系还能生出一个幽灵宝宝。';

  @override
  String get triviaSims2Satellite =>
      '一个盯着星星看的市民，有极小的概率被坠落的卫星砸中。这是整个系列里最罕见的死法之一。';

  @override
  String get triviaSims2Therapist =>
      '人生目标崩溃会把市民送去看心理医生，这是游戏为数不多的、为了搞笑而打破自己第四面墙的时刻。';

  @override
  String get triviaSims2WantsFears =>
      '愿望和恐惧撑起了整个游戏。人生目标条对市民「怕发生的事」和「盼发生的事」反应一样强烈。';

  @override
  String get triviaSims2FaceSculpt =>
      '游戏自带一整套体型和面部雕刻系统，这也是为什么《模拟人生 2》的脸至今看起来都比后面几代更有辨识度。';

  @override
  String get triviaSims2Aliens => '外星人绑架只会发生在盯着星星太久的男性市民身上，而且没错，他们回来时是怀着孕的。';

  @override
  String get triviaSims2FreezerBunny =>
      'Freezer Bunny 由美术 Emmy Toyonaga 为《模拟人生 2》所画，最早是藏在一个社区地块的冰柜里。从那以后，它被偷偷塞进了每一部作品。';

  @override
  String get triviaSims2SocialBunny =>
      '社交兔取代了悲剧小丑，而且跟小丑不一样，它是真的有用。不少玩家反而觉得这个称职的版本更让人发毛。';

  @override
  String get triviaSims2Giveaway =>
      '2014 年 7 月，EA 通过 Origin 免费送出了 Ultimate Collection，用兑换码 I-LOVE-THE-SIMS 领取。此后十年，直到 Legacy Collection 出现之前，这份赠品是唯一能拿到的版本。';

  @override
  String get triviaSims3SunsetValley =>
      'Sunset Valley 就是《模拟人生 2》里 Pleasantview 大约 25 年前的样子，所以你能见到自己玩过的那些市民的祖辈。';

  @override
  String get triviaSims3Founders =>
      'Sunset Valley 由哥特家创立，由 Landgraab 家建设起来。你可以操作童年时期的莫蒂默·哥特，看着他遇见贝拉·巴切勒。';

  @override
  String get triviaSims3OpenWorld =>
      '《模拟人生 3》彻底取消了加载画面。整个小镇同时运转，每个市民都在后台变老和上班。';

  @override
  String get triviaSims3Simulation =>
      '镇上所有市民都在同时被模拟，这就是老存档会越来越卡的原因。游戏正安静地替你从没见过的人过日子。';

  @override
  String get triviaSims3CreateAStyle =>
      '「创建风格」让玩家几乎能给任何物件换色换花纹，这个功能吃性能吃得太狠，此后再没回来过。';

  @override
  String get triviaSims3Exchange =>
      '《模拟人生 3》自带一个真正的在线交换平台，玩家直接在启动器里交换地块、市民和花纹。';

  @override
  String get triviaSims3Downloads => '光是第一周，玩家就从那个启动器里下载了超过七百万件社区自制物品。';

  @override
  String get triviaSims3Traits => '特质取代了旧的性格滑块，其中一些，比如盗窃癖和疯癫，会悄悄打破正常生活的规则。';

  @override
  String get triviaSims3Kleptomaniac =>
      '有盗窃癖的市民会把别人家的家具搬回家，没人让他这么做，而且他会一直搬到你发现为止。';

  @override
  String get triviaSims3Simlish =>
      'Katy Perry、Lily Allen、Depeche Mode 等几十位艺人，都用模拟语重新录制了自己的歌曲作为原声。';

  @override
  String get triviaSims3Townies =>
      '因为开放世界连镜头外的市民也一起模拟，玩家常常发现镇民们已经结了婚、生了孩子，全程不需要你插手。';

  @override
  String get triviaSims3Store => '模拟人生 3 商城最终卖出的物件，比游戏本体发售时自带的还多。';

  @override
  String get triviaSims3Launch =>
      '《模拟人生 3》在 2009 年 6 月首周卖出 140 万份，是 EA 当时最成功的一次 PC 发售。';

  @override
  String get triviaSims4Flies => '被苍蝇弄死是真的。让一块地脏到一定程度，一群苍蝇就能收走你的市民。';

  @override
  String get triviaSims4Emotions => '在这一代，一切都由情绪驱动。灵感涌现的市民画得更好；暴怒的市民则可能被自己气死。';

  @override
  String get triviaSims4EmotionDeaths => '市民可以笑死、气死，也可以尴尬死。在这一代，情绪不是装饰，是危险。';

  @override
  String get triviaSims4CreateASim =>
      '「创建市民」把滑块换成了直接在脸上拉扯推挤，所以在《模拟人生 4》里捏一张脸才这么快。';

  @override
  String get triviaSims4Launch =>
      '《模拟人生 4》发售时既没有泳池也没有幼儿。在玩家持续施压之后，这两样都通过免费更新补了回来。';

  @override
  String get triviaSims4Worlds =>
      '2014 年 9 月发售时，只有 Willow Creek 和 Oasis Springs 两个世界。现在有几十个了，而且几乎每一个都是跟着某个资料包一起来的。';

  @override
  String get triviaSims4Gender =>
      '2016 年的一次更新彻底解开了性别限制：任何市民都可以穿任何衣服、用任何声音，也可以选择能不能怀孕。';

  @override
  String get triviaSims4Newcrest =>
      'Newcrest 是故意做成完全空白的。十五块地，一栋房子都没有，等于向社区公开发出邀请。';

  @override
  String get triviaSims4Naming =>
      'Willow Creek、Oasis Springs 这类街区名字沿用的是老 Maxis 的内部规矩：两个普通英文单词，不搞生造拼写。';

  @override
  String get triviaSims4Goths => '哥特一家在这里也在，这让他们成了电子游戏里延续最久的家庭之一，每一部正传都有他们。';

  @override
  String get triviaSims4FreeToPlay =>
      '本体在 2022 年 10 月免费，PC、PlayStation 和 Xbox 同步开放。资料包依然是收费的。';

  @override
  String get triviaSims4Mccc =>
      'MC Command Center 是绝大多数《模拟人生 4》玩家装的第一个模组，光在 CurseForge 上就超过 1400 万次下载。作者 Deaderpool 从 2015 年更新到现在。';

  @override
  String get triviaSims4Twallan =>
      'MCCC 的存在要归功于《模拟人生 3》。它接过了 Twallan 的 Master Controller 和 Story Progression 没做完的事，把一个十多年前的想法带进了新引擎。';

  @override
  String get triviaSims4Deaths => '奶牛植物、自动售货机、羊驼造型的音响，还有大笑，都能弄死一个市民。当然不是一起来。';

  @override
  String get triviaMedievalWatcher =>
      '在这里你不是一户人家，你是「观察者」：一位善意的神明，推动整个王国的英雄，而不是操持一个家庭的日常。';

  @override
  String get triviaMedievalHeroes =>
      '一个王国最多容纳十位英雄市民、十种职业，每一位都从 1 级升到 10 级，一路解锁新能力和越来越气派的头衔。';

  @override
  String get triviaMedievalStocks =>
      '每位英雄醒来都会拿到两项职责和一个期限。次数太多不完成就要受罚，连君主也不例外，是真的会被套上枷锁示众。';

  @override
  String get triviaMedievalAmbition =>
      '开局前你要为整个王国选一个「抱负」，之后接的任务都按这个抱负来评分。这是《模拟人生》离「通关条件」最近的一次。';

  @override
  String get triviaMedievalQuests =>
      '这是一次彻底的改造，不是外传。沙盒被一连串任务取代，也正因如此，它是唯一一款真的能玩通关的《模拟人生》。';

  @override
  String get triviaMedievalPirates =>
      '2011 年 8 月的 Pirates and Nobles 是它唯一得到过的追加内容：猎鹰和鹦鹉、藏宝图和铁锹，还有两股新来势力之间的战争。';

  @override
  String get triviaMedievalProxy =>
      '这款游戏从来就没打算加载模组。脚本模组和核心模组需要社区做的 d3dx9_31.dll 代理放进 Game/Bin，游戏才肯读它们，不过自定义内容不用这个也能用。';

  @override
  String get triviaMedievalEngine =>
      '它跑在《模拟人生 3》的引擎上，所以只要你给那款游戏做过模组，这里的 Resource.cfg 和 .package 文件都会让你觉得眼熟。';

  @override
  String get navCreations => '创作';

  @override
  String creationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个创作',
      zero: '还没有保存任何东西',
    );
    return '$_temp0';
  }

  @override
  String get creationsScanning => '正在读取你的地块和家庭……';

  @override
  String get creationsRefresh => '刷新';

  @override
  String get creationsAll => '全部';

  @override
  String get creationsBack => '← 返回全部';

  @override
  String get creationsNoneOfKind => '这里没有这一类的东西。';

  @override
  String get creationsEmptyTitle => '这里还空着';

  @override
  String get creationsEmptyBody =>
      '你在游戏里保存的地块、房间、家庭和模拟市民都会出现在这里 —— 下载后拖到窗口上的东西也一样。';

  @override
  String creationsBy(String creator) {
    return '作者：$creator';
  }

  @override
  String get creationsWhoLivesHere => '一起带过来的人';

  @override
  String get creationsShowInFolder => '在文件夹中显示';

  @override
  String get creationsDelete => '删除';

  @override
  String creationsDeleteTitle(String name) {
    return '删除“$name”？';
  }

  @override
  String get creationsDeleteBody => '它会从游戏的文件夹里彻底消失，无法撤销。';

  @override
  String creationsFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个文件',
    );
    return '$_temp0';
  }

  @override
  String get creationKindLot => '地块';

  @override
  String get creationKindRoom => '房间';

  @override
  String get creationKindHousehold => '家庭';

  @override
  String get creationKindSim => '模拟市民';

  @override
  String get creationFolderSims4Tray => 'Tray';

  @override
  String get creationFolderSims3Library => 'Library';

  @override
  String get creationFolderSims2LotCatalog => '地块与住宅收藏';

  @override
  String get creationFolderSims2SavedSims => '已打包的市民';

  @override
  String creationFolderSims1Houses(String number) {
    return '第 $number 个街区';
  }

  @override
  String creationBadFileName(String name) {
    return '“$name”的文件名里有本系统不能用的字符，游戏永远找不到它。改个名字再试一次。';
  }

  @override
  String creationFileInUse(String name) {
    return '“$name”正在被占用。关掉游戏再试一次。';
  }

  @override
  String get creationNeighborhoodFull => '这个街区已经放满 99 栋房子了。先删掉一栋你不玩的，再添加新的。';

  @override
  String creationInstallFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '那 $count 个文件没能添加进来。',
      one: '那个文件没能添加进来。',
    );
    return '$_temp0';
  }

  @override
  String creationRemoveFailed(String name) {
    return '“$name”没能删除。';
  }

  @override
  String get creationsAdd => '添加';

  @override
  String get creationsAdding => '正在添加……';

  @override
  String creationsPickerLabel(String game) {
    return '$game 的地块、房间、家庭和市民';
  }

  @override
  String get creationsNothingToAdd =>
      '里面没有这个游戏能用的地块、房间、家庭或市民。自定义内容和模组请从模组库那边添加。';
}
