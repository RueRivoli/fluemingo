import '../models/article.dart';
import '../models/audiobook.dart';

class ProfileContent {
  List<Article> inProgressArticles; // list of article in progress (not finished)
  List<Audiobook> inProgressAudiobooks; // ist of audiobooks in progress (not finished)
  List<Article> favoriteArticles;
  List<Audiobook> favoriteAudiobooks;
  List<Article> interestingArticles;
  List<Audiobook> interestingAudiobooks;
  List<String> favoriteTopics;

  ProfileContent({
    this.inProgressArticles = const [],
    this.inProgressAudiobooks = const [],
    this.favoriteArticles = const [],
    this.favoriteAudiobooks = const [],
    this.interestingArticles = const [],
    this.interestingAudiobooks = const [],
    this.favoriteTopics = const [],
  });
}


