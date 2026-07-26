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
  String get navSettings => 'Configurações';

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
  String get install => 'Instalar';

  @override
  String filePickerModsLabel(String game) {
    return 'Mods de $game';
  }

  @override
  String get statTotal => 'Total';

  @override
  String get statEnabled => 'Ativos';

  @override
  String get statDisabled => 'Inativos';

  @override
  String get statConflicts => 'Conflitos';

  @override
  String get conflictTooltipActive =>
      'Mostrando só os mods em conflito. Clique para ver todos de novo.';

  @override
  String get conflictTooltip =>
      'Mods ativos que dividem o nome de arquivo com outro mod ativo, que estão instalados em mais de uma versão ou que sobrescrevem os mesmos recursos do jogo. O jogo só fica com a cópia que carrega por último — às vezes isso é de propósito (mods de patch), muitas vezes não.';

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
      'Estes pacotes têm recursos com os mesmos identificadores, então o jogo só fica com a cópia que carrega por último. Isso pode ser de propósito — mods de patch e de override cobrem os recursos de outro mod intencionalmente —, mas entre mods sem relação significa que um deles simplesmente para de funcionar sem avisar: fique com o que você quer e desative os outros.';

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
      'O app fala dez idiomas graças a estes simmers.';

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
  String errorInstallFailed(String name, String reason) {
    return 'Não deu para instalar “$name” — $reason. Se continuar falhando, descompacte na mão e instale os arquivos de dentro.';
  }

  @override
  String errorInstallFailedRaw(String name, String reason) {
    return 'Não deu para instalar “$name” — $reason';
  }

  @override
  String errorFileInUseDelete(String name) {
    return 'Não deu para excluir “$name” — outro programa está usando o arquivo (o jogo está aberto?) ou ele está protegido contra gravação. Feche o que estiver usando e tente de novo.';
  }

  @override
  String errorFileInUseRename(String name) {
    return 'Não deu para renomear “$name” — outro programa está usando o arquivo (o jogo está aberto?) ou ele está protegido contra gravação. Feche o que estiver usando e tente de novo.';
  }

  @override
  String errorFileMissing(String name) {
    return '“$name” não está mais na pasta de mods — outro programa pode ter movido ou excluído o arquivo.';
  }

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
  String get setupHelpSims1 =>
      'O The Sims original guarda o conteúdo personalizado dentro da pasta de instalação, não em Documentos: os objetos vão para uma pasta Downloads ao lado do executável do jogo (por exemplo C:\\Program Files (x86)\\Maxis\\The Sims\\Downloads), e este app organiza os outros tipos sozinho — skins (.skn/.cmx/.bmp) vão para GameData\\Skins, paredes e pisos para GameData\\Walls e GameData\\Floors. A Legacy Collection de 2025 funciona do mesmo jeito a partir da própria pasta de instalação (EA Games\\The Sims Legacy, ou Steam\\steamapps\\common\\The Sims Legacy Collection). Se o jogo estiver instalado em outro lugar (outro disco, uma biblioteca do Steam personalizada), escolha a pasta Downloads dele manualmente.';

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
