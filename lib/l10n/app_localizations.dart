import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('nl'),
    Locale('pt')
  ];

  /// No description provided for @fiveMinutesADay.
  ///
  /// In en, this message translates to:
  /// **'\'5 mins/day\''**
  String get fiveMinutesADay;

  /// No description provided for @fifteenMinutesADay.
  ///
  /// In en, this message translates to:
  /// **'\'15 min/day\''**
  String get fifteenMinutesADay;

  /// No description provided for @thirtyMinutesADay.
  ///
  /// In en, this message translates to:
  /// **'\'30 min/day\''**
  String get thirtyMinutesADay;

  /// No description provided for @oneHourADay.
  ///
  /// In en, this message translates to:
  /// **'\'1 hr/day\''**
  String get oneHourADay;

  /// No description provided for @activeFilters.
  ///
  /// In en, this message translates to:
  /// **'Active filters'**
  String get activeFilters;

  /// No description provided for @addedByUser.
  ///
  /// In en, this message translates to:
  /// **'Added by you'**
  String get addedByUser;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @allLevels.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allLevels;

  /// No description provided for @answers.
  ///
  /// In en, this message translates to:
  /// **'answers'**
  String get answers;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Fluemingo'**
  String get appTitle;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @areYouSureYouWantToDeleteWord.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {word} from the vocabulary list?'**
  String areYouSureYouWantToDeleteWord(Object word);

  /// No description provided for @areYouSureYouWantToDeleteReferenceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to change your reference language to {languageName}?\n\nThis change will have an effect on the previous translated words.'**
  String areYouSureYouWantToDeleteReferenceLanguage(Object languageName);

  /// No description provided for @areYouSureYouWantToDeleteTargetLanguage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to change your target language to {languageName}?\n\nThis change will have an effect on the previous translated words.'**
  String areYouSureYouWantToDeleteTargetLanguage(Object languageName);

  /// No description provided for @art.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get art;

  /// No description provided for @article.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get article;

  /// No description provided for @audiobooks.
  ///
  /// In en, this message translates to:
  /// **'Audiobooks'**
  String get audiobooks;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @biography.
  ///
  /// In en, this message translates to:
  /// **'Biography'**
  String get biography;

  /// No description provided for @buildA.
  ///
  /// In en, this message translates to:
  /// **'Build a'**
  String get buildA;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @changeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change Status'**
  String get changeStatus;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @chapters.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get chapters;

  /// No description provided for @cinema.
  ///
  /// In en, this message translates to:
  /// **'Cinema'**
  String get cinema;

  /// No description provided for @chooseYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Choose an answer'**
  String get chooseYourAnswer;

  /// No description provided for @clickOnPlusToAddThisExpressionToYourVocabularyList.
  ///
  /// In en, this message translates to:
  /// **'Click on + to add this expression to your vocabulary list'**
  String get clickOnPlusToAddThisExpressionToYourVocabularyList;

  /// No description provided for @clickOnXToRemoveThisExpressionFromYourVocabularyList.
  ///
  /// In en, this message translates to:
  /// **'Tap the trash icon to remove this expression from your vocabulary'**
  String get clickOnXToRemoveThisExpressionFromYourVocabularyList;

  /// No description provided for @completedQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Completed quizzes'**
  String get completedQuizzes;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @contentInProgress.
  ///
  /// In en, this message translates to:
  /// **'Content in progress'**
  String get contentInProgress;

  /// No description provided for @continueReadingToEarnXP.
  ///
  /// In en, this message translates to:
  /// **'Keep reading to earn XP'**
  String get continueReadingToEarnXP;

  /// No description provided for @connexion.
  ///
  /// In en, this message translates to:
  /// **'Connexion'**
  String get connexion;

  /// No description provided for @continueWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// No description provided for @continueWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get continueWithFacebook;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @culture.
  ///
  /// In en, this message translates to:
  /// **'Culture'**
  String get culture;

  /// No description provided for @dailyGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// No description provided for @definition.
  ///
  /// In en, this message translates to:
  /// **'Definition'**
  String get definition;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteVocabularyItem.
  ///
  /// In en, this message translates to:
  /// **'Delete this vocabulary item'**
  String get deleteVocabularyItem;

  /// No description provided for @difficult.
  ///
  /// In en, this message translates to:
  /// **'Difficult'**
  String get difficult;

  /// No description provided for @difficultVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Difficult vocabulary'**
  String get difficultVocabulary;

  /// No description provided for @downloadForOfflineAccess.
  ///
  /// In en, this message translates to:
  /// **'Download for offline access'**
  String get downloadForOfflineAccess;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @extreme.
  ///
  /// In en, this message translates to:
  /// **'Extreme'**
  String get extreme;

  /// No description provided for @fashion.
  ///
  /// In en, this message translates to:
  /// **'Fashion'**
  String get fashion;

  /// No description provided for @expressionAddedToFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Expression added to flashcards'**
  String get expressionAddedToFlashcards;

  /// No description provided for @favoritesArticlesOnly.
  ///
  /// In en, this message translates to:
  /// **'Favorite articles only'**
  String get favoritesArticlesOnly;

  /// No description provided for @favoritesAudiobooksOnly.
  ///
  /// In en, this message translates to:
  /// **'Favorite audiobooks only'**
  String get favoritesAudiobooksOnly;

  /// No description provided for @favoriteContent.
  ///
  /// In en, this message translates to:
  /// **'Favorite content'**
  String get favoriteContent;

  /// No description provided for @favoriteThemes.
  ///
  /// In en, this message translates to:
  /// **'Favorite themes'**
  String get favoriteThemes;

  /// No description provided for @fiction.
  ///
  /// In en, this message translates to:
  /// **'Fiction'**
  String get fiction;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get finished;

  /// No description provided for @finishedArticles.
  ///
  /// In en, this message translates to:
  /// **'Finished articles'**
  String get finishedArticles;

  /// No description provided for @finishedAudiobooks.
  ///
  /// In en, this message translates to:
  /// **'Finished audiobooks'**
  String get finishedAudiobooks;

  /// No description provided for @finishedChaptersAudiobooks.
  ///
  /// In en, this message translates to:
  /// **'Audio chapters'**
  String get finishedChaptersAudiobooks;

  /// No description provided for @flashcardsVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary flashcards'**
  String get flashcardsVocabulary;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get fontSize;

  /// No description provided for @goalIntensity.
  ///
  /// In en, this message translates to:
  /// **'{intensity, select, light{light} regular{regular} high{high} extreme{extreme} other{}}'**
  String goalIntensity(String intensity);

  /// No description provided for @goalDuration.
  ///
  /// In en, this message translates to:
  /// **'{duration, select, fiveMinutesADay{5 mins/day} fifteenMinutesADay{15 min/day} thirtyMinutesADay{30 min/day} oneHourADay{1 hr/day} other{}}'**
  String goalDuration(String duration);

  /// No description provided for @gastronomy.
  ///
  /// In en, this message translates to:
  /// **'Gastronomy'**
  String get gastronomy;

  /// No description provided for @grammarPoints.
  ///
  /// In en, this message translates to:
  /// **'Grammar rules'**
  String get grammarPoints;

  /// No description provided for @greetings.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get greetings;

  /// No description provided for @health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'high'**
  String get high;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @includeFinishedArticles.
  ///
  /// In en, this message translates to:
  /// **'Include finished articles'**
  String get includeFinishedArticles;

  /// No description provided for @includeFinishedAudiobooks.
  ///
  /// In en, this message translates to:
  /// **'Include finished audiobooks'**
  String get includeFinishedAudiobooks;

  /// No description provided for @interestingContent.
  ///
  /// In en, this message translates to:
  /// **'Content matching your favorite themes'**
  String get interestingContent;

  /// No description provided for @forYou.
  ///
  /// In en, this message translates to:
  /// **'For You'**
  String get forYou;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Expressions'**
  String get items;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Foreign languages'**
  String get languages;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @languageFr.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFr;

  /// No description provided for @languageEs.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageEs;

  /// No description provided for @languageDe.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageDe;

  /// No description provided for @languageNl.
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get languageNl;

  /// No description provided for @languageIt.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageIt;

  /// No description provided for @languagePt.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languagePt;

  /// No description provided for @languageJa.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageJa;

  /// No description provided for @learn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learn;

  /// No description provided for @literature.
  ///
  /// In en, this message translates to:
  /// **'Literature'**
  String get literature;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @mainVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Main vocabulary'**
  String get mainVocabulary;

  /// No description provided for @mastered.
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get mastered;

  /// No description provided for @masteredFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Mastered flashcards'**
  String get masteredFlashcards;

  /// No description provided for @masteredVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Mastered vocabulary'**
  String get masteredVocabulary;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @navAudiobooks.
  ///
  /// In en, this message translates to:
  /// **'Audiobooks'**
  String get navAudiobooks;

  /// No description provided for @navFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get navFlashcards;

  /// No description provided for @navLibrary.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get navLibrary;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @noAudiobooksFound.
  ///
  /// In en, this message translates to:
  /// **'No audiobooks found'**
  String get noAudiobooksFound;

  /// No description provided for @noArticlesFound.
  ///
  /// In en, this message translates to:
  /// **'No articles found'**
  String get noArticlesFound;

  /// No description provided for @noAudioAvailableForThisArticle.
  ///
  /// In en, this message translates to:
  /// **'No audio available for this article'**
  String get noAudioAvailableForThisArticle;

  /// No description provided for @noQuizAvailableForThisArticle.
  ///
  /// In en, this message translates to:
  /// **'No quiz available for this article'**
  String get noQuizAvailableForThisArticle;

  /// No description provided for @noVocabularyItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No vocabulary items found'**
  String get noVocabularyItemsFound;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Not started'**
  String get notStarted;

  /// No description provided for @people.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// No description provided for @philosophy.
  ///
  /// In en, this message translates to:
  /// **'Philosophy'**
  String get philosophy;

  /// No description provided for @psychology.
  ///
  /// In en, this message translates to:
  /// **'Psychology'**
  String get psychology;

  /// No description provided for @poetry.
  ///
  /// In en, this message translates to:
  /// **'Poetry'**
  String get poetry;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @quizCompleted.
  ///
  /// In en, this message translates to:
  /// **'Quiz completed!'**
  String get quizCompleted;

  /// No description provided for @readFlashcards.
  ///
  /// In en, this message translates to:
  /// **'Read flashcards'**
  String get readFlashcards;

  /// No description provided for @regular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get regular;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get repeat;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @savedVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Saved vocabulary'**
  String get savedVocabulary;

  /// No description provided for @science.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get science;

  /// No description provided for @selectGoal.
  ///
  /// In en, this message translates to:
  /// **'Select a Goal to Remain Motivated'**
  String get selectGoal;

  /// No description provided for @selectUpToThemes.
  ///
  /// In en, this message translates to:
  /// **'Select up to {maxSelection} themes.'**
  String selectUpToThemes(Object maxSelection);

  /// No description provided for @setHowManyXpYouWant.
  ///
  /// In en, this message translates to:
  /// **'Set how many XP you want to earn per week.'**
  String get setHowManyXpYouWant;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// No description provided for @signInWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get signInWithFacebook;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @showOnlyFavoriteArticles.
  ///
  /// In en, this message translates to:
  /// **'Show favorite articles only'**
  String get showOnlyFavoriteArticles;

  /// No description provided for @showOnlyFavoriteAudiobooks.
  ///
  /// In en, this message translates to:
  /// **'Show favorite audiobooks only'**
  String get showOnlyFavoriteAudiobooks;

  /// No description provided for @society.
  ///
  /// In en, this message translates to:
  /// **'Society'**
  String get society;

  /// No description provided for @space.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get space;

  /// No description provided for @sport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get sport;

  /// No description provided for @startToRead.
  ///
  /// In en, this message translates to:
  /// **'Start Reading'**
  String get startToRead;

  /// No description provided for @strongLastingVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Strong & Lasting Vocabulary'**
  String get strongLastingVocabulary;

  /// No description provided for @tale.
  ///
  /// In en, this message translates to:
  /// **'Tale'**
  String get tale;

  /// No description provided for @targetLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language I want to learn'**
  String get targetLanguage;

  /// No description provided for @technology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get technology;

  /// No description provided for @testYourKnowledge.
  ///
  /// In en, this message translates to:
  /// **'Test your knowledge'**
  String get testYourKnowledge;

  /// No description provided for @training.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get training;

  /// No description provided for @trainingVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Training vocabulary'**
  String get trainingVocabulary;

  /// No description provided for @travel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get travel;

  /// No description provided for @themes.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get themes;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @sourceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Source language'**
  String get sourceLanguage;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get manageSubscription;

  /// No description provided for @unlockWithPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock with Premium'**
  String get unlockWithPremium;

  /// No description provided for @vocabulary.
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get vocabulary;

  /// No description provided for @vocabularyAcquired.
  ///
  /// In en, this message translates to:
  /// **'Acquired vocabulary'**
  String get vocabularyAcquired;

  /// No description provided for @vocabularyForTraining.
  ///
  /// In en, this message translates to:
  /// **'Training vocabulary'**
  String get vocabularyForTraining;

  /// No description provided for @watersports.
  ///
  /// In en, this message translates to:
  /// **'Water sports'**
  String get watersports;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get week;

  /// No description provided for @weekProgress.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get weekProgress;

  /// No description provided for @weeklyGoal.
  ///
  /// In en, this message translates to:
  /// **'Weekly goal: {goal} XP'**
  String weeklyGoal(Object goal);

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} {days, plural, =1{day} other{days}} left'**
  String daysRemaining(int days);

  /// No description provided for @weekGoal.
  ///
  /// In en, this message translates to:
  /// **'Weekly goal'**
  String get weekGoal;

  /// No description provided for @whichLanguageDoYouWantToLearn.
  ///
  /// In en, this message translates to:
  /// **'Which language do you want to learn?'**
  String get whichLanguageDoYouWantToLearn;

  /// No description provided for @selectOne.
  ///
  /// In en, this message translates to:
  /// **'Select one'**
  String get selectOne;

  /// No description provided for @whichLanguageDoYouSpeakTheBest.
  ///
  /// In en, this message translates to:
  /// **'Which language would you like to use as a reference?'**
  String get whichLanguageDoYouSpeakTheBest;

  /// No description provided for @withYour.
  ///
  /// In en, this message translates to:
  /// **'with your'**
  String get withYour;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @xpPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Xp Per Week'**
  String get xpPerWeek;

  /// No description provided for @yoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get yoga;

  /// No description provided for @yourSavedVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Saved vocabulary'**
  String get yourSavedVocabulary;

  /// No description provided for @yourPersonalVocabulary.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get yourPersonalVocabulary;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall progress'**
  String get yourProgress;

  /// No description provided for @yourWeekProgress.
  ///
  /// In en, this message translates to:
  /// **'Weekly progress'**
  String get yourWeekProgress;

  /// No description provided for @yourWeeklyGoal.
  ///
  /// In en, this message translates to:
  /// **'Your Weekly goal'**
  String get yourWeeklyGoal;

  /// No description provided for @rateTheApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the app'**
  String get rateTheApp;

  /// No description provided for @rateTheAppStoreUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Store unavailable (try on a real device or set App Store ID in code).'**
  String get rateTheAppStoreUnavailable;

  /// No description provided for @flashcardCategoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Flashcard category updated'**
  String get flashcardCategoryUpdated;

  /// No description provided for @flashcardMastered.
  ///
  /// In en, this message translates to:
  /// **'Congratulations, you achieved a new expression! +1 XP'**
  String get flashcardMastered;

  /// No description provided for @noFlashcardsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No flashcards available'**
  String get noFlashcardsAvailable;

  /// No description provided for @noFlashcardsFound.
  ///
  /// In en, this message translates to:
  /// **'No flashcards found'**
  String get noFlashcardsFound;

  /// No description provided for @deleteFlashcard.
  ///
  /// In en, this message translates to:
  /// **'Delete flashcard'**
  String get deleteFlashcard;

  /// No description provided for @noContentInProgress.
  ///
  /// In en, this message translates to:
  /// **'No content in progress'**
  String get noContentInProgress;

  /// No description provided for @noLikedContentYet.
  ///
  /// In en, this message translates to:
  /// **'No liked content yet'**
  String get noLikedContentYet;

  /// No description provided for @noSuggestionsYet.
  ///
  /// In en, this message translates to:
  /// **'No suggestions yet'**
  String get noSuggestionsYet;

  /// No description provided for @yourContentInProgress.
  ///
  /// In en, this message translates to:
  /// **'Your content in progress'**
  String get yourContentInProgress;

  /// No description provided for @yourFavoriteContent.
  ///
  /// In en, this message translates to:
  /// **'Your favorite content'**
  String get yourFavoriteContent;

  /// No description provided for @yourContent.
  ///
  /// In en, this message translates to:
  /// **'Your content'**
  String get yourContent;

  /// No description provided for @finishContentToEarnXP.
  ///
  /// In en, this message translates to:
  /// **'Finish this content to earn XP'**
  String get finishContentToEarnXP;

  /// No description provided for @basedOnYourLikes.
  ///
  /// In en, this message translates to:
  /// **'Based on your likes'**
  String get basedOnYourLikes;

  /// No description provided for @basedOnYourFavoriteThemes.
  ///
  /// In en, this message translates to:
  /// **'Based on your favorite themes'**
  String get basedOnYourFavoriteThemes;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @pleaseSelectAtLeastOneTheme.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one theme'**
  String get pleaseSelectAtLeastOneTheme;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logout;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get downloading;

  /// No description provided for @availableOffline.
  ///
  /// In en, this message translates to:
  /// **'Available offline'**
  String get availableOffline;

  /// No description provided for @downloadedForOfflineAccess.
  ///
  /// In en, this message translates to:
  /// **'Downloaded for offline access'**
  String get downloadedForOfflineAccess;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @noAudioAvailable.
  ///
  /// In en, this message translates to:
  /// **'No audio available'**
  String get noAudioAvailable;

  /// No description provided for @pleaseEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid positive number'**
  String get pleaseEnterValidNumber;

  /// No description provided for @yourTargetLanguage.
  ///
  /// In en, this message translates to:
  /// **'Your target language'**
  String get yourTargetLanguage;

  /// No description provided for @yourReferenceLanguage.
  ///
  /// In en, this message translates to:
  /// **'Your reference language'**
  String get yourReferenceLanguage;

  /// No description provided for @oops.
  ///
  /// In en, this message translates to:
  /// **'Oops'**
  String get oops;

  /// No description provided for @weeklyGoalReached.
  ///
  /// In en, this message translates to:
  /// **'Weekly goal reached!'**
  String get weeklyGoalReached;

  /// No description provided for @wellDone.
  ///
  /// In en, this message translates to:
  /// **'Well done!'**
  String get wellDone;

  /// No description provided for @youEarnedXp.
  ///
  /// In en, this message translates to:
  /// **'You earned {xp} XP!'**
  String youEarnedXp(Object xp);

  /// No description provided for @quizFinishedMarkArticleAsFinished.
  ///
  /// In en, this message translates to:
  /// **'You finished the quiz! Do you want to mark the article as finished as well?'**
  String get quizFinishedMarkArticleAsFinished;

  /// No description provided for @quizFinishedMarkChapterAsFinished.
  ///
  /// In en, this message translates to:
  /// **'You finished the quiz! Do you want to mark the chapter as finished as well?'**
  String get quizFinishedMarkChapterAsFinished;

  /// No description provided for @congratsQuizAndArticle.
  ///
  /// In en, this message translates to:
  /// **'You finished the quiz and the article!'**
  String get congratsQuizAndArticle;

  /// No description provided for @congratsQuizAndChapter.
  ///
  /// In en, this message translates to:
  /// **'You finished the quiz and the chapter!'**
  String get congratsQuizAndChapter;

  /// No description provided for @congratsQuiz.
  ///
  /// In en, this message translates to:
  /// **'You finished the quiz!'**
  String get congratsQuiz;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @vocabularyAddedToList.
  ///
  /// In en, this message translates to:
  /// **'Added to the Vocabulary List'**
  String get vocabularyAddedToList;

  /// No description provided for @retranslate.
  ///
  /// In en, this message translates to:
  /// **'Re-translate'**
  String get retranslate;

  /// No description provided for @withContent.
  ///
  /// In en, this message translates to:
  /// **'With Content'**
  String get withContent;

  /// No description provided for @fitTasteLevel.
  ///
  /// In en, this message translates to:
  /// **'that fits your taste and level'**
  String get fitTasteLevel;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action is irreversible and all your data will be permanently deleted.'**
  String get deleteAccountConfirmation;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get accountDeleted;

  /// No description provided for @deleteAccountError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account. Please try again.'**
  String get deleteAccountError;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @termsAndPrivacyNotice.
  ///
  /// In en, this message translates to:
  /// **'By signing in, you agree to our Terms of Service and Privacy Policy.'**
  String get termsAndPrivacyNotice;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @purchasesRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchases restored successfully.'**
  String get purchasesRestored;

  /// No description provided for @restorePurchasesFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore purchases.'**
  String get restorePurchasesFailed;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @signInWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign in with email'**
  String get signInWithEmail;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterEmailAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and password to sign in.'**
  String get enterEmailAndPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'es',
        'fr',
        'it',
        'ja',
        'nl',
        'pt'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'nl':
      return AppLocalizationsNl();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
