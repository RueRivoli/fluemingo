import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article.dart';
import '../models/audiobook.dart';
import '../utils/storage_url_helper.dart';
import 'language_table_resolver.dart';

class ProfileService {
  final SupabaseClient _supabase;
  ProfileService(this._supabase);

  String _table(String name) => LanguageTableResolver.table(name);

  String _getImageUrl(String? imgPath) =>
      StorageUrlHelper.getImageUrl(_supabase, imgPath);

  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  List<String> _parseStringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((item) => item?.toString().trim() ?? '')
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  List<String> _cleanThemeList(Iterable<dynamic> values) {
    return values
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  String _normalizeThemeValue(dynamic value) {
    return value?.toString().trim().toLowerCase() ?? '';
  }

  bool _rowMatchesAnyTheme(
      Map<String, dynamic> row, Set<String> normalizedThemes) {
    if (normalizedThemes.isEmpty) return false;
    final categories = [
      _normalizeThemeValue(row['category_1']),
      _normalizeThemeValue(row['category_2']),
      _normalizeThemeValue(row['category_3']),
    ];
    return categories.any((category) =>
        category.isNotEmpty && normalizedThemes.contains(category));
  }

  String _buildCategoryOrInFilter(List<String> themeList) {
    final themeInFilter =
        themeList.map((t) => '"${t.replaceAll('"', r'\"')}"').join(',');
    return 'category_1.in.($themeInFilter),category_2.in.($themeInFilter),category_3.in.($themeInFilter)';
  }

  /// Deletes the current user's account via the delete-account edge function.
  Future<void> deleteAccount() async {
    final response = await _supabase.functions.invoke('delete-account');
    if (response.status != 200) {
      throw Exception('Failed to delete account');
    }
  }

  Future<Map<String, dynamic>> getProfileData() async {
    try {
      final user = _supabase.auth.currentUser;
      final response =
          await _supabase.from('profiles').select().eq('id', user!.id).single();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateFullName(String fullName) async {
    try {
      final user = _supabase.auth.currentUser;
      await _supabase
          .from('profiles')
          .update({'full_name': fullName}).eq('id', user!.id);
    } catch (e) {
      rethrow;
    }
  }

  static const _allowedProfileFields = <String>{
    'target_language',
    'native_language',
    'avatar',
    'avatar_url',
    'weekly_goal',
    'full_name',
    'has_seen_welcome',
    'theme_interest_1',
    'theme_interest_2',
    'theme_interest_3',
    'theme_interest_4',
    'theme_interest_5',
    'updated_at',
  };

  Future<void> updateProfileData(Map<String, dynamic> profileData) async {
    try {
      final user = _supabase.auth.currentUser;
      final sanitized = Map<String, dynamic>.fromEntries(
        profileData.entries.where((e) => _allowedProfileFields.contains(e.key)),
      );
      if (sanitized.isEmpty) return;
      await _supabase.from('profiles').update(sanitized).eq('id', user!.id);
    } catch (e) {
      rethrow;
    }
  }

  static const _allowedInsertFields = <String>{
    'id',
    'full_name',
    'email',
    'avatar',
    'avatar_url',
    'target_language',
    'native_language',
    'weekly_goal',
    'has_seen_welcome',
    'theme_interest_1',
    'theme_interest_2',
    'theme_interest_3',
    'theme_interest_4',
    'theme_interest_5',
    'updated_at',
  };

  Future<void> insertProfile(Map<String, dynamic> profileData) async {
    try {
      final sanitized = Map<String, dynamic>.fromEntries(
        profileData.entries.where((e) => _allowedInsertFields.contains(e.key)),
      );
      if (sanitized.isEmpty) return;
      await _supabase.from('profiles').insert(sanitized);
    } catch (e) {
      rethrow;
    }
  }

  /// Atomically create-or-update the profile row with any allowed field.
  /// Prevents the split-state window where INSERT succeeds but UPDATE fails.
  Future<void> upsertProfile(Map<String, dynamic> profileData) async {
    final allowed = <String>{..._allowedInsertFields, ..._allowedProfileFields};
    final sanitized = Map<String, dynamic>.fromEntries(
      profileData.entries.where((e) => allowed.contains(e.key)),
    );
    if (sanitized.isEmpty) return;
    await _supabase.from('profiles').upsert(sanitized, onConflict: 'id');
  }

  /// True iff target_language, native_language and weekly_goal are all set
  /// for the currently authenticated user.
  Future<bool> isProfileComplete() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;
    final row = await _supabase
        .from('profiles')
        .select('target_language, native_language, weekly_goal')
        .eq('id', user.id)
        .maybeSingle();
    if (row == null) return false;
    final target = (row['target_language'] as String?)?.trim() ?? '';
    final native = (row['native_language'] as String?)?.trim() ?? '';
    final weeklyGoal = row['weekly_goal'];
    return target.isNotEmpty && native.isNotEmpty && weeklyGoal != null;
  }

  Future<void> updateProfile(String avatarUrl) async {
    try {
      final user = _supabase.auth.currentUser;
      final avatar = avatarUrl.trim();
      await _supabase.from('profiles').update({
        'avatar': avatar,
        'avatar_url': avatarUrl,
      }).eq('id', user!.id);
    } catch (e) {
      rethrow;
    }
  }

  /// Update the user's weekly goal (XP) in profiles.
  Future<void> updateWeeklyGoal(int weeklyGoalXP) async {
    try {
      final user = _supabase.auth.currentUser;
      await _supabase
          .from('profiles')
          .update({'weekly_goal': weeklyGoalXP}).eq('id', user!.id);
    } catch (e) {
      rethrow;
    }
  }

  /// Update the user's target language in profiles.
  Future<void> updateTargetLanguage(String targetLanguage) async {
    try {
      final user = _supabase.auth.currentUser;
      await _supabase
          .from('profiles')
          .update({'target_language': targetLanguage}).eq('id', user!.id);
    } catch (e) {
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
      rethrow;
    }
  }

  /// Update the user's reference (native) language in profiles.
  Future<void> updateNativeLanguage(String nativeLanguage) async {
    try {
      final user = _supabase.auth.currentUser;
      await _supabase
          .from('profiles')
          .update({'native_language': nativeLanguage}).eq('id', user!.id);
    } catch (e) {
      rethrow;
    }
  }

  /// Returns all registered push tokens for the authenticated user.
  Future<List<String>> getNotificationTokens() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return const [];
      final response = await _supabase
          .from('profiles')
          .select('notification_tokens')
          .eq('id', user.id)
          .maybeSingle();
      if (response == null) return const [];
      return _parseStringList(response['notification_tokens']);
    } catch (e) {
      rethrow;
    }
  }

  /// Adds a push token to profiles.notification_tokens if missing.
  Future<void> registerNotificationToken(String token) async {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) return;

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      final response = await _supabase
          .from('profiles')
          .select('notification_tokens')
          .eq('id', user.id)
          .maybeSingle();

      final currentTokens = response == null
          ? <String>[]
          : _parseStringList(response['notification_tokens']).toList();

      if (!currentTokens.contains(normalizedToken)) {
        currentTokens.add(normalizedToken);
      }

      // Keep only the 10 most recent tokens to avoid unbounded growth
      if (currentTokens.length > 10) {
        currentTokens.removeRange(0, currentTokens.length - 10);
      }

      final nowIso = DateTime.now().toUtc().toIso8601String();
      await _supabase.from('profiles').update({
        'notification_tokens': currentTokens,
        'notifications_enabled': true,
        'notification_tokens_updated_at': nowIso,
        'updated_at': nowIso,
      }).eq('id', user.id);
    } catch (e) {
      rethrow;
    }
  }

  /// Removes a push token from profiles.notification_tokens.
  Future<void> unregisterNotificationToken(String token) async {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) return;

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      final response = await _supabase
          .from('profiles')
          .select('notification_tokens')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) return;

      final currentTokens =
          _parseStringList(response['notification_tokens']).toList();
      currentTokens.removeWhere((value) => value == normalizedToken);

      final nowIso = DateTime.now().toUtc().toIso8601String();
      await _supabase.from('profiles').update({
        'notification_tokens': currentTokens,
        'notification_tokens_updated_at': nowIso,
        'updated_at': nowIso,
      }).eq('id', user.id);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Article>> getArticlesInProgress() async {
    try {
      final user = _supabase.auth.currentUser;
      final unfinishedArticles = await _supabase
          .from(_table('progress'))
          .select('*, ${_table('content')}!id(*)')
          .eq('reading_status', 'started')
          .eq('content_type', 1)
          .eq('user_id', user!.id);

      return (unfinishedArticles as List)
          .map((json) {
            final contentFr = json[_table('content')];
            if (contentFr is! Map<String, dynamic>) return null;
            final article = contentFr;
            return Article(
              id: article['id']?.toString() ?? '',
              title: article['title'] ?? '',
              description: article['description'] ?? '',
              author: article['author'] ?? '',
              imageUrl: _getImageUrl(
                  (article['image_url'] ?? article['img_url'])?.toString() ??
                      ''),
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
          })
          .whereType<Article>()
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Audiobook>> getAudiobooksInProgress() async {
    try {
      final user = _supabase.auth.currentUser;
      final unfinishedAudiobooks = await _supabase
          .from(_table('progress'))
          .select('*, ${_table('content')}!id(*)')
          .eq('reading_status', 'started')
          .filter('chapter_id', 'is', 'null')
          .eq('content_type', 2)
          .eq('user_id', user!.id);

      return (unfinishedAudiobooks as List)
          .map((json) {
            final contentFr = json[_table('content')];
            if (contentFr is! Map<String, dynamic>) return null;
            final audiobook = contentFr;
            return Audiobook(
              id: audiobook['id'] as int,
              title: audiobook['title'] ?? '',
              author: audiobook['author'] ?? '',
              description: audiobook['description'] ?? '',
              imageUrl: _getImageUrl(
                  (audiobook['image_url'] ?? audiobook['img_url'])
                          ?.toString() ??
                      ''),
              level: audiobook['level'] ?? 'A1',
              category1: audiobook['category_1'] ?? '',
              category2: audiobook['category_2'] ?? '',
              category3: audiobook['category_3'] ?? '',
              chapters: const [],
              createdAt: _parseDateTime(audiobook['created_at']),
              isFavorite: json['is_liked'] == true,
              isFree: audiobook['is_free'] == true,
            );
          })
          .whereType<Audiobook>()
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Returns the list of theme interests from the current user's profile.
  Future<List<String>> getThemeInterests() async {
    try {
      final user = _supabase.auth.currentUser;
      final profileRow = await _supabase
          .from('profiles')
          .select(
              'theme_interest_1, theme_interest_2, theme_interest_3, theme_interest_4, theme_interest_5')
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
      debugPrint('Error fetching theme interests: $e');
      return [];
    }
  }

  Future<List<Article>> getInterestingArticles() async {
    try {
      final user = _supabase.auth.currentUser;
      final profileRow = await _supabase
          .from('profiles')
          .select(
              'theme_interest_1, theme_interest_2, theme_interest_3, theme_interest_4, theme_interest_5')
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

      final cleanedThemes = _cleanThemeList(themeList);
      if (cleanedThemes.isEmpty) return [];
      final normalizedThemes =
          cleanedThemes.map((theme) => theme.toLowerCase()).toSet();
      final orFilter = _buildCategoryOrInFilter(cleanedThemes);

      final articlesResponse = await _supabase
          .from(_table('content'))
          .select(
              '*, ${_table('progress')}!content_id(reading_status, user_id, is_liked)')
          .eq('content_type', 1)
          .or(orFilter);

      var rows = (articlesResponse as List).whereType<Map<String, dynamic>>();
      if (rows.isEmpty) {
        // Fallback to local theme matching
        final fallbackResponse = await _supabase
            .from(_table('content'))
            .select(
                '*, ${_table('progress')}!content_id(reading_status, user_id, is_liked)')
            .eq('content_type', 1);
        rows = (fallbackResponse as List)
            .whereType<Map<String, dynamic>>()
            .where((row) => _rowMatchesAnyTheme(row, normalizedThemes));
      }

      return rows
          .where((json) {
            final progressFr = json[_table('progress')];
            if (progressFr == null) return true;
            final list = progressFr is List ? progressFr : [progressFr];
            final userProgress = list
                .cast<Map<String, dynamic>?>()
                .whereType<Map<String, dynamic>>()
                .where((p) => p['user_id'] == user.id)
                .firstOrNull;
            if (userProgress == null) return true;
            final status = userProgress['reading_status'] as String?;
            if (status == 'started' || status == 'finished') return false;
            final isLiked = userProgress['is_liked'] as bool?;
            if (isLiked == true) return false;
            return true;
          })
          .map((json) {
            final article = json;
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
          })
          .whereType<Article>()
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Audiobook>> getInterestingAudiobooks() async {
    try {
      final user = _supabase.auth.currentUser;
      final profileRow = await _supabase
          .from('profiles')
          .select(
              'theme_interest_1, theme_interest_2, theme_interest_3, theme_interest_4, theme_interest_5')
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

      final cleanedThemes = _cleanThemeList(themeList);
      if (cleanedThemes.isEmpty) return [];
      final normalizedThemes =
          cleanedThemes.map((theme) => theme.toLowerCase()).toSet();

      // Exclude audiobooks the user has started or finished (fr_progress: content_type 2, chapter_id null)
      final excludedProgress = await _supabase
          .from(_table('progress'))
          .select('content_id')
          .eq('user_id', user.id)
          .eq('content_type', 2)
          .filter('chapter_id', 'is', 'null')
          .inFilter('reading_status', ['started', 'finished']);
      final excludedContentIds = (excludedProgress as List)
          .map((r) => (r as Map<String, dynamic>)['content_id'])
          .whereType<int>()
          .toSet();

      final orFilter = _buildCategoryOrInFilter(cleanedThemes);

      final audiobooksResponse = await _supabase
          .from(_table('content'))
          .select()
          .eq('content_type', 2)
          .or(orFilter);

      var rows = (audiobooksResponse as List).whereType<Map<String, dynamic>>();
      if (rows.isEmpty) {
        // Fallback to local theme matching
        final fallbackResponse = await _supabase
            .from(_table('content'))
            .select()
            .eq('content_type', 2);
        rows = (fallbackResponse as List)
            .whereType<Map<String, dynamic>>()
            .where((row) => _rowMatchesAnyTheme(row, normalizedThemes));
      }

      return rows
          .where((json) {
            final id = json['id'];
            if (id == null) return true;
            return !excludedContentIds
                .contains(id is int ? id : int.tryParse(id.toString()));
          })
          .map((json) {
            final audiobook = json;
            return Audiobook(
              id: audiobook['id'],
              title: audiobook['title'] ?? '',
              author: audiobook['author'] ?? '',
              description: audiobook['description'] ?? '',
              imageUrl: _getImageUrl(
                  (audiobook['image_url'] ?? audiobook['img_url'])
                          ?.toString() ??
                      ''),
              level: audiobook['level'] ?? 'A1',
              category1: audiobook['category_1'] ?? '',
              category2: audiobook['category_2'] ?? '',
              category3: audiobook['category_3'] ?? '',
              chapters: [],
              createdAt: _parseDateTime(audiobook['created_at']),
              isFavorite: false, // attention
              isFree: audiobook['is_free'] == true,
            );
          })
          .whereType<Audiobook>()
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Article>> getFavoriteArticles() async {
    // We don't fetch in progress articles
    try {
      final user = _supabase.auth.currentUser;
      final favoriteArticles = await _supabase
          .from(_table('progress'))
          .select('*, ${_table('content')}!id(*)')
          .eq('is_liked', true)
          .eq('content_type', 1)
          .eq('user_id', user!.id);
      final list = favoriteArticles as List;
      return list
          .where((json) {
            final contentFr = json[_table('content')];
            if (contentFr == null || contentFr is! Map<String, dynamic>)
              return true;
            final status = json['reading_status'] as String?;
            if (status == 'started' || status == 'finished') return false;
            return true;
          })
          .map((json) {
            final contentFr = json[_table('content')];
            if (contentFr is! Map<String, dynamic>) return null;
            final article = contentFr;
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
          })
          .whereType<Article>()
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Audiobook>> getFavoriteAudiobooks() async {
    try {
      final user = _supabase.auth.currentUser;
      final favoriteAudiobooks = await _supabase
          .from(_table('progress'))
          .select('*, ${_table('content')}!id(*)')
          .eq('is_liked', true)
          .filter('chapter_id', 'is', 'null')
          .eq('content_type', 2)
          .eq('user_id', user!.id);
      // exclude audiobooks in progress
      return (favoriteAudiobooks as List)
          .where((json) {
            final contentFr = json[_table('content')];
            if (contentFr == null || contentFr is! Map<String, dynamic>)
              return true;
            final status = json['reading_status'] as String?;
            final exclude = status == 'started' || status == 'finished';
            return !exclude;
          })
          .map((json) {
            final contentFr = json[_table('content')];
            if (contentFr is! Map<String, dynamic>) return null;
            final audiobook = contentFr;
            return Audiobook(
              id: audiobook['id'],
              title: audiobook['title'] ?? '',
              author: audiobook['author'] ?? '',
              description: audiobook['description'] ?? '',
              imageUrl: _getImageUrl(
                  (audiobook['image_url'] ?? audiobook['img_url'])
                          ?.toString() ??
                      ''),
              level: audiobook['level'] ?? 'A1',
              category1: audiobook['category_1'] ?? '',
              category2: audiobook['category_2'] ?? '',
              category3: audiobook['category_3'] ?? '',
              chapters: const [],
              readingStatus: json['reading_status'] ?? null,
              createdAt: DateTime.tryParse(
                      audiobook['created_at']?.toString() ?? '') ??
                  DateTime.now(),
              isFavorite: true,
              isFree: audiobook['is_free'] == true,
            );
          })
          .whereType<Audiobook>()
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
