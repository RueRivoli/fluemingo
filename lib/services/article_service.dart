import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article.dart';
import '../models/vocabulary_item.dart';
import '../models/grammar_point.dart';
import '../models/article_paragraph.dart';

class ArticleService {
  final SupabaseClient _supabase;
  static const String _storageBucket = 'content'; // Main storage bucket

  ArticleService(this._supabase);

  /// Get full public URL for a file stored in Supabase Storage
  /// Path format expected: "content/images/filename.jpg" -> extracts "images/filename.jpg"
  String _getStorageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }
    
    // If the path already contains the full URL, return it as is
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    
    // Remove leading slash if present
    String cleanPath = path.startsWith('/') ? path.substring(1) : path;
    
    // If path starts with "content/", remove it since bucket is already "content"
    if (cleanPath.startsWith('content/')) {
      cleanPath = cleanPath.substring('content/'.length);
    }
    
    try {
      // Construct the full public URL
      final url = _supabase.storage.from(_storageBucket).getPublicUrl(cleanPath);
      print('Storage URL constructed: $url (from path: $path)');
      return url;
    } catch (e) {
      print('Error constructing storage URL: $e');
      return '';
    }
  }

  /// Get full public URL for an image stored in Supabase Storage
  String _getImageUrl(String? imgPath) {
    return _getStorageUrl(imgPath);
  }

  /// Get full public URL for an audio file stored in Supabase Storage
  String? _getAudioUrl(String? audioPath) {
    if (audioPath == null || audioPath.isEmpty) {
      return null;
    }
    return _getStorageUrl(audioPath);
  }

  /// Fetch all articles from Supabase
  Future<List<Article>> getArticles({String? level}) async {
    try {
      var query = _supabase.from('content_fr').select().eq('content_type', 1);

      // Filter by level if provided
      if (level != null && level != 'All') {
        query = query.eq('level', level);
      }

      final response = await query;

      return (response as List).map((json) => _articleFromJson(json)).toList();
    } catch (e) {
      print('Error fetching articles: $e');
      rethrow;
    }
  }

  /// Fetch a single article by ID with all related data
  Future<Article?> getArticleById(String id) async {
    try {
      // Fetch article from content_fr table
      final articleResponse = await _supabase
          .from('content_fr')
          .select()
          .eq('id', int.parse(id))
          .eq('content_type', 1)
          .single();

      if (articleResponse == null) return null;

      // Fetch related vocabulary from vocabulary_fr table
      final vocabularyResponse = await _supabase
          .from('vocabulary_fr')
          .select()
          .eq('reference_id', int.parse(id))
          .eq('content_type', 1);

      final vocabulary = (vocabularyResponse as List).map((json) => VocabularyItem(
            word: json['text'] ?? '',
            translation: json['text_en'] ?? '',
            type: json['function'] ?? 'n',
            isSaved: false, // vocabulary_fr doesn't have is_saved field
          )).toList();

      // Note: article_paragraphs and article_grammar_points tables may not exist
      // If they do, they might need to be updated to reference content_fr.id
      // For now, leaving them empty as content might be in content_fr.content field
      final paragraphs = <ArticleParagraph>[];
      final grammarPoints = <GrammarPoint>[];

      // Create article with all related data
      return Article(
        id: articleResponse['id']?.toString() ?? '',
        title: articleResponse['title'] ?? '',
        description: articleResponse['description'] ?? '',
        imageUrl: _getImageUrl(articleResponse['img_url']),
        level: articleResponse['level'] ?? 'A1',
        category: articleResponse['category'] ?? '',
        audioUrl: _getAudioUrl(articleResponse['audio_url']),
        isFavorite: false, // content_fr doesn't have is_favorite field
        vocabulary: vocabulary,
        grammarPoints: grammarPoints,
        paragraphs: paragraphs,
      );
    } catch (e) {
      print('Error fetching article: $e');
      return null;
    }
  }

  /// Convert JSON to Article model
  Article _articleFromJson(Map<String, dynamic> json) {
    // Debug: print raw values from database
    print('DEBUG - Raw img_url from DB: ${json['img_url']}');
    print('DEBUG - Raw audio_url from DB: ${json['audio_url']}');
    
    return Article(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: _getImageUrl(json['img_url']),
      level: json['level'] ?? 'A1',
      category: json['category'] ?? '',
      audioUrl: _getAudioUrl(json['audio_url']),
      isFavorite: false, // content_fr doesn't have is_favorite field
      vocabulary: [],
      grammarPoints: [],
      paragraphs: [],
    );
  }

  /// Toggle favorite status for an article
  /// Note: content_fr table doesn't have is_favorite field
  /// This method is kept for compatibility but will not update the database
  Future<void> toggleFavorite(String articleId, bool isFavorite) async {
    try {
      // content_fr table doesn't have is_favorite field
      // If favorite functionality is needed, consider adding it to the table
      // or using a separate user_favorites table
      print('Warning: toggleFavorite called but content_fr table has no is_favorite field');
      // await _supabase
      //     .from('content_fr')
      //     .update({'is_favorite': isFavorite})
      //     .eq('id', int.parse(articleId))
      //     .eq('content_type', 1);
    } catch (e) {
      print('Error toggling favorite: $e');
      rethrow;
    }
  }
}

