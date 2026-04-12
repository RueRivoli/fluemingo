// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get fiveMinutesADay => '\'5 min/dag\'';

  @override
  String get fifteenMinutesADay => '\'15 min/dag\'';

  @override
  String get thirtyMinutesADay => '\'30 min/dag\'';

  @override
  String get oneHourADay => '\'1 u/dag\'';

  @override
  String get activeFilters => 'Actieve filters';

  @override
  String get addedByUser => 'Door jou toegevoegd';

  @override
  String get all => 'Alle niveaus';

  @override
  String get allLevels => 'Alle';

  @override
  String get answers => 'antwoorden';

  @override
  String get appTitle => 'Fluemingo';

  @override
  String get apply => 'Toepassen';

  @override
  String areYouSureYouWantToDeleteWord(Object word) {
    return 'Weet je zeker dat je $word uit de woordenlijst wilt verwijderen?';
  }

  @override
  String areYouSureYouWantToDeleteReferenceLanguage(Object languageName) {
    return 'Weet je zeker dat je je referentietaal wilt wijzigen naar $languageName?\n\nDeze wijziging heeft gevolgen voor eerder vertaalde woorden.';
  }

  @override
  String areYouSureYouWantToDeleteTargetLanguage(Object languageName) {
    return 'Weet je zeker dat je je doeltaal wilt wijzigen naar $languageName?\n\nDeze wijziging heeft gevolgen voor eerder vertaalde woorden.';
  }

  @override
  String get art => 'Kunst';

  @override
  String get article => 'Artikel';

  @override
  String get audiobooks => 'Luisterboeken';

  @override
  String get back => 'Terug';

  @override
  String get biography => 'Biografie';

  @override
  String get buildA => 'bouw een';

  @override
  String get cancel => 'Annuleren';

  @override
  String get changeStatus => 'Status wijzigen';

  @override
  String get changeLanguage => 'Taal wijzigen';

  @override
  String get chapters => 'Hoofdstukken';

  @override
  String get cinema => 'Film';

  @override
  String get chooseYourAnswer => 'Kies een antwoord';

  @override
  String get clickOnPlusToAddThisExpressionToYourVocabularyList =>
      'Klik op + om deze uitdrukking aan je woordenlijst toe te voegen';

  @override
  String get clickOnXToRemoveThisExpressionFromYourVocabularyList =>
      'Tik op het prullenbak-icoon om deze uitdrukking uit je woordenlijst te verwijderen';

  @override
  String get completedQuizzes => 'Voltooide quizzen';

  @override
  String get confirm => 'Bevestigen';

  @override
  String get contentInProgress => 'Lopende inhoud';

  @override
  String get continueReadingToEarnXP => 'Blijf lezen om XP te verdienen';

  @override
  String get continueButton => 'Doorgaan';

  @override
  String get contentFittingYou => 'Content die perfect bij jou past:';

  @override
  String get connexion => 'Inloggen';

  @override
  String get continueWithApple => 'Doorgaan met Apple';

  @override
  String get continueWithFacebook => 'Doorgaan met Facebook';

  @override
  String get continueWithGoogle => 'Doorgaan met Google';

  @override
  String get culture => 'Cultuur';

  @override
  String get dailyGoal => 'Dagelijks doel';

  @override
  String get definition => 'Definitie';

  @override
  String get delete => 'Verwijderen';

  @override
  String get deleteVocabularyItem => 'Dit woordenlijstitem verwijderen';

  @override
  String get difficult => 'Moeilijk';

  @override
  String get difficultVocabulary => 'Moeilijke woordenschat';

  @override
  String get downloadForOfflineAccess => 'Downloaden voor offline toegang';

  @override
  String get edit => 'Bewerken';

  @override
  String get education => 'Onderwijs';

  @override
  String get extreme => 'Extreem';

  @override
  String get fashion => 'Mode';

  @override
  String get expressionAddedToFlashcards =>
      'Uitdrukking toegevoegd aan flashcards';

  @override
  String get favoritesArticlesOnly => 'Alleen favoriete artikelen';

  @override
  String get favoritesAudiobooksOnly => 'Alleen favoriete luisterboeken';

  @override
  String get favoriteContent => 'Favoriete inhoud';

  @override
  String get favoriteThemes => 'Favoriete thema\'s';

  @override
  String get fiction => 'Fictie';

  @override
  String get filters => 'Filters';

  @override
  String get finished => 'Voltooid';

  @override
  String get finishedArticles => 'Voltooide artikelen';

  @override
  String get finishedAudiobooks => 'Voltooide luisterboeken';

  @override
  String get finishedChaptersAudiobooks => 'Audiohoofdstukken';

  @override
  String get flashcardsVocabulary => 'Woordenschat-flashcards';

  @override
  String get fontSize => 'Lettergrootte';

  @override
  String goalIntensity(String intensity) {
    String _temp0 = intl.Intl.selectLogic(
      intensity,
      {
        'light': 'licht',
        'regular': 'regelmatig',
        'high': 'hoog',
        'extreme': 'extreem',
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
        'fiveMinutesADay': '5 min/dag',
        'fifteenMinutesADay': '15 min/dag',
        'thirtyMinutesADay': '30 min/dag',
        'oneHourADay': '1 u/dag',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get gastronomy => 'Gastronomie';

  @override
  String get grammarPoints => 'Grammaticaregels';

  @override
  String get greetings => 'Hallo';

  @override
  String get health => 'Gezondheid';

  @override
  String get high => 'hoog';

  @override
  String get history => 'Geschiedenis';

  @override
  String get inProgress => 'Bezig';

  @override
  String get includeFinishedArticles => 'Voltooide artikelen opnemen';

  @override
  String get includeFinishedAudiobooks => 'Voltooide luisterboeken opnemen';

  @override
  String get interestingContent => 'Inhoud afgestemd op je favoriete thema\'s';

  @override
  String get forYou => 'Voor jou';

  @override
  String get items => 'Uitdrukkingen';

  @override
  String get languages => 'Vreemde talen';

  @override
  String get languageEn => 'Engels';

  @override
  String get languageFr => 'Frans';

  @override
  String get languageEs => 'Spaans';

  @override
  String get languageDe => 'Duits';

  @override
  String get languageNl => 'Nederlands';

  @override
  String get languageIt => 'Italiaans';

  @override
  String get languagePt => 'Portugees';

  @override
  String get languageJa => 'Japans';

  @override
  String get learn => 'Leer';

  @override
  String get literature => 'Literatuur';

  @override
  String get level => 'Niveau';

  @override
  String get light => 'Licht';

  @override
  String get mainVocabulary => 'Hoofdwoordenschat';

  @override
  String get mastered => 'Geleerd';

  @override
  String get masteredFlashcards => 'Geleerde flashcards';

  @override
  String get masteredVocabulary => 'Geleerde woordenschat';

  @override
  String get music => 'Muziek';

  @override
  String get navAudiobooks => 'Luisterboeken';

  @override
  String get navFlashcards => 'Woordenschat';

  @override
  String get navLibrary => 'Artikelen';

  @override
  String get navProfile => 'Profiel';

  @override
  String get noAudiobooksFound => 'Geen luisterboeken gevonden';

  @override
  String get noArticlesFound => 'Geen artikelen gevonden';

  @override
  String get noAudioAvailableForThisArticle =>
      'Geen audio beschikbaar voor dit artikel';

  @override
  String get noQuizAvailableForThisArticle =>
      'Geen quiz beschikbaar voor dit artikel';

  @override
  String get noVocabularyItemsFound => 'Geen woordenschat gevonden';

  @override
  String get news => 'Nieuws';

  @override
  String get next => 'Volgende';

  @override
  String get notStarted => 'Niet begonnen';

  @override
  String get people => 'Mensen';

  @override
  String get philosophy => 'Filosofie';

  @override
  String get psychology => 'Psychologie';

  @override
  String get poetry => 'Poëzie';

  @override
  String get previous => 'Vorige';

  @override
  String get quiz => 'Quiz';

  @override
  String get quizCompleted => 'Quiz voltooid!';

  @override
  String get readFlashcards => 'Flashcards lezen';

  @override
  String get regular => 'Regelmatig';

  @override
  String get repeat => 'Oefenen';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get dailyLimitReached =>
      'Dagelijkse limiet bereikt. Probeer het morgen opnieuw.';

  @override
  String get saved => 'Opgeslagen';

  @override
  String get savedVocabulary => 'Opgeslagen woordenschat';

  @override
  String get science => 'Wetenschap';

  @override
  String get selectGoal => 'Kies een doel om gemotiveerd te blijven';

  @override
  String selectUpToThemes(Object maxSelection) {
    return 'Selecteer tot $maxSelection thema\'s.';
  }

  @override
  String get setHowManyXpYouWant =>
      'Stel in hoeveel XP je per week wilt verdienen.';

  @override
  String get signInWithApple => 'Inloggen met Apple';

  @override
  String get signInWithFacebook => 'Doorgaan met Facebook';

  @override
  String get signInWithGoogle => 'Inloggen met Google';

  @override
  String get showOnlyFavoriteArticles => 'Alleen favoriete artikelen tonen';

  @override
  String get showOnlyFavoriteAudiobooks =>
      'Alleen favoriete luisterboeken tonen';

  @override
  String get society => 'Maatschappij';

  @override
  String get space => 'Ruimte';

  @override
  String get sport => 'Sport';

  @override
  String get startToRead => 'Begin met Lezen';

  @override
  String get strongLastingVocabulary => 'Sterke en blijvende woordenschat';

  @override
  String get tale => 'Sprookje';

  @override
  String get targetLanguage => 'Taal die ik wil leren';

  @override
  String get technology => 'Technologie';

  @override
  String get testYourKnowledge => 'Test je kennis';

  @override
  String get training => 'Oefenen';

  @override
  String get trainingVocabulary => 'Oefenwoordenschat';

  @override
  String get travel => 'Reizen';

  @override
  String get themes => 'Thema\'s';

  @override
  String get tryAgain => 'Opnieuw proberen';

  @override
  String get sourceLanguage => 'Brontaal';

  @override
  String get subscription => 'Abonnement';

  @override
  String get upgradeToPremium => 'Upgrade naar Premium';

  @override
  String get manageSubscription => 'Abonnement beheren';

  @override
  String get unlockWithPremium => 'Ontgrendel met Premium';

  @override
  String get vocabulary => 'Woordenschat';

  @override
  String get vocabularyAcquired => 'Geleerde woordenschat';

  @override
  String get vocabularyForTraining => 'Oefenwoordenschat';

  @override
  String get watersports => 'Watersport';

  @override
  String get week => 'week';

  @override
  String get weekProgress => 'Deze week';

  @override
  String weeklyGoal(Object goal) {
    return 'Weekdoel: $goal XP';
  }

  @override
  String daysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'dagen resterend',
      one: 'dag resterend',
    );
    return '$days $_temp0';
  }

  @override
  String get weekGoal => 'Weekdoel';

  @override
  String get whichLanguageDoYouWantToLearn => 'Welke taal wil je leren?';

  @override
  String get selectOne => 'Selecteer één';

  @override
  String get whichLanguageDoYouSpeakTheBest =>
      'Welke taal wil je gebruiken als referentie?';

  @override
  String get withWord => 'Met';

  @override
  String get withYour => 'met je';

  @override
  String get unknown => 'Onbekend';

  @override
  String get xpPerWeek => 'XP per week';

  @override
  String get yoga => 'Yoga';

  @override
  String get yourSavedVocabulary => 'Opgeslagen woordenschat';

  @override
  String get yourPersonalVocabulary => 'Persoonlijke woordenschat';

  @override
  String get yourProgress => 'Totale voortgang';

  @override
  String get yourWeekProgress => 'Wekelijkse voortgang';

  @override
  String get yourWeeklyGoal => 'Je weekdoel';

  @override
  String get rateTheApp => 'App beoordelen';

  @override
  String get rateTheAppStoreUnavailable =>
      'Store niet beschikbaar (test op een echt apparaat).';

  @override
  String get flashcardCategoryUpdated => 'Flashcard-categorie bijgewerkt';

  @override
  String get flashcardMastered =>
      'Gefeliciteerd, je hebt een nieuwe uitdrukking onder de knie! +1 XP';

  @override
  String get noFlashcardsAvailable => 'Geen flashcards beschikbaar';

  @override
  String get noFlashcardsFound => 'Geen flashcards gevonden';

  @override
  String get deleteFlashcard => 'Flashcard verwijderen';

  @override
  String get noContentInProgress => 'Geen inhoud in uitvoering';

  @override
  String get noLikedContentYet => 'Nog geen leuke inhoud';

  @override
  String get noSuggestionsYet => 'Nog geen suggesties';

  @override
  String get yourContentInProgress => 'Jouw inhoud in uitvoering';

  @override
  String get yourFavoriteContent => 'Jouw favoriete inhoud';

  @override
  String get yourContent => 'Jouw inhoud';

  @override
  String get finishContentToEarnXP => 'Voltooi deze inhoud om XP te verdienen';

  @override
  String get basedOnYourLikes => 'Gebaseerd op je likes';

  @override
  String get basedOnYourFavoriteThemes => 'Gebaseerd op je favoriete thema\'s';

  @override
  String get save => 'Opslaan';

  @override
  String get pleaseSelectAtLeastOneTheme =>
      'Selecteer alstublieft minimaal één thema';

  @override
  String get logout => 'Uitloggen';

  @override
  String get downloading => 'Downloaden...';

  @override
  String get availableOffline => 'Offline beschikbaar';

  @override
  String get downloadedForOfflineAccess => 'Gedownload voor offline toegang';

  @override
  String get goBack => 'Terug';

  @override
  String get noAudioAvailable => 'Geen audio beschikbaar';

  @override
  String get pleaseEnterValidNumber => 'Voer een geldig positief getal in';

  @override
  String get yourTargetLanguage => 'Jouw doeltaal';

  @override
  String get yourReferenceLanguage => 'Jouw referentietaal';

  @override
  String get oops => 'Oeps';

  @override
  String get weeklyGoalReached => 'Weekdoel bereikt!';

  @override
  String get wellDone => 'Goed gedaan!';

  @override
  String youEarnedXp(Object xp) {
    return 'Je hebt $xp XP verdiend!';
  }

  @override
  String get quizFinishedMarkArticleAsFinished =>
      'Je hebt de quiz afgerond! Wil je het artikel ook als afgerond markeren?';

  @override
  String get quizFinishedMarkChapterAsFinished =>
      'Je hebt de quiz afgerond! Wil je het hoofdstuk ook als afgerond markeren?';

  @override
  String get congratsQuizAndArticle =>
      'Je hebt de quiz en het artikel afgerond!';

  @override
  String get congratsQuizAndChapter =>
      'Je hebt de quiz en het hoofdstuk afgerond!';

  @override
  String get congratsQuiz => 'Je hebt de quiz afgerond!';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nee';

  @override
  String get vocabularyAddedToList => 'Woordenschat toegevoegd aan de lijst';

  @override
  String get retranslate => 'Opnieuw vertalen';

  @override
  String get withContent => 'met content';

  @override
  String get yourTaste => 'jouw smaak, jouw niveau, jouw tempo';

  @override
  String get fitTasteLevel => 'die past bij jouw smaak en niveau';

  @override
  String get deleteAccount => 'Account verwijderen';

  @override
  String get deleteAccountConfirmation =>
      'Weet je zeker dat je je account wilt verwijderen? Deze actie is onomkeerbaar en al je gegevens worden permanent verwijderd.';

  @override
  String get accountDeleted => 'Je account is verwijderd.';

  @override
  String get deleteAccountError =>
      'Account kon niet worden verwijderd. Probeer het opnieuw.';

  @override
  String get privacyPolicy => 'Privacybeleid';

  @override
  String get termsOfService => 'Gebruiksvoorwaarden';

  @override
  String get termsAndPrivacyNotice =>
      'Door in te loggen ga je akkoord met onze Gebruiksvoorwaarden en ons Privacybeleid.';

  @override
  String get restorePurchases => 'Aankopen herstellen';

  @override
  String get purchasesRestored => 'Aankopen succesvol hersteld.';

  @override
  String get restorePurchasesFailed => 'Aankopen konden niet worden hersteld.';

  @override
  String get orContinueWith => 'of ga verder met';

  @override
  String get signInWithEmail => 'Inloggen met e-mail';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Wachtwoord';

  @override
  String get enterEmailAndPassword =>
      'Voer je e-mail en wachtwoord in om in te loggen.';

  @override
  String get signIn => 'Inloggen';

  @override
  String get start => 'Beginnen';

  @override
  String get downloadFailed => 'Download mislukt';

  @override
  String get errorPlayingAudio => 'Fout bij het afspelen van audio';

  @override
  String get errorSeekingAudio => 'Fout bij het positioneren van audio';

  @override
  String get errorSavingThemes => 'Fout bij het opslaan van thema\'s';

  @override
  String get errorUpdatingStatus => 'Status kon niet worden bijgewerkt';

  @override
  String get errorUpdatingGoal => 'Doel kon niet worden bijgewerkt';

  @override
  String get errorUpdatingTargetLanguage =>
      'Doeltaal kon niet worden bijgewerkt';

  @override
  String get errorUpdatingReferenceLanguage =>
      'Referentietaal kon niet worden bijgewerkt';

  @override
  String get errorLoggingOut => 'Uitloggen mislukt';

  @override
  String get authenticationError => 'Authenticatiefout';

  @override
  String get signInFailed => 'Inloggen mislukt';

  @override
  String get noParagraphsAvailable => 'Geen paragrafen beschikbaar';

  @override
  String get supabaseConfigMissing =>
      'Supabase-configuratie ontbreekt. Start de app met --dart-define-from-file=.env';
}
