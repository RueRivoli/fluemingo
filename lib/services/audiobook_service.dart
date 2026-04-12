import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/audiobook.dart';
import '../models/article.dart';
import '../utils/storage_url_helper.dart';
import '../utils/reference_language.dart';
import '../utils/json_utils.dart';
import 'article_service.dart';
import 'language_table_resolver.dart';

class AudiobookService {
  final SupabaseClient _supabase;
  static const String _storageBucket = 'content'; // Main storage bucket

  AudiobookService(this._supabase);

  String _table(String name) => LanguageTableResolver.table(name);

  Future<String> _getReferenceLanguageCode() =>
      ReferenceLanguage.getReferenceLanguageCode(_supabase);

  Future<void> _setAllChaptersFinished(int audiobookId, String userId) async {
    final chapters = await _supabase
        .from(_table('chapters'))
        .select('id')
        .eq('long_format_id', audiobookId);
    final chapterIds = (chapters as List)
        .map((c) => c['id'])
        .whereType<num>()
        .map((v) => v.toInt())
        .toList();

    if (chapterIds.isEmpty) return;

    final existingRows = await _supabase
        .from(_table('progress'))
        .select('id, chapter_id')
        .eq('content_id', audiobookId)
        .eq('user_id', userId)
        .eq('content_type', 2);

    final existingByChapter = <int, int>{};
    for (final row in (existingRows as List)) {
      final chapterId = row['chapter_id'];
      final id = row['id'];
      if (chapterId is num && id is num) {
        existingByChapter[chapterId.toInt()] = id.toInt();
      }
    }

    final now = DateTime.now().toIso8601String();
    for (final chapterId in chapterIds) {
      final payload = {
        'content_id': audiobookId,
        'user_id': userId,
        'content_type': 2,
        'chapter_id': chapterId,
        'reading_status': 'finished',
        'finished_datetime': now,
      };
      final existingId = existingByChapter[chapterId];
      if (existingId != null) {
        await _supabase
            .from(_table('progress'))
            .update(payload)
            .eq('id', existingId);
      } else {
        await _supabase.from(_table('progress')).insert(payload);
      }
    }
  }

  String _getImageUrl(String? imgPath) =>
      StorageUrlHelper.getImageUrl(_supabase, imgPath);

  /// Normalize storage path (no leading slash, no "content/" prefix).
  String? _normalizeStoragePath(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return null;
    String clean = path.startsWith('/') ? path.substring(1) : path;
    if (clean.startsWith('content/'))
      clean = clean.substring('content/'.length);
    return clean.isEmpty ? null : clean;
  }

  /// Resolve image URL: try signed URL first (for private buckets), fall back to public URL.
  Future<String> _getImageUrlResolved(String? imgPath) async {
    final cleanPath = _normalizeStoragePath(imgPath);
    if (cleanPath == null) return StorageUrlHelper.getStorageUrl(_supabase, imgPath);
    try {
      final signedUrl = await _supabase.storage
          .from(_storageBucket)
          .createSignedUrl(cleanPath, 3600);
      return signedUrl;
    } catch (e) {
      return StorageUrlHelper.getStorageUrl(_supabase, imgPath);
    }
  }

