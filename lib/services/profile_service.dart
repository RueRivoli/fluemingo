import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz_question.dart';
import '../models/article.dart';
import '../models/audiobook.dart';
import '../models/profile.dart';
class ProfileService {
  final SupabaseClient _supabase;
  ProfileService(this._supabase);

    static const String _storageBucket = 'content'; // Main storage bucket


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

  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  Future<Map<String, dynamic>> getProfileData() async {
    try {
      final user = _supabase.auth.currentUser;
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', user!.id)
          .single();
      return response;
    } catch (e) {
      print('Error fetching profile data: $e');
      rethrow;
    }
  }

  /// Update the user's weekly goal (XP) in profiles.
  Future<void> updateWeeklyGoal(int weeklyGoalXP) async {
    try {
      final user = _supabase.auth.currentUser;
      await _supabase
          .from('profiles')
          .update({'weekly_goal': weeklyGoalXP})
          .eq('id', user!.id);
    } catch (e) {
      print('Error updating weekly goal: $e');
      rethrow;
    }
  }

  /// Update the user's target language in profiles.
  Future<void> updateTargetLanguage(String targetLanguage) async {
    try {
      final user = _supabase.auth.currentUser;
      await _supabase
          .from('profiles')
          .update({'target_language': targetLanguage})
          .eq('id', user!.id);
    } catch (e) {
      print('Error updating target language: $e');
      rethrow;
    }
  }

  Future<void> updateThemeInterests(List<String> themes) async {
    try {
      final user = _supabase.auth.currentUser;
      final data = <String, String?>{};
      for (int i = 0; i < 5; i++) {
        data['theme_interest_${i + 1}'] = i < themes.length ? themes[i] : null;
      }
      await _supabase.from('profiles').update(data).eq('id', user!.id);
    } catch (e) {
      print('Error updating theme interests: $e');
      rethrow;
    }
  }

  /// Update the user's reference (native) language in profiles.
  Future<void> updateNativeLanguage(String nativeLanguage) async {
    try {
      final user = _supabase.auth.currentUser;
      await _supabase
          .from('profiles')
          .update({'native_language': nativeLanguage})
          .eq('id', user!.id);
    } catch (e) {
      print('Error updating native language: $e');
      rethrow;
    }
  }

  /// Start of current week (Monday 00:00 UTC) as ISO string for Supabase.
  static String _startOfWeekIso() {
    final now = DateTime.now().toUtc();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime.utc(monday.year, monday.month, monday.day);
    return start.toIso8601String();
  }

