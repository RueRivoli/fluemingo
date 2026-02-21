import 'vocabulary_item.dart';
import 'article.dart';
import 'chapter_overview.dart';

class Audiobook {
  final int id;
  final String title;
  final String author;
  final String description;
  /// Description in reference language (e.g. English). Shown when user's native language matches.
  final String? descriptionRef;
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

  Audiobook({
    required this.id,
    required this.title,
    required this.author,
    this.description = '',
    this.descriptionRef,
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
  });
}