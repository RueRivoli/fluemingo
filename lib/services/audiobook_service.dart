import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/audiobook.dart';
import '../models/vocabulary_item.dart';
import '../models/article.dart';
import '../models/chapter_overview.dart';
import 'article_service.dart';

class AudiobookService {
  final SupabaseClient _supabase;
  static const String _storageBucket = 'content'; // Main storage bucket

  AudiobookService(this._supabase);

  /// Get full public URL for a file stored in Supabase Storage
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
      final url = _supabase.storage.from(_storageBucket).getPublicUrl(cleanPath);
      return url;
    } catch (e) {
      print('Error constructing storage URL: $e');
      return '';
    }
  }

  /// Normalize storage path (no leading slash, no "content/" prefix).
  String? _normalizeStoragePath(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return null;
    String clean = path.startsWith('/') ? path.substring(1) : path;
    if (clean.startsWith('content/')) clean = clean.substring('content/'.length);
    return clean.isEmpty ? null : clean;
  }

  /// Get full public URL for an image stored in Supabase Storage
  String _getImageUrl(String? imgPath) {
    return _getStorageUrl(imgPath);
  }

  /// Resolve image URL: try signed URL first (for private buckets), fall back to public URL.
  /// Use this when images don't load with getPublicUrl (e.g. bucket is private).
  Future<String> _getImageUrlResolved(String? imgPath) async {
    final cleanPath = _normalizeStoragePath(imgPath);
    if (cleanPath == null) return _getStorageUrl(imgPath);
    try {
      final signedUrl = await _supabase.storage
          .from(_storageBucket)
          .createSignedUrl(cleanPath, 3600);
      return signedUrl;
    } catch (e) {
      // Fallback to public URL (e.g. if bucket is public or signed URL fails)
      return _getStorageUrl(imgPath);
    }
  }

  /// Get full public URL for an audio file stored in Supabase Storage
  String? _getAudioUrl(String? audioPath) {
    if (audioPath == null || audioPath.isEmpty) {
      return null;
    }
    return _getStorageUrl(audioPath);
  }

  /// Fetch all audiobooks from Supabase (content_fr table with content_type = 2)
  Future<List<Audiobook>> getAudiobooks({String? level}) async {
    try {
      final user = _supabase.auth.currentUser;
      final select = user != null
          ? '*, progress_fr!content_id(reading_status, is_liked)'
          : '*';
      var query = _supabase
          .from('content_fr')
          .select(select)
          .eq('content_type', 2);

      // Filter progress_fr to the row matching content_id + content_type=2 + chapter_id=null (and current user)
      if (user != null) {
        query = query
            .eq('progress_fr.user_id', user.id)
            .eq('progress_fr.content_type', 2)
            .filter('progress_fr.chapter_id', 'is', 'null');
      }

      // Filter by level if provided
      if (level != null && level != 'All') {
        query = query.eq('level', level);
      }

      final response = await query;
      print('TTTT: $response');
      final list = <Audiobook>[];
      for (final json in response as List) {
        final rawPath = (json['image_url'] ?? json['img_url'])?.toString() ?? '';
        final imageUrl = await _getImageUrlResolved(rawPath);
        list.add(_audiobookFromJson(json, imageUrlOverride: imageUrl));
      }
      return list;
    } catch (e) {
      print('Error fetching audiobooks: $e');
      rethrow;
    }
  }

  /// Fetch a single audiobook by ID with all related data (chapters, vocabulary)
  Future<Audiobook?> getAudiobookById(int id) async {
    try {
      // Fetch audiobook from content_fr table
      final audiobookResponse = await _supabase
          .from('content_fr')
          .select('*, chapters_fr!long_format_id(*)')
          .eq('id', id)
          .eq('content_type', 2)
          .maybeSingle();
      if (audiobookResponse == null) return null;
      print('audiobookResponse: $audiobookResponse');
      // Convert chapters_fr to ChapterOverview objects and sort by order_id (ascending)
      final chaptersData = audiobookResponse['chapters_fr'] as List<dynamic>? ?? [];
      final sortedChapters = List<Map<String, dynamic>>.from(chaptersData)
        ..sort((a, b) {
          final orderIdA = a['order_id'] as int? ?? 0;
          final orderIdB = b['order_id'] as int? ?? 0;
          return orderIdA.compareTo(orderIdB);
        });
      
      final progressResponse = await _supabase
          .from('progress_fr')
          .select('reading_status, is_liked')
          .eq('content_id', id)
          .eq('content_type', 2)
          .filter('chapter_id', 'is', 'null')
          .maybeSingle();
      final rawImgPath = (audiobookResponse['image_url'] ?? audiobookResponse['img_url'])?.toString() ?? '';
      final resolvedImageUrl = await _getImageUrlResolved(rawImgPath);
      final chapters = sortedChapters.map((chapterJson) {
        return Article(
          id: audiobookResponse['id'].toString(),
          chapterId: chapterJson['id'].toString(),
          title: chapterJson['title'] ?? '',
          description: chapterJson['description'] ?? '',
          author: audiobookResponse['author'] ?? '',
          imageUrl: resolvedImageUrl,
          level: audiobookResponse['level']?.toString() ?? 'A1',
          category1: audiobookResponse['category_1'] ?? '',
          category2: audiobookResponse['category_2'] ?? '',
          category3: audiobookResponse['category_3'] ?? '',
          vocabulary: [],
          grammarPoints: [],
          paragraphs: ArticleService.parseContentToArticleParagraphs(chapterJson['content_multi']),
          audioUrl: '',
          readingStatus: audiobookResponse['reading_status'] ?? null,
          isFavorite: false,
          orderId: chapterJson['order_id'] as int?,
          duration: chapterJson['duration'] as int?,
          contentType: 2,
        );
      }).toList();
      // Create audiobook with all related data
      final descriptionRef = audiobookResponse['description_en']?.toString();
      return Audiobook(
        id: audiobookResponse['id'],
        title: audiobookResponse['title'] ?? '',
        author: audiobookResponse['author'] ?? '',
        description: audiobookResponse['description'] ?? '',
        descriptionRef: descriptionRef != null && descriptionRef.isNotEmpty ? descriptionRef : null,
        imageUrl: resolvedImageUrl,
        level: audiobookResponse['level'] ?? 'A1',
        category1: audiobookResponse['category_1'] ?? '',
        category2: audiobookResponse['category_2'] ?? '',
        category3: audiobookResponse['category_3'] ?? '',
        chapters: chapters,
        createdAt: DateTime.parse(audiobookResponse['created_at']),
        readingStatus: progressResponse?['reading_status'] ?? null,
        isFavorite: progressResponse?['is_liked'] == true,
        isFree: audiobookResponse['is_free'] == true,
      );

    } catch (e) {
      print('Error fetching audiobook: $e');
      return null;
    }
  }

  /// Convert JSON to Audiobook model (basic info only).
  /// When logged in, progress_fr is filtered to the row with chapter_id=null (overall audiobook progress).
  /// [imageUrlOverride] is used when resolved (e.g. signed) URL was computed by the caller.
  Audiobook _audiobookFromJson(Map<String, dynamic> json, {String? imageUrlOverride}) {
    bool isFavorite = false;
    String? readingStatus;
    final progressFr = json['progress_fr'];
    if (progressFr is List && progressFr.isNotEmpty) {
      final progress = progressFr.first as Map<String, dynamic>?;
      if (progress != null && progress['is_liked'] == true) isFavorite = true;
      if (progress != null && progress['reading_status'] != null) {
        readingStatus = progress['reading_status'] as String?;
      }
    }
    final descriptionRef = json['description_en']?.toString();
    final imageUrl = imageUrlOverride ?? _getImageUrl((json['image_url'] ?? json['img_url'])?.toString() ?? '');
    return Audiobook(
      id: json['id'] as int,
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      description: json['description'] ?? '',
      descriptionRef: descriptionRef != null && descriptionRef.isNotEmpty ? descriptionRef : null,
      imageUrl: imageUrl,
      level: json['level'] ?? 'A1',
      category1: json['category_1'] ?? '',
      category2: json['category_2'] ?? '',
      category3: json['category_3'] ?? '',
      chapters: json['chapters'] ?? [],
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      readingStatus: readingStatus,
      isFavorite: isFavorite,
      isFree: json['is_free'] == true,
    );
  }


    /// Update reading status for an audiobook in progress_fr
  Future<void> editAudiobookStatus(Audiobook audiobook, String status) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      final contentId = audiobook.id;
      final existing = await _supabase
          .from('progress_fr')
          .select('id')
          .eq('content_id', contentId)
          .filter('chapter_id', 'is', 'null')
          .eq('user_id', user.id)
          .eq('content_type', 2)
          .maybeSingle();

      final payload = status == 'started' ? {
        'content_id': contentId,
        'user_id': user.id,
        'content_type': 2,
        'chapter_id': null,
        'reading_status': status,
        'started_datetime': DateTime.now().toIso8601String(),
      } : status == 'finished' ? {
          'content_id': contentId,
          'user_id': user.id,
          'content_type': 2,
          'chapter_id': null,
          'reading_status': status,
          'finished_datetime': DateTime.now().toIso8601String(),
        } : {
          'content_id': contentId,
          'user_id': user.id,
          'content_type': 2,
          'chapter_id': null,
          'reading_status': status,
        };

      if (existing != null && existing['id'] != null) {
        await _supabase
            .from('progress_fr')
            .update(payload)
            .eq('id', existing['id']);
      } else {
        await _supabase.from('progress_fr').insert(payload);
      }
    } catch (e) {
      print('Error editing audiobook status: $e');
    }
  }

  /// Toggle favorite (is_liked) for an audiobook in progress_fr
  Future<void> toggleFavorite(int audiobookId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    try {
      final existing = await _supabase
          .from('progress_fr')
          .select('id, reading_status, is_liked')
          .eq('content_id', audiobookId)
          .eq('user_id', user.id)
          .eq('content_type', 2)
          .filter('chapter_id', 'is', 'null')
          .maybeSingle();
      print('existing: $existing');
      print('isliked initial: ${existing?['is_liked']}');
      final bool isFavorite = existing != null ? existing['is_liked'] == true : false;
      final status = existing != null ? existing['reading_status'] as String? : null;
      final payload = {
        'content_id': audiobookId,
        'user_id': user.id,
        'content_type': 2,
        'chapter_id': null,
        'is_liked': !isFavorite,
        if (status != null) 'reading_status': status,
      };
      print('payload: $payload');
      if (existing != null && existing['id'] != null) {
        await _supabase
            .from('progress_fr')
            .update(payload)
            .eq('id', existing['id']);
      } else {
        await _supabase.from('progress_fr').insert(payload);
      }
    } catch (e) {
      print('Error toggling audiobook favorite: $e');
    }
  }

}