  /// Weekly activity counts: articles read, audiobooks read, flashcards achieved, quizzes completed.
  Future<Map<String, int>> getWeeklyProgress() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return {
        'articles': 0,
        'audiobooks': 0,
        'flashcards': 0,
        'quizzes': 0,
      };
    }
    final startOfWeek = _startOfWeekIso();
    try {
      final articlesRes = await _supabase
          .from('progress_fr')
          .select('id')
          .eq('user_id', user.id)
          .eq('content_type', 1)
          .eq('reading_status', 'finished')
          .gte('finished_datetime', startOfWeek);
      final audiobooksRes = await _supabase
          .from('progress_fr')
          .select('id')
          .eq('user_id', user.id)
          .eq('content_type', 2)
          .eq('reading_status', 'finished')
          .gte('finished_datetime', startOfWeek);
      final flashcardsRes = await _supabase
          .from('flashcards_fr')
          .select('id')
          .eq('user_id', user.id)
          .eq('status', 'mastered')
          .gte('finished_datetime', startOfWeek);
      final quizzesRes = await _supabase
          .from('quiz_results_fr')
          .select('id')
          .eq('user_id', user.id)
          .gte('finished_datetime', startOfWeek);
      return {
        'articles': (articlesRes as List).length,
        'audiobooks': (audiobooksRes as List).length,
        'flashcards': (flashcardsRes as List).length,
        'quizzes': (quizzesRes as List).length,
      };
    } catch (e) {
      print('Error fetching weekly progress: $e');
      return {
        'articles': 0,
        'audiobooks': 0,
        'flashcards': 0,
        'quizzes': 0,
      };
    }
  }

  Future<List<Article>> getArticlesInProgress() async {
    print('-- get Unfinished Articles -- ');
    try {
      final user = _supabase.auth.currentUser;
      final unfinishedArticles = await _supabase
          .from('progress_fr')
          .select('*, content_fr!id(*)')
          .eq('reading_status', 'started')
          .eq('content_type', 1)
          .eq('user_id', user!.id);

      return (unfinishedArticles as List).map((json) {
        final contentFr = json['content_fr'];
        if (contentFr is! Map<String, dynamic>) return null;
        final article = contentFr as Map<String, dynamic>;
        return Article(
          id: article['id']?.toString() ?? '',
          title: article['title'] ?? '',
          description: article['description'] ?? '',
          author: article['author'] ?? '',
          imageUrl: _getImageUrl((article['image_url'] ?? article['img_url'])?.toString() ?? ''),
          level: article['level'] ?? 'A1',
          category1: article['category_1'] ?? '',
          category2: article['category_2'] ?? '',
          category3: article['category_3'] ?? '',
          readingStatus: json['reading_status'] ?? null,
          vocabulary: const [],
          grammarPoints: const [],
          paragraphs: const [],
          audioUrl: article['audio_url']?.toString(),
          contentType: (article['content_type'] as int?) ?? 1,
          isFavorite: json['is_liked'] == true,
          isFree: article['is_free'] == true,
        );
      }).whereType<Article>().toList();
    } catch (e) {
      print('Error fetching unfinished articles: $e');
      rethrow;
    }
  }

  Future<List<Audiobook>> getAudiobooksInProgress() async {
    print('-- get Unfinished Audiobooks -- ');
      try {
        final user = _supabase.auth.currentUser;
        final unfinishedAudiobooks = await _supabase
            .from('progress_fr')
            .select('*, content_fr!id(*)')
            .eq('reading_status', 'started')
            .filter('chapter_id', 'is', 'null')
            .eq('content_type', 2)
            .eq('user_id', user!.id);

        return (unfinishedAudiobooks as List).map((json) {
          final contentFr = json['content_fr'];
          if (contentFr is! Map<String, dynamic>) return null;
          final audiobook = contentFr as Map<String, dynamic>;
          return Audiobook(
            id: audiobook['id'] as int,
            title: audiobook['title'] ?? '',
            author: audiobook['author'] ?? '',
            description: audiobook['description'] ?? '',
            imageUrl: _getImageUrl((audiobook['image_url'] ?? audiobook['img_url'])?.toString() ?? ''),
            level: audiobook['level'] ?? 'A1',
            category1: audiobook['category_1'] ?? '',
            category2: audiobook['category_2'] ?? '',
            category3: audiobook['category_3'] ?? '',
            chapters: const [],
            createdAt: _parseDateTime(audiobook['created_at']),
            isFavorite: json['is_liked'] == true,
            isFree: audiobook['is_free'] == true,
          );
        }).whereType<Audiobook>().toList();
      } catch (e) {
        print('Error fetching unfinished articles: $e');
        rethrow;
      }
    }

    /// Returns the list of theme interests from the current user's profile.
    Future<List<String>> getThemeInterests() async {
      try {
        final user = _supabase.auth.currentUser;
        final profileRow = await _supabase
            .from('profiles')
            .select('theme_interest_1, theme_interest_2, theme_interest_3, theme_interest_4, theme_interest_5')
            .eq('id', user!.id)
            .maybeSingle();
        return [
          profileRow?['theme_interest_1'],
          profileRow?['theme_interest_2'],
          profileRow?['theme_interest_3'],
          profileRow?['theme_interest_4'],
          profileRow?['theme_interest_5'],
        ].whereType<String>().where((s) => s.isNotEmpty).toList();
      } catch (e) {
        print('Error fetching theme interests: $e');
        return [];
      }
    }

    Future<List<Article>> getInterestingArticles() async {
      try {
        print('-- get Interesting Articles -- ');
        final user = _supabase.auth.currentUser;
        final profileRow = await _supabase
            .from('profiles')
            .select('theme_interest_1, theme_interest_2, theme_interest_3, theme_interest_4, theme_interest_5')
            .eq('id', user!.id)
            .maybeSingle();

        final themeList = [
          profileRow?['theme_interest_1'],
          profileRow?['theme_interest_2'],
          profileRow?['theme_interest_3'],
          profileRow?['theme_interest_4'],
          profileRow?['theme_interest_5'],
        ].whereType<String>().where((s) => s.isNotEmpty).toList();
        print('<><><> themeList: $themeList <><><>');
        if (themeList.isEmpty) return [];

        // Match rows where any of category1, category2, or category3 is in themeList
        final themeInFilter = themeList.map((t) => '"${t.replaceAll('"', '\\"')}"').join(',');
        final orFilter = 'category_1.in.($themeInFilter),category_2.in.($themeInFilter),category_3.in.($themeInFilter)';

        final articlesOfInterest = await _supabase
            .from('content_fr')
            .select('*, progress_fr!content_id(reading_status, user_id, is_liked)')
            .eq('content_type', 1)
            .or(orFilter);
        print('<><><> interestingArticles: $articlesOfInterest <><><>');
        final list = articlesOfInterest as List;
        return list.where((json) {
          final progressFr = json['progress_fr'];
          if (progressFr == null) return true;
          final list = progressFr is List ? progressFr as List : [progressFr];
          final userProgress = list.cast<Map<String, dynamic>?>().whereType<Map<String, dynamic>>().where((p) => p['user_id'] == user.id).firstOrNull;
          if (userProgress == null) return true;
          final status = userProgress['reading_status'] as String?;
          if (status == 'started' || status == 'finished') return false;
           final isLiked = userProgress['is_liked'] as bool?;
           if (isLiked == true) return false;
          return true;
        }).map((json) {
          final article = json as Map<String, dynamic>;
          return Article(
            id: article['id']?.toString() ?? '',
            title: article['title'] ?? '',
            description: article['description'] ?? '',
            author: article['author'] ?? '',
            imageUrl: _getImageUrl(article['img_url']),
            level: article['level'] ?? 'A1',
            category1: article['category_1'] ?? '',
            category2: article['category_2'] ?? '',
            category3: article['category_3'] ?? '',
            readingStatus: json['reading_status'] ?? null,
            vocabulary: const [],
            grammarPoints: const [],
            paragraphs: const [],
            audioUrl: article['audio_url']?.toString(),
            contentType: (article['content_type'] as int?) ?? 1,
            isFavorite: false,
            isFree: article['is_free'] == true,
          );
        }).whereType<Article>().toList();
      } catch (e) {
        print('Error fetching articles of interests: $e');
        rethrow;
      }
    }

    Future<List<Audiobook>> getInterestingAudiobooks() async {
      try {
        print('getInterestingAudiobooks');
        final user = _supabase.auth.currentUser;
        final profileRow = await _supabase
            .from('profiles')
            .select('theme_interest_1, theme_interest_2, theme_interest_3, theme_interest_4, theme_interest_5')
            .eq('id', user!.id)
            .maybeSingle();

        final themeList = [
          profileRow?['theme_interest_1'],
          profileRow?['theme_interest_2'],
          profileRow?['theme_interest_3'],
          profileRow?['theme_interest_4'],
          profileRow?['theme_interest_5'],
        ].whereType<String>().where((s) => s.isNotEmpty).toList();

        if (themeList.isEmpty) return [];

        // Exclude audiobooks the user has started or finished (progress_fr: content_type 2, chapter_id null)
        final excludedProgress = await _supabase
            .from('progress_fr')
            .select('content_id')
            .eq('user_id', user.id)
            .eq('content_type', 2)
            .filter('chapter_id', 'is', 'null')
            .inFilter('reading_status', ['started', 'finished']);
        final excludedContentIds = (excludedProgress as List)
            .map((r) => (r as Map<String, dynamic>)['content_id'])
            .whereType<int>()
            .toSet();

        // Match rows where any of category1, category2, or category3 is in themeList
        final themeInFilter = themeList.map((t) => '"${t.replaceAll('"', '\\"')}"').join(',');
        final orFilter = 'category_1.in.($themeInFilter),category_2.in.($themeInFilter),category_3.in.($themeInFilter)';

        final audiobooksOfInterest = await _supabase
            .from('content_fr')
            .select()
            .eq('content_type', 2)
            .or(orFilter);

        return (audiobooksOfInterest as List)
            .where((json) {
              final row = json as Map<String, dynamic>;
              final id = row['id'];
              if (id == null) return true;
              return !excludedContentIds.contains(id is int ? id : int.tryParse(id.toString()));
            })
            .map((json) {
          final audiobook = json as Map<String, dynamic>;
          return Audiobook(
            id: audiobook['id'],
            title: audiobook['title'] ?? '',
            author: audiobook['author'] ?? '',
            description: audiobook['description'] ?? '',
            imageUrl: _getImageUrl((audiobook['image_url'] ?? audiobook['img_url'])?.toString() ?? ''),
            level: audiobook['level'] ?? 'A1',
            category1: audiobook['category_1'] ?? '',
            category2: audiobook['category_2'] ?? '',
            category3: audiobook['category_3'] ?? '',
            chapters: [],
            createdAt: _parseDateTime(audiobook['created_at']),
            isFavorite: false, // attention
            isFree: audiobook['is_free'] == true,
          );
        }).whereType<Audiobook>().toList();
      } catch (e) {
        print('Error fetching audiobooks of interests: $e');
        rethrow;
      }
    }

    Future<List<Article>> getFavoriteArticles() async {
      // We don't fetch in progress articles
      print('-- get Favorite Articles -- ');
      try {
        final user = _supabase.auth.currentUser;
        final favoriteArticles = await _supabase
            .from('progress_fr')
            .select('*, content_fr!id(*)')
            .eq('is_liked', true)
            .eq('content_type', 1)
            .eq('user_id', user!.id);
        final list = favoriteArticles as List;
        return list.where((json) {
          final contentFr = json['content_fr'];
          if (contentFr == null || contentFr is! Map<String, dynamic>) return true;
          final status = json['reading_status'] as String?;
          if (status == 'started' || status == 'finished') return false;
          return true;
        }).map((json) {
          final contentFr = json['content_fr'];
          if (contentFr is! Map<String, dynamic>) return null;
          final article = contentFr as Map<String, dynamic>;
          return Article(
            id: article['id']?.toString() ?? '',
            title: article['title'] ?? '',
            description: article['description'] ?? '',
            author: article['author'] ?? '',
            imageUrl: _getImageUrl(article['img_url']),
            level: article['level'] ?? 'A1',
            category1: article['category_1'] ?? '',
            category2: article['category_2'] ?? '',
            category3: article['category_3'] ?? '',
            readingStatus: json['reading_status'] ?? null,
            vocabulary: const [],
            grammarPoints: const [],
            paragraphs: const [],
            audioUrl: article['audio_url']?.toString(),
            contentType: (article['content_type'] as int?) ?? 1,
            isFavorite: json['is_liked'] == true,
            isFree: article['is_free'] == true,
          );
        }).whereType<Article>().toList();
      } catch (e) {
        print('Error fetching favorite articles: $e');
        rethrow;
      }
    }

    Future<List<Audiobook>> getFavoriteAudiobooks() async {
      try {
        final user = _supabase.auth.currentUser;
        final favoriteAudiobooks = await _supabase
            .from('progress_fr')
            .select('*, content_fr!id(*)')
            .eq('is_liked', true)
            .filter('chapter_id', 'is', 'null')
            .eq('content_type', 2)
            .eq('user_id', user!.id);
        // exclude audiobooks in progress
        return (favoriteAudiobooks as List)
            .where((json) {
              final contentFr = json['content_fr'];
              if (contentFr == null || contentFr is! Map<String, dynamic>) return true;
              final status = json['reading_status'] as String?;
              final exclude = status == 'started' || status == 'finished';
              return !exclude;
            })
            .map((json) {
          final contentFr = json['content_fr'];
          if (contentFr is! Map<String, dynamic>) return null;
          final audiobook = contentFr as Map<String, dynamic>;
          return Audiobook(
            id: audiobook['id'],
            title: audiobook['title'] ?? '',
            author: audiobook['author'] ?? '',
            description: audiobook['description'] ?? '',
            imageUrl: _getImageUrl((audiobook['image_url'] ?? audiobook['img_url'])?.toString() ?? ''),
            level: audiobook['level'] ?? 'A1',
            category1: audiobook['category_1'] ?? '',
            category2: audiobook['category_2'] ?? '',
            category3: audiobook['category_3'] ?? '',
            chapters: const [],
            readingStatus: json['reading_status'] ?? null,
            createdAt: DateTime.tryParse(audiobook['created_at']?.toString() ?? '') ?? DateTime.now(),
            isFavorite: true,
            isFree: audiobook['is_free'] == true,
          );
        }).whereType<Audiobook>().toList();
      } catch (e) {
        print('Error fetching favorite audiobooks: $e');
        rethrow;
      }
    }

}

