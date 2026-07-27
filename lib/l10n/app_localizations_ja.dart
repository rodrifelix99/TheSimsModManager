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
  String get install => 'インストール';

  @override
  String filePickerModsLabel(String game) {
    return '『$game』の MOD';
  }

  @override
  String get statTotal => '合計';

  @override
  String get statEnabled => '有効';

  @override
  String get statDisabled => '無効';

  @override
  String get statConflicts => '競合';

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
  String get conflictSameNameBody =>
      'ファイル名がまったく同じなのは、たいてい同じ MOD が二重に入っているか、別々の作者のパッケージがぶつかっているサインです。重なったリソースの読み込み順は予測できないので、ひとつだけ残して他は無効にするか削除してください。';

  @override
  String get conflictVersionBody =>
      '同じ MOD のバージョンが複数入っていると、重なったリソースの読み込み順が予測できません。いちばん新しいものだけ残して、他は無効にするか削除してください。';

  @override
  String get conflictResourcesBody =>
      'これらのパッケージには同じ識別子のリソースが入っているため、ゲームは最後に読み込んだものだけを残します。パッチ系や上書き系の MOD はわざと他の MOD のリソースを隠すので意図的なこともありますが、無関係な MOD 同士だと片方が黙って効かなくなります。使いたいほうを残して、他は無効にしてください。';

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
  String get translatorsDesc => 'アプリが10か国語で使えるのは、訳してくれたシマーたちのおかげです。';

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
  String errorNoModFiles(String extensions, String name) {
    return '$name の中にMODファイル（$extensions）が見つかりませんでした。';
  }

  @override
  String errorUnreadableArchive(String name) {
    return '$name はこのアプリで読めるZIPアーカイブではありません。';
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
  String errorInstallFailed(String name, String reason) {
    return '「$name」をインストールできませんでした — $reason。うまくいかないままなら、手動で展開して中のファイルをインストールしてね。';
  }

  @override
  String errorInstallFailedRaw(String name, String reason) {
    return '「$name」をインストールできませんでした — $reason';
  }

  @override
  String errorFileInUseDelete(String name) {
    return '「$name」を削除できませんでした — 別のプログラムが使用中（ゲームは起動中？）か、書き込み禁止になっています。使っているものを閉じて、もう一度試してね。';
  }

  @override
  String errorFileInUseRename(String name) {
    return '「$name」の名前を変更できませんでした — 別のプログラムが使用中（ゲームは起動中？）か、書き込み禁止になっています。使っているものを閉じて、もう一度試してね。';
  }

  @override
  String errorFileMissing(String name) {
    return '「$name」はもうMODフォルダーにありません — 別のプログラムが移動したか削除したのかもしれません。';
  }

  @override
  String errorShopDownload(String name) {
    return '「$name」をThe Exchangeからダウンロードできませんでした。接続を確認して、もう一度試してみてください。';
  }

  @override
  String get errorShopListingNotFound =>
      'このMODはもう The Exchange にないみたい。取り下げられたのかも。';

  @override
  String get errorShopListingUnknownGame =>
      'このMODは、今のバージョンのアプリがまだ知らないゲーム向けだよ。アップデートしてみて。';

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
}
