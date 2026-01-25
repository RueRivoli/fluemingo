import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vocabulary_item.dart';

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
      
      final countAcknowledged = _supabase
          .from('flashcards_fr')
          .select('id')
          .eq('user_id', user.id)
          .eq('status', 'acknowledged');
      
      final responses = await Future.wait([
        countBookmarked,
        countDifficult,
        countTraining,
        countAcknowledged,
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
          .update({'status': status})
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
      isAddedByUser: true,
    );
  }

}

