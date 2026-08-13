// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class LJa extends L {
  LJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Sims Mod Manager';

  @override
  String get brandTitle => 'MOD マネージャー';

  @override
  String get brandSubtitle => 'for The Sims';

  @override
  String get navLibrary => 'ライブラリ';

  @override
  String get navShop => 'The Exchange';

  @override
  String get navSettings => '設定';

  @override
  String get shopAlphaBadge => 'アルファ版';

  @override
  String get shopTagline => 'コミュニティのMODをワンクリックでインストール。';

  @override
  String shopListingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '棚にMOD $count 個',
    );
    return '$_temp0';
  }

  @override
  String get shopRefresh => '更新';

  @override
  String get shopPublish => 'MODを公開する';

  @override
  String get shopLoadFailedTitle => 'The Exchangeにつながりません';

  @override
  String get shopLoadFailedBody => '棚を読み込めませんでした。接続を確認して、もう一度試してみてください。';

  @override
  String get shopRetry => 'もう一度試す';

  @override
  String get shopEmptyTitle => '棚はまだ空っぽ';

  @override
  String get shopEmptyBody =>
      'The Exchangeはオープンしたばかりで、まだ誰も何も公開していません。それくらい新しい場所です。MODを作っているなら、棚の一番乗りになりませんか？';

  @override
  String get shopAllGames => 'すべてのゲーム';

  @override
  String get shopShowAllGames => 'すべてのゲームを表示';

  @override
  String shopEmptyGameTitle(String game) {
    return '$game向けはまだありません';
  }

  @override
  String shopEmptyGameBody(String game) {
    return 'ほかのゲームの棚にはMODが並んでいますが、$game向けはまだ誰も公開していません。作っているなら、一番乗りになりませんか？';
  }

  @override
  String shopBy(String author) {
    return '作者: $author';
  }

  @override
  String get shopInstalled => 'インストール済み';

  @override
  String get shopUpdate => 'アップデート';

  @override
  String get shopUpdateBadge => '更新あり';

  @override
  String shopUpdatesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'あなたのMOD $count 個にThe Exchangeで新しいバージョンが出ています',
    );
    return '$_temp0';
  }

  @override
  String get shopUpdateHeading => 'このMODの新しいバージョンがあります';

  @override
  String shopUpdateBody(String version, String author) {
    return '$author さんがThe Exchangeで v$version を公開しました。アップデートすると今のファイルが置き換わります。';
  }

  @override
  String get shopUpdateSeeListing => 'ページを見る';

  @override
  String get shopInstalling => 'インストール中…';

  @override
  String get shopInstallNotes => 'インストールメモ';

  @override
  String get shopCreatorNudge =>
      'MODを作っていますか？The Exchangeへの公開は無料。プレイヤーはワンクリックであなたの作品をインストールできます。';

  @override
  String shopNeedsFolder(String game) {
    return 'まず$gameのMODフォルダーを設定してください。ライブラリタブが案内します。';
  }

  @override
  String shopVariations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 種類',
    );
    return '$_temp0';
  }

  @override
  String get shopSaveFile => 'ダウンロード';

  @override
  String get shopSaving => 'ダウンロード中…';

  @override
  String get shopSaved => '保存しました';

  @override
  String get shopSaveHint =>
      'インストールはファイルをMODフォルダーに直接入れます。ダウンロードは好きな場所にファイルを保存するだけです。';

  @override
  String get shopDestination => 'インストール先';

  @override
  String get shopVariationPick => 'バリエーションを選ぶ';

  @override
  String get shopBack => '棚に戻る';

  @override
  String get shopCopyLink => 'リンクをコピー';

  @override
  String get shopLinkCopied => 'コピーしました';

  @override
  String get sidebarGames => 'ゲーム';

  @override
  String sidebarNotInstalled(String detail) {
    return '未インストール · $detail';
  }

  @override
  String sidebarModCount(int count, String detail) {
    return 'MOD $count 個 · $detail';
  }

  @override
  String get updateAvailable => 'アップデートあり';

  @override
  String updateClickToDownload(String version) {
    return 'v$version：クリックでダウンロード';
  }

  @override
  String get storage => 'ストレージ';

  @override
  String storageInMods(String size) {
    return 'MOD が $size';
  }

  @override
  String storageFreeOf(String free, String total) {
    return '$total 中 $free 空き';
  }

  @override
  String dropToInstall(String game) {
    return 'ここに落とすと『$game』にインストールします';
  }

  @override
  String get dropFolders => 'フォルダ';

  @override
  String scanningMods(int done, int total) {
    return 'MOD の中を見て、画像と競合を探しています… $done/$total';
  }

  @override
  String get skip => 'スキップ';

  @override
  String libraryTitle(String game) {
    return '『$game』のライブラリ';
  }

  @override
  String modsShown(int count, String era) {
    return 'MOD $count 個を表示中 · $era';
  }

  @override
  String get learnMore => '詳しく見る';

  @override
  String get dismiss => '閉じる';

  @override
  String get searchMods => 'MOD を検索…';

  @override
  String get viewGrid => 'グリッド';

  @override
  String get viewList => 'リスト';

  @override
  String get viewFolders => 'フォルダ';

  @override
  String get sortTooltip => '並べ替え';

  @override
  String get sortByName => '名前（A–Z）';

  @override
  String get sortByRecent => '最近変更した順';

  @override
  String get sortBySize => 'サイズが大きい順';

  @override
  String get sortDisabledLast => '無効にしたものを最後に';

  @override
  String get libraryRefresh => '更新';

  @override
  String get libraryRootFolder => 'Mods フォルダ';

  @override
  String get selectionTooltip => '選択';

  @override
  String selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件選択中',
    );
    return '$_temp0';
  }

  @override
  String get selectionSelectAll => 'すべて選択';

  @override
  String get selectionClear => '選択を解除';

  @override
  String get selectionEnable => '有効にする';

  @override
  String get selectionDisable => '無効にする';

  @override
  String selectionProgress(int done, int total) {
    return '$total 件中 $done 件';
  }

  @override
  String selectionDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'MOD $count 個をアンインストールしますか？',
    );
    return '$_temp0';
  }

  @override
  String selectionDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個のファイルをディスクから削除します。元には戻せません。',
    );
    return '$_temp0';
  }

  @override
  String get selectionMove => '移動先…';

  @override
  String get newFolder => '新しいフォルダ';

  @override
  String newFolderIn(String folder) {
    return '$folder の中に作成';
  }

  @override
  String get newFolderHint => 'フォルダ名';

  @override
  String get create => '作成';

  @override
  String get move => '移動';

  @override
  String moveTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'MOD $count 個をどこに移動しますか？',
    );
    return '$_temp0';
  }

  @override
  String get moveBody => 'ディスク上でフォルダが変わるだけです。ほかは変わりません（無効のものは無効のまま）。';

  @override
  String get installFolderTitle => 'どのフォルダ？';

  @override
  String installFolderBody(String game) {
    return '$game の Mods フォルダのどこにファイルを置くか。';
  }

  @override
  String get installFolderChoose => '決定';

  @override
  String get installFolderEmpty => 'サブフォルダはまだないよ。作ってもいいし、全部 Mods フォルダのままでもOK。';

  @override
  String get folderEmptySection => 'まだ何もありません';

  @override
  String get install => 'インストール';

  @override
  String filePickerModsLabel(String game) {
    return '『$game』の MOD';
  }

  @override
  String get installWhereTitle => 'どこに入れる？';

  @override
  String installWhereBody(String game) {
    return '$gameはMODを複数のフォルダから読み込むよ。ファイルを見てアプリが判断することもできるし、自分で指定してもいいよ。';
  }

  @override
  String get installWhereSorted => 'おまかせで振り分ける';

  @override
  String get installWhereSortedDesc =>
      'ダウンロードに入っているフォルダをそのまま使って、残りはファイルの種類で振り分けるよ。';

  @override
  String get installWhereRemember => 'もう聞かない';

  @override
  String get destinationSims1Downloads => 'オブジェクト、Hack、それにほとんどのダウンロード。';

  @override
  String get destinationSims1Global => '基本ゲーム全体を書き換えるMOD。';

  @override
  String get destinationSims1Objects => 'ゲーム本体のオブジェクトファイルを差し替えるMOD。';

  @override
  String get destinationSims1Skins => '普段着のスキンと頭。CASに出てくるよ。';

  @override
  String get destinationSims1SkinsBuy => '共有区画のお店で売っている服。';

  @override
  String get destinationSims1Walls => '壁紙。';

  @override
  String get destinationSims1Floors => '床。';

  @override
  String get destinationSims1Roofs => '屋根のテクスチャ。';

  @override
  String get prefAskWhereTitle => 'インストール先を毎回聞く';

  @override
  String get prefAskWhereDesc =>
      'このゲームはMODを複数のフォルダから読み込みます。アプリに任せず、毎回自分でフォルダを選びます';

  @override
  String get statTotal => '合計';

  @override
  String get statEnabled => '有効';

  @override
  String get statDisabled => '無効';

  @override
  String get statConflicts => '競合';

  @override
  String get statTotalTooltip => 'このフォルダにある MOD の数。有効も無効もぜんぶ。';

  @override
  String get statTotalTooltipClear =>
      'このフォルダにある MOD の数。クリックすると検索と絞り込みを全部解除します。';

  @override
  String get statEnabledTooltip => 'ゲームが読み込む MOD。';

  @override
  String get statEnabledTooltipActive => '有効な MOD だけを表示中です。クリックすると全部に戻ります。';

  @override
  String get statDisabledTooltip => 'フォルダには入っているけど切ってある MOD。';

  @override
  String get statDisabledTooltipActive => '無効な MOD だけを表示中です。クリックすると全部に戻ります。';

  @override
  String get conflictTooltipActive => '競合している MOD だけを表示中です。クリックすると全部に戻ります。';

  @override
  String get conflictTooltip =>
      '他の有効な MOD とファイル名が同じ、複数のバージョンが入っている、または同じゲーム内リソースを上書きしている有効な MOD です。ゲームは最後に読み込んだものだけを残します。狙ってやっている場合（パッチ系 MOD）もありますが、たいていは事故です。';

  @override
  String get conflictTooltipClickHint => 'クリックするとこの MOD だけ表示します。';

  @override
  String get filterAll => 'すべて';

  @override
  String get emptyFiltered => '条件に合う MOD がありません';

  @override
  String get emptyNoMods => 'MOD はまだありません';

  @override
  String get emptyFilteredHint => '検索をクリアするか、別のフィルタを選んでみてください。';

  @override
  String emptyNoModsHint(String path) {
    return 'このフォルダを見ています：\n$path';
  }

  @override
  String get openFolder => 'フォルダを開く';

  @override
  String get conflictBadge => '競合';

  @override
  String get duplicateBadge => '重複';

  @override
  String modInFolder(String folder) {
    return '$folder 内';
  }

  @override
  String get modInModsFolder => 'Mods フォルダ内';

  @override
  String setupFoundNoModsFolder(String game) {
    return '『$game』はありますが、MOD フォルダがまだありません';
  }

  @override
  String setupNotFound(String game) {
    return '『$game』の MOD フォルダが見つかりません';
  }

  @override
  String get setupFoundNoModsFolderBody =>
      'ゲームのフォルダはこのパソコンにありますが、中にまだ MOD フォルダがありません。下から作るか、手動で指定してください。';

  @override
  String get setupNotFoundBody =>
      'ゲームが入っていないか、めずらしい場所にあるか、MOD フォルダがまだ作られていないのかもしれません。';

  @override
  String get foundOnThisComputer => 'このパソコンで見つかった場所';

  @override
  String get chooseFolder => 'フォルダを選ぶ…';

  @override
  String get createItForMe => '作ってもらう';

  @override
  String willBeCreatedAt(String path) {
    return 'ここに作成します：\n$path';
  }

  @override
  String get checkAgain => 'もう一度さがす';

  @override
  String get useThis => 'これを使う';

  @override
  String get enabled => '有効';

  @override
  String get disabled => '無効';

  @override
  String get showInFileManager => 'ファイルマネージャーで表示';

  @override
  String get uninstallMod => 'MOD をアンインストール';

  @override
  String uninstallConfirmTitle(String title) {
    return '$title をアンインストールしますか？';
  }

  @override
  String uninstallConfirmBody(String path) {
    return 'このファイルをディスクから削除します：\n$path';
  }

  @override
  String get cancel => 'キャンセル';

  @override
  String get uninstall => 'アンインストール';

  @override
  String conflictSameFileHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '他に $count 個の有効な MOD がまったく同じファイルです：',
    );
    return '$_temp0';
  }

  @override
  String conflictSameNameHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '他に $count 個の有効な MOD が同じファイル名です：',
    );
    return '$_temp0';
  }

  @override
  String conflictVersionHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '他に $count 個の有効な MOD が、この MOD の別バージョンのようです：',
    );
    return '$_temp0';
  }

  @override
  String conflictResourcesHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '他に $count 個の有効な MOD が同じゲーム内リソースを上書きしています：',
    );
    return '$_temp0';
  }

  @override
  String sharedResources(int count) {
    return '共通リソース $count 件';
  }

  @override
  String get conflictSameFileBody =>
      '重複スキャンがこれらのファイルを読んだところ、バイト単位で一致しました。MOD 同士がぶつかっているのではなく、同じダウンロードがフォルダーに何度も入っているだけです。ひとつだけ残して他を削除しても、ゲームの中身は何も変わらず、容量だけ戻ってきます。';

  @override
  String get conflictSameNameBody =>
      'ファイル名がまったく同じなのは、たいてい同じ MOD が二重に入っているか、別々の作者のパッケージがぶつかっているサインです。重なったリソースの読み込み順は予測できないので、ひとつだけ残して他は無効にするか削除してください。';

  @override
  String get conflictVersionBody =>
      '同じ MOD のバージョンが複数入っていると、重なったリソースの読み込み順が予測できません。いちばん新しいものだけ残して、他は無効にするか削除してください。';

  @override
  String get conflictResourcesBody =>
      'これらのパッケージには同じ識別子のリソースが入っているため、ゲームは最後に読み込んだものだけを残します。パッチ系や上書き系の MOD はわざと他の MOD のリソースを隠すので意図的なこともありますが、無関係な MOD 同士だと片方が黙って効かなくなります。使いたいほうを残して、他は無効にしてください。';

  @override
  String get conflictIgnore => '無視';

  @override
  String get conflictIgnoreTooltip =>
      'この競合がわざとなら非表示にできます。Mod は何も変わらず、消えるのは警告だけです。このページか設定からいつでも戻せます。';

  @override
  String get conflictRestore => '戻す';

  @override
  String advisoryBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'MOD が $count 個、既知の問題を抱えています',
    );
    return '$_temp0';
  }

  @override
  String get advisoryShow => '見てみる';

  @override
  String get advisoryShowAll => 'すべての MOD を表示';

  @override
  String get advisoryBadge => '問題';

  @override
  String get advisoryBrokenHeading => 'この MOD は壊れていると報告されています';

  @override
  String get advisoryBrokenBody =>
      'この MOD でゲームが動かなくなるという報告が出ています。原因かどうかを確かめるには、まず無効にしてみるのが一番早いです。';

  @override
  String get advisoryOutdatedHeading => 'この MOD には新しいバージョンがあります';

  @override
  String get advisoryOutdatedBody =>
      '入っているのは、まさに問題が報告されているバージョンです。作者さんの最新版を入れ直せば直るはずです。';

  @override
  String get advisoryCautionHeading => '様子を見ておきたい MOD です';

  @override
  String get advisoryCautionBody =>
      'ほとんどの人は問題なく使えていますが、たまに調子を崩すことで知られています。不具合を探しているなら、無効にしてみる価値はあります。';

  @override
  String advisorySince(String since) {
    return '$since から';
  }

  @override
  String get advisoryOpenLink => '作者のページを開く';

  @override
  String get advisorySource => 'ゲームではなく、他のプレイヤーからの報告です。';

  @override
  String modInDirectory(String dir) {
    return '$dir 内';
  }

  @override
  String get factVersion => 'バージョン';

  @override
  String get factFormat => '形式';

  @override
  String get factSize => 'サイズ';

  @override
  String get factType => '種類';

  @override
  String get factModified => '更新日';

  @override
  String get factDownloads => 'ダウンロード数';

  @override
  String get factIgnoredConflicts => '無視中';

  @override
  String ignoredConflictsCount(int count) {
    return '競合 $count 件';
  }

  @override
  String get statusHeading => '状態';

  @override
  String get statusEnabledBody => 'この MOD は有効です。次にゲームを起動したときに読み込まれます。';

  @override
  String statusDisabledBody(String marker) {
    return 'この MOD は無効です。ファイルは「$marker」の目印を付けたままディスクに残るので、ゲームは読み飛ばします。いつでも有効に戻せますし、何も消えていません。';
  }

  @override
  String get fileOnDisk => 'ディスク上のファイル';

  @override
  String get insideThePackage => 'パッケージの中身';

  @override
  String resourcesTotal(int count) {
    return 'リソース合計 $count 件';
  }

  @override
  String get settingsTitle => '設定';

  @override
  String get sectionModManagement => 'MOD の管理';

  @override
  String get sectionAppearance => '外観';

  @override
  String get sectionLanguage => '言語';

  @override
  String get sectionPrivacy => 'プライバシー';

  @override
  String sectionModsFolder(String game) {
    return 'MOD フォルダ · $game';
  }

  @override
  String sectionGameCaches(String game) {
    return 'ゲームのキャッシュ · $game';
  }

  @override
  String sectionIgnoredConflicts(String game) {
    return '無視した競合 · $game';
  }

  @override
  String sectionShopFolder(String game) {
    return 'THE EXCHANGE · $game';
  }

  @override
  String get prefShopFolderTitle => 'The Exchange の Mod の入れ先';

  @override
  String prefShopFolderDesc(String folder) {
    return 'インストールは $folder に入るよ';
  }

  @override
  String get sectionFeedback => 'フィードバック';

  @override
  String get sectionAbout => 'このアプリについて';

  @override
  String get prefWarnConflictsTitle => '競合を知らせる';

  @override
  String get prefWarnConflictsDesc =>
      'ファイル名が重なっている、または他の MOD と同じゲーム内リソースを上書きしている有効な MOD に印を付けます';

  @override
  String get prefConfirmDeleteTitle => 'アンインストール前に確認';

  @override
  String get prefConfirmDeleteDesc => 'MOD ファイルをディスクから消す前に確認します';

  @override
  String get prefShowDisabledTitle => '無効な MOD も表示';

  @override
  String get prefShowDisabledDesc => '無効にした MOD を隠さず、ライブラリに残して表示します';

  @override
  String get prefDisabledSuffixTitle => '無効化マーカー';

  @override
  String get prefDisabledSuffixDesc =>
      'MOD をオフにしたときにファイル名の末尾へ付く文字列です。ほかのマネージャーに合わせて変更できます（CC Magic は .off）。どちらの書き方もアプリは読み取れますし、すでに無効にした MOD は今の名前のままです';

  @override
  String get prefDisabledSuffixInvalid => 'ドットのあとに英数字を数文字、たとえば .off のように入力してね';

  @override
  String get prefExperimentalPacksTitle => '実験的なパックスイッチ';

  @override
  String get prefExperimentalPacksDesc =>
      'このゲームのパックをオフにできるようにする。この版では未検証で、あるパックで遊んだ近所はそれなしだと壊れることがある - 先にセーブのバックアップを';

  @override
  String get prefScanArtworkTitle => 'MOD の中身をスキャン';

  @override
  String get prefScanArtworkDesc =>
      'ライブラリの読み込み中に MOD ファイルの中を見て、埋め込まれた画像や中身の内訳、同じリソースを上書きする MOD を調べます';

  @override
  String get prefSoundEffectsTitle => 'UI サウンド';

  @override
  String get prefSoundEffectsDesc =>
      'クリックや切り替え、お知らせのときに、シムズおなじみの UI サウンドを鳴らします';

  @override
  String get prefAnalyticsTitle => '匿名の利用データを送る';

  @override
  String get prefAnalyticsDesc =>
      'アプリを良くするために、匿名の利用統計とクラッシュレポートを送ります。MOD 名やファイルパス、個人に関わるものは一切含みません';

  @override
  String get themeTitle => 'テーマ';

  @override
  String get themeDesc => 'ライトかダークか。「システム」はパソコンの設定に合わせます。';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get languageTitle => 'アプリの言語';

  @override
  String get languageDesc => 'アプリを表示する言語を選べます。「システム」はパソコンの言語に合わせます。';

  @override
  String get languageSystem => 'システム';

  @override
  String get translatorsTitle => '翻訳';

  @override
  String get translatorsDesc => 'アプリが12か国語で使えるのは、訳してくれたシマーたちのおかげです。';

  @override
  String get sectionStartup => '起動';

  @override
  String get prefDefaultGameTitle => '起動時のゲーム';

  @override
  String get prefDefaultGameDesc => 'アプリを開いたときに表示するライブラリ';

  @override
  String get defaultGameAuto => '自動';

  @override
  String get prefSetupGuideTitle => 'セットアップガイド';

  @override
  String get prefSetupGuideDesc => '初回起動の質問をもう一度確認する';

  @override
  String get onboardingReplay => 'もう一度見る';

  @override
  String get onboardingSkip => 'スキップ';

  @override
  String get onboardingSkipIntro => 'イントロをスキップ';

  @override
  String get onboardingBack => '戻る';

  @override
  String get onboardingNext => '次へ';

  @override
  String get onboardingFinish => 'ライブラリを開く';

  @override
  String onboardingStepOf(int current, int total) {
    return 'ステップ $current/$total';
  }

  @override
  String get onboardingWelcomeTitle => 'ようこそ！さっそく準備しよう';

  @override
  String get onboardingWelcomeBody =>
      'いくつか質問に答えるだけでMODの準備は完了。1分もかからないし、ここで選んだことは後から設定で変えられるよ。';

  @override
  String get onboardingGamesTitle => 'ゲームを探しています';

  @override
  String get onboardingGamesBody => 'それぞれのゲームと、MODを読み込むフォルダーをいつもの場所から探しているところ。';

  @override
  String get onboardingScanning => 'まだ探しています…';

  @override
  String onboardingGamesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count本のゲームが見つかりました',
      zero: 'まだ見つかっていません',
    );
    return '$_temp0';
  }

  @override
  String onboardingGameMods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'MODが$count件インストール済み',
      zero: 'MODフォルダーの準備ができています',
    );
    return '$_temp0';
  }

  @override
  String get onboardingGameMissing => 'このパソコンにはありません';

  @override
  String get onboardingNoGamesTitle => '何も見つかりませんでした';

  @override
  String get onboardingNoGamesBody =>
      '大丈夫。設定からMODフォルダーを自分で指定すれば、あとはまったく同じように使えるよ。';

  @override
  String get onboardingFavoriteTitle => 'いちばん遊ぶのはどれ？';

  @override
  String get onboardingFavoriteBody =>
      'アプリは毎回このゲームで開くようになるよ。サイドバーからいつでも切り替えられる。';

  @override
  String get onboardingLookTitle => '自分好みにしよう';

  @override
  String get onboardingLookBody => 'アプリ全体が、いま開いているゲームの色に染まるよ。見た目と音の好みを選んでね。';

  @override
  String get onboardingLibraryTitle => 'ライブラリの見え方';

  @override
  String get onboardingLibraryBody => 'いま決めておきたいのはこの2つ。ライブラリに何が表示されるかが変わるから。';

  @override
  String get onboardingDoneTitle => '準備完了！';

  @override
  String get onboardingDoneBody =>
      'ライブラリはもう読み込み済み。MODファイルをウィンドウにドロップすればインストールできるし、ここで選んだことは設定でいつでも変えられるよ。';

  @override
  String get folderNotFound => '見つかりません。フォルダを選んでください';

  @override
  String get folderNotLocated => 'ゲーム（またはその MOD フォルダ）を自動で見つけられませんでした';

  @override
  String folderSummary(int count, String size) {
    return 'MOD $count 個 · ディスク上 $size';
  }

  @override
  String get customFolder => 'カスタムフォルダ';

  @override
  String get change => '変更…';

  @override
  String get resetToAuto => '自動に戻す';

  @override
  String createDefaultFolderAt(String path) {
    return '既定のフォルダ（ゲームに必要なファイル入り）をここに作成：\n$path';
  }

  @override
  String get createFolder => 'フォルダを作成';

  @override
  String get alsoFoundOnThisComputer => 'このパソコンには他にも：';

  @override
  String get clearCacheTitle => 'キャッシュファイルを削除';

  @override
  String clearCacheDesc(int count, String size) {
    return 'キャッシュファイル $count 個（$size）を削除して、追加や削除した内容がちゃんと出るようにします。ゲームは次の起動時に作り直します';
  }

  @override
  String get clearCaches => 'キャッシュを削除';

  @override
  String get ignoredConflictsTitle => '無視している競合';

  @override
  String ignoredConflictsDesc(int count) {
    return 'アプリに知らせなくていいと伝えた競合が $count 件あります。戻すとライブラリにまた出てきます';
  }

  @override
  String get ignoredConflictsReset => '全部戻す';

  @override
  String get reportBugTitle => '不具合を報告';

  @override
  String get reportBugDesc =>
      'GitHub に不具合の報告を開きます。アプリのバージョン・OS・いま選んでいるゲームは入力済みです';

  @override
  String get reportBugButton => '報告する…';

  @override
  String get suggestFeatureTitle => '機能をリクエスト';

  @override
  String get suggestFeatureDesc => '足りないものがありますか？どうすればもっと使いやすくなるか教えてください';

  @override
  String get suggestFeatureButton => 'リクエスト…';

  @override
  String get wikiTitle => '使い方と FAQ';

  @override
  String get wikiDesc => 'MOD の入れ方、フォルダ検出がうまくいかないときの直し方などをプロジェクトの wiki で';

  @override
  String get wikiButton => 'wiki を開く';

  @override
  String aboutTagline(String version) {
    return 'バージョン $version · The Sims 1-4 に対応 · シムシティも近日対応';
  }

  @override
  String updateIsAvailable(String version) {
    return 'バージョン $version が出ています';
  }

  @override
  String get noUpdateFound => 'アップデートはありません';

  @override
  String getVersion(String version) {
    return 'v$version を入手';
  }

  @override
  String get checkingForUpdates => '確認中…';

  @override
  String get checkForUpdates => 'アップデートを確認';

  @override
  String get categoryPackage => 'パッケージ';

  @override
  String get categoryScript => 'スクリプト';

  @override
  String get categoryObject => 'オブジェクト';

  @override
  String get categoryArchive => 'アーカイブ';

  @override
  String get categorySkin => 'スキン';

  @override
  String get categoryTexture => 'テクスチャ';

  @override
  String get categoryWall => '壁';

  @override
  String get categoryFloor => '床';

  @override
  String get contentCasParts => 'CAS パーツ';

  @override
  String get contentObjects => 'オブジェクト';

  @override
  String get contentTunings => 'チューニング';

  @override
  String get contentBehaviors => 'ビヘイビア';

  @override
  String get contentTextTables => 'テキストテーブル';

  @override
  String get contentTextures => 'テクスチャ';

  @override
  String get contentMeshes => 'メッシュ';

  @override
  String get modKindCas => 'CAS';

  @override
  String get modKindBuildBuy => '建設・購入';

  @override
  String get modKindGameplay => 'ゲームプレイ';

  @override
  String get modKindScript => 'スクリプト';

  @override
  String errorNoModFiles(String extensions, String name) {
    return '$name の中にMODファイル（$extensions）が見つかりませんでした。';
  }

  @override
  String errorUnreadableArchive(String name) {
    return '$name はこのアプリで読めるアーカイブではありません。';
  }

  @override
  String errorNoUnpacker(String format, String name) {
    return 'このパソコンには$formatアーカイブを展開できるものがありません。$name を自分で展開して、中のファイルをインストールしてね。';
  }

  @override
  String errorNoUnpackerLinux(String format, String name) {
    return 'このパソコンには$formatアーカイブを展開できるものがありません。p7zip をインストールしてもう一度試すか、$name を自分で展開して中のファイルをインストールしてね。';
  }

  @override
  String errorNoUnpackerLinuxRar(String format, String name) {
    return 'このパソコンには$formatアーカイブを展開できるものがありません。p7zip か unrar をインストールしてもう一度試すか、$name を自分で展開して中のファイルをインストールしてね。';
  }

  @override
  String errorUnpackFailed(String name) {
    return '$name を展開できませんでした。パスワード付き、分割アーカイブの一部、またはダウンロードが壊れているのかもしれません。手動で展開して、中のファイルをインストールしてね。';
  }

  @override
  String errorSims3PackUnreadable(String name) {
    return '$name はこのアプリが読める The Sims 3 のパッケージじゃないみたい。';
  }

  @override
  String errorSims3PackWorld(String name) {
    return '$name はワールドで、カスタムコンテンツじゃないよ。The Sims 3 ランチャーからインストールしてね。ワールドは Mods フォルダの外に置かれるんだ。';
  }

  @override
  String errorSims3PackLibrary(String name) {
    return '$name は区画か世帯で、カスタムコンテンツじゃないよ。The Sims 3 ランチャーからインストールしてね。ゲーム内のライブラリに入るよ。';
  }

  @override
  String errorInstallFailed(String name, String reason) {
    return '「$name」をインストールできませんでした。$reason。うまくいかないままなら、手動で展開して中のファイルをインストールしてね。';
  }

  @override
  String errorInstallFailedRaw(String name, String reason) {
    return '「$name」をインストールできませんでした。$reason';
  }

  @override
  String errorFileInUseDelete(String name) {
    return '「$name」を削除できませんでした。別のプログラムが使用中（ゲームは起動中？）か、書き込み禁止になっています。使っているものを閉じて、もう一度試してね。';
  }

  @override
  String errorFileInUseRename(String name) {
    return '「$name」の名前を変更できませんでした。別のプログラムが使用中（ゲームは起動中？）か、書き込み禁止になっています。使っているものを閉じて、もう一度試してね。';
  }

  @override
  String errorFileNameTaken(String name) {
    return 'そのフォルダには「$name」がすでにあります。どちらかの名前を変えてからもう一度どうぞ。';
  }

  @override
  String errorFolderNameBad(String name) {
    return '「$name」はフォルダ名に使えません。スラッシュやシステムの予約文字を含まない名前にしてください。';
  }

  @override
  String errorFolderTooDeep(int levels) {
    return 'ゲームは MOD フォルダの $levels 階層下までしか読み込みません。それより深い場所に置いても読み込まれません。';
  }

  @override
  String errorBulkMoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'MOD $count 個を移動できませんでした。他のプログラムが使用中（ゲームは起動していませんか？）か、書き込み禁止か、移動先に同じ名前のファイルがあるのかもしれません。',
    );
    return '$_temp0';
  }

  @override
  String errorBulkToggleFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'MOD $count 個を切り替えられませんでした。他のプログラムが使用中（ゲームは起動していませんか？）か、書き込み禁止になっているかもしれません。',
    );
    return '$_temp0';
  }

  @override
  String errorBulkRemoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'MOD $count 個を削除できませんでした。他のプログラムが使用中（ゲームは起動していませんか？）か、書き込み禁止になっているかもしれません。',
    );
    return '$_temp0';
  }

  @override
  String errorFileMissing(String name) {
    return '「$name」はもうMODフォルダーにありません。別のプログラムが移動したか削除したのかもしれません。';
  }

  @override
  String get requirementMedievalModLoader =>
      'The Sims Medieval は、コミュニティ製のローダーファイルがゲームの Game\\Bin フォルダーにないと、スクリプトMODやコアMODを動かせません。カスタムコンテンツは動きますが、それ以外は動きません。';

  @override
  String get requirementSims4ModsOff =>
      'ゲーム側の「ゲームオプション」でカスタムコンテンツとMODがオフになっているので、どれも読み込まれていません。オプション → ゲームオプション → その他 でオンに戻して、ゲームを再起動してください。';

  @override
  String get requirementSims4ScriptModsOff =>
      'ここにスクリプトMODがありますが、ゲーム側の「ゲームオプション」で「スクリプトMODを許可」がオフです。ゲームのアップデートでリセットされます。';

  @override
  String get requirementGetFile => '入手先';

  @override
  String tooDeepBanner(int count, int levels) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count個のMOD',
    );
    return '$_temp0が、ゲームの読まないサブフォルダーに入っています。MODフォルダーの中は$levels階層までしか見てくれません。上の階層に移せば読み込まれます。';
  }

  @override
  String get tooDeepShow => 'どれか見る';

  @override
  String get duplicatesFind => '重複したMODを探す';

  @override
  String duplicatesScanning(int done, int total) {
    return '重複しているかもしれないMODを読んでるよ… $done / $total';
  }

  @override
  String get duplicatesStop => '中止';

  @override
  String duplicatesBanner(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count個のMOD',
    );
    return '$_temp0が、別のMODとまったく同じファイルだよ。$size分を取り戻せる。';
  }

  @override
  String get duplicatesShow => 'どれか見る';

  @override
  String get duplicatesSelectExtras => '余分なコピーにチェック';

  @override
  String get duplicatesClean => 'ここには重複したMODはないよ。';

  @override
  String get duplicatesDismiss => '了解';

  @override
  String tagTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count個のMODのタグ',
    );
    return '$_temp0';
  }

  @override
  String get tagBody => 'あとで探すための、自分だけのタグだよ。タップで付けたり外したりできる。';

  @override
  String get tagHint => '新しいタグ';

  @override
  String get tagAdd => '追加';

  @override
  String get tagDone => '完了';

  @override
  String get tagHeading => 'タグ';

  @override
  String get tagAddFirst => 'タグを付ける';

  @override
  String tagRemove(String tag) {
    return '「$tag」を外す';
  }

  @override
  String get selectionTag => 'タグを付ける…';

  @override
  String folderAlsoReading(String folders) {
    return 'ゲームは $folders も読み込むから、そこに入ってるMODもこのライブラリーに出てくるよ。';
  }

  @override
  String errorFolderUnreadable(String folder) {
    return '「$folder」を開けませんでした。このパソコンから見えるドライブのフォルダーを選んでください。スマホやカメラ、切断されたネットワークドライブにはMODを置けません。';
  }

  @override
  String errorNoWriteAccess(String folder) {
    return 'アプリに「$folder」への書き込み権限がありません。このフォルダーはシステムに保護されています。アカウントに書き込み権限を付けるか、設定で別のフォルダーを選んでください。';
  }

  @override
  String get folderReadOnlyBanner =>
      'このMODフォルダーは読み取り専用なので、アカウントが書き込めるようになるまでMODのインストールと削除はできません。';

  @override
  String get elevatedNoDropBanner =>
      '管理者として実行しているので、Windows がウィンドウへのファイルのドラッグをブロックしてるよ。かわりにインストールボタンを使ってね。そっちは普通に使えるよ。';

  @override
  String errorShopDownload(String name) {
    return '「$name」をThe Exchangeからダウンロードできませんでした。接続を確認して、もう一度試してみてください。';
  }

  @override
  String errorShopNoModFiles(String name) {
    return '「$name」の中に、このゲームがインストールできるものが入ってないみたい。MODじゃないのかも。ダウンロードを使えば好きな場所にファイルを保存できるよ。';
  }

  @override
  String get errorShopListingNotFound =>
      'このMODはもう The Exchange にないみたい。取り下げられたのかも。';

  @override
  String get errorShopListingUnknownGame =>
      'このMODは、今のバージョンのアプリがまだ知らないゲーム向けだよ。アップデートしてみて。';

  @override
  String errorPackToggleFailed(String pack) {
    return '$pack を切り替えられなかったよ。ゲームを閉じてもう一度試してみて。';
  }

  @override
  String get errorPackNoUserData =>
      'ゲーム自身の設定フォルダが見つからないから、どのパックを飛ばすか書き込む場所がないんだ。先にゲームを一度起動してみて。';

  @override
  String get errorPackNeedsAdmin =>
      'Windows がアプリにその変更を許可しなかったよ。管理者として起動し直してもう一度試してみて。';

  @override
  String get errorPackNotSupported => 'このシステムではパックのオンオフはできないんだ。';

  @override
  String get errorPackIsTheGame => 'それはゲームの起動元になっているパックだから、オンのままにしておく必要があるよ。';

  @override
  String get errorPackToggleRefused => 'そのパックを変えられなかったよ。ゲームを閉じてもう一度試してみて。';

  @override
  String get eraClassic => 'クラシック';

  @override
  String get eraNightlife => 'ナイトライフ';

  @override
  String get eraAmbitions => 'アンビションズ';

  @override
  String get eraModern => 'モダン';

  @override
  String get eraMedieval => '中世';

  @override
  String get navPacks => 'パック';

  @override
  String get packsScanning => 'パックを探しています…';

  @override
  String get packsEmptyTitle => 'パックが見つかりません';

  @override
  String packsEmptyBody(String game) {
    return '$game がアプリから見える場所にインストールされていないか、まだ隣にパックが入っていないみたい。';
  }

  @override
  String get packsRescan => 'もう一度調べる';

  @override
  String packsSummary(int count) {
    return '$count 個のパックがインストール済み';
  }

  @override
  String packsSummaryWithOff(int count, int off) {
    return '$count 個がオン、$off 個がオフ';
  }

  @override
  String get packsOff => 'オフ';

  @override
  String get packsInstalled => 'インストール済み';

  @override
  String get packsNeedAdmin =>
      'このパックのオンオフには管理者権限が必要なんだ。ゲームがそこに一覧を持っているからだよ。変えるにはアプリを管理者として起動し直してね - その間はドラッグ＆ドロップが使えなくなるから、終わったら戻すのがおすすめ。';

  @override
  String get packsExperimentalTitle => 'オフにするのは実験的な機能だよ';

  @override
  String get packsExperimentalOff =>
      'このゲームで昔から使われてきたやり方と同じだけど、この版で試した人はいないんだ。あるパックで遊んだ近所は、それなしで開くと壊れることがあるよ。見るだけなら安全。それでも試したいなら、設定で実験的なパックスイッチをオンにしてね。';

  @override
  String get packsExperimentalOn =>
      '先に近所のバックアップを取ってね。あるパックで遊んだ近所は、それなしで開くと壊れることがあって、ここからは元に戻せないんだ。パックをオンに戻しても、セーブが必ず戻るとは限らないよ。';

  @override
  String packsRestartNotice(String game) {
    return '$game を再起動すると反映されるよ。パック自体はそのまま残るから安心して。';
  }

  @override
  String packsAllOwnedSims4(String expansions, String gamePacks) {
    return '拡張パック$expansions個、ゲームパック$gamePacks個。全部ちゃんと買ったんだよね。';
  }

  @override
  String get packKindExpansions => '拡張パック';

  @override
  String get packKindGamePacks => 'ゲームパック';

  @override
  String get packKindStuffPacks => 'アイテムパック';

  @override
  String get packKindKits => 'キット';

  @override
  String get packKindFreePacks => '無料パック';

  @override
  String get navSaves => 'セーブ';

  @override
  String get savesScanning => 'セーブデータを読み込み中…';

  @override
  String get savesEmptyTitle => 'セーブデータが見つかりません';

  @override
  String savesEmptyBody(String game) {
    return '$gameをプレイしてセーブすると、家族や写真などワールドの情報がここに表示されます。';
  }

  @override
  String get savesRescan => '再スキャン';

  @override
  String savesCount(int count) {
    return 'セーブデータ $count 件';
  }

  @override
  String savesLastSaved(String date) {
    return '最終セーブ: $date';
  }

  @override
  String get savesShowInFolder => 'フォルダで表示';

  @override
  String savesBackups(int count) {
    return 'バックアップ $count 件';
  }

  @override
  String get savesTabHouseholds => '世帯';

  @override
  String get savesTabAlbum => 'フォトアルバム';

  @override
  String get savesTabStats => 'ワールド統計';

  @override
  String savesNeighborhood(int number) {
    return '近隣地域 $number';
  }

  @override
  String get savesOtherHouseholds => 'NPCとその他の世帯';

  @override
  String savesSimCount(int count) {
    return 'シム $count 人';
  }

  @override
  String get savesFunds => '資金';

  @override
  String get savesRooms => '部屋';

  @override
  String savesBedsBaths(int beds, int baths) {
    return '寝室$beds · 浴室$baths';
  }

  @override
  String savesByCreator(String name) {
    return '作成者: $name';
  }

  @override
  String get savesMembers => 'メンバー';

  @override
  String get savesRelationships => '人間関係';

  @override
  String get savesUnknownSim => '不明なシム';

  @override
  String get savesStatSims => 'シム';

  @override
  String get savesStatHouseholds => '世帯';

  @override
  String get savesStatNetWorth => '総資産';

  @override
  String get savesStatWorlds => 'ワールド';

  @override
  String get savesStatPhotos => '写真';

  @override
  String savesAcrossHouseholds(int count) {
    return '$count 世帯';
  }

  @override
  String savesPlayedCount(int count) {
    return 'プレイ中 $count';
  }

  @override
  String get savesSizeOnDisk => 'ディスク使用量';

  @override
  String get savesLifeStages => 'ライフステージ';

  @override
  String get savesTopSkills => 'このセーブの最高スキル';

  @override
  String get savesSaveInfo => 'セーブファイル';

  @override
  String get savesLastSavedLabel => '最終セーブ';

  @override
  String get savesGameVersion => 'ゲームバージョン';

  @override
  String get savesDescription => '説明';

  @override
  String get savesAgeInfant => '乳児';

  @override
  String get savesAgeBaby => '赤ちゃん';

  @override
  String get savesAgeToddler => '幼児';

  @override
  String get savesAgeChild => '子供';

  @override
  String get savesAgeTeen => 'ティーン';

  @override
  String get savesAgeYoungAdult => 'ヤングアダルト';

  @override
  String get savesAgeAdult => '大人';

  @override
  String get savesAgeElder => 'シニア';

  @override
  String get savesGenderMale => '男性';

  @override
  String get savesGenderFemale => '女性';

  @override
  String get savesSkillCooking => '料理';

  @override
  String get savesSkillMechanical => '修理';

  @override
  String get savesSkillCharisma => 'カリスマ';

  @override
  String get savesSkillBody => '身体';

  @override
  String get savesSkillLogic => '論理';

  @override
  String get savesSkillCreativity => '創造力';

  @override
  String get savesSkillCleaning => '掃除';

  @override
  String get savesPersonalityNeat => 'きれい好き';

  @override
  String get savesPersonalityOutgoing => '社交的';

  @override
  String get savesPersonalityActive => '活発';

  @override
  String get savesPersonalityPlayful => '遊び好き';

  @override
  String get savesPersonalityNice => '優しい';

  @override
  String get savesZodiacAries => 'おひつじ座';

  @override
  String get savesZodiacTaurus => 'おうし座';

  @override
  String get savesZodiacGemini => 'ふたご座';

  @override
  String get savesZodiacCancer => 'かに座';

  @override
  String get savesZodiacLeo => 'しし座';

  @override
  String get savesZodiacVirgo => 'おとめ座';

  @override
  String get savesZodiacLibra => 'てんびん座';

  @override
  String get savesZodiacScorpio => 'さそり座';

  @override
  String get savesZodiacSagittarius => 'いて座';

  @override
  String get savesZodiacCapricorn => 'やぎ座';

  @override
  String get savesZodiacAquarius => 'みずがめ座';

  @override
  String get savesZodiacPisces => 'うお座';

  @override
  String get savesAspirationRomance => 'ロマンス';

  @override
  String get savesAspirationFamily => '家族';

  @override
  String get savesAspirationFortune => '富';

  @override
  String get savesAspirationPopularity => '人気';

  @override
  String get savesAspirationKnowledge => '知識';

  @override
  String get savesAspirationGrowUp => '成長';

  @override
  String get savesAspirationPleasure => '快楽';

  @override
  String get savesAspirationGrilledCheese => 'グリルチーズ';

  @override
  String get savesRelCrush => '片思い';

  @override
  String get savesRelLove => '恋人';

  @override
  String get savesRelEngaged => '婚約中';

  @override
  String get savesRelMarried => '結婚';

  @override
  String get savesRelFriends => '友達';

  @override
  String get savesRelBestFriends => '親友';

  @override
  String get savesRelSteady => '交際中';

  @override
  String get savesRelEnemies => '敵';

  @override
  String get savesPhotoFamilyPortrait => '家族写真';

  @override
  String get savesPhotoLot => '区画';

  @override
  String get savesPhotoSim => 'シムのポートレート';

  @override
  String get savesPhotoSnapshot => 'スナップショット';

  @override
  String get savesProperty => '資産';

  @override
  String get savesGhost => 'ゴースト';

  @override
  String savesCareerLevel(String career, int level) {
    return '$career · レベル$level';
  }

  @override
  String get savesSpeciesLargeDog => '犬';

  @override
  String get savesSpeciesSmallDog => '小型犬';

  @override
  String get savesSpeciesCat => '猫';

  @override
  String get savesOccultVampire => 'ヴァンパイア';

  @override
  String get savesOccultZombie => 'ゾンビ';

  @override
  String get savesOccultWerewolf => '人狼';

  @override
  String get savesOccultPlantSim => 'プラントシム';

  @override
  String get savesOccultAlien => 'エイリアン';

  @override
  String get savesOccultServo => 'サーボ';

  @override
  String get savesOccultWitch => '魔女';

  @override
  String get savesOccultBigfoot => 'ビッグフット';

  @override
  String get savesOccultFairy => 'フェアリー';

  @override
  String get savesOccultGenie => 'ジーニー';

  @override
  String get savesOccultMermaid => 'マーメイド';

  @override
  String get savesLotResidential => '住宅区画';

  @override
  String get savesLotCommunity => '公共区画';

  @override
  String get savesLotDorm => '寮';

  @override
  String get savesLotSecretSociety => '秘密結社';

  @override
  String get savesLotGreekHouse => '学生寮';

  @override
  String get savesLotHotel => 'ホテル';

  @override
  String get savesLotSecret => '隠し区画';

  @override
  String get savesLotBusiness => '店舗';

  @override
  String get savesLotApartment => 'アパート';

  @override
  String savesGpa(String gpa) {
    return 'GPA $gpa';
  }

  @override
  String savesSemester(int number) {
    return '$number学期';
  }

  @override
  String savesPredestinedHobby(String hobby) {
    return '天職は$hobby';
  }

  @override
  String get savesHobbyCuisine => '料理';

  @override
  String get savesHobbyArts => 'アート＆クラフト';

  @override
  String get savesHobbyFilm => '映画と文学';

  @override
  String get savesHobbySports => 'スポーツ';

  @override
  String get savesHobbyGames => 'ゲーム';

  @override
  String get savesHobbyNature => '自然';

  @override
  String get savesHobbyTinkering => '工作';

  @override
  String get savesHobbyFitness => 'フィットネス';

  @override
  String get savesHobbyScience => '科学';

  @override
  String get savesHobbyMusic => '音楽とダンス';

  @override
  String get savesTieMother => '母';

  @override
  String get savesTieFather => '父';

  @override
  String get savesTieSpouse => '配偶者';

  @override
  String savesTieSibling(int count) {
    return '兄弟姉妹';
  }

  @override
  String savesTieChild(int count) {
    return '子ども';
  }

  @override
  String get savesInterestPolitics => '政治';

  @override
  String get savesInterestMoney => 'お金';

  @override
  String get savesInterestEnvironment => '環境';

  @override
  String get savesInterestCrime => '犯罪';

  @override
  String get savesInterestEntertainment => '娯楽';

  @override
  String get savesInterestCulture => '文化';

  @override
  String get savesInterestFood => '料理';

  @override
  String get savesInterestHealth => '健康';

  @override
  String get savesInterestFashion => 'ファッション';

  @override
  String get savesInterestSports => 'スポーツ';

  @override
  String get savesInterestParanormal => '超常現象';

  @override
  String get savesInterestTravel => '旅行';

  @override
  String get savesInterestWork => '仕事';

  @override
  String get savesInterestWeather => '天気';

  @override
  String get savesInterestAnimals => '動物';

  @override
  String get savesInterestSchool => '学校';

  @override
  String get savesInterestToys => 'おもちゃ';

  @override
  String get savesInterestSciFi => 'SF';

  @override
  String get savesInterestMusic => '音楽';

  @override
  String get savesInterestOutdoors => 'アウトドア';

  @override
  String get setupHelpSims1 =>
      '初代 The Sims はカスタムコンテンツをドキュメントではなくインストールフォルダに置きます。オブジェクトはゲームの実行ファイルの隣にある Downloads フォルダへ（例：C:\\Program Files (x86)\\Maxis\\The Sims\\Downloads）。それ以外の種類はこのアプリが自動で振り分けます。スキン（.skn/.cmx/.bmp）は GameData\\Skins へ、壁と床は GameData\\Walls と GameData\\Floors へ。2025 年の Legacy Collection も同じで、それぞれのインストールフォルダを使います（EA Games\\The Sims Legacy、または Steam\\steamapps\\common\\The Sims Legacy Collection）。別の場所（別ドライブ、独自の Steam ライブラリ）に入れている場合は、その Downloads フォルダを手動で選んでください。';

  @override
  String get setupHelpSims2 =>
      'The Sims 2 はカスタムコンテンツを「ドキュメント > EA Games > The Sims 2 > Downloads」から読み込みます（Ultimate Collection は「The Sims 2 Ultimate Collection」、2025 年の Legacy Collection は「The Sims 2 Legacy」）。自分で作るか、一度コンテンツを入れるまでフォルダが無いこともあります。ゲームを起動したら、カスタムコンテンツの確認に「はい」と答えるとダウンロードが有効になります。';

  @override
  String get setupHelpSims3 =>
      'The Sims 3 は MOD フォルダを自分では作りません。コミュニティ製の「フレームワーク」、つまり「ドキュメント > Electronic Arts > The Sims 3」の中の Mods > Packages フォルダと、それを読むようゲームに伝える Resource.cfg が必要です。どちらもこのアプリが作れます。ディスク版や Wine 環境ではフォルダがゲームのパッケージ内にあることもあるので、その場合は「フォルダを選ぶ」で指定してください。';

  @override
  String get setupHelpSims4 =>
      'The Sims 4 は「ドキュメント > Electronic Arts > The Sims 4 > Mods」から MOD を読み込みます。このフォルダは初回起動時にゲームが作るので、無ければ一度ゲームを起動してください。そのあとゲーム内で オプション > ゲームオプション > その他 >「カスタムコンテンツとMODを有効にする」（.ts4script ファイルには「スクリプトMODを許可」も）をオンにして、ゲームを再起動します。';

  @override
  String get setupHelpSimsMedieval =>
      'The Sims Medieval はドキュメントではなくインストールフォルダから MOD を読み込みます。ゲームファイルの隣に Mods > Packages フォルダ（例：C:\\Program Files (x86)\\Origin Games\\The Sims Medieval）と、それを読むようゲームに伝える Resource.cfg をインストールフォルダに置きます。どちらもこのアプリが作れます（Program Files の下では Windows が管理者権限を求めることがあります）。「ドキュメント > Electronic Arts > The Sims Medieval」にはセーブしか入っておらず、そこに MOD を置いても何も起きません。Wine/CrossOver や独自の Steam ライブラリの場合は、「フォルダを選ぶ」でインストール先の Mods > Packages を指定してください。';

  @override
  String get prefSubfoldersTitle => 'フォルダにサブフォルダを含める';

  @override
  String get prefSubfoldersDesc =>
      'フォルダの中身もまとめて表示します。オフにすると cc と cc/defaults は別々の棚になります。';

  @override
  String deleteFolderTitle(String folder) {
    return '$folder を削除しますか？';
  }

  @override
  String get deleteFolderBody => 'このフォルダと中身は、サブフォルダごとすべて消えます。元には戻せません。';

  @override
  String deleteFolderMods(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個の MOD が削除されます',
    );
    return '$_temp0';
  }

  @override
  String get deleteFolderEmpty => 'MOD は入っていません。';

  @override
  String get deleteFolder => 'フォルダを削除';

  @override
  String triviaTitle(String game) {
    return 'プラムボブ豆知識 · $game';
  }

  @override
  String get triviaContextLibrary => 'Mod を眺めているみたいだね';

  @override
  String get triviaContextSaves => 'セーブデータを見ているみたいだね';

  @override
  String get triviaContextPacks => 'パックを整理しているみたいだね';

  @override
  String triviaCounter(int index, int total) {
    return '$total 件中 $index 件目';
  }

  @override
  String get triviaOpen => 'プラムボブに聞く';

  @override
  String get triviaClose => '今はいい';

  @override
  String get triviaPrevious => '前の豆知識';

  @override
  String get triviaNext => '次の豆知識';

  @override
  String get triviaAnother => 'もう一つ';

  @override
  String get triviaToSettings => 'もう十分？ 設定からプラムボブをオフにできるよ';

  @override
  String get prefTriviaTitle => 'プラムボブの豆知識';

  @override
  String get prefTriviaDesc => '今開いているゲームの豆知識を、プラムボブがときどき教えてくれるようにする';

  @override
  String get triviaCategoryOrigins => '誕生';

  @override
  String get triviaCategoryDesign => '設計';

  @override
  String get triviaCategoryLore => '設定';

  @override
  String get triviaCategoryDeath => '死因';

  @override
  String get triviaCategoryMusic => '音楽';

  @override
  String get triviaCategoryCheats => 'チート';

  @override
  String get triviaCategoryRecords => '記録';

  @override
  String get triviaCategoryModding => 'Mod';

  @override
  String get triviaCategoryLanguage => '言語';

  @override
  String get triviaCategoryCommunity => 'コミュニティ';

  @override
  String get triviaSeriesLlama =>
      'Maxis はかつてスタジオ全体で非公式マスコットを投票で決めた。候補はタマシダ、無鉤条虫、そしてラマ。ラマが勝ち、それ以来どの作品にも顔を出し続けている。';

  @override
  String get triviaSeriesSimlish =>
      'シムリッシュはマイクの前で生まれた。Stephen Kearin と Gerri Lawlor は「空腹」「孤独」といったお題を渡され、それがどう聞こえるべきかを何時間も即興でつくっていった。';

  @override
  String get triviaSeriesCheats =>
      'rosebud も klapaucius もそれぞれ §1,000 くれる。rosebud は『市民ケーン』から。Klapaucius はスタニスワフ・レムの『宇宙創世記ロボットの旅』に出てくる建造ロボットで、この本は SimCity のころから Will Wright が影響源として挙げている。';

  @override
  String get triviaSeriesRecords =>
      'ギネスは The Sims を史上最も売れた PC ゲームシリーズとして認定している。1 億 2500 万本を超えたのは 10 年以上前で、60 言語に翻訳されている。';

  @override
  String get triviaSeriesGoths =>
      'ゴス家はゲーム史でも指折りの長寿一家。モーティマーとベラは 2000 年以降、すべてのナンバリング作品に登場している。';

  @override
  String get triviaSeriesReaper =>
      '死神には、普通に遊んでいると決して表示されないプロフィールがある。そこには好きなバンドまで書いてあって、答えは Styx。';

  @override
  String get triviaSeriesSimCity =>
      'The Sims は SimCity から生まれた。Will Wright は、その街が誰のために建てられているのか、小さな住人たちに寄って見たくて仕方がなかった。';

  @override
  String get triviaSeriesLegacy =>
      '2025 年 1 月、EA は The Sims と The Sims 2 を Legacy Collection として再発売した。拡張パックはすべて同梱。リマスターではなく互換性の修正なので、遊び心地は当時のままだ。';

  @override
  String get triviaSeriesPlumbob =>
      'あの緑の菱形には表記が三つある。The Sims では PlumbBob、The Sims 2 では Plum Bob、The Sims 4 以降は plumbob。Maxis いわく、開発中はどれも使われていた。';

  @override
  String get triviaSeriesModScene =>
      'Mod シーンはシリーズとほぼ同い年だ。2000 年の第 1 作発売から数か月でスキンやオブジェクトのエディタが出回っていた。公式ツールなど影も形もない時代の話。';

  @override
  String get triviaSeriesConflicts =>
      '競合は響きほど難しくない。二つの Mod が同じリソースを主張し、両方とも読み込まれ、ゲームが最後に読んだほうが勝つ。壊れたわけではなく、片方が上書きされただけだ。';

  @override
  String get triviaSeriesPackage =>
      '.package ファイルの正体は DBPF アーカイブ、Database Packed File の略。Maxis は SimCity 4 のころから同じコンテナを使い続けていて、だからこそ一つのツールで 20 年分のカスタムコンテンツが開ける。';

  @override
  String get triviaSeriesRename =>
      'ファイル名を変えて Mod を無効にするのは、この界隈で一番古い手だ。ゲームは自分が認識できるものしか読まないので、名前を変えた package はその場に置かれたまま黙っている。';

  @override
  String get triviaSeriesSaves =>
      'The Sims のセーブは「スロット」ではなく「近隣」だ。家族も区画も思い出も噂話も、遊び続けるかぎり膨らんでいく一つのフォルダに一緒に入っている。';

  @override
  String get triviaSeriesPacks =>
      'パックをオフにしてもファイルは一つも動かない。シリーズのどの作品も「何を読み込むか」の一覧を別の場所に持っていて、設定ファイルの一行だったりレジストリのキーだったりする。パックを隠すというのは、その一覧を書き換えるだけのことだ。';

  @override
  String get triviaSims1Dollhouse =>
      'The Sims は Project Dollhouse という建築シミュレーターとして始まった。シムが加わったのは、その家が住み心地よく出来ているかをプレイヤーが判断できるようにするためだけだった。';

  @override
  String get triviaSims1Oakland =>
      'Will Wright は 1991 年のオークランド大火で自宅を失った。家具も家電も生活習慣も一から組み直す作業が、このゲームの種になった。';

  @override
  String get triviaSims1Toilet =>
      '経営陣はこの企画に納得せず、シムにトイレが要るという理由で「便所ゲーム」と切り捨てたことで知られている。';

  @override
  String get triviaSims1HomeTactics =>
      'The Sims になる前、この企画は Home Tactics: The Experimental Domestic Simulator という名前で提案されていた。そちらもフォーカスグループには不評だった。';

  @override
  String get triviaSims1Myst =>
      '2002 年、The Sims は Myst を抜いて史上最も売れた PC ゲームになった。';

  @override
  String get triviaSims1Simlish =>
      'シムリッシュは声優たちがウクライナ語、ナバホ語、タガログ語、エストニア語の断片を素材に即興でつくったもの。言語が古びないよう、意味を持たせないまま残された。';

  @override
  String get triviaSims1Architecture =>
      '2000 年当時としては建築ツールがあまりに独特で、シムを一人も置かないまま無料の建築ソフトとして使い続けた人までいた。';

  @override
  String get triviaSims1Audience =>
      '当時としては珍しく、プレイヤーの多数は女性だった。売り場で他のどれとも似ていない広告になっていたのは、それも理由の一つだ。';

  @override
  String get triviaSims1Cowplant =>
      'カウプラントの初登場はここ。ゲーム内での名前は Laganaphyllis Simnovorii で、以来どの世代でもこっそりシムを食べ続けている。';

  @override
  String get triviaSims1Plumbob =>
      'plumbob という言葉は下げ振りから来ている。垂直を出すために職人が糸で吊るす、あの先のとがった重りだ。これは何よりもまず建築のゲームだった。';

  @override
  String get triviaSims1Release =>
      '発売は 2000 年 2 月 4 日。EA が立てたどの販売予測も上回る売れ方をした。';

  @override
  String get triviaSims1Edith =>
      'ゲーム内のすべてのオブジェクトは SimAntics という言語で書かれ、Edith という社内ツールで組まれた。名前の由来は Edith Bunker、The Sims のために最初に作られたキャラクターだ。';

  @override
  String get triviaSims1Expansions =>
      '3 年半で 7 本の拡張パック。春と秋に 1 本ずつ、2000 年 8 月の Livin’ Large から 2003 年 10 月の Makin’ Magic まで。';

  @override
  String get triviaSims1Unleashed =>
      'Unleashed は 2002 年にペットをシリーズへ持ち込み、Interactive Achievement Awards で年間最優秀シミュレーションゲームを獲得した。';

  @override
  String get triviaSims1Clown =>
      '悲劇のピエロは、彼の絵を持っている落ち込んだシムを励ましに現れる。それが見事なまでに下手で、そこが笑いどころになっている。';

  @override
  String get triviaSims1Llama =>
      'オリジナルの紙のマニュアルには『Making the Most of Your Llama』という本が収められていた。理由は今日まで誰も説明していない。';

  @override
  String get triviaSims1Superstar =>
      'Superstar ではシムが俳優、モデル、歌手になれた。名声メーターまで付いていて、The Sims 4 が再び有名人に挑むより 11 年も早い。';

  @override
  String get triviaSims1Catalogue =>
      '火事のあと家を建て直しながら、Will Wright は家のどの部分が不可欠で、どれは後回しでいいのかを問い続けた。その問いがほぼそのまま購入モードのカタログになっている。';

  @override
  String get triviaSims2Aging =>
      'The Sims 2 はシリーズで初めて、シムが年を取り、寿命で亡くなり、遺伝を引き継ぐ作品になった。目も鼻もあごも両親から受け継がれる。';

  @override
  String get triviaSims2Memories =>
      'どのシムも隠れた記憶リストを持っている。死を目撃したこと、初めてのキス、昇進などが記録され、あとの気分に影響する。';

  @override
  String get triviaSims2Bella =>
      'ベラ・ゴスはゲーム開始時点で Pleasantview から姿を消しており、20 年経った今も公式な説明は一度もない。';

  @override
  String get triviaSims2Strangetown =>
      'ベラは Strangetown で生きて見つかるが、Pleasantview の記憶がまったくない。Maxis は「どちらのベラも本物」と言い、それきりだ。';

  @override
  String get triviaSims2FamilyTrees =>
      'The Sims 2 の近隣は本物の家系図の上に成り立っている。Pleasantview、Strangetown、Veronaville は婚姻と噂話でつながっている。';

  @override
  String get triviaSims2Plead =>
      '死神には嘆願できる。ちょうどいい瞬間に話しかければシムを返してくれることがあり、ときには別の誰かと引き換えになる。';

  @override
  String get triviaSims2ReaperRomance =>
      '死神と恋愛関係になれる。うまく運べば、その関係から幽霊の赤ちゃんが生まれる。';

  @override
  String get triviaSims2Satellite =>
      '星を眺めているシムには、落ちてきた人工衛星に当たるというごく小さな確率がある。シリーズでもっとも珍しい死因の一つだ。';

  @override
  String get triviaSims2Therapist =>
      '野望が崩壊するとシムはセラピストのもとへ送られる。ゲームが笑いのために自分から第四の壁を破る、数少ない場面だ。';

  @override
  String get triviaSims2WantsFears =>
      '願望と恐怖がゲーム全体を動かしている。野望メーターは、シムが望んでいたことと同じ強さで、恐れていたことにも反応する。';

  @override
  String get triviaSims2FaceSculpt =>
      '発売時から体型と顔を丸ごと造形できる仕組みが入っていた。The Sims 2 の顔が今でも後年の作品より多彩に見えるのはそのためだ。';

  @override
  String get triviaSims2Aliens =>
      'エイリアンによる誘拐は、星を眺めすぎた男性シムにしか起こらない。そして、そのとおり妊娠して帰ってくる。';

  @override
  String get triviaSims2FreezerBunny =>
      'Freezer Bunny はアーティストの Emmy Toyonaga が The Sims 2 のために描いたもので、最初は共有区画の冷凍庫の中に隠れて登場した。以来どの作品にもこっそり紛れ込んでいる。';

  @override
  String get triviaSims2SocialBunny =>
      'ソーシャルバニーは悲劇のピエロの後任だが、ピエロと違ってこちらはちゃんと役に立つ。有能なほうが不気味だと感じたプレイヤーも少なくない。';

  @override
  String get triviaSims2Giveaway =>
      'EA は 2014 年 7 月、Origin で Ultimate Collection を無料配布した。引き換えコードは I-LOVE-THE-SIMS。その後 Legacy Collection が出るまでの 10 年間、この配布分が唯一入手できる版だった。';

  @override
  String get triviaSims3SunsetValley =>
      'Sunset Valley は The Sims 2 の Pleasantview のおよそ 25 年前の姿だ。つまり、すでに遊んだことのあるシムたちの祖父母に会える。';

  @override
  String get triviaSims3Founders =>
      'Sunset Valley を興したのはゴス家で、育てたのは Landgraab 家。子どものモーティマー・ゴスを操作して、ベラ・バチェラーと出会う場面を見ることもできる。';

  @override
  String get triviaSims3OpenWorld =>
      'The Sims 3 はロード画面を完全になくした。町全体が同時にシミュレートされ、どのシムも裏で年を取り、仕事に出ている。';

  @override
  String get triviaSims3Simulation =>
      '町中のシムが同時に動いているので、長く遊んだセーブほど重くなる。ゲームは、あなたが一度も会っていない人生を静かに回し続けている。';

  @override
  String get triviaSims3CreateAStyle =>
      'クリエイト・ア・スタイルはほぼどんなオブジェクトも色や柄を変えられる機能だった。あまりに負荷が重く、以後の作品には戻ってきていない。';

  @override
  String get triviaSims3Exchange =>
      'The Sims 3 には本物のオンライン交換所が付いていて、区画もシムも柄もランチャーから直接やり取りできた。';

  @override
  String get triviaSims3Downloads =>
      '発売週だけで、プレイヤーはそのランチャーからコミュニティ製アイテムを 700 万点以上ダウンロードした。';

  @override
  String get triviaSims3Traits =>
      '特質が旧来の性格スライダーに取って代わった。中には「窃盗癖」や「狂気」のように、普通の生活のルールをさらりと破るものもある。';

  @override
  String get triviaSims3Kleptomaniac =>
      '窃盗癖のシムは頼まれてもいないのに他人の家具を持ち帰ってくる。しかも、あなたが気づくまでずっと続ける。';

  @override
  String get triviaSims3Simlish =>
      'Katy Perry、Lily Allen、Depeche Mode をはじめ数十組のアーティストが、自分の曲をシムリッシュで録り直してサントラに提供した。';

  @override
  String get triviaSims3Townies =>
      'オープンワールドは画面外のシムもシミュレートしていたので、町の住人が勝手に結婚して子どもをもうけていた、ということがしょっちゅう起きた。';

  @override
  String get triviaSims3Store =>
      'The Sims 3 ストアは最終的に、発売時のゲーム本体が持っていたより多くのオブジェクトを売った。';

  @override
  String get triviaSims3Launch =>
      'The Sims 3 は 2009 年 6 月の発売週に 140 万本を売り上げた。EA にとって当時最大の PC タイトル発売だった。';

  @override
  String get triviaSims4Flies => 'ハエによる死は本当にある。区画を十分に汚くしておくと、群れがシムにとどめを刺す。';

  @override
  String get triviaSims4Emotions =>
      'ここではすべて感情が動かしている。「ひらめいた」シムは絵がうまくなり、「激怒」したシムは怒りで死ぬことがある。';

  @override
  String get triviaSims4EmotionDeaths =>
      'シムは笑い死にもするし、怒り死にもするし、恥ずかしさでも死ぬ。この作品では感情は飾りではなく危険物だ。';

  @override
  String get triviaSims4CreateASim =>
      'クリエイト・ア・シムはスライダーをやめ、顔を直接つまんで引っ張る方式にした。The Sims 4 で顔があっという間に作れるのはそのためだ。';

  @override
  String get triviaSims4Launch =>
      'The Sims 4 はプールも幼児もない状態で発売された。どちらもプレイヤーの粘り強い要望を受け、無料アップデートで戻ってきた。';

  @override
  String get triviaSims4Worlds =>
      '2014 年 9 月の発売時、ワールドは Willow Creek と Oasis Springs の二つだけだった。今では数十あり、そのほとんどはパックと一緒にやって来た。';

  @override
  String get triviaSims4Gender =>
      '2016 年のアップデートで性別の制約が完全に外れた。どのシムもどの服を着てもよく、どの声でもよく、妊娠する／しないも選べる。';

  @override
  String get triviaSims4Newcrest =>
      'Newcrest はわざと完全に空の状態で出された。15 区画、建物ゼロ。コミュニティへの公開招待状のようなものだ。';

  @override
  String get triviaSims4Naming =>
      'Willow Creek や Oasis Springs といった近隣名は、古い Maxis から続く社内ルールに従っている。平易な英単語を二つ、造語のつづりは使わない。';

  @override
  String get triviaSims4Goths =>
      'ゴス家はここにも登場する。おかげで彼らはゲーム史でも屈指の長寿一家となり、ナンバリング全作に顔を出している。';

  @override
  String get triviaSims4FreeToPlay =>
      '本体は 2022 年 10 月に無料化された。PC、PlayStation、Xbox で同時に。パックは有料のままだ。';

  @override
  String get triviaSims4Mccc =>
      'The Sims 4 プレイヤーがまず入れる Mod、MC Command Center は CurseForge だけで 1400 万ダウンロードを超えた。作者の Deaderpool は 2015 年から更新を続けている。';

  @override
  String get triviaSims4Twallan =>
      'MCCC があるのは The Sims 3 のおかげだ。Twallan の Master Controller と Story Progression が残した仕事を引き継ぎ、10 年以上前の発想を新しいエンジンへ持ち込んでいる。';

  @override
  String get triviaSims4Deaths =>
      'シムはカウプラント、自動販売機、ラマ型のステレオ、そして笑いで死ぬことがある。さすがに全部同時ではない。';

  @override
  String get triviaMedievalWatcher =>
      'ここでのあなたは一世帯ではなく「ウォッチャー」だ。一家の一日を回すのではなく、王国じゅうの英雄たちを後押しする善意の神である。';

  @override
  String get triviaMedievalHeroes =>
      '一つの王国には 10 種の職業の英雄シムが最大 10 人まで。それぞれレベル 1 から 10 まで上がり、新しい能力とだんだん立派になる称号を手に入れていく。';

  @override
  String get triviaMedievalStocks =>
      '英雄は毎朝、二つの責務と締切を渡される。サボりすぎれば罰が下り、それは君主も例外ではない。さらし台に入れられることもある。';

  @override
  String get triviaMedievalAmbition =>
      '始める前に王国全体の「野望」を選び、受けるクエストはその野望に照らして採点される。The Sims が勝利条件にもっとも近づいた瞬間だ。';

  @override
  String get triviaMedievalQuests =>
      'これはスピンオフではなく完全な作り替えだ。サンドボックスがクエストの連なりに置き換わっていて、だからこそ「終わらせられる」唯一の The Sims になっている。';

  @override
  String get triviaMedievalPirates =>
      '2011 年 8 月の Pirates and Nobles が唯一の追加コンテンツだった。ハヤブサとオウム、宝の地図とシャベル、そしてやって来た二つの勢力の戦い。';

  @override
  String get triviaMedievalProxy =>
      'このゲームはそもそも Mod を読み込む前提で作られていない。スクリプト Mod やコア Mod を動かすには、コミュニティ製の d3dx9_31.dll プロキシを Game/Bin に置く必要がある。カスタムコンテンツはそれなしでも動く。';

  @override
  String get triviaMedievalEngine =>
      'エンジンは The Sims 3 のものだ。だから Resource.cfg も .package ファイルも、あのゲームを触ったことがある人には妙に見覚えがある。';

  @override
  String get navCreations => 'クリエイション';

  @override
  String creationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'クリエイション $count 件',
      zero: 'まだ何も保存されていません',
    );
    return '$_temp0';
  }

  @override
  String get creationsScanning => '区画と世帯を読み込み中…';

  @override
  String get creationsRefresh => '更新';

  @override
  String get creationsAll => 'すべて';

  @override
  String get creationsBack => '← すべてに戻る';

  @override
  String get creationsNoneOfKind => 'その種類のものはここにありません。';

  @override
  String get creationsEmptyTitle => 'まだ何もありません';

  @override
  String get creationsEmptyBody =>
      'ゲーム内で保存した区画・部屋・世帯・シムがここに出てきます。ダウンロードしてウィンドウにドロップしたものも同じです。';

  @override
  String creationsBy(String creator) {
    return '作者：$creator';
  }

  @override
  String get creationsWhoLivesHere => '一緒についてくるシム';

  @override
  String get creationsShowInFolder => 'フォルダーで表示';

  @override
  String get creationsDelete => '削除';

  @override
  String creationsDeleteTitle(String name) {
    return '「$name」を削除しますか？';
  }

  @override
  String get creationsDeleteBody => 'ゲームのフォルダーから完全になくなります。元には戻せません。';

  @override
  String creationsFileCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個のファイル',
    );
    return '$_temp0';
  }

  @override
  String get creationKindLot => '区画';

  @override
  String get creationKindRoom => '部屋';

  @override
  String get creationKindHousehold => '世帯';

  @override
  String get creationKindSim => 'シム';

  @override
  String get creationFolderSims4Tray => 'Tray';

  @override
  String get creationFolderSims3Library => 'Library';

  @override
  String get creationFolderSims2LotCatalog => '区画と家のコレクション';

  @override
  String get creationFolderSims2SavedSims => 'パッケージ化したシム';

  @override
  String creationFolderSims1Houses(String number) {
    return '近所 $number';
  }

  @override
  String creationBadFileName(String name) {
    return '「$name」のファイル名にはこのシステムで使えない文字が入っていて、ゲームからは見つけられません。名前を変えてもう一度試してください。';
  }

  @override
  String creationFileInUse(String name) {
    return '「$name」は使用中です。ゲームを閉じてからもう一度試してください。';
  }

  @override
  String get creationNeighborhoodFull =>
      'この近所にはもう入る限界の99軒が入っています。遊んでいない家を削除してから追加してください。';

  @override
  String creationInstallFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'その $count 個のファイルは追加できませんでした。',
      one: 'そのファイルは追加できませんでした。',
    );
    return '$_temp0';
  }

  @override
  String creationRemoveFailed(String name) {
    return '「$name」は削除できませんでした。';
  }

  @override
  String get creationsAdd => '追加';

  @override
  String get creationsAdding => '追加中…';

  @override
  String creationsPickerLabel(String game) {
    return '$game の区画・部屋・世帯・シム';
  }

  @override
  String get creationsNothingToAdd =>
      'この中に、このゲームが読み込める区画・部屋・世帯・シムはありませんでした。カスタムコンテンツやMODはライブラリから追加してください。';
}
