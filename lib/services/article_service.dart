import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article.dart';
import '../models/vocabulary_item.dart';
import '../models/grammar_point.dart';
import '../models/article_content.dart';

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
      print("Article response: $articleResponse");
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
      final grammarPoints = <GrammarPoint>[];
      print('vocabulary: $vocabulary');
      
      // Convert string content to List<ArticleContent>
      final contentString = articleResponse['content'] ?? '';
      final contentEnString = articleResponse['content_en'] ?? '';
      final contentList = _parseContentToArticleContent(contentString, contentEnString);
      
      // Create article with all related data
      return Article(
        id: articleResponse['id']?.toString() ?? '',
        title: articleResponse['title'] ?? '',
        description: articleResponse['description'] ?? '',
        imageUrl: _getImageUrl(articleResponse['img_url']),
        level: articleResponse['level'] ?? 'A1',
        category: articleResponse['category'] ?? '',
        audioUrl: _getAudioUrl(articleResponse['audio_url']),
        content: contentList,
        translatedContent: [], // Not used separately, translations are in ArticleContent objects
        vocabulary: vocabulary,
        isFavorite: false, // content_fr doesn't have is_favorite field
        grammarPoints: grammarPoints,
      );
    } catch (e) {
      print('Error fetching article: $e');
      return null;
    }
  }

  /// Convert string content to List<ArticleContent>
  /// Splits content by paragraphs (double newlines) and pairs with translations
  List<ArticleContent> _parseContentToArticleContent(String content, String contentEn) {
    if (content.isEmpty) {
      return [];
    }
    
    // Split by double newlines (paragraphs) or single newlines if no double newlines
    final contentParagraphs = content.split('\n\n');
    final contentEnParagraphs = contentEn.split('\n\n');
    
    // If no double newlines, try single newlines
    if (contentParagraphs.length == 1 && content.contains('\n')) {
      final singleSplit = content.split('\n');
      final singleSplitEn = contentEn.split('\n');
      return singleSplit
          .asMap()
          .entries
          .map((entry) => ArticleContent(
                originalText: entry.value.trim(),
                translationText: entry.key < singleSplitEn.length 
                    ? singleSplitEn[entry.key].trim() 
                    : '',
              ))
          .where((item) => item.originalText.isNotEmpty)
          .toList();
    }
    
    // Pair up paragraphs
    return contentParagraphs
        .asMap()
        .entries
        .map((entry) => ArticleContent(
              originalText: entry.value.trim(),
              translationText: entry.key < contentEnParagraphs.length 
                  ? contentEnParagraphs[entry.key].trim() 
                  : '',
            ))
        .where((item) => item.originalText.isNotEmpty)
        .toList();
  }

  /// Convert JSON to Article model
  Article _articleFromJson(Map<String, dynamic> json) {
    // Debug: print raw values from database
    print('DEBUG - Raw img_url from DB: ${json['img_url']}');
    print('DEBUG - Raw audio_url from DB: ${json['audio_url']}');
    
    // Convert string content to List<ArticleContent>
    final contentString = json['content'] ?? '';
    final contentEnString = json['content_en'] ?? '';
    final contentList = _parseContentToArticleContent(contentString, contentEnString);
    
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
      content: contentList,
      translatedContent: [],
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

