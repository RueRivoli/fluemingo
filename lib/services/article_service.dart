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
      final user = _supabase.auth.currentUser;

      // Join with progress_fr to get is_liked for the current user when logged in
      final select = user != null
          ? '*, progress_fr!content_id(is_liked, reading_status)'
          : '*';
      var query = _supabase
          .from('content_fr')
          .select(select)
          .eq('content_type', 1);

      // Filter progress_fr to current user's rows only (when logged in)
      if (user != null) {
        query = query.eq('progress_fr.user_id', user.id);
      }

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

  /// Check if a vocabulary item is saved in flashcards_fr for the current user
  Future<bool> _isVocabularyItemSaved(String word, String articleId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;
      
      final response = await _supabase
          .from('flashcards_fr')
          .select('id')
          .eq('user_id', user.id)
          .eq('text', word)
          .eq('content_id', int.parse(articleId))
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      print('Error checking if vocabulary item is saved: $e');
      return false;
    }
  }

  /// Fetch a single article by ID with all related data
  Future<Article?> getArticleById(String id) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    try {
      print('Fetching article by ID: $id');
      // Fetch article from content_fr table
      final articleResponse = await _supabase
          .from('content_fr')
          .select('*, progress_fr!content_id(is_liked, reading_status)')
          .eq('id', int.parse(id))
          .eq('content_type', 1)
          .single();

      if (articleResponse == null) return null;

      // Fetch proposed vocabulary saved in flashcards
      final mainVocabularyResponse = await _supabase
          .from('vocabulary_fr')
          .select('*, flashcards_fr!vocabulary_id(*)')
          .eq('reference_id', int.parse(id))
          .eq('content_type', 1);
      // Rank rows with an associated flashcards_fr row first
      final mainList = mainVocabularyResponse as List;
      mainList.sort((a, b) {
        final aHasFlashcard = a['flashcards_fr'] is List && (a['flashcards_fr'] as List).isNotEmpty;
        final bHasFlashcard = b['flashcards_fr'] is List && (b['flashcards_fr'] as List).isNotEmpty;
        if (aHasFlashcard == bHasFlashcard) return 0;
        return aHasFlashcard ? -1 : 1; // rows with flashcard first
      });
      print('<><><>: ${mainVocabularyResponse.map((json) => json['audio_url']).toList()}');
      // Fetch vocabulary added by user to flashcards
      final vocabularyAddedByUser = await _supabase
          .from('flashcards_fr')
          .select('*')
          .eq('content_id', int.parse(id))
          .eq('user_id', user.id)
          .filter('vocabulary_id', 'is', 'null')
          .order('status', ascending: true, nullsFirst: false);
      print('VOCABULARY ADDED BY USER: ${vocabularyAddedByUser.map((json) => json['status']).toList()}');
      final vocabulary = (mainVocabularyResponse as List).map((json) {
        String? status;
        bool isAddedByUser = false;
        int? flashcardId = null;
        if (json['flashcards_fr'] is List && (json['flashcards_fr'] as List).isNotEmpty) {
          final flashcards = json['flashcards_fr'] as List;
          status = flashcards[0]?['status'];
          flashcardId = flashcards[0]?['id'];
        }
        return VocabularyItem(
          id: json['id'],
          word: json['text'] ?? '',
          translation: json['text_en'] ?? '',
          type: json['function'] ?? 'expr',
          exampleSentence: json['example'] ?? '',
          exampleTranslation: json['example_en'] ?? '',
          audioUrl: _getAudioUrl(json['audio_url']) ?? '',
          flashcardId: flashcardId,
          status: status,
          isAddedByUser: false,
        );
      }).toList();

      vocabulary.addAll(vocabularyAddedByUser.map((item) => VocabularyItem(
        id: item['id'],
        word: item['text'] ?? '',
        translation: item['text_translation'] ?? '',
        type: item['function'] ?? 'expr',
        exampleSentence: item['example'] ?? '',
        exampleTranslation: item['example_translation'] ?? '',
        audioUrl: '',
        flashcardId: item['id'],
        status: item['status'],
        isAddedByUser: true,
      )));
      
      final progressFr = articleResponse['progress_fr'];
      final progressList = progressFr is List && progressFr.isNotEmpty ? progressFr : null;
      final progressRow = progressList != null ? progressList[0] as Map<String, dynamic>? : null;
      if (progressRow != null) {
        print('PROGRESS FR: ${progressRow['reading_status']}');
      }
      final contentMulti = articleResponse['content_multi'] ?? '';
      final paragraphs = parseContentToArticleParagraphs(contentMulti);
      final grammarPoints = <GrammarPoint>[];
      return Article(
        id: articleResponse['id']?.toString() ?? '',
        chapterId: articleResponse['chapter_id'] ?? null,
        title: articleResponse['title'] ?? '',
        description: articleResponse['description'] ?? '',
        author: articleResponse['author'] ?? '',
        imageUrl: _getImageUrl(articleResponse['img_url']),
        level: articleResponse['level'] ?? 'A1',
        category1: articleResponse['category_1'] ?? '',
        category2: articleResponse['category_2'] ?? '',
        category3: articleResponse['category_3'] ?? '',
        contentType: 1,
        vocabulary: vocabulary,
        grammarPoints: grammarPoints,
        paragraphs: paragraphs,
        audioUrl: _getAudioUrl(articleResponse['audio_url']),
        readingStatus: progressRow?['reading_status'] ?? null,
        isFavorite: progressRow?['is_liked'] == true,
        isFree: articleResponse['is_free'] ?? false,
      );
    } catch (e) {
      print('Error fetching article: $e');
      return null;
    }
  }


  /// Update reading status for an article in progress_fr
  Future<void> editArticleStatus(Article article, String status) async {
    print('Editing article status by ID: ${article.id} - status: $status');
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      final contentId = int.parse(article.id);
      final existing = await _supabase
          .from('progress_fr')
          .select('id')
          .eq('content_id', contentId)
          .eq('user_id', user.id)
          .eq('content_type', 1)
          .maybeSingle();

      final payload = status == 'started'
          ? {
              'content_id': contentId,
              'user_id': user.id,
              'content_type': 1,
              'reading_status': status,
              'started_datetime': DateTime.now().toIso8601String(),
            }
          : status == 'finished' ? {
              'content_id': contentId,
              'user_id': user.id,
              'content_type': 1,
              'reading_status': status,
              'finished_datetime': DateTime.now().toIso8601String(),
            } : {
              'content_id': contentId,
              'user_id': user.id,
              'content_type': 1,
              'reading_status': status,
            };

      if (existing != null && existing['id'] != null) {
        print('Updating existing progress_fr record: ${existing['id']}, payload: $payload');
        await _supabase
            .from('progress_fr')
            .update(payload)
            .eq('id', existing['id']);
      } else {
        await _supabase.from('progress_fr').insert(payload);
      }
    } catch (e) {
      print('Error editing article status: $e');
    }
  }

