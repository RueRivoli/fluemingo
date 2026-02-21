import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vocabulary_item.dart';
import '../utils/flashcards.dart';

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

  const FlashcardService(this._supabase);

  /// Fetch all articles from Supabase
  Future<List<int>> getFlashcardsCount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [0, 0, 0, 0];
      
      // Select only 'id' to minimize data transfer, then get count from length
      final countBookmarked = _supabase
          .from('flashcards_fr')
          .select('id')
          .eq('user_id', user.id)
          .eq('status', 'saved');
      final countDifficult = _supabase
          .from('flashcards_fr')
          .select('id')
          .eq('user_id', user.id)
          .eq('status', 'difficult');
      
      final countTraining = _supabase
          .from('flashcards_fr')
          .select('id')
          .eq('user_id', user.id)
          .eq('status', 'training');
      
      final countMastered = _supabase
          .from('flashcards_fr')
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
      
      final response = await _supabase
          .from('flashcards_fr')
          .select()
          .eq('user_id', user.id)
          .eq('status', status ?? '');

      return (response as List).map((json) => _vocabularyItemFromJson(json)).toList();
    } catch (e) {
      print('Error fetching flashcards: $e');
      rethrow;
    }
  }
  Future<List<VocabularyItem>> updateFlashcardStatus(int id, String? status) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];
      
      final response = await _supabase
          .from('flashcards_fr')
          .update({'status': status, 'finished_datetime': status == 'mastered' ? DateTime.now().toIso8601String() : null})
          .eq('id', id)
          .eq('user_id', user.id);

      return response;
    } catch (e) {
      print('Error updating flashcard status: $e');
      rethrow;
    }
  }

  Future<List<VocabularyItem>> getFlashcards({String? status}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return [];
      
      var query = _supabase
          .from('flashcards_fr')
          .select()
          .eq('user_id', user.id);
      
      if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query;

      return (response as List).map((json) => _vocabularyItemFromJson(json)).toList();
    } catch (e) {
      print('Error fetching flashcards: $e');
      rethrow;
    }
  }

  /// Convert JSON to VocabularyItem model
  VocabularyItem _vocabularyItemFromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      id: json['id'] as int,
      word: json['text'] ?? '',
      translation: json['text_translation'] ?? '',
      type: json['function'] ?? 'n',
      exampleSentence: json['example'],
      exampleTranslation: json['example_translation'],
      audioUrl: json['audio_url'] ?? '',
      flashcardId: json['id'] as int?,
      status: json['status'] as String?,
      isAddedByUser: true,
    );
  }

  Future<Map<String, dynamic>?> addFlashcard(VocabularyItem vocabularyItem, int contentId, int? chapterId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      print('addFlashcard www');
      final newFlashcardRow = vocabularyItemToFlashcardRow(vocabularyItem, userId: user.id, contentId: contentId, chapterId: chapterId);
      print('newFlashcardRow: $newFlashcardRow');
      return await _supabase.from('flashcards_fr').insert(newFlashcardRow).select().single();
    } catch (e) {
      print('Error adding flashcard: $e');
      return null;
    }
  }

    Future<VocabularyItem?> editStatusFlashcard(int id, String status) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      print('editingFlashcard: $id');
      await _supabase.from('flashcards_fr').update({'status': status}).eq('id', id).eq('user_id', user.id);
    } catch (e) {
      print('Error editing status flashcard: $e');
      rethrow;
    }
  }


  Future<VocabularyItem?> deleteFlashcard(int id) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      print('deleteFlashcard: $id');
      await _supabase.from('flashcards_fr').delete().eq('id', id).eq('user_id', user.id);
    } catch (e) {
      print('Error deleting flashcard: $e');
      rethrow;
    }
  }

    Future<VocabularyItem?> deleteFlashcardWithText(String text, String type) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;
      final response = await _supabase.from('flashcards_fr').delete().eq('text', text).eq('function', type).eq('user_id', user.id);
      return response;
    } catch (e) {
      print('Error deleting flashcard: $e');
      rethrow;
    }
  }

    Future<Map<String, dynamic>?> isVocabularyItemAlreadySavedInThatArticle(String word, int contentId, int? chapterId) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      Map<String, dynamic>? response = null;
      if (user == null) return null;
      if (chapterId != null) {
        response = await supabase
            .from('flashcards_fr')
            .select('id')
            .eq('user_id', user.id)
            .eq('text', word)
            .eq('content_id', contentId)
            .eq('chapter_id', chapterId)
            .maybeSingle();
      } else {
        response = await supabase
            .from('flashcards_fr')
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

