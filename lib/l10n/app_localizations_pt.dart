// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get fiveMinutesADay => '\'5 min/dia\'';

  @override
  String get fifteenMinutesADay => '\'15 min/dia\'';

  @override
  String get thirtyMinutesADay => '\'30 min/dia\'';

  @override
  String get oneHourADay => '\'1 h/dia\'';

  @override
  String get activeFilters => 'Filtros ativos';

  @override
  String get addedByUser => 'Adicionado por você';

  @override
  String get all => 'Todos os níveis';

  @override
  String get allLevels => 'Todos';

  @override
  String get answers => 'respostas';

  @override
  String get appTitle => 'Fluemingo';

  @override
  String get apply => 'Aplicar';

  @override
  String areYouSureYouWantToDeleteWord(Object word) {
    return 'Tem certeza de que deseja excluir $word da lista de vocabulário?';
  }

  @override
  String areYouSureYouWantToDeleteReferenceLanguage(Object languageName) {
    return 'Tem certeza de que deseja alterar o seu idioma de referência para $languageName?\n\nEsta alteração afetará as palavras já traduzidas.';
  }

  @override
  String areYouSureYouWantToDeleteTargetLanguage(Object languageName) {
    return 'Tem certeza de que deseja alterar o seu idioma de aprendizagem para $languageName?\n\nEsta alteração afetará as palavras já traduzidas.';
  }

  @override
  String get art => 'Arte';

  @override
  String get article => 'Artigo';

  @override
  String get audiobooks => 'Audiolivros';

  @override
  String get back => 'Voltar';

  @override
  String get biography => 'Biografia';

  @override
  String get buildA => 'construir um';

  @override
  String get cancel => 'Cancelar';

  @override
  String get changeStatus => 'Alterar estado';

  @override
  String get changeLanguage => 'Alterar idioma';

  @override
  String get chapters => 'Capítulos';

  @override
  String get cinema => 'Cinema';

  @override
  String get chooseYourAnswer => 'Escolha uma resposta';

  @override
  String get clickOnPlusToAddThisExpressionToYourVocabularyList =>
      'Clique em + para adicionar esta expressão ao seu vocabulário';

  @override
  String get clickOnXToRemoveThisExpressionFromYourVocabularyList =>
      'Clique em x para remover esta expressão do seu vocabulário';

  @override
  String get completedQuizzes => 'Questionários concluídos';

  @override
  String get confirm => 'Confirmar';

  @override
  String get contentInProgress => 'Conteúdo em andamento';

  @override
  String get continueReadingToEarnXP => 'Continue lendo para ganhar XP';

  @override
  String get connexion => 'Conexão';

  @override
  String get continueWithApple => 'Continuar com Apple';

  @override
  String get continueWithFacebook => 'Continuar com Facebook';

  @override
  String get continueWithGoogle => 'Continuar com Google';

  @override
  String get culture => 'Cultura';

  @override
  String get dailyGoal => 'Objetivo diário';

  @override
  String get definition => 'Definição';

  @override
  String get delete => 'Excluir';

  @override
  String get deleteVocabularyItem => 'Excluir este item do vocabulário';

  @override
  String get difficult => 'Difícil';

  @override
  String get difficultVocabulary => 'Vocabulário difícil';

  @override
  String get downloadForOfflineAccess => 'Baixar para acesso offline';

  @override
  String get edit => 'Editar';

  @override
  String get education => 'Educação';

  @override
  String get extreme => 'Extremo';

  @override
  String get fashion => 'Moda';

  @override
  String get expressionAddedToFlashcards =>
      'Expressão adicionada aos cartões de memória';

  @override
  String get favoritesArticlesOnly => 'Apenas artigos favoritos';

  @override
  String get favoritesAudiobooksOnly => 'Apenas audiolivros favoritos';

  @override
  String get favoriteContent => 'Conteúdo favorito';

  @override
  String get favoriteThemes => 'Temas favoritos';

  @override
  String get fiction => 'Ficção';

  @override
  String get filters => 'Filtros';

  @override
  String get finished => 'Concluído';

  @override
  String get finishedArticles => 'Artigos concluídos';

  @override
  String get finishedAudiobooks => 'Audiolivros concluídos';

  @override
  String get finishedChaptersAudiobooks => 'Capítulos de áudio';

  @override
  String get flashcardsVocabulary => 'Cartões de vocabulário';

  @override
  String get fontSize => 'Tamanho da fonte';

  @override
  String goalIntensity(String intensity) {
    String _temp0 = intl.Intl.selectLogic(
      intensity,
      {
        'light': 'leve',
        'regular': 'regular',
        'high': 'alto',
        'extreme': 'extremo',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String goalDuration(String duration) {
    String _temp0 = intl.Intl.selectLogic(
      duration,
      {
        'fiveMinutesADay': '5 min/dia',
        'fifteenMinutesADay': '15 min/dia',
        'thirtyMinutesADay': '30 min/dia',
        'oneHourADay': '1 h/dia',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get gastronomy => 'Gastronomia';

  @override
  String get grammarPoints => 'Regras de gramática';

  @override
  String get greetings => 'Olá';

  @override
  String get health => 'Saúde';

  @override
  String get high => 'alto';

  @override
  String get history => 'História';

  @override
  String get inProgress => 'Em andamento';

  @override
  String get includeFinishedArticles => 'Incluir artigos concluídos';

  @override
  String get includeFinishedAudiobooks => 'Incluir audiolivros concluídos';

  @override
  String get interestingContent => 'Conteúdo adaptado aos seus temas favoritos';

  @override
  String get items => 'Expressões';

  @override
  String get languages => 'Línguas estrangeiras';

  @override
  String get languageEn => 'Inglês';

  @override
  String get languageFr => 'Francês';

  @override
  String get languageEs => 'Espanhol';

  @override
  String get languageDe => 'Alemão';

  @override
  String get languageNl => 'Neerlandês';

  @override
  String get languageIt => 'Italiano';

  @override
  String get languagePt => 'Português';

  @override
  String get languageJa => 'Japonês';

  @override
  String get learn => 'Aprender';

  @override
  String get literature => 'Literatura';

  @override
  String get level => 'Nível';

  @override
  String get light => 'Leve';

  @override
  String get mainVocabulary => 'Vocabulário principal';

  @override
  String get mastered => 'Dominado';

  @override
  String get masteredFlashcards => 'Cartões aprendidos';

  @override
  String get masteredVocabulary => 'Vocabulário dominado';

  @override
  String get music => 'Música';

  @override
  String get navAudiobooks => 'Audiolivros';

  @override
  String get navFlashcards => 'Cartões';

  @override
  String get navLibrary => 'Artigos';

  @override
  String get navProfile => 'Perfil';

  @override
  String get noAudiobooksFound => 'Nenhum audiolivro encontrado';

  @override
  String get noArticlesFound => 'Nenhum artigo encontrado';

  @override
  String get noAudioAvailableForThisArticle =>
      'Nenhum áudio disponível para este artigo';

  @override
  String get noQuizAvailableForThisArticle =>
      'Nenhum questionário disponível para este artigo';

  @override
  String get noVocabularyItemsFound => 'Nenhum item de vocabulário encontrado';

  @override
  String get news => 'Atualidades';

  @override
  String get next => 'Seguinte';

  @override
  String get notStarted => 'Não iniciado';

  @override
  String get people => 'Pessoas';

  @override
  String get poetry => 'Poesia';

  @override
  String get previous => 'Anterior';

  @override
  String get quiz => 'Questionário';

  @override
  String get quizCompleted => 'Questionário concluído!';

  @override
  String get readFlashcards => 'Ler cartões';

  @override
  String get regular => 'Regular';

  @override
  String get repeat => 'Praticar';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get saved => 'Salvo';

  @override
  String get savedVocabulary => 'Vocabulário guardado';

  @override
  String get science => 'Ciência';

  @override
  String get selectGoal => 'Selecione um objetivo para se manter motivado';

  @override
  String selectUpToThemes(Object maxSelection) {
    return 'Selecione até $maxSelection temas.';
  }

  @override
  String get setHowManyXpYouWant =>
      'Defina quantos XP você quer ganhar por semana.';

  @override
  String get signInWithApple => 'Entrar com Apple';

  @override
  String get signInWithFacebook => 'Continuar com o Facebook';

  @override
  String get signInWithGoogle => 'Entrar com o Google';

  @override
  String get showOnlyFavoriteArticles => 'Mostrar apenas artigos favoritos';

  @override
  String get showOnlyFavoriteAudiobooks =>
      'Mostrar apenas audiolivros favoritos';

  @override
  String get society => 'Sociedade';

  @override
  String get space => 'Espaço';

  @override
  String get sport => 'Esporte';

  @override
  String get startToRead => 'Começar a Ler';

  @override
  String get strongLastingVocabulary => 'Vocabulário forte e duradouro';

  @override
  String get tale => 'Conto';

  @override
  String get targetLanguage => 'Língua que quero aprender';

  @override
  String get technology => 'Tecnologia';

  @override
  String get testYourKnowledge => 'Teste seus conhecimentos';

  @override
  String get training => 'Treino';

  @override
  String get trainingVocabulary => 'Vocabulário de treino';

  @override
  String get travel => 'Viagens';

  @override
  String get themes => 'Temas';

  @override
  String get tryAgain => 'Tentar novamente';

  @override
  String get sourceLanguage => 'Língua de referência';

  @override
  String get subscription => 'Assinatura';

  @override
  String get upgradeToPremium => 'Atualizar para Premium';

  @override
  String get manageSubscription => 'Gerir assinatura';

  @override
  String get unlockWithPremium => 'Desbloquear com Premium';

  @override
  String get vocabulary => 'Vocabulário';

  @override
  String get vocabularyAcquired => 'Vocabulário adquirido';

  @override
  String get vocabularyForTraining => 'Vocabulário de treino';

  @override
  String get watersports => 'Esportes aquáticos';

  @override
  String get week => 'semana';

  @override
  String get weekProgress => 'Esta semana';

  @override
  String weeklyGoal(Object goal) {
    return 'Objetivo semanal: $goal XP';
  }

  @override
  String get weekGoal => 'Objetivo semanal';

  @override
  String get whichLanguageDoYouWantToLearn => 'Qual idioma você quer aprender?';

  @override
  String get selectOne => 'Selecione um';

  @override
  String get whichLanguageDoYouSpeakTheBest => 'Qual idioma você fala melhor?';

  @override
  String get withYour => 'com o seu';

  @override
  String get unknown => 'Desconhecido';

  @override
  String get xpPerWeek => 'XP por semana';

  @override
  String get yoga => 'Yoga';

  @override
  String get yourSavedVocabulary => 'Vocabulário salvo';

  @override
  String get yourPersonalVocabulary => 'Vocabulário pessoal';

  @override
  String get yourProgress => 'Progresso geral';

  @override
  String get yourWeekProgress => 'Progresso semanal';

  @override
  String get yourWeeklyGoal => 'O seu objetivo semanal';

  @override
  String get rateTheApp => 'Avaliar o app';

  @override
  String get rateTheAppStoreUnavailable =>
      'Store indisponível (teste num dispositivo real).';
}
