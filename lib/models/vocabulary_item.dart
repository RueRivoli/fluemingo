class VocabularyItem {
  final int? id; // id from vocabulary_fr table (created vocabulary item have undefined id)
  final String word;
  final String translation;
  final String type; // (n) noun, (v) verb, (adj) adjective, etc.
  final String? exampleSentence;
  final String? exampleTranslation;
  final String audioUrl;
  int? flashcardId;
  String? status; // "saved", "difficult", "training", "acknowledged"
  bool? isAddedByUser = false;

  VocabularyItem({
    this.id,
    required this.word,
    required this.translation,
    required this.type,
    this.exampleSentence,
    this.exampleTranslation,
    required this.audioUrl,
    this.flashcardId,
    this.status,
    this.isAddedByUser = false,
  });

  // "bookmarked" means status is not undefined
  // meaning status is "saved", "difficult", "training" or "acknowledged"
  bool get isBookmarked {
    if (status == null) return false;
    
    const validStatuses = ['saved', 'bookmarked', 'difficult', 'training', 'acknowledged'];
    return validStatuses.contains(status!.toLowerCase());
  }
}