  /// Fetch all audiobooks from Supabase (fr_content table with content_type = 2)
  Future<List<Audiobook>> getAudiobooks({String? level}) async {
    try {
      final user = _supabase.auth.currentUser;
      final progressTable = _table('progress');
      final select = user != null
          ? '*, $progressTable!content_id(reading_status, is_liked)'
          : '*';
      var query = _supabase
          .from(_table('content'))
          .select(select)
          .eq('content_type', 2);

      // Filter fr_progress to the row matching content_id + content_type=2 + chapter_id=null (and current user)
      if (user != null) {
        query = query
            .eq('$progressTable.user_id', user.id)
            .eq('$progressTable.content_type', 2)
            .filter('$progressTable.chapter_id', 'is', 'null');
      }

      // Filter by level if provided
      if (level != null && level != 'All') {
        query = query.eq('level', level);
      }

      final response = await query;
      final referenceLanguageCode = await _getReferenceLanguageCode();
      return (response as List)
          .map((json) => _audiobookFromJson(json,
              referenceLanguageCode: referenceLanguageCode))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Fetch a single audiobook by ID with all related data (chapters, vocabulary)
  Future<Audiobook?> getAudiobookById(int id) async {
    try {
      final user = _supabase.auth.currentUser;

      final futures = <Future<dynamic>>[
        _getReferenceLanguageCode(),
        _supabase
            .from(_table('content'))
            .select('*, ${_table('chapters')}!long_format_id(*)')
            .eq('id', id)
            .eq('content_type', 2)
            .maybeSingle(),
      ];
      if (user != null) {
        futures.add(_supabase
            .from(_table('progress'))
            .select('reading_status, is_liked, chapter_id')
            .eq('content_id', id)
            .eq('content_type', 2)
            .eq('user_id', user.id));
      }
      final results = await Future.wait(futures);

      final referenceLanguageCode = results[0] as String;
      final audiobookResponse = results[1] as Map<String, dynamic>?;
      if (audiobookResponse == null) return null;

      // Split progress rows into overall (chapter_id=null) and per-chapter
      Map<String, dynamic>? progressResponse;
      final chapterStatusById = <int, String>{};
      if (user != null && results.length > 2) {
        final allProgressRows = results[2] as List<dynamic>;
        for (final row in allProgressRows) {
          if (row['chapter_id'] == null) {
            progressResponse = row as Map<String, dynamic>;
          } else {
            final chapterId = row['chapter_id'];
            final readingStatus = row['reading_status'];
            if (chapterId is num && readingStatus is String) {
              chapterStatusById[chapterId.toInt()] = readingStatus;
            }
          }
        }
      }

      final chaptersData =
          audiobookResponse[_table('chapters')] as List<dynamic>? ?? [];
      final sortedChapters = List<Map<String, dynamic>>.from(chaptersData)
        ..sort((a, b) {
          final orderIdA = a['order_id'] as int? ?? 0;
          final orderIdB = b['order_id'] as int? ?? 0;
          return orderIdA.compareTo(orderIdB);
        });

      final imageUrl = _getImageUrl(
          (audiobookResponse['image_url'] ?? audiobookResponse['img_url'])
                  ?.toString() ??
              '');

      final chapters = sortedChapters.map((chapterJson) {
        final chapterIdValue = chapterJson['id'];
        final chapterId = chapterIdValue is num ? chapterIdValue.toInt() : null;
        return Article(
          id: audiobookResponse['id'].toString(),
          chapterId: chapterId?.toString(),
          title: chapterJson['title'] ?? '',
          parentTitle: audiobookResponse['title'] ?? '',
          description: ArticleService.localizedDescription(
              chapterJson, referenceLanguageCode),
          author: audiobookResponse['author'] ?? '',
          imageUrl: imageUrl,
          level: audiobookResponse['level']?.toString() ?? 'A1',
          category1: audiobookResponse['category_1'] ?? '',
          category2: audiobookResponse['category_2'] ?? '',
          category3: audiobookResponse['category_3'] ?? '',
          vocabulary: [],
          grammarPoints: [],
          paragraphs: [],
          audioUrl: '',
          readingStatus:
              chapterId != null ? chapterStatusById[chapterId] : null,
          isFavorite: false,
          orderId: chapterJson['order_id'] as int?,
          duration: chapterJson['duration'] as int?,
          contentType: 2,
        );
      }).toList();

      return Audiobook(
        id: audiobookResponse['id'],
        title: audiobookResponse['title'] ?? '',
        author: audiobookResponse['author'] ?? '',
        description: ArticleService.localizedDescription(
            audiobookResponse, referenceLanguageCode),
        imageUrl: imageUrl,
        level: audiobookResponse['level'] ?? 'A1',
        category1: audiobookResponse['category_1'] ?? '',
        category2: audiobookResponse['category_2'] ?? '',
        category3: audiobookResponse['category_3'] ?? '',
        chapters: chapters,
        createdAt: DateTime.parse(audiobookResponse['created_at']),
        readingStatus: progressResponse?['reading_status'] ?? null,
        isFavorite: progressResponse?['is_liked'] == true,
        isFree: audiobookResponse['is_free'] == true,
        isNew: JsonUtils.readIsNew(audiobookResponse),
      );
    } catch (e) {
      debugPrint('Error fetching audiobook: $e');
      return null;
    }
  }

  /// Convert JSON to Audiobook model (basic info only).
  /// When logged in, fr_progress is filtered to the row with chapter_id=null (overall audiobook progress).
  /// [imageUrlOverride] is used when resolved (e.g. signed) URL was computed by the caller.
  Audiobook _audiobookFromJson(Map<String, dynamic> json,
      {String? imageUrlOverride, String referenceLanguageCode = 'en'}) {
    bool isFavorite = false;
    String? readingStatus;
    final progressFr = json[_table('progress')];
    if (progressFr is List && progressFr.isNotEmpty) {
      final progress = progressFr.first as Map<String, dynamic>?;
      if (progress != null && progress['is_liked'] == true) isFavorite = true;
      if (progress != null && progress['reading_status'] != null) {
        readingStatus = progress['reading_status'] as String?;
      }
    }
    final imageUrl = imageUrlOverride ??
        _getImageUrl((json['image_url'] ?? json['img_url'])?.toString() ?? '');
    return Audiobook(
      id: json['id'] as int,
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description:
          ArticleService.localizedDescription(json, referenceLanguageCode),
      imageUrl: imageUrl,
      level: json['level'] ?? 'A1',
      category1: json['category_1'] ?? '',
      category2: json['category_2'] ?? '',
      category3: json['category_3'] ?? '',
      chapters: json['chapters'] ?? [],
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      readingStatus: readingStatus,
      isFavorite: isFavorite,
      isFree: json['is_free'] == true,
      isNew: JsonUtils.readIsNew(json),
    );
  }

  /// Update reading status for an audiobook in fr_progress
  Future<void> editAudiobookStatus(Audiobook audiobook, String status) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      final contentId = audiobook.id;
      final existing = await _supabase
          .from(_table('progress'))
          .select('id')
          .eq('content_id', contentId)
          .filter('chapter_id', 'is', 'null')
          .eq('user_id', user.id)
          .eq('content_type', 2)
          .maybeSingle();

      final payload = status == 'started'
          ? {
              'content_id': contentId,
              'user_id': user.id,
              'content_type': 2,
              'chapter_id': null,
              'reading_status': status,
              'started_datetime': DateTime.now().toIso8601String(),
            }
          : status == 'finished'
              ? {
                  'content_id': contentId,
                  'user_id': user.id,
                  'content_type': 2,
                  'chapter_id': null,
                  'reading_status': status,
                  'finished_datetime': DateTime.now().toIso8601String(),
                }
              : {
                  'content_id': contentId,
                  'user_id': user.id,
                  'content_type': 2,
                  'chapter_id': null,
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

      if (status == 'finished') {
        await _setAllChaptersFinished(contentId, user.id);
      }
    } catch (e) {
      debugPrint('Error editing audiobook status: $e');
    }
  }

  /// Toggle favorite (is_liked) for an audiobook in fr_progress
  Future<void> toggleFavorite(int audiobookId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      final existing = await _supabase
          .from(_table('progress'))
          .select('id, reading_status, is_liked')
          .eq('content_id', audiobookId)
          .eq('user_id', user.id)
          .eq('content_type', 2)
          .filter('chapter_id', 'is', 'null')
          .maybeSingle();
      final bool isFavorite =
          existing != null ? existing['is_liked'] == true : false;
      final status =
          existing != null ? existing['reading_status'] as String? : null;
      final payload = {
        'content_id': audiobookId,
        'user_id': user.id,
        'content_type': 2,
        'chapter_id': null,
        'is_liked': !isFavorite,
        if (status != null) 'reading_status': status,
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
      debugPrint('Error toggling audiobook favorite: $e');
    }
  }
}
