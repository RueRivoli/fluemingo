// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get fiveMinutesADay => '\'5 min/jour\'';

  @override
  String get fifteenMinutesADay => '\'15 min/jour\'';

  @override
  String get thirtyMinutesADay => '\'30 min/jour\'';

  @override
  String get oneHourADay => '\'1 h/jour\'';

  @override
  String get activeFilters => 'Filtres actifs';

  @override
  String get addedByUser => 'Ajouté par vous';

  @override
  String get all => 'Tous';

  @override
  String get allLevels => 'Tous';

  @override
  String get answers => 'réponses';

  @override
  String get appTitle => 'Fluemingo';

  @override
  String get apply => 'Appliquer';

  @override
  String areYouSureYouWantToDeleteWord(Object word) {
    return 'Êtes-vous sûr de vouloir supprimer $word de la liste du vocabulaire ?';
  }

  @override
  String areYouSureYouWantToDeleteReferenceLanguage(Object languageName) {
    return 'Êtes-vous sûr de vouloir changer votre langue de référence pour $languageName ?\n\nCe changement aura un effet sur les mots déjà traduits.';
  }

  @override
  String areYouSureYouWantToDeleteTargetLanguage(Object languageName) {
    return 'Êtes-vous sûr de vouloir changer votre langue cible pour $languageName ?\n\nCe changement aura un effet sur les mots déjà traduits.';
  }

  @override
  String get art => 'Art';

  @override
  String get article => 'Article';

  @override
  String get audiobooks => 'Livres audio';

  @override
  String get back => 'Retour';

  @override
  String get biography => 'Biographie';

  @override
  String get buildA => 'Développez un';

  @override
  String get cancel => 'Annuler';

  @override
  String get changeStatus => 'Changer le statut';

  @override
  String get changeLanguage => 'Changer la langue';

  @override
  String get chapters => 'Chapitres';

  @override
  String get cinema => 'Cinéma';

  @override
  String get chooseYourAnswer => 'Choisissez une réponse';

  @override
  String get clickOnPlusToAddThisExpressionToYourVocabularyList =>
      'Cliquez sur + pour ajouter cette expression au vocabulaire';

  @override
  String get clickOnXToRemoveThisExpressionFromYourVocabularyList =>
      'Cliquez sur x pour retirer cette expression du vocabulaire';

  @override
  String get completedQuizzes => 'Questionnaires réalisés';

  @override
  String get confirm => 'Confirmer';

  @override
  String get contentInProgress => 'Contenu en cours';

  @override
  String get continueReadingToEarnXP => 'Continue à lire pour gagner des XP';

  @override
  String get connexion => 'Connexion';

  @override
  String get continueWithApple => 'Continuer avec Apple';

  @override
  String get continueWithFacebook => 'Continuer avec Facebook';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get culture => 'Culture';

  @override
  String get dailyGoal => 'Objectif quotidien';

  @override
  String get definition => 'Définition';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteVocabularyItem => 'Supprimer cet élément du vocabulaire';

  @override
  String get difficult => 'Difficile';

  @override
  String get difficultVocabulary => 'Vocabulaire difficile';

  @override
  String get downloadForOfflineAccess => 'Télécharger pour un accès hors ligne';

  @override
  String get edit => 'Éditer';

  @override
  String get education => 'Éducation';

  @override
  String get extreme => 'Extrême';

  @override
  String get fashion => 'Mode';

  @override
  String get expressionAddedToFlashcards =>
      'Expression ajoutée aux cartes de mémorisation';

  @override
  String get favoritesArticlesOnly => 'Uniquement les articles likés';

  @override
  String get favoritesAudiobooksOnly => 'Uniquement les livres audio likés';

  @override
  String get favoriteContent => 'Contenu préféré';

  @override
  String get favoriteThemes => 'Thèmes favoris';

  @override
  String get fiction => 'Fiction';

  @override
  String get filters => 'Filtres';

  @override
  String get finished => 'Terminé';

  @override
  String get finishedArticles => 'Articles terminés';

  @override
  String get finishedAudiobooks => 'Livres audio terminés';

  @override
  String get finishedChaptersAudiobooks => 'Chapitres audio';

  @override
  String get flashcardsVocabulary => 'Cartes mémoire de vocabulaire';

  @override
  String get fontSize => 'Taille de police';

  @override
  String goalIntensity(String intensity) {
    String _temp0 = intl.Intl.selectLogic(
      intensity,
      {
        'light': 'léger',
        'regular': 'régulier',
        'high': 'élevé',
        'extreme': 'extrême',
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
        'fiveMinutesADay': '5 min/jour',
        'fifteenMinutesADay': '15 min/jour',
        'thirtyMinutesADay': '30 min/jour',
        'oneHourADay': '1 h/jour',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get gastronomy => 'Gastronomie';

  @override
  String get grammarPoints => 'Règles de grammaire';

  @override
  String get greetings => 'Bonjour';

  @override
  String get health => 'Santé';

  @override
  String get high => 'élevé';

  @override
  String get history => 'Histoire';

  @override
  String get inProgress => 'En cours';

  @override
  String get includeFinishedArticles => 'Inclure les articles terminés';

  @override
  String get includeFinishedAudiobooks => 'Inclure les livres audio terminés';

  @override
  String get interestingContent => 'Contenu adapté à vos thèmes favoris';

  @override
  String get items => 'Expressions';

  @override
  String get languages => 'Langues étrangères';

  @override
  String get languageEn => 'Anglais';

  @override
  String get languageFr => 'Français';

  @override
  String get languageEs => 'Espagnol';

  @override
  String get languageDe => 'Allemand';

  @override
  String get languageNl => 'Néerlandais';

  @override
  String get languageIt => 'Italien';

  @override
  String get languagePt => 'Portugais';

  @override
  String get languageJa => 'Japonais';

  @override
  String get learn => 'Apprenez';

  @override
  String get literature => 'Littérature';

  @override
  String get level => 'Niveau';

  @override
  String get light => 'Léger';

  @override
  String get mainVocabulary => 'Vocabulaire principal';

  @override
  String get mastered => 'Acquis';

  @override
  String get masteredFlashcards => 'Cartes mémoire apprises';

  @override
  String get masteredVocabulary => 'Vocabulaire acquis';

  @override
  String get music => 'Musique';

  @override
  String get navAudiobooks => 'Livres audio';

  @override
  String get navFlashcards => 'Cartes mémoire';

  @override
  String get navLibrary => 'Articles';

  @override
  String get navProfile => 'Profil';

  @override
  String get noAudiobooksFound => 'Aucun livre audio trouvé';

  @override
  String get noArticlesFound => 'Aucun article trouvé';

  @override
  String get noAudioAvailableForThisArticle =>
      'Pas d\'audio disponible pour cet article';

  @override
  String get noQuizAvailableForThisArticle =>
      'Pas de quiz disponible pour cet article';

  @override
  String get noVocabularyItemsFound => 'Vocabulaire vide';

  @override
  String get news => 'Actualité';

  @override
  String get next => 'Suivant';

  @override
  String get notStarted => 'Pas commencé';

  @override
  String get people => 'People';

  @override
  String get poetry => 'Poésie';

  @override
  String get previous => 'Précédent';

  @override
  String get quiz => 'Quiz';

  @override
  String get quizCompleted => 'Quiz complété !';

  @override
  String get readFlashcards => 'Lire les cartes mémoire';

  @override
  String get regular => 'Régulier';

  @override
  String get repeat => 'S\'entraîner';

  @override
  String get retry => 'Réessayer';

  @override
  String get saved => 'Sauvegardé';

  @override
  String get savedVocabulary => 'Vocabulaire sauvegardé';

  @override
  String get science => 'Science';

  @override
  String get selectGoal => 'Choisissez un objectif pour rester motivé';

  @override
  String selectUpToThemes(Object maxSelection) {
    return 'Choisissez jusqu\'à $maxSelection thèmes.';
  }

  @override
  String get setHowManyXpYouWant =>
      'Définissez combien de XP vous voulez gagner par semaine.';

  @override
  String get signInWithApple => 'Se connecter avec Apple';

  @override
  String get signInWithFacebook => 'Continuer avec Facebook';

  @override
  String get signInWithGoogle => 'Se connecter avec Google';

  @override
  String get showOnlyFavoriteArticles =>
      'Afficher uniquement les articles likés';

  @override
  String get showOnlyFavoriteAudiobooks =>
      'Afficher uniquement les livres audio likés';

  @override
  String get society => 'Société';

  @override
  String get space => 'Espace';

  @override
  String get sport => 'Sport';

  @override
  String get startToRead => 'Commencer à Lire';

  @override
  String get strongLastingVocabulary => 'Vocabulaire solide et durable';

  @override
  String get tale => 'Conte';

  @override
  String get targetLanguage => 'Langue que je veux apprendre';

  @override
  String get technology => 'Technologie';

  @override
  String get testYourKnowledge => 'Testez vos connaissances';

  @override
  String get training => 'Entraînement';

  @override
  String get trainingVocabulary => 'Vocabulaire d\'entraînement';

  @override
  String get travel => 'Voyage';

  @override
  String get themes => 'Thèmes';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get sourceLanguage => 'Langue de référence';

  @override
  String get subscription => 'Abonnement';

  @override
  String get upgradeToPremium => 'Passer à Premium';

  @override
  String get manageSubscription => 'Gérer l\'abonnement';

  @override
  String get unlockWithPremium => 'Débloquer avec Premium';

  @override
  String get vocabulary => 'Vocabulaire';

  @override
  String get vocabularyAcquired => 'Vocabulaire acquis';

  @override
  String get vocabularyForTraining => 'Vocab. d\'entraînement';

  @override
  String get watersports => 'Sports aquatiques';

  @override
  String get week => 'semaine';

  @override
  String get weekProgress => 'Cette semaine';

  @override
  String weeklyGoal(Object goal) {
    return 'Objectif hebdomadaire : $goal XP';
  }

  @override
  String get weekGoal => 'Objectif hebdomadaire';

  @override
  String get whichLanguageDoYouWantToLearn =>
      'Quelle langue voulez-vous apprendre ?';

  @override
  String get selectOne => 'Choisissez une option';

  @override
  String get whichLanguageDoYouSpeakTheBest =>
      'Quelle langue parlez-vous le mieux ?';

  @override
  String get withYour => 'avec votre';

  @override
  String get unknown => 'Inconnu';

  @override
  String get xpPerWeek => 'XP par semaine';

  @override
  String get yoga => 'Yoga';

  @override
  String get yourSavedVocabulary => 'Vocabulaire sauvegardé';

  @override
  String get yourPersonalVocabulary => 'Vocabulaire personnel';

  @override
  String get yourProgress => 'Bilan global';

  @override
  String get yourWeekProgress => 'Bilan de la semaine';

  @override
  String get yourWeeklyGoal => 'Votre objectif hebdomadaire';

  @override
  String get rateTheApp => 'Noter l\'app';

  @override
  String get rateTheAppStoreUnavailable =>
      'Store indisponible (testez sur un appareil réel ou configurez l\'App Store ID).';
}
