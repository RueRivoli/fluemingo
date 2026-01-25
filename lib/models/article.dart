import 'vocabulary_item.dart';
import 'grammar_point.dart';
import 'article_paragraph.dart';
import 'sentence_timestamp.dart';

class Article {
  final String id;
  final String? chapterId;
  final String title;
  final String description;
  final String imageUrl;
  final String level;
  final String category;
  final List<VocabularyItem> vocabulary;
  final List<GrammarPoint> grammarPoints;
  final List<ArticleParagraph> paragraphs;
  final String? audioUrl;
  bool isFavorite;

  Article({
    required this.id,
    this.chapterId,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.level,
    required this.category,
    this.vocabulary = const [],
    this.grammarPoints = const [],
    this.paragraphs = const [],
    this.audioUrl,
    this.isFavorite = false,
  });

  List<VocabularyItem> get addedByUserVocabularyItems {
    return vocabulary.where((item) => item.isAddedByUser == true).toList();
  }

 List<VocabularyItem> get mainVocabularyItems {
    return vocabulary.where((item) => item.isAddedByUser == false).toList();
  }

    bool get hasAddedByUserVocabularyItems {
      return addedByUserVocabularyItems.isNotEmpty;
    }

   List<String> get listOfVocabularyItems {
    return vocabulary.map((item) => item.word + ' (' + item.type + ')').toList();
  }

  @override
  String toString() {
    return 'Article('
        'id: $id, '
        'title: $title, '
        'level: $level, '
        'category: $category, '
        'vocabularyCount: ${vocabulary.length}, '
        'paragraphsCount: ${paragraphs.length}, '
        'grammarPointsCount: ${grammarPoints.length}, '
        'isFavorite: $isFavorite'
        ')';
  }
}

