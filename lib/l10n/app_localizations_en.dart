// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get fiveMinutesADay => '\'5 mins/day\'';

  @override
  String get fifteenMinutesADay => '\'15 min/day\'';

  @override
  String get thirtyMinutesADay => '\'30 min/day\'';

  @override
  String get oneHourADay => '\'1 hr/day\'';

  @override
  String get activeFilters => 'Active filters';

  @override
  String get addedByUser => 'Added by you';

  @override
  String get all => 'All';

  @override
  String get allLevels => 'All';

  @override
  String get answers => 'answers';

  @override
  String get appTitle => 'Fluemingo';

  @override
  String get apply => 'Apply';

  @override
  String areYouSureYouWantToDeleteWord(Object word) {
    return 'Are you sure you want to delete $word from the vocabulary list?';
  }

  @override
  String areYouSureYouWantToDeleteReferenceLanguage(Object languageName) {
    return 'Are you sure you want to change your reference language to $languageName?\n\nThis change will have an effect on the previous translated words.';
  }

  @override
  String areYouSureYouWantToDeleteTargetLanguage(Object languageName) {
    return 'Are you sure you want to change your target language to $languageName?\n\nThis change will have an effect on the previous translated words.';
  }

  @override
  String get art => 'Art';

  @override
  String get article => 'Article';

  @override
  String get audiobooks => 'Audiobooks';

  @override
  String get back => 'Back';

  @override
  String get biography => 'Biography';

  @override
  String get buildA => 'build a';

  @override
  String get cancel => 'Cancel';

  @override
  String get changeStatus => 'Change Status';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get chapters => 'Chapters';

  @override
  String get cinema => 'Cinema';

  @override
  String get chooseYourAnswer => 'Choose an answer';

  @override
  String get clickOnPlusToAddThisExpressionToYourVocabularyList =>
      'Click on + to add this expression to your vocabulary';

  @override
  String get clickOnXToRemoveThisExpressionFromYourVocabularyList =>
      'Click on x to remove this expression from your vocabulary';

  @override
  String get completedQuizzes => 'Completed quizzes';

  @override
  String get confirm => 'Confirm';

  @override
  String get contentInProgress => 'Content in progress';

  @override
  String get continueReadingToEarnXP => 'Keep reading to earn XP';

  @override
  String get connexion => 'Connexion';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithFacebook => 'Continue with Facebook';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get culture => 'Culture';

  @override
  String get dailyGoal => 'Daily Goal';

  @override
  String get definition => 'Definition';

  @override
  String get delete => 'Delete';

  @override
  String get deleteVocabularyItem => 'Delete this vocabulary item';

  @override
  String get difficult => 'Difficult';

  @override
  String get difficultVocabulary => 'Difficult vocabulary';

  @override
  String get downloadForOfflineAccess => 'Download for offline access';

  @override
  String get edit => 'Edit';

  @override
  String get education => 'Education';

  @override
  String get extreme => 'Extreme';

  @override
  String get fashion => 'Fashion';

  @override
  String get expressionAddedToFlashcards => 'Expression added to flashcards';

  @override
  String get favoritesArticlesOnly => 'Favorite articles only';

  @override
  String get favoritesAudiobooksOnly => 'Favorite audiobooks only';

  @override
  String get favoriteContent => 'Favorite content';

  @override
  String get favoriteThemes => 'Favorite themes';

  @override
  String get fiction => 'Fiction';

  @override
  String get filters => 'Filters';

  @override
  String get finished => 'Finished';

  @override
  String get finishedArticles => 'Finished articles';

  @override
  String get finishedAudiobooks => 'Finished audiobooks';

  @override
  String get finishedChaptersAudiobooks => 'Audio chapters';

  @override
  String get flashcardsVocabulary => 'Vocabulary flashcards';

  @override
  String get fontSize => 'Font size';

  @override
  String goalIntensity(String intensity) {
    String _temp0 = intl.Intl.selectLogic(
      intensity,
      {
        'light': 'light',
        'regular': 'regular',
        'high': 'high',
        'extreme': 'extreme',
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
        'fiveMinutesADay': '5 mins/day',
        'fifteenMinutesADay': '15 min/day',
        'thirtyMinutesADay': '30 min/day',
        'oneHourADay': '1 hr/day',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get gastronomy => 'Gastronomy';

  @override
  String get grammarPoints => 'Grammar rules';

  @override
  String get greetings => 'Hello';

  @override
  String get health => 'Health';

  @override
  String get high => 'high';

  @override
  String get history => 'History';

  @override
  String get inProgress => 'In progress';

  @override
  String get includeFinishedArticles => 'Include finished articles';

  @override
  String get includeFinishedAudiobooks => 'Include finished audiobooks';

  @override
  String get interestingContent => 'Content matching your favorite themes';

  @override
  String get items => 'Expressions';

  @override
  String get languages => 'Foreign languages';

  @override
  String get languageEn => 'English';

  @override
  String get languageFr => 'French';

  @override
  String get languageEs => 'Spanish';

  @override
  String get languageDe => 'German';

  @override
  String get languageNl => 'Dutch';

  @override
  String get languageIt => 'Italian';

  @override
  String get languagePt => 'Portuguese';

  @override
  String get languageJa => 'Japanese';

  @override
  String get learn => 'Learn';

  @override
  String get literature => 'Literature';

  @override
  String get level => 'Level';

  @override
  String get light => 'Light';

  @override
  String get mainVocabulary => 'Main vocabulary';

  @override
  String get mastered => 'Mastered';

  @override
  String get masteredFlashcards => 'Mastered flashcards';

  @override
  String get masteredVocabulary => 'Mastered vocabulary';

  @override
  String get music => 'Music';

  @override
  String get navAudiobooks => 'Audiobooks';

  @override
  String get navFlashcards => 'Flashcards';

  @override
  String get navLibrary => 'Articles';

  @override
  String get navProfile => 'Profile';

  @override
  String get noAudiobooksFound => 'No audiobooks found';

  @override
  String get noArticlesFound => 'No articles found';

  @override
  String get noAudioAvailableForThisArticle =>
      'No audio available for this article';

  @override
  String get noQuizAvailableForThisArticle =>
      'No quiz available for this article';

  @override
  String get noVocabularyItemsFound => 'No vocabulary items found';

  @override
  String get news => 'News';

  @override
  String get next => 'Next';

  @override
  String get notStarted => 'Not started';

  @override
  String get people => 'People';

  @override
  String get poetry => 'Poetry';

  @override
  String get previous => 'Previous';

  @override
  String get quiz => 'Quiz';

  @override
  String get quizCompleted => 'Quiz completed!';

  @override
  String get readFlashcards => 'Read flashcards';

  @override
  String get regular => 'Regular';

  @override
  String get repeat => 'Practice';

  @override
  String get retry => 'Retry';

  @override
  String get saved => 'Saved';

  @override
  String get savedVocabulary => 'Saved vocabulary';

  @override
  String get science => 'Science';

  @override
  String get selectGoal => 'Select a Goal to Remain Motivated';

  @override
  String selectUpToThemes(Object maxSelection) {
    return 'Select up to $maxSelection themes.';
  }

  @override
  String get setHowManyXpYouWant =>
      'Set how many XP you want to earn per week.';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get signInWithFacebook => 'Continue with Facebook';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get showOnlyFavoriteArticles => 'Show favorite articles only';

  @override
  String get showOnlyFavoriteAudiobooks => 'Show favorite audiobooks only';

  @override
  String get society => 'Society';

  @override
  String get space => 'Space';

  @override
  String get sport => 'Sport';

  @override
  String get startToRead => 'Start Reading';

  @override
  String get strongLastingVocabulary => 'Strong & Lasting Vocabulary';

  @override
  String get tale => 'Tale';

  @override
  String get targetLanguage => 'Language I want to learn';

  @override
  String get technology => 'Technology';

  @override
  String get testYourKnowledge => 'Test your knowledge';

  @override
  String get training => 'Training';

  @override
  String get trainingVocabulary => 'Training vocabulary';

  @override
  String get travel => 'Travel';

  @override
  String get themes => 'Themes';

  @override
  String get tryAgain => 'Try again';

  @override
  String get sourceLanguage => 'Source language';

  @override
  String get subscription => 'Subscription';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get manageSubscription => 'Manage subscription';

  @override
  String get unlockWithPremium => 'Unlock with Premium';

  @override
  String get vocabulary => 'Vocabulary';

  @override
  String get vocabularyAcquired => 'Acquired vocabulary';

  @override
  String get vocabularyForTraining => 'Training vocabulary';

  @override
  String get watersports => 'Water sports';

  @override
  String get week => 'week';

  @override
  String get weekProgress => 'This week';

  @override
  String weeklyGoal(Object goal) {
    return 'Weekly goal: $goal XP';
  }

  @override
  String get weekGoal => 'Weekly goal';

  @override
  String get whichLanguageDoYouWantToLearn =>
      'Which language do you want to learn ?';

  @override
  String get selectOne => 'Select one';

  @override
  String get whichLanguageDoYouSpeakTheBest =>
      'Which language do you speak the best ?';

  @override
  String get withYour => 'with your';

  @override
  String get unknown => 'Unknown';

  @override
  String get xpPerWeek => 'Xp Per Week';

  @override
  String get yoga => 'Yoga';

  @override
  String get yourSavedVocabulary => 'Saved vocabulary';

  @override
  String get yourPersonalVocabulary => 'Personal';

  @override
  String get yourProgress => 'Overall progress';

  @override
  String get yourWeekProgress => 'Weekly progress';

  @override
  String get yourWeeklyGoal => 'Your Weekly goal';

  @override
  String get rateTheApp => 'Rate the app';

  @override
  String get rateTheAppStoreUnavailable =>
      'Store unavailable (try on a real device or set App Store ID in code).';
}
