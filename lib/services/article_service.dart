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
import 'language_table_resolver.dart';
import 'offline_content_service.dart';

class ArticleService {
  final SupabaseClient _supabase;
  final OfflineContentService _offlineContentService;
  static const String _storageBucket = 'content'; // Main storage bucket
  String? _cachedReferenceLanguageCode;

  ArticleService(this._supabase)
      : _offlineContentService = OfflineContentService();

  String _table(String name) => LanguageTableResolver.table(name);

  static String _normalizeReferenceLanguageCode(String? code) {
    final normalized = (code ?? '').trim().toLowerCase();
    switch (normalized) {
      case 'es':
      case 'sp':
        return 'sp';
      case 'de':
      case 'ge':
        return 'ge';
      case 'nl':
      case 'dt':
        return 'dt';
      case 'ja':
      case 'jp':
        return 'jp';
      default:
        return normalized;
    }
  }

  static List<String> _referenceLanguageAliases(String? code) {
    final normalized = _normalizeReferenceLanguageCode(code);
    switch (normalized) {
      case 'sp':
        return const ['sp', 'es'];
      case 'ge':
        return const ['ge', 'de'];
      case 'dt':
        return const ['dt', 'nl'];
      case 'jp':
        return const ['jp', 'ja'];
      default:
        return normalized.isEmpty ? const [] : [normalized];
    }
  }

