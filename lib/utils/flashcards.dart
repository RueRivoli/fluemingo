import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/vocabulary_item.dart';
import 'package:fluemingo/services/flashcard_service.dart';
import 'package:fluemingo/l10n/app_localizations.dart';

Map<String, dynamic> vocabularyItemToFlashcardRow(VocabularyItem item,
    {required String userId, int? contentId, int? chapterId}) {
  return {
    if (contentId != null) 'content_id': contentId,
    if (chapterId != null) 'chapter_id': chapterId,
    if (item.id != null) 'vocabulary_id': item.id,
    'function': item.type,
    'text': item.word,
    'text_translation': item.translation,
    'example': item.exampleSentence,
    'example_translation': item.exampleTranslation,
    'basis': item.basis,
    'user_id': userId,
    'status': item.status,
    'audio_url': item.audioUrl,
  };
}

/// Safely parse int from Supabase row (may return num from JSON).
int? _rowInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

String _rowAudioUrl(dynamic value) {
  final path = (value ?? '').toString();
  if (path.isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;

  var cleanPath = path.startsWith('/') ? path.substring(1) : path;
  if (cleanPath.startsWith('content/')) {
    cleanPath = cleanPath.substring('content/'.length);
  }
  return Supabase.instance.client.storage
      .from('content')
      .getPublicUrl(cleanPath);
}

/// Maps a flashcards_fr Row (from database) to VocabularyItem
VocabularyItem flashcardRowToVocabularyItem(
  Map<String, dynamic> row,
) {
  return VocabularyItem(
    id: _rowInt(row['vocabulary_id']),
    word: (row['text'] ?? '') as String,
    translation: (row['text_translation'] ?? '') as String,
    type: (row['function'] ?? 'n') as String,
    exampleSentence: row['example'] as String?,
    exampleTranslation: row['example_translation'] as String?,
    audioUrl: _rowAudioUrl(row['audio_url']),
    basis: row['basis'] as String?,
    flashcardId: _rowInt(row['id']),
    status: row['status'] as String?,
    isAddedByUser: row['vocabulary_id'] == null,
  );
}

String flashcardStatusToText(BuildContext context, FlashcardStatus status) {
  switch (status) {
    case FlashcardStatus.saved:
      return AppLocalizations.of(context)!.saved;
    case FlashcardStatus.difficult:
      return AppLocalizations.of(context)!.difficult;
    case FlashcardStatus.training:
      return AppLocalizations.of(context)!.training;
    case FlashcardStatus.mastered:
      return AppLocalizations.of(context)!.mastered;
    default:
      return AppLocalizations.of(context)!.unknown;
  }
}
