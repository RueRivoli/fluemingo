// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get fiveMinutesADay => '\'5分/日\'';

  @override
  String get fifteenMinutesADay => '\'15分/日\'';

  @override
  String get thirtyMinutesADay => '\'30分/日\'';

  @override
  String get oneHourADay => '\'1時間/日\'';

  @override
  String get activeFilters => 'アクティブなフィルター';

  @override
  String get addedByUser => 'あなたが追加';

  @override
  String get all => '全レベル';

  @override
  String get allLevels => 'すべて';

  @override
  String get answers => '回答';

  @override
  String get appTitle => 'Fluemingo';

  @override
  String get apply => '適用';

  @override
  String areYouSureYouWantToDeleteWord(Object word) {
    return '本当に$wordを単語リストから削除しますか？';
  }

  @override
  String areYouSureYouWantToDeleteReferenceLanguage(Object languageName) {
    return '参照言語を$languageNameに変更してもよろしいですか？\n\nこの変更は、既に翻訳された単語に影響します。';
  }

  @override
  String areYouSureYouWantToDeleteTargetLanguage(Object languageName) {
    return '学習言語を$languageNameに変更してもよろしいですか？\n\nこの変更は、既に翻訳された単語に影響します。';
  }

  @override
  String get art => 'アート';

  @override
  String get article => '記事';

  @override
  String get audiobooks => 'オーディオブック';

  @override
  String get back => '戻る';

  @override
  String get biography => '伝記';

  @override
  String get buildA => '作る';

  @override
  String get cancel => 'キャンセル';

  @override
  String get changeStatus => 'ステータスを変更';

  @override
  String get changeLanguage => '言語を変更';

  @override
  String get chapters => '章';

  @override
  String get cinema => '映画';

  @override
  String get chooseYourAnswer => '回答を選んでください';

  @override
  String get clickOnPlusToAddThisExpressionToYourVocabularyList =>
      '+をクリックしてこの表現を単語帳に追加';

  @override
  String get clickOnXToRemoveThisExpressionFromYourVocabularyList =>
      'xをクリックしてこの表現を単語帳から削除';

  @override
  String get completedQuizzes => '完了したクイズ';

  @override
  String get confirm => '確認';

  @override
  String get contentInProgress => '進行中のコンテンツ';

  @override
  String get continueReadingToEarnXP => '読み続けてXPを獲得しよう';

  @override
  String get connexion => '接続';

  @override
  String get continueWithApple => 'Appleで続ける';

  @override
  String get continueWithFacebook => 'Facebookで続ける';

  @override
  String get continueWithGoogle => 'Googleで続ける';

  @override
  String get culture => '文化';

  @override
  String get dailyGoal => 'デイリー目標';

  @override
  String get definition => '定義';

  @override
  String get delete => '削除';

  @override
  String get deleteVocabularyItem => 'この単語を削除';

  @override
  String get difficult => '難しい';

  @override
  String get difficultVocabulary => '難しい単語';

  @override
  String get downloadForOfflineAccess => 'オフライン用にダウンロード';

  @override
  String get edit => '編集';

  @override
  String get education => '教育';

  @override
  String get extreme => 'エクストリーム';

  @override
  String get fashion => 'ファッション';

  @override
  String get expressionAddedToFlashcards => 'フラッシュカードに表現を追加しました';

  @override
  String get favoritesArticlesOnly => 'お気に入りの記事のみ';

  @override
  String get favoritesAudiobooksOnly => 'お気に入りのオーディオブックのみ';

  @override
  String get favoriteContent => 'お気に入りのコンテンツ';

  @override
  String get favoriteThemes => 'お気に入りのテーマ';

  @override
  String get fiction => 'フィクション';

  @override
  String get filters => 'フィルター';

  @override
  String get finished => '完了';

  @override
  String get finishedArticles => '完了した記事';

  @override
  String get finishedAudiobooks => '完了したオーディオブック';

  @override
  String get finishedChaptersAudiobooks => 'オーディオ章';

  @override
  String get flashcardsVocabulary => '単語フラッシュカード';

  @override
  String get fontSize => 'フォントサイズ';

  @override
  String goalIntensity(String intensity) {
    String _temp0 = intl.Intl.selectLogic(
      intensity,
      {
        'light': 'ライト',
        'regular': 'レギュラー',
        'high': '高い',
        'extreme': 'エクストリーム',
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
        'fiveMinutesADay': '5分/日',
        'fifteenMinutesADay': '15分/日',
        'thirtyMinutesADay': '30分/日',
        'oneHourADay': '1時間/日',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get gastronomy => '美食';

  @override
  String get grammarPoints => '文法ルール';

  @override
  String get greetings => 'こんにちは';

  @override
  String get health => '健康';

  @override
  String get high => '高い';

  @override
  String get history => '歴史';

  @override
  String get inProgress => '進行中';

  @override
  String get includeFinishedArticles => '完了した記事を含める';

  @override
  String get includeFinishedAudiobooks => '完了したオーディオブックを含める';

  @override
  String get interestingContent => 'お気に入りのテーマに合ったコンテンツ';

  @override
  String get items => '表現';

  @override
  String get languages => '外国語';

  @override
  String get languageEn => '英語';

  @override
  String get languageFr => 'フランス語';

  @override
  String get languageEs => 'スペイン語';

  @override
  String get languageDe => 'ドイツ語';

  @override
  String get languageNl => 'オランダ語';

  @override
  String get languageIt => 'イタリア語';

  @override
  String get languagePt => 'ポルトガル語';

  @override
  String get languageJa => '日本語';

  @override
  String get learn => '学ぶ';

  @override
  String get literature => '文学';

  @override
  String get level => 'レベル';

  @override
  String get light => 'ライト';

  @override
  String get mainVocabulary => 'メイン単語帳';

  @override
  String get mastered => '習得済み';

  @override
  String get masteredFlashcards => '習得したフラッシュカード';

  @override
  String get masteredVocabulary => '習得した単語';

  @override
  String get music => '音楽';

  @override
  String get navAudiobooks => 'オーディオブック';

  @override
  String get navFlashcards => 'フラッシュカード';

  @override
  String get navLibrary => '記事';

  @override
  String get navProfile => 'プロフィール';

  @override
  String get noAudiobooksFound => 'オーディオブックが見つかりません';

  @override
  String get noArticlesFound => '記事が見つかりません';

  @override
  String get noAudioAvailableForThisArticle => 'この記事の音声はありません';

  @override
  String get noQuizAvailableForThisArticle => 'この記事のクイズはありません';

  @override
  String get noVocabularyItemsFound => '単語が見つかりません';

  @override
  String get news => 'ニュース';

  @override
  String get next => '次へ';

  @override
  String get notStarted => '未開始';

  @override
  String get people => '人物';

  @override
  String get poetry => '詩';

  @override
  String get previous => '前へ';

  @override
  String get quiz => 'クイズ';

  @override
  String get quizCompleted => 'クイズ完了！';

  @override
  String get readFlashcards => 'フラッシュカードを読む';

  @override
  String get regular => 'レギュラー';

  @override
  String get repeat => '練習する';

  @override
  String get retry => '再試行';

  @override
  String get saved => '保存済み';

  @override
  String get savedVocabulary => '保存した単語';

  @override
  String get science => '科学';

  @override
  String get selectGoal => 'モチベーションを維持する目標を選択';

  @override
  String selectUpToThemes(Object maxSelection) {
    return '最大$maxSelection個のテーマを選択してください。';
  }

  @override
  String get setHowManyXpYouWant => '週に獲得したいXPの量を設定してください。';

  @override
  String get signInWithApple => 'Appleでサインイン';

  @override
  String get signInWithFacebook => 'Facebookで続ける';

  @override
  String get signInWithGoogle => 'Googleでサインイン';

  @override
  String get showOnlyFavoriteArticles => 'お気に入りの記事のみ表示';

  @override
  String get showOnlyFavoriteAudiobooks => 'お気に入りのオーディオブックのみ表示';

  @override
  String get society => '社会';

  @override
  String get space => '宇宙';

  @override
  String get sport => 'スポーツ';

  @override
  String get startToRead => '読み始める';

  @override
  String get strongLastingVocabulary => '強く定着する語彙';

  @override
  String get tale => '物語';

  @override
  String get targetLanguage => '学びたい言語';

  @override
  String get technology => 'テクノロジー';

  @override
  String get testYourKnowledge => '知識を試す';

  @override
  String get training => '練習中';

  @override
  String get trainingVocabulary => '練習用の単語';

  @override
  String get travel => '旅行';

  @override
  String get themes => 'テーマ';

  @override
  String get tryAgain => '再試行';

  @override
  String get sourceLanguage => '母語';

  @override
  String get subscription => 'サブスクリプション';

  @override
  String get upgradeToPremium => 'プレミアムにアップグレード';

  @override
  String get manageSubscription => 'サブスクリプションを管理';

  @override
  String get unlockWithPremium => 'プレミアムでアンロック';

  @override
  String get vocabulary => '単語帳';

  @override
  String get vocabularyAcquired => '習得した単語';

  @override
  String get vocabularyForTraining => '練習用の単語';

  @override
  String get watersports => 'ウォータースポーツ';

  @override
  String get week => '週';

  @override
  String get weekProgress => '今週';

  @override
  String weeklyGoal(Object goal) {
    return '週間目標：$goal XP';
  }

  @override
  String get weekGoal => '週間目標';

  @override
  String get whichLanguageDoYouWantToLearn => 'どの言語を学びたいですか？';

  @override
  String get selectOne => '1つ選んでください';

  @override
  String get whichLanguageDoYouSpeakTheBest => '最も得意な言語はどれですか？';

  @override
  String get withYour => 'あなたの〜で';

  @override
  String get unknown => '不明';

  @override
  String get xpPerWeek => '週間XP';

  @override
  String get yoga => 'ヨガ';

  @override
  String get yourSavedVocabulary => '保存した単語';

  @override
  String get yourPersonalVocabulary => '個人の単語帳';

  @override
  String get yourProgress => '全体の進捗';

  @override
  String get yourWeekProgress => '今週の進捗';

  @override
  String get yourWeeklyGoal => '週間目標';

  @override
  String get rateTheApp => 'アプリを評価';

  @override
  String get rateTheAppStoreUnavailable => 'ストアを開けません（実機でお試しください）。';
}