  static String _toPascal(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  static String _readFirstNonEmptyFromMap(
      Map<dynamic, dynamic> source, List<String> candidates) {
    for (final key in candidates) {
      final value = source[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString();
      }
    }

    if (source.keys.any((key) => key is String)) {
      final lowerCaseIndex = <String, dynamic>{};
      for (final entry in source.entries) {
        final key = entry.key;
        if (key is String) {
          lowerCaseIndex[key.toLowerCase()] = entry.value;
        }
      }
      for (final key in candidates) {
        final value = lowerCaseIndex[key.toLowerCase()];
        if (value != null && value.toString().trim().isNotEmpty) {
          return value.toString();
        }
      }
    }

    return '';
  }

  static String _localizedVocabularyFieldValue({
    required Map<dynamic, dynamic> source,
    required String baseField,
    required String referenceLanguageCode,
  }) {
    final aliases = _referenceLanguageAliases(referenceLanguageCode);
    final candidates = <String>[
      ...aliases.map((code) => '${baseField}_$code'),
      ...aliases.map((code) => '${baseField}_${code.toUpperCase()}'),
      '${baseField}_en',
      '${baseField}_EN',
    ];

    return _readFirstNonEmptyFromMap(source, candidates);
  }

  static String _localizedContentFieldValue({
    required Map<dynamic, dynamic> source,
    required String baseField,
    required String referenceLanguageCode,
  }) {
    final aliases = _referenceLanguageAliases(referenceLanguageCode);
    final candidates = <String>[
      ...aliases.map((code) => '$baseField${_toPascal(code)}'),
      ...aliases.map((code) => '${baseField}_$code'),
      ...aliases.map((code) => '${baseField}_${code.toUpperCase()}'),
      '${baseField}En',
      '${baseField}_en',
      '${baseField}_EN',
    ];

    return _readFirstNonEmptyFromMap(source, candidates);
  }

  Future<String> _getReferenceLanguageCode() async {
    if (_cachedReferenceLanguageCode != null &&
        _cachedReferenceLanguageCode!.isNotEmpty) {
      return _cachedReferenceLanguageCode!;
    }

    final user = _supabase.auth.currentUser;
    if (user == null) return 'en';

    try {
      final profile = await _supabase
          .from('profiles')
          .select('native_language')
          .eq('id', user.id)
          .maybeSingle();
      final referenceLanguage =
          _normalizeReferenceLanguageCode(profile?['native_language']);
      if (referenceLanguage.isNotEmpty) {
        _cachedReferenceLanguageCode = referenceLanguage;
        return referenceLanguage;
      }
    } catch (e) {
      print('Error fetching reference language: $e');
    }

    return 'en';
  }

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
      final url =
          _supabase.storage.from(_storageBucket).getPublicUrl(cleanPath);
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

  Future<List<Article>> getArticles({String? level}) async {
    try {
      final user = _supabase.auth.currentUser;
      final referenceLanguageCode = await _getReferenceLanguageCode();

      final progressTable = _table('progress');
      final select = user != null
          ? '*, $progressTable!content_id(is_liked, reading_status)'
          : '*';
      var query = _supabase
          .from(_table('content'))
          .select(select)
          .eq('content_type', 1);

      if (user != null) {
        query = query.eq('$progressTable.user_id', user.id);
      }

      // Filter by level if provided
      if (level != null && level != 'All') {
        query = query.eq('level', level);
      }

      final response = await query;

      return (response as List)
          .map((json) => _articleFromJson(
                json,
                referenceLanguageCode: referenceLanguageCode,
              ))
          .toList();
    } catch (e) {
      print('Error fetching articles: $e');
      rethrow;
    }
  }

  /// Check if a vocabulary item is saved in fr_flashcards for the current user
  Future<bool> _isVocabularyItemSaved(String word, String articleId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from(_table('flashcards'))
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

  Future<Article?> getArticleById(String id) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return _offlineContentService.getCachedArticle(
        contentType: 1,
        contentId: id,
      );
    }
    try {
      final referenceLanguageCode = await _getReferenceLanguageCode();
      final articleResponse = await _supabase
          .from(_table('content'))
          .select(
              '*, ${_table('progress')}!content_id(is_liked, reading_status)')
          .eq('id', int.parse(id))
          .eq('content_type', 1)
          .single();
      if (articleResponse == null) {
        return _offlineContentService.getCachedArticle(
          contentType: 1,
          contentId: id,
        );
      }

      // Fetch proposed vocabulary saved in flashcards
      final mainVocabularyResponse = await _supabase
          .from(_table('vocabulary'))
          .select('*, ${_table('flashcards')}!vocabulary_id(*)')
          .eq('reference_id', int.parse(id))
          .eq('content_type', 1);

      // Rank rows with an associated fr_flashcards row first
      final mainList = mainVocabularyResponse as List;
      mainList.sort((a, b) {
        final aHasFlashcard = a[_table('flashcards')] is List &&
            (a[_table('flashcards')] as List).isNotEmpty;
        final bHasFlashcard = b[_table('flashcards')] is List &&
            (b[_table('flashcards')] as List).isNotEmpty;
        if (aHasFlashcard == bHasFlashcard) return 0;
        return aHasFlashcard ? -1 : 1; // rows with flashcard first
      });
      // Fetch vocabulary added by user to flashcards
      final vocabularyAddedByUser = await _supabase
          .from(_table('flashcards'))
          .select('*')
          .eq('content_id', int.parse(id))
          .eq('user_id', user.id)
          .filter('vocabulary_id', 'is', 'null')
          .order('status', ascending: true, nullsFirst: false);

      final vocabulary = (mainVocabularyResponse as List).map((json) {
        String? status;
        bool isAddedByUser = false;
        int? flashcardId = null;
        if (json[_table('flashcards')] is List &&
            (json[_table('flashcards')] as List).isNotEmpty) {
          final flashcards = json[_table('flashcards')] as List;
          status = flashcards[0]?['status'];
          flashcardId = flashcards[0]?['id'];
        }
        return VocabularyItem(
          id: json['id'],
          word: json['text'] ?? '',
          translation: _localizedVocabularyFieldValue(
            source: json,
            baseField: 'text',
            referenceLanguageCode: referenceLanguageCode,
          ),
          type: json['function'] ?? 'expr',
          exampleSentence: json['example'] ?? '',
          exampleTranslation: _localizedVocabularyFieldValue(
            source: json,
            baseField: 'example',
            referenceLanguageCode: referenceLanguageCode,
          ),
          audioUrl: _getAudioUrl(json['audio_url']) ?? '',
          basis: json['basis'] is String ? json['basis'] as String : '',
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
            audioUrl: _getAudioUrl(item['audio_url']) ?? '',
            basis: item['basis'] is String ? item['basis'] as String : '',
            flashcardId: item['id'],
            status: item['status'],
            isAddedByUser: true,
          )));
      final progressFr = articleResponse[_table('progress')];
      final progressList =
          progressFr is List && progressFr.isNotEmpty ? progressFr : null;
      final progressRow = progressList != null
          ? progressList[0] as Map<String, dynamic>?
          : null;
      final contentMulti = articleResponse['content_multi'] ?? '';
      final paragraphs = parseContentToArticleParagraphs(
        contentMulti,
        referenceLanguageCode: referenceLanguageCode,
      );
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
      return _offlineContentService.getCachedArticle(
        contentType: 1,
        contentId: id,
      );
    }
  }

