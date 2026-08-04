// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class LPt extends L {
  LPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Sims Mod Manager';

  @override
  String get brandTitle => 'Mod Manager';

  @override
  String get brandSubtitle => 'para The Sims';

  @override
  String get navLibrary => 'Biblioteca';

  @override
  String get navShop => 'The Exchange';

  @override
  String get navSettings => 'Configurações';

  @override
  String get shopAlphaBadge => 'ALFA';

  @override
  String get shopTagline => 'Mods da comunidade, instalados com um clique.';

  @override
  String shopListingCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods nas prateleiras',
      one: '1 mod nas prateleiras',
    );
    return '$_temp0';
  }

  @override
  String get shopRefresh => 'Atualizar';

  @override
  String get shopPublish => 'Publique seus mods';

  @override
  String get shopLoadFailedTitle => 'The Exchange não está respondendo';

  @override
  String get shopLoadFailedBody =>
      'Não deu para carregar as prateleiras. Confira sua conexão e tente de novo.';

  @override
  String get shopRetry => 'Tentar de novo';

  @override
  String get shopEmptyTitle => 'As prateleiras ainda estão vazias';

  @override
  String get shopEmptyBody =>
      'The Exchange acabou de abrir as portas e ninguém publicou nada ainda. É novo assim mesmo. Você cria mods? Inaugure as prateleiras!';

  @override
  String get shopAllGames => 'Todos os jogos';

  @override
  String get shopShowAllGames => 'Ver todos os jogos';

  @override
  String shopEmptyGameTitle(String game) {
    return 'Ainda não tem nada de $game';
  }

  @override
  String shopEmptyGameBody(String game) {
    return 'Outros jogos já têm mods nas prateleiras, mas de $game ninguém publicou ainda. Você fez um? Inaugure essa prateleira!';
  }

  @override
  String shopBy(String author) {
    return 'por $author';
  }

  @override
  String get shopInstalled => 'Instalado';

  @override
  String get shopUpdate => 'Atualizar';

  @override
  String get shopUpdateBadge => 'atualização';

  @override
  String shopUpdatesWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dos seus mods têm versões novas no The Exchange',
      one: '1 dos seus mods tem versão nova no The Exchange',
    );
    return '$_temp0';
  }

  @override
  String get shopUpdateHeading => 'Tem uma versão nova deste mod';

  @override
  String shopUpdateBody(String version, String author) {
    return '$author publicou a v$version no The Exchange. Atualizar substitui os arquivos que você tem agora.';
  }

  @override
  String get shopUpdateSeeListing => 'Ver o anúncio';

  @override
  String get shopInstalling => 'Instalando…';

  @override
  String get shopInstallNotes => 'Notas de instalação';

  @override
  String get shopCreatorNudge =>
      'Você cria mods? Publicar no The Exchange é de graça, e os jogadores instalam seu trabalho com um clique.';

  @override
  String shopNeedsFolder(String game) {
    return 'Configure primeiro a pasta de mods de $game. A aba Biblioteca mostra o caminho.';
  }

  @override
  String shopVariations(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count variações',
      one: '1 variação',
    );
    return '$_temp0';
  }

  @override
  String get shopSaveFile => 'Baixar';

  @override
  String get shopSaving => 'Baixando…';

  @override
  String get shopSaved => 'Salvo';

  @override
  String get shopSaveHint =>
      'Instalar joga os arquivos direto na sua pasta de mods. Baixar só salva o arquivo, onde você quiser.';

  @override
  String get shopVariationPick => 'Escolhe a variação';

  @override
  String get shopBack => 'Voltar às prateleiras';

  @override
  String get shopCopyLink => 'Copiar link';

  @override
  String get shopLinkCopied => 'Link copiado';

  @override
  String get sidebarGames => 'JOGOS';

  @override
  String sidebarNotInstalled(String detail) {
    return 'não instalado · $detail';
  }

  @override
  String sidebarModCount(int count, String detail) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods',
      one: '1 mod',
      zero: '0 mods',
    );
    return '$_temp0 · $detail';
  }

  @override
  String get updateAvailable => 'Atualização disponível';

  @override
  String updateClickToDownload(String version) {
    return 'v$version: clique para baixar';
  }

  @override
  String get storage => 'Armazenamento';

  @override
  String storageInMods(String size) {
    return '$size em mods';
  }

  @override
  String storageFreeOf(String free, String total) {
    return '$free livres de $total';
  }

  @override
  String dropToInstall(String game) {
    return 'Solte aqui para instalar em $game';
  }

  @override
  String get dropFolders => 'pastas';

  @override
  String scanningMods(int done, int total) {
    return 'Olhando dentro dos mods atrás de imagens e conflitos… $done de $total';
  }

  @override
  String get skip => 'Pular';

  @override
  String libraryTitle(String game) {
    return 'Biblioteca de $game';
  }

  @override
  String modsShown(int count, String era) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods à mostra',
      one: '1 mod à mostra',
      zero: '0 mods à mostra',
    );
    return '$_temp0 · $era';
  }

  @override
  String get learnMore => 'Saiba mais';

  @override
  String get dismiss => 'Dispensar';

  @override
  String get searchMods => 'Buscar mods…';

  @override
  String get viewGrid => 'Grade';

  @override
  String get viewList => 'Lista';

  @override
  String get viewFolders => 'Pastas';

  @override
  String get sortTooltip => 'Ordenar';

  @override
  String get sortByName => 'Nome (A–Z)';

  @override
  String get sortByRecent => 'Modificados recentemente';

  @override
  String get sortBySize => 'Maiores primeiro';

  @override
  String get sortDisabledLast => 'Desativados por último';

  @override
  String get libraryRefresh => 'Atualizar';

  @override
  String get libraryRootFolder => 'Pasta Mods';

  @override
  String get selectionTooltip => 'Selecionar';

  @override
  String selectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selecionados',
      one: '1 selecionado',
    );
    return '$_temp0';
  }

  @override
  String get selectionSelectAll => 'Selecionar tudo';

  @override
  String get selectionClear => 'Limpar seleção';

  @override
  String get selectionEnable => 'Ativar';

  @override
  String get selectionDisable => 'Desativar';

  @override
  String selectionProgress(int done, int total) {
    return '$done de $total';
  }

  @override
  String selectionDeleteTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Desinstalar $count mods?',
      one: 'Desinstalar 1 mod?',
    );
    return '$_temp0';
  }

  @override
  String selectionDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Os $count arquivos vão ser apagados do disco. Não dá pra desfazer.',
      one: 'O arquivo vai ser apagado do disco. Não dá pra desfazer.',
    );
    return '$_temp0';
  }

  @override
  String get selectionMove => 'Mover para…';

  @override
  String get newFolder => 'Nova pasta';

  @override
  String newFolderIn(String folder) {
    return 'Dentro de $folder';
  }

  @override
  String get newFolderHint => 'Nome da pasta';

  @override
  String get create => 'Criar';

  @override
  String get move => 'Mover';

  @override
  String moveTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mover $count mods pra onde?',
      one: 'Mover 1 mod pra onde?',
    );
    return '$_temp0';
  }

  @override
  String get moveBody =>
      'Os arquivos mudam de pasta no disco. Nada mais muda: o que estiver desativado continua desativado.';

  @override
  String get folderEmptySection => 'Ainda não tem nada aqui';

  @override
  String get install => 'Instalar';

  @override
  String filePickerModsLabel(String game) {
    return 'Mods de $game';
  }

  @override
  String get installWhereTitle => 'Onde isso vai?';

  @override
  String installWhereBody(String game) {
    return '$game lê mods de várias pastas. O app pode descobrir pelo próprio arquivo, ou você diz onde é.';
  }

  @override
  String get installWhereSorted => 'Decide por mim';

  @override
  String get installWhereSortedDesc =>
      'Segue as pastas que vêm no download e coloca o resto pelo tipo de arquivo.';

  @override
  String get installWhereRemember => 'Não perguntar de novo';

  @override
  String get destinationSims1Downloads =>
      'Objetos, hacks e a maioria dos downloads.';

  @override
  String get destinationSims1Global =>
      'Alterações que mudam o jogo base inteiro.';

  @override
  String get destinationSims1Objects =>
      'Alterações nos arquivos de objetos do próprio jogo.';

  @override
  String get destinationSims1Skins =>
      'Peles e cabeças do dia a dia. Aparecem no Criar um Sim.';

  @override
  String get destinationSims1SkinsBuy =>
      'Roupas vendidas nas lojas dos terrenos comunitários.';

  @override
  String get destinationSims1Walls => 'Revestimentos de parede.';

  @override
  String get destinationSims1Floors => 'Pisos.';

  @override
  String get destinationSims1Roofs => 'Texturas de telhado.';

  @override
  String get prefAskWhereTitle => 'Perguntar onde instalar';

  @override
  String get prefAskWhereDesc =>
      'Esse jogo lê mods de mais de uma pasta. Escolha a pasta toda vez em vez de deixar o app decidir';

  @override
  String get statTotal => 'Total';

  @override
  String get statEnabled => 'Ativos';

  @override
  String get statDisabled => 'Inativos';

  @override
  String get statConflicts => 'Conflitos';

  @override
  String get statTotalTooltip => 'Todos os mods desta pasta, ligados ou não.';

  @override
  String get statTotalTooltipClear =>
      'Todos os mods desta pasta. Clique para largar a busca e os filtros.';

  @override
  String get statEnabledTooltip => 'Os mods que o jogo carrega.';

  @override
  String get statEnabledTooltipActive =>
      'Mostrando só os mods ativos. Clique para ver todos de novo.';

  @override
  String get statDisabledTooltip => 'Mods que estão na pasta mas desligados.';

  @override
  String get statDisabledTooltipActive =>
      'Mostrando só os mods inativos. Clique para ver todos de novo.';

  @override
  String get conflictTooltipActive =>
      'Mostrando só os mods em conflito. Clique para ver todos de novo.';

  @override
  String get conflictTooltip =>
      'Mods ativos que dividem o nome de arquivo com outro mod ativo, que estão instalados em mais de uma versão ou que sobrescrevem os mesmos recursos do jogo. O jogo só fica com a cópia que carrega por último, às vezes de propósito (mods de patch), muitas vezes não.';

  @override
  String get conflictTooltipClickHint => 'Clique para ver só esses mods.';

  @override
  String get filterAll => 'Todos';

  @override
  String get emptyFiltered => 'Nenhum mod corresponde aos filtros';

  @override
  String get emptyNoMods => 'Ainda não há mods';

  @override
  String get emptyFilteredHint =>
      'Tente limpar a busca ou escolher outro filtro.';

  @override
  String emptyNoModsHint(String path) {
    return 'Esta é a pasta que está sendo observada:\n$path';
  }

  @override
  String get openFolder => 'Abrir pasta';

  @override
  String get conflictBadge => 'conflito';

  @override
  String modInFolder(String folder) {
    return 'em $folder';
  }

  @override
  String get modInModsFolder => 'na pasta Mods';

  @override
  String setupFoundNoModsFolder(String game) {
    return '$game foi encontrado, mas ainda sem pasta de mods';
  }

  @override
  String setupNotFound(String game) {
    return 'Pasta de mods de $game não encontrada';
  }

  @override
  String get setupFoundNoModsFolderBody =>
      'A pasta do jogo está neste computador, só que ainda não tem uma pasta de mods dentro. Crie ela aqui embaixo ou aponte uma manualmente.';

  @override
  String get setupNotFoundBody =>
      'Pode ser que o jogo não esteja instalado, que esteja num lugar incomum ou que a pasta de mods ainda não exista.';

  @override
  String get foundOnThisComputer => 'ENCONTRADO NESTE COMPUTADOR';

  @override
  String get chooseFolder => 'Escolher pasta…';

  @override
  String get createItForMe => 'Criar pra mim';

  @override
  String willBeCreatedAt(String path) {
    return 'Vai ser criada em:\n$path';
  }

  @override
  String get checkAgain => 'Verificar de novo';

  @override
  String get useThis => 'Usar esta';

  @override
  String get enabled => 'Ativo';

  @override
  String get disabled => 'Inativo';

  @override
  String get showInFileManager => 'Mostrar no gerenciador de arquivos';

  @override
  String get uninstallMod => 'Desinstalar mod';

  @override
  String uninstallConfirmTitle(String title) {
    return 'Desinstalar $title?';
  }

  @override
  String uninstallConfirmBody(String path) {
    return 'O arquivo vai ser apagado do disco:\n$path';
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
      other: 'Outros $count mods ativos têm o mesmo nome de arquivo:',
      one: 'Outro mod ativo tem o mesmo nome de arquivo:',
    );
    return '$_temp0';
  }

  @override
  String conflictVersionHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Outros $count mods ativos parecem versões diferentes deste mod:',
      one: 'Outro mod ativo parece ser uma versão diferente deste mod:',
    );
    return '$_temp0';
  }

  @override
  String conflictResourcesHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Outros $count mods ativos sobrescrevem os mesmos recursos do jogo:',
      one: 'Outro mod ativo sobrescreve os mesmos recursos do jogo:',
    );
    return '$_temp0';
  }

  @override
  String sharedResources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recursos em comum',
      one: '1 recurso em comum',
    );
    return '$_temp0';
  }

  @override
  String get conflictSameNameBody =>
      'Nomes idênticos normalmente querem dizer que o mesmo mod está instalado duas vezes, ou que os pacotes de dois criadores estão brigando. O jogo carrega os recursos que se sobrepõem numa ordem imprevisível: fique com um e desative ou remova o resto.';

  @override
  String get conflictVersionBody =>
      'Ter várias versões do mesmo mod instaladas faz o jogo carregar os recursos que se sobrepõem numa ordem imprevisível: fique com a mais nova e desative ou remova as outras.';

  @override
  String get conflictResourcesBody =>
      'Estes pacotes têm recursos com os mesmos identificadores, então o jogo só fica com a cópia que carrega por último. Isso pode ser de propósito (mods de patch e de override cobrem os recursos de outro mod intencionalmente), mas entre mods sem relação significa que um deles simplesmente para de funcionar sem avisar: fique com o que você quer e desative os outros.';

  @override
  String get conflictIgnore => 'Ignorar';

  @override
  String get conflictIgnoreTooltip =>
      'Se esse conflito é de propósito, esconde ele. O mod não muda em nada, e dá pra trazer o aviso de volta nesta página ou nas configurações.';

  @override
  String get conflictRestore => 'Trazer de volta';

  @override
  String advisoryBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dos seus mods têm problemas conhecidos',
      one: 'Um dos seus mods tem um problema conhecido',
    );
    return '$_temp0';
  }

  @override
  String get advisoryShow => 'Dar uma olhada';

  @override
  String get advisoryShowAll => 'Mostrar todos os mods';

  @override
  String get advisoryBadge => 'problema';

  @override
  String get advisoryBrokenHeading => 'Este mod está quebrado';

  @override
  String get advisoryBrokenBody =>
      'Outros jogadores estão relatando que esse aí trava o jogo. Desativar é o jeito mais rápido de saber se o problema é ele.';

  @override
  String get advisoryOutdatedHeading => 'Existe uma versão mais nova deste mod';

  @override
  String get advisoryOutdatedBody =>
      'A versão que você tem é justamente a que está dando problema. Baixar a mais recente do criador deve resolver.';

  @override
  String get advisoryCautionHeading => 'Vale ficar de olho';

  @override
  String get advisoryCautionBody =>
      'Funciona para a maioria, mas já deu problema para alguns. Vale desativar se você estiver caçando um bug.';

  @override
  String advisorySince(String since) {
    return 'Desde $since';
  }

  @override
  String get advisoryOpenLink => 'Abrir a página do criador';

  @override
  String get advisorySource => 'Relatado por outros jogadores, não pelo jogo.';

  @override
  String modInDirectory(String dir) {
    return 'em $dir';
  }

  @override
  String get factVersion => 'Versão';

  @override
  String get factFormat => 'Formato';

  @override
  String get factSize => 'Tamanho';

  @override
  String get factType => 'Tipo';

  @override
  String get factModified => 'Modificado';

  @override
  String get factDownloads => 'Downloads';

  @override
  String get factIgnoredConflicts => 'Ignorados';

  @override
  String ignoredConflictsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count conflitos',
      one: '1 conflito',
    );
    return '$_temp0';
  }

  @override
  String get statusHeading => 'Status';

  @override
  String get statusEnabledBody =>
      'Este mod está ativo: o jogo vai carregar ele na próxima vez que abrir.';

  @override
  String statusDisabledBody(String marker) {
    return 'Este mod está desativado: o arquivo continua no disco com a marca “$marker” para o jogo ignorar. Pode reativar quando quiser; nada é apagado.';
  }

  @override
  String get fileOnDisk => 'Arquivo no disco';

  @override
  String get insideThePackage => 'Dentro do pacote';

  @override
  String resourcesTotal(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recursos no total',
      one: '1 recurso no total',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get sectionModManagement => 'GERENCIAMENTO DE MODS';

  @override
  String get sectionAppearance => 'APARÊNCIA';

  @override
  String get sectionLanguage => 'IDIOMA';

  @override
  String get sectionPrivacy => 'PRIVACIDADE';

  @override
  String sectionModsFolder(String game) {
    return 'PASTA DE MODS · $game';
  }

  @override
  String sectionGameCaches(String game) {
    return 'CACHE DO JOGO · $game';
  }

  @override
  String sectionIgnoredConflicts(String game) {
    return 'CONFLITOS IGNORADOS · $game';
  }

  @override
  String get sectionFeedback => 'FEEDBACK';

  @override
  String get sectionAbout => 'SOBRE';

  @override
  String get prefWarnConflictsTitle => 'Avisar sobre conflitos';

  @override
  String get prefWarnConflictsDesc =>
      'Marca os mods ativos que repetem um nome de arquivo ou que sobrescrevem os mesmos recursos do jogo que outro mod';

  @override
  String get prefConfirmDeleteTitle => 'Confirmar antes de desinstalar';

  @override
  String get prefConfirmDeleteDesc =>
      'Perguntar antes de apagar o arquivo de um mod do disco';

  @override
  String get prefShowDisabledTitle => 'Mostrar mods desativados';

  @override
  String get prefShowDisabledDesc =>
      'Mantém os mods desativados visíveis na biblioteca em vez de escondê-los';

  @override
  String get prefDisabledSuffixTitle => 'Marca de mod desativado';

  @override
  String get prefDisabledSuffixDesc =>
      'O que é acrescentado ao nome do arquivo quando você desativa um mod. Mude para combinar com outro gerenciador (o CC Magic usa .off); o app lê as duas formas do mesmo jeito, e os mods que você já desativou continuam com o nome que têm';

  @override
  String get prefDisabledSuffixInvalid =>
      'Precisa ser um ponto e algumas letras ou números, tipo .off';

  @override
  String get prefExperimentalPacksTitle =>
      'Interruptores de pacotes experimentais';

  @override
  String get prefExperimentalPacksDesc =>
      'Permite desligar os pacotes deste jogo. Sem testes nesta edição, e um bairro jogado com um pacote pode quebrar sem ele - faz backup dos saves primeiro';

  @override
  String get prefScanArtworkTitle => 'Escanear dentro dos mods';

  @override
  String get prefScanArtworkDesc =>
      'Olha dentro dos arquivos de mod enquanto a biblioteca carrega, atrás das imagens embutidas, do que tem dentro e de mods que sobrescrevem os mesmos recursos';

  @override
  String get prefSoundEffectsTitle => 'Efeitos sonoros';

  @override
  String get prefSoundEffectsDesc =>
      'Toca os sons clássicos da interface do The Sims nos cliques, nas chaves e nos avisos';

  @override
  String get prefAnalyticsTitle => 'Compartilhar dados de uso anônimos';

  @override
  String get prefAnalyticsDesc =>
      'Envia estatísticas de uso e relatórios de erro anônimos para ajudar a melhorar o app. Nunca inclui nomes de mods, caminhos de arquivo ou qualquer coisa pessoal';

  @override
  String get themeTitle => 'Tema';

  @override
  String get themeDesc =>
      'Claro ou escuro. “Sistema” segue a configuração do seu computador.';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get languageTitle => 'Idioma do app';

  @override
  String get languageDesc =>
      'Escolha em que idioma o app aparece. “Sistema” segue o idioma do seu computador.';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get translatorsTitle => 'Traduzido por';

  @override
  String get translatorsDesc =>
      'O app fala onze idiomas graças a estes simmers.';

  @override
  String get folderNotFound => 'Não encontrada. Escolha uma pasta';

  @override
  String get folderNotLocated =>
      'O jogo (ou a pasta de mods dele) não foi localizado automaticamente';

  @override
  String folderSummary(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods',
      one: '1 mod',
      zero: '0 mods',
    );
    return '$_temp0 · $size no disco';
  }

  @override
  String get customFolder => 'pasta personalizada';

  @override
  String get change => 'Mudar…';

  @override
  String get resetToAuto => 'Voltar ao automático';

  @override
  String createDefaultFolderAt(String path) {
    return 'Criar a pasta padrão (com os arquivos que o jogo precisa) em:\n$path';
  }

  @override
  String get createFolder => 'Criar pasta';

  @override
  String get alsoFoundOnThisComputer => 'Também encontradas neste computador:';

  @override
  String get clearCacheTitle => 'Limpar arquivos de cache';

  @override
  String clearCacheDesc(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Apaga $count arquivos de cache ($size)',
      one: 'Apaga 1 arquivo de cache ($size)',
    );
    return '$_temp0 para o conteúdo recém-adicionado ou removido aparecer; o jogo recria eles na próxima vez que abrir';
  }

  @override
  String get clearCaches => 'Limpar cache';

  @override
  String get ignoredConflictsTitle => 'Conflitos que você está ignorando';

  @override
  String ignoredConflictsDesc(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count conflitos que você mandou o app parar de avisar. Traga eles de volta pra ver de novo na biblioteca',
      one:
          'Um conflito que você mandou o app parar de avisar. Traga ele de volta pra ver de novo na biblioteca',
    );
    return '$_temp0';
  }

  @override
  String get ignoredConflictsReset => 'Trazer de volta';

  @override
  String get reportBugTitle => 'Relatar um bug';

  @override
  String get reportBugDesc =>
      'Abre um relatório de bug no GitHub com a versão do app, o sistema operacional e o jogo atual já preenchidos';

  @override
  String get reportBugButton => 'Relatar…';

  @override
  String get suggestFeatureTitle => 'Sugerir um recurso';

  @override
  String get suggestFeatureDesc =>
      'Está faltando alguma coisa? Conta pra gente o que deixaria o gerenciador de mods melhor';

  @override
  String get suggestFeatureButton => 'Sugerir…';

  @override
  String get wikiTitle => 'Guia e perguntas frequentes';

  @override
  String get wikiDesc =>
      'Como instalar mods, resolver a detecção de pastas e muito mais, na wiki do projeto';

  @override
  String get wikiButton => 'Abrir a wiki';

  @override
  String aboutTagline(String version) {
    return 'Versão $version · Compatível com The Sims 1-4 · SimCity em breve';
  }

  @override
  String updateIsAvailable(String version) {
    return 'A versão $version já está disponível';
  }

  @override
  String get noUpdateFound => 'Nenhuma atualização encontrada';

  @override
  String getVersion(String version) {
    return 'Baixar v$version';
  }

  @override
  String get checkingForUpdates => 'Verificando…';

  @override
  String get checkForUpdates => 'Verificar atualizações';

  @override
  String get categoryPackage => 'Pacote';

  @override
  String get categoryScript => 'Script';

  @override
  String get categoryObject => 'Objeto';

  @override
  String get categoryArchive => 'Arquivo';

  @override
  String get categorySkin => 'Skin';

  @override
  String get categoryTexture => 'Textura';

  @override
  String get categoryWall => 'Parede';

  @override
  String get categoryFloor => 'Piso';

  @override
  String get contentCasParts => 'peças do CAS';

  @override
  String get contentObjects => 'objetos';

  @override
  String get contentTunings => 'tunings';

  @override
  String get contentBehaviors => 'comportamentos';

  @override
  String get contentTextTables => 'tabelas de texto';

  @override
  String get contentTextures => 'texturas';

  @override
  String get contentMeshes => 'malhas';

  @override
  String errorNoModFiles(String extensions, String name) {
    return 'Nenhum arquivo de mod ($extensions) dentro de $name.';
  }

  @override
  String errorUnreadableArchive(String name) {
    return '$name não é um zip que este app consiga ler.';
  }

  @override
  String errorNoUnpacker(String format, String name) {
    return 'Nada neste computador consegue descompactar arquivos $format. Descompacte $name por conta própria e instale os arquivos de dentro.';
  }

  @override
  String errorNoUnpackerLinux(String format, String name) {
    return 'Nada neste computador consegue descompactar arquivos $format. Instale p7zip e tente de novo, ou descompacte $name por conta própria e instale os arquivos de dentro.';
  }

  @override
  String errorNoUnpackerLinuxRar(String format, String name) {
    return 'Nada neste computador consegue descompactar arquivos $format. Instale p7zip ou unrar e tente de novo, ou descompacte $name por conta própria e instale os arquivos de dentro.';
  }

  @override
  String errorUnpackFailed(String name) {
    return 'Não deu para descompactar $name. Ele pode estar protegido por senha, ser parte de um arquivo dividido ou ser um download corrompido. Descompacte na mão e instale os arquivos de dentro.';
  }

  @override
  String errorSims3PackUnreadable(String name) {
    return '$name não é um pacote do The Sims 3 que este app consiga ler.';
  }

  @override
  String errorSims3PackWorld(String name) {
    return '$name é um mundo, não conteúdo personalizado. Instale pelo Launcher do The Sims 3: o jogo guarda os mundos fora da pasta de mods.';
  }

  @override
  String errorSims3PackLibrary(String name) {
    return '$name é um terreno ou uma família, não conteúdo personalizado. Instale pelo Launcher do The Sims 3: ele vai parar na sua Biblioteca dentro do jogo.';
  }

  @override
  String errorInstallFailed(String name, String reason) {
    return 'Não deu para instalar “$name”: $reason. Se continuar falhando, descompacte na mão e instale os arquivos de dentro.';
  }

  @override
  String errorInstallFailedRaw(String name, String reason) {
    return 'Não deu para instalar “$name”: $reason';
  }

  @override
  String errorFileInUseDelete(String name) {
    return 'Não deu para excluir “$name”: outro programa está usando o arquivo (o jogo está aberto?) ou ele está protegido contra gravação. Feche o que estiver usando e tente de novo.';
  }

  @override
  String errorFileInUseRename(String name) {
    return 'Não deu para renomear “$name”: outro programa está usando o arquivo (o jogo está aberto?) ou ele está protegido contra gravação. Feche o que estiver usando e tente de novo.';
  }

  @override
  String errorFileNameTaken(String name) {
    return 'Já tem um “$name” nessa pasta. Renomeie um dos dois e tente de novo.';
  }

  @override
  String errorFolderNameBad(String name) {
    return '“$name” não serve como nome de pasta. Tente um sem barras nem caracteres que o sistema reserva.';
  }

  @override
  String errorFolderTooDeep(int levels) {
    return 'O jogo só olha $levels pastas para dentro da pasta de mods, então nada que você colocar mais fundo seria carregado.';
  }

  @override
  String errorBulkMoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods não puderam ser movidos',
      one: '1 mod não pôde ser movido',
    );
    return '$_temp0 - podem estar em uso por outro programa (o jogo está aberto?), protegidos contra gravação, ou já existe um arquivo com o mesmo nome na pasta.';
  }

  @override
  String errorBulkToggleFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods não puderam ser alterados',
      one: '1 mod não pôde ser alterado',
    );
    return '$_temp0 - podem estar em uso por outro programa (o jogo está aberto?) ou protegidos contra gravação.';
  }

  @override
  String errorBulkRemoveFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods não puderam ser apagados',
      one: '1 mod não pôde ser apagado',
    );
    return '$_temp0 - podem estar em uso por outro programa (o jogo está aberto?) ou protegidos contra gravação.';
  }

  @override
  String errorFileMissing(String name) {
    return '“$name” não está mais na pasta de mods: outro programa pode ter movido ou excluído o arquivo.';
  }

  @override
  String get requirementMedievalModLoader =>
      'The Sims Medieval não roda mods de script nem de núcleo sem o arquivo carregador da comunidade na pasta Game\\Bin do jogo. Conteúdo personalizado funciona; o resto não.';

  @override
  String get requirementSims4ModsOff =>
      'O jogo está com conteúdo personalizado e mods desligados nas Opções de jogo dele, então nada disso está carregando. Liga de novo em Opções → Opções de jogo → Outros e reinicia o jogo.';

  @override
  String get requirementSims4ScriptModsOff =>
      'Você tem mods de script aqui, mas o jogo está com “Permitir mods de script” desligado nas Opções de jogo. As atualizações resetam isso.';

  @override
  String get requirementGetFile => 'Onde baixar';

  @override
  String tooDeepBanner(int count, int levels) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tem $count mods',
      one: 'Tem um mod',
    );
    return '$_temp0 numa subpasta que o jogo não lê. Ele só olha $levels pastas pra dentro: sobe eles um pouco e vão carregar.';
  }

  @override
  String get tooDeepShow => 'Mostra quais';

  @override
  String get duplicatesFind => 'Procurar mods repetidos';

  @override
  String duplicatesScanning(int done, int total) {
    return 'Lendo os mods que podem estar repetidos… $done de $total';
  }

  @override
  String get duplicatesStop => 'Parar';

  @override
  String duplicatesBanner(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mods são o mesmo arquivo que outros',
      one: 'Um mod é o mesmo arquivo que outro',
    );
    return '$_temp0 - dá pra recuperar $size.';
  }

  @override
  String get duplicatesShow => 'Mostra quais';

  @override
  String get duplicatesSelectExtras => 'Marcar as cópias sobrando';

  @override
  String get duplicatesClean => 'Não tem nada repetido aqui.';

  @override
  String get duplicatesDismiss => 'Beleza';

  @override
  String tagTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tags de $count mods',
      one: 'Tags desse mod',
    );
    return '$_temp0';
  }

  @override
  String get tagBody =>
      'Suas próprias tags, pra achar as coisas depois. Toca numa pra colocar ou tirar.';

  @override
  String get tagHint => 'Tag nova';

  @override
  String get tagAdd => 'Adicionar';

  @override
  String get tagDone => 'Pronto';

  @override
  String get tagHeading => 'Tags';

  @override
  String get tagAddFirst => 'Adicionar uma tag';

  @override
  String tagRemove(String tag) {
    return 'Tirar “$tag”';
  }

  @override
  String get selectionTag => 'Etiquetar…';

  @override
  String folderAlsoReading(String folders) {
    return 'Seu jogo também lê $folders, então os mods que estão lá também aparecem nesta biblioteca.';
  }

  @override
  String errorNoWriteAccess(String folder) {
    return 'O app não tem permissão para escrever em “$folder”. O sistema protege essa pasta: dá permissão de escrita pra sua conta, ou escolhe outra pasta nas Configurações.';
  }

  @override
  String get folderReadOnlyBanner =>
      'Esta pasta de mods é somente leitura, então instalar e remover mods não vai funcionar até sua conta poder escrever nela.';

  @override
  String get elevatedNoDropBanner =>
      'Você está rodando como administrador, então o Windows não deixa arrastar arquivos para a janela. Use o botão Instalar, que continua funcionando.';

  @override
  String errorShopDownload(String name) {
    return '“$name” não pôde ser baixado do The Exchange. Confira sua conexão e tente de novo.';
  }

  @override
  String errorShopNoModFiles(String name) {
    return 'Não tem nada que este jogo consiga instalar dentro de “$name”. Pode nem ser um mod - usa Baixar para salvar o arquivo onde você quiser.';
  }

  @override
  String get errorShopListingNotFound =>
      'Esse mod não está mais na The Exchange. Pode ter sido tirado do ar.';

  @override
  String get errorShopListingUnknownGame =>
      'Esse mod é de um jogo que esta versão do app ainda não conhece. Tenta atualizar.';

  @override
  String errorPackToggleFailed(String pack) {
    return 'Não deu pra mudar $pack. Fecha o jogo e tenta de novo.';
  }

  @override
  String get errorPackNoUserData =>
      'Não achei a pasta de configurações do jogo, então não tem onde anotar quais pacotes pular. Abre o jogo uma vez primeiro.';

  @override
  String get errorPackNeedsAdmin =>
      'O Windows não deixou o app mudar isso. Reinicia como administrador e tenta de novo.';

  @override
  String get errorPackNotSupported =>
      'Neste sistema não dá pra ligar e desligar pacotes.';

  @override
  String get errorPackIsTheGame =>
      'Esse é o pacote de onde o jogo roda, então precisa continuar ligado.';

  @override
  String get errorPackToggleRefused =>
      'Não deu pra mudar esse pacote. Fecha o jogo e tenta de novo.';

  @override
  String get eraClassic => 'Clássico';

  @override
  String get eraNightlife => 'Vida Noturna';

  @override
  String get eraAmbitions => 'Ambições';

  @override
  String get eraModern => 'Moderno';

  @override
  String get eraMedieval => 'Medieval';

  @override
  String get navPacks => 'Pacotes';

  @override
  String get packsScanning => 'Procurando seus pacotes…';

  @override
  String get packsEmptyTitle => 'Nenhum pacote encontrado';

  @override
  String packsEmptyBody(String game) {
    return 'Ou o $game não está instalado onde o app consegue ver, ou ainda não há pacotes junto dele.';
  }

  @override
  String get packsRescan => 'Procurar de novo';

  @override
  String packsSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pacotes instalados',
      one: '1 pacote instalado',
    );
    return '$_temp0';
  }

  @override
  String packsSummaryWithOff(int count, int off) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pacotes ativos',
      one: '1 pacote ativo',
    );
    return '$_temp0, $off desativados';
  }

  @override
  String get packsOff => 'Desativado';

  @override
  String get packsInstalled => 'Instalado';

  @override
  String get packsNeedAdmin =>
      'Ligar e desligar esses pacotes precisa de permissão de administrador, porque é aí que o jogo guarda a lista dele. Reinicia o app como administrador pra mexer neles - enquanto isso o arrastar e soltar para de funcionar, então vale voltar depois.';

  @override
  String get packsExperimentalTitle => 'Desligar esses é experimental';

  @override
  String get packsExperimentalOff =>
      'Funciona como sempre funcionou nesse jogo, mas ninguém testou nesta edição, e um bairro que você jogou com um pacote pode quebrar se abrir sem ele. Só ver é seguro. Liga os interruptores experimentais nos Ajustes se quiser tentar mesmo assim.';

  @override
  String get packsExperimentalOn =>
      'Faz backup dos teus bairros antes. Um bairro que você jogou com um pacote pode quebrar se abrir sem ele, e não dá pra desfazer isso por aqui: religar o pacote nem sempre traz o save de volta.';

  @override
  String packsRestartNotice(String game) {
    return 'Reinicia o $game pra isso valer. Seus pacotes continuam instalados de qualquer jeito.';
  }

  @override
  String packsAllOwnedSims4(String expansions, String gamePacks) {
    return '$expansions pacotes de expansão. $gamePacks pacotes de jogo. Comprou todos, né?';
  }

  @override
  String get packKindExpansions => 'Pacotes de expansão';

  @override
  String get packKindGamePacks => 'Pacotes de jogo';

  @override
  String get packKindStuffPacks => 'Pacotes de objetos';

  @override
  String get packKindKits => 'Kits';

  @override
  String get packKindFreePacks => 'Pacotes grátis';

  @override
  String get navSaves => 'Saves';

  @override
  String get savesScanning => 'Lendo seus saves…';

  @override
  String get savesEmptyTitle => 'Nenhum save encontrado';

  @override
  String savesEmptyBody(String game) {
    return 'Quando você jogar $game e salvar, seus mundos vão aparecer aqui: famílias, fotos e tudo mais.';
  }

  @override
  String get savesRescan => 'Procurar de novo';

  @override
  String savesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saves encontrados',
      one: '1 save encontrado',
    );
    return '$_temp0';
  }

  @override
  String savesLastSaved(String date) {
    return 'Salvo pela última vez em $date';
  }

  @override
  String get savesShowInFolder => 'Mostrar na pasta';

  @override
  String savesBackups(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count backups',
      one: '1 backup',
    );
    return '$_temp0';
  }

  @override
  String get savesTabHouseholds => 'Famílias';

  @override
  String get savesTabAlbum => 'Álbum de fotos';

  @override
  String get savesTabStats => 'Estatísticas';

  @override
  String savesNeighborhood(int number) {
    return 'Bairro $number';
  }

  @override
  String get savesOtherHouseholds => 'NPCs e outras famílias';

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
  String get savesFunds => 'Fundos';

  @override
  String get savesRooms => 'Cômodos';

  @override
  String savesBedsBaths(int beds, int baths) {
    return '$beds quartos · $baths banheiros';
  }

  @override
  String savesByCreator(String name) {
    return 'de $name';
  }

  @override
  String get savesMembers => 'Membros';

  @override
  String get savesRelationships => 'Relacionamentos';

  @override
  String get savesUnknownSim => 'Sim desconhecido';

  @override
  String get savesStatSims => 'Sims';

  @override
  String get savesStatHouseholds => 'Famílias';

  @override
  String get savesStatNetWorth => 'Patrimônio';

  @override
  String get savesStatWorlds => 'Mundos';

  @override
  String get savesStatPhotos => 'Fotos';

  @override
  String savesAcrossHouseholds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'em $count famílias',
      one: 'em 1 família',
    );
    return '$_temp0';
  }

  @override
  String savesPlayedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jogadas',
      one: '1 jogada',
    );
    return '$_temp0';
  }

  @override
  String get savesSizeOnDisk => 'Espaço em disco';

  @override
  String get savesLifeStages => 'Fases da vida';

  @override
  String get savesTopSkills => 'Maiores habilidades deste save';

  @override
  String get savesSaveInfo => 'Arquivo de save';

  @override
  String get savesLastSavedLabel => 'Último salvamento';

  @override
  String get savesGameVersion => 'Versão do jogo';

  @override
  String get savesDescription => 'Descrição';

  @override
  String get savesAgeInfant => 'Recém-nascido';

  @override
  String get savesAgeBaby => 'Bebê';

  @override
  String get savesAgeToddler => 'Criança pequena';

  @override
  String get savesAgeChild => 'Criança';

  @override
  String get savesAgeTeen => 'Adolescente';

  @override
  String get savesAgeYoungAdult => 'Jovem adulto';

  @override
  String get savesAgeAdult => 'Adulto';

  @override
  String get savesAgeElder => 'Idoso';

  @override
  String get savesGenderMale => 'Masculino';

  @override
  String get savesGenderFemale => 'Feminino';

  @override
  String get savesSkillCooking => 'Culinária';

  @override
  String get savesSkillMechanical => 'Mecânica';

  @override
  String get savesSkillCharisma => 'Carisma';

  @override
  String get savesSkillBody => 'Corpo';

  @override
  String get savesSkillLogic => 'Lógica';

  @override
  String get savesSkillCreativity => 'Criatividade';

  @override
  String get savesSkillCleaning => 'Limpeza';

  @override
  String get savesPersonalityNeat => 'Organizado';

  @override
  String get savesPersonalityOutgoing => 'Extrovertido';

  @override
  String get savesPersonalityActive => 'Ativo';

  @override
  String get savesPersonalityPlayful => 'Brincalhão';

  @override
  String get savesPersonalityNice => 'Gentil';

  @override
  String get savesZodiacAries => 'Áries';

  @override
  String get savesZodiacTaurus => 'Touro';

  @override
  String get savesZodiacGemini => 'Gêmeos';

  @override
  String get savesZodiacCancer => 'Câncer';

  @override
  String get savesZodiacLeo => 'Leão';

  @override
  String get savesZodiacVirgo => 'Virgem';

  @override
  String get savesZodiacLibra => 'Libra';

  @override
  String get savesZodiacScorpio => 'Escorpião';

  @override
  String get savesZodiacSagittarius => 'Sagitário';

  @override
  String get savesZodiacCapricorn => 'Capricórnio';

  @override
  String get savesZodiacAquarius => 'Aquário';

  @override
  String get savesZodiacPisces => 'Peixes';

  @override
  String get savesAspirationRomance => 'Romance';

  @override
  String get savesAspirationFamily => 'Família';

  @override
  String get savesAspirationFortune => 'Fortuna';

  @override
  String get savesAspirationPopularity => 'Popularidade';

  @override
  String get savesAspirationKnowledge => 'Conhecimento';

  @override
  String get savesAspirationGrowUp => 'Crescer';

  @override
  String get savesAspirationPleasure => 'Prazer';

  @override
  String get savesAspirationGrilledCheese => 'Queijo quente';

  @override
  String get savesRelCrush => 'paquera';

  @override
  String get savesRelLove => 'apaixonados';

  @override
  String get savesRelEngaged => 'noivos';

  @override
  String get savesRelMarried => 'casados';

  @override
  String get savesRelFriends => 'amigos';

  @override
  String get savesRelBestFriends => 'melhores amigos';

  @override
  String get savesRelSteady => 'namorando';

  @override
  String get savesRelEnemies => 'inimigos';

  @override
  String get savesPhotoFamilyPortrait => 'Retrato da família';

  @override
  String get savesPhotoLot => 'Lote';

  @override
  String get savesPhotoSim => 'Retrato de Sim';

  @override
  String get savesPhotoSnapshot => 'Foto';

  @override
  String get savesProperty => 'Patrimônio';

  @override
  String get savesGhost => 'fantasma';

  @override
  String savesCareerLevel(String career, int level) {
    return '$career · nível $level';
  }

  @override
  String get savesSpeciesLargeDog => 'cão';

  @override
  String get savesSpeciesSmallDog => 'cão pequeno';

  @override
  String get savesSpeciesCat => 'gato';

  @override
  String get savesOccultVampire => 'vampiro';

  @override
  String get savesOccultZombie => 'zumbi';

  @override
  String get savesOccultWerewolf => 'lobisomem';

  @override
  String get savesOccultPlantSim => 'PlantSim';

  @override
  String get savesOccultAlien => 'alienígena';

  @override
  String get savesOccultServo => 'servo';

  @override
  String get savesOccultWitch => 'bruxa';

  @override
  String get savesOccultBigfoot => 'Pé Grande';

  @override
  String get savesOccultFairy => 'fada';

  @override
  String get savesOccultGenie => 'gênio';

  @override
  String get savesOccultMermaid => 'sereia';

  @override
  String get savesLotResidential => 'Residencial';

  @override
  String get savesLotCommunity => 'Lote comunitário';

  @override
  String get savesLotDorm => 'Dormitório';

  @override
  String get savesLotSecretSociety => 'Sociedade secreta';

  @override
  String get savesLotGreekHouse => 'República';

  @override
  String get savesLotHotel => 'Hotel';

  @override
  String get savesLotSecret => 'Lote secreto';

  @override
  String get savesLotBusiness => 'Negócio';

  @override
  String get savesLotApartment => 'Apartamento';

  @override
  String savesGpa(String gpa) {
    return 'média $gpa';
  }

  @override
  String savesSemester(int number) {
    return 'semestre $number';
  }

  @override
  String savesPredestinedHobby(String hobby) {
    return 'Nasceu para $hobby';
  }

  @override
  String get savesHobbyCuisine => 'Culinária';

  @override
  String get savesHobbyArts => 'Artesanato';

  @override
  String get savesHobbyFilm => 'Cinema e literatura';

  @override
  String get savesHobbySports => 'Esportes';

  @override
  String get savesHobbyGames => 'Jogos';

  @override
  String get savesHobbyNature => 'Natureza';

  @override
  String get savesHobbyTinkering => 'Bricolagem';

  @override
  String get savesHobbyFitness => 'Fitness';

  @override
  String get savesHobbyScience => 'Ciência';

  @override
  String get savesHobbyMusic => 'Música e dança';

  @override
  String get savesTieMother => 'mãe';

  @override
  String get savesTieFather => 'pai';

  @override
  String get savesTieSpouse => 'casado com';

  @override
  String savesTieSibling(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'irmãos',
      one: 'irmão',
    );
    return '$_temp0';
  }

  @override
  String savesTieChild(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'filhos',
      one: 'filho',
    );
    return '$_temp0';
  }

  @override
  String get savesInterestPolitics => 'Política';

  @override
  String get savesInterestMoney => 'Dinheiro';

  @override
  String get savesInterestEnvironment => 'Meio ambiente';

  @override
  String get savesInterestCrime => 'Crime';

  @override
  String get savesInterestEntertainment => 'Entretenimento';

  @override
  String get savesInterestCulture => 'Cultura';

  @override
  String get savesInterestFood => 'Comida';

  @override
  String get savesInterestHealth => 'Saúde';

  @override
  String get savesInterestFashion => 'Moda';

  @override
  String get savesInterestSports => 'Esportes';

  @override
  String get savesInterestParanormal => 'Paranormal';

  @override
  String get savesInterestTravel => 'Viagens';

  @override
  String get savesInterestWork => 'Trabalho';

  @override
  String get savesInterestWeather => 'Clima';

  @override
  String get savesInterestAnimals => 'Animais';

  @override
  String get savesInterestSchool => 'Escola';

  @override
  String get savesInterestToys => 'Brinquedos';

  @override
  String get savesInterestSciFi => 'Ficção científica';

  @override
  String get savesInterestMusic => 'Música';

  @override
  String get savesInterestOutdoors => 'Ar livre';

  @override
  String get setupHelpSims1 =>
      'O The Sims original guarda o conteúdo personalizado dentro da pasta de instalação, não em Documentos: os objetos vão para uma pasta Downloads ao lado do executável do jogo (por exemplo C:\\Program Files (x86)\\Maxis\\The Sims\\Downloads), e este app organiza os outros tipos sozinho: skins (.skn/.cmx/.bmp) vão para GameData\\Skins, paredes e pisos para GameData\\Walls e GameData\\Floors. A Legacy Collection de 2025 funciona do mesmo jeito a partir da própria pasta de instalação (EA Games\\The Sims Legacy, ou Steam\\steamapps\\common\\The Sims Legacy Collection). Se o jogo estiver instalado em outro lugar (outro disco, uma biblioteca do Steam personalizada), escolha a pasta Downloads dele manualmente.';

  @override
  String get setupHelpSims2 =>
      'O The Sims 2 carrega o conteúdo personalizado de Documentos > EA Games > The Sims 2 > Downloads (a Ultimate Collection usa “The Sims 2 Ultimate Collection”; a Legacy Collection de 2025 usa “The Sims 2 Legacy”). A pasta pode não existir até você criar ela ou instalar algum conteúdo pela primeira vez. Quando o jogo abrir, responda “Sim” ao aviso sobre conteúdo personalizado para liberar os downloads.';

  @override
  String get setupHelpSims3 =>
      'O The Sims 3 não cria a pasta de mods sozinho: ele precisa do “framework” da comunidade, ou seja, uma pasta Mods > Packages dentro de Documentos > Electronic Arts > The Sims 3, mais um arquivo Resource.cfg dizendo ao jogo para ler ela. Este app cria as duas coisas pra você. Em instalações de disco ou via Wine a pasta pode ficar dentro do próprio pacote do jogo; use “Escolher pasta” para apontar pra ela.';

  @override
  String get setupHelpSims4 =>
      'O The Sims 4 carrega os mods de Documentos > Electronic Arts > The Sims 4 > Mods. O jogo cria essa pasta na primeira vez que roda, então abra o jogo uma vez se ela não estiver lá. Depois, dentro do jogo, ative Opções > Opções de jogo > Outros > “Ativar conteúdo personalizado e mods” (e “Permitir mods de script” para os arquivos .ts4script) e reinicie o jogo.';

  @override
  String get setupHelpSimsMedieval =>
      'O The Sims Medieval carrega os mods da pasta de instalação, não de Documentos: uma pasta Mods > Packages ao lado dos arquivos do jogo (por exemplo C:\\Program Files (x86)\\Origin Games\\The Sims Medieval), mais um arquivo Resource.cfg na pasta de instalação dizendo ao jogo para ler ela. Este app cria as duas coisas pra você (o Windows pode pedir permissão de administrador dentro de Arquivos de Programas). A pasta Documentos > Electronic Arts > The Sims Medieval só guarda os saves; mods colocados lá não fazem nada. Para instalações com Wine/CrossOver ou numa biblioteca do Steam personalizada, use “Escolher pasta” e aponte para a pasta Mods > Packages de dentro da instalação.';
}
