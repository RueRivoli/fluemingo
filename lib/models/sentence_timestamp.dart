/// Represents a sentence with its timestamp information from speech-to-text
class SentenceTimestamp {
  final String sentence; // The sentence as spoken
  final String? punctuatedSentence; // The sentence with punctuation
  final double start; // Start time in seconds
  final double end; // End time in seconds
  final double confidence; // Confidence score (0.0 to 1.0)

  SentenceTimestamp({
    required this.sentence,
    this.punctuatedSentence,
    required this.start,
    required this.end,
    required this.confidence,
  });

  factory SentenceTimestamp.fromJson(Map<String, dynamic> json) {
    return SentenceTimestamp(
      sentence: json['sentence'] ?? '',
      punctuatedSentence: json['punctuated_sentence'],
      start: (json['start'] ?? 0.0).toDouble(),
      end: (json['end'] ?? 0.0).toDouble(),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sentence': sentence,
      'punctuated_sentence': punctuatedSentence,
      'start': start,
      'end': end,
      'confidence': confidence,
    };
  }
}