  /// Update reading status for an article in fr_progress
  Future<void> editArticleStatus(Article article, String status) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      final contentId = int.parse(article.id);
      final existing = await _supabase
          .from(_table('progress'))
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
          : status == 'finished'
              ? {
                  'content_id': contentId,
                  'user_id': user.id,
                  'content_type': 1,
                  'reading_status': status,
                  'finished_datetime': DateTime.now().toIso8601String(),
                }
              : {
                  'content_id': contentId,
                  'user_id': user.id,
                  'content_type': 1,
                  'reading_status': status,
                };

      if (existing != null && existing['id'] != null) {
        await _supabase
            .from(_table('progress'))
            .update(payload)
            .eq('id', existing['id']);
      } else {
        await _supabase.from(_table('progress')).insert(payload);
      }
    } catch (e) {
      print('Error editing article status: $e');
    }
  }

  /// Update reading status for a specific audiobook chapter in fr_progress.
  /// Uses content_type=2 with content_id=audiobookId and chapter_id=chapterId.
  Future<void> editChapterStatus({
    required String audiobookId,
    required String chapterId,
    required String status,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      final contentId = int.parse(audiobookId);
      final chapterIdInt = int.parse(chapterId);
      final existing = await _supabase
          .from(_table('progress'))
          .select('id')
          .eq('content_id', contentId)
          .eq('chapter_id', chapterIdInt)
          .eq('user_id', user.id)
          .eq('content_type', 2)
          .maybeSingle();

      final payload = status == 'started'
          ? {
              'content_id': contentId,
              'chapter_id': chapterIdInt,
              'user_id': user.id,
              'content_type': 2,
              'reading_status': status,
              'started_datetime': DateTime.now().toIso8601String(),
            }
          : status == 'finished'
              ? {
                  'content_id': contentId,
                  'chapter_id': chapterIdInt,
                  'user_id': user.id,
                  'content_type': 2,
                  'reading_status': status,
                  'finished_datetime': DateTime.now().toIso8601String(),
                }
              : {
                  'content_id': contentId,
                  'chapter_id': chapterIdInt,
                  'user_id': user.id,
                  'content_type': 2,
                  'reading_status': status,
                };

      if (existing != null && existing['id'] != null) {
        await _supabase
            .from(_table('progress'))
            .update(payload)
            .eq('id', existing['id']);
      } else {
        await _supabase.from(_table('progress')).insert(payload);
      }

      await _syncAudiobookStatusFromChapterProgress(
        audiobookId: contentId,
        userId: user.id,
      );
    } catch (e) {
      print('Error editing chapter status: $e');
    }
  }

  /// If all chapters of an audiobook are finished for a user, mark the overall
  /// audiobook progress row (chapter_id = null) as finished.
  /// If the first chapter is started/finished, mark overall audiobook as started.
  Future<void> _syncAudiobookStatusFromChapterProgress({
    required int audiobookId,
    required String userId,
  }) async {
    final chapters = await _supabase
        .from(_table('chapters'))
        .select('id, order_id')
        .eq('long_format_id', audiobookId)
        .order('order_id', ascending: true);
    final chapterIds = (chapters as List)
        .map((row) => row['id'])
        .whereType<num>()
        .map((v) => v.toInt())
        .toList();

    if (chapterIds.isEmpty) return;
    final firstChapterId = chapterIds.first;

    final chapterProgressRows = await _supabase
        .from(_table('progress'))
        .select('chapter_id, reading_status')
        .eq('content_id', audiobookId)
        .eq('user_id', userId)
        .eq('content_type', 2)
        .inFilter('chapter_id', chapterIds);

    int statusRank(String? status) {
      final normalized = status?.toLowerCase().trim();
      if (normalized == 'finished') return 2;
      if (normalized == 'started') return 1;
      return 0;
    }

    final chapterStatusRank = <int, int>{};
    for (final row in (chapterProgressRows as List)) {
      final chapterIdValue = row['chapter_id'];
      final readingStatus = row['reading_status'] as String?;
      if (chapterIdValue is num) {
        final chapterId = chapterIdValue.toInt();
        final currentRank = chapterStatusRank[chapterId] ?? 0;
        final newRank = statusRank(readingStatus);
        if (newRank > currentRank) {
          chapterStatusRank[chapterId] = newRank;
        }
      }
    }

    final allChaptersFinished =
        chapterIds.every((id) => (chapterStatusRank[id] ?? 0) == 2);
    final firstChapterStarted = (chapterStatusRank[firstChapterId] ?? 0) >= 1;

    final targetOverallStatus = allChaptersFinished
        ? 'finished'
        : (firstChapterStarted ? 'started' : 'not_started');

    final existingOverallRow = await _supabase
        .from(_table('progress'))
        .select('id, reading_status')
        .eq('content_id', audiobookId)
        .eq('user_id', userId)
        .eq('content_type', 2)
        .filter('chapter_id', 'is', 'null')
        .maybeSingle();

    final existingOverallStatus =
        (existingOverallRow?['reading_status'] as String?)?.toLowerCase();
    if (existingOverallStatus == targetOverallStatus) return;

    final overallPayload = {
      'content_id': audiobookId,
      'user_id': userId,
      'content_type': 2,
      'chapter_id': null,
      'reading_status': targetOverallStatus,
      if (targetOverallStatus == 'started')
        'started_datetime': DateTime.now().toIso8601String(),
      if (targetOverallStatus == 'finished')
        'finished_datetime': DateTime.now().toIso8601String(),
    };

    if (existingOverallRow != null && existingOverallRow['id'] != null) {
      await _supabase
          .from(_table('progress'))
          .update(overallPayload)
          .eq('id', existingOverallRow['id']);
    } else {
      await _supabase.from(_table('progress')).insert(overallPayload);
    }
  }

  /// Fetch a single article by ID with all related data
  Future<Article?> getChapterById(String contentId, String chapterId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return _offlineContentService.getCachedArticle(
        contentType: 2,
        contentId: contentId,
        chapterId: chapterId,
      );
    }
    try {
      final referenceLanguageCode = await _getReferenceLanguageCode();
      // Fetch article from fr_content table
      final chapterResponse = await _supabase
          .from(_table('chapters'))
          .select()
          .eq('id', int.parse(chapterId))
          .single();

      if (chapterResponse == null) {
        return _offlineContentService.getCachedArticle(
          contentType: 2,
          contentId: contentId,
          chapterId: chapterId,
        );
      }

      final chapterProgress = await _supabase
          .from(_table('progress'))
          .select('reading_status')
          .eq('content_id', int.parse(contentId))
          .eq('chapter_id', int.parse(chapterId))
          .eq('content_type', 2)
          .eq('user_id', user.id)
          .maybeSingle();

      // Fetch proposed vocabulary saved in flashcards
      final mainVocabularyResponse = await _supabase
          .from(_table('vocabulary'))
          .select('*, ${_table('flashcards')}!vocabulary_id(*)')
          .eq('content_type', 2)
          .eq('chapter_id', int.parse(chapterId));
      // Rank rows with an associated fr_flashcards row first
      final mainList = mainVocabularyResponse as List;
      mainList.sort((a, b) {
        final aHasFlashcard = a[_table('flashcards')] is List &&
            (a[_table('flashcards')] as List).isNotEmpty;
        final bHasFlashcard = b[_table('flashcards')] is List &&
            (b[_table('flashcards')] as List).isNotEmpty;
        if (aHasFlashcard == bHasFlashcard) return 0;
        return aHasFlashcard ? -1 : 1; // rows with flashcard first
      });

      // Fetch vocabulary added by user to flashcards
      final vocabularyAddedByUser = await _supabase
          .from(_table('flashcards'))
          .select('*')
          .eq('chapter_id', int.parse(chapterId))
          .eq('user_id', user.id)
          .filter('vocabulary_id', 'is', 'null')
          .order('status', ascending: true, nullsFirst: false);

      final vocabulary = (mainVocabularyResponse as List).map((json) {
        String? status;
        bool isAddedByUser = false;
        int? flashcardId = null;
        if (json[_table('flashcards')] is List &&
            (json[_table('flashcards')] as List).isNotEmpty) {
          final flashcards = json[_table('flashcards')] as List;
          status = flashcards[0]?['status'];
          flashcardId = flashcards[0]?['id'];
        }
        return VocabularyItem(
          id: int.parse(contentId),
          word: json['text'] ?? '',
          translation: _localizedVocabularyFieldValue(
            source: json,
            baseField: 'text',
            referenceLanguageCode: referenceLanguageCode,
          ),
          type: json['function'] ?? 'expr',
          exampleSentence: json['example'] ?? '',
          exampleTranslation: _localizedVocabularyFieldValue(
            source: json,
            baseField: 'example',
            referenceLanguageCode: referenceLanguageCode,
          ),
          audioUrl: _getAudioUrl(json['audio_url']) ?? '',
          basis: json['basis'] is String ? json['basis'] as String : '',
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
            audioUrl: _getAudioUrl(item['audio_url']) ?? '',
            basis: item['basis'] is String ? item['basis'] as String : '',
            flashcardId: item['id'],
            status: item['status'],
            isAddedByUser: true,
          )));

      final contentMulti = chapterResponse['content_multi'] ?? '';
      final paragraphs = parseContentToArticleParagraphs(
        contentMulti,
        referenceLanguageCode: referenceLanguageCode,
      );
      final grammarPoints = <GrammarPoint>[];

      return Article(
        id: contentId,
        chapterId: chapterResponse['id']?.toString() ?? '',
        title: chapterResponse['title'] ?? '',
        description: chapterResponse['description'] ?? '',
        author: '',
        imageUrl: _getImageUrl(chapterResponse['img_url']),
        readingStatus: chapterProgress?['reading_status'] ?? null,
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
        orderId: chapterResponse['order_id'] as int?,
        // isFree: chapterResponse['is_free'] ?? false,
      );
    } catch (e) {
      print('Error fetching chapter: $e');
      return _offlineContentService.getCachedArticle(
        contentType: 2,
        contentId: contentId,
        chapterId: chapterId,
      );
    }
  }

  /// Parse content_multi JSON structure to List<ArticleParagraph>
  /// Expected structure: Object with "paragraphs" array, each paragraph contains "sentences" array
  static List<ArticleParagraph> parseContentToArticleParagraphs(
    dynamic contentMulti, {
    String referenceLanguageCode = 'en',
  }) {
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

      return paragraphsData
          .map((paragraphJson) {
            if (paragraphJson is! Map) {
              return null;
            }

            // Extract sentences from the paragraph
            final sentencesData = paragraphJson['sentences'];
            if (sentencesData == null || sentencesData is! List) {
              return null;
            }

            // Parse each sentence in the paragraph
            final sentences = sentencesData
                .map((sentenceJson) {
                  if (sentenceJson is! Map) {
                    return null;
                  }

                  // Extract text and translation in the user's reference language
                  final originalText = sentenceJson['text']?.toString() ?? '';
                  final translationText = _localizedContentFieldValue(
                    source: sentenceJson,
                    baseField: 'text',
                    referenceLanguageCode: referenceLanguageCode,
                  );

                  // Extract units with translations in the user's reference language
                  final unitsList = <Unit>[];
                  final unitsData = sentenceJson['units'];
                  if (unitsData is List) {
                    for (final unitJson in unitsData) {
                      if (unitJson is! Map) continue;

                      unitsList.add(Unit(
                        text: unitJson['text']?.toString() ?? '',
                        translatedText: _localizedContentFieldValue(
                          source: unitJson,
                          baseField: 'text',
                          referenceLanguageCode: referenceLanguageCode,
                        ),
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
                })
                .whereType<ArticleSentence>()
                .where((sentence) => sentence.originalText.isNotEmpty)
                .toList();

            // Create ArticleParagraph containing all sentences
            if (sentences.isEmpty) {
              return null;
            }

            return ArticleParagraph(
              sentences: sentences,
            );
          })
          .whereType<ArticleParagraph>()
          .where((paragraph) => paragraph.sentences.isNotEmpty)
          .toList();
    } catch (e, stackTrace) {
      print('Error parsing content_multi: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  /// Convert JSON to Article model
  Article _articleFromJson(
    Map<String, dynamic> json, {
    String referenceLanguageCode = 'en',
  }) {
    // Extract isFavorite from fr_progress join (when user is logged in)
    bool isFavorite = false;
    String? readingStatus = null;
    final progressFr = json[_table('progress')];
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
    final paragraphs = parseContentToArticleParagraphs(
      contentMulti,
      referenceLanguageCode: referenceLanguageCode,
    );
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
      isFree: json['is_free'] ?? false,
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
      final existing = await _supabase
          .from(_table('progress'))
          .select('id, reading_status, is_liked')
          .eq('content_id', contentId)
          .eq('user_id', user.id)
          .eq('content_type', 1)
          .maybeSingle();

      final bool isFavorite =
          existing != null ? existing['is_liked'] == true : false;
      final status =
          existing != null ? existing['reading_status'] as String? : null;
      final payload = {
        'content_id': contentId,
        'user_id': user.id,
        'content_type': 1,
        'reading_status': status,
        'is_liked': !isFavorite,
      };

      if (existing != null && existing['id'] != null) {
        await _supabase
            .from(_table('progress'))
            .update(payload)
            .eq('id', existing['id']);
      } else {
        await _supabase.from(_table('progress')).insert(payload);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
    }
  }
}
