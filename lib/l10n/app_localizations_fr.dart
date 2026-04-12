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
      'Appuyez sur l\'icône corbeille pour retirer cette expression du vocabulaire';

  @override
  String get completedQuizzes => 'Questionnaires réalisés';

  @override
  String get confirm => 'Confirmer';

  @override
  String get contentInProgress => 'Contenu en cours';

  @override
  String get continueReadingToEarnXP => 'Continue à lire pour gagner des XP';

  @override
  String get continueButton => 'Continuer';

  @override
  String get contentFittingYou =>
      'Du contenu qui vous correspond parfaitement :';

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
  String get forYou => 'Pour vous';

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
  String get learn => 'Apprenez le';

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
  String get navFlashcards => 'Vocabulaire';

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
  String get philosophy => 'Philosophie';

  @override
  String get psychology => 'Psychologie';

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
  String get dailyLimitReached =>
      'Limite quotidienne atteinte. Réessayez demain.';

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
  String daysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'jours restants',
      one: 'jour restant',
    );
    return '$days $_temp0';
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
      'Quelle langue souhaitez-vous utiliser comme référence ?';

  @override
  String get withWord => 'Avec';

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

  @override
  String get flashcardCategoryUpdated => 'Catégorie de flashcard mise à jour';

  @override
  String get flashcardMastered =>
      'Félicitations, vous avez maîtrisé une nouvelle expression ! +1 XP';

  @override
  String get noFlashcardsAvailable => 'Aucun flashcard disponible';

  @override
  String get noFlashcardsFound => 'Aucun flashcard trouvé';

  @override
  String get deleteFlashcard => 'Supprimer le flashcard';

  @override
  String get noContentInProgress => 'Aucun contenu en cours';

  @override
  String get noLikedContentYet => 'Aucun contenu aimé pour l\'instant';

  @override
  String get noSuggestionsYet => 'Aucune suggestion pour l\'instant';

  @override
  String get yourContentInProgress => 'Votre contenu en cours';

  @override
  String get yourFavoriteContent => 'Votre contenu favori';

  @override
  String get yourContent => 'Votre contenu';

  @override
  String get finishContentToEarnXP => 'Terminez ce contenu pour gagner des XP';

  @override
  String get basedOnYourLikes => 'Basé sur vos coups de cœur';

  @override
  String get basedOnYourFavoriteThemes => 'Basé sur vos thèmes favoris';

  @override
  String get save => 'Enregistrer';

  @override
  String get pleaseSelectAtLeastOneTheme =>
      'Veuillez sélectionner au moins un thème';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get downloading => 'Téléchargement...';

  @override
  String get availableOffline => 'Disponible hors ligne';

  @override
  String get downloadedForOfflineAccess =>
      'Téléchargé pour un accès hors ligne';

  @override
  String get goBack => 'Retour';

  @override
  String get noAudioAvailable => 'Aucun audio disponible';

  @override
  String get pleaseEnterValidNumber =>
      'Veuillez entrer un nombre positif valide';

  @override
  String get yourTargetLanguage => 'Votre langue cible';

  @override
  String get yourReferenceLanguage => 'Votre langue de référence';

  @override
  String get oops => 'Oups';

  @override
  String get weeklyGoalReached => 'Objectif hebdomadaire atteint !';

  @override
  String get wellDone => 'Bravo !';

  @override
  String youEarnedXp(Object xp) {
    return 'Tu as gagné $xp XP !';
  }

  @override
  String get quizFinishedMarkArticleAsFinished =>
      'Tu as terminé le quiz ! Veux-tu aussi marquer l\'article comme terminé ?';

  @override
  String get quizFinishedMarkChapterAsFinished =>
      'Tu as terminé le quiz ! Veux-tu aussi marquer le chapitre comme terminé ?';

  @override
  String get congratsQuizAndArticle => 'Tu as terminé le quiz et l\'article !';

  @override
  String get congratsQuizAndChapter => 'Tu as terminé le quiz et le chapitre !';

  @override
  String get congratsQuiz => 'Tu as terminé le quiz !';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get vocabularyAddedToList => 'Vocabulaire ajouté à la liste';

  @override
  String get retranslate => 'Re-traduire';

  @override
  String get withContent => 'avec du contenu';

  @override
  String get yourTaste => 'vos goûts, votre niveau, votre rythme';

  @override
  String get fitTasteLevel => 'qui correspond à vos goûts et à votre niveau';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountConfirmation =>
      'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible et toutes vos données seront définitivement supprimées.';

  @override
  String get accountDeleted => 'Votre compte a été supprimé.';

  @override
  String get deleteAccountError =>
      'Impossible de supprimer le compte. Veuillez réessayer.';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String get termsAndPrivacyNotice =>
      'En vous connectant, vous acceptez nos Conditions d\'utilisation et notre Politique de confidentialité.';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get purchasesRestored => 'Achats restaurés avec succès.';

  @override
  String get restorePurchasesFailed => 'Impossible de restaurer les achats.';

  @override
  String get orContinueWith => 'ou continuer avec';

  @override
  String get signInWithEmail => 'Se connecter par email';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get enterEmailAndPassword =>
      'Entrez votre email et votre mot de passe pour vous connecter.';

  @override
  String get signIn => 'Se connecter';

  @override
  String get start => 'Commencer';

  @override
  String get downloadFailed => 'Échec du téléchargement';

  @override
  String get errorPlayingAudio => 'Erreur de lecture audio';

  @override
  String get errorSeekingAudio => 'Erreur de positionnement audio';

  @override
  String get errorSavingThemes => 'Erreur lors de la sauvegarde des thèmes';

  @override
  String get errorUpdatingStatus => 'Impossible de mettre à jour le statut';

  @override
  String get errorUpdatingGoal => 'Impossible de mettre à jour l\'objectif';

  @override
  String get errorUpdatingTargetLanguage =>
      'Impossible de mettre à jour la langue cible';

  @override
  String get errorUpdatingReferenceLanguage =>
      'Impossible de mettre à jour la langue de référence';

  @override
  String get errorLoggingOut => 'Échec de la déconnexion';

  @override
  String get authenticationError => 'Erreur d\'authentification';

  @override
  String get signInFailed => 'Échec de la connexion';

  @override
  String get noParagraphsAvailable => 'Aucun paragraphe disponible';

  @override
  String get supabaseConfigMissing =>
      'Configuration Supabase manquante. Lancez l\'app avec --dart-define-from-file=.env';
}
