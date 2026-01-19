class Unit {
  final String text;
  final String translatedText;
  final String type; // "verb", "noun", "adjective", "adverb", "preposition", "conjunction", "interjection", "article", "pronoun", "other"
  final bool? punctuation;
  final bool? properName;
  final String? originVerb;

  Unit({
    required this.text,
    required this.translatedText,
    required this.type,
    this.punctuation,
    this.properName,
    this.originVerb,
  });
}


