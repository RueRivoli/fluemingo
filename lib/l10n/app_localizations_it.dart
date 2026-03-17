// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get fiveMinutesADay => '\'5 min/giorno\'';

  @override
  String get fifteenMinutesADay => '\'15 min/giorno\'';

  @override
  String get thirtyMinutesADay => '\'30 min/giorno\'';

  @override
  String get oneHourADay => '\'1 h/giorno\'';

  @override
  String get activeFilters => 'Filtri attivi';

  @override
  String get addedByUser => 'Aggiunto da te';

  @override
  String get all => 'Tutti i livelli';

  @override
  String get allLevels => 'Tutti';

  @override
  String get answers => 'risposte';

  @override
  String get appTitle => 'Fluemingo';

  @override
  String get apply => 'Applica';

  @override
  String areYouSureYouWantToDeleteWord(Object word) {
    return 'Sei sicuro di voler eliminare $word dalla lista del vocabolario?';
  }

  @override
  String areYouSureYouWantToDeleteReferenceLanguage(Object languageName) {
    return 'Sei sicuro di voler cambiare la tua lingua di riferimento in $languageName?\n\nQuesta modifica avrà effetto sulle parole già tradotte.';
  }

  @override
  String areYouSureYouWantToDeleteTargetLanguage(Object languageName) {
    return 'Sei sicuro di voler cambiare la tua lingua di apprendimento in $languageName?\n\nQuesta modifica avrà effetto sulle parole già tradotte.';
  }

  @override
  String get art => 'Arte';

  @override
  String get article => 'Articolo';

  @override
  String get audiobooks => 'Audiolibri';

  @override
  String get back => 'Indietro';

  @override
  String get biography => 'Biografia';

  @override
  String get buildA => 'costruire un';

  @override
  String get cancel => 'Annulla';

  @override
  String get changeStatus => 'Cambia stato';

  @override
  String get changeLanguage => 'Cambia lingua';

  @override
  String get chapters => 'Capitoli';

  @override
  String get cinema => 'Cinema';

  @override
  String get chooseYourAnswer => 'Scegli una risposta';

  @override
  String get clickOnPlusToAddThisExpressionToYourVocabularyList =>
      'Clicca su + per aggiungere questa espressione al tuo vocabolario';

  @override
  String get clickOnXToRemoveThisExpressionFromYourVocabularyList =>
      'Clicca su x per rimuovere questa espressione dal tuo vocabolario';

  @override
  String get completedQuizzes => 'Quiz completati';

  @override
  String get confirm => 'Conferma';

  @override
  String get contentInProgress => 'Contenuto in corso';

  @override
  String get continueReadingToEarnXP => 'Continua a leggere per guadagnare XP';

  @override
  String get connexion => 'Connessione';

  @override
  String get continueWithApple => 'Continua con Apple';

  @override
  String get continueWithFacebook => 'Continua con Facebook';

  @override
  String get continueWithGoogle => 'Continua con Google';

  @override
  String get culture => 'Cultura';

  @override
  String get dailyGoal => 'Obiettivo giornaliero';

  @override
  String get definition => 'Definizione';

  @override
  String get delete => 'Elimina';

  @override
  String get deleteVocabularyItem => 'Elimina questo elemento dal vocabolario';

  @override
  String get difficult => 'Difficile';

  @override
  String get difficultVocabulary => 'Vocabolario difficile';

  @override
  String get downloadForOfflineAccess => 'Scarica per l\'accesso offline';

  @override
  String get edit => 'Modifica';

  @override
  String get education => 'Istruzione';

  @override
  String get extreme => 'Estremo';

  @override
  String get fashion => 'Moda';

  @override
  String get expressionAddedToFlashcards =>
      'Espressione aggiunta alle schede di memoria';

  @override
  String get favoritesArticlesOnly => 'Solo articoli preferiti';

  @override
  String get favoritesAudiobooksOnly => 'Solo audiolibri preferiti';

  @override
  String get favoriteContent => 'Contenuto preferito';

  @override
  String get favoriteThemes => 'Temi preferiti';

  @override
  String get fiction => 'Narrativa';

  @override
  String get filters => 'Filtri';

  @override
  String get finished => 'Completato';

  @override
  String get finishedArticles => 'Articoli completati';

  @override
  String get finishedAudiobooks => 'Audiolibri completati';

  @override
  String get finishedChaptersAudiobooks => 'Capitoli audio';

  @override
  String get flashcardsVocabulary => 'Schede di vocabolario';

  @override
  String get fontSize => 'Dimensione del carattere';

  @override
  String goalIntensity(String intensity) {
    String _temp0 = intl.Intl.selectLogic(
      intensity,
      {
        'light': 'leggero',
        'regular': 'regolare',
        'high': 'alto',
        'extreme': 'estremo',
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
        'fiveMinutesADay': '5 min/giorno',
        'fifteenMinutesADay': '15 min/giorno',
        'thirtyMinutesADay': '30 min/giorno',
        'oneHourADay': '1 h/giorno',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get gastronomy => 'Gastronomia';

  @override
  String get grammarPoints => 'Regole di grammatica';

  @override
  String get greetings => 'Ciao';

  @override
  String get health => 'Salute';

  @override
  String get high => 'alto';

  @override
  String get history => 'Storia';

  @override
  String get inProgress => 'In corso';

  @override
  String get includeFinishedArticles => 'Includi articoli completati';

  @override
  String get includeFinishedAudiobooks => 'Includi audiolibri completati';

  @override
  String get interestingContent => 'Contenuto adatto ai tuoi temi preferiti';

  @override
  String get items => 'Espressioni';

  @override
  String get languages => 'Lingue straniere';

  @override
  String get languageEn => 'Inglese';

  @override
  String get languageFr => 'Francese';

  @override
  String get languageEs => 'Spagnolo';

  @override
  String get languageDe => 'Tedesco';

  @override
  String get languageNl => 'Olandese';

  @override
  String get languageIt => 'Italiano';

  @override
  String get languagePt => 'Portoghese';

  @override
  String get languageJa => 'Giapponese';

  @override
  String get learn => 'Imparare';

  @override
  String get literature => 'Letteratura';

  @override
  String get level => 'Livello';

  @override
  String get light => 'Leggero';

  @override
  String get mainVocabulary => 'Vocabolario principale';

  @override
  String get mastered => 'Acquisito';

  @override
  String get masteredFlashcards => 'Schede apprese';

  @override
  String get masteredVocabulary => 'Vocabolario acquisito';

  @override
  String get music => 'Musica';

  @override
  String get navAudiobooks => 'Audiolibri';

  @override
  String get navFlashcards => 'Schede';

  @override
  String get navLibrary => 'Articoli';

  @override
  String get navProfile => 'Profilo';

  @override
  String get noAudiobooksFound => 'Nessun audiolibro trovato';

  @override
  String get noArticlesFound => 'Nessun articolo trovato';

  @override
  String get noAudioAvailableForThisArticle =>
      'Nessun audio disponibile per questo articolo';

  @override
  String get noQuizAvailableForThisArticle =>
      'Nessun quiz disponibile per questo articolo';

  @override
  String get noVocabularyItemsFound => 'Nessun elemento di vocabolario trovato';

  @override
  String get news => 'Attualità';

  @override
  String get next => 'Avanti';

  @override
  String get notStarted => 'Non iniziato';

  @override
  String get people => 'Persone';

  @override
  String get poetry => 'Poesia';

  @override
  String get previous => 'Indietro';

  @override
  String get quiz => 'Quiz';

  @override
  String get quizCompleted => 'Quiz completato!';

  @override
  String get readFlashcards => 'Leggi le schede';

  @override
  String get regular => 'Regolare';

  @override
  String get repeat => 'Esercitarsi';

  @override
  String get retry => 'Riprova';

  @override
  String get saved => 'Salvato';

  @override
  String get savedVocabulary => 'Vocabolario salvato';

  @override
  String get science => 'Scienza';

  @override
  String get selectGoal => 'Seleziona un obiettivo per restare motivato';

  @override
  String selectUpToThemes(Object maxSelection) {
    return 'Seleziona fino a $maxSelection temi.';
  }

  @override
  String get setHowManyXpYouWant =>
      'Imposta quanti XP vuoi guadagnare a settimana.';

  @override
  String get signInWithApple => 'Accedi con Apple';

  @override
  String get signInWithFacebook => 'Continua con Facebook';

  @override
  String get signInWithGoogle => 'Accedi con Google';

  @override
  String get showOnlyFavoriteArticles => 'Mostra solo articoli preferiti';

  @override
  String get showOnlyFavoriteAudiobooks => 'Mostra solo audiolibri preferiti';

  @override
  String get society => 'Società';

  @override
  String get space => 'Spazio';

  @override
  String get sport => 'Sport';

  @override
  String get startToRead => 'Inizia a Leggere';

  @override
  String get strongLastingVocabulary => 'Vocabolario solido e duraturo';

  @override
  String get tale => 'Racconto';

  @override
  String get targetLanguage => 'Lingua che voglio imparare';

  @override
  String get technology => 'Tecnologia';

  @override
  String get testYourKnowledge => 'Metti alla prova le tue conoscenze';

  @override
  String get training => 'Allenamento';

  @override
  String get trainingVocabulary => 'Vocabolario di allenamento';

  @override
  String get travel => 'Viaggi';

  @override
  String get themes => 'Temi';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get sourceLanguage => 'Lingua di riferimento';

  @override
  String get subscription => 'Abbonamento';

  @override
  String get upgradeToPremium => 'Passa a Premium';

  @override
  String get manageSubscription => 'Gestisci abbonamento';

  @override
  String get unlockWithPremium => 'Sblocca con Premium';

  @override
  String get vocabulary => 'Vocabolario';

  @override
  String get vocabularyAcquired => 'Vocabolario acquisito';

  @override
  String get vocabularyForTraining => 'Vocabolario di allenamento';

  @override
  String get watersports => 'Sport acquatici';

  @override
  String get week => 'settimana';

  @override
  String get weekProgress => 'Questa settimana';

  @override
  String weeklyGoal(Object goal) {
    return 'Obiettivo settimanale: $goal XP';
  }

  @override
  String get weekGoal => 'Obiettivo settimanale';

  @override
  String get whichLanguageDoYouWantToLearn => 'Quale lingua vuoi imparare?';

  @override
  String get selectOne => 'Seleziona uno';

  @override
  String get whichLanguageDoYouSpeakTheBest => 'Quale lingua parli meglio?';

  @override
  String get withYour => 'con il tuo';

  @override
  String get unknown => 'Sconosciuto';

  @override
  String get xpPerWeek => 'XP a settimana';

  @override
  String get yoga => 'Yoga';

  @override
  String get yourSavedVocabulary => 'Vocabolario salvato';

  @override
  String get yourPersonalVocabulary => 'Vocabolario personale';

  @override
  String get yourProgress => 'Progresso generale';

  @override
  String get yourWeekProgress => 'Progresso settimanale';

  @override
  String get yourWeeklyGoal => 'Il tuo obiettivo settimanale';

  @override
  String get rateTheApp => 'Valuta l\'app';

  @override
  String get rateTheAppStoreUnavailable =>
      'Store non disponibile (prova su dispositivo reale o configura l\'ID App Store).';
}
