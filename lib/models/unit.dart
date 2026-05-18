class Unit {
  final String text;
  final String translatedText;
  final String type; // "verb", "noun", "adjective", "adverb", "preposition", "conjunction", "interjection", "article", "pronoun", "other"
  final bool? punctuation;
  final bool? properName;
  final String? originVerb;
  final String? basis;

  /// Encyclopedic note for proper names, already resolved to the user's
  /// source (reference) language. Empty/absent when there is no note.
  final String? note;

  Unit({
    required this.text,
    required this.translatedText,
    required this.type,
    this.punctuation,
    this.properName,
    this.originVerb,
    this.basis,
    this.note,
  });
}


