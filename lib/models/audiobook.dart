import 'article.dart';

class Audiobook {
  final int id;
  final String title;
  final String author;
  final String description;
  final String imageUrl;
  final String level;
  final String category1;
  final String? category2;
  final String? category3;
  final List<Article> chapters;
  final DateTime createdAt;
  final String? readingStatus;
  bool isFavorite;
  bool isFree;
  final bool isNew;

  Audiobook({
    required this.id,
    required this.title,
    required this.author,
    this.description = '',
    required this.imageUrl,
    required this.level,
    required this.category1,
    this.category2,
    this.category3,
    this.chapters = const [],
    required this.createdAt,
    this.isFavorite = false,
    this.readingStatus = null,
    this.isFree = false,
    this.isNew = false,
  });
}