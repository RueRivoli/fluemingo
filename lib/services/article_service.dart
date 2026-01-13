import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article.dart';
import '../models/vocabulary_item.dart';
import '../models/grammar_point.dart';
import '../models/article_content.dart';
import '../models/word_timestamp.dart';

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
            audioUrl: _getAudioUrl(json['audio_url']) ?? '',
            word: json['text'] ?? '',
            translation: json['text_en'] ?? '',
            type: json['function'] ?? 'n',
            isSaved: false, // vocabulary_fr doesn't have is_saved field
          )).toList();
      final grammarPoints = <GrammarPoint>[];
      
      // Convert string content to List<ArticleContent>
      final contentString = articleResponse['content'] ?? '';
      final contentEnString = articleResponse['content_en'] ?? '';
      final contentList = _parseContentToArticleContent(contentString, contentEnString);
      
      // Get content_timestamps from database and parse it
      final contentTimestamps = articleResponse['content_timestamps'];
      final parsedTimestamps = _parseContentTimestamps(contentTimestamps);
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
        contentTimestamps: parsedTimestamps,
        isFavorite: false, // content_fr doesn't have is_favorite field
        grammarPoints: grammarPoints,
      );
    } catch (e) {
      print('Error fetching article: $e');
      return null;
    }
  }

  /// Parse contentTimestamps JSON to extract a list of words with timestamps
  /// Expected structure: {"results":{"channels":[{"alternatives":[{"words":[...]}]}]}}
  List<WordTimestamp>? _parseContentTimestamps(dynamic contentTimestamps) {
    if (contentTimestamps == null) {
      return null;
    }

    try {
      // Convert to Map if it's not already
      Map<String, dynamic> timestampsMap;
      if (contentTimestamps is Map) {
        timestampsMap = Map<String, dynamic>.from(contentTimestamps);
      } else {
        return null;
      }

      // Navigate through the nested structure: results -> channels -> alternatives -> words
      final results = timestampsMap['results'];
      if (results == null || results is! Map) {
        return null;
      }

      final channels = results['channels'];
      if (channels == null || channels is! List || channels.isEmpty) {
        return null;
      }

      final channel = channels[0];
      if (channel == null || channel is! Map) {
        return null;
      }

      final alternatives = channel['alternatives'];
      if (alternatives == null || alternatives is! List || alternatives.isEmpty) {
        return null;
      }

      final alternative = alternatives[0];
      if (alternative == null || alternative is! Map) {
        return null;
      }

      final words = alternative['words'];
      if (words == null || words is! List) {
        return null;
      }

      // Parse each word into a WordTimestamp object
      return (words as List)
          .map((wordJson) {
            try {
              if (wordJson is Map) {
                return WordTimestamp.fromJson(Map<String, dynamic>.from(wordJson));
              }
              return null;
            } catch (e) {
              print('Error parsing word timestamp: $e');
              return null;
            }
          })
          .whereType<WordTimestamp>()
          .toList();
    } catch (e) {
      print('Error parsing content timestamps: $e');
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
      contentTimestamps: _parseContentTimestamps(json['content_timestamps']),
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

