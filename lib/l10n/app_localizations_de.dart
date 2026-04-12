// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get fiveMinutesADay => '\'5 Min/Tag\'';

  @override
  String get fifteenMinutesADay => '\'15 Min/Tag\'';

  @override
  String get thirtyMinutesADay => '\'30 Min/Tag\'';

  @override
  String get oneHourADay => '\'1 Std/Tag\'';

  @override
  String get activeFilters => 'Aktive Filter';

  @override
  String get addedByUser => 'Von dir hinzugefügt';

  @override
  String get all => 'Alle Niveaus';

  @override
  String get allLevels => 'Alle';

  @override
  String get answers => 'Antworten';

  @override
  String get appTitle => 'Fluemingo';

  @override
  String get apply => 'Anwenden';

  @override
  String areYouSureYouWantToDeleteWord(Object word) {
    return 'Möchten Sie $word wirklich aus der Vokabelliste löschen?';
  }

  @override
  String areYouSureYouWantToDeleteReferenceLanguage(Object languageName) {
    return 'Möchten Sie Ihre Referenzsprache wirklich auf $languageName ändern?\n\nDiese Änderung wirkt sich auf bereits übersetzte Wörter aus.';
  }

  @override
  String areYouSureYouWantToDeleteTargetLanguage(Object languageName) {
    return 'Möchten Sie Ihre Zielsprache wirklich auf $languageName ändern?\n\nDiese Änderung wirkt sich auf bereits übersetzte Wörter aus.';
  }

  @override
  String get art => 'Kunst';

  @override
  String get article => 'Artikel';

  @override
  String get audiobooks => 'Hörbücher';

  @override
  String get back => 'Zurück';

  @override
  String get biography => 'Biografie';

  @override
  String get buildA => 'aufbauen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get changeStatus => 'Status ändern';

  @override
  String get changeLanguage => 'Sprache ändern';

  @override
  String get chapters => 'Kapitel';

  @override
  String get cinema => 'Kino';

  @override
  String get chooseYourAnswer => 'Wählen Sie eine Antwort';

  @override
  String get clickOnPlusToAddThisExpressionToYourVocabularyList =>
      'Klicken Sie auf +, um diesen Ausdruck zu Ihrem Vokabular hinzuzufügen';

  @override
  String get clickOnXToRemoveThisExpressionFromYourVocabularyList =>
      'Tippen Sie auf das Papierkorb-Symbol, um diesen Ausdruck aus Ihrem Vokabular zu entfernen';

  @override
  String get completedQuizzes => 'Abgeschlossene Quizze';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get contentInProgress => 'Laufende Inhalte';

  @override
  String get continueReadingToEarnXP => 'Lies weiter, um XP zu verdienen';

  @override
  String get connexion => 'Anmeldung';

  @override
  String get continueWithApple => 'Mit Apple fortfahren';

  @override
  String get continueWithFacebook => 'Mit Facebook fortfahren';

  @override
  String get continueWithGoogle => 'Mit Google fortfahren';

  @override
  String get culture => 'Kultur';

  @override
  String get dailyGoal => 'Tagesziel';

  @override
  String get definition => 'Definition';

  @override
  String get delete => 'Löschen';

  @override
  String get deleteVocabularyItem => 'Dieses Vokabelelement löschen';

  @override
  String get difficult => 'Schwierig';

  @override
  String get difficultVocabulary => 'Schwieriges Vokabular';

  @override
  String get downloadForOfflineAccess => 'Für Offline-Zugriff herunterladen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get education => 'Bildung';

  @override
  String get extreme => 'Extrem';

  @override
  String get fashion => 'Mode';

  @override
  String get expressionAddedToFlashcards =>
      'Ausdruck zu Lernkarten hinzugefügt';

  @override
  String get favoritesArticlesOnly => 'Nur Lieblingsartikel';

  @override
  String get favoritesAudiobooksOnly => 'Nur Lieblingshörbücher';

  @override
  String get favoriteContent => 'Lieblingsinhalt';

  @override
  String get favoriteThemes => 'Lieblingsthemen';

  @override
  String get fiction => 'Fiktion';

  @override
  String get filters => 'Filter';

  @override
  String get finished => 'Abgeschlossen';

  @override
  String get finishedArticles => 'Abgeschlossene Artikel';

  @override
  String get finishedAudiobooks => 'Abgeschlossene Hörbücher';

  @override
  String get finishedChaptersAudiobooks => 'Audio-Kapitel';

  @override
  String get flashcardsVocabulary => 'Vokabel-Lernkarten';

  @override
  String get fontSize => 'Schriftgröße';

  @override
  String goalIntensity(String intensity) {
    String _temp0 = intl.Intl.selectLogic(
      intensity,
      {
        'light': 'leicht',
        'regular': 'regelmäßig',
        'high': 'hoch',
        'extreme': 'extrem',
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
        'fiveMinutesADay': '5 Min/Tag',
        'fifteenMinutesADay': '15 Min/Tag',
        'thirtyMinutesADay': '30 Min/Tag',
        'oneHourADay': '1 Std/Tag',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get gastronomy => 'Gastronomie';

  @override
  String get grammarPoints => 'Grammatikregeln';

  @override
  String get greetings => 'Hallo';

  @override
  String get health => 'Gesundheit';

  @override
  String get high => 'hoch';

  @override
  String get history => 'Geschichte';

  @override
  String get inProgress => 'In Bearbeitung';

  @override
  String get includeFinishedArticles => 'Abgeschlossene Artikel einbeziehen';

  @override
  String get includeFinishedAudiobooks =>
      'Abgeschlossene Hörbücher einbeziehen';

  @override
  String get interestingContent => 'Inhalte passend zu Ihren Lieblingsthemen';

  @override
  String get forYou => 'Für dich';

  @override
  String get items => 'Ausdrücke';

  @override
  String get languages => 'Fremdsprachen';

  @override
  String get languageEn => 'Englisch';

  @override
  String get languageFr => 'Französisch';

  @override
  String get languageEs => 'Spanisch';

  @override
  String get languageDe => 'Deutsch';

  @override
  String get languageNl => 'Niederländisch';

  @override
  String get languageIt => 'Italienisch';

  @override
  String get languagePt => 'Portugiesisch';

  @override
  String get languageJa => 'Japanisch';

  @override
  String get learn => 'Lerne';

  @override
  String get literature => 'Literatur';

  @override
  String get level => 'Niveau';

  @override
  String get light => 'Leicht';

  @override
  String get mainVocabulary => 'Hauptvokabular';

  @override
  String get mastered => 'Gelernt';

  @override
  String get masteredFlashcards => 'Gelernte Lernkarten';

  @override
  String get masteredVocabulary => 'Gelerntes Vokabular';

  @override
  String get music => 'Musik';

  @override
  String get navAudiobooks => 'Hörbücher';

  @override
  String get navFlashcards => 'Vokabeln';

  @override
  String get navLibrary => 'Artikel';

  @override
  String get navProfile => 'Profil';

  @override
  String get noAudiobooksFound => 'Keine Hörbücher gefunden';

  @override
  String get noArticlesFound => 'Keine Artikel gefunden';

  @override
  String get noAudioAvailableForThisArticle =>
      'Kein Audio für diesen Artikel verfügbar';

  @override
  String get noQuizAvailableForThisArticle =>
      'Kein Quiz für diesen Artikel verfügbar';

  @override
  String get noVocabularyItemsFound => 'Keine Vokabeln gefunden';

  @override
  String get news => 'Nachrichten';

  @override
  String get next => 'Weiter';

  @override
  String get notStarted => 'Nicht begonnen';

  @override
  String get people => 'Leute';

  @override
  String get philosophy => 'Philosophie';

  @override
  String get psychology => 'Psychologie';

  @override
  String get poetry => 'Lyrik';

  @override
  String get previous => 'Zurück';

  @override
  String get quiz => 'Quiz';

  @override
  String get quizCompleted => 'Quiz abgeschlossen!';

  @override
  String get readFlashcards => 'Karteikarten lesen';

  @override
  String get regular => 'Regelmäßig';

  @override
  String get repeat => 'Üben';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get dailyLimitReached =>
      'Tageslimit erreicht. Versuche es morgen erneut.';

  @override
  String get saved => 'Gespeichert';

  @override
  String get savedVocabulary => 'Gespeichertes Vokabular';

  @override
  String get science => 'Wissenschaft';

  @override
  String get selectGoal => 'Wähle ein Ziel, um motiviert zu bleiben';

  @override
  String selectUpToThemes(Object maxSelection) {
    return 'Wähle bis zu $maxSelection Themen.';
  }

  @override
  String get setHowManyXpYouWant =>
      'Lege fest, wie viele XP du pro Woche verdienen möchtest.';

  @override
  String get signInWithApple => 'Mit Apple anmelden';

  @override
  String get signInWithFacebook => 'Mit Facebook fortfahren';

  @override
  String get signInWithGoogle => 'Mit Google anmelden';

  @override
  String get showOnlyFavoriteArticles => 'Nur Lieblingsartikel anzeigen';

  @override
  String get showOnlyFavoriteAudiobooks => 'Nur Lieblingshörbücher anzeigen';

  @override
  String get society => 'Gesellschaft';

  @override
  String get space => 'Weltraum';

  @override
  String get sport => 'Sport';

  @override
  String get startToRead => 'Lesen Beginnen';

  @override
  String get strongLastingVocabulary => 'Starker und dauerhafter Wortschatz';

  @override
  String get tale => 'Märchen';

  @override
  String get targetLanguage => 'Sprache, die ich lernen möchte';

  @override
  String get technology => 'Technologie';

  @override
  String get testYourKnowledge => 'Testen Sie Ihr Wissen';

  @override
  String get training => 'Übung';

  @override
  String get trainingVocabulary => 'Übungsvokabular';

  @override
  String get travel => 'Reisen';

  @override
  String get themes => 'Themen';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get sourceLanguage => 'Ausgangssprache';

  @override
  String get subscription => 'Abonnement';

  @override
  String get upgradeToPremium => 'Upgrade auf Premium';

  @override
  String get manageSubscription => 'Abonnement verwalten';

  @override
  String get unlockWithPremium => 'Mit Premium freischalten';

  @override
  String get vocabulary => 'Vokabular';

  @override
  String get vocabularyAcquired => 'Gelerntes Vokabular';

  @override
  String get vocabularyForTraining => 'Übungsvokabular';

  @override
  String get watersports => 'Wassersport';

  @override
  String get week => 'Woche';

  @override
  String get weekProgress => 'Diese Woche';

  @override
  String weeklyGoal(Object goal) {
    return 'Wochenziel: $goal XP';
  }

  @override
  String daysRemaining(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Tage verbleibend',
      one: 'Tag verbleibend',
    );
    return '$days $_temp0';
  }

  @override
  String get weekGoal => 'Wochenziel';

  @override
  String get whichLanguageDoYouWantToLearn =>
      'Welche Sprache möchtest du lernen?';

  @override
  String get selectOne => 'Wähle eine Option';

  @override
  String get whichLanguageDoYouSpeakTheBest =>
      'Welche Sprache möchtest du als Referenz verwenden?';

  @override
  String get withYour => 'mit deinem';

  @override
  String get unknown => 'Unbekannt';

  @override
  String get xpPerWeek => 'XP pro Woche';

  @override
  String get yoga => 'Yoga';

  @override
  String get yourSavedVocabulary => 'Gespeichertes Vokabular';

  @override
  String get yourPersonalVocabulary => 'Persönliches Vokabular';

  @override
  String get yourProgress => 'Gesamtfortschritt';

  @override
  String get yourWeekProgress => 'Wochenfortschritt';

  @override
  String get yourWeeklyGoal => 'Dein Wochenziel';

  @override
  String get rateTheApp => 'App bewerten';

  @override
  String get rateTheAppStoreUnavailable =>
      'Store nicht verfügbar (auf echtem Gerät testen oder App-Store-ID setzen).';

  @override
  String get flashcardCategoryUpdated => 'Flashcard-Kategorie aktualisiert';

  @override
  String get flashcardMastered =>
      'Glückwunsch, du hast einen neuen Ausdruck gemeistert! +1 XP';

  @override
  String get noFlashcardsAvailable => 'Keine Flashcards verfügbar';

  @override
  String get noFlashcardsFound => 'Keine Flashcards gefunden';

  @override
  String get deleteFlashcard => 'Flashcard löschen';

  @override
  String get noContentInProgress => 'Kein Inhalt in Bearbeitung';

  @override
  String get noLikedContentYet => 'Noch keine gefallenen Inhalte';

  @override
  String get noSuggestionsYet => 'Noch keine Vorschläge';

  @override
  String get yourContentInProgress => 'Dein Inhalt in Bearbeitung';

  @override
  String get yourFavoriteContent => 'Deine Lieblingsinhalte';

  @override
  String get yourContent => 'Dein Inhalt';

  @override
  String get finishContentToEarnXP =>
      'Schließe diesen Inhalt ab, um XP zu verdienen';

  @override
  String get basedOnYourLikes => 'Basierend auf deinen Likes';

  @override
  String get basedOnYourFavoriteThemes =>
      'Basierend auf deinen Lieblingsthemen';

  @override
  String get save => 'Speichern';

  @override
  String get pleaseSelectAtLeastOneTheme => 'Bitte wähle mindestens ein Thema';

  @override
  String get logout => 'Abmelden';

  @override
  String get downloading => 'Herunterladen...';

  @override
  String get availableOffline => 'Offline verfügbar';

  @override
  String get downloadedForOfflineAccess =>
      'Für Offline-Zugriff heruntergeladen';

  @override
  String get goBack => 'Zurück';

  @override
  String get noAudioAvailable => 'Kein Audio verfügbar';

  @override
  String get pleaseEnterValidNumber =>
      'Bitte gib eine gültige positive Zahl ein';

  @override
  String get yourTargetLanguage => 'Deine Zielsprache';

  @override
  String get yourReferenceLanguage => 'Deine Referenzsprache';

  @override
  String get oops => 'Huch';

  @override
  String get weeklyGoalReached => 'Wochenziel erreicht!';

  @override
  String get wellDone => 'Gut gemacht!';

  @override
  String youEarnedXp(Object xp) {
    return 'Du hast $xp XP verdient!';
  }

  @override
  String get quizFinishedMarkArticleAsFinished =>
      'Du hast das Quiz abgeschlossen! Möchtest du den Artikel auch als abgeschlossen markieren?';

  @override
  String get quizFinishedMarkChapterAsFinished =>
      'Du hast das Quiz abgeschlossen! Möchtest du das Kapitel auch als abgeschlossen markieren?';

  @override
  String get congratsQuizAndArticle =>
      'Du hast das Quiz und den Artikel abgeschlossen!';

  @override
  String get congratsQuizAndChapter =>
      'Du hast das Quiz und das Kapitel abgeschlossen!';

  @override
  String get congratsQuiz => 'Du hast das Quiz abgeschlossen!';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get vocabularyAddedToList => 'Vokabular zur Liste hinzugefügt';

  @override
  String get retranslate => 'Neu übersetzen';

  @override
  String get withContent => 'mit Inhalten,';

  @override
  String get fitTasteLevel => 'die zu deinem Geschmack und Niveau passen';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get deleteAccountConfirmation =>
      'Bist du sicher, dass du dein Konto löschen möchtest? Diese Aktion ist unwiderruflich und alle deine Daten werden dauerhaft gelöscht.';

  @override
  String get accountDeleted => 'Dein Konto wurde gelöscht.';

  @override
  String get deleteAccountError =>
      'Konto konnte nicht gelöscht werden. Bitte versuche es erneut.';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get termsAndPrivacyNotice =>
      'Mit der Anmeldung akzeptierst du unsere Nutzungsbedingungen und Datenschutzrichtlinie.';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get purchasesRestored => 'Käufe erfolgreich wiederhergestellt.';

  @override
  String get restorePurchasesFailed =>
      'Käufe konnten nicht wiederhergestellt werden.';

  @override
  String get orContinueWith => 'oder fortfahren mit';

  @override
  String get signInWithEmail => 'Mit E-Mail anmelden';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get enterEmailAndPassword =>
      'Gib deine E-Mail und dein Passwort ein, um dich anzumelden.';

  @override
  String get signIn => 'Anmelden';

  @override
  String get start => 'Starten';
}
