import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article.dart';
import '../models/vocabulary_item.dart';
import '../models/grammar_point.dart';
import '../models/article_paragraph.dart';
import '../models/article_sentence.dart';
import '../models/unit.dart';
import '../utils/storage_url_helper.dart';
import '../utils/reference_language.dart';
import '../utils/localization_field_resolver.dart';
import '../utils/json_utils.dart';
import 'language_table_resolver.dart';
import 'offline_content_service.dart';

class ArticleService {
  final SupabaseClient _supabase;
  final OfflineContentService _offlineContentService;
  ArticleService(this._supabase)
      : _offlineContentService = OfflineContentService();

  String _table(String name) => LanguageTableResolver.table(name);

  static String _toPascal(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  static String _localizedContentFieldValue({
    required Map<dynamic, dynamic> source,
    required String baseField,
    required String referenceLanguageCode,
  }) {
    final aliases =
        LocalizationFieldResolver.referenceLanguageAliases(referenceLanguageCode);
    final candidates = <String>[
      ...aliases.map((code) => '$baseField${_toPascal(code)}'),
      ...aliases.map((code) => '${baseField}_$code'),
      ...aliases.map((code) => '${baseField}_${code.toUpperCase()}'),
      '${baseField}En',
      '${baseField}_en',
      '${baseField}_EN',
    ];

    return LocalizationFieldResolver.readFirstNonEmptyFromMap(source, candidates);
  }

  Future<String> _getReferenceLanguageCode() =>
      ReferenceLanguage.getReferenceLanguageCode(_supabase);

  String _getImageUrl(String? imgPath) =>
      StorageUrlHelper.getImageUrl(_supabase, imgPath);

  String? _getAudioUrl(String? audioPath) =>
      StorageUrlHelper.getAudioUrl(_supabase, audioPath);

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
      rethrow;
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
      final parsedId = int.parse(id);
      final futures = <Future<dynamic>>[
        _getReferenceLanguageCode(),
        _supabase
            .from(_table('content'))
            .select(
                '*, ${_table('progress')}!content_id(is_liked, reading_status)')
            .eq('id', parsedId)
            .eq('content_type', 1)
            .single(),
        _supabase
            .from(_table('vocabulary'))
            .select('*, ${_table('flashcards')}!vocabulary_id(*)')
            .eq('reference_id', parsedId)
            .eq('content_type', 1),
        _supabase
            .from(_table('flashcards'))
            .select('*')
            .eq('content_id', parsedId)
            .eq('user_id', user.id)
            .filter('vocabulary_id', 'is', 'null')
            .order('status', ascending: true, nullsFirst: false),
      ];
      final results = await Future.wait(futures);

      final referenceLanguageCode = results[0] as String;
      final articleResponse = results[1] as Map<String, dynamic>;
      final mainVocabularyResponse = results[2] as List;
      final vocabularyAddedByUser = results[3] as List;

      final vocabulary = _parseVocabulary(
        mainVocabularyResponse: mainVocabularyResponse,
        vocabularyAddedByUser: vocabularyAddedByUser,
        referenceLanguageCode: referenceLanguageCode,
        fallbackId: parsedId,
      );
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
        description:
            localizedDescription(articleResponse, referenceLanguageCode),
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
        isNew: JsonUtils.readIsNew(articleResponse),
      );
    } catch (e) {
      debugPrint('Error fetching article: $e');
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
      debugPrint('Error editing article status: $e');
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
      debugPrint('Error editing chapter status: $e');
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
  Future<Article?> getChapterById(String contentId, String chapterId,
      {String? parentTitle}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return _offlineContentService.getCachedArticle(
        contentType: 2,
        contentId: contentId,
        chapterId: chapterId,
      );
    }
    try {
      final parsedContentId = int.parse(contentId);
      final parsedChapterId = int.parse(chapterId);
      final futures = <Future<dynamic>>[
        _getReferenceLanguageCode(),
        _supabase
            .from(_table('chapters'))
            .select()
            .eq('id', parsedChapterId)
            .single(),
        _supabase
            .from(_table('progress'))
            .select('reading_status')
            .eq('content_id', parsedContentId)
            .eq('chapter_id', parsedChapterId)
            .eq('content_type', 2)
            .eq('user_id', user.id)
            .maybeSingle(),
        _supabase
            .from(_table('vocabulary'))
            .select('*, ${_table('flashcards')}!vocabulary_id(*)')
            .eq('content_type', 2)
            .eq('chapter_id', parsedChapterId),
        _supabase
            .from(_table('flashcards'))
            .select('*')
            .eq('chapter_id', parsedChapterId)
            .eq('user_id', user.id)
            .filter('vocabulary_id', 'is', 'null')
            .order('status', ascending: true, nullsFirst: false),
      ];
      final results = await Future.wait(futures);

      final referenceLanguageCode = results[0] as String;
      final chapterResponse = results[1] as Map<String, dynamic>;
      final chapterProgress = results[2] as Map<String, dynamic>?;
      final mainVocabularyResponse = results[3] as List;
      final vocabularyAddedByUser = results[4] as List;

      final vocabulary = _parseVocabulary(
        mainVocabularyResponse: mainVocabularyResponse,
        vocabularyAddedByUser: vocabularyAddedByUser,
        referenceLanguageCode: referenceLanguageCode,
        fallbackId: parsedContentId,
      );

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
        parentTitle: parentTitle,
        description:
            localizedDescription(chapterResponse, referenceLanguageCode),
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
        isNew: JsonUtils.readIsNew(chapterResponse),
        // isFree: chapterResponse['is_free'] ?? false,
      );
    } catch (e) {
      debugPrint('Error fetching chapter: $e');
      return _offlineContentService.getCachedArticle(
        contentType: 2,
        contentId: contentId,
        chapterId: chapterId,
      );
    }
  }

  /// Parse content_multi JSON structure to List<ArticleParagraph>
  /// Expected structure: Object with "paragraphs" array, each paragraph contains "sentences" array
  /// Returns the description in the user's native language (`description_{lg}`),
  /// falling back to `description_en` only. Never falls back to the target-language
  /// `description` column.
  static String localizedDescription(
      Map<dynamic, dynamic> source, String referenceLanguageCode) {
    return _localizedContentFieldValue(
      source: source,
      baseField: 'description',
      referenceLanguageCode: referenceLanguageCode,
    );
  }

  /// Parse vocabulary rows (from `{lang}_vocabulary` joined with flashcards)
  /// and user-added flashcard rows into a single [VocabularyItem] list.
  List<VocabularyItem> _parseVocabulary({
    required List<dynamic> mainVocabularyResponse,
    required List<dynamic> vocabularyAddedByUser,
    required String referenceLanguageCode,
    required int fallbackId,
  }) {
    // Sort: rows with an associated flashcard first
    final mainList = List<dynamic>.from(mainVocabularyResponse);
    mainList.sort((a, b) {
      final aHasFlashcard = a[_table('flashcards')] is List &&
          (a[_table('flashcards')] as List).isNotEmpty;
      final bHasFlashcard = b[_table('flashcards')] is List &&
          (b[_table('flashcards')] as List).isNotEmpty;
      if (aHasFlashcard == bHasFlashcard) return 0;
      return aHasFlashcard ? -1 : 1;
    });

    final vocabulary = mainList.map((json) {
      String? status;
      int? flashcardId;
      if (json[_table('flashcards')] is List &&
          (json[_table('flashcards')] as List).isNotEmpty) {
        final flashcards = json[_table('flashcards')] as List;
        status = flashcards[0]?['status'];
        flashcardId = flashcards[0]?['id'];
      }
      return VocabularyItem(
        id: json['id'] ?? fallbackId,
        word: json['text'] ?? '',
        translation: LocalizationFieldResolver.localizedVocabularyFieldValue(
          source: json,
          baseField: 'text',
          referenceLanguageCode: referenceLanguageCode,
        ),
        type: json['function'] ?? 'expr',
        properName: json['properName'] ?? false,
        exampleSentence: json['example'] ?? '',
        exampleTranslation:
            LocalizationFieldResolver.localizedVocabularyFieldValue(
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
          properName: item['properName'] ?? false,
          exampleSentence: item['example'] ?? '',
          exampleTranslation: item['example_translation'] ?? '',
          audioUrl: _getAudioUrl(item['audio_url']) ?? '',
          basis: item['basis'] is String ? item['basis'] as String : '',
          flashcardId: item['id'],
          status: item['status'],
          isAddedByUser: true,
        )));

    return vocabulary;
  }

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
        debugPrint('Error: parsed is not a Map, it is: ${parsed.runtimeType}');
        return [];
      }

      final paragraphsData = parsed['paragraphs'];
      if (paragraphsData == null || paragraphsData is! List) {
        debugPrint('Error: paragraphs key not found or not a List');
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
    } catch (e) {
      debugPrint('Error parsing content_multi: $e');
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
      description: localizedDescription(json, referenceLanguageCode),
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
      isNew: JsonUtils.readIsNew(json),
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
      debugPrint('Error toggling favorite: $e');
    }
  }
}
