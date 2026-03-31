import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vocabulary_item.dart';
import '../utils/flashcards.dart';
import '../utils/storage_url_helper.dart';
import '../utils/reference_language.dart';
import '../utils/localization_field_resolver.dart';
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

  FlashcardService(this._supabase);

  String _table(String name) => LanguageTableResolver.table(name);

  Future<String> _getReferenceLanguageCode() =>
      ReferenceLanguage.getReferenceLanguageCode(_supabase);

  String _getAudioUrl(String? path) =>
      StorageUrlHelper.getAudioUrl(_supabase, path) ?? '';

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
      return (response as List)
          .map((json) => _vocabularyItemFromJson(
                json,
                referenceLanguageCode: referenceLanguageCode,
              ))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateFlashcardStatus(int id, String? status) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase
          .from(_table('flashcards'))
          .update({
            'status': status,
            'finished_datetime':
                status == 'mastered' ? DateTime.now().toIso8601String() : null
          })
          .eq('id', id)
          .eq('user_id', user.id);
    } catch (e) {
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
        ? LocalizationFieldResolver.localizedVocabularyFieldValue(
            source: vocabularyRow,
            baseField: 'text',
            referenceLanguageCode: referenceLanguageCode,
          )
        : '';
    final localizedExampleTranslation = vocabularyRow != null
        ? LocalizationFieldResolver.localizedVocabularyFieldValue(
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
       properName: json['properName'] ?? false,
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

      // Check if this flashcard already exists for this user/word/content
      final existing = await isVocabularyItemAlreadySavedInThatArticle(
          vocabularyItem.word, contentId, chapterId);
      if (existing != null) {
        // Update existing flashcard
        await _supabase
            .from(_table('flashcards'))
            .update(newFlashcardRow)
            .eq('id', existing['id']);
        return await _supabase
            .from(_table('flashcards'))
            .select()
            .eq('id', existing['id'])
            .single();
      }
      return await _supabase
          .from(_table('flashcards'))
          .insert(newFlashcardRow)
          .select()
          .single();
    } catch (e) {
      debugPrint('Error adding flashcard: $e');
      return null;
    }
  }

  Future<void> deleteFlashcard(int id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      await _supabase
          .from(_table('flashcards'))
          .delete()
          .eq('id', id)
          .eq('user_id', user.id);
    } catch (e) {
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
      debugPrint('Error checking if vocabulary item is saved: $e');
      return null;
    }
  }
}
