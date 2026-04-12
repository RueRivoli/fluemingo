import 'vocabulary_item.dart';
import 'grammar_point.dart';
import 'article_paragraph.dart';
import 'sentence_timestamp.dart';

class Article {
  final String id;
  final String? chapterId;
  final String title;
  final String? parentTitle;
  final String description;
  final String author;
  final String imageUrl;
  final String? readingStatus;
  final String level;
  final String category1;
  final String? category2;
  final String? category3;
  final List<VocabularyItem> vocabulary;
  final List<GrammarPoint> grammarPoints;
  final List<ArticleParagraph> paragraphs;
  final String? audioUrl;
  final int? orderId;
  final int? duration;
  final int contentType;
  bool isFavorite;
  bool isFree;
  final bool isNew;

  Article({
    required this.id,
    this.chapterId,
    required this.title,
    this.parentTitle,
    required this.description,
    required this.author,
    required this.imageUrl,
    this.readingStatus = null,
    required this.level,
    required this.category1,
    this.category2,
    this.category3,
    this.vocabulary = const [],
    this.grammarPoints = const [],
    this.paragraphs = const [],
    this.audioUrl,
    this.orderId,
    this.duration,
    this.isFavorite = false,
    this.contentType = 1,
    this.isFree = false,
    this.isNew = false,
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
  
   List<VocabularyItem> get orderedListOfVocabularyItems {
    final savedVocabularyItems = vocabulary.where((item) => item.status != null).toList();
    final addedByUserVocabularyItems = vocabulary.where((item) => item.status == null && item.isAddedByUser == true).toList();
    final unsavedStandardVocabularyItems = vocabulary.where((item) => item.status == null && item.isAddedByUser == false).toList();
    return [...savedVocabularyItems, ...addedByUserVocabularyItems, ...unsavedStandardVocabularyItems];
  }

  @override
  String toString() {
    return 'Article('
        'id: $id, '
        'title: $title, '
        'level: $level, '
        'category1: $category1, '
        'category2: $category2, '
        'category3: $category3, '
        'readingStatus: $readingStatus, '
        'vocabularyCount: ${vocabulary.length}, '
        'paragraphsCount: ${paragraphs.length}, '
        'grammarPointsCount: ${grammarPoints.length}, '
        'isFavorite: $isFavorite'
        ')';
  }
}

