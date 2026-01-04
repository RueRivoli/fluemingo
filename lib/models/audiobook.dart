import 'vocabulary_item.dart';

class Audiobook {
  final int id;
  final String title;
  final String author;
  final String imageUrl;
  final String level;
  final String category;
  final String description;
  final List<VocabularyItem> vocabulary;
  final List<Chapter> chapters;
  final DateTime createdAt;

  Audiobook({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.level,
    required this.category,
    this.description = '',
    this.vocabulary = const [],
    this.chapters = const [],
    required this.createdAt,
  });
}

class Chapter {
  final int id;
  final int longFormatId;
  final String title;
  final String? description;
  final String? content;
  final String? contentEn;
  final String? audioUrl;
  final int orderIndex;

  Chapter({
    required this.id,
    required this.longFormatId,
    required this.title,
    this.description,
    this.content,
    this.contentEn,
    this.audioUrl,
    required this.orderIndex,
  });
}


