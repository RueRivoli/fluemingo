import 'vocabulary_item.dart';
import 'grammar_point.dart';
import 'article_paragraph.dart';
import 'sentence_timestamp.dart';

class Article {
  final String id;
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
}

