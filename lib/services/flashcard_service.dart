import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vocabulary_item.dart';
import '../utils/flashcards.dart';
import 'language_table_resolver.dart';

enum FlashcardStatus {
  saved('saved'),
  difficult('difficult'),
  training('training'),
  mastered('mastered');

  final String value;
  const FlashcardStatus(this.value);

  /// Convert from string (useful when reading from database)
  static FlashcardStatus? fromString(String? status) {
    if (status == null) return null;
    for (var statusEnum in FlashcardStatus.values) {
      if (statusEnum.value == status) {
        return statusEnum;
      }
    }
    return null;
  }
}

class FlashcardService {
  final SupabaseClient _supabase;
  String? _cachedReferenceLanguageCode;

  FlashcardService(this._supabase);

  String _table(String name) => LanguageTableResolver.table(name);
  static const String _storageBucket = 'content';

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
      print('Error fetching reference language for flashcards: $e');
    }

    return 'en';
  }

  String _getAudioUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;

    var cleanPath = path.startsWith('/') ? path.substring(1) : path;
    if (cleanPath.startsWith('content/')) {
      cleanPath = cleanPath.substring('content/'.length);
    }
    return _supabase.storage.from(_storageBucket).getPublicUrl(cleanPath);
  }

  /// Fetch all articles from Supabase
  Future<List<int>> getFlashcardsCount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [0, 0, 0, 0];

      // Select only 'id' to minimize data transfer, then get count from length
      final countBookmarked = _supabase
          .from(_table('flashcards'))
          .select('id')
          .eq('user_id', user.id)
          .eq('status', 'saved');
      final countDifficult = _supabase
          .from(_table('flashcards'))
          .select('id')
          .eq('user_id', user.id)
          .eq('status', 'difficult');

      final countTraining = _supabase
          .from(_table('flashcards'))
          .select('id')
          .eq('user_id', user.id)
          .eq('status', 'training');

      final countMastered = _supabase
          .from(_table('flashcards'))
          .select('id')
          .eq('user_id', user.id)
          .eq('status', 'mastered');

      final responses = await Future.wait([
        countBookmarked,
        countDifficult,
        countTraining,
        countMastered,
      ]);

      // Extract counts from responses
      return [
        (responses[0] as List).length,
        (responses[1] as List).length,
        (responses[2] as List).length,
        (responses[3] as List).length,
      ];
    } catch (e) {
      print('Error fetching flashcards count: $e');
      rethrow;
    }
  }

  Future<List<VocabularyItem>> getFlashcardsWithStatus({String? status}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];
      final referenceLanguageCode = await _getReferenceLanguageCode();

      final response = await _supabase
          .from(_table('flashcards'))
          .select('*, ${_table('vocabulary')}!vocabulary_id(*)')
          .eq('user_id', user.id)
          .eq('status', status ?? '');
      print('response: ${response.map((e) => e['vocabulary_id'])}');
      return (response as List)
          .map((json) => _vocabularyItemFromJson(
                json,
                referenceLanguageCode: referenceLanguageCode,
              ))
          .toList();
    } catch (e) {
      print('Error fetching flashcards: $e');
      rethrow;
    }
  }

  Future<void> updateFlashcardStatus(int id, String? status) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from(_table('flashcards'))
          .update({
            'status': status,
            'finished_datetime':
                status == 'mastered' ? DateTime.now().toIso8601String() : null
          })
          .eq('id', id)
          .eq('user_id', user.id);
    } catch (e) {
      print('Error updating flashcard status: $e');
      rethrow;
    }
  }

  Future<List<VocabularyItem>> getFlashcards({String? status}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];
      final referenceLanguageCode = await _getReferenceLanguageCode();

      var query = _supabase
          .from(_table('flashcards'))
          .select('*, ${_table('vocabulary')}!vocabulary_id(*)')
          .eq('user_id', user.id);

      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query;

      return (response as List)
          .map((json) => _vocabularyItemFromJson(
                json,
                referenceLanguageCode: referenceLanguageCode,
              ))
          .toList();
    } catch (e) {
      print('Error fetching flashcards: $e');
      rethrow;
    }
  }

  /// Convert JSON to VocabularyItem model
  VocabularyItem _vocabularyItemFromJson(
    Map<String, dynamic> json, {
    String referenceLanguageCode = 'en',
  }) {
    Map<dynamic, dynamic>? vocabularyRow;
    final joinedVocabulary = json[_table('vocabulary')];
    if (joinedVocabulary is Map) {
      vocabularyRow = joinedVocabulary;
    } else if (joinedVocabulary is List &&
        joinedVocabulary.isNotEmpty &&
        joinedVocabulary.first is Map) {
      vocabularyRow = joinedVocabulary.first as Map;
    }

    final localizedTranslation = vocabularyRow != null
        ? _localizedVocabularyFieldValue(
            source: vocabularyRow,
            baseField: 'text',
            referenceLanguageCode: referenceLanguageCode,
          )
        : '';
    final localizedExampleTranslation = vocabularyRow != null
        ? _localizedVocabularyFieldValue(
            source: vocabularyRow,
            baseField: 'example',
            referenceLanguageCode: referenceLanguageCode,
          )
        : '';

    return VocabularyItem(
      id: json['id'] as int,
      word: json['text'] ?? '',
      translation: localizedTranslation.isNotEmpty
          ? localizedTranslation
          : (json['text_translation'] ?? ''),
      type: json['function'] ?? 'n',
      exampleSentence: json['example'],
      exampleTranslation: localizedExampleTranslation.isNotEmpty
          ? localizedExampleTranslation
          : json['example_translation'],
      audioUrl: _getAudioUrl(json['audio_url']),
      basis: json['basis'] ?? '',
      flashcardId: json['id'] as int?,
      status: json['status'] as String?,
      isAddedByUser: json['vocabulary_id'] == null,
    );
  }

  Future<Map<String, dynamic>?> addFlashcard(
      VocabularyItem vocabularyItem, int contentId, int? chapterId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      final newFlashcardRow = vocabularyItemToFlashcardRow(vocabularyItem,
          userId: user.id, contentId: contentId, chapterId: chapterId);
      return await _supabase
          .from(_table('flashcards'))
          .insert(newFlashcardRow)
          .select()
          .single();
    } catch (e) {
      print('Error adding flashcard: $e');
      return null;
    }
  }

  Future<VocabularyItem?> deleteFlashcard(int id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      await _supabase
          .from(_table('flashcards'))
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);
    } catch (e) {
      print('Error deleting flashcard: $e');
      rethrow;
    }
  }

  Future<VocabularyItem?> deleteFlashcardWithText(
      String text, String type) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      final response = await _supabase
          .from(_table('flashcards'))
          .delete()
          .eq('text', text)
          .eq('function', type)
          .eq('user_id', user.id);
      return response;
    } catch (e) {
      print('Error deleting flashcard: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> isVocabularyItemAlreadySavedInThatArticle(
      String word, int contentId, int? chapterId) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      Map<String, dynamic>? response = null;
      if (user == null) return null;
      if (chapterId != null) {
        response = await supabase
            .from(_table('flashcards'))
            .select('id')
            .eq('user_id', user.id)
            .eq('text', word)
            .eq('content_id', contentId)
            .eq('chapter_id', chapterId)
            .maybeSingle();
      } else {
        response = await supabase
            .from(_table('flashcards'))
            .select('id')
            .eq('user_id', user.id)
            .eq('text', word)
            .eq('content_id', contentId)
            .maybeSingle();
      }
      return response;
    } catch (e) {
      print('Error checking if vocabulary item is saved: $e');
      return null;
    }
  }
}
