/// Represents a word with its timestamp information from speech-to-text
class WordTimestamp {
  final String word; // The word as spoken
  final String? punctuatedWord; // The word with punctuation
  final double start; // Start time in seconds
  final double end; // End time in seconds
  final double confidence; // Confidence score (0.0 to 1.0)

  WordTimestamp({
    required this.word,
    this.punctuatedWord,
    required this.start,
    required this.end,
    required this.confidence,
  });

  factory WordTimestamp.fromJson(Map<String, dynamic> json) {
    return WordTimestamp(
      word: json['word'] ?? '',
      punctuatedWord: json['punctuated_word'],
      start: (json['start'] ?? 0.0).toDouble(),
      end: (json['end'] ?? 0.0).toDouble(),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'punctuated_word': punctuatedWord,
      'start': start,
      'end': end,
      'confidence': confidence,
    };
  }
}

