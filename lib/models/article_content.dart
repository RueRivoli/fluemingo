class ArticleContent {
  final String originalText; // Text in the target language (e.g., French)
  final String translationText; // Translation (e.g., English)
  final double? startTime; // Start timestamp in seconds
  final double? endTime; // End timestamp in seconds

  ArticleContent({
    required this.originalText,
    required this.translationText,
    this.startTime,
    this.endTime,
  });
}


