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
  String get libraryRefresh => '刷新';

  @override
  String get libraryRootFolder => 'Mods 文件夹';

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
  String get conflictSameNameBody =>
      '文件名完全一样，通常意味着同一个 MOD 装了两遍，或者两位作者的包撞车了。游戏加载重叠资源的顺序无法预料：留一个，其余的停用或删掉。';

  @override
  String get conflictVersionBody =>
      '同一个 MOD 装了好几个版本，游戏加载重叠资源的顺序就无法预料：留最新的那个，其余的停用或删掉。';

  @override
  String get conflictResourcesBody =>
      '这些包里有标识符相同的资源，所以游戏只会保留最后加载的那一份。这有时是故意的（补丁类和覆盖类 MOD 本来就是要盖住别的 MOD 的资源），但如果两个 MOD 毫不相干，那就意味着其中一个悄悄失效了：留下你想要的那个，把其余的停用。';

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
  String get translatorsDesc => '这个应用能有十一种语言，全靠这些模拟人生玩家。';

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
  String errorNoModFiles(String extensions, String name) {
    return '$name 里没有找到模组文件（$extensions）。';
  }

  @override
  String errorUnreadableArchive(String name) {
    return '$name 不是这个应用能读取的 zip 压缩包。';
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
  String get errorShopListingNotFound => 'The Exchange 上已经没有这个模组了，可能是被下架了。';

  @override
  String get errorShopListingUnknownGame => '这个模组对应的游戏，当前版本的应用还不认识。更新一下试试。';

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
}
