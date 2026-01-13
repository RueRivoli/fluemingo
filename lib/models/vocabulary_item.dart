class VocabularyItem {
  final String word;
  final String translation;
  final String type; // (n) noun, (v) verb, (adj) adjective, etc.
  final String audioUrl;
  bool isSaved;

  VocabularyItem({
    required this.word,
    required this.translation,
    required this.type,
    required this.audioUrl,
    this.isSaved = false,
  });
}





