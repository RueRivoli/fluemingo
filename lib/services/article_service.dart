import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article.dart';
import '../models/vocabulary_item.dart';
import '../models/grammar_point.dart';
import '../models/article_paragraph.dart';
import '../models/article_sentence.dart';
import '../models/word_timestamp.dart';
import '../models/sentence_timestamp.dart';
import '../models/unit.dart';

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
      final contentMulti = articleResponse['content_multi'] ?? '';
      final paragraphs = _parseContentToArticleParagraphs(contentMulti);


      return Article(
        id: articleResponse['id']?.toString() ?? '',
        title: articleResponse['title'] ?? '',
        description: articleResponse['description'] ?? '',
        imageUrl: _getImageUrl(articleResponse['img_url']),
        level: articleResponse['level'] ?? 'A1',
        category: articleResponse['category'] ?? '',
        audioUrl: _getAudioUrl(articleResponse['audio_url']),
        vocabulary: vocabulary,
        paragraphs: paragraphs,
        grammarPoints: grammarPoints,
      );
    } catch (e) {
      print('Error fetching article: $e');
      return null;
    }
  }


  /// Parse content_multi JSON structure to List<ArticleParagraph>
  /// Expected structure: Object with "paragraphs" array, each paragraph contains "sentences" array
  List<ArticleParagraph> _parseContentToArticleParagraphs(dynamic contentMulti) {
    print('contentMulti: ${contentMulti}');
    if (contentMulti == null) {
      return [];
    }

    try {
      // Handle string JSON
      dynamic parsed;
      if (contentMulti is String) {
        if (contentMulti.isEmpty) {
          return [];
        }
        parsed = jsonDecode(contentMulti);
      } else {
        parsed = contentMulti;
      }

      // Expect an object with "paragraphs" key
      if (parsed is! Map) {
        print('Error: parsed is not a Map, it is: ${parsed.runtimeType}');
        return [];
      }

      final paragraphsData = parsed['paragraphs'];
      if (paragraphsData == null || paragraphsData is! List) {
        print('Error: paragraphs key not found or not a List');
        return [];
      }

      return paragraphsData.map((paragraphJson) {
        if (paragraphJson is! Map) {
          return null;
        }

        // Extract sentences from the paragraph
        final sentencesData = paragraphJson['sentences'];
        if (sentencesData == null || sentencesData is! List) {
          return null;
        }

        // Parse each sentence in the paragraph
        final sentences = sentencesData.map((sentenceJson) {
          if (sentenceJson is! Map) {
            return null;
          }

          // Extract text and English translation
          final originalText = sentenceJson['text']?.toString() ?? '';
          final translationText = sentenceJson['textEn']?.toString() ?? '';
          
          // Extract units with English translations
          final unitsList = <Unit>[];
          final unitsData = sentenceJson['units'];
          if (unitsData is List) {
            for (final unitJson in unitsData) {
              if (unitJson is! Map) continue;
              
              unitsList.add(Unit(
                text: unitJson['text']?.toString() ?? '',
                translatedText: unitJson['textEn']?.toString() ?? '', // Use English translation
                type: unitJson['type']?.toString() ?? 'other',
                punctuation: unitJson['punctuation'] == true,
                properName: unitJson['properName'] == true,
                originVerb: unitJson['originVerb']?.toString(),
              ));
            }
          }

          // Create ArticleSentence with start/end times
          return ArticleSentence(
            originalText: originalText,
            translationText: translationText,
            units: unitsList,
            startTime: sentenceJson['start'] != null 
                ? (sentenceJson['start'] as num).toDouble() 
                : null,
            endTime: sentenceJson['end'] != null 
                ? (sentenceJson['end'] as num).toDouble() 
                : null,
          );
        }).whereType<ArticleSentence>()
            .where((sentence) => sentence.originalText.isNotEmpty)
            .toList();

        // Create ArticleParagraph containing all sentences
        if (sentences.isEmpty) {
          return null;
        }

        return ArticleParagraph(
          sentences: sentences,
        );
      }).whereType<ArticleParagraph>()
          .where((paragraph) => paragraph.sentences.isNotEmpty)
          .toList();
    } catch (e, stackTrace) {
      print('Error parsing content_multi: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Convert JSON to Article model
  Article _articleFromJson(Map<String, dynamic> json) {    
    // Convert content_multi JSON to List<ArticleParagraph>
    final contentMulti = json['content_multi'];
    final paragraphs = _parseContentToArticleParagraphs(contentMulti);
    return Article(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: _getImageUrl(json['img_url']),
      level: json['level'] ?? 'A1',
      category: json['category'] ?? '',
      audioUrl: _getAudioUrl(json['audio_url']),
      isFavorite: false,
      vocabulary: [],
      grammarPoints: [],
      paragraphs: paragraphs,
    );
  }

  Future<void> toggleFavorite(String articleId, bool isFavorite) async {
    try {
      await _supabase.from('content_fr').update({
        'is_favorite': !isFavorite,
      }).eq('id', articleId);
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

}

