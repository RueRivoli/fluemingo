import '../models/vocabulary_item.dart';
import 'package:fluemingo/services/flashcard_service.dart';

Map<String, dynamic> vocabularyItemToFlashcardRow(
    VocabularyItem item, {
    required String userId,
    int? contentId,
    int? chapterId
  }) {
    return {
      if (contentId != null) 'content_id': contentId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (item.id != null) 'vocabulary_id': item.id,
      'function': item.type,
      'text': item.word,
      'text_translation': item.translation,
      'example': item.exampleSentence,
      'example_translation': item.exampleTranslation,
      'user_id': userId,
      'status': item.status
    };
}

  /// Maps a flashcards_fr Row (from database) to VocabularyItem
  VocabularyItem flashcardRowToVocabularyItem(
    Map<String, dynamic> row,
  ) {
    return VocabularyItem(
      id: row['vocabulary_id'] as int?,
      word: row['text'] ?? '',
      translation: row['text_translation'] ?? '',
      type: row['function'] ?? 'n',
      exampleSentence: row['example'],
      exampleTranslation: row['example_translation'],
      audioUrl: row['audio_url'] ?? '',
      flashcardId: row['id'] as int?,
      status: row['status'] as String?,
      isAddedByUser: row['vocabulary_id'] == null,
    );
  }

  String flashcardStatusToText(FlashcardStatus status) {
    switch (status) {
      case FlashcardStatus.saved:
        return 'Saved';
      case FlashcardStatus.difficult:
        return 'Difficult';
      case FlashcardStatus.training:
        return 'Training';
      case FlashcardStatus.mastered:
        return 'Mastered';
      default:
        return 'Unknown';
    }
  }