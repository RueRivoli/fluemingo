class VocabularyItem {
  final String word;
  final String translation;
  final String type; // (n) noun, (v) verb, (adj) adjective, etc.
  bool isSaved;

  VocabularyItem({
    required this.word,
    required this.translation,
    required this.type,
    this.isSaved = false,
  });
}