/// Fetch a single article by ID with all related data
  Future<Article?> getChapterById(String contentId, String chapterId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    try {
      // Fetch article from content_fr table
      final chapterResponse = await _supabase
          .from('chapters_fr')
          .select()
          .eq('id', int.parse(chapterId))
          .single();

      if (chapterResponse == null) return null;

      // Fetch proposed vocabulary saved in flashcards
      final mainVocabularyResponse = await _supabase
          .from('vocabulary_fr')
          .select('*, flashcards_fr!vocabulary_id(*)')
          .eq('content_type', 2)
          .eq('chapter_id', int.parse(chapterId));
      // Rank rows with an associated flashcards_fr row first
      final mainList = mainVocabularyResponse as List;
      mainList.sort((a, b) {
        final aHasFlashcard = a['flashcards_fr'] is List && (a['flashcards_fr'] as List).isNotEmpty;
        final bHasFlashcard = b['flashcards_fr'] is List && (b['flashcards_fr'] as List).isNotEmpty;
        if (aHasFlashcard == bHasFlashcard) return 0;
        return aHasFlashcard ? -1 : 1; // rows with flashcard first
      });

      // Fetch vocabulary added by user to flashcards
      final vocabularyAddedByUser = await _supabase
          .from('flashcards_fr')
          .select('*')
          .eq('chapter_id', int.parse(chapterId))
          .eq('user_id', user.id)
          .filter('vocabulary_id', 'is', 'null')
          .order('status', ascending: true, nullsFirst: false);

      final vocabulary = (mainVocabularyResponse as List).map((json) {
        String? status;
        bool isAddedByUser = false;
        int? flashcardId = null;
        if (json['flashcards_fr'] is List && (json['flashcards_fr'] as List).isNotEmpty) {
          final flashcards = json['flashcards_fr'] as List;
          status = flashcards[0]?['status'];
          flashcardId = flashcards[0]?['id'];
        }
        return VocabularyItem(
          id: int.parse(contentId),
          word: json['text'] ?? '',
          translation: json['text_en'] ?? '',
          type: json['function'] ?? 'expr',
          exampleSentence: json['example'] ?? '',
          exampleTranslation: json['example_en'] ?? '',
          audioUrl: _getAudioUrl(json['audio_url']) ?? '',
          flashcardId: flashcardId,
          status: status,
          isAddedByUser: false,
        );
      }).toList();

      vocabulary.addAll(vocabularyAddedByUser.map((item) => VocabularyItem(
        id: item['id'],
        word: item['text'] ?? '',
        translation: item['text_translation'] ?? '',
        type: item['function'] ?? 'expr',
        exampleSentence: item['example'] ?? '',
        exampleTranslation: item['example_translation'] ?? '',
        audioUrl: '',
        flashcardId: item['id'],
        status: item['status'],
        isAddedByUser: true,
      )));
            
      final contentMulti = chapterResponse['content_multi'] ?? '';
      final paragraphs = parseContentToArticleParagraphs(contentMulti);
      final grammarPoints = <GrammarPoint>[];

      return Article(
        id: chapterResponse['id']?.toString() ?? '',
        chapterId: chapterResponse['id']?.toString() ?? '',
        title: chapterResponse['title'] ?? '',
        description: chapterResponse['description'] ?? '',
        author: '',
        imageUrl: _getImageUrl(chapterResponse['img_url']),
        readingStatus: chapterResponse['reading_status'] ?? null,
        level: chapterResponse['level'] ?? 'A1',
        category1: chapterResponse['category_1'] ?? '',
        category2: chapterResponse['category_2'] ?? '',
        category3: chapterResponse['category_3'] ?? '',
        contentType: 2,
        vocabulary: vocabulary,
        grammarPoints: grammarPoints,
        paragraphs: paragraphs,
        audioUrl: _getAudioUrl(chapterResponse['audio_url']),
        isFavorite: false,
        // isFree: chapterResponse['is_free'] ?? false,
      );
    } catch (e) {
      print('Error fetching chapter: $e');
      return null;
    }
  }

  /// Parse content_multi JSON structure to List<ArticleParagraph>
  /// Expected structure: Object with "paragraphs" array, each paragraph contains "sentences" array
  static List<ArticleParagraph> parseContentToArticleParagraphs(dynamic contentMulti) {
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
    // Extract isFavorite from progress_fr join (when user is logged in)
    bool isFavorite = false;
    String? readingStatus = null;
    final progressFr = json['progress_fr'];
    if (progressFr is List && progressFr.isNotEmpty) {
      final progress = progressFr.first;
      if (progress is Map && progress['is_liked'] == true) {
        isFavorite = true;
      }
      if (progress is Map && progress['reading_status'] != null) {
        readingStatus = progress['reading_status'];
      }
    }

    // Convert content_multi JSON to List<ArticleParagraph>
    final contentMulti = json['content_multi'];
    final paragraphs = parseContentToArticleParagraphs(contentMulti);
    return Article(
      id: json['id']?.toString() ?? '',
      chapterId: json['chapter_id'] ?? null,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      author: json['author'] ?? '',
      imageUrl: _getImageUrl(json['img_url']),
      readingStatus: readingStatus,
      level: json['level'] ?? 'A1',
      category1: json['category_1'] ?? '',
      category2: json['category_2'] ?? '',
      category3: json['category_3'] ?? '',
      audioUrl: _getAudioUrl(json['audio_url']),
      isFavorite: isFavorite,
      vocabulary: [],
      grammarPoints: [],
      paragraphs: paragraphs,
    );
  }

  Future<void> toggleFavorite(String articleId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      final contentId = int.parse(articleId);
      print('TOGGLE FAVORITE: $contentId');
      final existing = await _supabase
          .from('progress_fr')
          .select('id, reading_status, is_liked')
          .eq('content_id', contentId)
          .eq('user_id', user.id)
          .eq('content_type', 1)
          .maybeSingle();

      final bool isFavorite = existing != null ? existing['is_liked'] == true : false;
      final status = existing != null ? existing['reading_status'] as String? : null;
  print('IS FAVORITE: $isFavorite');
      final payload = {
        'content_id': contentId,
        'user_id': user.id,
        'content_type': 1,
        'reading_status': status,
        'is_liked': !isFavorite,
      };

      if (existing != null && existing['id'] != null) {
          print('AAA: $payload');
        await _supabase
            .from('progress_fr')
            .update(payload)
            .eq('id', existing['id']);
      } else {
        print('ZZ: $payload');
        await _supabase.from('progress_fr').insert(payload);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }

}

